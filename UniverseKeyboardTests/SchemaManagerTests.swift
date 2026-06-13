import Foundation
import KeyboardCore
import RimeBridge
import XCTest

@testable import Universe_Keyboard

@MainActor
final class SchemaManagerTests: XCTestCase {
    func testRefreshSchemaListUsesInjectedInstallationState() {
        let settings = StubSharedSettingsStore(
            values: ["rime_ice_installed": true, "rime_ice_version": "2026.05.01"]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let manager = makeManager(settings: settings, installer: installer)

        let rimeIce = manager.schemas.first { $0.schemaID == "rime_ice" }

        XCTAssertEqual(rimeIce?.version, "2026.05.01")
        XCTAssertEqual(rimeIce?.installed, true)
    }

    func testSchemaSwitchAndLicenseAcceptancePersistIntentFlags() {
        let settings = StubSharedSettingsStore()
        let manager = makeManager(settings: settings)

        manager.acceptLicense()
        manager.switchToSchema("rime_ice")

        XCTAssertTrue(settings.bool(forKey: "rime_ice_license_accepted"))
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "rime_ice")
        XCTAssertTrue(settings.bool(forKey: "rime_needs_deploy"))
        XCTAssertFalse(settings.bool(forKey: "rime_deployed"))
    }

    func testCheckForUpdateUsesInjectedCatalogClient() async {
        let manager = makeManager(
            settings: StubSharedSettingsStore(values: ["rime_ice_version": "full-old.zip"]),
            catalogClient: StubSchemaCatalogClient(
                latestURL: URL(string: "https://example.test/releases/full-new.zip")
            )
        )

        let updateAvailable = await manager.checkForUpdate()

        XCTAssertTrue(updateAvailable)
    }

    func testCheckForUpdateUsesGitHubReleaseTagWhenAvailable() async {
        let manager = makeManager(
            settings: StubSharedSettingsStore(values: ["rime_ice_version": "2026.05.01"]),
            catalogClient: StubSchemaCatalogClient(
                latestURL: URL(string: "https://github.com/iDvel/rime-ice/releases/download/2026.05.01/full.zip")
            )
        )

        let updateAvailable = await manager.checkForUpdate()

        XCTAssertFalse(updateAvailable)
    }

    func testCheckForUpdateDetectsDifferentGitHubReleaseTag() async {
        let manager = makeManager(
            settings: StubSharedSettingsStore(values: ["rime_ice_version": "2026.05.01"]),
            catalogClient: StubSchemaCatalogClient(
                latestURL: URL(string: "https://github.com/iDvel/rime-ice/releases/download/2026.05.02/full.zip")
            )
        )

        let updateAvailable = await manager.checkForUpdate()

        XCTAssertTrue(updateAvailable)
    }

    func testReleaseVersionIdentifierFallsBackToFilenameForNonReleaseURLs() {
        let manager = makeManager()

        let version = manager.releaseVersionIdentifier(from: URL(string: "https://example.test/releases/full-new.zip")!)

        XCTAssertEqual(version, "full-new.zip")
    }

    func testDownloadUsesStoredETagAndPersistsReturnedETag() async throws {
        let settings = StubSharedSettingsStore(values: ["rime_ice_etag": "old-etag"])
        let downloader = StubSchemaArchiveDownloader(returnedETag: "new-etag")
        let manager = makeManager(settings: settings, archiveDownloader: downloader)
        let sourceURL = URL(string: "https://example.test/releases/full.zip")!

        _ = try await manager.downloadZip(from: sourceURL)

        let requests = await downloader.requests
        XCTAssertEqual(requests.first?.existingETag, "old-etag")
        XCTAssertEqual(settings.string(forKey: "rime_ice_etag"), "new-etag")
    }

    func testStartDownloadAllowsCompletedStateForInstalledSchemaUpdates() {
        let manager = makeManager()
        manager.rimeIceDownloadState = .completed

        manager.startDownload()

        XCTAssertEqual(manager.rimeIceDownloadState, .fetchingReleaseInfo)
    }

