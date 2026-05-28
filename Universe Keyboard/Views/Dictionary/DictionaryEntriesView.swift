import SwiftUI

struct DictionaryEntriesView: View {
    let entries: [LocalDictionaryEntry]
    let query: String
    let isLoading: Bool
    let footerText: String
    let previewTitle: String
    var loadingText: String? = nil

    var body: some View {
        Section {
            if let loadingText, isLoading {
                ProgressView(loadingText)
            } else if entries.isEmpty, !isLoading {
                Text(query.isEmpty ? "暂无可预览词条" : "未找到匹配词条")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entries) { entry in
                    DictionaryEntryRowView(entry: entry)
                }
            }
        } header: {
            Text(query.isEmpty ? previewTitle : "搜索结果")
        } footer: {
            Text(footerText)
        }
    }
}
