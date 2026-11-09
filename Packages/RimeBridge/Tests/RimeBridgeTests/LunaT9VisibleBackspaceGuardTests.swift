import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

@MainActor
final class LunaT9VisibleBackspaceGuardTests: XCTestCase {
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

    private struct StepObs {
        let label: String
        let raw: String
        let candCount: Int
        let marked: String
        let committed: String
    }

    func testE6VariantDigitBackspacesKeepNonEmptyCandidates() throws {
        let scene = try openScene(name: "S2b-E6-digits")
        defer { scene.finish() }
        let controller = scene.controller
        let client = scene.client
        resetHost(client)

        var steps: [StepObs] = []
        for key in ["6", "4", "4", "6"] {
            _ = controller.handle(.insertKey(key))
            steps.append(observe("type-\(key)", controller, client))
        }
        for i in 1...2 {
            _ = controller.handle(.deleteBackward)
            steps.append(observe("bs-\(i)", controller, client))
        }

        for step in steps {
            XCTAssertGreaterThan(
                step.candCount, 0,
                "\(step.label) candidates must be non-empty; raw=\(step.raw) marked=\(step.marked)"
            )
            XCTAssertEqual(step.committed, "", "\(step.label) host committed must stay empty")
        }
        let last = try XCTUnwrap(steps.last)
        let norm = T9PinyinPathExtractor.normalizeRawIdentity(last.raw)
        XCTAssertEqual(norm, "ni", "final raw normalized; raw=\(last.raw)")
        XCTAssertEqual(last.marked, "ni", "final marked; marked=\(last.marked)")
        print(
            "S2B_GUARD_RB E6-digits final raw=\(last.raw) norm=\(norm) cands=\(last.candCount) marked=\(last.marked)"
        )
    }

    func testPathSelectNiAppend6BackspaceKeepsNonEmptyCandidates() throws {
        let scene = try openScene(name: "S2b-E6-path")
        defer { scene.finish() }
        let controller = scene.controller
        let client = scene.client
        resetHost(client)

        var steps: [StepObs] = []
        for key in ["6", "4"] {
            _ = controller.handle(.insertKey(key))
            steps.append(observe("type-\(key)", controller, client))
        }
        let snap = controller.t9CompositionPresentationSnapshot()
        guard let path = snap.paths.first(where: { $0.displayText == "ni" }) else {
            XCTFail("missing displayText=ni paths=\(pathList(snap.paths))")
            return
        }
        _ = controller.handle(.selectT9PinyinPath(path))
        steps.append(observe("select-ni", controller, client))
        _ = controller.handle(.insertKey("6"))
        steps.append(observe("type-6", controller, client))
        _ = controller.handle(.deleteBackward)
        steps.append(observe("bs-1", controller, client))

        for step in steps {
            XCTAssertGreaterThan(
                step.candCount, 0,
                "\(step.label) candidates must be non-empty; raw=\(step.raw) marked=\(step.marked)"
            )
            XCTAssertEqual(step.committed, "", "\(step.label) host committed must stay empty")
        }
        let last = try XCTUnwrap(steps.last)
        let norm = T9PinyinPathExtractor.normalizeRawIdentity(last.raw)
        XCTAssertEqual(norm, "ni", "final raw normalized; raw=\(last.raw)")
        XCTAssertEqual(last.marked, "ni", "final marked; marked=\(last.marked)")
        print(
            "S2B_GUARD_RB E6-path final raw=\(last.raw) norm=\(norm) cands=\(last.candCount) marked=\(last.marked)"
        )
    }

    private func openScene(name: String, selectT9: Bool = true) throws -> Scene {
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
        let root = try LunaT9EvidenceRoot.directory("host-contract").appendingPathComponent(
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
        if selectT9 {
            XCTAssertTrue(engine.bridge.selectSchema("luna_pinyin_t9"))
            XCTAssertEqual(engine.bridge.currentSchemaID(), "luna_pinyin_t9")
        }
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

    private func observe(
        _ label: String, _ controller: KeyboardController, _ client: FakeTextInputClient
    ) -> StepObs {
        let output = controller.state.lastRimeOutput
        let committed = hostCommitted(client)
        let candCount = output?.candidates.count ?? 0
        let raw = output?.rawInput ?? ""
        let marked = client.markedText
        print(
            "S2B_GUARD_RB observe=\(label) raw=\(raw) cands=\(candCount) marked=\(marked) committed=\(committed)"
        )
        return StepObs(
            label: label, raw: raw, candCount: candCount, marked: marked, committed: committed)
    }

    private func pathList(_ paths: [T9PinyinPath]) -> String {
        paths.map { "\($0.displayText)=>\($0.replacementRawInput)" }.joined(separator: ",")
    }
}
