import Foundation

// MARK: - Rem-3 provisional L1 (visual shadow anchor)

/// Content-free skip reasons for dual-gate provisional composition (closed set).
public enum ResponsiveProvisionalL1SkipReason: String, Sendable, Equatable {
    case unsafe
    case nonT9 = "non_t9"
    case emptyLedger = "empty_ledger"
    case gateOff = "gate_off"
    case noDual = "no_dual"
}

/// Host-visible provisional presentation (never digits / Chinese / pinyin).
public struct ResponsiveProvisionalPresentation: Sendable, Equatable {
    public let preedit: String
    /// The last host-visible L2 marked text retained as the visual shadow prefix.
    /// This is presentation-only and never becomes RIME input authority.
    public let stablePreedit: String
    public let slotCount: Int
    public let sessionEpoch: UInt64
    /// Highest accept revision covered by the ledger (watermark floor for L2).
    public let watermark: UInt64

    public init(
        preedit: String,
        slotCount: Int,
        sessionEpoch: UInt64,
        watermark: UInt64,
        stablePreedit: String = ""
    ) {
        self.preedit = preedit
        self.stablePreedit = stablePreedit
        self.slotCount = slotCount
        self.sessionEpoch = sessionEpoch
        self.watermark = watermark
    }
}

/// Pure builder + MainActor-owned mirror for dual-gate L1 (Amendment B).
///
/// The host string is the last stable L2 marked text followed by U+00B7 MIDDLE
/// DOT repeated per accepted T9 digit slot still pending at L1.
public enum ResponsiveProvisionalComposition: Sendable {
    /// Fixed content-free placeholder (not a digit, not a pinyin letter).
    public static let placeholderScalar: Character = "\u{00B7}"

    /// Default Rem-3-Polish delay before L1 visual paint (not a product SLO).
    public static let defaultVisualPaintDelayNanoseconds: UInt64 = 48_000_000

    /// True when `rimeKey` is a single ASCII digit suitable for T9 letter-group keys.
    public static func isT9DigitKey(_ rimeKey: String) -> Bool {
        guard rimeKey.count == 1, let scalar = rimeKey.unicodeScalars.first else {
            return false
        }
        return scalar.value >= 48 && scalar.value <= 57
    }

    /// Build `stablePreedit + (·×N)` or nil when N == 0.
    public static func presentation(
        slotCount: Int,
        sessionEpoch: UInt64,
        watermark: UInt64,
        stablePreedit: String = ""
    ) -> ResponsiveProvisionalPresentation? {
        guard slotCount > 0 else { return nil }
        let pendingDots = String(repeating: String(placeholderScalar), count: slotCount)
        return ResponsiveProvisionalPresentation(
            preedit: stablePreedit + pendingDots,
            slotCount: slotCount,
            sessionEpoch: sessionEpoch,
            watermark: watermark,
            stablePreedit: stablePreedit
        )
    }

    public static func l1SkipMarkerLine(reason: ResponsiveProvisionalL1SkipReason) -> String {
        "T9RESP marker=L1_SKIP reason=\(reason.rawValue) "
            + "fixture=\(ResponsiveRimeFeltMetrics.fixtureID)"
    }
}

/// Accumulated provisional raw slots between L0 accepts and L2 apply.
public struct ResponsiveProvisionalCompositionMirror: Sendable, Equatable {
    public private(set) var sessionEpoch: UInt64 = 0
    public private(set) var slotCount: Int = 0
    public private(set) var watermark: UInt64 = 0
    /// Last host-visible L2 marked text. Cleared only by an epoch/reset barrier.
    public private(set) var stablePreedit: String = ""
    public private(set) var isActive: Bool = false

    public init() {}

    /// True when L1 holds progressive length ahead of a settled engine paint.
    public var isProvisionalAhead: Bool {
        isActive && slotCount > 0
    }

    public mutating func clear() {
        sessionEpoch = 0
        slotCount = 0
        watermark = 0
        stablePreedit = ""
        isActive = false
    }

    /// Clear pending L1 slots while retaining the last stable L2 display.
    /// Called when a live engine snapshot is about to replace the shadow.
    public mutating func clearPending() {
        sessionEpoch = 0
        slotCount = 0
        watermark = 0
        isActive = false
    }

    /// Record the latest host-visible L2 marked text. A placeholder is never a
    /// stable anchor; fail closed rather than stacking provisional dots.
    public mutating func setStablePreedit(_ preedit: String) {
        stablePreedit = preedit.contains(ResponsiveProvisionalComposition.placeholderScalar)
            ? ""
            : preedit
    }

    /// Append one T9 digit accept. Returns skip reason if not applicable.
    public mutating func appendT9DigitAccept(
        revision: UInt64,
        epoch: UInt64
    ) -> ResponsiveProvisionalL1SkipReason? {
        if sessionEpoch != 0, sessionEpoch != epoch {
            clear()
        }
        sessionEpoch = epoch
        slotCount += 1
        if revision > watermark {
            watermark = revision
        }
        isActive = true
        return nil
    }

    /// Clear pending L1 after a live L2 apply (atomic replace), retaining the
    /// stable prefix until the controller records the new host snapshot.
    public mutating func alignToEngineApply(epoch: UInt64, revision: UInt64) {
        _ = epoch
        _ = revision
        clearPending()
    }

    public func makePresentation() -> ResponsiveProvisionalPresentation? {
        guard isActive else { return nil }
        return ResponsiveProvisionalComposition.presentation(
            slotCount: slotCount,
            sessionEpoch: sessionEpoch,
            watermark: watermark,
            stablePreedit: stablePreedit
        )
    }
}
