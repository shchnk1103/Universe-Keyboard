import Foundation

/// Expands ZIP raw-deflate payloads using the existing libz algorithm.
struct ZipInflater {
    private let maxUncompressedSize: Int

    init(maxUncompressedSize: Int) {
        self.maxUncompressedSize = maxUncompressedSize
    }

    func inflateRaw(data: Data, expectedSize: Int) throws -> Data {
        guard expectedSize <= maxUncompressedSize else {
            throw Unzip.Error.tooLarge("uncompressedSize \(expectedSize) 超过安全上限")
        }

        var stream = z_stream()
        stream.zalloc = nil
        stream.zfree = nil
        stream.opaque = nil

        let initializationResult = inflateInit2_(
            &stream,
            -MAX_WBITS,
            zlibVersion(),
            Int32(MemoryLayout<z_stream>.size)
        )
        guard initializationResult == Z_OK else {
            throw Unzip.Error.decompressionFailed("inflateInit2 失败，代码: \(initializationResult)")
        }
        defer { _ = inflateEnd(&stream) }

        var result = Data(count: expectedSize)
        let chunkSize = 16_384
        let maximumSize = maxUncompressedSize + chunkSize
        var iterations = 0

        return try data.withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
            stream.next_in = UnsafeMutablePointer(
                mutating: inputPointer.bindMemory(to: UInt8.self).baseAddress
            )
            stream.avail_in = uInt(data.count)

            while true {
                iterations += 1
                guard iterations < 10_000 else {
                    throw Unzip.Error.decompressionFailed("解压迭代次数超限，数据可能损坏")
                }

                let currentSize = result.count
                guard currentSize < maximumSize else {
                    throw Unzip.Error.tooLarge("解压后数据超过安全上限")
                }

                result.withUnsafeMutableBytes { (outputPointer: UnsafeMutableRawBufferPointer) in
                    let offset = stream.total_out
                    stream.next_out = outputPointer.baseAddress?
                        .advanced(by: Int(offset))
                        .assumingMemoryBound(to: UInt8.self)
                    stream.avail_out = uInt(currentSize - Int(offset))
                }

                let resultCode = inflate(&stream, Z_NO_FLUSH)

                if resultCode == Z_STREAM_END {
                    result.count = Int(stream.total_out)
                    return result
                }

                if resultCode != Z_OK {
                    if let message = stream.msg {
                        throw Unzip.Error.decompressionFailed(String(cString: message))
                    }
                    throw Unzip.Error.decompressionFailed("inflate 错误，代码: \(resultCode)")
                }

                if stream.avail_out == 0 {
                    result.count += chunkSize
                }
            }
        }
    }
}
