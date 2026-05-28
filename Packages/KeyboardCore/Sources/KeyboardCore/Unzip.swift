import Foundation

/// 最小 zip 解压工具，使用系统 libz 进行 raw deflate 解压。
/// 只支持 store（method 0）和 deflate（method 8），足够处理 rime-ice full.zip。
public enum Unzip {

    /// 解压后单个条目的安全上限（100 MB）
    public static let maxUncompressedSize = 100_000_000

    public struct Entry {
        public let filename: String
        public let data: Data

        public init(filename: String, data: Data) {
            self.filename = filename
            self.data = data
        }
    }

    public enum Error: Swift.Error, LocalizedError {
        case cannotOpen
        case badFormat(String)
        case decompressionFailed(String)
        case unsupportedMethod(UInt16, String)
        case tooLarge(String)

        public var errorDescription: String? {
            switch self {
            case .cannotOpen: return "无法打开 zip 文件"
            case .badFormat(let msg): return "Zip 格式错误：\(msg)"
            case .decompressionFailed(let msg): return "解压失败：\(msg)"
            case .unsupportedMethod(let method, let name):
                return "不支持压缩方法 \(method)（文件：\(name)）"
            case .tooLarge(let msg): return "文件过大：\(msg)"
            }
        }
    }

    // MARK: - Public

    public static func extract(zipPath: String, to destinationDir: URL) throws -> [String] {
        let data = try Data(contentsOf: URL(fileURLWithPath: zipPath), options: .mappedIfSafe)
        let entries = try extract(data: data)
        var extracted: [String] = []
        let fm = FileManager.default

        for entry in entries {
            let destURL = destinationDir.appendingPathComponent(entry.filename)
            let parentDir = destURL.deletingLastPathComponent()
            try? fm.createDirectory(at: parentDir, withIntermediateDirectories: true)
            try entry.data.write(to: destURL)
            extracted.append(entry.filename)
        }
        return extracted
    }

    public static func extract(data: Data) throws -> [Entry] {
        try ZipArchiveReader(data: data, maxUncompressedSize: maxUncompressedSize).extractEntries()
    }
}
