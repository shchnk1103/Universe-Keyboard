import CryptoKit
import Foundation
import XCTest

/// Opt-in physical-device driver for the S6-A Release-like A/B preflight.
///
/// The driver creates an empty item only in the reviewed disposable Reminders
/// list. It never reads host text, selects a candidate/Path, or deletes host
/// state. Coordinates come exclusively from same-run Extension geometry.
@MainActor
final class T9DevicePreflightUITests: XCTestCase {
    fileprivate struct Geometry: Equatable {
        let token: String
        let digest: String
        let space: String
        let orientation: String
        let screen: CGRect
        let scale: CGFloat
        let keyboard: CGRect
        let slots: [CGRect]

        var canonical: String {
            "v1|run=\(token)|space=\(space)|orientation=\(orientation)"
                + "|screen=\(Self.rect(screen))|scale=\(Self.number(scale))"
                + "|keyboard=\(Self.rect(keyboard))|"
                + slots.enumerated()
                    .map { "s\($0.offset)=\(Self.rect($0.element))" }
                    .joined(separator: "|")
        }

        var computedDigest: String {
            SHA256.hash(data: Data(canonical.utf8))
                .map { String(format: "%02x", $0) }
                .joined()
        }

        private static func rect(_ rect: CGRect) -> String {
            [
                rect.origin.x,
                rect.origin.y,
                rect.size.width,
                rect.size.height,
            ].map(number).joined(separator: ",")
        }

        private static func number(_ value: CGFloat) -> String {
            String(
                format: "%.3f",
                locale: Locale(identifier: "en_US_POSIX"),
                Double(value)
            )
        }
    }

    private enum EvidenceErrorCode: String, Equatable {
        case markerAbsent = "marker-absent"
        case markerMismatch = "marker-mismatch"
        case markerCount = "marker-count"
        case geometryCount = "geometry-count"
        case geometryInvalid = "geometry-invalid"
        case geometryDrift = "geometry-drift"
        case segmentCount = "segment-count"
        case segmentOrder = "segment-order"
        case commitDetected = "commit-detected"
        case sessionInvalid = "session-invalid"
        case summaryCount = "summary-count"
        case summaryInvalid = "summary-invalid"
        case outcomeCount = "outcome-count"
        case outcomeInvalid = "outcome-invalid"
        case evidenceOrder = "evidence-order"
        case tokenMismatch = "token-mismatch"
    }

    private enum DriverError: Error, Equatable {
        case hostUnavailable
        case hostFrameUnavailable
        case disposableListUnavailable
        case reminderControlUnavailable
        case titleFieldUnavailable
        case tokenPreparationFailed
        case geometryUnavailable
        case tokenConsumptionInvalid
        case geometryInvalid
        case hostRestoreFailed
        case fixtureMappingFailed
        case evidenceUnavailable
        case tokenCleanupFailed

        var code: String {
            switch self {
            case .hostUnavailable: return "host-unavailable"
            case .hostFrameUnavailable: return "host-frame-unavailable"
            case .disposableListUnavailable: return "disposable-list-unavailable"
            case .reminderControlUnavailable: return "reminder-control-unavailable"
            case .titleFieldUnavailable: return "title-field-unavailable"
            case .tokenPreparationFailed: return "token-preparation-failed"
            case .geometryUnavailable: return "geometry-unavailable"
            case .tokenConsumptionInvalid: return "token-consumption-invalid"
            case .geometryInvalid: return "geometry-invalid"
            case .hostRestoreFailed: return "host-restore-failed"
            case .fixtureMappingFailed: return "fixture-mapping-failed"
            case .evidenceUnavailable: return "evidence-unavailable"
            case .tokenCleanupFailed: return "token-cleanup-failed"
            }
        }
    }

    private let mainAppBundleIdentifier = "com.DoubleShy0N.Universe-Keyboard"
    private let remindersBundleIdentifier = "com.apple.reminders"

    private let runEnvironmentKey = "T9_S6A_DEVICE_PREFLIGHT_RUN"
    private let disposableListEnvironmentKey = "T9_S6A_DISPOSABLE_LIST"
    private let expectedMarkerEnvironmentKey = "T9_S6A_EXPECTED_MARKER"
    private let prepareTokenEnvironmentKey = "T9_S6A_PREPARE_RUN_TOKEN"
    private let cleanupTokenEnvironmentKey = "T9_S6A_CLEANUP_RUN_TOKEN"
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

