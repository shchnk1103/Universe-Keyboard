import Foundation
import QuartzCore
import KeyboardCore

/// 基于真实 librime 引擎的 RimeEngine 实现。
///
/// 通过 RimeSessionManager（ObjC 桥接层）调用 librime C API。
/// 负责：keycode 翻译、RimeOutput 构造、session 生命周期管理。
///
/// 配置路径使用 App Group 共享容器：
/// - sharedDataDir: AppGroup/Rime/shared/（YAML schema、dict）
/// - userDataDir: AppGroup/Rime/user/（user.yaml、同步目录）
public final class RimeEngineImpl: RimeEngine {

    private let bridge: RimeSessionManager

    // MARK: - Init

    public init(sharedDataDir: String, userDataDir: String) {
        let startTime = CACurrentMediaTime()

        self.bridge = RimeSessionManager()
        bridge.setup(withSharedDataDir: sharedDataDir, userDataDir: userDataDir)
        bridge.initializeEngine()
        bridge.createSession()

        let elapsed = (CACurrentMediaTime() - startTime) * 1000

        let version = bridge.librimeVersion()
        let schemas = bridge.availableSchemas()
        Logger.shared.info("librime \(version)", category: .engine)
        Logger.shared.info("Schemas: \(schemas)", category: .engine)
        Logger.shared.performance("Engine init complete", durationMs: elapsed)
    }

    deinit {
        bridge.finalize()
    }

    // MARK: - RimeEngine

    public func processKey(_ key: String) -> RimeOutput {
        let keycode = Self.keycode(for: key)
        let raw = bridge.processKey(keycode, modifiers: 0)
        let output = parseOutput(raw)
        if key != "BackSpace" && key != "Delete" {
            let preedit = output.composition?.preeditText ?? ""
            Logger.shared.debug("\(key) → preedit: \(preedit), candidates: \(output.candidates.count)", category: .engine)
        }
        if raw.isEmpty && !bridge.isComposing() && key != "BackSpace" && key != "Delete" {
            Logger.shared.warning("processKey(\(key)) returned empty output", category: .engine)
        }
        return output
    }

    public func selectCandidate(at index: Int) -> RimeOutput {
        let raw = bridge.selectCandidate(at: Int32(index))
        let output = parseOutput(raw)
        Logger.shared.debug("selectCandidate(\(index)) → commit: \(output.committedText ?? "nil")", category: .engine)
        return output
    }

    public func deleteBackward() -> RimeOutput {
        let raw = bridge.deleteBackward()
        return parseOutput(raw)
    }

    public func resetSession() {
        bridge.clearComposition()
    }

    public func isComposing() -> Bool {
        bridge.isComposing()
    }

    // MARK: - Output parsing

    private func parseOutput(_ raw: [AnyHashable: Any]) -> RimeOutput {
        let preedit = raw[RimeKeyPreedit] as? String
        let cursorPos = (raw[RimeKeyCursorPos] as? NSNumber)?.intValue ?? 0

        let composition: RimeComposition?
        if let preedit, !preedit.isEmpty {
            composition = RimeComposition(preeditText: preedit, cursorPosition: cursorPos)
        } else {
            composition = nil
        }

        let rawCandidates = raw[RimeKeyCandidates] as? [[String: String]] ?? []
        let candidates = rawCandidates.map { item in
            RimeCandidate(
                text: item[RimeKeyCandidateText] ?? "",
                comment: item[RimeKeyCandidateComment]
            )
        }

        let commit = raw[RimeKeyCommit] as? String
        let isLastPage = (raw[RimeKeyIsLastPage] as? NSNumber)?.boolValue ?? true
        let highlighted = (raw[RimeKeyHighlightedIndex] as? NSNumber)?.intValue ?? -1

        return RimeOutput(
            composition: composition,
            candidates: candidates,
            committedText: commit,
            hasMorePages: !isLastPage,
            highlightedIndex: highlighted
        )
    }

    // MARK: - Keycode translation

    static func keycode(for key: String) -> Int32 {
        switch key {
        case "BackSpace", "Delete":
            return 0xFF08  // XK_BackSpace
        case "Return", "Enter":
            return 0xFF0D  // XK_Return
        case "space", " ":
            return 0x0020  // XK_space
        case "Escape":
            return 0xFF1B
        case "Tab":
            return 0xFF09
        default:
            break
        }

        if let scalar = key.unicodeScalars.first, key.unicodeScalars.count == 1 {
            let cp = scalar.value
            if cp >= 0x20 && cp <= 0x7E {
                return Int32(cp)
            }
        }

        if key.count == 1, let ascii = key.utf8.first {
            return Int32(ascii)
        }

        return 0
    }
}

// Bridge key constants
private let RimeKeyPreedit          = "preedit"
private let RimeKeyCursorPos        = "cursorPos"
private let RimeKeyCandidates       = "candidates"
private let RimeKeyCandidateText    = "text"
private let RimeKeyCandidateComment = "comment"
private let RimeKeyCommit           = "commit"
private let RimeKeyIsLastPage       = "isLastPage"
private let RimeKeyHighlightedIndex = "highlightedIndex"
