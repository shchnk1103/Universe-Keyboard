import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

@MainActor
final class LunaT9PartialCommitContractTests: XCTestCase {
    func testPartialCommitKeepsRemainderAndProtectsHost() throws {
        let scene = try openScene(name: "C4-64426")
        defer { scene.finish() }
        let controller = scene.controller
        let client = scene.client
        resetHost(client)
        for key in "64426" {
            _ = controller.handle(.insertKey(String(key)))
        }
        var found: (text: String, index: Int, page: Int)?
        for page in 0..<4 {
            let snap = controller.t9CompositionPresentationSnapshot()
            let pageCands = snap.candidates
            print(
                "LUNA_PARTIAL page=\(page) texts=\(pageCands.map(\.text)) hasMore=\(controller.state.lastRimeOutput?.hasMorePages ?? false)"
            )
            if let index = pageCands.firstIndex(where: { $0.text.count == 1 }) {
                found = (pageCands[index].text, index, page)
                break
            }
            let hasMore = controller.state.lastRimeOutput?.hasMorePages ?? false
            if !hasMore { break }
            _ = controller.handle(.candidatePageDown)
        }
        guard let found else {
            let snap = controller.t9CompositionPresentationSnapshot()
            print(
                "LUNA_PARTIAL result=FINDING missing-single-char finalTexts=\(snap.candidates.map(\.text)) raw=\(snap.rimeRawInput ?? "")"
            )
            return
        }
        XCTAssertEqual(hostCommitted(client), "", "C4 host empty before select")
        _ = controller.handle(
            .insertCandidate(
                found.text, kind: .candidate,
                selectionReference: CandidateSelectionReference(
                    page: found.page, indexOnPage: found.index)))
        // Partial-commit presentation keeps confirmedText inside marked display
        // (updateInlinePreedit(confirmed+remainder)); assert the controller
        // confirmed segment and that host document text still starts with it.
        let confirmed = controller.state.partialCommit?.confirmedText ?? ""
        XCTAssertEqual(
            confirmed, found.text,
            "C4 confirmed exactly \(found.text); got \(confirmed) text=\(client.text) marked=\(client.markedText) hostCommitted=\(hostCommitted(client))"
        )
        XCTAssertTrue(
            client.text.hasPrefix(found.text),
            "C4 host text starts with confirmed; text=\(client.text)")
        let after = controller.t9CompositionPresentationSnapshot()
        let rawNorm = T9PinyinPathExtractor.normalizeRawIdentity(
            after.rimeRawInput ?? controller.state.lastRimeOutput?.rawInput)
        print(
            "LUNA_PARTIAL step=afterSelect confirmed=\(confirmed) single=\(found.text) pageFound=\(found.page) rawNorm=\(rawNorm) cand=\(after.candidates.count) marked=\(client.markedText) text=\(client.text)"
        )
        XCTAssertFalse(rawNorm.isEmpty, "C4 remaining raw non-empty; measured=\(rawNorm)")
        XCTAssertGreaterThanOrEqual(after.candidates.count, 1, "C4 still composing with candidates")
        let textBeforeDelete = client.text
        _ = controller.handle(.deleteBackward)
        let textAfterDelete = client.text
        XCTAssertTrue(
            textAfterDelete.hasPrefix(found.text),
            "C4 delete must not remove confirmed \(found.text); textAfter=\(textAfterDelete) textBefore=\(textBeforeDelete)"
        )
        let afterDel = controller.t9CompositionPresentationSnapshot()
        let rawAfterDel = T9PinyinPathExtractor.normalizeRawIdentity(
            afterDel.rimeRawInput ?? controller.state.lastRimeOutput?.rawInput)
        print(
            "LUNA_PARTIAL result=PASS confirmed=\(confirmed) remainBeforeDel=\(rawNorm) remainAfterDel=\(rawAfterDel) textAfter=\(textAfterDelete)"
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
