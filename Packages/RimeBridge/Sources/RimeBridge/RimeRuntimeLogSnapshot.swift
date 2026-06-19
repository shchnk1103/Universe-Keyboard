import Foundation

enum RimeRuntimeLogSnapshot {
    static func relevantLines(in userDataURL: URL, maxLines: Int = 20) -> [String] {
        let logDirectory = userDataURL.appendingPathComponent("logs", isDirectory: true)
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: logDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        let recentFiles = files
            .filter { !$0.hasDirectoryPath }
            .sorted { lhs, rhs in
                modificationDate(lhs) > modificationDate(rhs)
            }
            .prefix(4)

        let keywords = ["lua", "date_translator", "translator", "error", "warning", "failed"]
        var matches: [String] = []
        for file in recentFiles {
            guard let content = try? String(contentsOf: file, encoding: .utf8) else { continue }
            let fileName = file.lastPathComponent
            for line in content.components(separatedBy: .newlines) {
                let lowercased = line.lowercased()
                guard keywords.contains(where: lowercased.contains) else { continue }
                matches.append("\(fileName): \(line)")
            }
        }
        return Array(matches.suffix(maxLines))
    }

    private static func modificationDate(_ url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate)
            ?? .distantPast
    }
}
