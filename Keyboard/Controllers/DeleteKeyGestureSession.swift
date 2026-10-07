import KeyboardCore
import UIKit

enum DeleteKeyGesturePhase: Equatable {
    case pressed
    case scrubCommitted
    case composingCleared
    /// Horizontal lock that must not delete on lift. Used for a composing right swipe.
    case lockedWithoutDelete
    case repeating
    case exhausted
}

enum DeleteScrubStep: Equatable {
    /// Visible grapheme removed; safe to put on the in-memory restore ledger.
    case recorded(String)
    /// Host text is not readable (password). One delete was attempted; nothing is restored.
    case blind
    case stopped
}

/// In-process hold session. Discarded on lift, cancel, bounds exit, or disappear.
@MainActor
final class DeleteKeyGestureSession {
    let button: UIButton
    var phase: DeleteKeyGesturePhase
    var playhead: DeleteScrubPlayhead
    var restoreLedger: [String] = []
    var fingerInBubble = false
    var bubbleVisible = false
    var didVisitBubble = false

    init(button: UIButton, originX: CGFloat) {
        self.button = button
        self.phase = .pressed
        self.playhead = DeleteScrubPlayhead(originX: Double(originX))
    }

    func discardLedger() {
        restoreLedger.removeAll(keepingCapacity: false)
        playhead.appliedUnits = 0
    }
}
