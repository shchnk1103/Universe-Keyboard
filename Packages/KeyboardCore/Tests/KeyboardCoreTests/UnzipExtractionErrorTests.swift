import XCTest

@testable import KeyboardCore

final class UnzipExtractionErrorTests: UnzipTestSupport {
    func testExtractIncludesEmptyStoredFiles() throws {
        // Store-only zip with empty lua/data/chaifen.txt plus keep.txt.
        let hex =
            "504b030414000000000073a81c5d000000000000000000000000140000006c75612f646174612f6368616966656e2e747874504b030414000000000073a81c5d7d0e16da0300000003000000080000006b6565702e7478746f6b0a504b0102140314000000000073a81c5d0000000000000000000000001400000000000000000000008001000000006c75612f646174612f6368616966656e2e747874504b0102140314000000000073a81c5d7d0e16da03000000030000000800000000000000000000008001320000006b6565702e747874504b05060000000002000200780000005b0000000000"
        var bytes: [UInt8] = []
        var index = hex.startIndex
        while index < hex.endIndex {
            let next = hex.index(index, offsetBy: 2)
            bytes.append(UInt8(hex[index..<next], radix: 16)!)
            index = next
        }
        let entries = try Unzip.extract(data: Data(bytes))
        let byName = Dictionary(uniqueKeysWithValues: entries.map { ($0.filename, $0.data) })
        XCTAssertEqual(byName["lua/data/chaifen.txt"], Data())
        XCTAssertEqual(byName["keep.txt"], Data("ok\n".utf8))
    }

    func testExtractEmptyData() {
        let data = Data()
        XCTAssertThrowsError(try Unzip.extract(data: data)) { error in
            guard case Unzip.Error.badFormat(let message) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(message.contains("文件太小"))
        }
    }

    func testExtractTooSmallData() {
        let data = Data(repeating: 0, count: 21)
        XCTAssertThrowsError(try Unzip.extract(data: data)) { error in
            guard case Unzip.Error.badFormat(let message) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(message.contains("文件太小"))
        }
    }

    func testExtractNoEOCD() {
        let data = Data(repeating: 0, count: 50)
        XCTAssertThrowsError(try Unzip.extract(data: data)) { error in
            guard case Unzip.Error.badFormat(let message) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(message.contains("找不到 EOCD"))
        }
    }

    func testExtractBadEOCDSignature() {
        var data = Data(repeating: 0, count: 128)
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
        let eocdSig: [UInt8] = [0x50, 0x4B, 0x05, 0x06]
        var data = Data(repeating: 0, count: 100)
        let eocdOffset = data.count - 22
        data[eocdOffset] = eocdSig[0]
        data[eocdOffset + 1] = eocdSig[1]
        data[eocdOffset + 2] = eocdSig[2]
        data[eocdOffset + 3] = eocdSig[3]
        data[eocdOffset + 8] = 1
        data[eocdOffset + 10] = 1
        data[eocdOffset + 16] = 0x0F
        data[eocdOffset + 17] = 0x27

        XCTAssertThrowsError(try Unzip.extract(data: data)) { error in
            guard case Unzip.Error.badFormat(let message) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(message.contains("中央目录偏移"))
        }
    }

