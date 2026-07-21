import Foundation

/// One precise pinyin path shown in the nine-key path bar / panel.
public struct T9PinyinPath: Equatable, Sendable, Hashable {
    /// UI label, e.g. `ni hao`.
    public let displayText: String
    /// Value passed to `RimeEngine.replaceInput`, e.g. `ni'hao`.
    public let replacementRawInput: String

    public init(displayText: String, replacementRawInput: String) {
        self.displayText = displayText
        self.replacementRawInput = replacementRawInput
    }
}

/// Compact path bar state owned by KeyboardCore (not UIKit).
public struct T9PinyinPathState: Equatable, Sendable {
    public var compactPaths: [T9PinyinPath]
    public var selectedPath: T9PinyinPath?
    /// Bumped when the tracked raw-input identity changes (stable for same raw).
    public var rawInputGeneration: UInt64
    /// Bumped when live comment/window provenance authority changes (independent of raw).
    /// UIKit expanded panel must bind to this revision, not only `rawInputGeneration`.
    public var provenanceRevision: UInt64
    /// Normalized raw identity used for generation stability (ASCII-oriented).
    public var trackedRawInput: String?
    /// Replacement keys issued by Core for this provenance revision (comment provenance).
    /// Selection is authorized only when the key is in this set.
    public var issuedReplacementKeys: Set<String>
    /// Next Rime global candidate index for path discovery (panel / availability).
    public var discoveryNextIndex: Int
    /// `true` while later candidate windows may still contain valid paths.
    /// Must not be collapsed to "no paths" solely because a 16-item peek was empty.
    public var discoveryMayHaveMore: Bool
    /// Original single digit that issued deterministic key-group choices (ADR 0021).
    /// It intentionally survives a successful `6 -> m/n/o` refinement so another
    /// cycle can select a sibling choice. All other input/lifecycle changes clear it.
    public var retainedChoiceSourceRawInput: String?
    /// Original digit sequence represented by the current segmented snapshot.
    /// This is UI/state provenance only; live composition remains owned by RIME.
    public var segmentSourceDigits: String?
    /// Key-group index whose choices are currently shown in segmented mode.
    public var focusedSegmentIndex: Int?
    /// Tentatively confirmed key-group values before `focusedSegmentIndex`.
    public var confirmedSegmentValues: [String]

    public init(
        compactPaths: [T9PinyinPath] = [],
        selectedPath: T9PinyinPath? = nil,
        rawInputGeneration: UInt64 = 0,
        provenanceRevision: UInt64 = 0,
        trackedRawInput: String? = nil,
        issuedReplacementKeys: Set<String> = [],
        discoveryNextIndex: Int = 0,
        discoveryMayHaveMore: Bool = false,
        retainedChoiceSourceRawInput: String? = nil,
        segmentSourceDigits: String? = nil,
        focusedSegmentIndex: Int? = nil,
        confirmedSegmentValues: [String] = []
    ) {
        self.compactPaths = compactPaths
        self.selectedPath = selectedPath
        self.rawInputGeneration = rawInputGeneration
        self.provenanceRevision = provenanceRevision
        self.trackedRawInput = trackedRawInput
        self.issuedReplacementKeys = issuedReplacementKeys
        self.discoveryNextIndex = discoveryNextIndex
        self.discoveryMayHaveMore = discoveryMayHaveMore
        self.retainedChoiceSourceRawInput = retainedChoiceSourceRawInput
        self.segmentSourceDigits = segmentSourceDigits
        self.focusedSegmentIndex = focusedSegmentIndex
        self.confirmedSegmentValues = confirmedSegmentValues
    }

    public static let empty = T9PinyinPathState()

    public var hasIssuedPaths: Bool { !issuedReplacementKeys.isEmpty }
}

/// Availability for UI “选拼音” without collapsing sparse later windows to “none”.
public enum T9PinyinPathAvailability: Equatable, Sendable {
    /// Not in an active T9 composition.
    case noComposition
    /// Core has issued at least one validated path for the current generation.
    case pathsAvailable
    /// No path issued yet, but later candidate windows may still contain paths.
    case discoveryPending
    /// Candidate list fully scanned for this generation with zero valid paths.
    case exhaustedNoPaths

