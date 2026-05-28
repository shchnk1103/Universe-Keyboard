import Foundation

struct SchemaMetadata: Codable, Identifiable, Equatable {
    var id: String { schemaID }
    let schemaID: String
    let name: String
    let description: String
    let source: SchemaSource
    let version: String?
    var installed: Bool
    let requiresLua: Bool
    let downloadSize: String

    enum SchemaSource: String, Codable {
        case builtin
        case downloaded
    }
}

enum DownloadState: Equatable {
    case idle
    case fetchingReleaseInfo
    case downloading(progress: Double)
    case extracting
    case postProcessing
    case deploying
    case completed
    case failed(String)
}

enum DownloadError: Error, LocalizedError {
    case networkError(String)
    case gitHubRateLimit
    case diskSpaceInsufficient(needed: Int64, available: Int64)
    case corruptArchive
    case extractionFailed(String)
    case postProcessingFailed(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "网络错误：\(message)"
        case .gitHubRateLimit:
            return "GitHub API 限流，请稍后再试（约 1 小时后重置）"
        case .diskSpaceInsufficient(let needed, let available):
            let needMB = needed / 1_000_000
            let availableMB = available / 1_000_000
            return "存储空间不足（需要约 \(needMB) MB，可用 \(availableMB) MB）"
        case .corruptArchive:
            return "下载文件损坏，请重试"
        case .extractionFailed(let message):
            return "解压失败：\(message)"
        case .postProcessingFailed(let message):
            return "配置文件处理失败：\(message)"
        }
    }
}
