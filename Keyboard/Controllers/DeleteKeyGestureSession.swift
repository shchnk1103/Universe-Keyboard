import KeyboardCore
import UIKit

enum DeleteKeyGesturePhase: Equatable {
    case pressed
    case scrubCommitted
    case composingCleared
    /// Horizontal lock that must not delete on lift. Used for a composing right swipe.
    case lockedWithoutDelete
    case repeating
    /// Scrub is off and this press has already stopped. Lift does not tap-delete.
    case leftKeyPending
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
    /// Captured at touchDown. Later settings edits apply to the next press.
    let holdFlags: DeleteKeyHoldFlags
    /// Scrub is off and the finger came back onto the delete key. This press
    /// cannot arm the trash bubble again.
    var returnedToDeleteKey = false

    init(
        button: UIButton,
        originX: CGFloat,
        holdFlags: DeleteKeyHoldFlags = .allEnabled
    ) {
        self.button = button
        self.phase = .pressed
        self.playhead = DeleteScrubPlayhead(originX: Double(originX))
        self.holdFlags = holdFlags
    }

    func discardLedger() {
        restoreLedger.removeAll(keepingCapacity: false)
        playhead.appliedUnits = 0
    }
}
