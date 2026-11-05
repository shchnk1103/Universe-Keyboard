import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

/// Real-engine assertions for the slice 3a matrix. Observation lines stay in `RimeT9R2Tests`.
final class RimeT9MatrixAssertTests: XCTestCase {
    private let shortSequences = ["64", "6446", "94664", "2", "22", "7464", "8", "86"]

    @MainActor
    func testShortSequencesMatchProjection() async throws {
        let harness = try await openHarness()
        for sequence in shortSequences {
            let sample = shortSequenceSample(harness, sequence)
            XCTAssertEqual(sample.snapshot.visiblePreedit, sample.client.markedText, sequence)
            assertNoDigitsOrEmoji(sample.snapshot.visiblePreedit, sequence)
            assertNoDigitsOrEmoji(sample.client.markedText, sequence)
            let narrow = T9PreeditResolver.visiblePreedit(
                rawInput: sample.output.rawInput,
                candidates: sample.output.candidates,
                highlightedIndex: sample.output.highlightedIndex)
            // Empty narrow projection is the emoji-on case: the highlighted comment
            // fails validation, while the host still shows the provisional Path.
            let projected = narrow.isEmpty ? provisionalAwareVisiblePreedit(sample) : narrow
            XCTAssertEqual(sample.snapshot.visiblePreedit, projected, sequence)
            XCTAssertEqual(sample.client.markedText, projected, sequence)
        }
    }

    /// Same provisional Path selection as `KeyboardController.t9VisiblePreedit(for:)`.
    private func provisionalAwareVisiblePreedit(_ sample: ShortSequenceSample) -> String {
        let pathState = sample.pathState
        let provisional =
            pathState.selectedPath == nil
            ? (pathState.compactPaths.first { $0.id == pathState.provisionalPathID }
                ?? pathState.compactPaths.first)
            : nil
        return T9PreeditResolver.visiblePreedit(
            rawInput: sample.output.rawInput,
            candidates: sample.output.candidates,
            highlightedIndex: sample.output.highlightedIndex,
            provisionalPathDisplay: provisional?.displayText,
            provisionalConsumedSlots: provisional?.consumedSlotCount)
    }

    @MainActor
    private func shortSequenceSample(_ harness: Harness, _ sequence: String) -> ShortSequenceSample {
        let engine = harness.makeEngine()
        let controller = KeyboardController()
        let client = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        controller.textClient = client
        for key in sequence { _ = controller.handle(.insertKey(String(key))) }
        let output = controller.state.lastRimeOutput ?? RimeOutput()
        let snapshot = controller.t9CompositionPresentationSnapshot()
        let pathState = controller.state.t9PinyinPathState
        harness.finish(engine)
        return ShortSequenceSample(
            output: output, snapshot: snapshot, client: client, pathState: pathState)
    }

    private struct ShortSequenceSample {
        let output: RimeOutput
        let snapshot: T9CompositionPresentationSnapshot
        let client: FakeTextInputClient
        let pathState: T9PinyinPathState
    }

    @MainActor
    func testLongSequenceKeepsConfirmedTextAndProjectedRemainder() async throws {
        let harness = try await openHarness()
        let sequence = "644264426442"
        for index in [1, 2] {
            let isolated = harness.makeEngine()
            let controller = KeyboardController()
            let client = FakeTextInputClient()
            controller.rimeEngine = isolated
            controller.usesT9InputSemantics = true
            controller.textClient = client
            for key in sequence { _ = controller.handle(.insertKey(String(key))) }
            let before = controller.state.lastRimeOutput
            let candidates = before?.candidates ?? []
            XCTAssertTrue(candidates.indices.contains(index), "home page item \(index + 1) missing")
            let chosen = candidates[index].text
            _ = controller.handle(
                .insertCandidate(
                    chosen, kind: .candidate,
                    selectionReference: CandidateSelectionReference(
                        page: 0, indexOnPage: index, globalIndex: index)))
            let after = controller.t9CompositionPresentationSnapshot()
            let output = controller.state.lastRimeOutput
            let projected = T9PreeditResolver.visiblePreedit(
                rawInput: output?.rawInput,
                candidates: output?.candidates ?? [],
                highlightedIndex: output?.highlightedIndex)
            XCTAssertTrue(
                client.text == chosen || client.text.hasPrefix(chosen),
                "confirmed text \(client.text) dropped \(chosen)")
            let visibleTail = unresolvedTail(after.visiblePreedit, confirmed: chosen)
            let markedTail = unresolvedTail(client.markedText, confirmed: chosen)
            XCTAssertTrue(visibleTail == projected || visibleTail.isEmpty, "visible tail \(visibleTail)")
            XCTAssertTrue(markedTail == projected || markedTail.isEmpty, "marked tail \(markedTail)")
            assertNoDigitsOrEmoji(visibleTail, "remainder \(index)")
            assertNoDigitsOrEmoji(markedTail, "marked remainder \(index)")
            if let raw = after.rimeRawInput, raw.unicodeScalars.contains(where: isASCIIDigit) {
                XCTAssertNotEqual(visibleTail, raw, "digit raw must not be the visible remainder")
                XCTAssertNotEqual(markedTail, raw, "digit raw must not be the marked remainder")
            }
            harness.finish(isolated)
        }
    }

