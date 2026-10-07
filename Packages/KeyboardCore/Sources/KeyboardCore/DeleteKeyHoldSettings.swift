import Foundation

/// App Group switches for one delete-key hold.
///
/// A missing key stays on. `bool(forKey:)` would treat that absence as off,
/// which would silently disable the gestures already shipping.
public struct DeleteKeyHoldFlags: Equatable, Sendable {
    public static let trashBubbleKey = "delete_trash_bubble_enabled"
    public static let scrubKey = "delete_scrub_enabled"
    public static let composingAbandonKey = "delete_composing_abandon_enabled"

    public var trashBubbleEnabled: Bool
    public var scrubEnabled: Bool
    public var composingAbandonEnabled: Bool

    public static let allEnabled = DeleteKeyHoldFlags(
        trashBubbleEnabled: true,
        scrubEnabled: true,
        composingAbandonEnabled: true
    )

    public init(
        trashBubbleEnabled: Bool,
        scrubEnabled: Bool,
        composingAbandonEnabled: Bool
    ) {
        self.trashBubbleEnabled = trashBubbleEnabled
        self.scrubEnabled = scrubEnabled
        self.composingAbandonEnabled = composingAbandonEnabled
    }

    public static func load(from defaults: UserDefaults?) -> DeleteKeyHoldFlags {
        guard let defaults else { return .allEnabled }
        return DeleteKeyHoldFlags(
            trashBubbleEnabled: isEnabled(defaults, key: trashBubbleKey),
            scrubEnabled: isEnabled(defaults, key: scrubKey),
            composingAbandonEnabled: isEnabled(defaults, key: composingAbandonKey)
        )
    }

    private static func isEnabled(_ defaults: UserDefaults, key: String) -> Bool {
        guard defaults.object(forKey: key) != nil else { return true }
        return defaults.bool(forKey: key)
    }
}

/// Where the finger is after it has left the delete-key face.
public enum DeleteKeyOffKeyZone: Equatable, Sendable {
    /// The seam between the key and the trash bubble. Not a cancel yet.
    case crossingGap
    case inBubble
    case elsewhere
}

public enum DeleteKeyOutsideIntent: Equatable, Sendable {
    /// Keep the bubble up. Clear happens only when `inBubble` is true on lift.
    case seekBubble(inBubble: Bool)
    /// This press stops. Returning to the key does not resume repeat.
    case stopWithoutResume
}

public enum DeleteKeyHoldPolicy {
    /// Scrub-off only. A hidden bubble cannot be crossed into.
    public static func outsideKeyIntent(
        trashBubbleEnabled: Bool,
        bubbleVisible: Bool,
        zone: DeleteKeyOffKeyZone,
        returnedToKey: Bool = false
    ) -> DeleteKeyOutsideIntent {
        // Sliding back onto the delete key ends this press. A later trip
        // through the gap must not arm clear-on-lift again.
        guard !returnedToKey, trashBubbleEnabled, bubbleVisible else {
            return .stopWithoutResume
        }
        switch zone {
        case .inBubble:
            return .seekBubble(inBubble: true)
        case .crossingGap:
            return .seekBubble(inBubble: false)
        case .elsewhere:
            return .stopWithoutResume
        }
    }
}
