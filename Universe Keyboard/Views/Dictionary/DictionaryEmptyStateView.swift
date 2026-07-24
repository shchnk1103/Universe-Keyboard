import SwiftUI

struct DictionaryEmptyStateView: View {
    var body: some View {
        Section {
            EmptyStateView(
                systemImage: "character.book.closed",
                title: "尚未找到本地词典",
                message: "打开一次键盘完成初始化后，可在这里查看已安装的 RIME 词典。",
                verticalPadding: 24
            )
        }
    }
}
