import SwiftUI

struct DictionaryOverviewView: View {
    let fileCount: Int
    let formattedEntryCount: String
    let formattedTotalSize: String
    let isLoading: Bool

    var body: some View {
        Section {
            HStack(spacing: 0) {
                DictionaryMetricView(value: "\(fileCount)", label: "词典文件")
                Divider().frame(height: 34)
                DictionaryMetricView(value: formattedEntryCount, label: "词条数量")
                Divider().frame(height: 34)
                DictionaryMetricView(value: formattedTotalSize, label: "占用空间")
            }
            .padding(.vertical, 4)

            if isLoading {
                LoadingStateView(message: "正在读取词典")
            }
        } header: {
            Text("概览")
        }
    }
}
