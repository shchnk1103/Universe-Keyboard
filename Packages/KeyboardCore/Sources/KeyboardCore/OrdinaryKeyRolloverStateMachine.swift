import Foundation

/// Immutable key payload captured when a touch first lands on an ordinary key face.
/// Freezing this at `began` ensures a `Shift.singleUse` reset or title refresh caused
/// by an overlapping second key never mutates the first key's pending character.
public struct FrozenOrdinaryKeyPayload: Equatable, Sendable {
    public let rawKey: String
    public let effectiveText: String
    public let isT9Digit: Bool

    public init(rawKey: String, effectiveText: String, isT9Digit: Bool = false) {
        self.rawKey = rawKey
        self.effectiveText = effectiveText
        self.isT9Digit = isT9Digit
    }
}

/// Side effects emitted by `OrdinaryKeyRolloverStateMachine` in strict execution order.
public enum OrdinaryKeyRolloverEffect<ButtonID: Hashable & Sendable>: Equatable, Sendable {
    case dismissVariantAndSuppressLongPress(buttonID: ButtonID)
    case consumeKey(buttonID: ButtonID, payload: FrozenOrdinaryKeyPayload)
    case suppressLongPress(buttonID: ButtonID)
    case clearHighlight(buttonID: ButtonID)
}

/// Deterministic press-order rollover state machine for ordinary character keys
/// (26-key English/Chinese letters, text-row character keys, and nine-key `2–9`).
///
/// Key gaps (`KeyboardTouchCellControl`) and function keys (Shift, Delete, Space,
/// Return, page/mode switches) are intentionally excluded.
public struct OrdinaryKeyRolloverStateMachine<
    TouchID: Hashable & Sendable,
    ButtonID: Hashable & Sendable
