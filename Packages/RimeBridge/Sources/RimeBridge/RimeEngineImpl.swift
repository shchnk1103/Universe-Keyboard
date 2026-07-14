import Foundation
import KeyboardCore
import QuartzCore
import RimeBridgeObjC

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
/// 4. Schema（输入方案）快速选择与异常恢复验证
/// 5. 输入路径异常诊断；逐键成功诊断仅在 Debug，不在按键事件中执行配置部署或磁盘同步
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
    let bridge: RimeSessionManager
    var nextRecoveryAttemptTime: CFTimeInterval = 0
    private var isSuspendedForVisibilityChange = false
    private var activeSchemaID = "luna_pinyin"

    // MARK: === Init ===

    /// 初始化 RIME 引擎。
    ///
    /// 初始化步骤：
    ///   1. 创建 RimeSessionManager（ObjC 桥接层）
    ///   2. setup：配置 RIME traits（目录路径、模块列表）
    ///   3. initializeEngine：启动 librime 运行时，不进行部署或文件检查
    ///   4. createSession：创建输入会话（session 是 librime 的核心抽象）
    ///   5. 诊断日志：记录低成本 librime 版本信息
    ///   6. Schema 快速选择：健康路径不枚举所有 schema，也不合成测试输入
    ///
    /// - Parameters:
    ///   - sharedDataDir: RIME 共享数据目录（schema、dict 等配置文件）
    ///   - userDataDir: RIME 用户数据目录（user.yaml、同步等）
    public init(sharedDataDir: String, userDataDir: String) {
        let startTime = CACurrentMediaTime()

        self.bridge = RimeSessionManager()

        // ── 1. Setup + Initialize ──────────────────────────────
        // setup: 设置 RIME 的数据目录和模块列表
        // initializeEngine: 只启动运行时；部署和配置落盘由主 App 完成。
        let setupStartTime = CACurrentMediaTime()
        bridge.setup(withSharedDataDir: sharedDataDir, userDataDir: userDataDir)
        let setupElapsed = (CACurrentMediaTime() - setupStartTime) * 1000

        let initializeStartTime = CACurrentMediaTime()
        bridge.initializeEngine()
        let initializeElapsed = (CACurrentMediaTime() - initializeStartTime) * 1000

        // ── 2. 创建 RIME session ──────────────────────────────
        // session 是 librime 的核心概念 — 每个 session 维护独立的输入状态
        // 包括：composition（拼音缓冲区）、candidates（候选列表）、context（上下文）
        let sessionStartTime = CACurrentMediaTime()
        bridge.createSession()
        let sessionElapsed = (CACurrentMediaTime() - sessionStartTime) * 1000

        // ── 3. 保留低成本版本诊断；完整 schema 枚举只在失败恢复时执行 ──
        let version = bridge.librimeVersion()
        Logger.shared.info("librime \(version)", category: .engine)

        // ── 4. Schema 快速选择 ────────────────────────────────
        // 主 App 已负责部署与完整运行时验证。健康冷启动只确认 schema 可以选中，
        // 不再合成 "ni" 输入或枚举所有 schema；深度验证保留给失败恢复路径。
        let schemaStartTime = CACurrentMediaTime()
        let activeSchema =
            UserDefaults(
                suiteName: "group.com.DoubleShy0N.Universe-Keyboard"
            )?.string(forKey: "rime_active_schema") ?? "luna_pinyin"

        let selected = selectSchemaForStartup(activeSchema, fallback: "luna_pinyin")
        let schemaElapsed = (CACurrentMediaTime() - schemaStartTime) * 1000
        activeSchemaID = selected ?? activeSchema
        Logger.shared.info(
            "Active schema: \(activeSchema), actual: \(selected ?? "nil")",
            category: .engine
        )

        if selected != activeSchema {
            Logger.shared.warning(
                "Schema mismatch: wanted '\(activeSchema)', "
                    + "got '\(selected ?? "none")'; repair must be performed by the main app",
                category: .engine
            )
        }

        let elapsed = (CACurrentMediaTime() - startTime) * 1000
        let startupPhaseSummary = [
            "setup=\(String(format: "%.1f", setupElapsed))ms",
            "initialize=\(String(format: "%.1f", initializeElapsed))ms",
            "session=\(String(format: "%.1f", sessionElapsed))ms",
            "schema=\(String(format: "%.1f", schemaElapsed))ms",
        ].joined(separator: " ")
        Logger.shared.performance(
            "RIME startup phases \(startupPhaseSummary)"
        )
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
    ///   1. 将 Swift 按键字符（如 "n"）翻译为 X11 keysym（如 0x006e）
    ///   2. 调用 librime process_key（核心 API）
    ///   3. 解析返回的 NSDictionary 为 RimeOutput
    ///
    /// 完整部署由主 App 的 `RimeDeploymentServicing` 执行；任何配置
    /// 同步或 maintenance 都不得进入键盘按键热路径。
    ///
    /// - Parameter key: Swift 字符串按键（"a", "BackSpace", "space", etc.）
    /// - Returns: RimeOutput（包含 composition、candidates、committed text）
    public func processKey(_ key: String) -> KeyboardCore.RimeOutput {
        processInputKey(key)
    }

    /// 选择指定索引的候选词。
    /// - Parameter index: 0-based 候选索引
    /// - Returns: 选择后的 RIME 输出（可能包含新的候选页或 commit）
    public func selectCandidate(at index: Int) -> KeyboardCore.RimeOutput {
        chooseCandidate(at: index)
    }

    public func selectCandidate(globalIndex index: Int) -> KeyboardCore.RimeOutput {
        chooseCandidate(globalIndex: index)
    }

    public func candidateWindow(from globalIndex: Int, limit: Int) -> KeyboardCore.RimeCandidateWindow {
        readCandidateWindow(from: globalIndex, limit: limit)
    }

    /// 在 RIME 中删除一个字符（回退拼音）。
    public func deleteBackward() -> KeyboardCore.RimeOutput {
        processDeletion()
    }

    /// 用未格式化输入替换当前 RIME composition。
    public func replaceInput(_ input: String) -> KeyboardCore.RimeOutput {
        parseOutput(bridge.replaceInput(input))
    }

    /// 重置当前 RIME session 的输入状态（清除拼音 composition）。
    public func resetSession() {
        bridge.clearComposition()
    }

    /// 宿主展示自己的表情/键盘后，旧 session 可能仍有 id 但已经不能处理输入。
    /// 先重建 session；若 librime 已无法创建 session，则重新初始化整个引擎。
    public func recoverSession() {
        restoreInputSession()
    }

    /// iOS 会在扩展挂起时终止仍持有数据库文件锁的进程。
    /// 因此这里必须同步 finalize，不能依赖不保证及时执行的 deinit。
    public func suspendForVisibilityChange() {
        guard !isSuspendedForVisibilityChange else { return }
        bridge.finalize()
        isSuspendedForVisibilityChange = true
    }

    public func resumeAfterVisibilityChange() {
        guard isSuspendedForVisibilityChange else { return }
        guard bridge.initializeEngine(), bridge.createSession() else {
            Logger.shared.error(
                "RIME runtime could not resume after keyboard visibility change",
                category: .engine
            )
            return
        }

        let selected = selectSchemaForStartup(activeSchemaID, fallback: "luna_pinyin")
        guard let selected else {
            bridge.finalize()
            Logger.shared.error(
                "RIME schema could not be restored after keyboard visibility change",
                category: .engine
            )
            return
        }

        activeSchemaID = selected
        isSuspendedForVisibilityChange = false
    }

    /// 查询 RIME 是否有活跃的 composition（拼音正在输入中）。
    public func isComposing() -> Bool {
        bridge.isComposing()
    }

    /// 候选词翻页（上一页）。
    /// 发送 XK_Page_Up (0xFF55) 按键码到 librime。
    public func pageUp() -> KeyboardCore.RimeOutput {
        pageCandidates(keycode: 0xFF55, diagnosticName: "PAGE_UP")
    }

    /// 候选词翻页（下一页）。
    /// 发送 XK_Page_Down (0xFF56) 按键码到 librime。
    public func pageDown() -> KeyboardCore.RimeOutput {
        pageCandidates(keycode: 0xFF56, diagnosticName: "PAGE_DOWN")
    }

    /// 获取可用 schema 列表字符串。
    public func availableSchemas() -> String {
        bridge.availableSchemas()
    }
}
