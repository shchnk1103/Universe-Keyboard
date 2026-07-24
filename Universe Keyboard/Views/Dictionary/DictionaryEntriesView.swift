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
                LoadingStateView(message: loadingText)
            } else if entries.isEmpty, !isLoading {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: query.isEmpty ? "暂无可预览词条" : "未找到匹配词条",
                    message: query.isEmpty
                        ? "选择词典文件后可在这里预览词条。"
                        : "试试更短的关键词，或清空搜索。",
                    symbolFont: .title3,
                    titleFont: .subheadline,
                    messageFont: .caption,
                    verticalPadding: 16
                )
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
