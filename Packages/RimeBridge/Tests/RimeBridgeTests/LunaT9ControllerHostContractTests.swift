import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

@MainActor
final class LunaT9ControllerHostContractTests: XCTestCase {
    private let frozenSamples = ["6", "44", "444444", "64", "6446", "94664"]

    func testH1PathSelectAppendDeleteHostCommitZero() throws {
        let scene = try openScene(name: "H1")
        defer { scene.finish() }
        let controller = scene.controller
        let client = scene.client
        resetHost(client)
        for key in "64" {
            _ = controller.handle(.insertKey(String(key)))
            observe("H1-key", controller, client)
        }
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")
        let snap = controller.t9CompositionPresentationSnapshot()
        guard let path = snap.paths.first(where: { $0.displayText == "ni" }) else {
            XCTFail("H1 missing displayText=ni paths=\(pathList(snap.paths))")
            print("LUNA_HOST scene=H1 input=64 result=FAIL missing-ni-path paths=\(pathList(snap.paths))")
            return
        }
        let beforeSelectRev = controller.state.compositionRevision
        _ = controller.handle(.selectT9PinyinPath(path))
        let afterSelect = observe("H1-select-ni", controller, client)
        let snapBeforeAppend = controller.t9CompositionPresentationSnapshot()
        let rawBeforeAppend = snapBeforeAppend.rimeRawInput ?? afterSelect.raw
        let candsBeforeAppend = candidateSummaries(snapBeforeAppend.candidates)
        let top5BeforeAppend = snapBeforeAppend.candidates.prefix(5).map(\.text)
        let markedBeforeAppend = client.markedText
        let revBeforeAppend = controller.state.compositionRevision
        XCTAssertGreaterThanOrEqual(snapBeforeAppend.candidates.count, 1, "H1 after select cand>=1")
        XCTAssertEqual(hostCommitted(client), "", "H1 host empty after select")
        print(
            "LUNA_HOST scene=H1 step=select replacement=\(path.replacementRawInput) rawOut=\(afterSelect.raw) snapRaw=\(snapBeforeAppend.rimeRawInput ?? "<nil>") preedit=\(afterSelect.preedit) rev=\(revBeforeAppend) pageSize=\(candsBeforeAppend.count) tracked=\(controller.state.t9PinyinPathState.trackedRawInput ?? "<nil>")"
        )
        _ = controller.handle(.insertKey("6"))
        let afterAppend = observe("H1-append-6", controller, client)
        XCTAssertNotEqual(afterAppend.revision, revBeforeAppend)
        XCTAssertGreaterThanOrEqual(afterAppend.pageSize, 1, "H1 after append cand>=1")
        XCTAssertEqual(hostCommitted(client), "", "H1 host empty after append")
        _ = controller.handle(.deleteBackward)
        let afterDelete = observe("H1-delete", controller, client)
        let snapAfterDelete = controller.t9CompositionPresentationSnapshot()
        let rawAfterDelete = snapAfterDelete.rimeRawInput ?? afterDelete.raw
        let candsAfter = candidateSummaries(snapAfterDelete.candidates)
        let top5AfterDelete = snapAfterDelete.candidates.prefix(5).map(\.text)
        let markedAfterDelete = client.markedText
        print(
            "LUNA_HOST scene=H1 revRule=state.compositionRevision beforeSelect=\(beforeSelectRev) beforeAppend=\(revBeforeAppend) afterAppend=\(afterAppend.revision) afterDelete=\(afterDelete.revision) rawBefore=\(rawBeforeAppend) rawAfter=\(rawAfterDelete)"
        )
        XCTAssertNotEqual(afterDelete.revision, revBeforeAppend)
        XCTAssertGreaterThanOrEqual(afterDelete.revision, afterAppend.revision)
        XCTAssertEqual(rawAfterDelete, rawBeforeAppend)
        XCTAssertEqual(top5AfterDelete, Array(top5BeforeAppend), "H1 delete restores top5 texts")
        XCTAssertEqual(markedAfterDelete, markedBeforeAppend, "H1 delete restores marked")
        XCTAssertFalse(candsAfter.isEmpty)
        XCTAssertGreaterThanOrEqual(snapAfterDelete.candidates.count, 1, "H1 after delete cand>=1")
        XCTAssertEqual(hostCommitted(client), "", "H1 host empty after delete")
        if candsAfter != candsBeforeAppend {
            print("LUNA_HOST scene=H1 candDiff before=\(candsBeforeAppend) after=\(candsAfter)")
        } else {
            print("LUNA_HOST scene=H1 candMatch before=after count=\(candsAfter.count)")
        }
        print(
            "LUNA_HOST scene=H1 input=64 result=PASS replacement=\(path.replacementRawInput) hostCommittedAlwaysEmpty=true deletedCount=\(client.deletedCount)"
        )
    }

