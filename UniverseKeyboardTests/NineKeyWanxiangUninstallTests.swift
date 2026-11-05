import KeyboardCore
import RimeBridge
import XCTest

@testable import Universe_Keyboard

@MainActor
final class NineKeyWanxiangUninstallTests: XCTestCase {
    private struct DirectoriesUnavailable: Error {}

    func testDirectoryPreparationFailureLeavesBothMarkersUnready() async throws {
        let wanxiangID = try wanxiangSchemeID()
        let settings = RecordingSettingsStore()
        settings.set("wanxiang", forKey: "rime_active_schema")
        settings.set("wanxiang", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        settings.set(true, forKey: "wanxiang_installed")
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "fog-keep", upstreamVersion: "v", settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: wanxiangID, fingerprint: "wan-keep", upstreamVersion: "v", settings: settings)
        let installer = UninstallArchiveInstaller(failDirectories: true)
        let deployment = UninstallDeployment(succeeded: false)
        let manager = SchemaManager(
            settings: settings, archiveInstaller: installer, deploymentService: deployment)
        await manager.uninstallSchema("wanxiang")?.value
        XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.ready, false)
        XCTAssertEqual(T9DeploymentSupport.loadMarker(schemaID: wanxiangID, settings: settings)?.ready, false)
        XCTAssertFalse(installer.didCommitUninstall)
        let calls = await deployment.calls
        XCTAssertEqual(calls, 0)
    }

    /// `schemeBinding26` holds the nine-key schema id, which is not a 26-key
    /// binding. The route snapshot then fails validation inside
    /// `performSchemaUninstall` before `deployRimeConfig`.
    func testRouteSnapshotFailureBeforeSharedDeployClearsOnlyWanxiangMarker() async throws {
        let wanxiangID = try wanxiangSchemeID()
        let settings = RecordingSettingsStore()
        settings.set("luna_pinyin", forKey: "rime_active_schema")
        settings.set(wanxiangID, forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        settings.set(true, forKey: "wanxiang_installed")
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "fog-keep", upstreamVersion: "v", settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: wanxiangID, fingerprint: "wan-keep", upstreamVersion: "v", settings: settings)
        let installer = UninstallArchiveInstaller(failDirectories: false)
        let deployment = UninstallDeployment(succeeded: false)
        let manager = SchemaManager(
            settings: settings, archiveInstaller: installer, deploymentService: deployment)
        await manager.uninstallSchema("wanxiang")?.value
        XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.ready, true)
        XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.resourceFingerprint, "fog-keep")
        XCTAssertEqual(T9DeploymentSupport.loadMarker(schemaID: wanxiangID, settings: settings)?.ready, false)
        XCTAssertEqual(
            T9DeploymentSupport.loadMarker(schemaID: wanxiangID, settings: settings)?.resourceFingerprint, "")
        XCTAssertFalse(installer.didCommitUninstall)
        let calls = await deployment.calls
        XCTAssertEqual(calls, 0)
    }

    func testFailureAfterSharedDeployLeavesBothMarkersUnready() async throws {
        let wanxiangID = try wanxiangSchemeID()
        let settings = RecordingSettingsStore()
        settings.set("wanxiang", forKey: "rime_active_schema")
        settings.set("wanxiang", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        settings.set(true, forKey: "wanxiang_installed")
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "fog-keep", upstreamVersion: "v", settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: wanxiangID, fingerprint: "wan-keep", upstreamVersion: "v", settings: settings)
        let installer = UninstallArchiveInstaller(failDirectories: false)
        let deployment = UninstallDeployment(succeeded: false)
        let manager = SchemaManager(
            settings: settings, archiveInstaller: installer, deploymentService: deployment)
        await manager.uninstallSchema("wanxiang")?.value
        XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.ready, false)
        XCTAssertEqual(T9DeploymentSupport.loadMarker(schemaID: wanxiangID, settings: settings)?.ready, false)
        XCTAssertFalse(installer.didCommitUninstall)
        let calls = await deployment.calls
        XCTAssertGreaterThan(calls, 0)
    }

    func testFileDeletionFailureDoesNotRestoreClearedMarker() async throws {
        let wanxiangID = try wanxiangSchemeID()
        let settings = RecordingSettingsStore()
        settings.set("luna_pinyin", forKey: "rime_active_schema")
        settings.set("luna_pinyin", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        settings.set(wanxiangID, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        settings.set(true, forKey: "wanxiang_installed")
        T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "fog-keep", upstreamVersion: "v", settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: wanxiangID, fingerprint: "wan-keep", upstreamVersion: "v", settings: settings)
        let installer = UninstallArchiveInstaller(failDirectories: true, failStaging: true)
        let manager = SchemaManager(
            settings: settings,
            archiveInstaller: installer,
            deploymentService: UninstallDeployment(succeeded: false))
        await manager.uninstallSchema("wanxiang")?.value
        XCTAssertEqual(
            T9DeploymentSupport.loadMarker(schemaID: wanxiangID, settings: settings)?.resourceFingerprint, "")
        XCTAssertEqual(T9DeploymentSupport.loadMarker(schemaID: wanxiangID, settings: settings)?.ready, false)
        XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.resourceFingerprint, "fog-keep")
        XCTAssertFalse(installer.didCommitUninstall)
    }

    func testUninstallWhileWanxiangNineKeyBoundReturnsTwentySixKey() async throws {
        let wanxiangID = try wanxiangSchemeID()
        let settings = RecordingSettingsStore()
        settings.set("luna_pinyin", forKey: "rime_active_schema")
        settings.set("luna_pinyin", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        settings.set(wanxiangID, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        settings.set(true, forKey: "wanxiang_installed")
        T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
        let installer = UninstallArchiveInstaller(failDirectories: false)
        let manager = SchemaManager(
            settings: settings,
            archiveInstaller: installer,
            deploymentService: UninstallDeployment(succeeded: true))
        await manager.uninstallSchema("wanxiang")?.value
        XCTAssertEqual(
            settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            KeyboardLayoutStyle.twentySixKey.rawValue)
        XCTAssertTrue(installer.didCommitUninstall)
    }

    private func wanxiangSchemeID() throws -> String {
        try XCTUnwrap(NineKeySchemeRegistry.schemes(forFamily: "wanxiang").first).schemaID
    }
}

private actor UninstallDeployment: RimeDeploymentServicing {
    let succeeded: Bool
    private(set) var calls = 0

    init(succeeded: Bool) {
        self.succeeded = succeeded
    }

    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        calls += 1
        return RimeDeploymentResult(
            succeeded: succeeded,
            diagnosticMessage: "test",
            librimeVersion: succeeded ? "test-librime" : nil
        )
    }
}

