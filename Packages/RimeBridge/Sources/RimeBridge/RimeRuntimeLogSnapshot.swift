import Foundation

enum RimeRuntimeLogSnapshot {
    /// 第三方 RIME runtime log 可能含输入与候选内容。这里只允许返回聚合计数，
    /// 调用方不得把原始行、文件名或路径写进任何本地诊断存储。
    struct Summary: Sendable, Equatable {
        let filesInspected: Int
        let matchingLineCount: Int
        let readFailureCount: Int
    }

    static func summary(in userDataURL: URL) -> Summary {
        let logDirectory = userDataURL.appendingPathComponent("logs", isDirectory: true)
        guard
            let files = try? FileManager.default.contentsOfDirectory(
                at: logDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
        else {
            return Summary(filesInspected: 0, matchingLineCount: 0, readFailureCount: 1)
        }

        let recentFiles =
            files
            .filter { !$0.hasDirectoryPath }
            .sorted { lhs, rhs in
                modificationDate(lhs) > modificationDate(rhs)
            }
            .prefix(4)

        let keywords = ["lua", "date_translator", "translator", "error", "warning", "failed"]
        var matchingLineCount = 0
        var readFailureCount = 0
        for file in recentFiles {
            guard let content = try? String(contentsOf: file, encoding: .utf8) else {
                readFailureCount += 1
                continue
            }
            for line in content.components(separatedBy: .newlines) {
                let lowercased = line.lowercased()
                guard keywords.contains(where: lowercased.contains) else { continue }
                matchingLineCount += 1
            }
        }
        return Summary(
            filesInspected: recentFiles.count,
            matchingLineCount: matchingLineCount,
            readFailureCount: readFailureCount
        )
    }

    private static func modificationDate(_ url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate)
            ?? .distantPast
    }
}
