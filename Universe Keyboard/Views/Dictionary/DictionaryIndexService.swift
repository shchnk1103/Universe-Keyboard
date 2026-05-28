import Foundation

protocol DictionaryIndexServicing: Sendable {
    func scan(query: String) async -> DictionarySnapshot
    func preview(fileID: String, query: String) async -> [LocalDictionaryEntry]
}

/// Serializes shared dictionary file access away from the UI actor. The App
/// reads deployed data only; deployment and mutation remain owned by settings.
actor DictionaryIndexService: DictionaryIndexServicing {
    nonisolated private static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

    private let rootURL: URL?
    private let resolvesAppGroupRoot: Bool

    init() {
        self.rootURL = nil
        self.resolvesAppGroupRoot = true
    }

    init(rootURL: URL) {
        self.rootURL = rootURL.standardizedFileURL
        self.resolvesAppGroupRoot = false
    }

    func scan(query: String) async -> DictionarySnapshot {
        guard let rootURL = dictionaryRootURL() else {
            return DictionarySnapshot(files: [], entries: [], totalEntries: 0, totalBytes: 0)
        }

        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.isRegularFileKey, .fileSizeKey]
        let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        )
        let sources = (enumerator?.allObjects as? [URL] ?? [])
            .filter { $0.lastPathComponent.hasSuffix(".dict.yaml") }
            .sorted { $0.path < $1.path }
            .compactMap { source(for: $0, relativeTo: rootURL, resourceKeys: keys) }

        return DictionaryScanner.snapshot(sources: sources, query: query)
    }

    func preview(fileID: String, query: String) async -> [LocalDictionaryEntry] {
        guard let rootURL = dictionaryRootURL() else { return [] }
        let url = rootURL.appendingPathComponent(fileID).standardizedFileURL
        guard
            url.path.hasPrefix(rootURL.standardizedFileURL.path + "/"),
            let content = try? String(contentsOf: url, encoding: .utf8)
        else {
            return []
        }

        return DictionaryScanner.preview(content: content, fileID: fileID, query: query)
    }

    private func dictionaryRootURL() -> URL? {
        guard resolvesAppGroupRoot else { return rootURL }
        return FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupID
        )?.appendingPathComponent("Rime/shared", isDirectory: true)
    }

    private func source(
        for url: URL,
        relativeTo rootURL: URL,
        resourceKeys: [URLResourceKey]
    ) -> LocalDictionarySourceFile? {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        let relativePath = url.path.replacingOccurrences(of: rootURL.path + "/", with: "")
        let values = try? url.resourceValues(forKeys: Set(resourceKeys))
        return LocalDictionarySourceFile(
            id: relativePath,
            displayName: url.deletingPathExtension().deletingPathExtension().lastPathComponent,
            relativePath: relativePath,
            byteCount: Int64(values?.fileSize ?? 0),
            content: content
        )
    }
}
