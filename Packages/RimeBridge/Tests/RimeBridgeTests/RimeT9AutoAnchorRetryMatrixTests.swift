import CryptoKit
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
    /// Keeps the historical maximal-prefix arm available as a test-only
    /// comparator while `.experimental` exercises the S4 two-syllable cap.
    private let maximalPrefixConfiguration =
        T9ReversibleAutoAnchorPolicy.Configuration()

    private enum FixtureSafetyError: Error {
        case deploymentFailed
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

    private struct S4PairedArmSummary {
        let pairIndex: Int
        let runID: String
        let gateEnabled: Bool
        let startupValid: Bool
        let sessionValid: Bool
        let cleanupSucceeded: Bool
        let durationsMs: [Double]
        let librimeDurationsMs: [Double]
        let outcome: T9ReversibleAutoAnchorOutcome?
        let invalidReasons: [String]

        var isValid: Bool {
            startupValid
                && sessionValid
                && cleanupSucceeded
                && invalidReasons.isEmpty
                && durationsMs.count == 38
                && librimeDurationsMs.count == 38
        }
    }

    private enum S21Arm: String, CaseIterable {
        case a0
        case a1
        case b2
        /// S2.2 triple-rolling internal arm (B3).
        case b3
        /// S2.3 earlier first-anchor on A1.
        case a1e
        /// S2.3 earlier first-anchor on B2.
        case b2e
        /// S2.3 earlier first-anchor on B3.
        case b3e
    }

    private struct S21ArmSummary {
        let arm: S21Arm
        let replaceInputCount: Int
        let outcomes: [(action: Int, outcome: T9ReversibleAutoAnchorOutcome)]
        let completedActionCount: Int
        let sessionIdentityCount: Int
        let invalidReasons: [String]
    }

    /// Test-only decorator that keeps a real librime session underneath while
    /// forcing the second automatic result to fail candidate conservation.
    private final class SecondApplyDriftEngine: RimeEngine {
        let base: RimeEngineImpl
        let failPriorMixedRestore: Bool
        private(set) var replaceInputCount = 0
        private(set) var resetCount = 0
        private(set) var recoverCount = 0

        init(
            base: RimeEngineImpl,
            failPriorMixedRestore: Bool = false
        ) {
            self.base = base
            self.failPriorMixedRestore = failPriorMixedRestore
        }

        var runtimeSelection: RimeRuntimeSelection? {
            base.runtimeSelection
        }

        var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? {
            base.diagnosticSessionSnapshot
        }

        var onRuntimeSelectionChanged:
            ((RimeRuntimeSelection) -> Void)?
        {
            get { base.onRuntimeSelectionChanged }
            set { base.onRuntimeSelectionChanged = newValue }
        }

        func processKey(_ key: String) -> RimeOutput {
            base.processKey(key)
        }

        func selectCandidate(at index: Int) -> RimeOutput {
            base.selectCandidate(at: index)
        }

        func selectCandidate(globalIndex index: Int) -> RimeOutput {
            base.selectCandidate(globalIndex: index)
        }

        func candidateWindow(
            from globalIndex: Int,
            limit: Int
        ) -> RimeCandidateWindow {
            base.candidateWindow(from: globalIndex, limit: limit)
        }

        func deleteBackward() -> RimeOutput {
            base.deleteBackward()
        }

        func replaceInput(_ input: String) -> RimeOutput {
            replaceInputCount += 1
            let output = base.replaceInput(input)
            if replaceInputCount == 2,
                let first = output.candidates.first
            {
                var candidates = output.candidates
                candidates[0] = RimeCandidate(
                    text: first.text + "测试漂移",
                    comment: first.comment,
                    globalIndex: first.globalIndex
                )
                return replacingCandidates(in: output, with: candidates)
            }
            if replaceInputCount == 3, failPriorMixedRestore {
                return RimeOutput()
            }
            return output
        }

        func resetSession() {
            resetCount += 1
            base.resetSession()
        }

        func recoverSession() {
            recoverCount += 1
            base.recoverSession()
        }

        func suspendForVisibilityChange() {
            base.suspendForVisibilityChange()
        }

        func resumeAfterVisibilityChange() {
            base.resumeAfterVisibilityChange()
        }

        func isComposing() -> Bool {
            base.isComposing()
        }

        func pageUp() -> RimeOutput {
            base.pageUp()
        }

        func pageDown() -> RimeOutput {
            base.pageDown()
        }

        private func replacingCandidates(
            in output: RimeOutput,
            with candidates: [RimeCandidate]
        ) -> RimeOutput {
            RimeOutput(
                rawInput: output.rawInput,
                composition: output.composition,
                candidates: candidates,
                committedText: output.committedText,
                hasMorePages: output.hasMorePages,
                highlightedIndex: output.highlightedIndex,
                candidatePageNumber: output.candidatePageNumber,
                caretPositionInRaw: output.caretPositionInRaw,
                commitPreviewLength: output.commitPreviewLength
            )
        }
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

    @MainActor
    func testRollingControllerFrozenA0A1B2B3Matrix() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)
        let sourceDigits = t9Digits(
            for: "jintiandetianqihenbucuowomenchuquwanba"
        )
        XCTAssertEqual(sourceDigits.count, 38)

        var summaries: [S21ArmSummary] = []
        for arm in S21Arm.allCases {
            summaries.append(
                try await runS21Arm(
                    arm,
                    sourceDigits: sourceDigits,
                    sharedDir: directories.sharedDir,
                    userRoot: directories.userDir
                )
            )
        }

        let a0 = try XCTUnwrap(summaries.first { $0.arm == .a0 })
        let a1 = try XCTUnwrap(summaries.first { $0.arm == .a1 })
        let b2 = try XCTUnwrap(summaries.first { $0.arm == .b2 })
        let b3 = try XCTUnwrap(summaries.first { $0.arm == .b3 })
        let a1e = try XCTUnwrap(summaries.first { $0.arm == .a1e })
        let b2e = try XCTUnwrap(summaries.first { $0.arm == .b2e })
        let b3e = try XCTUnwrap(summaries.first { $0.arm == .b3e })

        XCTAssertEqual(a0.replaceInputCount, 0)
        XCTAssertTrue(a0.outcomes.isEmpty)

        XCTAssertEqual(a1.replaceInputCount, 1)
        XCTAssertEqual(a1.outcomes.count, 1)
        XCTAssertEqual(a1.outcomes.first?.outcome.status, .accepted)
        XCTAssertEqual(a1.outcomes.first?.outcome.attemptIndex, 1)

        XCTAssertEqual(b2.replaceInputCount, 2)
        XCTAssertEqual(b2.outcomes.count, 2)
        XCTAssertTrue(b2.outcomes.allSatisfy { $0.outcome.status == .accepted })
        XCTAssertEqual(
            b2.outcomes.map { $0.outcome.attemptIndex },
            [1, 2]
        )
        XCTAssertLessThan(
            b2.outcomes[0].action,
            b2.outcomes[1].action,
            "attempt 2 must be caused by a later physical key"
        )
        XCTAssertLessThanOrEqual(
            b2.outcomes[1].action,
            23,
            "the rolling extension missed the frozen pre-spike deadline"
        )

        XCTAssertEqual(b3.replaceInputCount, 3)
        XCTAssertEqual(b3.outcomes.count, 3)
        XCTAssertTrue(b3.outcomes.allSatisfy { $0.outcome.status == .accepted })
        XCTAssertEqual(
            b3.outcomes.map { $0.outcome.attemptIndex },
            [1, 2, 3]
        )
        XCTAssertLessThan(
            b3.outcomes[0].action,
            b3.outcomes[1].action
        )
        XCTAssertLessThan(
            b3.outcomes[1].action,
            b3.outcomes[2].action,
            "attempt 3 must be caused by a later physical key than attempt 2"
        )
        XCTAssertLessThanOrEqual(
            b3.outcomes[1].action,
            23,
            "B3 inherits the attempt-2 pre-spike deadline"
        )
        XCTAssertLessThanOrEqual(
            b3.outcomes[2].action,
            28,
            "attempt 3 missed the frozen S2.2 pre-late-spike deadline"
        )

        // S2.3 earlier-first arms: attempt 1 must land at physical ≤15.
        XCTAssertEqual(a1e.replaceInputCount, 1)
        XCTAssertEqual(a1e.outcomes.count, 1)
        XCTAssertEqual(a1e.outcomes.first?.outcome.status, .accepted)
        XCTAssertEqual(a1e.outcomes.first?.outcome.attemptIndex, 1)
        XCTAssertLessThanOrEqual(
            a1e.outcomes[0].action,
            15,
            "A1e attempt 1 missed the S2.3 earlier-first ordinal ceiling"
        )

        XCTAssertEqual(b2e.replaceInputCount, 2)
        XCTAssertEqual(b2e.outcomes.count, 2)
        XCTAssertTrue(b2e.outcomes.allSatisfy { $0.outcome.status == .accepted })
        XCTAssertEqual(
            b2e.outcomes.map { $0.outcome.attemptIndex },
            [1, 2]
        )
        XCTAssertLessThanOrEqual(b2e.outcomes[0].action, 15)
        XCTAssertLessThan(b2e.outcomes[0].action, b2e.outcomes[1].action)
        XCTAssertLessThanOrEqual(b2e.outcomes[1].action, 23)

        XCTAssertEqual(b3e.replaceInputCount, 3)
        XCTAssertEqual(b3e.outcomes.count, 3)
        XCTAssertTrue(b3e.outcomes.allSatisfy { $0.outcome.status == .accepted })
        XCTAssertEqual(
            b3e.outcomes.map { $0.outcome.attemptIndex },
            [1, 2, 3]
        )
        XCTAssertLessThanOrEqual(
            b3e.outcomes[0].action,
            15,
            "B3e attempt 1 missed the S2.3 earlier-first ordinal ceiling"
        )
        XCTAssertLessThan(b3e.outcomes[0].action, b3e.outcomes[1].action)
        XCTAssertLessThan(b3e.outcomes[1].action, b3e.outcomes[2].action)
        XCTAssertLessThanOrEqual(b3e.outcomes[1].action, 23)
        XCTAssertLessThanOrEqual(b3e.outcomes[2].action, 28)

        XCTAssertTrue(
            summaries.allSatisfy {
                $0.completedActionCount == 38
                    && $0.sessionIdentityCount == 1
                    && $0.invalidReasons.isEmpty
            }
        )
        let rows = summaries.map { summary in
            let outcomeRows = summary.outcomes.map {
                "action=\($0.action):attempt=\($0.outcome.attemptIndex)"
            }.joined(separator: "|")
            return [
                "arm=\(summary.arm.rawValue)",
                "actions=\(summary.completedActionCount)",
                "sessions=\(summary.sessionIdentityCount)",
                "replace=\(summary.replaceInputCount)",
                "outcomes=\(outcomeRows.isEmpty ? "none" : outcomeRows)",
                "invalid=\(summary.invalidReasons.joined(separator: "+"))",
            ].joined(separator: ",")
        }
        let record = "T9_S21_A0_A1_B2_B3_A1e_B2e_B3e " + rows.joined(separator: ";")
        fputs(record + "\n", stderr)
        print(record)
    }

    @MainActor
    func testRollingControllerRealRimeDeletePathAndPartialOwnership() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)
        let armUserURL = URL(
            fileURLWithPath: directories.userDir,
            isDirectory: true
        )
        .appendingPathComponent(
            "s21-ownership-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: armUserURL,
            withIntermediateDirectories: false
        )
        defer {
            try? FileManager.default.removeItem(at: armUserURL)
        }

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(
                    fileURLWithPath: directories.sharedDir,
                    isDirectory: true
                ),
                userDataURL: armUserURL,
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: armUserURL.path
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        XCTAssertTrue(engine.bridge.selectSchema("t9"))
        let sourceDigits = String(
            t9Digits(
                for: "jintiandetianqihenbucuowomenchuquwanba"
            ).prefix(20)
        )

        let deleteController = makeS21B2Controller(engine: engine)
        typeOnController(sourceDigits, controller: deleteController)
        XCTAssertEqual(
            deleteController.state.t9ReversibleAutoAnchorState
                .automaticApplyAttemptCount,
            2
        )
        let replaceBeforeDelete = engine.replaceInputCallCountForTesting
        _ = deleteController.handle(.deleteBackward)
        XCTAssertGreaterThanOrEqual(
            engine.replaceInputCallCountForTesting,
            replaceBeforeDelete + 1,
            "Delete must cross the full-digit rollback boundary before its normal path work"
        )
        XCTAssertEqual(
            T9PinyinPathExtractor.pureDigitRaw(
                deleteController.state.lastRimeOutput?.rawInput
            ),
            String(sourceDigits.dropLast())
        )
        XCTAssertNotEqual(
            deleteController.state.t9ReversibleAutoAnchorState.phase,
            .accepted
        )

        engine.bridge.clearComposition()
        let pathController = makeS21B2Controller(engine: engine)
        typeOnController(sourceDigits, controller: pathController)
        let path = try XCTUnwrap(
            pathController.state.t9PinyinPathState.compactPaths.first
        )
        _ = pathController.handle(.selectT9PinyinPath(path))
        XCTAssertEqual(
            pathController.state.t9ReversibleAutoAnchorState,
            T9ReversibleAutoAnchorState(phase: .rejected)
        )
        XCTAssertTrue(
            pathController.state.t9PinyinPathState.selectedPath != nil
                || !pathController.state.t9PinyinPathState
                    .confirmedSegmentValues.isEmpty
        )

        engine.bridge.clearComposition()
        let partialController = makeS21B2Controller(engine: engine)
        let partialSourceDigits = t9Digits(
            for: "jintiantianqihenhao"
        )
        typeOnController(
            partialSourceDigits,
            controller: partialController
        )
        XCTAssertEqual(
            partialController.state.t9ReversibleAutoAnchorState.phase,
            .accepted
        )
        let candidate = try XCTUnwrap(
            partialController.state.lastRimeOutput?.candidates
                .dropFirst(2)
                .first
        )
        _ = partialController.handle(
            .insertCandidate(
                candidate.text,
                kind: .candidate,
                selectionReference: CandidateSelectionReference(
                    page: 0,
                    indexOnPage: 2
                )
            )
        )
        XCTAssertNotNil(
            partialController.state.partialCommit,
            "the frozen long fixture must exercise a real partial selection"
        )
        XCTAssertEqual(
            partialController.state.t9ReversibleAutoAnchorState,
            T9ReversibleAutoAnchorState(phase: .rejected)
        )
    }

    @MainActor
    func testRollingControllerMissingLiveCompositionFailsClosedBeforeKey()
        async throws
    {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)
        let armUserURL = URL(
            fileURLWithPath: directories.userDir,
            isDirectory: true
        )
        .appendingPathComponent(
            "s21-missing-live-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: armUserURL,
            withIntermediateDirectories: false
        )
        defer {
            try? FileManager.default.removeItem(at: armUserURL)
        }

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(
                    fileURLWithPath: directories.sharedDir,
                    isDirectory: true
                ),
                userDataURL: armUserURL,
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: armUserURL.path
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        XCTAssertTrue(engine.bridge.selectSchema("t9"))

        let controller = makeS21B2Controller(engine: engine)
        let sourceDigits = String(
            t9Digits(
                for: "jintiandetianqihenbucuowomenchuquwanba"
            ).prefix(20)
        )
        typeOnController(sourceDigits, controller: controller)
        XCTAssertEqual(
            controller.state.t9ReversibleAutoAnchorState
                .automaticApplyAttemptCount,
            2
        )
        let sessionBefore = try XCTUnwrap(engine.diagnosticSessionSnapshot)

        // Preserve the controller's cached mixed raw while removing the live
        // native composition. This is the exact flag=false P1 reproduction.
        engine.bridge.clearComposition()
        XCTAssertFalse(engine.isComposing())
        XCTAssertFalse(controller.shouldRestoreRimeComposition)
        let processCallsBeforeKey = engine.processKeyCallCountForTesting
        let replaceCallsBeforeKey = engine.replaceInputCallCountForTesting
        let resetCallsBeforeKey = engine.resetSessionCallCountForTesting
        let recoveryCallsBeforeKey = engine.recoverSessionCallCountForTesting

        _ = controller.handle(.insertKey("2"))

        XCTAssertEqual(
            engine.processKeyCallCountForTesting,
            processCallsBeforeKey
        )
        XCTAssertEqual(
            engine.replaceInputCallCountForTesting,
            replaceCallsBeforeKey
        )
        XCTAssertEqual(
            engine.resetSessionCallCountForTesting,
            resetCallsBeforeKey + 1
        )
        XCTAssertEqual(
            engine.recoverSessionCallCountForTesting,
            recoveryCallsBeforeKey
        )
        XCTAssertEqual(
            engine.diagnosticSessionSnapshot,
            sessionBefore,
            "fail-closed must clear the same session, never create a replacement"
        )
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertTrue(controller.state.currentComposition.isEmpty)
        XCTAssertEqual(
            controller.state.t9ReversibleAutoAnchorState,
            T9ReversibleAutoAnchorState(
                phase: .rejected,
                automaticApplyAttemptCount: 2,
                lastAttemptSourceDigitCount: sourceDigits.count
            )
        )
    }

    @MainActor
    func testRollingControllerRealRimeSecondRejectRestoreMatrix() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)
        let armUserURL = URL(
            fileURLWithPath: directories.userDir,
            isDirectory: true
        )
        .appendingPathComponent(
            "s21-second-reject-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: armUserURL,
            withIntermediateDirectories: false
        )
        defer {
            try? FileManager.default.removeItem(at: armUserURL)
        }

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(
                    fileURLWithPath: directories.sharedDir,
                    isDirectory: true
                ),
                userDataURL: armUserURL,
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)
        let sourceDigits = String(
            t9Digits(
                for: "jintiandetianqihenbucuowomenchuquwanba"
            ).prefix(20)
        )

        do {
            let base = RimeEngineImpl(
                sharedDataDir: directories.sharedDir,
                userDataDir: armUserURL.path
            )
            defer {
                base.bridge.clearComposition()
                base.bridge.finalize()
            }
            XCTAssertTrue(base.bridge.selectSchema("t9"))
            let engine = SecondApplyDriftEngine(base: base)
            let controller = makeS21B2Controller(engine: engine)
            var outcomes: [T9ReversibleAutoAnchorOutcome] = []
            controller.onReversibleT9AutoAnchorOutcome = {
                outcomes.append($0)
            }

            typeOnController(sourceDigits, controller: controller)

            XCTAssertEqual(engine.replaceInputCount, 3)
            XCTAssertEqual(engine.resetCount, 0)
            XCTAssertEqual(engine.recoverCount, 0)
            XCTAssertEqual(outcomes.map(\.status), [
                .accepted, .rejectedAndRestored,
            ])
            XCTAssertEqual(outcomes.map(\.attemptIndex), [1, 2])
            XCTAssertEqual(
                controller.state.t9ReversibleAutoAnchorState.phase,
                .accepted
            )
            XCTAssertEqual(
                controller.state.t9ReversibleAutoAnchorState
                    .automaticApplyAttemptCount,
                2
            )
            XCTAssertEqual(
                controller.state.t9ReversibleAutoAnchorState
                    .anchoredSyllableCount,
                2
            )
            XCTAssertEqual(
                controller.state.lastRimeOutput?.rawInput,
                controller.state.t9ReversibleAutoAnchorState
                    .replacementRawInput
            )
        }

        do {
            let base = RimeEngineImpl(
                sharedDataDir: directories.sharedDir,
                userDataDir: armUserURL.path
            )
            defer {
                base.bridge.clearComposition()
                base.bridge.finalize()
            }
            XCTAssertTrue(base.bridge.selectSchema("t9"))
            let engine = SecondApplyDriftEngine(
                base: base,
                failPriorMixedRestore: true
            )
            let controller = makeS21B2Controller(engine: engine)
            var outcomes: [T9ReversibleAutoAnchorOutcome] = []
            controller.onReversibleT9AutoAnchorOutcome = {
                outcomes.append($0)
            }

            typeOnController(sourceDigits, controller: controller)

            XCTAssertEqual(engine.replaceInputCount, 3)
            XCTAssertEqual(engine.resetCount, 1)
            XCTAssertEqual(engine.recoverCount, 0)
            XCTAssertEqual(outcomes.map(\.status), [
                .accepted, .restoreFailed,
            ])
            XCTAssertNil(controller.state.lastRimeOutput)
            XCTAssertEqual(
                controller.state.t9ReversibleAutoAnchorState,
                T9ReversibleAutoAnchorState(
                    phase: .rejected,
                    automaticApplyAttemptCount: 2,
                    lastAttemptSourceDigitCount: sourceDigits.count
                )
            )
        }
    }

    @MainActor
    func testCappedTwoSyllableControllerFrozenPairedMatrix() async throws {
        let environment = ProcessInfo.processInfo.environment
        guard
            let implementationCommit = environmentValue(
                "UK_S4_IMPLEMENTATION_COMMIT",
                environment: environment
            ),
            isLowercaseSHA1(implementationCommit)
        else {
            throw XCTSkip(
                "Set the immutable 40-character lowercase S4 commit to run the paired matrix."
            )
        }

        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)
        let fixtureFingerprint = try canonicalDirectorySHA256(
            atPath: directories.sharedDir
        )
        let testBundle = Bundle(
            for: RimeT9AutoAnchorRetryMatrixTests.self
        )
        guard
            let executableURL = testBundle.executableURL,
            let testBundleID = testBundle.bundleIdentifier,
            let xcodeBuild = testBundle.object(
                forInfoDictionaryKey: "DTXcodeBuild"
            ) as? String,
            let simulatorID = environment["SIMULATOR_UDID"],
            let simulatorModel = environment["SIMULATOR_MODEL_IDENTIFIER"],
            let simulatorRuntime = environment["SIMULATOR_RUNTIME_VERSION"]
        else {
            XCTFail("The frozen S4 Run Header is incomplete.")
            return
        }
        let testExecutableSHA256 = try fileSHA256(at: executableURL)
        let sourceDigits = t9Digits(
            for: "jintiandetianqihenbucuowomenchuquwanba"
        )
        XCTAssertEqual(sourceDigits.count, 38)
        let matrixRunID = UUID().uuidString

        let gateOrders = [
            [false, true],
            [true, false],
            [false, true],
            [true, false],
            [false, true],
        ]
        var summaries: [S4PairedArmSummary] = []

        for (pairOffset, gateOrder) in gateOrders.enumerated() {
            for gateEnabled in gateOrder {
                summaries.append(
                    await runS4PairedArm(
                        pairIndex: pairOffset + 1,
                        runID: "\(matrixRunID)-\(pairOffset + 1)-\(gateEnabled ? "B" : "A")",
                        gateEnabled: gateEnabled,
                        sourceDigits: sourceDigits,
                        sharedDir: directories.sharedDir,
                        userRoot: directories.userDir
                    )
                )
            }
        }

        XCTAssertEqual(summaries.count, 10)
        let rows = summaries.map(s4PairedSummaryRow).joined(separator: ";")
        let validPairCount = (1...5).count { pairIndex in
            let pair = summaries.filter { $0.pairIndex == pairIndex }
            return pair.count == 2 && pair.allSatisfy(\.isValid)
        }
        let pairedDeltas = s4PairedDeltaRows(summaries)
            .joined(separator: ";")
        #if DEBUG
        let buildConfiguration = "Debug"
        #else
        let buildConfiguration = "Release"
        #endif
        let runHeader = [
            "runID=\(matrixRunID)",
            "commit=\(implementationCommit)",
            "fixture=\(fixtureFingerprint)",
            "testExecutable=\(testExecutableSHA256)",
            "xcodeBuild=\(xcodeBuild)",
            "configuration=\(buildConfiguration)",
            "testBundle=\(testBundleID)",
            "simulator=\(simulatorID)",
            "model=\(simulatorModel)",
            "runtime=\(simulatorRuntime)",
            "architecture=\(runtimeArchitecture)",
            "schema=t9",
            "userRootPolicy=generatedStrictPrivateTmpDescendant",
            "cadenceMs=200",
            "pairs=5",
            "validPairs=\(validPairCount)",
            "order=AB,BA,AB,BA,AB",
            "rows=\(rows)",
            "pairedDeltas=\(pairedDeltas)",
        ].joined(separator: " ")
        fputs("T9_S4_PAIRED \(runHeader)\n", stderr)
        print("T9_S4_PAIRED \(runHeader)")
        XCTAssertTrue(
            summaries.allSatisfy(\.isValid),
            "Invalid arms remain in the manifest; the paired matrix is Blocked."
        )
        XCTAssertEqual(
            validPairCount,
            5,
            "Fewer than five valid pairs makes the paired matrix Blocked."
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
                    output: baselineOutput,
                    configuration: maximalPrefixConfiguration
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

    @MainActor
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

    @MainActor
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

    @MainActor
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

    @MainActor
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
        var personalizedRollingOutcomes:
            [T9ReversibleAutoAnchorOutcome] = []
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

            if item.id == "knownPositive" {
                engine.bridge.clearComposition()
                let controller = makeS21B2Controller(engine: engine)
                controller.onReversibleT9AutoAnchorOutcome = {
                    personalizedRollingOutcomes.append($0)
                }
                typeOnController(sourceDigits, controller: controller)
                XCTAssertEqual(
                    personalizedRollingOutcomes.map(\.status),
                    [.accepted, .accepted]
                )
                XCTAssertEqual(
                    personalizedRollingOutcomes.map(\.attemptIndex),
                    [1, 2]
                )
                XCTAssertEqual(
                    controller.state.t9ReversibleAutoAnchorState
                        .automaticApplyAttemptCount,
                    2
                )
                XCTAssertNil(
                    controller.state.t9PinyinPathState.selectedPath,
                    "personalized rank remains preference evidence, not Path ownership"
                )
            }
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
            "rollingAccepted="
                + String(
                    personalizedRollingOutcomes.count {
                        $0.status == .accepted
                    }
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
            let proposal =
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
                        output: output,
                        configuration: maximalPrefixConfiguration
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
                        output: output,
                        configuration: maximalPrefixConfiguration
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
                            output: output,
                            configuration: maximalPrefixConfiguration
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

            let twoSyllableProposal =
                T9ReversibleAutoAnchorPolicy.proposal(
                    sourceDigits: String(digits.prefix(proposalSlot)),
                    output: baselineOutput
                )
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

    @MainActor
    private func runS21Arm(
        _ arm: S21Arm,
        sourceDigits: String,
        sharedDir: String,
        userRoot: String
    ) async throws -> S21ArmSummary {
        let armUserURL = URL(
            fileURLWithPath: userRoot,
            isDirectory: true
        )
        .appendingPathComponent(
            "s21-\(arm.rawValue)-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: armUserURL,
            withIntermediateDirectories: false
        )
        defer {
            try? FileManager.default.removeItem(at: armUserURL)
        }

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(
                    fileURLWithPath: sharedDir,
                    isDirectory: true
                ),
                userDataURL: armUserURL,
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let engine = RimeEngineImpl(
            sharedDataDir: sharedDir,
            userDataDir: armUserURL.path
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        var invalidReasons: [String] = []
        guard engine.bridge.selectSchema("t9") else {
            return S21ArmSummary(
                arm: arm,
                replaceInputCount: 0,
                outcomes: [],
                completedActionCount: 0,
                sessionIdentityCount: 0,
                invalidReasons: ["schemaSelectionFailed"]
            )
        }

        let controller = KeyboardController()
        controller.rimeEngine = engine
        controller.textClient = FakeTextInputClient()
        controller.usesT9InputSemantics = true
        controller.isReversibleT9AutoAnchorEnabled = arm != .a0
        controller.isRollingT9AutoAnchorEnabled =
            arm == .b2 || arm == .b3 || arm == .b2e || arm == .b3e
        controller.isTripleRollingT9AutoAnchorEnabled =
            arm == .b3 || arm == .b3e
        controller.isEarlierFirstT9AutoAnchorEnabled =
            arm == .a1e || arm == .b2e || arm == .b3e

        var currentAction = 0
        var outcomes: [
            (action: Int, outcome: T9ReversibleAutoAnchorOutcome)
        ] = []
        controller.onReversibleT9AutoAnchorOutcome = {
            outcomes.append((currentAction, $0))
        }
        var sessionIdentities: Set<UInt64> = []
        for (offset, digit) in sourceDigits.enumerated() {
            currentAction = offset + 1
            _ = controller.handle(.insertKey(String(digit)))
            if let snapshot = engine.diagnosticSessionSnapshot,
                snapshot.isValid
            {
                sessionIdentities.insert(snapshot.identity)
            } else {
                invalidReasons.append("invalidSession")
            }
            if controller.state.lastRimeOutput?.committedText != nil {
                invalidReasons.append("unexpectedCommit")
            }
            if controller.state.lastRimeOutput?.candidates.isEmpty != false {
                invalidReasons.append("missingCandidates")
            }
        }
        controller.onReversibleT9AutoAnchorOutcome = nil

        if controller.state.t9PinyinPathState.selectedPath != nil
            || !controller.state.t9PinyinPathState
                .confirmedSegmentValues.isEmpty
        {
            invalidReasons.append("userPathOwnershipChanged")
        }

        return S21ArmSummary(
            arm: arm,
            replaceInputCount: engine.replaceInputCallCountForTesting,
            outcomes: outcomes,
            completedActionCount: currentAction,
            sessionIdentityCount: sessionIdentities.count,
            invalidReasons: Array(Set(invalidReasons)).sorted()
        )
    }

    @MainActor
    private func makeS21B2Controller(
        engine: RimeEngine
    ) -> KeyboardController {
        let controller = KeyboardController()
        controller.rimeEngine = engine
        controller.textClient = FakeTextInputClient()
        controller.usesT9InputSemantics = true
        controller.isReversibleT9AutoAnchorEnabled = true
        controller.isRollingT9AutoAnchorEnabled = true
        return controller
    }

    @MainActor
    private func typeOnController(
        _ sourceDigits: String,
        controller: KeyboardController
    ) {
        for digit in sourceDigits {
            _ = controller.handle(.insertKey(String(digit)))
        }
    }

    @MainActor
    private func runS4PairedArm(
        pairIndex: Int,
        runID: String,
        gateEnabled: Bool,
        sourceDigits: String,
        sharedDir: String,
        userRoot: String
    ) async -> S4PairedArmSummary {
        let armUserURL = URL(
            fileURLWithPath: userRoot,
            isDirectory: true
        )
        .appendingPathComponent(
            "s4-pair-\(pairIndex)-\(gateEnabled ? "b" : "a")-\(UUID().uuidString)",
            isDirectory: true
        )
        var engine: RimeEngineImpl?
        var startupValid = false
        var sessionValid = false
        var cleanupSucceeded = false
        var durationsMs: [Double] = []
        var librimeDurationsMs: [Double] = []
        var outcome: T9ReversibleAutoAnchorOutcome?
        var invalidReasons: [String] = []

        do {
            try FileManager.default.createDirectory(
                at: armUserURL,
                withIntermediateDirectories: false
            )
            let deployResult = try await RimeDeploymentService().deploy(
                RimeDeploymentRequest(
                    mode: .fullCheck,
                    sharedDataURL: URL(
                        fileURLWithPath: sharedDir,
                        isDirectory: true
                    ),
                    userDataURL: armUserURL,
                    runtimeSmokeSchemaID: nil
                )
            )
            guard deployResult.succeeded else {
                invalidReasons.append("deploymentFailed")
                throw FixtureSafetyError.deploymentFailed
            }

            let liveEngine = RimeEngineImpl(
                sharedDataDir: sharedDir,
                userDataDir: armUserURL.path
            )
            engine = liveEngine
            sessionValid = liveEngine.bridge.selectSchema("t9")
            startupValid = sessionValid && !liveEngine.isComposing()
            if !sessionValid {
                invalidReasons.append("schemaSelectionFailed")
            }
            if !startupValid {
                invalidReasons.append("nonEmptyStartup")
            }

            let controller = KeyboardController()
            controller.rimeEngine = liveEngine
            controller.textClient = FakeTextInputClient()
            controller.usesT9InputSemantics = true
            controller.isReversibleT9AutoAnchorEnabled = gateEnabled
            var outcomes: [T9ReversibleAutoAnchorOutcome] = []
            controller.onReversibleT9AutoAnchorOutcome = {
                outcomes.append($0)
            }

            durationsMs.reserveCapacity(sourceDigits.count)
            librimeDurationsMs.reserveCapacity(sourceDigits.count)
            for (offset, digit) in sourceDigits.enumerated() {
                let start = ProcessInfo.processInfo.systemUptime
                _ = controller.handle(.insertKey(String(digit)))
                durationsMs.append(
                    (ProcessInfo.processInfo.systemUptime - start) * 1_000
                )
                if let librimeDuration =
                    liveEngine.lastLibrimeProcessKeyDurationMs
                {
                    librimeDurationsMs.append(librimeDuration)
                } else {
                    invalidReasons.append("missingProcessKeyTiming")
                }
                if controller.state.lastRimeOutput?.committedText != nil {
                    invalidReasons.append("unexpectedCommit")
                }
                if controller.state.lastRimeOutput?.candidates.isEmpty
                    != false
                {
                    invalidReasons.append("missingCandidates")
                }
                if offset + 1 < sourceDigits.count {
                    try await Task.sleep(for: .milliseconds(200))
                }
            }

            outcome = outcomes.first
            if controller.state.t9PinyinPathState.selectedPath != nil
                || !controller.state.t9PinyinPathState
                    .confirmedSegmentValues.isEmpty
            {
                invalidReasons.append("userPathOwnershipChanged")
            }
            if gateEnabled {
                if outcomes.count != 1 {
                    invalidReasons.append("unexpectedAttemptCount")
                }
                if outcome?.status != .accepted {
                    invalidReasons.append("attemptNotAccepted")
                }
                if outcome?.anchoredSlotCount != 7 {
                    invalidReasons.append("unexpectedAnchorDepth")
                }
                if controller.state.t9ReversibleAutoAnchorState.phase
                    != .accepted
                {
                    invalidReasons.append("acceptedLedgerMissing")
                }
            } else {
                if !outcomes.isEmpty {
                    invalidReasons.append("disabledGateAttempted")
                }
                if controller.state.t9ReversibleAutoAnchorState != .empty {
                    invalidReasons.append("disabledGateMutatedLedger")
                }
            }
            if durationsMs.count != 38 {
                invalidReasons.append("wrongKeyCount")
            }
            if librimeDurationsMs.count != 38 {
                invalidReasons.append("incompleteProcessKeyTiming")
            }
            controller.onReversibleT9AutoAnchorOutcome = nil
        } catch is CancellationError {
            invalidReasons.append("cancelled")
        } catch {
            if !invalidReasons.contains("deploymentFailed") {
                invalidReasons.append("executionError")
            }
        }

        engine?.bridge.clearComposition()
        engine?.bridge.finalize()
        do {
            if FileManager.default.fileExists(atPath: armUserURL.path) {
                try FileManager.default.removeItem(at: armUserURL)
            }
            cleanupSucceeded =
                !FileManager.default.fileExists(atPath: armUserURL.path)
        } catch {
            invalidReasons.append("cleanupFailed")
        }

        return S4PairedArmSummary(
            pairIndex: pairIndex,
            runID: runID,
            gateEnabled: gateEnabled,
            startupValid: startupValid,
            sessionValid: sessionValid,
            cleanupSucceeded: cleanupSucceeded,
            durationsMs: durationsMs,
            librimeDurationsMs: librimeDurationsMs,
            outcome: outcome,
            invalidReasons: Array(Set(invalidReasons)).sorted()
        )
    }

    private func environmentValue(
        _ key: String,
        environment: [String: String]
    ) -> String? {
        environment[key] ?? environment["TEST_RUNNER_\(key)"]
    }

    private func s4PairedSummaryRow(
        _ summary: S4PairedArmSummary
    ) -> String {
        let sorted = summary.durationsMs.sorted()
        let slowCount = summary.durationsMs.count { $0 >= 50 }
        let median = percentile(sorted, fraction: 0.5)
        let p95 = percentile(sorted, fraction: 0.95)
        let worst = sorted.last ?? 0
        let fixedSlots = [24, 32, 34].map { slot in
            String(
                format: "%d:%.1f",
                slot,
                summary.durationsMs.indices.contains(slot - 1)
                    ? summary.durationsMs[slot - 1]
                    : -1
            )
        }
        .joined(separator: ",")
        let totalSlots = summary.durationsMs.enumerated().map {
            String(format: "%d:%.1f", $0.offset + 1, $0.element)
        }
        .joined(separator: "|")
        let processSlots = summary.librimeDurationsMs.enumerated().map {
            String(format: "%d:%.1f", $0.offset + 1, $0.element)
        }
        .joined(separator: "|")
        return [
            "pair=\(summary.pairIndex)",
            "run=\(summary.runID)",
            "arm=\(summary.gateEnabled ? "B" : "A")",
            "valid=\(summary.isValid)",
            "reasons=\(summary.invalidReasons.joined(separator: "+"))",
            "startupValid=\(summary.startupValid)",
            "sessionValid=\(summary.sessionValid)",
            "cleanup=\(summary.cleanupSucceeded)",
            "keys=\(summary.durationsMs.count)",
            "attempt=\(summary.outcome?.status.rawValue ?? "none")",
            "anchorSlots=\(summary.outcome?.anchoredSlotCount ?? 0)",
            "unresolvedSlots=\(summary.outcome?.unresolvedSlotCount ?? 0)",
            "baseline=\(summary.outcome?.baselineCandidateCount ?? 0)",
            "result=\(summary.outcome?.resultingCandidateCount ?? 0)",
            "overlap=\(summary.outcome?.overlappingCandidateCount ?? 0)",
            "slow50=\(slowCount)",
            String(format: "median=%.1f", median),
            String(format: "p95=%.1f", p95),
            String(format: "worst=%.1f", worst),
            "slots=\(fixedSlots)",
            "totalBySlot=\(totalSlots)",
            "processKeyBySlot=\(processSlots)",
        ].joined(separator: ",")
    }

    private func s4PairedDeltaRows(
        _ summaries: [S4PairedArmSummary]
    ) -> [String] {
        (1...5).map { pairIndex in
            let pair = summaries.filter { $0.pairIndex == pairIndex }
            guard
                let a = pair.first(where: { !$0.gateEnabled }),
                let b = pair.first(where: \.gateEnabled),
                a.isValid,
                b.isValid
            else {
                return "pair=\(pairIndex),valid=false"
            }
            let aSorted = a.durationsMs.sorted()
            let bSorted = b.durationsMs.sorted()
            let slotDeltas = [24, 32, 34].map { slot in
                String(
                    format: "%d:%.1f",
                    slot,
                    b.durationsMs[slot - 1] - a.durationsMs[slot - 1]
                )
            }
            .joined(separator: ",")
            return [
                "pair=\(pairIndex)",
                "valid=true",
                "slow50=\(b.durationsMs.count { $0 >= 50 } - a.durationsMs.count { $0 >= 50 })",
                String(
                    format: "median=%.1f",
                    percentile(bSorted, fraction: 0.5)
                        - percentile(aSorted, fraction: 0.5)
                ),
                String(
                    format: "p95=%.1f",
                    percentile(bSorted, fraction: 0.95)
                        - percentile(aSorted, fraction: 0.95)
                ),
                String(
                    format: "worst=%.1f",
                    (bSorted.last ?? 0) - (aSorted.last ?? 0)
                ),
                "slots=\(slotDeltas)",
            ].joined(separator: ",")
        }
    }

    private func percentile(
        _ sortedValues: [Double],
        fraction: Double
    ) -> Double {
        guard let first = sortedValues.first else { return 0 }
        guard sortedValues.count > 1 else { return first }
        let position = Double(sortedValues.count - 1) * fraction
        let lowerIndex = Int(position.rounded(.down))
        let upperIndex = Int(position.rounded(.up))
        guard lowerIndex != upperIndex else {
            return sortedValues[lowerIndex]
        }
        let weight = position - Double(lowerIndex)
        return sortedValues[lowerIndex]
            + (sortedValues[upperIndex] - sortedValues[lowerIndex]) * weight
    }

    private var runtimeArchitecture: String {
        #if arch(arm64)
        "arm64"
        #elseif arch(x86_64)
        "x86_64"
        #else
        "unknown"
        #endif
    }

    private func isLowercaseSHA1(_ value: String) -> Bool {
        value.count == 40
            && value.allSatisfy { character in
                character.isNumber || ("a"..."f").contains(character)
            }
    }

    private func fileSHA256(at url: URL) throws -> String {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        return SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    private func canonicalDirectorySHA256(atPath path: String) throws -> String {
        let root = URL(fileURLWithPath: path, isDirectory: true)
            .standardizedFileURL
            .resolvingSymlinksInPath()
        let keys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .isSymbolicLinkKey,
        ]
        let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        )
        var files: [URL] = []
        while let url = enumerator?.nextObject() as? URL {
            let values = try url.resourceValues(forKeys: keys)
            if values.isRegularFile == true,
                values.isSymbolicLink != true
            {
                files.append(url)
            }
        }
        files.sort {
            $0.path.replacingOccurrences(of: root.path, with: "")
                < $1.path.replacingOccurrences(of: root.path, with: "")
        }

        var hasher = SHA256()
        for file in files {
            let relativePath = String(file.path.dropFirst(root.path.count))
            hasher.update(data: Data(relativePath.utf8))
            hasher.update(data: Data([0]))
            hasher.update(
                data: try Data(contentsOf: file, options: .mappedIfSafe)
            )
            hasher.update(data: Data([0]))
        }
        return hasher.finalize()
            .map { String(format: "%02x", $0) }
            .joined()
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
