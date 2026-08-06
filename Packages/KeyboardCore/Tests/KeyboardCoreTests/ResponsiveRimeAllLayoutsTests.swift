import XCTest
@testable import KeyboardCore

/// RESPONSIVE-ALL-LAYOUTS-001: L0 serial owner is layout-universal for Chinese
/// RIME; L1 provisional dots remain T9-only. Tests arm the gate explicitly.
@MainActor
final class ResponsiveRimeAllLayoutsTests: XCTestCase {

    // MARK: - Defaults

    func testGateDefaultsOffForNonT9Controller() {
        let controller = KeyboardController()
        XCTAssertFalse(controller.isResponsiveRimePipelineEnabled)
        XCTAssertFalse(controller.usesT9InputSemantics)
        XCTAssertFalse(controller.isThreadAffineRimeOwnerEnabled)
        XCTAssertNil(controller.responsiveRimeCoordinator)
    }

    // MARK: - 26-key (non-T9) L0

    func testNonT9GateOnDefersProcessKeyUntilDrain() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(dictionary: [
            "n": ["你"], "ni": ["你", "呢"], "nih": ["你"], "niha": ["你"], "nihao": ["你好"],
        ])
        let controller = makeNonT9ResponsiveController(client: client, engine: engine)

        var presentationCount = 0
        let presented = expectation(description: "non-T9 presentation")
        presented.assertForOverFulfill = false
        controller.onResponsivePresentationNeeded = { _ in
            presentationCount += 1
            if presentationCount == 1 {
                presented.fulfill()
            }
        }

        let started = DispatchTime.now().uptimeNanoseconds
        _ = controller.handle(.insertKey("n"))
        let elapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- started) / 1_000_000.0

        XCTAssertEqual(engine.processKeyCallCount, 0, "accept must not wait on engine")
        XCTAssertLessThan(elapsedMS, 50)
        XCTAssertFalse(
            controller.isResponsiveProvisionalAhead,
            "26-key must not arm T9 L1 provisional dots"
        )

        wait(for: [presented], timeout: 2)
        controller.responsiveRimeCoordinator?.flushPending()
        XCTAssertEqual(engine.processKeyCallCount, 1)
        XCTAssertEqual(engine.sessionComposition, "n")
    }

    func testNonT9OrderedLetterSequenceAndDelete() {
        let engine = FakeRimeEngine(dictionary: [
            "n": ["你"], "ni": ["你"], "w": ["我"],
        ])
        let controller = makeNonT9ResponsiveController(
            client: FakeTextInputClient(),
            engine: engine
        )

        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        controller.responsiveRimeCoordinator?.flushPending()
        XCTAssertEqual(engine.sessionComposition, "ni")

        _ = controller.handle(.deleteBackward)
        controller.responsiveRimeCoordinator?.flushPending()
        XCTAssertEqual(engine.sessionComposition, "n")
    }

    func testNonT9CandidateSelectAfterDeferredKeys() {
        let engine = FakeRimeEngine(dictionary: ["ni": ["你", "呢"]])
        let controller = makeNonT9ResponsiveController(
            client: FakeTextInputClient(),
            engine: engine
        )

        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        controller.responsiveRimeCoordinator?.flushPending()

        let candidates = controller.state.lastRimeOutput?.candidates ?? []
        XCTAssertFalse(candidates.isEmpty)
        let firstText = candidates[0].text
        _ = controller.handle(.insertCandidate(firstText, kind: .candidate))
        controller.responsiveRimeCoordinator?.flushPending()

        XCTAssertEqual(engine.sessionComposition, "")
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)
    }

    func testNonT9GateOffRestoresSynchronousPath() {
        let engine = FakeRimeEngine(dictionary: ["n": ["你"]])
        let controller = makeNonT9ResponsiveController(
            client: FakeTextInputClient(),
            engine: engine
        )
        XCTAssertTrue(controller.rimeEngine is ResponsiveRimeEngineBridge)

        controller.isResponsiveRimePipelineEnabled = false
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        XCTAssertTrue(controller.rimeEngine === engine)
        XCTAssertNil(controller.responsiveRimeCoordinator)

        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(engine.processKeyCallCount, 1)
        XCTAssertEqual(engine.sessionComposition, "n")
    }

    func testNonT9AbandonClearsDeferredContextsWithoutL1() {
        let engine = FakeRimeEngine()
        let controller = makeNonT9ResponsiveController(
            client: FakeTextInputClient(),
            engine: engine
        )

        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertFalse(controller.responsiveKeyApplyContexts.isEmpty)
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)

        _ = controller.abandonCompositionForVisibilityChange()
        XCTAssertTrue(controller.responsiveKeyApplyContexts.isEmpty)
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)

        _ = controller.handle(.insertKey("w"))
        controller.responsiveRimeCoordinator?.flushPending()
        XCTAssertEqual(engine.sessionComposition, "w")
    }

    // MARK: - T9 L1 remains T9-only

    func testT9WithoutDualGateDoesNotArmProvisionalL1() {
        let engine = FakeRimeEngine(dictionary: ["6": ["m", "n", "o"]])
        engine.appendDigitsToComposition = true
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        controller.isResponsiveRimePipelineEnabled = true
        // Dual-gate L1 requires thread-affine owner; MainActor R2 alone must not
        // leave provisional-ahead chrome for T9 digits.
        controller.isThreadAffineRimeOwnerEnabled = false
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        _ = controller.handle(.insertKey("6"))
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)

        controller.usesT9InputSemantics = false
        _ = controller.handle(.insertKey("n"))
        controller.responsiveRimeCoordinator?.flushPending()
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)
    }

    func testLayoutFlagSwitchClearsT9OnlyPresentationClaims() {
        let engine = FakeRimeEngine(dictionary: [
            "n": ["你"], "6": ["m", "n", "o"],
        ])
        let controller = makeNonT9ResponsiveController(
            client: FakeTextInputClient(),
            engine: engine
        )

        _ = controller.handle(.insertKey("n"))
        controller.responsiveRimeCoordinator?.flushPending()
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)

        // Switching to T9 semantics must not invent L1 without dual-gate + digit accept.
        controller.usesT9InputSemantics = true
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)

        controller.usesT9InputSemantics = false
        _ = controller.handle(.insertKey("i"))
        controller.responsiveRimeCoordinator?.flushPending()
        XCTAssertEqual(engine.sessionComposition, "ni")
        XCTAssertFalse(controller.isResponsiveProvisionalAhead)
    }

    // MARK: - Helpers

    private func makeNonT9ResponsiveController(
        client: FakeTextInputClient,
        engine: FakeRimeEngine
    ) -> KeyboardController {
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = false
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = false
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        XCTAssertNotNil(controller.responsiveRimeCoordinator)
        XCTAssertTrue(controller.rimeEngine is ResponsiveRimeEngineBridge)
        return controller
    }
}
