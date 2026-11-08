import CryptoKit
import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

final class LunaT9UpgradeRollbackTests: XCTestCase {
    private let schema = "luna_pinyin_t9"
    private let marker = "test_luna_upgrade_marker"

    private final class Store: NineKeySettingsStore {
        var values: [String: Any] = [:]
        func data(forKey key: String) -> Data? { values[key] as? Data }
        func set(_ value: Any?, forKey key: String) { values[key] = value }
    }

    private func digest(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func elapsed(_ start: Date) -> Int { Int(Date().timeIntervalSince(start) * 1000) }

    func testUpgradeAndFailureIsolation() async throws {
        let start = Date()
        let oldPath = try XCTUnwrap(ProcessInfo.processInfo.environment["LUNA_T9_OLD_VARIANT_PATH"])
        let old = try Data(contentsOf: URL(fileURLWithPath: oldPath))
        guard digest(old) == "a7ba5f874e05126a86f55ba2122f094c57eb380d1f0d8625cefa0915311caa3e" else {
            XCTFail("Old variant SHA-256 mismatch")
            return
        }
        let oldText = String(decoding: old, as: UTF8.self)
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let original = try Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml"))
        let derived = try LunaT9SchemaCompatibility.rewrite(original)
        let fixture = try Data(
            contentsOf: repository.appendingPathComponent(
                "Packages/RimeBridge/Tests/RimeBridgeTests/Fixtures/LunaT9/variant1.schema.yaml"))
        XCTAssertEqual(derived, fixture)
        XCTAssertNotEqual(digest(old), LunaT9SchemaCompatibility.outputSHA256)
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: schema, userDictionarySchemaID: "luna_pinyin", sourceText: oldText, wanxiangFamily: false)
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target], simplificationEnabled: true,
            userDictionarySettings: .init(lunaPinyinEnabled: true, rimeIceEnabled: false),
            fuzzyPinyinSettings: .init(enabled: true), grammarYamlPresent: false, compileInputProven: true)
        let patch = try XCTUnwrap(plan.first { $0.filename == schema + ".custom.yaml" })
        XCTAssertFalse(patch.content.contains("switches/"))
        XCTAssertFalse(patch.content.contains("speller/algebra"))
        XCTAssertTrue(patch.content.contains("translator/enable_user_dict"))
        print(
            "LUNA_UPGRADE U1 old=\(digest(old)) proof=false overlay=true learning=\(patch.content.contains("translator/enable_user_dict")) ms=\(elapsed(start))"
        )

        let root = try LunaT9EvidenceRoot.directory("upgrade-rollback")
        let entry = NineKeyScheme(
            schemaID: schema, familyID: "luna_pinyin", markerKey: marker, compatibilityVersion: "1")
        func put(_ data: Data, _ path: String, _ runtime: URL) throws {
            let url = runtime.appendingPathComponent(path)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
        }
        func makeScene(_ name: String) throws -> (URL, URL, URL, [String: Data]) {
            let scene = root.appendingPathComponent("\(name)-\(UUID().uuidString)", isDirectory: true)
            try LunaT9EvidenceRoot.createExclusiveDirectory(scene)
            let runtime = scene.appendingPathComponent("runtime", isDirectory: true)
            let shared = runtime.appendingPathComponent("shared", isDirectory: true)
            let user = runtime.appendingPathComponent("user", isDirectory: true)
            try put(old, LunaT9DeploymentSupport.derivedPath, runtime)
            try put(Data(patch.content.utf8), LunaT9DeploymentSupport.derivedOverlayPath, runtime)
            let initial: [String: Data] = [
                "user/default.custom.yaml": Data("patch:\n  custom_user_setting: original\n".utf8),
                "user/luna_pinyin.custom.yaml": Data("patch:\n  translator/enable_user_dict: false\n".utf8),
                "user/luna_pinyin.userdb/fixture.txt": Data("user dictionary sentinel".utf8),
                "shared/t9.schema.yaml": Data("other family t9".utf8),
                "shared/wanxiang_t9.schema.yaml": Data("other family wanxiang".utf8),
                "shared/build/luna_pinyin_t9extra.prism.bin": Data("other nearby shared".utf8),
                "user/build/luna_pinyin_t9extra.prism.bin": Data("other nearby user".utf8),
            ]
            for (path, data) in initial { try put(data, path, runtime) }
            return (scene, shared, user, initial)
        }
        func check(_ scene: URL, _ before: [String: Data], _ phase: String) throws {
            let runtime = scene.appendingPathComponent("runtime", isDirectory: true)
            let evidence = scene.appendingPathComponent("observations", isDirectory: true)
            try FileManager.default.createDirectory(at: evidence, withIntermediateDirectories: true)
            for (path, prior) in before.sorted(by: { $0.key < $1.key }) {
                let after = try Data(contentsOf: runtime.appendingPathComponent(path))
                let label = path.replacingOccurrences(of: "/", with: "_")
                try prior.write(to: evidence.appendingPathComponent("\(phase)-before-\(label)"))
                try after.write(to: evidence.appendingPathComponent("\(phase)-after-\(label)"))
                print(
                    "LUNA_UPGRADE U5U6 phase=\(phase) path=\(path) before=\(digest(prior)) after=\(digest(after)) equal=\(prior == after) ms=\(elapsed(start))"
                )
                if !path.hasSuffix("default.custom.yaml") && !path.hasSuffix("luna_pinyin.custom.yaml") {
                    XCTAssertEqual(after, prior, "Unrelated data \(path)")
                }
            }
        }
        func compile(_ shared: URL, _ user: URL) async throws -> RimeDeploymentResult {
            try await RimeDeploymentService().deploy(
                RimeDeploymentRequest(
                    mode: .testFixtureMaintenanceOnly, sharedDataURL: shared, userDataURL: user,
                    runtimeSmokeSchemaID: nil))
        }
        func verify(_ shared: URL, _ user: URL, _ input: String) -> Bool {
            RimeT9SmokeProbe.verify(
                sharedDataDir: shared.path, userDataDir: user.path, schemaID: schema, input: input, registry: [entry])
        }
        func letters(_ shared: URL, _ user: URL, _ phase: String) -> Bool {
            let engine = RimeEngineImpl(sharedDataDir: shared.path, userDataDir: user.path)
            let selected = engine.bridge.selectSchema("luna_pinyin") && engine.bridge.currentSchemaID() == "luna_pinyin"
            engine.resetSession()
            var output = RimeOutput()
            for key in "nihao" { output = engine.processKey(String(key)) }
            let ok = selected && !output.candidates.isEmpty
            print(
                "LUNA_UPGRADE \(phase)-fallback selected=\(selected) raw=\(output.rawInput ?? "") candidates=\(output.candidates.map(\.text)) available=\(ok) ms=\(elapsed(start))"
            )
            engine.suspendForVisibilityChange()
            return ok
        }
        let (scene, shared, user, before) = try makeScene("success")
        let transactionStart = Date()
        let transaction = try LunaT9DeploymentSupport(scenario: scene)
        let prepared = try transaction.deploy(sourceRoot: builtin)
        let transactionMS = elapsed(transactionStart)
        XCTAssertEqual(prepared.sourceSHA256, LunaT9SchemaCompatibility.outputSHA256)
        try check(scene, before, "after-transaction")
        let compileStart = Date(); let compiled = try await compile(shared, user); let compileMS = elapsed(compileStart)
        let smokeStart = Date(); let smoke = verify(shared, user, "6446"); let smokeMS = elapsed(smokeStart)
        print(
            "LUNA_UPGRADE U2 source=\(prepared.sourceSHA256) transaction=true compile=\(compiled.succeeded) diagnostic=\(compiled.diagnosticMessage) smoke=\(smoke) transactionMS=\(transactionMS) compileMS=\(compileMS) smokeMS=\(smokeMS) totalMS=\(transactionMS + compileMS + smokeMS)"
        )
        XCTAssertTrue(compiled.succeeded); XCTAssertTrue(smoke)

        let store = Store(); let sentinelKey = try XCTUnwrap(NineKeySchemeRegistry.entries.first?.markerKey)
        let sentinel = Data("store sentinel".utf8); store.set(sentinel, forKey: sentinelKey)
        XCTAssertEqual(store.data(forKey: sentinelKey), sentinel); XCTAssertNil(store.data(forKey: marker))
        let engine = RimeEngineImpl(sharedDataDir: shared.path, userDataDir: user.path)
        let selected = engine.bridge.selectSchema(schema); engine.resetSession(); var output = RimeOutput()
        for key in "1111" { output = engine.processKey(String(key)) }
        let raw = output.rawInput ?? ""; let candidates = output.candidates.map(\.text)
        engine.suspendForVisibilityChange()
        let invalidSmoke = verify(shared, user, "1111")
        XCTAssertFalse(invalidSmoke); XCTAssertNil(store.data(forKey: marker)); XCTAssertTrue(selected)
        let fallback4 = letters(shared, user, "U4")
        print(
            "LUNA_UPGRADE U4 input=1111 raw=\(raw) candidates=\(candidates) smoke=\(invalidSmoke) markerBeforeAfter=nil storeSentinel=true fallback=\(fallback4) ms=\(elapsed(start))"
        )
        XCTAssertTrue(fallback4)
        try check(scene, before, "after-smoke-failure")

        let (failedScene, failedShared, failedUser, failedBefore) = try makeScene("compile-failure")
        let failedTransaction = try LunaT9DeploymentSupport(scenario: failedScene)
        _ = try failedTransaction.deploy(sourceRoot: builtin)
        let dictionary = failedShared.appendingPathComponent("luna_pinyin.dict.yaml")
        let backup = try Data(contentsOf: dictionary)
        try backup.write(to: failedScene.appendingPathComponent("dictionary-backup.yaml"))
        try FileManager.default.removeItem(at: dictionary)
        let failed = try await compile(failedShared, failedUser)
        let failedSmoke = verify(failedShared, failedUser, "6446")
        let fallback3 = letters(failedShared, failedUser, "U3")
        print(
            "LUNA_UPGRADE U3 injection=missing-dictionary backup=\(digest(backup)) compile=\(failed.succeeded) diagnostic=\(failed.diagnosticMessage) smoke=\(failedSmoke) fallback=\(fallback3) ms=\(elapsed(start))"
        )
        XCTAssertFalse(failed.succeeded); XCTAssertFalse(failedSmoke); XCTAssertTrue(fallback3)
        try check(failedScene, failedBefore, "after-compile-failure")
    }
}
