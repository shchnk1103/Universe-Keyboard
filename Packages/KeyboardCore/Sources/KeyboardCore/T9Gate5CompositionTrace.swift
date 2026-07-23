#if DEBUG
import Foundation

/// Phase 0 Gate 5 diagnostics: DEBUG-only and in-memory, with no host context.
///
/// Captures only redacted structural identity (class / length / shape / session hash)
/// for A/B/C root-cause pinning. It never persists raw pinyin or digit input and must
/// never run production identity repair logic.
/// Release builds compile this type out entirely.
@MainActor
enum T9Gate5CompositionTrace {
    static let maxBufferedEvents = 64

    /// DEBUG-only ring buffer. Gate 5 call sites already run on KeyboardController's
    /// MainActor, so the diagnostic buffer follows the same ownership boundary.
    private static var buffer: [String] = []

    /// Structural event kinds observed on the T9 composition path.
    enum Event: String {
        case pathSelect
        case digitAppend
        case deleteBackward
        case partialCommit
        case partialRestore
        case checkpointRestore
    }

    /// Append one redacted line. Never records host document text, raw composition
    /// tokens, or App Group payloads.
    static func record(
        event: Event,
        revision: UInt64,
        previousRaw: String?,
        resultRaw: String?,
        preedit: String?,
        remainingRaw: String?,
        sourceDigits: String?,
        confirmed: [String],
        focus: Int?,
        pathHead: [String],
        candidateHead: [String],
        note: String = ""
    ) {
        let line = [
            "GATE5_TRACE",
            "event=\(event.rawValue)",
            "rev=\(revision)",
            "prev={\(tokenSummary(previousRaw))}",
            "result={\(tokenSummary(resultRaw))}",
            "preedit={\(tokenSummary(preedit))}",
            "remaining={\(tokenSummary(remainingRaw))}",
            "source={\(tokenSummary(sourceDigits))}",
            "confCount=\(confirmed.count)",
            "confLens=\(confirmed.map(\.count).map(String.init).joined(separator: ","))",
            "confSig=\(sessionSignature(confirmed.joined(separator: "'")))",
            "focus=\(focus.map(String.init) ?? "nil")",
            "pathCount=\(pathHead.count)",
            "pathLens=\(pathHead.prefix(6).map(\.count).map(String.init).joined(separator: ","))",
            "pathSig=\(sessionSignature(pathHead.prefix(6).joined(separator: "'")))",
            "candidateLens=\(candidateHead.prefix(4).joined(separator: ","))",
            note.isEmpty ? "" : "note=\(note)",
        ]
        .filter { !$0.isEmpty }
        .joined(separator: " ")

        buffer.append(line)
        if buffer.count > maxBufferedEvents {
            buffer.removeFirst(buffer.count - maxBufferedEvents)
        }

        // Intentionally no Logger call: even a DEBUG App Group logger can persist
        // personal composition data. Device evidence is harvested explicitly from
        // this bounded in-memory buffer under debugger control.
    }

    /// Test / Console harvest of recent structural lines (no host text).
    static func snapshotLines() -> [String] {
        buffer
    }

    static func reset() {
        buffer.removeAll(keepingCapacity: false)
    }

    // MARK: - Sanitizers

    /// Structural summary that is useful for identity comparison without exposing
    /// the original token. `shape` is run-length encoded (`L4.S1.D2`, etc.) and
    /// `sig` is process-randomized by Swift's `Hasher`, so it only supports equality
    /// comparisons inside one debugger capture.
    static func tokenSummary(_ value: String?) -> String {
        guard let value else { return "class=none,len=0,shape=none,sig=none" }
        guard !value.isEmpty else { return "class=empty,len=0,shape=empty,sig=empty" }
        return "class=\(rawClass(value)),len=\(value.count),shape=\(tokenShape(value)),sig=\(sessionSignature(value))"
    }

    static func tokenShape(_ value: String) -> String {
        var runs: [(kind: Character, count: Int)] = []
        for character in value {
            let kind: Character
            if character.unicodeScalars.allSatisfy({ $0.isASCII && CharacterSet.letters.contains($0) }) {
                kind = "L"
            } else if character.unicodeScalars.allSatisfy({ $0.isASCII && CharacterSet.decimalDigits.contains($0) }) {
                kind = "D"
            } else if character == "'" {
                kind = "A"
            } else if character == " " {
                kind = "S"
            } else {
                kind = "X"
            }

            if runs.last?.kind == kind {
                runs[runs.count - 1].count += 1
            } else {
                runs.append((kind, 1))
            }
        }
        return runs.map { "\($0.kind)\($0.count)" }.joined(separator: ".")
    }

    static func sessionSignature(_ value: String) -> String {
        guard !value.isEmpty else { return "empty" }
        var hasher = Hasher()
        hasher.combine(value)
        return String(UInt(bitPattern: hasher.finalize()), radix: 16)
    }

    static func rawClass(_ raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return "empty" }
        let hasLetter = raw.unicodeScalars.contains {
            CharacterSet.letters.contains($0) && $0.isASCII
        }
        let hasDigit = raw.unicodeScalars.contains { CharacterSet.decimalDigits.contains($0) }
        let hasApos = raw.contains("'")
        if hasLetter && hasDigit && hasApos { return "anchoredMixed" }
        if hasLetter && hasDigit { return "mixed" }
        if hasLetter && hasApos { return "apostropheLetters" }
        if hasLetter { return "letters" }
        if hasDigit { return "digits" }
        return "other"
    }
}

extension KeyboardController {
    /// DEBUG-only structural snapshot for Gate 5 Phase 0 device / test capture.
    func gate5TraceComposition(
        event: T9Gate5CompositionTrace.Event,
        previousRaw: String? = nil,
        note: String = ""
    ) {
        let output = state.lastRimeOutput
        let pathState = state.t9PinyinPathState
        T9Gate5CompositionTrace.record(
            event: event,
            revision: state.compositionRevision,
            previousRaw: previousRaw,
            resultRaw: output?.rawInput,
            preedit: output?.composition?.preeditText,
            remainingRaw: state.partialCommit?.remainingRawInput,
            sourceDigits: pathState.segmentSourceDigits,
            confirmed: pathState.confirmedSegmentValues,
            focus: pathState.focusedSegmentIndex,
            pathHead: pathState.compactPaths.map(\.displayText),
            candidateHead: (output?.candidates ?? []).map(\.text).map { text in
                // Candidates may be CJK — only lengths, not content, for host privacy.
                "len\(text.count)"
            },
            note: note
        )
    }
}
#endif
