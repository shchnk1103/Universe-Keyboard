import Foundation
import KeyboardCore
import RimeBridge
import Synchronization
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

        XCTAssertNotNil(manager.schemas.first { $0.schemaID == "wanxiang" })
        let rimeIce = manager.schemas.first { $0.schemaID == "rime_ice" }

        XCTAssertEqual(rimeIce?.version, "2026.05.01")
        XCTAssertEqual(rimeIce?.installed, true)
        XCTAssertEqual(rimeIce?.licenseName, "GPL-3.0-only")
        XCTAssertEqual(rimeIce?.licenseDescriptor, ThirdPartyLicenseCatalog.rimeIce)
        XCTAssertTrue(rimeIce?.isDownloadable == true)
        XCTAssertTrue(rimeIce?.supportsUserDictionary == true)
    }

    func testWanxiangCatalogEntryIsDownloadableFullPinyin() {
        let entry = RimeSchemeCatalog.entry(for: "wanxiang")
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.schemaID, "wanxiang")
        XCTAssertEqual(entry?.name, "万象拼音")
        XCTAssertEqual(entry?.distribution?.manifest.schemeID, "wanxiang")
        XCTAssertEqual(entry?.distribution?.manifest.version, "17.5.9")
        XCTAssertEqual(entry?.distribution?.manifest.assetName, "rime-wanxiang-base.zip")
        XCTAssertEqual(entry?.distribution?.manifest.sourceVariants.count, 2)
        XCTAssertEqual(entry?.installationPlan?.schemaFileName, "wanxiang.schema.yaml")
        XCTAssertEqual(entry?.license, ThirdPartyLicenseCatalog.wanxiang)
        XCTAssertTrue(entry?.requiresLua == true)
        XCTAssertTrue(RimeRuntimeSelection.isTwentySixKeyCapable("wanxiang"))
        XCTAssertFalse(RimeRuntimeSelection.isNineKeyCapable("wanxiang"))
        XCTAssertNotNil(RimeSchemeCatalog.downloadableEntries.first { $0.schemaID == "wanxiang" })
    }

    func testSchemaSwitchAndLicenseAcceptancePersistIntentFlags() {
        let settings = StubSharedSettingsStore()
        let manager = makeManager(settings: settings)

        manager.acceptLicense()
        manager.switchToSchema("rime_ice")

        XCTAssertTrue(settings.bool(forKey: "rime_ice_license_accepted"))
        XCTAssertEqual(
            settings.string(forKey: "rime_ice_license_acceptance_revision"),
            ThirdPartyLicenseCatalog.rimeIce.acceptanceRevision
        )
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "rime_ice")
        XCTAssertTrue(settings.bool(forKey: "rime_needs_deploy"))
        XCTAssertFalse(settings.bool(forKey: "rime_deployed"))
    }

    func testDownloadableSchemesUseTheirOwnLicenseDescriptors() {
        XCTAssertEqual(
            RimeSchemeCatalog.entry(for: "rime_ice")?.license,
            ThirdPartyLicenseCatalog.rimeIce
        )
        XCTAssertEqual(
            RimeSchemeCatalog.entry(for: "wanxiang")?.license,
            ThirdPartyLicenseCatalog.wanxiang
        )
        XCTAssertNotEqual(
            ThirdPartyLicenseCatalog.rimeIce.acceptanceRevision,
            ThirdPartyLicenseCatalog.wanxiang.acceptanceRevision
        )
    }

    func testEveryThirdPartyCatalogEntryHasBundledOfflineDocuments() {
        let catalog =
            ThirdPartyLicenseCatalog.downloadableSchemes
            + ThirdPartyLicenseCatalog.bundledContent

        for license in catalog {
            XCTAssertFalse(
                license.offlineDocuments.isEmpty,
                "\(license.projectName) must provide at least one offline notice"
            )
            XCTAssertEqual(
                Set(license.offlineDocuments.map(\.resourceName)).count,
                license.offlineDocuments.count,
                "\(license.projectName) must not repeat an offline notice"
            )

            for document in license.offlineDocuments {
                let nestedURL = Bundle.main.url(
                    forResource: document.resourceName,
                    withExtension: "txt",
                    subdirectory: "ThirdPartyLicenses"
                )
                let resourceURL =
                    nestedURL
                    ?? Bundle.main.url(
                        forResource: document.resourceName,
                        withExtension: "txt"
                    )

                guard let resourceURL else {
                    XCTFail("Missing bundled notice: \(document.resourceName).txt")
                    continue
                }

                let text = try? String(contentsOf: resourceURL, encoding: .utf8)
                XCTAssertFalse(
                    text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true,
                    "Bundled notice must be non-empty UTF-8: \(document.resourceName).txt"
                )
            }
        }
    }

    func testOpenCCCatalogRequiresLicenseAndAuthorsDocuments() {
        let openCC = ThirdPartyLicenseCatalog.bundledComponents.first { $0.id == "opencc" }

        XCTAssertEqual(
            Set(openCC?.offlineDocuments.map(\.resourceName) ?? []),
            ["OPENCC-Apache-2.0", "OPENCC-AUTHORS"]
        )
    }

    func testLicenseAcceptanceIsIsolatedPerScheme() {
        let manager = makeManager()

        manager.acceptLicense(for: "rime_ice")

        XCTAssertTrue(manager.licenseAccepted(for: "rime_ice"))
        XCTAssertFalse(manager.licenseAccepted(for: "wanxiang"))
    }

    func testStaleLicenseRevisionRequiresNewAcceptance() {
        let settings = StubSharedSettingsStore(
            values: ["rime_ice_license_acceptance_revision": "rime-ice-gpl-3.0-only-old"]
        )
        let manager = makeManager(settings: settings)

        XCTAssertFalse(manager.licenseAccepted(for: "rime_ice"))
    }

    func testLegacyRimeIceAcceptanceMigratesToCurrentRevision() {
        let settings = StubSharedSettingsStore(values: ["rime_ice_license_accepted": true])

        let manager = makeManager(settings: settings)

        XCTAssertTrue(manager.licenseAccepted(for: "rime_ice"))
        XCTAssertEqual(
            settings.string(forKey: "rime_ice_license_acceptance_revision"),
            ThirdPartyLicenseCatalog.rimeIce.acceptanceRevision
        )
    }

    func testLegacyWanxiangAcceptanceDoesNotMigrateFromIncorrectSharedDialog() {
        let settings = StubSharedSettingsStore(values: ["wanxiang_license_accepted": true])

        let manager = makeManager(settings: settings)

        XCTAssertFalse(manager.licenseAccepted(for: "wanxiang"))
        XCTAssertNil(settings.string(forKey: "wanxiang_license_acceptance_revision"))
    }

    func testDownloadIsBlockedUntilCurrentLicenseRevisionIsAccepted() {
        let manager = makeManager()
        manager.rimeIceDownloadState = .completed(schemeName: "雾凇拼音")

        manager.startDownload()

        XCTAssertEqual(manager.rimeIceDownloadState, .completed(schemeName: "雾凇拼音"))
    }

    func testCheckForUpdateUsesPinnedManifestVersion() async {
        let manager = makeManager(
            settings: StubSharedSettingsStore(values: ["rime_ice_version": "old-version"])
        )

        let updateAvailable = await manager.checkForUpdate()

        XCTAssertTrue(updateAvailable)
    }

    func testCheckForUpdateReportsCurrentPinnedVersion() async {
        let manager = makeManager(
            settings: StubSharedSettingsStore(values: ["rime_ice_version": "nightly"])
        )

        let updateAvailable = await manager.checkForUpdate()

        XCTAssertFalse(updateAvailable)
    }

    func testCheckForUpdateUsesWanxiangPinnedVersion() async {
        let manager = makeManager(
            settings: StubSharedSettingsStore(values: ["wanxiang_version": "17.5.9"])
        )

        let updateAvailable = await manager.checkForUpdate(schemaID: "wanxiang")

        XCTAssertFalse(updateAvailable)
    }

    func testReleaseVersionIdentifierFallsBackToFilenameForNonReleaseURLs() {
        let manager = makeManager()

        let version = manager.releaseVersionIdentifier(from: URL(string: "https://example.test/releases/full-new.zip")!)

        XCTAssertEqual(version, "full-new.zip")
    }

    func testPinnedSourceVariantsDoNotShareArchiveReceipt() throws {
        let manager = makeManager()
        let variants = try XCTUnwrap(
            manager.downloadableEntry(for: "wanxiang")?.distribution?.manifest.sourceVariants
        )

        XCTAssertEqual(variants.count, 2)
        XCTAssertNotEqual(variants[0].archiveSHA256, variants[1].archiveSHA256)
        XCTAssertNotEqual(variants[0].expectedByteCount, variants[1].expectedByteCount)
    }

    func testStartDownloadAllowsCompletedStateForInstalledSchemaUpdates() {
        let manager = makeManager()
        manager.acceptLicense()
        manager.rimeIceDownloadState = .completed(schemeName: "雾凇拼音")

        manager.startDownload()

        XCTAssertEqual(
            manager.rimeIceDownloadState,
            .fetchingReleaseInfo(schemeName: "雾凇拼音")
        )
    }

    func testForceRedownloadPreservesLastVerifiedReceiptUntilReplacementSucceeds() {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_ice_etag": "old-etag",
                "rime_ice_version": "old-version",
            ]
        )
        let installer = StubSchemaArchiveInstaller()
        let manager = makeManager(settings: settings, installer: installer)
        manager.acceptLicense()
        manager.rimeIceDownloadState = .completed(schemeName: "雾凇拼音")

        manager.forceRedownload()

        XCTAssertEqual(
            manager.rimeIceDownloadState,
            .fetchingReleaseInfo(schemeName: "雾凇拼音")
        )
        XCTAssertEqual(settings.string(forKey: "rime_ice_etag"), "old-etag")
        XCTAssertEqual(settings.string(forKey: "rime_ice_version"), "old-version")
        XCTAssertTrue(installer.didClearBuildCache)
    }

    func testDownloadSchemeDisplayNameUsesCatalogName() {
        let manager = makeManager()
        XCTAssertEqual(manager.downloadSchemeDisplayName(for: "rime_ice"), "雾凇拼音")
        XCTAssertEqual(manager.downloadSchemeDisplayName(for: "wanxiang"), "万象拼音")
    }

    func testDownloadToastMessagesUseSchemeNameAndIndeterminateProgress() {
        let wanxiangDownloading = AppOperationToastState(
            downloadState: .downloading(schemeName: "万象拼音", sourceName: "CNB", progress: nil)
        )
        XCTAssertEqual(wanxiangDownloading?.message, "正在通过 CNB 下载万象拼音…")
        XCTAssertFalse(wanxiangDownloading?.message.contains("0%") == true)

        let fogProgress = AppOperationToastState(
            downloadState: .downloading(schemeName: "雾凇拼音", sourceName: "南京大学镜像", progress: 0.42)
        )
        XCTAssertEqual(fogProgress?.message, "正在通过 南京大学镜像 下载雾凇拼音 42%")

        let completed = AppOperationToastState(
            downloadState: .completed(schemeName: "万象拼音")
        )
        XCTAssertEqual(completed?.message, "万象拼音已下载并部署")
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
        XCTAssertEqual(request.runtimeSmokeSchemaID, "luna_pinyin")
        XCTAssertEqual(installer.deploymentDirectoriesCallCount, 1)
        XCTAssertTrue(settings.bool(forKey: "rime_deployed"))
        XCTAssertFalse(settings.bool(forKey: "rime_needs_deploy"))
        XCTAssertFalse(settings.bool(forKey: "rime_deploying"))
        XCTAssertFalse(settings.bool(forKey: RimeFuzzyPinyinSettings.pendingDeployKey))
        XCTAssertFalse(settings.bool(forKey: RimeUserDictionarySettings.pendingDeployKey))
        XCTAssertFalse(settings.bool(forKey: RimeAdvancedInputSettings.pendingDeployKey))
        XCTAssertEqual(
            settings.string(forKey: RimeFuzzyPinyinSettings.deployedSignatureKey),
            RimeFuzzyPinyinSettings().deploymentSignature(activeSchemaID: "all")
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

    func testDeploymentForwardsOnlyActiveWanxiangSchemaToSmoke() async {
        let settings = StubSharedSettingsStore(
            values: ["rime_active_schema": "wanxiang", "rime_needs_deploy": true]
        )
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: StubSchemaArchiveInstaller(),
            deploymentService: deploymentService
        )

        await manager.deployRimeConfig()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.runtimeSmokeSchemaID, "wanxiang")
    }

    func testExplicitLuaSmokeFailureCannotBeMaskedByDeployedFlag() throws {
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
                "rime_ice_lua_smoke_passed": false,
            ]
        )
        let manager = makeManager(
            settings: settings,
            installer: StubSchemaArchiveInstaller(
                containsInstalledSchema: true,
                directories: SchemaDeploymentDirectories(
                    sharedDataURL: fixture.sharedURL,
                    userDataURL: fixture.userURL
                )
            )
        )

        XCTAssertEqual(manager.rimeIceLuaCapabilityDiagnostic().status, .needsDeploy)
    }

    func testLayoutReadPathsNeverPrepareDeploymentResources() {
        let settings = StubSharedSettingsStore()
        let installer = StubSchemaArchiveInstaller()
        let manager = makeManager(settings: settings, installer: installer)

        _ = manager.currentT9ReadinessMatched()
        _ = manager.schemeBinding26()
        _ = manager.schemeBinding9()

        XCTAssertEqual(installer.deploymentDirectoriesCallCount, 0)
        XCTAssertGreaterThan(installer.runtimeDirectoriesCallCount, 0)
    }

    func testDeploymentAppliesFuzzyPinyinToDownloadableSchemaAndPreservesOfficialLuna() async throws {
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
        try schemaYaml.write(
            to: sharedURL.appendingPathComponent("rime_ice.schema.yaml"), atomically: true, encoding: .utf8)
        try schemaYaml.write(
            to: sharedURL.appendingPathComponent("luna_pinyin.schema.yaml"), atomically: true, encoding: .utf8)

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

        let activeSchema = try String(
            contentsOf: sharedURL.appendingPathComponent("rime_ice.schema.yaml"), encoding: .utf8)
        let otherSchema = try String(
            contentsOf: sharedURL.appendingPathComponent("luna_pinyin.schema.yaml"), encoding: .utf8)
        XCTAssertTrue(activeSchema.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
        XCTAssertTrue(activeSchema.contains("- derive/^zh/z/"))
        XCTAssertFalse(activeSchema.contains("- derive/^ch/c/"))
        // Official Luna is immutable source material. Its managed fuzzy rules
        // are delivered by luna_pinyin.custom.yaml, tested in RimeBridge.
        XCTAssertEqual(otherSchema, schemaYaml)
        XCTAssertEqual(
            settings.string(forKey: RimeFuzzyPinyinSettings.deployedSignatureKey),
            RimeFuzzyPinyinSettings(
                enabled: true,
                zhZEnabled: true,
                chCEnabled: false,
                shSEnabled: false,
                nLEnabled: false
            ).deploymentSignature(activeSchemaID: "all")
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

    func testDeploymentDoesNotMutateOfficialLunaWhenFuzzyPinyinIsDisabled() async throws {
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
        XCTAssertEqual(schema, schemaYaml)
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

    func testArchiveDigestMismatchCleansExactArtifactBeforePinnedFallback() async throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let sources = try XCTUnwrap(entry.distribution?.manifest.sourceVariants)
        let operationID = UUID()
        let registry = SchemaTemporaryArtifactRegistry()
        let downloader = ControlledArchiveDownloader(registry: registry)
        let cleaner = RecordingTemporaryCleaner(registry: registry)
        let diagnostics = RecordingDeliveryDiagnostics()
        let manager = makeManager(
            archiveDownloader: downloader,
            artifactVerifier: SourceControlledArtifactVerifier(
                failingDigestSourceIDs: [sources[0].id]
            ),
            temporaryArtifactCleaner: cleaner,
            deliveryDiagnostics: diagnostics
        )
        manager.activeDownloadOperationID = operationID

        let result = try await manager.downloadFirstValidArchive(
            from: sources,
            schemeName: entry.name,
            operationID: operationID,
            diagnosticContext: nil
        )

        XCTAssertEqual(result.source.id, sources[1].id)
        let requestedSourceIDs = downloader.requestedSourceIDs()
        XCTAssertEqual(requestedSourceIDs, sources.map(\.id))
        let registered = downloader.registeredArtifacts()
        XCTAssertEqual(registered.count, 2)
        let removed = await cleaner.removedArtifacts()
        XCTAssertEqual(removed, [registered[0]])
        XCTAssertEqual(removed[0].sourceID, sources[0].id)
        XCTAssertEqual(removed[0].operationID, operationID)
        XCTAssertEqual(removed[0].artifactID, registered[0].artifactID)
        XCTAssertFalse(FileManager.default.fileExists(atPath: registered[0].localURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: registered[1].localURL.path))
    }

    func testArchiveSizeMismatchCleansExactRegisteredArtifactBeforePinnedFallback() async throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let sources = try XCTUnwrap(entry.distribution?.manifest.sourceVariants)
        let operationID = UUID()
        let registry = SchemaTemporaryArtifactRegistry()
        let downloader = ControlledArchiveDownloader(registry: registry)
        let cleaner = RecordingTemporaryCleaner(registry: registry)
        let manager = makeManager(
            archiveDownloader: downloader,
            artifactVerifier: SourceControlledArtifactVerifier(
                failingSizeSourceIDs: [sources[0].id]
            ),
            temporaryArtifactCleaner: cleaner
        )
        manager.activeDownloadOperationID = operationID

        let result = try await manager.downloadFirstValidArchive(
            from: sources,
            schemeName: entry.name,
            operationID: operationID,
            diagnosticContext: nil
        )

        XCTAssertEqual(result.source.id, sources[1].id)
        let registered = downloader.registeredArtifacts()
        let removed = await cleaner.removedArtifacts()
        XCTAssertEqual(removed, [registered[0]])
        XCTAssertEqual(downloader.requestedSourceIDs(), sources.map(\.id))
    }

    func testAllArchiveIntegrityFailuresStopAfterCleaningEachRegisteredArtifact() async throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let sources = try XCTUnwrap(entry.distribution?.manifest.sourceVariants)
        let operationID = UUID()
        let registry = SchemaTemporaryArtifactRegistry()
        let downloader = ControlledArchiveDownloader(registry: registry)
        let cleaner = RecordingTemporaryCleaner(registry: registry)
        let manager = makeManager(
            archiveDownloader: downloader,
            artifactVerifier: SourceControlledArtifactVerifier(
                failingDigestSourceIDs: Set(sources.map(\.id))
            ),
            temporaryArtifactCleaner: cleaner
        )
        manager.activeDownloadOperationID = operationID

        do {
            _ = try await manager.downloadFirstValidArchive(
                from: sources,
                schemeName: entry.name,
                operationID: operationID,
                diagnosticContext: nil
            )
            XCTFail("exhausted archive integrity failures must stop")
        } catch {
            guard
                case DownloadError.allSourcesFailedIntegrity(.archiveDigest)? =
                    error as? DownloadError
            else {
                XCTFail("unexpected error: \(error)")
                return
            }
        }
        XCTAssertEqual(downloader.requestedSourceIDs(), sources.map(\.id))
        let removed = await cleaner.removedArtifacts()
        XCTAssertEqual(removed, downloader.registeredArtifacts())
    }

    func testMixedArchiveIntegrityFailuresUseAggregateClassification() async throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let sources = try XCTUnwrap(entry.distribution?.manifest.sourceVariants)
        let operationID = UUID()
        let registry = SchemaTemporaryArtifactRegistry()
        let downloader = ControlledArchiveDownloader(registry: registry)
        let manager = makeManager(
            archiveDownloader: downloader,
            artifactVerifier: SourceControlledArtifactVerifier(
                failingSizeSourceIDs: [sources[0].id],
                failingDigestSourceIDs: [sources[1].id]
            ),
            temporaryArtifactCleaner: FileSystemSchemaTemporaryArtifactCleaner(
                registry: registry
            )
        )
        manager.activeDownloadOperationID = operationID

        do {
            _ = try await manager.downloadFirstValidArchive(
                from: sources,
                schemeName: entry.name,
                operationID: operationID,
                diagnosticContext: nil
            )
            XCTFail("mixed integrity failures must stop with an aggregate classification")
        } catch {
            XCTAssertEqual(error as? DownloadError, .allSourcesFailedIntegrity(.mixed))
        }
    }

    func testStaleCleanupReceiptStopsFallbackWithoutRequestingNextSource() async throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let sources = try XCTUnwrap(entry.distribution?.manifest.sourceVariants)
        let operationID = UUID()
        let registry = SchemaTemporaryArtifactRegistry()
        let downloader = ControlledArchiveDownloader(registry: registry)
        let manager = makeManager(
            archiveDownloader: downloader,
            artifactVerifier: SourceControlledArtifactVerifier(
                failingDigestSourceIDs: [sources[0].id]
            ),
            temporaryArtifactCleaner: StaleReceiptTemporaryCleaner(registry: registry)
        )
        manager.activeDownloadOperationID = operationID

        do {
            _ = try await manager.downloadFirstValidArchive(
                from: sources,
                schemeName: entry.name,
                operationID: operationID,
                diagnosticContext: nil
            )
            XCTFail("stale cleanup receipt must stop fallback")
        } catch {
            XCTAssertEqual(error as? DownloadError, .temporaryCleanupFailed)
        }
        XCTAssertEqual(downloader.requestedSourceIDs(), [sources[0].id])
    }

    func testDisabledDiagnosticsDoNotChangeArchiveFallback() async throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let manifest = try XCTUnwrap(entry.distribution?.manifest)
        let sources = manifest.sourceVariants
        let operationID = UUID()
        let identity = try manifest.resolvedStagedIdentity(for: sources[0])
        let context = try XCTUnwrap(
            SchemeDeliveryDiagnosticMapper.context(operationID: operationID, identity: identity)
        )
        let recordingRegistry = SchemaTemporaryArtifactRegistry()
        let droppingRegistry = SchemaTemporaryArtifactRegistry()
        let recordingDownloader = ControlledArchiveDownloader(
            registry: recordingRegistry
        )
        let droppingDownloader = ControlledArchiveDownloader(
            registry: droppingRegistry
        )
        let recordingDiagnostics = RecordingDeliveryDiagnostics()
        let recordingManager = makeManager(
            archiveDownloader: recordingDownloader,
            artifactVerifier: SourceControlledArtifactVerifier(
                failingDigestSourceIDs: [sources[0].id]
            ),
            temporaryArtifactCleaner: FileSystemSchemaTemporaryArtifactCleaner(
                registry: recordingRegistry
            ),
            deliveryDiagnostics: recordingDiagnostics
        )
        let droppingManager = makeManager(
            archiveDownloader: droppingDownloader,
            artifactVerifier: SourceControlledArtifactVerifier(
                failingDigestSourceIDs: [sources[0].id]
            ),
            temporaryArtifactCleaner: FileSystemSchemaTemporaryArtifactCleaner(
                registry: droppingRegistry
            ),
            deliveryDiagnostics: DroppingDeliveryDiagnostics()
        )
        recordingManager.activeDownloadOperationID = operationID
        droppingManager.activeDownloadOperationID = operationID

        let recorded = try await recordingManager.downloadFirstValidArchive(
            from: sources,
            schemeName: entry.name,
            operationID: operationID,
            diagnosticContext: context
        )
        let dropped = try await droppingManager.downloadFirstValidArchive(
            from: sources,
            schemeName: entry.name,
            operationID: operationID,
            diagnosticContext: context
        )

        XCTAssertFalse(recordingDiagnostics.recordedPayloads().isEmpty)
        XCTAssertTrue(
            recordingDiagnostics.recordedPayloads().contains {
                guard case .phaseChanged(let event) = $0 else { return false }
                return event.phase == .downloading && event.result == .started
            }
        )
        XCTAssertEqual(recorded.source.id, dropped.source.id)
        XCTAssertEqual(
            recordingDownloader.requestedSourceIDs(),
            droppingDownloader.requestedSourceIDs()
        )
    }

    func testCleanupFailureStopsIntegrityFallback() async throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let sources = try XCTUnwrap(entry.distribution?.manifest.sourceVariants)
        let operationID = UUID()
        let downloader = ControlledArchiveDownloader()
        let manager = makeManager(
            archiveDownloader: downloader,
            artifactVerifier: SourceControlledArtifactVerifier(
                failingDigestSourceIDs: [sources[0].id]
            ),
            temporaryArtifactCleaner: FailingTemporaryCleaner()
        )
        manager.activeDownloadOperationID = operationID

        do {
            _ = try await manager.downloadFirstValidArchive(
                from: sources,
                schemeName: entry.name,
                operationID: operationID,
                diagnosticContext: nil
            )
            XCTFail("cleanup failure must stop fallback")
        } catch {
            XCTAssertEqual(error as? DownloadError, .temporaryCleanupFailed)
        }
        let requestedSourceIDs = downloader.requestedSourceIDs()
        XCTAssertEqual(requestedSourceIDs, [sources[0].id])
    }

    func testCancellationAfterCleanupDoesNotRequestFallbackSource() async throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let sources = try XCTUnwrap(entry.distribution?.manifest.sourceVariants)
        let operationID = UUID()
        let registry = SchemaTemporaryArtifactRegistry()
        let downloader = ControlledArchiveDownloader(registry: registry)
        let manager = makeManager(
            archiveDownloader: downloader,
            artifactVerifier: SourceControlledArtifactVerifier(
                failingDigestSourceIDs: [sources[0].id]
            ),
            temporaryArtifactCleaner: CancellingTemporaryCleaner(registry: registry)
        )
        manager.activeDownloadOperationID = operationID

        do {
            _ = try await manager.downloadFirstValidArchive(
                from: sources,
                schemeName: entry.name,
                operationID: operationID,
                diagnosticContext: nil
            )
            XCTFail("cancellation after cleanup must stop fallback")
        } catch is CancellationError {
        } catch {
            XCTFail("unexpected error: \(error)")
        }

        XCTAssertEqual(downloader.requestedSourceIDs(), [sources[0].id])
    }

    func testTransportFailureRecordsFallbackToNextPinnedSource() async throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let manifest = try XCTUnwrap(entry.distribution?.manifest)
        let sources = manifest.sourceVariants
        let operationID = UUID()
        let downloader = ControlledArchiveDownloader(failingSourceIDs: [sources[0].id])
        let diagnostics = RecordingDeliveryDiagnostics()
        let identity = try manifest.resolvedStagedIdentity(for: sources[0])
        let context = try XCTUnwrap(
            SchemeDeliveryDiagnosticMapper.context(operationID: operationID, identity: identity)
        )
        let manager = makeManager(
            archiveDownloader: downloader,
            artifactVerifier: SourceControlledArtifactVerifier(),
            deliveryDiagnostics: diagnostics
        )
        manager.activeDownloadOperationID = operationID

        let result = try await manager.downloadFirstValidArchive(
            from: sources,
            schemeName: entry.name,
            operationID: operationID,
            diagnosticContext: context
        )

        XCTAssertEqual(result.source.id, sources[1].id)
        XCTAssertTrue(
            diagnostics.recordedPayloads().contains {
                guard case .fallback(let event) = $0 else { return false }
                return event.reason == .transport
                    && event.from.rawValue == sources[0].id
                    && event.to.rawValue == sources[1].id
            }
        )
    }

    func testCommitLeaseCoalescesMutationsAndAppliesThemAfterRelease() async {
        let settings = StubSharedSettingsStore()
        let manager = makeManager(settings: settings)
        let operationID = UUID()

        let acquired = await manager.acquireSchemeDeliveryCommitLease(operationID: operationID)
        XCTAssertTrue(acquired)
        manager.switchToSchema("rime_ice")
        manager.switchToSchema("wanxiang")
        manager.requestDeploy()
        manager.requestDeploy()

        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
        XCTAssertFalse(settings.bool(forKey: "rime_needs_deploy"))
        XCTAssertEqual(
            manager.queuedSchemeMutationIntents,
            [.switchSchema("wanxiang"), .requestDeploy]
        )

        manager.releaseSchemeDeliveryCommitLease(operationID: operationID)

        XCTAssertEqual(manager.activeSchemaID, "wanxiang")
        XCTAssertTrue(settings.bool(forKey: "rime_needs_deploy"))
        XCTAssertTrue(manager.queuedSchemeMutationIntents.isEmpty)
    }

    func testCancellationCannotInterruptOwnedCommitLease() async {
        let manager = makeManager()
        let operationID = UUID()
        manager.activeDownloadOperationID = operationID
        manager.rimeIceDownloadState = .deploying(schemeName: "万象拼音")

        let acquired = await manager.acquireSchemeDeliveryCommitLease(operationID: operationID)
        XCTAssertTrue(acquired)
        manager.cancelDownload()

        XCTAssertEqual(manager.activeDownloadOperationID, operationID)
        XCTAssertEqual(manager.rimeIceDownloadState, .deploying(schemeName: "万象拼音"))
        XCTAssertTrue(manager.deferredDownloadCancellationRequested)

        manager.releaseSchemeDeliveryCommitLease(operationID: operationID)

        XCTAssertEqual(manager.activeDownloadOperationID, operationID)
        XCTAssertFalse(manager.deferredDownloadCancellationRequested)
    }

    func testCommitLeaseCoalescesConcurrentDeploymentWaiters() async {
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(deploymentService: deploymentService)
        let operationID = UUID()
        let acquired = await manager.acquireSchemeDeliveryCommitLease(operationID: operationID)
        XCTAssertTrue(acquired)

        let first = Task { @MainActor in await manager.deployRimeConfig() }
        let second = Task { @MainActor in await manager.deployRimeConfig() }
        await Task.yield()
        let requestsBeforeRelease = await deploymentService.requests
        XCTAssertTrue(requestsBeforeRelease.isEmpty)

        manager.releaseSchemeDeliveryCommitLease(operationID: operationID)

        let firstResult = await first.value
        let secondResult = await second.value
        XCTAssertTrue(firstResult)
        XCTAssertTrue(secondResult)
        let requestsAfterRelease = await deploymentService.requests
        XCTAssertEqual(requestsAfterRelease.count, 1)
    }

    func testCommitLeaseKeepsOnlyLatestDeferredDownloadIntent() async {
        let manager = makeManager()
        let operationID = UUID()
        let acquired = await manager.acquireSchemeDeliveryCommitLease(operationID: operationID)
        XCTAssertTrue(acquired)

        manager.enqueueSchemeMutation(.startDownload(schemaID: "rime_ice", force: false))
        manager.enqueueSchemeMutation(.startDownload(schemaID: "wanxiang", force: true))

        XCTAssertEqual(
            manager.queuedSchemeMutationIntents,
            [.startDownload(schemaID: "wanxiang", force: true)]
        )
    }

    func testInvalidDeferredDownloadDoesNotStrandDeploymentWaiter() async {
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(deploymentService: deploymentService)
        let operationID = UUID()
        let acquired = await manager.acquireSchemeDeliveryCommitLease(operationID: operationID)
        XCTAssertTrue(acquired)

        let waiter = Task { @MainActor in await manager.deployRimeConfig() }
        await Task.yield()
        manager.enqueueSchemeMutation(.startDownload(schemaID: "missing", force: false))
        manager.releaseSchemeDeliveryCommitLease(operationID: operationID)

        let waiterResult = await waiter.value
        XCTAssertTrue(waiterResult)
        guard case .failed(let name, _) = manager.rimeIceDownloadState else {
            return XCTFail("invalid deferred download must publish a recoverable failure")
        }
        XCTAssertEqual(name, "missing")
        let requestCount = await deploymentService.requests.count
        XCTAssertEqual(requestCount, 1)
    }

    func testGenerationInvalidationAfterLeaseWaitRollsBackLease() async {
        let manager = makeManager()
        let foreignOperationID = UUID()
        let downloadOperationID = UUID()
        let foreignLeaseAcquired = await manager.acquireSchemeDeliveryCommitLease(
            operationID: foreignOperationID
        )
        XCTAssertTrue(foreignLeaseAcquired)
        manager.activeDownloadOperationID = downloadOperationID

        let attempt = Task { @MainActor in
            do {
                try await manager.acquireActiveSchemeDeliveryCommitLease(
                    operationID: downloadOperationID
                )
                return false
            } catch is CancellationError {
                return true
            } catch {
                return false
            }
        }
        await Task.yield()
        XCTAssertEqual(manager.schemeDeliveryCommitLeaseAvailabilityWaiterCount, 1)

        manager.activeDownloadOperationID = nil
        manager.releaseSchemeDeliveryCommitLease(operationID: foreignOperationID)

        let cancelled = await attempt.value
        XCTAssertTrue(cancelled)
        XCTAssertNil(manager.schemeDeliveryCommitLeaseOperationID)
        XCTAssertEqual(manager.schemeDeliveryCommitLeaseAvailabilityWaiterCount, 0)

        let recoveryOperationID = UUID()
        let recoveryLeaseAcquired = await manager.acquireSchemeDeliveryCommitLease(
            operationID: recoveryOperationID
        )
        XCTAssertTrue(recoveryLeaseAcquired)
        manager.releaseSchemeDeliveryCommitLease(operationID: recoveryOperationID)
    }

    func testCancelledCommitLeaseAttemptDoesNotRegisterAvailabilityWaiter() async {
        let manager = makeManager()
        let blockingOperationID = UUID()
        let acquired = await manager.acquireSchemeDeliveryCommitLease(
            operationID: blockingOperationID
        )
        XCTAssertTrue(acquired)

        let cancelledOperationID = UUID()
        let attempt = Task { @MainActor in
            await manager.acquireSchemeDeliveryCommitLease(operationID: cancelledOperationID)
        }
        // The task has not yielded from this MainActor test yet, so this
        // deterministically exercises cancellation before waiter registration.
        attempt.cancel()

        let cancelledAttemptAcquired = await attempt.value
        XCTAssertFalse(cancelledAttemptAcquired)
        XCTAssertEqual(manager.schemeDeliveryCommitLeaseAvailabilityWaiterCount, 0)
        XCTAssertEqual(manager.schemeDeliveryCommitLeaseOperationID, blockingOperationID)

        manager.releaseSchemeDeliveryCommitLease(operationID: blockingOperationID)
    }

    private func makeManager(
        settings: StubSharedSettingsStore = StubSharedSettingsStore(),
        sourceSelector: any SchemaSourceSelecting = StubSchemaSourceSelector(),
        archiveDownloader: any SchemaArchiveDownloading = StubSchemaArchiveDownloader(),
        artifactVerifier: any SchemaArtifactVerifying = SchemaArtifactVerifier(),
        temporaryArtifactCleaner: any SchemaTemporaryArtifactCleaning =
            FileSystemSchemaTemporaryArtifactCleaner(),
        deliveryDiagnostics: any SchemaDeliveryDiagnosing = RecordingDeliveryDiagnostics(),
        installer: StubSchemaArchiveInstaller = StubSchemaArchiveInstaller(),
        deploymentService: any RimeDeploymentServicing = StubDeploymentService(succeeded: true)
    ) -> SchemaManager {
        SchemaManager(
            settings: settings,
            sourceSelector: sourceSelector,
            archiveDownloader: archiveDownloader,
            artifactVerifier: artifactVerifier,
            temporaryArtifactCleaner: temporaryArtifactCleaner,
            deliveryDiagnostics: deliveryDiagnostics,
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
private final class ControlledArchiveDownloader: SchemaArchiveDownloading {
    private var sourceIDs: [String] = []
    private var registered: [SchemaOwnedTemporaryArtifact] = []
    private let failingSourceIDs: Set<String>
    private let registry: SchemaTemporaryArtifactRegistry?

    init(
        failingSourceIDs: Set<String> = [],
        registry: SchemaTemporaryArtifactRegistry? = nil
    ) {
        self.failingSourceIDs = failingSourceIDs
        self.registry = registry
    }

    func downloadArchive(
        from source: RimeSchemeSourceVariant,
        operationID: UUID,
        attemptID: UUID,
        onProgress: (@Sendable (Double?) -> Void)?
    ) async throws -> DownloadedSchemaArchive {
        sourceIDs.append(source.id)
        if failingSourceIDs.contains(source.id) {
            throw URLError(.notConnectedToInternet)
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("controlled-download-\(UUID().uuidString).zip")
        try Data("fixture".utf8).write(to: url)
        let archive = DownloadedSchemaArchive(
            localURL: url,
            expectedContentLength: source.expectedByteCount,
            operationID: operationID,
            attemptID: attemptID,
            sourceID: source.id,
            artifactID: UUID(),
            finalHost: source.downloadURL.host ?? "github.com"
        )
        if let registry {
            try await registry.register(archive.ownedTemporaryArtifact)
        }
        registered.append(archive.ownedTemporaryArtifact)
        return archive
    }

    func requestedSourceIDs() -> [String] { sourceIDs }
    func registeredArtifacts() -> [SchemaOwnedTemporaryArtifact] { registered }
}

nonisolated private struct SourceControlledArtifactVerifier: SchemaArtifactVerifying {
    let failingSizeSourceIDs: Set<String>
    let failingDigestSourceIDs: Set<String>

    init(
        failingSizeSourceIDs: Set<String> = [],
        failingDigestSourceIDs: Set<String> = []
    ) {
        self.failingSizeSourceIDs = failingSizeSourceIDs
        self.failingDigestSourceIDs = failingDigestSourceIDs
    }

    func verifyArchiveSize(at archiveURL: URL, source: RimeSchemeSourceVariant) throws {
        if failingSizeSourceIDs.contains(source.id) {
            throw DownloadError.integrityMismatch(
                .archiveSize(expected: source.expectedByteCount, actual: 1)
            )
        }
    }

    func verifyArchiveDigest(at archiveURL: URL, source: RimeSchemeSourceVariant) throws -> String {
        if failingDigestSourceIDs.contains(source.id) {
            throw DownloadError.integrityMismatch(
                .archiveDigest(
                    expected: source.archiveSHA256,
                    actual: String(repeating: "0", count: 64)
                )
            )
        }
        return source.archiveSHA256
    }

    func stagedContentSHA256(
        in extractionDirectory: URL,
        plan: RimeSchemeInstallationPlan,
        luaAvailable: Bool
    ) throws -> String { String(repeating: "0", count: 64) }
}

private actor RecordingTemporaryCleaner: SchemaTemporaryArtifactCleaning {
    private var artifacts: [SchemaOwnedTemporaryArtifact] = []
    private let delegate: FileSystemSchemaTemporaryArtifactCleaner

    init(registry: SchemaTemporaryArtifactRegistry) {
        delegate = FileSystemSchemaTemporaryArtifactCleaner(registry: registry)
    }

    func removeAndVerifyAbsent(_ artifact: SchemaOwnedTemporaryArtifact) async throws
        -> SchemaTemporaryCleanupReceipt
    {
        artifacts.append(artifact)
        return try await delegate.removeAndVerifyAbsent(artifact)
    }

    func removedArtifacts() -> [SchemaOwnedTemporaryArtifact] { artifacts }
}

nonisolated private struct CancellingTemporaryCleaner: SchemaTemporaryArtifactCleaning {
    let delegate: FileSystemSchemaTemporaryArtifactCleaner

    init(registry: SchemaTemporaryArtifactRegistry) {
        delegate = FileSystemSchemaTemporaryArtifactCleaner(registry: registry)
    }

    func removeAndVerifyAbsent(_ artifact: SchemaOwnedTemporaryArtifact) async throws
        -> SchemaTemporaryCleanupReceipt
    {
        let receipt = try await delegate.removeAndVerifyAbsent(artifact)
        withUnsafeCurrentTask { $0?.cancel() }
        return receipt
    }
}

nonisolated private struct FailingTemporaryCleaner: SchemaTemporaryArtifactCleaning {
    func removeAndVerifyAbsent(_ artifact: SchemaOwnedTemporaryArtifact) async throws
        -> SchemaTemporaryCleanupReceipt
    {
        throw DownloadError.temporaryCleanupFailed
    }
}

/// Cleans a different registered artifact so the returned receipt cannot prove
/// removal of the downloader's current attempt.
nonisolated private struct StaleReceiptTemporaryCleaner: SchemaTemporaryArtifactCleaning {
    let registry: SchemaTemporaryArtifactRegistry
    let delegate: FileSystemSchemaTemporaryArtifactCleaner

    init(registry: SchemaTemporaryArtifactRegistry) {
        self.registry = registry
        delegate = FileSystemSchemaTemporaryArtifactCleaner(registry: registry)
    }

    func removeAndVerifyAbsent(_ artifact: SchemaOwnedTemporaryArtifact) async throws
        -> SchemaTemporaryCleanupReceipt
    {
        let decoyURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("stale-receipt-\(UUID().uuidString).zip")
        try Data("stale".utf8).write(to: decoyURL)
        let decoy = SchemaOwnedTemporaryArtifact(
            operationID: artifact.operationID,
            attemptID: UUID(),
            sourceID: artifact.sourceID,
            artifactID: UUID(),
            localURL: decoyURL
        )
        try await registry.register(decoy)
        return try await delegate.removeAndVerifyAbsent(decoy)
    }
}

nonisolated private struct DroppingDeliveryDiagnostics: SchemaDeliveryDiagnosing {
    func record(_ payload: DiagnosticEvent.SchemeDeliveryPayload) {}
}

nonisolated private final class RecordingDeliveryDiagnostics: SchemaDeliveryDiagnosing, Sendable {
    private let payloads = Mutex<[DiagnosticEvent.SchemeDeliveryPayload]>([])

    func record(_ payload: DiagnosticEvent.SchemeDeliveryPayload) {
        payloads.withLock { $0.append(payload) }
    }

    func recordedPayloads() -> [DiagnosticEvent.SchemeDeliveryPayload] {
        payloads.withLock { $0 }
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

nonisolated private struct StubSchemaSourceSelector: SchemaSourceSelecting {
    func selectSource(
        from variants: [RimeSchemeSourceVariant],
        preferredSourceID: String?
    ) async throws -> RimeSchemeSourceVariant {
        if let preferredSourceID, let preferred = variants.first(where: { $0.id == preferredSourceID }) {
            return preferred
        }
        guard let first = variants.first else { throw DownloadError.allSourcesUnavailable }
        return first
    }
}

@MainActor
private final class StubSchemaArchiveDownloader: SchemaArchiveDownloading {
    struct Request: Sendable {
        let source: RimeSchemeSourceVariant
    }

    private(set) var requests: [Request] = []

    func downloadArchive(
        from source: RimeSchemeSourceVariant,
        operationID: UUID,
        attemptID: UUID,
        onProgress: (@Sendable (Double?) -> Void)?
    ) async throws -> DownloadedSchemaArchive {
        requests.append(Request(source: source))
        onProgress?(1)
        return DownloadedSchemaArchive(
            localURL: URL(fileURLWithPath: "/tmp/\(UUID().uuidString).zip"),
            expectedContentLength: source.expectedByteCount,
            operationID: operationID,
            attemptID: attemptID,
            sourceID: source.id,
            artifactID: UUID(),
            finalHost: source.downloadURL.host ?? "github.com"
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
    private(set) var runtimeDirectoriesCallCount = 0
    private(set) var deploymentDirectoriesCallCount = 0

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
    func runtimeDirectories() throws -> SchemaDeploymentDirectories {
        runtimeDirectoriesCallCount += 1
        return directories
    }
    func deploymentDirectories() throws -> SchemaDeploymentDirectories {
        deploymentDirectoriesCallCount += 1
        return directories
    }
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
