# ARCH-C7-UI-READER-AND-CANDIDATE round 1

结论：R0、A1、A2 = Partial；仅为该冻结候选的静态架构 artifact 意见。

| 身份 | 值 |
|---|---|
| packet SHA-256 | bf7704109af968f0ab9ee1958df2d593cc112be1a068f90e9c4003a31116a9f3 |
| worktree / branch / HEAD | `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard` / `codex/keyboard-wake-v3-compatibility-gate` / `84b9c19227330b0fe6ff391be001ee398010fd6a` |
| candidate | `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50` |

R0：reader SHA 与 allowlist 一致；独立审过绝对 path→SHA、Mach-O64 头偏移、load-command/section 边界及原始 section bytes→plist 路径。`--self-test` 正例和六负例全过；输出仅写 scratch。

A1：独立复算 H1 四项 binding、78 项 payload 和 candidate；两最终 executable SHA/UUID、唯一 `__TEXT,__entitlements` 原字节与归档及生成 xcent 全相等，App Group 与 bundle/application identifier 一致。两 bundle codesign 验证通过，六 Mach-O UUID 核对通过。候选 `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50`。

A2：Partial。Presentation 三处 postbinding refresh 均受 `DEBUG && KEYBOARD_WAKE_OWNER_PROBE` 保护；patch 局部性不能完全证明；patch diff not confined to the three guarded diagnostic refresh insertions; see patch finding below

范围止于静态 artifact；不构成测试、安装、runtime 或 Product Gate 结论，旧 R1/R2/R3 状态不变。

Patch check: files=[]; added guarded refreshes=0; unexpected changed lines=[]
