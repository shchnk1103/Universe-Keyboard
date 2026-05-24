import Foundation
import QuartzCore
import KeyboardCore

/// 基于真实 librime 引擎的 RimeEngine 协议实现。
///
/// ── 架构概述（ObjC 桥接模式）──────────────────────────────────
/// 本文件是 Swift → ObjC → C  三层桥接的中间层：
///
///   Swift (此文件)  ←→  ObjC (RimeSessionManager)  ←→  C (librime API)
///       ↓                        ↓                          ↓
///   RimeEngine 协议         RimeSessionManager.m         rime_api.h
///   (纯 Swift 接口)       (封装 C 指针/内存管理)      (官方 C API)
///
/// 为什么需要 ObjC 中间层？
/// - librime 是 C 库，C 头文件在 Swift 中不能直接使用
/// - ObjC 可以包含 C 头文件（通过 ObjC++），Swift 可以调用 ObjC 方法
/// - RimeSessionManager 封装了 C 指针管理、内存释放等危险操作
///
/// ── 职责 ─────────────────────────────────────────────────────
/// 1. 键盘按键码翻译（如 "n" → 0x006e, "BackSpace" → 0xFF08）
/// 2. RIME 输出的解析（NSDictionary → RimeOutput）
/// 3. Session 生命周期管理（创建/销毁/恢复）
/// 4. Schema（输入方案）选择与验证
/// 5. 热部署检测（在每次按键时检查是否需要重新编译配置）
///
/// ── 线程安全 ─────────────────────────────────────────────────
/// librime 不是线程安全的。所有 RIME API 调用必须在同一线程。
/// 键盘扩展中所有输入事件都在主线程，所以这不存在问题。
/// 但不要从后台队列调用 processKey/selectCandidate。
///
/// ── 配置路径 ─────────────────────────────────────────────────
/// 使用 App Group 共享容器，主 App 和键盘扩展都可读写：
/// - sharedDataDir: AppGroup/Rime/shared/（YAML schema、dict、OpenCC）
/// - userDataDir: AppGroup/Rime/user/（user.yaml、同步目录）
public final class RimeEngineImpl: RimeEngine {

    /// ObjC 桥接层实例（封装 librime C API）
    private let bridge: RimeSessionManager

    // MARK: === Init ===

