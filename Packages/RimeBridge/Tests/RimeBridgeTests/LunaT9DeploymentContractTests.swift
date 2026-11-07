import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

final class LunaT9DeploymentContractTests: XCTestCase {
    private typealias Support = LunaT9DeploymentSupport
    private typealias Point = Support.Point

    func testFreshAndExistingCombinationsConvergeAndBindPatchToCurrentSource() throws {
        for existing in [false, true] {
            for oldSource in [false, true] {
                for oldOverlay in [false, true] {
                    let fixture = try Fixture(existing: existing, oldSource: oldSource, oldOverlay: oldOverlay)
                    let transaction = try Support(scenario: fixture.scene)
                    let first = try transaction.deploy(sourceRoot: fixture.newResources)
                    XCTAssertEqual(first.sourceSHA256, LunaT9SchemaCompatibility.outputSHA256)
                    XCTAssertEqual(first.patchInputSHA256, first.sourceSHA256)
                    XCTAssertEqual(try fixture.read(Support.derivedPath), fixture.variant)
                    let patch = try XCTUnwrap(String(data: fixture.read(Support.derivedOverlayPath), encoding: .utf8))
                    XCTAssertTrue(patch.contains("# compile-input-sha256: \(first.sourceSHA256)\n"))
                    XCTAssertTrue(patch.contains("speller/algebra:"))
                    XCTAssertEqual(patch.components(separatedBy: "- xlit/").count, 2)
                    try fixture.assertAuthorized()
                    let committed = try fixture.snapshot()
                    let second = try Support(scenario: fixture.scene).deploy(sourceRoot: fixture.newResources)
                    XCTAssertEqual(first, second)
                    XCTAssertEqual(try fixture.snapshot(), committed)
                    try fixture.assertCachesClearedAndUnrelatedPreserved()
                    try fixture.assertNoMarkersOrDictionaryMutation()
                    print(
                        "SCENARIO_PASS success existing=\(existing) source=\(oldSource) overlay=\(oldOverlay) \(fixture.scene.path)"
                    )
                }
            }
        }
    }

    func testEveryForwardFailureRestoresBytesOrNonexistenceThenRedeploys() throws {
        let points: [Point] = [
            .backupResources, .backupSource, .backupOverlays, .backupReceipts,
            .resourceWrite, .resourceReceiptWrite, .sourceWrite, .sourceReplace,
            .overlayWrite, .overlayReplace, .overlayReceiptWrite, .cacheDelete,
        ]
        for existing in [false, true] {
            for oldSource in [false, true] {
                for oldOverlay in [false, true] {
                    for point in points {
                        let fixture = try Fixture(existing: existing, oldSource: oldSource, oldOverlay: oldOverlay)
                        let before = try fixture.snapshot()
                        // Fail after one resource/overlay/cache operation to exercise partial mutation too.
                        let occurrence =
                            [.resourceWrite, .overlayWrite, .overlayReplace, .cacheDelete].contains(point) ? 2 : 1
                        var hits = 0
                        let transaction = try Support(scenario: fixture.scene) { visited in
                            guard visited == point else { return }
                            hits += 1
                            if hits == occurrence { throw Support.TransactionError.injected(point) }
                        }
                        XCTAssertThrowsError(try transaction.deploy(sourceRoot: fixture.newResources)) { error in
                            XCTAssertEqual(error as? Support.TransactionError, .injected(point))
                        }
                        XCTAssertEqual(hits, occurrence, "Injection must actually execute: \(point)")
                        XCTAssertEqual(try fixture.snapshot(), before, "\(point) \(fixture.scene.path)")
                        if existing { try fixture.assertAuthorized() }
                        try fixture.assertNoMarkersOrDictionaryMutation()
                        let recovered = try Support(scenario: fixture.scene).deploy(sourceRoot: fixture.newResources)
                        XCTAssertEqual(recovered.patchInputSHA256, LunaT9SchemaCompatibility.outputSHA256)
                        XCTAssertEqual(try fixture.read(Support.derivedPath), fixture.variant)
                        try fixture.assertAuthorized()
                        try fixture.assertCachesClearedAndUnrelatedPreserved()
                        print(
                            "SCENARIO_PASS rollback \(point.rawValue) existing=\(existing) source=\(oldSource) overlay=\(oldOverlay) \(fixture.scene.path)"
                        )
                    }
                }
            }
        }
    }