    @MainActor
    func testFirstPathThenDeleteStaysExplainable() async throws {
        let harness = try await openHarness()
        var checked = 0
        for sequence in shortSequences {
            let isolated = harness.makeEngine()
            let controller = KeyboardController()
            let client = FakeTextInputClient()
            controller.rimeEngine = isolated
            controller.usesT9InputSemantics = true
            controller.textClient = client
            for key in sequence { _ = controller.handle(.insertKey(String(key))) }
            guard let path = controller.t9CompositionPresentationSnapshot().paths.first else {
                harness.finish(isolated)
                continue
            }
            _ = controller.handle(.selectT9PinyinPath(path))
            assertExplainable(controller, client: client, label: "path \(sequence)")
            _ = controller.handle(.deleteBackward)
            assertExplainable(controller, client: client, label: "delete \(sequence)")
            harness.finish(isolated)
            checked += 1
        }
        XCTAssertGreaterThan(checked, 0, "no path to explain")
    }

    /// Emoji candidates are scanned on pages 0 and 1 only.
    @MainActor
    func testEmojiSwitchOnScannedPages() async throws {
        let harness = try await openHarness()
        let emojiOn = harness.emojiSwitchEnabled
        if harness.schema == "t9" {
            XCTAssertFalse(emojiOn)
            return
        }
        for sequence in ["94664", "946", "746"] {
            let sample = harness.drive(sequence)
            let projected = T9PreeditResolver.visiblePreedit(
                rawInput: sample.output.rawInput,
                candidates: sample.output.candidates,
                highlightedIndex: sample.output.highlightedIndex)
            XCTAssertEqual(sample.snapshot.visiblePreedit, projected, sequence)
            XCTAssertEqual(sample.client.markedText, projected, sequence)
            assertNoDigitsOrEmoji(sample.snapshot.visiblePreedit, sequence)
            assertNoDigitsOrEmoji(sample.client.markedText, sequence)
            let pages = harness.candidateTexts(sequence: sequence, pageLimit: 2)
            let emoji = pages.texts.filter(containsEmoji)
            if emojiOn {
                XCTAssertFalse(emoji.isEmpty, "pages 0...\(pages.lastPage) of \(sequence) have no emoji")
            } else {
                XCTAssertTrue(emoji.isEmpty, "pages 0...\(pages.lastPage) of \(sequence) still have \(emoji)")
            }
        }
    }

    @MainActor
    func testVisiblePreeditExcludesDigitsAndEmoji() async throws {
        let harness = try await openHarness()
        for sequence in shortSequences {
            let sample = harness.drive(sequence)
            assertNoDigitsOrEmoji(sample.snapshot.visiblePreedit, sequence)
            XCTAssertFalse(sample.snapshot.visiblePreedit.unicodeScalars.contains(where: isASCIIDigit))
            XCTAssertFalse(containsEmoji(sample.snapshot.visiblePreedit), sequence)
        }
    }

