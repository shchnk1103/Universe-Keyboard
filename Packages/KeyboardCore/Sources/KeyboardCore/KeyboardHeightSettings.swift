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

    /// fixedHeight 包含候选栏、路径栏、边距及间距，单位均为 pt。
    /// 横屏只应用行高上限，不使用竖屏的屏高比例。
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