    public var allowsSelectPinyinControl: Bool {
        switch self {
        case .pathsAvailable, .discoveryPending:
            return true
        case .noComposition, .exhaustedNoPaths:
            return false
        }
    }
}

/// Lazy scan window over Rime global candidates for path extraction.
public struct T9PinyinPathWindow: Equatable, Sendable {
    public var paths: [T9PinyinPath]
    public var nextGlobalIndex: Int
    public var hasMoreCandidates: Bool
    public var rawInputGeneration: UInt64
    public var provenanceRevision: UInt64

    public init(
        paths: [T9PinyinPath] = [],
        nextGlobalIndex: Int = 0,
        hasMoreCandidates: Bool = false,
        rawInputGeneration: UInt64 = 0,
        provenanceRevision: UInt64 = 0
    ) {
        self.paths = paths
        self.nextGlobalIndex = nextGlobalIndex
        self.hasMoreCandidates = hasMoreCandidates
        self.rawInputGeneration = rawInputGeneration
        self.provenanceRevision = provenanceRevision
    }
}

/// Pure parsing / validation / ranking for T9 precise pinyin paths (ADR 0020).
public enum T9PinyinPathExtractor {
    public static let compactLimit = 5
    /// Bounded sync scan on the input path when page candidates are sparse (not a full catalog walk).
    public static let hotPathWindowLimit = 16
    public static let panelWindowLimit = 48
    /// Maximum live-RIME probes used to discover complete syllables that are
    /// absent from the current candidate window (Amendment F).
    public static let completeSyllableProbeLimit = 48
    /// Keeps discovery independent of an unusually long unresolved digit tail.
    public static let completeSyllableMaximumDigits = 6

    private static let t9Groups: [Character: [Character]] = [
        "2": Array("abc"),
        "3": Array("def"),
        "4": Array("ghi"),
        "5": Array("jkl"),
        "6": Array("mno"),
        "7": Array("pqrs"),
        "8": Array("tuv"),
        "9": Array("wxyz"),
    ]

    // MARK: - ASCII helpers (ADR 0020)

    public static func isASCIILetter(_ scalar: Unicode.Scalar) -> Bool {
        (scalar.value >= 65 && scalar.value <= 90) || (scalar.value >= 97 && scalar.value <= 122)
    }

    public static func isASCIIDigit(_ scalar: Unicode.Scalar) -> Bool {
        scalar.value >= 48 && scalar.value <= 57
    }

    public static func isASCIISpace(_ scalar: Unicode.Scalar) -> Bool {
        scalar.value == 32
    }

    public static func isApostrophe(_ scalar: Unicode.Scalar) -> Bool {
        scalar.value == 39
    }

    public static func isASCIISeparator(_ scalar: Unicode.Scalar) -> Bool {
        isASCIISpace(scalar) || isApostrophe(scalar)
    }

    public static func lowercaseASCIILetter(_ scalar: Unicode.Scalar) -> Unicode.Scalar {
        if scalar.value >= 65 && scalar.value <= 90 {
            return Unicode.Scalar(scalar.value + 32)!
        }
        return scalar
    }

