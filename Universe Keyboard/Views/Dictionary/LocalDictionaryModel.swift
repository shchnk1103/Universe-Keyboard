import Foundation
import Observation

@MainActor
@Observable
final class LocalDictionaryModel {
    static let shared = LocalDictionaryModel()

    let indexService: any DictionaryIndexServicing
    var files: [LocalDictionaryFile] = []
    var entries: [LocalDictionaryEntry] = []
    var totalEntries = 0
    var totalBytes: Int64 = 0
    var isLoading = false
    var query = ""

    private var pendingTask: Task<Void, Never>?
    private var hasLoaded = false

    init(indexService: any DictionaryIndexServicing = DictionaryIndexService()) {
        self.indexService = indexService
    }

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
            let snapshot = await indexService.scan(query: query)
            guard !Task.isCancelled else { return }
            apply(snapshot)
        }
    }

    func refreshImmediately(query: String) async {
        pendingTask?.cancel()
        isLoading = true
        apply(await indexService.scan(query: query))
    }

    func entriesFooter(searching: Bool) -> String {
        if searching {
            return entries.count == DictionaryScanner.resultLimit
                ? "最多显示前 120 个搜索结果。"
                : "共显示 \(entries.count) 个匹配结果。"
        }
        return "显示前 \(entries.count) 个词条，可使用搜索快速查找本地条目。"
    }

    private func apply(_ snapshot: DictionarySnapshot) {
        files = snapshot.files
        entries = snapshot.entries
        totalEntries = snapshot.totalEntries
        totalBytes = snapshot.totalBytes
        isLoading = false
        hasLoaded = true
    }
}

@MainActor
@Observable
final class LocalDictionaryPreviewModel {
    let file: LocalDictionaryFile
    var entries: [LocalDictionaryEntry] = []
    var query = ""
    var isLoading = true

    private let indexService: any DictionaryIndexServicing
    private var pendingTask: Task<Void, Never>?
    private var hasLoaded = false

    init(file: LocalDictionaryFile, indexService: any DictionaryIndexServicing) {
        self.file = file
        self.indexService = indexService
    }

    func loadIfNeeded() {
        guard !hasLoaded else { return }
        refresh(query: query, delayed: false)
    }

    func scheduleRefresh(query: String) {
        refresh(query: query, delayed: true)
    }

    func refreshImmediately(query: String) async {
        pendingTask?.cancel()
        isLoading = true
        entries = await indexService.preview(fileID: file.id, query: query)
        isLoading = false
        hasLoaded = true
    }

    func entriesFooter() -> String {
        entries.count == DictionaryScanner.resultLimit
            ? "最多显示前 120 个词条。"
            : "当前显示 \(entries.count) 个词条。"
    }

    private func refresh(query: String, delayed: Bool) {
        pendingTask?.cancel()
        pendingTask = Task {
            if delayed {
                try? await Task.sleep(for: .milliseconds(180))
            }
            guard !Task.isCancelled else { return }
            isLoading = true
            let result = await indexService.preview(fileID: file.id, query: query)
            guard !Task.isCancelled else { return }
            entries = result
            isLoading = false
            hasLoaded = true
        }
    }
}
