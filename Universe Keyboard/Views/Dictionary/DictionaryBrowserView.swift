import SwiftUI
import Combine

struct DictionaryBrowserView: View {
    @ObservedObject private var model = LocalDictionaryViewModel.shared

    var body: some View {
        List {
            if model.files.isEmpty, !model.isLoading {
                emptyState
            } else {
                summarySection
                filesSection
                entriesSection
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

    private var emptyState: some View {
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

    private var summarySection: some View {
        Section {
            HStack(spacing: 0) {
                DictionaryMetric(value: "\(model.files.count)", label: "词典文件")
                Divider().frame(height: 34)
                DictionaryMetric(value: model.formattedEntryCount, label: "词条数量")
                Divider().frame(height: 34)
                DictionaryMetric(value: model.formattedTotalSize, label: "占用空间")
            }
            .padding(.vertical, 4)

            if model.isLoading {
                ProgressView("正在读取词典")
                    .font(.footnote)
            }
        } header: {
            Text("概览")
        }
    }

    private var filesSection: some View {
        Section {
            ForEach(model.files) { file in
                NavigationLink {
                    DictionaryFilePreviewView(file: file)
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

    private var entriesSection: some View {
        Section {
            if model.entries.isEmpty, !model.isLoading {
                Text(model.query.isEmpty ? "暂无可预览词条" : "未找到匹配词条")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.entries) { entry in
                    DictionaryEntryRow(entry: entry)
                }
            }
        } header: {
            Text(model.query.isEmpty ? "综合预览" : "搜索结果")
        } footer: {
            Text(model.entriesFooter(searching: !model.query.isEmpty))
        }
    }
}

private struct DictionaryFilePreviewView: View {
    let file: LocalDictionaryFile
    @State private var entries: [LocalDictionaryEntry] = []
    @State private var query = ""
    @State private var isLoading = true
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        List {
            Section {
                HStack(spacing: 0) {
                    DictionaryMetric(value: file.formattedEntryCount, label: "词条数量")
                    Divider().frame(height: 34)
                    DictionaryMetric(value: file.formattedSize, label: "文件大小")
                }
                .padding(.vertical, 4)
            } header: {
                Text(file.relativePath)
            }

            Section {
                if isLoading {
                    ProgressView("正在载入预览")
                } else if entries.isEmpty {
                    Text(query.isEmpty ? "暂无可预览词条" : "未找到匹配词条")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(entries) { entry in
                        DictionaryEntryRow(entry: entry)
                    }
                }
            } header: {
                Text(query.isEmpty ? "词条预览" : "搜索结果")
            } footer: {
                Text(entries.count == 120 ? "最多显示前 120 个词条。" : "当前显示 \(entries.count) 个词条。")
            }
        }
        .navigationTitle(file.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "在此词典中搜索")
        .onChange(of: query) { _, newValue in
            loadPreview(query: newValue, delayed: true)
        }
        .tint(.primary)
        .task {
            loadPreview(query: "", delayed: false)
        }
    }

    private func loadPreview(query: String, delayed: Bool) {
        searchTask?.cancel()
        searchTask = Task {
            if delayed {
                try? await Task.sleep(for: .milliseconds(180))
            }
            guard !Task.isCancelled else { return }
            isLoading = true
            let result = await Task.detached(priority: .userInitiated) {
                DictionaryScanner.preview(fileID: file.id, query: query)
            }.value
            guard !Task.isCancelled else { return }
            entries = result
            isLoading = false
        }
    }
}

private struct DictionaryEntryRow: View {
    let entry: LocalDictionaryEntry

    var body: some View {
        HStack {
            Text(entry.text)
                .font(.body)
            Spacer(minLength: 12)
            Text(entry.code)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            if let weight = entry.weight {
                Text(weight)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct DictionaryMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.headline.monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LocalDictionaryFile: Identifiable, Sendable {
    let id: String
    let displayName: String
    let relativePath: String
    let byteCount: Int64
    let entryCount: Int

    var formattedEntryCount: String { entryCount.formatted() + " 条" }
    var formattedSize: String { ByteCountFormatter.string(fromByteCount: byteCount, countStyle: .file) }
}

private struct LocalDictionaryEntry: Identifiable, Sendable {
    let id: String
    let text: String
    let code: String
    let weight: String?
}

private struct DictionarySnapshot: Sendable {
    let files: [LocalDictionaryFile]
    let entries: [LocalDictionaryEntry]
    let totalEntries: Int
    let totalBytes: Int64
}

@MainActor
private final class LocalDictionaryViewModel: ObservableObject {
    static let shared = LocalDictionaryViewModel()

    @Published var files: [LocalDictionaryFile] = []
    @Published var entries: [LocalDictionaryEntry] = []
    @Published var totalEntries = 0
    @Published var totalBytes: Int64 = 0
    @Published var isLoading = false
    @Published var query = ""

    private var pendingTask: Task<Void, Never>?
    private var hasLoaded = false

    var formattedEntryCount: String { totalEntries.formatted() }
    var formattedTotalSize: String { ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file) }

    func loadIfNeeded() {
        guard !hasLoaded else { return }
        refresh(query: query)
    }

    func scheduleRefresh(query: String) {
        pendingTask?.cancel()
        pendingTask = Task {
            try? await Task.sleep(for: .milliseconds(220))
            guard !Task.isCancelled else { return }
            refresh(query: query)
        }
    }

    func refresh(query: String) {
        pendingTask?.cancel()
        isLoading = true

        pendingTask = Task {
            let snapshot = await Task.detached(priority: .userInitiated) {
                DictionaryScanner.scan(query: query)
            }.value
            guard !Task.isCancelled else { return }
            files = snapshot.files
            entries = snapshot.entries
            totalEntries = snapshot.totalEntries
            totalBytes = snapshot.totalBytes
            isLoading = false
            hasLoaded = true
        }
    }

    func entriesFooter(searching: Bool) -> String {
        if searching {
            return entries.count == 120 ? "最多显示前 120 个搜索结果。" : "共显示 \(entries.count) 个匹配结果。"
        }
        return "显示前 \(entries.count) 个词条，可使用搜索快速查找本地条目。"
    }
}

private enum DictionaryScanner {
    nonisolated static func scan(query: String) -> DictionarySnapshot {
        guard let root = sharedDictionaryRoot else {
            return DictionarySnapshot(files: [], entries: [], totalEntries: 0, totalBytes: 0)
        }

        let keys: [URLResourceKey] = [.isRegularFileKey, .fileSizeKey]
        let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        )
        let urls = (enumerator?.allObjects as? [URL] ?? [])
            .filter { $0.lastPathComponent.hasSuffix(".dict.yaml") }
            .sorted { $0.path < $1.path }

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var files: [LocalDictionaryFile] = []
        var entries: [LocalDictionaryEntry] = []
        var totalEntries = 0
        var totalBytes: Int64 = 0

        for url in urls {
            guard let content = try? String(contentsOf: url, encoding: .utf8) else { continue }
            let relativePath = url.path.replacingOccurrences(of: root.path + "/", with: "")
            let values = try? url.resourceValues(forKeys: Set(keys))
            let byteCount = Int64(values?.fileSize ?? 0)
            var fileEntryCount = 0
            var reachedData = false

            content.enumerateLines { line, _ in
                if line.trimmingCharacters(in: .whitespaces) == "..." {
                    reachedData = true
                    return
                }
                guard reachedData else { return }
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { return }
                let parts = trimmed.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
                guard parts.count >= 2 else { return }

                fileEntryCount += 1
                let matches = trimmedQuery.isEmpty ||
                    parts[0].localizedCaseInsensitiveContains(trimmedQuery) ||
                    parts[1].localizedCaseInsensitiveContains(trimmedQuery)
                guard matches, entries.count < 120 else { return }
                entries.append(
                    LocalDictionaryEntry(
                        id: "\(relativePath)-\(fileEntryCount)",
                        text: parts[0],
                        code: parts[1],
                        weight: parts.count > 2 && !parts[2].isEmpty ? parts[2] : nil
                    )
                )
            }

            totalEntries += fileEntryCount
            totalBytes += byteCount
            files.append(
                LocalDictionaryFile(
                    id: relativePath,
                    displayName: url.deletingPathExtension().deletingPathExtension().lastPathComponent,
                    relativePath: relativePath,
                    byteCount: byteCount,
                    entryCount: fileEntryCount
                )
            )
        }

        return DictionarySnapshot(files: files, entries: entries, totalEntries: totalEntries, totalBytes: totalBytes)
    }

    nonisolated static func preview(fileID: String, query: String) -> [LocalDictionaryEntry] {
        guard let root = sharedDictionaryRoot else { return [] }
        let url = root.appendingPathComponent(fileID).standardizedFileURL
        guard url.path.hasPrefix(root.standardizedFileURL.path + "/"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var entries: [LocalDictionaryEntry] = []
        var reachedData = false
        var index = 0

        content.enumerateLines { line, stop in
            if line.trimmingCharacters(in: .whitespaces) == "..." {
                reachedData = true
                return
            }
            guard reachedData else { return }
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { return }
            let parts = trimmed.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard parts.count >= 2 else { return }

            index += 1
            let matches = trimmedQuery.isEmpty ||
                parts[0].localizedCaseInsensitiveContains(trimmedQuery) ||
                parts[1].localizedCaseInsensitiveContains(trimmedQuery)
            guard matches else { return }
            entries.append(
                LocalDictionaryEntry(
                    id: "\(fileID)-\(index)",
                    text: parts[0],
                    code: parts[1],
                    weight: parts.count > 2 && !parts[2].isEmpty ? parts[2] : nil
                )
            )
            if entries.count >= 120 {
                stop = true
            }
        }
        return entries
    }

    nonisolated private static var sharedDictionaryRoot: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.DoubleShy0N.Universe-Keyboard"
        )?.appendingPathComponent("Rime/shared", isDirectory: true)
    }
}

#Preview {
    NavigationStack {
        DictionaryBrowserView()
    }
}
