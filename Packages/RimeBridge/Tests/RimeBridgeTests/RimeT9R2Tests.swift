import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

final class RimeT9R2Tests: XCTestCase {
    @MainActor
    func testObservations() async throws {
        let env = ProcessInfo.processInfo.environment
        func value(_ name: String) -> String? { env[name] ?? env["TEST_RUNNER_" + name] }
        guard let shared = value("UK_MATRIX_SHARED"), let user = value("UK_MATRIX_USER"),
            let schema = value("UK_MATRIX_SCHEMA")
        else { throw XCTSkip("isolated fixture not configured") }
        let deployed = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .testFixtureMaintenanceOnly, sharedDataURL: URL(fileURLWithPath: shared),
                userDataURL: URL(fileURLWithPath: user), runtimeSmokeSchemaID: nil))
        XCTAssertTrue(deployed.succeeded)
        guard deployed.succeeded else { return }
        func engine() -> RimeEngineImpl {
            let result = RimeEngineImpl(sharedDataDir: shared, userDataDir: user)
            XCTAssertTrue(result.bridge.selectSchema(schema))
            return result
        }
        func finish(_ engine: RimeEngineImpl) {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        func checkFog(_ value: String) throws {
            if schema == "t9"
                && value.unicodeScalars.contains(where: {
                    $0.value > 127 || (48...57).contains($0.value) || "[]()".unicodeScalars.contains($0)
                })
            {
                XCTFail("Fog baseline conflicts with §D: \(value)")
                throw NSError(domain: "FogBaselineConflict", code: 1)
            }
        }
        let runtime = engine()
        for sequence in ["94664", "946", "746", "64", "6446", "2", "22", "7464", "8", "86"] {
            runtime.bridge.clearComposition()
            var output = runtime.processKey(String(sequence.first!))
            for key in sequence.dropFirst() { output = runtime.processKey(String(key)) }
            let visible = T9PreeditResolver.visiblePreedit(
                rawInput: output.rawInput,
                candidates: output.candidates, highlightedIndex: output.highlightedIndex)
            print(
                "R2_INPUT schema=\(schema) sequence=\(sequence) raw=\(output.rawInput ?? "nil") preedit=\(output.composition?.preeditText ?? "nil") visible=\(visible)"
            )
            if schema == "t9"
                && visible.unicodeScalars.contains(where: {
                    $0.value > 127 || (48...57).contains($0.value) || "[]()".unicodeScalars.contains($0)
                })
            {
                XCTFail("Fog baseline conflicts with §D: \(visible)")
                finish(runtime)
                throw NSError(domain: "FogBaselineConflict", code: 1)
            }
            print(
                "R2_PAGE sequence=\(sequence) page=0 candidates=\(output.candidates.enumerated().map { "\($0.offset):\($0.element.text){\($0.element.comment ?? "nil")}" }.joined(separator: "|")) more=\(output.hasMorePages)"
            )
            let second = runtime.pageDown()
            print(
                "R2_PAGE sequence=\(sequence) page=1 candidates=\(second.candidates.enumerated().map { "\($0.offset):\($0.element.text){\($0.element.comment ?? "nil")}" }.joined(separator: "|")) more=\(second.hasMorePages)"
            )
            if sequence == "64", output.candidates.count >= 2 {
                let original = output.candidates
                for invalid in ["", "ni💥"] {
                    var copy = original
                    copy[1] = RimeCandidate(
                        text: original[1].text, comment: invalid, globalIndex: original[1].globalIndex)
                    let projected = T9PreeditResolver.visiblePreedit(
                        rawInput: output.rawInput, candidates: copy, highlightedIndex: 1)
                    print(
                        "R2_SYNTHETIC schema=\(schema) first=\(copy[0].comment ?? "nil") highlight=\(invalid) projected=\(projected)"
                    )
                }
            }
        }
        var partialFound = 0
        var partialSamples: [(String, Int, String)] = []
        for sequence in ["644264426442", "94664426442", "746443642664", "6446624264", "9466427464"] {
            for index in 0..<20 {
                runtime.bridge.clearComposition()
                for key in sequence { _ = runtime.processKey(String(key)) }
                let window = runtime.candidateWindow(from: 0, limit: 21)
                guard window.candidates.indices.contains(index) else { break }
                let candidate = window.candidates[index]
                let before = runtime.replaceInput(sequence)
                let selected = runtime.selectCandidate(globalIndex: index)
                if let remaining = selected.rawInput, !remaining.isEmpty {
                    partialFound += 1
                    partialSamples.append((sequence, index, candidate.text))
                    print(
                        "R2_PARTIAL schema=\(schema) sequence=\(sequence) index=\(index) candidate=\(candidate.text) before=\(before.composition?.preeditText ?? "nil") beforeVisible=\(T9PreeditResolver.visiblePreedit(rawInput: before.rawInput, candidates: before.candidates, highlightedIndex: before.highlightedIndex)) commit=\(selected.committedText ?? "nil") raw=\(remaining) preedit=\(selected.composition?.preeditText ?? "nil") afterVisible=\(T9PreeditResolver.visiblePreedit(rawInput: selected.rawInput, candidates: selected.candidates, highlightedIndex: selected.highlightedIndex))"
                    )
                    if partialFound >= 2 { break }
                }
            }
            if partialFound >= 2 { break }
        }
        print("R2_PARTIAL_COUNT schema=\(schema) count=\(partialFound)")
        finish(runtime)
        for (sequence, index, candidate) in partialSamples {
            let isolated = engine()
            let controller = KeyboardController()
            let client = FakeTextInputClient()
            controller.rimeEngine = isolated
            controller.usesT9InputSemantics = true
            controller.textClient = client
            for key in sequence { _ = controller.handle(.insertKey(String(key))) }
            let before = controller.t9CompositionPresentationSnapshot()
            let beforeMarked = client.markedText
            _ = controller.handle(
                .insertCandidate(
                    candidate, kind: .candidate,
                    selectionReference: CandidateSelectionReference(page: 0, indexOnPage: index, globalIndex: index)))
            let after = controller.t9CompositionPresentationSnapshot()
            try checkFog(before.visiblePreedit)
            try checkFog(beforeMarked)
            // The chosen candidate is confirmed text; validate only the unresolved tail.
            if after.visiblePreedit.hasPrefix(candidate) {
                try checkFog(String(after.visiblePreedit.dropFirst(candidate.count)))
            } else {
                print("R2_PARTIAL_TAIL_UNKNOWN visible=\(after.visiblePreedit) candidate=\(candidate)")
            }
            if client.markedText.hasPrefix(candidate) {
                try checkFog(String(client.markedText.dropFirst(candidate.count)))
            } else {
                print("R2_MARKED_TAIL_UNKNOWN marked=\(client.markedText) candidate=\(candidate)")
            }

            print(
                "R2_PARTIAL_CONTROLLER sequence=\(sequence) index=\(index) candidate=\(candidate) beforeVisible=\(before.visiblePreedit) beforeMarked=\(beforeMarked) afterVisible=\(after.visiblePreedit) afterMarked=\(client.markedText) afterText=\(client.text) raw=\(after.rimeRawInput ?? "nil")"
            )
            finish(isolated)
        }
        for sequence in ["64", "6446", "94664", "2", "22", "7464", "8", "86"] {
            let isolated = engine()
            let controller = KeyboardController()
            let client = FakeTextInputClient()
            controller.rimeEngine = isolated
            controller.usesT9InputSemantics = true
            controller.textClient = client
            for key in sequence { _ = controller.handle(.insertKey(String(key))) }
            let snapshot = controller.t9CompositionPresentationSnapshot()
            try checkFog(snapshot.visiblePreedit)
            try checkFog(client.markedText)
            print("R2_CONTROLLER sequence=\(sequence) visible=\(snapshot.visiblePreedit) marked=\(client.markedText)")
            if let path = snapshot.paths.first {
                _ = controller.handle(.selectT9PinyinPath(path))
                try checkFog(controller.t9CompositionPresentationSnapshot().visiblePreedit)
                try checkFog(client.markedText)
                print(
                    "R2_PATH sequence=\(sequence) path=\(path.displayText) visible=\(controller.t9CompositionPresentationSnapshot().visiblePreedit) marked=\(client.markedText)"
                )
                _ = controller.handle(.deleteBackward)
                try checkFog(controller.t9CompositionPresentationSnapshot().visiblePreedit)
                try checkFog(client.markedText)
                print(
                    "R2_DELETE sequence=\(sequence) visible=\(controller.t9CompositionPresentationSnapshot().visiblePreedit) marked=\(client.markedText)"
                )
            }
            finish(isolated)
        }
    }
}
