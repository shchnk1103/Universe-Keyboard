import Foundation

/// Path kind owned by KeyboardCore (ADR 0023).
public enum T9PinyinPathKind: String, Equatable, Sendable, Hashable {
    case completeSyllable
    case letterPrefix
}

/// One precise pinyin path shown in the nine-key path bar.
public struct T9PinyinPath: Equatable, Sendable, Hashable {
    /// Stable identity for the current focus snapshot (not accessibility payload).
    public let id: String
    public let kind: T9PinyinPathKind
    /// How many source digit slots this path consumes in the current focus.
    public let consumedSlotCount: Int
    /// UI label, e.g. `bu` or `b`.
    public let displayText: String
    /// Value passed to `RimeEngine.replaceInput`, e.g. `bu` / `b8` / `qiu'53`.
    public let replacementRawInput: String
    /// Composition revision that issued this path. UI must reject mismatched taps.
    public let compositionRevision: UInt64
    /// Inclusive start of the focus slot range within full source digits.
    public let focusSlotStart: Int
    /// Exclusive end of the focus slot range within full source digits.
    public let focusSlotEnd: Int

    public init(
        id: String? = nil,
        kind: T9PinyinPathKind = .completeSyllable,
        consumedSlotCount: Int? = nil,
        displayText: String,
        replacementRawInput: String,
        compositionRevision: UInt64 = 0,
        focusSlotStart: Int = 0,
        focusSlotEnd: Int? = nil
    ) {
        let slots = consumedSlotCount
            ?? T9PinyinPathExtractor.asciiLetterCount(in: displayText)
        self.kind = kind
        self.consumedSlotCount = max(0, slots)
        self.displayText = displayText
        self.replacementRawInput = replacementRawInput
        self.compositionRevision = compositionRevision
        self.focusSlotStart = max(0, focusSlotStart)
        let end = focusSlotEnd ?? (self.focusSlotStart + self.consumedSlotCount)
        self.focusSlotEnd = max(self.focusSlotStart, end)
        self.id = id ?? Self.makeID(
            kind: kind,
            displayText: displayText,
            replacementRawInput: replacementRawInput,
            consumedSlotCount: self.consumedSlotCount
        )
    }

    public static func makeID(
        kind: T9PinyinPathKind,
        displayText: String,
        replacementRawInput: String,
        consumedSlotCount: Int
    ) -> String {
        "\(kind.rawValue)|\(displayText)|\(consumedSlotCount)|\(replacementRawInput)"
    }

    public static func == (lhs: T9PinyinPath, rhs: T9PinyinPath) -> Bool {
        lhs.id == rhs.id
            && lhs.kind == rhs.kind
            && lhs.displayText == rhs.displayText
            && lhs.replacementRawInput == rhs.replacementRawInput
            && lhs.consumedSlotCount == rhs.consumedSlotCount
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(kind)
        hasher.combine(displayText)
        hasher.combine(replacementRawInput)
        hasher.combine(consumedSlotCount)
    }
}

/// Coherent T9 presentation published with one composition revision (ADR 0023).
public struct T9CompositionPresentationSnapshot: Equatable, Sendable {
    public var revision: UInt64
    public var sourceDigits: String
    public var rimeRawInput: String?
    public var focusSlotStart: Int
    public var focusSlotEnd: Int
    public var confirmedSyllables: [String]
    public var lockedLetterPrefix: String?
    public var provisionalPathID: String?
    public var selectedPathID: String?
    public var paths: [T9PinyinPath]
    /// Candidates that belong to the same composition revision as `paths`.
    public var candidates: [RimeCandidate]
    public var visiblePreedit: String
    /// Paging metadata captured with the same revision (avoid live re-read in UI).
    public var candidatePageNumber: Int
    public var hasMorePages: Bool
    public var compositionPreedit: String