    /// 初始化 RIME 引擎。
    ///
    /// 初始化步骤：
    ///   1. 创建 RimeSessionManager（ObjC 桥接层）
    ///   2. setup：配置 RIME traits（目录路径、模块列表）
    ///   3. initializeEngine：启动 librime，做快速的增量部署检查
    ///   4. createSession：创建输入会话（session 是 librime 的核心抽象）
    ///   5. 诊断日志：打印 librime 版本、可用 schema 列表
    ///   6. Schema 选择与验证：选择用户上次的 schema，功能测试确保可用
    ///
    /// - Parameters:
    ///   - sharedDataDir: RIME 共享数据目录（schema、dict 等配置文件）
    ///   - userDataDir: RIME 用户数据目录（user.yaml、同步等）
    public init(sharedDataDir: String, userDataDir: String) {
        let startTime = CACurrentMediaTime()

        self.bridge = RimeSessionManager()

        // ── 1. Setup + Initialize ──────────────────────────────
        // setup: 设置 RIME 的数据目录和模块列表
        // initializeEngine: 启动 librime，处理基础配置
        bridge.setup(withSharedDataDir: sharedDataDir, userDataDir: userDataDir)
        bridge.initializeEngine()

        // ── 2. 创建 RIME session ──────────────────────────────
        // session 是 librime 的核心概念 — 每个 session 维护独立的输入状态
        // 包括：composition（拼音缓冲区）、candidates（候选列表）、context（上下文）
        bridge.createSession()

        let elapsed = (CACurrentMediaTime() - startTime) * 1000

        // ── 3. 诊断：打印 librime 版本和可用方案 ──────────────
        let version = bridge.librimeVersion()
        let schemas = bridge.availableSchemas()
        Logger.shared.info("librime \(version)", category: .engine)
        Logger.shared.info("Schemas: \(schemas)", category: .engine)

        // ── 4. 诊断：比对 default.yaml 配置与实际加载结果 ────
        // 这个检查用于发现配置不一致的问题，例如：
        // default.yaml 的 schema_list 包含了 rime_ice，但 librime 因为
        // schema 文件损坏/Lua 被剥离/词库缺失而无法加载它
        let defaultYamlPath = "\(sharedDataDir)/default.yaml"
        if let dy = try? String(contentsOfFile: defaultYamlPath, encoding: .utf8) {
            let inDefault = dy.contains("schema: rime_ice")
            let inLibRime = schemas.contains("rime_ice")
            Logger.shared.info(
                "default.yaml has rime_ice: \(inDefault), " +
                "librime lists rime_ice: \(inLibRime)",
                category: .engine
            )

            // 如果配置声明了 rime_ice 但 librime 加载不出来 → 诊断
            if inDefault && !inLibRime {
                Logger.shared.warning(
                    "MISMATCH: default.yaml has rime_ice but librime doesn't list it",
                    category: .engine
                )

                // 打印 schema_list 段：帮助定位是配置语法错误还是文件问题
                if let dyLines = try? String(contentsOfFile: defaultYamlPath, encoding: .utf8) {
                    let schemaLines = dyLines.components(separatedBy: "\n").enumerated()
                        .filter {
                            $0.element.contains("schema_list") ||
                            $0.element.contains("schema:") ||
                            $0.element.contains("name:")
                        }
                        .map { "[\($0.offset)] \($0.element)" }
                        .joined(separator: " | ")
                    Logger.shared.info(
                        "default.yaml schema section: \(schemaLines)",
                        category: .engine
                    )
                }

                // 检查关键的词库文件是否存在
                let fm = FileManager.default
                let dictFiles = [
                    "cn_dicts/8105", "cn_dicts/base", "cn_dicts/ext",
                    "cn_dicts/tencent", "cn_dicts/others"
                ]
                for df in dictFiles {
                    let path = "\(sharedDataDir)/\(df).dict.yaml"
                    if !fm.fileExists(atPath: path) {
                        Logger.shared.warning(
                            "Missing dict: \(df).dict.yaml",
                            category: .engine
                        )
                    }
                }
            }
        }

        // ── 5. Schema 选择与验证 ──────────────────────────────
        let activeSchema = UserDefaults(
            suiteName: "group.com.DoubleShy0N.Universe-Keyboard"
        )?.string(forKey: "rime_active_schema") ?? "luna_pinyin"

        let selected = selectAndVerifySchema(activeSchema, fallback: "luna_pinyin")
        Logger.shared.info(
            "Active schema: \(activeSchema), actual: \(selected ?? "nil")",
            category: .engine
        )

        if selected != activeSchema {
            Logger.shared.warning(
                "Schema mismatch: wanted '\(activeSchema)', " +
                "got '\(selected ?? "none")' — schema file may be corrupt",
                category: .engine
            )

            // 诊断：检查目标 schema 文件是否存在
            let fm = FileManager.default
            let sharedDir = sharedDataDir
            let schemaFile = "\(sharedDir)/\(activeSchema).schema.yaml"
            let dictFile = "\(sharedDir)/\(activeSchema).dict.yaml"
            let schemaExists = fm.fileExists(atPath: schemaFile)
            let dictExists = fm.fileExists(atPath: dictFile)
            Logger.shared.warning(
                "Schema file '\(activeSchema).schema.yaml' exists: \(schemaExists)",
                category: .engine
            )
            Logger.shared.warning(
                "Dict file '\(activeSchema).dict.yaml' exists: \(dictExists)",
                category: .engine
            )

            if schemaExists {
                if let content = try? String(contentsOfFile: schemaFile, encoding: .utf8) {
                    let hasLua = content.contains("lua_translator") ||
                        content.contains("lua_filter") ||
                        content.contains("lua_processor")
                    let hasTranslator = content.contains("script_translator") ||
                        content.contains("table_translator")
                    Logger.shared.info(
                        "Schema contains lua: \(hasLua), " +
                        "translator: \(hasTranslator)",
                        category: .engine
                    )

                    // 如果有 Lua 被剥离但有可用翻译器 → 尝试修复
                    if !hasLua && hasTranslator {
                        RimeConfigPostProcessor.repairSchemaIfNeeded(at: schemaFile)
                    }

                    // 两者都没有 → 完全损坏的文件
                    if !hasLua && !hasTranslator {
                        Logger.shared.warning(
                            "Schema appears STRIPPED and BROKEN — " +
                            "please re-download rime_ice in the main app",
                            category: .engine
                        )
                    }
                }
            }
        }

        Logger.shared.performance("Engine init complete", durationMs: elapsed)
    }

