import CryptoKit
import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

/// Planner contract for luna_pinyin_t9. The compiled learning key stays a known L4 failure.
@MainActor
final class LunaT9CompileInputContractTests: XCTestCase {
    private let schemaID = "luna_pinyin_t9"
    private let runtimeRoot = URL(
        fileURLWithPath:
            "/Users/doubleshy0n/.kos-work/Universe-Keyboard/LUNA-PLANNER-IMPL-001/scratch/impl-b/compile-runtime",
        isDirectory: true
    )

    func testCompileInputMatrix() throws {
        try runMatrix(checkCompiledLearning: false)
    }

    func testCompiledLearningKeyFollowsTheRequest() throws {
        // Only the compiled learning key. Simplification and algebra stay in the main matrix.
        let builtin = try builtinDirectory()
        let original = try Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml"))
        let derived = try LunaT9SchemaCompatibility.rewrite(original)
        let frozen = String(decoding: derived, as: UTF8.self)
        for enabled in [true, false] {
            let root = runtimeRoot.appendingPathComponent(
                "learning-\(enabled)-\(UUID().uuidString)", isDirectory: true)
            try observe(
                root: root, builtin: builtin, source: frozen, sourceName: "proven",
                compileInputProven: true, enabled: enabled, baseAlgebra: [],
                checkCompiledLearning: true, assertNonLearningContract: false
            )
        }
    }

