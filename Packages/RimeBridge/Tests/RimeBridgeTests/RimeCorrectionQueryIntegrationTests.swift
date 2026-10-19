import Foundation
import RimeBridgeObjC
import XCTest

@testable import KeyboardCore
@testable import RimeBridge

@MainActor
final class RimeCorrectionQueryIntegrationTests: XCTestCase {
    func testPrivateSyntheticSchemaReturnsRealReadyCandidates() throws {
        let fixture = try makeRuntimeFixture(schemaID: "synthetic_echo", hasTranslator: true)
        try deployPrivateFixture(fixture)
        let manager = try makeReadyManager(fixture: fixture)
        defer { close(manager, fixture: fixture) }

        let rawResult = manager.correctionCandidates(forInput: "nihao", limit: 3)
        let result = try XCTUnwrap(RimeEngineImpl.parseCorrectionQueryResult(rawResult))

        XCTAssertEqual(result.readiness, .ready)
        XCTAssertEqual(result.state, .candidatesReturned)
        XCTAssertFalse(result.candidates.isEmpty)
        XCTAssertLessThanOrEqual(result.candidates.count, 3)
    }

    func testPrivateSyntheticSchemaReturnsRealReadyEmptyContext() throws {
        let fixture = try makeRuntimeFixture(schemaID: "synthetic_empty", hasTranslator: false)
        try deployPrivateFixture(fixture)
        let manager = try makeReadyManager(fixture: fixture)
        defer { close(manager, fixture: fixture) }

        let rawResult = manager.correctionCandidates(forInput: "nihao", limit: 3)
        let result = try XCTUnwrap(RimeEngineImpl.parseCorrectionQueryResult(rawResult))

        XCTAssertEqual(result.readiness, .ready)
        XCTAssertEqual(result.state, .candidatesReturned)
        XCTAssertTrue(result.candidates.isEmpty)
    }

    func testGetContextFalseIsCoveredOnlyBySimulatedDebugSeam() throws {
        let fixture = try makeRuntimeFixture(schemaID: "synthetic_echo", hasTranslator: true)
        let manager = try makeReadyManager(fixture: fixture)
        defer { close(manager, fixture: fixture) }
        manager.setCorrectionQueryContextAvailabilityForTesting(NSNumber(value: false))

        let rawResult = manager.correctionCandidates(forInput: "nihao", limit: 3)
        let result = try XCTUnwrap(RimeEngineImpl.parseCorrectionQueryResult(rawResult))

        XCTAssertEqual(result.readiness, .ready)
        XCTAssertEqual(result.state, .contextUnavailable)
        XCTAssertTrue(result.candidates.isEmpty)
    }

    #if DEBUG
        func testSequentialManagerReplacementGetsNewCorrectionOrdinalWithoutOverlappingRuntime() throws {
            func observeOnePrivateManager() throws -> UInt64 {
                let fixture = try makeRuntimeFixture(schemaID: "synthetic_echo", hasTranslator: true)
                try deployPrivateFixture(fixture)
                let manager = try makeReadyManager(fixture: fixture)
                defer { close(manager, fixture: fixture) }
                let absent = manager.existingCorrectionQueryDebugScope()
                XCTAssertEqual((absent["sessionOrdinal"])?.uint64Value, 0)
                _ = manager.correctionCandidates(forInput: "nihao", limit: 3)
                let observed = manager.existingCorrectionQueryDebugScope()
                let ordinal = try XCTUnwrap(observed["sessionOrdinal"]).uint64Value
                XCTAssertGreaterThan(ordinal, 0)
                XCTAssertEqual((observed["schemaCode"])?.uint64Value, 0)
                XCTAssertEqual(manager.existingCorrectionQueryDebugScope() as NSDictionary, observed as NSDictionary)
                XCTAssertEqual(manager.currentSchemaID(), fixture.schemaID)
                return ordinal
            }
            // First helper finalizes its process-global runtime and removes its
            // private directories before the second manager is created. No App Group.
            let first = try observeOnePrivateManager()
            let second = try observeOnePrivateManager()
            XCTAssertGreaterThan(second, first)
        }
        func testExistingCorrectionScopeDoesNotCreateSessionOrSubstitutePrimarySchema() throws {
            let fixture = try makeRuntimeFixture(schemaID: "synthetic_echo", hasTranslator: true)
            try deployPrivateFixture(fixture)
            let manager = try makeReadyManager(fixture: fixture)
            defer { close(manager, fixture: fixture) }
            let initial = manager.existingCorrectionQueryDebugScope()
            XCTAssertEqual((initial["sessionOrdinal"])?.uint64Value, 0)
            XCTAssertEqual((initial["schemaCode"])?.uint64Value, 0)
            XCTAssertEqual(manager.currentSchemaID(), fixture.schemaID)
            // Only this explicit synthetic fixture query may create the correction session.
            _ = manager.correctionCandidates(forInput: "nihao", limit: 3)
            let observed = manager.existingCorrectionQueryDebugScope()
            XCTAssertGreaterThan((observed["sessionOrdinal"])?.uint64Value ?? 0, 0)
            XCTAssertEqual((observed["schemaCode"])?.uint64Value, 0)
            XCTAssertEqual(manager.existingCorrectionQueryDebugScope() as NSDictionary, observed as NSDictionary)
            XCTAssertEqual(manager.currentSchemaID(), fixture.schemaID)
        }
    #endif