    deinit {
        // 释放 librime 资源：销毁 session → finalize 引擎
        bridge.finalize()
    }

    // MARK: === RimeEngine 协议实现 ===

    /// 处理一个按键输入。
    ///
    /// 处理流程：
    ///   1. 检查是否需要在本次按键前执行部署（rime_needs_deploy）
    ///   2. 如果需要部署：清除 build 缓存 → 全量 maintenance → 重建 session → 重新选择 schema
    ///   3. 将 Swift 按键字符（如 "n"）翻译为 X11 keysym（如 0x006e）
    ///   4. 调用 librime process_key（核心 API）
    ///   5. 解析返回的 NSDictionary 为 RimeOutput
    ///
    /// - Parameter key: Swift 字符串按键（"a", "BackSpace", "space", etc.）
    /// - Returns: RimeOutput（包含 composition、candidates、committed text）
    public func processKey(_ key: String) -> RimeOutput {
        let startTime = CACurrentMediaTime()

        // ── 1. 部署前配置同步 ──────────────────────────────────
        // 从 UserDefaults 同步主 App 的配置变更到 .custom.yaml
        if UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")?
            .bool(forKey: "rime_needs_deploy") == true {
            RimeConfigManager.syncCustomYamlFiles()
        }

        // ── 2. 热部署检测 ─────────────────────────────────────
        // deployIfNeeded 是轻量检查 — 只在 rime_needs_deploy=true 时执行重操作
        let deployStartTime = CACurrentMediaTime()
        let didDeploy = bridge.deployIfNeeded()
        if didDeploy, Logger.shared.isEnabled {
            let deployElapsed = (CACurrentMediaTime() - deployStartTime) * 1000
            Logger.shared.performance(
                "RIME deployIfNeeded on key '\(key)' " +
                "(\(String(format: "%.1f", deployElapsed))ms)"
            )
        }

        if didDeploy {
            Logger.shared.info(
                "Hot-reload deployment completed on keystroke",
                category: .deployment
            )

            // 部署会销毁旧 session 并创建新的，需要重新选择并验证 scheme
            let schema = UserDefaults(
                suiteName: "group.com.DoubleShy0N.Universe-Keyboard"
            )?.string(forKey: "rime_active_schema") ?? "luna_pinyin"
            let actual = selectAndVerifySchema(schema, fallback: "luna_pinyin")
            if actual != schema {
                Logger.shared.warning(
                    "Post-deploy schema mismatch: wanted '\(schema)', " +
                    "actual '\(actual ?? "none")'",
                    category: .engine
                )
            }
        }

        // ── 3. 字符 → X11 keysym 翻译 ────────────────────────
        let keycode = Self.keycode(for: key)

        // ── 4. 调用 librime process_key ──────────────────────
        let bridgeStartTime = CACurrentMediaTime()
        let raw = bridge.processKey(keycode, modifiers: 0)
        let bridgeElapsed = (CACurrentMediaTime() - bridgeStartTime) * 1000

        // ── 5. 解析输出 ──────────────────────────────────────
        let output = parseOutput(raw)

        // 性能日志（跳过高频的删除键避免日志洪水）
        if Logger.shared.isEnabled, key != "BackSpace", key != "Delete" {
            let totalElapsed = (CACurrentMediaTime() - startTime) * 1000
            Logger.shared.performance(
                "RIME processKey '\(key)' returned " +
                "(bridge \(String(format: "%.1f", bridgeElapsed))ms, " +
                "total \(String(format: "%.1f", totalElapsed))ms, " +
                "candidates \(output.candidates.count))"
            )
        }

        // 每个按键的调试日志（跳过删除键）
        if key != "BackSpace" && key != "Delete" {
            let preedit = output.composition?.preeditText ?? ""
            Logger.shared.debug(
                "\(key) → preedit: \(preedit), " +
                "candidates: \(output.candidates.count)",
                category: .engine
            )
        }

        // 空输出检测：不是删除键，但返回了空输出且 comp 也为空
        if raw.isEmpty && !bridge.isComposing()
            && key != "BackSpace" && key != "Delete" {
            Logger.shared.warning(
                "processKey(\(key)) returned empty output",
                category: .engine
            )
        }

        return output
    }