>: Sendable {
    public enum Phase: Equatable, Sendable {
        case pending
        case variantOwned
        case consumed
    }

    public struct ActiveTouch: Equatable, Sendable {
        public let touchID: TouchID
        public let buttonID: ButtonID
        public let pressID: UInt64
        public let epoch: UInt64
        public var phase: Phase
        public let payload: FrozenOrdinaryKeyPayload
    }

    public private(set) var sessionEpoch: UInt64 = 0
    private var nextPressID: UInt64 = 0
    private var activeTouches: [TouchID: ActiveTouch] = [:]

    public init() {}

    public var activeTouchCount: Int {
        activeTouches.count
    }

    public func phase(forButtonID buttonID: ButtonID) -> Phase? {
        activeTouches.values.first { $0.buttonID == buttonID }?.phase
    }

    /// Consumes any `.pending` or `.variantOwned` preceding touches before an incoming
    /// second key resolves its own payload (e.g. so `Shift.singleUse` consumed by the
    /// first key updates Shift state before the second key freezes its character).
    public mutating func consumePrecedingTouchesIfNeeded(
        incomingTouchID: TouchID,
        incomingButtonID: ButtonID
    ) -> [OrdinaryKeyRolloverEffect<ButtonID>] {
        if activeTouches[incomingTouchID] != nil
            || activeTouches.values.contains(where: { $0.buttonID == incomingButtonID })
        {
            return []
        }

        let unconsumed = activeTouches.values
            .filter { $0.phase == .pending || $0.phase == .variantOwned }
            .sorted { $0.pressID < $1.pressID }

        guard !unconsumed.isEmpty else { return [] }

        var effects: [OrdinaryKeyRolloverEffect<ButtonID>] = []
        for entry in unconsumed where entry.phase == .variantOwned {
            effects.append(.dismissVariantAndSuppressLongPress(buttonID: entry.buttonID))
        }
        for entry in unconsumed {
            if entry.phase == .variantOwned {
                // Tracking was already cancelled when entering `.variantOwned`, and the
                // long-press recognizer is invalidated below, so no `endTracking` will arrive.
                activeTouches.removeValue(forKey: entry.touchID)
            } else {
                activeTouches[entry.touchID]?.phase = .consumed
            }
            effects.append(.consumeKey(buttonID: entry.buttonID, payload: entry.payload))
            if entry.phase == .pending {
                effects.append(.suppressLongPress(buttonID: entry.buttonID))
            }
        }
        return effects
    }

    public mutating func began(
        touchID: TouchID,
        buttonID: ButtonID,
        payload: FrozenOrdinaryKeyPayload,
        forceImmediateConsume: Bool = false
    ) -> [OrdinaryKeyRolloverEffect<ButtonID>] {
        // Same-key two-finger overlap (PF-063) is ignored without disturbing the active touch.
        if activeTouches[touchID] != nil
            || activeTouches.values.contains(where: { $0.buttonID == buttonID })
        {
            return []
        }

        nextPressID &+= 1
        let pressID = nextPressID

        if activeTouches.isEmpty, !forceImmediateConsume {
            activeTouches[touchID] = ActiveTouch(
                touchID: touchID,
                buttonID: buttonID,
                pressID: pressID,
                epoch: sessionEpoch,
                phase: .pending,
                payload: payload
            )
            return []
        }

        var effects = consumePrecedingTouchesIfNeeded(
            incomingTouchID: touchID,
            incomingButtonID: buttonID
        )

        activeTouches[touchID] = ActiveTouch(
            touchID: touchID,
            buttonID: buttonID,
            pressID: pressID,
            epoch: sessionEpoch,
            phase: .consumed,
            payload: payload
        )
        effects.append(.consumeKey(buttonID: buttonID, payload: payload))
        effects.append(.suppressLongPress(buttonID: buttonID))
        return effects
    }

    public mutating func endedInside(
        touchID: TouchID,
        epoch: UInt64
    ) -> [OrdinaryKeyRolloverEffect<ButtonID>] {
        guard epoch == sessionEpoch,
            let entry = activeTouches[touchID],
            entry.epoch == sessionEpoch
        else {
            return []
        }

        activeTouches.removeValue(forKey: touchID)
        switch entry.phase {
        case .pending:
            return [
                .consumeKey(buttonID: entry.buttonID, payload: entry.payload),
                .clearHighlight(buttonID: entry.buttonID),
            ]
        case .variantOwned, .consumed:
            return [.clearHighlight(buttonID: entry.buttonID)]
        }
    }

    public mutating func dragExit(
        touchID: TouchID,
        epoch: UInt64
    ) -> [OrdinaryKeyRolloverEffect<ButtonID>] {
        guard epoch == sessionEpoch,
            let entry = activeTouches[touchID],
            entry.epoch == sessionEpoch
        else {
            return []
        }

        switch entry.phase {
        case .pending:
            activeTouches.removeValue(forKey: touchID)
            return [.clearHighlight(buttonID: entry.buttonID)]
        case .consumed:
            return [.clearHighlight(buttonID: entry.buttonID)]
        case .variantOwned:
            return []
        }
    }

    public mutating func endedOutside(
        touchID: TouchID,
        epoch: UInt64
    ) -> [OrdinaryKeyRolloverEffect<ButtonID>] {
        guard epoch == sessionEpoch,
            let entry = activeTouches[touchID],
            entry.epoch == sessionEpoch
        else {
            return []
        }
        activeTouches.removeValue(forKey: touchID)
        return [.clearHighlight(buttonID: entry.buttonID)]
    }

    public mutating func uiButtonCancelTracking(
        touchID: TouchID?,
        buttonID: ButtonID,
        epoch: UInt64
    ) -> [OrdinaryKeyRolloverEffect<ButtonID>] {
        guard epoch == sessionEpoch else { return [] }
        let matched: ActiveTouch?
        if let touchID {
            matched = activeTouches[touchID]
        } else {
            matched = activeTouches.values.first { $0.buttonID == buttonID }
        }
        guard let entry = matched, entry.epoch == sessionEpoch else { return [] }

        // Per r3 §1: UIButton.cancelTracking fired during long-press takeover is a no-op
        // once the touch has atomically transferred to `.variantOwned`.
        if entry.phase == .variantOwned {
            return []
        }

        activeTouches.removeValue(forKey: entry.touchID)
        return [.clearHighlight(buttonID: entry.buttonID)]
    }

    /// Atomically transfers a `.pending` touch on `buttonID` to `.variantOwned`.
    /// Returns `false` if the touch was already `.consumed` (e.g. by a second key press).
    public mutating func longPressBegan(buttonID: ButtonID) -> Bool {
        guard let entry = activeTouches.values.first(where: { $0.buttonID == buttonID }),
            entry.epoch == sessionEpoch,
            entry.phase == .pending
        else {
            return false
        }
        activeTouches[entry.touchID]?.phase = .variantOwned
        return true
    }

    /// Rolls back `.variantOwned` if the UI failed to present a variant popup.
    public mutating func rollbackVariantOwnership(buttonID: ButtonID) {
        guard
            let entry = activeTouches.values.first(where: {
                $0.buttonID == buttonID && $0.phase == .variantOwned
            })
        else {
            return
        }
        activeTouches.removeValue(forKey: entry.touchID)
    }

    /// Completes or cancels a `.variantOwned` long press. Returns `false` if the touch
    /// was already interrupted and consumed by another key press.
    public mutating func variantEndedOrCancelled(buttonID: ButtonID) -> Bool {
        guard
            let entry = activeTouches.values.first(where: {
                $0.buttonID == buttonID && $0.phase == .variantOwned
            })
        else {
            return false
        }
        activeTouches.removeValue(forKey: entry.touchID)
        return true
    }

    public mutating func invalidateAll() -> [OrdinaryKeyRolloverEffect<ButtonID>] {
        sessionEpoch &+= 1
        let sorted = activeTouches.values.sorted { $0.pressID < $1.pressID }
        var effects: [OrdinaryKeyRolloverEffect<ButtonID>] = []
        for entry in sorted {
            if entry.phase == .variantOwned {
                effects.append(.dismissVariantAndSuppressLongPress(buttonID: entry.buttonID))
            }
            effects.append(.clearHighlight(buttonID: entry.buttonID))
        }
        activeTouches.removeAll()
        return effects
    }
}