    public init(
        revision: UInt64 = 0,
        sourceDigits: String = "",
        rimeRawInput: String? = nil,
        focusSlotStart: Int = 0,
        focusSlotEnd: Int = 0,
        confirmedSyllables: [String] = [],
        lockedLetterPrefix: String? = nil,
        provisionalPathID: String? = nil,
        selectedPathID: String? = nil,
        paths: [T9PinyinPath] = [],
        candidates: [RimeCandidate] = [],
        visiblePreedit: String = "",
        candidatePageNumber: Int = 0,
        hasMorePages: Bool = false,
        compositionPreedit: String = ""
    ) {
        self.revision = revision
        self.sourceDigits = sourceDigits
        self.rimeRawInput = rimeRawInput
        self.focusSlotStart = focusSlotStart
        self.focusSlotEnd = focusSlotEnd
        self.confirmedSyllables = confirmedSyllables
        self.lockedLetterPrefix = lockedLetterPrefix
        self.provisionalPathID = provisionalPathID
        self.selectedPathID = selectedPathID
        self.paths = paths
        self.candidates = candidates
        self.visiblePreedit = visiblePreedit
        self.candidatePageNumber = candidatePageNumber
        self.hasMorePages = hasMorePages
        self.compositionPreedit = compositionPreedit
    }

    public static let empty = T9CompositionPresentationSnapshot()
}

/// Local complete-syllable Path construction (no RIME probes, ADR 0023).
public enum T9PinyinLocalPathCatalog {
    public static let maximumFocusDigits = 6

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

    /// Build ordered paths for the current focus digit run.
    ///
    /// - Parameters:
    ///   - focusDigits: unresolved pure-digit focus (not the whole multi-syllable
    ///     source when confirmed syllables already consumed leading slots).
    ///   - lockedLetterPrefix: optional explicit prefix (e.g. `b` after choosing `b` on `28`).
    ///   - commentSyllableHints: first-seen focus-segment syllables from live comments
    ///     (ranking only; never legality).
    public static func pathsForFocus(
        focusDigits: String,
        lockedLetterPrefix: String?,
        commentSyllableHints: [String],
        confirmedSyllables: [String],
        sourceDigits: String,
        compositionRevision: UInt64
    ) -> [T9PinyinPath] {
        guard !focusDigits.isEmpty,
              focusDigits.allSatisfy({ $0.isASCII && $0.isNumber })
        else { return [] }

        let focusStart = T9PinyinPathExtractor.letterCount(ofSyllables: confirmedSyllables)
        // `sourceDigits` is the full composition digit identity when confirmed
        // syllables already consumed leading slots; otherwise it equals focusDigits.
        let resolvedSource = sourceDigits.isEmpty ? focusDigits : sourceDigits
        _ = focusStart + focusDigits.count // documented bound; callers keep identity coherent
        let locked = lockedLetterPrefix?.lowercased()
        if let locked, locked.count == 1, let letter = locked.first, letter.isLetter {
            return pathsWithLockedPrefix(
                letter: letter,
                focusDigits: focusDigits,
                commentSyllableHints: commentSyllableHints,
                confirmedSyllables: confirmedSyllables,
                sourceDigits: resolvedSource,
                compositionRevision: compositionRevision,
                focusSlotStart: focusStart
            )
        }

        // Single unresolved digit keeps physical key-group order (a/b/c…), while
        // still tagging catalog-complete letters as completeSyllable.
        if focusDigits.count == 1 {
            return singleDigitKeyGroupPaths(
                focusDigits: focusDigits,
                confirmedSyllables: confirmedSyllables,
                sourceDigits: resolvedSource,
                compositionRevision: compositionRevision,
                focusSlotStart: focusStart
            )
        }

        return unlockedPaths(
            focusDigits: focusDigits,
            commentSyllableHints: commentSyllableHints,
            confirmedSyllables: confirmedSyllables,
            sourceDigits: resolvedSource,
            compositionRevision: compositionRevision,
            focusSlotStart: focusStart
        )
    }

