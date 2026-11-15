import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

@MainActor
final class SchemeT9ContractObservationTests: XCTestCase {
    private struct Scheme {
        let name: String
        let fixture: String
        let t9: String
        let full: String
        let samples: [String]
        let h1: String
        let h2: [(String, (T9PinyinPath) -> Bool)]
        let h4: String
        let h4Comment: String
        let letters: String
        let digits: String
    }

    func testSchemeIndependentContracts() async throws {
        let root = try evidenceRoot()
        for scheme in try schemes() {
            try await h1(scheme, root)
            try await h2(scheme, root)
            try await h3(scheme, root)
            try await h4(scheme, root)
            try await r1(scheme, root)
        }
    }

    private func h1(_ scheme: Scheme, _ root: URL) async throws {
        let scene = try await scene(scheme, root, "H1")
        defer { scene.finish() }
        type(scheme.h1, scene)
        let snap = scene.controller.t9CompositionPresentationSnapshot()
        observePaths(scheme, "H1", scheme.h1, snap.paths)
        guard let path = snap.paths.first else {
            print("SCHEME_OBS scheme=\(scheme.name) scene=H1 field=status value=no-path")
            XCTFail("\(scheme.name) H1 no path")
            return
        }
        _ = scene.controller.handle(.selectT9PinyinPath(path))
        let before = scene.controller.t9CompositionPresentationSnapshot()
        _ = scene.controller.handle(.insertKey("6"))
        _ = scene.controller.handle(.deleteBackward)
        let after = scene.controller.t9CompositionPresentationSnapshot()
        XCTAssertEqual(after.rimeRawInput, before.rimeRawInput)
        XCTAssertEqual(committedText(scene.client), "")
    }

    private func h2(_ scheme: Scheme, _ root: URL) async throws {
        for (input, match) in scheme.h2 {
            let scene = try await scene(scheme, root, "H2-\(input)")
            defer { scene.finish() }
            type(input, scene)
            let snap = scene.controller.t9CompositionPresentationSnapshot()
            observePaths(scheme, "H2", input, snap.paths)
            guard let path = snap.paths.first(where: match) else {
                print("SCHEME_OBS scheme=\(scheme.name) scene=H2 field=status value=no-matching-path input=\(input)")
                XCTFail("\(scheme.name) H2 missing path")
                continue
            }
            _ = scene.controller.handle(.selectT9PinyinPath(path))
            _ = scene.controller.handle(.insertKey("2"))
            let before = capture(scene)
            _ = scene.controller.handle(.selectT9PinyinPath(path))
            XCTAssertEqual(capture(scene), before)
        }
    }

