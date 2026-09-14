import Foundation
import KeyboardCore
import XCTest

@testable import Universe_Keyboard

@MainActor
final class ReleaseEvidenceStoreTests: XCTestCase {
    func testStoreRoundTripsAReleaseEvidenceRun() async throws {
        let rootURL = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let fileURL = rootURL.appendingPathComponent("records.json")
        let store = ReleaseEvidenceFileStore(fileURL: fileURL)
        let run = makeRun(candidateID: "Build-56")

        try await store.save(run)
        let loaded = try await store.load()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, run.id)
        XCTAssertEqual(loaded.first?.candidateID, "Build-56")
        XCTAssertEqual(loaded.first?.steps, run.steps)
    }

    func testStoreKeepsOnlyTheNewestFiftyRuns() async throws {
        let rootURL = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let store = ReleaseEvidenceFileStore(
            fileURL: rootURL.appendingPathComponent("records.json")
        )

        for index in 0..<60 {
            let date = Date(timeIntervalSince1970: TimeInterval(index))
            try await store.save(makeRun(candidateID: "Build-\(index)", date: date))
        }

        let loaded = try await store.load()
        XCTAssertEqual(loaded.count, ReleaseEvidenceFileStore.maximumRunCount)
        XCTAssertEqual(loaded.first?.candidateID, "Build-59")
        XCTAssertEqual(loaded.last?.candidateID, "Build-10")
    }

    func testRunOutcomeFailsClosedForIncompleteSteps() {
        let run = makeRun(
            steps: [
                ReleaseEvidenceStep(scope: .candidateIdentity, outcome: .pass),
                ReleaseEvidenceStep(scope: .affectedPathSmoke, outcome: .notRun),
            ]
        )

        XCTAssertEqual(run.outcome, .partial)
        XCTAssertFalse(run.isCompletePass)
    }

    func testEmptyRunDoesNotReportPass() {
        let run = makeRun(steps: [])

        XCTAssertEqual(run.outcome, .notRun)
        XCTAssertFalse(run.isCompletePass)
    }

    func testEvidenceReuseIsOnlyRequiredForExternalCandidates() {
        let dailyScopes = ReleaseEvidenceScope.defaultScopes(
            lane: .dailyBeta,
            profile: .delta
        )
        let externalScopes = ReleaseEvidenceScope.defaultScopes(
            lane: .externalCandidate,
            profile: .delta
        )

        XCTAssertFalse(dailyScopes.contains(.evidenceReuse))
        XCTAssertTrue(externalScopes.contains(.evidenceReuse))
    }

    func testSessionRequiresAStableCandidateIdentifier() async throws {
        let rootURL = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let store = ReleaseEvidenceFileStore(
            fileURL: rootURL.appendingPathComponent("records.json")
        )
        let model = ReleaseEvidenceSessionModel(
            storage: store,
            deviceModel: "Test Device",
            osVersion: "Test OS"
        )

        model.candidateID = "Build 56"
        model.startSession()
        XCTAssertTrue(model.runs.isEmpty)
        XCTAssertNotNil(model.candidateIDError)

        model.candidateID = "Build-56"
        model.startSession()
        XCTAssertEqual(model.runs.count, 1)
        XCTAssertEqual(model.selectedRun?.candidateID, "Build-56")

        await waitUntil { !model.isSaving }
        let loaded = try await store.load()
        XCTAssertEqual(loaded.first?.candidateID, "Build-56")
    }

    func testPromotionKeepsExternalReadinessSeparateFromBetaEvidence() async throws {
        let rootURL = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let store = ReleaseEvidenceFileStore(
            fileURL: rootURL.appendingPathComponent("records.json")
        )
        let model = ReleaseEvidenceSessionModel(
            storage: store,
            deviceModel: "Test Device",
            osVersion: "Test OS"
        )

        model.candidateID = "Build-56"
        model.startSession()
        await waitUntil { !model.isSaving }
        guard let source = model.selectedRun else {
            return XCTFail("expected a daily Beta run")
        }

        for step in source.steps {
            model.setOutcome(.pass, for: step.scope, in: source.id)
            await waitUntil { !model.isSaving }
        }

        XCTAssertTrue(model.canPromoteSelectedRun)
        model.promoteSelectedRun()
        await waitUntil { !model.isSaving }

        guard let promoted = model.selectedRun else {
            return XCTFail("expected a promoted external candidate run")
        }
        XCTAssertEqual(promoted.lane, .externalCandidate)
        XCTAssertEqual(promoted.promotionSourceRunID, source.id)
        XCTAssertEqual(promoted.promotionMode, .pendingArtifactMatch)
        XCTAssertEqual(promoted.outcome, .partial)
        XCTAssertEqual(
            promoted.steps.last?.scope,
            .externalReadiness
        )
        XCTAssertEqual(promoted.steps.last?.outcome, .notRun)
    }

    func testPendingExternalRunCannotReportPassEvenIfEveryStepIsMarkedPass() {
        let run = ReleaseEvidenceRun(
            lane: .externalCandidate,
            profile: .delta,
            appVersion: "1.0",
            appBuild: "56",
            deviceModel: "Test Device",
            osVersion: "Test OS",
            candidateID: "Build-56",
            promotionMode: .pendingArtifactMatch,
            steps: [
                ReleaseEvidenceStep(scope: .candidateIdentity, outcome: .pass),
                ReleaseEvidenceStep(scope: .evidenceReuse, outcome: .pass),
                ReleaseEvidenceStep(scope: .externalReadiness, outcome: .pass),
            ]
        )

        XCTAssertEqual(run.outcome, .partial)
        XCTAssertFalse(run.isCompletePass)
    }

    func testStepNotesAreBoundedWhenCreated() {
        let note = String(repeating: "x", count: ReleaseEvidenceStep.maximumNoteLength + 40)
        let step = ReleaseEvidenceStep(scope: .candidateIdentity, note: note)

        XCTAssertEqual(step.note.count, ReleaseEvidenceStep.maximumNoteLength)
    }

    func testLegacyArchiveDecodingBoundsNoteAndMarksMissingBehaviorContractUnknown() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var runObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: encoder.encode(makeRun()),
                options: []
            ) as? [String: Any]
        )
        var steps = try XCTUnwrap(runObject["steps"] as? [[String: Any]])
        steps[0]["note"] = String(
            repeating: "x",
            count: ReleaseEvidenceStep.maximumNoteLength + 40
        )
        runObject["steps"] = steps
        runObject.removeValue(forKey: "behaviorContract")

        let archiveData = try JSONSerialization.data(
            withJSONObject: [
                "schemaVersion": ReleaseEvidenceRun.currentSchemaVersion,
                "runs": [runObject],
            ]
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let archive = try decoder.decode(ReleaseEvidenceArchive.self, from: archiveData)

        XCTAssertEqual(
            archive.runs.first?.behaviorContract,
            ReleaseEvidenceRun.unknownBehaviorContract
        )
        XCTAssertEqual(
            archive.runs.first?.steps.first?.note.count,
            ReleaseEvidenceStep.maximumNoteLength
        )
    }

    func testCorruptArchiveIsQuarantinedBeforeSavingNewRun() async throws {
        let rootURL = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let fileURL = rootURL.appendingPathComponent("records.json")
        try FileManager.default.createDirectory(
            at: rootURL,
            withIntermediateDirectories: true
        )
        try Data("not-json".utf8).write(to: fileURL)
        let store = ReleaseEvidenceFileStore(fileURL: fileURL)

        try await store.save(makeRun(candidateID: "Recovered-56"))
        let loaded = try await store.load()
        let files = try FileManager.default.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: nil
        )

        XCTAssertEqual(loaded.first?.candidateID, "Recovered-56")
        XCTAssertTrue(
            files.contains { $0.lastPathComponent.hasPrefix("records.corrupt.") }
        )
    }

    func testDiagnosticsClearDoesNotDeleteReleaseEvidence() async throws {
        let rootURL = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let diagnosticsRoot = rootURL.appendingPathComponent("Diagnostics/v1", isDirectory: true)
        let store = ReleaseEvidenceFileStore(
            fileURL: diagnosticsRoot.appendingPathComponent(
                "release-evidence/records.json",
                isDirectory: false
            )
        )
        let run = makeRun(candidateID: "Keep-56")
        try await store.save(run)

        let source = V1DiagnosticsLogSource(
            appGroupID: "test.group",
            rootURLProvider: { diagnosticsRoot }
        )
        let clearResult = await source.clearLog()
        XCTAssertEqual(clearResult, .cleared)

        let loaded = try await store.load()
        XCTAssertEqual(loaded.first?.candidateID, "Keep-56")
    }

    private func makeRun(
        candidateID: String = "Build-56",
        date: Date = Date(),
        steps: [ReleaseEvidenceStep] = [
            ReleaseEvidenceStep(scope: .candidateIdentity, outcome: .pass),
            ReleaseEvidenceStep(scope: .affectedPathSmoke, outcome: .pass),
        ]
    ) -> ReleaseEvidenceRun {
        ReleaseEvidenceRun(
            createdAt: date,
            updatedAt: date,
            lane: .dailyBeta,
            profile: .delta,
            appVersion: "1.0",
            appBuild: "56",
            deviceModel: "Test Device",
            osVersion: "Test OS",
            candidateID: candidateID,
            steps: steps
        )
    }

    private func temporaryRoot() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("ReleaseEvidenceStoreTests-\(UUID().uuidString)")
    }

    private func waitUntil(
        timeout: Duration = .seconds(2),
        condition: @escaping @MainActor () -> Bool
    ) async {
        let deadline = ContinuousClock.now + timeout
        while !condition(), ContinuousClock.now < deadline {
            await Task.yield()
        }
    }
}
