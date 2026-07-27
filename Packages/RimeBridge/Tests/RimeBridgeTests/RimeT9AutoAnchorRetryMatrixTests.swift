import Foundation
import XCTest

@testable import KeyboardCore
@testable import RimeBridge

/// Test-target-only real-librime matrix for later auto-anchor opportunities.
///
/// This deliberately performs more than one transaction in an isolated test
/// session so we can measure the safety of a future retry policy. It does not
/// call `KeyboardController` and cannot change the production one-attempt
/// ledger defined by ADR 0024.
final class RimeT9AutoAnchorRetryMatrixTests: XCTestCase {
    private enum FixtureSafetyError: Error {
        case userRootOutsidePrivateTemporaryDirectory
    }

    private struct Attempt {
        let sourceSlot: Int
        let accepted: Bool
        let baselineCandidateCount: Int
        let resultingCandidateCount: Int
        let overlappingCandidateCount: Int
        let anchoredSlotCount: Int
        let unresolvedSlotCount: Int
        let anchoredSyllableCount: Int
        let replacementDurationMs: Double
        let restoreDurationMs: Double
    }

    private struct CompletePersonalizationCase {
        let id: String
        let learningSpelling: String
        let sourceSpelling: String
        let expectedBaselineRank: Int
        let expectedLearnedRank: Int
        let expectedTwoAccepted: Bool
        let expectedTwoOverlap: Int
    }

    func testPersonalizationFixtureUserRootSafetyPolicy() throws {
        let fileManager = FileManager.default
        let allowedURL = URL(
            fileURLWithPath: "/private/tmp",
            isDirectory: true
        )
        .appendingPathComponent(
            "universe-keyboard-s5-policy-\(UUID().uuidString)",
            isDirectory: true
        )
        try fileManager.createDirectory(
            at: allowedURL,
            withIntermediateDirectories: false
        )
        defer {
            try? fileManager.removeItem(at: allowedURL)
        }

        XCTAssertNotNil(
            authorizedTemporaryUserRoot(allowedURL.path)
        )
        XCTAssertNotNil(
            authorizedTemporaryUserRoot(
                "/tmp/\(allowedURL.lastPathComponent)"
            )
        )
        XCTAssertNil(authorizedTemporaryUserRoot("/private/tmp"))
        XCTAssertNil(
            authorizedTemporaryUserRoot(
                "/Users/example/Library/Group Containers/user"
            )
        )
    }

