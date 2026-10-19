import XCTest

@testable import KeyboardCore

final class T9ExactRetypeRecoveryTests: XCTestCase {
    private typealias Policy = T9ExactRetypeRecovery
    private let namespace = Policy.Namespace(ownerID: UUID(), sessionEpoch: 7, editingGeneration: 11)

    private func origin(_ digits: String = "94624", _ comment: String = "yin ci") throws -> Policy.Interpretation {
        try XCTUnwrap(Policy.Interpretation(sourceDigits: digits, adoptedComment: comment, visiblePreedit: comment))
    }

    private func advanced(_ ns: Policy.Namespace) -> Policy.Namespace {
        .init(ownerID: ns.ownerID, sessionEpoch: ns.sessionEpoch + 1, editingGeneration: ns.editingGeneration)
    }

    private func plan(_ policy: inout Policy, _ action: KeyboardAction, in ns: Policy.Namespace? = nil)
        -> Policy.Directive
    {
        policy.plan(for: action, namespace: ns ?? namespace, currentKeyboardType: .default)
    }

    private func output(_ raw: String, comment: String = "yin ci", committedText: String? = nil) -> RimeOutput {
        RimeOutput(
            rawInput: raw, composition: RimeComposition(preeditText: comment, cursorPosition: comment.count),
            candidates: [RimeCandidate(text: "test", comment: comment)], committedText: committedText,
            highlightedIndex: 0)
    }

    private func replayRequest() throws -> Policy.RestoreRequest {
        var policy = Policy()
        policy.didDelete(from: "94624", to: "9462", original: try origin(), namespace: namespace)
        policy.didDelete(from: "9462", to: "946", original: nil, namespace: namespace)
        XCTAssertNil(policy.didInsertDigit("2", from: "946", to: "9462", namespace: namespace))
        return try XCTUnwrap(policy.didInsertDigit("4", from: "9462", to: "94624", namespace: namespace))
    }

    func testYinciRestoresOnlyAtExactEndpointAndConsumesOneRecord() throws {
        var policy = Policy()
        policy.didDelete(from: "94624", to: "9462", original: try origin(), namespace: namespace)
        policy.didDelete(from: "9462", to: "946", original: nil, namespace: namespace)
        XCTAssertTrue(policy.hasHistory)
        XCTAssertNil(policy.didInsertDigit("2", from: "946", to: "9462", namespace: namespace))
        let request = try XCTUnwrap(policy.didInsertDigit("4", from: "9462", to: "94624", namespace: namespace))
        XCTAssertEqual(request.interpretation.spelling, "yinci")
        XCTAssertEqual(request.namespace, namespace)
        XCTAssertFalse(policy.hasHistory)
        XCTAssertNil(policy.didInsertDigit("4", from: "9462", to: "94624", namespace: namespace))
    }

    func testKeyiTwoSlotPrefixIsEligibleButSingleSlotPrefixIsNot() throws {
        var policy = Policy()
        policy.didDelete(from: "5394", to: "539", original: try origin("5394", "ke yi"), namespace: namespace)
        policy.didDelete(from: "539", to: "53", original: nil, namespace: namespace)
        XCTAssertNil(policy.didInsertDigit("9", from: "53", to: "539", namespace: namespace))
        XCTAssertEqual(
            policy.didInsertDigit("4", from: "539", to: "5394", namespace: namespace)?.interpretation.spelling, "keyi")
        policy.didDelete(from: "5394", to: "539", original: try origin("5394", "ke yi"), namespace: namespace)
        policy.didDelete(from: "539", to: "53", original: nil, namespace: namespace)
        policy.didDelete(from: "53", to: "5", original: nil, namespace: namespace)
        XCTAssertFalse(policy.hasHistory)
    }

    func testMalformedOrUnpresentedInterpretationsCannotStartHistory() {
        let cases: [(String, String?, String)] = [
            ("94624", "xin ai", "yin ci"), ("94624", nil, "yin ci"),
            ("94624", "yin cc", "yin cc"), ("94624", "yin", "yin"),
            ("94624", "yi nci", "yi nci"), ("94622", "yin ci", "yin ci"),
            ("946240", "yin ci", "yin ci"), ("94", "yi", "yi"),
            ("946249", "yin ci z", "yin ci z"), ("94624", "yin\tci", "yin ci"),
        ]
        for (digits, comment, visible) in cases {
            XCTAssertNil(Policy.Interpretation(sourceDigits: digits, adoptedComment: comment, visiblePreedit: visible))
        }
    }