    private static func singleDigitKeyGroupPaths(
        focusDigits: String,
        confirmedSyllables: [String],
        sourceDigits: String,
        compositionRevision: UInt64,
        focusSlotStart: Int
    ) -> [T9PinyinPath] {
        guard let digit = focusDigits.first else { return [] }
        // PD-004 option 1: only catalog-legal syllables are completeSyllable.
        // Other key-group letters (m/n, b/c, …) are letterPrefix — lock only, never
        // confirm/advance. Slot coverage alone does not make a letter a syllable.
        let completeSet = Set(
            T9PinyinSyllableCatalog.completeSyllables(matchingDigits: focusDigits)
        )
        return (t9Groups[digit] ?? []).compactMap { letter in
            let display = String(letter)
            let kind: T9PinyinPathKind =
                completeSet.contains(display) ? .completeSyllable : .letterPrefix
            guard let replacement = replacementForLetterPrefix(
                letter: display,
                confirmedSyllables: confirmedSyllables,
                focusDigits: focusDigits
            ) ?? T9PinyinPathExtractor.replacementForProgressiveSyllable(
                displaySyllable: display,
                confirmedSyllables: confirmedSyllables,
                sourceDigits: sourceDigits
            ) else { return nil }
            return T9PinyinPath(
                kind: kind,
                consumedSlotCount: 1,
                displayText: display,
                replacementRawInput: replacement,
                compositionRevision: compositionRevision,
                focusSlotStart: focusSlotStart,
                focusSlotEnd: focusSlotStart + 1
            )
        }
    }

    /// Ordered comment syllables for the current focus segment (ranking hints).
    public static func commentSyllableHints(
        from candidates: [RimeCandidate],
        confirmedSyllables: [String]
    ) -> [String] {
        let segmentIndex = confirmedSyllables.count
        var ordered: [String] = []
        var seen = Set<String>()
        for candidate in candidates {
            guard let path = T9PinyinPathExtractor.path(fromComment: candidate.comment) else {
                continue
            }
            let segments = path.replacementRawInput
                .split(separator: "'", omittingEmptySubsequences: true)
                .map { $0.lowercased() }
            guard segments.indices.contains(segmentIndex) else { continue }
            if !confirmedSyllables.isEmpty {
                var matches = true
                for index in confirmedSyllables.indices {
                    guard segments.indices.contains(index),
                          segments[index].hasPrefix(confirmedSyllables[index].lowercased())
                    else {
                        matches = false
                        break
                    }
                }
                if !matches { continue }
            }
            let syllable = segments[segmentIndex]
            if seen.insert(syllable).inserted {
                ordered.append(syllable)
            }
        }
        return ordered
    }

    // MARK: - Private

    private static func unlockedPaths(
        focusDigits: String,
        commentSyllableHints: [String],
        confirmedSyllables: [String],
        sourceDigits: String,
        compositionRevision: UInt64,
        focusSlotStart: Int
    ) -> [T9PinyinPath] {
        let complete = completeSyllableEntries(
            focusDigits: focusDigits,
            lockedPrefix: nil,
            commentSyllableHints: commentSyllableHints,
            confirmedSyllables: confirmedSyllables,
            sourceDigits: sourceDigits,
            compositionRevision: compositionRevision,
            focusSlotStart: focusSlotStart
        )

        var completeDisplays = Set(complete.map(\.displayText))
        var result = complete

        guard let firstDigit = focusDigits.first else { return result }
        let letters = t9Groups[firstDigit] ?? []
        let suffix = String(focusDigits.dropFirst())
        for letter in letters {
            let display = String(letter)
            if completeDisplays.contains(display) { continue }
            guard let replacement = replacementForLetterPrefix(
                letter: display,
                confirmedSyllables: confirmedSyllables,
                focusDigits: focusDigits
            ) else { continue }
            result.append(
                T9PinyinPath(
                    kind: .letterPrefix,
                    consumedSlotCount: 1,
                    displayText: display,
                    replacementRawInput: replacement,
                    compositionRevision: compositionRevision,
                    focusSlotStart: focusSlotStart,
                    focusSlotEnd: focusSlotStart + 1
                )
            )
            completeDisplays.insert(display)
            _ = suffix
        }
        return result
    }