    private func makeReadyManager(fixture: RuntimeFixture) throws -> RimeSessionManager {
        let manager = RimeSessionManager()
        XCTAssertTrue(manager.setup(withSharedDataDir: fixture.sharedURL.path, userDataDir: fixture.userURL.path))
        XCTAssertTrue(manager.initializeEngine())
        XCTAssertTrue(manager.createSession())
        XCTAssertTrue(manager.selectSchema(fixture.schemaID))
        XCTAssertEqual(manager.currentSchemaID(), fixture.schemaID)
        return manager
    }

    private func deployPrivateFixture(_ fixture: RuntimeFixture) throws {
        // Build only inside the private fixture directories. RimeDeployer also
        // writes a fixed App Group preference, so it is not suitable here.
        let manager = RimeSessionManager()
        XCTAssertTrue(manager.setup(withSharedDataDir: fixture.sharedURL.path, userDataDir: fixture.userURL.path))
        XCTAssertTrue(manager.initializeEngine())
        defer { manager.finalize() }

        guard
            let api = rime_get_api(),
            let startMaintenance = api.pointee.start_maintenance,
            let joinMaintenance = api.pointee.join_maintenance_thread
        else {
            throw FixtureDeploymentError.maintenanceAPIUnavailable
        }

        guard startMaintenance(1) != 0 else {
            throw FixtureDeploymentError.maintenanceDidNotStart
        }
        joinMaintenance()
    }

    private func makeRuntimeFixture(schemaID: String, hasTranslator: Bool) throws -> RuntimeFixture {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("int003-correction-query-\(UUID().uuidString)", isDirectory: true)
        let sharedURL = rootURL.appendingPathComponent("shared", isDirectory: true)
        let userURL = rootURL.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: sharedURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userURL, withIntermediateDirectories: true)

        try """
        config_version: "0.1"
        schema_list:
          - schema: \(schemaID)
        """.write(
            to: sharedURL.appendingPathComponent("default.yaml"),
            atomically: true,
            encoding: .utf8
        )

        let translatorSection = hasTranslator ? "  translators:\n    - script_translator\n" : "  translators: []\n"
        try """
        schema:
          schema_id: \(schemaID)
          name: INT-003 Synthetic Query Fixture
          version: "1.0"
        engine:
          processors:
            - speller
            - selector
            - navigator
            - express_editor
          segmentors:
            - abc_segmentor
        \(translatorSection)
        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
        translator:
          dictionary: \(schemaID)
        """.write(
            to: sharedURL.appendingPathComponent("\(schemaID).schema.yaml"),
            atomically: true,
            encoding: .utf8
        )

        if hasTranslator {
            try """
            ---
            name: \(schemaID)
            version: "0.1"
            sort: by_weight
            ...

            你好\tnihao
            """.write(
                to: sharedURL.appendingPathComponent("\(schemaID).dict.yaml"),
                atomically: true,
                encoding: .utf8
            )
        }

