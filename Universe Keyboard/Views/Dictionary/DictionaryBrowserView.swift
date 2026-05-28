import Observation
import SwiftUI

struct DictionaryBrowserView: View {
    @State private var model = LocalDictionaryModel.shared

    var body: some View {
        List {
            if model.files.isEmpty, !model.isLoading {
                DictionaryEmptyStateView()
            } else {
                DictionaryOverviewView(
                    fileCount: model.files.count,
                    formattedEntryCount: model.formattedEntryCount,
                    formattedTotalSize: model.formattedTotalSize,
                    isLoading: model.isLoading
                )
                DictionaryFilesView(files: model.files, indexService: model.indexService)
                DictionaryEntriesView(
                    entries: model.entries,
                    query: model.query,
                    isLoading: model.isLoading,
                    footerText: model.entriesFooter(searching: !model.query.isEmpty),
                    previewTitle: "综合预览"
                )
            }
        }
        .navigationTitle("本地词典")
        .searchable(text: $model.query, prompt: "搜索词语或编码")
        .onChange(of: model.query) { _, query in
            model.scheduleRefresh(query: query)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    model.refresh(query: model.query)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("刷新词典")
            }
        }
        .tint(.primary)
        .task {
            model.loadIfNeeded()
        }
    }
}

#Preview {
    NavigationStack {
        DictionaryBrowserView()
    }
}
