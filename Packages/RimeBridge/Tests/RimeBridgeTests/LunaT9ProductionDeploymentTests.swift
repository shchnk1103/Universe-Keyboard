import CryptoKit
import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

final class LunaT9ProductionDeploymentTests: XCTestCase {
    private var repository: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    override func tearDown() {
        LunaT9ProductionDeploymentSupport.debugInjection = nil
        RimeT9SmokeProbe.selectAndConfirmHook = nil
        super.tearDown()
    }

    func testInstallerCallbackMaterializesFrozenSchemaAndOverlay() throws {
        XCTAssertNil(RimeT9SmokeProbe.selectAndConfirmHook)
        let scene = try makeScene()
        defer { try? FileManager.default.removeItem(at: scene.root) }
        _ = try RimeBuiltinResourceInstaller().install(
            sourceRoot: scene.source,
            rimeRoot: scene.rimeRoot,
            afterInstallingResources: {
                try LunaT9ProductionDeploymentSupport.commitInInstallerCallback(
                    defaults: scene.defaults,
                    rimeRoot: scene.rimeRoot
                )
            }
        )
        let derived = scene.rimeRoot.appendingPathComponent("shared/luna_pinyin_t9.schema.yaml")
        let bytes = try Data(contentsOf: derived)
        XCTAssertEqual(sha(bytes), LunaT9SchemaCompatibility.outputSHA256)
        let overlay = try String(
            contentsOf: scene.rimeRoot.appendingPathComponent("user/luna_pinyin_t9.custom.yaml"),
            encoding: .utf8)
        XCTAssertTrue(overlay.contains("enable_user_dict"))
        let defaults = try String(
            contentsOf: scene.rimeRoot.appendingPathComponent("user/default.custom.yaml"),
            encoding: .utf8)
        XCTAssertTrue(defaults.contains("luna_pinyin_t9"))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: scene.rimeRoot.appendingPathComponent(
                    RimeBuiltinResourceInstaller.overlayReceiptFileName
                ).path))
        try deployAndSmoke(scene)
    }

    func testSyncFailureRestoresPreviousDerivedBytes() throws {
        let scene = try makeScene()
        defer { try? FileManager.default.removeItem(at: scene.root) }
        _ = try RimeBuiltinResourceInstaller().install(
            sourceRoot: scene.source,
            rimeRoot: scene.rimeRoot,
            afterInstallingResources: {
                try LunaT9ProductionDeploymentSupport.commitInInstallerCallback(
                    defaults: scene.defaults, rimeRoot: scene.rimeRoot)
            }
        )
        let derived = scene.rimeRoot.appendingPathComponent("shared/luna_pinyin_t9.schema.yaml")
        let original = try Data(contentsOf: derived)
        LunaT9ProductionDeploymentSupport.debugInjection = { point in
            if point == .overlayReplace { throw LunaT9ProductionDeploymentSupport.ProductionError(message: "inject") }
        }
        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().install(
                sourceRoot: scene.source,
                rimeRoot: scene.rimeRoot,
                afterInstallingResources: {
                    try LunaT9ProductionDeploymentSupport.commitInInstallerCallback(
                        defaults: scene.defaults, rimeRoot: scene.rimeRoot)
                }
            )
        )
        XCTAssertEqual(try Data(contentsOf: derived), original)
    }

    func testSHAMismatchRejectsEnableWithoutWriting() throws {
        let scene = try makeScene()
        defer { try? FileManager.default.removeItem(at: scene.root) }
        let shared = scene.rimeRoot.appendingPathComponent("shared", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        let derived = shared.appendingPathComponent("luna_pinyin_t9.schema.yaml")
        try Data("not-the-schema".utf8).write(to: derived)
        XCTAssertThrowsError(
            try LunaT9ProductionDeploymentSupport.validateSourceBeforeEnable(sharedDataURL: shared)
        ) { error in
            let text = String(describing: error)
            XCTAssertTrue(text.contains("expected"))
            XCTAssertTrue(text.contains("actual"))
        }
        XCTAssertEqual(try Data(contentsOf: derived), Data("not-the-schema".utf8))
    }

    func testEachInjectionPointFailsAndRestoresLetterSchema() throws {
        let points = LunaT9DeploymentSupport.Point.allCases
        XCTAssertEqual(points.count, 15)
        let restorePoints: Set<LunaT9DeploymentSupport.Point> = [.restoreSource, .restoreOverlay, .restoreResources]
        for point in points {
            let scene = try makeScene()
            defer { try? FileManager.default.removeItem(at: scene.root) }
            let build = scene.rimeRoot.appendingPathComponent("shared/build", isDirectory: true)
            try FileManager.default.createDirectory(at: build, withIntermediateDirectories: true)
            try Data("stale".utf8).write(to: build.appendingPathComponent("luna_pinyin_t9.schema.yaml"))
            try Data("keep".utf8).write(to: build.appendingPathComponent("luna_pinyin.schema.yaml"))
            let started = Date()
            LunaT9ProductionDeploymentSupport.debugInjection = { hit in
                if hit == point { throw LunaT9ProductionDeploymentSupport.ProductionError(message: hit.rawValue) }
                if restorePoints.contains(point), hit == .sourceReplace {
                    throw LunaT9ProductionDeploymentSupport.ProductionError(message: "forward")
                }
            }
            XCTAssertThrowsError(
                try RimeBuiltinResourceInstaller().install(
                    sourceRoot: scene.source,
                    rimeRoot: scene.rimeRoot,
                    afterInstallingResources: {
                        try LunaT9ProductionDeploymentSupport.commitInInstallerCallback(
                            defaults: scene.defaults, rimeRoot: scene.rimeRoot)
                    }
                ),
                "point \(point.rawValue)"
            )
            let unavailableMs = Int(Date().timeIntervalSince(started) * 1000)
            let derived = scene.rimeRoot.appendingPathComponent("shared/luna_pinyin_t9.schema.yaml")
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: derived.path),
                "fresh deploy must not leave derived schema after \(point.rawValue)")
            let letter = scene.rimeRoot.appendingPathComponent("shared/luna_pinyin.schema.yaml")
            if FileManager.default.fileExists(atPath: letter.path) {
                let letterSHA = sha(try Data(contentsOf: letter))
                XCTAssertEqual(letterSHA, LunaT9SchemaCompatibility.sourceSHA256)
            }
            print("GATE6_UNAVAILABLE_MS point=\(point.rawValue) ms=\(unavailableMs)")
            LunaT9ProductionDeploymentSupport.debugInjection = nil
        }
    }

    func testUserdbSurvivesTwentySixAndNineKeyRoundTripWhenLearningOn() throws {
        XCTAssertNil(RimeT9SmokeProbe.selectAndConfirmHook)
        let scene = try makeScene()
        defer { try? FileManager.default.removeItem(at: scene.root) }
        _ = try RimeBuiltinResourceInstaller().install(
            sourceRoot: scene.source,
            rimeRoot: scene.rimeRoot,
            afterInstallingResources: {
                try LunaT9ProductionDeploymentSupport.commitInInstallerCallback(
                    defaults: scene.defaults, rimeRoot: scene.rimeRoot)
            }
        )
        try maintain(scene)
        let user = scene.rimeRoot.appendingPathComponent("user")
        let shared = scene.rimeRoot.appendingPathComponent("shared")
        func digest() -> [String: String] { userdbState(user) }
        let baseline = digest()
        try typeAndCommit(scene, schema: "luna_pinyin", keys: "nihao")
        let after26 = digest()
        XCTAssertNotEqual(after26, baseline, "learning on must change userdb from a fresh directory")
        let suite = scene.defaults
        suite.set("luna_pinyin", forKey: "rime_active_schema")
        suite.set("luna_pinyin_t9", forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        suite.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        let fingerprint = NineKeyReadiness.fingerprint(schemaID: "luna_pinyin_t9", sharedDirectory: shared)
        let marker = RimeT9ReadinessMarker(
            ready: true, compatibilityVersion: "1", resourceFingerprint: fingerprint ?? "")
        if let data = try? JSONEncoder().encode(marker) {
            suite.set(data, forKey: "rime_luna_t9_readiness_marker")
        }
        let selection = RimeRuntimeSelectionBridge.resolve(
            defaults: suite, sharedDataDir: shared.path)
        XCTAssertEqual(selection.effectiveSchemaID, "luna_pinyin_t9")
        try typeAndCommit(scene, schema: "luna_pinyin_t9", keys: "6446")
        let after9 = digest()
        XCTAssertFalse(after9.isEmpty, "nine-key step left no readable userdb")
        XCTAssertNotEqual(after9, after26)
        suite.set(KeyboardLayoutStyle.twentySixKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        let back = RimeRuntimeSelectionBridge.resolve(defaults: suite, sharedDataDir: shared.path)
        XCTAssertEqual(back.effectiveSchemaID, "luna_pinyin")
        try typeAndCommit(scene, schema: "luna_pinyin", keys: "nihao")
        let afterBack = digest()
        XCTAssertFalse(afterBack.isEmpty, "return to 26-key left no readable userdb")
        XCTAssertNotEqual(afterBack, baseline)
    }

    func testUserdbDigestStaysPutWhenLearningOff() throws {
        let scene = try makeScene(learning: false)
        defer { try? FileManager.default.removeItem(at: scene.root) }
        _ = try RimeBuiltinResourceInstaller().install(
            sourceRoot: scene.source,
            rimeRoot: scene.rimeRoot,
            afterInstallingResources: {
                try LunaT9ProductionDeploymentSupport.commitInInstallerCallback(
                    defaults: scene.defaults, rimeRoot: scene.rimeRoot)
            }
        )
        try maintain(scene)
        let user = scene.rimeRoot.appendingPathComponent("user")
        let before = userdbState(user)
        try typeAndCommit(scene, schema: "luna_pinyin", keys: "nihao")
        XCTAssertEqual(userdbState(user), before)
    }

    private func deployAndSmoke(_ scene: Scene) throws {
        try maintain(scene)
        let shared = scene.rimeRoot.appendingPathComponent("shared").path
        let user = scene.rimeRoot.appendingPathComponent("user").path
        XCTAssertTrue(
            RimeT9SmokeProbe.verify(
                sharedDataDir: shared, userDataDir: user, schemaID: "luna_pinyin_t9", input: "6446"))
        let check = LunaT9ProductionDeploymentSupport.recheckCompiled(
            sharedDataURL: URL(fileURLWithPath: shared),
            userDataURL: URL(fileURLWithPath: user))
        XCTAssertFalse(check.failed, check.step.reason)
    }

    private func maintain(_ scene: Scene) throws {
        let manager = RimeSessionManager()
        let shared = scene.rimeRoot.appendingPathComponent("shared").path
        let user = scene.rimeRoot.appendingPathComponent("user").path
        XCTAssertTrue(manager.setup(withSharedDataDir: shared, userDataDir: user))
        XCTAssertTrue(manager.initializeEngine())
        defer { manager.finalize() }
        let api = try XCTUnwrap(rime_get_api())
        let start = try XCTUnwrap(api.pointee.start_maintenance)
        let join = try XCTUnwrap(api.pointee.join_maintenance_thread)
        XCTAssertNotEqual(start(1), 0)
        join()
    }

    private func typeAndCommit(_ scene: Scene, schema: String, keys: String) throws {
        let manager = RimeSessionManager()
        let shared = scene.rimeRoot.appendingPathComponent("shared").path
        let user = scene.rimeRoot.appendingPathComponent("user").path
        XCTAssertTrue(manager.setup(withSharedDataDir: shared, userDataDir: user))
        XCTAssertTrue(manager.initializeEngine())
        defer { manager.finalize() }
        XCTAssertTrue(manager.createSession())
        XCTAssertTrue(manager.selectSchema(schema))
        _ = manager.replaceInput(keys)
        let selected = manager.selectCandidate(atGlobalIndex: 0)
        let committed = manager.commitComposition()
        let text =
            (selected[RimeKeyCommit] as? String ?? "") + (committed[RimeKeyCommit] as? String ?? "")
        XCTAssertFalse(text.isEmpty, "schema \(schema) keys \(keys) produced no commit")
    }

    private func userdbState(_ user: URL) -> [String: String] {
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(at: user, includingPropertiesForKeys: nil) else { return [:] }
        var state: [String: String] = [:]
        for entry in entries where entry.lastPathComponent.contains("userdb") {
            if (try? entry.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
                if let files = try? fm.contentsOfDirectory(at: entry, includingPropertiesForKeys: nil) {
                    for file in files {
                        if let data = try? Data(contentsOf: file) {
                            state["\(entry.lastPathComponent)/\(file.lastPathComponent)"] = sha(data)
                        }
                    }
                }
            } else if let data = try? Data(contentsOf: entry) {
                state[entry.lastPathComponent] = sha(data)
            }
        }
        return state
    }

    private struct Scene {
        let root: URL
        let source: URL
        let rimeRoot: URL
        let defaults: UserDefaults
    }

    private func makeScene(learning: Bool = true) throws -> Scene {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "luna-t9-prod-\(UUID().uuidString)", isDirectory: true)
        let source = root.appendingPathComponent("RimeBuiltin", isDirectory: true)
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin")
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
        let names =
            RimeBuiltinResourceInstaller.requiredRelativePaths + [
                RimeBuiltinResourceInstaller.manifestFileName
            ]
        for relative in names {
            let from = builtin.appendingPathComponent(relative)
            let to = source.appendingPathComponent(relative)
            try FileManager.default.createDirectory(
                at: to.deletingLastPathComponent(), withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: from, to: to)
        }
        let rimeRoot = root.appendingPathComponent("Rime", isDirectory: true)
        try FileManager.default.createDirectory(
            at: rimeRoot.appendingPathComponent("user"), withIntermediateDirectories: true)
        let suite = "luna-t9-prod-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defaults.set("luna_pinyin", forKey: "rime_active_schema")
        defaults.set(learning, forKey: RimeUserDictionarySettings.lunaPinyinEnabledKey)
        return Scene(root: root, source: source, rimeRoot: rimeRoot, defaults: defaults)
    }

    private func sha(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
