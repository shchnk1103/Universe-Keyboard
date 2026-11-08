import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

final class LunaT9ComposingDisplayTests: XCTestCase {
    @MainActor func testComposingMatrix() throws {
        var repo = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repo.deleteLastPathComponent() }
        let builtin = repo.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let source = String(
            decoding: try LunaT9SchemaCompatibility.rewrite(
                Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml"))), as: UTF8.self)
        let configs: [(String, RimeFuzzyPinyinSettings)] = [
            ("F0", .init(enabled: false, zhZEnabled: false, chCEnabled: false, shSEnabled: false, nLEnabled: false)),
            ("F1", .init(enabled: true, zhZEnabled: true, chCEnabled: false, shSEnabled: false, nLEnabled: false)),
            ("F2", .init(enabled: true, zhZEnabled: false, chCEnabled: true, shSEnabled: false, nLEnabled: false)),
            ("F3", .init(enabled: true, zhZEnabled: false, chCEnabled: false, shSEnabled: true, nLEnabled: false)),
            ("F4", .init(enabled: true, zhZEnabled: false, chCEnabled: false, shSEnabled: false, nLEnabled: true)),
            ("F5", .init(enabled: true, zhZEnabled: true, chCEnabled: true, shSEnabled: true, nLEnabled: true)),
        ]
        for (name, settings) in configs {
            for simplified in [false, true] {
                try scene(name, simplified: simplified, settings: settings, builtin: builtin, source: source)
            }
        }
    }
    @MainActor private func scene(
        _ name: String, simplified: Bool, settings: RimeFuzzyPinyinSettings, builtin: URL, source: String
    ) throws {
        let root = try LunaT9EvidenceRoot.directory("compose").appendingPathComponent(
            "\(name)-\(simplified)-\(UUID().uuidString)", isDirectory: true)
        try LunaT9EvidenceRoot.createExclusiveDirectory(root)
        let shared = root.appendingPathComponent("shared", isDirectory: true);
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.copyItem(at: builtin, to: shared);
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        try source.write(
            to: shared.appendingPathComponent("luna_pinyin_t9.schema.yaml"), atomically: false, encoding: .utf8)
        let defaults = shared.appendingPathComponent("default.yaml");
        var text = try String(contentsOf: defaults, encoding: .utf8)
        let start = try XCTUnwrap(text.range(of: "schema_list:\n"));
        let end = try XCTUnwrap(text.range(of: "\nswitcher:"))
        text.replaceSubrange(start.lowerBound..<end.lowerBound, with: "schema_list:\n  - schema: luna_pinyin_t9\n")
        try text.write(to: defaults, atomically: false, encoding: .utf8)
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: "luna_pinyin_t9", userDictionarySchemaID: "luna_pinyin", sourceText: source, wanxiangFamily: false
        )
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target], simplificationEnabled: simplified,
            userDictionarySettings: .init(lunaPinyinEnabled: true, rimeIceEnabled: false),
            fuzzyPinyinSettings: settings, grammarYamlPresent: false, compileInputProven: true)
        let overlay = try XCTUnwrap(plan.first);
        try overlay.content.write(to: user.appendingPathComponent(overlay.filename), atomically: false, encoding: .utf8)
        let manager = RimeSessionManager();
        XCTAssertTrue(manager.setup(withSharedDataDir: shared.path, userDataDir: user.path));
        XCTAssertTrue(manager.initializeEngine())
        let api = try XCTUnwrap(rime_get_api()); let startMaintenance = try XCTUnwrap(api.pointee.start_maintenance);
        let join = try XCTUnwrap(api.pointee.join_maintenance_thread)
        XCTAssertNotEqual(startMaintenance(1), 0); join(); manager.finalize()
        let engine = RimeEngineImpl(sharedDataDir: shared.path, userDataDir: user.path)
        defer { engine.bridge.clearComposition(); engine.bridge.finalize() }
        XCTAssertTrue(engine.bridge.selectSchema("luna_pinyin_t9"));
        XCTAssertEqual(engine.bridge.currentSchemaID(), "luna_pinyin_t9")
        for input in ["6446", "94664", "9664", "244", "24", "744", "74", "64", "54"] {
            engine.bridge.clearComposition()
            let controller = KeyboardController(); let client = FakeTextInputClient()
            controller.rimeEngine = engine; controller.usesT9InputSemantics = true; controller.textClient = client
            var steps: [[String: Any]] = []; var marks: [String] = []
            for key in input {
                _ = controller.handle(.insertKey(String(key)))
                let snap = controller.t9CompositionPresentationSnapshot(); let mark = client.markedText;
                marks.append(mark)
                let path = snap.paths.first { $0.id == snap.provisionalPathID }
                steps.append([
                    "marked": mark, "path": path?.displayText ?? "<absent>", "slots": path?.consumedSlotCount ?? 0,
                ])
                XCTAssertFalse(
                    mark.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    "A1 \(name) \(simplified) \(input) marked=\(mark)")
                XCTAssertFalse(mark.contains(where: \.isNumber), "A2 \(name) \(simplified) \(input) marked=\(mark)")
                if let path {
                    let prefix = String(input.prefix(marks.count)); let digits = encode(path.displayText)
                    XCTAssertNotNil(digits, "A3 \(name) \(simplified) \(input) path=\(path.displayText)")
                    if let digits {
                        XCTAssertTrue(
                            prefix.hasPrefix(digits),
                            "A3 \(name) \(simplified) \(input) path=\(path.displayText) encoded=\(digits) prefix=\(prefix)"
                        )
                    }
                }
            }
            let snapshot = controller.t9CompositionPresentationSnapshot()
            let candidates = snapshot.candidates.prefix(5).map { ["text": $0.text, "comment": $0.comment ?? ""] }
            _ = controller.handle(.deleteBackward); let after = client.markedText;
            let expected = marks.count > 1 ? marks[marks.count - 2] : ""
            XCTAssertEqual(after, expected, "A4 \(name) \(simplified) \(input) marked=\(after) expected=\(expected)")
            let row: [String: Any] = [
                "setting": name, "simplified": simplified, "input": input, "steps": steps, "candidates": candidates,
                "afterDelete": after,
            ]
            let data = try JSONSerialization.data(withJSONObject: row, options: [.sortedKeys]);
            let encoded = String(decoding: data, as: UTF8.self)
            print("LUNA_COMPOSE \(encoded)")
            if (name == "F1" && input == "9664") || (name == "F4" && ["6446", "54"].contains(input))
                || (name == "F5" && ["6446", "9664", "54"].contains(input))
            {
                print("LUNA_COMPOSE_KNOWN \(encoded)")
            }
        }
    }
    func testPathEncodingFiltersNonLettersPerSyllable() {
        XCTAssertEqual(encode("ni,"), "64")
        XCTAssertEqual(encode("n!i ' h@ao"), "64426")
        XCTAssertEqual(encode("nü"), "68")
        XCTAssertEqual(encode("nv"), "68")
        XCTAssertNil(encode("ni 123"))
        XCTAssertNil(encode("!?,"))
        XCTAssertNil(encode(""))
    }

    private func encode(_ path: String) -> String? {
        let parts = path.lowercased().replacingOccurrences(of: "ü", with: "v").split {
            $0.isWhitespace || $0 == "'"
        }
        guard !parts.isEmpty else { return nil }
        let groups = ["abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"]
        var digits = ""
        for part in parts {
            let letters = part.unicodeScalars.filter { (97...122).contains($0.value) }
            guard !letters.isEmpty else { return nil }
            for scalar in letters {
                guard let index = groups.firstIndex(where: { $0.unicodeScalars.contains(scalar) }) else { return nil }
                digits += String(index + 2)
            }
        }
        return digits
    }
}
