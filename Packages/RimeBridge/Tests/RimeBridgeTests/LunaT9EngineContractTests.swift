import CryptoKit
import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

final class LunaT9EngineContractTests: XCTestCase {
    private let schema = "luna_pinyin_t9"

    func testRealEngineContracts() async throws {
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let original = try Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml"))
        let derived = try LunaT9SchemaCompatibility.rewrite(original)
        let fixture = try Data(
            contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent()
                .appendingPathComponent("Fixtures/LunaT9/variant1.schema.yaml"))
        func digest(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }
        print("LUNA_SOURCES derived=\(digest(derived)) fixture=\(digest(fixture)) equal=\(derived == fixture)")
        XCTAssertEqual(derived, fixture)
        let source = String(decoding: derived, as: UTF8.self)

        for (input, expectedDelete, first) in [
            ("6", "", ""), ("44", "4", ""), ("444444", "44444", ""),
            ("64", "6", "你"), ("6446", "644", "你功能"), ("94664", "9466", "中"),
        ] {
            try await withEngine(builtin: builtin, source: source, simplified: false, name: "traditional-\(input)") {
                engine in
                let (output, window, deleted) = self.observe(engine, input: input, label: "traditional")
                XCTAssertEqual(output.rawInput, input)
                XCTAssertEqual(deleted.rawInput ?? "", expectedDelete)
                XCTAssertFalse(output.candidates.isEmpty)
                if !first.isEmpty { XCTAssertEqual(output.candidates.first?.text, first) }
                if input == "6" {
                    XCTAssertEqual(output.candidates.count, 5)
                    XCTAssertTrue(output.candidates.contains { $0.text == "哦" })
                }
                if input == "6446" { XCTAssertTrue(window.candidates.contains { $0.text == "你好嗎" }) }
            }
        }
        try await withEngine(builtin: builtin, source: source, simplified: true, name: "simplified") { engine in
            let (_, window, _) = self.observe(engine, input: "6446", label: "simplified")
            XCTAssertTrue(window.candidates.contains { $0.text == "你好吗" })
        }
        for simplified in [false, true] {
            try await withEngine(
                builtin: builtin, source: source, simplified: simplified, name: "letters-\(simplified)"
            ) { engine in
                XCTAssertTrue(engine.bridge.selectSchema("luna_pinyin"))
                XCTAssertEqual(engine.bridge.currentSchemaID(), "luna_pinyin")
                for input in ["ni", "hao"] {
                    let (output, _, deleted) = self.observe(engine, input: input, label: "letters-\(simplified)")
                    XCTAssertEqual(output.rawInput, input)
                    XCTAssertEqual(deleted.rawInput, String(input.dropLast()))
                    XCTAssertFalse(output.candidates.isEmpty)
                }
            }
        }
        try await withEngine(builtin: builtin, source: source, simplified: false, name: "smoke") { engine in
            engine.resetSession()
            var output = RimeOutput()
            for c in "6446" { output = engine.processKey(String(c)) }
            let deleted = engine.deleteBackward()
            let result = RimeT9SmokeProbe.evaluationPasses(
                raw: output.rawInput ?? "", expectedRaw: "6446", candidates: output.candidates,
                rawAfterDelete: deleted.rawInput ?? "", expectedAfterDelete: "644")
            print(
                "LUNA_SMOKE raw=\(output.rawInput ?? "") candidates=\(output.candidates) delete=\(deleted.rawInput ?? "") passes=\(result)"
            )
            XCTAssertTrue(result, "real engine must satisfy existing smoke evaluation")
            XCTAssertFalse(
                RimeT9SmokeProbe.evaluationPasses(
                    raw: "6446", expectedRaw: "6446", candidates: [], rawAfterDelete: "644", expectedAfterDelete: "644")
            )
            XCTAssertFalse(
                RimeT9SmokeProbe.evaluationPasses(
                    raw: "6446", expectedRaw: "6446", candidates: [RimeCandidate(text: "你", comment: "")],
                    rawAfterDelete: "644", expectedAfterDelete: "644"))
            XCTAssertFalse(
                RimeT9SmokeProbe.evaluationPasses(
                    raw: "6446", expectedRaw: "6446", candidates: [RimeCandidate(text: "你", comment: "ni")],
                    rawAfterDelete: "64", expectedAfterDelete: "644"))
        }
    }

