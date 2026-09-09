import CryptoKit
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

    func testOpenCCCatalogRequiresLicenseAndPinnedAuthorsDocument() throws {
        let openCC = ThirdPartyLicenseCatalog.bundledComponents.first { $0.id == "opencc" }

        XCTAssertEqual(
            Set(openCC?.offlineDocuments.map(\.resourceName) ?? []),
            ["OPENCC-Apache-2.0", "OPENCC-AUTHORS"]
        )

        let authorsURL =
            Bundle.main.url(
                forResource: "OPENCC-AUTHORS",
                withExtension: "txt",
                subdirectory: "ThirdPartyLicenses"
            )
            ?? Bundle.main.url(forResource: "OPENCC-AUTHORS", withExtension: "txt")
        let resolvedAuthorsURL = try XCTUnwrap(authorsURL)
        let authorsData = try Data(contentsOf: resolvedAuthorsURL)

        XCTAssertEqual(authorsData.count, 277)
        XCTAssertEqual(
            SHA256.hash(data: authorsData).map { String(format: "%02x", $0) }.joined(),
            "cb34e252fa994679bcbfc8355581e821ceda44bd857875e2cfe15b7ec4eec006"
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

    func testLegacyNightlyInstallationOffersPinnedReleaseUpdate() async {
        let manager = makeManager(settings: StubSharedSettingsStore(values: ["rime_ice_version": "nightly"]))
        let updateAvailable = await manager.checkForUpdate(schemaID: "rime_ice")
        XCTAssertTrue(updateAvailable)
    }

    func testCheckForUpdateReportsCurrentPinnedVersion() async {
        let manager = makeManager(
            settings: StubSharedSettingsStore(values: ["rime_ice_version": "2026.06.30"])
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

    func testShouldSkipIdenticalReinstallWhenReceiptMatchesStagedContent() throws {
        let iceIdentity = try XCTUnwrap(
            RimeSchemeCatalog.entry(for: "rime_ice")?
                .distribution?
                .manifest
                .stagedIdentities
                .first
        )
        let stagedSHA = iceIdentity.stagedContentSHA256WithLua
        let settings = StubSharedSettingsStore(
            values: [
                "rime_ice_installed": true,
                "rime_ice_staged_content_checksum": stagedSHA,
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let manager = makeManager(settings: settings, installer: installer)

        XCTAssertTrue(
            manager.shouldSkipIdenticalReinstall(
                schemaID: "rime_ice",
                stagedContentSHA256: stagedSHA
            )
        )
        XCTAssertFalse(
            manager.shouldSkipIdenticalReinstall(
                schemaID: "rime_ice",
                stagedContentSHA256: iceIdentity.stagedContentSHA256WithoutLua
            ),
            "a different staged digest must not no-op"
        )
        XCTAssertFalse(
            manager.shouldSkipIdenticalReinstall(
                schemaID: "rime_ice",
                stagedContentSHA256: ""
            )
        )
    }

    func testShouldSkipIdenticalReinstallRequiresInstalledSchemaPresence() throws {
        let wanxiangIdentity = try XCTUnwrap(
            RimeSchemeCatalog.entry(for: "wanxiang")?
                .distribution?
                .manifest
                .stagedIdentities
                .first
        )
        let stagedSHA = wanxiangIdentity.stagedContentSHA256WithLua
        let settings = StubSharedSettingsStore(
            values: [
                "wanxiang_installed": true,
                "wanxiang_staged_content_checksum": stagedSHA,
            ]
        )
        let missingInstaller = StubSchemaArchiveInstaller(containsInstalledSchema: false)
        let missingManager = makeManager(settings: settings, installer: missingInstaller)
        XCTAssertFalse(
            missingManager.shouldSkipIdenticalReinstall(
                schemaID: "wanxiang",
                stagedContentSHA256: stagedSHA
            ),
            "receipt alone is insufficient without on-disk schema presence"
        )

        let presentInstaller = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let presentManager = makeManager(settings: settings, installer: presentInstaller)
        XCTAssertTrue(
            presentManager.shouldSkipIdenticalReinstall(
                schemaID: "wanxiang",
                stagedContentSHA256: stagedSHA
            )
        )
    }

    /// CS-03 production-path proof: after verification, a matching receipt must
    /// finish without taking the lease, replacing live files, or deploying.
    func testFetchAndDownloadSkipsIdenticalIceReceiptBeforeLiveMutation() async throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("schema-manager-identical-receipt-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: rootURL) }

        let sharedURL = rootURL.appendingPathComponent("Rime/shared")
        let userURL = rootURL.appendingPathComponent("Rime/user")
        try FileManager.default.createDirectory(at: sharedURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userURL, withIntermediateDirectories: true)
        let liveSchemaURL = sharedURL.appendingPathComponent("rime_ice.schema.yaml")
        let liveSchemaBefore = Data("schema_id: retained-peer-safe-live-state\n".utf8)
        try liveSchemaBefore.write(to: liveSchemaURL)

        let identity = try XCTUnwrap(
            RimeSchemeCatalog.entry(for: "rime_ice")?
                .distribution?
                .manifest
                .stagedIdentities
                .first
        )
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                "rime_ice_installed": true,
                "rime_ice_staged_content_checksum": identity.stagedContentSHA256WithLua,
            ]
        )
        let installer = SharedContainerSchemaArchiveInstaller(
            appGroupID: "test.scheme-delivery",
            containerURL: rootURL
        )
        let downloader = FixtureArchiveDownloader()
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            archiveDownloader: downloader,
            artifactVerifier: FixedStagedContentVerifier(
                stagedContentSHA256: identity.stagedContentSHA256WithLua
            ),
            installer: installer,
            deploymentService: deploymentService
        )
        await manager.fetchAndDownload(schemaID: "rime_ice")

        XCTAssertEqual(manager.rimeIceDownloadState, .completed(schemeName: "雾凇拼音"))
        XCTAssertNil(manager.activeDownloadOperationID)
        XCTAssertNil(manager.schemeDeliveryCommitLeaseOperationID)
        XCTAssertEqual(manager.activeSchemaID, "wanxiang", "no-op must not thrash selection")
        XCTAssertEqual(try Data(contentsOf: liveSchemaURL), liveSchemaBefore)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: sharedURL.appendingPathComponent("rime_ice_preset.yaml").path
            ),
            "no-op must not replace the live resource tree"
        )
        let deploymentRequests = await deploymentService.requests
        XCTAssertTrue(
            deploymentRequests.isEmpty,
            "no-op must not deploy or activate the already-installed scheme"
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: try XCTUnwrap(downloader.downloadedURL()).path),
            "no-op must clean the verified temporary archive"
        )
    }

    /// CS-F1: a failed Ice deployment after install must not publish an Ice
    /// receipt or disturb the already-installed Wanxiang peer and selection.
    func testCSF1_IceDeployFailureWithWanxiangPeerKeepsPeerAndSkipsIceReceipt() async throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("schema-manager-csf1-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: rootURL) }

        let sharedURL = rootURL.appendingPathComponent("Rime/shared")
        let userURL = rootURL.appendingPathComponent("Rime/user")
        try FileManager.default.createDirectory(at: sharedURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userURL, withIntermediateDirectories: true)
        let wanxiangSchemaURL = sharedURL.appendingPathComponent("wanxiang.schema.yaml")
        let wanxiangSchemaBefore = Data("schema_id: wanxiang-peer-before-csf1\n".utf8)
        try wanxiangSchemaBefore.write(to: wanxiangSchemaURL)

        let identity = try XCTUnwrap(
            RimeSchemeCatalog.entry(for: "rime_ice")?
                .distribution?
                .manifest
                .stagedIdentities
                .first
        )
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            extractionDirectory: rootURL.appendingPathComponent("extract", isDirectory: true),
            installCopiesT9Fixture: true,
            directories: SchemaDeploymentDirectories(
                sharedDataURL: sharedURL,
                userDataURL: userURL
            )
        )
        let downloader = FixtureArchiveDownloader()
        let deploymentService = StubDeploymentService(results: [false, true])
        let manager = makeManager(
            settings: settings,
            archiveDownloader: downloader,
            artifactVerifier: FixedStagedContentVerifier(
                stagedContentSHA256: identity.stagedContentSHA256WithLua
            ),
            installer: installer,
            deploymentService: deploymentService
        )
        await manager.fetchAndDownload(schemaID: "rime_ice")

        XCTAssertNil(settings.object(forKey: "rime_ice_installed"))
        XCTAssertNil(settings.object(forKey: "rime_ice_version"))
        XCTAssertNil(settings.object(forKey: "rime_ice_checksum"))
        XCTAssertNil(settings.object(forKey: "rime_ice_staged_content_checksum"))
        XCTAssertNil(settings.object(forKey: "rime_ice_source_variant"))
        XCTAssertTrue(settings.bool(forKey: "wanxiang_installed"))
        XCTAssertEqual(settings.string(forKey: "wanxiang_version"), "17.5.9")
        XCTAssertEqual(try Data(contentsOf: wanxiangSchemaURL), wanxiangSchemaBefore)
        XCTAssertEqual(manager.activeSchemaID, "wanxiang")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "wanxiang")
        let deploymentRequests = await deploymentService.requests
        guard case .failed(_, _, let failureMessage) = manager.rimeIceDownloadState else {
            return XCTFail("expected a failed CS-F1 operation, got \(manager.rimeIceDownloadState)")
        }
        XCTAssertFalse(failureMessage.isEmpty)
        XCTAssertEqual(deploymentRequests.map(\.runtimeSmokeSchemaID), ["rime_ice"])
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: try XCTUnwrap(downloader.downloadedURL()).path),
            "failed install must clean the temporary archive"
        )
    }

    /// CS-F1 symmetry: a failed Wanxiang deployment must not publish its
    /// receipt or disturb the selected Ice peer.
    func testCSF1_WanxiangDeployFailureWithIcePeerKeepsPeerAndSkipsWanxiangReceipt() async throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("schema-manager-csf1-wanxiang-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: rootURL) }

        let sharedURL = rootURL.appendingPathComponent("Rime/shared")
        let userURL = rootURL.appendingPathComponent("Rime/user")
        try FileManager.default.createDirectory(at: sharedURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userURL, withIntermediateDirectories: true)
        let iceSchemaURL = sharedURL.appendingPathComponent("rime_ice.schema.yaml")
        let iceSchemaBefore = Data("schema_id: ice-peer-before-csf1\n".utf8)
        try iceSchemaBefore.write(to: iceSchemaURL)

        let identity = try XCTUnwrap(
            RimeSchemeCatalog.entry(for: "wanxiang")?
                .distribution?
                .manifest
                .stagedIdentities
                .first
        )
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_ice_version": "test-ice-version",
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            extractionDirectory: rootURL.appendingPathComponent("extract", isDirectory: true),
            installCopiesT9Fixture: true,
            directories: SchemaDeploymentDirectories(
                sharedDataURL: sharedURL,
                userDataURL: userURL
            )
        )
        let downloader = FixtureArchiveDownloader(schemaID: "wanxiang")
        let deploymentService = StubDeploymentService(succeeded: false)
        let manager = makeManager(
            settings: settings,
            archiveDownloader: downloader,
            artifactVerifier: FixedStagedContentVerifier(
                stagedContentSHA256: identity.stagedContentSHA256WithLua
            ),
            installer: installer,
            deploymentService: deploymentService
        )
        manager.acceptLicense(for: "wanxiang")

        await manager.fetchAndDownload(schemaID: "wanxiang")

        XCTAssertNil(settings.object(forKey: "wanxiang_installed"))
        XCTAssertNil(settings.object(forKey: "wanxiang_version"))
        XCTAssertNil(settings.object(forKey: "wanxiang_checksum"))
        XCTAssertNil(settings.object(forKey: "wanxiang_staged_content_checksum"))
        XCTAssertNil(settings.object(forKey: "wanxiang_source_variant"))
        XCTAssertTrue(settings.bool(forKey: "rime_ice_installed"))
        XCTAssertEqual(settings.string(forKey: "rime_ice_version"), "test-ice-version")
        XCTAssertEqual(try Data(contentsOf: iceSchemaURL), iceSchemaBefore)
        XCTAssertEqual(manager.activeSchemaID, "rime_ice")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "rime_ice")
        let deploymentRequests = await deploymentService.requests
        XCTAssertEqual(deploymentRequests.map(\.runtimeSmokeSchemaID), ["wanxiang"])
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: try XCTUnwrap(downloader.downloadedURL()).path),
            "failed install must clean the temporary archive"
        )
    }

    /// CS-F3 and CSF-PAIR-02: a real Ice staging rollback keeps Ice selected
    /// and restores both its owned files while preserving Wanxiang bytes.
    func testCSF3_ManagerIceStagingFailureRestoresSelectionAndWanxiangPeerFiles() async throws {
        let fixture = try makeCrossSchemeStagingFailureFixture(
            targetSchemaID: "rime_ice",
            peerSchemaID: "wanxiang",
            targetFiles: ["rime_ice.schema.yaml", "rime_ice.dict.yaml"],
            peerFile: "wanxiang.schema.yaml"
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        await fixture.manager.uninstallSchema("rime_ice")?.value

        XCTAssertEqual(fixture.manager.activeSchemaID, "rime_ice")
        XCTAssertEqual(fixture.settings.string(forKey: "rime_active_schema"), "rime_ice")
        XCTAssertTrue(fixture.settings.bool(forKey: "rime_ice_installed"))
        XCTAssertTrue(fixture.settings.bool(forKey: "wanxiang_installed"))
        for (url, data) in fixture.targetFilesBefore {
            XCTAssertEqual(try Data(contentsOf: url), data)
        }
        XCTAssertEqual(try Data(contentsOf: fixture.peerFileURL), fixture.peerFileBefore)
        let requests = await fixture.deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin", "rime_ice"])
    }

    /// CS-F3 symmetry: a real Wanxiang staging rollback restores its target
    /// files and selection without changing the Ice peer.
    func testCSF3_ManagerWanxiangStagingFailureRestoresSelectionAndIcePeerFiles() async throws {
        let fixture = try makeCrossSchemeStagingFailureFixture(
            targetSchemaID: "wanxiang",
            peerSchemaID: "rime_ice",
            targetFiles: ["wanxiang.schema.yaml", "wanxiang.dict.yaml"],
            peerFile: "rime_ice.schema.yaml"
        )
        defer { try? FileManager.default.removeItem(at: fixture.rootURL) }

        await fixture.manager.uninstallSchema("wanxiang")?.value

        XCTAssertEqual(fixture.manager.activeSchemaID, "wanxiang")
        XCTAssertEqual(fixture.settings.string(forKey: "rime_active_schema"), "wanxiang")
        XCTAssertTrue(fixture.settings.bool(forKey: "wanxiang_installed"))
        XCTAssertTrue(fixture.settings.bool(forKey: "rime_ice_installed"))
        for (url, data) in fixture.targetFilesBefore {
            XCTAssertEqual(try Data(contentsOf: url), data)
        }
        XCTAssertEqual(try Data(contentsOf: fixture.peerFileURL), fixture.peerFileBefore)
        let requests = await fixture.deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin", "wanxiang"])
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

        let failed = AppOperationToastState(
            downloadState: .failed(
                schemaID: "wanxiang",
                schemeName: "万象拼音",
                message: "网络不可用"
            )
        )
        XCTAssertEqual(failed?.message, "万象拼音下载或部署失败")
        XCTAssertEqual(failed?.source, .download)
        XCTAssertEqual(failed?.tone, .failure)
        XCTAssertTrue(failed?.automaticallyDismisses == true)
    }

    func testDownloadFailureBindsSchemaIDFromDownloadOperation() async throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let sourceIDs = try XCTUnwrap(
            entry.distribution?.manifest.sourceVariants.map(\.id)
        )
        let manager = makeManager(
            archiveDownloader: ControlledArchiveDownloader(failingSourceIDs: Set(sourceIDs))
        )
        manager.acceptLicense(for: "wanxiang")

        await manager.fetchAndDownload(schemaID: "wanxiang")

        guard case .failed(let schemaID, let schemeName, let message) = manager.rimeIceDownloadState else {
            return XCTFail("a failed download must retain its owning schema ID")
        }
        XCTAssertEqual(schemaID, "wanxiang")
        XCTAssertEqual(schemeName, "万象拼音")
        XCTAssertEqual(manager.rimeIceDownloadState.failureMessage(for: "wanxiang"), message)
        XCTAssertNil(manager.rimeIceDownloadState.failureMessage(for: "rime_ice"))
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

    func testActiveUninstallAwaitsLunaDeployBeforeCommittingFiles() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_ice_version": "test-version",
                "rime_ice_license_accepted": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let diagnostics = RecordingDeliveryDiagnostics()
        let manager = makeManager(
            settings: settings,
            deliveryDiagnostics: diagnostics,
            installer: installer,
            deploymentService: deploymentService
        )
        await deploymentService.setLeaseOwnerReader { @MainActor [weak manager] in
            manager?.schemeDeliveryCommitLeaseOperationID
        }

        let task = manager.uninstallRimeIce()
        await task?.value

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.runtimeSmokeSchemaID, "luna_pinyin")
        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertTrue(installer.didCommitUninstall)
        XCTAssertFalse(installer.didRollbackUninstall)
        XCTAssertNil(settings.object(forKey: "rime_ice_installed"))
        XCTAssertNil(settings.object(forKey: "rime_ice_version"))
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "luna_pinyin")
        guard
            let operationID = assertRuntimeRouteRecords(
                diagnostics.recordedRuntimeRouteRecords(),
                expected: [
                    "before:started", "fallback_deploy:started", "fallback_deploy:succeeded", "staging:started",
                    "commit:succeeded",
                ],
                failureIndexes: [],
                expectedRoutes: [
                    "rime_ice:26_key:ready", "luna_pinyin:26_key:ready", "luna_pinyin:26_key:ready",
                    "luna_pinyin:26_key:ready", "luna_pinyin:26_key:ready",
                ]
            )
        else { return }
        let owners = await deploymentService.observedLeaseOwners
        XCTAssertEqual(owners, [operationID])
    }

    func testActiveUninstallKeepsFilesAndRestoresSchemaWhenLunaDeployFails() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_ice_version": "test-version",
                "rime_ice_license_accepted": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: false)
        let diagnostics = RecordingDeliveryDiagnostics()
        let manager = makeManager(
            settings: settings,
            deliveryDiagnostics: diagnostics,
            installer: installer,
            deploymentService: deploymentService
        )
        await deploymentService.setLeaseOwnerReader { @MainActor [weak manager] in
            manager?.schemeDeliveryCommitLeaseOperationID
        }

        let task = manager.uninstallSchema("rime_ice")
        await task?.value

        XCTAssertFalse(installer.didStageUninstall)
        XCTAssertFalse(installer.didCommitUninstall)
        XCTAssertEqual(settings.bool(forKey: "rime_ice_installed"), true)
        XCTAssertEqual(settings.string(forKey: "rime_ice_version"), "test-version")
        XCTAssertEqual(manager.activeSchemaID, "rime_ice")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "rime_ice")
        let requests = await deploymentService.requests
        // Luna fallback attempt + fail-closed restore redeploy.
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(requests.first?.runtimeSmokeSchemaID, "luna_pinyin")
        XCTAssertEqual(requests.last?.runtimeSmokeSchemaID, "rime_ice")
        guard
            let operationID = assertRuntimeRouteRecords(
                diagnostics.recordedRuntimeRouteRecords(),
                expected: [
                    "before:started", "fallback_deploy:started", "fallback_deploy:failed", "rollback_deploy:started",
                    "rollback_deploy:failed",
                ],
                failureIndexes: [2, 4],
                expectedRoutes: [
                    "rime_ice:26_key:ready", "luna_pinyin:26_key:ready", "luna_pinyin:26_key:ready",
                    "rime_ice:26_key:ready", "rime_ice:26_key:ready",
                ]
            )
        else { return }
        let owners = await deploymentService.observedLeaseOwners
        XCTAssertEqual(owners, [operationID, operationID])
    }

    /// Q-UR-P2-01: manager-level deploy-failure injection for Wanxiang upgrade-rollback.
    /// Drives the production seam `deployInstalledUpgradeOrRestoreOnFailure` (shared with
    /// `fetchAndDownload`) after a prior-generation checkpoint + install mutation.
    func testWanxiangUpgradeRestoresPriorSelectionAndSkipsReceiptWhenDeployFails() async throws {
        let priorVersion = "17.5.9"
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "luna_pinyin",
                "wanxiang_installed": true,
                "wanxiang_version": priorVersion,
                "wanxiang_license_accepted": true,
                "wanxiang_checksum": "prior-archive-sha",
                "wanxiang_staged_content_checksum": "prior-staged-sha",
                "wanxiang_source_variant": "cnb",
            ]
        )
        let checkpoint = SchemaUpgradeCheckpoint(
            rootURL: URL(fileURLWithPath: "/test/schema-upgrade-checkpoint"),
            copiedRelativePaths: ["wanxiang.schema.yaml", "wanxiang.dict.yaml"]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            upgradeCheckpointToReturn: checkpoint
        )
        let deploymentService = StubDeploymentService(succeeded: false)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let plan = try XCTUnwrap(entry.installationPlan)

        // 1–2. Prior generation present → checkpoint + mutate/install (manager install seam).
        let created = try installer.createUpgradeCheckpoint(plan: plan, luaAvailable: true)
        XCTAssertEqual(created?.copiedRelativePaths, checkpoint.copiedRelativePaths)
        try installer.installSchemaFiles(
            from: URL(fileURLWithPath: "/test/extract"),
            plan: plan,
            luaAvailable: true
        )
        XCTAssertTrue(installer.didInstallSchemaFiles)

        // 3. Deploy fails via StubDeploymentService (same injection style as Luna uninstall).
        var liveCheckpoint: SchemaUpgradeCheckpoint? = checkpoint
        let deployed = await manager.deployInstalledUpgradeOrRestoreOnFailure(
            schemaID: "wanxiang",
            checkpoint: &liveCheckpoint,
            priorActiveSchemaID: "luna_pinyin"
        )

        // 4. Assert restore + prior selection + no new-version receipt.
        XCTAssertFalse(deployed)
        XCTAssertTrue(installer.didRestoreUpgradeCheckpoint)
        XCTAssertFalse(installer.didCommitUpgradeCheckpoint)
        XCTAssertNil(liveCheckpoint, "successful restore must clear the live checkpoint")
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "luna_pinyin")
        XCTAssertEqual(settings.string(forKey: "wanxiang_version"), priorVersion)
        XCTAssertEqual(settings.bool(forKey: "wanxiang_installed"), true)
        XCTAssertEqual(settings.string(forKey: "wanxiang_checksum"), "prior-archive-sha")
        XCTAssertEqual(settings.string(forKey: "wanxiang_staged_content_checksum"), "prior-staged-sha")
        XCTAssertEqual(settings.string(forKey: "wanxiang_source_variant"), "cnb")
        let requests = await deploymentService.requests
        XCTAssertFalse(requests.isEmpty, "deploy must have been attempted")
        XCTAssertEqual(requests.last?.runtimeSmokeSchemaID, "wanxiang")
    }

    func testActiveUninstallRestoresSchemaWhenStagingFailsAfterLunaDeploy() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_ice_version": "test-version",
                "rime_ice_license_accepted": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            stageUninstallError: DownloadError.postProcessingFailed("stage boom")
        )
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        let task = manager.uninstallSchema("rime_ice")
        await task?.value

        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertFalse(installer.didCommitUninstall)
        XCTAssertEqual(settings.bool(forKey: "rime_ice_installed"), true)
        XCTAssertEqual(settings.string(forKey: "rime_ice_version"), "test-version")
        XCTAssertEqual(manager.activeSchemaID, "rime_ice")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "rime_ice")
        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(requests.first?.runtimeSmokeSchemaID, "luna_pinyin")
        XCTAssertEqual(requests.last?.runtimeSmokeSchemaID, "rime_ice")
    }

    /// CS-07: active Ice removal always deploys stable builtin Luna first.
    /// Wanxiang remains installed but must not become an uninstall fallback.
    func testCS07_ActiveIceUninstallWithWanxiangPeerDeploysLunaBeforeRemovingIce() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_ice_version": "test-ice-version",
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.uninstallSchema("rime_ice")?.value

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin"])
        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertTrue(installer.didCommitUninstall)
        XCTAssertNil(settings.object(forKey: "rime_ice_installed"))
        XCTAssertTrue(settings.bool(forKey: "wanxiang_installed"))
        XCTAssertEqual(settings.string(forKey: "wanxiang_version"), "17.5.9")
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "luna_pinyin")
    }

    /// CS-08: active Wanxiang removal is symmetric and still uses Luna, never
    /// the retained Ice peer, as the deterministic fallback.
    func testCS08_ActiveWanxiangUninstallWithIcePeerDeploysLunaBeforeRemovingWanxiang() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                "rime_ice_installed": true,
                "rime_ice_version": "test-ice-version",
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.uninstallSchema("wanxiang")?.value

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin"])
        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertTrue(installer.didCommitUninstall)
        XCTAssertNil(settings.object(forKey: "wanxiang_installed"))
        XCTAssertTrue(settings.bool(forKey: "rime_ice_installed"))
        XCTAssertEqual(settings.string(forKey: "rime_ice_version"), "test-ice-version")
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "luna_pinyin")
    }

    /// CS09-10-02: a stored nine-key preference can be fail-closed to the
    /// 26-key Wanxiang binding. Removing Wanxiang must follow that effective
    /// route, not incorrectly classify the uninstall as inactive.
    func testActiveWanxiangUninstallUsesFailClosedTwentySixKeyRoute() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.nineKey.rawValue,
                KeyboardLayoutSettingsKey.schemeBinding26: "wanxiang",
                KeyboardLayoutSettingsKey.schemeBinding9: "t9",
                "rime_ice_installed": true,
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.uninstallSchema("wanxiang")?.value

        let requests = await deploymentService.requests
        XCTAssertEqual(
            requests.map(\.runtimeSmokeSchemaID),
            ["luna_pinyin"]
        )
        XCTAssertTrue(installer.didCommitUninstall)
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(
            settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            KeyboardLayoutStyle.twentySixKey.rawValue
        )
        XCTAssertEqual(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26), "luna_pinyin")
        XCTAssertEqual(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9), "t9")

        let resolved = RimeRuntimeSelection(
            baseSchemaID: manager.activeSchemaID,
            layoutStyle: .twentySixKey,
            t9ReadinessMatched: false,
            schemeBinding26: settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26),
            schemeBinding9: settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        )
        XCTAssertEqual(resolved.effectiveSchemaID, "luna_pinyin")
        XCTAssertEqual(resolved.effectiveLayoutStyle, .twentySixKey)
    }

    func testActiveWanxiangUninstallRestoresCompleteRouteStateWhenLunaDeployFails() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.nineKey.rawValue,
                KeyboardLayoutSettingsKey.schemeBinding26: "wanxiang",
                KeyboardLayoutSettingsKey.schemeBinding9: "t9",
                "rime_ice_installed": true,
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(results: [false, true])
        let diagnostics = RecordingDeliveryDiagnostics()
        let manager = makeManager(
            settings: settings,
            deliveryDiagnostics: diagnostics,
            installer: installer,
            deploymentService: deploymentService
        )
        await deploymentService.setLeaseOwnerReader { @MainActor [weak manager] in
            manager?.schemeDeliveryCommitLeaseOperationID
        }

        await manager.uninstallSchema("wanxiang")?.value

        let requests = await deploymentService.requests
        XCTAssertEqual(
            requests.map(\.runtimeSmokeSchemaID),
            ["luna_pinyin", "wanxiang"]
        )
        XCTAssertFalse(installer.didStageUninstall)
        XCTAssertFalse(installer.didCommitUninstall)
        XCTAssertEqual(manager.activeSchemaID, "wanxiang")
        XCTAssertEqual(
            settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            KeyboardLayoutStyle.nineKey.rawValue
        )
        XCTAssertEqual(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26), "wanxiang")
        XCTAssertEqual(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9), "t9")
        guard
            let operationID = assertRuntimeRouteRecords(
                diagnostics.recordedRuntimeRouteRecords(),
                expected: [
                    "before:started", "fallback_deploy:started", "fallback_deploy:failed", "rollback_deploy:started",
                    "rollback_deploy:succeeded",
                ],
                failureIndexes: [2],
                expectedRoutes: [
                    "wanxiang:26_key:fail_closed", "luna_pinyin:26_key:ready", "luna_pinyin:26_key:ready",
                    "wanxiang:26_key:fail_closed", "wanxiang:26_key:fail_closed",
                ]
            )
        else { return }
        let owners = await deploymentService.observedLeaseOwners
        XCTAssertEqual(owners, [operationID, operationID])
    }

    func testActiveWanxiangUninstallRestoresCompleteRouteStateWhenStagingFails() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.nineKey.rawValue,
                KeyboardLayoutSettingsKey.schemeBinding26: "wanxiang",
                KeyboardLayoutSettingsKey.schemeBinding9: "t9",
                "rime_ice_installed": true,
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            stageUninstallError: DownloadError.postProcessingFailed("stage boom")
        )
        let deploymentService = StubDeploymentService(succeeded: true)
        let diagnostics = RecordingDeliveryDiagnostics()
        let manager = makeManager(
            settings: settings,
            deliveryDiagnostics: diagnostics,
            installer: installer,
            deploymentService: deploymentService
        )
        await deploymentService.setLeaseOwnerReader { @MainActor [weak manager] in
            manager?.schemeDeliveryCommitLeaseOperationID
        }

        await manager.uninstallSchema("wanxiang")?.value

        let requests = await deploymentService.requests
        XCTAssertEqual(
            requests.map(\.runtimeSmokeSchemaID),
            ["luna_pinyin", "wanxiang"]
        )
        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertFalse(installer.didCommitUninstall)
        XCTAssertEqual(manager.activeSchemaID, "wanxiang")
        XCTAssertEqual(
            settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            KeyboardLayoutStyle.nineKey.rawValue
        )
        XCTAssertEqual(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26), "wanxiang")
        XCTAssertEqual(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9), "t9")
        guard
            let operationID = assertRuntimeRouteRecords(
                diagnostics.recordedRuntimeRouteRecords(),
                expected: [
                    "before:started", "fallback_deploy:started", "fallback_deploy:succeeded", "staging:started",
                    "staging:failed", "rollback_deploy:started", "rollback_deploy:succeeded",
                ],
                failureIndexes: [4],
                expectedRoutes: [
                    "wanxiang:26_key:fail_closed", "luna_pinyin:26_key:ready", "luna_pinyin:26_key:ready",
                    "luna_pinyin:26_key:ready", "luna_pinyin:26_key:ready", "wanxiang:26_key:fail_closed",
                    "wanxiang:26_key:fail_closed",
                ]
            )
        else { return }
        let owners = await deploymentService.observedLeaseOwners
        XCTAssertEqual(owners, [operationID, operationID])
    }

    /// CS-09: the last active downloaded Ice scheme uses the same fail-closed
    /// Luna path; a peer must not be required for the fallback to succeed.
    func testCS09_UninstallLastActiveIceDeploysLunaAndClearsIceReceipt() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_ice_version": "test-ice-version",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )
        await manager.uninstallSchema("rime_ice")?.value

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin"])
        XCTAssertFalse(installer.didInstallSchemaFiles)
        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertTrue(installer.didCommitUninstall)
        XCTAssertNil(settings.object(forKey: "rime_ice_installed"))
        XCTAssertNil(settings.object(forKey: "rime_ice_version"))
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "luna_pinyin")
    }

    /// CS-09: Wanxiang is symmetric when it is the only downloaded scheme.
    func testCS09_UninstallLastActiveWanxiangDeploysLunaAndClearsWanxiangReceipt() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.uninstallSchema("wanxiang")?.value

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin"])
        XCTAssertFalse(installer.didInstallSchemaFiles)
        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertTrue(installer.didCommitUninstall)
        XCTAssertNil(settings.object(forKey: "wanxiang_installed"))
        XCTAssertNil(settings.object(forKey: "wanxiang_version"))
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "luna_pinyin")
    }

    /// CS-10: after active Ice removal, the retained Wanxiang scheme can be
    /// selected and deployed without reinstalling it.
    func testCS10_RetainedWanxiangDeploysAfterActiveIceUninstall() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_ice_version": "test-ice-version",
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.uninstallSchema("rime_ice")?.value
        manager.activateSchema("wanxiang")
        await manager.deployRimeConfig()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin", "wanxiang"])
        XCTAssertFalse(installer.didInstallSchemaFiles)
        XCTAssertNil(settings.object(forKey: "rime_ice_installed"))
        XCTAssertTrue(settings.bool(forKey: "wanxiang_installed"))
        XCTAssertEqual(manager.activeSchemaID, "wanxiang")
        XCTAssertTrue(settings.bool(forKey: "rime_deployed"))
        XCTAssertFalse(settings.bool(forKey: "rime_needs_deploy"))
    }

    /// CS-10: the retained Ice scheme is deployable after active Wanxiang
    /// removal without reinstallation.
    func testCS10_RetainedIceDeploysAfterActiveWanxiangUninstall() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                "rime_ice_installed": true,
                "rime_ice_version": "test-ice-version",
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.uninstallSchema("wanxiang")?.value
        manager.activateSchema("rime_ice")
        await manager.deployRimeConfig()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin", "rime_ice"])
        XCTAssertFalse(installer.didInstallSchemaFiles)
        XCTAssertNil(settings.object(forKey: "wanxiang_installed"))
        XCTAssertTrue(settings.bool(forKey: "rime_ice_installed"))
        XCTAssertEqual(manager.activeSchemaID, "rime_ice")
        XCTAssertTrue(settings.bool(forKey: "rime_deployed"))
        XCTAssertFalse(settings.bool(forKey: "rime_needs_deploy"))
    }

    /// CS-F2 for CS-07: a failed Luna deployment leaves both the active Ice
    /// target and its retained Wanxiang peer untouched, then restores Ice.
    func testCSF2_ActiveIceUninstallWithWanxiangPeerRestoresIceWhenLunaDeployFails() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_ice_version": "test-ice-version",
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: false)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.uninstallSchema("rime_ice")?.value

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin", "rime_ice"])
        XCTAssertFalse(installer.didStageUninstall)
        XCTAssertFalse(installer.didCommitUninstall)
        XCTAssertTrue(settings.bool(forKey: "rime_ice_installed"))
        XCTAssertTrue(settings.bool(forKey: "wanxiang_installed"))
        XCTAssertEqual(manager.activeSchemaID, "rime_ice")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "rime_ice")
    }

    /// CS-F2 for CS-08: the symmetric failure keeps Wanxiang selected and Ice
    /// retained; fallback behavior stays independent of the peer inventory.
    func testCSF2_ActiveWanxiangUninstallWithIcePeerRestoresWanxiangWhenLunaDeployFails() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                "rime_ice_installed": true,
                "rime_ice_version": "test-ice-version",
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: false)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.uninstallSchema("wanxiang")?.value

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin", "wanxiang"])
        XCTAssertFalse(installer.didStageUninstall)
        XCTAssertFalse(installer.didCommitUninstall)
        XCTAssertTrue(settings.bool(forKey: "wanxiang_installed"))
        XCTAssertTrue(settings.bool(forKey: "rime_ice_installed"))
        XCTAssertEqual(manager.activeSchemaID, "wanxiang")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "wanxiang")
    }

    func testIncompleteRollbackStopsWithoutRedeployingOriginalSchema() async {
        let settings = StubSharedSettingsStore(
            values: ["rime_active_schema": "rime_ice", "rime_ice_installed": true]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            stageUninstallError: SchemaUninstallRecoveryError.rollbackIncomplete
        )
        let deploymentService = StubDeploymentService(succeeded: true)
        let diagnostics = RecordingDeliveryDiagnostics()
        let manager = makeManager(
            settings: settings, deliveryDiagnostics: diagnostics, installer: installer,
            deploymentService: deploymentService
        )
        await deploymentService.setLeaseOwnerReader { @MainActor [weak manager] in
            manager?.schemeDeliveryCommitLeaseOperationID
        }
        await manager.uninstallSchema("rime_ice")?.value
        XCTAssertFalse(installer.didCommitUninstall)
        XCTAssertTrue(settings.bool(forKey: "rime_ice_installed"))
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(
            settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            KeyboardLayoutStyle.twentySixKey.rawValue
        )
        XCTAssertEqual(
            settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26),
            "luna_pinyin"
        )
        XCTAssertNil(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9))
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "luna_pinyin")
        let requests = await deploymentService.requests
        XCTAssertEqual(requests.map(\.runtimeSmokeSchemaID), ["luna_pinyin"])
        XCTAssertNil(manager.schemeDeliveryCommitLeaseOperationID)
        guard
            let operationID = assertRuntimeRouteRecords(
                diagnostics.recordedRuntimeRouteRecords(),
                expected: [
                    "before:started", "fallback_deploy:started", "fallback_deploy:succeeded", "staging:started",
                    "staging:recovery_incomplete",
                ],
                failureIndexes: [4],
                expectedRoutes: [
                    "rime_ice:26_key:ready", "luna_pinyin:26_key:ready", "luna_pinyin:26_key:ready",
                    "luna_pinyin:26_key:ready", "luna_pinyin:26_key:ready",
                ]
            )
        else { return }
        let owners = await deploymentService.observedLeaseOwners
        XCTAssertEqual(owners, [operationID])
    }

    func testNonActiveUninstallStillRemovesFilesWithoutLunaFallback() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "luna_pinyin",
                "rime_ice_installed": true,
                "rime_ice_version": "test-version",
                "rime_ice_license_accepted": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let diagnostics = RecordingDeliveryDiagnostics()
        let manager = makeManager(
            settings: settings,
            deliveryDiagnostics: diagnostics,
            installer: installer,
            deploymentService: deploymentService
        )

        let task = manager.uninstallSchema("rime_ice")
        await task?.value

        let requests = await deploymentService.requests
        XCTAssertTrue(requests.isEmpty)
        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertTrue(installer.didCommitUninstall)
        XCTAssertNil(settings.object(forKey: "rime_ice_installed"))
        XCTAssertNil(settings.object(forKey: "rime_ice_version"))
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
        XCTAssertTrue(settings.bool(forKey: "rime_needs_deploy"))
        assertRuntimeRouteRecords(
            diagnostics.recordedRuntimeRouteRecords(),
            expected: ["before:started", "inactive:skipped", "staging:started", "commit:succeeded"],
            failureIndexes: [],
            expectedRoutes: Array(repeating: "luna_pinyin:26_key:ready", count: 4)
        )
    }

    func testNonActiveUninstallKeepsFilesWhenStagingFails() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "luna_pinyin",
                "rime_ice_installed": true,
                "rime_ice_version": "test-version",
            ]
        )
        let installer = StubSchemaArchiveInstaller(
            containsInstalledSchema: true,
            stageUninstallError: DownloadError.postProcessingFailed("stage boom")
        )
        let manager = makeManager(settings: settings, installer: installer)

        let task = manager.uninstallSchema("rime_ice")
        await task?.value

        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertFalse(installer.didCommitUninstall)
        XCTAssertEqual(settings.bool(forKey: "rime_ice_installed"), true)
        XCTAssertEqual(settings.string(forKey: "rime_ice_version"), "test-version")
        XCTAssertEqual(manager.activeSchemaID, "luna_pinyin")
    }

    func testMalformedInactiveBindingStopsBeforeStagingWithReconciliationDiagnostic() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                KeyboardLayoutSettingsKey.schemeBinding26: "rime_ice",
                KeyboardLayoutSettingsKey.schemeBinding9: " ",
                "rime_ice_installed": true,
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let diagnostics = RecordingDeliveryDiagnostics()
        let manager = makeManager(
            settings: settings,
            deliveryDiagnostics: diagnostics,
            installer: installer
        )

        await manager.uninstallSchema("rime_ice")?.value

        XCTAssertFalse(installer.didStageUninstall)
        XCTAssertFalse(installer.didCommitUninstall)
        assertRuntimeRouteRecords(
            diagnostics.recordedRuntimeRouteRecords(),
            expected: ["before:started", "reconciliation:failed"],
            failureIndexes: [1],
            expectedRoutes: ["rime_ice:26_key:ready", "rime_ice:26_key:ready"]
        )
    }

    /// CS-05: removing inactive Ice must preserve the active Wanxiang session
    /// and must not invoke the active-uninstall Luna fallback.
    func testCS05_UninstallInactiveIceKeepsWanxiangSelectionWithoutLunaDeploy() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                "rime_ice_installed": true,
                "rime_ice_version": "test-ice-version",
                "rime_ice_staged_content_checksum": "test-ice-staged-sha",
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.uninstallSchema("rime_ice")?.value

        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertTrue(installer.didCommitUninstall)
        XCTAssertNil(settings.object(forKey: "rime_ice_installed"))
        XCTAssertNil(settings.object(forKey: "rime_ice_staged_content_checksum"))
        XCTAssertTrue(settings.bool(forKey: "wanxiang_installed"))
        XCTAssertEqual(settings.string(forKey: "wanxiang_version"), "17.5.9")
        XCTAssertEqual(manager.activeSchemaID, "wanxiang")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "wanxiang")
        XCTAssertTrue(settings.bool(forKey: "rime_needs_deploy"))
        let deploymentRequests = await deploymentService.requests
        XCTAssertTrue(deploymentRequests.isEmpty, "inactive uninstall must not deploy Luna")
    }

    /// CS-06: symmetric inactive Wanxiang uninstall preserves the active Ice
    /// session and must not invoke the active-uninstall Luna fallback.
    func testCS06_UninstallInactiveWanxiangKeepsIceSelectionWithoutLunaDeploy() async {
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                "rime_ice_version": "test-ice-version",
                "wanxiang_installed": true,
                "wanxiang_version": "17.5.9",
                "wanxiang_staged_content_checksum": "test-wanxiang-staged-sha",
            ]
        )
        let installer = StubSchemaArchiveInstaller(containsInstalledSchema: true)
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )

        await manager.uninstallSchema("wanxiang")?.value

        XCTAssertTrue(installer.didStageUninstall)
        XCTAssertTrue(installer.didCommitUninstall)
        XCTAssertNil(settings.object(forKey: "wanxiang_installed"))
        XCTAssertNil(settings.object(forKey: "wanxiang_staged_content_checksum"))
        XCTAssertTrue(settings.bool(forKey: "rime_ice_installed"))
        XCTAssertEqual(settings.string(forKey: "rime_ice_version"), "test-ice-version")
        XCTAssertEqual(manager.activeSchemaID, "rime_ice")
        XCTAssertEqual(settings.string(forKey: "rime_active_schema"), "rime_ice")
        XCTAssertTrue(settings.bool(forKey: "rime_needs_deploy"))
        let deploymentRequests = await deploymentService.requests
        XCTAssertTrue(deploymentRequests.isEmpty, "inactive uninstall must not deploy Luna")
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
                RimeFuzzyPinyinSettings.enabledKey: true,
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
        guard case .failed(let schemaID, let name, _) = manager.rimeIceDownloadState else {
            return XCTFail("invalid deferred download must publish a recoverable failure")
        }
        XCTAssertEqual(schemaID, "missing")
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

    private struct CrossSchemeStagingFailureFixture {
        let rootURL: URL
        let settings: StubSharedSettingsStore
        let manager: SchemaManager
        let deploymentService: StubDeploymentService
        let targetFilesBefore: [(URL, Data)]
        let peerFileURL: URL
        let peerFileBefore: Data
    }

    private func makeCrossSchemeStagingFailureFixture(
        targetSchemaID: String,
        peerSchemaID: String,
        targetFiles: [String],
        peerFile: String
    ) throws -> CrossSchemeStagingFailureFixture {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("schema-manager-csf3-\(UUID().uuidString)")
        let sharedURL = rootURL.appendingPathComponent("Rime/shared", isDirectory: true)
        let userURL = rootURL.appendingPathComponent("Rime/user", isDirectory: true)
        try FileManager.default.createDirectory(at: sharedURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userURL, withIntermediateDirectories: true)

        let targetFilesBefore = try targetFiles.map { relativePath in
            let url = sharedURL.appendingPathComponent(relativePath)
            let data = Data("target:\(targetSchemaID):\(relativePath)".utf8)
            try data.write(to: url)
            return (url, data)
        }
        let peerFileURL = sharedURL.appendingPathComponent(peerFile)
        let peerFileBefore = Data("peer:\(peerSchemaID):\(peerFile)".utf8)
        try peerFileBefore.write(to: peerFileURL)

        let targetPrefix = targetSchemaID == "rime_ice" ? "rime_ice" : "wanxiang"
        let peerPrefix = peerSchemaID == "rime_ice" ? "rime_ice" : "wanxiang"
        let settings = StubSharedSettingsStore(
            values: [
                "rime_active_schema": targetSchemaID,
                "\(targetPrefix)_installed": true,
                "\(targetPrefix)_version": "target-version",
                "\(peerPrefix)_installed": true,
                "\(peerPrefix)_version": "peer-version",
            ]
        )
        let realInstaller = SharedContainerSchemaArchiveInstaller(
            appGroupID: "test.scheme-delivery",
            fileManager: SchemaManagerMoveItemFailureFileManager(
                failOnStagingMoveNumber: 2,
                sharedDirectoryURL: sharedURL
            ),
            containerURL: rootURL
        )
        let installer = DeploymentDirectoryOverrideSchemaArchiveInstaller(
            underlying: realInstaller,
            directories: SchemaDeploymentDirectories(sharedDataURL: sharedURL, userDataURL: userURL)
        )
        let deploymentService = StubDeploymentService(succeeded: true)
        let manager = makeManager(
            settings: settings,
            installer: installer,
            deploymentService: deploymentService
        )
        return CrossSchemeStagingFailureFixture(
            rootURL: rootURL,
            settings: settings,
            manager: manager,
            deploymentService: deploymentService,
            targetFilesBefore: targetFilesBefore,
            peerFileURL: peerFileURL,
            peerFileBefore: peerFileBefore
        )
    }

    private func makeManager(
        settings: StubSharedSettingsStore = StubSharedSettingsStore(),
        sourceSelector: any SchemaSourceSelecting = StubSchemaSourceSelector(),
        archiveDownloader: any SchemaArchiveDownloading = StubSchemaArchiveDownloader(),
        artifactVerifier: any SchemaArtifactVerifying = SchemaArtifactVerifier(),
        temporaryArtifactCleaner: any SchemaTemporaryArtifactCleaning =
            FileSystemSchemaTemporaryArtifactCleaner(),
        deliveryDiagnostics: any SchemaDeliveryDiagnosing = RecordingDeliveryDiagnostics(),
        installer: any SchemaArchiveInstalling = StubSchemaArchiveInstaller(),
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

    private func routePhaseDescription(
        _ record: RecordingDeliveryDiagnostics.RuntimeRouteRecord
    ) -> String {
        "\(record.payload.phase.rawValue):\(record.payload.result.rawValue)"
    }

    @discardableResult
    private func assertRuntimeRouteRecords(
        _ records: [RecordingDeliveryDiagnostics.RuntimeRouteRecord],
        expected: [String],
        failureIndexes: Set<Int>,
        expectedRoutes: [String] = []
    ) -> UUID? {
        XCTAssertEqual(records.map(routePhaseDescription), expected)
        guard let operationID = records.first?.payload.operationID else {
            XCTFail("expected runtime-route diagnostics")
            return nil
        }
        XCTAssertTrue(records.allSatisfy { $0.payload.operationID == operationID })
        XCTAssertTrue(records.allSatisfy { (0...600_000).contains($0.payload.elapsedMilliseconds) })
        XCTAssertEqual(
            records.map(\.payload.elapsedMilliseconds),
            records.map(\.payload.elapsedMilliseconds).sorted()
        )
        XCTAssertEqual(
            Set(records.enumerated().compactMap { $0.element.isFailure ? $0.offset : nil }),
            failureIndexes
        )
        if !expectedRoutes.isEmpty {
            XCTAssertEqual(
                records.map {
                    "\($0.payload.schema.rawValue):\($0.payload.layout.rawValue):\($0.payload.state.rawValue)"
                },
                expectedRoutes
            )
        }
        return operationID
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

/// Minimal valid Ice input for the production no-op path. Archive-integrity
/// binding has dedicated coverage; this fixture isolates the state transition.
@MainActor
private final class FixtureArchiveDownloader: SchemaArchiveDownloading {
    private static let archiveBase64 =
        "UEsDBAoAAAAAAPhmKF0a9USgFAAAABQAAAAUABwAcmltZV9pY2Uuc2NoZW1hLnlhbWxVVAkAA1SVn2pUlZ9qdXgLAAEE9QEAAAQAAAAAc2NoZW1hX2lkOiByaW1lX2ljZQpQSwMECgAAAAAA+GYoXYE7L4EQAAAAEAAAAAwAHABkZWZhdWx0LnlhbWxVVAkAA1SVn2pUlZ9qdXgLAAEE9QEAAAQAAAAAcHJlc2V0OiBmaXh0dXJlClBLAwQKAAAAAAD4Zihd9JeuQ9QAAADUAAAADgAcAHQ5LnNjaGVtYS55YW1sVVQJAANUlZ9qVJWfanV4CwABBPUBAAAEAAAAAHNjaGVtYV9pZDogdDkKc3BlbGxlcjoKICBhbGdlYnJhOgogICAgLSBkZXJpdmUvW2FiY10vMi8KICAgIC0gZGVyaXZlL1tkZWZdLzMvCiAgICAtIGRlcml2ZS9baGdpXS80LwogICAgLSBkZXJpdmUvW2prbF0vNS8KICAgIC0gZGVyaXZlL1tvbW5dLzYvCiAgICAtIGRlcml2ZS9bcHFyc10vNy8KICAgIC0gZGVyaXZlL1t0dXZdLzgvCiAgICAtIGRlcml2ZS9bd3h5el0vOS8KUEsBAh4DCgAAAAAA+GYoXRr1RKAUAAAAFAAAABQAGAAAAAAAAAAAAKSBAAAAAHJpbWVfaWNlLnNjaGVtYS55YW1sVVQFAANUlZ9qdXgLAAEE9QEAAAQAAAAAUEsBAh4DCgAAAAAA+GYoXYE7L4EQAAAAEAAAAAwAGAAAAAAAAAAAAKSBYgAAAGRlZmF1bHQueWFtbFVUBQADVJWfanV4CwABBPUBAAAEAAAAAFBLAQIeAwoAAAAAAPhmKF30l65D1AAAANQAAAAOABgAAAAAAAAAAACkgbgAAAB0OS5zY2hlbWEueWFtbFVUBQADVJWfanV4CwABBPUBAAAEAAAAAFBLBQYAAAAAAwADAAABAADUAQAAAAA="

    private let schemaID: String
    private var archiveURL: URL?

    init(schemaID: String = "rime_ice") {
        precondition(schemaID.utf8.count == "rime_ice".utf8.count)
        self.schemaID = schemaID
    }

    func downloadArchive(
        from source: RimeSchemeSourceVariant,
        operationID: UUID,
        attemptID: UUID,
        onProgress: (@Sendable (Double?) -> Void)?
    ) async throws -> DownloadedSchemaArchive {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("identical-receipt-fixture-\(UUID().uuidString).zip")
        var archiveData = try XCTUnwrap(Data(base64Encoded: Self.archiveBase64))
        if schemaID != "rime_ice" {
            let iceSchemaID = Data("rime_ice".utf8)
            let replacement = Data(schemaID.utf8)
            while let range = archiveData.range(of: iceSchemaID) {
                archiveData.replaceSubrange(range, with: replacement)
            }
        }
        try archiveData.write(to: url)
        archiveURL = url
        onProgress?(1)
        return DownloadedSchemaArchive(
            localURL: url,
            expectedContentLength: source.expectedByteCount,
            operationID: operationID,
            attemptID: attemptID,
            sourceID: source.id,
            artifactID: UUID(),
            finalHost: source.downloadURL.host ?? "fixture"
        )
    }

    func downloadedURL() -> URL? { archiveURL }
}

nonisolated private struct FixedStagedContentVerifier: SchemaArtifactVerifying {
    let stagedContentSHA256: String

    func verifyArchiveSize(at archiveURL: URL, source: RimeSchemeSourceVariant) throws {}

    func verifyArchiveDigest(at archiveURL: URL, source: RimeSchemeSourceVariant) throws -> String {
        source.archiveSHA256
    }

    func stagedContentSHA256(
        in extractionDirectory: URL,
        plan: RimeSchemeInstallationPlan,
        luaAvailable: Bool
    ) throws -> String {
        stagedContentSHA256
    }
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
    func recordRuntimeRoute(_ payload: DiagnosticEvent.RuntimeRoutePhaseEvent, isFailure: Bool) {}
}

nonisolated private final class RecordingDeliveryDiagnostics: SchemaDeliveryDiagnosing, Sendable {
    struct RuntimeRouteRecord: Sendable {
        let payload: DiagnosticEvent.RuntimeRoutePhaseEvent
        let isFailure: Bool
    }

    private let payloads = Mutex<[DiagnosticEvent.SchemeDeliveryPayload]>([])
    private let runtimeRouteRecords = Mutex<[RuntimeRouteRecord]>([])

    func record(_ payload: DiagnosticEvent.SchemeDeliveryPayload) {
        payloads.withLock { $0.append(payload) }
    }

    func recordRuntimeRoute(_ payload: DiagnosticEvent.RuntimeRoutePhaseEvent, isFailure: Bool) {
        runtimeRouteRecords.withLock { $0.append(.init(payload: payload, isFailure: isFailure)) }
    }

    func recordedPayloads() -> [DiagnosticEvent.SchemeDeliveryPayload] {
        payloads.withLock { $0 }
    }

    func recordedRuntimeRoutePayloads() -> [DiagnosticEvent.RuntimeRoutePhaseEvent] {
        runtimeRouteRecords.withLock { $0.map(\.payload) }
    }

    func recordedRuntimeRouteRecords() -> [RuntimeRouteRecord] {
        runtimeRouteRecords.withLock { $0 }
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

/// Test-only seam: fail once during production installer staging so its
/// rollback path, rather than a manager stub, restores the resource tree.
private final class SchemaManagerMoveItemFailureFileManager: FileManager {
    private let failOnStagingMoveNumber: Int
    private let sharedDirectoryURL: URL
    private var stagingMoveCallCount = 0

    init(failOnStagingMoveNumber: Int, sharedDirectoryURL: URL) {
        self.failOnStagingMoveNumber = failOnStagingMoveNumber
        self.sharedDirectoryURL = sharedDirectoryURL.standardizedFileURL
        super.init()
    }

    override func moveItem(at srcURL: URL, to dstURL: URL) throws {
        if isStagingMove(from: srcURL, to: dstURL) {
            stagingMoveCallCount += 1
        }
        if stagingMoveCallCount == failOnStagingMoveNumber, isStagingMove(from: srcURL, to: dstURL) {
            throw CocoaError(.fileWriteUnknown)
        }
        try super.moveItem(at: srcURL, to: dstURL)
    }

    private func isStagingMove(from sourceURL: URL, to destinationURL: URL) -> Bool {
        sourceURL.deletingLastPathComponent().standardizedFileURL == sharedDirectoryURL
            && destinationURL.path.hasPrefix(sharedDirectoryURL.path + "/.schema-uninstall-")
    }
}

/// Keeps the production installer responsible for schema staging while giving
/// this App Group-free test a deployable directory pair.
@MainActor
private final class DeploymentDirectoryOverrideSchemaArchiveInstaller: SchemaArchiveInstalling {
    private let underlying: SharedContainerSchemaArchiveInstaller
    private let directories: SchemaDeploymentDirectories

    init(underlying: SharedContainerSchemaArchiveInstaller, directories: SchemaDeploymentDirectories) {
        self.underlying = underlying
        self.directories = directories
    }

    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        underlying.cachedArchiveURL(for: distribution)
    }

    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        try underlying.prepareExtractionDirectory(for: distribution)
    }

    func removeTemporaryItem(at url: URL) { underlying.removeTemporaryItem(at: url) }

    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool {
        underlying.containsInstalledSchema(plan: plan)
    }

    func checkDiskSpace(needed: Int64) throws { try underlying.checkDiskSpace(needed: needed) }

    func installSchemaFiles(
        from extractDir: URL,
        plan: RimeSchemeInstallationPlan,
        luaAvailable: Bool
    ) throws {
        try underlying.installSchemaFiles(from: extractDir, plan: plan, luaAvailable: luaAvailable)
    }

    func createUpgradeCheckpoint(
        plan: RimeSchemeInstallationPlan,
        luaAvailable: Bool
    ) throws -> SchemaUpgradeCheckpoint? {
        try underlying.createUpgradeCheckpoint(plan: plan, luaAvailable: luaAvailable)
    }

    func restoreUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) throws {
        try underlying.restoreUpgradeCheckpoint(checkpoint)
    }

    func commitUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) {
        underlying.commitUpgradeCheckpoint(checkpoint)
    }

    func stageSchemaUninstall(plan: RimeSchemeInstallationPlan) throws -> SchemaUninstallStaging {
        try underlying.stageSchemaUninstall(plan: plan)
    }

    func commitSchemaUninstall(_ staging: SchemaUninstallStaging, plan: RimeSchemeInstallationPlan) {
        underlying.commitSchemaUninstall(staging, plan: plan)
    }

    func rollbackSchemaUninstall(_ staging: SchemaUninstallStaging) throws {
        try underlying.rollbackSchemaUninstall(staging)
    }

    func clearBuildCache(plan: RimeSchemeInstallationPlan) {
        underlying.clearBuildCache(plan: plan)
    }

    func sharedDataDirectoryURL() -> URL? { underlying.sharedDataDirectoryURL() }

    func runtimeDirectories() throws -> SchemaDeploymentDirectories { directories }

    func deploymentDirectories() throws -> SchemaDeploymentDirectories { directories }
}

