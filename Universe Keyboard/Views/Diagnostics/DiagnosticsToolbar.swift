import SwiftUI

struct DiagnosticsToolbar: ToolbarContent {
    let isRefreshing: Bool
    let canCopy: Bool
    let canClear: Bool
    let onRefresh: () -> Void
    let onCopy: () -> Void
    let onClear: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(action: onRefresh) {
                if isRefreshing {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .accessibilityLabel("刷新日志")
            .disabled(isRefreshing)

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
            }
            .accessibilityLabel("复制当前日志")
            .disabled(!canCopy)

            Button(role: .destructive, action: onClear) {
                Image(systemName: "trash")
            }
            .accessibilityLabel("清空日志")
            .disabled(!canClear)
        }
    }
}