    private func withEngine(
        builtin: URL, source: String, simplified: Bool, name: String, body: (RimeEngineImpl) throws -> Void
    ) async throws {
        let root = try LunaT9EvidenceRoot.directory("engine-contract").appendingPathComponent(
            "\(name)-\(UUID().uuidString)", isDirectory: true)
        try LunaT9EvidenceRoot.createExclusiveDirectory(root)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.copyItem(at: builtin, to: shared)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        try source.write(
            to: shared.appendingPathComponent("luna_pinyin_t9.schema.yaml"), atomically: false, encoding: .utf8)
        let defaults = shared.appendingPathComponent("default.yaml")
        var text = try String(contentsOf: defaults, encoding: .utf8)
        let start = try XCTUnwrap(text.range(of: "schema_list:\n"))
        let end = try XCTUnwrap(text.range(of: "\nswitcher:"))
        text.replaceSubrange(
            start.lowerBound..<end.lowerBound,
            with: "schema_list:\n  - schema: luna_pinyin\n  - schema: luna_pinyin_t9\n")
        try text.write(to: defaults, atomically: false, encoding: .utf8)
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: schema, userDictionarySchemaID: "luna_pinyin", sourceText: source, wanxiangFamily: false)
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target], simplificationEnabled: simplified,
            userDictionarySettings: RimeUserDictionarySettings(lunaPinyinEnabled: false, rimeIceEnabled: false),
            compileInputProven: true)
        let overlay = try XCTUnwrap(plan.first)
        try overlay.content.write(to: user.appendingPathComponent(overlay.filename), atomically: false, encoding: .utf8)
        let deployment = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .testFixtureMaintenanceOnly, sharedDataURL: shared, userDataURL: user, runtimeSmokeSchemaID: nil))
        print("LUNA_DEPLOY \(name) success=\(deployment.succeeded) diagnostic=\(deployment.diagnosticMessage)")
        XCTAssertTrue(deployment.succeeded)
        XCTAssertFalse(
            RimeT9SmokeProbe.verify(sharedDataDir: shared.path, userDataDir: user.path, schemaID: schema, input: "6446")
        )
        let engine = RimeEngineImpl(sharedDataDir: shared.path, userDataDir: user.path)
        defer { engine.bridge.clearComposition(); engine.bridge.finalize() }
        XCTAssertTrue(engine.bridge.selectSchema(schema))
        XCTAssertEqual(engine.bridge.currentSchemaID(), schema)
        try body(engine)
    }

    private func observe(_ engine: RimeEngineImpl, input: String, label: String) -> (
        RimeOutput, RimeCandidateWindow, RimeOutput
    ) {
        engine.resetSession()
        var output = RimeOutput()
        for c in input { output = engine.processKey(String(c)) }
        let window = RimeEngineImpl.parseCandidateWindowDictionary(engine.bridge.candidates(from: 0, limit: 10))
        let deleted = engine.deleteBackward()
        let candidates = window.candidates.map { "\($0.text){\($0.comment ?? "")}" }.joined(separator: "|")
        print(
            "LUNA_SAMPLE label=\(label) input=\(input) raw=\(output.rawInput ?? "") preedit=\(output.composition?.preeditText ?? "") page=\(output.candidatePageNumber) pageSize=\(output.candidates.count) pageHasMore=\(output.hasMorePages) windowHasMore=\(window.hasMoreCandidates) candidates=\(candidates) delete=\(deleted.rawInput ?? "")"
        )
        return (output, window, deleted)
    }
}