    func testH2OldRevisionTapNoChange() throws {
        let cases: [(String, (T9PinyinPath) -> Bool)] = [
            ("6", { $0.displayText == "n" }),
            ("64", { $0.displayText == "ni" }),
            ("6446", { $0.displayText.hasPrefix("ni") }),
        ]
        for (input, match) in cases {
            let scene = try openScene(name: "H2-\(input)")
            defer { scene.finish() }
            let controller = scene.controller
            let client = scene.client
            resetHost(client)
            for key in input {
                _ = controller.handle(.insertKey(String(key)))
                _ = observe("H2-\(input)-key", controller, client)
            }
            let snap = controller.t9CompositionPresentationSnapshot()
            guard let path = snap.paths.first(where: match) else {
                print("LUNA_HOST scene=H2 input=\(input) result=FAIL missing-path paths=\(pathList(snap.paths))")
                XCTFail("H2 \(input) missing target path paths=\(pathList(snap.paths))")
                continue
            }
            print(
                "LUNA_HOST scene=H2 input=\(input) replacement=\(path.replacementRawInput) display=\(path.displayText)"
            )
            _ = controller.handle(.selectT9PinyinPath(path))
            _ = observe("H2-\(input)-select", controller, client)
            let saved = path
            _ = controller.handle(.insertKey("2"))
            _ = observe("H2-\(input)-bump", controller, client)
            let before = captureHostEngine(controller, client)
            _ = controller.handle(.selectT9PinyinPath(saved))
            let after = captureHostEngine(controller, client)
            XCTAssertEqual(before.raw, after.raw)
            XCTAssertEqual(before.cands, after.cands)
            XCTAssertEqual(before.text, after.text)
            XCTAssertEqual(before.marked, after.marked)
            XCTAssertEqual(before.deleted, after.deleted)
            print(
                "LUNA_HOST scene=H2 input=\(input) result=PASS oldTapUnchanged replacement=\(path.replacementRawInput)"
            )
        }
    }

