import CryptoKit
import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

final class LunaT9RelaxedLatencyTests: XCTestCase {
    private let a1SHA = "d8f3327f5dc949ed562deaaa838644e03fa7708957c14b95df025b487d4426c3"
    private let r2SHA = "4ace88759d55296c6c8e3ff078ec14474dc307dca73ecefd5eb94eb96ef7cf27"
    private let digitInputs = ["64", "6446", "94664", "644266442664426644"]
    private let letterInputs = ["ni6", "ni46", "nihao"]

    override func setUp() {
        super.setUp()
        executionTimeAllowance = 2400
    }

    func testRelaxedLatencyAndCompileCost() async throws {
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let rewritten = try LunaT9SchemaCompatibility.rewrite(
            Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml")))
        let fixture = try Data(
            contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent()
                .appendingPathComponent("Fixtures/LunaT9/variant1.schema.yaml"))
        XCTAssertEqual(rewritten, fixture, "R2 rewrite must equal Fixtures/LunaT9/variant1.schema.yaml")
        let r2Source = String(decoding: rewritten, as: UTF8.self)
        XCTAssertEqual(digest(Data(r2Source.utf8)), r2SHA, "R2 SHA mismatch")
        let a1Source = try reverseConstructLegacyA1Output(from: r2Source)
        XCTAssertEqual(digest(Data(a1Source.utf8)), a1SHA, "A1 SHA mismatch")

        let iceRootPath = try XCTUnwrap(
            ProcessInfo.processInfo.environment["LUNA_T9_ICE_FIXTURE"],
            "LUNA_T9_ICE_FIXTURE missing")
        let iceFixture = URL(fileURLWithPath: iceRootPath, isDirectory: true)
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: iceFixture.appendingPathComponent("shared").path),
            "ice shared missing")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: iceFixture.appendingPathComponent("user").path),
            "ice user missing")

        // M1 hot latency
        let a1Hot = try deployLuna(name: "M1-A1", source: a1Source, builtin: builtin, schemaID: "luna_pinyin_t9")
        for input in digitInputs {
            try measureHot(variant: "A1", input: input, engine: a1Hot.engine, schemaID: "luna_pinyin_t9")
        }

        let r2Hot = try deployLuna(name: "M1-R2", source: r2Source, builtin: builtin, schemaID: "luna_pinyin_t9")
        for input in digitInputs + letterInputs {
            try measureHot(variant: "R2", input: input, engine: r2Hot.engine, schemaID: "luna_pinyin_t9")
        }

        let iceHot = try deployIce(name: "M1-ICE", iceFixture: iceFixture)
        for input in digitInputs + letterInputs {
            try measureHot(variant: "ICE", input: input, engine: iceHot.engine, schemaID: "t9")
        }

        finalizeEngine(a1Hot.engine)
        finalizeEngine(r2Hot.engine)
        finalizeEngine(iceHot.engine)

        // M2 cold start (reuse already-deployed shared/user; recreate engines)
        try measureCold(variant: "A1", shared: a1Hot.shared, user: a1Hot.user, schemaID: "luna_pinyin_t9")
        try measureCold(variant: "R2", shared: r2Hot.shared, user: r2Hot.user, schemaID: "luna_pinyin_t9")
        try measureCold(variant: "ICE", shared: iceHot.shared, user: iceHot.user, schemaID: "t9")

        // M3 compile + prism (no live engines)
        try await measureCompile(
            caseName: "A1", source: a1Source, builtin: builtin, iceFixture: nil, fuzzyAll: false)
        try await measureCompile(
            caseName: "R2", source: r2Source, builtin: builtin, iceFixture: nil, fuzzyAll: false)
        try await measureCompile(
            caseName: "R2+FUZZY_ALL", source: r2Source, builtin: builtin, iceFixture: nil, fuzzyAll: true)
        try await measureCompile(
            caseName: "ICE", source: nil, builtin: builtin, iceFixture: iceFixture, fuzzyAll: false)
    }

    // MARK: - Deploy helpers (A7-equivalent for luna; copy fixture for ice)

    private struct Deployed {
        let shared: URL
        let user: URL
        let engine: RimeEngineImpl
    }

    private func deployLuna(name: String, source: String, builtin: URL, schemaID: String) throws -> Deployed {
        let root = try LunaT9EvidenceRoot.directory("relaxed-latency").appendingPathComponent(
            "\(name)-\(UUID().uuidString)", isDirectory: true)
        try LunaT9EvidenceRoot.createExclusiveDirectory(root)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.copyItem(at: builtin, to: shared)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        try source.write(
            to: shared.appendingPathComponent("luna_pinyin_t9.schema.yaml"), atomically: false, encoding: .utf8)
        try rewriteSchemaList(shared: shared, entries: ["luna_pinyin", "luna_pinyin_t9"])
        try runMaintenance(shared: shared, user: user)
        let engine = RimeEngineImpl(sharedDataDir: shared.path, userDataDir: user.path)
        XCTAssertTrue(engine.bridge.selectSchema(schemaID), "\(name) selectSchema \(schemaID)")
        XCTAssertEqual(engine.bridge.currentSchemaID(), schemaID, "\(name) currentSchemaID")
        return Deployed(shared: shared, user: user, engine: engine)
    }

    private func deployIce(name: String, iceFixture: URL) throws -> Deployed {
        let root = try LunaT9EvidenceRoot.directory("relaxed-latency").appendingPathComponent(
            "\(name)-\(UUID().uuidString)", isDirectory: true)
        try LunaT9EvidenceRoot.createExclusiveDirectory(root)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.copyItem(at: iceFixture.appendingPathComponent("shared"), to: shared)
        try FileManager.default.copyItem(at: iceFixture.appendingPathComponent("user"), to: user)
        let engine = RimeEngineImpl(sharedDataDir: shared.path, userDataDir: user.path)
        XCTAssertTrue(engine.bridge.selectSchema("t9"), "\(name) selectSchema t9")
        XCTAssertEqual(engine.bridge.currentSchemaID(), "t9", "\(name) currentSchemaID")
        return Deployed(shared: shared, user: user, engine: engine)
    }

    private func rewriteSchemaList(shared: URL, entries: [String]) throws {
        let defaults = shared.appendingPathComponent("default.yaml")
        var text = try String(contentsOf: defaults, encoding: .utf8)
        let start = try XCTUnwrap(text.range(of: "schema_list:\n"))
        let end = try XCTUnwrap(text.range(of: "\nswitcher:"))
        let body = entries.map { "  - schema: \($0)\n" }.joined()
        text.replaceSubrange(start.lowerBound..<end.lowerBound, with: "schema_list:\n\(body)")
        try text.write(to: defaults, atomically: false, encoding: .utf8)
    }

    private func runMaintenance(shared: URL, user: URL) throws {
        let manager = RimeSessionManager()
        XCTAssertTrue(manager.setup(withSharedDataDir: shared.path, userDataDir: user.path))
        XCTAssertTrue(manager.initializeEngine())
        let api = try XCTUnwrap(rime_get_api())
        let startMaintenance = try XCTUnwrap(api.pointee.start_maintenance)
        let join = try XCTUnwrap(api.pointee.join_maintenance_thread)
        XCTAssertNotEqual(startMaintenance(1), 0)
        join()
        manager.finalize()
    }

    private func finalizeEngine(_ engine: RimeEngineImpl) {
        engine.bridge.clearComposition()
        engine.bridge.finalize()
    }

    // MARK: - M1 hot

    private func measureHot(variant: String, input: String, engine: RimeEngineImpl, schemaID: String)
        throws
    {
        let keys = Array(input)
        let keyCount = keys.count
        for _ in 0..<3 {
            _ = timedRun(engine: engine, keys: keys)
        }
        var totals: [Double] = []
        var perKey: [[Double]] = Array(repeating: [], count: keyCount)
        var lastRaw = ""
        var lastCand = 0
        for _ in 0..<30 {
            let sample = timedRun(engine: engine, keys: keys)
            totals.append(sample.total)
            for i in 0..<keyCount {
                perKey[i].append(sample.perKey[i])
            }
            lastRaw = sample.raw
            lastCand = sample.candidateCount
        }
        emitStats(prefix: "LUNA_LAT_HOT", variant: variant, input: input, keyIndex: nil, samples: totals)
        for i in 0..<keyCount {
            emitStats(
                prefix: "LUNA_LAT_HOT_KEY", variant: variant, input: input, keyIndex: i + 1,
                samples: perKey[i])
        }
        // Functional self-check on last sample values
        let iceLetterMismatch =
            variant == "ICE" && letterInputs.contains(input) && lastRaw != input
        if iceLetterMismatch {
            print(
                "LUNA_LAT_NOTE variant=\(variant) input=\(input) raw=\(lastRaw) cand=\(lastCand) reason=ice-letter-raw-mismatch"
            )
        } else {
            XCTAssertEqual(
                lastRaw, input,
                "self-check raw variant=\(variant) input=\(input) raw=\(lastRaw) schema=\(schemaID)")
            XCTAssertGreaterThanOrEqual(
                lastCand, 1,
                "self-check cand>=1 variant=\(variant) input=\(input) cand=\(lastCand)")
        }
    }

    private struct TimedSample {
        var total: Double
        var perKey: [Double]
        var raw: String
        var candidateCount: Int
    }

    private func timedRun(engine: RimeEngineImpl, keys: [Character]) -> TimedSample {
        let t0 = DispatchTime.now().uptimeNanoseconds
        engine.resetSession()
        var perKey: [Double] = []
        perKey.reserveCapacity(keys.count)
        var output = RimeOutput()
        for c in keys {
            let k0 = DispatchTime.now().uptimeNanoseconds
            output = engine.processKey(String(c))
            _ = engine.bridge.candidates(from: 0, limit: 10)
            let k1 = DispatchTime.now().uptimeNanoseconds
            perKey.append(Double(k1 - k0) / 1_000_000)
        }
        let t1 = DispatchTime.now().uptimeNanoseconds
        let window = RimeEngineImpl.parseCandidateWindowDictionary(
            engine.bridge.candidates(from: 0, limit: 10))
        let candCount = max(output.candidates.count, window.candidates.count)
        return TimedSample(
            total: Double(t1 - t0) / 1_000_000,
            perKey: perKey,
            raw: output.rawInput ?? "",
            candidateCount: candCount)
    }

    // MARK: - M2 cold

    private func measureCold(variant: String, shared: URL, user: URL, schemaID: String) throws {
        var totals: [Double] = []
        var firstKeys: [Double] = []
        let input = "6446"
        let keys = Array(input)
        for _ in 0..<30 {
            let t0 = DispatchTime.now().uptimeNanoseconds
            let engine = RimeEngineImpl(sharedDataDir: shared.path, userDataDir: user.path)
            XCTAssertTrue(engine.bridge.selectSchema(schemaID))
            XCTAssertEqual(engine.bridge.currentSchemaID(), schemaID)
            var firstKeyMS: Double = 0
            for (idx, c) in keys.enumerated() {
                let k0 = DispatchTime.now().uptimeNanoseconds
                _ = engine.processKey(String(c))
                _ = engine.bridge.candidates(from: 0, limit: 10)
                let k1 = DispatchTime.now().uptimeNanoseconds
                if idx == 0 {
                    firstKeyMS = Double(k1 - k0) / 1_000_000
                }
            }
            let t1 = DispatchTime.now().uptimeNanoseconds
            totals.append(Double(t1 - t0) / 1_000_000)
            firstKeys.append(firstKeyMS)
            finalizeEngine(engine)
        }
        emitStats(prefix: "LUNA_LAT_COLD", variant: variant, input: input, keyIndex: nil, samples: totals)
        emitStats(
            prefix: "LUNA_LAT_COLD_KEY", variant: variant, input: input, keyIndex: 1, samples: firstKeys)
    }

    // MARK: - M3 compile

    private func measureCompile(
        caseName: String, source: String?, builtin: URL, iceFixture: URL?, fuzzyAll: Bool
    ) async throws {
        for run in 1...3 {
            let root = try LunaT9EvidenceRoot.directory("relaxed-latency").appendingPathComponent(
                "M3-\(caseName)-\(run)-\(UUID().uuidString)", isDirectory: true)
            try LunaT9EvidenceRoot.createExclusiveDirectory(root)
            let shared = root.appendingPathComponent("shared", isDirectory: true)
            let user = root.appendingPathComponent("user", isDirectory: true)
            let prismName: String
            if let iceFixture {
                try FileManager.default.copyItem(at: iceFixture.appendingPathComponent("shared"), to: shared)
                try FileManager.default.copyItem(at: iceFixture.appendingPathComponent("user"), to: user)
                prismName = "t9.prism.bin"
                let build = user.appendingPathComponent("build", isDirectory: true)
                let prismURL = build.appendingPathComponent("t9.prism.bin")
                let schemaURL = build.appendingPathComponent("t9.schema.yaml")
                if FileManager.default.fileExists(atPath: prismURL.path) {
                    try FileManager.default.removeItem(at: prismURL)
                }
                if FileManager.default.fileExists(atPath: schemaURL.path) {
                    try FileManager.default.removeItem(at: schemaURL)
                }
                let preexisting = FileManager.default.fileExists(atPath: prismURL.path)
                XCTAssertFalse(preexisting, "ICE prism must be deleted before deploy")
                let t0 = DispatchTime.now().uptimeNanoseconds
                let deployment = try await RimeDeploymentService().deploy(
                    RimeDeploymentRequest(
                        mode: .testFixtureMaintenanceOnly, sharedDataURL: shared, userDataURL: user,
                        runtimeSmokeSchemaID: nil))
                let t1 = DispatchTime.now().uptimeNanoseconds
                let deployMS = Double(t1 - t0) / 1_000_000
                let prismBytes = prismByteCount(userBuild: build, name: prismName)
                print(
                    "LUNA_LAT_COMPILE case=\(caseName) run=\(run) deploy_ms=\(deployMS) prismBytes=\(prismBytes) prismPreexisting=\(preexisting) succeeded=\(deployment.succeeded) diagnostic=\(deployment.diagnosticMessage)"
                )
                if !deployment.succeeded {
                    print(
                        "LUNA_LAT_NOTE case=\(caseName) run=\(run) deploy_failed diagnostic=\(deployment.diagnosticMessage)"
                    )
                }
            } else {
                let src = try XCTUnwrap(source)
                try FileManager.default.copyItem(at: builtin, to: shared)
                try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
                try src.write(
                    to: shared.appendingPathComponent("luna_pinyin_t9.schema.yaml"), atomically: false,
                    encoding: .utf8)
                try rewriteSchemaList(shared: shared, entries: ["luna_pinyin", "luna_pinyin_t9"])
                if fuzzyAll {
                    let target = RimeConfigManager.SchemaSwitchTarget(
                        schemaID: "luna_pinyin_t9", userDictionarySchemaID: "luna_pinyin", sourceText: src,
                        wanxiangFamily: false)
                    let plan = RimeConfigManager.planSchemaCustomYamlFiles(
                        targets: [target], simplificationEnabled: true,
                        userDictionarySettings: .init(lunaPinyinEnabled: true, rimeIceEnabled: false),
                        fuzzyPinyinSettings: .init(enabled: true), grammarYamlPresent: false,
                        compileInputProven: true)
                    let overlay = try XCTUnwrap(plan.first)
                    try overlay.content.write(
                        to: user.appendingPathComponent(overlay.filename), atomically: false, encoding: .utf8)
                }
                prismName = "luna_pinyin_t9.prism.bin"
                let sharedBuild = shared.appendingPathComponent("build", isDirectory: true)
                let userBuild = user.appendingPathComponent("build", isDirectory: true)
                XCTAssertFalse(
                    FileManager.default.fileExists(
                        atPath: sharedBuild.appendingPathComponent(prismName).path),
                    "\(caseName) shared/build must not contain \(prismName)")
                XCTAssertFalse(
                    FileManager.default.fileExists(atPath: userBuild.appendingPathComponent(prismName).path),
                    "\(caseName) user/build must not contain \(prismName)")
                let preexisting = FileManager.default.fileExists(
                    atPath: userBuild.appendingPathComponent(prismName).path)
                let t0 = DispatchTime.now().uptimeNanoseconds
                let deployment = try await RimeDeploymentService().deploy(
                    RimeDeploymentRequest(
                        mode: .testFixtureMaintenanceOnly, sharedDataURL: shared, userDataURL: user,
                        runtimeSmokeSchemaID: nil))
                let t1 = DispatchTime.now().uptimeNanoseconds
                let deployMS = Double(t1 - t0) / 1_000_000
                try? FileManager.default.createDirectory(at: userBuild, withIntermediateDirectories: true)
                let listed = (try? FileManager.default.contentsOfDirectory(atPath: userBuild.path)) ?? []
                print("LUNA_LAT_NOTE case=\(caseName) run=\(run) userBuildListing=\(listed.sorted())")
                let prismBytes = prismByteCount(userBuild: userBuild, name: prismName)
                print(
                    "LUNA_LAT_COMPILE case=\(caseName) run=\(run) deploy_ms=\(deployMS) prismBytes=\(prismBytes) prismPreexisting=\(preexisting) succeeded=\(deployment.succeeded) diagnostic=\(deployment.diagnosticMessage)"
                )
                if !deployment.succeeded {
                    print(
                        "LUNA_LAT_NOTE case=\(caseName) run=\(run) deploy_failed diagnostic=\(deployment.diagnosticMessage)"
                    )
                }
            }
        }
    }

    private func prismByteCount(userBuild: URL, name: String) -> String {
        let url = userBuild.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: url.path),
            let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
            let size = attrs[.size] as? NSNumber
        else {
            return "<missing>"
        }
        return "\(size.intValue)"
    }

    // MARK: - Stats / A1 reverse / digest

    private func emitStats(
        prefix: String, variant: String, input: String, keyIndex: Int?, samples: [Double]
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
        if let key = keyIndex {
            print(
                "\(prefix) key=\(key) variant=\(variant) input=\(input) n=30 min_ms=\(minimum) median_ms=\(median) p90_ms=\(p90) max_ms=\(maximum) samples=\(joined)"
            )
        } else {
            print(
                "\(prefix) variant=\(variant) input=\(input) n=30 min_ms=\(minimum) median_ms=\(median) p90_ms=\(p90) max_ms=\(maximum) samples=\(joined)"
            )
        }
    }

    private func reverseConstructLegacyA1Output(from source: String) throws -> String {
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
        return source.replacingOccurrences(of: alphaNew, with: alphaOld)
            .replacingOccurrences(of: derives, with: xlit)
    }

    private func digest(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
