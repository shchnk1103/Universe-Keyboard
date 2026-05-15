import Foundation
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
        self.bridge = RimeSessionManager()
        bridge.setup(withSharedDataDir: sharedDataDir, userDataDir: userDataDir)
        bridge.initializeEngine()
        bridge.createSession()

        // 写入诊断信息（插入到日志最前面）
        let schemas = bridge.availableSchemas()
        let version = bridge.librimeVersion()
        let defaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
        let diagText = "[RimeEngine] librime \(version)\n[RimeEngine] Schemas: \(schemas)"
        var existing = defaults?.string(forKey: "rime_diag_log") ?? ""
        existing = diagText + "\n" + existing  // 放在日志最前面
        defaults?.set(existing, forKey: "rime_diag_log")
        defaults?.synchronize()
    }

    deinit {
        bridge.finalize()
    }

    // MARK: - RimeEngine

    public func processKey(_ key: String) -> RimeOutput {
        // 每次按键检查是否需要部署（支持主 App 点击部署后实时生效）
        bridge.deployIfNeeded()
        let keycode = Self.keycode(for: key)
        let raw = bridge.processKey(keycode, modifiers: 0)
        return parseOutput(raw)
    }

    public func selectCandidate(at index: Int) -> RimeOutput {
        let raw = bridge.selectCandidate(at: Int32(index))
        return parseOutput(raw)
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

    public func availableSchemas() -> String {
        bridge.availableSchemas()
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
