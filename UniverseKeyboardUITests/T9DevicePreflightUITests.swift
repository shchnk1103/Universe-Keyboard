import CryptoKit
import Foundation
import XCTest

/// Opt-in physical-device driver for the S6-A Release-like A/B preflight.
///
/// The driver may only add an item to the reviewed disposable Reminders list.
/// It never reads host text, selects a candidate/Path, or deletes Reminders
/// state. Runtime output identifies the synthetic fixture only by its frozen
/// case ID, digest, action count, and cadence.
@MainActor
final class T9DevicePreflightUITests: XCTestCase {
    private enum EvidenceErrorCode: String, Equatable {
        case markerAbsent = "marker-absent"
        case markerMismatch = "marker-mismatch"
        case segmentCount = "segment-count"
        case segmentOrder = "segment-order"
        case commitDetected = "commit-detected"
        case sessionInvalid = "session-invalid"
        case summaryCount = "summary-count"
        case summaryInvalid = "summary-invalid"
        case outcomeCount = "outcome-count"
        case outcomeInvalid = "outcome-invalid"
    }

    private enum DriverError: Error {
        case hostUnavailable
        case disposableListUnavailable
        case reminderControlUnavailable
        case titleFieldUnavailable
        case keyboardSwitcherUnavailable
        case keyboardSelectionUnavailable
        case keyboardUnavailable
        case fixtureMappingFailed
        case keyUnavailable
        case extensionDisappeared
        case evidenceUnavailable

        var code: String {
            switch self {
            case .hostUnavailable: return "host-unavailable"
            case .disposableListUnavailable: return "disposable-list-unavailable"
            case .reminderControlUnavailable: return "reminder-control-unavailable"
            case .titleFieldUnavailable: return "title-field-unavailable"
            case .keyboardSwitcherUnavailable: return "keyboard-switcher-unavailable"
            case .keyboardSelectionUnavailable: return "keyboard-selection-unavailable"
            case .keyboardUnavailable: return "keyboard-unavailable"
            case .fixtureMappingFailed: return "fixture-mapping-failed"
            case .keyUnavailable: return "key-unavailable"
            case .extensionDisappeared: return "extension-disappeared"
            case .evidenceUnavailable: return "evidence-unavailable"
            }
        }
    }

    private let mainAppBundleIdentifier = "com.DoubleShy0N.Universe-Keyboard"
    private let remindersBundleIdentifier = "com.apple.reminders"
    private let springboardBundleIdentifier = "com.apple.springboard"

    private let runEnvironmentKey = "T9_S6A_DEVICE_PREFLIGHT_RUN"
    private let disposableListEnvironmentKey = "T9_S6A_DISPOSABLE_LIST"
    private let expectedMarkerEnvironmentKey = "T9_S6A_EXPECTED_MARKER"
    private let disposableListName = "Universe Keyboard S6A 20260728"

    private let fixtureID = "T9-LONG-38-V1"
    private let fixtureSHA256 =
        "7b5075d1b2ab4df823b896e9bedf5eef0aec9e1fb4500988d0169c45ee410b98"
    private let sourcePinyin = "jintiandetianqihenbucuowomenchuquwanba"
    private let actionCount = 38
    private let cadence: TimeInterval = 0.200
    private let maximumScheduleLag: TimeInterval = 0.050

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testFrozenFixtureContract() {
        validateFrozenFixture()
    }

    func testContentFreeIntervalStatisticsContract() {
        let intervals = [198.0, 199.0, 200.0, 201.0, 202.0]
        XCTAssertEqual(percentile(0.50, in: intervals), 200)
        XCTAssertEqual(percentile(0.95, in: intervals), 202)
        XCTAssertEqual(rounded(199.6), 200)
    }

    func testContentFreeEvidenceValidatorContracts() {
        let segments = validSyntheticSegments()
        let summary =
            "T9ARM actions=38 committed=0 session=42 "
            + "sessionStable=true sessionValid=true"

        XCTAssertNil(evidenceErrorCode(
            (["T9DEVICE marker=T9DEVICE_DISABLED gate=off measurement=on"]
                + segments + [summary])
                .joined(separator: "\n"),
            expectedMarker: "T9DEVICE_DISABLED"
        ))
        XCTAssertNil(evidenceErrorCode(
            (["T9DEVICE marker=T9DEVICE_ENABLED gate=on measurement=on"]
                + segments
                + ["T9AUTO status=accepted", summary])
                .joined(separator: "\n"),
            expectedMarker: "T9DEVICE_ENABLED"
        ))
    }

