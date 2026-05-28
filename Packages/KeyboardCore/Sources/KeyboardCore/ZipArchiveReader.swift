import Foundation

/// Parses supported ZIP records and delegates payload expansion to `ZipInflater`.
struct ZipArchiveReader {
    private struct LocalEntryReference {
        let filename: String
        let localOffset: Int
    }

    private let data: Data
    private let maxUncompressedSize: Int

    init(data: Data, maxUncompressedSize: Int) {
        self.data = data
        self.maxUncompressedSize = maxUncompressedSize
    }

    func extractEntries() throws -> [Unzip.Entry] {
        guard data.count > 22 else { throw Unzip.Error.badFormat("文件太小") }

        let eocdOffset = try findEOCD()
        let reader = BinaryReader(data: data)
        reader.position = eocdOffset
        let signature = try reader.readUInt32()
        guard signature == 0x06054b50 else { throw Unzip.Error.badFormat("EOCD 签名不匹配") }
        reader.skip(6)
        let totalEntries = Int(try reader.readUInt16())
        reader.skip(4)
        let centralDirectoryOffset = Int(try reader.readUInt32())
        reader.skip(2)

        guard totalEntries > 0, totalEntries < 100_000,
            centralDirectoryOffset > 0, centralDirectoryOffset < data.count
        else {
            throw Unzip.Error.badFormat("中央目录偏移无效")
        }

        let references = try readCentralDirectory(
            with: reader,
            totalEntries: totalEntries,
            at: centralDirectoryOffset
        )
        return try references.compactMap { try readEntry($0, with: reader) }
    }

    private func readCentralDirectory(
        with reader: BinaryReader,
        totalEntries: Int,
        at offset: Int
    ) throws -> [LocalEntryReference] {
        reader.position = offset
        var references: [LocalEntryReference] = []

        for _ in 0..<min(totalEntries, 50_000) {
            let signature = try reader.readUInt32()
            if signature == 0x02014b50 {
                reader.skip(6)  // version made by (2) + version needed (2) + flags (2)
                reader.skip(2)  // compression method is verified from the local header.
                reader.skip(8)
                let compressedSize = Int(try reader.readUInt32())
                reader.skip(4)  // uncompressed size is verified from the local header.
                let filenameLength = Int(try reader.readUInt16())
                let extraLength = Int(try reader.readUInt16())
                let commentLength = Int(try reader.readUInt16())
                reader.skip(8)
                let localOffset = Int(try reader.readUInt32())

                guard filenameLength > 0, filenameLength < 4096,
                    extraLength >= 0, extraLength < 32768,
                    commentLength >= 0, commentLength < 65536
                else {
                    throw Unzip.Error.badFormat("文件名字段长度无效")
                }

                let filename = try reader.readString(length: filenameLength)
                reader.skip(extraLength + commentLength)

                guard !filename.hasSuffix("/"), compressedSize > 0 else { continue }
                references.append(LocalEntryReference(filename: filename, localOffset: localOffset))
            } else if signature == 0x06054b50 {
                break
            }
        }

        return references
    }

    private func readEntry(_ reference: LocalEntryReference, with reader: BinaryReader) throws -> Unzip.Entry? {
        guard reference.localOffset >= 0, reference.localOffset < data.count else {
            throw Unzip.Error.badFormat("本地文件偏移无效: \(reference.filename)")
        }

        reader.position = reference.localOffset
        let signature = try reader.readUInt32()
        guard signature == 0x04034b50 else {
            throw Unzip.Error.badFormat("本地文件头签名错误: \(reference.filename)")
        }
        reader.skip(4)  // version needed (2) + flags (2)
        let method = try reader.readUInt16()
        reader.skip(2)  // modification time
        reader.skip(6)  // modification date (2) + CRC32 (4)
        let compressedSize = Int(try reader.readUInt32())
        let uncompressedSize = Int(try reader.readUInt32())
        let filenameLength = Int(try reader.readUInt16())
        let extraLength = Int(try reader.readUInt16())

        guard filenameLength > 0, filenameLength < 4096,
            extraLength >= 0, extraLength < 32768,
            compressedSize >= 0, compressedSize < maxUncompressedSize * 2,
            uncompressedSize >= 0, uncompressedSize <= maxUncompressedSize
        else {
            throw Unzip.Error.badFormat("本地文件头字段无效: \(reference.filename)")
        }

        _ = try reader.readData(length: filenameLength)
        reader.skip(extraLength)
        guard method == 0 || method == 8 else {
            throw Unzip.Error.unsupportedMethod(method, reference.filename)
        }
        guard compressedSize > 0, uncompressedSize > 0 else { return nil }

        let rawData = try reader.readData(length: compressedSize)
        let extractedData =
            if method == 0 {
                rawData
            } else {
                try ZipInflater(maxUncompressedSize: maxUncompressedSize)
                    .inflateRaw(data: rawData, expectedSize: uncompressedSize)
            }
        return Unzip.Entry(filename: reference.filename, data: extractedData)
    }

    private func findEOCD() throws -> Int {
        let maximumCommentLength = 65_535
        let searchStart = max(0, data.count - maximumCommentLength - 22)
        let signature: [UInt8] = [0x50, 0x4B, 0x05, 0x06]

        var offset = data.count - 22
        while offset >= searchStart {
            if data[offset] == signature[0]
                && data[offset + 1] == signature[1]
                && data[offset + 2] == signature[2]
                && data[offset + 3] == signature[3]
            {
                return offset
            }
            offset -= 1
        }
        throw Unzip.Error.badFormat("找不到 EOCD 记录")
    }
}