    private static func pathsWithLockedPrefix(
        letter: Character,
        focusDigits: String,
        commentSyllableHints: [String],
        confirmedSyllables: [String],
        sourceDigits: String,
        compositionRevision: UInt64,
        focusSlotStart: Int
    ) -> [T9PinyinPath] {
        let prefix = String(letter)
        guard let firstDigit = focusDigits.first,
              (t9Groups[firstDigit] ?? []).contains(letter)
        else { return [] }

        let complete = completeSyllableEntries(
            focusDigits: focusDigits,
            lockedPrefix: prefix,
            commentSyllableHints: commentSyllableHints,
            confirmedSyllables: confirmedSyllables,
            sourceDigits: sourceDigits,
            compositionRevision: compositionRevision,
            focusSlotStart: focusSlotStart
        )
        var result = complete
        if let replacement = replacementForLetterPrefix(
            letter: prefix,
            confirmedSyllables: confirmedSyllables,
            focusDigits: focusDigits
        ) {
            result.append(
                T9PinyinPath(
                    kind: .letterPrefix,
                    consumedSlotCount: 1,
                    displayText: prefix,
                    replacementRawInput: replacement,
                    compositionRevision: compositionRevision,
                    focusSlotStart: focusSlotStart,
                    focusSlotEnd: focusSlotStart + 1
                )
            )
        }
        return result
    }

    private static func completeSyllableEntries(
        focusDigits: String,
        lockedPrefix: String?,
        commentSyllableHints: [String],
        confirmedSyllables: [String],
        sourceDigits: String,
        compositionRevision: UInt64,
        focusSlotStart: Int
    ) -> [T9PinyinPath] {
        let maxLen = min(maximumFocusDigits, focusDigits.count)
        guard maxLen >= 1 else { return [] }

        struct Entry {
            let syllable: String
            let slots: Int
            let commentRank: Int
            let catalogRank: Int
        }

        var entries: [Entry] = []
        var seen = Set<String>()
        let hintRank = Dictionary(
            uniqueKeysWithValues: commentSyllableHints.enumerated().map { ($0.element, $0.offset) }
        )
        // Use the once-built catalog rank map; never rebuild per keystroke.
        let catalogRank = T9PinyinSyllableCatalog.catalogRankBySyllable

        for length in stride(from: maxLen, through: 1, by: -1) {
            let signature = String(focusDigits.prefix(length))
            for syllable in T9PinyinSyllableCatalog.completeSyllables(matchingDigits: signature) {
                if let lockedPrefix, !syllable.hasPrefix(lockedPrefix) { continue }
                guard seen.insert(syllable).inserted else { continue }
                entries.append(
                    Entry(
                        syllable: syllable,
                        slots: length,
                        commentRank: hintRank[syllable] ?? Int.max,
                        catalogRank: catalogRank[syllable] ?? Int.max
                    )
                )
            }
        }

        entries.sort {
            if $0.slots != $1.slots { return $0.slots > $1.slots }
            if $0.commentRank != $1.commentRank { return $0.commentRank < $1.commentRank }
            return $0.catalogRank < $1.catalogRank
        }

        return entries.compactMap { entry in
            guard let replacement = T9PinyinPathExtractor.replacementForProgressiveSyllable(
                displaySyllable: entry.syllable,
                confirmedSyllables: confirmedSyllables,
                sourceDigits: sourceDigits
            ) else { return nil }
            return T9PinyinPath(
                kind: .completeSyllable,
                consumedSlotCount: entry.slots,
                displayText: entry.syllable,
                replacementRawInput: replacement,
                compositionRevision: compositionRevision,
                focusSlotStart: focusSlotStart,
                focusSlotEnd: focusSlotStart + entry.slots
            )
        }
    }

    private static func replacementForLetterPrefix(
        letter: String,
        confirmedSyllables: [String],
        focusDigits: String
    ) -> String? {
        guard letter.count == 1,
              focusDigits.count >= 1,
              let first = focusDigits.first,
              let ch = letter.first,
              (t9Groups[first] ?? []).contains(ch)
        else { return nil }
        let suffix = String(focusDigits.dropFirst())
        let prefix = confirmedSyllables.joined(separator: "'")
        if prefix.isEmpty {
            return letter + suffix
        }
        return prefix + "'" + letter + suffix
    }
}
