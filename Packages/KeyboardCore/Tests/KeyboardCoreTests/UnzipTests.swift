import XCTest
@testable import KeyboardCore

final class UnzipTests: XCTestCase {

    // MARK: - Helpers

    /// Create a minimal valid zip with one file using store method (no compression).
    func makeStoreZip(filename: String, content: Data) -> Data {
        let fnData = filename.data(using: .utf8)!
        var zip = Data()

        // Local file header
        let localSig: [UInt8] = [0x50, 0x4B, 0x03, 0x04]
        var localHeader = Data()
        localHeader.append(contentsOf: localSig)             // signature
        localHeader.append(contentsOf: u16le(20))             // version needed
        localHeader.append(contentsOf: u16le(0))              // flags
        localHeader.append(contentsOf: u16le(0))              // method = store
        localHeader.append(contentsOf: u16le(0))              // mod time
        localHeader.append(contentsOf: u16le(0))              // mod date
        localHeader.append(contentsOf: crc32le(content))      // crc32
        localHeader.append(contentsOf: u32le(content.count))  // compressed size
        localHeader.append(contentsOf: u32le(content.count))  // uncompressed size
        localHeader.append(contentsOf: u16le(fnData.count))   // filename length
        localHeader.append(contentsOf: u16le(0))              // extra field length
        localHeader.append(fnData)                            // filename
        // file data
        localHeader.append(content)

        let localOffset = zip.count
        zip.append(localHeader)

        // Central directory entry
        let cdSig: [UInt8] = [0x50, 0x4B, 0x01, 0x02]
        var cd = Data()
        cd.append(contentsOf: cdSig)                          // signature
        cd.append(contentsOf: u16le(20))                      // version made by
        cd.append(contentsOf: u16le(20))                      // version needed
        cd.append(contentsOf: u16le(0))                       // flags
        cd.append(contentsOf: u16le(0))                       // method
        cd.append(contentsOf: u16le(0))                       // mod time
        cd.append(contentsOf: u16le(0))                       // mod date
        cd.append(contentsOf: crc32le(content))               // crc32
        cd.append(contentsOf: u32le(content.count))           // compressed size
        cd.append(contentsOf: u32le(content.count))           // uncompressed size
        cd.append(contentsOf: u16le(fnData.count))            // filename length
        cd.append(contentsOf: u16le(0))                       // extra field length
        cd.append(contentsOf: u16le(0))                       // file comment length
        cd.append(contentsOf: u16le(0))                       // disk number start
        cd.append(contentsOf: u16le(0))                       // internal file attrs
        cd.append(contentsOf: u32le(0))                       // external file attrs
        cd.append(contentsOf: u32le(localOffset))             // local header offset
        cd.append(fnData)                                     // filename

        let cdOffset = zip.count
        zip.append(cd)

        // EOCD
        let eocdSig: [UInt8] = [0x50, 0x4B, 0x05, 0x06]
        var eocd = Data()
        eocd.append(contentsOf: eocdSig)                      // signature
        eocd.append(contentsOf: u16le(0))                     // disk number
        eocd.append(contentsOf: u16le(0))                     // start disk
        eocd.append(contentsOf: u16le(1))                     // entries on disk
        eocd.append(contentsOf: u16le(1))                     // total entries
        eocd.append(contentsOf: u32le(cd.count))              // central dir size
        eocd.append(contentsOf: u32le(cdOffset))              // central dir offset
        eocd.append(contentsOf: u16le(0))                     // comment length
        zip.append(eocd)

        return zip
    }

