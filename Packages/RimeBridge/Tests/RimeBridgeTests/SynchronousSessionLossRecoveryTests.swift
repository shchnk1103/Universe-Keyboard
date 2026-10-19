import RimeBridgeObjC
import XCTest

@testable import KeyboardCore
@testable import RimeBridge

/// Proves the synchronous engine restores a dropped session's raw prefix
/// before accepting the next key. The fixture is a private synthetic schema.
@MainActor
final class SynchronousSessionLossRecoveryTests: XCTestCase {
    func testVisibleSessionLossRestoresRawPrefixBeforeTheNextKey() throws {
        let fixture = try RuntimeFixture.make(schemaID: "synthetic_empty", hasTranslator: false)
        try fixture.deploy()
        let engine = RimeEngineImpl(
            sharedDataDir: fixture.sharedURL.path,
            userDataDir: fixture.userURL.path
        )
        defer { fixture.close(engine.bridge) }
        XCTAssertTrue(engine.bridge.selectSchema(fixture.schemaID))

        let host = RecoveryHost()
        let controller = KeyboardController()
        controller.textClient = host
        controller.rimeEngine = engine

        _ = controller.handle(.insertKey("n"))
        XCTAssertTrue(engine.isComposing())
        XCTAssertEqual(controller.state.currentComposition, "n")
        let recoveriesBeforeLoss = engine.recoverSessionCallCountForTesting

        XCTAssertTrue(engine.bridge.destroySession())
        _ = controller.handle(.insertKey("i"))

        XCTAssertEqual(engine.recoverSessionCallCountForTesting, recoveriesBeforeLoss + 1)
        XCTAssertEqual(controller.state.currentComposition, "ni")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "ni")
        XCTAssertTrue(engine.isComposing())
        XCTAssertEqual(host.markedText, controller.state.insertedPreeditText)
        XCTAssertFalse(host.markedText.isEmpty)
        XCTAssertEqual(host.insertCount, 0)
    }

    func testFailedSessionRecreationDoesNotConsumeTheNextKey() throws {
        let fixture = try RuntimeFixture.make(schemaID: "synthetic_empty", hasTranslator: false)
        try fixture.deploy()
        let engine = RimeEngineImpl(
            sharedDataDir: fixture.sharedURL.path,
            userDataDir: fixture.userURL.path
        )
        defer { fixture.close(engine.bridge) }
        XCTAssertTrue(engine.bridge.selectSchema(fixture.schemaID))
        _ = engine.processKey("n")
        XCTAssertTrue(engine.bridge.destroySession())

        engine.bridge.failNextSessionCreationsForTesting(8)
        let rejected = engine.processKey("i")

        XCTAssertNil(rejected.composition)
        XCTAssertNil(rejected.rawInput)
        XCTAssertNil(rejected.committedText)
        XCTAssertEqual(engine.bridge.currentSessionIdentifier(), 0)
        XCTAssertGreaterThan(engine.bridge.injectedSessionCreationFailureCountForTesting, 0)

        // A failed recreation backs off for 0.5s. The remembered prefix must
        // still be available once that window opens.
        engine.bridge.failNextSessionCreationsForTesting(0)
        Thread.sleep(forTimeInterval: 0.7)
        let restored = engine.processKey("i")

        XCTAssertEqual(restored.rawInput, "ni")
        XCTAssertEqual(restored.composition?.preeditText, "ni")
        XCTAssertNil(restored.committedText)
        XCTAssertTrue(engine.isComposing())
        XCTAssertEqual(engine.bridge.currentSessionIdentifier() == 0, false)
    }
}

@MainActor
private final class RecoveryHost: TextInputClient {
    private(set) var markedText = ""
    private(set) var insertCount = 0

    var hasTextBeforeInput: Bool { !markedText.isEmpty }

    func insertText(_ text: String) {
        insertCount += 1
        markedText = ""
    }

    func deleteBackward() {}

    func adjustTextPosition(byCharacterOffset offset: Int) {}

    func setMarkedText(_ text: String, selectedRange: Range<Int>) {
        markedText = text
    }

    func unmarkText() {
        markedText = ""
    }
}

private struct RuntimeFixture {
    let rootURL: URL
    let sharedURL: URL
    let userURL: URL
    let schemaID: String

    static func make(schemaID: String, hasTranslator: Bool) throws -> RuntimeFixture {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-delivery-001-\(UUID().uuidString)", isDirectory: true)
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
        let translators = hasTranslator ? "    - script_translator\n" : ""
        try """
        schema:
          schema_id: \(schemaID)
          name: \(schemaID)
          version: "1.0"
        engine:
          processors:
            - speller
            - selector
            - navigator
            - express_editor
          segmentors:
            - abc_segmentor
          translators:
        \(translators)
        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
        translator:
          dictionary: \(schemaID)
        """.write(
            to: sharedURL.appendingPathComponent("\(schemaID).schema.yaml"),
            atomically: true,
            encoding: .utf8
        )
        return RuntimeFixture(rootURL: rootURL, sharedURL: sharedURL, userURL: userURL, schemaID: schemaID)
    }

    func deploy() throws {
        // Compile only inside the private fixture. RimeDeployer also writes a
        // fixed App Group preference, so it is not used here.
        let manager = RimeSessionManager()
        XCTAssertTrue(manager.setup(withSharedDataDir: sharedURL.path, userDataDir: userURL.path))
        XCTAssertTrue(manager.initializeEngine())
        defer { manager.finalize() }
        guard
            let api = rime_get_api(),
            let startMaintenance = api.pointee.start_maintenance,
            let joinMaintenance = api.pointee.join_maintenance_thread
        else {
            XCTFail("librime maintenance API is unavailable")
            return
        }
        XCTAssertNotEqual(startMaintenance(1), 0)
        joinMaintenance()
    }

    func close(_ bridge: RimeSessionManager) {
        bridge.finalize()
        try? FileManager.default.removeItem(at: rootURL)
    }
}
