import Foundation

/// 仅承载新 RIME session 首键的阶段耗时。
///
/// 这些字段由 ObjC bridge 附在已有输出字典上；它们不改变 KeyboardCore 的
/// `RimeOutput`，也不携带按键、候选或宿主文本。
struct RimeFirstKeyBridgeTiming: Equatable {
    let librimeProcessKeyMs: Double
    let outputCollectionMs: Double
    let totalMs: Double

    init?(rawOutput: [AnyHashable: Any]) {
        guard
            let librimeProcessKeyMs =
                (rawOutput[Key.librimeProcessKeyMs] as? NSNumber)?.doubleValue,
            let outputCollectionMs =
                (rawOutput[Key.outputCollectionMs] as? NSNumber)?.doubleValue,
            let totalMs =
                (rawOutput[Key.totalMs] as? NSNumber)?.doubleValue
        else {
            return nil
        }

        self.librimeProcessKeyMs = librimeProcessKeyMs
        self.outputCollectionMs = outputCollectionMs
        self.totalMs = totalMs
    }

    var diagnosticDescription: String {
        "firstProcessKey=(api \(String(format: "%.1f", librimeProcessKeyMs))ms, "
            + "output \(String(format: "%.1f", outputCollectionMs))ms, "
            + "total \(String(format: "%.1f", totalMs))ms)"
    }

    private enum Key {
        static let librimeProcessKeyMs = "firstProcessKeyLibrimeDurationMs"
        static let outputCollectionMs = "firstProcessKeyOutputDurationMs"
        static let totalMs = "firstProcessKeyTotalDurationMs"
    }
}