    func testContentFreeGeometryContracts() {
        let geometry = syntheticGeometry()
        XCTAssertNil(geometryError(geometry, foregroundFrame: geometry.screen))
        func assertInvalid(_ candidate: Geometry) {
            XCTAssertEqual(
                geometryError(candidate, foregroundFrame: candidate.screen),
                .geometryInvalid
            )
        }

        var slots = geometry.slots
        slots[0] = CGRect(x: slots[0].minX, y: slots[0].minY, width: 0, height: 45)
        assertInvalid(replacingSlots(in: geometry, with: slots))

        slots = geometry.slots
        slots[0] = CGRect(x: slots[0].minX, y: slots[0].minY, width: -1, height: 45)
        assertInvalid(replacingSlots(in: geometry, with: slots))

        slots = geometry.slots
        slots[0] = CGRect(x: slots[0].minX, y: slots[0].minY, width: 29, height: 45)
        assertInvalid(replacingSlots(in: geometry, with: slots))

        slots = geometry.slots
        slots[1] = slots[0]
        assertInvalid(replacingSlots(in: geometry, with: slots))

        slots = geometry.slots
        slots.swapAt(0, 1)
        assertInvalid(replacingSlots(in: geometry, with: slots))

        slots = geometry.slots
        slots[2] = CGRect(
            x: slots[2].minX,
            y: slots[2].minY + 5,
            width: slots[2].width,
            height: slots[2].height
        )
        assertInvalid(replacingSlots(in: geometry, with: slots))

        slots = geometry.slots
        slots[5] = CGRect(
            x: slots[5].minX,
            y: slots[2].minY,
            width: slots[5].width,
            height: slots[5].height
        )
        assertInvalid(replacingSlots(in: geometry, with: slots))

        slots = geometry.slots
        slots[0] = CGRect(x: -1, y: slots[0].minY, width: 70, height: 45)
        assertInvalid(replacingSlots(in: geometry, with: slots))

        slots = geometry.slots
        slots[0] = CGRect(x: slots[0].minX, y: 530, width: 70, height: 45)
        assertInvalid(replacingSlots(in: geometry, with: slots))

        assertInvalid(replacingSlots(in: geometry, with: []))
        assertInvalid(
            replacingSlots(
                in: geometry,
                with: Array(geometry.slots.dropLast())
            )
        )
        assertInvalid(
            replacingSlots(
                in: geometry,
                with: geometry.slots + [geometry.slots[7]]
            )
        )

        let landscapeScreen = CGRect(x: 0, y: 0, width: 844, height: 390)
        assertInvalid(replacingScreen(in: geometry, with: landscapeScreen))
        assertInvalid(
            replacingGeometry(
                in: geometry,
                space: "keyboard-local-points"
            )
        )
        assertInvalid(
            replacingGeometry(in: geometry, orientation: "landscape")
        )
        assertInvalid(replacingGeometry(in: geometry, scale: 0))
        assertInvalid(
            replacingGeometry(
                in: geometry,
                keyboard: CGRect(x: 0, y: 300, width: 390, height: 304)
            )
        )

        let wrongFrame = CGRect(
            x: 0,
            y: 0,
            width: geometry.screen.width - 1,
            height: geometry.screen.height
        )
        XCTAssertEqual(
            geometryError(geometry, foregroundFrame: wrongFrame),
            .geometryInvalid
        )

        let line = geometryLine(geometry, phase: "prepared")
        let slotZero =
            "s0=\(Geometry.rectForTesting(geometry.slots[0]))"
        let slotSeven =
            " s7=\(Geometry.rectForTesting(geometry.slots[7]))"
        XCTAssertNil(parseGeometry(from: line + " \(slotZero)"))
        XCTAssertNil(parseGeometry(
            from: line.replacingOccurrences(of: slotSeven, with: "")
        ))
        XCTAssertNil(parseGeometry(
            from: line + " s8=\(Geometry.rectForTesting(geometry.slots[7]))"
        ))
        XCTAssertNil(parseGeometry(
            from: line.replacingOccurrences(of: "scale=3.000", with: "scale=nan")
        ))
        XCTAssertNil(parseGeometry(
            from: line.replacingOccurrences(
                of: "scale=3.000",
                with: "scale=inf"
            )
        ))
    }

    func testForegroundHostSnapshotAndPreparedGeometryContracts() {
        let geometry = syntheticGeometry()
        let consumedEvidence =
            "T9TOKEN state=consumed run=\(geometry.token)"

        XCTAssertEqual(
            validatedForegroundFrame(
                geometry.screen,
                hostIsForeground: true
            ),
            geometry.screen
        )
        XCTAssertNil(
            validatedForegroundFrame(
                geometry.screen,
                hostIsForeground: false
            )
        )
        XCTAssertNil(
            validatedForegroundFrame(
                CGRect(x: 0, y: 0, width: 0, height: geometry.screen.height),
                hostIsForeground: true
            )
        )

        XCTAssertNil(
            preparedGeometryValidationError(
                geometry,
                evidence: consumedEvidence,
                token: geometry.token,
                foregroundFrame: geometry.screen
            )
        )
        XCTAssertEqual(
            preparedGeometryValidationError(
                geometry,
                evidence: "",
                token: geometry.token,
                foregroundFrame: geometry.screen
            ),
            .tokenConsumptionInvalid
        )
        XCTAssertEqual(
            preparedGeometryValidationError(
                geometry,
                evidence: consumedEvidence,
                token: geometry.token,
                foregroundFrame: CGRect(
                    x: 0,
                    y: 0,
                    width: geometry.screen.width - 1,
                    height: geometry.screen.height
                )
            ),
            .geometryInvalid
        )
    }

