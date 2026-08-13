import KeyboardCore
import SwiftUI
import UIKit

/// 键盘诊断日志子页面。业务状态和持久化边界由 `DiagnosticsStore` 管理。
struct DiagnosticsView: View {
    @State private var store = DiagnosticsStore()
    @State private var showClearConfirm = false
    @State private var isSearchPresented = false

    var body: some View {
        VStack(spacing: 0) {
            if !store.availableLogDays.isEmpty {
                DiagnosticsDayPicker(
                    days: store.availableLogDays,
                    selectedDay: store.selectedLogDay,
                    onSelect: store.selectLogDay
                )
            }

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
                exportLimitMessage: store.exportLimitMessage,
                hasMorePages: store.hasMorePages,
                isLoadingMore: store.isLoadingMore,
                pagingNotice: store.displayedNotice,
                isPartialWindow: store.isPartialWindow,
                colorTokenForLine: store.colorForLine,
                onLoadMore: store.loadMore
            )
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("键盘诊断")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: Binding(
                get: { store.searchQuery },
                set: store.updateSearchQuery
            ),
            isPresented: $isSearchPresented,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "搜索事件、分类或状态"
        )
        .onChange(of: isSearchPresented, initial: true) { _, presented in
            store.setSearchPresented(presented)
        }
        .toolbar {
            DiagnosticsToolbar(
                isRefreshing: store.isManualRefreshing,
                canCopy: store.canExportCurrentSelection,
                canClear: store.canClearLog,
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
        .onAppear {
            store.loadLog()
            store.startLiveRefresh()
        }
        .onDisappear(perform: store.stopLiveRefresh)
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
