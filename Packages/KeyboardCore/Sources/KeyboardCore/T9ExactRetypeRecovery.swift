import Foundation

/// R174's bounded policy. It plans work but never calls RIME or writes host text.
/// The controller must validate ownership and install one coherent snapshot.
struct T9ExactRetypeRecovery {
    struct Namespace: Equatable {
        let ownerID: UUID
        let sessionEpoch: UInt64
        let editingGeneration: UInt64
    }

    struct Interpretation: Equatable {
        let sourceDigits: String
        let syllables: [String]
        var spelling: String { syllables.joined() }
        var firstSyllableSlots: Int { syllables[0].count }

        /// The caller supplies the comment actually adopted by the visible snapshot,
        /// not an alternative found by scanning candidates for the desired spelling.
        init?(sourceDigits: String, adoptedComment: String?, visiblePreedit: String) {
            guard (3...5).contains(sourceDigits.count), Self.areDigits(sourceDigits),
                let path = T9PinyinPathExtractor.path(fromComment: adoptedComment)
            else { return nil }
            let segments = path.replacementRawInput.split(separator: "'").map(String.init)
            guard segments.count == 2, (2...3).contains(segments[0].count),
                (1...2).contains(segments[1].count),
                segments.allSatisfy({ T9PinyinSyllableCatalog.catalogRankBySyllable[$0] != nil }),
                let visible = T9PinyinPathExtractor.path(fromComment: visiblePreedit),
                visible.replacementRawInput.replacingOccurrences(of: "'", with: "") == segments.joined(),
                segments.joined().count == sourceDigits.count,
                zip(sourceDigits, segments.joined()).allSatisfy({
                    T9PinyinPathExtractor.keyLetters(forDigit: $0.0).contains($0.1)
                })
            else { return nil }
            self.sourceDigits = sourceDigits
            self.syllables = segments
        }

        static func areDigits(_ value: String) -> Bool {
            !value.isEmpty && value.allSatisfy { "23456789".contains($0) }
        }
    }

    struct RestoreRequest: Equatable {
        let interpretation: Interpretation
        let namespace: Namespace
    }

    private struct History {
        let original: Interpretation
        let namespace: Namespace
        var currentDigits: String
        var isRetyping = false
    }

    struct RecoveryRequest: Equatable {
        let id: UUID
        let namespace: Namespace
        let targetRawInput: String
        let startsNewComposition: Bool
        let requiresT9Semantics: Bool
    }

    enum Directive: Equatable {
        case normal
        case block
        case shiftOnly
        case abandonContext
        case cancelSegment
        case cancelAndSwitch
        case recover(RecoveryRequest)
    }

    enum Notice: Equatable {
        case waitingForEdit
        case failed
        case needsFreshSession
    }

    private enum Phase {
        case waitingForEdit
        case recovering(RecoveryRequest)
        case failed
        case needsFreshSession
    }

    private struct UntrustedSession {
        let namespace: Namespace
        let verifiedDigits: String
        var phase: Phase
    }

    private var history: History?
    private var untrusted: UntrustedSession?
    var hasHistory: Bool { history != nil }
    var isSessionUntrusted: Bool { untrusted != nil }
    var notice: Notice? {
        guard let untrusted else { return nil }
        switch untrusted.phase {
        case .waitingForEdit, .recovering: return .waitingForEdit
        case .failed: return .failed
        case .needsFreshSession: return .needsFreshSession
        }
    }

    mutating func clearHistory() { history = nil }

    /// Call only after the lifecycle has fenced/disposed the unknown session.
    /// Clearing this policy alone does not make a live RIME session trustworthy.
    mutating func abandonAfterSessionFence() {
        history = nil
        untrusted = nil
    }

    /// Advances only after a real, verified one-slot Delete. Failed Delete does
    /// not fabricate progress. The original interpretation is captured once.
    mutating func didDelete(
        from previousDigits: String, to digits: String,
        original: Interpretation?, namespace: Namespace
    ) {
        guard untrusted == nil else { return }
        if history == nil, let original, original.sourceDigits == previousDigits {
            history = History(original: original, namespace: namespace, currentDigits: previousDigits)
        }
        guard var entry = history, entry.namespace == namespace, !entry.isRetyping,
            entry.currentDigits == previousDigits,
            digits == String(previousDigits.dropLast()),
            digits.count >= entry.original.firstSyllableSlots,
            (1...2).contains(entry.original.sourceDigits.count - digits.count)
        else { history = nil; return }
        entry.currentDigits = digits
        history = entry
    }

    /// Consumes the one temporary record at the exact replay endpoint. The
    /// intermediate digit is ordinary input and never issues a restore request.
    mutating func didInsertDigit(
        _ key: String, from previousDigits: String, to digits: String, namespace: Namespace
    ) -> RestoreRequest? {
        guard untrusted == nil, var entry = history, entry.namespace == namespace,
            key.count == 1, Interpretation.areDigits(key), entry.currentDigits == previousDigits,
            entry.isRetyping || previousDigits.count == entry.original.firstSyllableSlots,
            digits == previousDigits + key, entry.original.sourceDigits.hasPrefix(digits)
        else { history = nil; return nil }
        if digits == entry.original.sourceDigits {
            history = nil
            return RestoreRequest(interpretation: entry.original, namespace: namespace)
        }
        entry.isRetyping = true
        entry.currentDigits = digits
        history = entry
        return nil
    }