    /// 选择指定索引的候选词。
    /// - Parameter index: 0-based 候选索引
    /// - Returns: 选择后的 RIME 输出（可能包含新的候选页或 commit）
    public func selectCandidate(at index: Int) -> RimeOutput {
        let raw = bridge.selectCandidate(at: Int32(index))
        let output = parseOutput(raw)
        Logger.shared.debug(
            "selectCandidate(\(index)) → commit: \(output.committedText ?? "nil")",
            category: .engine
        )
        return output
    }

    /// 在 RIME 中删除一个字符（回退拼音）。
    public func deleteBackward() -> RimeOutput {
        let raw = bridge.deleteBackward()
        return parseOutput(raw)
    }

    /// 重置当前 RIME session 的输入状态（清除拼音 composition）。
    public func resetSession() {
        bridge.clearComposition()
    }

    /// 查询 RIME 是否有活跃的 composition（拼音正在输入中）。
    public func isComposing() -> Bool {
        bridge.isComposing()
    }

    /// 候选词翻页（上一页）。
    /// 发送 XK_Page_Up (0xFF55) 按键码到 librime。
    public func pageUp() -> RimeOutput {
        let raw = bridge.processKey(0xFF55, modifiers: 0)
        return parseOutput(raw)
    }

    /// 候选词翻页（下一页）。
    /// 发送 XK_Page_Down (0xFF56) 按键码到 librime。
    public func pageDown() -> RimeOutput {
        let raw = bridge.processKey(0xFF56, modifiers: 0)
        return parseOutput(raw)
    }

    /// 获取可用 schema 列表字符串。
    public func availableSchemas() -> String {
        bridge.availableSchemas()
    }

    // MARK: === 输出解析 ===

