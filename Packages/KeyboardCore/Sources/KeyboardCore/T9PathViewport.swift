/// Computes the path bar's horizontal offset without platform UI dependencies.
public enum T9PathViewport {
    public static func offset(
        current: Double, viewportWidth: Double, contentWidth: Double,
        selectedStart: Double?, selectedEnd: Double?, selectedIndex: Int?,
        selectionChanged: Bool, listChanged: Bool
    ) -> Double {
        if listChanged || selectedIndex == nil { return 0 }
        guard selectionChanged, let start = selectedStart, let end = selectedEnd else { return current }
        if selectedIndex == 0 { return 0 }
        let target: Double
        if start < current {
            target = start
        } else if end > current + viewportWidth {
            target = end - viewportWidth
        } else {
            target = current
        }
        return max(0, min(target, max(0, contentWidth - viewportWidth)))
    }
}