    private func h3(_ scheme: Scheme, _ root: URL) async throws {
        let exits = ["space", "return", "blur", "candidate"]
        for input in scheme.samples {
            for exit in exits {
                let scene = try await scene(scheme, root, "H3-\(input)-\(exit)")
                defer { scene.finish() }
                type(input, scene)
                guard let first = scene.controller.state.lastRimeOutput?.candidates.first else {
                    print(
                        "SCHEME_OBS scheme=\(scheme.name) scene=H3 field=status value=not-run input=\(input) exit=\(exit)"
                    )
                    continue
                }
                switch exit {
                case "space": _ = scene.controller.handle(.insertSpace)
                case "return": _ = scene.controller.handle(.insertReturn)
                case "blur": scene.controller.suspendRimeForVisibilityChange()
                default:
                    _ = scene.controller.handle(
                        .insertCandidate(
                            first.text, kind: .candidate,
                            selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0, globalIndex: 0)))
                }
                let committed = committedText(scene.client)
                XCTAssertFalse(committed.unicodeScalars.contains { (48...57).contains($0.value) })
                print(
                    "SCHEME_OBS scheme=\(scheme.name) scene=H3 field=committed value=\(committed) input=\(input) exit=\(exit)"
                )
            }
        }
    }

    private func h4(_ scheme: Scheme, _ root: URL) async throws {
        let scene = try await scene(scheme, root, "H4")
        defer { scene.finish() }
        type(scheme.h4, scene)
        let output = scene.controller.state.lastRimeOutput
        print(
            "SCHEME_OBS scheme=\(scheme.name) scene=H4 field=page value=\(output?.candidates.count ?? -1) hasMore=\(output?.hasMorePages ?? false)"
        )
        scene.engine.resetSession()
        type(scheme.h4Comment, scene)
        for (index, candidate) in scene.controller.t9CompositionPresentationSnapshot().candidates.enumerated() {
            print(
                "SCHEME_OBS scheme=\(scheme.name) scene=H4 field=comment value=\(candidate.comment ?? "nil") index=\(index) text=\(candidate.text)"
            )
        }
    }

    private func r1(_ scheme: Scheme, _ root: URL) async throws {
        let scene = try await scene(scheme, root, "R1", select: false)
        defer { scene.finish() }
        let sentinel = scene.user.appendingPathComponent("scheme.userdb.sentinel")
        let payload = Data("sentinel-a8c".utf8)
        try payload.write(to: sentinel)
        XCTAssertTrue(scene.engine.bridge.selectSchema(scheme.full))
        scene.engine.resetSession()
        var letters = RimeOutput()
        for character in scheme.letters { letters = scene.engine.processKey(String(character)) }
        XCTAssertTrue(scene.engine.bridge.selectSchema(scheme.t9))
        scene.engine.resetSession()
        var digits = RimeOutput()
        for character in scheme.digits { digits = scene.engine.processKey(String(character)) }
        let deleted = scene.engine.deleteBackward()
        XCTAssertTrue(
            RimeT9SmokeProbe.evaluationPasses(
                raw: digits.rawInput ?? "", expectedRaw: scheme.digits, candidates: digits.candidates,
                rawAfterDelete: deleted.rawInput ?? "", expectedAfterDelete: String(scheme.digits.dropLast())))
        XCTAssertTrue(scene.engine.bridge.selectSchema(scheme.full))
        scene.engine.resetSession()
        var repeated = RimeOutput()
        for character in scheme.letters { repeated = scene.engine.processKey(String(character)) }
        XCTAssertEqual(letters.candidates.first?.text, repeated.candidates.first?.text)
        XCTAssertEqual(try Data(contentsOf: sentinel), payload)
    }

    private struct Scene {
        let engine: RimeEngineImpl
        let controller: KeyboardController
        let client: FakeTextInputClient
        let user: URL
        func finish() { engine.bridge.clearComposition(); engine.bridge.finalize() }
    }

    private func scene(_ scheme: Scheme, _ root: URL, _ name: String, select: Bool = true) async throws -> Scene {
        let destination = root.appendingPathComponent("\(scheme.name)-\(name)-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: false)
        let source = URL(fileURLWithPath: scheme.fixture, isDirectory: true)
        let shared = destination.appendingPathComponent("shared", isDirectory: true)
        let user = destination.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.copyItem(at: source.appendingPathComponent("shared"), to: shared)
        try FileManager.default.copyItem(at: source.appendingPathComponent("user"), to: user)
        let deployed = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .testFixtureMaintenanceOnly, sharedDataURL: shared, userDataURL: user,
                runtimeSmokeSchemaID: nil))
        XCTAssertTrue(deployed.succeeded)
        let engine = RimeEngineImpl(sharedDataDir: shared.path, userDataDir: user.path)
        if select { XCTAssertTrue(engine.bridge.selectSchema(scheme.t9)) }
        let controller = KeyboardController(), client = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        controller.textClient = client
        return Scene(engine: engine, controller: controller, client: client, user: user)
    }

    private func schemes() throws -> [Scheme] {
        let environment = ProcessInfo.processInfo.environment
        guard let ice = environment["LUNA_T9_ICE_FIXTURE"], let wanxiang = environment["LUNA_T9_WANXIANG_FIXTURE"]
        else { throw XCTSkip("fixture missing") }
        return [
            Scheme(
                name: "ice", fixture: ice, t9: "t9", full: "rime_ice", samples: ["6", "64", "6446", "94664", "44"],
                h1: "64", h2: [("6", { $0.displayText == "o" }), ("64", { $0.displayText == "ni" })], h4: "6",
                h4Comment: "44", letters: "nihao", digits: "6446"),
            Scheme(
                name: "wanxiang", fixture: wanxiang, t9: "wanxiang_t9i", full: "wanxiang",
                samples: ["6", "64", "6446", "94664", "44"], h1: "64",
                h2: [("6", { $0.displayText == "o" }), ("64", { $0.displayText == "ni" })], h4: "6", h4Comment: "44",
                letters: "nihao", digits: "6446"),
        ]
    }

    private func evidenceRoot() throws -> URL {
        let value = try XCTUnwrap(ProcessInfo.processInfo.environment["LUNA_T9_EVIDENCE_ROOT"])
        let root = URL(fileURLWithPath: value, isDirectory: true).standardizedFileURL
        let allowed = URL(
            fileURLWithPath: "/Users/doubleshy0n/.kos-work/Universe-Keyboard/LUNA-T9-A8C/scratch", isDirectory: true
        ).standardizedFileURL
        XCTAssertTrue(root.path.hasPrefix(allowed.path + "/"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.path))
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        return root
    }

    private func type(_ input: String, _ scene: Scene) {
        for character in input { _ = scene.controller.handle(.insertKey(String(character))) }
    }

    private func observePaths(_ scheme: Scheme, _ scene: String, _ input: String, _ paths: [T9PinyinPath]) {
        print("SCHEME_OBS scheme=\(scheme.name) scene=\(scene) field=paths value=\(paths.count) input=\(input)")
        for path in paths {
            print(
                "SCHEME_OBS scheme=\(scheme.name) scene=\(scene) field=path value=\(path.displayText) replacement=\(path.replacementRawInput)"
            )
        }
    }

    private func capture(_ scene: Scene) -> [String] {
        let output = scene.controller.state.lastRimeOutput
        return [output?.rawInput ?? "", scene.client.text, scene.client.markedText, String(scene.client.deletedCount)]
            + (output?.candidates.map(\.text) ?? [])
    }

    private func committedText(_ client: FakeTextInputClient) -> String {
        client.markedText.isEmpty
            ? client.text
            : (client.markedText.count >= client.text.count
                ? "" : String(client.text.dropLast(client.markedText.count)))
    }

}
