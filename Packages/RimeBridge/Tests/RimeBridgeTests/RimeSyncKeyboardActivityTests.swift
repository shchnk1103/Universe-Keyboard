import Foundation
import XCTest

@testable import RimeBridge

final class RimeSyncKeyboardActivityTests: XCTestCase {
    func testFreshHeartbeatMarksKeyboardAsActive() {
        let defaults = makeDefaults()
        let now = Date(timeIntervalSince1970: 1_000)

        RimeSyncKeyboardActivity.recordVisibleKeyboard(in: defaults, now: now)

        XCTAssertTrue(RimeSyncKeyboardActivity.isKeyboardActive(in: defaults, now: now))
    }

    func testExpiredHeartbeatDoesNotBlockSync() {
        let defaults = makeDefaults()
        let now = Date(timeIntervalSince1970: 1_000)
        RimeSyncKeyboardActivity.recordVisibleKeyboard(in: defaults, now: now)

        XCTAssertFalse(
            RimeSyncKeyboardActivity.isKeyboardActive(
                in: defaults,
                now: now.addingTimeInterval(RimeSyncKeyboardActivity.heartbeatValidity)
            )
        )
    }

    func testFutureHeartbeatRemainsConservativelyActive() {
        let defaults = makeDefaults()
        let now = Date(timeIntervalSince1970: 1_000)
        RimeSyncKeyboardActivity.recordVisibleKeyboard(
            in: defaults,
            now: now.addingTimeInterval(3_600)
        )

        XCTAssertTrue(RimeSyncKeyboardActivity.isKeyboardActive(in: defaults, now: now))
    }

    func testClearingHeartbeatMarksKeyboardAsInactive() {
        let defaults = makeDefaults()
        RimeSyncKeyboardActivity.recordVisibleKeyboard(in: defaults)
        RimeSyncKeyboardActivity.clearVisibleKeyboard(in: defaults)

        XCTAssertFalse(RimeSyncKeyboardActivity.isKeyboardActive(in: defaults))
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "RimeSyncKeyboardActivityTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        addTeardownBlock {
            UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        }
        return defaults
    }
}
