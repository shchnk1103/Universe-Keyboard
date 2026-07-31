# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / R5-Rem-3 **implementation**

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立 subagent；对抗性 **implementation** 结构审查，非 design-only）  
**Date:** `2026-07-31 Asia/Shanghai`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Phase:** R5-Rem-3 — dual-gate provisional **L1** composition **implementation**  
**Product authority:** Human Product Owner authorized Rem-3 **implementation option 1** after design freeze + Amendment A  
**Design under review (binding):**  
  [`t9-responsive-pipeline-001-r5-rem-3-design.md`](t9-responsive-pipeline-001-r5-rem-3-design.md) — D1–D9 / Amendment A  
**Prior design Arch review:**  
  [`t9-responsive-pipeline-001-r5-rem-3-architecture-review.md`](t9-responsive-pipeline-001-r5-rem-3-architecture-review.md) — design-only Pass with conditions（P1 closed by Amendment A）  
**Executor evidence (context; not Arch Pass):**  
  [`../evidence/t9-responsive-pipeline-r5-rem-3-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-3-2026-07-31.md)  
**ADR:** [`0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) — **Status remains `Proposed`（本审查不 Accept）**  
**Tip honesty:** evidence tip `9b9bbeb`（`feat: R5-Rem-3 dual-gate provisional L1 composition`）；本审查以 **working tree 源码结构** 为准，**不**将 Executor `swift test` 绿条采信为 Arch Pass。

| Field | Value |
|---|---|
| **Verdict** | **Pass with conditions**（initial on `9b9bbeb`） |
| **P0** | **0** |
| **P1** | **2** on `9b9bbeb` → **closed in Executor remediation same day**（见 Addendum A） |
| **P2** | **4** |
| **P3** | **3** |

> **判定原则：** 只根据源码结构是否兑现 Rem-3 design D1–D9（含 Amendment A）与 layer model Rule 1–5；不以测试绿条、设备体感或 evidence 叙事代替结构审查。  
> **强制 non-claims：** 本审查 **不** Accept ADR 0025、**不** Product Gate、**不** dual-gate default-on、**不** 改写 Rem-Device PASS / Formal R5 FAIL、**不** 授权 Rem-3-Device knife、**不** 锁定数值 product SLO、**不** 声称 Quality Pass。

---

## 1. Scope of this review

### In scope（Product 已授权的 Rem-3 实现面）

| 面 | 检查目标 |
|---|---|
| **D1** | dual-gate only；T9 digit processKey；epoch + revision floor vs L1 watermark |
| **D2** | `·`×N structure-only；禁 digit/pinyin/CJK；chrome disable while ahead |
| **D3** | Delete v1 path A；ledger 与返回 L2 对齐；无 async Delete 重设计 |
| **D4** | `provisionalAhead` 下候选 / Path / Space·选定 / Partial Commit fail-closed |
| **D5** | `VISIBLE source=provisional` 与随后 `engine`；`L1_SKIP` 封闭 reason |
| **D6** | MainActor mirror + pure builder；L2 原子覆盖；无第二 live session；无 Path API 名碰撞 |
| **D7** | 测试是否形成可证伪结构（绿条归 Quality） |
| **D8–D9** | 不改写历史 PASS/FAIL；Amendment A 四处关闭在代码中是否落地 |
| **Layer Rule 3** | L1 永不 `insertText` / commit host 终稿 |
| **Non-claims / gates** | default-off；无 Gate / ADR Accept 偷渡 |

### Out of scope / 禁止借本 Pass 偷渡

- Rem-3-Device A/B 或 Product Gate  
- ADR 0025 Accept / dual-gate default-on / R6  
- 数值 SLO 锁定  
- R4-Wire `performOrderedNow` residual **全量**重开为本刀 Fail（仅当 Rem-3 放大为新阻断时记条件）  
- Quality 对 850/0 的再执行与诚实性裁决  
- 主观 “·×N 好不好看” 产品取舍  

---

## 2. Sources reviewed