    func testTypingBeforeCompletePrefixOrChangingTailDiscardsHistory() throws {
        var early = Policy()
        early.didDelete(from: "94624", to: "9462", original: try origin(), namespace: namespace)
        XCTAssertNil(early.didInsertDigit("4", from: "9462", to: "94624", namespace: namespace))
        XCTAssertFalse(early.hasHistory)
        var changed = Policy()
        changed.didDelete(from: "94624", to: "9462", original: try origin(), namespace: namespace)
        changed.didDelete(from: "9462", to: "946", original: nil, namespace: namespace)
        XCTAssertNil(changed.didInsertDigit("3", from: "946", to: "9463", namespace: namespace))
        XCTAssertFalse(changed.hasHistory)
    }

    func testDeleteDuringReplayAndSkippedSourceTransitionsDiscardHistory() throws {
        var policy = Policy()
        policy.didDelete(from: "94624", to: "9462", original: try origin(), namespace: namespace)
        policy.didDelete(from: "9462", to: "946", original: nil, namespace: namespace)
        _ = policy.didInsertDigit("2", from: "946", to: "9462", namespace: namespace)
        policy.didDelete(from: "9462", to: "946", original: nil, namespace: namespace)
        XCTAssertFalse(policy.hasHistory)
        policy.didDelete(from: "94624", to: "946", original: try origin(), namespace: namespace)
        XCTAssertFalse(policy.hasHistory, "A two-slot jump cannot pretend two real Deletes completed.")
    }

    func testEpochOwnerAndEditingGenerationEachInvalidateReplay() throws {
        let foreign: [Policy.Namespace] = [
            advanced(namespace),
            .init(ownerID: UUID(), sessionEpoch: 7, editingGeneration: 11),
            .init(ownerID: namespace.ownerID, sessionEpoch: 7, editingGeneration: 12),
        ]
        for ns in foreign {
            var policy = Policy()
            policy.didDelete(from: "94624", to: "9462", original: try origin(), namespace: namespace)
            policy.didDelete(from: "9462", to: "946", original: nil, namespace: ns)
            XCTAssertFalse(policy.hasHistory)
        }
    }

    func testSoftValidationRejectsWrongRawWrongCommentEmptyAndCommit() throws {
        let request = try replayRequest()
        XCTAssertTrue(Policy.acceptsSoftOutput(output("yinci"), for: request))
        XCTAssertFalse(Policy.acceptsSoftOutput(output("94624"), for: request))
        XCTAssertFalse(Policy.acceptsSoftOutput(output("yinci", comment: "xin ai"), for: request))
        XCTAssertFalse(Policy.acceptsSoftOutput(RimeOutput(), for: request))
        let committed = output("yinci", committedText: "unexpected")
        XCTAssertFalse(Policy.acceptsSoftOutput(committed, for: request))
    }

    func testEverySelectionCommitAndPagingActionIsBlockedWhileUntrusted() {
        let path = T9PinyinPath(displayText: "yin", replacementRawInput: "yin24")
        let correction = TypoCorrectionCommit(committedText: "test", originalInput: "x", correctedInput: "y", edits: [])
        let blocked: [KeyboardAction] = [
            .insertCandidate("test", kind: .candidate), .insertCandidate("test", kind: .composition),
            .insertCandidate("", kind: .placeholder), .insertCorrectionCandidate(correction),
            .insertDirectText("text"), .insertEmoji("emoji"), .insertSpace, .insertReturn,
            .selectT9PinyinPath(path), .cycleT9PinyinPath, .candidatePageUp, .candidatePageDown,
            .pressT9CommonPunctuation, .pressKaomoji, .insertKey("a"), .insertKey("1"), .insertKey("24"),
        ]
        for action in blocked {
            var policy = Policy()
            policy.freeze(verifiedDigits: "94624", namespace: namespace, terminal: false)
            XCTAssertEqual(plan(&policy, action), .block)
            XCTAssertEqual(policy.notice, .waitingForEdit)
        }
    }

