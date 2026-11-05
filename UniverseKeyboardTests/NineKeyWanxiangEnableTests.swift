import KeyboardCore
import RimeBridge
import XCTest

@testable import Universe_Keyboard

@MainActor
final class NineKeyWanxiangEnableTests: XCTestCase {
    private let schemaID = "wanxiang_t9i"

    override func tearDown() {
        NineKeyPublishSmoke.override = nil
        RimeT9SmokeProbe.selectAndConfirmHook = nil
        super.tearDown()
    }

    func testPrepareFailureKeepsWanxiangMarkerUnreadyWhileSharingDeployResult() async throws {
        let succeeded = try await deploy(prepareFails: true, deploySucceeds: true, compiled: .clean)
        XCTAssertTrue(succeeded.returned)
        XCTAssertTrue(succeeded.settings.bool(forKey: "rime_deployed"))
        XCTAssertEqual(
            T9DeploymentSupport.loadMarker(schemaID: schemaID, settings: succeeded.settings)?.ready,
            false
        )

        let failed = try await deploy(prepareFails: true, deploySucceeds: false, compiled: .clean)
        XCTAssertFalse(failed.returned)
        XCTAssertFalse(failed.settings.bool(forKey: "rime_deployed"))
        XCTAssertNotEqual(
            T9DeploymentSupport.loadMarker(schemaID: schemaID, settings: failed.settings)?.ready,
            true
        )
        succeeded.cleanup()
        failed.cleanup()
    }

    func testCompiledGateWritesWanxiangMarkerOnlyWhenClean() throws {
        NineKeyPublishSmoke.override = { _, _, _, _ in true }
        RimeT9SmokeProbe.selectAndConfirmHook = { _, _, _ in true }

        let missing = try publishFixture(compiled: .missing)
        XCTAssertNotEqual(
            T9DeploymentSupport.loadMarker(schemaID: schemaID, settings: missing.settings)?.ready,
            true
        )
        missing.cleanup()

        let dirty = try publishFixture(compiled: .t9Processor)
        XCTAssertNotEqual(
            T9DeploymentSupport.loadMarker(schemaID: schemaID, settings: dirty.settings)?.ready,
            true
        )
        dirty.cleanup()

        let clean = try publishFixture(compiled: .clean)
        let marker = T9DeploymentSupport.loadMarker(schemaID: schemaID, settings: clean.settings)
        XCTAssertEqual(marker?.ready, true)
        XCTAssertTrue(
            NineKeyReadiness.isMatched(
                schemaID: schemaID,
                marker: marker,
                fingerprint: T9DeploymentSupport.resourceFingerprint(
                    schemaID: schemaID,
                    sharedDataURL: clean.shared
                )
            )
        )
        clean.cleanup()
    }

