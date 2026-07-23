# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Phase 0.6 Executor Handoff

**Date:** 2026-07-23 Asia/Shanghai  
**From:** Product Lead  
**To:** Executor（Assignment 指派：Grok 4.5）  
**Authority:** [`PD-…-004-GATE5-PATH`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-path-decision.md) + Assignment Phase 0.6 Authorization  

## Product status you inherit

1. Phase 0.5 **closed**: `sel_*` = `UNRELIABLE_MENU_SCOPED_ONLY`（独立复审 Accept）。  
2. 只读 `selStart/selEnd` 可保留；**禁止**当 coverage 或接入 reducer。  
3. Human Gate step 5：**仍 Fail**；**禁止**重开或代填。  
4. Phase 1：**仍 blocked**。  
5. Path β 安全底线：无 coverage 时**禁止错误 Path 重基准**——本 Spike **不**实现 β 生产逻辑，只在结论中尊重它。

## Your only job

回答：

> 是否存在 **非 `sel_*`** 的 engine-native 信号，或 **仅引擎状态差分** 的、不可由显示文本伪造的消费边界，能唯一映射到 T9 `sourceDigits`？

## Must / Must not

**Must**

- 先读 Assignment Phase 0.6 allowlist 与 `PD-…-004-GATE5-PATH`
- 真实 Bridge + 固定 t9 fixture（可复用 Phase 0.5 evidence runtime）
- 覆盖 B / A（尽量「请喂饭到」）/ shortened remainder / window / page / 负例
- 观测驱动 verdict（禁止硬编码永远 true/false 当结论）
- 更新 gate5 remediation evidence + gate status
- 完成后 **Stop**，交独立 Architecture + Quality

**Must not**

- Phase 1 / `T9CompositionIdentity` 生产接入  
- 汉字数、comment、preedit 显示、排名猜槽位  
- 改 PD-004 主体、ADR 0023、catalog、26 键、UIKit  
- commit / push / PR  
- 宣布 Human Gate 通过  
- 把 `sel_*` 重新洗白为 coverage  

## Done means

- Spike 测试 + 命令/结果  
- 权威 **Found**（接口说明，不接 reducer）或 **UNKNOWN/UNRELIABLE**（否定证据）  
- evidence / hash inventory  
- 独立复审请求  

## After you stop

Product Lead 根据 Architecture 再决定：开 Phase 1、继续调研、或产品收窄验收。

---

## Executor completion (`2026-07-23`)

| Item | Result |
|---|---|
| Verdict | **`UNRELIABLE_NO_ALLOWED_SLOT_MAP`** |
| Tests | `testGate5Phase06…` + parser Phase06 fields **PASS** |
| Evidence | remediation §16；`evidence/…/phase06/20260723-155717/` |
| Phase 1 | **Not started** |
| Next | 独立 Architecture + Quality 复审 |
