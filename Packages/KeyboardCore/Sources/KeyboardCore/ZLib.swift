import Foundation

// MARK: - zlib types

internal typealias uInt = UInt32

internal struct z_stream {
    var next_in: UnsafeMutablePointer<UInt8>? = nil
    var avail_in: uInt = 0
    // 4 bytes implicit padding on arm64
    var total_in: UInt = 0
    var next_out: UnsafeMutablePointer<UInt8>? = nil
    var avail_out: uInt = 0
    // 4 bytes implicit padding on arm64
    var total_out: UInt = 0
    var msg: UnsafePointer<CChar>? = nil
    var state: UnsafeMutableRawPointer? = nil
    var zalloc: UnsafeMutableRawPointer? = nil
    var zfree: UnsafeMutableRawPointer? = nil
    var opaque: UnsafeMutableRawPointer? = nil
    var data_type: Int32 = 0
    // 4 bytes implicit padding on arm64
    var adler: UInt = 0
    var reserved: UInt = 0
}

// MARK: - zlib constants

internal let Z_OK: Int32 = 0
internal let Z_STREAM_END: Int32 = 1
internal let Z_NO_FLUSH: Int32 = 0
internal let Z_FINISH: Int32 = 4
internal let MAX_WBITS: Int32 = 15
internal let Z_DEFAULT_COMPRESSION: Int32 = -1
internal let Z_DEFLATED: Int32 = 8
internal let Z_DEFAULT_STRATEGY: Int32 = 0

internal var zlibVersionString: String {
    String(cString: zlibVersion())
}

// MARK: - zlib functions

@_silgen_name("zlibVersion")
internal func zlibVersion() -> UnsafePointer<CChar>

@_silgen_name("inflateInit2_")
internal func inflateInit2_(_ strm: UnsafeMutablePointer<z_stream>, _ windowBits: Int32, _ version: UnsafePointer<CChar>, _ stream_size: Int32) -> Int32

@_silgen_name("inflate")
internal func inflate(_ strm: UnsafeMutablePointer<z_stream>, _ flush: Int32) -> Int32

@_silgen_name("inflateEnd")
internal func inflateEnd(_ strm: UnsafeMutablePointer<z_stream>) -> Int32

@_silgen_name("deflateInit2_")
internal func deflateInit2_(_ strm: UnsafeMutablePointer<z_stream>, _ level: Int32, _ method: Int32, _ windowBits: Int32, _ memLevel: Int32, _ strategy: Int32, _ version: UnsafePointer<CChar>, _ stream_size: Int32) -> Int32

@_silgen_name("deflate")
internal func deflate(_ strm: UnsafeMutablePointer<z_stream>, _ flush: Int32) -> Int32

@_silgen_name("deflateEnd")
internal func deflateEnd(_ strm: UnsafeMutablePointer<z_stream>) -> Int32
