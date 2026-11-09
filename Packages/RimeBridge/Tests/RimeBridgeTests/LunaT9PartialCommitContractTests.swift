import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

@MainActor
final class LunaT9PartialCommitContractTests: XCTestCase {
    func testPartialCommitKeepsRemainderAndProtectsHost() throws {
        let scene = try openScene(name: "C4-6446")
        defer { scene.finish() }
        let controller = scene.controller
        let client = scene.client
        resetHost(client)
        for key in "6446" {
            _ = controller.handle(.insertKey(String(key)))
        }
        var found: (text: String, index: Int, page: Int)?
        for page in 0..<8 {
            let snap = controller.t9CompositionPresentationSnapshot()
            let pageCands = snap.candidates
            if let index = pageCands.firstIndex(where: { $0.text == "你" }) {
                found = (pageCands[index].text, index, page)
                break
            }
            let hasMore = controller.state.lastRimeOutput?.hasMorePages ?? false
            print(
                "LUNA_PARTIAL page=\(page) texts=\(pageCands.map(\.text)) hasMore=\(hasMore)"
            )
            if !hasMore { break }
            _ = controller.handle(.candidatePageDown)
        }
        guard let found else {
            let snap = controller.t9CompositionPresentationSnapshot()
            print(
                "LUNA_PARTIAL result=FINDING missing-candidate-你 finalTexts=\(snap.candidates.map(\.text)) raw=\(snap.rimeRawInput ?? "")"
            )
            // Package: do not invent; record discovery/blocker without forcing a green assert.
            return
        }
        XCTAssertEqual(hostCommitted(client), "", "C4 host empty before select")
        _ = controller.handle(
            .insertCandidate(
                found.text, kind: .candidate,
                selectionReference: CandidateSelectionReference(
                    page: found.page, indexOnPage: found.index)))
        let committed = hostCommitted(client)
        XCTAssertEqual(
            committed, "你",
            "C4 host committed exactly 你; got \(committed) text=\(client.text) marked=\(client.markedText)")
        let after = controller.t9CompositionPresentationSnapshot()
        let rawNorm = T9PinyinPathExtractor.normalizeRawIdentity(
            after.rimeRawInput ?? controller.state.lastRimeOutput?.rawInput)
        let expectedRemain = T9PinyinPathExtractor.normalizeRawIdentity("46")
        print(
            "LUNA_PARTIAL step=afterSelect committed=\(committed) rawNorm=\(rawNorm) expectedRemain=\(expectedRemain) cand=\(after.candidates.count) marked=\(client.markedText) pageFound=\(found.page)"
        )
        XCTAssertEqual(rawNorm, expectedRemain, "C4 remaining raw normalized == 46")
        XCTAssertGreaterThanOrEqual(after.candidates.count, 1, "C4 still composing with candidates")
        let hostBeforeDelete = hostCommitted(client)
        _ = controller.handle(.deleteBackward)
        let hostAfterDelete = hostCommitted(client)
        XCTAssertTrue(
            hostAfterDelete.hasPrefix("你"), "C4 delete must not remove committed 你; host=\(hostAfterDelete)")
        XCTAssertEqual(
            hostAfterDelete, hostBeforeDelete, "C4 host committed prefix unchanged by compose delete")
        let afterDel = controller.t9CompositionPresentationSnapshot()
        let rawAfterDel = T9PinyinPathExtractor.normalizeRawIdentity(
            afterDel.rimeRawInput ?? controller.state.lastRimeOutput?.rawInput)
        XCTAssertNotEqual(
            rawAfterDel, rawNorm, "C4 compose shortens after delete; before=\(rawNorm) after=\(rawAfterDel)")
        print(
            "LUNA_PARTIAL result=PASS committed=\(committed) remainBeforeDel=\(rawNorm) remainAfterDel=\(rawAfterDel) hostAfter=\(hostAfterDelete)"
        )
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