    func testRollbackFailureSurvivesOuterBoundaryAndRetainsRecoverableBackups() throws {
        for failure in [Point.restoreOverlay, .restoreSource, .restoreResources] {
            let fixture = try Fixture(existing: true, oldSource: true, oldOverlay: true)
            let before = try fixture.snapshot()
            let transaction = try Support(scenario: fixture.scene) { point in
                if point == .cacheDelete || point == failure { throw Support.TransactionError.injected(point) }
            }
            // This observer models the installer's caller, outside both rollback layers.
            var observed: Support.TransactionError?
            var reportedSuccess = false
            do {
                _ = try transaction.deploy(sourceRoot: fixture.newResources)
                reportedSuccess = true
            } catch {
                observed = error as? Support.TransactionError
            }
            XCTAssertFalse(reportedSuccess)
            XCTAssertEqual(observed, .rollbackFailed([failure]))
            XCTAssertFalse(transaction.oldAuthorizationPreserved)
            try fixture.assertNoMarkersOrDictionaryMutation()
            for (path, bytes) in before {
                let group: String
                if path == Support.derivedPath {
                    group = "derived"
                } else if Support.overlayPaths.contains(path) {
                    group = "overlays"
                } else if path == RimeBuiltinResourceInstaller.overlayReceiptFileName {
                    group = "overlay-receipt"
                } else if path == "user/luna_pinyin.userdb/fixture.txt" {
                    continue
                } else {
                    group = "resources"
                }
                let backup = transaction.backupRoot.appendingPathComponent("\(group)/\(path)")
                XCTAssertEqual(try Data(contentsOf: backup), bytes, "Recovery backup: \(path)")
            }
            if failure != .restoreResources {
                // A successful resource rollback must not erase the callback's rollbackFailed.
                XCTAssertEqual(
                    try fixture.read(RimeBuiltinResourceInstaller.resourceReceiptFileName),
                    before[RimeBuiltinResourceInstaller.resourceReceiptFileName]
                )
                for path in RimeBuiltinResourceInstaller.requiredRelativePaths {
                    XCTAssertEqual(try fixture.read("shared/\(path)"), before["shared/\(path)"])
                }
            }
            XCTAssertNotEqual(try fixture.snapshot(), before)
            // Restore is still possible from retained backups; a normal redeploy also converges.
            _ = try Support(scenario: fixture.scene).deploy(sourceRoot: fixture.newResources)
            XCTAssertEqual(try fixture.read(Support.derivedPath), fixture.variant)
            try fixture.assertAuthorized()
            print("SCENARIO_PASS rollbackFailed \(failure.rawValue) backup=\(transaction.backupRoot.path)")
        }
    }