    /// Create a minimal valid zip with one file using deflate method.
    func makeDeflateZip(filename: String, content: Data) -> Data {
        let compressed = deflateData(content)
        let fnData = filename.data(using: .utf8)!
        var zip = Data()

        // Local file header
        let localSig: [UInt8] = [0x50, 0x4B, 0x03, 0x04]
        var localHeader = Data()
        localHeader.append(contentsOf: localSig)
        localHeader.append(contentsOf: u16le(20))
        localHeader.append(contentsOf: u16le(0))
        localHeader.append(contentsOf: u16le(8))              // method = deflate
        localHeader.append(contentsOf: u16le(0))
        localHeader.append(contentsOf: u16le(0))
        localHeader.append(contentsOf: crc32le(content))
        localHeader.append(contentsOf: u32le(compressed.count))
        localHeader.append(contentsOf: u32le(content.count))
        localHeader.append(contentsOf: u16le(fnData.count))
        localHeader.append(contentsOf: u16le(0))
        localHeader.append(fnData)
        localHeader.append(compressed)

        let localOffset = zip.count
        zip.append(localHeader)

        // Central directory entry
        let cdSig: [UInt8] = [0x50, 0x4B, 0x01, 0x02]
        var cd = Data()
        cd.append(contentsOf: cdSig)
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(8))                      // method = deflate
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(compressed.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(fnData.count))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(localOffset))
        cd.append(fnData)

        let cdOffset = zip.count
        zip.append(cd)

        // EOCD
        let eocdSig: [UInt8] = [0x50, 0x4B, 0x05, 0x06]
        var eocd = Data()
        eocd.append(contentsOf: eocdSig)
        eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        return zip
    }

    /// Raw deflate using libz. Produces deflate data suitable for zip method 8.
    func deflateData(_ data: Data) -> Data {
        var zs = z_stream()
        zs.zalloc = nil
        zs.zfree = nil
        zs.opaque = nil
        deflateInit2_(&zs, Z_DEFAULT_COMPRESSION, Z_DEFLATED, -MAX_WBITS, 8, Z_DEFAULT_STRATEGY, zlibVersion(), Int32(MemoryLayout<z_stream>.size))
        defer { deflateEnd(&zs) }

        let inCount = data.count
        let outCapacity = max(inCount * 2 + 16, 64)
        var result = Data(count: outCapacity)

        return data.withUnsafeBytes { (inputPtr: UnsafeRawBufferPointer) in
            zs.next_in = UnsafeMutablePointer(mutating: inputPtr.bindMemory(to: UInt8.self).baseAddress)
            zs.avail_in = uInt(inCount)

            result.withUnsafeMutableBytes { (outputPtr: UnsafeMutableRawBufferPointer) in
                zs.next_out = outputPtr.baseAddress?.assumingMemoryBound(to: UInt8.self)
                zs.avail_out = uInt(outCapacity)
                deflate(&zs, Z_FINISH)
            }
            result.count = Int(zs.total_out)
            return result
        }
    }

    // MARK: - Little-endian helpers

    func u16le(_ v: Int) -> [UInt8] {
        let u = UInt16(v)
        return [UInt8(u & 0xFF), UInt8(u >> 8)]
    }

    func u32le(_ v: Int) -> [UInt8] {
        let u = UInt32(v)
        return [UInt8(u & 0xFF), UInt8(u >> 8 & 0xFF), UInt8(u >> 16 & 0xFF), UInt8(u >> 24 & 0xFF)]
    }

    /// Compute CRC32 matching zip's specification.
    func crc32le(_ data: Data) -> [UInt8] {
        var crc: UInt32 = 0xFFFF_FFFF
        for byte in data {
            crc ^= UInt32(byte)
            for _ in 0..<8 {
                if (crc & 1) != 0 {
                    crc = (crc >> 1) ^ 0xEDB8_8320
                } else {
                    crc >>= 1
                }
            }
        }
        crc ^= 0xFFFF_FFFF
        return u32le(Int(crc))
    }

    // MARK: - Tests: Error cases

    func testExtractEmptyData() {
        let data = Data()
        XCTAssertThrowsError(try Unzip.extract(data: data)) { error in
            guard case Unzip.Error.badFormat(let msg) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(msg.contains("文件太小"))
        }
    }

    func testExtractTooSmallData() {
        let data = Data(repeating: 0, count: 21)
        XCTAssertThrowsError(try Unzip.extract(data: data)) { error in
            guard case Unzip.Error.badFormat(let msg) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(msg.contains("文件太小"))
        }
    }

    func testExtractNoEOCD() {
        // 50 bytes of zeros — no EOCD signature
        let data = Data(repeating: 0, count: 50)
        XCTAssertThrowsError(try Unzip.extract(data: data)) { error in
            guard case Unzip.Error.badFormat(let msg) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(msg.contains("找不到 EOCD"))
        }
    }

    func testExtractBadEOCDSignature() {
        // Valid EOCD-like structure but wrong signature
        var data = Data(repeating: 0, count: 128)
        // Place fake EOCD at the end with wrong signature
        data[data.count - 22] = 0xFF
        data[data.count - 21] = 0xFF
        data[data.count - 20] = 0xFF
        data[data.count - 19] = 0xFF
        XCTAssertThrowsError(try Unzip.extract(data: data)) { error in
            guard case Unzip.Error.badFormat = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
        }
    }

    func testExtractInvalidCentralDirOffset() {
        // Create minimal valid EOCD that points to invalid central dir offset
        let eocdSig: [UInt8] = [0x50, 0x4B, 0x05, 0x06]
        var data = Data(repeating: 0, count: 100)
        let eocdOffset = data.count - 22
        data[eocdOffset] = eocdSig[0]
        data[eocdOffset + 1] = eocdSig[1]
        data[eocdOffset + 2] = eocdSig[2]
        data[eocdOffset + 3] = eocdSig[3]
        // Set total entries = 1
        data[eocdOffset + 8] = 1
        data[eocdOffset + 10] = 1
        // Set central dir offset = 9999 (out of bounds)
        data[eocdOffset + 16] = 0x0F
        data[eocdOffset + 17] = 0x27

        XCTAssertThrowsError(try Unzip.extract(data: data)) { error in
            guard case Unzip.Error.badFormat(let msg) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(msg.contains("中央目录偏移"))
        }
    }

    func testExtractCorruptedDeflateData() {
        let content = "hello".data(using: .utf8)!
        var zip = makeDeflateZip(filename: "test.txt", content: content)

        // Corrupt the compressed data in the local file header
        // Find local file data after the filename
        let fnData = "test.txt".data(using: .utf8)!
        // Local header: 30 bytes + filename + compressed data
        let localDataStart = 30 + fnData.count
        // Flip some bytes in the compressed data
        if zip.count > localDataStart + 2 {
            zip[localDataStart] = 0xFF
            zip[localDataStart + 1] = 0xFF
            zip[localDataStart + 2] = 0xFF
        }

        XCTAssertThrowsError(try Unzip.extract(data: zip)) { error in
            guard case Unzip.Error.decompressionFailed = error else {
                return XCTFail("Expected decompressionFailed, got \(error)")
            }
        }
    }

    func testExtractUnsupportedMethod() {
        let content = "test".data(using: .utf8)!
        let fnData = "file.txt".data(using: .utf8)!
        var zip = Data()

        // Local file header with method = 9 (unsupported)
        let localSig: [UInt8] = [0x50, 0x4B, 0x03, 0x04]
        var local = Data()
        local.append(contentsOf: localSig)
        local.append(contentsOf: u16le(20))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(9))              // unsupported method
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: crc32le(content))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u16le(fnData.count))
        local.append(contentsOf: u16le(0))
        local.append(fnData)
        local.append(content)

        let localOffset = zip.count
        zip.append(local)

        // Central directory
        let cdSig: [UInt8] = [0x50, 0x4B, 0x01, 0x02]
        var cd = Data()
        cd.append(contentsOf: cdSig)
        cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(9))  // same method
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(fnData.count))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(localOffset))
        cd.append(fnData)

        let cdOffset = zip.count
        zip.append(cd)

        // EOCD
        let eocdSig: [UInt8] = [0x50, 0x4B, 0x05, 0x06]
        var eocd = Data()
        eocd.append(contentsOf: eocdSig)
        eocd.append(contentsOf: u16le(0)); eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(1)); eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        XCTAssertThrowsError(try Unzip.extract(data: zip)) { error in
            guard case Unzip.Error.unsupportedMethod(let method, _) = error else {
                return XCTFail("Expected unsupportedMethod, got \(error)")
            }
            XCTAssertEqual(method, 9)
        }
    }

    func testExtractTooLargeUncompressedSize() {
        let content = "test".data(using: .utf8)!
        let fnData = "big.txt".data(using: .utf8)!
        let bigSize = Unzip.maxUncompressedSize + 1
        var zip = Data()

        let localSig: [UInt8] = [0x50, 0x4B, 0x03, 0x04]
        var local = Data()
        local.append(contentsOf: localSig)
        local.append(contentsOf: u16le(20))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))              // store
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: crc32le(content))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u32le(bigSize))         // oversized uncompressed
        local.append(contentsOf: u16le(fnData.count))
        local.append(contentsOf: u16le(0))
        local.append(fnData)
        local.append(content)

        let localOffset = zip.count
        zip.append(local)

        // Central directory
        let cdSig: [UInt8] = [0x50, 0x4B, 0x01, 0x02]
        var cd = Data()
        cd.append(contentsOf: cdSig)
        cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(bigSize))
        cd.append(contentsOf: u16le(fnData.count))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(localOffset))
        cd.append(fnData)

        let cdOffset = zip.count
        zip.append(cd)

        var eocd = Data()
        let eocdSig: [UInt8] = [0x50, 0x4B, 0x05, 0x06]
        eocd.append(contentsOf: eocdSig)
        eocd.append(contentsOf: u16le(0)); eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(1)); eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        XCTAssertThrowsError(try Unzip.extract(data: zip)) { error in
            guard case Unzip.Error.badFormat(let msg) = error else {
                return XCTFail("Expected badFormat for oversized entry, got \(error)")
            }
            XCTAssertTrue(msg.contains("本地文件头字段无效") || msg.contains("超过安全上限"))
        }
    }

    func testExtractDirectoryEntrySkipped() {
        let content = "file content".data(using: .utf8)!
        let dirName = "subdir/".data(using: .utf8)!
        let fnName = "subdir/readme.txt".data(using: .utf8)!
        var zip = Data()

        // Directory entry (trailing slash, compressedSize = 0)
        var dirLocal = Data()
        dirLocal.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])
        dirLocal.append(contentsOf: u16le(20)); dirLocal.append(contentsOf: u16le(0))
        dirLocal.append(contentsOf: u16le(0))
        dirLocal.append(contentsOf: u16le(0)); dirLocal.append(contentsOf: u16le(0))
        dirLocal.append(contentsOf: crc32le(Data()))
        dirLocal.append(contentsOf: u32le(0))
        dirLocal.append(contentsOf: u32le(0))
        dirLocal.append(contentsOf: u16le(dirName.count))
        dirLocal.append(contentsOf: u16le(0))
        dirLocal.append(dirName)
        let dirOffset = zip.count
        zip.append(dirLocal)

        // File entry
        var fileLocal = Data()
        fileLocal.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])
        fileLocal.append(contentsOf: u16le(20)); fileLocal.append(contentsOf: u16le(0))
        fileLocal.append(contentsOf: u16le(0))
        fileLocal.append(contentsOf: u16le(0)); fileLocal.append(contentsOf: u16le(0))
        fileLocal.append(contentsOf: crc32le(content))
        fileLocal.append(contentsOf: u32le(content.count))
        fileLocal.append(contentsOf: u32le(content.count))
        fileLocal.append(contentsOf: u16le(fnName.count))
        fileLocal.append(contentsOf: u16le(0))
        fileLocal.append(fnName)
        fileLocal.append(content)
        let fileOffset = zip.count
        zip.append(fileLocal)

        // Central directory entries
        var cd = Data()
        // Dir entry
        cd.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
        cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(Data()))
        cd.append(contentsOf: u32le(0)); cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u16le(dirName.count))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(dirOffset))
        cd.append(dirName)
        // File entry
        cd.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
        cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(fnName.count))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(fileOffset))
        cd.append(fnName)

        let cdOffset = zip.count
        zip.append(cd)

        // EOCD
        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        eocd.append(contentsOf: u16le(0)); eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(2)); eocd.append(contentsOf: u16le(2))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        let entries = try! Unzip.extract(data: zip)
        // Directory entry should be skipped (trailing / or compressedSize=0)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].filename, "subdir/readme.txt")
        XCTAssertEqual(entries[0].data, content)
    }

    // MARK: - Tests: Store method (uncompressed)

    func testExtractStoreMethod() {
        let content = "hello world".data(using: .utf8)!
        let zip = makeStoreZip(filename: "hello.txt", content: content)

        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].filename, "hello.txt")
        XCTAssertEqual(entries[0].data, content)
    }

    func testExtractStoreMethodChineseFilename() {
        let content = "你好世界".data(using: .utf8)!
        let zip = makeStoreZip(filename: "你好.txt", content: content)

        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].filename, "你好.txt")
        XCTAssertEqual(entries[0].data, content)
    }

    func testExtractStoreMethodBinaryContent() {
        // Binary content with all byte values
        var content = Data()
        for i in 0..<256 { content.append(UInt8(i)) }
        let zip = makeStoreZip(filename: "binary.bin", content: content)

        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].data, content)
    }

    func testExtractStoreMethodEmptyContent() {
        // A zero-size file would be skipped (compressedSize > 0 guard),
        // so use a single byte
        let content = "X".data(using: .utf8)!
        let zip = makeStoreZip(filename: "empty.txt", content: content)

        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].data, content)
    }

    // MARK: - Tests: Deflate method

    func testExtractDeflateMethod() {
        let content = "The quick brown fox jumps over the lazy dog. ".data(using: .utf8)!
        // Repeat to get compressible content
        let repeated = String(repeating: String(data: content, encoding: .utf8)!, count: 50).data(using: .utf8)!
        let zip = makeDeflateZip(filename: "fox.txt", content: repeated)

        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].filename, "fox.txt")
        XCTAssertEqual(entries[0].data, repeated)
    }

    func testExtractDeflateMethodChineseContent() {
        let content = "床前明月光疑是地上霜举头望明月低头思故乡".data(using: .utf8)!
        let zip = makeDeflateZip(filename: "poem.txt", content: content)

        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].data, content)
    }

    /// Validates that deflate-method zips created by system zip can be extracted.
    func testExtractRealSystemZipStore() throws {
        let tmpDir = FileManager.default.temporaryDirectory
        let workDir = tmpDir.appendingPathComponent("unzip_test_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: workDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: workDir) }

        let content = "system zip test content"
        let fileURL = workDir.appendingPathComponent("test.txt")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)

        let zipURL = workDir.appendingPathComponent("test.zip")
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        task.arguments = ["-j", zipURL.path, fileURL.path]
        task.currentDirectoryURL = workDir
        try task.run()
        task.waitUntilExit()

        let zipData = try Data(contentsOf: zipURL)
        let entries = try Unzip.extract(data: zipData)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].filename, "test.txt")
        XCTAssertEqual(String(data: entries[0].data, encoding: .utf8), content)
    }

    // MARK: - Tests: Multiple entries

    func testExtractMultipleStoreEntries() {
        let files: [(String, Data)] = [
            ("a.txt", "aaaa".data(using: .utf8)!),
            ("b.txt", "bbbb".data(using: .utf8)!),
            ("c.txt", "cccc".data(using: .utf8)!),
        ]

        var zip = Data()
        var localOffsets: [(String, Int, Int, Int, Data)] = []  // name, offset, compSize, uncompSize, content

        for (name, content) in files {
            let fnData = name.data(using: .utf8)!
            var local = Data()
            local.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])
            local.append(contentsOf: u16le(20)); local.append(contentsOf: u16le(0))
            local.append(contentsOf: u16le(0))
            local.append(contentsOf: u16le(0)); local.append(contentsOf: u16le(0))
            local.append(contentsOf: crc32le(content))
            local.append(contentsOf: u32le(content.count))
            local.append(contentsOf: u32le(content.count))
            local.append(contentsOf: u16le(fnData.count))
            local.append(contentsOf: u16le(0))
            local.append(fnData)
            local.append(content)

            let off = zip.count
            localOffsets.append((name, off, content.count, content.count, content))
            zip.append(local)
        }

        // Central directory
        var cd = Data()
        for (name, offset, compSize, uncompSize, content) in localOffsets {
            let fnData = name.data(using: .utf8)!
            cd.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
            cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
            cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
            cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
            cd.append(contentsOf: crc32le(content))
            cd.append(contentsOf: u32le(compSize))
            cd.append(contentsOf: u32le(uncompSize))
            cd.append(contentsOf: u16le(fnData.count))
            cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
            cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
            cd.append(contentsOf: u32le(0))
            cd.append(contentsOf: u32le(offset))
            cd.append(fnData)
        }
        let cdOffset = zip.count
        zip.append(cd)

        // EOCD
        let n = localOffsets.count
        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        eocd.append(contentsOf: u16le(0)); eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(n)); eocd.append(contentsOf: u16le(n))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 3)
        XCTAssertEqual(entries[0].filename, "a.txt")
        XCTAssertEqual(entries[0].data, "aaaa".data(using: .utf8)!)
        XCTAssertEqual(entries[1].filename, "b.txt")
        XCTAssertEqual(entries[1].data, "bbbb".data(using: .utf8)!)
        XCTAssertEqual(entries[2].filename, "c.txt")
        XCTAssertEqual(entries[2].data, "cccc".data(using: .utf8)!)
    }

    // MARK: - Tests: EOCD with comment

    func testExtractEOCDWithComment() {
        let content = "hello".data(using: .utf8)!
        let zip = makeStoreZip(filename: "test.txt", content: content)

        // Append a comment to the end of EOCD
        var zipWithComment = zip
        let comment = "this is a zip comment".data(using: .utf8)!
        // Update comment length in EOCD (2 bytes at offset 20 from EOCD start)
        let eocdOffset = zipWithComment.count - 22
        zipWithComment[eocdOffset + 20] = UInt8(comment.count & 0xFF)
        zipWithComment[eocdOffset + 21] = UInt8(comment.count >> 8)
        zipWithComment.append(comment)

        let entries = try! Unzip.extract(data: zipWithComment)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].data, content)
    }

    // MARK: - Tests: Malformed local header

    func testExtractBadLocalFileOffset() {
        let content = "test".data(using: .utf8)!
        let fnData = "bad.txt".data(using: .utf8)!
        var zip = Data()

        // Valid local file header
        var local = Data()
        local.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])
        local.append(contentsOf: u16le(20)); local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0)); local.append(contentsOf: u16le(0))
        local.append(contentsOf: crc32le(content))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u16le(fnData.count))
        local.append(contentsOf: u16le(0))
        local.append(fnData)
        local.append(content)

        zip.append(local)

        // Central directory pointing to invalid offset (99999)
        var cd = Data()
        cd.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
        cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(fnData.count))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(99999))  // bad offset
        cd.append(fnData)

        let cdOffset = zip.count
        zip.append(cd)

        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        eocd.append(contentsOf: u16le(0)); eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(1)); eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        XCTAssertThrowsError(try Unzip.extract(data: zip)) { error in
            guard case Unzip.Error.badFormat(let msg) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(msg.contains("本地文件偏移无效"))
        }
    }

    func testExtractBadLocalFileSignature() {
        let content = "test".data(using: .utf8)!
        let fnData = "bad.txt".data(using: .utf8)!
        var zip = Data()

        // Local file with wrong signature
        var local = Data()
        local.append(contentsOf: [0xFF, 0xFF, 0xFF, 0xFF])  // bad sig
        local.append(contentsOf: u16le(20)); local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0)); local.append(contentsOf: u16le(0))
        local.append(contentsOf: crc32le(content))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u16le(fnData.count))
        local.append(contentsOf: u16le(0))
        local.append(fnData)
        local.append(content)

        let localOffset = zip.count
        zip.append(local)

        // Central directory with correct signature, pointing to the bad local file
        var cd = Data()
        cd.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
        cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(fnData.count))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(localOffset))
        cd.append(fnData)

        let cdOffset = zip.count
        zip.append(cd)

        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        eocd.append(contentsOf: u16le(0)); eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(1)); eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        XCTAssertThrowsError(try Unzip.extract(data: zip)) { error in
            guard case Unzip.Error.badFormat(let msg) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(msg.contains("本地文件头签名错误"))
        }
    }

    // MARK: - Tests: max safety limits

    func testMaxUncompressedSizeConstant() {
        XCTAssertEqual(Unzip.maxUncompressedSize, 100_000_000)
    }

    // MARK: - Tests: Entry struct

    func testEntryInitialization() {
        let entry = Unzip.Entry(filename: "test.txt", data: "hello".data(using: .utf8)!)
        XCTAssertEqual(entry.filename, "test.txt")
        XCTAssertEqual(entry.data, "hello".data(using: .utf8)!)
    }

    // MARK: - Tests: Error descriptions

    func testErrorCannotOpen() {
        let desc = Unzip.Error.cannotOpen.errorDescription
        XCTAssertNotNil(desc)
        XCTAssertTrue(desc!.contains("无法打开"))
    }

    func testErrorBadFormat() {
        let desc = Unzip.Error.badFormat("test error").errorDescription
        XCTAssertTrue(desc!.contains("test error"))
    }

    func testErrorDecompressionFailed() {
        let desc = Unzip.Error.decompressionFailed("inflate error").errorDescription
        XCTAssertTrue(desc!.contains("inflate error"))
    }

    func testErrorUnsupportedMethod() {
        let desc = Unzip.Error.unsupportedMethod(99, "file.txt").errorDescription
        XCTAssertTrue(desc!.contains("99"))
        XCTAssertTrue(desc!.contains("file.txt"))
    }

    func testErrorTooLarge() {
        let desc = Unzip.Error.tooLarge("over 100MB").errorDescription
        XCTAssertTrue(desc!.contains("over 100MB"))
    }

    // MARK: - Tests: BinaryReader

    func testBinaryReaderReadUInt16() {
        var data = Data()
        data.append(contentsOf: [0x34, 0x12])  // little-endian 0x1234
        let reader = BinaryReader(data: data)
        XCTAssertEqual(try! reader.readUInt16(), 0x1234)
    }

    func testBinaryReaderReadUInt32() {
        var data = Data()
        data.append(contentsOf: [0x78, 0x56, 0x34, 0x12])  // little-endian 0x12345678
        let reader = BinaryReader(data: data)
        XCTAssertEqual(try! reader.readUInt32(), 0x12345678)
    }

    func testBinaryReaderReadString() {
        let str = "hello"
        let reader = BinaryReader(data: str.data(using: .utf8)!)
        let result = try! reader.readString(length: 5)
        XCTAssertEqual(result, "hello")
    }

    func testBinaryReaderReadData() {
        let content = Data([0x01, 0x02, 0x03, 0x04])
        let reader = BinaryReader(data: content)
        let result = try! reader.readData(length: 4)
        XCTAssertEqual(result, content)
    }

    func testBinaryReaderSkip() {
        let data = Data([0x01, 0x02, 0x03, 0x04])
        let reader = BinaryReader(data: data)
        reader.skip(2)
        XCTAssertEqual(reader.position, 2)
        XCTAssertEqual(try! reader.readUInt16(), 0x0403)  // little-endian
    }

    func testBinaryReaderOutOfBounds() {
        let reader = BinaryReader(data: Data([0x01]))
        XCTAssertThrowsError(try reader.readUInt16()) { error in
            guard case Unzip.Error.badFormat(let msg) = error else {
                return XCTFail("Expected badFormat")
            }
            XCTAssertTrue(msg.contains("越界"))
        }
    }

    func testBinaryReaderOutOfBoundsReadData() {
        let reader = BinaryReader(data: Data([0x01, 0x02]))
        reader.skip(1)
        XCTAssertThrowsError(try reader.readData(length: 5)) { error in
            guard case Unzip.Error.badFormat(let msg) = error else {
                return XCTFail("Expected badFormat")
            }
            XCTAssertTrue(msg.contains("越界"))
        }
    }

    // MARK: - Tests: EOCD boundary conditions

    func testExtractEOCDAtMinimumPosition() {
        // EOCD exactly at offset 0 (no data before it)
        var data = Data(repeating: 0, count: 22)
        data[0] = 0x50; data[1] = 0x4B; data[2] = 0x05; data[3] = 0x06
        // entries = 0 → bad because totalEntries > 0 check fails
        // Set entries = 1
        data[8] = 1; data[10] = 1
        // central dir offset = 0
        data[16] = 0; data[17] = 0; data[18] = 0; data[19] = 0

        // Should fail because central dir at offset 0 is invalid (centralDirOffset > 0 check)
        XCTAssertThrowsError(try Unzip.extract(data: data))
    }

    func testExtractEOCDWithMaxComment() {
        let content = "hello".data(using: .utf8)!
        let zip = makeStoreZip(filename: "test.txt", content: content)

        // Add a large comment to shift EOCD
        var zipWithComment = Data()
        zipWithComment.append(zip)
        // The EOCD is at the end of zip; we add comment after it and update comment length
        let commentData = Data(repeating: 0x41, count: 100)
        let eocdOffset = zipWithComment.count - 22
        zipWithComment[eocdOffset + 20] = UInt8(100 & 0xFF)
        zipWithComment[eocdOffset + 21] = UInt8(100 >> 8)
        zipWithComment.append(commentData)

        let entries = try! Unzip.extract(data: zipWithComment)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].data, content)
    }

    // MARK: - Tests: Central directory with termination

    func testExtractEOCDInCentralDir() {
        let content = "test".data(using: .utf8)!
        let fnData = "test.txt".data(using: .utf8)!
        var zip = Data()

        // First valid entry
        var local = Data()
        local.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])
        local.append(contentsOf: u16le(20)); local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0)); local.append(contentsOf: u16le(0))
        local.append(contentsOf: crc32le(content))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u16le(fnData.count))
        local.append(contentsOf: u16le(0))
        local.append(fnData)
        local.append(content)
        let localOffset = zip.count
        zip.append(local)

        // Central directory with 2 entries (second one is fake/duplicate),
        // but first entry is valid. EOCD in CD means we stop there.
        // Actually, let's test: totalEntries=2, first CD entry valid, second would crash reader.
        // The min(totalEntries, 50000) loop processes both.
        // Put an EOCD signature as the second CD entry to test the break-on-EOCD behavior.
        var cd = Data()
        // Valid entry
        cd.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
        cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(fnData.count))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(localOffset))
        cd.append(fnData)
        // Fake second entry starts with EOCD signature — should be caught by the break
        cd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        // Add enough zeros so it doesn't crash reading further fields
        cd.append(Data(repeating: 0, count: 46))

        let cdOffset = zip.count
        zip.append(cd)

        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        eocd.append(contentsOf: u16le(0)); eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(2)); eocd.append(contentsOf: u16le(2))  // totalEntries=2
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        // Should not crash - EOCD sig in CD breaks the loop
        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].filename, "test.txt")
    }
}
