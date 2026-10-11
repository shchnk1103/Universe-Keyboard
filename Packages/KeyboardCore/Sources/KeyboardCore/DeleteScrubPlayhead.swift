/// Content-free mapping from horizontal finger displacement to delete units.
///
/// Product contract: origin is the press x; leftward distance sets how many
/// committed graphemes this hold has removed; rightward restores from the
/// in-memory ledger. Speed is ignored. The playhead never stores host text.
public struct DeleteScrubPlayhead: Equatable, Sendable {
    public static let horizontalLockPoints: Double = 10
    public static let unitWidthPoints: Double = 10
    public static let ledgerCap = 64
    public static let clearAllCap = 256

    public var originX: Double
    public var appliedUnits: Int

    public init(originX: Double, appliedUnits: Int = 0) {
        self.originX = originX
        self.appliedUnits = appliedUnits
    }

    public func isHorizontallyLocked(at currentX: Double) -> Bool {
        abs(originX - currentX) >= Self.horizontalLockPoints
    }

    public func isLeftwardLocked(at currentX: Double) -> Bool {
        (originX - currentX) >= Self.horizontalLockPoints
    }

    /// Left of origin counts deleted units; right of origin is zero (full restore).
    public func targetUnits(at currentX: Double) -> Int {
        let leftward = originX - currentX
        guard leftward > 0 else { return 0 }
        return min(Self.ledgerCap, Int(leftward / Self.unitWidthPoints))
    }

    public mutating func setAppliedUnits(_ units: Int) {
        appliedUnits = max(0, min(Self.ledgerCap, units))
    }
}
