import Foundation

/// Wall-time split for one `processKey` bridge call: librime API vs output collection.
///
/// Attached by ObjC without changing `KeyboardCore.RimeOutput`. Never carries key or
/// candidate text — durations only, for continuous-typing spike attribution.
struct RimeProcessKeyBridgeTiming: Equatable {
    let librimeProcessKeyMs: Double
    let collectOutputMs: Double

    var totalMs: Double { librimeProcessKeyMs + collectOutputMs }

    init?(rawOutput: [AnyHashable: Any]) {
        if let librime = (rawOutput[Key.librimeMs] as? NSNumber)?.doubleValue,
           let collect = (rawOutput[Key.collectMs] as? NSNumber)?.doubleValue
        {
            librimeProcessKeyMs = librime
            collectOutputMs = collect
            return
        }
        // Backward-compatible: first-key-only legacy keys.
        if let librime = (rawOutput[Key.firstLibrimeMs] as? NSNumber)?.doubleValue,
           let collect = (rawOutput[Key.firstCollectMs] as? NSNumber)?.doubleValue
        {
            librimeProcessKeyMs = librime
            collectOutputMs = collect
            return
        }
        return nil
    }

    var diagnosticDescription: String {
        "processKey=(api \(String(format: "%.1f", librimeProcessKeyMs))ms, "
            + "collect \(String(format: "%.1f", collectOutputMs))ms, "
            + "total \(String(format: "%.1f", totalMs))ms)"
    }

    private enum Key {
        static let librimeMs = "processKeyLibrimeDurationMs"
        static let collectMs = "processKeyCollectDurationMs"
        static let firstLibrimeMs = "firstProcessKeyLibrimeDurationMs"
        static let firstCollectMs = "firstProcessKeyOutputDurationMs"
    }
}
