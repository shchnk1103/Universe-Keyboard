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

    // MARK: - Wanxiang exact-hash Lua ownership (pinned CNB 17.5.9)

    /// Empty `lua/data/chaifen.txt` matches the pinned empty SHA; a second
    /// non-empty map entry is planted from the extracted CNB tree when present.
    func testWanxiangExactHashLuaMatchIsStagedOnUninstall() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let wanxiangPlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)
        XCTAssertEqual(wanxiangPlan.revision, "wanxiang-plan-1")
        XCTAssertEqual(wanxiangPlan.schemaFileName, "wanxiang.schema.yaml")

        let chaifenRel = "lua/data/chaifen.txt"
        let emptyHash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        XCTAssertEqual(WanxiangLuaOwnership.sha256ByPath[chaifenRel], emptyHash)

        try plantSharedFile(env.shared, relativePath: chaifenRel, data: Data())
        XCTAssertEqual(sha256(Data()), emptyHash)

        var expectedMatched = [chaifenRel]
        if let bitBytes = optionalWanxiangExtractBytes(relativePath: "lua/wanxiang/bit.lua") {
            let bitRel = "lua/wanxiang/bit.lua"
            XCTAssertEqual(sha256(bitBytes), WanxiangLuaOwnership.sha256ByPath[bitRel])
            try plantSharedFile(env.shared, relativePath: bitRel, data: bitBytes)
            expectedMatched.append(bitRel)
        }

        try plantSharedFile(
            env.shared,
            relativePath: "wanxiang.schema.yaml",
            data: Data("wanxiang-schema".utf8)
        )

        let staging = try env.installer.stageSchemaUninstall(plan: wanxiangPlan)
        defer { try? env.installer.rollbackSchemaUninstall(staging) }

        for path in expectedMatched {
            XCTAssertTrue(
                staging.movedRelativePaths.contains(path),
                "expected owned Lua path \(path) in staging"
            )
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: env.shared.appendingPathComponent(path).path),
                "live tree should no longer hold staged \(path)"
            )
            XCTAssertTrue(
                FileManager.default.fileExists(
                    atPath: staging.rootURL.appendingPathComponent(path).path
                )
            )
        }
    }

    func testWanxiangModifiedLuaBytesAreNotStaged() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let wanxiangPlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)
        let chaifenRel = "lua/data/chaifen.txt"
        let modified = Data("user-edited-chaifen".utf8)
        XCTAssertNotEqual(sha256(modified), WanxiangLuaOwnership.sha256ByPath[chaifenRel])
        try plantSharedFile(env.shared, relativePath: chaifenRel, data: modified)
        try plantSharedFile(
            env.shared,
            relativePath: "wanxiang.schema.yaml",
            data: Data("wanxiang-schema".utf8)
        )

        let staging = try env.installer.stageSchemaUninstall(plan: wanxiangPlan)
        defer { try? env.installer.rollbackSchemaUninstall(staging) }

        XCTAssertFalse(staging.movedRelativePaths.contains(chaifenRel))
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent(chaifenRel)),
            modified
        )
    }

    func testWanxiangUnknownLuaPathIsLeftInPlaceOnUninstallCommit() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let wanxiangPlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)
        let chaifenRel = "lua/data/chaifen.txt"
        let unknownRel = "lua/user_custom.lua"
        let iceStyleRel = "lua/date_translator.lua"
        let unknownBytes = Data("user-custom-lua".utf8)
        let iceStyleBytes = Data("ice-style-lua".utf8)

        try plantSharedFile(env.shared, relativePath: chaifenRel, data: Data())
        try plantSharedFile(env.shared, relativePath: unknownRel, data: unknownBytes)
        try plantSharedFile(env.shared, relativePath: iceStyleRel, data: iceStyleBytes)
        try plantSharedFile(
            env.shared,
            relativePath: "wanxiang.schema.yaml",
            data: Data("wanxiang-schema".utf8)
        )

        let staging = try env.installer.stageSchemaUninstall(plan: wanxiangPlan)
        XCTAssertTrue(staging.movedRelativePaths.contains(chaifenRel))
        XCTAssertFalse(staging.movedRelativePaths.contains(unknownRel))
        XCTAssertFalse(staging.movedRelativePaths.contains(iceStyleRel))
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent(unknownRel)),
            unknownBytes
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent(iceStyleRel)),
            iceStyleBytes
        )

        env.installer.commitSchemaUninstall(staging, plan: wanxiangPlan)

        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent(chaifenRel).path
            )
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent(unknownRel)),
            unknownBytes
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent(iceStyleRel)),
            iceStyleBytes
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: staging.rootURL.path))
    }

    func testWanxiangSymlinkAtMappedLuaPathIsNotStaged() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let wanxiangPlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)
        let chaifenRel = "lua/data/chaifen.txt"
        let targetRel = "lua/data/chaifen-target-outside.txt"
        let linkURL = env.shared.appendingPathComponent(chaifenRel)
        let targetURL = env.shared.appendingPathComponent(targetRel)

        try FileManager.default.createDirectory(
            at: linkURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        // Empty payload matches the map hash, but the entry is a symlink so
        // resolvingSymlinksInPath must differ from the standardized file URL.
        try Data().write(to: targetURL)
        do {
            try FileManager.default.createSymbolicLink(
                at: linkURL,
                withDestinationURL: targetURL
            )
        } catch {
            throw XCTSkip("Simulator FS rejected symlink creation: \(error)")
        }

        var isDir: ObjCBool = false
        guard
            FileManager.default.fileExists(atPath: linkURL.path, isDirectory: &isDir),
            linkURL.resolvingSymlinksInPath().path != linkURL.standardizedFileURL.path
        else {
            throw XCTSkip("Created path is not a resolvable out-of-path symlink")
        }

        try plantSharedFile(
            env.shared,
            relativePath: "wanxiang.schema.yaml",
            data: Data("wanxiang-schema".utf8)
        )

        let staging = try env.installer.stageSchemaUninstall(plan: wanxiangPlan)
        defer { try? env.installer.rollbackSchemaUninstall(staging) }

        XCTAssertFalse(staging.movedRelativePaths.contains(chaifenRel))
        // Symlink node itself must remain; target bytes are untouched too.
        XCTAssertTrue(FileManager.default.fileExists(atPath: linkURL.path))
        XCTAssertEqual(try Data(contentsOf: targetURL), Data())
    }

    func testIceUninstallDoesNotStageWanxiangExactHashLuaPaths() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        let chaifenRel = "lua/data/chaifen.txt"
        let bitRel = "lua/wanxiang/bit.lua"

        try plantSharedFile(env.shared, relativePath: chaifenRel, data: Data())
        if let bitBytes = optionalWanxiangExtractBytes(relativePath: bitRel) {
            try plantSharedFile(env.shared, relativePath: bitRel, data: bitBytes)
        } else {
            // Still plant matching empty bytes under a Wanxiang map path Ice
            // does not list in removableFiles.
            try plantSharedFile(env.shared, relativePath: bitRel, data: Data())
        }
        try plantSharedFile(
            env.shared,
            relativePath: "rime_ice.schema.yaml",
            data: Data("ice-schema".utf8)
        )

        let staging = try env.installer.stageSchemaUninstall(plan: icePlan)
        defer { try? env.installer.rollbackSchemaUninstall(staging) }

        XCTAssertFalse(staging.movedRelativePaths.contains(chaifenRel))
        XCTAssertFalse(staging.movedRelativePaths.contains(bitRel))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent(chaifenRel).path
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent(bitRel).path
            )
        )
        XCTAssertTrue(staging.movedRelativePaths.contains("rime_ice.schema.yaml"))
    }

    // MARK: - Wanxiang upgrade-rollback (contract 2026-09-08)

    func testWanxiangUpgradeMidCopyFailureRestoresPriorGeneration() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        let plan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)

        let priorSchema = Data("prior-wanxiang-schema".utf8)
        let priorDict = Data("prior-wanxiang-dict".utf8)
        let unknownBytes = Data("user-unknown-keep".utf8)
        try plantSharedFile(env.shared, relativePath: "wanxiang.schema.yaml", data: priorSchema)
        try plantSharedFile(env.shared, relativePath: "wanxiang.dict.yaml", data: priorDict)
        try plantSharedFile(env.shared, relativePath: "lua/user_custom.lua", data: unknownBytes)

        let extract = env.root.appendingPathComponent("extract", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try Data("new-wanxiang-schema".utf8).write(
            to: extract.appendingPathComponent("wanxiang.schema.yaml")
        )
        try Data("new-wanxiang-dict".utf8).write(
            to: extract.appendingPathComponent("wanxiang.dict.yaml")
        )

        let failingFM = CopyItemFailureFileManager(failOnCopyNumber: 3)
        let installer = SharedContainerSchemaArchiveInstaller(
            appGroupID: "test",
            fileManager: failingFM,
            containerURL: env.root.appendingPathComponent("container")
        )

        let checkpoint = try XCTUnwrap(
            try installer.createUpgradeCheckpoint(plan: plan, luaAvailable: true)
        )
        XCTAssertTrue(checkpoint.rootURL.lastPathComponent.hasPrefix(".schema-upgrade-"))
        XCTAssertTrue(checkpoint.copiedRelativePaths.contains("wanxiang.schema.yaml"))
        XCTAssertFalse(checkpoint.copiedRelativePaths.contains("lua/user_custom.lua"))

        XCTAssertThrowsError(
            try installer.installSchemaFiles(from: extract, plan: plan, luaAvailable: true)
        )

        do {
            try installer.restoreUpgradeCheckpoint(checkpoint)
            XCTAssertEqual(
                try Data(contentsOf: env.shared.appendingPathComponent("wanxiang.schema.yaml")),
                priorSchema
            )
            XCTAssertEqual(
                try Data(contentsOf: env.shared.appendingPathComponent("wanxiang.dict.yaml")),
                priorDict
            )
            XCTAssertFalse(FileManager.default.fileExists(atPath: checkpoint.rootURL.path))
        } catch {
            // Restore itself failed: checkpoint must remain; no silent deletion.
            XCTAssertTrue(error is SchemaUpgradeRecoveryError)
            XCTAssertTrue(FileManager.default.fileExists(atPath: checkpoint.rootURL.path))
            XCTAssertEqual(
                try Data(contentsOf: checkpoint.rootURL.appendingPathComponent("wanxiang.schema.yaml")),
                priorSchema
            )
        }

        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("lua/user_custom.lua")),
            unknownBytes,
            "unknown/user path must be preserved on upgrade failure path"
        )
    }

    func testWanxiangUpgradeRestoreFailureRetainsCheckpoint() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        let plan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)

        let priorSchema = Data("prior-schema-bytes".utf8)
        try plantSharedFile(env.shared, relativePath: "wanxiang.schema.yaml", data: priorSchema)
        try plantSharedFile(
            env.shared,
            relativePath: "wanxiang.dict.yaml",
            data: Data("prior-dict".utf8)
        )

        let installer = SharedContainerSchemaArchiveInstaller(
            appGroupID: "test",
            containerURL: env.root.appendingPathComponent("container")
        )
        let checkpoint = try XCTUnwrap(
            try installer.createUpgradeCheckpoint(plan: plan, luaAvailable: true)
        )

        // Simulate a failed upgrade that mutated live files.
        try Data("partial-new".utf8).write(
            to: env.shared.appendingPathComponent("wanxiang.schema.yaml")
        )

        let failingRestore = SharedContainerSchemaArchiveInstaller(
            appGroupID: "test",
            fileManager: CopyItemFailureFileManager(failOnCopyNumber: 1),
            containerURL: env.root.appendingPathComponent("container")
        )
        XCTAssertThrowsError(try failingRestore.restoreUpgradeCheckpoint(checkpoint)) { error in
            XCTAssertTrue(error is SchemaUpgradeRecoveryError)
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: checkpoint.rootURL.path))
        XCTAssertEqual(
            try Data(contentsOf: checkpoint.rootURL.appendingPathComponent("wanxiang.schema.yaml")),
            priorSchema
        )
    }

    func testWanxiangFirstInstallCreatesNoUpgradeCheckpoint() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        let plan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)

        // No prior Wanxiang generation present.
        let checkpoint = try env.installer.createUpgradeCheckpoint(plan: plan, luaAvailable: true)
        XCTAssertNil(checkpoint)

        let extract = env.root.appendingPathComponent("extract-first", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try Data("first-schema".utf8).write(
            to: extract.appendingPathComponent("wanxiang.schema.yaml")
        )
        try env.installer.installSchemaFiles(from: extract, plan: plan, luaAvailable: true)
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("wanxiang.schema.yaml")),
            Data("first-schema".utf8)
        )
        let pollution = try FileManager.default.contentsOfDirectory(atPath: env.shared.path)
        XCTAssertFalse(
            pollution.contains(where: { $0.hasPrefix(".schema-upgrade-") }),
            "first install must not leave a spurious upgrade checkpoint"
        )
    }

    func testWanxiangUpgradeFailurePreservesUnknownUserPath() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        let plan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)

        let unknownBytes = Data("keep-me-unknown".utf8)
        try plantSharedFile(env.shared, relativePath: "wanxiang.schema.yaml", data: Data("old".utf8))
        try plantSharedFile(env.shared, relativePath: "lua/user_custom.lua", data: unknownBytes)

        let extract = env.root.appendingPathComponent("extract-up", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try Data("new".utf8).write(to: extract.appendingPathComponent("wanxiang.schema.yaml"))

        let installer = SharedContainerSchemaArchiveInstaller(
            appGroupID: "test",
            fileManager: CopyItemFailureFileManager(failOnCopyNumber: 2),
            containerURL: env.root.appendingPathComponent("container")
        )
        let checkpoint = try XCTUnwrap(
            try installer.createUpgradeCheckpoint(plan: plan, luaAvailable: true)
        )
        XCTAssertThrowsError(
            try installer.installSchemaFiles(from: extract, plan: plan, luaAvailable: true)
        )
        try? installer.restoreUpgradeCheckpoint(checkpoint)

        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("lua/user_custom.lua")),
            unknownBytes
        )
        XCTAssertFalse(checkpoint.copiedRelativePaths.contains("lua/user_custom.lua"))
    }

    // MARK: - Cross-scheme matrix CS-01 / CS-02 (first coding freeze §6.2–§6.3)

    /// CS-01: Ice then Wanxiang. Both installed; peer retain / preserve; activate just-installed.
    func testCS01_IceThenWanxiang_BothInstalledPeerRetainedAndJustInstalledActivated() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        var selection = CrossSchemeSelectionTracker()

        try plantSharedFile(
            env.shared,
            relativePath: CrossSchemeDualInstall.unknownRelativePath,
            data: CrossSchemeDualInstall.unknownBytes
        )
        let preludeBefore = try Data(contentsOf: env.defaultYAMLURL)
        let openccBefore = sampleBuiltinOpenCCFingerprint(shared: env.shared)

        try installIcePinnedIntoShared(env: env, selection: &selection)
        XCTAssertEqual(selection.activeSchemaID, "rime_ice")
        XCTAssertTrue(
            env.installer.containsInstalledSchema(
                plan: try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
            )
        )

        try installWanxiangPinnedIntoShared(env: env, selection: &selection)
        XCTAssertEqual(
            selection.activeSchemaID,
            "wanxiang",
            "approved post-install policy: activate the scheme just installed"
        )

        try assertDualInstallPeerInventory(
            env: env,
            preludeBefore: preludeBefore,
            openccBefore: openccBefore
        )
    }

    /// CS-02: Wanxiang then Ice. Symmetric to CS-01; Ice must not reclaim default.yaml.
    func testCS02_WanxiangThenIce_BothInstalledPeerRetainedAndJustInstalledActivated() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        var selection = CrossSchemeSelectionTracker()

        try plantSharedFile(
            env.shared,
            relativePath: CrossSchemeDualInstall.unknownRelativePath,
            data: CrossSchemeDualInstall.unknownBytes
        )
        let preludeBefore = try Data(contentsOf: env.defaultYAMLURL)
        let openccBefore = sampleBuiltinOpenCCFingerprint(shared: env.shared)

        try installWanxiangPinnedIntoShared(env: env, selection: &selection)
        XCTAssertEqual(selection.activeSchemaID, "wanxiang")
        XCTAssertTrue(
            env.installer.containsInstalledSchema(
                plan: try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)
            )
        )

        try installIcePinnedIntoShared(env: env, selection: &selection)
        XCTAssertEqual(
            selection.activeSchemaID,
            "rime_ice",
            "approved post-install policy: activate the scheme just installed"
        )

        try assertDualInstallPeerInventory(
            env: env,
            preludeBefore: preludeBefore,
            openccBefore: openccBefore
        )
        XCTAssertEqual(
            try Data(contentsOf: env.defaultYAMLURL),
            preludeBefore,
            "Ice install must not reclaim Prelude default.yaml"
        )
    }

    // MARK: - Cross-scheme matrix CS-03 / CS-04 (repeat install; peer retain)

    /// CS-03: Dual-installed; repeat Ice with unchanged staged identity → no-op.
    /// Peer Wanxiang retained; selection not thrashed (activate-just-installed is
    /// for real installs only).
    func testCS03_RepeatIceSameIdentity_NoOpKeepsWanxiangPeerAndSelection() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        var selection = CrossSchemeSelectionTracker()

        try plantSharedFile(
            env.shared,
            relativePath: CrossSchemeDualInstall.unknownRelativePath,
            data: CrossSchemeDualInstall.unknownBytes
        )
        let preludeBefore = try Data(contentsOf: env.defaultYAMLURL)
        let openccBefore = sampleBuiltinOpenCCFingerprint(shared: env.shared)

        try installIcePinnedIntoShared(env: env, selection: &selection)
        try installWanxiangPinnedIntoShared(env: env, selection: &selection)
        XCTAssertEqual(selection.activeSchemaID, "wanxiang")

        let iceSchemaBefore = try Data(
            contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml")
        )
        let wanxiangSchemaBefore = try Data(
            contentsOf: env.shared.appendingPathComponent("wanxiang.schema.yaml")
        )
        let iceIdentity = try catalogStagedIdentity(schemaID: "rime_ice")
        let stagedSHA = iceIdentity.stagedContentSHA256WithLua
        let settings = CrossSchemeHarnessSettingsStore(
            values: [
                "rime_active_schema": selection.activeSchemaID,
                "rime_ice_installed": true,
                "rime_ice_version": iceIdentity.version,
                "rime_ice_staged_content_checksum": stagedSHA,
                "wanxiang_installed": true,
            ]
        )
        let manager = SchemaManager(settings: settings, archiveInstaller: env.installer)
        XCTAssertTrue(
            manager.shouldSkipIdenticalReinstall(
                schemaID: "rime_ice",
                stagedContentSHA256: stagedSHA
            ),
            "identical Ice receipt must take the production no-op seam"
        )
        // No-op path: do not reinstall / do not activateJustInstalled.
        XCTAssertEqual(
            selection.activeSchemaID,
            "wanxiang",
            "no-op must keep current selection (Wanxiang)"
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml")),
            iceSchemaBefore,
            "Ice files must not be wiped on identical reinstall no-op"
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("wanxiang.schema.yaml")),
            wanxiangSchemaBefore,
            "peer Wanxiang must be retained"
        )
        try assertDualInstallPeerInventory(
            env: env,
            preludeBefore: preludeBefore,
            openccBefore: openccBefore
        )
        XCTAssertFalse(
            manager.shouldSkipIdenticalReinstall(
                schemaID: "rime_ice",
                stagedContentSHA256: String(repeating: "a", count: 64)
            ),
            "mismatched staged identity must not no-op"
        )
    }

    /// CS-04: Dual-installed; repeat Wanxiang with unchanged identity → no-op.
    /// Peer Ice retained; selection unchanged.
    func testCS04_RepeatWanxiangSameIdentity_NoOpKeepsIcePeerAndSelection() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        var selection = CrossSchemeSelectionTracker()

        try plantSharedFile(
            env.shared,
            relativePath: CrossSchemeDualInstall.unknownRelativePath,
            data: CrossSchemeDualInstall.unknownBytes
        )
        let preludeBefore = try Data(contentsOf: env.defaultYAMLURL)
        let openccBefore = sampleBuiltinOpenCCFingerprint(shared: env.shared)

        try installWanxiangPinnedIntoShared(env: env, selection: &selection)
        try installIcePinnedIntoShared(env: env, selection: &selection)
        XCTAssertEqual(selection.activeSchemaID, "rime_ice")

        let iceSchemaBefore = try Data(
            contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml")
        )
        let wanxiangSchemaBefore = try Data(
            contentsOf: env.shared.appendingPathComponent("wanxiang.schema.yaml")
        )
        let wanxiangIdentity = try catalogStagedIdentity(schemaID: "wanxiang")
        let stagedSHA = wanxiangIdentity.stagedContentSHA256WithLua
        let settings = CrossSchemeHarnessSettingsStore(
            values: [
                "rime_active_schema": selection.activeSchemaID,
                "wanxiang_installed": true,
                "wanxiang_version": wanxiangIdentity.version,
                "wanxiang_staged_content_checksum": stagedSHA,
                "rime_ice_installed": true,
            ]
        )
        let manager = SchemaManager(settings: settings, archiveInstaller: env.installer)
        XCTAssertTrue(
            manager.shouldSkipIdenticalReinstall(
                schemaID: "wanxiang",
                stagedContentSHA256: stagedSHA
            ),
            "identical Wanxiang receipt must take the production no-op seam"
        )
        XCTAssertEqual(
            selection.activeSchemaID,
            "rime_ice",
            "no-op must keep current selection (Ice)"
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("wanxiang.schema.yaml")),
            wanxiangSchemaBefore
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml")),
            iceSchemaBefore,
            "peer Ice must be retained"
        )
        try assertDualInstallPeerInventory(
            env: env,
            preludeBefore: preludeBefore,
            openccBefore: openccBefore
        )
    }

    /// CS-04 identity-change path: prior Wanxiang generation uses upgrade-rollback
    /// checkpoint/replace; Ice peer paths and unknown/user files stay intact.
    func testCS04_WanxiangIdentityChange_UpgradeRollbackPreservesIcePeer() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        var selection = CrossSchemeSelectionTracker()

        try plantSharedFile(
            env.shared,
            relativePath: CrossSchemeDualInstall.unknownRelativePath,
            data: CrossSchemeDualInstall.unknownBytes
        )
        let preludeBefore = try Data(contentsOf: env.defaultYAMLURL)
        let openccBefore = sampleBuiltinOpenCCFingerprint(shared: env.shared)

        try installIcePinnedIntoShared(env: env, selection: &selection)
        try installWanxiangPinnedIntoShared(env: env, selection: &selection)

        let iceSchemaBefore = try Data(
            contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml")
        )
        let iceLuaURL = env.shared.appendingPathComponent(
            CrossSchemeDualInstall.iceLuaRelativePath
        )
        let iceLuaBefore =
            FileManager.default.fileExists(atPath: iceLuaURL.path)
            ? try Data(contentsOf: iceLuaURL) : nil

        let wanxiangPlan = try XCTUnwrap(
            RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan
        )
        let wanxiangIdentity = try catalogStagedIdentity(schemaID: "wanxiang")
        let settings = CrossSchemeHarnessSettingsStore(
            values: [
                "rime_active_schema": selection.activeSchemaID,
                "wanxiang_installed": true,
                "wanxiang_version": wanxiangIdentity.version,
                // Prior receipt differs from the bytes we are about to stage.
                "wanxiang_staged_content_checksum": wanxiangIdentity.stagedContentSHA256WithLua,
                "rime_ice_installed": true,
            ]
        )
        let manager = SchemaManager(settings: settings, archiveInstaller: env.installer)
        let upgradedStaged = String(repeating: "b", count: 64)
        XCTAssertFalse(
            manager.shouldSkipIdenticalReinstall(
                schemaID: "wanxiang",
                stagedContentSHA256: upgradedStaged
            ),
            "changed identity must not no-op; upgrade-rollback path applies"
        )

        let checkpoint = try env.installer.createUpgradeCheckpoint(
            plan: wanxiangPlan,
            luaAvailable: true
        )
        XCTAssertNotNil(
            checkpoint,
            "prior Wanxiang generation must create an upgrade checkpoint"
        )

        let extract = env.root.appendingPathComponent(
            "wanxiang-upgrade-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        let upgradedSchema = Data("wanxiang-schema-upgraded-identity".utf8)
        try upgradedSchema.write(to: extract.appendingPathComponent("wanxiang.schema.yaml"))
        try plantSharedFile(
            extract,
            relativePath: CrossSchemeDualInstall.wanxiangChaifenRelativePath,
            data: Data("upgraded-chaifen".utf8)
        )
        try env.installer.installSchemaFiles(
            from: extract,
            plan: wanxiangPlan,
            luaAvailable: true
        )
        selection.activateJustInstalled("wanxiang")

        if let checkpoint {
            env.installer.commitUpgradeCheckpoint(checkpoint)
        }

        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("wanxiang.schema.yaml")),
            upgradedSchema
        )
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml")),
            iceSchemaBefore,
            "Ice peer must survive Wanxiang upgrade-rollback replace"
        )
        if let iceLuaBefore {
            XCTAssertEqual(try Data(contentsOf: iceLuaURL), iceLuaBefore)
        }
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), preludeBefore)
        if let openccBefore {
            XCTAssertEqual(
                try Data(contentsOf: env.shared.appendingPathComponent(openccBefore.path)),
                openccBefore.data
            )
        }
        XCTAssertEqual(
            try Data(
                contentsOf: env.shared.appendingPathComponent(
                    CrossSchemeDualInstall.unknownRelativePath
                )
            ),
            CrossSchemeDualInstall.unknownBytes
        )
        XCTAssertTrue(
            env.installer.containsInstalledSchema(
                plan: try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
            )
        )
        XCTAssertEqual(selection.activeSchemaID, "wanxiang")
    }

    /// CS-05: with Wanxiang active, uninstalling inactive Ice removes only Ice
    /// ownership and leaves Wanxiang's schema, exact-hash Lua, and user paths.
    func testCS05_UninstallInactiveIceRetainsWanxiangPeerInventory() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        var selection = CrossSchemeSelectionTracker()

        try plantSharedFile(
            env.shared,
            relativePath: CrossSchemeDualInstall.unknownRelativePath,
            data: CrossSchemeDualInstall.unknownBytes
        )
        try installIcePinnedIntoShared(env: env, selection: &selection)
        try installWanxiangPinnedIntoShared(env: env, selection: &selection)
        XCTAssertEqual(selection.activeSchemaID, "wanxiang")

        let wanxiangSchemaURL = env.shared.appendingPathComponent("wanxiang.schema.yaml")
        let wanxiangSchemaBefore = try Data(contentsOf: wanxiangSchemaURL)
        let chaifenURL = env.shared.appendingPathComponent(
            CrossSchemeDualInstall.wanxiangChaifenRelativePath
        )
        let chaifenBefore = try Data(contentsOf: chaifenURL)
        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)

        let staging = try env.installer.stageSchemaUninstall(plan: icePlan)
        env.installer.commitSchemaUninstall(staging, plan: icePlan)

        XCTAssertFalse(env.installer.containsInstalledSchema(plan: icePlan))
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent("rime_ice_preset.yaml").path
            )
        )
        XCTAssertEqual(try Data(contentsOf: wanxiangSchemaURL), wanxiangSchemaBefore)
        XCTAssertEqual(try Data(contentsOf: chaifenURL), chaifenBefore)
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent(CrossSchemeDualInstall.unknownRelativePath)),
            CrossSchemeDualInstall.unknownBytes
        )
        XCTAssertEqual(selection.activeSchemaID, "wanxiang")
    }

    /// CS-06: with Ice active, uninstalling inactive Wanxiang removes only
    /// Wanxiang ownership and retains Ice Lua plus unknown/user paths.
    func testCS06_UninstallInactiveWanxiangRetainsIcePeerInventory() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }
        var selection = CrossSchemeSelectionTracker()

        try plantSharedFile(
            env.shared,
            relativePath: CrossSchemeDualInstall.unknownRelativePath,
            data: CrossSchemeDualInstall.unknownBytes
        )
        try installWanxiangPinnedIntoShared(env: env, selection: &selection)
        try installIcePinnedIntoShared(env: env, selection: &selection)
        XCTAssertEqual(selection.activeSchemaID, "rime_ice")

        let iceSchemaURL = env.shared.appendingPathComponent("rime_ice.schema.yaml")
        let iceSchemaBefore = try Data(contentsOf: iceSchemaURL)
        let iceLuaURL = env.shared.appendingPathComponent(CrossSchemeDualInstall.iceLuaRelativePath)
        let iceLuaBefore = try Data(contentsOf: iceLuaURL)
        let wanxiangPlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)

        let staging = try env.installer.stageSchemaUninstall(plan: wanxiangPlan)
        env.installer.commitSchemaUninstall(staging, plan: wanxiangPlan)

        XCTAssertFalse(env.installer.containsInstalledSchema(plan: wanxiangPlan))
        XCTAssertEqual(try Data(contentsOf: iceSchemaURL), iceSchemaBefore)
        XCTAssertEqual(try Data(contentsOf: iceLuaURL), iceLuaBefore)
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent(CrossSchemeDualInstall.unknownRelativePath)),
            CrossSchemeDualInstall.unknownBytes
        )
        XCTAssertEqual(selection.activeSchemaID, "rime_ice")
    }

    /// In-harness selection for approved CS-01/02 policy (activate just-installed).
    /// CS-03/04 no-op keeps this tracker unchanged; real installs still activate.
    private struct CrossSchemeSelectionTracker {
        var activeSchemaID: String = "luna_pinyin"

        mutating func activateJustInstalled(_ schemaID: String) {
            activeSchemaID = schemaID
        }
    }

    private enum CrossSchemeDualInstall {
        static let unknownRelativePath = "lua/user_custom_cross_scheme.lua"
        static let unknownBytes = Data("cross-scheme-unknown-keep".utf8)
        static let iceLuaRelativePath = "lua/date_translator.lua"
        static let wanxiangBitRelativePath = "lua/wanxiang/bit.lua"
        static let wanxiangChaifenRelativePath = "lua/data/chaifen.txt"
    }

    private func catalogStagedIdentity(schemaID: String) throws -> RimeSchemeStagedIdentity {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: schemaID))
        let manifest = try XCTUnwrap(entry.distribution?.manifest)
        let source = try XCTUnwrap(manifest.sourceVariants.first)
        return try manifest.resolvedStagedIdentity(for: source)
    }

    private func sampleBuiltinOpenCCFingerprint(shared: URL) -> (path: String, data: Data)? {
        let candidates = [
            "opencc/t2s.json",
            "opencc/s2t.json",
            "opencc/TSCharacters.txt",
            "opencc/STCharacters.txt",
        ]
        for rel in candidates {
            let url = shared.appendingPathComponent(rel)
            if let data = try? Data(contentsOf: url) {
                return (rel, data)
            }
        }
        return nil
    }

    private func installIcePinnedIntoShared(
        env: Environment,
        selection: inout CrossSchemeSelectionTracker
    ) throws {
        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        XCTAssertEqual(icePlan.revision, "rime-ice-plan-2")
        let extract = env.root.appendingPathComponent(
            "ice-extract-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)

        if let fixture = optionalIceExtractURL() {
            let admitted = [
                "default.yaml",
                "rime_ice.schema.yaml",
                "rime_ice.dict.yaml",
                "radical_pinyin.schema.yaml",
                "radical_pinyin.dict.yaml",
                "melt_eng.schema.yaml",
                "melt_eng.dict.yaml",
                "symbols_v.yaml",
                "symbols_caps_v.yaml",
                "custom_phrase.txt",
                "t9.schema.yaml",
                CrossSchemeDualInstall.iceLuaRelativePath,
                "opencc/emoji.json",
                "opencc/emoji.txt",
            ]
            for rel in admitted {
                let src = fixture.appendingPathComponent(rel)
                guard FileManager.default.fileExists(atPath: src.path) else { continue }
                let dst = extract.appendingPathComponent(rel)
                try FileManager.default.createDirectory(
                    at: dst.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                if FileManager.default.fileExists(atPath: dst.path) {
                    try FileManager.default.removeItem(at: dst)
                }
                try FileManager.default.copyItem(at: src, to: dst)
            }
            let cold = fixture.appendingPathComponent("lua/cold_word_drop")
            if FileManager.default.fileExists(atPath: cold.path) {
                let names =
                    (try? FileManager.default.contentsOfDirectory(atPath: cold.path)) ?? []
                if let first = names.first {
                    let rel = "lua/cold_word_drop/\(first)"
                    let dst = extract.appendingPathComponent(rel)
                    try FileManager.default.createDirectory(
                        at: dst.deletingLastPathComponent(),
                        withIntermediateDirectories: true
                    )
                    try FileManager.default.copyItem(
                        at: cold.appendingPathComponent(first),
                        to: dst
                    )
                }
            }
            try RimeIceSharedDefaultAdapter.apply(in: extract)
        } else {
            try plantSharedFile(
                extract,
                relativePath: CrossSchemeDualInstall.iceLuaRelativePath,
                data: Data("ice-date-translator".utf8)
            )
            try Data("ice-schema".utf8).write(
                to: extract.appendingPathComponent("rime_ice.schema.yaml")
            )
            try iceDefaultYAMLData().write(
                to: extract.appendingPathComponent(RimeIceSharedDefaultAdapter.presetFileName)
            )
        }

        try env.installer.installSchemaFiles(from: extract, plan: icePlan, luaAvailable: true)
        selection.activateJustInstalled("rime_ice")
    }

    private func installWanxiangPinnedIntoShared(
        env: Environment,
        selection: inout CrossSchemeSelectionTracker
    ) throws {
        let wanxiangPlan = try XCTUnwrap(
            RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan
        )
        XCTAssertEqual(wanxiangPlan.revision, "wanxiang-plan-1")
        let extract = env.root.appendingPathComponent(
            "wanxiang-extract-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)

        let pinRoots = [
            ProcessInfo.processInfo.environment["SCHEME_WANXIANG_EXTRACT_ROOT"],
            "/private/tmp/rime-wanxiang-1759/extract",
        ].compactMap { $0 }
        var usedPin = false
        for path in pinRoots {
            let root = URL(fileURLWithPath: path)
            let schema = root.appendingPathComponent("wanxiang.schema.yaml")
            guard FileManager.default.fileExists(atPath: schema.path) else { continue }
            let admittedFiles = [
                "wanxiang.schema.yaml",
                "wanxiang.dict.yaml",
                "wanxiang_algebra.yaml",
                "wanxiang_symbols.yaml",
                "wanxiang_english.schema.yaml",
                "wanxiang_english.dict.yaml",
                "wanxiang_mixedcode.schema.yaml",
                "wanxiang_mixedcode.dict.yaml",
                "wanxiang_reverse.schema.yaml",
                "wanxiang_reverse.dict.yaml",
                "wanxiang_t9.schema.yaml",
                "wanxiang_t9i.schema.yaml",
                "default.yaml",  // plan must skip installing over Prelude
            ]
            for rel in admittedFiles {
                let src = root.appendingPathComponent(rel)
                guard FileManager.default.fileExists(atPath: src.path) else { continue }
                let dst = extract.appendingPathComponent(rel)
                if FileManager.default.fileExists(atPath: dst.path) {
                    try FileManager.default.removeItem(at: dst)
                }
                try FileManager.default.copyItem(at: src, to: dst)
            }
            let chaifenDst = extract.appendingPathComponent(
                CrossSchemeDualInstall.wanxiangChaifenRelativePath
            )
            try FileManager.default.createDirectory(
                at: chaifenDst.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let chaifenSrc = root.appendingPathComponent(
                CrossSchemeDualInstall.wanxiangChaifenRelativePath
            )
            if FileManager.default.fileExists(atPath: chaifenSrc.path) {
                try FileManager.default.copyItem(at: chaifenSrc, to: chaifenDst)
            } else {
                try Data().write(to: chaifenDst)
            }
            if let bitBytes = optionalWanxiangExtractBytes(
                relativePath: CrossSchemeDualInstall.wanxiangBitRelativePath
            ) {
                try plantSharedFile(
                    extract,
                    relativePath: CrossSchemeDualInstall.wanxiangBitRelativePath,
                    data: bitBytes
                )
            }
            usedPin = true
            break
        }
        if !usedPin {
            try Data("wanxiang-schema".utf8).write(
                to: extract.appendingPathComponent("wanxiang.schema.yaml")
            )
            try plantSharedFile(
                extract,
                relativePath: CrossSchemeDualInstall.wanxiangChaifenRelativePath,
                data: Data()
            )
        }

        try env.installer.installSchemaFiles(
            from: extract,
            plan: wanxiangPlan,
            luaAvailable: true
        )
        selection.activateJustInstalled("wanxiang")
    }

    private func assertDualInstallPeerInventory(
        env: Environment,
        preludeBefore: Data,
        openccBefore: (path: String, data: Data)?
    ) throws {
        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        let wanxiangPlan = try XCTUnwrap(
            RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan
        )
        XCTAssertTrue(env.installer.containsInstalledSchema(plan: icePlan))
        XCTAssertTrue(env.installer.containsInstalledSchema(plan: wanxiangPlan))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent("rime_ice.schema.yaml").path
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent("wanxiang.schema.yaml").path
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent(
                    RimeIceSharedDefaultAdapter.presetFileName
                ).path
            ),
            "Ice private preset must coexist; Prelude default.yaml is not reclaimed"
        )

        XCTAssertEqual(
            try Data(contentsOf: env.defaultYAMLURL),
            preludeBefore,
            "Prelude / official default.yaml baseline must remain intact"
        )
        if let openccBefore {
            XCTAssertEqual(
                try Data(contentsOf: env.shared.appendingPathComponent(openccBefore.path)),
                openccBefore.data,
                "Builtin OpenCC baseline \(openccBefore.path) must remain intact"
            )
        }

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent(
                    CrossSchemeDualInstall.iceLuaRelativePath
                ).path
            ),
            "Ice Lua must be retained across peer install"
        )

        let chaifenURL = env.shared.appendingPathComponent(
            CrossSchemeDualInstall.wanxiangChaifenRelativePath
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: chaifenURL.path))
        XCTAssertEqual(
            sha256(try Data(contentsOf: chaifenURL)),
            WanxiangLuaOwnership.sha256ByPath[
                CrossSchemeDualInstall.wanxiangChaifenRelativePath
            ]
        )
        let bitURL = env.shared.appendingPathComponent(
            CrossSchemeDualInstall.wanxiangBitRelativePath
        )
        if FileManager.default.fileExists(atPath: bitURL.path) {
            XCTAssertEqual(
                sha256(try Data(contentsOf: bitURL)),
                WanxiangLuaOwnership.sha256ByPath[
                    CrossSchemeDualInstall.wanxiangBitRelativePath
                ],
                "Wanxiang exact-hash bit.lua when feasible"
            )
        }

        XCTAssertEqual(
            try Data(
                contentsOf: env.shared.appendingPathComponent(
                    CrossSchemeDualInstall.unknownRelativePath
                )
            ),
            CrossSchemeDualInstall.unknownBytes,
            "unknown/user files must remain untouched"
        )
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

    private func plantSharedFile(_ shared: URL, relativePath: String, data: Data) throws {
        let url = shared.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url)
    }

    private func optionalWanxiangExtractBytes(relativePath: String) -> Data? {
        let roots = [
            ProcessInfo.processInfo.environment["SCHEME_WANXIANG_EXTRACT_ROOT"],
            "/private/tmp/rime-wanxiang-1759/extract",
        ].compactMap { $0 }
        for path in roots {
            let url = URL(fileURLWithPath: path).appendingPathComponent(relativePath)
            if let data = try? Data(contentsOf: url) {
                return data
            }
        }
        return nil
    }

    private func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

/// Minimal settings store for CS-03/04 identical-receipt no-op decisions against
/// the real dual-install container installer.
@MainActor
private final class CrossSchemeHarnessSettingsStore: SharedSettingsStoring {
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

/// Test-only FileManager seam for Wanxiang upgrade-rollback. Fails exactly
/// once on the Nth `copyItem`, then delegates so checkpoint create/restore
/// and `installSchemaFiles` can be fault-injected independently of moves.
private final class CopyItemFailureFileManager: FileManager {
    private let failOnCopyNumber: Int
    private(set) var copyCallCount = 0

    init(failOnCopyNumber: Int) {
        self.failOnCopyNumber = failOnCopyNumber
        super.init()
    }

    override func copyItem(at srcURL: URL, to dstURL: URL) throws {
        copyCallCount += 1
        if copyCallCount == failOnCopyNumber {
            throw CocoaError(.fileWriteUnknown)
        }
        try super.copyItem(at: srcURL, to: dstURL)
    }
}
