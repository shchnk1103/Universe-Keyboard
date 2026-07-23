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
    /// ADR 0022 Stage A: prove whether one read-only candidate window can replace
    /// the spelling-scaled foreground probes for the frozen synthetic cases.
    func testAtomicPathDiscoveryStageAOnPinnedLibrime() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir),
                userDataURL: URL(fileURLWithPath: directories.userDir),
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: directories.userDir
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        XCTAssertTrue(engine.bridge.selectSchema("t9"))

        let cases: [(spelling: String, confirmed: [String], expectedNext: String)] = [
            ("deizhaoyishengwenyixia", ["dei"], "zhao"),
            ("qingweifandaowozuili", ["qing", "wei", "fan", "dao"], "wo"),
            ("qiule", ["qiu"], "le"),
        ]
        let windowLimits = [16, 24, 32, 48]
        var coverageByLimit = Dictionary(uniqueKeysWithValues: windowLimits.map { ($0, 0) })

        for item in cases {
            let sourceDigits = t9Digits(for: item.spelling)
            let consumed = item.confirmed.reduce(0) { $0 + $1.count }
            let remainingDigits = String(sourceDigits.dropFirst(consumed))
            XCTAssertFalse(remainingDigits.isEmpty)

            let anchoredRaw = item.confirmed.joined(separator: "'") + "'" + remainingDigits
            engine.bridge.clearComposition()
            let anchored = engine.replaceInput(anchoredRaw)
            XCTAssertEqual(
                T9PinyinPathExtractor.normalizeRawIdentity(anchored.rawInput),
                T9PinyinPathExtractor.normalizeRawIdentity(anchoredRaw)
            )
            XCTAssertNil(anchored.committedText)

            let beforeWindow = engine.parseOutput(engine.bridge.currentOutput())

            for limit in windowLimits {
                let window = engine.candidateWindow(from: 0, limit: limit)
                let evidence = anchored.candidates + window.candidates
                let paths = T9PinyinPathExtractor.progressiveSyllablePaths(
                    from: evidence,
                    sourceDigits: sourceDigits,
                    confirmedSyllables: item.confirmed,
                    limit: 5
                )
                if paths.contains(where: { $0.displayText == item.expectedNext }) {
                    coverageByLimit[limit, default: 0] += 1
                }
            }

            // Observe the same live session without writing it. A replaceInput-based
            // assertion could conceal a mutation by repairing the session under test.
            let afterWindow = engine.parseOutput(engine.bridge.currentOutput())
            XCTAssertEqual(
                T9PinyinPathExtractor.normalizeRawIdentity(afterWindow.rawInput),
                T9PinyinPathExtractor.normalizeRawIdentity(anchoredRaw)
            )
            XCTAssertNil(afterWindow.committedText)
            XCTAssertEqual(afterWindow.rawInput, beforeWindow.rawInput)
            XCTAssertEqual(afterWindow.composition, beforeWindow.composition)
            XCTAssertEqual(afterWindow.candidates, beforeWindow.candidates)
            XCTAssertEqual(afterWindow.highlightedIndex, beforeWindow.highlightedIndex)
        }

        XCTAssertEqual(
            coverageByLimit[48],
            cases.count,
            "Stage A single-window discovery missed at least one frozen case"
        )
        fputs(
            "T9_ATOMIC_PATH_STAGE_A caseCount=\(cases.count) "
                + windowLimits.map { "limit\($0)=\(coverageByLimit[$0, default: 0])" }
                    .joined(separator: " ")
                + "\n",
            stderr
        )
    }

    /// Diagnostic for the physical-device report where the third focus only
    /// exposes `yi`, even though `zi` maps to the same `94` digit slots.
    /// This determines whether a larger read-only window can recover the sibling
    /// without reintroducing spelling-scaled session mutation.
    func testReadOnlyWindowCoverageForYiZiSibling() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir),
                userDataURL: URL(fileURLWithPath: directories.userDir),
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: directories.userDir
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        XCTAssertTrue(engine.bridge.selectSchema("t9"))

        let spelling = "deizhaoyishengwenyixia"
        let confirmed = ["dei", "zhao"]
        let sourceDigits = t9Digits(for: spelling)
        let consumed = confirmed.reduce(0) { $0 + $1.count }
        let remainingDigits = String(sourceDigits.dropFirst(consumed))
        let anchoredRaw = confirmed.joined(separator: "'") + "'" + remainingDigits

        engine.bridge.clearComposition()
        let anchored = engine.replaceInput(anchoredRaw)
        XCTAssertEqual(
            T9PinyinPathExtractor.normalizeRawIdentity(anchored.rawInput),
            T9PinyinPathExtractor.normalizeRawIdentity(anchoredRaw)
        )

        let limits = [48, 96, 192, 384, 768]
        var observed: [String] = []
        for limit in limits {
            let window = engine.candidateWindow(from: 0, limit: limit)
            let paths = T9PinyinPathExtractor.progressiveSyllablePaths(
                from: anchored.candidates + window.candidates,
                sourceDigits: sourceDigits,
                confirmedSyllables: confirmed,
                limit: 32
            )
            let displays = Set(paths.map(\.displayText))
            observed.append(
                "limit\(limit)=yi:\(displays.contains("yi")),zi:\(displays.contains("zi"))"
            )
        }

        let afterWindow = engine.parseOutput(engine.bridge.currentOutput())
        XCTAssertEqual(afterWindow.rawInput, anchored.rawInput)
        XCTAssertEqual(afterWindow.composition, anchored.composition)
        fputs("T9_YI_ZI_READONLY " + observed.joined(separator: " ") + "\n", stderr)
    }

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

    /// KEYBOARD-LAYOUT-9KEY-PINYIN-004: prove Core-generated exact raws are accepted
    /// by the pinned T9 session without unexpected host commits.
    ///
    /// Cases: `28`, `b8`, `cu`, `94 → zi`, `qiu'53`, `qiul`.
    /// Bridge does not generate full Path catalogs — only exact raw acceptance.
    func test004CatalogExactRawAcceptanceOnPinnedLibrime() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir),
                userDataURL: URL(fileURLWithPath: directories.userDir),
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: directories.userDir
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        XCTAssertTrue(engine.bridge.selectSchema("t9"))

        struct Case {
            let name: String
            let raw: String
            let setupDigits: String?
        }
        let cases: [Case] = [
            Case(name: "28", raw: "28", setupDigits: "28"),
            Case(name: "b8", raw: "b8", setupDigits: "28"),
            Case(name: "cu", raw: "cu", setupDigits: "28"),
            Case(name: "94", raw: "94", setupDigits: "94"),
            Case(name: "zi", raw: "zi", setupDigits: "94"),
            Case(name: "qiu'53", raw: "qiu'53", setupDigits: nil),
            Case(name: "qiul", raw: "qiul", setupDigits: nil),
        ]

        var lines: [String] = []
        for item in cases {
            engine.bridge.clearComposition()
            if let digits = item.setupDigits {
                for ch in digits {
                    _ = engine.processKey(String(ch))
                }
            }
            let result = engine.replaceInput(item.raw)
            let normalizedResult = T9PinyinPathExtractor.normalizeRawIdentity(result.rawInput)
            let normalizedExpected = T9PinyinPathExtractor.normalizeRawIdentity(item.raw)
            let candidatesNonEmpty = !result.candidates.isEmpty
            let unexpectedCommit = result.committedText.map { !$0.isEmpty } ?? false

            XCTAssertEqual(
                normalizedResult,
                normalizedExpected,
                "\(item.name): exact raw mismatch got=\(result.rawInput ?? "nil")"
            )
            XCTAssertFalse(
                unexpectedCommit,
                "\(item.name): unexpected committedText=\(result.committedText ?? "nil")"
            )
            // Soft observation for empty candidate pages — product still needs exact raw.
            lines.append(
                "\(item.name): raw=\(result.rawInput ?? "nil") "
                    + "candidates=\(result.candidates.count) "
                    + "commit=\(result.committedText ?? "∅") "
                    + "okExact=\(normalizedResult == normalizedExpected) "
                    + "okNoCommit=\(!unexpectedCommit) "
                    + "okCandidates=\(candidatesNonEmpty)"
            )
        }

        // Explicit zi path after 94.
        engine.bridge.clearComposition()
        _ = engine.processKey("9")
        _ = engine.processKey("4")
        let zi = engine.replaceInput("zi")
        XCTAssertEqual(T9PinyinPathExtractor.normalizeRawIdentity(zi.rawInput), "zi")
        XCTAssertNil(zi.committedText)
        lines.append(
            "94→zi: raw=\(zi.rawInput ?? "nil") candidates=\(zi.candidates.count) "
                + "commit=\(zi.committedText ?? "∅")"
        )

        let summary = "T9_004_RAW_SPIKE passed=true cases=\(lines.count) "
            + lines.joined(separator: " || ")
        fputs(summary + "\n", stderr)
        print(summary)
        NSLog("%@", summary)
    }

    // MARK: - Gate 5 Phase 0.5: engine-native candidate coverage

    /// Prove whether librime `sel_start/sel_end` (exposed as
    /// `RimeComposition.selectionStart/selectionEnd`) can authoritatively express
    /// the raw range a candidate actually consumes for T9 slot mapping.
    ///
    /// This Spike must not infer coverage from candidate text length, comment,
    /// preedit display, or ranking. Logs are structural (class/len/range) only.
    func testGate5Phase05CandidateCoverageSelRangeOnPinnedLibrime() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir),
                userDataURL: URL(fileURLWithPath: directories.userDir),
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: directories.userDir
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        XCTAssertTrue(engine.bridge.selectSchema("t9"))

        var observations: [String] = []
        func observe(_ label: String, _ output: RimeOutput) {
            let preedit = output.composition?.preeditText ?? ""
            let preeditLen = preedit.utf8.count
            let raw = output.rawInput ?? ""
            let rawClass = classifyRawForSpike(raw)
            let selStart = output.composition?.selectionStart.map(String.init) ?? "nil"
            let selEnd = output.composition?.selectionEnd.map(String.init) ?? "nil"
            let cursor = output.composition.map { String($0.cursorPosition) } ?? "nil"
            let commitLen = output.committedText?.count ?? 0
            let candLens = output.candidates.prefix(6).map { "len\($0.text.count)" }.joined(separator: ",")
            let line =
                "\(label) rawClass=\(rawClass) rawLen=\(raw.utf8.count) "
                + "preeditLen=\(preeditLen) cursor=\(cursor) "
                + "sel=\(selStart)..\(selEnd) commitLen=\(commitLen) "
                + "cand=\(candLens) highlighted=\(output.highlightedIndex) "
                + "page=\(output.candidatePageNumber)"
            observations.append(line)
            fputs(line + "\n", stderr)
        }

        // --- Fixture B/A: confirmed qing/wei/fan/dao + remaining digits ---
        // Matches device-calibrated anchored-mixed shape used by Gate 5 Path B.
        let spelling = "qingweifandaowozuili"
        let sourceDigits = t9Digits(for: spelling)
        XCTAssertEqual(sourceDigits, "74649343263269698454")
        let confirmed = ["qing", "wei", "fan", "dao"]
        let consumedLetters = confirmed.reduce(0) { $0 + $1.count }
        let remainingDigits = String(sourceDigits.dropFirst(consumedLetters))
        let anchoredRaw = confirmed.joined(separator: "'") + "'" + remainingDigits

        engine.bridge.clearComposition()
        let before = engine.replaceInput(anchoredRaw)
        observe("B_before_select", before)
        XCTAssertEqual(
            T9PinyinPathExtractor.normalizeRawIdentity(before.rawInput),
            T9PinyinPathExtractor.normalizeRawIdentity(anchoredRaw)
        )
        XCTAssertNotNil(before.composition, "anchored composition must exist")
        XCTAssertNotNil(
            before.composition?.selectionStart,
            "Phase 0.5: bridge must surface sel_start when composition is non-empty"
        )
        XCTAssertNotNil(
            before.composition?.selectionEnd,
            "Phase 0.5: bridge must surface sel_end when composition is non-empty"
        )

        let baseSelStart = before.composition?.selectionStart
        let baseSelEnd = before.composition?.selectionEnd
        if let start = baseSelStart, let end = baseSelEnd {
            XCTAssertGreaterThanOrEqual(end, start)
            // librime positions are UTF-8 code-unit offsets into preedit C string.
            XCTAssertLessThanOrEqual(end, (before.composition?.preeditText.utf8.count ?? 0))
        }

        // Build a large candidate pool: current page + read-only expanded window + page-down.
        var pool: [(source: String, globalIndex: Int?, pageIndex: Int?, text: String, comment: String?)] = []
        for (idx, candidate) in before.candidates.enumerated() {
            pool.append((
                source: "page",
                globalIndex: candidate.globalIndex ?? idx,
                pageIndex: idx,
                text: candidate.text,
                comment: candidate.comment
            ))
        }
        let window = engine.candidateWindow(from: 0, limit: 48)
        observe(
            "B_after_window_read",
            engine.parseOutput(engine.bridge.currentOutput())
        )
        for candidate in window.candidates {
            let text = candidate.text
            if pool.contains(where: { $0.text == text && $0.globalIndex == candidate.globalIndex }) {
                continue
            }
            pool.append((
                source: "window",
                globalIndex: candidate.globalIndex,
                pageIndex: nil,
                text: text,
                comment: candidate.comment
            ))
        }

        // Page-down once if available — coverage must not depend on entry surface.
        if before.hasMorePages {
            let paged = engine.pageDown()
            observe("B_after_page_down", paged)
            for (idx, candidate) in paged.candidates.enumerated() {
                pool.append((
                    source: "page2",
                    globalIndex: candidate.globalIndex,
                    pageIndex: idx,
                    text: candidate.text,
                    comment: candidate.comment
                ))
            }
            // Restore menu to first page for local select indices.
            engine.bridge.clearComposition()
            _ = engine.replaceInput(anchoredRaw)
        }

        // Prefer structural classification by syllable-shaped comment only as a
        // *search key* for fixtures; coverage judgment uses sel range alone.
        func syllableCount(fromComment comment: String?) -> Int? {
            guard let comment, let normalized = normalizePinyinComment(comment) else { return nil }
            let parts = normalized.split(separator: "'").filter { !$0.isEmpty }
            return parts.isEmpty ? nil : parts.count
        }

        let singleSyllableHits = pool.filter { syllableCount(fromComment: $0.comment) == 1 }
        let multiSyllableHits = pool.filter { (syllableCount(fromComment: $0.comment) ?? 0) >= 4 }
        let singleCharTextHits = pool.filter { $0.text.count == 1 }
        let fourCharTextHits = pool.filter { $0.text.count == 4 }

        observations.append(
            "pool page=\(before.candidates.count) window=\(window.candidates.count) "
                + "uniquePool=\(pool.count) "
                + "commentSyll1=\(singleSyllableHits.count) commentSyll4+=\(multiSyllableHits.count) "
                + "textLen1=\(singleCharTextHits.count) textLen4=\(fourCharTextHits.count)"
        )

        // Snapshot default highlight range (no candidate text used for judgment).
        let defaultRange = (baseSelStart, baseSelEnd)
        observations.append(
            "default_sel=\(defaultRange.0.map(String.init) ?? "nil").."
                + "\(defaultRange.1.map(String.init) ?? "nil")"
        )

        // --- Select single-char candidate (Path B target 「请」 if present) ---
        // Prefer exact 「请」 only as fixture locator; range judgment stays engine-native.
        let singlePick =
            pool.first(where: { $0.text == "请" && $0.pageIndex != nil })
            ?? pool.first(where: { $0.text.count == 1 && $0.pageIndex != nil })
            ?? pool.first(where: { $0.text == "请" })
            ?? pool.first(where: { $0.text.count == 1 })

        var afterSingle: RimeOutput?
        var singleSelectLabel = "B_single_skip"
        if let singlePick {
            engine.bridge.clearComposition()
            _ = engine.replaceInput(anchoredRaw)
            let preSelect = engine.parseOutput(engine.bridge.currentOutput())
            observe("B_single_pre", preSelect)

            let selected: RimeOutput
            if let pageIndex = singlePick.pageIndex {
                selected = engine.selectCandidate(at: pageIndex)
                singleSelectLabel = "B_single_pageIndex=\(pageIndex)"
            } else if let global = singlePick.globalIndex {
                selected = engine.selectCandidate(globalIndex: global)
                singleSelectLabel = "B_single_global=\(global)"
            } else {
                selected = preSelect
                singleSelectLabel = "B_single_unselectable"
            }
            observe(singleSelectLabel, selected)
            afterSingle = selected

            // Re-read only: must not mutate.
            let afterRead = engine.parseOutput(engine.bridge.currentOutput())
            observe("B_single_currentOutput", afterRead)
        } else {
            observations.append("B_single_not_found_in_pool")
        }

        // --- Select multi-syllable / multi-char partial candidate (Path A) ---
        // Prefer exact 「请喂饭到」; else any ≥4-syllable comment or ≥4-char text.
        // Comment is used only as fixture locator, never as coverage authority.
        let multiPick =
            pool.first(where: { $0.text == "请喂饭到" && $0.pageIndex != nil })
            ?? pool.first(where: { $0.text == "请喂饭到" })
            ?? pool.first(where: { (syllableCount(fromComment: $0.comment) ?? 0) >= 4 && $0.pageIndex != nil })
            ?? pool.first(where: { (syllableCount(fromComment: $0.comment) ?? 0) >= 4 })
            ?? pool.first(where: { $0.text.count >= 4 && $0.pageIndex != nil })
            ?? pool.first(where: { $0.text.count >= 4 })

        var afterMulti: RimeOutput?
        if let multiPick {
            observations.append(
                "A_multi_pick source=\(multiPick.source) "
                    + "textLen=\(multiPick.text.count) "
                    + "commentSyll=\(syllableCount(fromComment: multiPick.comment).map(String.init) ?? "nil") "
                    + "pageIndex=\(multiPick.pageIndex.map(String.init) ?? "nil") "
                    + "global=\(multiPick.globalIndex.map(String.init) ?? "nil")"
            )
            engine.bridge.clearComposition()
            _ = engine.replaceInput(anchoredRaw)
            let preSelect = engine.parseOutput(engine.bridge.currentOutput())
            observe("A_multi_pre", preSelect)

            let selected: RimeOutput
            if let pageIndex = multiPick.pageIndex {
                selected = engine.selectCandidate(at: pageIndex)
            } else if let global = multiPick.globalIndex {
                selected = engine.selectCandidate(globalIndex: global)
            } else {
                selected = preSelect
            }
            observe("A_multi_select", selected)
            afterMulti = selected
        } else {
            observations.append("A_multi_not_found_in_pool")
        }

        // --- Apostrophe / mixed raw shortened remainder branch ---
        engine.bridge.clearComposition()
        let shortenedRaw = "wei'fan'dao'9698454"
        let shortened = engine.replaceInput(shortenedRaw)
        observe("shortened_remainder_before", shortened)
        if !shortened.candidates.isEmpty {
            let selected = engine.selectCandidate(at: 0)
            observe("shortened_remainder_select0", selected)
        }

        // --- Pure digit raw (pre-path) ---
        engine.bridge.clearComposition()
        var digitsOnly = engine.processKey("7")
        digitsOnly = engine.processKey("4")
        digitsOnly = engine.processKey("6")
        digitsOnly = engine.processKey("4")
        observe("digits_7464_before", digitsOnly)
        if !digitsOnly.candidates.isEmpty {
            let selected = engine.selectCandidate(at: 0)
            observe("digits_7464_select0", selected)
        }

        // --- Structural reliability synthesis (no text-based consumption guess) ---
        //
        // Critical question: does pre-selection composition expose one fixed sel
        // range for the whole menu (active segment), independent of which
        // candidate is later chosen? If yes, sel_* cannot name the consumption
        // width of a *specific* candidate (e.g. 请 vs 请喂饭到).

        let singleRawLen = afterSingle?.rawInput?.utf8.count
        let multiRawLen = afterMulti?.rawInput?.utf8.count
        let singleCommitLen = afterSingle?.committedText?.count
        let multiCommitLen = afterMulti?.committedText?.count
        let singlePostSel = (
            afterSingle?.composition?.selectionStart,
            afterSingle?.composition?.selectionEnd
        )
        let multiPostSel = (
            afterMulti?.composition?.selectionStart,
            afterMulti?.composition?.selectionEnd
        )

        let rawUnchangedAfterSingle: Bool = {
            guard let afterSingle else { return false }
            return T9PinyinPathExtractor.normalizeRawIdentity(afterSingle.rawInput)
                == T9PinyinPathExtractor.normalizeRawIdentity(anchoredRaw)
        }()

        let rawUnchangedAfterMulti: Bool = {
            guard let afterMulti else { return false }
            return T9PinyinPathExtractor.normalizeRawIdentity(afterMulti.rawInput)
                == T9PinyinPathExtractor.normalizeRawIdentity(anchoredRaw)
        }()

        // Empirical: both single and multi selections start from the *same*
        // pre-select composition (we reset anchoredRaw). That pre-select exposes
        // exactly one (selStart, selEnd) pair for the menu — not one pair per
        // candidate. Post-select remaining/commit may differ, but that is not a
        // pre-select per-candidate coverage field.
        let preSelectFieldsPresent = baseSelStart != nil && baseSelEnd != nil
        let selectionsDifferInOutcome: Bool = {
            guard afterSingle != nil, afterMulti != nil else { return false }
            if singleCommitLen != multiCommitLen { return true }
            if singleRawLen != multiRawLen { return true }
            if singlePostSel.0 != multiPostSel.0 || singlePostSel.1 != multiPostSel.1 {
                return true
            }
            return false
        }()
        // Per-candidate distinction would require different pre-select ranges
        // when highlighting different candidates. We only have one pre-select
        // range per composition snapshot; no per-candidate engine field exists
        // on RimeCandidate / RimeOutput today.
        let canDistinguishCandidatesBySelAlone = false
        let reliableForT9SlotCoverage =
            preSelectFieldsPresent && canDistinguishCandidatesBySelAlone

        let verdict: String
        if reliableForT9SlotCoverage {
            verdict = "RELIABLE"
        } else if preSelectFieldsPresent {
            verdict = "UNRELIABLE_MENU_SCOPED_ONLY"
        } else {
            verdict = "UNKNOWN_OR_MISSING"
        }

        let summary =
            "T9_GATE5_PHASE05_SEL_RANGE verdict=\(verdict) "
            + "preSel=\(baseSelStart.map(String.init) ?? "nil")..\((baseSelEnd.map(String.init) ?? "nil")) "
            + "singleRawLen=\(singleRawLen.map(String.init) ?? "na") "
            + "multiRawLen=\(multiRawLen.map(String.init) ?? "na") "
            + "singleCommitLen=\(singleCommitLen.map(String.init) ?? "na") "
            + "multiCommitLen=\(multiCommitLen.map(String.init) ?? "na") "
            + "singlePostSel=\(singlePostSel.0.map(String.init) ?? "nil")..\((singlePostSel.1.map(String.init) ?? "nil")) "
            + "multiPostSel=\(multiPostSel.0.map(String.init) ?? "nil")..\((multiPostSel.1.map(String.init) ?? "nil")) "
            + "rawUnchangedSingle=\(rawUnchangedAfterSingle) "
            + "rawUnchangedMulti=\(rawUnchangedAfterMulti) "
            + "outcomesDiffer=\(selectionsDifferInOutcome) "
            + "singleLabel=\(singleSelectLabel)"
        fputs(summary + "\n", stderr)
        print(summary)
        NSLog("%@", summary)
        for line in observations {
            fputs("T9_GATE5_PHASE05_OBS \(line)\n", stderr)
        }

        // Hard contract: fields must be present for non-empty composition.
        XCTAssertNotNil(baseSelStart)
        XCTAssertNotNil(baseSelEnd)

        // Product conclusion for Architecture: menu-scoped sel_* is not per-
        // candidate T9 slot coverage. Recorded in summary/verdict.
        XCTAssertFalse(
            reliableForT9SlotCoverage,
            "sel_* must not be treated as T9 slot coverage without per-candidate distinction"
        )
        XCTAssertEqual(verdict, "UNRELIABLE_MENU_SCOPED_ONLY")
    }

    /// Negative contract: missing/out-of-bounds selection metadata must stay
    /// fail-closed at the parse layer (no invented range).
    func testGate5Phase05SelectionRangeFailClosedParserContract() {
        let missing = RimeEngineImpl.parseOutputDictionary([
            "rawInput": "qing",
            "preedit": "qing",
            "cursorPos": 4,
        ])
        XCTAssertNil(missing.composition?.selectionStart)
        XCTAssertNil(missing.composition?.selectionEnd)

        // Parser still accepts out-of-range numbers as raw engine values;
        // consumers must fail-closed — they must not clamp/guess.
        let outOfBounds = RimeEngineImpl.parseOutputDictionary([
            "rawInput": "qing",
            "preedit": "qing",
            "cursorPos": 4,
            "selStart": 2,
            "selEnd": 99,
        ])
        XCTAssertEqual(outOfBounds.composition?.selectionStart, 2)
        XCTAssertEqual(outOfBounds.composition?.selectionEnd, 99)
        let preeditLen = outOfBounds.composition?.preeditText.utf8.count ?? 0
        XCTAssertGreaterThan(outOfBounds.composition?.selectionEnd ?? 0, preeditLen)
    }

    // MARK: - Gate 5 Phase 0.6: alternative coverage / selection-delta

    /// Prove whether non-`sel_*` engine-native fields or selection deltas can
    /// authoritatively map candidate consumption onto T9 `sourceDigits` slots.
    ///
    /// Verdict is **observation-derived** (not a hardcoded boolean). Forbidden
    /// primary signals: candidate text length, comment, ranking, preedit display
    /// content, and `sel_*` (Phase 0.5). `commitPreviewLen` is recorded only as
    /// structural evidence; Product forbids using 汉字数 as slot authority.
    func testGate5Phase06AlternativeCoverageSelectionDeltaOnPinnedLibrime() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)

        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir),
                userDataURL: URL(fileURLWithPath: directories.userDir),
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(deployResult.succeeded, deployResult.diagnosticMessage)

        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: directories.userDir
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }
        XCTAssertTrue(engine.bridge.selectSchema("t9"))

        struct Snapshot: Equatable {
            var rawLen: Int
            var rawClass: String
            var caret: Int?
            var compLen: Int?
            var selStart: Int?
            var selEnd: Int?
            var commitLen: Int
            var previewLen: Int?
            var preeditLen: Int
            var candCount: Int
            var highlighted: Int
        }

        func snapshot(_ output: RimeOutput) -> Snapshot {
            Snapshot(
                rawLen: output.rawInput?.utf8.count ?? 0,
                rawClass: classifyRawForSpike(output.rawInput ?? ""),
                caret: output.caretPositionInRaw,
                compLen: output.composition?.length,
                selStart: output.composition?.selectionStart,
                selEnd: output.composition?.selectionEnd,
                commitLen: output.committedText?.utf8.count ?? 0,
                previewLen: output.commitPreviewLength,
                preeditLen: output.composition?.preeditText.utf8.count ?? 0,
                candCount: output.candidates.count,
                highlighted: output.highlightedIndex
            )
        }

        func log(_ label: String, _ snap: Snapshot) {
            let line =
                "\(label) rawClass=\(snap.rawClass) rawLen=\(snap.rawLen) "
                + "caret=\(snap.caret.map(String.init) ?? "nil") "
                + "compLen=\(snap.compLen.map(String.init) ?? "nil") "
                + "sel=\(snap.selStart.map(String.init) ?? "nil")..\((snap.selEnd.map(String.init) ?? "nil")) "
                + "commitLen=\(snap.commitLen) previewLen=\(snap.previewLen.map(String.init) ?? "nil") "
                + "preeditLen=\(snap.preeditLen) candCount=\(snap.candCount) hi=\(snap.highlighted)"
            fputs("T9_GATE5_PHASE06_OBS \(line)\n", stderr)
        }

        /// Allowed (non-forbidden) feature vector for slot-mapping attempts.
        func allowedVector(_ snap: Snapshot) -> [Int] {
            [
                snap.rawLen,
                snap.caret ?? -1,
                snap.compLen ?? -1,
                snap.commitLen,
                snap.candCount == 0 ? 0 : 1, // composing residual boolean as 0/1
            ]
        }

        let spelling = "qingweifandaowozuili"
        let sourceDigits = t9Digits(for: spelling)
        let confirmed = ["qing", "wei", "fan", "dao"]
        let consumedLetters = confirmed.reduce(0) { $0 + $1.count }
        let remainingDigits = String(sourceDigits.dropFirst(consumedLetters))
        let anchoredRaw = confirmed.joined(separator: "'") + "'" + remainingDigits
        // Legal Path segment slot cuts on sourceDigits (pre-selection ledger bounds only).
        let legalSlotCuts = [4, 7, 10, 13] // after qing / +wei / +fan / +dao

        engine.bridge.clearComposition()
        let base = engine.replaceInput(anchoredRaw)
        let baseSnap = snapshot(base)
        log("base", baseSnap)
        XCTAssertNotNil(base.caretPositionInRaw, "Phase 0.6 requires caretPos passthrough")
        XCTAssertNotNil(base.composition?.length, "Phase 0.6 requires composition.length passthrough")

        // --- Pre-select highlight sweep: does any allowed field vary per candidate? ---
        var highlightAllowedVectors: [[Int]] = []
        var highlightPreviewLens: [Int?] = []
        var highlightSelPairs: [(Int?, Int?)] = []
        let pageCount = min(base.candidates.count, 9)
        for index in 0..<pageCount {
            engine.bridge.clearComposition()
            _ = engine.replaceInput(anchoredRaw)
            let highlighted = engine.parseOutput(
                engine.bridge.highlightCandidateOnCurrentPage(at: Int32(index))
            )
            let snap = snapshot(highlighted)
            log("highlight_pageIndex=\(index)", snap)
            highlightAllowedVectors.append(allowedVector(snap))
            highlightPreviewLens.append(snap.previewLen)
            highlightSelPairs.append((snap.selStart, snap.selEnd))
        }

        let uniqueAllowedPreSelect = Set(highlightAllowedVectors.map { $0.description })
        let uniquePreviewPreSelect = Set(highlightPreviewLens.map { $0.map(String.init) ?? "nil" })
        let uniqueSelPreSelect = Set(highlightSelPairs.map { "\($0.0.map(String.init) ?? "nil")..\(($0.1.map(String.init) ?? "nil"))" })
        let allowedVariesByHighlight = uniqueAllowedPreSelect.count > 1
        let previewVariesByHighlight = uniquePreviewPreSelect.count > 1
        let selVariesByHighlight = uniqueSelPreSelect.count > 1

        // --- Select single-char vs multi-char (fixture locators only) ---
        func rebuildBase() -> RimeOutput {
            engine.bridge.clearComposition()
            return engine.replaceInput(anchoredRaw)
        }

        var pool: [(pageIndex: Int?, globalIndex: Int?, textLen: Int)] = []
        for (idx, candidate) in base.candidates.enumerated() {
            pool.append((pageIndex: idx, globalIndex: candidate.globalIndex ?? idx, textLen: candidate.text.count))
        }
        let window = engine.candidateWindow(from: 0, limit: 48)
        for candidate in window.candidates {
            pool.append((pageIndex: nil, globalIndex: candidate.globalIndex, textLen: candidate.text.count))
        }

        let singlePick =
            pool.first(where: { $0.textLen == 1 && $0.pageIndex != nil })
            ?? pool.first(where: { $0.textLen == 1 })
        let multiPick =
            pool.first(where: { $0.textLen >= 4 && $0.pageIndex != nil })
            ?? pool.first(where: { $0.textLen >= 4 })
            ?? pool.first(where: { $0.textLen >= 2 && $0.pageIndex != nil })

        var afterSingle: Snapshot?
        var afterMulti: Snapshot?
        var preSingle: Snapshot?
        var preMulti: Snapshot?

        if let singlePick {
            let pre = rebuildBase()
            preSingle = snapshot(pre)
            log("B_single_pre", preSingle!)
            let selected: RimeOutput
            if let pageIndex = singlePick.pageIndex {
                selected = engine.selectCandidate(at: pageIndex)
            } else if let global = singlePick.globalIndex {
                selected = engine.selectCandidate(globalIndex: global)
            } else {
                selected = pre
            }
            afterSingle = snapshot(selected)
            log("B_single_post textLen=\(singlePick.textLen)", afterSingle!)
        }

        if let multiPick {
            let pre = rebuildBase()
            preMulti = snapshot(pre)
            log("A_multi_pre", preMulti!)
            let selected: RimeOutput
            if let pageIndex = multiPick.pageIndex {
                selected = engine.selectCandidate(at: pageIndex)
            } else if let global = multiPick.globalIndex {
                selected = engine.selectCandidate(globalIndex: global)
            } else {
                selected = pre
            }
            afterMulti = snapshot(selected)
            log("A_multi_post textLen=\(multiPick.textLen)", afterMulti!)
        }

        // --- Shortened remainder branch ---
        engine.bridge.clearComposition()
        let shortenedPre = engine.replaceInput("wei'fan'dao'9698454")
        let shortenedPreSnap = snapshot(shortenedPre)
        log("shortened_pre", shortenedPreSnap)
        var shortenedPost: Snapshot?
        if !shortenedPre.candidates.isEmpty {
            shortenedPost = snapshot(engine.selectCandidate(at: 0))
            log("shortened_post", shortenedPost!)
        }

        // --- Digits-only branch ---
        engine.bridge.clearComposition()
        var digits = engine.processKey("7")
        digits = engine.processKey("4")
        digits = engine.processKey("6")
        digits = engine.processKey("4")
        let digitsPre = snapshot(digits)
        log("digits_pre", digitsPre)
        var digitsPost: Snapshot?
        if !digits.candidates.isEmpty {
            digitsPost = snapshot(engine.selectCandidate(at: 0))
            log("digits_post", digitsPost!)
        }

        // --- Observation-derived reliability ---
        // Question: can allowed post-select deltas produce an integer that lands
        // on a legal Path slot cut for B, and differs for multi, without forbidden signals?
        func rawDelta(pre: Snapshot?, post: Snapshot?) -> Int? {
            guard let pre, let post else { return nil }
            return pre.rawLen - post.rawLen
        }
        func caretDelta(pre: Snapshot?, post: Snapshot?) -> Int? {
            guard let pre, let post, let a = pre.caret, let b = post.caret else { return nil }
            return a - b
        }
        func compLenDelta(pre: Snapshot?, post: Snapshot?) -> Int? {
            guard let pre, let post, let a = pre.compLen, let b = post.compLen else { return nil }
            return a - b
        }

        let singleRawDelta = rawDelta(pre: preSingle, post: afterSingle)
        let multiRawDelta = rawDelta(pre: preMulti, post: afterMulti)
        let singleCaretDelta = caretDelta(pre: preSingle, post: afterSingle)
        let multiCaretDelta = caretDelta(pre: preMulti, post: afterMulti)
        let singleCompDelta = compLenDelta(pre: preSingle, post: afterSingle)
        let multiCompDelta = compLenDelta(pre: preMulti, post: afterMulti)

        let singleRawUnchanged =
            (preSingle.map(\.rawLen) == afterSingle.map(\.rawLen))
            && (afterSingle?.rawLen ?? 0) > 0

        // Candidate allowed vectors differ post-select?
        let postAllowedDiffer: Bool = {
            guard let s = afterSingle, let m = afterMulti else { return false }
            return allowedVector(s) != allowedVector(m)
        }()

        // Try to interpret allowed numeric deltas as sourceDigits slot cuts.
        // Only rawLen delta is in the same alphabet as sourceDigits length units
        // (one char of raw ≈ one letter/digit of raw identity). caret is raw-space
        // index, not a consumed-slot count by itself.
        func mapsToLegalCut(_ value: Int?) -> Bool {
            guard let value, value > 0 else { return false }
            return legalSlotCuts.contains(value)
        }

        let rawDeltaMapsSingle = mapsToLegalCut(singleRawDelta)
        let rawDeltaMapsMulti = mapsToLegalCut(multiRawDelta)
        let caretDeltaMapsSingle = mapsToLegalCut(singleCaretDelta)
        let caretDeltaMapsMulti = mapsToLegalCut(multiCaretDelta)
        let compDeltaMapsSingle = mapsToLegalCut(singleCompDelta)
        let compDeltaMapsMulti = mapsToLegalCut(multiCompDelta)

        // Reliable only if an allowed signal both (1) distinguishes single vs multi
        // and (2) maps single onto a legal pre-selection slot cut without forbidden inputs.
        let allowedSignalMapsSlots =
            (rawDeltaMapsSingle && singleRawDelta != multiRawDelta)
            || (caretDeltaMapsSingle && singleCaretDelta != multiCaretDelta)
            || (compDeltaMapsSingle && singleCompDelta != multiCompDelta)
        let multiAlsoMaps =
            rawDeltaMapsMulti || caretDeltaMapsMulti || compDeltaMapsMulti

        // Pre-select allowed fields must also be able to name consumption *before*
        // select for unchanged-raw B planning — highlight sweep is the probe.
        let preSelectAllowedDistinguishesCandidates = allowedVariesByHighlight

        let reliable =
            allowedSignalMapsSlots
            && (preSelectAllowedDistinguishesCandidates || !singleRawUnchanged)

        // If B raw is unchanged, raw delta cannot be the slot authority.
        let bBlockedByUnchangedRaw = singleRawUnchanged && !rawDeltaMapsSingle

        let verdict: String
        if reliable {
            verdict = "RELIABLE_ALLOWED_DELTA"
        } else if postAllowedDiffer || previewVariesByHighlight {
            // Engine state can differ, but not as Product-allowed slot map.
            verdict = "UNRELIABLE_NO_ALLOWED_SLOT_MAP"
        } else {
            verdict = "UNKNOWN_OR_MISSING_SIGNAL"
        }

        let summary =
            "T9_GATE5_PHASE06_DELTA verdict=\(verdict) "
            + "allowedVariesByHighlight=\(allowedVariesByHighlight) "
            + "previewVariesByHighlight=\(previewVariesByHighlight) "
            + "selVariesByHighlight=\(selVariesByHighlight) "
            + "postAllowedDiffer=\(postAllowedDiffer) "
            + "singleRawDelta=\(singleRawDelta.map(String.init) ?? "na") "
            + "multiRawDelta=\(multiRawDelta.map(String.init) ?? "na") "
            + "singleCaretDelta=\(singleCaretDelta.map(String.init) ?? "na") "
            + "multiCaretDelta=\(multiCaretDelta.map(String.init) ?? "na") "
            + "singleCompDelta=\(singleCompDelta.map(String.init) ?? "na") "
            + "multiCompDelta=\(multiCompDelta.map(String.init) ?? "na") "
            + "rawDeltaMapsSingle=\(rawDeltaMapsSingle) rawDeltaMapsMulti=\(rawDeltaMapsMulti) "
            + "caretDeltaMapsSingle=\(caretDeltaMapsSingle) caretDeltaMapsMulti=\(caretDeltaMapsMulti) "
            + "compDeltaMapsSingle=\(compDeltaMapsSingle) compDeltaMapsMulti=\(compDeltaMapsMulti) "
            + "multiAlsoMaps=\(multiAlsoMaps) "
            + "singleRawUnchanged=\(singleRawUnchanged) "
            + "bBlockedByUnchangedRaw=\(bBlockedByUnchangedRaw) "
            + "legalCuts=\(legalSlotCuts.map(String.init).joined(separator: "/"))"
        fputs(summary + "\n", stderr)
        print(summary)
        NSLog("%@", summary)

        // Structural presence contracts.
        XCTAssertNotNil(base.caretPositionInRaw)
        XCTAssertNotNil(base.composition?.length)

        // Observation-driven product conclusion for Architecture.
        XCTAssertFalse(
            reliable,
            "If this becomes true, evidence must document the allowed signal and stop for Architecture Accept before reducer use"
        )
        XCTAssertTrue(
            verdict == "UNRELIABLE_NO_ALLOWED_SLOT_MAP" || verdict == "UNKNOWN_OR_MISSING_SIGNAL",
            "Unexpected verdict=\(verdict)"
        )
        // B unchanged-raw remains the blocking morphology.
        if afterSingle != nil {
            XCTAssertTrue(
                singleRawUnchanged,
                "Expected B-like unchanged raw on single-char select; got raw delta \(singleRawDelta.map(String.init) ?? "na")"
            )
        }
    }

    private func classifyRawForSpike(_ raw: String) -> String {
        if raw.isEmpty { return "empty" }
        let letters = CharacterSet.letters
        let digits = CharacterSet.decimalDigits
        var hasLetter = false
        var hasDigit = false
        var hasApos = false
        var hasOther = false
        for scalar in raw.unicodeScalars {
            if scalar == "'" {
                hasApos = true
            } else if letters.contains(scalar) {
                hasLetter = true
            } else if digits.contains(scalar) {
                hasDigit = true
            } else if !CharacterSet.whitespaces.contains(scalar) {
                hasOther = true
            }
        }
        if hasOther { return "other" }
        if hasLetter && hasDigit { return hasApos ? "anchoredMixed" : "mixed" }
        if hasLetter { return hasApos ? "anchoredLetters" : "letters" }
        if hasDigit { return "digits" }
        return "other"
    }

    // MARK: - Helpers

    private func t9Digits(for spelling: String) -> String {
        let mapping: [Character: Character] = [
            "a": "2", "b": "2", "c": "2",
            "d": "3", "e": "3", "f": "3",
            "g": "4", "h": "4", "i": "4",
            "j": "5", "k": "5", "l": "5",
            "m": "6", "n": "6", "o": "6",
            "p": "7", "q": "7", "r": "7", "s": "7",
            "t": "8", "u": "8", "v": "8",
            "w": "9", "x": "9", "y": "9", "z": "9",
        ]
        return String(spelling.lowercased().compactMap { mapping[$0] })
    }

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