    func testProductionTargetIncludesLunaPinyinT9() throws {
        let root = runtimeRoot.appendingPathComponent(
            "planner-target-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let targets = RimeConfigManager.schemaSwitchTargets(
            rimeRoot: root, iceInstalled: false, wanxiangInstalled: false, pendingSchemaID: nil)
        let match = targets.filter { $0.schemaID == schemaID }
        XCTAssertEqual(match.count, 1)
        XCTAssertEqual(match.first?.userDictionarySchemaID, "luna_pinyin")
        XCTAssertEqual(match.first?.wanxiangFamily, false)
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: targets,
            simplificationEnabled: false,
            userDictionarySettings: RimeUserDictionarySettings(lunaPinyinEnabled: true, rimeIceEnabled: false)
        )
        XCTAssertTrue(plan.contains { $0.filename == "luna_pinyin_t9.custom.yaml" })
    }

    func testGrammarYamlBlocksLunaT9ResetAndAlgebra() throws {
        let source = try frozenSource()
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: schemaID, userDictionarySchemaID: "luna_pinyin", sourceText: source, wanxiangFamily: false)
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target],
            simplificationEnabled: true,
            userDictionarySettings: RimeUserDictionarySettings(lunaPinyinEnabled: true, rimeIceEnabled: false),
            fuzzyPinyinSettings: RimeFuzzyPinyinSettings(enabled: true),
            grammarYamlPresent: true,
            compileInputProven: true
        )
        let content = try XCTUnwrap(plan.first?.content)
        XCTAssertFalse(content.contains("switches/"))
        XCTAssertFalse(content.contains("speller/algebra"))
        XCTAssertTrue(content.contains("\"translator/enable_user_dict\": true"))
    }

    private func runMatrix(checkCompiledLearning: Bool) throws {
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let original = try Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml"))
        let derived = try LunaT9SchemaCompatibility.rewrite(original)
        XCTAssertEqual(digest(derived), LunaT9SchemaCompatibility.outputSHA256)
        let frozen = try frozenSource()
        let expectedBaseAlgebra = frozen.components(separatedBy: "  algebra:\n")[1]
            .components(separatedBy: "\ntranslator:")[0]
            .split(separator: "\n")
            .map { line in
                String(line.components(separatedBy: "#")[0])
                    .trimmingCharacters(in: .whitespaces).dropFirst(2)
            }.map(String.init)
        XCTAssertEqual(expectedBaseAlgebra.count, 13)
        let inputs = [
            ("proven", frozen),
            // Exactly one UTF-8 byte changes, without making the schema unparseable.
            ("one-byte-change", frozen.replacingOccurrences(of: "version: '0.31'", with: "version: '0.32'")),
            ("extra-patch", frozen + "\npatch:\n  menu/page_size: 7\n"),
            ("unproven", frozen + "\n# unproven source\n"),
        ]
        for (name, source) in inputs {
            XCTAssertEqual(digest(Data(source.utf8)) == LunaT9SchemaCompatibility.outputSHA256, name == "proven")
            for proven in [true, false] {
                for enabled in [true, false] {
                    let scene =
                        "\(name)-\(proven ? "callback" : "sync-false")-\(enabled ? "on" : "off")-\(UUID().uuidString)"
                    let root = runtimeRoot.appendingPathComponent(scene, isDirectory: true)
                    do {
                        try observe(
                            root: root, builtin: builtin, source: source, sourceName: name,
                            compileInputProven: proven, enabled: enabled, baseAlgebra: expectedBaseAlgebra,
                            checkCompiledLearning: checkCompiledLearning
                        )
                    } catch {
                        // Keep later matrix entries observable even if one cannot compile/open.
                        try "\(error)\n".write(
                            to: root.appendingPathComponent("error.txt"), atomically: false, encoding: .utf8)
                        XCTFail("\(scene): \(error)")
                    }
                }
            }
        }
    }

    private func observe(
        root: URL, builtin: URL, source: String, sourceName: String,
        compileInputProven: Bool, enabled: Bool, baseAlgebra: [String],
        checkCompiledLearning: Bool,
        assertNonLearningContract: Bool = true
    ) throws {
        let fm = FileManager.default
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        try fm.copyItem(at: builtin, to: shared)
        try fm.createDirectory(at: user, withIntermediateDirectories: true)
        try source.write(
            to: shared.appendingPathComponent("\(schemaID).schema.yaml"), atomically: false, encoding: .utf8)
        let defaultURL = shared.appendingPathComponent("default.yaml")
        let defaults = try String(contentsOf: defaultURL, encoding: .utf8)
        let listStart = try XCTUnwrap(defaults.range(of: "schema_list:\n"))
        let listEnd = try XCTUnwrap(defaults.range(of: "\nswitcher:"))
        let privateDefaults = defaults.replacingCharacters(
            in: listStart.lowerBound..<listEnd.lowerBound,
            with: "schema_list:\n  - schema: \(schemaID)\n"
        )
        try privateDefaults.write(to: defaultURL, atomically: false, encoding: .utf8)
        let fuzzy = RimeFuzzyPinyinSettings(enabled: enabled)
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: schemaID, userDictionarySchemaID: "luna_pinyin", sourceText: source, wanxiangFamily: false
        )
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target], simplificationEnabled: enabled,
            userDictionarySettings: RimeUserDictionarySettings(lunaPinyinEnabled: enabled, rimeIceEnabled: !enabled),
            fuzzyPinyinSettings: fuzzy, compileInputProven: compileInputProven
        )
        XCTAssertEqual(plan.count, 1)
        let overlay = try XCTUnwrap(plan.first)
        try overlay.content.write(to: user.appendingPathComponent(overlay.filename), atomically: false, encoding: .utf8)
        try overlay.content.write(to: root.appendingPathComponent("overlay.txt"), atomically: false, encoding: .utf8)
        print("COMPILE_INPUT_SCENE \(root.path) sourceSHA256=\(digest(Data(source.utf8))) flag=\(compileInputProven)")
        print("OVERLAY_BEGIN\n\(overlay.content)OVERLAY_END")

        let manager = RimeSessionManager()
        XCTAssertTrue(manager.setup(withSharedDataDir: shared.path, userDataDir: user.path))
        XCTAssertTrue(manager.initializeEngine())
        defer { manager.finalize() }
        let api = try XCTUnwrap(rime_get_api())
        let start = try XCTUnwrap(api.pointee.start_maintenance)
        let join = try XCTUnwrap(api.pointee.join_maintenance_thread)
        // Avoid RimeDeployer: it writes a real App Group preference.
        XCTAssertNotEqual(start(1), 0)
        join()
        let compiledURL = user.appendingPathComponent("build/\(schemaID).schema.yaml")
        let compiled = try String(contentsOf: compiledURL, encoding: .utf8)
        XCTAssertFalse(compiled.isEmpty)
        XCTAssertTrue(manager.createSession())
        XCTAssertTrue(manager.selectSchema(schemaID))
        XCTAssertEqual(manager.currentSchemaID(), schemaID)
        let session = UInt(manager.currentSessionIdentifier())
        let getOption = try XCTUnwrap(api.pointee.get_option)
        let actualSimplified = getOption(session, "zh_hans") != 0
        let actualTraditional = getOption(session, "zh_hant") != 0
        var config = RimeConfig()
        let open = try XCTUnwrap(api.pointee.schema_open)
        let close = try XCTUnwrap(api.pointee.config_close)
        XCTAssertNotEqual(open(schemaID, &config), 0)
        defer { _ = close(&config) }
        let getBool = try XCTUnwrap(api.pointee.config_get_bool)
        let getString = try XCTUnwrap(api.pointee.config_get_cstring)
        var learning: Int32 = -1
        XCTAssertNotEqual(getBool(&config, "translator/enable_user_dict", &learning), 0)
        var algebra: [String] = []
        for index in 0..<64 {
            guard let value = getString(&config, "speller/algebra/@\(index)") else { break }
            algebra.append(String(cString: value))
        }
        // Observe actual output before touching session options: the reset must take effect itself.
        _ = manager.replaceInput("6442662")
        let automatic = manager.candidates(from: 0, limit: 100)
        manager.clearComposition()
        let setOption = try XCTUnwrap(api.pointee.set_option)
        setOption(session, "zh_hant", 1)
        setOption(session, "zh_hans", 0)
        _ = manager.replaceInput("6442662")
        let traditional = manager.candidates(from: 0, limit: 100)
        manager.clearComposition()
        setOption(session, "zh_hans", 1)
        _ = manager.replaceInput("6442662")
        let simplified = manager.candidates(from: 0, limit: 100)
        let automaticTexts = texts(automatic)
        let traditionalTexts = texts(traditional)
        let simplifiedTexts = texts(simplified)
        let observation: [String: Any] = [
            "scene": root.path, "input": sourceName, "sourceSHA256": digest(Data(source.utf8)),
            "sourceProofMatches": digest(Data(source.utf8)) == LunaT9SchemaCompatibility.outputSHA256,
            "compileInputProven": compileInputProven, "simplificationRequested": enabled,
            "learningRequested": enabled, "fuzzyRequested": enabled, "overlay": overlay.content,
            "compiledPath": compiledURL.path, "algebra": algebra, "learning": learning,
            "sessionID": session, "schemaID": manager.currentSchemaID(), "librimeVersion": manager.librimeVersion(),
            "initialZhHans": actualSimplified, "initialZhHant": actualTraditional,
            "automaticCandidates": automaticTexts, "traditionalCandidates": traditionalTexts,
            "simplifiedCandidates": simplifiedTexts,
        ]
        let json = try JSONSerialization.data(withJSONObject: observation, options: [.prettyPrinted, .sortedKeys])
        try json.write(to: root.appendingPathComponent("observation.json"))
        print("OBSERVATION \(String(decoding: json, as: UTF8.self))")
        if checkCompiledLearning {
            XCTAssertNotEqual(getBool(&config, "translator/enable_user_dict", &learning), 0)
            XCTAssertEqual(learning != 0, enabled, "compiled learning setting")
        }
        guard assertNonLearningContract else { return }
        XCTAssertTrue(
            overlay.content.contains("\"translator/enable_user_dict\": \(enabled ? "true" : "false")"),
            "planner still writes the learning key")
        XCTAssertTrue(traditionalTexts.contains("你好嗎"), "real traditional candidate")
        XCTAssertTrue(simplifiedTexts.contains("你好吗"), "real OpenCC simplified candidate")
        // The compile-input gate is closed unless the frozen hash and the proven flag both hold.
        let positive = sourceName == "proven" && compileInputProven
        if !positive {
            XCTAssertFalse(overlay.content.contains("switches/"), "unproven inputs must fail closed")
            XCTAssertFalse(overlay.content.contains("speller/algebra"), "unproven inputs must not replace algebra")
            XCTAssertEqual(algebra, baseAlgebra, "unproven compile input keeps the source algebra")
        }
        if positive {
            XCTAssertTrue(overlay.content.contains("switches/"), "resolver reset must be in the overlay")
            if enabled {
                XCTAssertTrue(overlay.content.contains("speller/algebra"))
            } else {
                XCTAssertFalse(overlay.content.contains("speller/algebra"))
            }
            XCTAssertEqual(actualSimplified, enabled, "session reset must follow requested simplification")
            XCTAssertTrue(automaticTexts.contains(enabled ? "你好吗" : "你好嗎"), "unmodified session output")
            var expected = Array(baseAlgebra.dropLast())
            expected.append(contentsOf: fuzzy.algebraRules)
            expected.append(baseAlgebra.last!)
            XCTAssertEqual(algebra, expected, "R5: letter rules, fuzzy letters, then exactly one terminal xlit")
        }
    }

    func testPatchConsumptionABAttributesL4OnlyWhenBMatches() throws {
        let builtin = try builtinDirectory()
        let original = try Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml"))
        let derived = try LunaT9SchemaCompatibility.rewrite(original)
        let bSource = String(decoding: derived, as: UTF8.self)
        let third = "\n  - luna_pinyin_t9.custom:/patch?"
        XCTAssertEqual(bSource.components(separatedBy: third).count, 2)
        let aSource = bSource.replacingOccurrences(of: third, with: "")
        XCTAssertNotEqual(aSource, bSource)
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: schemaID, userDictionarySchemaID: "luna_pinyin", sourceText: bSource, wanxiangFamily: false)
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target], simplificationEnabled: true,
            userDictionarySettings: RimeUserDictionarySettings(lunaPinyinEnabled: true, rimeIceEnabled: false),
            fuzzyPinyinSettings: RimeFuzzyPinyinSettings(enabled: true), compileInputProven: true)
        let overlay = try XCTUnwrap(plan.first?.content)
        let a = try compileCopy(builtin: builtin, schema: aSource, overlay: overlay, name: "ab-a")
        let b = try compileCopy(builtin: builtin, schema: bSource, overlay: overlay, name: "ab-b")
        let record = """
            overlaySHA256=\(digest(Data(overlay.utf8)))
            A algebraCount=\(a.algebra.count) learning=\(String(describing: a.learning)) hans=\(a.hans) auto=\(a.automatic.prefix(8))
            B algebraCount=\(b.algebra.count) learning=\(String(describing: b.learning)) hans=\(b.hans) auto=\(b.automatic.prefix(8))
            """
        try record.write(to: runtimeRoot.appendingPathComponent("ab-record.txt"), atomically: true, encoding: .utf8)
        XCTAssertEqual(a.overlaySHA, b.overlaySHA)
        // A is the two-item schema. Consumption failure is the L4 signature.
        XCTAssertFalse(a.algebra.contains { $0.contains("derive/^zh/z/") })
        XCTAssertEqual(a.hans, false)
        XCTAssertEqual(a.learning, nil)
        XCTAssertTrue(b.algebra.contains { $0 == "derive/^zh/z/" })
        XCTAssertEqual(b.hans, true)
        XCTAssertEqual(b.learning, true)
        XCTAssertTrue(b.automatic.contains("你好吗"))
    }

    private struct CompiledProbe {
        var algebra: [String]
        var learning: Bool?
        var hans: Bool
        var automatic: [String]
        var overlaySHA: String
    }

    private func compileCopy(builtin: URL, schema: String, overlay: String, name: String) throws -> CompiledProbe {
        let root = runtimeRoot.appendingPathComponent("\(name)-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.copyItem(at: builtin, to: shared)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        try schema.write(
            to: shared.appendingPathComponent("\(schemaID).schema.yaml"), atomically: false, encoding: .utf8)
        let defaultURL = shared.appendingPathComponent("default.yaml")
        var defaults = try String(contentsOf: defaultURL, encoding: .utf8)
        let listStart = try XCTUnwrap(defaults.range(of: "schema_list:\n"))
        let listEnd = try XCTUnwrap(defaults.range(of: "\nswitcher:"))
        defaults.replaceSubrange(
            listStart.lowerBound..<listEnd.lowerBound, with: "schema_list:\n  - schema: \(schemaID)\n")
        try defaults.write(to: defaultURL, atomically: false, encoding: .utf8)
        try overlay.write(
            to: user.appendingPathComponent("luna_pinyin_t9.custom.yaml"), atomically: false, encoding: .utf8)
        let manager = RimeSessionManager()
        XCTAssertTrue(manager.setup(withSharedDataDir: shared.path, userDataDir: user.path))
        XCTAssertTrue(manager.initializeEngine())
        defer { manager.finalize() }
        let api = try XCTUnwrap(rime_get_api())
        let start = try XCTUnwrap(api.pointee.start_maintenance)
        let join = try XCTUnwrap(api.pointee.join_maintenance_thread)
        XCTAssertNotEqual(start(1), 0)
        join()
        XCTAssertTrue(manager.createSession())
        XCTAssertTrue(manager.selectSchema(schemaID))
        let session = UInt(manager.currentSessionIdentifier())
        let getOption = try XCTUnwrap(api.pointee.get_option)
        var config = RimeConfig()
        let open = try XCTUnwrap(api.pointee.schema_open)
        let close = try XCTUnwrap(api.pointee.config_close)
        XCTAssertNotEqual(open(schemaID, &config), 0)
        defer { _ = close(&config) }
        let getBool = try XCTUnwrap(api.pointee.config_get_bool)
        let getString = try XCTUnwrap(api.pointee.config_get_cstring)
        var learning: Int32 = -1
        let learningPresent = getBool(&config, "translator/enable_user_dict", &learning) != 0
        var algebra: [String] = []
        for index in 0..<64 {
            guard let value = getString(&config, "speller/algebra/@\(index)") else { break }
            algebra.append(String(cString: value))
        }
        _ = manager.replaceInput("6442662")
        let automatic = texts(manager.candidates(from: 0, limit: 20))
        return CompiledProbe(
            algebra: algebra,
            learning: learningPresent ? (learning != 0) : nil,
            hans: getOption(session, "zh_hans") != 0,
            automatic: automatic,
            overlaySHA: digest(Data(overlay.utf8)))
    }

    private func builtinDirectory() throws -> URL {
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        return repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
    }

    private func frozenSource() throws -> String {

        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let original = try Data(
            contentsOf: repository.appendingPathComponent("Universe Keyboard/RimeBuiltin/luna_pinyin.schema.yaml"))
        let derived = try LunaT9SchemaCompatibility.rewrite(original)
        XCTAssertEqual(digest(derived), LunaT9SchemaCompatibility.outputSHA256)
        return String(decoding: derived, as: UTF8.self)
    }

    private func texts(_ output: [AnyHashable: Any]) -> [String] {
        let candidates = output[RimeKeyCandidates] as? [[String: Any]] ?? []
        return candidates.compactMap { $0[RimeKeyCandidateText] as? String }
    }

    private func digest(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