    func testRejectedCompositionLaterOpportunityTransactionMatrix() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir),
                userDataURL: URL(fileURLWithPath: directories.userDir),
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: directories.userDir
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        XCTAssertTrue(engine.bridge.selectSchema("t9"))

        let spelling = "mingtianzaoshangwomenyiqiqugongyuanpaobu"
        let sourceDigits = t9Digits(for: spelling)
        XCTAssertEqual(sourceDigits.count, 40)

        engine.bridge.clearComposition()
        var maximalAttempts: [Attempt] = []
        var backoffAttempts: [Attempt] = []

        for (offset, digit) in sourceDigits.enumerated() {
            let sourceSlot = offset + 1
            let baselineOutput = engine.processKey(String(digit))
            guard sourceSlot >= 18,
                let proposal = T9ReversibleAutoAnchorPolicy.proposal(
                    sourceDigits: String(sourceDigits.prefix(sourceSlot)),
                    output: baselineOutput
                )
            else {
                continue
            }

            let baselineCandidates = Array(
                baselineOutput.candidates.prefix(
                    T9ReversibleAutoAnchorPolicy.Configuration
                        .experimental.evidenceCandidateLimit
                )
            )
            maximalAttempts.append(
                runTransaction(
                    engine: engine,
                    sourceSlot: sourceSlot,
                    proposal: proposal,
                    baselineCandidates: baselineCandidates
                )
            )

            for syllableCount in stride(
                from: proposal.anchoredSyllables.count - 1,
                through: 2,
                by: -1
            ) {
                guard
                    let backoffProposal = makeBackoffProposal(
                        from: proposal,
                        syllableCount: syllableCount,
                        baselineCandidates: baselineCandidates
                    )
                else {
                    continue
                }
                backoffAttempts.append(
                    runTransaction(
                        engine: engine,
                        sourceSlot: sourceSlot,
                        proposal: backoffProposal,
                        baselineCandidates: baselineCandidates
                    )
                )
            }
        }

        let maximalSlots = maximalAttempts.map(\.sourceSlot)
        let laterMaximalAttempts = maximalAttempts.filter {
            $0.sourceSlot > 18
        }
        XCTAssertEqual(
            maximalAttempts.first?.sourceSlot,
            18,
            "The frozen rejected composition must retain its first S2 opportunity."
        )
        XCTAssertFalse(
            laterMaximalAttempts.isEmpty,
            "The matrix must exercise at least one opportunity after the first rejection."
        )
        XCTAssertTrue(
            maximalAttempts.allSatisfy { !$0.accepted },
            "The frozen sentence currently expects every maximal proposal to fail conservation."
        )
        XCTAssertTrue(
            maximalAttempts.allSatisfy {
                $0.overlappingCandidateCount == 2
            },
            "Unexpected maximal-prefix conservation drift requires evidence review."
        )
        let acceptedBackoffs = backoffAttempts.filter { $0.accepted }
        XCTAssertEqual(
            acceptedBackoffs.count,
            maximalAttempts.count,
            "Every frozen opportunity should retain exactly one safe backoff."
        )
        XCTAssertEqual(
            Set(acceptedBackoffs.map(\.sourceSlot)),
            Set(maximalSlots),
            "Safe backoff coverage changed across the frozen opportunity slots."
        )
        XCTAssertTrue(
            acceptedBackoffs.allSatisfy {
                $0.anchoredSyllableCount == 2
                    && $0.overlappingCandidateCount == 5
            },
            "Only the two-syllable backoff should preserve all five candidates."
        )

        let allAttempts = maximalAttempts + backoffAttempts
        // Keep machine output content-free: only slots, counts, decisions and
        // timing are emitted. Candidate text and pinyin paths stay ephemeral.
        let rows = allAttempts.map { attempt in
            [
                "slot=\(attempt.sourceSlot)",
                "syllables=\(attempt.anchoredSyllableCount)",
                "accepted=\(attempt.accepted)",
                "baseline=\(attempt.baselineCandidateCount)",
                "result=\(attempt.resultingCandidateCount)",
                "overlap=\(attempt.overlappingCandidateCount)",
                "anchor=\(attempt.anchoredSlotCount)",
                "unresolved=\(attempt.unresolvedSlotCount)",
                "replaceMs=\(format(attempt.replacementDurationMs))",
                "restoreMs=\(format(attempt.restoreDurationMs))",
            ].joined(separator: ",")
        }
        let summary = [
            "T9_AUTO_ANCHOR_RETRY_MATRIX",
            "maximalAttempts=\(maximalAttempts.count)",
            "maximalAccepted=\(maximalAttempts.filter { $0.accepted }.count)",
            "backoffAttempts=\(backoffAttempts.count)",
            "backoffAccepted=\(backoffAttempts.filter { $0.accepted }.count)",
            "maximalSlots=\(maximalSlots.map(String.init).joined(separator: ","))",
            "rows=\(rows.joined(separator: ";"))",
        ].joined(separator: " ")
        fputs(summary + "\n", stderr)
        print(summary)

        let timingSummary = runPairedTimingMatrix(
            engine: engine,
            sourceDigits: sourceDigits
        )
        fputs(timingSummary + "\n", stderr)
        print(timingSummary)

        let corpusSummary = runFrozenCorpusDepthMatrix(engine: engine)
        fputs(corpusSummary + "\n", stderr)
        print(corpusSummary)

        let reviewedCorpusSummary = runReviewedTwoSyllableCorpusMatrix(
            engine: engine
        )
        fputs(reviewedCorpusSummary + "\n", stderr)
        print(reviewedCorpusSummary)
    }

    func testIsolatedPersonalizationKnownPositive() async throws {
        try await runCompletePersonalizationCase(
            CompletePersonalizationCase(
                id: "knownPositive",
                learningSpelling: "jintian",
                sourceSpelling: "jintiantianqihenhao",
                expectedBaselineRank: 4,
                expectedLearnedRank: 0,
                expectedTwoAccepted: true,
                expectedTwoOverlap: 3
            )
        )
    }

    func testIsolatedPersonalizationNaturalWeather() async throws {
        try await runCompletePersonalizationCase(
            CompletePersonalizationCase(
                id: "naturalWeather",
                learningSpelling: "tianqi",
                sourceSpelling: "tianqibianhuabijiaoda",
                expectedBaselineRank: 4,
                expectedLearnedRank: 0,
                expectedTwoAccepted: true,
                expectedTwoOverlap: 3
            )
        )
    }

    func testIsolatedPersonalizationNaturalReminder() async throws {
        try await runCompletePersonalizationCase(
            CompletePersonalizationCase(
                id: "naturalReminder",
                learningSpelling: "qingji",
                sourceSpelling: "qingjidegeiwodadianhua",
                expectedBaselineRank: 4,
                expectedLearnedRank: 0,
                expectedTwoAccepted: false,
                expectedTwoOverlap: 2
            )
        )
    }

    private func runCompletePersonalizationCase(
        _ item: CompletePersonalizationCase
    ) async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)

        let fileManager = FileManager.default
        let isolatedUserURL = URL(fileURLWithPath: directories.userDir)
            .appendingPathComponent(
                "personalization-\(UUID().uuidString)",
                isDirectory: true
            )
        try fileManager.createDirectory(
            at: isolatedUserURL,
            withIntermediateDirectories: false
        )
        defer {
            do {
                try fileManager.removeItem(at: isolatedUserURL)
                XCTAssertFalse(
                    fileManager.fileExists(atPath: isolatedUserURL.path),
                    "The generated personalization directory was not removed."
                )
            } catch {
                XCTFail(
                    "Failed to remove the generated personalization directory."
                )
            }
        }

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir),
                userDataURL: isolatedUserURL,
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let learningDigits = t9Digits(for: item.learningSpelling)
        let sourceDigits = t9Digits(for: item.sourceSpelling)
        XCTAssertGreaterThanOrEqual(sourceDigits.count, 18)

        var targetText = ""
        var baselineRank = -1
        var learnedRank = -1
        var selectionCount = 0
        var targetLength = 0
        var baselineTwoSyllable: Attempt?

        do {
            let engine = RimeEngineImpl(
                sharedDataDir: directories.sharedDir,
                userDataDir: isolatedUserURL.path
            )
            defer {
                engine.bridge.clearComposition()
                engine.bridge.finalize()
            }
            XCTAssertTrue(engine.bridge.selectSchema("t9"))

            let learningOutput = enter(
                sourceDigits: learningDigits,
                engine: engine
            )
            let evidenceLimit =
                T9ReversibleAutoAnchorPolicy.Configuration
                .experimental.evidenceCandidateLimit
            let baselineCandidates = Array(
                learningOutput.candidates.prefix(evidenceLimit)
            )
            guard baselineCandidates.count >= 3 else {
                XCTFail(
                    "The isolated personalization fixture needs at least three candidates."
                )
                return
            }

            // Learn a complete short phrase first. Selecting a candidate from
            // the long composition can be a partial segment; that would train
            // the combined continuation instead of the visible segment.
            let target = baselineCandidates.enumerated()
                .dropFirst()
                .max {
                    if $0.element.text.count == $1.element.text.count {
                        return $0.offset < $1.offset
                    }
                    return $0.element.text.count < $1.element.text.count
                }
            guard let target else {
                XCTFail("No non-leading synthetic learning target was available.")
                return
            }
            targetText = target.element.text
            baselineRank = target.offset
            targetLength = target.element.text.count
            XCTAssertEqual(baselineRank, item.expectedBaselineRank)

            let baselineOutput = enter(
                sourceDigits: sourceDigits,
                engine: engine
            )
            baselineTwoSyllable = twoSyllableAttempt(
                sourceDigits: sourceDigits,
                baselineOutput: baselineOutput,
                engine: engine
            )
            XCTAssertEqual(
                baselineTwoSyllable?.anchoredSyllableCount,
                2,
                "The baseline two-syllable proposal disappeared."
            )
            XCTAssertEqual(
                baselineTwoSyllable?.accepted,
                item.expectedTwoAccepted
            )
            XCTAssertEqual(
                baselineTwoSyllable?.overlappingCandidateCount,
                item.expectedTwoOverlap
            )

            let currentOutput = enter(
                sourceDigits: learningDigits,
                engine: engine
            )
            guard
                let currentRank = currentOutput.candidates.firstIndex(
                    where: { $0.text == targetText }
                )
            else {
                XCTFail(
                    "The synthetic learning target left the current candidate page."
                )
                return
            }

            let selected = engine.selectCandidate(at: currentRank)
            selectionCount = 1
            XCTAssertNotNil(
                selected.committedText,
                "A complete-learning case required a continuation selection."
            )

            let rankedOutput = enter(
                sourceDigits: learningDigits,
                engine: engine
            )
            guard
                let currentLearnedRank =
                    rankedOutput.candidates.firstIndex(
                        where: { $0.text == targetText }
                    )
            else {
                XCTFail(
                    "The synthetic learning target disappeared after selection."
                )
                return
            }
            learnedRank = currentLearnedRank

            XCTAssertEqual(selectionCount, 1)
            XCTAssertGreaterThanOrEqual(learnedRank, 0)
            XCTAssertEqual(learnedRank, item.expectedLearnedRank)
            XCTAssertLessThan(
                learnedRank,
                baselineRank,
                "Bounded synthetic selections produced no ranking delta."
            )
        }

        var reopenedRank = -1
        var personalizedTwoSyllable: Attempt?
        do {
            let engine = RimeEngineImpl(
                sharedDataDir: directories.sharedDir,
                userDataDir: isolatedUserURL.path
            )
            defer {
                engine.bridge.clearComposition()
                engine.bridge.finalize()
            }
            XCTAssertTrue(engine.bridge.selectSchema("t9"))

            let reopenedOutput = enter(
                sourceDigits: learningDigits,
                engine: engine
            )
            guard
                let rank = reopenedOutput.candidates.firstIndex(
                    where: { $0.text == targetText }
                )
            else {
                XCTFail(
                    "The learned target was absent after reopening the isolated userdb."
                )
                return
            }
            reopenedRank = rank
            XCTAssertEqual(reopenedRank, item.expectedLearnedRank)
            XCTAssertLessThan(
                reopenedRank,
                baselineRank,
                "The ranking delta did not survive an isolated-engine restart."
            )

            let personalizedOutput = enter(
                sourceDigits: sourceDigits,
                engine: engine
            )
            personalizedTwoSyllable = twoSyllableAttempt(
                sourceDigits: sourceDigits,
                baselineOutput: personalizedOutput,
                engine: engine
            )
            XCTAssertEqual(
                personalizedTwoSyllable?.anchoredSyllableCount,
                2,
                "The personalized two-syllable proposal disappeared."
            )
            XCTAssertEqual(
                personalizedTwoSyllable?.accepted,
                baselineTwoSyllable?.accepted,
                "Personalization changed the two-syllable conservation decision."
            )
            XCTAssertEqual(
                personalizedTwoSyllable?.overlappingCandidateCount,
                item.expectedTwoOverlap
            )
        }

        // Keep the evidence content-free. Candidate text, raw pinyin and the
        // generated directory name are intentionally excluded.
        let summary = [
            "T9_AUTO_ANCHOR_PERSONALIZATION",
            "case=\(item.id)",
            "selections=\(selectionCount)",
            "baselineRank=\(baselineRank)",
            "learnedRank=\(learnedRank)",
            "reopenedRank=\(reopenedRank)",
            "targetLength=\(targetLength)",
            "completionSelections=0",
            "baselineTwoAccepted=\(baselineTwoSyllable?.accepted ?? false)",
            "baselineTwoOverlap="
                + String(
                    baselineTwoSyllable?.overlappingCandidateCount ?? 0
                ),
            "personalizedTwoAccepted="
                + String(personalizedTwoSyllable?.accepted ?? false),
            "personalizedTwoOverlap="
                + String(
                    personalizedTwoSyllable?
                        .overlappingCandidateCount
                        ?? 0
                ),
            "cleanup=deferred",
        ].joined(separator: " ")
        fputs(summary + "\n", stderr)
        print(summary)
    }

    func testPartialLongSelectionIsNotPersonalizationProof() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)

        let fileManager = FileManager.default
        let isolatedUserURL = URL(fileURLWithPath: directories.userDir)
            .appendingPathComponent(
                "personalization-partial-\(UUID().uuidString)",
                isDirectory: true
            )
        try fileManager.createDirectory(
            at: isolatedUserURL,
            withIntermediateDirectories: false
        )
        defer {
            do {
                try fileManager.removeItem(at: isolatedUserURL)
                XCTAssertFalse(
                    fileManager.fileExists(atPath: isolatedUserURL.path),
                    "The generated partial-selection directory was not removed."
                )
            } catch {
                XCTFail(
                    "Failed to remove the generated partial-selection directory."
                )
            }
        }

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir),
                userDataURL: isolatedUserURL,
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let sourceDigits = t9Digits(for: "jintiantianqihenhao")
        var targetText = ""
        var baselineRank = -1
        var targetLength = 0
        var completionSelections = 0
        var baselineTwoSyllable: Attempt?

        do {
            let engine = RimeEngineImpl(
                sharedDataDir: directories.sharedDir,
                userDataDir: isolatedUserURL.path
            )
            defer {
                engine.bridge.clearComposition()
                engine.bridge.finalize()
            }
            XCTAssertTrue(engine.bridge.selectSchema("t9"))

            let baselineOutput = enter(
                sourceDigits: sourceDigits,
                engine: engine
            )
            baselineTwoSyllable = twoSyllableAttempt(
                sourceDigits: sourceDigits,
                baselineOutput: baselineOutput,
                engine: engine
            )
            XCTAssertTrue(baselineTwoSyllable?.accepted == true)
            XCTAssertEqual(
                baselineTwoSyllable?.overlappingCandidateCount,
                3
            )

            let evidenceLimit =
                T9ReversibleAutoAnchorPolicy.Configuration
                .experimental.evidenceCandidateLimit
            let candidates = Array(
                baselineOutput.candidates.prefix(evidenceLimit)
            )
            guard candidates.count >= 3,
                let target = candidates.enumerated()
                    .dropFirst(2)
                    .max(by: {
                        $0.element.text.count < $1.element.text.count
                    })
            else {
                XCTFail(
                    "The partial-selection fixture lost its non-leading target."
                )
                return
            }
            targetText = target.element.text
            baselineRank = target.offset
            targetLength = target.element.text.count
            XCTAssertEqual(baselineRank, 2)
            XCTAssertEqual(targetLength, 3)

            let currentOutput = enter(
                sourceDigits: sourceDigits,
                engine: engine
            )
            guard
                let currentRank = currentOutput.candidates.firstIndex(
                    where: { $0.text == targetText }
                )
            else {
                XCTFail("The partial-selection target was not repeatable.")
                return
            }
            let partialSelection = engine.selectCandidate(at: currentRank)
            XCTAssertNil(
                partialSelection.committedText,
                "The frozen negative unexpectedly became a complete selection."
            )
            XCTAssertNotNil(partialSelection.composition)
            XCTAssertFalse(partialSelection.candidates.isEmpty)

            let completedSelection = engine.selectCandidate(at: 0)
            completionSelections = 1
            XCTAssertNil(
                completedSelection.composition,
                "The frozen continuation did not complete the selection."
            )
            XCTAssertEqual(completionSelections, 1)
            XCTAssertNotNil(completedSelection.committedText)
        }

        var reopenedRank = -1
        var personalizedTwoSyllable: Attempt?
        do {
            let engine = RimeEngineImpl(
                sharedDataDir: directories.sharedDir,
                userDataDir: isolatedUserURL.path
            )
            defer {
                engine.bridge.clearComposition()
                engine.bridge.finalize()
            }
            XCTAssertTrue(engine.bridge.selectSchema("t9"))

            let reopenedOutput = enter(
                sourceDigits: sourceDigits,
                engine: engine
            )
            reopenedRank =
                reopenedOutput.candidates.firstIndex(
                    where: { $0.text == targetText }
                ) ?? -1
            XCTAssertEqual(reopenedRank, 3)

            personalizedTwoSyllable = twoSyllableAttempt(
                sourceDigits: sourceDigits,
                baselineOutput: reopenedOutput,
                engine: engine
            )
            XCTAssertNil(
                personalizedTwoSyllable,
                "Partial continuation learning must not become anchor authority."
            )
        }

        let summary = [
            "T9_AUTO_ANCHOR_PERSONALIZATION",
            "case=partialNegative",
            "baselineRank=\(baselineRank)",
            "reopenedRank=\(reopenedRank)",
            "targetLength=\(targetLength)",
            "completionSelections=\(completionSelections)",
            "baselineTwoAccepted=\(baselineTwoSyllable?.accepted ?? false)",
            "baselineTwoOverlap="
                + String(
                    baselineTwoSyllable?.overlappingCandidateCount ?? 0
                ),
            "personalizedTwoProposal="
                + String(personalizedTwoSyllable != nil),
            "personalizedTwoAccepted="
                + String(personalizedTwoSyllable?.accepted ?? false),
            "personalizedTwoOverlap="
                + String(
                    personalizedTwoSyllable?
                        .overlappingCandidateCount
                        ?? 0
                ),
            "cleanup=deferred",
        ].joined(separator: " ")
        fputs(summary + "\n", stderr)
        print(summary)
    }

    private func enter(
        sourceDigits: String,
        engine: RimeEngineImpl
    ) -> RimeOutput {
        engine.bridge.clearComposition()
        var output = RimeOutput()
        for digit in sourceDigits {
            output = engine.processKey(String(digit))
        }
        return output
    }

    private func twoSyllableAttempt(
        sourceDigits: String,
        baselineOutput: RimeOutput,
        engine: RimeEngineImpl
    ) -> Attempt? {
        guard
            let maximalProposal =
                T9ReversibleAutoAnchorPolicy.proposal(
                    sourceDigits: sourceDigits,
                    output: baselineOutput
                )
        else {
            return nil
        }
        let baselineCandidates = Array(
            baselineOutput.candidates.prefix(
                T9ReversibleAutoAnchorPolicy.Configuration
                    .experimental.evidenceCandidateLimit
            )
        )
        let proposal: T9ReversibleAutoAnchorPolicy.Proposal?
        if maximalProposal.anchoredSyllables.count == 2 {
            proposal = maximalProposal
        } else {
            proposal = makeBackoffProposal(
                from: maximalProposal,
                syllableCount: 2,
                baselineCandidates: baselineCandidates
            )
        }
        guard let proposal else {
            return nil
        }
        return runTransaction(
            engine: engine,
            sourceSlot: sourceDigits.count,
            proposal: proposal,
            baselineCandidates: baselineCandidates
        )
    }

    private func runTransaction(
        engine: RimeEngineImpl,
        sourceSlot: Int,
        proposal: T9ReversibleAutoAnchorPolicy.Proposal,
        baselineCandidates: [RimeCandidate]
    ) -> Attempt {
        let replacementStart = ProcessInfo.processInfo.systemUptime
        let result = engine.replaceInput(proposal.replacementRawInput)
        let replacementDuration =
            (ProcessInfo.processInfo.systemUptime - replacementStart) * 1_000
        let validation = T9ReversibleAutoAnchorPolicy.validate(
            proposal: proposal,
            result: result
        )

        let restoreStart = ProcessInfo.processInfo.systemUptime
        let restored = engine.replaceInput(proposal.sourceDigits)
        let restoreDuration =
            (ProcessInfo.processInfo.systemUptime - restoreStart) * 1_000

        assertRestored(
            restored,
            sourceDigits: proposal.sourceDigits,
            baselineCandidates: baselineCandidates,
            sourceSlot: sourceSlot
        )
        return Attempt(
            sourceSlot: sourceSlot,
            accepted: validation.isAccepted,
            baselineCandidateCount: baselineCandidates.count,
            resultingCandidateCount: validation.resultingCandidateCount,
            overlappingCandidateCount: validation.overlappingCandidateCount,
            anchoredSlotCount: proposal.anchoredSlotCount,
            unresolvedSlotCount: proposal.unresolvedSlotCount,
            anchoredSyllableCount: proposal.anchoredSyllables.count,
            replacementDurationMs: replacementDuration,
            restoreDurationMs: restoreDuration
        )
    }

    private func makeBackoffProposal(
        from maximalProposal: T9ReversibleAutoAnchorPolicy.Proposal,
        syllableCount: Int,
        baselineCandidates: [RimeCandidate]
    ) -> T9ReversibleAutoAnchorPolicy.Proposal? {
        let syllables = Array(
            maximalProposal.anchoredSyllables.prefix(syllableCount)
        )
        guard syllables.count >= 2 else {
            return nil
        }
        let anchoredSlotCount = syllables.reduce(0) {
            $0 + T9PinyinPathExtractor.asciiLetterCount(in: $1)
        }
        let unresolvedSlotCount =
            maximalProposal.sourceDigits.count - anchoredSlotCount
        let configuration =
            T9ReversibleAutoAnchorPolicy.Configuration.experimental
        guard anchoredSlotCount >= configuration.minimumAnchoredSlotCount,
            unresolvedSlotCount >= configuration.minimumUnresolvedSlotCount
        else {
            return nil
        }
        let trailingDigits = String(
            maximalProposal.sourceDigits.dropFirst(anchoredSlotCount)
        )
        return T9ReversibleAutoAnchorPolicy.Proposal(
            sourceDigits: maximalProposal.sourceDigits,
            replacementRawInput:
                syllables.joined(separator: "'") + "'" + trailingDigits,
            anchoredSyllables: syllables,
            anchoredSlotCount: anchoredSlotCount,
            unresolvedSlotCount: unresolvedSlotCount,
            baselineCandidateTexts: baselineCandidates.map(\.text)
        )
    }

    private func runPairedTimingMatrix(
        engine: RimeEngineImpl,
        sourceDigits: String
    ) -> String {
        var baselineRuns: [[Int: Double]] = []
        var anchoredRuns: [[Int: Double]] = []

        // Alternate order to reduce the chance that one side always receives
        // the warmer session/cache state.
        for round in 0..<3 {
            if round.isMultiple(of: 2) {
                baselineRuns.append(
                    measureScenario(
                        engine: engine,
                        sourceDigits: sourceDigits,
                        anchorsTwoSyllablesAt18: false
                    )
                )
                anchoredRuns.append(
                    measureScenario(
                        engine: engine,
                        sourceDigits: sourceDigits,
                        anchorsTwoSyllablesAt18: true
                    )
                )
            } else {
                anchoredRuns.append(
                    measureScenario(
                        engine: engine,
                        sourceDigits: sourceDigits,
                        anchorsTwoSyllablesAt18: true
                    )
                )
                baselineRuns.append(
                    measureScenario(
                        engine: engine,
                        sourceDigits: sourceDigits,
                        anchorsTwoSyllablesAt18: false
                    )
                )
            }
        }

        let targetSlots = [22, 24, 26, 32, 36]
        let rows = targetSlots.map { slot in
            let baselineMedian = median(
                baselineRuns.compactMap { $0[slot] }
            )
            let anchoredMedian = median(
                anchoredRuns.compactMap { $0[slot] }
            )
            return [
                "slot=\(slot)",
                "baselineMs=\(format(baselineMedian))",
                "anchoredMs=\(format(anchoredMedian))",
            ].joined(separator: ",")
        }
        let baselineSlowCount = baselineRuns.reduce(0) { partial, run in
            partial + run.values.filter { $0 >= 50 }.count
        }
        let anchoredSlowCount = anchoredRuns.reduce(0) { partial, run in
            partial + run.values.filter { $0 >= 50 }.count
        }
        return [
            "T9_AUTO_ANCHOR_TWO_SYLLABLE_TIMING",
            "rounds=3",
            "baselineSlow50=\(baselineSlowCount)",
            "anchoredSlow50=\(anchoredSlowCount)",
            "rows=\(rows.joined(separator: ";"))",
        ].joined(separator: " ")
    }

    private func measureScenario(
        engine: RimeEngineImpl,
        sourceDigits: String,
        anchorsTwoSyllablesAt18: Bool
    ) -> [Int: Double] {
        engine.bridge.clearComposition()
        var durations: [Int: Double] = [:]

        for (offset, digit) in sourceDigits.enumerated() {
            let sourceSlot = offset + 1
            let start = ProcessInfo.processInfo.systemUptime
            let output = engine.processKey(String(digit))
            durations[sourceSlot] =
                (ProcessInfo.processInfo.systemUptime - start) * 1_000
            XCTAssertNil(
                output.committedText,
                "Timing scenario unexpectedly committed at slot \(sourceSlot)."
            )

            guard anchorsTwoSyllablesAt18, sourceSlot == 18 else {
                continue
            }
            let prefixDigits = String(sourceDigits.prefix(sourceSlot))
            let baselineCandidates = Array(
                output.candidates.prefix(
                    T9ReversibleAutoAnchorPolicy.Configuration
                        .experimental.evidenceCandidateLimit
                )
            )
            guard
                let maximalProposal =
                    T9ReversibleAutoAnchorPolicy.proposal(
                        sourceDigits: prefixDigits,
                        output: output
                    ),
                let backoffProposal = makeBackoffProposal(
                    from: maximalProposal,
                    syllableCount: 2,
                    baselineCandidates: baselineCandidates
                )
            else {
                XCTFail("The frozen slot-18 two-syllable proposal disappeared.")
                continue
            }
            let anchored = engine.replaceInput(
                backoffProposal.replacementRawInput
            )
            let validation = T9ReversibleAutoAnchorPolicy.validate(
                proposal: backoffProposal,
                result: anchored
            )
            XCTAssertTrue(
                validation.isAccepted,
                "The frozen slot-18 two-syllable proposal lost conservation."
            )
            XCTAssertEqual(validation.overlappingCandidateCount, 5)
        }
        engine.bridge.clearComposition()
        return durations
    }

    private func median(_ values: [Double]) -> Double {
        guard !values.isEmpty else {
            return 0
        }
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }

    private func runFrozenCorpusDepthMatrix(
        engine: RimeEngineImpl
    ) -> String {
        let cases:
            [(
                id: String,
                spelling: String,
                expectsProposal: Bool,
                expectedMaximalOverlap: Int
            )] = [
                (
                    "knownPositive",
                    "jintiandetianqihenbucuowomenchuquwanba",
                    true,
                    5
                ),
                (
                    "differentSentence",
                    "mingtianzaoshangwomenyiqiqugongyuanpaobu",
                    true,
                    2
                ),
                ("localRanking", "jintiantianqihenhao", true, 3),
                (
                    "highAmbiguity",
                    "shishishishishishishishishishishishi",
                    true,
                    5
                ),
                ("legalPoorPath", String(repeating: "a", count: 18), true, 1),
                ("threshold", "jintiandetianqihe", false, 0),
            ]
        var rows: [String] = []

        for item in cases {
            let digits = t9Digits(for: item.spelling)
            engine.bridge.clearComposition()
            var output = RimeOutput()
            for digit in digits {
                output = engine.processKey(String(digit))
            }
            guard
                let maximalProposal =
                    T9ReversibleAutoAnchorPolicy.proposal(
                        sourceDigits: digits,
                        output: output
                    )
            else {
                XCTAssertFalse(
                    item.expectsProposal,
                    "Frozen corpus case \(item.id) unexpectedly lost its proposal."
                )
                rows.append(
                    "case=\(item.id),proposal=false,acceptedDepths=none"
                )
                continue
            }
            XCTAssertTrue(
                item.expectsProposal,
                "Frozen threshold case unexpectedly produced a proposal."
            )

            let baselineCandidates = Array(
                output.candidates.prefix(
                    T9ReversibleAutoAnchorPolicy.Configuration
                        .experimental.evidenceCandidateLimit
                )
            )
            let maximalAttempt = runTransaction(
                engine: engine,
                sourceSlot: digits.count,
                proposal: maximalProposal,
                baselineCandidates: baselineCandidates
            )
            XCTAssertEqual(
                maximalAttempt.overlappingCandidateCount,
                item.expectedMaximalOverlap,
                "Frozen maximal overlap drifted for corpus case \(item.id)."
            )

            var acceptedDepths: [Int] = []
            if maximalAttempt.accepted {
                acceptedDepths.append(
                    maximalAttempt.anchoredSyllableCount
                )
            }
            for syllableCount in stride(
                from: maximalProposal.anchoredSyllables.count - 1,
                through: 2,
                by: -1
            ) {
                guard
                    let backoffProposal = makeBackoffProposal(
                        from: maximalProposal,
                        syllableCount: syllableCount,
                        baselineCandidates: baselineCandidates
                    )
                else {
                    continue
                }
                let attempt = runTransaction(
                    engine: engine,
                    sourceSlot: digits.count,
                    proposal: backoffProposal,
                    baselineCandidates: baselineCandidates
                )
                if attempt.accepted {
                    acceptedDepths.append(attempt.anchoredSyllableCount)
                }
            }
            rows.append(
                [
                    "case=\(item.id)",
                    "proposal=true",
                    "maxDepth=\(maximalAttempt.anchoredSyllableCount)",
                    "maxOverlap=\(maximalAttempt.overlappingCandidateCount)",
                    "acceptedDepths="
                        + (acceptedDepths.isEmpty
                            ? "none"
                            : acceptedDepths.map(String.init)
                                .joined(separator: ",")),
                ].joined(separator: ",")
            )
        }
        engine.bridge.clearComposition()
        return "T9_AUTO_ANCHOR_CORPUS_DEPTH_MATRIX "
            + rows.joined(
                separator: ";"
            )
    }

    private func runReviewedTwoSyllableCorpusMatrix(
        engine: RimeEngineImpl
    ) -> String {
        let cases: [(id: String, category: String, spelling: String)] = [
            (
                "natural01",
                "natural",
                "jintianwomenyiqiqugongyuanwanba"
            ),
            (
                "natural02",
                "natural",
                "mingtianxiawuwomenqukandianying"
            ),
            (
                "natural03",
                "natural",
                "zhegezhoumowoxiangzaijialixiuxi"
            ),
            (
                "natural04",
                "natural",
                "qingbangwobazhefenwenjianfageita"
            ),
            (
                "natural05",
                "natural",
                "wanshangchifanlewomenqusanbu"
            ),
            (
                "natural06",
                "natural",
                "zuijintianqibianhuabijiaoda"
            ),
            (
                "natural07",
                "natural",
                "woxiangxuexiyixiexindongxi"
            ),
            (
                "natural08",
                "natural",
                "ruguomingtiantianqihenhaojiuchufa"
            ),
            (
                "natural09",
                "natural",
                "gongzuowanchengyihoujiuhuijia"
            ),
            (
                "natural10",
                "natural",
                "qingjidegeiwodadianhua"
            ),
            (
                "natural11",
                "natural",
                "womenxiayigezhouzaijianmian"
            ),
            (
                "natural12",
                "natural",
                "zhejianshiqingxuyaomanmanjiejue"
            ),
            (
                "natural13",
                "natural",
                "xianzaiwaimiandexuexiadehenpiaoliang"
            ),
            (
                "natural14",
                "natural",
                "nigangcaishuodefangfahenyouyong"
            ),
            (
                "natural15",
                "natural",
                "woxiwangmeitiandounengkaixin"
            ),
            (
                "natural16",
                "natural",
                "zhoubianyouhenduohaochidecanguan"
            ),
            (
                "ambiguous01",
                "repeated",
                "shishishishishishishishishishishishi"
            ),
            (
                "ambiguous02",
                "repeated",
                "yiyiyiyiyiyiyiyiyiyiyiyiyiyiyi"
            ),
            (
                "ambiguous03",
                "repeated",
                "qiqiqiqiqiqiqiqiqiqiqiqiqiqiqi"
            ),
            (
                "ambiguous04",
                "repeated",
                "nananananananananananananananana"
            ),
            (
                "poor01",
                "poor",
                String(repeating: "a", count: 18)
            ),
            (
                "poor02",
                "poor",
                "abcdefghijklmnopqr"
            ),
            ("threshold01", "threshold", "jintiandetianqihe"),
            ("threshold02", "threshold", "qingjizhunbehao"),
        ]

        var proposalCount = 0
        var maximalAcceptedCount = 0
        var twoSyllableAcceptedCount = 0
        var maximalAcceptedButTwoRejectedCount = 0
        var poorTwoSyllableAcceptedCount = 0
        var rows: [String] = []

        for item in cases {
            let digits = t9Digits(for: item.spelling)
            engine.bridge.clearComposition()
            var firstProposal: T9ReversibleAutoAnchorPolicy.Proposal?
            var proposalOutput: RimeOutput?
            var proposalSlot = 0

            for (offset, digit) in digits.enumerated() {
                let output = engine.processKey(String(digit))
                let sourceSlot = offset + 1
                guard sourceSlot >= 18,
                    let proposal =
                        T9ReversibleAutoAnchorPolicy.proposal(
                            sourceDigits: String(
                                digits.prefix(sourceSlot)
                            ),
                            output: output
                        )
                else {
                    continue
                }
                firstProposal = proposal
                proposalOutput = output
                proposalSlot = sourceSlot
                break
            }

            guard let maximalProposal = firstProposal,
                let baselineOutput = proposalOutput
            else {
                rows.append(
                    [
                        "case=\(item.id)",
                        "category=\(item.category)",
                        "slots=\(digits.count)",
                        "proposal=false",
                    ].joined(separator: ",")
                )
                continue
            }

            proposalCount += 1
            let baselineCandidates = Array(
                baselineOutput.candidates.prefix(
                    T9ReversibleAutoAnchorPolicy.Configuration
                        .experimental.evidenceCandidateLimit
                )
            )
            let maximalAttempt = runTransaction(
                engine: engine,
                sourceSlot: proposalSlot,
                proposal: maximalProposal,
                baselineCandidates: baselineCandidates
            )
            if maximalAttempt.accepted {
                maximalAcceptedCount += 1
            }

            let twoSyllableProposal: T9ReversibleAutoAnchorPolicy.Proposal?
            if maximalProposal.anchoredSyllables.count == 2 {
                twoSyllableProposal = maximalProposal
            } else {
                twoSyllableProposal = makeBackoffProposal(
                    from: maximalProposal,
                    syllableCount: 2,
                    baselineCandidates: baselineCandidates
                )
            }
            let twoSyllableAttempt = twoSyllableProposal.map {
                runTransaction(
                    engine: engine,
                    sourceSlot: proposalSlot,
                    proposal: $0,
                    baselineCandidates: baselineCandidates
                )
            }
            if twoSyllableAttempt?.accepted == true {
                twoSyllableAcceptedCount += 1
                if item.category == "poor" {
                    poorTwoSyllableAcceptedCount += 1
                }
            }
            if maximalAttempt.accepted,
                twoSyllableAttempt?.accepted != true
            {
                maximalAcceptedButTwoRejectedCount += 1
            }

            rows.append(
                [
                    "case=\(item.id)",
                    "category=\(item.category)",
                    "slots=\(digits.count)",
                    "proposalSlot=\(proposalSlot)",
                    "maxDepth=\(maximalAttempt.anchoredSyllableCount)",
                    "maxOverlap=\(maximalAttempt.overlappingCandidateCount)",
                    "maxAccepted=\(maximalAttempt.accepted)",
                    "twoOverlap="
                        + String(
                            twoSyllableAttempt?
                                .overlappingCandidateCount
                                ?? 0
                        ),
                    "twoAccepted=\(twoSyllableAttempt?.accepted ?? false)",
                ].joined(separator: ",")
            )
        }
        engine.bridge.clearComposition()
        XCTAssertEqual(
            proposalCount,
            21,
            "Pinned reviewed-corpus proposal coverage drifted."
        )
        XCTAssertEqual(
            maximalAcceptedCount,
            8,
            "Pinned maximal-prefix acceptance distribution drifted."
        )
        XCTAssertEqual(
            twoSyllableAcceptedCount,
            9,
            "Pinned two-syllable acceptance distribution drifted."
        )
        XCTAssertEqual(
            maximalAcceptedButTwoRejectedCount,
            0,
            "Two-syllable cap regressed a case accepted by the maximal prefix."
        )
        XCTAssertEqual(
            poorTwoSyllableAcceptedCount,
            0,
            "Two-syllable cap accepted a frozen poor-input case."
        )
        return [
            "T9_AUTO_ANCHOR_REVIEWED_CORPUS",
            "cases=\(cases.count)",
            "proposals=\(proposalCount)",
            "maxAccepted=\(maximalAcceptedCount)",
            "twoAccepted=\(twoSyllableAcceptedCount)",
            "rows=\(rows.joined(separator: ";"))",
        ].joined(separator: " ")
    }

    private func assertRestored(
        _ restored: RimeOutput,
        sourceDigits: String,
        baselineCandidates: [RimeCandidate],
        sourceSlot: Int
    ) {
        XCTAssertNil(
            restored.committedText,
            "Restore unexpectedly committed text at source slot \(sourceSlot)."
        )
        XCTAssertEqual(
            T9PinyinPathExtractor.normalizeRawIdentity(restored.rawInput),
            T9PinyinPathExtractor.normalizeRawIdentity(sourceDigits),
            "Restore did not recover pure-digit identity at source slot \(sourceSlot)."
        )
        XCTAssertFalse(
            restored.composition?.preeditText.isEmpty ?? true,
            "Restore lost the active composition at source slot \(sourceSlot)."
        )

        let restoredCandidates = Array(
            restored.candidates.prefix(baselineCandidates.count)
        )
        XCTAssertEqual(
            restoredCandidates.first?.text,
            baselineCandidates.first?.text,
            "Restore changed the first candidate at source slot \(sourceSlot)."
        )
        XCTAssertEqual(
            Set(restoredCandidates.map(\.text)),
            Set(baselineCandidates.map(\.text)),
            "Restore changed the bounded candidate set at source slot \(sourceSlot)."
        )
    }

    private func format(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    private func t9Digits(for spelling: String) -> String {
        let mapping: [Character: Character] = [
            "a": "2", "b": "2", "c": "2",
            "d": "3", "e": "3", "f": "3",
            "g": "4", "h": "4", "i": "4",
            "j": "5", "k": "5", "l": "5",
            "m": "6", "n": "6", "o": "6",
            "p": "7", "q": "7", "r": "7", "s": "7",
            "t": "8", "u": "8", "v": "8",
            "w": "9", "x": "9", "y": "9", "z": "9",
        ]
        return String(spelling.lowercased().compactMap { mapping[$0] })
    }

    private func spikeRuntimeDirectories() throws -> (
        sharedDir: String,
        userDir: String
    ) {
        let env = ProcessInfo.processInfo.environment
        let sharedDir =
            env["UK_RIME_T9_SPIKE_SHARED_DIR"]
            ?? env["TEST_RUNNER_UK_RIME_T9_SPIKE_SHARED_DIR"]
        let userDir =
            env["UK_RIME_T9_SPIKE_USER_DIR"]
            ?? env["TEST_RUNNER_UK_RIME_T9_SPIKE_USER_DIR"]

        guard let sharedDir, let userDir else {
            throw XCTSkip(
                "Set isolated T9 Spike runtime directories to run this matrix."
            )
        }
        guard let authorizedUserURL = authorizedTemporaryUserRoot(userDir) else {
            XCTFail(
                "The T9 Spike user root must be a real descendant of /private/tmp."
            )
            throw FixtureSafetyError.userRootOutsidePrivateTemporaryDirectory
        }
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: sharedDir),
            fileManager.fileExists(atPath: authorizedUserURL.path),
            fileManager.fileExists(atPath: "\(sharedDir)/t9.schema.yaml"),
            fileManager.fileExists(
                atPath: "\(sharedDir)/rime_ice.schema.yaml"
            )
        else {
            throw XCTSkip("The isolated T9 Spike fixture is incomplete.")
        }
        return (sharedDir, authorizedUserURL.path)
    }

    private func authorizedTemporaryUserRoot(_ path: String) -> URL? {
        let temporaryRoot = URL(
            fileURLWithPath: "/private/tmp",
            isDirectory: true
        )
        .standardizedFileURL
        .resolvingSymlinksInPath()
        let candidate = URL(fileURLWithPath: path, isDirectory: true)
            .standardizedFileURL
            .resolvingSymlinksInPath()
        let rootComponents = temporaryRoot.pathComponents
        let candidateComponents = candidate.pathComponents
        guard candidateComponents.count > rootComponents.count,
            Array(candidateComponents.prefix(rootComponents.count))
                == rootComponents
        else {
            return nil
        }
        return candidate
    }

    private func assertSpikeSchemaIsPatched(sharedDir: String) throws {
        let schemaPath = "\(sharedDir)/t9.schema.yaml"
        let contents = try String(
            contentsOfFile: schemaPath,
            encoding: .utf8
        )
        XCTAssertFalse(contents.contains("t9_processor"))
        XCTAssertTrue(
            contents.contains("schema_id: t9")
                || contents.contains("schema_id:t9")
        )
        XCTAssertTrue(contents.contains("derive/[abc]/2/"))
    }
}
