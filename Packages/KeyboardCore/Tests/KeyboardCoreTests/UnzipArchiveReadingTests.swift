import XCTest

@testable import KeyboardCore

final class UnzipArchiveReadingTests: UnzipTestSupport {
    func testExtractDirectoryEntrySkipped() {
        let content = "file content".data(using: .utf8)!
        let dirName = "subdir/".data(using: .utf8)!
        let fileName = "subdir/readme.txt".data(using: .utf8)!
        var zip = Data()

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

        var fileLocal = Data()
        fileLocal.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])
        fileLocal.append(contentsOf: u16le(20)); fileLocal.append(contentsOf: u16le(0))
        fileLocal.append(contentsOf: u16le(0))
        fileLocal.append(contentsOf: u16le(0)); fileLocal.append(contentsOf: u16le(0))
        fileLocal.append(contentsOf: crc32le(content))
        fileLocal.append(contentsOf: u32le(content.count))
        fileLocal.append(contentsOf: u32le(content.count))
        fileLocal.append(contentsOf: u16le(fileName.count))
        fileLocal.append(contentsOf: u16le(0))
        fileLocal.append(fileName)
        fileLocal.append(content)
        let fileOffset = zip.count
        zip.append(fileLocal)

        var cd = Data()
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

        cd.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
        cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(fileName.count))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(fileOffset))
        cd.append(fileName)

        let cdOffset = zip.count
        zip.append(cd)

        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        eocd.append(contentsOf: u16le(0)); eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(2)); eocd.append(contentsOf: u16le(2))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].filename, "subdir/readme.txt")
        XCTAssertEqual(entries[0].data, content)
    }

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
        var content = Data()
        for i in 0..<256 { content.append(UInt8(i)) }
        let zip = makeStoreZip(filename: "binary.bin", content: content)
        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].data, content)
    }

    func testExtractStoreMethodEmptyContent() {
        let content = "X".data(using: .utf8)!
        let zip = makeStoreZip(filename: "empty.txt", content: content)
        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].data, content)
    }

    func testExtractDeflateMethod() {
        let content = "The quick brown fox jumps over the lazy dog. ".data(using: .utf8)!
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

    func testExtractMultipleStoreEntries() {
        let files: [(String, Data)] = [
            ("a.txt", "aaaa".data(using: .utf8)!),
            ("b.txt", "bbbb".data(using: .utf8)!),
            ("c.txt", "cccc".data(using: .utf8)!),
        ]

        var zip = Data()
        var localOffsets: [(String, Int, Int, Int, Data)] = []

        for (name, content) in files {
            let filenameData = name.data(using: .utf8)!
            var local = Data()
            local.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])
            local.append(contentsOf: u16le(20)); local.append(contentsOf: u16le(0))
            local.append(contentsOf: u16le(0))
            local.append(contentsOf: u16le(0)); local.append(contentsOf: u16le(0))
            local.append(contentsOf: crc32le(content))
            local.append(contentsOf: u32le(content.count))
            local.append(contentsOf: u32le(content.count))
            local.append(contentsOf: u16le(filenameData.count))
            local.append(contentsOf: u16le(0))
            local.append(filenameData)
            local.append(content)

            let offset = zip.count
            localOffsets.append((name, offset, content.count, content.count, content))
            zip.append(local)
        }

        var cd = Data()
        for (name, offset, compressedSize, uncompressedSize, content) in localOffsets {
            let filenameData = name.data(using: .utf8)!
            cd.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])
            cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
            cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
            cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
            cd.append(contentsOf: crc32le(content))
            cd.append(contentsOf: u32le(compressedSize))
            cd.append(contentsOf: u32le(uncompressedSize))
            cd.append(contentsOf: u16le(filenameData.count))
            cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
            cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
            cd.append(contentsOf: u32le(0))
            cd.append(contentsOf: u32le(offset))
            cd.append(filenameData)
        }
        let cdOffset = zip.count
        zip.append(cd)

        let count = localOffsets.count
        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        eocd.append(contentsOf: u16le(0)); eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(count)); eocd.append(contentsOf: u16le(count))
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

    func testExtractEOCDWithComment() {
        let content = "hello".data(using: .utf8)!
        let zip = makeStoreZip(filename: "test.txt", content: content)

        var zipWithComment = zip
        let comment = "this is a zip comment".data(using: .utf8)!
        let eocdOffset = zipWithComment.count - 22
        zipWithComment[eocdOffset + 20] = UInt8(comment.count & 0xFF)
        zipWithComment[eocdOffset + 21] = UInt8(comment.count >> 8)
        zipWithComment.append(comment)

        let entries = try! Unzip.extract(data: zipWithComment)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].data, content)
    }

    func testExtractEOCDWithMaxComment() {
        let content = "hello".data(using: .utf8)!
        let zip = makeStoreZip(filename: "test.txt", content: content)

        var zipWithComment = Data()
        zipWithComment.append(zip)
        let commentData = Data(repeating: 0x41, count: 100)
        let eocdOffset = zipWithComment.count - 22
        zipWithComment[eocdOffset + 20] = UInt8(100 & 0xFF)
        zipWithComment[eocdOffset + 21] = UInt8(100 >> 8)
        zipWithComment.append(commentData)

        let entries = try! Unzip.extract(data: zipWithComment)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].data, content)
    }

    func testExtractEOCDInCentralDir() {
        let content = "test".data(using: .utf8)!
        let filenameData = "test.txt".data(using: .utf8)!
        var zip = Data()

        var local = Data()
        local.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])
        local.append(contentsOf: u16le(20)); local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0))
        local.append(contentsOf: u16le(0)); local.append(contentsOf: u16le(0))
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
        cd.append(contentsOf: u16le(20)); cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: crc32le(content))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u32le(content.count))
        cd.append(contentsOf: u16le(filenameData.count))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(0)); cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u32le(0))
        cd.append(contentsOf: u32le(localOffset))
        cd.append(filenameData)
        cd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        cd.append(Data(repeating: 0, count: 46))

        let cdOffset = zip.count
        zip.append(cd)

        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])
        eocd.append(contentsOf: u16le(0)); eocd.append(contentsOf: u16le(0))
        eocd.append(contentsOf: u16le(2)); eocd.append(contentsOf: u16le(2))
        eocd.append(contentsOf: u32le(cd.count))
        eocd.append(contentsOf: u32le(cdOffset))
        eocd.append(contentsOf: u16le(0))
        zip.append(eocd)

        let entries = try! Unzip.extract(data: zip)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].filename, "test.txt")
    }
}
