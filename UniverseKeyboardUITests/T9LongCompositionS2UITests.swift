import CoreFoundation
import XCTest

/// System-level evidence harness for the reversible S2 prototype.
///
/// This test is opt-in because it depends on a simulator where Universe
/// Keyboard is installed, enabled and backed by a deployed T9 runtime. It taps
/// the visible letter groups; digits remain an internal RIME identity.
@MainActor
final class T9LongCompositionS2UITests: XCTestCase {
    private let remindersBundleIdentifier = "com.apple.reminders"
    private let springboardBundleIdentifier = "com.apple.springboard"
    private let runEnvironmentKey = "T9_S2_LONG_COMPOSITION_RUN"
    private let sourcePinyin = "jintiandetianqihenbucuowomenchuquwanba"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testReversibleS2LongCompositionInReminders() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment[runEnvironmentKey] == "1",
            "Run only on the reviewed simulator fixture with deployed T9 resources."
        )

        let reminders = XCUIApplication(bundleIdentifier: remindersBundleIdentifier)
        reminders.launch()
        XCTAssertTrue(
            reminders.wait(for: .runningForeground, timeout: 10),
            "XCUITest could not launch Reminders."
        )

        var title = reminders.textFields["标题"].firstMatch
        if !title.waitForExistence(timeout: 2) {
            let addReminder = [
                reminders.buttons["新提醒事项"].firstMatch,
                reminders.buttons["New Reminder"].firstMatch,
            ].first { $0.exists && $0.isHittable }
            try XCTUnwrap(
                addReminder,
                "Neither an active title field nor the New Reminder button was available."
            ).tap()
            title = reminders.textFields["标题"].firstMatch
        }
        XCTAssertTrue(title.waitForExistence(timeout: 10), "Reminder title field was unavailable.")
        title.tap()

        try activateUniverseKeyboardIfNeeded(in: reminders)

        var tapDurations: [TimeInterval] = []
        tapDurations.reserveCapacity(sourcePinyin.count)
        for letter in sourcePinyin {
            let group = try XCTUnwrap(
                letterGroup(containing: letter),
                "No T9 group for \(letter)."
            )
            let key = t9Key(for: group, in: reminders)
            XCTAssertTrue(
                key.waitForExistence(timeout: 5) && key.isHittable,
                "The visible \(group) key was not hittable."
            )
            let startedAt = CFAbsoluteTimeGetCurrent()
            key.tap()
            tapDurations.append(CFAbsoluteTimeGetCurrent() - startedAt)
        }

        XCTAssertTrue(
            reminders.buttons["键盘页面"].firstMatch.exists,
            "Keyboard Extension disappeared during the long composition."
        )

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "S2 long composition completed in Reminders"
        attachment.lifetime = .keepAlways
        add(attachment)

        let milliseconds = tapDurations.map { Int(($0 * 1_000).rounded()) }
        print(
            "T9_S2_UI tapCount=\(milliseconds.count) "
                + "maxTapMs=\(milliseconds.max() ?? 0) "
                + "tailTapMs=\(milliseconds.suffix(12))"
        )
    }

    private func activateUniverseKeyboardIfNeeded(
        in app: XCUIApplication
    ) throws {
        if app.buttons["键盘页面"].firstMatch.waitForExistence(timeout: 3) {
            return
        }

        var switcher = [
            app.buttons["下一个键盘"].firstMatch,
            app.buttons["Next Keyboard"].firstMatch,
            app.keys["下一个键盘"].firstMatch,
            app.keys["Next Keyboard"].firstMatch,
        ].first { $0.exists && $0.isHittable }
        if switcher == nil {
            // iOS 27 Reminders can retain a dismissed-keyboard state across
            // launches. Its small host-owned keyboard button is not exposed as
            // a stable accessibility element, so use the fixed iPhone fixture
            // coordinate only to reveal the Apple keyboard.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.21, dy: 0.335)).tap()
            let deadline = Date().addingTimeInterval(5)
            repeat {
                switcher = [
                    app.buttons["下一个键盘"].firstMatch,
                    app.buttons["Next Keyboard"].firstMatch,
                    app.keys["下一个键盘"].firstMatch,
                    app.keys["Next Keyboard"].firstMatch,
                ].first { $0.exists && $0.isHittable }
                if switcher != nil { break }
                RunLoop.current.run(until: Date().addingTimeInterval(0.1))
            } while Date() < deadline
        }
        let availableSwitcher = try XCTUnwrap(
            switcher,
            "No hittable system keyboard switcher was exposed."
        )
        availableSwitcher.press(forDuration: 1)

        let springboard = XCUIApplication(bundleIdentifier: springboardBundleIdentifier)
        let deadline = Date().addingTimeInterval(5)
        var selection: XCUIElement?
        repeat {
            let candidates = [
                app.buttons["Universe Keyboard"].firstMatch,
                app.staticTexts["Universe Keyboard"].firstMatch,
                springboard.buttons["Universe Keyboard"].firstMatch,
                springboard.staticTexts["Universe Keyboard"].firstMatch,
            ]
            selection = candidates.first { $0.exists && $0.isHittable }
            if selection != nil { break }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        } while Date() < deadline

        let availableSelection = try XCTUnwrap(
            selection,
            "Universe Keyboard was not exposed in the system keyboard menu."
        )
        availableSelection.tap()
        XCTAssertTrue(
            app.buttons["键盘页面"].firstMatch.waitForExistence(timeout: 10),
            "Universe Keyboard-specific controls did not appear."
        )
    }

    private func t9Key(
        for group: String,
        in app: XCUIApplication
    ) -> XCUIElement {
        app.keys.matching(
            NSPredicate(format: "label BEGINSWITH[c] %@", group)
        ).firstMatch
    }

    private func letterGroup(containing letter: Character) -> String? {
        switch letter.lowercased() {
        case "a", "b", "c":
            return "ABC"
        case "d", "e", "f":
            return "DEF"
        case "g", "h", "i":
            return "GHI"
        case "j", "k", "l":
            return "JKL"
        case "m", "n", "o":
            return "MNO"
        case "p", "q", "r", "s":
            return "PQRS"
        case "t", "u", "v":
            return "TUV"
        case "w", "x", "y", "z":
            return "WXYZ"
        default:
            return nil
        }
    }
}
