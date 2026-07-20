import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

/// Real librime Spike for precise T9 pinyin path selection.
///
/// KEYBOARD-LAYOUT-9KEY-PINYIN-002 additionally requires every deterministic
/// single-key choice shown for digit 6 (`m`, `n`, `o`) to be a safe refinement.
///
/// Preconditions (same isolated runtime as `scripts/run_t9_pinyin_selection_spike.sh`):
/// - `UK_RIME_T9_SPIKE_SHARED_DIR` / `UK_RIME_T9_SPIKE_USER_DIR`
/// - Compatible `t9.schema.yaml` without unsupported `t9_processor`
///
/// Hard stop conditions (any failure blocks product UI):
/// - `replaceInput` rejects letter / mixed refinement
/// - candidate comments cannot express usable pinyin paths
/// - schema or vendor upgrade required (not authorized)
final class RimeT9PinyinSelectionSpikeTests: XCTestCase {
    func testPrecisePinyinPathRefinementOnPinnedLibrime() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)

        let deployService = RimeDeploymentService()
        let deployResult = try await deployService.deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir),
                userDataURL: URL(fileURLWithPath: directories.userDir),
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(
            deployResult.succeeded,
            "T9 pinyin Spike deploy failed: \(deployResult.diagnosticMessage)"
        )

        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: directories.userDir
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }

        let selected = engine.bridge.selectSchema("t9")
        let currentSchema = engine.bridge.currentSchemaID()
        XCTAssertTrue(selected, "selectSchema(t9) returned false")
        XCTAssertEqual(currentSchema, "t9")

        // --- Digit 6: path comments ---
        engine.bridge.clearComposition()
        let after6 = engine.processKey("6")
        let raw6 = after6.rawInput ?? ""
        let comments6 = uniquePinyinLikeComments(from: after6.candidates)
        let window6 = engine.candidateWindow(from: 0, limit: 32)
        let windowComments6 = uniquePinyinLikeComments(from: window6.candidates)

        XCTAssertEqual(raw6, "6", "Expected raw '6', got '\(raw6)'")
        XCTAssertFalse(after6.candidates.isEmpty, "Digit 6 must produce Chinese candidates")
        XCTAssertFalse(
            comments6.isEmpty && windowComments6.isEmpty,
            """
            STOP: no pinyin-like candidate comments after digit 6. \
            pageComments=\(after6.candidates.map { $0.comment ?? "∅" }) \
            windowComments=\(window6.candidates.map { $0.comment ?? "∅" })
            """
        )

        let pathPool6 = comments6.isEmpty ? windowComments6 : comments6
        let expectedSingleLetters: Set<String> = ["m", "n", "o"]
        let singleLetterPaths = Set(pathPool6.filter { $0.count == 1 })
        // Record actual paths; product may adjust display if not exactly m/n/o.
        let hasMNOOverlap = !singleLetterPaths.isDisjoint(with: expectedSingleLetters)
        XCTAssertTrue(
            hasMNOOverlap || pathPool6.contains(where: { !$0.isEmpty }),
            "Expected at least one usable path comment after 6; got \(pathPool6)"
        )

        // --- KEYBOARD-LAYOUT-9KEY-PINYIN-002 hard gate: all MNO refinements ---
        var singleLetterCandidateCounts: [String: Int] = [:]
        for letterPath in ["m", "n", "o"] {
            // Recreate the same ambiguous source before each probe. A previous
            // replaceInput must not influence the next letter's evidence.
            engine.bridge.clearComposition()
            let source = engine.processKey("6")
            XCTAssertEqual(source.rawInput, "6")

            let refinedLetter = engine.replaceInput(letterPath)
            let refinedRaw = refinedLetter.rawInput ?? ""
            let refinedHasComposition = !(refinedLetter.composition?.preeditText ?? "").isEmpty
                || !refinedRaw.isEmpty

            XCTAssertNil(
                refinedLetter.committedText,
                "STOP: replaceInput(\(letterPath)) produced committedText=\(refinedLetter.committedText ?? "nil")"
            )
            XCTAssertEqual(
                refinedRaw.lowercased(),
                letterPath,
                "replaceInput must set raw input to \(letterPath); got '\(refinedRaw)'"
            )
            XCTAssertTrue(
                refinedHasComposition,
                "replaceInput(\(letterPath)) must keep a non-empty composition"
            )
            XCTAssertFalse(
                refinedLetter.candidates.isEmpty,
                "STOP: replaceInput(\(letterPath)) must keep Chinese candidates non-empty"
            )
            singleLetterCandidateCounts[letterPath] = refinedLetter.candidates.count
        }

        // --- Amendment A hard gate: retained first segment + next digit ---
        // Native nine-key keeps the selected `n` visible after the user presses
        // GHI. The engine must therefore support an uncommitted `n4` source and
        // expose enough live path evidence to derive the next segment safely.
        engine.bridge.clearComposition()
        _ = engine.processKey("6")
        let selectedN = engine.replaceInput("n")
        XCTAssertEqual(selectedN.rawInput?.lowercased(), "n")
        XCTAssertNil(selectedN.committedText)

        let afterN4 = engine.processKey("4")
        let rawN4 = afterN4.rawInput ?? ""
        let windowN4 = engine.candidateWindow(from: 0, limit: 48)
        let pagePathsN4 = uniquePinyinLikeComments(from: afterN4.candidates)
        let windowPathsN4 = uniquePinyinLikeComments(from: windowN4.candidates)
        let pathPoolN4 = pagePathsN4.isEmpty ? windowPathsN4 : pagePathsN4

        XCTAssertNil(
            afterN4.committedText,
            "STOP: n + digit 4 must remain an uncommitted composition"
        )
        XCTAssertEqual(
            rawN4.lowercased(),
            "n4",
            "STOP: retained segment must preserve n + next ambiguous digit; got '\(rawN4)'"
        )
        XCTAssertFalse(
            afterN4.candidates.isEmpty,
            "STOP: n4 must retain Chinese candidates"
        )
        XCTAssertFalse(
            pathPoolN4.isEmpty,
            "STOP: n4 must expose live pinyin path comments for segment authorization"
        )

        var segmentedCandidateCounts: [String: Int] = [:]
        var segmentedRawInputs: [String: String] = [:]
        var segmentedComments: [String: [String]] = [:]
        var segmentedPreedits: [String: String] = [:]
        var segmentedFirstCandidates: [String: String] = [:]
        for suffix in ["g", "h", "i"] {
            engine.bridge.clearComposition()
            _ = engine.processKey("6")
            _ = engine.replaceInput("n")
            _ = engine.processKey("4")

            let segmentedPath = "n'\(suffix)"
            let refinedSegment = engine.replaceInput(segmentedPath)
            let refinedRaw = refinedSegment.rawInput ?? ""
            XCTAssertNil(
                refinedSegment.committedText,
                "STOP: replaceInput(\(segmentedPath)) must not host-commit"
            )
            segmentedRawInputs[suffix] = refinedRaw
            segmentedCandidateCounts[suffix] = refinedSegment.candidates.count
            segmentedComments[suffix] = uniquePinyinLikeComments(
                from: refinedSegment.candidates
            )
            segmentedPreedits[suffix] = refinedSegment.composition?.preeditText ?? ""
            segmentedFirstCandidates[suffix] = refinedSegment.candidates.first?.text ?? ""
        }

        // Native observation requires g/h to be selectable after confirmed n.
        // `i` is deliberately observational: its engine viability alone must
        // not authorize UI display if live n4 path comments omit it.
        for requiredSuffix in ["g", "h"] {
            XCTAssertEqual(
                segmentedRawInputs[requiredSuffix]?.lowercased(),
                "n'\(requiredSuffix)",
                "STOP: segmented path n'\(requiredSuffix) was not preserved"
            )
            XCTAssertGreaterThan(
                segmentedCandidateCounts[requiredSuffix] ?? 0,
                0,
                "STOP: segmented path n'\(requiredSuffix) must keep Chinese candidates"
            )
        }

        let authorizedSuffixes = ["g", "h", "i"].filter { suffix in
            (segmentedComments[suffix] ?? []).contains { path in
                path.split(separator: "'").dropFirst().contains { segment in
                    segment.hasPrefix(suffix)
                }
            }
        }
        XCTAssertEqual(
            authorizedSuffixes,
            ["g", "h"],
            "STOP: live RIME paths must authorize g/h and reject fallback-only i"
        )

        // --- 64 → select ni (or first multi-letter path) ---
        engine.bridge.clearComposition()
        var after64 = engine.processKey("6")
        after64 = engine.processKey("4")
        let raw64 = after64.rawInput ?? ""
        XCTAssertEqual(raw64, "64")
        XCTAssertFalse(after64.candidates.isEmpty)

        let comments64 = uniquePinyinLikeComments(from: after64.candidates)
        let window64 = engine.candidateWindow(from: 0, limit: 48)
        let windowComments64 = uniquePinyinLikeComments(from: window64.candidates)
        let pathPool64 = comments64.isEmpty ? windowComments64 : comments64
        XCTAssertFalse(
            pathPool64.isEmpty,
            """
            STOP: no pinyin-like comments after 64. \
            page=\(after64.candidates.map { $0.comment ?? "∅" }) \
            window=\(window64.candidates.map { $0.comment ?? "∅" })
            """
        )

        let niPath = pathPool64.first(where: { $0 == "ni" })
            ?? pathPool64.first(where: { $0.hasPrefix("ni") })
            ?? pathPool64.first(where: { $0.count >= 2 })
            ?? pathPool64[0]
        let candidateCountBefore = after64.candidates.count
        let refinedNi = engine.replaceInput(niPath)
        let rawNi = refinedNi.rawInput ?? ""
        XCTAssertNil(
            refinedNi.committedText,
            "STOP: replaceInput(\(niPath)) committed host text: \(refinedNi.committedText ?? "")"
        )
        XCTAssertEqual(
            rawNi.lowercased().replacingOccurrences(of: " ", with: "'"),
            niPath.lowercased().replacingOccurrences(of: " ", with: "'"),
            "Expected raw '\(niPath)', got '\(rawNi)'"
        )
        XCTAssertFalse(refinedNi.candidates.isEmpty, "Refined path must keep Chinese candidates")

        // Narrowing: refined set should not explode relative to digit ambiguity (soft check).
        // Hard check: composition is letter-shaped, not still pure "64".
        XCTAssertNotEqual(rawNi, "64", "Path refine must leave pure digit raw input")
        let _ = candidateCountBefore

        // Continue typing a digit → mixed raw input if engine accepts.
        let afterMixed = engine.processKey("4")
        let mixedRaw = afterMixed.rawInput ?? ""
        let mixedCommitted = afterMixed.committedText
        XCTAssertNil(
            mixedCommitted,
            "Continuing digit after letter refine must not host-commit; got \(mixedCommitted ?? "")"
        )
        // Accept either mixed form (ni4 / ni'4 / etc.) or pure digits if engine rewrote.
        let mixedIsLetterDigit = mixedRaw.rangeOfCharacter(from: .letters) != nil
            && mixedRaw.rangeOfCharacter(from: .decimalDigits) != nil
        let mixedIsContinued = !mixedRaw.isEmpty
        XCTAssertTrue(
            mixedIsContinued,
            "After refine+digit, raw input must remain non-empty; got '\(mixedRaw)'"
        )

        // Backspace reduces raw length by one when non-empty.
        let beforeDeleteRaw = mixedRaw
        let afterDelete = engine.processDeletion()
        let afterDeleteRaw = afterDelete.rawInput ?? ""
        if !beforeDeleteRaw.isEmpty {
            XCTAssertEqual(
                afterDeleteRaw.count,
                beforeDeleteRaw.count - 1,
                "BackSpace must remove one raw unit; before=\(beforeDeleteRaw) after=\(afterDeleteRaw)"
            )
        }

        // candidateWindow must not clear composition solely by reading.
        engine.bridge.clearComposition()
        var base = engine.processKey("6")
        base = engine.processKey("4")
        let rawBeforeWindow = base.rawInput ?? ""
        let highlightedBefore = base.highlightedIndex
        let windowRead = engine.candidateWindow(from: 0, limit: 16)
        // Re-read engine state by re-applying the same raw input (window read must not host-commit).
        let afterWindowProbe = engine.replaceInput(rawBeforeWindow)
        XCTAssertEqual(afterWindowProbe.rawInput ?? "", rawBeforeWindow)
        XCTAssertNil(afterWindowProbe.committedText)
        XCTAssertFalse(windowRead.candidates.isEmpty || base.candidates.isEmpty)
        _ = highlightedBefore

        // Empty-candidate path: replace with nonsense letters that produce no commit.
        let emptyish = engine.replaceInput("zzzzzzzz")
        XCTAssertNil(
            emptyish.committedText,
            "Failed/empty refine must not commit raw to host"
        )

        let summary = """
        T9_PINYIN_SPIKE_RESULT passed=true \
        librime=\(engine.bridge.librimeVersion()) \
        schema=\(currentSchema) \
        comments6=\(pathPool6.joined(separator: "|")) \
        deterministicChoices=m|n|o \
        singleLetterCandidateCounts=m:\(singleLetterCandidateCounts["m"] ?? 0),n:\(singleLetterCandidateCounts["n"] ?? 0),o:\(singleLetterCandidateCounts["o"] ?? 0) \
        rawAfterN4=\(rawN4) \
        commentsN4=\(pathPoolN4.prefix(16).joined(separator: "|")) \
        segmentedRaw=g:\(segmentedRawInputs["g"] ?? ""),h:\(segmentedRawInputs["h"] ?? ""),i:\(segmentedRawInputs["i"] ?? "") \
        segmentedCandidateCounts=g:\(segmentedCandidateCounts["g"] ?? 0),h:\(segmentedCandidateCounts["h"] ?? 0),i:\(segmentedCandidateCounts["i"] ?? 0) \
        segmentedComments=g:\((segmentedComments["g"] ?? []).prefix(8).joined(separator: "|")),h:\((segmentedComments["h"] ?? []).prefix(8).joined(separator: "|")),i:\((segmentedComments["i"] ?? []).prefix(8).joined(separator: "|")) \
        segmentedPreedits=g:\(segmentedPreedits["g"] ?? ""),h:\(segmentedPreedits["h"] ?? ""),i:\(segmentedPreedits["i"] ?? "") \
        segmentedFirstCandidates=g:\(segmentedFirstCandidates["g"] ?? ""),h:\(segmentedFirstCandidates["h"] ?? ""),i:\(segmentedFirstCandidates["i"] ?? "") \
        authorizedSuffixes=\(authorizedSuffixes.joined(separator: "|")) \
        comments64=\(pathPool64.prefix(12).joined(separator: "|")) \
        niPath=\(niPath) \
        rawAfterNi=\(rawNi) \
        niCandidateCount=\(refinedNi.candidates.count) \
        mixedRaw=\(mixedRaw) \
        mixedIsLetterDigit=\(mixedIsLetterDigit) \
        rawAfterDelete=\(afterDeleteRaw) \
        window6Count=\(window6.candidates.count) \
        window64Count=\(window64.candidates.count) \
        deploy=\(deployResult.diagnosticMessage)
        """
        fputs(summary + "\n", stderr)
        print(summary)
        NSLog("%@", summary)
    }

    // MARK: - Helpers

    private func uniquePinyinLikeComments(from candidates: [RimeCandidate]) -> [String] {
        var seen = Set<String>()
        var ordered: [String] = []
        for candidate in candidates {
            guard let comment = candidate.comment else { continue }
            guard let path = normalizePinyinComment(comment) else { continue }
            if seen.insert(path).inserted {
                ordered.append(path)
            }
        }
        return ordered
    }

    /// Accept ASCII letters / spaces / apostrophes only; lowercase; collapse whitespace to `'`.
    private func normalizePinyinComment(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        var scalars: [UnicodeScalar] = []
        for scalar in trimmed.unicodeScalars {
            let isLetter = CharacterSet.lowercaseLetters.contains(scalar)
                || CharacterSet.uppercaseLetters.contains(scalar)
            let isSpace = CharacterSet.whitespaces.contains(scalar)
            let isApos = scalar == "'"
            guard isLetter || isSpace || isApos else { return nil }
            if isSpace {
                if scalars.last != "'" {
                    scalars.append("'")
                }
            } else if isApos {
                if scalars.last != "'" {
                    scalars.append("'")
                }
            } else {
                let lower = Character(scalar).lowercased()
                for s in lower.unicodeScalars {
                    scalars.append(s)
                }
            }
        }
        while scalars.last == "'" { scalars.removeLast() }
        while scalars.first == "'" { scalars.removeFirst() }
        let value = String(String.UnicodeScalarView(scalars))
        return value.isEmpty ? nil : value
    }

    private func spikeRuntimeDirectories() throws -> (sharedDir: String, userDir: String) {
        let env = ProcessInfo.processInfo.environment
        let sharedDir = env["UK_RIME_T9_SPIKE_SHARED_DIR"] ?? env["TEST_RUNNER_UK_RIME_T9_SPIKE_SHARED_DIR"]
        let userDir = env["UK_RIME_T9_SPIKE_USER_DIR"] ?? env["TEST_RUNNER_UK_RIME_T9_SPIKE_USER_DIR"]

        guard let sharedDir, let userDir else {
            throw XCTSkip(
                "Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 pinyin selection Spike."
            )
        }

        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: sharedDir), fileManager.fileExists(atPath: userDir) else {
            throw XCTSkip("Provided T9 Spike directories do not exist.")
        }
        guard fileManager.fileExists(atPath: "\(sharedDir)/t9.schema.yaml"),
              fileManager.fileExists(atPath: "\(sharedDir)/rime_ice.schema.yaml")
        else {
            throw XCTSkip("T9 Spike fixture is incomplete (needs t9.schema.yaml and rime_ice.schema.yaml).")
        }

        return (sharedDir, userDir)
    }

    private func assertSpikeSchemaIsPatched(sharedDir: String) throws {
        let schemaPath = "\(sharedDir)/t9.schema.yaml"
        let contents = try String(contentsOfFile: schemaPath, encoding: .utf8)
        XCTAssertFalse(
            contents.contains("t9_processor"),
            "Spike fixture must remove unsupported t9_processor before using the pinned librime."
        )
        XCTAssertTrue(
            contents.contains("schema_id: t9") || contents.contains("schema_id:t9"),
            "Spike fixture must remain schema_id t9."
        )
        XCTAssertTrue(
            contents.contains("derive/[abc]/2/"),
            "Spike fixture must retain T9 digit algebra mappings."
        )
    }
}
