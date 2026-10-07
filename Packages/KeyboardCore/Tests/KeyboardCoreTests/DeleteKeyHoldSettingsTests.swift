import XCTest

@testable import KeyboardCore

final class DeleteKeyHoldSettingsTests: XCTestCase {
    func testMissingKeysStayOn() {
        let defaults = makeIsolatedDefaults()
        XCTAssertEqual(DeleteKeyHoldFlags.load(from: defaults), .allEnabled)
        XCTAssertEqual(DeleteKeyHoldFlags.load(from: nil), .allEnabled)
    }

    func testExplicitFalseStaysOffAndDoesNotAffectOtherKeys() {
        let defaults = makeIsolatedDefaults()
        defaults.set(false, forKey: DeleteKeyHoldFlags.scrubKey)

        let flags = DeleteKeyHoldFlags.load(from: defaults)
        XCTAssertFalse(flags.scrubEnabled)
        XCTAssertTrue(flags.trashBubbleEnabled)
        XCTAssertTrue(flags.composingAbandonEnabled)
    }

    func testStoredTrueStaysOn() {
        let defaults = makeIsolatedDefaults()
        defaults.set(true, forKey: DeleteKeyHoldFlags.trashBubbleKey)
        defaults.set(true, forKey: DeleteKeyHoldFlags.scrubKey)
        defaults.set(true, forKey: DeleteKeyHoldFlags.composingAbandonKey)
        XCTAssertEqual(DeleteKeyHoldFlags.load(from: defaults), .allEnabled)
    }

    func testGapAndBubbleStaySeekableOnlyWhileTheBubbleIsVisible() {
        XCTAssertEqual(
            DeleteKeyHoldPolicy.outsideKeyIntent(
                trashBubbleEnabled: true,
                bubbleVisible: true,
                zone: .crossingGap
            ),
            .seekBubble(inBubble: false)
        )
        XCTAssertEqual(
            DeleteKeyHoldPolicy.outsideKeyIntent(
                trashBubbleEnabled: true,
                bubbleVisible: true,
                zone: .inBubble
            ),
            .seekBubble(inBubble: true)
        )
        XCTAssertEqual(
            DeleteKeyHoldPolicy.outsideKeyIntent(
                trashBubbleEnabled: true,
                bubbleVisible: true,
                zone: .elsewhere
            ),
            .stopWithoutResume
        )
    }

    func testReturnToKeyBlocksAnotherClearOnTheSamePress() {
        for zone in [DeleteKeyOffKeyZone.crossingGap, .inBubble, .elsewhere] {
            XCTAssertEqual(
                DeleteKeyHoldPolicy.outsideKeyIntent(
                    trashBubbleEnabled: true,
                    bubbleVisible: true,
                    zone: zone,
                    returnedToKey: true
                ),
                .stopWithoutResume
            )
        }
    }

    func testHiddenOrDisabledBubbleStopsImmediately() {
        for zone in [DeleteKeyOffKeyZone.crossingGap, .inBubble, .elsewhere] {
            XCTAssertEqual(
                DeleteKeyHoldPolicy.outsideKeyIntent(
                    trashBubbleEnabled: true,
                    bubbleVisible: false,
                    zone: zone
                ),
                .stopWithoutResume
            )
            XCTAssertEqual(
                DeleteKeyHoldPolicy.outsideKeyIntent(
                    trashBubbleEnabled: false,
                    bubbleVisible: true,
                    zone: zone
                ),
                .stopWithoutResume
            )
        }
    }

    private func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "DeleteKeyHoldSettingsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        addTeardownBlock {
            UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        }
        return defaults
    }
}