@MainActor
private final class StubSchemaArchiveInstaller: SchemaArchiveInstalling {
    let directories: SchemaDeploymentDirectories
    private let containsInstalledSchema: Bool
    private let stageUninstallError: Error?
    private let upgradeCheckpointToReturn: SchemaUpgradeCheckpoint?
    private let restoreUpgradeError: Error?
    private let extractionDirectory: URL?
    private let installCopiesT9Fixture: Bool
    private(set) var installedLuaAvailability: Bool?
    private(set) var didUninstall = false
    private(set) var didStageUninstall = false
    private(set) var didCommitUninstall = false
    private(set) var didRollbackUninstall = false
    private(set) var didClearBuildCache = false
    private(set) var didInstallSchemaFiles = false
    private(set) var didCreateUpgradeCheckpoint = false
    private(set) var didRestoreUpgradeCheckpoint = false
    private(set) var didCommitUpgradeCheckpoint = false
    private(set) var runtimeDirectoriesCallCount = 0
    private(set) var deploymentDirectoriesCallCount = 0

    init(
        containsInstalledSchema: Bool = false,
        stageUninstallError: Error? = nil,
        upgradeCheckpointToReturn: SchemaUpgradeCheckpoint? = nil,
        restoreUpgradeError: Error? = nil,
        extractionDirectory: URL? = nil,
        installCopiesT9Fixture: Bool = false,
        directories: SchemaDeploymentDirectories = SchemaDeploymentDirectories(
            sharedDataURL: URL(fileURLWithPath: "/test/Rime/shared"),
            userDataURL: URL(fileURLWithPath: "/test/Rime/user")
        )
    ) {
        self.containsInstalledSchema = containsInstalledSchema
        self.stageUninstallError = stageUninstallError
        self.upgradeCheckpointToReturn = upgradeCheckpointToReturn
        self.restoreUpgradeError = restoreUpgradeError
        self.extractionDirectory = extractionDirectory
        self.installCopiesT9Fixture = installCopiesT9Fixture
        self.directories = directories
    }

    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        URL(fileURLWithPath: "/test/\(distribution.cachedArchiveFileName)")
    }
    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        if let extractionDirectory {
            try FileManager.default.createDirectory(
                at: extractionDirectory,
                withIntermediateDirectories: true
            )
            return extractionDirectory
        }
        return URL(fileURLWithPath: "/test/\(distribution.extractionDirectoryName)")
    }
    func removeTemporaryItem(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool { containsInstalledSchema }
    func checkDiskSpace(needed: Int64) throws {}
    func installSchemaFiles(from extractDir: URL, plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws {
        didInstallSchemaFiles = true
        installedLuaAvailability = luaAvailable
        if installCopiesT9Fixture {
            let source = extractDir.appendingPathComponent("t9.schema.yaml")
            let destination = directories.sharedDataURL.appendingPathComponent("t9.schema.yaml")
            try FileManager.default.createDirectory(
                at: destination.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try FileManager.default.copyItem(at: source, to: destination)
        }
    }

    func createUpgradeCheckpoint(plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws
        -> SchemaUpgradeCheckpoint?
    {
        didCreateUpgradeCheckpoint = true
        return upgradeCheckpointToReturn
    }
    func restoreUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) throws {
        didRestoreUpgradeCheckpoint = true
        if let restoreUpgradeError {
            throw restoreUpgradeError
        }
    }
    func commitUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) {
        didCommitUpgradeCheckpoint = true
    }
    func stageSchemaUninstall(plan: RimeSchemeInstallationPlan) throws -> SchemaUninstallStaging {
        didStageUninstall = true
        if let stageUninstallError {
            throw stageUninstallError
        }
        return SchemaUninstallStaging(
            rootURL: URL(fileURLWithPath: "/test/staging"),
            movedRelativePaths: []
        )
    }
    func commitSchemaUninstall(_ staging: SchemaUninstallStaging, plan: RimeSchemeInstallationPlan) {
        didCommitUninstall = true
        didUninstall = true
        clearBuildCache(plan: plan)
    }
    func rollbackSchemaUninstall(_ staging: SchemaUninstallStaging) {
        didRollbackUninstall = true
    }
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
    private let results: [RimeDeploymentResult]
    private(set) var requests: [RimeDeploymentRequest] = []
    private var leaseOwnerReader: (@MainActor @Sendable () -> UUID?)?
    private(set) var observedLeaseOwners: [UUID?] = []

    init(succeeded: Bool) {
        results = [RimeDeploymentResult(succeeded: succeeded, diagnosticMessage: "test")]
    }

    init(results: [Bool]) {
        precondition(!results.isEmpty)
        self.results = results.map { RimeDeploymentResult(succeeded: $0, diagnosticMessage: "test") }
    }

    func setLeaseOwnerReader(_ reader: @escaping @MainActor @Sendable () -> UUID?) {
        leaseOwnerReader = reader
    }

    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        observedLeaseOwners.append(await leaseOwnerReader?())
        requests.append(request)
        return results[min(requests.count - 1, results.count - 1)]
    }
}
