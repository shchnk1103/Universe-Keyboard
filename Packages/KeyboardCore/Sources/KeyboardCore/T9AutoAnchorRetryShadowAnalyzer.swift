#if DEBUG
import Foundation

/// Read-only result for a possible later anchor after the one S2 transaction
/// has already rejected and restored the pure-digit composition.
public struct T9AutoAnchorRetryShadowObservation: Equatable, Sendable {
    public enum Status: String, Equatable, Sendable {
        case proposalReady
        case notEligible
    }

    public let status: Status
    public let sourceDigitCount: Int
    public let rejectedAtSourceDigitCount: Int
    public let candidateCount: Int
    public let anchoredSlotCount: Int
    public let unresolvedSlotCount: Int
}

/// Stage 3 observer for later opportunities after an S2 rejection.
///
/// It deliberately reuses the pure S2 proposal policy against an already
/// returned snapshot. It never invokes RIME, validates replacement candidates,
/// changes the one-attempt ledger or authorizes another transaction.
public enum T9AutoAnchorRetryShadowAnalyzer {
    public static func analyze(
        rejectedAtSourceDigits: String,
        currentSourceDigits: String?,
        output: RimeOutput?
    ) -> T9AutoAnchorRetryShadowObservation? {
        guard !rejectedAtSourceDigits.isEmpty,
              let currentSourceDigits,
              currentSourceDigits.count > rejectedAtSourceDigits.count,
              let output
        else {
            return nil
        }

        let proposal = T9ReversibleAutoAnchorPolicy.proposal(
            sourceDigits: currentSourceDigits,
            output: output
        )
        return T9AutoAnchorRetryShadowObservation(
            status: proposal == nil ? .notEligible : .proposalReady,
            sourceDigitCount: currentSourceDigits.count,
            rejectedAtSourceDigitCount: rejectedAtSourceDigits.count,
            candidateCount: output.candidates.count,
            anchoredSlotCount: proposal?.anchoredSlotCount ?? 0,
            unresolvedSlotCount: proposal?.unresolvedSlotCount
                ?? currentSourceDigits.count
        )
    }
}

extension KeyboardController {
    /// Returns a content-free later-opportunity observation without changing
    /// KeyboardState or crossing the RIME boundary.
    public func t9AutoAnchorRetryShadowObservation()
        -> T9AutoAnchorRetryShadowObservation?
    {
        let anchorState = state.t9ReversibleAutoAnchorState
        guard isReversibleT9AutoAnchorEnabled,
              usesT9InputSemantics,
              anchorState.phase == .rejected,
              state.partialCommit == nil,
              state.t9PinyinPathState.selectedPath == nil,
              state.t9PinyinPathState.confirmedSegmentValues.isEmpty
        else {
            return nil
        }

        let output = state.lastRimeOutput
        // A successful S2 rejection restores pure digits. Prefer that live raw
        // identity so a stale presentation snapshot cannot fabricate progress.
        let currentSourceDigits =
            T9PinyinPathExtractor.pureDigitRaw(output?.rawInput)
        return T9AutoAnchorRetryShadowAnalyzer.analyze(
            rejectedAtSourceDigits: anchorState.sourceDigits,
            currentSourceDigits: currentSourceDigits,
            output: output
        )
    }
}
#endif