    func testExtractCorruptedDeflateData() {
        let content = "hello".data(using: .utf8)!
        var zip = makeDeflateZip(filename: "test.txt", content: content)
        let filenameData = "test.txt".data(using: .utf8)!
        let localDataStart = 30 + filenameData.count
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
        let filenameData = "file.txt".data(using: .utf8)!
        var zip = Data()

        let localSig: [UInt8] = [0x50, 0x4B, 0x03, 0x04]
        var local = Data()
        local.append(contentsOf: localSig)
        local.append(contentsOf: u16le(20))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(9))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: crc32le(content))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u16le(filenameData.count))
        local.append(contentsOf: u16le(0))
        local.append(filenameData)
        local.append(content)

        let localOffset = zip.count
        zip.append(local)

        let cdSig: [UInt8] = [0x50, 0x4B, 0x01, 0x02]
        var cd = Data()
        cd.append(contentsOf: cdSig)
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(9))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(filenameData.count))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(localOffset))
        cd.append(filenameData)

        let cdOffset = zip.count
        zip.append(cd)

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

        XCTAssertThrowsError(try Unzip.extract(data: zip)) { error in
            guard case Unzip.Error.unsupportedMethod(let method, _) = error else {
                return XCTFail("Expected unsupportedMethod, got \(error)")
            }
            XCTAssertEqual(method, 9)
        }
    }

    func testExtractTooLargeUncompressedSize() {
        let content = "test".data(using: .utf8)!
        let filenameData = "big.txt".data(using: .utf8)!
        let bigSize = Unzip.maxUncompressedSize + 1
        var zip = Data()

        let localSig: [UInt8] = [0x50, 0x4B, 0x03, 0x04]
        var local = Data()
        local.append(contentsOf: localSig)
        local.append(contentsOf: u16le(20))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: crc32le(content))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u32le(bigSize))
        local.append(contentsOf: u16le(filenameData.count))
        local.append(contentsOf: u16le(0))
        local.append(filenameData)
        local.append(content)

        let localOffset = zip.count
        zip.append(local)

        let cdSig: [UInt8] = [0x50, 0x4B, 0x01, 0x02]
        var cd = Data()
        cd.append(contentsOf: cdSig)
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(bigSize))
        cd.append(contentsOf: u16le(filenameData.count))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(localOffset))
        cd.append(filenameData)

        let cdOffset = zip.count
        zip.append(cd)

        var eocd = Data()
        let eocdSig: [UInt8] = [0x50, 0x4B, 0x05, 0x06]
        eocd.append(contentsOf: eocdSig)
        eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        XCTAssertThrowsError(try Unzip.extract(data: zip)) { error in
            guard case Unzip.Error.badFormat(let message) = error else {
                return XCTFail("Expected badFormat for oversized entry, got \(error)")
            }
            XCTAssertTrue(message.contains("本地文件头字段无效") || message.contains("超过安全上限"))
        }
    }

    func testExtractBadLocalFileOffset() {
        let content = "test".data(using: .utf8)!
        let filenameData = "bad.txt".data(using: .utf8)!
        var zip = Data()

        var local = Data()
        local.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])
        local.append(contentsOf: u16le(20))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: crc32le(content))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u16le(filenameData.count))
        local.append(contentsOf: u16le(0))
        local.append(filenameData)
        local.append(content)
        zip.append(local)

        var cd = Data()
        cd.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(filenameData.count))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(99999))
        cd.append(filenameData)

        let cdOffset = zip.count
        zip.append(cd)

        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        XCTAssertThrowsError(try Unzip.extract(data: zip)) { error in
            guard case Unzip.Error.badFormat(let message) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(message.contains("本地文件偏移无效"))
        }
    }

    func testExtractBadLocalFileSignature() {
        let content = "test".data(using: .utf8)!
        let filenameData = "bad.txt".data(using: .utf8)!
        var zip = Data()

        var local = Data()
        local.append(contentsOf: [0xFF, 0xFF, 0xFF, 0xFF])
        local.append(contentsOf: u16le(20))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: crc32le(content))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u32le(content.count))
        local.append(contentsOf: u16le(filenameData.count))
        local.append(contentsOf: u16le(0))
        local.append(filenameData)
        local.append(content)

        let localOffset = zip.count
        zip.append(local)

        var cd = Data()
        cd.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(filenameData.count))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(localOffset))
        cd.append(filenameData)

        let cdOffset = zip.count
        zip.append(cd)

        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u16le(1))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        XCTAssertThrowsError(try Unzip.extract(data: zip)) { error in
            guard case Unzip.Error.badFormat(let message) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(message.contains("本地文件头签名错误"))
        }
    }

    func testExtractEOCDAtMinimumPosition() {
        var data = Data(repeating: 0, count: 22)
        data[0] = 0x50
        data[1] = 0x4B
        data[2] = 0x05
        data[3] = 0x06
        data[8] = 1
        data[10] = 1
        XCTAssertThrowsError(try Unzip.extract(data: data))
    }

    func testSafeRelativePathAcceptsUnicodeAndNestedFiles() throws {
        XCTAssertEqual(
            try Unzip.safeRelativePath(for: "词库/基础/wanxiang.dict.yaml"),
            "词库/基础/wanxiang.dict.yaml"
        )
        XCTAssertEqual(try Unzip.safeRelativePath(for: "lua/"), "lua")
    }

    func testSafeRelativePathRejectsTraversalAndAmbiguousAliases() {
        for path in [
            "../escape.txt",
            "folder/../escape.txt",
            "/absolute.txt",
            "folder\\escape.txt",
            "C:escape.txt",
            "folder//file.txt",
            "./file.txt",
            "",
        ] {
            XCTAssertThrowsError(try Unzip.safeRelativePath(for: path), "应拒绝 \(path)")
        }
    }

    func testExtractRejectsUnsafePathBeforeWritingOutsideDestination() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("unzip-path-security-\(UUID().uuidString)")
        let destination = root.appendingPathComponent("destination")
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let archiveURL = root.appendingPathComponent("malicious.zip")
        try makeStoreZip(filename: "../escape.txt", content: Data("blocked".utf8))
            .write(to: archiveURL)

        XCTAssertThrowsError(try Unzip.extract(zipPath: archiveURL.path, to: destination))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("escape.txt").path))
    }

    func testExtractRejectsUnixSymbolicLinkEntry() {
        var zip = makeStoreZip(filename: "link", content: Data("../outside".utf8))
        guard let centralOffset = zip.range(of: Data([0x50, 0x4B, 0x01, 0x02]))?.lowerBound else {
            return XCTFail("测试 ZIP 缺少中央目录")
        }

        // version made by: Unix (3), version 2.0 (20)
        zip[centralOffset + 4] = 20
        zip[centralOffset + 5] = 3
        // external attributes: Unix mode 0120777 (symbolic link)
        let symbolicLinkAttributes = u32le(0xA1FF_0000)
        zip.replaceSubrange(centralOffset + 38..<centralOffset + 42, with: symbolicLinkAttributes)

        XCTAssertThrowsError(try Unzip.extract(data: zip)) { error in
            guard case Unzip.Error.badFormat(let message) = error else {
                return XCTFail("Expected badFormat, got \(error)")
            }
            XCTAssertTrue(message.contains("符号链接"))
        }
    }
}