    func testFirstExplicitDigitConsumesOneRecoveryBudgetAndNoSecondKeyIsQueued() throws {
        var policy = Policy()
        policy.freeze(verifiedDigits: "94624", namespace: namespace, terminal: false)
        guard case .recover(let request) = plan(&policy, .insertKey("9")) else { return XCTFail() }
        XCTAssertEqual(request.targetRawInput, "946249")
        XCTAssertFalse(request.startsNewComposition)
        XCTAssertEqual(plan(&policy, .insertKey("9")), .block)
        XCTAssertEqual(plan(&policy, .deleteBackward), .block)
        XCTAssertTrue(
            policy.completeRecovery(
                request, output: output("946249", comment: "yin ci z"),
                realizedNamespace: advanced(namespace), sessionValid: true, usesT9Semantics: true))
        XCTAssertFalse(policy.isSessionUntrusted)
        XCTAssertEqual(plan(&policy, .insertSpace, in: advanced(namespace)), .normal)
    }

    func testDeletePlansNonemptyAndEmptyTargetsWithoutDeletingHostText() {
        for digits in ["94624", "9"] {
            var policy = Policy()
            policy.freeze(verifiedDigits: digits, namespace: namespace, terminal: false)
            guard case .recover(let request) = plan(&policy, .deleteBackward) else { return XCTFail() }
            XCTAssertEqual(request.targetRawInput, String(digits.dropLast()))
            let result =
                request.targetRawInput.isEmpty ? RimeOutput() : output(request.targetRawInput, comment: "yin c")
            XCTAssertTrue(
                policy.completeRecovery(
                    request, output: result,
                    realizedNamespace: advanced(namespace), sessionValid: true, usesT9Semantics: true))
        }
    }

    func testFailedRecoveryRequiresExplicitCancellationBeforeFreshStart() {
        var policy = Policy()
        policy.freeze(verifiedDigits: "94624", namespace: namespace, terminal: false)
        guard case .recover(let request) = plan(&policy, .insertKey("9")) else { return XCTFail() }
        XCTAssertFalse(
            policy.completeRecovery(
                request, output: output("bar"),
                realizedNamespace: advanced(namespace), sessionValid: true, usesT9Semantics: true))
        XCTAssertEqual(policy.notice, .failed)
        XCTAssertEqual(plan(&policy, .insertKey("9"), in: advanced(namespace)), .block)
        XCTAssertEqual(plan(&policy, .deleteBackward, in: advanced(namespace)), .cancelSegment)
        policy.didCancelSegment(namespace: advanced(namespace))
        XCTAssertTrue(policy.isSessionUntrusted, "Cancelling display must not release an unknown live session.")
        guard case .recover(let fresh) = plan(&policy, .insertKey("9"), in: advanced(namespace)) else {
            return XCTFail()
        }
        XCTAssertEqual(fresh.targetRawInput, "9")
        XCTAssertTrue(fresh.startsNewComposition)
        XCTAssertTrue(
            policy.completeRecovery(
                fresh, output: output("9", comment: "y"),
                realizedNamespace: advanced(advanced(namespace)), sessionValid: true, usesT9Semantics: true))
        XCTAssertFalse(policy.isSessionUntrusted)
    }

    func testInvalidOrOverlongSourceFailsClosedWithoutReplayOrCrash() {
        for digits in ["", "94620", "yinci", "946249"] {
            var policy = Policy()
            policy.freeze(verifiedDigits: digits, namespace: namespace, terminal: false)
            XCTAssertTrue(policy.isSessionUntrusted)
            XCTAssertEqual(policy.notice, .failed)
            XCTAssertEqual(plan(&policy, .insertKey("9")), .block)
            XCTAssertEqual(plan(&policy, .deleteBackward), .cancelSegment)
        }
    }

    func testUnexpectedCommitGoesDirectlyToCancellationWithoutAnotherRecovery() {
        var policy = Policy()
        policy.freeze(verifiedDigits: "94624", namespace: namespace, terminal: true)
        XCTAssertEqual(plan(&policy, .insertKey("9")), .block)
        XCTAssertEqual(plan(&policy, .deleteBackward), .cancelSegment)
    }

