# C7 调试器就绪核验 — 2026-10-02

本轮 Human 明确授权“调试器就绪核验，并确认独占”。按[冻结最小计划](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-debugger-readiness-plan-2026-10-02.md)执行；仅环境就绪核验完成，父子 Assignment 仍 Active，根因未确认。不是取证成功、Product Gate 或 Release。

## Entry 与身份

现有工作树 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；分支 `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`。保留既有 dirty，无暂存或源码改动。原 iPhone 18 Pro / iOS 27.0，UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2` 本轮独占。

[进程 Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-debugger-readiness-artifacts/process-entry.json)证明安装候选78文件匹配，唯一目标 PID 24050，路径为该设备容器中的 `Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard`。[授权记录](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-debugger-readiness-artifacts/authorization.json)限定 attach、身份和符号/断点解析、清理。

## 实际结果

MCP attach PID 24050，session `909bf624-6c08-402a-8f39-e052aff51d88`，执行暂停。后续所有命令均显式绑定该 session。

- 加载的 Keyboard UUID `7E0813A6-2992-353B-9BA2-C9B1F8AB69E6`；Keyboard.debug.dylib UUID `FE12AEDC-088B-3CBB-B00A-1ECD95323DA4`；两者与冻结候选一致。
- 精确出口 `$s8Keyboard25wakeOwnerProbeExportReadyyySV_SitF` lookup 唯一匹配于 Keyboard.debug.dylib，文件地址 `0x168714`，源码 `KeyboardViewController+WakeOwnerProbe.swift:96`。
- 断点1：locations=1、resolved=1、hit count=0；解析到出口函数 +60，运行地址 `0x1057d4750`。地址仅属于本次进程，不作未来固定地址。
- 移除断点1后 `No breakpoints currently set.`；continue 回执 running；detach 回执 detached。

原始[调试器回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-debugger-readiness-artifacts/debugger-receipts.json)保留结构化输出；attach 回执字段按实际工具返回转录，非另一次查询。

## Exit 与剩余依赖

[退出状态](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-debugger-readiness-artifacts/exit-status.json)：同 PID 仍存在，状态 Ss（非调试暂停）；两项诊断键仍不存在，保持关闭；部署 true / needs-deploy false / deploying false。未 arm、freeze、点击观测、输入、复现 Maps 或读取内容。未 build/test/install/deploy，未执行表达式、寄存器/内存写或缓冲读取。无独立 dSYM 的既有事实保留。

本轮只证明附加与断点解析可用，未验证真实出口停点的 address/byteCount 是否可读取，也未验证借用生命周期、缓冲导出或 owner 状态。下一步应另明确单轮正常路径 arm/freeze/有界导出授权和新鲜现场 Entry，先验证取证链；Maps 故障复现继续单独受限。原阶段 skip 和精确计时残项不因本轮变化，旧数据未恢复事实保留。

本轮仅证据及状态文档更新；不需 CHANGELOG 或架构合同改动，无 M-02 生命周期触发。