    func testContentFreeEvidenceValidatorFailsClosed() {
        let markerA = "T9DEVICE marker=T9DEVICE_DISABLED gate=off measurement=on"
        let markerB = "T9DEVICE marker=T9DEVICE_ENABLED gate=on measurement=on"
        let summary =
            "T9ARM actions=38 committed=0 session=42 "
                + "sessionStable=true sessionValid=true"
        let segments = validSyntheticSegments()

        XCTAssertEqual(
            evidenceErrorCode(
                ([markerA] + segments + [summary, markerB]).joined(separator: "\n"),
                expectedMarker: "T9DEVICE_DISABLED"
            ),
            .markerMismatch
        )
        XCTAssertEqual(
            evidenceErrorCode(
                ([markerA] + Array(segments.dropLast()) + [summary]).joined(separator: "\n"),
                expectedMarker: "T9DEVICE_DISABLED"
            ),
            .segmentCount
        )
        XCTAssertEqual(
            evidenceErrorCode(
                ([markerA] + segments + [segments[0], summary]).joined(separator: "\n"),
                expectedMarker: "T9DEVICE_DISABLED"
            ),
            .segmentCount
        )
        var outOfOrder = segments
        outOfOrder.swapAt(9, 10)
        XCTAssertEqual(
            evidenceErrorCode(
                ([markerA] + outOfOrder + [summary]).joined(separator: "\n"),
                expectedMarker: "T9DEVICE_DISABLED"
            ),
            .segmentOrder
        )
        var committed = segments
        committed[4] = committed[4].replacingOccurrences(
            of: "committed=false",
            with: "committed=true"
        )
        XCTAssertEqual(
            evidenceErrorCode(
                ([markerA] + committed + [summary]).joined(separator: "\n"),
                expectedMarker: "T9DEVICE_DISABLED"
            ),
            .commitDetected
        )
        var invalidSession = segments
        invalidSession[4] = invalidSession[4].replacingOccurrences(
            of: "validAfter=true",
            with: "validAfter=false"
        )
        XCTAssertEqual(
            evidenceErrorCode(
                ([markerA] + invalidSession + [summary]).joined(separator: "\n"),
                expectedMarker: "T9DEVICE_DISABLED"
            ),
            .sessionInvalid
        )
        XCTAssertEqual(
            evidenceErrorCode(
                ([markerA] + segments + ["T9AUTO status=accepted", summary])
                    .joined(separator: "\n"),
                expectedMarker: "T9DEVICE_DISABLED"
            ),
            .outcomeCount
        )
        XCTAssertEqual(
            evidenceErrorCode(
                ([markerB] + segments + [summary]).joined(separator: "\n"),
                expectedMarker: "T9DEVICE_ENABLED"
            ),
            .outcomeCount
        )
        XCTAssertEqual(
            evidenceErrorCode(
                ([markerB] + segments
                    + ["T9AUTO status=accepted", "T9AUTO status=rejectedAndRestored", summary])
                    .joined(separator: "\n"),
                expectedMarker: "T9DEVICE_ENABLED"
            ),
            .outcomeCount
        )
    }