    func testContentFreeEvidenceValidatorContracts() {
        let token = syntheticToken
        let geometry = syntheticGeometry(token: token)
        let markerA =
            "T9DEVICE marker=T9DEVICE_DISABLED run=\(token) gate=off measurement=on"
        let markerB =
            "T9DEVICE marker=T9DEVICE_ENABLED run=\(token) gate=on measurement=on"
        let prepared = geometryLine(geometry, phase: "prepared")
        let execution = geometryLine(geometry, phase: "execution")
        let segments = validSyntheticSegments(token: token)
        let summary =
            "T9ARM run=\(token) actions=38 committed=0 session=42 "
                + "sessionStable=true sessionValid=true"
        let outcome =
            "T9AUTO run=\(token) action=18 event=18 status=accepted"
        let bLines =
            [markerB, prepared, execution]
            + Array(segments.prefix(17))
            + [outcome]
            + Array(segments.dropFirst(17))
            + [summary]

        XCTAssertNil(evidenceErrorCode(
            ([markerA, prepared, execution] + segments + [summary])
                .joined(separator: "\n"),
            expectedMarker: "T9DEVICE_DISABLED",
            token: token,
            preparedGeometry: geometry
        ))
        XCTAssertNil(evidenceErrorCode(
            bLines.joined(separator: "\n"),
            expectedMarker: "T9DEVICE_ENABLED",
            token: token,
            preparedGeometry: geometry
        ))
        XCTAssertNil(evidenceErrorCode(
            bLines.joined(separator: "\n").replacingOccurrences(
                of: "status=accepted",
                with: "status=rejectedAndRestored"
            ),
            expectedMarker: "T9DEVICE_ENABLED",
            token: token,
            preparedGeometry: geometry
        ))
    }

    func testContentFreeEvidenceValidatorFailsClosed() {
        let token = syntheticToken
        let geometry = syntheticGeometry(token: token)
        let markerA =
            "T9DEVICE marker=T9DEVICE_DISABLED run=\(token) gate=off measurement=on"
        let markerB =
            "T9DEVICE marker=T9DEVICE_ENABLED run=\(token) gate=on measurement=on"
        let prepared = geometryLine(geometry, phase: "prepared")
        let execution = geometryLine(geometry, phase: "execution")
        let segments = validSyntheticSegments(token: token)
        let summary =
            "T9ARM run=\(token) actions=38 committed=0 session=42 "
                + "sessionStable=true sessionValid=true"
        let outcome =
            "T9AUTO run=\(token) action=18 event=18 status=accepted"
        func error(
            _ lines: [String],
            marker: String = "T9DEVICE_DISABLED",
            preparedGeometry: Geometry = geometry
        ) -> EvidenceErrorCode? {
            evidenceErrorCode(
                lines.joined(separator: "\n"),
                expectedMarker: marker,
                token: token,
                preparedGeometry: preparedGeometry
            )
        }

        XCTAssertEqual(
            error(
                [markerA, prepared, execution]
                    + Array(segments.dropLast())
                    + [summary]
            ),
            .segmentCount
        )

        var outOfOrder = segments
        outOfOrder.swapAt(9, 10)
        XCTAssertEqual(
            error([markerA, prepared, execution] + outOfOrder + [summary]),
            .segmentOrder
        )

        var duplicateEvent = segments
        duplicateEvent[10] = duplicateEvent[10].replacingOccurrences(
            of: "event=11",
            with: "event=10"
        )
        XCTAssertEqual(
            error([markerA, prepared, execution] + duplicateEvent + [summary]),
            .segmentOrder
        )

        let staleSummary = summary.replacingOccurrences(
            of: token,
            with: "S6A-FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
        )
        XCTAssertEqual(
            error([markerA, prepared, execution] + segments + [staleSummary]),
            .tokenMismatch
        )

        XCTAssertEqual(
            error(
                [markerB, outcome, prepared, execution] + segments + [summary],
                marker: "T9DEVICE_ENABLED"
            ),
            .evidenceOrder
        )

        XCTAssertEqual(
            error(
                [markerA, markerA, prepared, execution] + segments + [summary]
            ),
            .markerCount
        )
        XCTAssertEqual(
            error(
                [
                    markerA.replacingOccurrences(
                        of: "gate=off",
                        with: "gate=on"
                    ),
                    prepared,
                    execution,
                ] + segments + [summary]
            ),
            .markerMismatch
        )
        XCTAssertEqual(
            error([markerA, prepared] + segments + [summary]),
            .geometryCount
        )
        XCTAssertEqual(
            error(
                [markerA, prepared, prepared, execution]
                    + segments
                    + [summary]
            ),
            .geometryCount
        )

        let driftedGeometry = replacingGeometry(in: geometry, scale: 2)
        XCTAssertEqual(
            error(
                [
                    markerA,
                    prepared,
                    geometryLine(driftedGeometry, phase: "execution"),
                ] + segments + [summary]
            ),
            .geometryDrift
        )
        XCTAssertEqual(
            error([markerA, execution, prepared] + segments + [summary]),
            .evidenceOrder
        )

        var committed = segments
        committed[5] = committed[5].replacingOccurrences(
            of: "committed=false",
            with: "committed=true"
        )
        XCTAssertEqual(
            error([markerA, prepared, execution] + committed + [summary]),
            .commitDetected
        )

        var sessionDrift = segments
        sessionDrift[20] = sessionDrift[20].replacingOccurrences(
            of: "sessionAfter=42",
            with: "sessionAfter=43"
        )
        XCTAssertEqual(
            error([markerA, prepared, execution] + sessionDrift + [summary]),
            .sessionInvalid
        )

        XCTAssertEqual(
            error([markerA, prepared, execution] + segments),
            .summaryCount
        )
        XCTAssertEqual(
            error(
                [markerA, prepared, execution]
                    + segments
                    + [summary, summary]
            ),
            .summaryCount
        )
        XCTAssertEqual(
            error(
                [markerA, prepared, execution]
                    + segments
                    + [
                        summary.replacingOccurrences(
                            of: "actions=38",
                            with: "actions=37"
                        ),
                    ]
            ),
            .summaryInvalid
        )

        XCTAssertEqual(
            error(
                [markerA, prepared, execution, outcome]
                    + segments
                    + [summary]
            ),
            .outcomeCount
        )
        XCTAssertEqual(
            error(
                [markerB, prepared, execution] + segments + [summary],
                marker: "T9DEVICE_ENABLED"
            ),
            .outcomeCount
        )
        XCTAssertEqual(
            error(
                [markerB, prepared, execution, outcome, outcome]
                    + segments
                    + [summary],
                marker: "T9DEVICE_ENABLED"
            ),
            .outcomeCount
        )
        XCTAssertEqual(
            error(
                [
                    markerB,
                    prepared,
                    execution,
                    outcome.replacingOccurrences(
                        of: "event=18",
                        with: "event=99"
                    ),
                ] + segments + [summary],
                marker: "T9DEVICE_ENABLED"
            ),
            .evidenceOrder
        )
        XCTAssertEqual(
            error(
                [
                    markerB,
                    prepared,
                    execution,
                    outcome.replacingOccurrences(
                        of: "status=accepted",
                        with: "status=ignored"
                    ),
                ] + segments + [summary],
                marker: "T9DEVICE_ENABLED"
            ),
            .outcomeInvalid
        )
    }

