import XCTest

/// PB-001-AUDIO-HAPTICS-HYGIENE-001 r1: click/haptic sync-hygiene contracts
/// for `KeyboardViewController+Feedback.swift`. The keyboard-extension module
/// is not importable from unit-test bundles, so these follow the repo's
/// source-contract fixture pattern (see `DeleteKeyScrubContractTests`).
final class KeyboardFeedbackSyncContractTests: XCTestCase {
    /// A1: repeat/scrub click and haptic must fire on the same tick, with the
    /// haptic at reduced intensity instead of the old every-4th-tick gating.
    func testRepeatFeedbackFiresClickAndHapticOnTheSameTick() throws {
        let feedback = try sourceFile("Keyboard/Controllers/KeyboardViewController+Feedback.swift")

        XCTAssertTrue(
            feedback.contains("KeyboardFeedbackRepeatRhythm"),
            "Repeat rhythm must be decided by the shared rhythm helper."
        )
        XCTAssertFalse(
            feedback.contains("isMultiple(of: 4)"),
            "Repeat haptics must no longer be gated to every 4th tick."
        )
    }

    /// A2: a `.commit` inside a narrow window after a `.tap` must be
    /// suppressed, with an injectable clock and no sleeps.
    func testTapCommitDedupUsesInjectableClock() throws {
        let feedback = try sourceFile("Keyboard/Controllers/KeyboardViewController+Feedback.swift")

        XCTAssertTrue(
            feedback.contains("struct KeyboardFeedbackTapCommitDedup"),
            "Missing the tap→commit dedup guard."
        )
        XCTAssertTrue(
            feedback.contains("struct KeyboardFeedbackClock"),
            "The dedup clock must be injectable for deterministic tests."
        )
        XCTAssertFalse(
            feedback.contains("Task.sleep"),
            "Feedback must stay deterministic; no sleeps."
        )

        // The dedup window stays in the tens-of-milliseconds range.
        let window = try dedupWindow(from: feedback)
        XCTAssertTrue(
            (0.02...0.1).contains(window),
            "Dedup window \(window)s is outside the tens-of-ms range."
        )

        // emitFeedback consults the injectable clock and the guard before
        // firing either channel.
        let emitBody = try functionBody("func emitFeedback(", in: feedback)
        XCTAssertTrue(
            emitBody.contains("clock.now()"),
            "emitFeedback must read the injectable clock."
        )
        XCTAssertTrue(
            emitBody.contains("shouldEmit"),
            "emitFeedback must consult the dedup guard before firing."
        )
        XCTAssertTrue(emitBody.contains("playHaptic"))
        XCTAssertTrue(emitBody.contains("playKeyClick"))
    }

    /// A3: prepare() precedes the first user-visible impact, and a hardware
    /// style swap prepares the freshly swapped generator.
    func testHapticPreparesBeforeImpactAndAfterStyleSwap() throws {
        let feedback = try sourceFile("Keyboard/Controllers/KeyboardViewController+Feedback.swift")

        let playHapticBody = try functionBody("func playHaptic(", in: feedback)
        let prepareIndex = try requireRange(of: "prepare()", in: playHapticBody)
        let impactIndex = try requireRange(of: "impactOccurred", in: playHapticBody)
        XCTAssertLessThan(
            prepareIndex.lowerBound,
            impactIndex.lowerBound,
            "playHaptic must prepare before impacting."
        )

        let applyBody = try functionBody("func applyHapticHardwareStyle(", in: feedback)
        XCTAssertTrue(applyBody.contains("UIImpactFeedbackGenerator(style:"))
        XCTAssertTrue(
            applyBody.contains("prepare()"),
            "applyHapticHardwareStyle must prepare the swapped generator."
        )
    }

    // MARK: - Fixtures

    private struct FixtureError: Error {}

    private func dedupWindow(from source: String) throws -> TimeInterval {
        let pattern = "dedupWindow: TimeInterval = ([0-9.]+)"
        guard let range = source.range(of: pattern, options: .regularExpression) else {
            XCTFail("Missing KeyboardFeedbackTapCommitDedup.dedupWindow constant.")
            throw FixtureError()
        }
        let value = Double(source[range].split(separator: "=")[1].trimmingCharacters(in: .whitespaces))
        guard let value else {
            XCTFail("dedupWindow is not numeric.")
            throw FixtureError()
        }
        return value
    }

    private func functionBody(_ signatureMarker: String, in source: String) throws -> Substring {
        let signatureStart = try requireRange(of: signatureMarker, in: source)
        guard let braceStart = source[signatureStart.upperBound...].firstIndex(of: "{") else {
            XCTFail("No braces after \(signatureMarker).")
            throw FixtureError()
        }
        var depth = 0
        var index = braceStart
        while index < source.endIndex {
            let character = source[index]
            if character == "{" { depth += 1 }
            if character == "}" {
                depth -= 1
                if depth == 0 { return source[braceStart...index] }
            }
            index = source.index(after: index)
        }
        XCTFail("Unbalanced braces after \(signatureMarker).")
        throw FixtureError()
    }

    private func requireRange<S: StringProtocol>(
        of needle: String,
        in source: S
    ) throws -> Range<S.Index> {
        guard let range = source.range(of: needle) else {
            XCTFail("Missing \(needle) in \(source.prefix(40))….")
            throw FixtureError()
        }
        return range
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let repositoryRoot = testsDirectory.deletingLastPathComponent()
        return try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
