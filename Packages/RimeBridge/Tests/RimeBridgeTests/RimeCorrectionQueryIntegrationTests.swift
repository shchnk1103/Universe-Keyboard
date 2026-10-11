import Foundation
import RimeBridgeObjC
import XCTest

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