    func testH2NewRevisionTapTakesEffect() throws {
        let scene = try openScene(name: "H2-new")
        defer { scene.finish() }
        let controller = scene.controller
        let client = scene.client
        resetHost(client)
        for key in "64" {
            _ = controller.handle(.insertKey(String(key)))
            _ = observe("H2-new-key", controller, client)
        }
        let snap0 = controller.t9CompositionPresentationSnapshot()
        guard let path = snap0.paths.first(where: { $0.displayText == "ni" }) else {
            XCTFail("H2-new missing displayText=ni paths=\(pathList(snap0.paths))")
            print("LUNA_HOST scene=H2-new result=FAIL missing-ni-path paths=\(pathList(snap0.paths))")
            return
        }
        _ = controller.handle(.selectT9PinyinPath(path))
        _ = observe("H2-new-select", controller, client)
        let revAfterSelect = controller.state.compositionRevision
        _ = controller.handle(.insertKey("6"))
        _ = observe("H2-new-append", controller, client)
        let snap1 = controller.t9CompositionPresentationSnapshot()
        // Prefer a Path whose display equals the previously selected display ("ni"),
        // else any Path whose display equals the visible selected spelling in the new snapshot.
        let newPath =
            snap1.paths.first(where: { $0.displayText == "ni" })
            ?? snap1.paths.first(where: { $0.displayText == path.displayText })
        guard let newPath else {
            print(
                "LUNA_HOST scene=H2-new result=FINDING missing-new-path afterAppend paths=\(pathList(snap1.paths))"
            )
            // Do not invent a Path; surface as discovery via soft fail message for report.
            XCTFail("H2-new no usable new Path after append; paths=\(pathList(snap1.paths))")
            return
        }
        let beforeTapRev = controller.state.compositionRevision
        _ = controller.handle(.selectT9PinyinPath(newPath))
        let after = observe("H2-new-retap", controller, client)
        let snap2 = controller.t9CompositionPresentationSnapshot()
        let rawNorm = T9PinyinPathExtractor.normalizeRawIdentity(snap2.rimeRawInput ?? after.raw)
        let expectedNorm = T9PinyinPathExtractor.normalizeRawIdentity(newPath.replacementRawInput)
        XCTAssertEqual(rawNorm, expectedNorm, "H2-new raw normalized to replacement")
        XCTAssertGreaterThanOrEqual(snap2.candidates.count, 1, "H2-new cand>=1")
        XCTAssertEqual(client.markedText, newPath.displayText, "H2-new marked==path display")
        XCTAssertGreaterThan(after.revision, beforeTapRev, "H2-new revision advances")
        print(
            "LUNA_HOST scene=H2-new result=PASS replacement=\(newPath.replacementRawInput) display=\(newPath.displayText) rawNorm=\(rawNorm) revBefore=\(beforeTapRev) revAfter=\(after.revision) afterSelectRev=\(revAfterSelect)"
        )
    }

    func testH3ExitHostCommits() throws {
        let exits: [(String, (KeyboardController, FakeTextInputClient, KeyboardCore.RimeCandidate) -> Void)] = [
            ("space", { c, _, _ in _ = c.handle(.insertSpace) }),
            ("return", { c, _, _ in _ = c.handle(.insertReturn) }),
            ("blur", { c, _, _ in c.suspendRimeForVisibilityChange() }),
            (
                "candidate",
                { c, _, first in
                    _ = c.handle(
                        .insertCandidate(
                            first.text, kind: .candidate,
                            selectionReference: CandidateSelectionReference(
                                page: 0, indexOnPage: 0, globalIndex: 0)))
                }
            ),
        ]
        for sample in frozenSamples {
            for (exitName, apply) in exits {
                let scene = try openScene(name: "H3-\(sample)-\(exitName)")
                defer { scene.finish() }
                let controller = scene.controller
                let client = scene.client
                resetHost(client)
                for key in sample {
                    _ = controller.handle(.insertKey(String(key)))
                    _ = observe("H3-\(sample)-\(exitName)-key", controller, client)
                }
                let first = try XCTUnwrap(controller.state.lastRimeOutput?.candidates.first)
                apply(controller, client, first)
                _ = observe("H3-\(sample)-\(exitName)-exit", controller, client, requireEmptyCommitted: false)
                let committed = hostCommitted(client)
                let hasDigit = committed.unicodeScalars.contains { $0.value >= 48 && $0.value <= 57 }
                let equalsSample = committed == sample
                let equalsCand = committed == first.text || committed.hasPrefix(first.text)
                let historyHasDigit = client.markedTextHistory.contains {
                    $0.unicodeScalars.contains { $0.value >= 48 && $0.value <= 57 }
                }
                XCTAssertFalse(equalsSample, "H3 \(sample)/\(exitName) committed==sample \(committed)")
                XCTAssertFalse(hasDigit, "H3 \(sample)/\(exitName) committed has digit \(committed)")
                if exitName == "candidate" {
                    XCTAssertTrue(equalsCand, "H3 \(sample) candidate commit \(committed) vs \(first.text)")
                }
                XCTAssertFalse(historyHasDigit, "H3 \(sample)/\(exitName) markedTextHistory has digit")
                let markedStill = !client.markedText.isEmpty
                print(
                    "LUNA_HOST scene=H3 sample=\(sample) exit=\(exitName) committed=\(committed) hasDigit=\(hasDigit) equalsCand=\(equalsCand) markedStill=\(markedStill) historyHasDigit=\(historyHasDigit) result=PASS"
                )
            }
        }
    }