    func testMultipleRollbackFailuresRemainExplicit() throws {
        let fixture = try Fixture(existing: true, oldSource: true, oldOverlay: true)
        let transaction = try Support(scenario: fixture.scene) { point in
            if [.cacheDelete, .restoreOverlay, .restoreSource, .restoreResources].contains(point) {
                throw Support.TransactionError.injected(point)
            }
        }
        XCTAssertThrowsError(try transaction.deploy(sourceRoot: fixture.newResources)) { error in
            XCTAssertEqual(
                error as? Support.TransactionError,
                .rollbackFailed([.restoreOverlay, .restoreSource, .restoreResources]))
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: transaction.backupRoot.path))
        XCTAssertFalse(transaction.oldAuthorizationPreserved)
        try fixture.assertNoMarkersOrDictionaryMutation()
    }

    func testInvalidResourceClosureFailsBeforeMutation() throws {
        let fixture = try Fixture(existing: true, oldSource: true, oldOverlay: true)
        let before = try fixture.snapshot()
        try Data("corrupt-source".utf8).write(
            to: fixture.newResources.appendingPathComponent("luna_pinyin.schema.yaml"))
        XCTAssertThrowsError(try Support(scenario: fixture.scene).deploy(sourceRoot: fixture.newResources))
        XCTAssertEqual(try fixture.snapshot(), before)
        try fixture.assertAuthorized()
    }

    func testDeletionGuardRejectsRootEscapesSiblingsBackupsAndForeignNames() throws {
        let fixture = try Fixture(existing: true, oldSource: true, oldOverlay: true)
        let transaction = try Support(scenario: fixture.scene)
        let outside = fixture.repository.appendingPathComponent("Universe Keyboard/RimeBuiltin/luna_pinyin.schema.yaml")
        let link = fixture.runtime.appendingPathComponent("shared/build/luna_pinyin_t9.external")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: outside)
        let denied = [
            fixture.scene, outside, link, transaction.backupRoot,
            fixture.scene.appendingPathComponent("../\(fixture.scene.lastPathComponent)-sibling/file"),
            fixture.runtime.appendingPathComponent("shared/build/luna_pinyin_t9extra.prism.bin"),
        ]
        for target in denied {
            XCTAssertThrowsError(try transaction.removeManagedItem(target, category: "cache")) { error in
                XCTAssertEqual(error as? Support.TransactionError, .unsafePath)
            }
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: link.path))
        XCTAssertEqual(try Data(contentsOf: outside), fixture.original)
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: fixture.scene.appendingPathComponent("deletions.tsv").path))
        try fixture.assertAuthorized()
    }

    private struct Fixture {
        let scene: URL
        let repository: URL
        let newResources: URL
        let original: Data
        let variant: Data
        var runtime: URL { scene.appendingPathComponent("runtime", isDirectory: true) }
        private let dictionary = Data("user-owned-dictionary-must-survive".utf8)

        init(existing: Bool, oldSource: Bool, oldOverlay: Bool) throws {
            var root = URL(fileURLWithPath: #filePath)
            for _ in 0..<5 { root.deleteLastPathComponent() }
            repository = root
            original = try Data(
                contentsOf: root.appendingPathComponent("Universe Keyboard/RimeBuiltin/luna_pinyin.schema.yaml"))
            variant = try Data(
                contentsOf: root.appendingPathComponent(
                    "Packages/RimeBridge/Tests/RimeBridgeTests/Fixtures/LunaT9/variant1.schema.yaml"))
            scene = URL(
                fileURLWithPath:
                    "/Users/doubleshy0n/.kos-work/Universe-Keyboard/LUNA-PLANNER-IMPL-001/scratch/impl-b/deployment-runtime"
            )
            .appendingPathComponent("scene-\(UUID().uuidString)", isDirectory: true)
            // UUID scene is created by this run and never reused or deleted.
            try FileManager.default.createDirectory(at: scene, withIntermediateDirectories: false)
            newResources = scene.appendingPathComponent("incoming", isDirectory: true)
            try Self.makeResources(at: newResources, repository: root, generation: "pr1b-new", original: original)
            if existing {
                let old = scene.appendingPathComponent("previous", isDirectory: true)
                try Self.makeResources(at: old, repository: root, generation: "pr1b-old", original: original)
                let manifest = try RimeBuiltinResourceInstaller().validateResourceTree(at: old)
                for entry in manifest.entries {
                    try put(Data(contentsOf: old.appendingPathComponent(entry.path)), "shared/\(entry.path)")
                }
                let receipt = RimeBuiltinResourceInstaller.ResourceReceipt(
                    formatVersion: 1, manifestSHA256: Support.digest(try Support.encode(manifest)), manifest: manifest
                )
                try put(try Support.encode(receipt), RimeBuiltinResourceInstaller.resourceReceiptFileName)
                try put(Data("old-default-overlay".utf8), "user/default.custom.yaml")
                try put(Data("old-luna-overlay".utf8), "user/luna_pinyin.custom.yaml")
                try RimeBuiltinResourceInstaller().recordOverlayReceipt(
                    rimeRoot: runtime, userDataURL: runtime.appendingPathComponent("user")
                )
                try assertAuthorized()
                XCTAssertEqual(manifest.formatVersion, 3)
                XCTAssertEqual(receipt.formatVersion, 1)
            }
            if oldSource { try put(Data("old-derived-source".utf8), Support.derivedPath) }
            if oldOverlay { try put(Data("old-derived-overlay".utf8), Support.derivedOverlayPath) }
            try put(dictionary, "user/luna_pinyin.userdb/fixture.txt")
            for location in ["shared/build", "user/build"] {
                for name in ["luna_pinyin_t9.schema.yaml", "luna_pinyin_t9.prism.bin"] {
                    try put(Data("stale-cache".utf8), "\(location)/\(name)")
                }
                for name in [
                    "luna_pinyin.prism.bin", "luna_pinyin_t9extra.prism.bin", "not_luna_pinyin_t9.schema.yaml",
                    "wanxiang_t9i.prism.bin",
                ] {
                    // The base prism belongs to the receipt and must not be overwritten here.
                    let path = "\(location)/\(name)"
                    if !FileManager.default.fileExists(atPath: runtime.appendingPathComponent(path).path) {
                        try put(Data("unrelated".utf8), path)
                    }
                }
            }
        }

        func read(_ path: String) throws -> Data {
            try Data(contentsOf: runtime.appendingPathComponent(path))
        }

        func put(_ data: Data, _ path: String) throws {
            let url = runtime.appendingPathComponent(path)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
        }

        func snapshot() throws -> [String: Data] {
            let paths =
                RimeBuiltinResourceInstaller.requiredRelativePaths.map { "shared/\($0)" }
                + [Support.derivedPath] + Support.overlayPaths + [
                    RimeBuiltinResourceInstaller.resourceReceiptFileName,
                    RimeBuiltinResourceInstaller.overlayReceiptFileName,
                    "user/luna_pinyin.userdb/fixture.txt",
                ]
            var result: [String: Data] = [:]
            for path in paths where FileManager.default.fileExists(atPath: runtime.appendingPathComponent(path).path) {
                result[path] = try read(path)
            }
            return result
        }

        func assertAuthorized() throws {
            try RimeBuiltinResourceInstaller().validateInstalledRuntime(
                rimeRoot: runtime, userDataURL: runtime.appendingPathComponent("user")
            )
        }

        func assertNoMarkersOrDictionaryMutation() throws {
            XCTAssertEqual(try read("user/luna_pinyin.userdb/fixture.txt"), dictionary)
            for name in ["luna_pinyin_installed", "rime_t9_ready", "rime_luna_pinyin_t9_readiness_marker"] {
                XCTAssertFalse(FileManager.default.fileExists(atPath: runtime.appendingPathComponent(name).path))
            }
        }

        func assertCachesClearedAndUnrelatedPreserved() throws {
            for location in ["shared/build", "user/build"] {
                for name in ["luna_pinyin_t9.schema.yaml", "luna_pinyin_t9.prism.bin"] {
                    XCTAssertFalse(
                        FileManager.default.fileExists(
                            atPath: runtime.appendingPathComponent("\(location)/\(name)").path))
                }
                for name in [
                    "luna_pinyin_t9extra.prism.bin", "not_luna_pinyin_t9.schema.yaml", "wanxiang_t9i.prism.bin",
                ] {
                    XCTAssertEqual(try read("\(location)/\(name)"), Data("unrelated".utf8))
                }
            }
        }

        private static func makeResources(at directory: URL, repository: URL, generation: String, original: Data) throws
        {
            let bundled = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin/RimeBuiltin.manifest.json")
            var manifest = try XCTUnwrap(
                JSONSerialization.jsonObject(with: Data(contentsOf: bundled)) as? [String: Any])
            var entries = try XCTUnwrap(manifest["entries"] as? [[String: Any]])
            var hashes: [String: String] = [:]
            // Tiny synthetic payloads exercise the real v3 validator, not the RIME engine.
            for index in entries.indices {
                let path = try XCTUnwrap(entries[index]["path"] as? String)
                let data = path == "luna_pinyin.schema.yaml" ? original : Data("\(generation):\(path)".utf8)
                let target = directory.appendingPathComponent(path)
                try FileManager.default.createDirectory(
                    at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
                try data.write(to: target)
                hashes[URL(fileURLWithPath: path).lastPathComponent] = Support.digest(data)
                entries[index]["byteCount"] = data.count
                entries[index]["sha256"] = Support.digest(data)
            }
            manifest["entries"] = entries
            manifest["generationID"] = generation
            var inputs = try XCTUnwrap(manifest["sourceInputs"] as? [String: [String: Any]])
            for key in inputs.keys.sorted() {
                var input = try XCTUnwrap(inputs[key])
                var files = try XCTUnwrap(input["files"] as? [[String: Any]])
                for index in files.indices {
                    let path = try XCTUnwrap(files[index]["path"] as? String)
                    if let hash = hashes[URL(fileURLWithPath: path).lastPathComponent] { files[index]["sha256"] = hash }
                }
                input["files"] = files
                inputs[key] = input
            }
            manifest["sourceInputs"] = inputs
            try JSONSerialization.data(withJSONObject: manifest, options: [.sortedKeys]).write(
                to: directory.appendingPathComponent(RimeBuiltinResourceInstaller.manifestFileName)
            )
            _ = try RimeBuiltinResourceInstaller().validateResourceTree(at: directory)
        }
    }
}
