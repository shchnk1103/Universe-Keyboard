import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

@MainActor
final class LunaT9MixedKeyGroupContractTests: XCTestCase {
    func testMixedKeyGroupPathsLowercaseAndS0FirstCandidates() throws {
        let scene = try openScene(name: "C5-mixed")
        defer { scene.finish() }

        func freshController() -> (KeyboardController, FakeTextInputClient) {
            scene.engine.resetSession()
            let controller = KeyboardController()
            let client = FakeTextInputClient()
            controller.rimeEngine = scene.engine
            controller.usesT9InputSemantics = true
            controller.textClient = client
            return (controller, client)
        }

        // Path snapshots for digit groups: only [a-z0-9']
        for input in ["64", "6446", "94664", "22"] {
            let (controller, client) = freshController()
            resetHost(client)
            for key in input {
                _ = controller.handle(.insertKey(String(key)))
            }
            let snap = controller.t9CompositionPresentationSnapshot()
            for path in snap.paths {
                let ok = path.replacementRawInput.unicodeScalars.allSatisfy { scalar in
                    (97...122).contains(scalar.value) || (48...57).contains(scalar.value) || scalar == "'"
                }
                XCTAssertTrue(
                    ok,
                    "C5 path replacement must be [a-z0-9']; input=\(input) display=\(path.displayText) repl=\(path.replacementRawInput)"
                )
            }
            print(
                "LUNA_MIXED paths input=\(input) count=\(snap.paths.count) list=\(snap.paths.map { "\($0.displayText)=>\($0.replacementRawInput)" })"
            )
        }

        let samples: [(keys: String, pathDisplay: String?, append: String, expectRaw: String, expectFirst: String?)] =
            [
                ("6", "m", "4", "m4", "米"),
                ("6", "n", "4", "n4", "你"),
                ("22", "b", "", "b2", nil),
                ("64", "ni", "6", "ni6", "你哦"),
                ("64", "ni", "46", "ni46", "你好嗎"),
            ]
        for sample in samples {
            let (controller, client) = freshController()
            resetHost(client)
            for key in sample.keys {
                _ = controller.handle(.insertKey(String(key)))
            }
            let snap0 = controller.t9CompositionPresentationSnapshot()
            if let display = sample.pathDisplay {
                guard let path = snap0.paths.first(where: { $0.displayText == display }) else {
                    print(
                        "LUNA_MIXED sample=\(sample.expectRaw) result=FINDING missing-path display=\(display) paths=\(snap0.paths.map(\.displayText))"
                    )
                    XCTFail("C5 missing path \(display) for \(sample.expectRaw)")
                    continue
                }
                _ = controller.handle(.selectT9PinyinPath(path))
            }
            for key in sample.append {
                _ = controller.handle(.insertKey(String(key)))
            }
            let snap = controller.t9CompositionPresentationSnapshot()
            let raw = snap.rimeRawInput ?? controller.state.lastRimeOutput?.rawInput ?? ""
            let rawNorm = T9PinyinPathExtractor.normalizeRawIdentity(raw)
            let expectNorm = T9PinyinPathExtractor.normalizeRawIdentity(sample.expectRaw)
            let first = snap.candidates.first?.text ?? ""
            let count = snap.candidates.count
            print(
                "LUNA_MIXED sample=\(sample.expectRaw) raw=\(raw) rawNorm=\(rawNorm) marked=\(client.markedText) count=\(count) first=\(first)"
            )
            XCTAssertEqual(rawNorm, expectNorm, "C5 raw for \(sample.expectRaw)")
            XCTAssertGreaterThanOrEqual(count, 1, "C5 cand>=1 for \(sample.expectRaw)")
            if let expectFirst = sample.expectFirst {
                XCTAssertEqual(first, expectFirst, "C5 first candidate for \(sample.expectRaw); actual=\(first)")
            }
        }
    }

    private struct Scene {
        let engine: RimeEngineImpl
        let controller: KeyboardController
        let client: FakeTextInputClient
        let shared: URL
        let user: URL
        func finish() {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
    }

    private func openScene(name: String) throws -> Scene {
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let rewritten = try LunaT9SchemaCompatibility.rewrite(
            Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml")))
        let fixture = try Data(
            contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent()
                .appendingPathComponent("Fixtures/LunaT9/variant1.schema.yaml"))
        XCTAssertEqual(rewritten, fixture)
        let source = String(decoding: rewritten, as: UTF8.self)
        let root = try LunaT9EvidenceRoot.directory("s3b-contract").appendingPathComponent(
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
        XCTAssertTrue(engine.bridge.selectSchema("luna_pinyin_t9"))
        XCTAssertEqual(engine.bridge.currentSchemaID(), "luna_pinyin_t9")
        let controller = KeyboardController()
        let client = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        controller.textClient = client
        return Scene(engine: engine, controller: controller, client: client, shared: shared, user: user)
    }

    private func resetHost(_ client: FakeTextInputClient) {
        client.unmarkText()
        while client.hasTextBeforeInput { client.deleteBackward() }
    }

    private func hostCommitted(_ client: FakeTextInputClient) -> String {
        let mark = client.markedText.count
        if mark == 0 { return client.text }
        if mark >= client.text.count { return "" }
        return String(client.text.dropLast(mark))
    }
}