    /// 将 RimeSessionManager 返回的 NSDictionary 转换为类型安全的 RimeOutput。
    ///
    /// 从 RimeSessionManager.collectOutput 返回的字典结构：
    ///   {
    ///     "preedit": "ni hao",          // 拼音串
    ///     "cursorPos": 5,               // 光标位置（NSNumber）
    ///     "candidates": [               // 候选词数组
    ///       { "text": "你好", "comment": "" },
    ///       { "text": "泥嚎", "comment": "" }
    ///     ],
    ///     "commit": "你好",             // 已确认的上屏文字
    ///     "isLastPage": true,           // 是否最后一页
    ///     "highlightedIndex": 0         // 当前高亮的候选索引
    ///   }
    ///
    /// - Parameter raw: ObjC 层返回的字典
    /// - Returns: 类型安全的 RimeOutput
    private func parseOutput(_ raw: [AnyHashable: Any]) -> RimeOutput {
        let preedit = raw[RimeKeyPreedit] as? String
        let cursorPos = (raw[RimeKeyCursorPos] as? NSNumber)?.intValue ?? 0

        let composition: RimeComposition?
        if let preedit, !preedit.isEmpty {
            composition = RimeComposition(
                preeditText: preedit,
                cursorPosition: cursorPos
            )
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

    // MARK: === Schema 选择与验证 ===

    /// 功能测试：发送 "n"+"i" 形成拼音 "ni"，返回候选词数量。
    ///
    /// 为什么用 "n"+"i" 而不是单个 "n"？
    /// rime_ice 的 speller/recognizer 有 erase/^n$/ 规则 —
    /// 单个 "n" 会被 speller 吞掉（视为无效拼音），返回 0 候选。
    /// 用双键 "ni" 测试才能正确触发 translator。
    ///
    /// 测试后会清除 composition 恢复干净状态。
    private func functionalTestCandidates() -> Int {
        _ = bridge.processKey(Int32(Character("n").asciiValue!), modifiers: 0)
        let secondRaw = bridge.processKey(
            Int32(Character("i").asciiValue!),
            modifiers: 0
        )
        let output = parseOutput(secondRaw)
        bridge.clearComposition()
        return output.candidates.count
    }

    /// 选择 schema 并验证是否真的生效。
    ///
    /// 两阶段验证（因为 selectSchema 返回 true ≠ schema 真的能用）：
    ///
    ///   Phase 1：验证 schema ID
    ///     selectSchema 后检查 currentSchemaID 是否匹配。
    ///     不匹配可能是因为 schema 文件 YAML 语法错误导致 librime 拒绝加载。
    ///
    ///   Phase 2：功能测试
    ///     schema 加载成功但可能没有可用的翻译器。
    ///     例如：Lua 翻译器 lua_translator@xxx 引用的 xxx 模块不存在。
    ///     发送 "ni" 检查实际返回的候选词数量。
    ///     0 候选 = 翻译器不工作 = 回退。
    ///
    /// 自动回退策略：
    ///   1. 先尝试指定的 fallback schema（如 luna_pinyin）
    ///   2. fallback 也失败 → 遍历所有可用 schema
    ///   3. 全失败 → 保留最后一个尝试的 schema（虽然不可用）
    ///
    /// - Parameters:
    ///   - schemaID: 目标 schema 标识符
    ///   - fallback: 回退 schema 标识符
    /// - Returns: 实际生效的 schema ID（可能与目标不同）
    @discardableResult
    private func selectAndVerifySchema(
        _ schemaID: String,
        fallback: String
    ) -> String? {
        let requested = bridge.selectSchema(schemaID)
        let actual = bridge.currentSchemaID()

        // ── Phase 1: ID 验证 ──────────────────────────────────
        if actual != schemaID {
            if requested {
                Logger.shared.warning(
                    "selectSchema('\(schemaID)') returned true " +
                    "but currentSchemaID is '\(actual)'",
                    category: .engine
                )
            } else {
                Logger.shared.warning(
                    "selectSchema('\(schemaID)') returned false",
                    category: .engine
                )
            }
            return fallbackToWorkingSchema(from: schemaID, fallback: fallback)
        }

        // ── Phase 2: 功能测试 ─────────────────────────────────
        let cands = functionalTestCandidates()
        if cands == 0 {
            Logger.shared.warning(
                "Schema '\(schemaID)' loaded but produces 0 candidates " +
                "on 'ni' — translator may be missing (Lua stripped?)",
                category: .engine
            )
            return fallbackToWorkingSchema(from: schemaID, fallback: fallback)
        }

        Logger.shared.info(
            "Schema '\(schemaID)' functional: 'ni' produced \(cands) candidates",
            category: .engine
        )
        return actual
    }

    /// 从当前无效 schema 回退到可工作的 schema。
    private func fallbackToWorkingSchema(
        from schemaID: String,
        fallback: String
    ) -> String? {
        // ── 尝试指定回退 ──────────────────────────────────────
        if fallback != schemaID, bridge.selectSchema(fallback) {
            let fbActual = bridge.currentSchemaID()
            if fbActual == fallback {
                let cands = functionalTestCandidates()
                if cands > 0 {
                    Logger.shared.info(
                        "Fallback to '\(fallback)' functional (\(cands) candidates)",
                        category: .engine
                    )
                    return fbActual
                }
                Logger.shared.warning(
                    "Fallback '\(fallback)' loaded but produces 0 candidates",
                    category: .engine
                )
            }
        }

        // ── 遍历所有可用 schema ───────────────────────────────
        let available = bridge.availableSchemas()
        let ids = available.components(separatedBy: ", ").compactMap { s -> String? in
            let parts = s.components(separatedBy: " — ")
            return parts.first
        }
        for candidateID in ids
            where candidateID != schemaID && candidateID != fallback {
            if !bridge.selectSchema(candidateID) { continue }
            let cands = functionalTestCandidates()
            if cands > 0 {
                Logger.shared.info(
                    "Fallback to '\(candidateID)' functional " +
                    "(\(cands) candidates)",
                    category: .engine
                )
                return bridge.currentSchemaID()
            }
        }

        Logger.shared.error(
            "All schema fallbacks failed. Engine will not produce candidates.",
            category: .engine
        )
        return bridge.currentSchemaID()
    }

    // MARK: === 按键码翻译 ===

    /// 将 Swift 字符翻译为 X11 keysym 值（librime 使用 X11 按键码）。
    ///
    /// 特殊键使用 X11 标准 keysym：
    ///   - BackSpace / Delete → 0xFF08 (XK_BackSpace)
    ///   - Return / Enter → 0xFF0D (XK_Return)
    ///   - space → 0x0020 (XK_space)
    ///   - Escape → 0xFF1B (XK_Escape)
    ///   - Tab → 0xFF09 (XK_Tab)
    ///
    /// 普通字符：取 Unicode scalar value（0x0020~0x007E 为 ASCII 可打印字符）。
    static func keycode(for key: String) -> Int32 {
        switch key {
        case "BackSpace", "Delete":
            return 0xFF08  // XK_BackSpace
        case "Return", "Enter":
            return 0xFF0D  // XK_Return
        case "space", " ":
            return 0x0020  // XK_space
        case "Escape":
            return 0xFF1B  // XK_Escape
        case "Tab":
            return 0xFF09  // XK_Tab
        default:
            break
        }

        // 对于单个 Unicode 字符，使用其码点值
        if let scalar = key.unicodeScalars.first,
           key.unicodeScalars.count == 1 {
            let cp = scalar.value
            if cp >= 0x20 && cp <= 0x7E {  // ASCII 可打印字符范围
                return Int32(cp)
            }
        }

        // 回退：取 UTF-8 第一个字节
        if key.count == 1, let ascii = key.utf8.first {
            return Int32(ascii)
        }

        return 0
    }
}

// MARK: === Bridge Key 常量 ===

// 与 RimeSessionManager.m 中定义的 NSString 常量对应的 Swift 字符串
// 用于解析 collectOutput 返回的 NSDictionary
private let RimeKeyPreedit          = "preedit"
private let RimeKeyCursorPos        = "cursorPos"
private let RimeKeyCandidates       = "candidates"
private let RimeKeyCandidateText    = "text"
private let RimeKeyCandidateComment = "comment"
private let RimeKeyCommit           = "commit"
private let RimeKeyIsLastPage       = "isLastPage"
private let RimeKeyHighlightedIndex = "highlightedIndex"
