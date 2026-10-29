import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

final class RimeT9MatrixTests: XCTestCase {
    @MainActor
    func testMatrix() async throws {
        let env = ProcessInfo.processInfo.environment
        func value(_ key: String) -> String? { env[key] ?? env["TEST_RUNNER_" + key] }
        guard let shared = value("UK_MATRIX_SHARED"), let user = value("UK_MATRIX_USER"),
            let schema = value("UK_MATRIX_SCHEMA")
        else { throw XCTSkip("isolated fixture paths not set") }
        let task = URL(fileURLWithPath: shared).deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent()
        let upstream =
            schema == "t9"
            ? task.appendingPathComponent("scratch/extract/rime-ice/t9.schema.yaml")
            : task.deletingLastPathComponent().appendingPathComponent(
                "WANXIANG-T9-SPIKE-001/scratch/extract/github/\(schema).schema.yaml")
        // The negative fixtures are checked before deployment can recreate any artifact.
        let negative = task.appendingPathComponent("scratch/negative-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: negative, withIntermediateDirectories: true)
        let source = negative.appendingPathComponent("source.yaml")
        try FileManager.default.copyItem(at: upstream, to: source)
        let raw = try String(contentsOf: source, encoding: .utf8)
        let sourceAccepted = !raw.contains("t9_processor")
        let missingBuild = negative.appendingPathComponent("build/\(schema).schema.yaml")
        let buildAccepted = FileManager.default.fileExists(atPath: missingBuild.path)
        print(
            "NEGATIVE schema=\(schema) source=\(source.path) containsProcessor=\(!sourceAccepted) missingBuild=\(missingBuild.path) exists=\(buildAccepted)"
        )
        XCTAssertFalse(sourceAccepted)
        XCTAssertFalse(buildAccepted)
        let markerURL = task.appendingPathComponent("scratch/ice-readiness-marker.json")
        let sourceURL = URL(fileURLWithPath: shared).appendingPathComponent("t9.schema.yaml")
        if schema == "t9" {
            let before = (try? Data(contentsOf: markerURL)).flatMap {
                try? JSONDecoder().decode(RimeT9ReadinessMarker.self, from: $0)
            }
            let fingerprint = RimeT9Readiness.fingerprint(ofFileAt: sourceURL)
            let compiled = URL(fileURLWithPath: user).appendingPathComponent("build/t9.schema.yaml")
            print(
                "READINESS_BEFORE marker=\(String(describing: before)) fingerprint=\(fingerprint ?? "<nil>") compiled=\(FileManager.default.fileExists(atPath: compiled.path)) matched=\(RimeT9Readiness.isMatched(marker: before, onDiskFingerprint: fingerprint))"
            )
        }
        let deployed = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .testFixtureMaintenanceOnly, sharedDataURL: URL(fileURLWithPath: shared),
                userDataURL: URL(fileURLWithPath: user), runtimeSmokeSchemaID: nil))
        print("MATRIX_DEPLOY \(deployed.succeeded)")
        guard deployed.succeeded else { XCTFail("deployment failed"); return }
        let engine = RimeEngineImpl(sharedDataDir: shared, userDataDir: user)
        defer { engine.bridge.clearComposition(); engine.bridge.finalize() }
        XCTAssertTrue(engine.bridge.selectSchema(schema))
        for sequence in ["64", "6446", "94664", "2", "22", "7464", "8", "86"] {
            engine.bridge.clearComposition()
            var output = engine.processKey(String(sequence.first!))
            for key in sequence.dropFirst() { output = engine.processKey(String(key)) }
            let visible = T9PreeditResolver.visiblePreedit(
                rawInput: output.rawInput, candidates: output.candidates, highlightedIndex: output.highlightedIndex)
            let candidates = output.candidates.map { "\($0.text){\($0.comment ?? "<nil>")}" }.joined(separator: "|")
            print(
                "MATRIX sequence=\(sequence) raw=\(output.rawInput ?? "<nil>") preedit=\(output.composition?.preeditText ?? "<nil>") highlighted=\(output.highlightedIndex) visible=\(visible) candidates=\(candidates)"
            )
            if output.candidates.count > 1 {
                let highlighted = engine.parseOutput(engine.bridge.highlightCandidateOnCurrentPage(at: 1))
                let visibleHighlight = T9PreeditResolver.visiblePreedit(
                    rawInput: highlighted.rawInput, candidates: highlighted.candidates,
                    highlightedIndex: highlighted.highlightedIndex)
                print(
                    "MATRIX_HIGHLIGHT sequence=\(sequence) index=\(highlighted.highlightedIndex) visible=\(visibleHighlight) comments=\(highlighted.candidates.prefix(2).map { $0.comment ?? "<nil>" })"
                )
            }
            if sequence == "64" || sequence == "6446" {
                let first = output.candidates.first?.comment
                let high =
                    output.candidates.indices.contains(output.highlightedIndex)
                    ? output.candidates[output.highlightedIndex].comment : nil
                let accepted = referenceComment(high) ?? referenceComment(first)
                print(
                    "SMOKE sequence=\(sequence) candidates=\(output.candidates.count) high=\(high ?? "<nil>") first=\(first ?? "<nil>") reference=\(accepted ?? "<invalid>")"
                )
            }
            let deleted = engine.processDeletion()
            print("MATRIX_DELETE sequence=\(sequence) raw=\(deleted.rawInput ?? "<nil>")")
        }
        for sequence in ["64", "6446", "94664", "2", "22", "7464", "8", "86"] {
            engine.bridge.clearComposition()
            let controller = KeyboardController()
            let client = FakeTextInputClient()
            controller.rimeEngine = engine
            controller.usesT9InputSemantics = true
            controller.textClient = client
            for key in sequence { _ = controller.handle(.insertKey(String(key))) }
            let snapshot = controller.t9CompositionPresentationSnapshot()
            print(
                "CONTROLLER sequence=\(sequence) visible=\(snapshot.visiblePreedit) marked=\(client.markedText) raw=\(snapshot.rimeRawInput ?? "<nil>")"
            )
            if let first = snapshot.candidates.first {
                let selectController = KeyboardController()
                let selectClient = FakeTextInputClient()
                engine.bridge.clearComposition()
                selectController.rimeEngine = engine
                selectController.usesT9InputSemantics = true
                selectController.textClient = selectClient
                for key in sequence { _ = selectController.handle(.insertKey(String(key))) }
                _ = selectController.handle(
                    .insertCandidate(
                        first.text, kind: .candidate,
                        selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0)))
                print(
                    "CONTROLLER_SELECT sequence=\(sequence) text=\(selectClient.text) marked=\(selectClient.markedText) raw=\(selectController.state.lastRimeOutput?.rawInput ?? "<nil>")"
                )
                _ = selectController.handle(.deleteBackward)
                print(
                    "CONTROLLER_SELECT_DELETE sequence=\(sequence) text=\(selectClient.text) marked=\(selectClient.markedText)"
                )
                engine.bridge.clearComposition()
                for key in sequence { _ = engine.processKey(String(key)) }
            }
            if let path = snapshot.paths.first {
                _ = controller.handle(.selectT9PinyinPath(path))
                let selected = controller.t9CompositionPresentationSnapshot()
                print(
                    "CONTROLLER_PATH sequence=\(sequence) path=\(path.displayText) visible=\(selected.visiblePreedit) marked=\(client.markedText)"
                )
                _ = controller.handle(.deleteBackward)
                print(
                    "CONTROLLER_PATH_DELETE sequence=\(sequence) visible=\(controller.t9CompositionPresentationSnapshot().visiblePreedit) marked=\(client.markedText)"
                )
            }
        }

        if schema == "t9", let fingerprint = RimeT9Readiness.fingerprint(ofFileAt: sourceURL) {
            let marker = RimeT9ReadinessMarker(
                ready: true, compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
                resourceFingerprint: fingerprint)
            try JSONEncoder().encode(marker).write(to: markerURL)
            let compiled = URL(fileURLWithPath: user).appendingPathComponent("build/t9.schema.yaml")
            print(
                "READINESS_AFTER marker=\(marker) fingerprint=\(fingerprint) compiled=\(FileManager.default.fileExists(atPath: compiled.path)) matched=\(RimeT9Readiness.isMatched(marker: marker, onDiskFingerprint: fingerprint))"
            )
        }

    }
    private func referenceComment(_ value: String?) -> String? {
        guard let value else { return nil }
        let pairs: [Character: Character] = ["〔": "〕", "【": "】", "[": "]", "(": ")", "（": "）"]
        let closes = Set(pairs.values)
        var stack: [Character] = []
        var kept = ""
        for ch in value {
            if let end = pairs[ch] { stack.append(end); continue }
            if closes.contains(ch) {
                guard stack.last == ch else { return nil }
                stack.removeLast()
                continue
            }
            if stack.isEmpty { kept.append(ch) }
        }
        guard stack.isEmpty else { return nil }
        kept = kept.lowercased().replacingOccurrences(of: "ü", with: "v")
        guard kept.unicodeScalars.allSatisfy({ (97...122).contains($0.value) || $0 == " " || $0 == "'" }),
            kept.unicodeScalars.contains(where: { (97...122).contains($0.value) })
        else { return nil }
        return kept
    }

}
