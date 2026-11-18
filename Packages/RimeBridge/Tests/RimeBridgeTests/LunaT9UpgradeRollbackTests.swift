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
        guard let oldPath = ProcessInfo.processInfo.environment["LUNA_T9_OLD_VARIANT_PATH"] else {
            throw XCTSkip("LUNA_T9_OLD_VARIANT_PATH not set")
        }
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
                "shared/wanxiang_t9i.schema.yaml": Data("other family wanxiang".utf8),
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
        func includeLunaInSchemaList(_ shared: URL, _ user: URL) throws {
            let defaults = shared.appendingPathComponent("default.yaml")
            var text = try String(contentsOf: defaults, encoding: .utf8)
            let start = try XCTUnwrap(text.range(of: "schema_list:\n"))
            let end = try XCTUnwrap(text.range(of: "\nswitcher:"))
            text.replaceSubrange(
                start.lowerBound..<end.lowerBound,
                with: "schema_list:\n  - schema: luna_pinyin\n  - schema: luna_pinyin_t9\n")
            try text.write(to: defaults, atomically: false, encoding: .utf8)
            let custom = user.appendingPathComponent("default.custom.yaml")
            try Data("patch:\n  schema_list:\n    - schema: luna_pinyin\n    - schema: luna_pinyin_t9\n".utf8)
                .write(to: custom)
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
        try includeLunaInSchemaList(shared, user)
        try check(scene, before, "after-transaction")
        let compileStart = Date(); let compiled = try await compile(shared, user); let compileMS = elapsed(compileStart)
        let smokeStart = Date(); let smoke = verify(shared, user, "6446"); let smokeMS = elapsed(smokeStart)
        print(
            "LUNA_UPGRADE U2 source=\(prepared.sourceSHA256) transaction=true compile=\(compiled.succeeded) diagnostic=\(compiled.diagnosticMessage) smoke=\(smoke) transactionMS=\(transactionMS) compileMS=\(compileMS) smokeMS=\(smokeMS) totalMS=\(transactionMS + compileMS + smokeMS)"
        )
        XCTAssertTrue(compiled.succeeded); XCTAssertTrue(smoke)
        if smoke {
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
        }

        let (failedScene, failedShared, failedUser, failedBefore) = try makeScene("compile-failure")
        let failedTransaction = try LunaT9DeploymentSupport(scenario: failedScene)
        _ = try failedTransaction.deploy(sourceRoot: builtin)
        try includeLunaInSchemaList(failedShared, failedUser)
        let schemaFile = failedShared.appendingPathComponent("luna_pinyin_t9.schema.yaml")
        let backup = try Data(contentsOf: schemaFile)
        try backup.write(to: failedScene.appendingPathComponent("schema-backup.yaml"))
        try Data(":\n[\n".utf8).write(to: schemaFile)
        let failed = try await compile(failedShared, failedUser)
        let failedSmoke = verify(failedShared, failedUser, "6446")
        let fallback3 = letters(failedShared, failedUser, "U3")
        print(
            "LUNA_UPGRADE U3 injection=invalid-schema backup=\(digest(backup)) compile=\(failed.succeeded) diagnostic=\(failed.diagnosticMessage) smoke=\(failedSmoke) fallback=\(fallback3) ms=\(elapsed(start))"
        )
        XCTAssertFalse(failed.succeeded); XCTAssertFalse(failedSmoke); XCTAssertTrue(fallback3)
        try check(failedScene, failedBefore, "after-compile-failure")
    }

    /// Design §5: reverse-construct A1 output d8f3327f from r2 fixture; repeat U1/U2/U3.
    func testLegacyA1OutputD8f3327fScene() async throws {
        let start = Date()
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let original = try Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml"))
        let derived = try LunaT9SchemaCompatibility.rewrite(original)
        let fixture = try Data(
            contentsOf: repository.appendingPathComponent(
                "Packages/RimeBridge/Tests/RimeBridgeTests/Fixtures/LunaT9/variant1.schema.yaml"))
        XCTAssertEqual(derived, fixture)
        let source = String(decoding: derived, as: UTF8.self)
        let alphaNew = "  alphabet: \"zyxwvutsrqponmlkjihgfedcba23456789\"\n"
        let alphaOld = "  alphabet: \"23456789\"\n"
        let derives =
            [
                "      - derive/[abc]/2/",
                "      - derive/[def]/3/",
                "      - derive/[hgi]/4/",
                "      - derive/[jkl]/5/",
                "      - derive/[omn]/6/",
                "      - derive/[pqrs]/7/",
                "      - derive/[tuv]/8/",
                "      - derive/[wxyz]/9/",
            ].joined(separator: "\n") + "\n"
        let xlit = "      - xlit/abcdefghijklmnopqrstuvwxyz/22233344455566677778889999/\n"
        XCTAssertEqual(source.components(separatedBy: alphaNew).count, 2)
        XCTAssertEqual(source.components(separatedBy: derives).count, 2)
        let legacyText = source.replacingOccurrences(of: alphaNew, with: alphaOld)
            .replacingOccurrences(of: derives, with: xlit)
        let legacy = Data(legacyText.utf8)
        XCTAssertEqual(digest(legacy), "d8f3327f5dc949ed562deaaa838644e03fa7708957c14b95df025b487d4426c3")

        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: schema, userDictionarySchemaID: "luna_pinyin", sourceText: legacyText,
            wanxiangFamily: false)
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target], simplificationEnabled: true,
            userDictionarySettings: .init(lunaPinyinEnabled: true, rimeIceEnabled: false),
            fuzzyPinyinSettings: .init(enabled: true), grammarYamlPresent: false, compileInputProven: true)
        let patch = try XCTUnwrap(plan.first { $0.filename == schema + ".custom.yaml" })
        XCTAssertFalse(patch.content.contains("switches/"))
        XCTAssertFalse(patch.content.contains("speller/algebra"))
        XCTAssertTrue(patch.content.contains("translator/enable_user_dict"))
        print(
            "LUNA_UPGRADE U1-d8f old=\(digest(legacy)) proof=false overlay=true learning=\(patch.content.contains("translator/enable_user_dict")) ms=\(elapsed(start))"
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
        let scene = root.appendingPathComponent("d8f-\(UUID().uuidString)", isDirectory: true)
        try LunaT9EvidenceRoot.createExclusiveDirectory(scene)
        let runtime = scene.appendingPathComponent("runtime", isDirectory: true)
        let shared = runtime.appendingPathComponent("shared", isDirectory: true)
        let user = runtime.appendingPathComponent("user", isDirectory: true)
        try put(legacy, LunaT9DeploymentSupport.derivedPath, runtime)
        try put(Data(patch.content.utf8), LunaT9DeploymentSupport.derivedOverlayPath, runtime)
        let initial: [String: Data] = [
            "user/default.custom.yaml": Data("patch:\n  custom_user_setting: original\n".utf8),
            "user/luna_pinyin.custom.yaml": Data("patch:\n  translator/enable_user_dict: false\n".utf8),
            "user/luna_pinyin.userdb/fixture.txt": Data("user dictionary sentinel".utf8),
            "shared/t9.schema.yaml": Data("other family t9".utf8),
        ]
        for (path, data) in initial { try put(data, path, runtime) }

        // U2: deploy from builtin (regenerates r2), with old state files present
        let transaction = try LunaT9DeploymentSupport(scenario: scene)
        let prepared = try transaction.deploy(sourceRoot: builtin)
        XCTAssertEqual(prepared.sourceSHA256, LunaT9SchemaCompatibility.outputSHA256)
        // schema list
        let defaults = shared.appendingPathComponent("default.yaml")
        // deploy copies builtin into shared — rewrite defaults
        var text = try String(contentsOf: defaults, encoding: .utf8)
        let startR = try XCTUnwrap(text.range(of: "schema_list:\n"))
        let endR = try XCTUnwrap(text.range(of: "\nswitcher:"))
        text.replaceSubrange(
            startR.lowerBound..<endR.lowerBound,
            with: "schema_list:\n  - schema: luna_pinyin\n  - schema: luna_pinyin_t9\n")
        try text.write(to: defaults, atomically: false, encoding: .utf8)
        try Data("patch:\n  schema_list:\n    - schema: luna_pinyin\n    - schema: luna_pinyin_t9\n".utf8)
            .write(to: user.appendingPathComponent("default.custom.yaml"))
        let compileStart = Date()
        let compiled = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .testFixtureMaintenanceOnly, sharedDataURL: shared, userDataURL: user,
                runtimeSmokeSchemaID: nil))
        let compileMS = elapsed(compileStart)
        let smokeStart = Date()
        let smoke = RimeT9SmokeProbe.verify(
            sharedDataDir: shared.path, userDataDir: user.path, schemaID: schema, input: "6446",
            registry: [entry])
        let smokeMS = elapsed(smokeStart)
        print(
            "LUNA_UPGRADE U2-d8f source=\(prepared.sourceSHA256) transaction=true compile=\(compiled.succeeded) diagnostic=\(compiled.diagnosticMessage) smoke=\(smoke) compileMS=\(compileMS) smokeMS=\(smokeMS)"
        )
        XCTAssertTrue(compiled.succeeded)
        XCTAssertTrue(smoke)

        // U3: compile failure injection on d8f scene clone
        let failedScene = root.appendingPathComponent("d8f-fail-\(UUID().uuidString)", isDirectory: true)
        try LunaT9EvidenceRoot.createExclusiveDirectory(failedScene)
        let failedRuntime = failedScene.appendingPathComponent("runtime", isDirectory: true)
        let failedShared = failedRuntime.appendingPathComponent("shared", isDirectory: true)
        let failedUser = failedRuntime.appendingPathComponent("user", isDirectory: true)
        try put(legacy, LunaT9DeploymentSupport.derivedPath, failedRuntime)
        try put(Data(patch.content.utf8), LunaT9DeploymentSupport.derivedOverlayPath, failedRuntime)
        for (path, data) in initial { try put(data, path, failedRuntime) }
        let failedTransaction = try LunaT9DeploymentSupport(scenario: failedScene)
        _ = try failedTransaction.deploy(sourceRoot: builtin)
        var ftext = try String(contentsOf: failedShared.appendingPathComponent("default.yaml"), encoding: .utf8)
        let fs = try XCTUnwrap(ftext.range(of: "schema_list:\n"))
        let fe = try XCTUnwrap(ftext.range(of: "\nswitcher:"))
        ftext.replaceSubrange(
            fs.lowerBound..<fe.lowerBound,
            with: "schema_list:\n  - schema: luna_pinyin\n  - schema: luna_pinyin_t9\n")
        try ftext.write(to: failedShared.appendingPathComponent("default.yaml"), atomically: false, encoding: .utf8)
        try Data("patch:\n  schema_list:\n    - schema: luna_pinyin\n    - schema: luna_pinyin_t9\n".utf8)
            .write(to: failedUser.appendingPathComponent("default.custom.yaml"))
        let schemaFile = failedShared.appendingPathComponent("luna_pinyin_t9.schema.yaml")
        let backup = try Data(contentsOf: schemaFile)
        try Data(":\n[\n".utf8).write(to: schemaFile)
        let failed = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .testFixtureMaintenanceOnly, sharedDataURL: failedShared, userDataURL: failedUser,
                runtimeSmokeSchemaID: nil))
        let failedSmoke = RimeT9SmokeProbe.verify(
            sharedDataDir: failedShared.path, userDataDir: failedUser.path, schemaID: schema, input: "6446",
            registry: [entry])
        let engine = RimeEngineImpl(sharedDataDir: failedShared.path, userDataDir: failedUser.path)
        let selected = engine.bridge.selectSchema("luna_pinyin") && engine.bridge.currentSchemaID() == "luna_pinyin"
        engine.resetSession()
        var output = RimeOutput()
        for key in "nihao" { output = engine.processKey(String(key)) }
        let fallback = selected && !(output.candidates.isEmpty)
        print(
            "LUNA_UPGRADE U3-d8f injection=invalid-schema backup=\(digest(backup)) compile=\(failed.succeeded) diagnostic=\(failed.diagnosticMessage) smoke=\(failedSmoke) fallback=\(fallback) ms=\(elapsed(start))"
        )
        XCTAssertFalse(failed.succeeded)
        XCTAssertFalse(failedSmoke)
        XCTAssertTrue(fallback)
    }
}
