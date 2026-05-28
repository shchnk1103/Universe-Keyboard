import XCTest

@testable import KeyboardCore

class UnzipTestSupport: XCTestCase {
    /// Create a minimal valid zip with one file using store method (no compression).
    func makeStoreZip(filename: String, content: Data) -> Data {
        let fnData = filename.data(using: .utf8)!
        var zip = Data()

        let localSig: [UInt8] = [0x50, 0x4B, 0x03, 0x04]
        var localHeader = Data()
        localHeader.append(contentsOf: localSig)
        localHeader.append(contentsOf: u16le(20))
        localHeader.append(contentsOf: u16le(0))
        localHeader.append(contentsOf: u16le(0))
        localHeader.append(contentsOf: u16le(0))
        localHeader.append(contentsOf: u16le(0))
        localHeader.append(contentsOf: crc32le(content))
        localHeader.append(contentsOf: u32le(content.count))
        localHeader.append(contentsOf: u32le(content.count))
        localHeader.append(contentsOf: u16le(fnData.count))
        localHeader.append(contentsOf: u16le(0))
        localHeader.append(fnData)
        localHeader.append(content)

        let localOffset = zip.count
        zip.append(localHeader)

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

    /// Create a minimal valid zip with one file using deflate method.
    func makeDeflateZip(filename: String, content: Data) -> Data {
        let compressed = deflateData(content)
        let fnData = filename.data(using: .utf8)!
        var zip = Data()

        let localSig: [UInt8] = [0x50, 0x4B, 0x03, 0x04]
        var localHeader = Data()
        localHeader.append(contentsOf: localSig)
        localHeader.append(contentsOf: u16le(20))
        localHeader.append(contentsOf: u16le(0))
        localHeader.append(contentsOf: u16le(8))
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

        let cdSig: [UInt8] = [0x50, 0x4B, 0x01, 0x02]
        var cd = Data()
        cd.append(contentsOf: cdSig)
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(20))
        cd.append(contentsOf: u16le(0))
        cd.append(contentsOf: u16le(8))
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
        XCTAssertEqual(
            deflateInit2_(
                &zs,
                Z_DEFAULT_COMPRESSION,
                Z_DEFLATED,
                -MAX_WBITS,
                8,
                Z_DEFAULT_STRATEGY,
                zlibVersion(),
                Int32(MemoryLayout<z_stream>.size)
            ),
            Z_OK
        )
        defer { _ = deflateEnd(&zs) }

        let inCount = data.count
        let outCapacity = max(inCount * 2 + 16, 64)
        var result = Data(count: outCapacity)

        return data.withUnsafeBytes { (inputPtr: UnsafeRawBufferPointer) in
            zs.next_in = UnsafeMutablePointer(mutating: inputPtr.bindMemory(to: UInt8.self).baseAddress)
            zs.avail_in = uInt(inCount)

            result.withUnsafeMutableBytes { (outputPtr: UnsafeMutableRawBufferPointer) in
                zs.next_out = outputPtr.baseAddress?.assumingMemoryBound(to: UInt8.self)
                zs.avail_out = uInt(outCapacity)
                _ = deflate(&zs, Z_FINISH)
            }
            result.count = Int(zs.total_out)
            return result
        }
    }

    func u16le(_ value: Int) -> [UInt8] {
        let unsignedValue = UInt16(value)
        return [UInt8(unsignedValue & 0xFF), UInt8(unsignedValue >> 8)]
    }

    func u32le(_ value: Int) -> [UInt8] {
        let unsignedValue = UInt32(value)
        return [
            UInt8(unsignedValue & 0xFF),
            UInt8(unsignedValue >> 8 & 0xFF),
            UInt8(unsignedValue >> 16 & 0xFF),
            UInt8(unsignedValue >> 24 & 0xFF),
        ]
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
}
