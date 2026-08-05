#if T9_RESPONSIVE_CANARY_INTERNAL

import XCTest
@testable import KeyboardCore

@MainActor
final class ResponsiveRimeCanaryContractTests: XCTestCase {
    func testPrepareWritesTypedSnapshotAndReleasesKillLast() {
        let suite = "ResponsiveRimeCanaryContractTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let receipt = ResponsiveRimePreflight.prepareCanaryConfiguration(
            defaults: defaults,
            runID: "device-run-1",
            expiryUnixSeconds: 500,
            nowUnixSeconds: 100
        )

        XCTAssertEqual(receipt.status, .success)
        XCTAssertEqual(receipt.decision, .prepared)
        XCTAssertTrue(receipt.enable)
        XCTAssertFalse(receipt.kill)
        XCTAssertEqual(receipt.expiryUnixSeconds, 500)
        XCTAssertTrue(receipt.valid)
        XCTAssertTrue(receipt.expiryIsFuture)
        XCTAssertEqual(
            receipt.markerLine,
            "T9RESP marker=CANARY_CONFIG schema=T9RESP-CANARY-CONFIG-v1 "
                + "actor=app phase=prepare run=device-run-1 enable=1 kill=0 "
                + "expiry=500 valid=1 expiryState=future decision=prepared status=success"
        )
        XCTAssertTrue(T9DevicePreflightEvidenceLineFilter.retains(receipt.markerLine))

