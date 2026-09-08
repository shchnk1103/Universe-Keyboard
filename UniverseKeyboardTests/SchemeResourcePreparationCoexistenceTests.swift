import CryptoKit
import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge
@testable import Universe_Keyboard

/// P0: production Ice/Wanxiang install plans against the built-in installer.
/// Does not use App Group; the installer seam only substitutes the container root.
@MainActor
final class SchemeResourcePreparationCoexistenceTests: XCTestCase {
    func testIcePlanSkipsDefaultYamlAndInstallsPrivatePreset() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let official = try Data(contentsOf: env.defaultYAMLURL)
        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        XCTAssertFalse(icePlan.shouldInstall(relativePath: "default.yaml", luaAvailable: true))
        XCTAssertTrue(icePlan.shouldInstall(relativePath: "rime_ice_preset.yaml", luaAvailable: true))
        XCTAssertTrue(icePlan.skippedFiles.contains("default.yaml"))

        let iceDefault = try iceDefaultYAMLData()
        XCTAssertNotEqual(iceDefault.count, official.count)

        let extract = env.root.appendingPathComponent("ice-extract", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try iceDefault.write(to: extract.appendingPathComponent("default.yaml"))
        try iceDefault.write(to: extract.appendingPathComponent("rime_ice_preset.yaml"))
        try Data("ice-schema".utf8).write(to: extract.appendingPathComponent("rime_ice.schema.yaml"))

        try env.installer.installSchemaFiles(from: extract, plan: icePlan, luaAvailable: true)

        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("rime_ice_preset.yaml")),
            iceDefault
        )
        XCTAssertNoThrow(
            try RimeBuiltinResourceInstaller().install(
                sourceRoot: env.sourceRoot,
                rimeRoot: env.rimeRoot
            )
        )
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
    }

    func testWanxiangPlanSkipsDefaultYamlSoBuiltinRedeploySucceeds() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let official = try Data(contentsOf: env.defaultYAMLURL)
        let wanxiangPlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)
        XCTAssertFalse(wanxiangPlan.shouldInstall(relativePath: "default.yaml", luaAvailable: true))

        let extract = env.root.appendingPathComponent("wanxiang-extract", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try Data(repeating: 0x61, count: 14_842).write(to: extract.appendingPathComponent("default.yaml"))
        try Data("wanxiang-schema".utf8).write(
            to: extract.appendingPathComponent("wanxiang.schema.yaml")
        )

        try env.installer.installSchemaFiles(from: extract, plan: wanxiangPlan, luaAvailable: true)

        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("wanxiang.schema.yaml")),
            Data("wanxiang-schema".utf8)
        )
        XCTAssertNoThrow(
            try RimeBuiltinResourceInstaller().install(
                sourceRoot: env.sourceRoot,
                rimeRoot: env.rimeRoot
            )
        )
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
    }

    func testIceUninstallRemovesPresetAndLeavesOfficialDefaultYaml() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let official = try Data(contentsOf: env.defaultYAMLURL)
        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        let iceDefault = try iceDefaultYAMLData()
        let extract = env.root.appendingPathComponent("ice-extract", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try iceDefault.write(to: extract.appendingPathComponent("default.yaml"))
        try iceDefault.write(to: extract.appendingPathComponent("rime_ice_preset.yaml"))
        try Data("ice-schema".utf8).write(to: extract.appendingPathComponent("rime_ice.schema.yaml"))
        try FileManager.default.createDirectory(
            at: extract.appendingPathComponent("opencc", isDirectory: true),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: extract.appendingPathComponent("lua", isDirectory: true),
            withIntermediateDirectories: true
        )
        try Data("emoji".utf8).write(
            to: extract.appendingPathComponent("opencc/emoji.json")
        )
        try Data("lua".utf8).write(
            to: extract.appendingPathComponent("lua/date_translator.lua")
        )
        try env.installer.installSchemaFiles(from: extract, plan: icePlan, luaAvailable: true)

        let staging = try env.installer.stageSchemaUninstall(plan: icePlan)
        env.installer.commitSchemaUninstall(staging, plan: icePlan)

        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent("rime_ice.schema.yaml").path
            )
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent("rime_ice_preset.yaml").path
            )
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent("lua/date_translator.lua").path
            )
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent("opencc/emoji.json").path
            )
        )
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent("opencc/s2t.json").path
            )
        )
    }

    func testIceUninstallStagingRollbackRestoresOwnedFiles() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        let iceDefault = try iceDefaultYAMLData()
        let extract = env.root.appendingPathComponent("ice-extract-rollback", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try iceDefault.write(to: extract.appendingPathComponent("default.yaml"))
        try iceDefault.write(to: extract.appendingPathComponent("rime_ice_preset.yaml"))
        try Data("ice-schema".utf8).write(to: extract.appendingPathComponent("rime_ice.schema.yaml"))
        try env.installer.installSchemaFiles(from: extract, plan: icePlan, luaAvailable: true)

        let staging = try env.installer.stageSchemaUninstall(plan: icePlan)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent("rime_ice.schema.yaml").path
            )
        )
        try env.installer.rollbackSchemaUninstall(staging)
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml")),
            Data("ice-schema".utf8)
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("rime_ice_preset.yaml")),
            iceDefault
        )
    }

    /// Q-P2-01: inject failure on the 2nd production `moveItem` so stage catch
    /// rolls back already-moved owned paths (fail-closed), without a manager Stub.
    func testIceUninstallStagingMidMoveFailureRestoresOwnedFiles() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        let iceDefault = try iceDefaultYAMLData()
        let schemaBytes = Data("ice-schema-mid-fail".utf8)
        let emojiBytes = Data("emoji-mid-fail".utf8)
        let luaBytes = Data("lua-mid-fail".utf8)
        let extract = env.root.appendingPathComponent("ice-extract-mid-fail", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try iceDefault.write(to: extract.appendingPathComponent("default.yaml"))
        try iceDefault.write(to: extract.appendingPathComponent("rime_ice_preset.yaml"))
        try schemaBytes.write(to: extract.appendingPathComponent("rime_ice.schema.yaml"))
        try FileManager.default.createDirectory(
            at: extract.appendingPathComponent("opencc", isDirectory: true),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: extract.appendingPathComponent("lua", isDirectory: true),
            withIntermediateDirectories: true
        )
        try emojiBytes.write(to: extract.appendingPathComponent("opencc/emoji.json"))
        try luaBytes.write(to: extract.appendingPathComponent("lua/date_translator.lua"))
        try env.installer.installSchemaFiles(from: extract, plan: icePlan, luaAvailable: true)

        let container = env.root.appendingPathComponent("container", isDirectory: true)
        let failingFileManager = MoveItemFailureFileManager(failOnMoveNumber: 2)
        let failingInstaller = SharedContainerSchemaArchiveInstaller(
            appGroupID: "group.com.DoubleShy0N.Universe-Keyboard",
            fileManager: failingFileManager,
            containerURL: container
        )

        XCTAssertThrowsError(try failingInstaller.stageSchemaUninstall(plan: icePlan)) { error in
            guard case DownloadError.postProcessingFailed = error else {
                return XCTFail("expected postProcessingFailed, got \(error)")
            }
        }
        XCTAssertGreaterThanOrEqual(failingFileManager.moveCallCount, 2)

        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml")),
            schemaBytes
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("rime_ice_preset.yaml")),
            iceDefault
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("opencc/emoji.json")),
            emojiBytes
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("lua/date_translator.lua")),
            luaBytes
        )

        let sharedNames = try FileManager.default.contentsOfDirectory(atPath: env.shared.path)
        XCTAssertFalse(
            sharedNames.contains(where: { $0.hasPrefix(".schema-uninstall-") }),
            "staging root must not remain as live shared pollution"
        )
    }

    func testUninstallDoubleFailurePreservesCheckpointAndAllowsRecoveryRetry() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        let plan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        let bytes = Data("original-schema".utf8)
        try bytes.write(to: env.shared.appendingPathComponent("rime_ice.schema.yaml"))
        try bytes.write(to: env.shared.appendingPathComponent("rime_ice.dict.yaml"))
        let installer = SharedContainerSchemaArchiveInstaller(
            appGroupID: "test",
            fileManager: MoveItemFailureFileManager(failingMoves: [2, 3]),
            containerURL: env.root.appendingPathComponent("container")
        )
        XCTAssertThrowsError(try installer.stageSchemaUninstall(plan: plan)) { error in
            XCTAssertTrue(error is SchemaUninstallRecoveryError)
        }
        let roots = try FileManager.default.contentsOfDirectory(
            at: env.shared, includingPropertiesForKeys: nil
        ).filter { $0.lastPathComponent.hasPrefix(".schema-uninstall-") }
        XCTAssertEqual(roots.count, 1)
        let root = try XCTUnwrap(roots.first)
        XCTAssertEqual(try Data(contentsOf: root.appendingPathComponent("rime_ice.schema.yaml")), bytes)
        XCTAssertEqual(try Data(contentsOf: env.shared.appendingPathComponent("rime_ice.dict.yaml")), bytes)
        let checkpoint = SchemaUninstallStaging(rootURL: root, movedRelativePaths: ["rime_ice.schema.yaml"])
        try installer.rollbackSchemaUninstall(checkpoint)
        XCTAssertEqual(try Data(contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml")), bytes)
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.path))
    }

    func testRollbackContinuesAfterMiddleFailureAndRetriesOriginalCheckpoint() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        let plan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        let paths = ["rime_ice.schema.yaml", "rime_ice.dict.yaml", "rime_ice_preset.yaml"]
        for path in paths {
            try Data(path.utf8).write(to: env.shared.appendingPathComponent(path))
        }
        let installer = SharedContainerSchemaArchiveInstaller(
            appGroupID: "test",
            fileManager: MoveItemFailureFileManager(failingMoves: [5]),
            containerURL: env.root.appendingPathComponent("container")
        )
        let checkpoint = try installer.stageSchemaUninstall(plan: plan)
        XCTAssertEqual(checkpoint.movedRelativePaths.count, 3)
        XCTAssertThrowsError(try installer.rollbackSchemaUninstall(checkpoint))
        for path in paths {
            let root = path == "rime_ice.dict.yaml" ? checkpoint.rootURL : env.shared
            XCTAssertEqual(try Data(contentsOf: root.appendingPathComponent(path)), Data(path.utf8))
        }
        try installer.rollbackSchemaUninstall(checkpoint)
        for path in paths {
            XCTAssertEqual(try Data(contentsOf: env.shared.appendingPathComponent(path)), Data(path.utf8))
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: checkpoint.rootURL.path))
    }

    func testMissingStagedFileWithoutRestoreEvidenceRetainsCheckpoint() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        let plan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        let path = "rime_ice.schema.yaml"
        try Data("original".utf8).write(to: env.shared.appendingPathComponent(path))
        let checkpoint = try env.installer.stageSchemaUninstall(plan: plan)
        try FileManager.default.removeItem(at: checkpoint.rootURL.appendingPathComponent(path))
        // An unrelated destination must not be mistaken for successful restore.
        try Data("replacement".utf8).write(to: env.shared.appendingPathComponent(path))
        XCTAssertThrowsError(try env.installer.rollbackSchemaUninstall(checkpoint)) { error in
            XCTAssertTrue(error is SchemaUninstallRecoveryError)
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: checkpoint.rootURL.path))
        XCTAssertEqual(try Data(contentsOf: env.shared.appendingPathComponent(path)), Data("replacement".utf8))
    }

    func testKnownIceDefaultYamlPollutionIsRecoveredThenBuiltinRedeploySucceeds() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let official = try Data(contentsOf: env.defaultYAMLURL)
        let iceDefault = try iceDefaultYAMLData()
        guard
            sha256(iceDefault)
                == "0dacfbaca4774c07a0adb2ca2380dc290ada5dfb97e027d54063790ebaca37cd"
        else {
            throw XCTSkip("Ice 2026.06.30 default.yaml fixture is required for P3 fingerprint recovery")
        }
        try iceDefault.write(to: env.defaultYAMLURL)

        _ = try RimeBuiltinResourceInstaller().install(
            sourceRoot: env.sourceRoot,
            rimeRoot: env.rimeRoot
        )
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
    }

    func testBuiltinOnlyRepeatedDeployRemainsIdempotent() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let official = try Data(contentsOf: env.defaultYAMLURL)
        _ = try RimeBuiltinResourceInstaller().install(
            sourceRoot: env.sourceRoot,
            rimeRoot: env.rimeRoot
        )
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
    }

    func testProductionProcessedIceTreeKeepsOfficialDefaultYamlWhenFixturePresent() throws {
        let fixture = try iceProcessedExtractURL()
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let extract = env.root.appendingPathComponent("ice-copy", isDirectory: true)
        try FileManager.default.copyItem(at: fixture, to: extract)
        try RimeIceSharedDefaultAdapter.apply(in: extract)

        let official = try Data(contentsOf: env.defaultYAMLURL)
        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        try env.installer.installSchemaFiles(from: extract, plan: icePlan, luaAvailable: true)

        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
        let preset = try Data(contentsOf: env.shared.appendingPathComponent("rime_ice_preset.yaml"))
        XCTAssertEqual(preset.count, 14_842)
        XCTAssertEqual(
            sha256(preset),
            "0dacfbaca4774c07a0adb2ca2380dc290ada5dfb97e027d54063790ebaca37cd"
        )
        let schema = try String(
            contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml"),
            encoding: .utf8
        )
        XCTAssertTrue(schema.contains("__include: rime_ice_preset:/punctuator"))
        XCTAssertNoThrow(
            try RimeBuiltinResourceInstaller().install(
                sourceRoot: env.sourceRoot,
                rimeRoot: env.rimeRoot
            )
        )
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
    }

    private struct Environment {
        let root: URL
        let sourceRoot: URL
        let rimeRoot: URL
        let shared: URL
        let defaultYAMLURL: URL
        let installer: SharedContainerSchemaArchiveInstaller

        func tearDown() {
            try? FileManager.default.removeItem(at: root)
            try? FileManager.default.removeItem(at: sourceRoot)
        }
    }

    private func makeEnvironment() throws -> Environment {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "uk-p0-coexist-\(UUID().uuidString)",
            isDirectory: true
        )
        let container = root.appendingPathComponent("container", isDirectory: true)
        try FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)
        let rimeRoot = container.appendingPathComponent("Rime", isDirectory: true)
        let sourceRoot = try RimeConfigManager.stageBundledResourceClosure(from: .main)
        _ = try RimeBuiltinResourceInstaller().install(sourceRoot: sourceRoot, rimeRoot: rimeRoot)
        return Environment(
            root: root,
            sourceRoot: sourceRoot,
            rimeRoot: rimeRoot,
            shared: rimeRoot.appendingPathComponent("shared", isDirectory: true),
            defaultYAMLURL: rimeRoot.appendingPathComponent("shared/default.yaml"),
            installer: SharedContainerSchemaArchiveInstaller(
                appGroupID: "group.com.DoubleShy0N.Universe-Keyboard",
                containerURL: container
            )
        )
    }

    private func iceDefaultYAMLData() throws -> Data {
        if let extract = optionalIceExtractURL() {
            return try Data(contentsOf: extract.appendingPathComponent("default.yaml"))
        }
        return Data(repeating: 0x61, count: 14_842)
    }

    private func iceProcessedExtractURL() throws -> URL {
        guard let extract = optionalIceExtractURL() else {
            throw XCTSkip(
                "Set TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT to the independently downloaded Ice archives"
            )
        }
        return extract
    }

    private func optionalIceExtractURL() -> URL? {
        let roots = [
            ProcessInfo.processInfo.environment["SCHEME_PIN_ARCHIVE_ROOT"],
            "/private/tmp/rime-ice-20260630",
        ].compactMap { $0 }
        for path in roots {
            let withLua = URL(fileURLWithPath: path).appendingPathComponent("withLua")
            if FileManager.default.fileExists(
                atPath: withLua.appendingPathComponent("default.yaml").path
            ) {
                return withLua
            }
        }
        return nil
    }

    private func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

/// Test-only FileManager seam for Q-P2-01. Fails exactly once on the Nth
/// `moveItem`, then delegates so production `rollbackSchemaUninstall` can
/// restore already-moved paths. Default production installer behavior is unchanged.
private final class MoveItemFailureFileManager: FileManager {
    private let failingMoves: Set<Int>
    private(set) var moveCallCount = 0

    init(failOnMoveNumber: Int) {
        self.failingMoves = [failOnMoveNumber]
        super.init()
    }

    init(failingMoves: Set<Int>) {
        self.failingMoves = failingMoves
        super.init()
    }

    override func moveItem(at srcURL: URL, to dstURL: URL) throws {
        moveCallCount += 1
        if failingMoves.contains(moveCallCount) {
            throw CocoaError(.fileWriteUnknown)
        }
        try super.moveItem(at: srcURL, to: dstURL)
    }
}