    /// Normalize raw identity for generation tracking and refine equality.
    public static func normalizeRawIdentity(_ raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return "" }
        var out: [Unicode.Scalar] = []
        var pendingSeparator = false
        for scalar in raw.unicodeScalars {
            if isASCIILetter(scalar) {
                if pendingSeparator, !out.isEmpty {
                    out.append("'")
                    pendingSeparator = false
                }
                out.append(lowercaseASCIILetter(scalar))
            } else if isASCIIDigit(scalar) {
                if pendingSeparator, !out.isEmpty {
                    out.append("'")
                    pendingSeparator = false
                }
                out.append(scalar)
            } else if isASCIISeparator(scalar) {
                pendingSeparator = true
            } else {
                // Invalid char: keep a stable but non-matching marker for identity only.
                return raw
            }
        }
        while out.last == "'" { out.removeLast() }
        while out.first == "'" { out.removeFirst() }
        return String(String.UnicodeScalarView(out))
    }

    /// Normalize a Rime candidate comment into a path, or `nil` if invalid (ASCII-only).
    public static func path(fromComment comment: String?) -> T9PinyinPath? {
        guard let comment else { return nil }
        // Trim only ASCII space edges; reject tab/newline/nbsp inside.
        var body = comment
        while body.first?.unicodeScalars.first.map(isASCIISpace) == true {
            body.removeFirst()
        }
        while body.last?.unicodeScalars.first.map(isASCIISpace) == true {
            body.removeLast()
        }
        guard !body.isEmpty else { return nil }

        var replacementScalars: [Unicode.Scalar] = []
        var displayScalars: [Unicode.Scalar] = []
        var pendingSeparator = false

        for scalar in body.unicodeScalars {
            if isASCIILetter(scalar) {
                if pendingSeparator, !replacementScalars.isEmpty {
                    replacementScalars.append("'")
                    displayScalars.append(" ")
                    pendingSeparator = false
                }
                let lower = lowercaseASCIILetter(scalar)
                replacementScalars.append(lower)
                displayScalars.append(lower)
            } else if isASCIISeparator(scalar) {
                pendingSeparator = true
            } else {
                return nil
            }
        }

        while replacementScalars.last == "'" { replacementScalars.removeLast() }
        while replacementScalars.first == "'" { replacementScalars.removeFirst() }
        let replacement = String(String.UnicodeScalarView(replacementScalars))
        guard !replacement.isEmpty else { return nil }

        var display = String(String.UnicodeScalarView(displayScalars))
        while display.first?.unicodeScalars.first.map(isASCIISpace) == true { display.removeFirst() }
        while display.last?.unicodeScalars.first.map(isASCIISpace) == true { display.removeLast() }
        while display.contains("  ") {
            display = display.replacingOccurrences(of: "  ", with: " ")
        }
        if display.isEmpty {
            display = replacement.replacingOccurrences(of: "'", with: " ")
        }

        return T9PinyinPath(displayText: display, replacementRawInput: replacement)
    }

    public static func isValidT9RawInput(_ rawInput: String?) -> Bool {
        guard let rawInput, !rawInput.isEmpty else { return false }
        return rawInput.unicodeScalars.allSatisfy { scalar in
            isASCIILetter(scalar) || isASCIIDigit(scalar) || isASCIISeparator(scalar)
        }
    }

    /// Complete deterministic choices for one unresolved T9 digit.
    ///
    /// This is key identity, not pinyin prediction: multi-digit input must still
    /// use compatible paths issued from live RIME comments.
    public static func deterministicSingleDigitPaths(rawInput: String?) -> [T9PinyinPath] {
        guard let rawInput, rawInput.count == 1,
              let digit = rawInput.first,
              let letters = t9Groups[digit]
        else { return [] }

        return letters.map { letter in
            let value = String(letter)
            return T9PinyinPath(displayText: value, replacementRawInput: value)
        }
    }

    public static func keyLetters(forDigit digit: Character) -> [Character] {
        t9Groups[digit] ?? []
    }

    /// Deterministic, strictly bounded spellings for live-RIME syllable probes.
    /// These are never published directly: callers must prove exact raw,
    /// usable composition and matching candidate-comment provenance first.
    public static func boundedCompleteSyllableSpellings(
        forDigits digits: String,
        limit: Int = completeSyllableProbeLimit
    ) -> [String] {
        let safeLimit = max(0, limit)
        guard safeLimit > 0, digits.count >= 2,
              digits.allSatisfy({ !keyLetters(forDigit: $0).isEmpty })
        else { return [] }

        var frontier = [""]
        var results: [String] = []
        let boundedDigits = digits.prefix(completeSyllableMaximumDigits)

        for (offset, digit) in boundedDigits.enumerated() {
            var next: [String] = []
            for prefix in frontier {
                for letter in keyLetters(forDigit: digit) {
                    let spelling = prefix + String(letter)
                    next.append(spelling)
                    if offset >= 1 {
                        results.append(spelling)
                        if results.count >= safeLimit { return results }
                    }
                }
            }
            frontier = next
        }
        return results
    }

    /// ASCII letter count of a syllable or raw fragment (digits/separators ignored).
    public static func asciiLetterCount(in text: String) -> Int {
        asciiLetters(from: text).count
    }

    /// Total ASCII letters across confirmed/focused syllable values.
    public static func letterCount(ofSyllables syllables: [String]) -> Int {
        syllables.reduce(0) { $0 + asciiLetterCount(in: $1) }
    }

    /// Whether confirming `selected` still leaves unresolved digits in `sourceDigits`.
    public static func canAdvanceAfterConfirming(
        selectedDisplay: String,
        confirmedSyllables: [String],
        sourceDigits: String
    ) -> Bool {
        let consumed = letterCount(ofSyllables: confirmedSyllables) + asciiLetterCount(in: selectedDisplay)
        return consumed < sourceDigits.count
    }

    /// Pure ASCII digit run, or empty when `raw` is not digit-only.
    public static func pureDigitRaw(_ raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return "" }
        guard raw.unicodeScalars.allSatisfy(isASCIIDigit) else { return "" }
        return raw
    }

    /// Parse an apostrophe-anchored mixed raw such as `qiu'53` or `qiu'shu'5`
    /// into confirmed letter syllables plus the trailing unresolved digit run.
    /// Returns `nil` when the raw is not a clean confirmed-prefix boundary.
    public static func anchoredConfirmedSyllables(
        fromMixedRaw raw: String
    ) -> (confirmed: [String], trailingDigits: String)? {
        guard let boundary = raw.lastIndex(of: "'"),
              boundary > raw.startIndex,
              raw.index(after: boundary) < raw.endIndex
        else { return nil }

        let trailing = String(raw[raw.index(after: boundary)...])
        guard !trailing.isEmpty, trailing.unicodeScalars.allSatisfy(isASCIIDigit) else {
            return nil
        }

        let prefix = String(raw[..<boundary])
        let segments = prefix
            .split(separator: "'", omittingEmptySubsequences: true)
            .map(String.init)
        guard !segments.isEmpty,
              segments.allSatisfy({
                  !$0.isEmpty && $0.unicodeScalars.allSatisfy(isASCIILetter)
              })
        else { return nil }

        return (segments.map { $0.lowercased() }, trailing)
    }

    /// Extract digit identity from a RIME preedit that contains only T9 digits
    /// and harmless segment separators. This is internal provenance, never text
    /// that may be written to the host.
    public static func internalDigitIdentity(fromPreedit preedit: String) -> String? {
        guard !preedit.isEmpty else { return nil }
        var digits: [Unicode.Scalar] = []
        for scalar in preedit.unicodeScalars {
            if isASCIIDigit(scalar) {
                digits.append(scalar)
            } else if !isASCIISeparator(scalar) {
                return nil
            }
        }
        guard !digits.isEmpty else { return nil }
        return String(String.UnicodeScalarView(digits))
    }

    /// Remaining T9 raw after a partial Chinese selection.
    ///
    /// Real librime often keeps the **full** digit raw while preedit becomes
    /// `你好ya`. Path bar and recovery tracking must use only the unresolved
    /// suffix (e.g. `92` for `ya`), never the leading confirmed slots that still
    /// start with `6 → m/n/o`.
    ///
    /// Rules (fail closed to `resultRaw` when unsure):
    /// 1. Prefer `resultRaw` when it is already a shorter pure-digit suffix of the previous digits.
    /// 2. When result still equals the previous pure-digit run, peel `suffix(remainingLetterCount)`
    ///    using the comment-preferred remaining display (e.g. `ya` → 2 → last two digits).
    /// 3. Otherwise keep `resultRaw` (letter/mixed remaining is authoritative).
    public static func remainingT9RawAfterPartialCommit(
        previousRaw: String?,
        resultRaw: String?,
        remainingDisplayPreedit: String
    ) -> String? {
        guard let resultRaw, !resultRaw.isEmpty else { return nil }
        let previousDigits = pureDigitRaw(previousRaw)
        let resultDigits = pureDigitRaw(resultRaw)

        if !resultDigits.isEmpty,
           !previousDigits.isEmpty,
           previousDigits.hasSuffix(resultDigits),
           resultDigits.count < previousDigits.count
        {
            return resultDigits
        }

        if !previousDigits.isEmpty,
           resultDigits == previousDigits || resultDigits.isEmpty
        {
            let remainingLetters = asciiLetterCount(in: remainingDisplayPreedit)
            if remainingLetters > 0, remainingLetters <= previousDigits.count {
                return String(previousDigits.suffix(remainingLetters))
            }
        }

        return resultRaw
    }

    /// Build a full live replacement for one progressive syllable choice.
    ///
    /// Confirmed syllables become the apostrophe-delimited prefix; the focused
    /// syllable's letters consume the next digit slots; any remaining digits are
    /// appended so RIME still sees the unresolved tail.
    public static func replacementForProgressiveSyllable(
        displaySyllable: String,
        confirmedSyllables: [String],
        sourceDigits: String
    ) -> String? {
        let syllable = displaySyllable.lowercased()
        guard !syllable.isEmpty,
              syllable.unicodeScalars.allSatisfy(isASCIILetter)
        else { return nil }

        let confirmedLetters = letterCount(ofSyllables: confirmedSyllables)
        let focusLetters = asciiLetterCount(in: syllable)
        guard confirmedLetters + focusLetters <= sourceDigits.count else { return nil }

        let digitPrefix = String(
            sourceDigits.dropFirst(confirmedLetters).prefix(focusLetters)
        )
        let probe = T9PinyinPath(displayText: syllable, replacementRawInput: syllable)
        guard isCompatible(path: probe, withRawInput: digitPrefix) else { return nil }

        let suffixDigits = String(sourceDigits.dropFirst(confirmedLetters + focusLetters))
        let prefix = confirmedSyllables.joined(separator: "'")
        if prefix.isEmpty {
            return syllable + suffixDigits
        }
        return prefix + "'" + syllable + suffixDigits
    }

    /// Progressive syllable choices for the current focus (Amendment B).
    ///
    /// Takes only the apostrophe-delimited segment at `confirmedSyllables.count`
    /// from live comments. Multi-syllable whole paths never appear as one compact
    /// label — each step exposes a single syllable (e.g. `ni`, then `xian`).
    public static func progressiveSyllablePaths(
        from candidates: [RimeCandidate],
        sourceDigits: String,
        confirmedSyllables: [String],
        limit: Int
    ) -> [T9PinyinPath] {
        let safeLimit = max(0, limit)
        guard safeLimit > 0, !sourceDigits.isEmpty else { return [] }
        guard sourceDigits.allSatisfy({ $0.isASCII && $0.isNumber }) else { return [] }

        let segmentIndex = confirmedSyllables.count
        let confirmedLetters = letterCount(ofSyllables: confirmedSyllables)
        guard confirmedLetters < sourceDigits.count else { return [] }

        var seen = Set<String>()
        var ordered: [T9PinyinPath] = []

        for candidate in candidates {
            guard let path = path(fromComment: candidate.comment) else { continue }
            let segments = path.replacementRawInput
                .split(separator: "'", omittingEmptySubsequences: true)
                .map(String.init)
            guard segments.indices.contains(segmentIndex) else { continue }
            guard matchesConfirmedPrefix(
                segments.map { $0.lowercased() },
                confirmedSyllables: confirmedSyllables
            ) else { continue }
            let syllable = segments[segmentIndex]
            guard seen.insert(syllable).inserted else { continue }
            guard let replacement = replacementForProgressiveSyllable(
                displaySyllable: syllable,
                confirmedSyllables: confirmedSyllables,
                sourceDigits: sourceDigits
            ) else { continue }

            ordered.append(
                T9PinyinPath(displayText: syllable, replacementRawInput: replacement)
            )
            if ordered.count >= safeLimit { break }
        }
        return ordered
    }

    /// First physical key-group letter choices for progressive whole composition.
    public static func firstKeyGroupPaths(sourceDigits: String) -> [T9PinyinPath] {
        guard let digit = sourceDigits.first,
              sourceDigits.count > 1,
              sourceDigits.allSatisfy({ $0.isASCII && $0.isNumber })
        else { return [] }
        let pending = String(sourceDigits.dropFirst())
        return keyLetters(forDigit: digit).map { letter in
            let value = String(letter)
            return T9PinyinPath(displayText: value, replacementRawInput: value + pending)
        }
    }

    /// A probe authorizes a focused choice only when a live candidate comment
    /// actually contains that apostrophe-delimited segment. Merely retaining raw
    /// input or fallback candidates is insufficient (`n'i` is the pinned example).
    public static func candidateCommentsAuthorizeSegment(
        _ candidates: [RimeCandidate],
        segmentIndex: Int,
        startingWith letter: Character,
        confirmedSyllables: [String] = []
    ) -> Bool {
        guard segmentIndex > 0 else { return false }
        let expected = String(letter).lowercased()
        return candidates.contains { candidate in
            guard let path = path(fromComment: candidate.comment) else { return false }
            let segments = path.replacementRawInput
                .split(separator: "'", omittingEmptySubsequences: true)
                .map { $0.lowercased() }
            guard segments.indices.contains(segmentIndex) else { return false }
            guard matchesConfirmedPrefix(
                segments,
                confirmedSyllables: confirmedSyllables
            ) else { return false }
            return segments[segmentIndex].hasPrefix(expected)
        }
    }

    /// Exact syllable authorization at `segmentIndex` (syllable-level advance).
    public static func candidateCommentsAuthorizeExactSegment(
        _ candidates: [RimeCandidate],
        segmentIndex: Int,
        syllable: String,
        confirmedSyllables: [String] = []
    ) -> Bool {
        guard segmentIndex >= 0 else { return false }
        let expected = syllable.lowercased()
        guard !expected.isEmpty else { return false }
        return candidates.contains { candidate in
            guard let path = path(fromComment: candidate.comment) else { return false }
            let segments = path.replacementRawInput
                .split(separator: "'", omittingEmptySubsequences: true)
                .map { $0.lowercased() }
            guard segments.indices.contains(segmentIndex) else { return false }
            guard matchesConfirmedPrefix(
                segments,
                confirmedSyllables: confirmedSyllables
            ) else { return false }
            return segments[segmentIndex] == expected
        }
    }

    /// First live comment whose leading segments still match every explicit
    /// user confirmation. Candidate ranking may change, but it cannot rewrite
    /// an already confirmed path prefix.
    public static func pathPreservingConfirmedPrefix(
        from candidates: [RimeCandidate],
        confirmedSyllables: [String]
    ) -> T9PinyinPath? {
        guard !confirmedSyllables.isEmpty else { return nil }
        let expected = confirmedSyllables.map { $0.lowercased() }
        for candidate in candidates {
            guard let path = path(fromComment: candidate.comment) else { continue }
            let segments = path.replacementRawInput
                .split(separator: "'", omittingEmptySubsequences: true)
                .map { $0.lowercased() }
            guard segments.count >= expected.count,
                  matchesConfirmedPrefix(
                    segments,
                    confirmedSyllables: expected
                  )
            else { continue }
            return path
        }
        return nil
    }

    private static func matchesConfirmedPrefix(
        _ segments: [String],
        confirmedSyllables: [String]
    ) -> Bool {
        guard !confirmedSyllables.isEmpty else { return true }
        guard segments.count >= confirmedSyllables.count else { return false }
        for index in confirmedSyllables.indices {
            guard segments[index].hasPrefix(confirmedSyllables[index].lowercased()) else {
                return false
            }
        }
        return true
    }

    /// Position-based compatibility: walk raw slots in order; never drop digit suffix constraints.
    public static func isCompatible(path: T9PinyinPath, withRawInput rawInput: String?) -> Bool {
        guard let rawInput, !rawInput.isEmpty else { return false }
        guard isValidT9RawInput(rawInput) else { return false }
        guard isValidT9RawInput(path.replacementRawInput) else { return false }

        let pathLetters = asciiLetters(from: path.replacementRawInput)
        guard !pathLetters.isEmpty else { return false }

        let slots = rawSlots(from: rawInput)
        guard !slots.isEmpty else { return false }
        guard pathLetters.count <= slots.count else { return false }

        for index in pathLetters.indices {
            let letter = pathLetters[index]
            switch slots[index] {
            case .letter(let rawLetter):
                guard letter == rawLetter else { return false }
            case .digit(let digit):
                guard let group = t9Groups[digit], group.contains(letter) else { return false }
            }
        }

        if pathLetters.count == slots.count {
            return true
        }

        // Shorter path is only allowed when remaining raw slots are trailing digits
        // (refined letter prefix + continued digit, e.g. path `ni` on raw `ni4`).
        // Pure digit compositions require a full-length path (complete sequence).
        let remaining = slots[pathLetters.count...]
        let rawHasLetters = slots.contains { if case .letter = $0 { return true }; return false }
        if !rawHasLetters {
            return false
        }
        return remaining.allSatisfy { if case .digit = $0 { return true }; return false }
    }

    /// Build ordered unique paths from candidates (first-seen wins).
    public static func paths(
        from candidates: [RimeCandidate],
        rawInput: String?,
        limit: Int? = nil
    ) -> [T9PinyinPath] {
        var seen = Set<String>()
        var ordered: [T9PinyinPath] = []
        for candidate in candidates {
            guard let path = path(fromComment: candidate.comment) else { continue }
            guard isCompatible(path: path, withRawInput: rawInput) else { continue }
            if seen.insert(path.replacementRawInput).inserted {
                ordered.append(path)
                if let limit, ordered.count >= limit { break }
            }
        }
        return ordered
    }

    /// Scan a Rime candidate window and merge into an accumulating window state.
    public static func extendWindow(
        _ window: T9PinyinPathWindow,
        with candidates: [RimeCandidate],
        rawInput: String?,
        nextIndex: Int,
        hasMoreCandidates: Bool,
        expectedGeneration: UInt64
    ) -> T9PinyinPathWindow? {
        guard window.rawInputGeneration == expectedGeneration else { return nil }
        var seen = Set(window.paths.map(\.replacementRawInput))
        var paths = window.paths
        for candidate in candidates {
            guard let path = path(fromComment: candidate.comment) else { continue }
            guard isCompatible(path: path, withRawInput: rawInput) else { continue }
            if seen.insert(path.replacementRawInput).inserted {
                paths.append(path)
            }
        }
        return T9PinyinPathWindow(
            paths: paths,
            nextGlobalIndex: nextIndex,
            hasMoreCandidates: hasMoreCandidates,
            rawInputGeneration: expectedGeneration
        )
    }

    // MARK: - Private

    private enum RawSlot: Equatable {
        case letter(Character)
        case digit(Character)
    }

    private static func asciiLetters(from text: String) -> [Character] {
        var letters: [Character] = []
        for scalar in text.unicodeScalars {
            if isASCIILetter(scalar) {
                letters.append(Character(lowercaseASCIILetter(scalar)))
            }
        }
        return letters
    }

    private static func rawSlots(from raw: String) -> [RawSlot] {
        var slots: [RawSlot] = []
        for scalar in raw.unicodeScalars {
            if isASCIILetter(scalar) {
                slots.append(.letter(Character(lowercaseASCIILetter(scalar))))
            } else if isASCIIDigit(scalar) {
                slots.append(.digit(Character(scalar)))
            }
            // separators skipped — do not consume path letters
        }
        return slots
    }
}
