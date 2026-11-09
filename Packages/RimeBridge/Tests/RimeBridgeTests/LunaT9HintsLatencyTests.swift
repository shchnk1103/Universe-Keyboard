import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

final class LunaT9HintsLatencyTests: XCTestCase {
    private let inputs: [String] = [
        "2", "3", "4", "5", "6", "7", "8", "9",
        "64", "6446", "94664", "444444",
        "644266442", "644266442664", "644266442664426644",
    ]

    override func setUp() {
        super.setUp()
        executionTimeAllowance = 900
    }

    func testHintsLatencyDistribution() throws {
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let original = try Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml"))
        let rewritten = try LunaT9SchemaCompatibility.rewrite(original)
        let v8Source = String(decoding: rewritten, as: UTF8.self)
        XCTAssertEqual(
            v8Source.components(separatedBy: "  spelling_hints: 8\n").count, 2,
            "rewrite must contain exactly one spelling_hints: 8 line")
        let fixture = try Data(
            contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent()
                .appendingPathComponent("Fixtures/LunaT9/variant1.schema.yaml"))
        XCTAssertEqual(Data(v8Source.utf8), fixture, "V8 bytes must equal Fixtures/LunaT9/variant1.schema.yaml")
        let v0Source = v8Source.replacingOccurrences(of: "  spelling_hints: 8\n", with: "")
        let v100Source = v8Source.replacingOccurrences(of: "  spelling_hints: 8\n", with: "  spelling_hints: 100\n")
        XCTAssertFalse(v0Source.contains("spelling_hints:"))
        XCTAssertEqual(v100Source.components(separatedBy: "  spelling_hints: 100\n").count, 2)

        var pass6446: [String: Bool] = [:]
        for (name, source) in [("V0", v0Source), ("V8", v8Source), ("V100", v100Source)] {
            pass6446[name] = try runVariant(name, source: source, builtin: builtin)
        }
        XCTAssertEqual(pass6446["V0"], false, "V0 evaluationPasses on 6446 must be false")
        XCTAssertEqual(pass6446["V8"], true, "V8 evaluationPasses on 6446 must be true")
        XCTAssertEqual(pass6446["V100"], true, "V100 evaluationPasses on 6446 must be true")
    }

    @discardableResult
    private func runVariant(_ variant: String, source: String, builtin: URL) throws -> Bool {
        let root = try LunaT9EvidenceRoot.directory("hints-latency").appendingPathComponent(
            "\(variant)-\(UUID().uuidString)", isDirectory: true)
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
        let manager = RimeSessionManager()
        XCTAssertTrue(manager.setup(withSharedDataDir: shared.path, userDataDir: user.path))
        XCTAssertTrue(manager.initializeEngine())
        let api = try XCTUnwrap(rime_get_api())
        let startMaintenance = try XCTUnwrap(api.pointee.start_maintenance)
        let join = try XCTUnwrap(api.pointee.join_maintenance_thread)
        XCTAssertNotEqual(startMaintenance(1), 0)
        join()
        manager.finalize()
        let engine = RimeEngineImpl(sharedDataDir: shared.path, userDataDir: user.path)
        defer { engine.bridge.clearComposition(); engine.bridge.finalize() }
        XCTAssertTrue(engine.bridge.selectSchema("luna_pinyin_t9"))
        XCTAssertEqual(engine.bridge.currentSchemaID(), "luna_pinyin_t9")

        var evaluationOn6446 = false
        for input in inputs {
            try measureInput(variant: variant, input: input, engine: engine)
            let l4 = recordL4(variant: variant, input: input, engine: engine)
            if input == "6446" {
                evaluationOn6446 = l4
            }
        }
        return evaluationOn6446
    }

    private func measureInput(variant: String, input: String, engine: RimeEngineImpl) throws {
        let keys = Array(input)
        let keyCount = keys.count
        // Discard warmup runs.
        for _ in 0..<3 {
            _ = timedRun(engine: engine, keys: keys)
        }
        var totals: [Double] = []
        var perKey: [[Double]] = Array(repeating: [], count: keyCount)
        for _ in 0..<30 {
            let sample = timedRun(engine: engine, keys: keys)
            totals.append(sample.total)
            for i in 0..<keyCount {
                perKey[i].append(sample.perKey[i])
            }
        }
        XCTAssertEqual(totals.count, 30)
        emitStats(kind: "total", variant: variant, input: input, keyIndex: nil, samples: totals)
        for i in 0..<keyCount {
            XCTAssertEqual(perKey[i].count, 30)
            emitStats(kind: "key", variant: variant, input: input, keyIndex: i + 1, samples: perKey[i])
        }
    }

    private struct TimedSample {
        var total: Double
        var perKey: [Double]
    }

    private func timedRun(engine: RimeEngineImpl, keys: [Character]) -> TimedSample {
        let t0 = DispatchTime.now().uptimeNanoseconds
        engine.resetSession()
        var perKey: [Double] = []
        perKey.reserveCapacity(keys.count)
        for c in keys {
            let k0 = DispatchTime.now().uptimeNanoseconds
            _ = engine.processKey(String(c))
            _ = engine.bridge.candidates(from: 0, limit: 10)
            let k1 = DispatchTime.now().uptimeNanoseconds
            let ms = Double(k1 - k0) / 1_000_000
            perKey.append(ms)
        }
        let t1 = DispatchTime.now().uptimeNanoseconds
        let total = Double(t1 - t0) / 1_000_000
        return TimedSample(total: total, perKey: perKey)
    }

    @discardableResult
    private func recordL4(variant: String, input: String, engine: RimeEngineImpl) -> Bool {
        engine.resetSession()
        var output = RimeOutput()
        for c in input {
            output = engine.processKey(String(c))
        }
        let page = Array(output.candidates.prefix(8))
        let validatedCount = page.filter { candidate in
            guard let comment = candidate.comment else { return false }
            return T9PreeditResolver.validatedSource(comment) != nil
        }.count
        let deleted = engine.deleteBackward()
        let passed = RimeT9SmokeProbe.evaluationPasses(
            raw: output.rawInput ?? "",
            expectedRaw: input,
            candidates: output.candidates,
            rawAfterDelete: deleted.rawInput ?? "",
            expectedAfterDelete: String(input.dropLast()))
        print(
            "LUNA_L4 variant=\(variant) input=\(input) pageCount=\(page.count) commentValidated=\(validatedCount) evaluationPasses=\(passed)"
        )
        return passed
    }

    private func emitStats(
        kind: String, variant: String, input: String, keyIndex: Int?, samples: [Double]
    ) {
        XCTAssertEqual(samples.count, 30)
        for sample in samples {
            XCTAssertTrue(sample.isFinite && sample > 0, "duration must be finite positive")
        }
        let sorted = samples.sorted()
        let minimum = sorted[0]
        let median = (sorted[14] + sorted[15]) / 2
        let p90 = sorted[26]
        let maximum = sorted[29]
        let joined = samples.map { String($0) }.joined(separator: ",")
        if kind == "total" {
            print(
                "LUNA_LATENCY total variant=\(variant) input=\(input) n=30 min_ms=\(minimum) median_ms=\(median) p90_ms=\(p90) max_ms=\(maximum) samples=\(joined)"
            )
        } else if let key = keyIndex {
            print(
                "LUNA_LATENCY key=\(key) variant=\(variant) input=\(input) n=30 min_ms=\(minimum) median_ms=\(median) p90_ms=\(p90) max_ms=\(maximum) samples=\(joined)"
            )
        } else {
            XCTFail("keyIndex missing for key stats")
        }
    }
}
