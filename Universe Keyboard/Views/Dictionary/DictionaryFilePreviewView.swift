import SwiftUI

struct DictionaryFilePreviewView: View {
    let file: LocalDictionaryFile
    @State private var model: LocalDictionaryPreviewModel

    init(file: LocalDictionaryFile, indexService: any DictionaryIndexServicing) {
        self.file = file
        _model = State(
            initialValue: LocalDictionaryPreviewModel(file: file, indexService: indexService)
        )
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 0) {
                    DictionaryMetricView(value: file.formattedEntryCount, label: "词条数量")
                    Divider().frame(height: 34)
                    DictionaryMetricView(value: file.formattedSize, label: "文件大小")
                }
                .padding(.vertical, 4)
            } header: {
                Text(file.relativePath)
            }

            DictionaryEntriesView(
                entries: model.entries,
                query: model.query,
                isLoading: model.isLoading,
                footerText: model.entriesFooter(),
                previewTitle: "词条预览",
                loadingText: "正在载入预览"
            )
        }
        .navigationTitle(file.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $model.query, prompt: "在此词典中搜索")
        .onChange(of: model.query) { _, query in
            model.scheduleRefresh(query: query)
        }
        .tint(.primary)
        .task {
            model.loadIfNeeded()
        }
    }
}