| Artifact | Role |
|---|---|
| `docs/assignments/t9-responsive-pipeline-001-r5-rem-3-design.md` | **Primary contract** D1–D9 |
| `docs/evidence/t9-responsive-pipeline-r5-rem-3-2026-07-31.md` | Executor 交付叙述（**不**采信为 Arch Pass） |
| `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveProvisionalComposition.swift` | pure builder + mirror + L1_SKIP enum |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` | mirror 字段、`isLivePresentationSnapshot`、L2 clear、`applyResponsiveProvisionalL1IfEligible`、`rejectIfResponsiveProvisionalAhead`、abandon clear |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift` | dual-gate accept → L1 接线 |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+Candidates.swift` | 候选 / composition kind fail-closed |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift` | Space fail-closed；Return / Delete 路径 |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift` | Path cycle / select fail-closed |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift` | host commit helpers；`applyRimeOutput*` 无 L1 align |
| `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+ModeAndShift.swift` | mode / type 切换与 composition finish |
| `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimeFeltMetrics.swift` | provisional→engine same-revision upgrade |
| `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift` | bridge `isComposing` / `deleteBackward`→`performOrderedNow`；async MainActor publish |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveProvisionalCompositionTests.swift` | D7 形态抽样（结构可证伪性） |

---

## 3. Executive structural judgment

| Dimension | Judgment |
|---|---|
| L0 accept 不阻塞 + dual-gate only L1 | **Held** — L1 仅 affine dual-gate accept 后；MainActor R2-only / gate-off 无 L1 |
| D2 `·`×N pure builder | **Held** — U+00B7 × N；builder 不发 digits |
| D1 revision floor / Amendment A P1-1 | **Held** — `isLivePresentationSnapshot` 在 ahead 时 `revision ≥ max(lastPresented, watermark)`；L1 paint 同步抬高 floor |
| D2/D4 chrome + 主选择 fail-closed | **Mostly held** — 候选 / Path cycle·select / Space 入口有 `rejectIfResponsiveProvisionalAhead`；L1 paint 清空 `lastRimeOutput` / Path / partialCommit |
| Layer Rule 3（L1 不 commit host 终稿） | **Not fully held** — Return / direct text / mode-type default finish 可在 ahead 时提交 `·` 串（**P1-1**） |
| D3 Delete ledger 对齐 | **Not fully held** — Delete 走 bridge `performOrderedNow` + `applyRimeOutput*`，**不**调用 `alignToEngineApply`；依赖异步 publish 侧清 mirror（**P1-2**） |
| D5 dual VISIBLE | **Held in tracker** — same rev provisional→engine 允许；重复 engine 拒绝 |
| D6 isolation / naming | **Held** — pure MainActor mirror；无 librime on L1；`ResponsiveProvisional*` 不碰 Path `provisionalPathID`；未见 `@unchecked Sendable` |
| D7 test shape | **Partial** — progressive slots / fail-closed select / abandon / gate-off 有形态；Delete 对齐、Return host commit、marker 分布未形成阻断级结构用例 |
| Gate / ADR / default-on non-claims | **Held** — 两 gate 默认 `false`；无 ADR Accept / Gate 代码路径 |

**结论一句话：** Rem-3 **主路径**（dual-gate accept → `·`×N L1 → revision floor 下 L2 原子覆盖 → 主选择 fail-closed → provisional→engine VISIBLE）结构成立且 Amendment A 四处在 **happy path** 落地；但 **host 终稿入口** 与 **Delete/ordered apply 旁路** 未完整兑现 Layer Rule 3 与 D3 ledger 对齐，故 **Pass with conditions**（条件 = 关闭 2× P1 后再推荐 Rem-3-Device / “implementation complete”）。

---

## 4. Design freeze D1–D9 disposition

### 4.1 D1 — When L1 may paint — **Pass（主路径）**

| Check | Implementation | Arch |
|---|---|---|
| Dual-gate | `isResponsiveRimePipelineEnabled && isThreadAffineRimeOwnerEnabled` | **Held** |
| T9 digit processKey | `isT9DigitKey` + `usesT9InputSemantics`；接线在 affine `scheduleProcessKey` 之后 | **Held** |
| 26-key / non-T9 | `logL1Skip(.nonT9)`；不 append | **Held** |
| Epoch + watermark | `appendT9DigitAccept(revision:epoch:)`；L2 需 `revision ≥ floor` | **Held** |
| MainActor R2-only | 无 `applyResponsiveProvisionalL1IfEligible` 调用 | **Held** |

### 4.2 D2 — What L1 may show — **Pass**

| Check | Implementation | Arch |
|---|---|---|
| `·`×N only | `String(repeating: "\u{00B7}", count:)` | **Held** |
| No digits / pinyin / CJK invent | builder 无此类输入 | **Held** |
| No blend mid-string | L2 清 mirror 后 `applyRimeOutput` 全量 | **Held on L2 presentation path** |
| Chrome while ahead | `lastRimeOutput = nil`；`clearT9PinyinPathState`；`partialCommit = nil` | **Held** |
| Skip | empty / non-T9 / no dual → skip（见 P2 metrics） | **Mostly held** |

### 4.3 D3 — Delete path A — **Pass with conditions → P1-2**

| Check | Implementation | Arch |
|---|---|---|
| 无 async Delete 重设计 | bridge 仍 `performOrderedNow(.deleteBackward)` | **Held**（scope） |
| L1 非 primary delete mirror | 无 L1 长度缩短 mirror | **Held as written** |
| Ledger 与返回 L2 对齐 | Delete → `applyRimeOutputPreservingPartialCommit`，**无** `alignToEngineApply` / mirror clear | **Gap → P1-2** |

设计原文：*“provisional ledger is cleared/aligned from the returned L2.”*  
实现仅在 `performResponsivePresentationApply` 清 ledger；Delete 的同步返回路径旁路该点，并依赖 `NotificationCenter` → `Task { @MainActor }` 的异步 `applyResponsivePublishedSnapshot` 间接清理。窗口期内 `isResponsiveProvisionalAhead` 可粘滞，选择错误 fail-closed，且与 D3 字面合同不符。

### 4.4 D4 — Selection / Partial Commit fail-closed — **Pass with conditions → P1-1**

| Action | Wired? | Arch |
|---|---|---|
| Candidate tap (`.candidate` / `.composition`) | `rejectIfResponsiveProvisionalAhead` | **Held** |
| Path select / cycle | same | **Held** |
| Space / 选定 first | `handleInsertSpace` 入口 reject | **Held** |
| Partial Commit **entry** | 无独立 reject；依赖 L1 清 chrome + 候选入口 | **Soft hold**（主入口覆盖；typo correction 未 reject → P2） |
| Return / direct text / mode finish | **无** ahead reject；可 `finishActiveCompositionAs*` 提交 `·` | **Fail vs Rule 3 → P1-1** |
| Explicit reset / abandon | `clearResponsiveKeyApplyContexts` 含 mirror clear | **Held** |
| Mode / language switch | 设计要求 clear L1；实现常走 display finish **且不** clear mirror | **Gap → P1-1** |

`provisionalAhead` 实现为 `isActive && slotCount > 0`，是设计三元 OR 的可执行子集；在 mirror 与 L2 presentation 同路径时足够，但在 Delete 旁路后会放大粘滞风险（P1-2）。

### 4.5 D5 — Metrics — **Pass with conditions（P2）**

| Marker | Implementation | Arch |
|---|---|---|
| `VISIBLE … source=provisional` | L1 paint → `recordVisible(..., .provisional)` | **Held** |
| 随后 `source=engine` | L2 presentation → `.engine`；tracker 允许 same-rev upgrade | **Held** |
| `L1_SKIP` closed set | enum: `unsafe` \| `non_t9` \| `empty_ledger` \| `gate_off` \| `no_dual` | **Enum held** |
| `gate_off` / `no_dual` 实际发出 | `logL1Skip` 在非 dual 时 **直接 return**，`.noDual` 永不落盘；`.gateOff` / `.unsafe` **无调用点** | **P2-1** |

### 4.6 D6 — Placement / isolation — **Pass**

- Pure `ResponsiveProvisionalComposition` + MainActor `ResponsiveProvisionalCompositionMirror`  
- L2 原子清 ledger 后 apply（presentation 路径）  
- 无第二 live MainActor RIME session；L1 不碰 librime  
- 命名隔离 Path provisional API  

**Note：** v1 ledger 仅为 `slotCount` + watermark（无 digit 身份数组）。对 D2 `·`×N 足够；若未来要 L1 delete mirror 或校验 raw，需加厚（P3）。

### 4.7 D7 — Test minimum — **Partial（结构形态，非 Quality 裁决）**

| Case | Present? |
|---|---|
| Fake stall N≥8 progressive slots | **Yes**（slot 数 / `·` 串；非 marker 分布断言） |
| L2 replace clears dots | **Yes** |
| Selection while ahead | **Yes**（candidate empty effects） |
| Gate-off no L1 | **Yes** |
| Abandon clears L1 | **Yes** |
| Delete v1 no double-shorten / ledger align | **No structural case** |
| Return / host commit while ahead | **No** |
| Coalesce + L1 | **No dedicated case** |
| Pure builder digits | **Yes** |
| Tracker provisional→engine | **Yes** |

### 4.8 D8 / D9 — History + Amendment A — **Pass（主路径）**

| Amendment A | Code landing |
|---|---|
| P1-1 revision floor | `isLivePresentationSnapshot` + L1 抬高 `lastPresentedRevision` |
| P1-2 ledger | `ResponsiveProvisionalCompositionMirror` |
| P1-3 `·`×N | pure presentation builder |
| P1-4 stale L2 + L1 | chrome clear + reject on main select sites |

D8：无 Rem-Device / Formal R5 历史改写。

---

## 5. Findings

### P0

*None.*

未发现：host digit 泄漏路径（L1 使用 `·`；既有 digit host guard 仍在）、双 live session、default-on 偷渡、或主候选/Path/Space 在 ahead 时仍成功提交引擎选择。

### P1（必须关闭后才推荐 Rem-3-Device / “implementation complete”）

#### P1-1 — Host 终稿入口在 `provisionalAhead` 下未 fail-closed（违背 Layer Rule 3）

**Evidence**

1. L1 paint 将 `state.currentComposition` / host marked text 设为 `·`×N，且 `lastRimeOutput = nil`。  
2. `handleInsertReturn` **无** `rejectIfResponsiveProvisionalAhead`：  
   - `returnAction` 对 `·` 串视为 **非** T9 raw → `.notT9Composition`；  
   - 落入 `finishActiveCompositionAsRawInput`，`preferred = currentComposition`（`·`×N）；  
   - `compositionProjectionContainsInternalDigit` **不**拒绝 middle dot → **可向 host commit `····`**。  
3. 同类旁路：`handleInsertDirectText` / `handleToggleInputMode` / `handleKeyboardTypeChanged` 的 `finishActiveCompositionAsDisplayText()`；`activeCompositionDisplayText` 在无 L2 时回落 `insertedPreeditText` / `currentComposition`（均为 `·`）。  
4. mode 切换清 composition **不** `provisionalCompositionMirror.clear()` → 视觉已空但 **sticky ahead**，后续选择持续错误 fail-closed。

**Why P1：** 直接违反 layer model Rule 3（“L1 must never insertText / commit host text”）与 D4 “explicit reset/mode change → Clear L1 ledger” 的一半合同。这不是观感问题，是 authority 边界洞。

**Close shape（guidance only；本审查不改生产码）：**

- 在 Return / direct-text composition finish / language-switch finish 入口：`if rejectIfResponsiveProvisionalAhead() { return [] }` **或** 统一 “ahead → abandon L1 + engine reset，永不 commit `·`”；  
- 凡清 composition 的 mode/type/abandon 旁路，必须 `provisionalCompositionMirror.clear()`（或复用 `clearResponsiveKeyApplyContexts` 的 mirror 段）。

#### P1-2 — D3 Delete / ordered `applyRimeOutput*` 旁路不对齐 L1 ledger

**Evidence**

1. dual-gate Delete：`ThreadAffineRimeEngineBridge.deleteBackward` → `performOrderedNow` → `applyRimeOutputPreservingPartialCommit`。  
2. 全仓库 `alignToEngineApply` / mirror clear 仅出现在：  
   - `performResponsivePresentationApply`（L2 presentation）  
   - `clearResponsiveKeyApplyContexts`（abandon / rebuild）  
3. Publish 到 UI 为 `NotificationCenter` + `queue: .main` + `Task { @MainActor }`，**异步**于 `waitForRevision` 返回；Delete 同步返回时 mirror 仍可能 `isProvisionalAhead`。  
4. 设计 D3：*ledger is cleared/aligned from the returned L2* — 字面未在 Delete 返回路径兑现。

**Why P1：** 放大 sticky `provisionalAhead`、错误 fail-closed、与 presentation generation floor 竞态；在 Rem-3 引入 L1 后，R4 ordered-wait residual 从 “阻塞体感” 升级为 **L1 authority 不一致**。

**Close shape：**

- 凡 dual-gate 下将 **engine 已结算 composition** 写入 UI 的路径（至少 Delete / 其他 `performOrderedNow` → `applyRimeOutput*`），在成功 apply 后 `alignToEngineApply` 或 `clear` mirror；**或** 强制走 `applyResponsivePublishedSnapshot` 并保证 generation 不吞掉 clear。  
- 单测：ahead 时 Delete flush 后 `isResponsiveProvisionalAhead == false` 且无 double-shorten。

### P2

| ID | Finding |
|---|---|
| **P2-1** | `L1_SKIP` 封闭枚举含 `gate_off` / `no_dual` / `unsafe`，但 `logL1Skip` 在非 dual 早退且 `unsafe`/`gateOff` 无调用点 → D5 可观测性不完整 |
| **P2-2** | D7 progressive bar 测试断言 slot 数，**不**断言 `source=provisional` marker 分布 / Fake≥150ms 语义（Quality 可升格） |
| **P2-3** | `handleInsertCorrectionCandidate` / typo partial commit **无** ahead reject；L1 亦未 `clearTypoCorrectionSuggestions`（主路径 typo 通常不活跃，仍属 D4 缝） |
| **P2-4** | D7 coalesce+L1 无专用结构用例；与 Rem-Device “coalesce 未充分” residual 叠加时设备刀解释力弱 |

### P3

| ID | Finding |
|---|---|
| **P3-1** | Ledger 仅 slotCount，无 raw digit 身份 — v1 OK；注释/类型名可标明 “length ledger” 以免后续误用 |
| **P3-2** | `appendT9DigitAccept` 的 skip 返回值恒 `nil`（死分支） |
| **P3-3** | Candidate page up/down 无 ahead reject（chrome 已空时低风险） |

---

## 6. Boundary / non-claims held

| Claim | Status |
|---|---|
| ADR 0025 Accept | **未发生** — 仍 Proposed |
| Product Gate | **未发生** |
| dual-gate default-on | **Held off** — `isResponsiveRimePipelineEnabled` / `isThreadAffineRimeOwnerEnabled` 默认 `false` |
| Rem-Device PASS 升级为 Gate | **未发生** |
| Formal R5 FAIL 改写 | **未发生** |
| Rem-3-Device 授权 / 完成 | **未发生**（且本审查因 P1 **不推荐** 立即 Device） |
| 数值 product SLO | **未锁定** |
| Executor 850/0 = Arch Pass | **拒绝采信** |

L1 相对 ADR 0025 “仅 engine snapshot 画 composition” 的 **显式 dual-gate 例外** 已在 design 文档声明；本实现审查 **不** 借此 Accept ADR。

---

## 7. Conditions for raising verdict / next Product move

**当前 Verdict = Pass with conditions** 的条件：

1. **关闭 P1-1**（ahead 时永不 commit `·`；mode/reset 必清 mirror）。  
2. **关闭 P1-2**（Delete/ordered engine apply 与 L1 ledger 对齐）。  
3. 关闭后由独立 Arch **implementation re-review**（或 Product 书面接受 residual 并 **Hold Device**）。  
4. P2 建议在 Device 前由 Quality/Executor 补齐，但 **不**单独阻断 “结构可进 re-review”。

**明确不推荐的 Product 话术：**

- “Rem-3 implementation Arch Pass / complete”  
- “可进 Product Gate / ADR Accept / default-on”  
- “Rem-3-Device 已就绪”  

**可选 Product 路径：**

1. 授权 **Rem-3 P1 remediation** 小刀 → re-review → 再议 Device。  
2. **Hold L1 Device**；保留 dual-gate default-off 与 Rem-Device key-feel PASS 现状。  
3. 切换 RELEASE / 9KEY 优先级（与 L1 无冲突，因 gate 仍 off）。

---

## 8. Handoff

**To:** 🧭 Human Product Owner / Product Lead；并行 🧪 Quality implementation review（若尚未出具）。  

**Arch 结论摘要：**

- **Verdict:** Pass with conditions  
- **P0:** 0  
- **P1:** 2（host commit while ahead；Delete ledger align）  
- **P2:** 4 · **P3:** 3  
- **主路径** D1/D2/D5/D6/D9 happy path **结构成立**  
- **Non-claims** 全部保持  

**本文件路径：**  
`/Users/doubleshy0n/Dev/Universe Keyboard/docs/assignments/t9-responsive-pipeline-001-r5-rem-3-implementation-architecture-review.md`

---

## Addendum A — P1 remediation disposition (same day)

**Role:** Architecture Steward recording Executor fix against this review  
**Fixes:** `abandonResponsiveProvisionalL1WithoutHostCommit` on Return / direct-text /
finishActive* / mode switch; `alignResponsiveProvisionalAfterOrderedEngineApply` on
dual-gate engine apply; tests `testReturnWhileAheadDoesNotCommitDots` +
`testCoalesceBacklogStillPaintsL1`.  
**Suite (Executor re-run):** full KeyboardCore **852/0**.

| Finding | Disposition |
|---|---|
| **P1-1** host commit `·` | **Closed in code** |
| **P1-2** Delete ledger sticky | **Closed in code** |

This addendum is **not** a second independent full re-review. Remaining P2/P3 and
non-claims unchanged. Still **no** Product Gate / ADR Accept / default-on /
Rem-3-Device authorization.
