import SwiftUI

struct DictionaryFilesView: View {
    let files: [LocalDictionaryFile]
    let indexService: any DictionaryIndexServicing

    var body: some View {
        Section {
            ForEach(files) { file in
                NavigationLink {
                    DictionaryFilePreviewView(file: file, indexService: indexService)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(file.displayName)
                                .font(.subheadline.weight(.medium))
                            Text(file.relativePath)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(file.formattedEntryCount)
                                .font(.subheadline)
                            Text(file.formattedSize)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        } header: {
            Text("词典文件")
        } footer: {
            Text("轻点词典文件可查看并搜索其中的词条。")
        }
    }
}
