/// 用户期望的整数行高；不负责屏幕读取或持久化。
public struct KeyboardHeightSettings: Equatable, Sendable {
    public static let defaultRowHeight = 45
    public static let minimumRowHeight = 40

    public enum Orientation: Sendable {
        case portrait
        case landscape
    }

    public enum ResolutionError: Error, Equatable {
        case invalidGeometry
        case insufficientHeight
    }

    /// nil 表示没有保存值；夹取只影响显示，不修改此值。
    public private(set) var savedRowHeight: Int?

    public init(savedRowHeight: Int? = nil) {
        self.savedRowHeight = savedRowHeight
    }

    public mutating func save(rowHeight: Int) {
        savedRowHeight = rowHeight
    }

    /// 调用方应删除持久化键，而不是将默认行高写入存储。
    public mutating func reset() {
        savedRowHeight = nil
    }

    /// PB-008：无手动覆盖时按屏高比例连续自适应。
    ///
    /// `screenHeight` 传长边屏高（竖屏即整屏高，横屏传长边而非短边）。
    /// `baseFixed = fixedHeight − pathHeight` 是比例基准（路径栏按 S7 额外
    /// 预留，不拿行高去填）；`fixedHeight` 含路径，只用于 50% 上限。
    /// 竖屏 `adaptive = floor((screenHeight × 254 / 844 − baseFixed) / 4)`，
    /// 夹到 `[40, upper]`，`upper = floor((screenHeight × 0.5 − fixedHeight) / 4)`：
    /// `upper < 40` 抛 `insufficientHeight`；`adaptive < 40` 且 `upper ≥ 40`
    /// 时抬到 40；`adaptive > upper` 时压到 upper。
    /// 横屏不用短边做比例：`min(竖屏 adaptive(长边), 45)`。
    public func adaptiveRowHeight(
        orientation: Orientation,
        screenHeight: Double,
        fixedHeight: Double,
        pathHeight: Double
    ) throws -> Int {
        guard screenHeight.isFinite, screenHeight > 0,
            fixedHeight.isFinite, fixedHeight >= 0,
            pathHeight.isFinite, pathHeight >= 0, pathHeight <= fixedHeight
        else {
            throw ResolutionError.invalidGeometry
        }
        let baseFixed = fixedHeight - pathHeight
        let adaptive = ((screenHeight * 254 / 844 - baseFixed) / 4).rounded(.down)
        let upperBound = ((screenHeight * 0.5 - fixedHeight) / 4).rounded(.down)
        guard upperBound >= Double(Self.minimumRowHeight) else {
            throw ResolutionError.insufficientHeight
        }
        let portrait =
            adaptive < Double(Self.minimumRowHeight)
            ? Self.minimumRowHeight
            : (upperBound < adaptive ? Int(upperBound) : Int(adaptive))
        switch orientation {
        case .portrait: return portrait
        case .landscape: return min(portrait, Self.defaultRowHeight)
        }
    }

    /// fixedHeight 包含候选栏、路径栏、边距及间距，单位均为 pt。
    /// 横屏只应用行高上限，不使用竖屏的屏高比例。
    /// 供「已有绝对保存值」夹取使用；无保存值的自适应走 adaptiveRowHeight。
    public func effectiveRowHeight(
        orientation: Orientation,
        screenHeight: Double,
        fixedHeight: Double
    ) throws -> Int {
        let preferred = max(Self.minimumRowHeight, savedRowHeight ?? Self.defaultRowHeight)
        switch orientation {
        case .landscape:
            return min(preferred, Self.defaultRowHeight)
        case .portrait:
            guard screenHeight.isFinite, screenHeight > 0,
                fixedHeight.isFinite, fixedHeight >= 0
            else {
                throw ResolutionError.invalidGeometry
            }
            let upperBound = ((screenHeight * 0.5 - fixedHeight) / 4).rounded(.down)
            // 预算不足时不存在同时满足下限和封顶的解；交由调用方报告，不能静默破例。
            guard upperBound >= Double(Self.minimumRowHeight) else {
                throw ResolutionError.insufficientHeight
            }
            // 先比较再转换，避免极大屏高转 Int 溢出。
            return upperBound < Double(preferred) ? Int(upperBound) : preferred
        }
    }
}