    func testH4PageSizeAndComments() throws {
        let scene = try openScene(name: "H4")
        defer { scene.finish() }
        let controller = scene.controller
        let client = scene.client
        let engine = scene.engine
        resetHost(client)
        _ = controller.handle(.insertKey("6"))
        _ = observe("H4-6", controller, client)
        let pageSize = controller.state.lastRimeOutput?.candidates.count ?? -1
        let hasMore = controller.state.lastRimeOutput?.hasMorePages ?? false
        XCTAssertEqual(pageSize, 5)
        XCTAssertTrue(hasMore)
        let window = RimeEngineImpl.parseCandidateWindowDictionary(engine.bridge.candidates(from: 0, limit: 10))
        let menuPageSize = readMenuPageSize()
        print(
            "LUNA_HOST scene=H4 input=6 page_size=\(pageSize) hasMorePages=\(hasMore) windowCount=\(window.candidates.count) windowHasMore=\(window.hasMoreCandidates) menu_page_size=\(menuPageSize) result=PASS"
        )

        resetHost(client)
        engine.bridge.clearComposition()
        let controller2 = KeyboardController()
        let client2 = FakeTextInputClient()
        controller2.rimeEngine = engine
        controller2.usesT9InputSemantics = true
        controller2.textClient = client2
        for key in "44" { _ = controller2.handle(.insertKey(String(key))) }
        let snap = controller2.t9CompositionPresentationSnapshot()
        let rev = snap.revision
        let pathRev = controller2.state.t9PinyinPathState.compositionRevision
        XCTAssertEqual(rev, pathRev)
        for (i, cand) in snap.candidates.enumerated() {
            let commentDesc: String
            if let c = cand.comment {
                commentDesc = c.isEmpty ? "<empty>" : c
            } else {
                commentDesc = "<nil>"
            }
            print(
                "LUNA_HOST scene=H4 input=44 idx=\(i) text=\(cand.text) comment=\(commentDesc) rev=\(rev) pathRev=\(pathRev)"
            )
        }
        print("LUNA_HOST scene=H4 input=44 result=PASS sameRevision=\(rev == pathRev) count=\(snap.candidates.count)")
    }