    func testFrozenLongCompositionInDisposableRemindersList() throws {
        let expectedMarker = try requireExplicitDevicePreflightOptIn()
        validateFrozenFixture()
        let runToken = makeRunToken()

        let reminders = XCUIApplication(bundleIdentifier: remindersBundleIdentifier)
        var driverFailure: DriverError?
        var result: (actionStartTimes: [TimeInterval], scheduleLags: [TimeInterval])?
        var finalEvidence = ""

        do {
            try prepareRun(token: runToken)
            reminders.activate()
            guard reminders.wait(for: .runningForeground, timeout: 10) else {
                throw DriverError.hostUnavailable
            }
            try openDisposableList(in: reminders)
            let title = try createEmptyReminder(in: reminders)
            title.tap()

            // The visible Extension writes fresh same-token geometry. Reading
            // it happens before the monotonic timing arm begins.
            RunLoop.current.run(until: Date().addingTimeInterval(1))
            // Freeze the host frame while Reminders is still foreground. The
            // evidence App launch below intentionally backgrounds Reminders,
            // after which querying its frame is not a valid screen snapshot.
            let foregroundFrame = try captureForegroundFrame(in: reminders)
            let preparedEvidence = try loadContentFreeEvidence()
            let geometry = try preparedGeometry(
                in: preparedEvidence,
                expectedMarker: expectedMarker,
                token: runToken,
                foregroundFrame: foregroundFrame
            )

            reminders.activate()
            guard reminders.wait(for: .runningForeground, timeout: 10),
                  activeTitleField(in: reminders) != nil
            else {
                throw DriverError.hostRestoreFailed
            }

            result = try driveFrozenFixture(
                in: reminders,
                geometry: geometry
            )
            RunLoop.current.run(until: Date().addingTimeInterval(1))
            finalEvidence = try loadContentFreeEvidence()

            if let error = evidenceErrorCode(
                finalEvidence,
                expectedMarker: expectedMarker,
                token: runToken,
                preparedGeometry: geometry
            ) {
                XCTFail("S6-A evidence validation failed code=\(error.rawValue).")
            }
        } catch let error as DriverError {
            driverFailure = error
            // Replace Reminders before any XCTest failure can generate a host
            // screenshot or hierarchy attachment.
            finalEvidence = (try? loadContentFreeEvidence()) ?? ""
        }

        let cleanupSucceeded = cleanupRun(token: runToken)
        if let driverFailure {
            XCTFail("S6-A driver failed code=\(driverFailure.code).")
            return
        }
        guard cleanupSucceeded else {
            XCTFail("S6-A driver failed code=\(DriverError.tokenCleanupFailed.code).")
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
        ).map { ($0.0 - $0.1) * 1_000 }
        let maximumLag = lagMilliseconds.max() ?? 0
        XCTAssertLessThanOrEqual(
            maximumLag,
            maximumScheduleLag * 1_000,
            "S6-A cadence driver exceeded its content-free schedule-lag bound."
        )

        print(
            "T9_S6A_UI fixture=\(fixtureID) sha256=\(fixtureSHA256) "
                + "run=\(runToken) actions=\(result.actionStartTimes.count) cadenceMs=200 "
                + "medianIntervalMs=\(rounded(percentile(0.50, in: intervalMilliseconds))) "
                + "p95IntervalMs=\(rounded(percentile(0.95, in: intervalMilliseconds))) "
                + "worstIntervalMs=\(rounded(intervalMilliseconds.max() ?? 0)) "
                + "maxScheduleLagMs=\(rounded(maximumLag))"
        )
        _ = finalEvidence
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
        XCTAssertEqual(sourcePinyin.count, actionCount)
        let digest = SHA256.hash(data: Data(sourcePinyin.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        XCTAssertEqual(digest, fixtureSHA256)
        XCTAssertEqual(
            sourcePinyin.compactMap(slotIndex(containing:)).count,
            actionCount
        )
    }

    private func prepareRun(token: String) throws {
        let evidence = try loadContentFreeEvidence(
            additionalEnvironment: [prepareTokenEnvironmentKey: token]
        )
        guard evidence.contains("T9TOKEN state=prepared run=\(token)"),
              evidence.contains("T9MATRIX state=active count=")
        else {
            throw DriverError.tokenPreparationFailed
        }
    }

    private func cleanupRun(token: String) -> Bool {
        guard let evidence = try? loadContentFreeEvidence(
            additionalEnvironment: [cleanupTokenEnvironmentKey: token]
        ) else {
            return false
        }
        return evidence.contains("T9TOKEN state=absent")
            && evidence.contains("T9MATRIX state=active count=")
    }

    private func loadContentFreeEvidence(
        additionalEnvironment: [String: String] = [:]
    ) throws -> String {
        let app = XCUIApplication(bundleIdentifier: mainAppBundleIdentifier)
        app.launchEnvironment["T9_S6A_EVIDENCE_VIEW"] = "1"
        for (key, value) in additionalEnvironment {
            app.launchEnvironment[key] = value
        }
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

    private func captureForegroundFrame(in app: XCUIApplication) throws -> CGRect {
        guard let frame = validatedForegroundFrame(
            app.frame,
            hostIsForeground: app.state == .runningForeground
        ) else {
            throw DriverError.hostFrameUnavailable
        }
        return frame
    }

    private func validatedForegroundFrame(
        _ frame: CGRect,
        hostIsForeground: Bool
    ) -> CGRect? {
        guard hostIsForeground, finitePositive(frame) else {
            return nil
        }
        return frame
    }

    private func preparedGeometry(
        in evidence: String,
        expectedMarker: String,
        token: String,
        foregroundFrame: CGRect
    ) throws -> Geometry {
        let lines = evidence.components(separatedBy: "\n")
        guard let markerIndex = latestMarkerIndex(
            in: lines,
            expectedMarker: expectedMarker,
            token: token
        ) else {
            throw DriverError.geometryUnavailable
        }
        let scoped = Array(lines.suffix(from: lines.index(after: markerIndex)))
        let prepared = scoped.filter {
            $0.contains("T9GEOM phase=prepared ")
                && $0.contains("run=\(token) ")
        }
        guard prepared.count == 1,
              let geometry = parseGeometry(from: prepared[0])
        else {
            throw DriverError.geometryUnavailable
        }
        if let error = preparedGeometryValidationError(
            geometry,
            evidence: evidence,
            token: token,
            foregroundFrame: foregroundFrame
        ) {
            throw error
        }
        return geometry
    }

    private func preparedGeometryValidationError(
        _ geometry: Geometry,
        evidence: String,
        token: String,
        foregroundFrame: CGRect
    ) -> DriverError? {
        guard evidence.components(separatedBy: "\n").contains(
            "T9TOKEN state=consumed run=\(token)"
        ) else {
            return .tokenConsumptionInvalid
        }
        guard geometryError(geometry, foregroundFrame: foregroundFrame) == nil else {
            return .geometryInvalid
        }
        return nil
    }

    private func evidenceErrorCode(
        _ evidence: String,
        expectedMarker: String,
        token: String,
        preparedGeometry: Geometry
    ) -> EvidenceErrorCode? {
        let lines = evidence.components(separatedBy: "\n")
        let allMarkerIndices = lines.indices.filter {
            lines[$0].contains("T9DEVICE marker=")
        }
        guard let markerIndex = allMarkerIndices.last else {
            return .markerAbsent
        }
        let matchingMarkerIndices = allMarkerIndices.filter {
            field("run", in: lines[$0]) == token
        }
        guard matchingMarkerIndices.count == 1 else {
            return .markerCount
        }
        guard markerIndex == matchingMarkerIndices[0],
              field("marker", in: lines[markerIndex]) == expectedMarker,
              field("run", in: lines[markerIndex]) == token,
              field("measurement", in: lines[markerIndex]) == "on",
              field("gate", in: lines[markerIndex])
                == (expectedMarker == "T9DEVICE_ENABLED" ? "on" : "off")
        else {
            return .markerMismatch
        }

        let armLines = Array(lines.suffix(from: markerIndex))
        let preparedLines = armLines.filter {
            $0.contains("T9GEOM phase=prepared ")
        }
        let executionLines = armLines.filter {
            $0.contains("T9GEOM phase=execution ")
        }
        guard preparedLines.count == 1, executionLines.count == 1,
              let observedPrepared = parseGeometry(from: preparedLines[0]),
              let observedExecution = parseGeometry(from: executionLines[0])
        else {
            return .geometryCount
        }
        guard observedPrepared.token == token, observedExecution.token == token else {
            return .tokenMismatch
        }
        guard observedPrepared == preparedGeometry,
              observedExecution == preparedGeometry
        else {
            return .geometryDrift
        }

        let segmentLines = armLines.filter { $0.contains("T9SEG ") }
        guard segmentLines.count == actionCount else {
            return .segmentCount
        }
        var segmentEventByAction: [Int: Int] = [:]
        var stableSessionIdentity: Int?
        var previousEvent = 0
        for (index, line) in segmentLines.enumerated() {
            guard field("run", in: line) == token else {
                return .tokenMismatch
            }
            guard fieldInt("action", in: line) == index + 1,
                  let event = fieldInt("event", in: line),
                  event > previousEvent
            else {
                return .segmentOrder
            }
            previousEvent = event
            segmentEventByAction[index + 1] = event
            guard field("committed", in: line) == "false" else {
                return .commitDetected
            }
            guard field("validBefore", in: line) == "true",
                  field("validAfter", in: line) == "true",
                  let sessionBefore = fieldInt("sessionBefore", in: line),
                  let sessionAfter = fieldInt("sessionAfter", in: line),
                  sessionBefore != 0,
                  sessionBefore == sessionAfter
            else {
                return .sessionInvalid
            }
            if let stableSessionIdentity {
                guard sessionBefore == stableSessionIdentity else {
                    return .sessionInvalid
                }
            } else {
                stableSessionIdentity = sessionBefore
            }
        }

        let summaries = armLines.filter { $0.contains("T9ARM ") }
        guard summaries.count == 1, let summary = summaries.first else {
            return .summaryCount
        }
        guard field("run", in: summary) == token else {
            return .tokenMismatch
        }
        guard fieldInt("actions", in: summary) == actionCount,
              fieldInt("committed", in: summary) == 0,
              fieldInt("session", in: summary) == stableSessionIdentity,
              field("sessionStable", in: summary) == "true",
              field("sessionValid", in: summary) == "true"
        else {
            return .summaryInvalid
        }

        guard let preparedIndex = armLines.firstIndex(where: {
            $0.contains("T9GEOM phase=prepared ")
        }), let executionIndex = armLines.firstIndex(where: {
            $0.contains("T9GEOM phase=execution ")
        }), let summaryIndex = armLines.firstIndex(where: {
            $0.contains("T9ARM ")
        }), let firstSegmentIndex = armLines.firstIndex(where: {
            $0.contains("T9SEG ")
        }), let lastSegmentIndex = armLines.lastIndex(where: {
            $0.contains("T9SEG ")
        }), preparedIndex < executionIndex,
            executionIndex < firstSegmentIndex,
            lastSegmentIndex < summaryIndex
        else {
            return .evidenceOrder
        }

        let outcomes = armLines.enumerated().filter {
            $0.element.contains("T9AUTO ")
        }
        if expectedMarker == "T9DEVICE_DISABLED" {
            guard outcomes.isEmpty else {
                return .outcomeCount
            }
        } else {
            guard outcomes.count == 1 else {
                return .outcomeCount
            }
            let outcomeIndex = outcomes[0].offset
            let outcome = outcomes[0].element
            guard field("run", in: outcome) == token else {
                return .tokenMismatch
            }
            guard let action = fieldInt("action", in: outcome),
                  let event = fieldInt("event", in: outcome),
                  segmentEventByAction[action] == event,
                  outcomeIndex > executionIndex,
                  outcomeIndex < summaryIndex
            else {
                return .evidenceOrder
            }
            guard field("status", in: outcome) == "accepted"
                    || field("status", in: outcome) == "rejectedAndRestored"
            else {
                return .outcomeInvalid
            }
        }
        return nil
    }

    private func parseGeometry(from line: String) -> Geometry? {
        let requiredFields = [
            "run", "digest", "space", "orientation", "screen", "scale",
            "keyboard",
        ] + (0..<8).map { "s\($0)" }
        guard requiredFields.allSatisfy({
            fieldOccurrences($0, in: line) == 1
        }) else {
            return nil
        }
        let observedSlotFields = line.split(whereSeparator: \.isWhitespace)
            .compactMap { component -> String? in
                guard let separator = component.firstIndex(of: "=") else {
                    return nil
                }
                let name = String(component[..<separator])
                guard name.hasPrefix("s"),
                      Int(name.dropFirst()) != nil
                else {
                    return nil
                }
                return name
            }
        guard observedSlotFields.count == 8,
              Set(observedSlotFields) == Set((0..<8).map { "s\($0)" }),
              let token = field("run", in: line),
              let digest = field("digest", in: line),
              let space = field("space", in: line),
              let orientation = field("orientation", in: line),
              let screenText = field("screen", in: line),
              let scaleText = field("scale", in: line),
              let scale = Double(scaleText),
              scale.isFinite,
              let keyboardText = field("keyboard", in: line),
              let screen = parseRect(screenText),
              let keyboard = parseRect(keyboardText)
        else {
            return nil
        }
        let slots = (0..<8).compactMap { index -> CGRect? in
            guard let text = field("s\(index)", in: line) else {
                return nil
            }
            return parseRect(text)
        }
        guard slots.count == 8 else {
            return nil
        }
        return Geometry(
            token: token,
            digest: digest,
            space: space,
            orientation: orientation,
            screen: screen,
            scale: CGFloat(scale),
            keyboard: keyboard,
            slots: slots
        )
    }

    private func geometryError(
        _ geometry: Geometry,
        foregroundFrame: CGRect
    ) -> EvidenceErrorCode? {
        guard isCanonicalToken(geometry.token),
              geometry.digest == geometry.computedDigest,
              geometry.space == "portrait-screen-points",
              geometry.orientation == "portrait",
              finitePositive(geometry.screen),
              geometry.screen.height > geometry.screen.width,
              finitePositive(geometry.keyboard),
              geometry.scale.isFinite,
              geometry.scale > 0,
              approximatelyEqual(geometry.screen.origin.x, 0),
              approximatelyEqual(geometry.screen.origin.y, 0),
              rectApproximatelyEqual(geometry.screen, foregroundFrame),
              geometry.screen.contains(geometry.keyboard),
              geometry.keyboard.minY >= geometry.screen.height * 0.5,
              geometry.slots.count == 8
        else {
            return .geometryInvalid
        }

        for (index, slot) in geometry.slots.enumerated() {
            guard finitePositive(slot),
                  slot.width >= 30,
                  slot.height >= 30,
                  geometry.screen.contains(slot),
                  geometry.keyboard.contains(slot)
            else {
                return .geometryInvalid
            }
            for later in geometry.slots.dropFirst(index + 1) where slot.intersects(later) {
                return .geometryInvalid
            }
        }

        let rowGroups = [Array(0...1), Array(2...4), Array(5...7)]
        var rowCenters: [CGFloat] = []
        for row in rowGroups {
            let centersY = row.map { geometry.slots[$0].midY }
            guard let minimumY = centersY.min(),
                  let maximumY = centersY.max(),
                  maximumY - minimumY <= 4
            else {
                return .geometryInvalid
            }
            let centersX = row.map { geometry.slots[$0].midX }
            guard zip(centersX, centersX.dropFirst()).allSatisfy({ $0.0 < $0.1 }) else {
                return .geometryInvalid
            }
            rowCenters.append(centersY.reduce(0, +) / CGFloat(centersY.count))
        }
        guard zip(rowCenters, rowCenters.dropFirst()).allSatisfy({ $0.0 < $0.1 }) else {
            return .geometryInvalid
        }
        return nil
    }

    private func driveFrozenFixture(
        in app: XCUIApplication,
        geometry: Geometry
    ) throws -> (actionStartTimes: [TimeInterval], scheduleLags: [TimeInterval]) {
        var actionStartTimes: [TimeInterval] = []
        var scheduleLags: [TimeInterval] = []
        actionStartTimes.reserveCapacity(actionCount)
        scheduleLags.reserveCapacity(actionCount)

        var scheduleOrigin: TimeInterval?
        for (index, letter) in sourcePinyin.enumerated() {
            guard let slot = slotIndex(containing: letter) else {
                throw DriverError.fixtureMappingFailed
            }
            let center = CGPoint(
                x: geometry.slots[slot].midX,
                y: geometry.slots[slot].midY
            )
            let coordinate = app.coordinate(
                withNormalizedOffset: CGVector(
                    dx: center.x / geometry.screen.width,
                    dy: center.y / geometry.screen.height
                )
            )

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
            coordinate.tap()
        }
        return (actionStartTimes, scheduleLags)
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

    private func exactDisposableListElement(in app: XCUIApplication) -> XCUIElement? {
        [
            app.buttons[disposableListName].firstMatch,
            app.staticTexts[disposableListName].firstMatch,
            app.cells.matching(
                NSPredicate(format: "label == %@", disposableListName)
            ).firstMatch,
        ].first { $0.exists && $0.isHittable }
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
        guard let title = activeTitleField(in: app, wait: true) else {
            throw DriverError.titleFieldUnavailable
        }
        return title
    }

    private func activeTitleField(
        in app: XCUIApplication,
        wait: Bool = false
    ) -> XCUIElement? {
        let candidates = [
            app.textFields["标题"].firstMatch,
            app.textFields["Title"].firstMatch,
        ]
        return candidates.first {
            wait ? $0.waitForExistence(timeout: 5) : $0.exists
        }
    }

    private func latestMarkerIndex(
        in lines: [String],
        expectedMarker: String,
        token: String
    ) -> Int? {
        let matching = lines.indices.filter {
            lines[$0].contains("T9DEVICE marker=")
                && field("run", in: lines[$0]) == token
        }
        guard matching.count == 1,
              let latest = lines.lastIndex(where: {
            $0.contains("T9DEVICE marker=")
        }), latest == matching[0],
            field("marker", in: lines[latest]) == expectedMarker,
            field("run", in: lines[latest]) == token
        else {
            return nil
        }
        return latest
    }

    private func field(_ name: String, in line: String) -> String? {
        let prefix = "\(name)="
        return line.split(whereSeparator: \.isWhitespace)
            .first { $0.hasPrefix(prefix) }
            .map { String($0.dropFirst(prefix.count)) }
    }

    private func fieldOccurrences(_ name: String, in line: String) -> Int {
        let prefix = "\(name)="
        return line.split(whereSeparator: \.isWhitespace)
            .count { $0.hasPrefix(prefix) }
    }

    private func fieldInt(_ name: String, in line: String) -> Int? {
        field(name, in: line).flatMap(Int.init)
    }

    private func parseRect(_ value: String) -> CGRect? {
        let values = value.split(separator: ",", omittingEmptySubsequences: false)
            .compactMap { Double($0) }
        guard values.count == 4, values.allSatisfy(\.isFinite) else {
            return nil
        }
        return CGRect(x: values[0], y: values[1], width: values[2], height: values[3])
    }

    private func finitePositive(_ rect: CGRect) -> Bool {
        [rect.minX, rect.minY, rect.width, rect.height].allSatisfy(\.isFinite)
            && rect.width > 0
            && rect.height > 0
    }

    private func approximatelyEqual(_ lhs: CGFloat, _ rhs: CGFloat) -> Bool {
        abs(lhs - rhs) <= 0.5
    }

    private func rectApproximatelyEqual(_ lhs: CGRect, _ rhs: CGRect) -> Bool {
        approximatelyEqual(lhs.minX, rhs.minX)
            && approximatelyEqual(lhs.minY, rhs.minY)
            && approximatelyEqual(lhs.width, rhs.width)
            && approximatelyEqual(lhs.height, rhs.height)
    }

    private func makeRunToken() -> String {
        "S6A-" + UUID().uuidString.replacingOccurrences(of: "-", with: "").uppercased()
    }

    private func isCanonicalToken(_ token: String) -> Bool {
        guard token.count == 36, token.hasPrefix("S6A-") else {
            return false
        }
        let uppercaseHexCharacters = Set("0123456789ABCDEF")
        return token.dropFirst(4).allSatisfy(uppercaseHexCharacters.contains)
    }

    private func slotIndex(containing letter: Character) -> Int? {
        switch letter.lowercased() {
        case "a", "b", "c": return 0
        case "d", "e", "f": return 1
        case "g", "h", "i": return 2
        case "j", "k", "l": return 3
        case "m", "n", "o": return 4
        case "p", "q", "r", "s": return 5
        case "t", "u", "v": return 6
        case "w", "x", "y", "z": return 7
        default: return nil
        }
    }

    private var syntheticToken: String {
        "S6A-0123456789ABCDEF0123456789ABCDEF"
    }

    private func syntheticGeometry(token: String? = nil) -> Geometry {
        let token = token ?? syntheticToken
        let screen = CGRect(x: 0, y: 0, width: 390, height: 844)
        let keyboard = CGRect(x: 0, y: 540, width: 390, height: 304)
        let slots = [
            CGRect(x: 180, y: 570, width: 70, height: 45),
            CGRect(x: 260, y: 570, width: 70, height: 45),
            CGRect(x: 100, y: 623, width: 70, height: 45),
            CGRect(x: 180, y: 623, width: 70, height: 45),
            CGRect(x: 260, y: 623, width: 70, height: 45),
            CGRect(x: 100, y: 676, width: 70, height: 45),
            CGRect(x: 180, y: 676, width: 70, height: 45),
            CGRect(x: 260, y: 676, width: 70, height: 45),
        ]
        let provisional = Geometry(
            token: token,
            digest: "",
            space: "portrait-screen-points",
            orientation: "portrait",
            screen: screen,
            scale: 3,
            keyboard: keyboard,
            slots: slots
        )
        return Geometry(
            token: token,
            digest: provisional.computedDigest,
            space: provisional.space,
            orientation: provisional.orientation,
            screen: screen,
            scale: provisional.scale,
            keyboard: keyboard,
            slots: slots
        )
    }

    private func replacingSlots(in geometry: Geometry, with slots: [CGRect]) -> Geometry {
        replacingGeometry(in: geometry, slots: slots)
    }

    private func replacingScreen(
        in geometry: Geometry,
        with screen: CGRect
    ) -> Geometry {
        replacingGeometry(in: geometry, screen: screen)
    }

    private func replacingGeometry(
        in geometry: Geometry,
        space: String? = nil,
        orientation: String? = nil,
        screen: CGRect? = nil,
        scale: CGFloat? = nil,
        keyboard: CGRect? = nil,
        slots: [CGRect]? = nil
    ) -> Geometry {
        let provisional = Geometry(
            token: geometry.token,
            digest: "",
            space: space ?? geometry.space,
            orientation: orientation ?? geometry.orientation,
            screen: screen ?? geometry.screen,
            scale: scale ?? geometry.scale,
            keyboard: keyboard ?? geometry.keyboard,
            slots: slots ?? geometry.slots
        )
        return Geometry(
            token: provisional.token,
            digest: provisional.computedDigest,
            space: provisional.space,
            orientation: provisional.orientation,
            screen: provisional.screen,
            scale: provisional.scale,
            keyboard: provisional.keyboard,
            slots: provisional.slots
        )
    }

    private func geometryLine(_ geometry: Geometry, phase: String) -> String {
        let identity =
            "T9GEOM phase=\(phase) run=\(geometry.token) "
            + "digest=\(geometry.digest)"
        let coordinateSpace =
            "space=\(geometry.space) orientation=\(geometry.orientation)"
        let bounds =
            "screen=\(Geometry.rectForTesting(geometry.screen)) "
            + "scale=\(Geometry.numberForTesting(geometry.scale)) "
            + "keyboard=\(Geometry.rectForTesting(geometry.keyboard))"
        let slots = geometry.slots.enumerated()
            .map { "s\($0.offset)=\(Geometry.rectForTesting($0.element))" }
            .joined(separator: " ")
        return [identity, coordinateSpace, bounds, slots].joined(separator: " ")
    }

    private func validSyntheticSegments(token: String) -> [String] {
        (1...actionCount).map {
            "T9SEG run=\(token) action=\($0) event=\($0) committed=false "
                + "sessionBefore=42 validBefore=true "
                + "sessionAfter=42 validAfter=true"
        }
    }

    private func waitUntil(timeout: TimeInterval, condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if condition() { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        } while Date() < deadline
        return condition()
    }

    private func waitUntil(monotonicTime target: TimeInterval) {
        while true {
            let now = ProcessInfo.processInfo.systemUptime
            guard now < target else { return }
            RunLoop.current.run(
                until: Date().addingTimeInterval(min(0.01, target - now))
            )
        }
    }

    private func percentile(_ percentile: Double, in values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let index = Int((Double(sorted.count - 1) * percentile).rounded(.up))
        return sorted[index]
    }

    private func rounded(_ value: Double) -> Int {
        Int(value.rounded())
    }
}

fileprivate extension T9DevicePreflightUITests.Geometry {
    static func rectForTesting(_ rect: CGRect) -> String {
        [
            rect.origin.x,
            rect.origin.y,
            rect.size.width,
            rect.size.height,
        ].map(numberForTesting).joined(separator: ",")
    }

    static func numberForTesting(_ value: CGFloat) -> String {
        String(
            format: "%.3f",
            locale: Locale(identifier: "en_US_POSIX"),
            Double(value)
        )
    }
}
