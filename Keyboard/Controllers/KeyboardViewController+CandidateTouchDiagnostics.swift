import KeyboardCore
import QuartzCore

#if DEBUG
    extension KeyboardViewController: CandidateTouchDiagnosticSink {
        /// Starts one content-free correlation chain for a UIKit candidate-bar touch.
        /// The callback is invoked after hit-testing and never changes the chosen view.
        func recordCandidateTouchRouted(
            band: DiagnosticEvent.CandidateTouchBand,
            didHitCell: Bool
        ) {
            guard isHighFidelityDiagnosticsActive else { return }
            candidateTouchDiagnosticSequence &+= 1
            let sequence = candidateTouchDiagnosticSequence
            activeCandidateTouchDiagnosticSequence = sequence
            activeCandidateTouchDiagnosticBand = band
            activeCandidateTouchDiagnosticDidHitCell = didHitCell
            activeCandidateTouchDiagnosticStartTime = CACurrentMediaTime()
            diagnosticsJournal.record(
                code: .candidateTouchRouted,
                category: .display,
                appearanceID: diagnosticsAppearanceID,
                actionSequence: sequence,
                fields: [
                    .count(.candidateTouchBand, band.rawValue),
                    .flag(.didHitCandidateCell, didHitCell),
                ]
            )
        }

        func recordCandidateGestureTerminal(didBegin: Bool, wasCancelled: Bool) {
            guard isHighFidelityDiagnosticsActive,
                let sequence = activeCandidateTouchDiagnosticSequence,
                isCandidateTouchDiagnosticCorrelationFresh(maximumAge: 5)
            else { return }
            diagnosticsJournal.record(
                code: .candidateGestureTerminal,
                category: .display,
                appearanceID: diagnosticsAppearanceID,
                actionSequence: sequence,
                fields: [
                    .flag(.didCandidatePanBegin, didBegin),
                    .flag(.wasCandidateTouchCancelled, wasCancelled),
                ]
            )
            // A recognized/cancelled pan cannot also become a candidate selection.
            // A failed pan over a cell is retained briefly because UIKit delivers
            // didSelectItemAt after the recognizer has failed for an ordinary tap.
            if didBegin || wasCancelled || !activeCandidateTouchDiagnosticDidHitCell {
                resetCandidateTouchDiagnosticCorrelation()
            }
        }

        func recordCandidateSelectionDelivered() {
            guard isHighFidelityDiagnosticsActive,
                let sequence = activeCandidateTouchDiagnosticSequence,
                let band = activeCandidateTouchDiagnosticBand,
                activeCandidateTouchDiagnosticDidHitCell,
                isCandidateTouchDiagnosticCorrelationFresh(maximumAge: 2)
            else { return }
            diagnosticsJournal.record(
                code: .candidateSelectionDelivered,
                category: .display,
                appearanceID: diagnosticsAppearanceID,
                actionSequence: sequence,
                fields: [.count(.candidateTouchBand, band.rawValue)]
            )
            resetCandidateTouchDiagnosticCorrelation()
        }

        /// Prevents a later accessibility or programmatic selection from inheriting
        /// correlation state created by an earlier physical touch.
        func resetCandidateTouchDiagnosticCorrelation() {
            activeCandidateTouchDiagnosticSequence = nil
            activeCandidateTouchDiagnosticBand = nil
            activeCandidateTouchDiagnosticDidHitCell = false
            activeCandidateTouchDiagnosticStartTime = nil
        }

        private func isCandidateTouchDiagnosticCorrelationFresh(maximumAge: CFTimeInterval) -> Bool {
            guard let startTime = activeCandidateTouchDiagnosticStartTime else { return false }
            return CACurrentMediaTime() - startTime <= maximumAge
        }
    }
#endif
