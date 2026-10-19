/// Short interpretations are temporary predictions, never user-confirmed Paths.
/// Only two complete source lengths are retained; candidate text stays live.
struct T9UnconfirmedDeleteHistory {
    struct Namespace: Equatable {
        let owner: ObjectIdentifier
        let epoch: UInt64
    }
    var namespace: Namespace?
    var spellings: [String: String] = [:]
    var preferred: (digits: String, spelling: String)?
    var generation: UInt64 = 0

    mutating func clear() {
        namespace = nil
        spellings.removeAll(keepingCapacity: true)
        preferred = nil
        generation &+= 1
    }
}

extension KeyboardController {
    func clearT9UnconfirmedDeleteHistory() {
        t9UnconfirmedDeleteHistory.clear()
    }

    private var t9HistoryNamespace: T9UnconfirmedDeleteHistory.Namespace? {
        if let owner = threadAffineRimeCoordinator {
            return .init(owner: ObjectIdentifier(owner), epoch: owner.diagnostics.sessionEpoch)
        }
        if let owner = responsiveRimeCoordinator {
            return .init(owner: ObjectIdentifier(owner), epoch: owner.diagnostics.sessionEpoch)
        }
        guard let engine = rimeEngine else { return nil }
        return .init(owner: ObjectIdentifier(engine), epoch: 0)
    }

    private var canUseT9UnconfirmedHistory: Bool {
        usesT9InputSemantics && state.inputMode == .chinese && state.currentPage == .letters
            && textClient != nil && state.partialCommit == nil
            && state.t9PinyinPathState.selectedPath == nil
            && state.t9PinyinPathState.confirmedSegmentValues.isEmpty
            && state.t9PinyinPathState.lockedLetterPrefix == nil
            && state.t9ReversibleAutoAnchorState.phase == .idle
            && !shouldRestoreRimeComposition && !shouldRebuildSessionDuringRestore
    }

    func prepareT9UnconfirmedHistory(for action: KeyboardAction) {
        switch action {
        case .insertKey(let key):
            t9UnconfirmedDeleteHistory.preferred = nil
            if key.count != 1 || !key.allSatisfy({ "23456789".contains($0) }) {
                clearT9UnconfirmedDeleteHistory()
            }
        case .deleteBackward:
            if !canUseT9UnconfirmedHistory { clearT9UnconfirmedDeleteHistory() }
        case .candidatePageUp, .candidatePageDown:
            break
        default:
            // Explicit choices, commits and mode/page changes own their own state.
            clearT9UnconfirmedDeleteHistory()
        }
    }

    private func synchronizeT9HistoryNamespace() -> Bool {
        guard canUseT9UnconfirmedHistory, let namespace = t9HistoryNamespace else {
            clearT9UnconfirmedDeleteHistory()
            return false
        }
        if t9UnconfirmedDeleteHistory.namespace != namespace {
            clearT9UnconfirmedDeleteHistory()
            t9UnconfirmedDeleteHistory.namespace = namespace
        }
        return true
    }

    private func isFullT9Spelling(_ spelling: String, for digits: String) -> Bool {
        spelling.count == digits.count
            && zip(digits, spelling).allSatisfy {
                T9PinyinPathExtractor.keyLetters(forDigit: $0.0).contains($0.1)
            }
    }

    /// Called after a real digit's complete post-processing, not every marked write.
    func captureT9UnconfirmedDigitInterpretation() {
        guard synchronizeT9HistoryNamespace(),
            let digits = state.t9PinyinPathState.segmentSourceDigits
        else { return }
        t9UnconfirmedDeleteHistory.spellings =
            t9UnconfirmedDeleteHistory.spellings.filter { digits.hasPrefix($0.key) }
        guard (2...3).contains(digits.count),
            let raw = state.lastRimeOutput?.rawInput,
            isFullT9Spelling(raw, for: digits) || raw == digits,
            let path = state.t9PinyinPathState.compactPaths.first(where: {
                $0.kind == .completeSyllable && $0.consumedSlotCount == digits.count
                    && $0.displayText == state.insertedPreeditText
            }),
            isFullT9Spelling(path.displayText, for: digits)
        else { return }
        t9UnconfirmedDeleteHistory.spellings[digits] = path.displayText
    }

    func t9HistoricalSpellingForDelete(digits: String) -> String? {
        guard synchronizeT9HistoryNamespace() else { return nil }
        t9UnconfirmedDeleteHistory.preferred = nil
        t9UnconfirmedDeleteHistory.spellings =
            t9UnconfirmedDeleteHistory.spellings.filter { digits.hasPrefix($0.key) }
        guard (2...3).contains(digits.count),
            let spelling = t9UnconfirmedDeleteHistory.spellings[digits],
            isFullT9Spelling(spelling, for: digits),
            state.t9PinyinPathState.compactPaths.contains(where: {
                $0.kind == .completeSyllable && $0.consumedSlotCount == digits.count
                    && $0.displayText == spelling
            })
        else { return nil }
        return spelling
    }

    /// Rebind a soft preference to a currently issued ID without changing rank.
    func t9HistoricalProvisionalPathID(in pathState: T9PinyinPathState) -> String? {
        guard canUseT9UnconfirmedHistory,
            t9UnconfirmedDeleteHistory.namespace == t9HistoryNamespace,
            let preferred = t9UnconfirmedDeleteHistory.preferred,
            pathState.segmentSourceDigits == preferred.digits,
            pathState.selectedPath == nil, pathState.confirmedSegmentValues.isEmpty,
            state.lastRimeOutput?.rawInput == preferred.spelling
        else { return nil }
        return pathState.compactPaths.first(where: {
            $0.kind == .completeSyllable && $0.consumedSlotCount == preferred.digits.count
                && $0.displayText == preferred.spelling
        })?.id
    }
}
