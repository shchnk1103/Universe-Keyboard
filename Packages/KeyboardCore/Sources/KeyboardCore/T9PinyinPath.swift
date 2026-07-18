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

    public init(
        compactPaths: [T9PinyinPath] = [],
        selectedPath: T9PinyinPath? = nil,
        rawInputGeneration: UInt64 = 0,
        provenanceRevision: UInt64 = 0,
        trackedRawInput: String? = nil,
        issuedReplacementKeys: Set<String> = [],
        discoveryNextIndex: Int = 0,
        discoveryMayHaveMore: Bool = false
    ) {
        self.compactPaths = compactPaths
        self.selectedPath = selectedPath
        self.rawInputGeneration = rawInputGeneration
        self.provenanceRevision = provenanceRevision
        self.trackedRawInput = trackedRawInput
        self.issuedReplacementKeys = issuedReplacementKeys
        self.discoveryNextIndex = discoveryNextIndex
        self.discoveryMayHaveMore = discoveryMayHaveMore
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
    public static let compactLimit = 4
    /// Bounded sync scan on the input path when page candidates are sparse (not a full catalog walk).
    public static let hotPathWindowLimit = 16
    public static let panelWindowLimit = 48

    private static let t9Groups: [Character: Set<Character>] = [
        "2": Set("abc"),
        "3": Set("def"),
        "4": Set("ghi"),
        "5": Set("jkl"),
        "6": Set("mno"),
        "7": Set("pqrs"),
        "8": Set("tuv"),
        "9": Set("wxyz"),
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
