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
        guard data.count > 22 else { throw Error.badFormat("文件太小") }

        let eocdOffset = try findEOCD(in: data)

        let reader = BinaryReader(data: data)
        reader.position = eocdOffset
        let signature = try reader.readUInt32()
        guard signature == 0x06054b50 else { throw Error.badFormat("EOCD 签名不匹配") }
        reader.skip(6)
        let totalEntries = Int(try reader.readUInt16())
        reader.skip(4)
        let centralDirOffset = Int(try reader.readUInt32())
        reader.skip(2)

        guard totalEntries > 0, totalEntries < 100_000,
              centralDirOffset > 0, centralDirOffset < data.count else {
            throw Error.badFormat("中央目录偏移无效")
        }

        reader.position = centralDirOffset
        var localOffsets: [(String, Int, UInt16)] = []

        for _ in 0..<min(totalEntries, 50_000) {
            let sig = try reader.readUInt32()
            if sig == 0x02014b50 {
                reader.skip(6)  // version made by (2) + version needed (2) + flags (2)
                let method = try reader.readUInt16()
                reader.skip(8)
                let compressedSize = Int(try reader.readUInt32())
                let _ = Int(try reader.readUInt32())  // uncompressedSize, read from local header
                let filenameLen = Int(try reader.readUInt16())
                let extraLen = Int(try reader.readUInt16())
                let commentLen = Int(try reader.readUInt16())
                reader.skip(8)
                let localOffset = Int(try reader.readUInt32())

                guard filenameLen > 0, filenameLen < 4096,
                      extraLen >= 0, extraLen < 32768,
                      commentLen >= 0, commentLen < 65536 else {
                    throw Error.badFormat("文件名字段长度无效")
                }

                let filename = try reader.readString(length: filenameLen)
                reader.skip(extraLen + commentLen)

                guard !filename.hasSuffix("/"), compressedSize > 0 else { continue }

                localOffsets.append((filename, localOffset, method))
            } else if sig == 0x06054b50 {
                break
            }
        }

        var entries: [Entry] = []
        for (filename, localOffset, _) in localOffsets {
            guard localOffset >= 0, localOffset < data.count else {
                throw Error.badFormat("本地文件偏移无效: \(filename)")
            }

            reader.position = localOffset
            let localSig = try reader.readUInt32()
            guard localSig == 0x04034b50 else {
                throw Error.badFormat("本地文件头签名错误: \(filename)")
            }
            reader.skip(4)  // version needed (2) + flags (2)
            let fileMethod = try reader.readUInt16()  // compression method
            reader.skip(2)  // mod time
            reader.skip(6)  // mod date (2) + crc32 (4)
            let compressedSize = Int(try reader.readUInt32())
            let uncompressedSize = Int(try reader.readUInt32())
            let filenameLen = Int(try reader.readUInt16())
            let extraLen = Int(try reader.readUInt16())

            guard filenameLen > 0, filenameLen < 4096,
                  extraLen >= 0, extraLen < 32768,
                  compressedSize >= 0, compressedSize < maxUncompressedSize * 2,
                  uncompressedSize >= 0, uncompressedSize <= maxUncompressedSize else {
                throw Error.badFormat("本地文件头字段无效: \(filename)")
            }

            let _ = try reader.readString(length: filenameLen)
            reader.skip(extraLen)

            guard fileMethod == 0 || fileMethod == 8 else {
                throw Error.unsupportedMethod(fileMethod, filename)
            }

            guard compressedSize > 0, uncompressedSize > 0 else { continue }

            let rawData = try reader.readData(length: compressedSize)

            let decompressed: Data
            if fileMethod == 0 {
                decompressed = rawData
            } else {
                decompressed = try inflateRaw(data: rawData, expectedSize: uncompressedSize)
            }

            entries.append(Entry(filename: filename, data: decompressed))
        }

        return entries
    }

    // MARK: - EOCD search

    private static func findEOCD(in data: Data) throws -> Int {
        let maxComment = 65535
        let searchStart = max(0, data.count - maxComment - 22)
        let signature: [UInt8] = [0x50, 0x4B, 0x05, 0x06]

        var i = data.count - 22
        while i >= searchStart {
            if data[i] == signature[0]
                && data[i+1] == signature[1]
                && data[i+2] == signature[2]
                && data[i+3] == signature[3] {
                return i
            }
            i -= 1
        }
        throw Error.badFormat("找不到 EOCD 记录")
    }

    // MARK: - Raw inflate via libz

    private static func inflateRaw(data: Data, expectedSize: Int) throws -> Data {
        guard expectedSize <= maxUncompressedSize else {
            throw Error.tooLarge("uncompressedSize \(expectedSize) 超过安全上限")
        }

        var zs = z_stream()
        zs.zalloc = nil
        zs.zfree = nil
        zs.opaque = nil

        let initRet = inflateInit2_(&zs, -MAX_WBITS, zlibVersion(), Int32(MemoryLayout<z_stream>.size))
        guard initRet == Z_OK else {
            throw Error.decompressionFailed("inflateInit2 失败，代码: \(initRet)")
        }
        defer { inflateEnd(&zs) }

        var result = Data(count: expectedSize)
        let chunkSize = 16384
        let maxSize = maxUncompressedSize + chunkSize
        var iterations = 0

        return try data.withUnsafeBytes { (inputPtr: UnsafeRawBufferPointer) in
            zs.next_in = UnsafeMutablePointer(mutating: inputPtr.bindMemory(to: UInt8.self).baseAddress)
            zs.avail_in = uInt(data.count)

            while true {
                iterations += 1
                guard iterations < 10_000 else {
                    throw Error.decompressionFailed("解压迭代次数超限，数据可能损坏")
                }

                let currentSize = result.count
                guard currentSize < maxSize else {
                    throw Error.tooLarge("解压后数据超过安全上限")
                }

                try result.withUnsafeMutableBytes { (outputPtr: UnsafeMutableRawBufferPointer) in
                    let offset = zs.total_out
                    zs.next_out = outputPtr.baseAddress?.advanced(by: Int(offset)).assumingMemoryBound(to: UInt8.self)
                    zs.avail_out = uInt(currentSize - Int(offset))
                }

                let ret = inflate(&zs, Z_NO_FLUSH)

                if ret == Z_STREAM_END {
                    result.count = Int(zs.total_out)
                    return result
                }

                if ret != Z_OK {
                    if let msg = zs.msg {
                        throw Error.decompressionFailed(String(cString: msg))
                    }
                    throw Error.decompressionFailed("inflate 错误，代码: \(ret)")
                }

                if zs.avail_out == 0 {
                    result.count += chunkSize
                }
            }
        }
    }
}

// MARK: - Binary reader helper

final class BinaryReader {
    let data: Data
    var position: Int = 0

    init(data: Data) { self.data = data }

    func checkBounds(_ size: Int) throws {
        guard position + size <= data.count else {
            throw Unzip.Error.badFormat("读取越界：pos=\(position) size=\(size) data=\(data.count)")
        }
    }

    func skip(_ n: Int) { position += n }

    func readUInt16() throws -> UInt16 {
        try checkBounds(2)
        let val = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt16.self) }
        position += 2
        return UInt16(littleEndian: val)
    }

    func readUInt32() throws -> UInt32 {
        try checkBounds(4)
        let val = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt32.self) }
        position += 4
        return UInt32(littleEndian: val)
    }

    func readString(length: Int) throws -> String {
        try checkBounds(length)
        let bytes = data.subdata(in: position..<position+length)
        position += length
        return String(data: bytes, encoding: .utf8) ?? String(decoding: bytes, as: UTF8.self)
    }

    func readData(length: Int) throws -> Data {
        try checkBounds(length)
        let d = data.subdata(in: position..<position+length)
        position += length
        return d
    }
}