        let configuration = ResponsiveRimePreflight.canaryConfiguration(
            defaults: defaults,
            bootstrapAvailable: true
        )
        XCTAssertTrue(configuration.configurationValid)
        XCTAssertTrue(configuration.explicitEnable)
        XCTAssertFalse(configuration.killSwitch)
        XCTAssertEqual(configuration.expiresAtUnixSeconds, 500)
        XCTAssertEqual(configuration.runID, "device-run-1")
    }

    func testInvalidPrepareFailsClosedWithoutReleasingKill() {
        let suite = "ResponsiveRimeCanaryContractTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(false, forKey: ResponsiveRimePreflight.canaryKillSwitchKey)

        let receipt = ResponsiveRimePreflight.prepareCanaryConfiguration(
            defaults: defaults,
            runID: "contains spaces",
            expiryUnixSeconds: 50,
            nowUnixSeconds: 100
        )

        XCTAssertEqual(receipt.status, .failure)
        XCTAssertEqual(receipt.decision, .failClosed)
        XCTAssertTrue(receipt.kill)
        XCTAssertEqual(receipt.runID, "invalid")
        XCTAssertTrue(defaults.bool(forKey: ResponsiveRimePreflight.canaryKillSwitchKey))
    }

    func testInvalidConfigurationRejectsUnicodeRunIDAndNonIntegerExpiry() {
        let suite = "ResponsiveRimeCanaryContractTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: ResponsiveRimePreflight.canaryEnableKey)
        defaults.set(false, forKey: ResponsiveRimePreflight.canaryKillSwitchKey)
        defaults.set(500.5, forKey: ResponsiveRimePreflight.canaryExpiryKey)
        defaults.set("运行-1", forKey: ResponsiveRimePreflight.canaryRunIDKey)

        XCTAssertFalse(
            ResponsiveRimePreflight.canaryConfiguration(
                defaults: defaults,
                bootstrapAvailable: true
            ).configurationValid
        )

        defaults.set("run-1", forKey: ResponsiveRimePreflight.canaryRunIDKey)
        defaults.set(TimeInterval(Int64.max), forKey: ResponsiveRimePreflight.canaryExpiryKey)
        XCTAssertFalse(
            ResponsiveRimePreflight.canaryConfiguration(
                defaults: defaults,
                bootstrapAvailable: true
            ).configurationValid
        )
    }

    func testForcedKillReceiptDoesNotClaimUnconfirmedKill() {
        let defaults = RejectingKillUserDefaults()

        let receipt = ResponsiveRimePreflight.prepareCanaryConfiguration(
            defaults: defaults,
            runID: "contains spaces",
            expiryUnixSeconds: 50,
            nowUnixSeconds: 100
        )

        XCTAssertEqual(receipt.status, .readbackMismatch)
        XCTAssertEqual(receipt.decision, .failClosed)
        XCTAssertFalse(receipt.kill)
    }

    func testPrepareSucceedsWhenSynchronizeReturnsFalse() {
        let defaults = FlakySynchronizeUserDefaults()
        defaults.synchronizeResult = false

        let receipt = ResponsiveRimePreflight.prepareCanaryConfiguration(
            defaults: defaults,
            runID: "device-run-1",
            expiryUnixSeconds: 500,
            nowUnixSeconds: 100
        )

        XCTAssertEqual(receipt.status, .success)
        XCTAssertEqual(receipt.decision, .prepared)
        XCTAssertTrue(receipt.enable)
        XCTAssertFalse(receipt.kill)
        XCTAssertEqual(receipt.expiryUnixSeconds, 500)
        let enableObject = defaults.object(
            forKey: ResponsiveRimePreflight.canaryEnableKey
        )
        guard let enableNumber = enableObject as? NSNumber else {
            return XCTFail("enable must persist as NSNumber/CFBoolean")
        }
        XCTAssertEqual(CFGetTypeID(enableNumber), CFBooleanGetTypeID())
    }

    func testConfigurationRejectsUntypedBooleanOrNumericExpiry() {
        let suite = "ResponsiveRimeCanaryContractTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(1, forKey: ResponsiveRimePreflight.canaryEnableKey)
        defaults.set(false, forKey: ResponsiveRimePreflight.canaryKillSwitchKey)
        defaults.set(true, forKey: ResponsiveRimePreflight.canaryExpiryKey)
        defaults.set("run-1", forKey: ResponsiveRimePreflight.canaryRunIDKey)

        let configuration = ResponsiveRimePreflight.canaryConfiguration(
            defaults: defaults,
            bootstrapAvailable: true
        )

        XCTAssertFalse(configuration.configurationValid)
    }

    func testKillAssertionRequiresMatchingRunReadback() {
        let suite = "ResponsiveRimeCanaryContractTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        _ = ResponsiveRimePreflight.prepareCanaryConfiguration(
            defaults: defaults,
            runID: "device-run-1",
            expiryUnixSeconds: 500,
            nowUnixSeconds: 100
        )

        let receipt = ResponsiveRimePreflight.assertCanaryKill(
            defaults: defaults,
            runID: "device-run-1",
            nowUnixSeconds: 200
        )

        XCTAssertEqual(receipt.status, .success)
        XCTAssertEqual(receipt.decision, .kill)
        XCTAssertTrue(receipt.kill)
        XCTAssertTrue(receipt.markerLine.contains("phase=kill"))
    }

    func testConfigurationFailsClosedWhenKillKeyIsMissing() {
        let suite = "ResponsiveRimeCanaryContractTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: ResponsiveRimePreflight.canaryEnableKey)
        defaults.set(200.0, forKey: ResponsiveRimePreflight.canaryExpiryKey)
        defaults.set("run-1", forKey: ResponsiveRimePreflight.canaryRunIDKey)

        let configuration = ResponsiveRimePreflight.canaryConfiguration(
            defaults: defaults,
            bootstrapAvailable: true
        )
        XCTAssertFalse(configuration.configurationValid)
        XCTAssertTrue(configuration.killSwitch)
    }

    func testActiveConfigurationTerminatesForNaNRunMismatchOrMissingBootstrap() {
        let nan = ResponsiveRimeCanaryConfiguration(
            explicitEnable: true,
            killSwitch: false,
            bootstrapAvailable: true,
            configurationValid: true,
            expiresAtUnixSeconds: .nan,
            runID: "run-1"
        )
        XCTAssertTrue(
            ResponsiveRimePreflight.shouldTerminateActiveCanary(
                configuration: nan,
                currentRunID: "run-1",
                nowUnixSeconds: 100
            )
        )
        XCTAssertTrue(
            ResponsiveRimePreflight.shouldTerminateActiveCanary(
                configuration: configuration(),
                currentRunID: "different-run",
                nowUnixSeconds: 100
            )
        )
        let missingBootstrap = ResponsiveRimeCanaryConfiguration(
            explicitEnable: true,
            killSwitch: false,
            bootstrapAvailable: false,
            configurationValid: true,
            expiresAtUnixSeconds: 200,
            runID: "run-1"
        )
        XCTAssertTrue(
            ResponsiveRimePreflight.shouldTerminateActiveCanary(
                configuration: missingBootstrap,
                currentRunID: "run-1",
                nowUnixSeconds: 100
            )
        )
    }

    func testMissingEnableAndPreStartKillStayOnBaseline() {
        let coordinator = ResponsiveRimeCanaryModeCoordinator()

        XCTAssertEqual(
            coordinator.evaluateStartup(
                configuration(explicitEnable: false),
                nowUnixSeconds: 100
            ),
            .useBaseline(.notEnabled)
        )
        XCTAssertTrue(coordinator.permitsBaselineCreation)

        XCTAssertEqual(
            coordinator.evaluateStartup(
                configuration(killSwitch: true),
                nowUnixSeconds: 100
            ),
            .useBaseline(.killBeforeStartup)
        )
        XCTAssertTrue(coordinator.permitsBaselineCreation)
    }

    func testActiveKillRequiresOrderedPositiveTerminals() throws {
        let coordinator = ResponsiveRimeCanaryModeCoordinator()
        XCTAssertEqual(
            coordinator.evaluateStartup(configuration(), nowUnixSeconds: 100),
            .startCanary(modeGeneration: 1)
        )
        XCTAssertEqual(coordinator.markCanaryReady(), 1)

        let key = try XCTUnwrap(
            coordinator.beginActiveKill(
                runID: "run-1",
                acceptedThroughRevision: 39
            )
        )
        XCTAssertFalse(coordinator.permitsBaselineCreation)
        XCTAssertFalse(coordinator.recordPositiveTerminal(.ownerDestroyed, key: key))
        XCTAssertFalse(coordinator.recordPositiveTerminal(.mailboxTerminal, key: key))
        XCTAssertTrue(coordinator.recordPositiveTerminal(.deliveryDrained, key: key))
        XCTAssertTrue(coordinator.permitsBaselineCreation)
    }

    func testOutOfOrderTerminalFailsClosed() throws {
        let coordinator = ResponsiveRimeCanaryModeCoordinator()
        _ = coordinator.evaluateStartup(configuration(), nowUnixSeconds: 100)
        _ = coordinator.markCanaryReady()
        let key = try XCTUnwrap(
            coordinator.beginActiveKill(runID: "run-1", acceptedThroughRevision: 1)
        )

        XCTAssertFalse(coordinator.recordPositiveTerminal(.deliveryDrained, key: key))
        XCTAssertFalse(coordinator.permitsBaselineCreation)
        guard case .fencedUnavailable = coordinator.state else {
            return XCTFail("out-of-order terminal must enter FencedUnavailable")
        }
    }

    func testPresentationTerminalRejectsDuplicateRevision() {
        let coordinator = ResponsiveRimeCanaryModeCoordinator()
        _ = coordinator.evaluateStartup(configuration(), nowUnixSeconds: 100)
        _ = coordinator.markCanaryReady()
        let terminal = ResponsiveRimeCanaryPresentationTerminal(
            runID: "run-1",
            modeGeneration: 1,
            canarySessionInstance: 1,
            sessionEpoch: 1,
            revision: 7,
            completion: .published,
            visibility: .visible(presentationRevision: 7),
            paint: .painted
        )

        XCTAssertTrue(coordinator.recordPresentationTerminal(terminal))
        XCTAssertFalse(coordinator.recordPresentationTerminal(terminal))
        XCTAssertFalse(coordinator.permitsBaselineCreation)
    }

    func testVisibilityExitRequiresPerRevisionReceiptsAndStartsFreshInstance() {
        let coordinator = ResponsiveRimeCanaryModeCoordinator()
        _ = coordinator.evaluateStartup(configuration(), nowUnixSeconds: 100)
        XCTAssertEqual(coordinator.markCanaryReady(), 1)
        XCTAssertTrue(coordinator.beginVisibilityExit())
        XCTAssertTrue(
            coordinator.recordVisibilityAbandonments([
                ThreadAffineRimeVisibilityAbandonmentReceipt(
                    sessionEpoch: 1,
                    revision: 2,
                    actionID: "pk-2"
                ),
                ThreadAffineRimeVisibilityAbandonmentReceipt(
                    sessionEpoch: 1,
                    revision: 3,
                    actionID: "pk-3"
                ),
            ])
        )
        coordinator.completeVisibilityExit(teardownPositive: true)
        XCTAssertEqual(
            coordinator.visibilityAbandonmentIdentities.map(\.modeGeneration),
            [1, 1],
            "visibility receipts must retain the generation of the accepting session"
        )
        XCTAssertTrue(coordinator.beginVisibilityResume())
        XCTAssertEqual(coordinator.markCanaryReady(), 2)
        XCTAssertEqual(coordinator.abandonedVisibilityCount, 2)
        XCTAssertTrue(coordinator.beginVisibilityExit())
        XCTAssertTrue(
            coordinator.recordVisibilityAbandonments([
                ThreadAffineRimeVisibilityAbandonmentReceipt(
                    sessionEpoch: 1,
                    revision: 2,
                    actionID: "pk-2-second-session"
                ),
            ]),
            "a fresh canarySessionInstance must not collide with an older receipt"
        )
        XCTAssertEqual(coordinator.visibilityAbandonmentIdentities.last?.modeGeneration, 3)
    }

    func testInvalidPresentationDuringVisibilityDoesNotPreemptOwnerTeardownState() {
        let coordinator = ResponsiveRimeCanaryModeCoordinator()
        _ = coordinator.evaluateStartup(configuration(), nowUnixSeconds: 100)
        _ = coordinator.markCanaryReady()
        XCTAssertTrue(coordinator.beginVisibilityExit())

        let invalidTerminal = ResponsiveRimeCanaryPresentationTerminal(
            runID: "run-1",
            modeGeneration: 1,
            canarySessionInstance: 1,
            sessionEpoch: 1,
            revision: 1,
            completion: .published,
            visibility: .notVisibleFencedBeforeVisible,
            paint: .painted
        )
        XCTAssertFalse(coordinator.recordPresentationTerminal(invalidTerminal))
        guard case .visibilityEnding = coordinator.state else {
            return XCTFail("contract failure must leave visibility teardown authority intact")
        }
    }

    func testVisibilityTerminalKeepsFrozenPublishGeneration() {
        let coordinator = ResponsiveRimeCanaryModeCoordinator()
        _ = coordinator.evaluateStartup(configuration(), nowUnixSeconds: 100)
        _ = coordinator.markCanaryReady()
        XCTAssertTrue(coordinator.beginVisibilityExit())
        XCTAssertEqual(coordinator.modeGeneration, 2)

        let oldPublishTerminal = ResponsiveRimeCanaryPresentationTerminal(
            runID: "run-1",
            modeGeneration: 1,
            canarySessionInstance: 1,
            sessionEpoch: 1,
            revision: 4,
            completion: .staleAfterFence,
            visibility: .notVisibleFencedBeforeVisible,
            paint: .failedFencedBeforeVisible
        )
        XCTAssertTrue(
            coordinator.recordPresentationTerminal(oldPublishTerminal),
            "visibility generation changes must not relabel the old publish"
        )

        let relabeled = ResponsiveRimeCanaryPresentationTerminal(
            runID: "run-1",
            modeGeneration: 2,
            canarySessionInstance: 1,
            sessionEpoch: 1,
            revision: 5,
            completion: .staleAfterFence,
            visibility: .notVisibleFencedBeforeVisible,
            paint: .failedFencedBeforeVisible
        )
        XCTAssertFalse(coordinator.recordPresentationTerminal(relabeled))
    }

    private func configuration(
        explicitEnable: Bool = true,
        killSwitch: Bool = false
    ) -> ResponsiveRimeCanaryConfiguration {
        ResponsiveRimeCanaryConfiguration(
            explicitEnable: explicitEnable,
            killSwitch: killSwitch,
            bootstrapAvailable: true,
            configurationValid: true,
            expiresAtUnixSeconds: 200,
            runID: "run-1"
        )
    }

    private final class RejectingKillUserDefaults: UserDefaults {
        private var values: [String: Any] = [:]

        override func set(_ value: Any?, forKey defaultName: String) {
            if defaultName == ResponsiveRimePreflight.canaryKillSwitchKey {
                values[defaultName] = kCFBooleanFalse as Any
            } else if let bool = value as? Bool {
                values[defaultName] = (bool ? kCFBooleanTrue : kCFBooleanFalse) as Any
            } else {
                values[defaultName] = value as Any
            }
        }

        override func set(_ value: Bool, forKey defaultName: String) {
            if defaultName == ResponsiveRimePreflight.canaryKillSwitchKey {
                values[defaultName] = kCFBooleanFalse as Any
            } else {
                values[defaultName] = (value ? kCFBooleanTrue : kCFBooleanFalse) as Any
            }
        }

        override func object(forKey defaultName: String) -> Any? {
            values[defaultName]
        }

        override func string(forKey defaultName: String) -> String? {
            values[defaultName] as? String
        }

        override func synchronize() -> Bool {
            true
        }
    }

    /// Models device App Group flushes that report failure while in-memory
    /// typed values remain readable for the prepare transaction.
    private final class FlakySynchronizeUserDefaults: UserDefaults {
        private var values: [String: Any] = [:]
        var synchronizeResult = true

        override func set(_ value: Any?, forKey defaultName: String) {
            if let bool = value as? Bool {
                values[defaultName] = (bool ? kCFBooleanTrue : kCFBooleanFalse) as Any
            } else {
                values[defaultName] = value as Any
            }
        }

        override func set(_ value: Bool, forKey defaultName: String) {
            values[defaultName] = (value ? kCFBooleanTrue : kCFBooleanFalse) as Any
        }

        override func object(forKey defaultName: String) -> Any? {
            values[defaultName]
        }

        override func string(forKey defaultName: String) -> String? {
            values[defaultName] as? String
        }

        override func synchronize() -> Bool {
            synchronizeResult
        }
    }
}

#endif
