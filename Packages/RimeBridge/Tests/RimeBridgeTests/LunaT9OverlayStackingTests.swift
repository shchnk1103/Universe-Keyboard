import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

final class LunaT9OverlayStackingTests: XCTestCase {
    private let inputs = ["6446", "94664", "9664", "244", "24", "744", "74", "64", "54"]

    func testStackingMatrix() throws {
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let source = try LunaT9SchemaCompatibility.rewrite(
            Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml")))
        let fixture = try Data(
            contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent(
                "Fixtures/LunaT9/variant1.schema.yaml"))
        XCTAssertEqual(source, fixture)
        let text = String(decoding: source, as: UTF8.self)
        let base = try XCTUnwrap(text.components(separatedBy: "  algebra:\n").dropFirst().first).components(
            separatedBy: "\ntranslator:")[0].split(separator: "\n").map {
                String($0.components(separatedBy: "#")[0]).trimmingCharacters(in: .whitespaces).dropFirst(2)
            }.map(String.init)
        let configs: [(String, RimeFuzzyPinyinSettings)] = [
            ("F0", .init(enabled: false, zhZEnabled: false, chCEnabled: false, shSEnabled: false, nLEnabled: false)),
            ("F1", .init(enabled: true, zhZEnabled: true, chCEnabled: false, shSEnabled: false, nLEnabled: false)),
            ("F2", .init(enabled: true, zhZEnabled: false, chCEnabled: true, shSEnabled: false, nLEnabled: false)),
            ("F3", .init(enabled: true, zhZEnabled: false, chCEnabled: false, shSEnabled: true, nLEnabled: false)),
            ("F4", .init(enabled: true, zhZEnabled: false, chCEnabled: false, shSEnabled: false, nLEnabled: true)),
            ("F5", .init(enabled: true, zhZEnabled: true, chCEnabled: true, shSEnabled: true, nLEnabled: true)),
        ]
        for (name, settings) in configs {
            let traditional = try scene(
                name, simplified: false, settings: settings, base: base, source: text, builtin: builtin)
            let simplified = try scene(
                name, simplified: true, settings: settings, base: base, source: text, builtin: builtin)
            for input in inputs {
                let left = traditional[input] ?? []; let right = simplified[input] ?? []
                let length = max(left.count, right.count)
                var paired = 0
                var unresolved = 0
                var rows: [String] = []
                for index in 0..<length {
                    let a = index < left.count ? left[index] : nil
                    let b = index < right.count ? right[index] : nil
                    let equal = a != nil && b != nil && a?.comment == b?.comment
                    if equal { paired += 1 } else { unresolved += 1 }
                    rows.append(
                        "\(index):\(a?.text ?? "<absent>"){\(a?.comment ?? "<nil>")}|\(b?.text ?? "<absent>"){\(b?.comment ?? "<nil>")}:\(equal ? "paired" : "undetermined")"
                    )
                }
                print(
                    "LUNA_STACK_COMPARE setting=\(name) input=\(input) paired=\(paired) undetermined=\(unresolved) rows=\(rows)"
                )
            }
        }
    }

    private func scene(
        _ name: String, simplified: Bool, settings: RimeFuzzyPinyinSettings, base: [String], source: String,
        builtin: URL
    ) throws -> [String: [KeyboardCore.RimeCandidate]] {
        let root = try LunaT9EvidenceRoot.directory("overlay-stacking").appendingPathComponent(
            "\(name)-\(simplified)-\(UUID().uuidString)", isDirectory: true)
        try LunaT9EvidenceRoot.createExclusiveDirectory(root)
        let shared = root.appendingPathComponent("shared", isDirectory: true);
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.copyItem(at: builtin, to: shared)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        try source.write(
            to: shared.appendingPathComponent("luna_pinyin_t9.schema.yaml"), atomically: false, encoding: .utf8)
        let defaults = shared.appendingPathComponent("default.yaml");
        var defaultsText = try String(contentsOf: defaults, encoding: .utf8)
        let start = try XCTUnwrap(defaultsText.range(of: "schema_list:\n"));
        let end = try XCTUnwrap(defaultsText.range(of: "\nswitcher:"))
        defaultsText.replaceSubrange(
            start.lowerBound..<end.lowerBound, with: "schema_list:\n  - schema: luna_pinyin_t9\n")
        try defaultsText.write(to: defaults, atomically: false, encoding: .utf8)
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: "luna_pinyin_t9", userDictionarySchemaID: "luna_pinyin", sourceText: source, wanxiangFamily: false
        )
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target], simplificationEnabled: simplified,
            userDictionarySettings: RimeUserDictionarySettings(lunaPinyinEnabled: true, rimeIceEnabled: false),
            fuzzyPinyinSettings: settings, grammarYamlPresent: false, compileInputProven: true)
        XCTAssertEqual(plan.count, 1)
        let overlay = try XCTUnwrap(plan.first)
        try overlay.content.write(to: user.appendingPathComponent(overlay.filename), atomically: false, encoding: .utf8)
        let patchLines = overlay.content.split(separator: "\n").filter {
            $0.trimmingCharacters(in: .whitespaces).hasPrefix("\"")
        }
        let keys = patchLines.map { $0.components(separatedBy: "\"")[1] }
        let counts = Dictionary(grouping: keys, by: { $0 }).mapValues(\.count)
        for (key, count) in counts { XCTAssertEqual(count, 1, "\(name) \(key)") }
        XCTAssertEqual(counts["switches/@2/reset"], 1)
        XCTAssertEqual(counts["translator/enable_user_dict"], 1)
        XCTAssertEqual(counts["speller/algebra"] ?? 0, settings.hasEnabledRules ? 1 : 0)
        XCTAssertTrue(overlay.content.contains("\"switches/@2/reset\": \(simplified ? 1 : 0)"))
        XCTAssertTrue(overlay.content.contains("\"translator/enable_user_dict\": true"))

        print(
            "LUNA_STACK_OVERLAY setting=\(name) simplified=\(simplified) keys=\(counts) BEGIN\n\(overlay.content)END_LUNA_STACK_OVERLAY"
        )
        let manager = RimeSessionManager();
        XCTAssertTrue(manager.setup(withSharedDataDir: shared.path, userDataDir: user.path));
        XCTAssertTrue(manager.initializeEngine()); defer { manager.finalize() }
        let api = try XCTUnwrap(rime_get_api()); let maintenance = try XCTUnwrap(api.pointee.start_maintenance);
        let join = try XCTUnwrap(api.pointee.join_maintenance_thread)
        XCTAssertNotEqual(maintenance(1), 0); join(); XCTAssertTrue(manager.createSession());
        XCTAssertTrue(manager.selectSchema("luna_pinyin_t9"));
        XCTAssertEqual(manager.currentSchemaID(), "luna_pinyin_t9")
        var config = RimeConfig(); let open = try XCTUnwrap(api.pointee.schema_open);
        let close = try XCTUnwrap(api.pointee.config_close); XCTAssertNotEqual(open("luna_pinyin_t9", &config), 0);
        defer { _ = close(&config) }
        let getString = try XCTUnwrap(api.pointee.config_get_cstring);
        let getBool = try XCTUnwrap(api.pointee.config_get_bool); let getInt = try XCTUnwrap(api.pointee.config_get_int)
        var algebra: [String] = [];
        for i in 0..<64 {
            guard let p = getString(&config, "speller/algebra/@\(i)") else { break }; algebra.append(String(cString: p))
        }
        let expected = Array(base.dropLast()) + settings.algebraRules + [try XCTUnwrap(base.last)]
        XCTAssertEqual(algebra, expected, "\(name) \(simplified) compiled algebra")
        if settings.hasEnabledRules {
            let overlayRules = overlay.content.split(separator: "\n").filter {
                $0.hasPrefix("    - ")
            }.map { String($0.dropFirst(6)) }
            XCTAssertEqual(overlayRules, expected, "\(name) overlay algebra")
            XCTAssertEqual(algebra, overlayRules, "\(name) compiled must match overlay")
        }

        let all = RimeFuzzyPinyinSettings(enabled: true).algebraRules
        for rule in all {
            XCTAssertEqual(
                algebra.filter { $0 == rule }.count, settings.algebraRules.contains(rule) ? 1 : 0, "\(name) \(rule)")
        }
        var learning: Int32 = -1; var hints: Int32 = -1
        XCTAssertNotEqual(getBool(&config, "translator/enable_user_dict", &learning), 0); XCTAssertEqual(learning, 1)
        XCTAssertNotEqual(getInt(&config, "translator/spelling_hints", &hints), 0); XCTAssertEqual(hints, 8)
        let getOption = try XCTUnwrap(api.pointee.get_option); let setOption = try XCTUnwrap(api.pointee.set_option);
        let session = UInt(manager.currentSessionIdentifier())
        let automaticHans = getOption(session, "zh_hans") != 0; let automaticHant = getOption(session, "zh_hant") != 0
        XCTAssertEqual(automaticHans, simplified)
        print(
            "LUNA_STACK_CONFIG setting=\(name) simplified=\(simplified) base=\(base) overlayRules=\(settings.algebraRules) compiled=\(algebra) learning=\(learning) hints=\(hints) autoHans=\(automaticHans) autoHant=\(automaticHant)"
        )
        setOption(session, "zh_hant", 1); setOption(session, "zh_hans", simplified ? 0 : 1)
        print(
            "LUNA_STACK_MANUAL setting=\(name) simplified=\(simplified) hans=\(getOption(session, "zh_hans") != 0) hant=\(getOption(session, "zh_hant") != 0)"
        )
        setOption(session, "zh_hant", automaticHant ? 1 : 0); setOption(session, "zh_hans", automaticHans ? 1 : 0)
        var observed: [String: [KeyboardCore.RimeCandidate]] = [:]
        for input in inputs {
            manager.clearComposition(); var output = RimeOutput()
            for index in input.indices {
                output = RimeEngineImpl.parseOutputDictionary(manager.replaceInput(String(input[...index])))
            }
            let candidates = output.candidates; observed[input] = candidates
            XCTAssertEqual(output.rawInput, input, "\(name) \(simplified) input \(input)");
            XCTAssertFalse(candidates.isEmpty, "\(name) \(simplified) \(input)")
            let deleted = RimeEngineImpl.parseOutputDictionary(manager.deleteBackward())
            XCTAssertEqual(deleted.rawInput ?? "", String(input.dropLast()), "\(name) \(simplified) \(input) delete")
            var rows: [[String: Any]] = []
            for candidate in candidates.prefix(10) {
                let comment = candidate.comment ?? ""; let valid = T9PreeditResolver.validatedSource(comment)
                let encoded = valid.map(encode) ?? ""; let prefix = encoded.hasPrefix(input)
                let syllables = valid?.split(whereSeparator: \.isWhitespace).count ?? 0
                let scalars = candidate.text.unicodeScalars;
                let chinese =
                    !scalars.isEmpty && scalars.allSatisfy { (0x3400...0x9fff).contains($0.value) }
                    && !candidate.text.contains("兒") && !candidate.text.contains("儿")
                let equal = chinese && valid != nil && scalars.count == syllables
                rows.append([
                    "text": candidate.text, "comment": comment, "validated": valid ?? "<nil>", "encoded": encoded,
                    "prefix": prefix, "hanCount": scalars.count, "syllables": syllables,
                    "countStatus": chinese ? (equal ? "equal" : "different") : "exception",
                ])
                XCTAssertFalse(
                    comment.contains(where: \.isNumber), "\(name) \(input) comment contains digit: \(comment)")
            }
            let firstComment = candidates.first?.comment.flatMap(T9PreeditResolver.validatedSource) ?? ""
            let equivalence = equivalent(firstComment, input: input, settings: settings)
            XCTAssertNotNil(equivalence, "\(name) \(simplified) \(input) comment=\(firstComment)")
            let record: [String: Any] = [
                "setting": name, "simplified": simplified, "input": input, "raw": output.rawInput ?? "",
                "preedit": output.composition?.preeditText ?? "", "page": output.candidatePageNumber,
                "candidates": rows, "deletedRaw": deleted.rawInput ?? "",
                "matchMethod": equivalence?.0 ?? "none", "matchCombination": equivalence?.1 ?? "",
            ]
            let data = try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]);
            print("LUNA_STACK \(String(decoding: data, as: UTF8.self))")
        }
        return observed
    }
    private func equivalent(_ comment: String, input: String, settings: RimeFuzzyPinyinSettings) -> (String, String)? {
        guard !comment.isEmpty else { return nil }
        let groups: [(String, String, Bool)] = [
            ("zh", "z", settings.enabled && settings.zhZEnabled),
            ("ch", "c", settings.enabled && settings.chCEnabled),
            ("sh", "s", settings.enabled && settings.shSEnabled),
            ("n", "l", settings.enabled && settings.nLEnabled),
        ]
        var combinations = [""]
        for syllable in comment.split(whereSeparator: \.isWhitespace).map(String.init) {
            var options = [syllable]
            for (a, b, active) in groups where active {
                if syllable.hasPrefix(a) {
                    options.append(b + syllable.dropFirst(a.count))
                } else if syllable.hasPrefix(b) {
                    options.append(a + syllable.dropFirst(b.count))
                }
            }
            combinations = combinations.flatMap { prefix in options.map { prefix.isEmpty ? $0 : prefix + " " + $0 } }
        }
        if encode(comment).hasPrefix(input) { return ("direct", comment) }
        if let match = combinations.first(where: { encode($0).hasPrefix(input) }) { return ("fuzzy-equivalent", match) }
        return nil
    }
    private func encode(_ source: String) -> String {
        let groups = ["abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"]
        return source.lowercased().filter { !$0.isWhitespace }.map { c in
            groups.enumerated().first { $0.element.contains(c) }.map { String($0.offset + 2) } ?? "?"
        }.joined()
    }
}
