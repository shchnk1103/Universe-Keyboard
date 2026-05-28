import XCTest

@testable import KeyboardCore

final class UnzipBinaryReaderTests: UnzipTestSupport {
    func testMaxUncompressedSizeConstant() {
        XCTAssertEqual(Unzip.maxUncompressedSize, 100_000_000)
    }

    func testEntryInitialization() {
        let entry = Unzip.Entry(filename: "test.txt", data: "hello".data(using: .utf8)!)
        XCTAssertEqual(entry.filename, "test.txt")
        XCTAssertEqual(entry.data, "hello".data(using: .utf8)!)
    }

    func testErrorCannotOpen() {
        let description = Unzip.Error.cannotOpen.errorDescription
        XCTAssertNotNil(description)
        XCTAssertTrue(description!.contains("无法打开"))
    }

    func testErrorBadFormat() {
        let description = Unzip.Error.badFormat("test error").errorDescription
        XCTAssertTrue(description!.contains("test error"))
    }

    func testErrorDecompressionFailed() {
        let description = Unzip.Error.decompressionFailed("inflate error").errorDescription
        XCTAssertTrue(description!.contains("inflate error"))
    }

    func testErrorUnsupportedMethod() {
        let description = Unzip.Error.unsupportedMethod(99, "file.txt").errorDescription
        XCTAssertTrue(description!.contains("99"))
        XCTAssertTrue(description!.contains("file.txt"))
    }

    func testErrorTooLarge() {
        let description = Unzip.Error.tooLarge("over 100MB").errorDescription
        XCTAssertTrue(description!.contains("over 100MB"))
    }

    func testBinaryReaderReadUInt16() {
        var data = Data()
        data.append(contentsOf: [0x34, 0x12])
        let reader = BinaryReader(data: data)
        XCTAssertEqual(try! reader.readUInt16(), 0x1234)
    }

    func testBinaryReaderReadUInt32() {
        var data = Data()
        data.append(contentsOf: [0x78, 0x56, 0x34, 0x12])
        let reader = BinaryReader(data: data)
        XCTAssertEqual(try! reader.readUInt32(), 0x12345678)
    }

    func testBinaryReaderReadString() {
        let string = "hello"
        let reader = BinaryReader(data: string.data(using: .utf8)!)
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
        XCTAssertEqual(try! reader.readUInt16(), 0x0403)
    }

    func testBinaryReaderOutOfBounds() {
        let reader = BinaryReader(data: Data([0x01]))
        XCTAssertThrowsError(try reader.readUInt16()) { error in
            guard case Unzip.Error.badFormat(let message) = error else {
                return XCTFail("Expected badFormat")
            }
            XCTAssertTrue(message.contains("越界"))
        }
    }

    func testBinaryReaderOutOfBoundsReadData() {
        let reader = BinaryReader(data: Data([0x01, 0x02]))
        reader.skip(1)
        XCTAssertThrowsError(try reader.readData(length: 5)) { error in
            guard case Unzip.Error.badFormat(let message) = error else {
                return XCTFail("Expected badFormat")
            }
            XCTAssertTrue(message.contains("越界"))
        }
    }
}