    func testDownloadPrepareUsesRuntimeUserDirectory() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-wx-f4-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let runtimeUser = root.appendingPathComponent("custom-user", isDirectory: true)
        let sibling = root.appendingPathComponent("user", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let artifactName = "\(schemaID).schema.yaml"
        for directory in [runtimeUser, sibling] {
            let build = directory.appendingPathComponent("build", isDirectory: true)
            try FileManager.default.createDirectory(at: build, withIntermediateDirectories: true)
            try "stale".write(
                to: build.appendingPathComponent(artifactName),
                atomically: true,
                encoding: .utf8
            )
        }
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        // Prepare rewrites the shared source. This fixture is already compatible
        // so the test still measures which user directory loses its build file.
        try """
        engine:
          processors:
            - speller
        speller:
          algebra:
            - abbrev/^([A-Z]).+$/$1/
            - abbrev/^([ZCS]H).+$/$1/
            - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
        super_replacer:
          rules:
            - option: emoji

        """.write(
            to: shared.appendingPathComponent(artifactName),
            atomically: true,
            encoding: .utf8
        )
        let directories = SchemaDeploymentDirectories(sharedDataURL: shared, userDataURL: runtimeUser)
        let manager = SchemaManager(
            settings: RecordingSettingsStore(),
            archiveInstaller: WanxiangEnableInstaller(directories: directories)
        )
        try manager.prepareWanxiangNineKeyDownloadSource(sharedDataURL: shared)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: runtimeUser.appendingPathComponent("build/\(artifactName)").path
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: sibling.appendingPathComponent("build/\(artifactName)").path
            )
        )
    }

    func testWanxiangNineKeySourceIsNotAFullKeyboardPostProcessTarget() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-wx-f5-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try "engine:\n  processors:\n    - speller\n".write(
            to: shared.appendingPathComponent("\(schemaID).schema.yaml"),
            atomically: true,
            encoding: .utf8
        )
        let settings = RecordingSettingsStore()
        settings.set(schemaID, forKey: "rime_active_schema")
        let manager = SchemaManager(
            settings: settings,
            archiveInstaller: WanxiangEnableInstaller(
                directories: SchemaDeploymentDirectories(sharedDataURL: shared, userDataURL: root)
            )
        )
        XCTAssertFalse(manager.fuzzyTargetSchemaIDs(sharedDataURL: shared).contains(schemaID))
    }

    private enum Compiled {
        case missing
        case clean
        case t9Processor
    }

    private struct DeployOutcome {
        let returned: Bool
        let settings: RecordingSettingsStore
        let cleanup: () -> Void
    }

    private func deploy(prepareFails: Bool, deploySucceeds: Bool, compiled: Compiled) async throws -> DeployOutcome {
        let fixture = try makeTree(prepareFails: prepareFails, compiled: compiled)
        NineKeyPublishSmoke.override = { _, _, _, _ in true }
        RimeT9SmokeProbe.selectAndConfirmHook = { _, _, _ in true }
        let service = WanxiangEnableDeployment(succeeded: deploySucceeds)
        let manager = SchemaManager(
            settings: fixture.settings,
            archiveInstaller: WanxiangEnableInstaller(directories: fixture.directories),
            deploymentService: service
        )
        let returned = await manager.deployRimeConfig()
        return DeployOutcome(returned: returned, settings: fixture.settings) {
            try? FileManager.default.removeItem(at: fixture.root)
        }
    }

    private func publishFixture(compiled: Compiled) throws -> PublishFixture {
        let tree = try makeTree(prepareFails: false, compiled: compiled)
        let manager = SchemaManager(
            settings: tree.settings,
            archiveInstaller: WanxiangEnableInstaller(directories: tree.directories)
        )
        _ = manager.publishIndependentNineKeyReadiness(
            sharedDataURL: tree.directories.sharedDataURL,
            userDataURL: tree.directories.userDataURL
        )
        return PublishFixture(
            shared: tree.directories.sharedDataURL,
            settings: tree.settings,
            cleanup: { try? FileManager.default.removeItem(at: tree.root) }
        )
    }

    private struct Tree {
        let root: URL
        let directories: SchemaDeploymentDirectories
        let settings: RecordingSettingsStore
    }

    private struct PublishFixture {
        let shared: URL
        let settings: RecordingSettingsStore
        let cleanup: () -> Void
    }

    private func makeTree(prepareFails: Bool, compiled: Compiled) throws -> Tree {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-wx-deploy-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        let ready = """
            engine:
              processors:
                - speller
            speller:
              algebra:
                - abbrev/^([A-Z]).+$/$1/
                - abbrev/^([ZCS]H).+$/$1/
                - xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
            super_replacer:
              rules:
                - option: emoji

            """
        let sourceText =
            prepareFails
            ? "engine:\n  processors:\n    - t9_processor\n    - t9_processor\n"
            : ready
        try sourceText.write(
            to: shared.appendingPathComponent("\(schemaID).schema.yaml"),
            atomically: true,
            encoding: .utf8
        )
        if compiled != .missing {
            let build = user.appendingPathComponent("build", isDirectory: true)
            try FileManager.default.createDirectory(at: build, withIntermediateDirectories: true)
            let compiledText =
                compiled == .t9Processor
                ? "engine:\n  processors:\n    - t9_processor\n"
                : "engine:\n  processors:\n    - speller\n"
            try compiledText.write(
                to: build.appendingPathComponent("\(schemaID).schema.yaml"),
                atomically: true,
                encoding: .utf8
            )
        }
        let settings = RecordingSettingsStore()
        settings.set(true, forKey: "wanxiang_installed")
        settings.set("luna_pinyin", forKey: "rime_active_schema")
        return Tree(
            root: root,
            directories: SchemaDeploymentDirectories(sharedDataURL: shared, userDataURL: user),
            settings: settings
        )
    }
}

@MainActor
private final class WanxiangEnableInstaller: SchemaArchiveInstalling {
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

private actor WanxiangEnableDeployment: RimeDeploymentServicing {
    let succeeded: Bool
    init(succeeded: Bool) { self.succeeded = succeeded }
    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        RimeDeploymentResult(
            succeeded: succeeded,
            diagnosticMessage: "test",
            librimeVersion: succeeded ? "test-librime" : nil
        )
    }
}
