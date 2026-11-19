import KeyboardCore
import XCTest

@testable import RimeBridge
@testable import Universe_Keyboard

@MainActor
final class NineKeyLunaEnableTests: XCTestCase {
    func testUnreadyBindingIsNotWritten() async {
        let settings = StubSharedSettingsStore()
        let manager = SchemaManager(
            settings: settings,
            sourceSelector: StubSchemaSourceSelector(),
            archiveDownloader: StubSchemaArchiveDownloader(),
            artifactVerifier: SchemaArtifactVerifier(),
            temporaryArtifactCleaner: FileSystemSchemaTemporaryArtifactCleaner(),
            deliveryDiagnostics: RecordingDeliveryDiagnostics(),
            archiveInstaller: StubSchemaArchiveInstaller(),
            deploymentService: StubDeploymentService(succeeded: false)
        )
        let message = await manager.setSchemeBinding9("luna_pinyin_t9")
        XCTAssertNotNil(message)
        XCTAssertNil(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9))
        XCTAssertNil(NineKeyPublishSmoke.override)
        XCTAssertNil(RimeT9SmokeProbe.selectAndConfirmHook)
    }

    func testReadyBindingRoundTripAndChoicesFollowReadiness() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "luna-enable-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let source = try Data(
            contentsOf: repo.appendingPathComponent("Universe Keyboard/RimeBuiltin/luna_pinyin.schema.yaml"))
        try source.write(to: shared.appendingPathComponent("luna_pinyin.schema.yaml"))
        let derived = try LunaT9SchemaCompatibility.rewrite(source)
        try derived.write(to: shared.appendingPathComponent("luna_pinyin_t9.schema.yaml"))
        let build = shared.appendingPathComponent("build", isDirectory: true)
        try FileManager.default.createDirectory(at: build, withIntermediateDirectories: true)
        try Data("schema:\n  schema_id: luna_pinyin_t9\nengine: {}\n".utf8).write(
            to: build.appendingPathComponent("luna_pinyin_t9.schema.yaml"))
        let settings = StubSharedSettingsStore()
        let installer = DeploymentDirectoryOverrideSchemaArchiveInstaller(
            underlying: SharedContainerSchemaArchiveInstaller(
                appGroupID: "test.luna-enable", containerURL: root),
            directories: SchemaDeploymentDirectories(sharedDataURL: shared, userDataURL: user)
        )
        let manager = SchemaManager(
            settings: settings,
            sourceSelector: StubSchemaSourceSelector(),
            archiveDownloader: StubSchemaArchiveDownloader(),
            artifactVerifier: SchemaArtifactVerifier(),
            temporaryArtifactCleaner: FileSystemSchemaTemporaryArtifactCleaner(),
            deliveryDiagnostics: RecordingDeliveryDiagnostics(),
            archiveInstaller: installer,
            deploymentService: StubDeploymentService(succeeded: true)
        )
        let fingerprint = try XCTUnwrap(
            T9DeploymentSupport.resourceFingerprint(schemaID: "luna_pinyin_t9", sharedDataURL: shared))
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: "luna_pinyin_t9", fingerprint: fingerprint, upstreamVersion: nil, settings: settings)
        let message = await manager.setSchemeBinding9("luna_pinyin_t9")
        XCTAssertNil(message)
        XCTAssertEqual(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9), "luna_pinyin_t9")
        let store = RimeSettingsStore(schemaManager: manager)
        XCTAssertTrue(store.nineKeySchemeChoices.contains { $0.id == "luna_pinyin_t9" })
        let entry: NineKeyLayoutEntry = store.nineKeyLayoutEntry()
        XCTAssertEqual(entry, NineKeyLayoutEntry.persistLayoutKeepingBinding)
    }
}
