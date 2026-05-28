import SwiftUI

struct DictionaryEmptyStateView: View {
    var body: some View {
        Section {
            VStack(spacing: 10) {
                Image(systemName: "character.book.closed")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("尚未找到本地词典")
                    .font(.headline)
                Text("打开一次键盘完成初始化后，可在这里查看已安装的 RIME 词典。")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
    }
}
