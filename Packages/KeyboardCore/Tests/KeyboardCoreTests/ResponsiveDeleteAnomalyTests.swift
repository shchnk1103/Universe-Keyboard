import XCTest
@testable import KeyboardCore

/// RESPONSIVE-DELETE-ANOMALY-001: deferred processKey backlog + bound replace/Delete.
@MainActor
final class ResponsiveDeleteAnomalyTests: XCTestCase {

    /// Bound replaceInput captured before draining backlog is rejected as stale;
    /// after flush-before-bind, shortened replace must land without wipe.
    func testReplaceInputAfterDeferredKeysDoesNotStayStaleOrWipe() {
        let engine = FakeRimeEngine(dictionary: [
            "n": ["你"], "ni": ["你"], "nih": ["你"], "niha": ["你"], "nihao": ["你好"],
        ])
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = false
        controller.isResponsiveRimePipelineEnabled = true
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        guard let bridge = controller.rimeEngine as? ResponsiveRimeEngineBridge else {
            XCTFail("expected ResponsiveRimeEngineBridge")
            return
        }
        let coordinator = controller.responsiveRimeCoordinator!

        // Publish one key so lastPublished exists (binding target).
        coordinator.scheduleProcessKey("n")
        coordinator.flushPending()
        XCTAssertEqual(engine.sessionComposition, "n")

        // Backlog more keys without MainActor drain of Core apply path — queue them.
        coordinator.scheduleProcessKey("i")
        coordinator.scheduleProcessKey("h")
        coordinator.scheduleProcessKey("a")
        coordinator.scheduleProcessKey("o")
        XCTAssertGreaterThan(coordinator.diagnostics.pendingDepth, 0)

        // Visible-spelling-style shorten: must apply to head after backlog, not wipe.
        let shortened = bridge.replaceInput("niha")
        XCTAssertEqual(engine.sessionComposition, "niha")
        XCTAssertEqual(
            T9PinyinPathExtractor.normalizeRawIdentity(shortened.rawInput),
            T9PinyinPathExtractor.normalizeRawIdentity("niha")
        )
        XCTAssertFalse(shortened.composition?.preeditText.isEmpty == true)
    }

    /// Burst type then several Deletes: composition shrinks by delete count, not to empty.
    func testBurstTypeThenFewDeletesDoesNotWipeAll() {
        let engine = FakeRimeEngine(dictionary: [
            "n": ["你"], "ni": ["你"], "nih": ["你"], "niha": ["你"], "nihao": ["你好"],
        ])
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = false
        controller.isResponsiveRimePipelineEnabled = true
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        for ch in ["n", "i", "h", "a", "o"] {
            _ = controller.handle(.insertKey(ch))
        }
        controller.responsiveRimeCoordinator?.flushPending()
        XCTAssertEqual(engine.sessionComposition, "nihao")

        _ = controller.handle(.deleteBackward)
        controller.responsiveRimeCoordinator?.flushPending()
        _ = controller.handle(.deleteBackward)
        controller.responsiveRimeCoordinator?.flushPending()

        XCTAssertEqual(engine.sessionComposition, "nih")
        XCTAssertFalse(engine.sessionComposition.isEmpty)
        XCTAssertNotEqual(client.markedText, "")
    }

    /// T9 visible-spelling Delete after deferred digit backlog must not fail-closed wipe.
    func testT9VisibleDeleteAfterDeferredKeysShortensNotWipes() {
        let engine = FakeRimeEngine(
            dictionary: [
                "6": ["m", "n", "o"],
                "64": ["mi", "ni"],
                "648": ["niu"],
                "6484": ["miui"],
            ],
            preeditFormatter: { raw in
                let map: [Character: String] = ["6": "m", "4": "i", "8": "u"]
                return raw.compactMap { map[$0] }.joined()
            }
        )
        engine.appendDigitsToComposition = true

        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        controller.isResponsiveRimePipelineEnabled = true
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        for d in ["6", "4", "8", "4"] {
            _ = controller.handle(.insertKey(d))
        }
        controller.responsiveRimeCoordinator?.flushPending()

        let before = engine.sessionComposition
        XCTAssertFalse(before.isEmpty)

        // One Delete should shorten, not resetSession/clear.
        _ = controller.handle(.deleteBackward)
        controller.responsiveRimeCoordinator?.flushPending()

        let after = engine.sessionComposition
        XCTAssertFalse(
            after.isEmpty && before.count > 1,
            "Delete must not wipe full T9 composition when backlog binding is involved"
        )
        XCTAssertLessThanOrEqual(after.count, before.count)
    }
}