    func testForceRedownloadAllowsCompletedStateAndClearsCachedMetadata() {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_ice_etag": "old-etag",
                "rime_ice_version": "old-version",
            ]
        )
        let manager = makeManager(settings: settings)
        manager.rimeIceDownloadState = .completed

        manager.forceRedownload()

        XCTAssertEqual(manager.rimeIceDownloadState, .fetchingReleaseInfo)
        XCTAssertNil(settings.string(forKey: "rime_ice_etag"))
        XCTAssertNil(settings.string(forKey: "rime_ice_version"))
    }

    func testInstallationPassesSharedLuaCapabilityToInstaller() throws {
        let settings = StubSharedSettingsStore(values: ["rime_lua_available": false])
        let installer = StubSchemaArchiveInstaller()
        let manager = makeManager(settings: settings, installer: installer)

        try manager.installRimeIceFiles(from: URL(fileURLWithPath: "/test/extracted"))

        XCTAssertEqual(installer.installedLuaAvailability, false)
    }

    func testUninstallDelegatesFileRemovalAndClearsInstalledMetadata() {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_ice_version": "test-version",
                "rime_ice_license_accepted": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let manager = makeManager(settings: settings, installer: installer)

        manager.uninstallRimeIce()

        XCTAssertTrue(installer.didUninstall)
        XCTAssertNil(settings.object(forKey: "rime_ice_installed"))
        XCTAssertNil(settings.object(forKey: "rime_ice_version"))
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
    }

    func testSuccessfulDeploymentUsesFullCheckAndUpdatesSharedFlags() async {
        let settings = StubSharedSettingsStore(values: ["rime_needs_deploy": true])
        let installer = StubSchemaArchiveInstaller()
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.deployRimeConfig()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        guard let request = requests.first else { return }
        if case .fullCheck = request.mode {
        } else {
            XCTFail("Main app deployments must use fullCheck mode")
        }
        XCTAssertEqual(request.sharedDataURL, installer.directories.sharedDataURL)
        XCTAssertTrue(settings.bool(forKey: "rime_deployed"))
        XCTAssertFalse(settings.bool(forKey: "rime_needs_deploy"))
        XCTAssertFalse(settings.bool(forKey: "rime_deploying"))
    }

    func testDeploymentAppliesFuzzyPinyinOnlyToActiveSchema() async throws {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("schema-manager-fuzzy-\(UUID().uuidString)")
        let sharedURL = tempRoot.appendingPathComponent("shared")
        let userURL = tempRoot.appendingPathComponent("user")
        try FileManager.default.createDirectory(at: sharedURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let schemaYaml = """
        schema:
          schema_id: rime_ice
        speller:
          algebra:
            - erase/^xx$/
        """
        try schemaYaml.write(to: sharedURL.appendingPathComponent("rime_ice.schema.yaml"), atomically: true, encoding: .utf8)
        try schemaYaml.write(to: sharedURL.appendingPathComponent("luna_pinyin.schema.yaml"), atomically: true, encoding: .utf8)

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                RimeFuzzyPinyinSettings.zhZKey: true,
                RimeFuzzyPinyinSettings.chCKey: false,
                RimeFuzzyPinyinSettings.shSKey: false,
                RimeFuzzyPinyinSettings.nLKey: false,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            directories: SchemaDeploymentDirectories(sharedDataURL: sharedURL, userDataURL: userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        await manager.deployRimeConfig()

        let activeSchema = try String(contentsOf: sharedURL.appendingPathComponent("rime_ice.schema.yaml"), encoding: .utf8)
        let inactiveSchema = try String(contentsOf: sharedURL.appendingPathComponent("luna_pinyin.schema.yaml"), encoding: .utf8)
        XCTAssertTrue(activeSchema.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
        XCTAssertTrue(activeSchema.contains("- derive/^zh/z/"))
        XCTAssertFalse(activeSchema.contains("- derive/^ch/c/"))
        XCTAssertFalse(inactiveSchema.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
    }

    func testFailedDeploymentPreservesRecoveryIntent() async {
        let settings = StubSharedSettingsStore()
        let manager = makeManager(
            settings: settings,
            deploymentService: StubDeploymentService(succeeded: false)
        )

        await manager.deployRimeConfig()

        XCTAssertFalse(settings.bool(forKey: "rime_deployed"))
        XCTAssertTrue(settings.bool(forKey: "rime_needs_deploy"))
        XCTAssertFalse(settings.bool(forKey: "rime_deploying"))
    }

    private func makeManager(
        settings: StubSharedSettingsStore = StubSharedSettingsStore(),
        catalogClient: any SchemaCatalogClient = StubSchemaCatalogClient(latestURL: nil),
        archiveDownloader: any SchemaArchiveDownloading = StubSchemaArchiveDownloader(returnedETag: nil),
        installer: StubSchemaArchiveInstaller = StubSchemaArchiveInstaller(),
        deploymentService: any RimeDeploymentServicing = StubDeploymentService(succeeded: true)
    ) -> SchemaManager {
        SchemaManager(
            settings: settings,
            catalogClient: catalogClient,
            archiveDownloader: archiveDownloader,
            archiveInstaller: installer,
            deploymentService: deploymentService
        )
    }
}

@MainActor
private final class StubSharedSettingsStore: SharedSettingsStoring {
    private var values: [String: Any]

    init(values: [String: Any] = [:]) {
        self.values = values
    }

    func string(forKey key: String) -> String? { values[key] as? String }
    func bool(forKey key: String) -> Bool { values[key] as? Bool ?? false }
    func object(forKey key: String) -> Any? { values[key] }
    func set(_ value: Any?, forKey key: String) { values[key] = value }
    func removeObject(forKey key: String) { values.removeValue(forKey: key) }
    func synchronize() {}
}

private struct StubSchemaCatalogClient: SchemaCatalogClient {
    let latestURL: URL?

    func latestRimeIceArchiveURL() async throws -> URL? { latestURL }
}

private actor StubSchemaArchiveDownloader: SchemaArchiveDownloading {
    struct Request: Sendable {
        let sourceURL: URL
        let existingETag: String?
        let cachedArchiveURL: URL
    }

    private let returnedETag: String?
    private(set) var requests: [Request] = []

    init(returnedETag: String?) {
        self.returnedETag = returnedETag
    }

    func downloadArchive(
        from url: URL,
        existingETag: String?,
        cachedArchiveURL: URL
    ) async throws -> DownloadedSchemaArchive {
        requests.append(
            Request(sourceURL: url, existingETag: existingETag, cachedArchiveURL: cachedArchiveURL)
        )
        return DownloadedSchemaArchive(
            localURL: cachedArchiveURL,
            expectedContentLength: 42,
            eTag: returnedETag
        )
    }
}

@MainActor
private final class StubSchemaArchiveInstaller: SchemaArchiveInstalling {
    let directories: SchemaDeploymentDirectories
    private let containsInstalledSchema: Bool
    private(set) var installedLuaAvailability: Bool?
    private(set) var didUninstall = false

    init(
        containsInstalledSchema: Bool = false,
        directories: SchemaDeploymentDirectories = SchemaDeploymentDirectories(
            sharedDataURL: URL(fileURLWithPath: "/test/Rime/shared"),
            userDataURL: URL(fileURLWithPath: "/test/Rime/user")
        )
    ) {
        self.containsInstalledSchema = containsInstalledSchema
        self.directories = directories
    }

    var cachedArchiveURL: URL { URL(fileURLWithPath: "/test/rime_ice_full.zip") }
    func prepareExtractionDirectory() throws -> URL { URL(fileURLWithPath: "/test/rime_ice_extract") }
    func removeTemporaryItem(at url: URL) {}
    func containsInstalledRimeIceSchema() -> Bool { containsInstalledSchema }
    func checkDiskSpace(needed: Int64) throws {}
    func installRimeIceFiles(from extractDir: URL, luaAvailable: Bool) throws {
        installedLuaAvailability = luaAvailable
    }
    func uninstallRimeIceFiles() { didUninstall = true }
    func deploymentDirectories() throws -> SchemaDeploymentDirectories { directories }
}

private actor StubDeploymentService: RimeDeploymentServicing {
    private let result: RimeDeploymentResult
    private(set) var requests: [RimeDeploymentRequest] = []

    init(succeeded: Bool) {
        self.result = RimeDeploymentResult(succeeded: succeeded, diagnosticMessage: "test")
    }

    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        requests.append(request)
        return result
    }
}