        return RuntimeFixture(rootURL: rootURL, sharedURL: sharedURL, userURL: userURL, schemaID: schemaID)
    }

    private func finalizeInstalledEngine(_ bridge: RimeSessionManager, fixture: RuntimeFixture) {
        bridge.finalize()
        try? FileManager.default.removeItem(at: fixture.rootURL)
    }

    #if DEBUG
        func testSynchronousFallbackInstallerRejectsResidualResponsiveStateWithoutCreatingEngine() throws {
            for residual in ["responsive-gate", "owner-gate", "bootstrap", "coordinator", "bridge"] {
                let controller = KeyboardController()
                controller.enableDefaultRimeEngine()
                let original = try XCTUnwrap(controller.rimeEngine)
                let pipeline = ResponsiveRimeSessionCoordinator(engine: original)
                let replacement = ResponsiveRimeEngineBridge(underlyingEngine: original, coordinator: pipeline)
                switch residual {
                case "responsive-gate":
                    controller.isResponsiveRimePipelineEnabled = true
                case "owner-gate":
                    controller.isThreadAffineRimeOwnerEnabled = true
                case "bootstrap":
                    controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
                        ThreadAffineRimeEngineImplBootstrap(sharedDataDir: "unused", userDataDir: "unused")
                    )
                case "coordinator":
                    controller.isResponsiveRimePipelineEnabled = true
                    controller.rebuildResponsiveRimeCoordinatorIfNeeded()
                    controller.isResponsiveRimePipelineEnabled = false
                default:
                    controller.rimeEngine = replacement
                }
                let beforeInstall = try XCTUnwrap(controller.rimeEngine)
                var factoryCalls = 0
                let result = SynchronousRimeFallbackInstaller.install(
                    on: controller,
                    makeEngine: {
                        factoryCalls += 1
                        return replacement
                    },
                    onRuntimeSelectionChanged: { _ in XCTFail("Rejected install must not publish") }
                )
                XCTAssertNil(result, residual)
                XCTAssertEqual(factoryCalls, 0, residual)
                XCTAssertTrue(controller.rimeEngine === beforeInstall, residual)
                controller.isResponsiveRimePipelineEnabled = false
                controller.isThreadAffineRimeOwnerEnabled = false
                controller.threadAffineEngineBootstrap = nil
                controller.rebuildResponsiveRimeCoordinatorIfNeeded()
            }
        }

        /// Turning off configuration does not itself destroy the installed owner.
        /// The installer must leave that owner usable until lifecycle teardown.
        func testSynchronousFallbackInstallerPreservesLiveThreadAffineOwnerWhenConfigurationIsCleared() throws {
            let fixture = try makeRuntimeFixture(schemaID: "synthetic_empty", hasTranslator: false)
            try deployPrivateFixture(fixture)
            let sharedPath = fixture.sharedURL.path
            let userPath = fixture.userURL.path
            let schemaID = fixture.schemaID
            let controller = KeyboardController()
            controller.isResponsiveRimePipelineEnabled = true
            controller.isThreadAffineRimeOwnerEnabled = true
            controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap {
                let engine = RimeEngineImpl(sharedDataDir: sharedPath, userDataDir: userPath)
                XCTAssertTrue(engine.bridge.selectSchema(schemaID))
                return engine
            }
            controller.rebuildResponsiveRimeCoordinatorIfNeeded()
            let coordinator = try XCTUnwrap(controller.threadAffineRimeCoordinator)
            let bridge = try XCTUnwrap(controller.rimeEngine as? ThreadAffineRimeEngineBridge)
            defer {
                let teardown = coordinator.suspendForVisibilityChange(timeout: .now() + 10)
                XCTAssertTrue(teardown?.isPositive == true)
                if teardown?.isPositive == true {
                    try? FileManager.default.removeItem(at: fixture.rootURL)
                } else {
                    coordinator.shutdown()
                }
            }

            XCTAssertEqual(bridge.processKey("n").rawInput, "n")
            let originalSession = try XCTUnwrap(bridge.diagnosticSessionSnapshot)
            XCTAssertTrue(originalSession.isValid)
            XCTAssertTrue(bridge.isOwnerReady)
            let beforeInstall = try XCTUnwrap(coordinator.lastPublished)

            // Clear only configuration: rebuilding here would tear down the owner
            // and erase the residual state this regression needs to exercise.
            controller.isResponsiveRimePipelineEnabled = false
            controller.isThreadAffineRimeOwnerEnabled = false
            controller.threadAffineEngineBootstrap = nil
            XCTAssertNil(controller.responsiveRimeCoordinator)
            var factoryCalls = 0
            let replacement = SynchronousRimeFallbackInstaller.install(
                on: controller,
                makeEngine: {
                    factoryCalls += 1
                    return RimeEngineImpl(sharedDataDir: sharedPath, userDataDir: userPath)
                },
                onRuntimeSelectionChanged: { _ in XCTFail("Rejected install must not publish") }
            )
            XCTAssertNil(replacement)
            XCTAssertEqual(factoryCalls, 0)
            XCTAssertTrue(controller.rimeEngine === bridge)
            XCTAssertTrue(controller.threadAffineRimeCoordinator === coordinator)
            XCTAssertTrue(bridge.isOwnerReady)
            XCTAssertEqual(bridge.diagnosticSessionSnapshot?.identity, originalSession.identity)

            // An exact ordered reply proves refusal did not shut down the owner.
            XCTAssertEqual(bridge.processKey("i").rawInput, "ni")
            let afterInstall = try XCTUnwrap(coordinator.lastPublished)
            let receipt = try XCTUnwrap(coordinator.lastAcceptReceipt)
            XCTAssertEqual(afterInstall.revision, receipt.revision)
            XCTAssertGreaterThan(afterInstall.revision, beforeInstall.revision)
            XCTAssertEqual(afterInstall.sessionEpoch, beforeInstall.sessionEpoch)
            XCTAssertTrue(bridge.diagnosticSessionSnapshot?.isValid == true)
            XCTAssertEqual(bridge.diagnosticSessionSnapshot?.identity, originalSession.identity)
        }

        func testSynchronousFallbackInstallerInstallsOneRealEngineAndSelectionCallback() throws {
            let fixture = try makeRuntimeFixture(schemaID: "synthetic_empty", hasTranslator: false)
            try deployPrivateFixture(fixture)
            let controller = KeyboardController()
            controller.enableDefaultRimeEngine()
            let original = try XCTUnwrap(controller.rimeEngine)
            var factoryCalls = 0
            var callbackSelections: [RimeRuntimeSelection] = []
            let engine = try XCTUnwrap(
                SynchronousRimeFallbackInstaller.install(
                    on: controller,
                    makeEngine: {
                        factoryCalls += 1
                        XCTAssertTrue(controller.rimeEngine === original)
                        return RimeEngineImpl(
                            sharedDataDir: fixture.sharedURL.path,
                            userDataDir: fixture.userURL.path
                        )
                    },
                    onRuntimeSelectionChanged: { callbackSelections.append($0) }
                )
            )
            defer { finalizeInstalledEngine(engine.bridge, fixture: fixture) }
            XCTAssertEqual(factoryCalls, 1)
            XCTAssertTrue(controller.rimeEngine === engine)
            XCTAssertNil(controller.responsiveRimeCoordinator)
            XCTAssertNil(controller.threadAffineRimeCoordinator)
            XCTAssertTrue(engine.bridge.selectSchema(fixture.schemaID))
            XCTAssertEqual(engine.bridge.currentSchemaID(), fixture.schemaID)
            XCTAssertTrue(engine.diagnosticSessionSnapshot?.isValid == true)
            let callback = try XCTUnwrap(engine.onRuntimeSelectionChanged)
            let selection = try XCTUnwrap(engine.runtimeSelection)
            callback(selection)
            XCTAssertEqual(callbackSelections, [selection])
            _ = controller.handle(.insertKey("n"))
            XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "n")
            XCTAssertNotNil(controller.state.lastRimeOutput?.composition)
        }
    #endif

    private func close(_ manager: RimeSessionManager, fixture: RuntimeFixture) {
        manager.finalize()
        try? FileManager.default.removeItem(at: fixture.rootURL)
    }
}

private struct RuntimeFixture {
    let rootURL: URL
    let sharedURL: URL
    let userURL: URL
    let schemaID: String
}

private enum FixtureDeploymentError: Error {
    case maintenanceAPIUnavailable
    case maintenanceDidNotStart
}
