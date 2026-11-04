import KeyboardCore
import RimeBridge
import XCTest

@testable import Universe_Keyboard

@MainActor
final class NineKeyWanxiangRouteTests: XCTestCase {
    private let schemaID = "wanxiang_t9i"

    func testMatchedWanxiangMarkerRoutesToNineKeyAndRestoreSelectsThatSchema() throws {
        let fixture = try makeFixture(markerFingerprintMatches: true)
        defer { fixture.cleanup() }
        let snapshot = fixture.manager.currentRuntimeRouteSnapshot()
        XCTAssertEqual(snapshot.effectiveRoute.schemaID, schemaID)
        XCTAssertEqual(snapshot.effectiveRoute.layoutStyle, .nineKey)

        var selected: String?
        var userDir: String?
        RimeT9SmokeProbe.selectAndConfirmHook = { _, user, id in
            selected = id
            userDir = user
            return true
        }
        defer { RimeT9SmokeProbe.selectAndConfirmHook = nil }
        XCTAssertTrue(
            fixture.manager.restoreNineKeyEngineRoute(
                sharedDataURL: fixture.shared,
                userDataURL: fixture.user
            )
        )
        XCTAssertEqual(selected, snapshot.effectiveRoute.schemaID)
        XCTAssertEqual(userDir, fixture.user.path)
    }

    func testMismatchedWanxiangMarkerFailClosesToTwentySix() throws {
        let fixture = try makeFixture(markerFingerprintMatches: false)
        defer { fixture.cleanup() }
        let snapshot = fixture.manager.currentRuntimeRouteSnapshot()
        XCTAssertEqual(snapshot.effectiveRoute.layoutStyle, .twentySixKey)
        XCTAssertNotEqual(snapshot.effectiveRoute.schemaID, schemaID)
    }

    private func makeFixture(markerFingerprintMatches: Bool) throws -> RouteFixture {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-wx-route-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("custom-user", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        let source = shared.appendingPathComponent("\(schemaID).schema.yaml")
        try "engine:\n  processors:\n    - speller\n".write(to: source, atomically: true, encoding: .utf8)
        let fingerprint = T9DeploymentSupport.resourceFingerprint(schemaID: schemaID, sharedDataURL: shared)
        let settings = RecordingSettingsStore()
        settings.set(true, forKey: "wanxiang_installed")
        settings.set("wanxiang", forKey: "rime_active_schema")
        settings.set("wanxiang", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        settings.set(schemaID, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        settings.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: schemaID,
            fingerprint: markerFingerprintMatches ? (fingerprint ?? "missing") : "mismatch",
            upstreamVersion: "test",
            settings: settings
        )
        let directories = SchemaDeploymentDirectories(sharedDataURL: shared, userDataURL: user)
        let manager = SchemaManager(
            settings: settings,
            archiveInstaller: WanxiangRouteInstaller(directories: directories)
        )
        return RouteFixture(root: root, shared: shared, user: user, manager: manager)
    }
}

@MainActor
private struct RouteFixture {
    let root: URL
    let shared: URL
    let user: URL
    let manager: SchemaManager
    func cleanup() { try? FileManager.default.removeItem(at: root) }
}

@MainActor
private final class WanxiangRouteInstaller: SchemaArchiveInstalling {
    let directories: SchemaDeploymentDirectories
    init(directories: SchemaDeploymentDirectories) { self.directories = directories }
    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(distribution.cachedArchiveFileName)
    }
    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(distribution.extractionDirectoryName)
    }
    func removeTemporaryItem(at url: URL) {}
    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool { false }
    func checkDiskSpace(needed: Int64) throws {}
    func installSchemaFiles(from extractDir: URL, plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws {}
    func createUpgradeCheckpoint(plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws
        -> SchemaUpgradeCheckpoint?
    { nil }
    func restoreUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) throws {}
    func commitUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) {}
    func stageSchemaUninstall(plan: RimeSchemeInstallationPlan) throws -> SchemaUninstallStaging {
        SchemaUninstallStaging(rootURL: URL(fileURLWithPath: "/tmp/staging"), movedRelativePaths: [])
    }
    func commitSchemaUninstall(_ staging: SchemaUninstallStaging, plan: RimeSchemeInstallationPlan) {}
    func rollbackSchemaUninstall(_ staging: SchemaUninstallStaging) {}
    func clearBuildCache(plan: RimeSchemeInstallationPlan) {}
    func sharedDataDirectoryURL() -> URL? { directories.sharedDataURL }
    func runtimeDirectories() throws -> SchemaDeploymentDirectories { directories }
    func deploymentDirectories(pendingSchemaID: String?) throws -> SchemaDeploymentDirectories { directories }
}