    @MainActor
    private func assertExplainable(_ controller: KeyboardController, client: FakeTextInputClient, label: String) {
        let snapshot = controller.t9CompositionPresentationSnapshot()
        assertNoDigitsOrEmoji(snapshot.visiblePreedit, label)
        assertNoDigitsOrEmoji(client.markedText, label)
        let raw = snapshot.rimeRawInput ?? ""
        let slots = raw.unicodeScalars.reduce(into: 0) { count, scalar in
            if T9PinyinPathExtractor.isASCIILetter(scalar) || T9PinyinPathExtractor.isASCIIDigit(scalar) {
                count += 1
            }
        }
        let letters = snapshot.visiblePreedit.unicodeScalars.filter(T9PinyinPathExtractor.isASCIILetter).count
        if raw.isEmpty {
            XCTAssertTrue(snapshot.visiblePreedit.isEmpty, label)
        } else {
            XCTAssertLessThanOrEqual(letters, slots, label)
            if raw.unicodeScalars.contains(where: isASCIIDigit) {
                XCTAssertNotEqual(snapshot.visiblePreedit, raw, label)
                XCTAssertNotEqual(client.markedText, raw, label)
            }
        }
    }

    private func unresolvedTail(_ value: String, confirmed: String) -> String {
        value.hasPrefix(confirmed) ? String(value.dropFirst(confirmed.count)) : value
    }

    private func assertNoDigitsOrEmoji(_ value: String, _ label: String) {
        XCTAssertFalse(value.unicodeScalars.contains(where: isASCIIDigit), label)
        XCTAssertFalse(containsEmoji(value), label)
    }

    private func isASCIIDigit(_ scalar: Unicode.Scalar) -> Bool {
        (48...57).contains(scalar.value)
    }

    private func containsEmoji(_ value: String) -> Bool {
        value.unicodeScalars.contains { scalar in
            scalar.properties.isEmojiPresentation
                || (scalar.properties.isEmoji && scalar.value > 255)
        }
    }

    @MainActor
    private func openHarness() async throws -> Harness {
        let env = ProcessInfo.processInfo.environment
        func value(_ name: String) -> String? {
            env[name] ?? env["TEST_RUNNER_" + name] ?? env["SIMCTL_CHILD_" + name]
        }
        guard let shared = value("UK_MATRIX_SHARED"), let user = value("UK_MATRIX_USER"),
            let schema = value("UK_MATRIX_SCHEMA")
        else { throw XCTSkip("isolated fixture not configured") }
        let deployed = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .testFixtureMaintenanceOnly, sharedDataURL: URL(fileURLWithPath: shared),
                userDataURL: URL(fileURLWithPath: user), runtimeSmokeSchemaID: nil))
        XCTAssertTrue(deployed.succeeded)
        let custom = URL(fileURLWithPath: user).appendingPathComponent(schema + ".custom.yaml")
        let emojiOn = (try? String(contentsOf: custom, encoding: .utf8))?.contains("switches/@3/reset: 1") == true
        return Harness(shared: shared, user: user, schema: schema, emojiSwitchEnabled: emojiOn)
    }

    @MainActor
    private struct Harness {
        let shared: String
        let user: String
        let schema: String
        let emojiSwitchEnabled: Bool

        func makeEngine() -> RimeEngineImpl {
            let engine = RimeEngineImpl(sharedDataDir: shared, userDataDir: user)
            XCTAssertTrue(engine.bridge.selectSchema(schema))
            return engine
        }

        func finish(_ engine: RimeEngineImpl) {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }

        func drive(_ sequence: String) -> (
            output: RimeOutput, snapshot: T9CompositionPresentationSnapshot, client: FakeTextInputClient
        ) {
            let engine = makeEngine()
            let controller = KeyboardController()
            let client = FakeTextInputClient()
            controller.rimeEngine = engine
            controller.usesT9InputSemantics = true
            controller.textClient = client
            for key in sequence { _ = controller.handle(.insertKey(String(key))) }
            let output = controller.state.lastRimeOutput ?? RimeOutput()
            let snapshot = controller.t9CompositionPresentationSnapshot()
            finish(engine)
            return (output, snapshot, client)
        }

        /// Pages 0 through `pageLimit - 1`, stopping when the engine reports no further page.
        func candidateTexts(sequence: String, pageLimit: Int) -> (texts: [String], lastPage: Int) {
            let engine = makeEngine()
            defer { finish(engine) }
            var output = RimeOutput()
            for key in sequence { output = engine.processKey(String(key)) }
            var texts: [String] = []
            var page = 0
            while true {
                texts.append(contentsOf: output.candidates.map(\.text))
                if page + 1 >= pageLimit || !output.hasMorePages { break }
                output = engine.pageDown()
                page += 1
            }
            return (texts, page)
        }
    }
}
