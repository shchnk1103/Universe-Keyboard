import Foundation

// MARK: - Rem-3 provisional L1 (structure-only)

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
    public let slotCount: Int
    public let sessionEpoch: UInt64
    /// Highest accept revision covered by the ledger (watermark floor for L2).
    public let watermark: UInt64

    public init(preedit: String, slotCount: Int, sessionEpoch: UInt64, watermark: UInt64) {
        self.preedit = preedit
        self.slotCount = slotCount
        self.sessionEpoch = sessionEpoch
        self.watermark = watermark
    }
}

/// Pure builder + MainActor-owned mirror for dual-gate L1 (design Amendment A).
///
/// v1 host string is U+00B7 MIDDLE DOT repeated per accepted T9 digit slot.
public enum ResponsiveProvisionalComposition: Sendable {
    /// Fixed structure-only placeholder (not a digit, not a pinyin letter).
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

    /// Build `·`×N or nil when N == 0.
    public static func presentation(
        slotCount: Int,
        sessionEpoch: UInt64,
        watermark: UInt64
    ) -> ResponsiveProvisionalPresentation? {
        guard slotCount > 0 else { return nil }
        let preedit = String(repeating: String(placeholderScalar), count: slotCount)
        return ResponsiveProvisionalPresentation(
            preedit: preedit,
            slotCount: slotCount,
            sessionEpoch: sessionEpoch,
            watermark: watermark
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
        isActive = false
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

    /// Clear L1 after a live L2 apply (atomic replace).
    public mutating func alignToEngineApply(epoch: UInt64, revision: UInt64) {
        _ = epoch
        _ = revision
        clear()
    }

    public func makePresentation() -> ResponsiveProvisionalPresentation? {
        guard isActive else { return nil }
        return ResponsiveProvisionalComposition.presentation(
            slotCount: slotCount,
            sessionEpoch: sessionEpoch,
            watermark: watermark
        )
    }
}
