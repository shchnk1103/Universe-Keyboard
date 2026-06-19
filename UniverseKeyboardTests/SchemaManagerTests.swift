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
        XCTAssertEqual(rimeIce?.licenseName, "GPL-3.0")
        XCTAssertTrue(rimeIce?.isDownloadable == true)
        XCTAssertTrue(rimeIce?.supportsUserDictionary == true)
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
        let installer = StubSchemaArchiveInstaller()
        let manager = makeManager(settings: settings, installer: installer)
        manager.rimeIceDownloadState = .completed

        manager.forceRedownload()

        XCTAssertEqual(manager.rimeIceDownloadState, .fetchingReleaseInfo)
        XCTAssertNil(settings.string(forKey: "rime_ice_etag"))
        XCTAssertNil(settings.string(forKey: "rime_ice_version"))
        XCTAssertTrue(installer.didClearBuildCache)
    }

    func testInstallationPassesSharedLuaCapabilityToInstaller() throws {
        let settings = StubSharedSettingsStore(values: ["rime_lua_available": false])
        let installer = StubSchemaArchiveInstaller()
        let manager = makeManager(settings: settings, installer: installer)

        try manager.installRimeIceFiles(from: URL(fileURLWithPath: "/test/extracted"))

        XCTAssertEqual(installer.installedLuaAvailability, false)
    }

    func testLuaDiagnosticReportsAvailableWhenEngineSchemaFilesAndDeploymentAreReady() throws {
        let fixture = try makeLuaDiagnosticFixture(
            schemaContent: "engine:\n  translators:\n    - lua_translator@*date_translator\n",
            includeLuaDirectory: true,
            includeDateTranslator: true
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_lua_available": true,
                "rime_deployed": true,
                "rime_needs_deploy": false,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            directories: SchemaDeploymentDirectories(sharedDataURL: fixture.sharedURL, userDataURL: fixture.userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        let diagnostic = manager.rimeIceLuaCapabilityDiagnostic()

        XCTAssertEqual(diagnostic.status, .available)
        XCTAssertTrue(diagnostic.deploymentModules.contains("lua"))
        XCTAssertTrue(diagnostic.schemaHasLuaComponents)
        XCTAssertTrue(diagnostic.luaEntryScriptExists)
        XCTAssertTrue(diagnostic.dateTranslatorExists)
    }

    func testLuaDiagnosticDetectsStrippedSchemaBeforeLuaFileChecks() throws {
        let fixture = try makeLuaDiagnosticFixture(
            schemaContent: "engine:\n  translators:\n    - script_translator\n",
            includeLuaDirectory: true,
            includeDateTranslator: true
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_lua_available": true,
                "rime_deployed": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            directories: SchemaDeploymentDirectories(sharedDataURL: fixture.sharedURL, userDataURL: fixture.userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        let diagnostic = manager.rimeIceLuaCapabilityDiagnostic()

        XCTAssertEqual(diagnostic.status, .schemaStripped)
    }

    func testLuaDiagnosticDetectsMissingLuaFiles() throws {
        let fixture = try makeLuaDiagnosticFixture(
            schemaContent: "engine:\n  translators:\n    - lua_translator@*date_translator\n",
            includeLuaDirectory: true,
            includeDateTranslator: false
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_lua_available": true,
                "rime_deployed": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            directories: SchemaDeploymentDirectories(sharedDataURL: fixture.sharedURL, userDataURL: fixture.userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        let diagnostic = manager.rimeIceLuaCapabilityDiagnostic()

        XCTAssertEqual(diagnostic.status, .luaFilesMissing)
    }

    func testLuaDiagnosticDetectsMissingLuaEntryScript() throws {
        let fixture = try makeLuaDiagnosticFixture(
            schemaContent: "engine:\n  translators:\n    - lua_translator@date_translator\n",
            includeLuaDirectory: true,
            includeLuaEntryScript: false,
            includeDateTranslator: true
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_lua_available": true,
                "rime_deployed": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            directories: SchemaDeploymentDirectories(sharedDataURL: fixture.sharedURL, userDataURL: fixture.userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        let diagnostic = manager.rimeIceLuaCapabilityDiagnostic()

        XCTAssertEqual(diagnostic.status, .luaFilesMissing)
        XCTAssertTrue(diagnostic.luaEntryScriptRequired)
        XCTAssertFalse(diagnostic.luaEntryScriptExists)
    }

    func testLuaDiagnosticDoesNotRequireEntryScriptForAutoloadLuaComponents() throws {
        let fixture = try makeLuaDiagnosticFixture(
            schemaContent: "engine:\n  translators:\n    - lua_translator@*date_translator\n",
            includeLuaDirectory: true,
            includeLuaEntryScript: false,
            includeDateTranslator: true
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_lua_available": true,
                "rime_deployed": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            directories: SchemaDeploymentDirectories(sharedDataURL: fixture.sharedURL, userDataURL: fixture.userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        let diagnostic = manager.rimeIceLuaCapabilityDiagnostic()

        XCTAssertEqual(diagnostic.status, .available)
        XCTAssertFalse(diagnostic.luaEntryScriptRequired)
        XCTAssertFalse(diagnostic.luaEntryScriptExists)
    }

    func testLuaDiagnosticReportsMissingLuaRequireDependencies() throws {
        let fixture = try makeLuaDiagnosticFixture(
            schemaContent: "engine:\n  translators:\n    - lua_translator@*date_translator\n",
            includeLuaDirectory: true,
            includeDateTranslator: true,
            dateTranslatorContent: #"local convert = require("convert_ar_num_to_zh")"#
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_lua_available": true,
                "rime_deployed": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            directories: SchemaDeploymentDirectories(sharedDataURL: fixture.sharedURL, userDataURL: fixture.userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        let diagnostic = manager.rimeIceLuaCapabilityDiagnostic()

        XCTAssertEqual(diagnostic.status, .luaFilesMissing)
        XCTAssertEqual(diagnostic.missingLuaDependencyNames, ["convert_ar_num_to_zh"])
    }

    func testLuaDiagnosticReportsSchemaReferencedMissingLuaComponents() throws {
        let fixture = try makeLuaDiagnosticFixture(
            schemaContent: """
            engine:
              translators:
                - lua_translator@*date_translator
              segmentors:
                - lua_segmentor@*unicode
              filters:
                - lua_filter@*corrector
            """,
            includeLuaDirectory: true,
            includeDateTranslator: true
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_lua_available": true,
                "rime_deployed": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            directories: SchemaDeploymentDirectories(sharedDataURL: fixture.sharedURL, userDataURL: fixture.userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        let diagnostic = manager.rimeIceLuaCapabilityDiagnostic()

        XCTAssertEqual(diagnostic.status, .luaFilesMissing)
        XCTAssertEqual(diagnostic.requiredLuaComponentNames, ["corrector", "date_translator", "unicode"])
        XCTAssertEqual(diagnostic.missingLuaComponentNames, ["corrector", "unicode"])
    }

    func testLuaDiagnosticPassesWhenAllSchemaReferencedLuaComponentsExist() throws {
        let fixture = try makeLuaDiagnosticFixture(
            schemaContent: """
            engine:
              translators:
                - lua_translator@*date_translator
              segmentors:
                - lua_segmentor@*unicode
              filters:
                - lua_filter@*corrector
            """,
            includeLuaDirectory: true,
            includeDateTranslator: true,
            extraLuaComponentNames: ["corrector", "unicode"]
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_lua_available": true,
                "rime_deployed": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            directories: SchemaDeploymentDirectories(sharedDataURL: fixture.sharedURL, userDataURL: fixture.userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        let diagnostic = manager.rimeIceLuaCapabilityDiagnostic()

        XCTAssertEqual(diagnostic.status, .available)
        XCTAssertEqual(diagnostic.missingLuaComponentNames, [])
    }

    func testLuaDiagnosticReportsNeedsDeployAfterCompleteInstallButBeforeDeployment() throws {
        let fixture = try makeLuaDiagnosticFixture(
            schemaContent: "engine:\n  translators:\n    - lua_translator@*date_translator\n",
            includeLuaDirectory: true,
            includeDateTranslator: true
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_lua_available": true,
                "rime_deployed": false,
                "rime_needs_deploy": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            directories: SchemaDeploymentDirectories(sharedDataURL: fixture.sharedURL, userDataURL: fixture.userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        let diagnostic = manager.rimeIceLuaCapabilityDiagnostic()

        XCTAssertEqual(diagnostic.status, .needsDeploy)
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
        XCTAssertFalse(settings.bool(forKey: RimeFuzzyPinyinSettings.pendingDeployKey))
        XCTAssertFalse(settings.bool(forKey: RimeUserDictionarySettings.pendingDeployKey))
        XCTAssertFalse(settings.bool(forKey: RimeAdvancedInputSettings.pendingDeployKey))
        XCTAssertEqual(
            settings.string(forKey: RimeFuzzyPinyinSettings.deployedSignatureKey),
            RimeFuzzyPinyinSettings().deploymentSignature(activeSchemaID: "luna_pinyin")
        )
        XCTAssertEqual(
            settings.string(forKey: RimeUserDictionarySettings.deployedSignatureKey),
            RimeUserDictionarySettings().deploymentSignature()
        )
        XCTAssertEqual(
            settings.string(forKey: RimeAdvancedInputSettings.deployedSignatureKey),
            RimeAdvancedInputSettings().deploymentSignature(activeSchemaID: "luna_pinyin", supportedFeatures: [])
        )
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
        XCTAssertEqual(
            settings.string(forKey: RimeFuzzyPinyinSettings.deployedSignatureKey),
            RimeFuzzyPinyinSettings(
                enabled: true,
                zhZEnabled: true,
                chCEnabled: false,
                shSEnabled: false,
                nLEnabled: false
            ).deploymentSignature(activeSchemaID: "rime_ice")
        )
    }

    func testDeploymentAppliesAdvancedInputFeatureSwitchesToRimeIce() async throws {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("schema-manager-advanced-input-\(UUID().uuidString)")
        let sharedURL = tempRoot.appendingPathComponent("shared")
        let userURL = tempRoot.appendingPathComponent("user")
        try FileManager.default.createDirectory(at: sharedURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let schemaYaml = """
        schema:
          schema_id: rime_ice
        engine:
          translators:
            - lua_translator@*date_translator
              date_locale: zh
            - lua_translator@*calc_translator
            - script_translator
        """
        let schemaURL = sharedURL.appendingPathComponent("rime_ice.schema.yaml")
        try schemaYaml.write(to: schemaURL, atomically: true, encoding: .utf8)

        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                RimeAdvancedInputSettings.enabledKey(for: .dateTime): false,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            directories: SchemaDeploymentDirectories(sharedDataURL: sharedURL, userDataURL: userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        await manager.deployRimeConfig()

        let disabledSchema = try String(contentsOf: schemaURL, encoding: .utf8)
        XCTAssertFalse(disabledSchema.contains("date_translator"))
        XCTAssertFalse(disabledSchema.contains("date_locale"))
        XCTAssertTrue(disabledSchema.contains("calc_translator"))

        settings.set(true, forKey: RimeAdvancedInputSettings.enabledKey(for: .dateTime))
        await manager.deployRimeConfig()

        let restoredSchema = try String(contentsOf: schemaURL, encoding: .utf8)
        XCTAssertTrue(restoredSchema.contains("date_translator"))
        XCTAssertTrue(restoredSchema.contains("date_locale"))
        XCTAssertTrue(restoredSchema.contains("calc_translator"))
    }

    func testDeploymentRemovesFuzzyPinyinBlockWhenMasterSwitchDisabled() async throws {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("schema-manager-fuzzy-disabled-\(UUID().uuidString)")
        let sharedURL = tempRoot.appendingPathComponent("shared")
        let userURL = tempRoot.appendingPathComponent("user")
        try FileManager.default.createDirectory(at: sharedURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let schemaYaml = """
        schema:
          schema_id: luna_pinyin
        speller:
          algebra:
            - erase/^xx$/
            # universe:fuzzy-pinyin begin
            - derive/^zh/z/
            # universe:fuzzy-pinyin end
        """
        try schemaYaml.write(
            to: sharedURL.appendingPathComponent("luna_pinyin.schema.yaml"),
            atomically: true,
            encoding: .utf8
        )

        let settings = StubSharedSettingsStore(
            values: [RimeFuzzyPinyinSettings.enabledKey: false]
        )
        let installer = StubSchemaArchiveInstaller(
            directories: SchemaDeploymentDirectories(sharedDataURL: sharedURL, userDataURL: userURL)
        )
        let manager = makeManager(settings: settings, installer: installer)

        await manager.deployRimeConfig()

        let schema = try String(
            contentsOf: sharedURL.appendingPathComponent("luna_pinyin.schema.yaml"),
            encoding: .utf8
        )
        XCTAssertFalse(schema.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
        XCTAssertTrue(schema.contains("- erase/^xx$/"))
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

    private func makeLuaDiagnosticFixture(
        schemaContent: String?,
        includeLuaDirectory: Bool,
        includeLuaEntryScript: Bool = true,
        includeDateTranslator: Bool,
        dateTranslatorContent: String = "-- test fixture\n",
        extraLuaComponentNames: [String] = []
    ) throws -> (rootURL: URL, sharedURL: URL, userURL: URL) {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("schema-manager-lua-\(UUID().uuidString)")
        let sharedURL = rootURL.appendingPathComponent("shared")
        let userURL = rootURL.appendingPathComponent("user")
        try FileManager.default.createDirectory(at: sharedURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userURL, withIntermediateDirectories: true)

        if let schemaContent {
            try schemaContent.write(
                to: sharedURL.appendingPathComponent("rime_ice.schema.yaml"),
                atomically: true,
                encoding: .utf8
            )
        }
        if includeLuaEntryScript {
            try "-- test fixture\n".write(
                to: sharedURL.appendingPathComponent("rime.lua"),
                atomically: true,
                encoding: .utf8
            )
        }
        if includeLuaDirectory {
            let luaURL = sharedURL.appendingPathComponent("lua", isDirectory: true)
            try FileManager.default.createDirectory(at: luaURL, withIntermediateDirectories: true)
            if includeDateTranslator {
                try dateTranslatorContent.write(
                    to: luaURL.appendingPathComponent("date_translator.lua"),
                    atomically: true,
                    encoding: .utf8
                )
            }
            for name in extraLuaComponentNames {
                try "-- test fixture\n".write(
                    to: luaURL.appendingPathComponent("\(name).lua"),
                    atomically: true,
                    encoding: .utf8
                )
            }
        }

        return (rootURL, sharedURL, userURL)
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

    func latestArchiveURL(for distribution: RimeSchemeDistribution) async throws -> URL? { latestURL }
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
    private(set) var didClearBuildCache = false

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

    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        URL(fileURLWithPath: "/test/\(distribution.cachedArchiveFileName)")
    }
    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        URL(fileURLWithPath: "/test/\(distribution.extractionDirectoryName)")
    }
    func removeTemporaryItem(at url: URL) {}
    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool { containsInstalledSchema }
    func checkDiskSpace(needed: Int64) throws {}
    func installSchemaFiles(from extractDir: URL, plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws {
        installedLuaAvailability = luaAvailable
    }
    func uninstallSchemaFiles(plan: RimeSchemeInstallationPlan) { didUninstall = true }
    func clearBuildCache(plan: RimeSchemeInstallationPlan) { didClearBuildCache = true }
    func sharedDataDirectoryURL() -> URL? { directories.sharedDataURL }
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
