# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Phase 0.5 Grok Handoff

**Date:** 2026-07-23 Asia/Shanghai  
**Target executor:** Grok 4.5  
**Current gate:** Architecture **Reject / Phase 1 No**；Quality **Pass-with-findings**  
**Human gate:** Step 5 remains failed；A 本轮精确候选 Pass，B/C Fail  

## 1. 权威入口

按顺序完整阅读：

1. `AGENTS.md`
2. `docs/KNOWLEDGE_INDEX.md`
3. `docs/READING_MAPS.md`
4. `docs/ASSIGNMENT_POLICY.md`
5. `docs/assignments/keyboard-layout-9key-pinyin-004.md`
6. `docs/plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md`
7. `docs/assignments/keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md`
8. `docs/assignments/keyboard-layout-9key-pinyin-004-gate-entry-status.md`

## 2. 当前唯一 Architecture blocker

B 真机选择单字「请」后，RIME 的 previous/result/remaining raw 结构和进程内 signature 完全不变。Core 的 pre-selection segment→slot ledger 能列出 `qing/wei/fan/dao` 的合法边界，但现有生产 `RimeOutput` / `RimeComposition` 没有候选实际消费范围，无法证明本次消费的是 `qing` 的 `0..<4`。

禁止通过以下信号推断：

- 候选汉字数；
- candidate comment；
- preedit 显示文本；
- 候选排名或索引；
- FakeRime 私有 `rawPrefix` 副作用。

librime 原生 `RimeComposition.sel_start/sel_end` 是待验证线索，不是已确认契约。

## 3. 任务边界：只做 Phase 0.5 Spike

本轮不得实现 `T9CompositionIdentity`，不得修改 Partial/Delete 身份算法。目标是回答：

> 在 A/B 真实候选选择前后，是否存在稳定、engine-native、不可由显示文本伪造的 consumed raw range，并且能唯一映射到 T9 `sourceDigits` 槽位？

必须覆盖：

- B：raw unchanged，单字「请」，期望原生范围对应 `qing`；
- A：精确部分候选「请喂饭到」；
- shortened remainder 与 unchanged raw 两类输出；
- apostrophe / mixed raw；
- 普通候选栏与扩展候选面板；
- 候选翻页后选择；
- range 缺失、越界、非音节边界、与 source signature 冲突的 fail-closed 负例。

## 4. Proposed Phase 0.5 allowlist（必须先由 Product Lead 明确授权）

只允许为 Spike/契约测试修改：

- `Packages/RimeBridge/Sources/RimeBridgeObjC/include/RimeSessionManager.h`
- `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m`
- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+Output.swift`
- `Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9PinyinSelectionSpikeTests.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/RimeComposition.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/RimeOutput.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/FakeRimeEngine.swift`
- Gate 5 plan/evidence/status/Assignment 文档

Phase 0.5 优先以测试或 DEBUG/test-only 观测完成。若必须形成 production-visible 只读元数据接口，先在 evidence 写清接口、生命周期和兼容性，再停下交 Architecture 审查；不得顺手接入 reducer。

## 5. 执行顺序

- [x] 保存当前 dirty worktree 的 allowlist hash 基线，不覆盖其他 003/004 WIP。
- [x] 只读追踪 librime `sel_start/sel_end` 从 C API 到 ObjC/Swift 的现有丢失点。
- [x] 先写真实 RimeBridge Spike 测试，打印/断言选择前后的 raw、selection range 与候选 index 关系；日志必须脱敏、不得持久化个人输入。
- [x] 在 simulator/真实 Bridge 固定 schema 上验证 A/B 与负例，不能只用 Fake。
- [x] range **不可靠** → **未**给 Fake 加 coverage 权威字段（按 stop condition）。
- [x] 运行定向 RimeBridge contract tests + Core smoke；记录命令/结果（见 remediation evidence §13）。
- [x] 更新 `keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md` 与 gate status；保留所有历史 Fail。
- [x] 停止，不实现 reducer；交独立 Architecture + Quality 复审。

### Phase 0.5 result (2026-07-23 Grok)

**Verdict:** `UNRELIABLE_MENU_SCOPED_ONLY`  
**Coverage authority for Phase 1:** still `UNKNOWN`  
**Detail:** remediation evidence §13

## 6. Stop Conditions

出现任一情况立即停止：

- `sel_start/sel_end` 在候选选择时不稳定、语义不明或只表示光标/高亮而非消费范围；
- range 不能唯一映射到 pre-selection source slots；
- 需要候选文本、comment、排名或汉字数补齐边界；
- 需要 RIME probe/candidateWindow 循环；
- 需要修改 PD-004、ADR 0023、catalog、26 键或 UIKit；
- 需要越出 Product Lead 明确授权的 Phase 0.5 allowlist；
- 发现 Bridge 行为与当前 Spike 证据冲突。

Stop 后标记 `UNKNOWN`，把原始证据交 Architecture/Product Lead，不得猜修。

## 7. 交付与禁止声明

交付：

- Phase 0.5 Spike 测试；
- engine-native coverage 契约或“不可靠”的否定证据；
- 更新后的 evidence/status/hash inventory；
- 独立复审请求。

禁止：

- commit / push / PR；
- 宣布 Phase 1、Human Gate 或 Product Gate 通过；
- 在 Architecture 重新 Accept 前实现 `T9CompositionIdentity`；
- 覆盖首次 Gate 5 Fail 历史。
