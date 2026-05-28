import Foundation

nonisolated struct LocalDictionaryFile: Identifiable, Sendable {
    let id: String
    let displayName: String
    let relativePath: String
    let byteCount: Int64
    let entryCount: Int

    var formattedEntryCount: String { entryCount.formatted() + " 条" }
    var formattedSize: String { ByteCountFormatter.string(fromByteCount: byteCount, countStyle: .file) }
}

nonisolated struct LocalDictionaryEntry: Identifiable, Sendable {
    let id: String
    let text: String
    let code: String
    let weight: String?
}

nonisolated struct DictionarySnapshot: Sendable {
    let files: [LocalDictionaryFile]
    let entries: [LocalDictionaryEntry]
    let totalEntries: Int
    let totalBytes: Int64
}

nonisolated struct LocalDictionarySourceFile: Sendable {
    let id: String
    let displayName: String
    let relativePath: String
    let byteCount: Int64
    let content: String
}