    func testForeignMissingAndUnexpectedRecoveryIdentitiesCannotReleaseTrust() {
        let namespaces: [Policy.Namespace] = [
            namespace,
            .init(ownerID: UUID(), sessionEpoch: 8, editingGeneration: 11),
            .init(ownerID: namespace.ownerID, sessionEpoch: 8, editingGeneration: 12),
            .init(ownerID: namespace.ownerID, sessionEpoch: 9, editingGeneration: 11),
        ]
        for ns in namespaces {
            var policy = Policy()
            policy.freeze(verifiedDigits: "94624", namespace: namespace, terminal: false)
            guard case .recover(let request) = plan(&policy, .insertKey("9")) else { return XCTFail() }
            XCTAssertFalse(
                policy.completeRecovery(
                    request, output: output("946249", comment: "yin ci z"),
                    realizedNamespace: ns, sessionValid: true, usesT9Semantics: true))
            XCTAssertTrue(policy.isSessionUntrusted)
        }
        var policy = Policy()
        policy.freeze(verifiedDigits: "94624", namespace: namespace, terminal: false)
        XCTAssertEqual(
            policy.plan(for: .insertKey("9"), namespace: nil, currentKeyboardType: .default), .abandonContext)
        XCTAssertEqual(plan(&policy, .insertSpace, in: advanced(namespace)), .abandonContext)
    }

    func testLateRecoveryCannotReleaseNewFreezeOrCancelledSegment() {
        var policy = Policy()
        policy.freeze(verifiedDigits: "94624", namespace: namespace, terminal: false)
        guard case .recover(let old) = plan(&policy, .insertKey("9")) else { return XCTFail() }
        policy.didCancelSegment(namespace: namespace)
        XCTAssertFalse(
            policy.completeRecovery(
                old, output: output("946249", comment: "yin ci z"),
                realizedNamespace: advanced(namespace), sessionValid: true, usesT9Semantics: true))
        XCTAssertEqual(policy.notice, .needsFreshSession)
    }

    func testVisibilityFenceAndModeSwitchAreDistinctFromTrustRelease() {
        var policy = Policy()
        policy.freeze(verifiedDigits: "94624", namespace: namespace, terminal: false)
        XCTAssertEqual(plan(&policy, .toggleShift), .shiftOnly)
        XCTAssertEqual(plan(&policy, .togglePage), .cancelAndSwitch)
        XCTAssertEqual(plan(&policy, .toggleInputMode), .cancelAndSwitch)
        XCTAssertEqual(plan(&policy, .keyboardTypeChanged(.URL)), .cancelAndSwitch)
        XCTAssertEqual(plan(&policy, .keyboardTypeChanged(.default)), .block)
        policy.abandonAfterSessionFence()
        XCTAssertFalse(policy.isSessionUntrusted)
        XCTAssertEqual(plan(&policy, .insertReturn), .normal)
    }

    func testFallbackFreshStartRequiresCancellationAndNeverRetainsOldDigits() {
        var policy = Policy()
        policy.freeze(verifiedDigits: "94624", namespace: namespace, terminal: false)
        XCTAssertEqual(policy.planFreshNonT9Key("a", namespace: namespace), .block)
        policy.didCancelSegment(namespace: namespace)
        XCTAssertEqual(policy.planFreshNonT9Key("24", namespace: namespace), .block)
        guard case .recover(let request) = policy.planFreshNonT9Key("a", namespace: namespace) else {
            return XCTFail()
        }
        XCTAssertEqual(request.targetRawInput, "a")
        XCTAssertTrue(request.startsNewComposition)
        XCTAssertFalse(request.requiresT9Semantics)
        XCTAssertTrue(
            policy.completeRecovery(
                request, output: output("a", comment: "a"),
                realizedNamespace: advanced(namespace), sessionValid: true, usesT9Semantics: false))
        XCTAssertFalse(policy.isSessionUntrusted)
    }

    func testInvalidSessionFailClosedSchemaOrUnexpectedCommitRejectRecovery() {
        for failure in 0..<3 {
            var policy = Policy()
            policy.freeze(verifiedDigits: "94624", namespace: namespace, terminal: false)
            guard case .recover(let request) = plan(&policy, .insertKey("9")) else { return XCTFail() }
            let result = output("946249", comment: "yin ci z", committedText: failure == 2 ? "unexpected" : nil)
            XCTAssertFalse(
                policy.completeRecovery(
                    request, output: result,
                    realizedNamespace: advanced(namespace), sessionValid: failure != 0, usesT9Semantics: failure != 1))
            XCTAssertEqual(policy.notice, .failed)
        }
    }
}
