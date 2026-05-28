import Foundation

/// Pure parser for dictionary YAML payloads. File-system ownership belongs to
/// `DictionaryIndexService`, keeping parsing independently testable.
enum DictionaryScanner {
    nonisolated static let resultLimit = 120

    nonisolated static func snapshot(
        sources: [LocalDictionarySourceFile],
        query: String
    ) -> DictionarySnapshot {
        var files: [LocalDictionaryFile] = []
        var entries: [LocalDictionaryEntry] = []
        var totalEntries = 0
        var totalBytes: Int64 = 0

        for source in sources {
            let parsedEntries = parse(content: source.content, fileID: source.id)
            totalEntries += parsedEntries.count
            totalBytes += source.byteCount
            files.append(
                LocalDictionaryFile(
                    id: source.id,
                    displayName: source.displayName,
                    relativePath: source.relativePath,
                    byteCount: source.byteCount,
                    entryCount: parsedEntries.count
                )
            )
            guard entries.count < resultLimit else { continue }
            entries.append(
                contentsOf: matchingEntries(parsedEntries, query: query)
                    .prefix(resultLimit - entries.count)
            )
        }

        return DictionarySnapshot(
            files: files,
            entries: entries,
            totalEntries: totalEntries,
            totalBytes: totalBytes
        )
    }

    nonisolated static func preview(
        content: String,
        fileID: String,
        query: String
    ) -> [LocalDictionaryEntry] {
        Array(matchingEntries(parse(content: content, fileID: fileID), query: query).prefix(resultLimit))
    }

    nonisolated private static func parse(content: String, fileID: String) -> [LocalDictionaryEntry] {
        var entries: [LocalDictionaryEntry] = []
        var reachedData = false
        var index = 0

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

            index += 1
            entries.append(
                LocalDictionaryEntry(
                    id: "\(fileID)-\(index)",
                    text: parts[0],
                    code: parts[1],
                    weight: parts.count > 2 && !parts[2].isEmpty ? parts[2] : nil
                )
            )
        }
        return entries
    }

    nonisolated private static func matchingEntries(
        _ entries: [LocalDictionaryEntry],
        query: String
    ) -> [LocalDictionaryEntry] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return entries }
        return entries.filter {
            $0.text.localizedCaseInsensitiveContains(query)
                || $0.code.localizedCaseInsensitiveContains(query)
        }
    }
}