    func testFrozenLongCompositionInDisposableRemindersList() throws {
        let expectedMarker = try requireExplicitDevicePreflightOptIn()
        validateFrozenFixture()

        let reminders = XCUIApplication(bundleIdentifier: remindersBundleIdentifier)
        // Preserve the Human-confirmed exact-list foreground state. `launch()`
        // terminates and relaunches Reminders, which can discard that trusted
        // navigation state before the driver verifies the list title.
        reminders.activate()
        var driverFailure: DriverError?
        var result: (actionStartTimes: [TimeInterval], scheduleLags: [TimeInterval])?
        do {
            guard reminders.wait(for: .runningForeground, timeout: 10) else {
                throw DriverError.hostUnavailable
            }
            try openDisposableList(in: reminders)
            let title = try createEmptyReminder(in: reminders)
            title.tap()
            try activateUniverseKeyboardIfNeeded(in: reminders)
            result = try driveFrozenFixture(in: reminders)
            guard reminders.buttons["键盘页面"].firstMatch.exists else {
                throw DriverError.extensionDisappeared
            }
            // The 38th action requests an ordered Logger flush. Keep the host
            // and extension visible after timing so the background writer can
            // finish before the evidence view replaces Reminders.
            RunLoop.current.run(until: Date().addingTimeInterval(1))
        } catch let error as DriverError {
            driverFailure = error
        }

        // Any XCTest failure is emitted only after Reminders is no longer
        // visible, preventing automatic failure screenshots from capturing
        // host text, preedit, candidates, or the keyboard surface.
        let evidence = try loadContentFreeEvidence()
        if let driverFailure {
            XCTFail("S6-A driver failed code=\(driverFailure.code).")
            return
        }
        guard let result else {
            XCTFail("S6-A driver returned no result.")
            return
        }

        let lagMilliseconds = result.scheduleLags.map { $0 * 1_000 }
        let intervalMilliseconds = zip(
            result.actionStartTimes.dropFirst(),
            result.actionStartTimes
        ).map { pair in
            (pair.0 - pair.1) * 1_000
        }

        let maximumLag = lagMilliseconds.max() ?? 0
        XCTAssertLessThanOrEqual(
            maximumLag,
            maximumScheduleLag * 1_000,
            "S6-A cadence driver exceeded its content-free schedule-lag bound."
        )
        validateEvidence(evidence, expectedMarker: expectedMarker)

        print(
            "T9_S6A_UI fixture=\(fixtureID) sha256=\(fixtureSHA256) "
                + "actions=\(result.actionStartTimes.count) cadenceMs=200 "
                + "medianIntervalMs=\(rounded(percentile(0.50, in: intervalMilliseconds))) "
                + "p95IntervalMs=\(rounded(percentile(0.95, in: intervalMilliseconds))) "
                + "worstIntervalMs=\(rounded(intervalMilliseconds.max() ?? 0)) "
                + "maxScheduleLagMs=\(rounded(maximumLag))"
        )
    }

    private func requireExplicitDevicePreflightOptIn() throws -> String {
        let environment = ProcessInfo.processInfo.environment
        try XCTSkipUnless(
            environment[runEnvironmentKey] == "1",
            "S6-A physical-device preflight is opt-in."
        )
        try XCTSkipUnless(
            environment[disposableListEnvironmentKey] == disposableListName,
            "S6-A requires Human confirmation of the exact disposable list."
        )
        let marker = environment[expectedMarkerEnvironmentKey]
        try XCTSkipUnless(
            marker == "T9DEVICE_DISABLED" || marker == "T9DEVICE_ENABLED",
            "S6-A requires an explicit expected binary marker."
        )
        return marker ?? ""
    }