    func testR1SchemaRoundTrip() throws {
        let scene = try openScene(name: "R1", selectT9: false)
        defer { scene.finish() }
        let engine = scene.engine
        let user = scene.user
        let sentinel = user.appendingPathComponent("luna_pinyin.userdb.sentinel")
        let payload = Data("sentinel-a8-r1".utf8)
        try payload.write(to: sentinel, options: .atomic)
        let before = try Data(contentsOf: sentinel)

        XCTAssertTrue(engine.bridge.selectSchema("luna_pinyin"))
        XCTAssertEqual(engine.bridge.currentSchemaID(), "luna_pinyin")
        engine.resetSession()
        var out26a = RimeOutput()
        for c in "nihao" { out26a = engine.processKey(String(c)) }
        let first26a = out26a.candidates.first?.text
        print("LUNA_HOST scene=R1 step=26a first=\(first26a ?? "<nil>") count=\(out26a.candidates.count)")

        XCTAssertTrue(engine.bridge.selectSchema("luna_pinyin_t9"))
        XCTAssertEqual(engine.bridge.currentSchemaID(), "luna_pinyin_t9")
        engine.resetSession()
        var outT9 = RimeOutput()
        for c in "6446" { outT9 = engine.processKey(String(c)) }
        let deleted = engine.deleteBackward()
        let passed = RimeT9SmokeProbe.evaluationPasses(
            raw: outT9.rawInput ?? "", expectedRaw: "6446", candidates: outT9.candidates,
            rawAfterDelete: deleted.rawInput ?? "", expectedAfterDelete: "644")
        print(
            "LUNA_HOST scene=R1 step=t9 evaluationPasses=\(passed) rawAfterDelete=\(deleted.rawInput ?? "")"
        )
        XCTAssertTrue(passed)

        XCTAssertTrue(engine.bridge.selectSchema("luna_pinyin"))
        XCTAssertEqual(engine.bridge.currentSchemaID(), "luna_pinyin")
        engine.resetSession()
        var out26b = RimeOutput()
        for c in "nihao" { out26b = engine.processKey(String(c)) }
        let first26b = out26b.candidates.first?.text
        XCTAssertEqual(first26a, first26b)
        let after = try Data(contentsOf: sentinel)
        XCTAssertEqual(before, after)
        print(
            "LUNA_HOST scene=R1 result=PASS first26=\(first26a ?? "<nil>") sentinelEqual=true evaluationPasses=\(passed)"
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

    private struct Obs {
        var raw: String
        var preedit: String
        var revision: UInt64
        var pageSize: Int
        var committed: String
        var text: String
        var marked: String
        var deleted: Int
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

    @discardableResult
    private func observe(
        _ label: String, _ controller: KeyboardController, _ client: FakeTextInputClient,
        requireEmptyCommitted: Bool = true
    ) -> Obs {
        let output = controller.state.lastRimeOutput
        let snap = controller.t9CompositionPresentationSnapshot()
        let pathState = controller.state.t9PinyinPathState
        let committed = hostCommitted(client)
        if requireEmptyCommitted {
            XCTAssertEqual(committed, "", "\(label) host committed must stay empty during compose: \(committed)")
        }
        let cands = (output?.candidates ?? []).map { cand -> String in
            let c: String
            if let comment = cand.comment {
                c = comment.isEmpty ? "<empty>" : comment
            } else {
                c = "<nil>"
            }
            return "\(cand.text)|\(c)"
        }
        print(
            "LUNA_HOST observe=\(label) raw=\(output?.rawInput ?? "") preedit=\(output?.composition?.preeditText ?? "") page=\(output?.candidatePageNumber ?? -1) page_size=\(output?.candidates.count ?? 0) hasMore=\(output?.hasMorePages ?? false) rev=\(controller.state.compositionRevision) pathRev=\(pathState.compositionRevision) gen=\(pathState.rawInputGeneration) prov=\(pathState.provenanceRevision) paths=\(pathList(snap.paths)) cands=\(cands) text=\(client.text) marked=\(client.markedText) committed=\(committed) deleted=\(client.deletedCount) historyCount=\(client.markedTextHistory.count)"
        )
        return Obs(
            raw: output?.rawInput ?? "",
            preedit: output?.composition?.preeditText ?? "",
            revision: controller.state.compositionRevision,
            pageSize: output?.candidates.count ?? 0,
            committed: committed,
            text: client.text,
            marked: client.markedText,
            deleted: client.deletedCount)
    }

    private func captureHostEngine(_ controller: KeyboardController, _ client: FakeTextInputClient) -> (
        raw: String, cands: [String], text: String, marked: String, deleted: Int
    ) {
        let output = controller.state.lastRimeOutput
        return (
            output?.rawInput ?? "",
            candidateSummaries(output?.candidates ?? []),
            client.text,
            client.markedText,
            client.deletedCount
        )
    }

    private func candidateSummaries(_ cands: [KeyboardCore.RimeCandidate]) -> [String] {
        cands.map { cand in
            let c: String
            if let comment = cand.comment {
                c = comment.isEmpty ? "<empty>" : comment
            } else {
                c = "<nil>"
            }
            return "\(cand.text)|\(c)"
        }
    }

    private func pathList(_ paths: [T9PinyinPath]) -> String {
        paths.map { "\($0.displayText)=>\($0.replacementRawInput)" }.joined(separator: ",")
    }

    private func readMenuPageSize() -> String {
        guard let api = rime_get_api() else { return "UNKNOWN" }
        guard let open = api.pointee.schema_open, let close = api.pointee.config_close,
            let getInt = api.pointee.config_get_int
        else { return "UNKNOWN" }
        var config = RimeConfig()
        guard open("luna_pinyin_t9", &config) != 0 else { return "UNKNOWN" }
        defer { _ = close(&config) }
        var value: Int32 = -1
        if getInt(&config, "menu/page_size", &value) == 0 { return "UNKNOWN" }
        return String(value)
    }
}
