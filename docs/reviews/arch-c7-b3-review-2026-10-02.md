# ARCH-C7-B1 round2 — Coordinator归档的独立final message / Partial

本文件由root归档Reviewer在硬调用上限后返回的可见final message；不是Reviewer已写入的scratch报告。Reviewer未交付约定的arch-review.md和arch-usage.json，完整逐call账本与实际结束时钟缺失。以下为原final正文，结论保持Partial/incomplete，不补造完整交付。

---

packet digest 已匹配，scope ACK 已发给 root。独立核验结果为 **Partial / incomplete**；本轮未触及实际 iOS、安装、运行时或 Gate 判断。

- **H1：Covered。** 1,279 项 hash-only 输入均匹配（571 source/build、630 Vendor、78 payload）；payload 清单 78/78 匹配。冻结记录显示 standalone generic build exit 0、无 XCTest host，App 与 appex 均为 1.0/build 1。T9 单行变更依据冻结入口与既有 Quality 评审；我没有读取源码或 Vendor 内容。
- **H2：Partial。** 两个 bundle 的 `codesign --verify` 均 exit 0；列出的 Mach-O UUID 与 `dwarfdump` 一致，`nm` 找到两个 probe 符号。`otool -l` 确认两个 `__TEXT,__entitlements` section 存在，offset/size 分别为 13416/414 和 10266/423。但我首次解析把十六进制 `size` 误作十进制，未能独立完成 section bytes 与 xcent 的逐字节比较；冻结 JSON 声称二者匹配，但这项独立核验仍未覆盖。没有独立 dSYM，因此不对运行时调试参数可读性作证明。
- **H3：Covered。** 冻结记录明确实际 suites、fresh exclusive、install/restore/runtime 仍待完成；旧 Hold、F2/F3、格式诊断和历史 skips 保持，host 编译不构成安装或 Gate 放行。[入口记录](</Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-entry-2026-10-02.md:3>)、[host 候选记录](</Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-host-candidate-2026-10-02.md:3>)、[Quality R2](</Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/reviews/quality-c7-b1-r2-review-2026-10-02.md:19>)、[既有 C7 验证记录](</Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b-validation-2026-10-02.md:32>)。

**交付未完成：** `/private/tmp/ukey-wake-c7b3-20261002/arch-review.md` 和 `arch-usage.json` 尚未写入。已达到 12/12 底层调用硬上限；首个记录时间为 `2026-10-02T08:37:48.807526+00:00`，root 最后报告时钟为 `08:43:07 UTC`。为遵守预算，我没有再调用工具，也没有补造逐 call 时间账本。