    private func validateFrozenFixture() {
        XCTAssertEqual(sourcePinyin.count, actionCount, "Frozen fixture action count drifted.")
        let digest = SHA256.hash(data: Data(sourcePinyin.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        XCTAssertEqual(digest, fixtureSHA256, "Frozen fixture digest drifted.")
        XCTAssertEqual(
            sourcePinyin.compactMap(letterGroup(containing:)).count,
            actionCount,
            "Frozen fixture contains an unsupported action."
        )
    }

    private func openDisposableList(in app: XCUIApplication) throws {
        if isDisposableListOpen(in: app) {
            return
        }

        for _ in 0..<4 {
            if let list = exactDisposableListElement(in: app) {
                list.tap()
                guard waitUntil(timeout: 5, condition: {
                    self.isDisposableListOpen(in: app)
                }) else {
                    throw DriverError.disposableListUnavailable
                }
                return
            }

            let backButton = app.navigationBars.buttons.firstMatch
            guard backButton.exists, backButton.isHittable else {
                break
            }
            backButton.tap()
            _ = waitUntil(timeout: 2) {
                self.exactDisposableListElement(in: app) != nil
                    || self.isDisposableListOpen(in: app)
            }
        }

        throw DriverError.disposableListUnavailable
    }

    private func isDisposableListOpen(in app: XCUIApplication) -> Bool {
        app.navigationBars[disposableListName].exists
            || app.navigationBars.staticTexts[disposableListName].exists
    }

    private func exactDisposableListElement(
        in app: XCUIApplication
    ) -> XCUIElement? {
        let candidates = [
            app.buttons[disposableListName].firstMatch,
            app.staticTexts[disposableListName].firstMatch,
            app.cells.matching(
                NSPredicate(format: "label == %@", disposableListName)
            ).firstMatch,
        ]
        return candidates.first { $0.exists && $0.isHittable }
    }

    private func loadContentFreeEvidence() throws -> String {
        let app = XCUIApplication(bundleIdentifier: mainAppBundleIdentifier)
        app.launchEnvironment["T9_S6A_EVIDENCE_VIEW"] = "1"
        app.launch()
        guard app.wait(for: .runningForeground, timeout: 10) else {
            throw DriverError.evidenceUnavailable
        }

        let evidence = app.staticTexts["T9S6AEvidence"].firstMatch
        guard evidence.waitForExistence(timeout: 10) else {
            throw DriverError.evidenceUnavailable
        }
        return evidence.label
    }

    private func validateEvidence(
        _ evidence: String,
        expectedMarker: String
    ) {
        if let error = evidenceErrorCode(evidence, expectedMarker: expectedMarker) {
            XCTFail("S6-A evidence validation failed code=\(error.rawValue).")
        }
    }

    /// Validates only content-free records and returns a stable failure code.
    ///
    /// Scope starts after the latest marker of either arm, so stale evidence
    /// from an earlier run can never satisfy the expected binary identity.
    private func evidenceErrorCode(
        _ evidence: String,
        expectedMarker: String
    ) -> EvidenceErrorCode? {
        let lines = evidence.components(separatedBy: "\n")
        guard let markerIndex = lines.lastIndex(where: {
            $0.contains("T9DEVICE marker=")
        }) else {
            return .markerAbsent
        }
        guard lines[markerIndex].contains(
            "T9DEVICE marker=\(expectedMarker) "
        ) else {
            return .markerMismatch
        }

        let armLines = Array(lines.suffix(from: lines.index(after: markerIndex)))
        let segmentLines = armLines.filter { $0.contains("T9SEG action=") }
        guard segmentLines.count == actionCount else {
            return .segmentCount
        }
        for (index, line) in segmentLines.enumerated() {
            guard line.contains("action=\(index + 1) ") else {
                return .segmentOrder
            }
            guard line.contains("committed=false") else {
                return .commitDetected
            }
            guard line.contains("validBefore=true"),
                  line.contains("validAfter=true")
            else {
                return .sessionInvalid
            }
        }

        let summaries = armLines.filter { $0.contains("T9ARM actions=38 ") }
        guard summaries.count == 1, let summary = summaries.first else {
            return .summaryCount
        }
        guard summary.contains("committed=0"),
              summary.contains("sessionStable=true"),
              summary.contains("sessionValid=true")
        else {
            return .summaryInvalid
        }

        let outcomes = armLines.filter { $0.contains("T9AUTO status=") }
        if expectedMarker == "T9DEVICE_DISABLED" {
            guard outcomes.isEmpty else {
                return .outcomeCount
            }
        } else {
            guard outcomes.count == 1, let outcome = outcomes.first else {
                return .outcomeCount
            }
            guard outcome.contains("status=accepted")
                    || outcome.contains("status=rejectedAndRestored")
            else {
                return .outcomeInvalid
            }
        }
        return nil
    }

    private func validSyntheticSegments() -> [String] {
        (1...actionCount).map { action in
            "T9SEG action=\(action) committed=false "
                + "validBefore=true validAfter=true"
        }
    }

    private func createEmptyReminder(in app: XCUIApplication) throws -> XCUIElement {
        let addReminder = [
            app.buttons["新提醒事项"].firstMatch,
            app.buttons["New Reminder"].firstMatch,
        ].first { $0.exists && $0.isHittable }
        guard let addReminder else {
            throw DriverError.reminderControlUnavailable
        }
        addReminder.tap()

        let title = [
            app.textFields["标题"].firstMatch,
            app.textFields["Title"].firstMatch,
        ].first { $0.waitForExistence(timeout: 5) }
        guard let title else {
            throw DriverError.titleFieldUnavailable
        }
        return title
    }

    private func driveFrozenFixture(
        in app: XCUIApplication
    ) throws -> (actionStartTimes: [TimeInterval], scheduleLags: [TimeInterval]) {
        var actionStartTimes: [TimeInterval] = []
        var scheduleLags: [TimeInterval] = []
        actionStartTimes.reserveCapacity(actionCount)
        scheduleLags.reserveCapacity(actionCount)

        var scheduleOrigin: TimeInterval?
        for (index, letter) in sourcePinyin.enumerated() {
            guard let group = letterGroup(containing: letter) else {
                throw DriverError.fixtureMappingFailed
            }
            let key = t9Key(for: group, in: app)
            guard key.waitForExistence(timeout: 5), key.isHittable else {
                throw DriverError.keyUnavailable
            }

            if scheduleOrigin == nil {
                scheduleOrigin = ProcessInfo.processInfo.systemUptime
            }
            let scheduledStart =
                (scheduleOrigin ?? ProcessInfo.processInfo.systemUptime)
                + (Double(index) * cadence)
            waitUntil(monotonicTime: scheduledStart)
            let actualStart = ProcessInfo.processInfo.systemUptime
            actionStartTimes.append(actualStart)
            scheduleLags.append(max(0, actualStart - scheduledStart))
            key.tap()
        }

        return (actionStartTimes, scheduleLags)
    }

    private func activateUniverseKeyboardIfNeeded(
        in app: XCUIApplication
    ) throws {
        if app.buttons["键盘页面"].firstMatch.waitForExistence(timeout: 3) {
            return
        }

        var switcher = keyboardSwitcher(in: app)
        if switcher == nil {
            // This coordinate only reveals the system software keyboard on the
            // frozen iPhone host fixture; it never targets Reminder content.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.21, dy: 0.335)).tap()
            _ = waitUntil(timeout: 5) {
                switcher = self.keyboardSwitcher(in: app)
                return switcher != nil
            }
        }

        guard let availableSwitcher = switcher else {
            throw DriverError.keyboardSwitcherUnavailable
        }
        availableSwitcher.press(forDuration: 1)

        let springboard = XCUIApplication(bundleIdentifier: springboardBundleIdentifier)
        var selection: XCUIElement?
        _ = waitUntil(timeout: 5) {
            let candidates = [
                app.buttons["Universe Keyboard"].firstMatch,
                app.staticTexts["Universe Keyboard"].firstMatch,
                springboard.buttons["Universe Keyboard"].firstMatch,
                springboard.staticTexts["Universe Keyboard"].firstMatch,
            ]
            selection = candidates.first { $0.exists && $0.isHittable }
            return selection != nil
        }

        guard let selection else {
            throw DriverError.keyboardSelectionUnavailable
        }
        selection.tap()
        guard app.buttons["键盘页面"].firstMatch.waitForExistence(timeout: 10)
        else {
            throw DriverError.keyboardUnavailable
        }
    }

    private func keyboardSwitcher(in app: XCUIApplication) -> XCUIElement? {
        [
            app.buttons["下一个键盘"].firstMatch,
            app.buttons["Next Keyboard"].firstMatch,
            app.keys["下一个键盘"].firstMatch,
            app.keys["Next Keyboard"].firstMatch,
        ].first { $0.exists && $0.isHittable }
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

    private func waitUntil(
        timeout: TimeInterval,
        condition: () -> Bool
    ) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if condition() {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        } while Date() < deadline
        return condition()
    }

    private func waitUntil(monotonicTime target: TimeInterval) {
        while true {
            let now = ProcessInfo.processInfo.systemUptime
            guard now < target else {
                return
            }
            RunLoop.current.run(
                until: Date().addingTimeInterval(min(0.01, target - now))
            )
        }
    }

    private func percentile(
        _ percentile: Double,
        in values: [Double]
    ) -> Double {
        guard !values.isEmpty else {
            return 0
        }
        let sorted = values.sorted()
        let index = Int(
            (Double(sorted.count - 1) * percentile).rounded(.up)
        )
        return sorted[index]
    }

    private func rounded(_ value: Double) -> Int {
        Int(value.rounded())
    }
}