@MainActor
private final class UninstallArchiveInstaller: SchemaArchiveInstalling {
    let directories: SchemaDeploymentDirectories
    var failDirectories: Bool
    var failStaging: Bool
    private(set) var didCommitUninstall = false

    init(failDirectories: Bool, failStaging: Bool = false) {
        self.failDirectories = failDirectories
        self.failStaging = failStaging
        directories = SchemaDeploymentDirectories(
            sharedDataURL: URL(
                fileURLWithPath:
                    "/Users/doubleshy0n/.kos-work/Universe-Keyboard/WANXIANG-T9-001/scratch/s2c-r2/tmp/uninstall-shared"
            ),
            userDataURL: URL(
                fileURLWithPath:
                    "/Users/doubleshy0n/.kos-work/Universe-Keyboard/WANXIANG-T9-001/scratch/s2c-r2/tmp/uninstall-user")
        )
    }

    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        URL(fileURLWithPath: "/tmp/unused-archive")
    }
    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        directories.sharedDataURL
    }
    func removeTemporaryItem(at url: URL) {}
    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool { true }
    func checkDiskSpace(needed: Int64) throws {}
    func installSchemaFiles(
        from extractDir: URL, plan: RimeSchemeInstallationPlan, luaAvailable: Bool
    ) throws {}
    func createUpgradeCheckpoint(
        plan: RimeSchemeInstallationPlan, luaAvailable: Bool
    ) throws -> SchemaUpgradeCheckpoint? { nil }
    func restoreUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) throws {}
    func commitUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) {}
    func stageSchemaUninstall(plan: RimeSchemeInstallationPlan) throws -> SchemaUninstallStaging {
        if failStaging { throw DirectoriesUnavailableError() }
        return SchemaUninstallStaging(rootURL: directories.userDataURL, movedRelativePaths: [])
    }
    func commitSchemaUninstall(_ staging: SchemaUninstallStaging, plan: RimeSchemeInstallationPlan) {
        didCommitUninstall = true
    }
    func rollbackSchemaUninstall(_ staging: SchemaUninstallStaging) throws {}
    func clearBuildCache(plan: RimeSchemeInstallationPlan) {}
    func sharedDataDirectoryURL() -> URL? { directories.sharedDataURL }
    func runtimeDirectories() throws -> SchemaDeploymentDirectories { directories }
    func deploymentDirectories(pendingSchemaID: String?) throws -> SchemaDeploymentDirectories {
        if failDirectories { throw DirectoriesUnavailableError() }
        return directories
    }
}

private struct DirectoriesUnavailableError: Error {}
