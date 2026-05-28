import Foundation

/// Cursor-based little-endian access for ZIP record fields.
final class BinaryReader {
    let data: Data
    var position: Int = 0

    init(data: Data) { self.data = data }

    func checkBounds(_ size: Int) throws {
        guard position + size <= data.count else {
            throw Unzip.Error.badFormat("读取越界：pos=\(position) size=\(size) data=\(data.count)")
        }
    }

    func skip(_ count: Int) { position += count }

    func readUInt16() throws -> UInt16 {
        try checkBounds(2)
        let value = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt16.self) }
        position += 2
        return UInt16(littleEndian: value)
    }

    func readUInt32() throws -> UInt32 {
        try checkBounds(4)
        let value = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: position, as: UInt32.self) }
        position += 4
        return UInt32(littleEndian: value)
    }

    func readString(length: Int) throws -> String {
        try checkBounds(length)
        let bytes = data.subdata(in: position..<position + length)
        position += length
        return String(data: bytes, encoding: .utf8) ?? String(decoding: bytes, as: UTF8.self)
    }

    func readData(length: Int) throws -> Data {
        try checkBounds(length)
        let result = data.subdata(in: position..<position + length)
        position += length
        return result
    }
}
