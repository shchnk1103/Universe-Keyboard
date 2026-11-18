import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

final class LunaT9LetterInputContractTests: XCTestCase {
    private let schema = "luna_pinyin_t9"

    func testLetterInputMatrixOnRelaxedVariant() async throws {
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let original = try Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml"))
        let derived = try LunaT9SchemaCompatibility.rewrite(original)
        let fixture = try Data(
            contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent()
                .appendingPathComponent("Fixtures/LunaT9/variant1.schema.yaml"))
        XCTAssertEqual(derived, fixture)
        let source = String(decoding: derived, as: UTF8.self)

        // a–e default: simplified false (S0 Vαβ / 你好嗎)
        try await withEngine(builtin: builtin, source: source, simplified: false, name: "letters-trad") {
            engine in
            // a. 64
            self.assertSample(engine, input: "64", expectFirst: "你", label: "a-64")
            // b. pure letters
            self.assertSample(engine, input: "ni", expectFirst: "你", label: "b-ni", allowNilComments: true)
            self.assertSample(engine, input: "mi", expectFirst: "米", label: "b-mi", allowNilComments: true)
            self.assertSample(engine, input: "nin", expectFirst: "您", label: "b-nin", allowNilComments: true)
            // c. mixed
            self.assertSample(engine, input: "ni6", expectFirst: "你哦", label: "c-ni6")
            self.assertSample(engine, input: "ni46", expectFirst: "你好嗎", label: "c-ni46")
            self.assertSample(engine, input: "o4", expectFirst: "耦合", label: "c-o4")
            self.assertSample(engine, input: "m4", expectFirst: "米", label: "c-m4")
            self.assertSample(engine, input: "n4", expectFirst: "你", label: "c-n4")
            // d. ü + separator (trad)
            self.assertContainsInTop5(engine, input: "nv", needle: "女", label: "d-nv")
            self.assertContainsInTop5(engine, input: "lv", needle: "綠", label: "d-lv-trad")
            self.assertSample(engine, input: "ni'hao", expectFirst: "你好", label: "d-nihao")
            // d. uppercase observation only
            let upper = self.observeSteps(engine, input: "NI", label: "d-NI-observe")
            print(
                "LUNA_LETTER_OBS input=NI finalRaw=\(upper.raw) count=\(upper.count) top5=\(upper.top5)"
            )
        }

        // d. lv simplified green
        try await withEngine(builtin: builtin, source: source, simplified: true, name: "letters-simp-lv") {
            engine in
            self.assertContainsInTop5(engine, input: "lv", needle: "绿", label: "d-lv-simp")
        }
    }

    private struct FinalObs {
        var raw: String
        var count: Int
        var top5: [String]
    }

    @discardableResult
    private func observeSteps(_ engine: RimeEngineImpl, input: String, label: String) -> FinalObs {
        engine.resetSession()
        var output = RimeOutput()
        var step = 0
        for ch in input {
            step += 1
            output = engine.processKey(String(ch))
            let top = output.candidates.prefix(5).map { cand -> String in
                let c = cand.comment ?? "<nil>"
                return "\(cand.text)|\(c)"
            }
            print(
                "LUNA_LETTER label=\(label) input=\(input) step=\(step) key=\(ch) raw=\(output.rawInput ?? "") count=\(output.candidates.count) top5=\(top) preedit=\(output.composition?.preeditText ?? "")"
            )
        }
        return FinalObs(
            raw: output.rawInput ?? "",
            count: output.candidates.count,
            top5: output.candidates.prefix(5).map(\.text))
    }

    private func assertSample(
        _ engine: RimeEngineImpl, input: String, expectFirst: String, label: String,
        allowNilComments: Bool = false
    ) {
        let obs = observeSteps(engine, input: input, label: label)
        XCTAssertEqual(obs.raw, input, "\(label) raw")
        XCTAssertGreaterThanOrEqual(obs.count, 1, "\(label) candidates")
        XCTAssertEqual(obs.top5.first, expectFirst, "\(label) first candidate; top5=\(obs.top5)")
        _ = allowNilComments
    }

    private func assertContainsInTop5(
        _ engine: RimeEngineImpl, input: String, needle: String, label: String
    ) {
        let obs = observeSteps(engine, input: input, label: label)
        XCTAssertEqual(obs.raw, input, "\(label) raw")
        XCTAssertGreaterThanOrEqual(obs.count, 1, "\(label) candidates")
        XCTAssertTrue(
            obs.top5.contains(needle),
            "\(label) expected \(needle) in top5=\(obs.top5)")
    }

    private func withEngine(
        builtin: URL, source: String, simplified: Bool, name: String,
        body: (RimeEngineImpl) throws -> Void
    ) async throws {
        let root = try LunaT9EvidenceRoot.directory("letter-input").appendingPathComponent(
            "\(name)-\(UUID().uuidString)", isDirectory: true)
        try LunaT9EvidenceRoot.createExclusiveDirectory(root)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.copyItem(at: builtin, to: shared)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        try source.write(
            to: shared.appendingPathComponent("luna_pinyin_t9.schema.yaml"), atomically: false,
            encoding: .utf8)
        let defaults = shared.appendingPathComponent("default.yaml")
        var text = try String(contentsOf: defaults, encoding: .utf8)
        let start = try XCTUnwrap(text.range(of: "schema_list:\n"))
        let end = try XCTUnwrap(text.range(of: "\nswitcher:"))
        text.replaceSubrange(
            start.lowerBound..<end.lowerBound,
            with: "schema_list:\n  - schema: luna_pinyin\n  - schema: luna_pinyin_t9\n")
        try text.write(to: defaults, atomically: false, encoding: .utf8)
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: schema, userDictionarySchemaID: "luna_pinyin", sourceText: source,
            wanxiangFamily: false)
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target], simplificationEnabled: simplified,
            userDictionarySettings: RimeUserDictionarySettings(
                lunaPinyinEnabled: false, rimeIceEnabled: false),
            compileInputProven: true)
        let overlay = try XCTUnwrap(plan.first)
        try overlay.content.write(
            to: user.appendingPathComponent(overlay.filename), atomically: false, encoding: .utf8)
        let deployment = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .testFixtureMaintenanceOnly, sharedDataURL: shared, userDataURL: user,
                runtimeSmokeSchemaID: nil))
        print("LUNA_LETTER_DEPLOY \(name) success=\(deployment.succeeded) diagnostic=\(deployment.diagnosticMessage)")
        XCTAssertTrue(deployment.succeeded)
        let engine = RimeEngineImpl(sharedDataDir: shared.path, userDataDir: user.path)
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        XCTAssertTrue(engine.bridge.selectSchema(schema))
        XCTAssertEqual(engine.bridge.currentSchemaID(), schema)
        try body(engine)
    }
}
