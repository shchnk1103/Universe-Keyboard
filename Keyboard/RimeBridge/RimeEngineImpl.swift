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

        // 诊断：比对 default.yaml 中的 schema_list 和 librime 实际返回
        let defaultYamlPath = "\(sharedDataDir)/default.yaml"
        if let dy = try? String(contentsOfFile: defaultYamlPath, encoding: .utf8) {
            let inDefault = dy.contains("schema: rime_ice")
            let inLibRime = schemas.contains("rime_ice")
            Logger.shared.info("default.yaml has rime_ice: \(inDefault), librime lists rime_ice: \(inLibRime)", category: .engine)
            if inDefault && !inLibRime {
                Logger.shared.warning("MISMATCH: default.yaml has rime_ice but librime doesn't list it", category: .engine)
                // Dump schema_list section from default.yaml
                if let dyLines = try? String(contentsOfFile: defaultYamlPath, encoding: .utf8) {
                    let schemaLines = dyLines.components(separatedBy: "\n").enumerated()
                        .filter { $0.element.contains("schema_list") || $0.element.contains("schema:") || $0.element.contains("name:") }
                        .map { "[\($0.offset)] \($0.element)" }
                        .joined(separator: " | ")
                    Logger.shared.info("default.yaml schema section: \(schemaLines)", category: .engine)
                }
                let fm = FileManager.default
                let dictFiles = ["cn_dicts/8105", "cn_dicts/base", "cn_dicts/ext", "cn_dicts/tencent", "cn_dicts/others"]
                for df in dictFiles {
                    let path = "\(sharedDataDir)/\(df).dict.yaml"
                    if !fm.fileExists(atPath: path) { Logger.shared.warning("Missing dict: \(df).dict.yaml", category: .engine) }
                }
            }
        }

        // 选择当前激活的方案（带验证和自动回退）
        let activeSchema = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")?
            .string(forKey: "rime_active_schema") ?? "luna_pinyin"
        let selected = selectAndVerifySchema(activeSchema, fallback: "luna_pinyin")
        Logger.shared.info("Active schema: \(activeSchema), actual: \(selected ?? "nil")", category: .engine)
        if selected != activeSchema {
            Logger.shared.warning("Schema mismatch: wanted '\(activeSchema)', got '\(selected ?? "none")' — schema file may be corrupt", category: .engine)

            // 额外诊断：检查目标 schema 文件是否存在
            let fm = FileManager.default
            let sharedDir = sharedDataDir
            let schemaFile = "\(sharedDir)/\(activeSchema).schema.yaml"
            let dictFile = "\(sharedDir)/\(activeSchema).dict.yaml"
            let schemaExists = fm.fileExists(atPath: schemaFile)
            let dictExists = fm.fileExists(atPath: dictFile)
            Logger.shared.warning("Schema file '\(activeSchema).schema.yaml' exists: \(schemaExists)", category: .engine)
            Logger.shared.warning("Dict file '\(activeSchema).dict.yaml' exists: \(dictExists)", category: .engine)
            if schemaExists {
                if let content = try? String(contentsOfFile: schemaFile, encoding: .utf8) {
                    let hasLua = content.contains("lua_translator") || content.contains("lua_filter") || content.contains("lua_processor")
                    let hasTranslator = content.contains("script_translator") || content.contains("table_translator")
                    Logger.shared.info("Schema contains lua_translator: \(hasLua)", category: .engine)
                    Logger.shared.info("Schema contains script/table_translator: \(hasTranslator)", category: .engine)

                    // 就地修复旧剥离代码遗留的损坏（独立于 RimeConfigManager.repairSchemaIfNeeded）
                    if !hasLua && hasTranslator {
                        let lines = content.components(separatedBy: "\n")
                        let hasBadInitials = lines.contains { line in
                            let t = line.trimmingCharacters(in: .whitespaces)
                            return t.hasPrefix("initials:") &&
                                (t.contains("zyxwvutsrqponmlkjihgfedcba") || t.contains("abcdefghijklmnopqrstuvwxyz"))
                        }
                        let hasOrphan = lines.contains { line in
                            line.trimmingCharacters(in: .whitespaces) == "date_locale: zh"
                        }
                        if hasBadInitials || hasOrphan {
                            var fixed = content
                            if hasBadInitials {
                                fixed = lines.filter { line in
                                    let t = line.trimmingCharacters(in: .whitespaces)
                                    if t.hasPrefix("initials:") && (t.contains("zyxwvutsrqponmlkjihgfedcba") || t.contains("abcdefghijklmnopqrstuvwxyz")) {
                                        return false
                                    }
                                    return true
                                }.joined(separator: "\n")
                            }
                            if hasOrphan {
                                fixed = fixed.components(separatedBy: "\n")
                                    .filter { $0.trimmingCharacters(in: .whitespaces) != "date_locale: zh" }
                                    .joined(separator: "\n")
                            }
                            try? fixed.write(toFile: schemaFile, atomically: true, encoding: .utf8)
                            let what = [hasBadInitials ? "initials" : nil, hasOrphan ? "orphan" : nil].compactMap{$0}.joined(separator: "+")
                            Logger.shared.warning("Engine-side repair: removed \(what) from rime_ice.schema.yaml", category: .engine)

                            // 清除 build 缓存并触发重新部署
                            let buildDir = "\(sharedDir)/build"
                            try? fm.removeItem(atPath: buildDir)
                            try? fm.createDirectory(atPath: buildDir, withIntermediateDirectories: true)
                            let defs = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
                            defs?.set(false, forKey: "rime_deployed")
                            defs?.set(true, forKey: "rime_needs_deploy")
                            defs?.synchronize()
                            Logger.shared.info("Cleared build cache after engine-side repair", category: .engine)
                        }
                    }

                    // 检测是否是旧代码剥离后的损坏文件
                    if !hasLua && !hasTranslator {
                        Logger.shared.warning("Schema appears STRIPPED and BROKEN — please re-download rime_ice in the main app", category: .engine)
                    }
                }
            }
        }

        Logger.shared.performance("Engine init complete", durationMs: elapsed)
    }

    deinit {
        bridge.finalize()
    }

    // MARK: - RimeEngine

    public func processKey(_ key: String) -> RimeOutput {
        // 部署前同步主 App 的配置变更到 .custom.yaml
        if UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")?.bool(forKey: "rime_needs_deploy") == true {
            RimeConfigManager.syncCustomYamlFiles()
        }
        let didDeploy = bridge.deployIfNeeded()
        if didDeploy {
            Logger.shared.info("Hot-reload deployment completed on keystroke", category: .deployment)
            // 部署重建了 session，需要重新选择方案（带验证）
            let schema = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")?
                .string(forKey: "rime_active_schema") ?? "luna_pinyin"
            let actual = selectAndVerifySchema(schema, fallback: "luna_pinyin")
            if actual != schema {
                Logger.shared.warning("Post-deploy schema mismatch: wanted '\(schema)', actual '\(actual ?? "none")'", category: .engine)
            }
        }
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

    // MARK: - Schema selection with verification

    /// 功能测试：发送两个字母 "n"+"i"（形成拼音 "ni"），返回候选数。
    /// rime_ice 的 speller 有 erase/^n$/ 规则会吞掉单 n，所以必须用双键测试。
    private func functionalTestCandidates() -> Int {
        _ = bridge.processKey(Int32(Character("n").asciiValue!), modifiers: 0)
        let secondRaw = bridge.processKey(Int32(Character("i").asciiValue!), modifiers: 0)
        let output = parseOutput(secondRaw)
        bridge.clearComposition()
        return output.candidates.count
    }

    /// 选择 schema 并验证是否真的生效（加载 + 功能性按键测试）。
    /// 如果目标 schema 无效（YAML 损坏/翻译器缺失），自动回退到 fallback。
    /// 返回实际生效的 schema ID。
    @discardableResult
    private func selectAndVerifySchema(_ schemaID: String, fallback: String) -> String? {
        let requested = bridge.selectSchema(schemaID)
        let actual = bridge.currentSchemaID()

        // Phase 1: 验证 schema 是否加载成功
        if actual != schemaID {
            if requested {
                Logger.shared.warning("selectSchema('\(schemaID)') returned true but currentSchemaID is '\(actual)'", category: .engine)
            } else {
                Logger.shared.warning("selectSchema('\(schemaID)') returned false", category: .engine)
            }
            return fallbackToWorkingSchema(from: schemaID, fallback: fallback)
        }

        // Phase 2: 功能性检测 — schema 加载了但可能没有可用的翻译器（Lua 被剥离）
        let cands = functionalTestCandidates()
        if cands == 0 {
            Logger.shared.warning("Schema '\(schemaID)' loaded but produces 0 candidates on 'ni' — translator may be missing (Lua stripped?)", category: .engine)
            return fallbackToWorkingSchema(from: schemaID, fallback: fallback)
        }

        Logger.shared.info("Schema '\(schemaID)' functional: 'ni' produced \(cands) candidates", category: .engine)
        return actual
    }

    /// 从当前无效 schema 回退到可用方案
    private func fallbackToWorkingSchema(from schemaID: String, fallback: String) -> String? {
        // 尝试指定的 fallback
        if fallback != schemaID, bridge.selectSchema(fallback) {
            let fbActual = bridge.currentSchemaID()
            if fbActual == fallback {
                let cands = functionalTestCandidates()
                if cands > 0 {
                    Logger.shared.info("Fallback to '\(fallback)' functional (\(cands) candidates)", category: .engine)
                    return fbActual
                }
                Logger.shared.warning("Fallback '\(fallback)' loaded but produces 0 candidates", category: .engine)
            }
        }

        // 最后尝试：遍历所有可用 schema
        let available = bridge.availableSchemas()
        let ids = available.components(separatedBy: ", ").compactMap { s -> String? in
            let parts = s.components(separatedBy: " — ")
            return parts.first
        }
        for candidateID in ids where candidateID != schemaID && candidateID != fallback {
            if !bridge.selectSchema(candidateID) { continue }
            let cands = functionalTestCandidates()
            if cands > 0 {
                Logger.shared.info("Fallback to '\(candidateID)' functional (\(cands) candidates)", category: .engine)
                return bridge.currentSchemaID()
            }
        }

        Logger.shared.error("All schema fallbacks failed. Engine will not produce candidates.", category: .engine)
        return bridge.currentSchemaID()
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
