import KeyboardCore
import SwiftUI
import UIKit

/// 键盘诊断日志子页面。业务状态和持久化边界由 `DiagnosticsStore` 管理。
struct DiagnosticsView: View {
    @State private var store = DiagnosticsStore()
    @State private var showClearConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            if !store.lines.isEmpty {
                DiagnosticsSummaryBar(
                    recordCount: store.lines.count,
                    slowEventCount: store.slowEventCount,
                    warningCount: store.warningCount,
                    selectedFilter: store.selectedSummaryFilter,
                    onSelect: selectSummaryFilter
                )

                DiagnosticsFilterBar(
                    options: store.filterOptions,
                    selectedCategory: store.selectedCategory,
                    onSelect: selectCategory
                )
            }

            DiagnosticsLogContentView(
                hasLoggedLines: !store.lines.isEmpty,
                selectionDescription: store.selectionDescription,
                filteredCount: store.filteredLines.count,
                totalCount: store.lines.count,
                displayedLines: store.displayedLines,
                colorTokenForLine: store.colorForLine
            )
        }
        .navigationTitle("键盘诊断")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            DiagnosticsToolbar(
                isRefreshing: store.isRefreshing,
                canCopy: !store.filteredLines.isEmpty,
                canClear: !store.lines.isEmpty && !store.isClearing,
                onRefresh: store.refresh,
                onCopy: copyLog,
                onClear: requestClear
            )
        }
        .alert("确认清空", isPresented: $showClearConfirm) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive, action: store.performClear)
        } message: {
            Text("清空后诊断日志将永久删除，无法恢复。")
        }
        .onAppear(perform: store.loadLog)
    }

    private func selectSummaryFilter(_ filter: DiagnosticsStore.SummaryFilter) {
        withAnimation(.easeInOut(duration: 0.15)) {
            store.selectSummaryFilter(filter)
        }
    }

    private func selectCategory(_ category: Logger.Category?) {
        withAnimation(.easeInOut(duration: 0.15)) {
            store.selectCategory(category)
        }
    }

    private func copyLog() {
        UIPasteboard.general.string = store.exportText
    }

    private func requestClear() {
        showClearConfirm = true
    }
}

#Preview {
    NavigationStack {
        DiagnosticsView()
    }
}