    static func acceptsSoftOutput(_ output: RimeOutput, for request: RestoreRequest) -> Bool {
        guard output.committedText == nil, output.rawInput == request.interpretation.spelling,
            let preedit = output.composition?.preeditText,
            let adoptedComment = output.candidates.first?.comment,
            let interpretation = Interpretation(
                sourceDigits: request.interpretation.sourceDigits,
                adoptedComment: adoptedComment, visiblePreedit: preedit)
        else { return false }
        return interpretation == request.interpretation
    }

    /// `terminal` is also used for unexpected commit: it must not be followed
    /// by a rollback that pretends to undo the engine's internal side effects.
    mutating func freeze(verifiedDigits: String, namespace: Namespace, terminal: Bool) {
        history = nil
        guard (1...5).contains(verifiedDigits.count), Interpretation.areDigits(verifiedDigits) else {
            // Missing/invalid source cannot be replayed. Keep the session fenced
            // without storing malformed input or trapping the keyboard process.
            untrusted = UntrustedSession(namespace: namespace, verifiedDigits: "", phase: .failed)
            return
        }
        untrusted = UntrustedSession(
            namespace: namespace, verifiedDigits: verifiedDigits,
            phase: terminal ? .failed : .waitingForEdit)
    }

    /// Must be consulted before punctuation acceptance or any other host/session
    /// side effect, including public candidate and paging entry points.
    mutating func plan(
        for action: KeyboardAction, namespace: Namespace?, currentKeyboardType: KeyboardType
    ) -> Directive {
        guard let session = untrusted else { return .normal }
        guard namespace == session.namespace else { return .abandonContext }
        switch action {
        case .toggleShift: return .shiftOnly
        case .toggleInputMode, .togglePage: return .cancelAndSwitch
        case .keyboardTypeChanged(let type):
            return type == currentKeyboardType ? .block : .cancelAndSwitch
        case .insertKey(let key):
            guard key.count == 1, Interpretation.areDigits(key) else { return .block }
            switch session.phase {
            case .waitingForEdit:
                return beginRecovery(target: session.verifiedDigits + key, session: session, fresh: false)
            case .needsFreshSession:
                return beginRecovery(target: key, session: session, fresh: true)
            case .recovering, .failed: return .block
            }
        case .deleteBackward:
            switch session.phase {
            case .waitingForEdit:
                return beginRecovery(
                    target: String(session.verifiedDigits.dropLast()), session: session, fresh: false)
            case .failed, .needsFreshSession: return .cancelSegment
            case .recovering: return .block
            }
        default:
            // Candidates, Path, paging, commits, symbols and direct text cannot
            // consult the unknown live composition or flush the retained preedit.
            return .block
        }
    }

    /// This is session quarantine after an explicit cancellation, not a 26-key
    /// retype preference. No old T9 source may be replayed into a fallback schema.
    mutating func planFreshNonT9Key(_ key: String, namespace: Namespace?) -> Directive {
        guard let session = untrusted, namespace == session.namespace,
            case .needsFreshSession = session.phase, session.verifiedDigits.isEmpty,
            key.count == 1, key.unicodeScalars.allSatisfy({ (97...122).contains($0.value) })
        else { return .block }
        return beginRecovery(target: key, session: session, fresh: true, requiresT9: false)
    }

    private mutating func beginRecovery(
        target: String, session: UntrustedSession, fresh: Bool, requiresT9: Bool = true
    ) -> Directive {
        let request = RecoveryRequest(
            id: UUID(), namespace: session.namespace, targetRawInput: target, startsNewComposition: fresh,
            requiresT9Semantics: requiresT9)
        var updated = session
        updated.phase = .recovering(request)
        untrusted = updated
        return .recover(request)
    }

    /// Completes only this exact request and its one authorized epoch transition.
    /// A late result cannot release a newer freeze or an explicitly cancelled edit.
    mutating func completeRecovery(
        _ request: RecoveryRequest, output: RimeOutput,
        realizedNamespace: Namespace, sessionValid: Bool, usesT9Semantics: Bool
    ) -> Bool {
        guard let session = untrusted, case .recovering(let current) = session.phase,
            current == request
        else { return false }
        let identityMatches =
            realizedNamespace.ownerID == request.namespace.ownerID
            && realizedNamespace.editingGeneration == request.namespace.editingGeneration
            && realizedNamespace.sessionEpoch == request.namespace.sessionEpoch &+ 1
        let compositionMatches: Bool
        if request.targetRawInput.isEmpty {
            compositionMatches =
                (output.rawInput ?? "").isEmpty
                && output.composition == nil && output.candidates.isEmpty
        } else {
            compositionMatches =
                output.rawInput == request.targetRawInput
                && output.composition?.preeditText.isEmpty == false
        }
        if identityMatches, sessionValid, usesT9Semantics == request.requiresT9Semantics,
            compositionMatches, output.committedText == nil
        {
            untrusted = nil
            return true
        }
        // Only our authorized transition may rebind the retained failure. A
        // foreign document/owner identity must instead take the abandon path.
        untrusted = UntrustedSession(
            namespace: identityMatches ? realizedNamespace : session.namespace,
            verifiedDigits: session.verifiedDigits, phase: .failed)
        return false
    }

    /// Losing the adapter may cancel display ownership while the engine remains
    /// unknown. Retain a fresh-start fence without retaining any old input.
    mutating func discardRetainedComposition() {
        guard let untrusted else { history = nil; return }
        didCancelSegment(namespace: untrusted.namespace)
    }

    /// Called after the controller cancels only the owned, uncommitted segment.
    /// The unknown session stays quarantined until a verified fresh start.
    mutating func didCancelSegment(namespace: Namespace) {
        history = nil
        untrusted = UntrustedSession(namespace: namespace, verifiedDigits: "", phase: .needsFreshSession)
    }
}
