# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Remediation Evidence

**Date:** 2026-07-23 Asia/Shanghai  
**Executor:** Grok 4.5 → Codex（额度耗尽后按 Assignment 交接继续 Phase 0）  
**Scope:** **Phase 0 remediation only** (Codex Architecture Reject + Quality Fail follow-up)  
**Plan:** [`../plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md`](../plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md)  
**Branch / HEAD base:** `codex/t9-atomic-path-snapshot` @ `101b889` (worktree dirty; 004 WIP)  

### Explicit non-claims

- **No** Phase 1 `T9CompositionIdentity` implementation  
- **No** production identity-repair logic changes (DEBUG observation hooks only)  
- **No** PD-004 / ADR 0023 edits  
- **No** commit / push / PR  
- **No** Human Product Gate pass claim  

---

## 0. Codex first review disposition (addressed here)

Prior Phase 0 delivery was **Architecture Reject + Quality Fail**. Required remediations and status:

| Codex requirement | Status |
|---|---|
| DEBUG-only Core observation for A/B/C raw/state | **Done** — `T9Gate5CompositionTrace` + call sites |
| Trace 不得持久化或保留可逆用户拼写 | **Done** — 仅 DEBUG 进程内 ring；只保存 class/length/shape/随机 session signature；sanitizer test PASS |
| Delete early-return 分支必须可观测 | **Done** — confirmed-focus、empty、rejected、visible-spelling success 均有结构化事件 |
| B 真实 Device raw 必须取证 | **Done** — 选择单字「请」后 raw/result/remaining 结构与 session signature 完全不变 |
| Real C raw OR trace-driven C red (fan fan / first focus) | **Done** — FakeRime scripted morphologies RED |
| B root cause includes missing slot-rebase (not only pure-digit guard) | **Done** — evidence + dedicated red test |
| Strict mixed-raw validation (illegal chars, apostrophe, catalog, exact slots) | **Done** |
| `testGate5PartialTransition…` non-vacuous RED | **Done** |
| Remove alias tests that re-call same body | **Done** |
| Phase 0 scoped file-hash inventory | **Done** (§10) |
| Independent re-run of Phase 0 matrix | **Done** (§6) |
| No Phase 1 / no Human Gate claim | **Honored** |

---

## 1. Frozen Facts A / B / C (Human — do not overwrite)

| Path | Human Product Gate (iPhone 13 Pro · 备忘录) |
|---|---|
| **A** | 首次/2026-07-22 历史为 Fail；**2026-07-23 本轮 PASS** — 从扩展候选精确点选「请喂饭到」后 Path 显示并聚焦 `wo…` |
| **B** | **FAIL (本轮真机再次必现)** — 单字「请」后 Path empty；候选仍正常显示剩余「喂饭到我嘴里」 |
| **C** | **FAIL (必现)** — `qing wei fan fan` + Path 回首焦点 after JKL+Delete+继续 |
| Steps 1–4, 6–8 | Pass (首次 Gate；本复测仅针对 step5 A/B/C) |

### Human retest log (append-only)

| When | What | Result |
|---|---|---|
| 首次 Human Gate | Step 5 失败，叙事以 B/C 为主 | Fail |
| **2026-07-22 用户补测** | **A / B / C 三条路径均复现问题依旧** | **Fail（预期：Phase 0 未修生产）** |
| **2026-07-23 C 三次复现** | iPhone 13 Pro / iOS 27.0 / 备忘录；Codex 通过 Xcode Debug + LLDB ring buffer 直接采集 | **C raw 已钉死；界面仍为 `qing wei fan fan wo zui li` + 首段 Path** |
| **2026-07-23 A 精确候选复测** | RIME 学习后普通栏先出现更长「请喂饭到我嘴里」；用户从扩展候选精确点选「请喂饭到」 | **PASS — Path 显示并聚焦 `wo…`；更长完整句未被冒充为 A 证据** |
| **2026-07-23 B 单字复测** | 同一 Debug 构建，Path 选 `qing/wei/fan/dao` 后从扩展候选点单字「请」 | **FAIL — Path 为空；候选仍显示剩余「喂饭到我嘴里」** |

说明：Phase 0 仅增加 DEBUG 观测与红测，**故意未改身份修复逻辑**；真机问题依旧 **不等于** 诊断失败，只说明修复尚未开始。

---

## 2. DEBUG-only observation (`GATE5_TRACE`)

### Implementation

| Item | Detail |
|---|---|
| File | `Packages/KeyboardCore/Sources/KeyboardCore/T9Gate5CompositionTrace.swift` |
| Compile | `#if DEBUG` only — Release strips types + calls |
| Storage | **仅进程内 ring（64 lines）**；不调用 App Group Logger，不落盘；由 LLDB 临时读取 |
| Privacy | raw/preedit/source 仅记录 class、长度、run-length shape 与进程随机 `Hasher` session signature；confirmed/path 仅记录 count/length/signature；候选仅 `lenN`；不记录宿主正文 |
| Events | `pathSelect`, `digitAppend`, `deleteBackward`, `partialCommit` (+ note flags) |

### Call sites (observation only — no identity algorithm change)

- `KeyboardController+PartialCommit` — after nested partial + restore attempt (`slotRebaseMissing=…`)
- `KeyboardController+TextEditing` — after digit-backed Delete
- `KeyboardController+RimeRecovery` — after T9 digit append
- `KeyboardController+T9PinyinPath` — after successful Path select

### Line shape (structural)

```
GATE5_TRACE event=partialCommit rev=N
  prev={class=anchoredMixed,len=N,shape=L4.A1.L3…,sig=<session-random>}
  result={class=anchoredMixed,len=N,shape=L4.A1.L3…,sig=<session-random>}
  source={class=digits,len=N,shape=D20,sig=<session-random>}
  confCount=4 confLens=4,3,3,3 focus=4 pathCount=N candHead=len6,len4
  note=restore=false preservedConfCount=4 livePureDigits=false slotRebaseMissing=true
```

### Device capture instructions (Human + debugger operator)

安装 DEBUG 构建后，由用户只执行下列交互；结构化事件**不会写入 Console 或 App Group Logger**。调试人员仅通过 LLDB 显式读取 `T9Gate5CompositionTrace.snapshotLines()`，读取完成后调用 `reset()`，不得要求用户复制 raw 拼写或宿主正文。

**Path A**

1. 九键中文 → 输入 `qingweifandaowozuili` 数字串 `74649343263269698454`
2. Path 依次点 `qing → wei → fan → dao`
3. 点候选「请喂饭到」
4. 用户报告 Path UI 结果；调试人员如需诊断，仅从 LLDB ring 读取结构化 `partialCommit` 事件

**Path B**

1. 同上选到 `qing/wei/fan/dao`
2. 点单字「请」（可扩展面板）
3. 用户报告 Path/候选 UI 结果；调试人员从 LLDB ring 读取结构化 `partialCommit` 事件
4. 可选：再按一次 Delete；调试人员只读取结构化 `deleteBackward` / checkpoint 事件

**Path C**

1. 输入到 `qingweifanda`（`746493432632`），Path 选 `qing → wei → fan`
2. 误触 **JKL(5)** → **Delete**
3. 继续输入 `owozuili`（`69698454`）
4. 调试人员从 LLDB ring 读取 typo 前后结构化 `digitAppend` / `deleteBackward` 事件

> 2026-07-23 已完成 A/B/C 本轮真机复测，并完成 B/C 的 Device Bridge 结构化采集。A 以精确候选后的 UI 契约确认 Pass；B/C raw 证据均来自真机，不得用 FakeRime 形态替代。

---

## 3. Path B — corrected root cause

### Incomplete prior framing

“仅 pure-digit restore guard 拒绝 mixed remaining” **不充分**。

### Full Phase 0 root-cause class (B)

1. **Destructive clear** before restore：Partial 选择时先清空 `confirmed/source/paths`。  
2. **Pure-digit restore guard**：`liveRaw` 非纯数字时 restore 直接失败（device-like `wei'fan'dao'9698454`）。  
3. **Missing slot-rebase model**：即使放宽 guard，当前代码也没有  
   “消费 `qing` 的精确槽位 `[0..<4]` 后，将未消费的 `wei/fan/dao` 重基准到剩余 source `[4…)` 并聚焦 `wo`” 的身份转移器。  
4. 结果：Path 空、`src=nil`、`conf=[]`。

### Real device capture (authoritative for B)

2026-07-23，同一 iPhone 13 Pro / iOS 27.0 / 备忘录 Debug 构建：用户输入完整数字串，Path 依次选择 `qing → wei → fan → dao`，再从扩展候选点单字「请」。UI 结果为 Path 空，但候选仍正确显示剩余「喂饭到我嘴里」。LLDB 读取仅内存、已脱敏结构化 ring 得到：

```text
before selection (rev=70)
  raw/result: anchoredMixed len=24 shape=L4.A1.L3.A1.L3.A1.L3.A1.D7
  source: digits len=20
  confirmed: count=4 lens=4,3,3,3  focus=4  pathCount=6

partial selection (rev=71)
  previous/result/remaining:
    same class=anchoredMixed, same len=24, same shape,
    same process-random session signature
  source: none  confirmed: count=0  focus=nil  pathCount=0
  candidates: non-empty (len6,len4,len2,len2)
  note: restore=false preservedConfCount=4 livePureDigits=false slotRebaseMissing=true
```

结论：B 的真实 Bridge **没有返回缩短的 remaining raw**；选择前后的 raw 表示完全不变。因此：

1. `remainingRaw` 不能在该分支充当“未消费后缀”；若直接编码，会错误得到完整 source。
2. 消费边界必须来自候选选择前已经验证的 `segment→slot` 身份与候选实际覆盖的前缀，并由统一 reducer 执行。
3. `wei'fan'dao'9698454` 仍是 FakeRime 覆盖的“Bridge 明确返回缩短 remainder”分支，不能冒充真机 B；它只证明该分支可做严格唯一后缀对齐。
4. 这进一步否定“只放宽 pure-digit guard”的局部修法，同时不要求改变候选排序、catalog 或 PD/ADR。

### Automation capture (B)

```
resultRaw=wei'fan'dao'9698454 rawIsPureDigits=false
srcBefore=74649343263269698454 srcAfter=nil conf=[] paths=[] pathEmpty=true
windowDelta=0
DEBUG note: slotRebaseMissing=true
```

新增 `testGate5BDeviceUnchangedRawStillConsumesQingAndPreservesRemainingIdentity`：FakeRime 用 selected-segment 行为模拟“候选已部分消费、raw 完全不缩短”的真机边界，并明确断言消费 `qing` 后 source 应为原 source 的 `dropFirst(4)`、保留 `wei/fan/dao`、focus=3、Path 含 `wo`。当前生产代码稳定 RED（5 个契约断言失败），且 `candidateWindow` 增量为 0。

### Strict mixed remaining proof

`testGate5BMixedRemainingStrictSlotAndCatalogValidation` **PASS**:

| Check | Result |
|---|---|
| Illegal chars / spaces rejected | yes |
| Apostrophe segment boundaries | `wei` `fan` `dao` + digit tail |
| Catalog-legal syllables | yes (`T9PinyinSyllableCatalog.syllables`) |
| Exact slot ranges on source | wei `4..<7`, fan `7..<10`, dao `10..<13`, digits `13..<20` |
| Consumed prefix slots | **4** (`qing` only) — not mere `hasSuffix` |

---

## 4. Path C — device-calibrated failure morphology

### Real device capture (authoritative for C)

环境与方法：iPhone 13 Pro（iOS 27.0）连接 Device Hub；Xcode 以 `Keyboard` scheme 直接附加键盘扩展；`T9Gate5CompositionTrace` 使用 DEBUG-only MainActor ring buffer。用户连续复现 C，Codex 在记录函数停点内导出脱敏缓冲。未读取宿主文档正文，候选仅记录长度。

真机重复两次得到同构轨迹。以下为第一组关键边界：

```text
rev=13 digitAppend
  resultRaw=7464934326325  resultClass=digits
  src=7464934326325  focus=0

# 用户随后 Delete；当前诊断 hook 在该设备分支没有发出 deleteBackward 行。
# 因此不推断 Delete 内部的瞬时值，只使用前后夹逼事实。

rev=15 digitAppend digit=6
  prevRaw=qing wei fan fa
  resultRaw=qing wei fan fa6  resultClass=mixed
  src=7464934326325  focus=0
  pathHead=qing,ping,pin,qin,pi,qi

rev=22 digitAppend（继续输入完成）
  resultRaw=qing wei fan fa69698454  resultClass=mixed
  src=7464934326325  focus=0
  pathHead=qing,ping,pin,qin,pi,qi
```

第二组重复轨迹为 rev `54 → 56…63`，raw/source/focus 形态一致。由此可确认：

1. Delete 后 RIME live raw 从纯数字切换成 `qing wei fan fa`，不是原 FakeRime 假设的纯数字 remainder。
2. 下一次按键把数字追加到 mixed raw；Core 的 `sourceDigits` 没有追加新槽，仍保留误触尾部 `5`。
3. `confirmed=[]`、`focus=0`、Path 始终为首段 `qing/ping/…`，与真机界面 `fan fan`/首焦点完全对应。
4. 这不是单纯放宽 pure-digit guard 可以修复的问题；需要 reducer 按按键槽位统一处理 raw 表示切换、Delete rebase 与 append。

### FakeRime calibration

### FakeRime extensions

- `deleteBackwardScript: [RimeOutput]`
- `processKeyScript: [RimeOutput]`
- `seedSessionComposition(_:)`

### Scripted Frozen Fact (Human-aligned, not byte-identical)

| Step | Scripted RIME output | Production outcome |
|---|---|---|
| Typo Delete | pure digits `746493432632` + preedit `qing wei fan fan` | conf may restore via `restoreFocused`, but **preedit stays fan fan** → RED |
| Continue first key | pure full `74649343263269698454` + preedit `qing wei fan fan` + candidates 轻微饭饭 | **conf=[]**, **paths=qing/ping/… first focus**, preedit fan fan → **RED** |

### Capture (C continue — RED)

```
GATE5_C_CONTINUE_TRACE:
  raw=74649343263269698454 conf=[]
  paths=["qing","ping","pin","qin",…]
  preedit=qing wei fan fan
  src=74649343263269698454 windowDelta=0
```

This matches Human Frozen Fact class: **fan fan + Path 回首焦点**.  
Production mechanism exercised: mixed-raw transition does not preserve a slot-bound identity.

新增 `testGate5CDeviceMixedRawDeleteRebasesSourceBeforeContinue` 使用真机 raw 边界：Delete 输出 `qing wei fan fa`，下一键输出 `qing wei fan fa6`。FakeRime 下 source 在 Delete 后能回到 prefix，但下一键仍不推进，并暴露 `fan fan` + 首段 Path；这条红测用于钉死 reducer 契约。真机 `src` 在下一键仍为带误触 `5` 的旧值，是更强的设备失败证据。

---

## 5. Path A (automation + current device)

```
GATE5_A: resultRaw=9698454 partialRemaining=9698454 src=9698454
  conf=[] focus=0 paths=["wo","yo","w","x","y","z"] windowDelta=0
```

**PASS** under pure-digit remainder FakeRime.

2026-07-23 真机复测：RIME 学习状态使普通候选栏优先出现完整句「请喂饭到我嘴里」，这不能替代 A。用户展开候选并精确点选「请喂饭到」后，Path 立即显示并聚焦 `wo…`，因此本轮 A UI 契约为 **PASS**。首次 Gate 5 与 2026-07-22 的 A Fail 记录仍保留，不回写历史。

---

## 6. Tests (Phase 0 matrix)

### Command

```bash
cd Packages/KeyboardCore
swift test --filter 'Gate5|testDeleteInvalidatesOnlySegmentIntersectingDeletedSlot|testAppendDeleteRoundTripPreservesConfirmedSegmentRanges|testMixedRawIdentityUsesT9SignatureNotLetterBudget'
```

### Results (2026-07-23 A/B/C device-calibrated re-run)

`16` tests executed: `7` PASS, `9` expected RED, `27` contract assertion failures, `0` unexpected harness failures. Build succeeded. Exit code 1 is solely the expected Phase 0 contract-red result; no compile or harness failure.

| Test | Result | Notes |
|---|---|---|
| `testGate5AFullCandidateRebasesPathToWo` | **PASS** | pure-digit remainder |
| `testGate5BDeviceUnchangedRawStillConsumesQingAndPreservesRemainingIdentity` | **RED** | 真机边界：raw unchanged，仍必须消费 qing 槽并保留 wei/fan/dao |
| `testGate5BSingleCharacterPartialKeepsRemainingSelectedSegmentsAndFocusesWo` | **RED** | Path wipe |
| `testGate5BPartialConsumesQingRequiresSlotRebaseOfRemainingSegments` | **RED** | slot-rebase missing |
| `testGate5BFirstDeleteRestoresExactT9SemanticCheckpoint` | **RED** | no semantic Path restore |
| `testGate5PartialTransitionPublishesSingleCoherentRevision` | **RED** | requires non-empty Path/cand |
| `testGate5BMixedRemainingStrictSlotAndCatalogValidation` | **PASS** | strict parser |
| `testGate5CTypoAppendThenDeleteRestoresSemanticIdentity` | **RED** | fan-fan preedit |
| `testGate5CContinueTypingAfterDeleteDoesNotDuplicateFan` | **RED** | fan fan + first focus |
| `testGate5CDeviceMixedRawWithoutSelectionsRebasesSourceBeforeContinue` | **RED** | device mixed raw；next source 不推进 + fan fan + 首段 Path |
| `testGate5CDeviceMixedRawWithSelectedSegmentsPreservesIdentity` | **RED** | 非空 qing/wei/fan 身份下仍不能推进 source，host 仍 fan fan |
| `testGate5CTypoAppendThenDeleteWithProvisionalOnlyPath` | **PASS** | provisional round-trip |
| `testGate5TraceRedactsCompositionTokensInMemory` | **PASS** | ring 不包含 qing/wei/fan/dao、原数字串或可逆 token |
| `testDeleteInvalidatesOnlySegmentIntersectingDeletedSlot` | **PASS** | baseline |
| `testAppendDeleteRoundTripPreservesConfirmedSegmentRanges` | **PASS** | unscripted happy path |
| `testMixedRawIdentityUsesT9SignatureNotLetterBudget` | **PASS** | slot map |

**Removed aliases:**  
`testGate5BSingleCharacterPartialHandlesAnchoredMixedRaw`,  
`testGate5BExpandedCandidateUsesSamePartialIdentityTransition`  
→ replaced by independent slot-rebase + strict validation tests.

---

## 7. RIME call budget (Phase 0)

| Scenario | Observed |
|---|---|
| B partial | `candidateWindow` Δ = 0 |
| B unchanged-raw device-calibrated partial | `candidateWindow` Δ = 0 |
| B first Delete | window Δ = 0 |
| C continue scripted | window Δ = 0 |
| Unscripted append/delete round-trip | processKey 1 for typo only |

No production probe loops added.

---

## 8. Production code policy this phase

| Change | Allowed? |
|---|---|
| DEBUG-only `GATE5_TRACE` hooks | **Yes** (diagnosis) |
| FakeRime scripts + red tests | **Yes** |
| Evidence / plan checkboxes | **Yes** |
| Identity reducer / restore guard relaxation | **No** — not started |
| PD-004 / ADR 0023 | **No** |

`T9CompositionIdentity.swift`: **ABSENT**.

---

## 9. Independent review placeholders

| Review | Status |
|---|---|
| Codex Architecture（首轮设备 C 证据后） | **Reject** — B device raw、A device 边界、trace privacy、C selected identity、Delete early-return 仍阻塞 |
| Codex Quality（首轮设备 C 证据后） | **Fail** — 同上；禁止进入 Phase 1 |
| Codex Architecture（三审） | **Reject / Phase 1 No** — unchanged raw 分支缺少 production-visible engine-native consumed range；触发 Stop Condition |
| Codex Quality（三审） | **Pass-with-findings / Phase 1 Yes from Quality only** — 无 Quality blocker；独立动态复跑受平台额度限制，主线程当代复跑为 16/7/9/27/0 |
| Human retest | **Partial evidence** — A 本轮 Pass；B/C 本轮 Fail；完整 Human matrix 仍 PENDING |
| Phase 1 approval | **Blocked** — Architecture Reject 优先；必须先完成 Phase 0.5 candidate-coverage authority spike 并重新审查 |

### Architecture 三审 blocking finding

当前 `RimeOutput` 只有 raw/composition/candidates/commit/paging，`RimeComposition` 只有 preedit/cursor；候选引用只提供页码与索引。真实 librime 的 `RimeComposition` 虽存在 `sel_start/sel_end`，现有 ObjC Bridge 与 Swift parser 没有透传。由此：

- B unchanged raw 时，pre-selection segment→slot ledger 只能提供多个合法边界，不能证明单字候选实际消费的是 `qing` 的 `0..<4`。
- FakeRime 的 `FakeRimeSelectedSegment.rawPrefix` 只在 Fake 内部裁剪候选/拼 preedit，返回的生产同构 `RimeOutput` 仍没有 coverage 元数据；它能钉死期望结果，不能证明 reducer 拥有足够输入。
- 若用候选「请」的汉字数、comment、preedit 或排名映射到 `qing`，违反本计划禁止猜测的约束。
- 正确方向是先做 Phase 0.5 真实 Bridge Spike，证明 `sel_start/sel_end` 或等价 engine-native range 是否稳定对应候选覆盖范围；若可靠，再由 Product Lead 更新 Assignment/allowlist 后最小透传。若不可靠，Stop 并交回 Architecture/Product。

因此 Quality 的 Yes 不能覆盖 Architecture 的 No；当前不得开始 `T9CompositionIdentity` 实现。

---

## 10. Phase 0 scoped file-hash inventory

SHA-256 of files touched for **this Phase 0 remediation** (diagnosis + tests + docs).  
Pre-existing 004 WIP files outside this list are **not** claimed as Phase 0-only.

| SHA-256 | Path |
|---|---|
| `453cf9622f2a07b30b2c9d91b4974d58202f2923e273fce193bc6f9b895179ce` | `Packages/KeyboardCore/Sources/KeyboardCore/T9Gate5CompositionTrace.swift` |
| `1ecce1b82a33d22c08e502694012f943ed2b93e18b390e324107b906887847c4` | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift` |
| `b69e5ef2612910a6ccf66fe1358699e7d66a5b74221ba54e6bd40af8fa131c91` | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift` |
| `6c11e59ed8ff038edd7f4da6b3bf86ecfe171c827268eb9a10e48886750b6523` | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift` |
| `7513aa7818153fe4469029375ab64aa0802726dd751772b03ff33fb21a4d6f52` | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift` |
| `016850f8dfdbe4b6a79988aac70f23d2b20745d003c646f137d0116c073b58bf` | `Packages/KeyboardCore/Tests/KeyboardCoreTests/FakeRimeEngine.swift` |
| `75bf53ca73abdb22345c9e328620b85e7e8beb0e1e9ac08d0d66422209179ed6` | `Packages/KeyboardCore/Tests/KeyboardCoreTests/PartialCommitControllerTests.swift` |
| `148b52e19d66670b2fdd9b4ddcb4a40e1bfd74f8aa1698dcaeeba95531850156` | `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift` |
| `bb564fc6aee83f59825b4a5b29f42add8537974e37ad07814368f0d22960c8c0` | `docs/assignments/keyboard-layout-9key-pinyin-004.md` |
| `7f62655347ba0069f93a01bf3071a4e13ad8b481d5160bdac5325e006a2f14b5` | `docs/plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md` |
| `de39e2c6a29b91ad07626592807b540ea0585e1040f47fd65eacfb803dd8cf45` | `docs/assignments/keyboard-layout-9key-pinyin-004-gate-entry-status.md` |
| `e27c488a0338f45110a13c8dc40ca0347c137071b8b1010e860182b263c956e7` | `docs/assignments/keyboard-layout-9key-pinyin-004-implementation-evidence.md` |
| `fafc0fa3399e445d89cca33f329b73f352ddcd3e5293df9fa467e4b8a0baa8c8` | `docs/assignments/keyboard-layout-9key-pinyin-004-gate5-phase05-grok-handoff.md` |

本 evidence 文件不记录自身 SHA（自引用哈希不可稳定）；Reviewer 应在读取时即时计算。

**Allowlist note:** Production diffs in the four `KeyboardController+*` files are **DEBUG trace hooks only** (no restore/identity algorithm edits). New diagnostic source is DEBUG-only.

---

## 11. Residual risks

- C 的 Device Bridge raw 已采集；FakeRime source 的具体错误值与设备不同，但都违反“Delete rebase 后下一槽必须推进”的同一契约，证据中已明确区分。  
- B 的 Device Bridge raw 已采集并证明 unchanged；FakeRime 的 shortened mixed remainder 是另一受支持分支，两者不得合并成同一推断规则。  
- C 的 `deleteBackward` 早返回分支已经补结构化事件；本轮 B/C 关键原始证据仍以操作前后夹逼与 reducer 红测共同约束。  
- C delete can restore `conf` while leaving fan-fan preedit — both are asserted.  
- A 本轮精确部分候选 UI 契约 Pass，但学习状态会改变候选可见位置；后续 Human Gate 必须仍精确选择目标候选，不能用完整句替代。  
- B unchanged raw 的“实际消费前缀”：**Phase 0.5 已证** librime `sel_*` **不是**权威字段（menu-scoped）；coverage 输入仍 `UNKNOWN`，仍是 Architecture blocker，不得由 RED 期望值或汉字数/comment 反推。  
- Full directed 004 matrix (non-Gate5) not re-run this phase.  
- Snapshot contract suite Gate5 cases still deferred to Phase 3.

---

## 12. Handoff to Codex (second Architecture + Quality)

**Ask Codex to re-score Phase 0 only:**

1. Is B root cause complete (destructive clear + pure-digit guard + **missing slot rebase**)?  
2. Does B unchanged raw prove Phase 1 must consume slots from the pre-selection semantic ledger rather than post-selection `remainingRaw`?  
3. Is C 的真机 mixed-raw 轨迹 + selected/non-selected calibrated red coverage sufficient to close Device raw UNKNOWN?  
4. Are in-memory structural traces + sanitizer test privacy-safe and free of identity “fix” leakage?  
5. Are red tests fail-closed (no vacuous greens / alias double-count)?  
6. File-hash scope acceptable vs allowlist?  
7. **Explicit Yes/No:** approve Executor to enter Phase 1 `T9CompositionIdentity`?

三审答案：Architecture **No**；Quality **Yes with nonblocking findings**；综合 Gate 决策为 **No / Phase 1 blocked**。

**Forbidden until approval:** Phase 1 implementation, Human Gate claim, commit/push/PR.

---

## 13. Phase 0.5 — engine-native candidate coverage Spike (Grok 4.5)

**Date:** 2026-07-23 Asia/Shanghai  
**Executor:** Grok 4.5（Product Lead 本会话授权）  
**Authority:** Assignment Phase 0.5 Authorization + allowlist  
**Handoff:** [`keyboard-layout-9key-pinyin-004-gate5-phase05-grok-handoff.md`](keyboard-layout-9key-pinyin-004-gate5-phase05-grok-handoff.md)  
**HEAD base:** `101b889`（worktree dirty；未 commit）

### Explicit non-claims (Phase 0.5)

- **No** Phase 1 `T9CompositionIdentity`  
- **No** identity reducer / Partial/Delete 算法改动  
- **No** PD-004 / ADR 0023 / catalog / 26 键 / UIKit  
- **No** commit / push / PR  
- **No** Human Product Gate pass  
- **No** 用汉字数、comment、preedit、排名推断消费槽位  

### 13.1 Loss-point trace（只读）

| Layer | `sel_start` / `sel_end` before Phase 0.5 | After Spike |
|---|---|---|
| librime C `RimeComposition` | 字段存在 | 不变 |
| ObjC `collectOutput` | **丢弃**（只写 preedit/cursorPos） | 写入 `selStart` / `selEnd` |
| Swift `parseOutputDictionary` | **不解析** | 可选 `selectionStart` / `selectionEnd` |
| `RimeComposition` | 无字段 | 可选只读字段（默认 `nil` 兼容） |
| Core reducer / PartialCommit | 未使用 | **仍未使用**（禁止接入） |

### 13.2 Production-visible read-only interface（生命周期 / 兼容性）

| Item | Spec |
|---|---|
| ObjC keys | `selStart` / `selEnd`（`NSNumber` int） |
| Swift fields | `RimeComposition.selectionStart` / `selectionEnd`（`Int?`） |
| Presence | 非空 composition 且 bridge 返回时非 `nil`；旧字典缺失 → `nil`（不发明默认值） |
| Units | 与 librime 一致：preedit UTF-8 码元偏移（与 `cursor_pos` 同单位） |
| Lifecycle | 每次 `processKey` / `selectCandidate` / `replaceInput` / `currentOutput` 的 composition 快照；**不是**候选级字段 |
| Compatibility | 既有 `RimeComposition(preeditText:cursorPosition:)` 调用方默认 `nil` |
| Consumer rule | Architecture 确认前 **不得** 作为 T9 槽位消费权威；缺失/越界必须 fail-closed，不得 clamp 猜测 |

### 13.3 Commands

```bash
# Isolated runtime (copied from 004 spike fixture)
EVIDENCE=evidence/keyboard-layout-9key-pinyin-004-gate5-phase05/20260723-153306
export UK_RIME_T9_SPIKE_SHARED_DIR=$PWD/$EVIDENCE/runtime/shared
export UK_RIME_T9_SPIKE_USER_DIR=$PWD/$EVIDENCE/runtime/user
export TEST_RUNNER_UK_RIME_T9_SPIKE_SHARED_DIR=$UK_RIME_T9_SPIKE_SHARED_DIR
export TEST_RUNNER_UK_RIME_T9_SPIKE_USER_DIR=$UK_RIME_T9_SPIKE_USER_DIR
export SIMCTL_CHILD_UK_RIME_T9_SPIKE_SHARED_DIR=$UK_RIME_T9_SPIKE_SHARED_DIR
export SIMCTL_CHILD_UK_RIME_T9_SPIKE_USER_DIR=$UK_RIME_T9_SPIKE_USER_DIR

xcodebuild test \
  -project "Universe Keyboard.xcodeproj" \
  -scheme RimeBridgeTests \
  -destination "platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474" \
  -derivedDataPath $EVIDENCE/DerivedData \
  -only-testing:RimeBridgeTests/RimeEngineContractTests/testOutputParserPassesThroughEngineNativeSelectionRange \
  -only-testing:RimeBridgeTests/RimeEngineContractTests/testOutputParserSeparatesRawInputFromDisplayPreedit \
  -only-testing:RimeBridgeTests/RimeT9PinyinSelectionSpikeTests/testGate5Phase05CandidateCoverageSelRangeOnPinnedLibrime \
  -only-testing:RimeBridgeTests/RimeT9PinyinSelectionSpikeTests/testGate5Phase05SelectionRangeFailClosedParserContract
```

Core smoke（package）：

```bash
cd Packages/KeyboardCore && swift test --filter testGate5BMixedRemainingStrictSlotAndCatalogValidation
```

### 13.4 Results

| Test | Result |
|---|---|
| `testOutputParserPassesThroughEngineNativeSelectionRange` | **PASS** |
| `testOutputParserSeparatesRawInputFromDisplayPreedit`（nil 兼容） | **PASS** |
| `testGate5Phase05CandidateCoverageSelRangeOnPinnedLibrime` | **PASS**（verdict 写入断言） |
| `testGate5Phase05SelectionRangeFailClosedParserContract` | **PASS** |
| Core `testGate5BMixedRemaining…` smoke | **PASS** |
| FakeRime 显式 coverage / Core identity fail-closed | **Not added** — range 不可靠，按 handoff 禁止猜测实现 |

Machine summary（pinned t9 / librime 1.16.1 系 fixture）：

```text
T9_GATE5_PHASE05_SEL_RANGE verdict=UNRELIABLE_MENU_SCOPED_ONLY
  preSel=0..26
  singleRawLen=24 multiRawLen=na
  singleCommitLen=na multiCommitLen=7
  singlePostSel=3..24 multiPostSel=nil..nil
  rawUnchangedSingle=true rawUnchangedMulti=false
  outcomesDiffer=true
  singleLabel=B_single_pageIndex=7
```

Structured observations（脱敏：仅 class/len/range；无宿主正文）：

| Step | rawClass | rawLen | preeditLen | sel | commitLen | notes |
|---|---|---|---|---|---|---|
| B before select | anchoredMixed | 24 | 26 | **0..26** | 0 | 整段 preedit 为 active segment |
| B after window read | anchoredMixed | 24 | 26 | 0..26 | 0 | 只读窗口不改 composition/sel |
| B after page down | anchoredMixed | 24 | 24 | **0..5** | 0 | 翻页可改 menu segment，仍非候选级 |
| B single pre | anchoredMixed | 24 | 26 | 0..26 | 0 | 与 multi 同一 pre-select range |
| B single select (pageIndex=7, textLen=1) | anchoredMixed | **24** | 24 | **3..24** | 0 | **raw 不缩短**（对齐真机 B） |
| A multi pick (pageIndex=0, textLen=7, commentSyll=7) pre | anchoredMixed | 24 | 26 | **0..26** | 0 | **与 B 相同 preSel** |
| A multi select | empty | 0 | 0 | nil | **7** | 整句提交；outcome 与 B 不同 |
| shortened remainder before | anchoredMixed | 19 | 21 | 0..21 | 0 | |
| shortened select0 | empty | 0 | 0 | nil | 6 | |
| digits 7464 before | digits | 4 | 4 | 0..4 | 0 | |
| digits select0 | empty | 0 | 0 | nil | 1 | |

### 13.5 Verdict（Architecture blocking answer）

> **`sel_start` / `sel_end` 不能权威表达「某个候选实际消费的 T9 sourceDigits 槽位」。**

| Criterion | Finding |
|---|---|
| 字段可透传？ | **Yes** — Bridge/parser 已只读暴露 |
| 选择前稳定？ | **Yes** — 同 composition 快照下固定（如 `0..26`） |
| 语义 | **Menu / composition active segment**（高亮转换段），**不是** per-candidate 消费宽度 |
| 能否区分 B「请」vs A 多音节/整句？ | **No** — 二者 pre-select 同为 `0..26`；outcome 不同但 **sel 无法在选择前区分** |
| 选择后 sel 是否 = 已消费 raw 前缀？ | **No** — B 后 `sel=3..24` 像是 **剩余** 转换区（3 可能对应已确认汉字 UTF-8 字节宽），**不是** `qing` 的 `0..<4` 源槽 |
| 映射 sourceDigits 唯一槽位？ | **No** — 单位在 preedit 显示串上；B 分支 raw 甚至不缩短 |
| 需要 comment/汉字数/排名？ | 若强行猜消费，会违反禁止项 — **Stop** |

**Machine verdict string:** `UNRELIABLE_MENU_SCOPED_ONLY`  
**Assignment residual status for Phase 1 coverage input:** `UNKNOWN`（仍缺 per-candidate engine-native coverage）

### 13.6 Stop Conditions triggered

按 handoff §6：

1. `sel_start/sel_end` **只表示 composition 活跃段/高亮范围，而非候选消费范围** → Stop  
2. range **不能唯一映射** pre-selection source slots → Stop  
3. 不得用候选文本/comment/排名补齐 → 遵守  
4. **未**进入 Phase 1；**未**把 coverage 接入 reducer  

### 13.7 What was intentionally not done

- FakeRime 显式 `coverage` 字段（仅在 range 可靠时才授权）  
- Core `T9CompositionIdentity` / Partial identity 修改  
- 将 `selectionStart/End` 接入任何生产决策路径  

### 13.8 Phase 0.5 file-hash inventory

| SHA-256 | Path |
|---|---|
| `f030f4ca5985c32d803ccefdd2be7718f7bfa2e1116156f045cc4731432215a6` | `Packages/RimeBridge/Sources/RimeBridgeObjC/include/RimeSessionManager.h` |
| `f8e2ec390c7136ff80717ad87688f948ecaef25a78e54e728f0b7f0e60ec1c96` | `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m` |
| `3f8f6e4ac2b97d57d4aaa7a4dd700f891becbe90233c564606e48520a3930304` | `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+Output.swift` |
| `bf7dee3be278ef24a239121530110961c5d7469f58a81e1ca1faf0a311026073` | `Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9PinyinSelectionSpikeTests.swift` |
| `dd02fa35d66d74df626c63b4c337944ba63815f5c9670dc88f049ff50c1d6512` | `Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift` |
| `c4e91fb17b9f008c991cf2acaa58d6a9b3996ac3e6db2ee8cd66a144b29f8e1a` | `Packages/KeyboardCore/Sources/KeyboardCore/RimeComposition.swift` |
| `aab31ce735c905dc6879e78ef072d34fc8f715c864efb9acd217be9d3e94aa80` | `Packages/KeyboardCore/Sources/KeyboardCore/RimeOutput.swift`（未改） |
| `016850f8dfdbe4b6a79988aac70f23d2b20745d003c646f137d0116c073b58bf` | `Packages/KeyboardCore/Tests/KeyboardCoreTests/FakeRimeEngine.swift`（未改） |

文档：Assignment / plan / gate-entry / 本 evidence / handoff 已更新；本文件不记自哈希。

### 13.9 Handoff to Codex（Architecture + Quality 独立复审）

**请 Codex 仅复审 Phase 0.5，回答：**

1. 是否同意 `sel_*` 仅为 menu-scoped active segment，**不能**作为 per-candidate T9 槽位消费权威？  
2. 只读透传接口（可选字段、nil 兼容、未接入 reducer）是否可保留为观测契约？  
3. B 真机 + Bridge Spike 双重证明 raw unchanged 后，Phase 1 是否仍缺 **其他** engine-native 或 **ledger-only** 权威路径？  
4. 是否批准任何替代覆盖信号调研（若批准，须新 Product Lead allowlist）？  
5. **Explicit Yes/No：** 能否进入 Phase 1？在 coverage 仍 `UNKNOWN` 时默认应为 **No**，除非 Architecture 接受「仅 pre-selection segment ledger + 显式用户 Path 选择」作为消费边界且不依赖 engine coverage。

**Forbidden until re-approval:** Phase 1 implementation, Human Gate claim, commit/push/PR.

---

## 14. Phase 0.5 Independent Review disposition（KOS 2.0）

**Date:** 2026-07-23 Asia/Shanghai  
**Full record:** [`keyboard-layout-9key-pinyin-004-gate5-phase05-independent-review.md`](keyboard-layout-9key-pinyin-004-gate5-phase05-independent-review.md)  
**Roles:** 🏛️ Architecture & Knowledge Steward + 🧪 Quality, Performance & Release Maintainer  

| Gate | Disposition |
|---|---|
| Phase 0.5 Spike completeness | **Accept / Done** |
| Verdict `UNRELIABLE_MENU_SCOPED_ONLY` | **Architecture Accept** |
| Read-only `selStart/selEnd` passthrough | **Architecture Accept with constraints**（不得作 T9 coverage；不得接入 reducer） |
| Quality on Phase 0.5 evidence | **Pass-with-findings**（Q1 硬编码 verdict；Q2 A 冷 fixture 未命中「请喂饭到」） |
| Independent test re-run | **TEST SUCCEEDED** — `logs/phase05-independent-review-rerun.log` |
| Hash inventory re-check | **Match §13.8** |
| Phase 1 `T9CompositionIdentity` | **No / Blocked** — coverage 仍 `UNKNOWN`；ledger-only 不足 |
| Human Product Gate | **Unchanged Fail**；不得重开直至产品/架构另批 |

### Answers to §13.9

1. **Yes** — `sel_*` menu-scoped only。  
2. **Yes with constraints** — 观测契约可保留。  
3. **Yes still missing** — 需其它权威或产品 fail-closed 取舍。  
4. **Needs Product Lead** — 新 allowlist / 新 Spike；本复审不自行开实现。  
5. **Phase 1 = No.**

---

## 15. Product Lead disposition after Phase 0.5 review

**Date:** 2026-07-23 Asia/Shanghai  
**Role:** Product Lead  
**Decision:** [`PD-…-004-GATE5-PATH`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-path-decision.md)

| Item | Product Lead decision |
|---|---|
| Phase 0.5 | **Closed** — 接受独立复审否定结论与只读透传约束 |
| Path α | **Authorized** as **Phase 0.6**（替代 coverage / selection-delta Spike） |
| Path β | **Mandatory safety floor** — 无 coverage 时禁止错误 Path 重基准；**不是**单独关闭 Gate 5 的方案 |
| Path γ | **Rejected**（本时点）— Gate 5 保持 Active |
| Phase 1 | **Still blocked** |
| Human Gate | **Not re-opened** |
| B 验收是否收窄 | **No** — 仍要求单字 Partial 后保留未消费 Path 并聚焦剩余音节 |
| Executor for 0.6 | Grok 4.5（Assignment 续任） |
| commit / push / PR | **Not authorized** |

Product Lead **不**在本步实现 Phase 0.6 代码；授权后由 Executor 按 allowlist 执行。

---

## 16. Phase 0.6 — alternative coverage / selection-delta Spike (Grok 4.5 Executor)

**Date:** 2026-07-23 Asia/Shanghai  
**Executor:** Grok 4.5  
**Authority:** [`PD-…-004-GATE5-PATH`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-path-decision.md) + Assignment Phase 0.6  
**Evidence dir:** `evidence/keyboard-layout-9key-pinyin-004-gate5-phase06/20260723-155717/`  
**HEAD base:** worktree dirty；**未** commit  

### Explicit non-claims

- **No** Phase 1 / reducer 接入  
- **No** 用汉字数、comment、preedit 内容、排名、或 `sel_*` 作槽位权威  
- **No** Human Gate 通过  
- **No** commit / push / PR  

### 16.1 New read-only observation fields

| Field | Source | Consumer rule |
|---|---|---|
| `caretPos` → `RimeOutput.caretPositionInRaw` | `get_caret_pos`（raw 空间） | 只读观测；**未**证明为槽位权威 |
| `compositionLength` → `RimeComposition.length` | `composition.length` | 只读 |
| `commitPreviewLen` → `commitPreviewLength` | `commit_text_preview` UTF-8 长度 | **禁止**当汉字数→槽位映射 |
| `highlightCandidateOnCurrentPage(at:)` | librime highlight API | Spike 用；不提交 |

### 16.2 Commands

```bash
EVIDENCE=evidence/keyboard-layout-9key-pinyin-004-gate5-phase06/20260723-155717
export UK_RIME_T9_SPIKE_SHARED_DIR=$PWD/$EVIDENCE/runtime/shared
export UK_RIME_T9_SPIKE_USER_DIR=$PWD/$EVIDENCE/runtime/user
# + TEST_RUNNER_ / SIMCTL_CHILD_ 同路径

xcodebuild test -scheme RimeBridgeTests \
  -destination "platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474" \
  -derivedDataPath $EVIDENCE/DerivedData \
  -only-testing:…/testOutputParserPassesThroughPhase06EngineNativeObservationFields \
  -only-testing:…/testGate5Phase06AlternativeCoverageSelectionDeltaOnPinnedLibrime
# → TEST SUCCEEDED；log: logs/phase06-xcodebuild-5.log
```

Core smoke: `swift test --filter testGate5BMixedRemainingStrictSlotAndCatalogValidation` **PASS**

### 16.3 Machine summary

```text
T9_GATE5_PHASE06_DELTA verdict=UNRELIABLE_NO_ALLOWED_SLOT_MAP
  allowedVariesByHighlight=true
  previewVariesByHighlight=true
  selVariesByHighlight=true
  postAllowedDiffer=true
  singleRawDelta=0 multiRawDelta=24
  singleCaretDelta=0 multiCaretDelta=24
  singleCompDelta=2 multiCompDelta=na
  raw/caret/comp DeltaMapsSingle=false (none hit legalCuts 4/7/10/13)
  singleRawUnchanged=true bBlockedByUnchangedRaw=true
```

### 16.4 Key observations (structural only)

| Step | rawLen | caret | compLen | sel | commitLen | notes |
|---|---|---|---|---|---|---|
| base | 24 | **24** | 26 | 0..26 | 0 | caret 钉在 raw 末尾 |
| highlight hi=0 | 24 | 24 | 26 | 0..26 | 0 | |
| highlight hi=1..6 | 24 | 24 | 24 | 0..9 | 0 | allowed 字段有变化，但非槽位切点 |
| highlight hi=7/8 | 24 | 24 | 24 | 0..5 | 0 | |
| B single post (textLen=1) | **24** | **24** | 24 | 3..24 | 0 | raw/caret **零差分** |
| A multi post (textLen=7) | 0 | 0 | nil | nil | 21 | 整句提交；与 B 可区分但靠 raw 清空 |
| shortened post | 0 | 0 | nil | nil | 18 | |
| digits post | 0 | 0 | nil | nil | 3 | |

Allowed feature vector = `{rawLen, caret, compLen, commitLen, residualComposing}`。  
legal Path slot cuts = `{4,7,10,13}`（qing/wei/fan/dao 前缀账本，仅作对照，非引擎证明）。

### 16.5 Verdict

> **`UNRELIABLE_NO_ALLOWED_SLOT_MAP`**

| Question | Answer |
|---|---|
| 是否存在非 `sel_*` 且 Product 允许的引擎信号，能映射到 T9 sourceDigits 槽？ | **No（本 pinned t9 观测）** |
| `get_caret_pos` 能否表达消费槽位？ | **No** — B 前后均为 raw 末尾 `24`，delta=0 |
| raw 差分？ | B **0**；多字/整句才清空 raw（24），不是 4/7/10/13 切点 |
| composition.length 差分？ | B 仅 `2`，不在 legal cuts |
| highlight 时 allowed 字段是否变化？ | **Yes**（compLen/部分 menu 态），但变化量 **不能**映射 legal slot cuts |
| previewLen 变化？ | 轻微（21/22）；**禁止**当汉字数权威 |
| coverage 输入状态 | 仍 **`UNKNOWN`** |
| Phase 1 | **仍 blocked** |

### 16.6 Path β note

本 Spike **未**实现 fail-closed 生产逻辑；否定结论加强 Path β 底线：无 coverage 时禁止猜测重基准。

### 16.7 Phase 0.6 hash inventory

| SHA-256 | Path |
|---|---|
| `f860e28648066f265931ebee6f6a72937b75d75fc64abf65444015438795db32` | `…/RimeSessionManager.h` |
| `dcf414250d5a8a9b4a64d4eaa2aaabd79ddaa03b29511349b4e6404c88aa3121` | `…/RimeSessionManager.m` |
| `ec1e4b1e1a964f91d6004278a11e530c2aa6940c4fe71d246231667ebd7ba015` | `…/RimeEngineImpl+Output.swift` |
| `f5158f334825f6a678a5d9e99e42b6bf9a5ed918f813d376692b2a4a260a18cf` | `…/RimeT9PinyinSelectionSpikeTests.swift` |
| `cc739638284426d28ce2a7ee94e56d6ca5bee6c219254484a1d115779c6eb644` | `…/RimeEngineContractTests.swift` |
| `26092f23cb8c4634372793b727c58f8f05ca944c9fe660a8b9932b216d0d6e87` | `…/RimeComposition.swift` |
| `73b97889f2419989160072de102cf6894b4957da77804222bd293be4557723f5` | `…/RimeOutput.swift` |

### 16.8 Handoff — independent Architecture + Quality

请独立复审 Phase 0.6 仅：

1. 是否同意 `UNRELIABLE_NO_ALLOWED_SLOT_MAP`？  
2. 新增只读字段（caret/compLen/previewLen/highlight）是否可保留为观测契约？  
3. Phase 1 是否仍 No？  
4. 是否建议 Product Lead 进入 Path β 书面收窄 / 继续其它调研 / 降优先级？  

**Forbidden until re-approval:** Phase 1、Human Gate claim、commit/push/PR。

---

## 17. Phase 0.6 Independent Review disposition（KOS 2.0）

**Date:** 2026-07-23 Asia/Shanghai  
**Full record:** [`keyboard-layout-9key-pinyin-004-gate5-phase06-independent-review.md`](keyboard-layout-9key-pinyin-004-gate5-phase06-independent-review.md)  
**Roles:** 🏛️ Architecture + 🧪 Quality  

| Gate | Disposition |
|---|---|
| Phase 0.6 Spike completeness | **Accept / Done** |
| Verdict `UNRELIABLE_NO_ALLOWED_SLOT_MAP` | **Architecture Accept** |
| Path α on pinned t9 public API | **Closed negative**（公开面已穷尽合理观测） |
| Read-only caret/length/previewLen/highlight | **Accept with constraints**（不得作槽位权威；不得接入 reducer） |
| Quality | **Pass**（独立复跑 PASS；hash 一致；无 reducer 耦合） |
| Independent re-run | **TEST SUCCEEDED** — `logs/phase06-independent-review-rerun.log`（含 0.5 回归） |
| Phase 1 | **No / Blocked** |
| Human Product Gate | **Unchanged Fail** |

### Answers to §16.8

1. **Yes** — Accept 否定结论。  
2. **Yes with constraints** — 观测契约可保留。  
3. **Yes** — Phase 1 No。  
4. **Escalate to Product Lead** — β-limited 有限修复 / 收窄 B 验收 / 新调研边界 / γ 降优先级。

---

## 18. Product Lead path decision after Phase 0.6 review

**Date:** 2026-07-23 Asia/Shanghai  
**Role:** Product Lead  
**Decision:** [`PD-…-GATE5-PHASE1-BETA`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md)

| Item | Decision |
|---|---|
| Path α | **Closed** — 不再开公开 librime coverage Spike |
| Path γ | **Still rejected** |
| Phase 1 full B | **Not authorized** |
| Phase 1 β-limited | **Authorized / Ready** — C + shortened remainder + unchanged-raw fail-closed |
| B 验收文案 | **不收窄**；交付后 B 仍预期 Human Fail |
| Executor | Grok 4.5 |
| Human now | **不需要**；β-limited 复审通过后再请真机分项 A/B/C |
| commit / push / PR | **Not authorized** |

---

## 19. Phase 1 β-limited implementation (Grok 4.5 Executor)

**Date:** 2026-07-23 Asia/Shanghai  
**Authority:** [`PD-…-GATE5-PHASE1-BETA`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md)  
**HEAD:** worktree dirty；**未** commit  

### Explicit non-claims

- **No** Human Product Gate pass  
- **No** full B Human contract delivery (device unchanged-raw remains fail-closed)  
- **No** commit / push / PR  
- **No** 用汉字数/comment/sel/caret 猜槽  

### 19.1 What shipped

| Item | Detail |
|---|---|
| `T9CompositionIdentity.swift` | 纯值 append/delete + partial remaining 对齐（shortened only） |
| Partial restore | shortened pure/mixed unique-suffix → Path 重基准；unchanged-raw → fail-closed |
| Checkpoint | 保存 pre-partial source/conf/focus；首 Delete 恢复 |
| Delete resync | 有 confirmed 时 `replaceInput` 回 Core identity，抑制 fan-fan |
| Append retain | 有 confirmed 时 source 推进 + resync |

### 19.2 Test results

```bash
cd Packages/KeyboardCore
swift test --filter "PartialCommit|T9Pinyin|T9Presentation|T9Host|KeyboardLayout|Gate5"
# Executed 145 tests, with 1 test skipped and 0 failures
```

| Area | Result |
|---|---|
| Gate5 Partial (A/B shortened/fail-closed/checkpoint) | **PASS** |
| Gate5 C selected-segment | **PASS** |
| Gate5 C provisional-only mixed continue | **SKIP**（β residual，见测试注释） |
| Directed 145 | **0 failures**, 1 skip |

### 19.3 Product mapping

| Sub-goal | Status |
|---|---|
| A / shortened remainder | **Automated green**（含 mixed shortened「请」→ wei/fan/dao） |
| B device unchanged-raw | **Fail-closed green**（不猜槽） |
| C selected-segment typo/Delete/continue | **Automated green** |
| Full B Human / complete Gate 5 | **Not claimed** |

### 19.4 Hash inventory (β-limited production + Gate5 tests)

| SHA-256 | Path |
|---|---|
| `a90021bfbca2f8fae5e1c6dc69c4dba839ef60125e39ecf8f212518a4bd5d73b` | `T9CompositionIdentity.swift` |
| `d7063dc298b5afad8a60b176953c66a7443603456ae540090224135d6b81f64c` | `KeyboardController+PartialCommit.swift` |
| `d662088dfd953238e16cddf89a89723125ad3dda1f8ce7d3df9495924c5fab5d` | `KeyboardController+T9PinyinPath.swift` |
| `f47bb44056dea0caaa5692535f9e250e5f821daf8a9dd43748e40508edcde5b0` | `KeyboardController+TextEditing.swift` |
| `73866313490edda2c21075e36e24c499f29f66313396e1561ad15546e1edc8ca` | `PartialCommitState.swift` |
| `4e724f5efea265cade2602372b0ed4a33e138370ba8e8232f8eb2298cf8a397a` | `PartialCommitControllerTests.swift` |
| `1c7d9357bca5b05b978f566c0e4d413ffc5f789d75279812d193645a5223042d` | `T9PinyinPathTests.swift` |

### 19.5 Handoff

→ **Independent Architecture + Quality** on β-limited scope only.  
→ Product Lead may then request Human **A/B/C** retest（B 诚实：unchanged-raw 仍可能 Fail）.

---

## 20. Phase 1 β-limited Independent Review disposition

**Date:** 2026-07-23 Asia/Shanghai  
**Full record:** [`keyboard-layout-9key-pinyin-004-gate5-phase1-beta-independent-review.md`](keyboard-layout-9key-pinyin-004-gate5-phase1-beta-independent-review.md)  

| Gate | Disposition |
|---|---|
| Architecture | **Accept with findings**（β-limited 范围；full B 仍 No） |
| Quality | **Pass-with-findings**（独立复跑 145/1 skip/0 fail；§19 identity hash 需更正） |
| Independent re-run | **PASS** — `evidence/…/phase1-beta/logs/phase1-beta-independent-review-rerun.log` |
| Human 分项复测 | **Eligible** — 由 Product Lead 请求；B 预期可能仍 Fail |
| Human Product Gate Pass | **No** |
| commit/push/PR | **No**（本复审不授权） |

### Hash correction (`T9CompositionIdentity.swift`)

| Version | SHA-256 |
|---|---|
| §19 (pre equal-tail fix) | `a90021bfbca2f8fae5e1c6dc69c4dba839ef60125e39ecf8f212518a4bd5d73b` |
| **Current (reviewed)** | `23bc439fa732d74082aea419c68fd71ffb47058f4432d7a7a810eae8a3d0ba1b` |

其余 §19 六文件 hash 与磁盘一致。

---

## 21. Human retest + hotfix (2026-07-23)

### 21.1 Human report (iPhone / 用户)

| Path | Result | Notes |
|---|---|---|
| **A** | **Pass** | 部分候选后后续 Path 正确 |
| **B** | **Pass** | 点「请」后 Path 正常（本构建/场景） |
| **C** | **Fail** | `qingweifa`+JKL+Delete 后续输 → `qingweidaodaowozuili` / 请味道到我嘴里 |
| **Delete stuck** | **Fail (major)** | Path 选 `qing/wei` 后删除到 `qingweie` 时 Delete 无响应 |
| **UI** | **Fail** | 删到只剩 `qing` 时 Path 上 `qing` 呈选中态 |

### 21.2 Hotfix (Executor)

| Fix | Detail |
|---|---|
| `handleT9CompositionIdentityDeleteIfNeeded` | confirmed Path 时 **先** 按 Core `sourceDigits` 剥槽再 resync，避免 RIME 卡在 `qingweie` |
| `handleConfirmedT9FocusDelete` 失败 | 改 `return nil` 下落，**禁止** `return []` 吞 Delete |
| Whole multi-digit refresh | 有 previousConfirmed 时 **不**被 RIME 长串纯数字重切分清空 conf |
| Tests | `testGate5PathSelectQingWeiThenDeletePeelsWithoutStuckSelectedChip`；`testGate5CContinueAfterDeleteKeepsConfirmedWhenRimeResegmentsFullDigits` |

### 21.3 Verification

```bash
swift test --filter "Gate5|UnconfirmedT9Delete|VisibleT9Delete|AppendDelete|WholeUnresolved"
# 0 failures (1 skip provisional-only C)
```

### 21.4 Non-claims

- 未宣称完整 Human Product Gate 通过  
- C 需 **再请真人** 用新构建复测  
- 未 commit/push/PR  

---

## 22. Human retest #2 + hotfix (path bar / qin candidates / C)

### 22.1 Human report

| Item | Result |
|---|---|
| Delete 卡死 | **Pass**（已正常） |
| **C** | **仍 Fail** — `qingweiecoudaowozuil` / 请巍峨凑到我嘴里；用户归因：删后重拼像 `da`+`o` 而非 `dao` |
| Path 选 qing/wei/fan 后 Delete | 剩 **qing** 时 **Path bar 消失**（必现） |
| 再删到 **qin** | Path 正确；候选错误成 瘦/手/首…（纯数字 746 形态） |
| 再删到 **qi** | Path 自动选中 qi；输入/候选正常 |

### 22.2 Hotfix

| Fix | Detail |
|---|---|
| `focusPathPlan` + `installIdentityAsPathState` | remaining 为空时 **重聚焦末音节**，Path bar 不再 `[]` |
| `resyncRimeCompositionFromT9Identity` | 无 confirmed 前缀时用 **provisional 字母 raw**（qin），避免裸 `746`→手/瘦 |
| selectedPath | identity install/resync 后保持 **nil**（不自动选中） |
| C resegment | 仍保留 previousConfirmed 不被长串纯数字冲掉 |

### 22.3 Tests

- 加强 `testGate5PathSelectQingWeiThenDeletePeelsWithoutStuckSelectedChip`（sole qing Path 非空；qin 非纯数字 raw）
- 定向矩阵应保持绿

### 22.4 Please retest (Human)

1. Path 选 qing→wei→fan → 连删：sole **qing** 时 Path bar **仍有** qing/pin/…  
2. 再删到 **qin**：Path 正确且候选 **不是** 手/瘦主导（应贴近 qin/亲）  
3. 再删 **qi**：不要自动选中  
4. **C** 再试 `qingweifa`+JKL+Delete+续输

---

## 23. Human retest #3 + hotfix (qi auto-select / pure-digit return after Delete)

**Date:** 2026-07-23 Asia/Shanghai  
**Executor:** Grok 4.5  

### 23.1 Human report

| Item | Result | Notes |
|---|---|---|
| 1 sole qing Path bar | **Pass** | 正常 |
| 2 qin 候选 | **Pass** | 正常 |
| 3 删到 **qi** 自动选中 | **仍 Fail** | Path chip 仍呈选中态 |
| 4 **C** | **仍 Fail** | `qingweifa`→JKL→Delete→续输仍错；Path 点 `qing/wei` 后 bar 变 `da/ta/e/d/f`、输入栏 `qingweiuil`、候选「请巍峨处理」；用户建议删后重输应回到输入模式 |

### 23.2 Root cause

| Bug | Cause |
|---|---|
| **#3 qi 自动选中** | `rebuildLetterOnlySyllableFocusPaths` 把 letter raw（如 `qi`）当作 preferred/selected；`rebuildSegmentedPathsForMixedRaw` 在 remaining 空时还会用 `lastSyllable` 发明 preferredSelected |
| **#4 错配 + qingweiuil** | (a) 长串无 confirmed 时 `resync` 用首个 provisional 字母 raw（`qing934…`）锁死错形态，续输不像首次纯数字输入；(b) Path 选择展示用 `t9DisplayPreservingUnresolvedSuffix` 只比长度、不校验 T9 编码，错 preedit 尾被拼到 `qingwei` 后成 `qingweiuil` |

### 23.3 Hotfix

| Fix | Detail |
|---|---|
| letter-only rebuild | **仅** remap 用户已有 `previousSelected`；禁止 letter raw / lastSyllable 发明选中 |
| `resync` 无 confirmed | `sourceDigits.count > 3` → **纯数字输入模式**；`≤3` 仍用 provisional 字母（保 qin 候选） |
| engine Delete 后 | 长串 unconfirmed 且 live raw 非纯数字 ledger → 强制 resync 回纯数字；并清 `selectedPath` |
| visible letter Delete | 只清 `selectedPath`，**不**强制纯数字（保留 `to`→`t` 拼写所有权） |
| display suffix | 未解决后缀必须 T9 编码等于 remaining digits；否则 fail-closed / 用合法 RIME 字母 preedit |

### 23.4 Tests

- `testGate5DeleteToQiDoesNotAutoSelectPath`
- `testGate5CAfterDeleteReturnsToPureDigitInputAndPathSelectDropsBadTail`
- 加强 peel 用例对 qi 焦点 `selectedPath == nil`
- 定向矩阵：`Gate5|DeleteToQi|UnconfirmedT9Delete|VisibleT9Delete|AppendDelete|WholeUnresolved` → **21 tests, 1 skip, 0 fail**

### 23.5 Hash inventory (this hotfix)

| SHA-256 | Path |
|---|---|
| `bc3ede898cdba29428a7f87dffc1359ef0a61153be480596a511b10cc995b983` | `KeyboardController+T9PinyinPath.swift` |
| `9043743183bc3a3cd6f5656f2e2d3d13b3e648f9f4401866d50e82e22471c149` | `KeyboardController+TextEditing.swift` |
| `6c0dde4e1132f6114940e6afdacc55b56150c4351c4a09ad63b0c98d554c1b68` | `T9CompositionIdentity.swift` |
| `229b86a505c3c813a5a6cf9ebca46455e22912e701c913cd22465dcf9aee42c4` | `T9PinyinPathTests.swift` |

### 23.6 Non-claims

- **未**宣称完整 Human Product Gate 通过  
- **未** commit / push / PR  
- C 真机仍需 Human 复测；B full 仍诚实 fail-closed  

### 23.7 Please retest (Human)

1. Path 选 qing→wei→fan → 连删到 **qi**：**不要**自动选中 Path chip  
2. **C**：`qingweifa` → JKL → Delete → 再输正确后续；期望接近首次连输（纯数字会话 / Path 可重新匹配）  
3. 若仍错，再 Path 点 `qing`→`wei`：输入栏 **不得** 变成 `qingweiuil`；剩余 focus 可为 `da/fa/…`，但 host 须 digit-safe  

---

## 24. Human retest #4 + hotfix (standalone da parity / no bare qingwei)

**Date:** 2026-07-23 Asia/Shanghai  

### 24.1 Human report

| Item | Result | Notes |
|---|---|---|
| 1 qi 不自动选中 | **Pass** | 正常 |
| 2 **C** / 句中 vs 单焦点 | **仍 Fail** | 单独 `da`+JKL+删+`o`→`dao` 正常；句中不行。用户问能否与单焦点一致及风险 |
| 3 Path 选 qing/wei 后输入栏 | **Fail** | 仅剩 `qingwei`，后续被抛弃（上轮 fail-closed 过严） |

### 24.2 Product / risk answer (standalone parity)

| 策略 | 行为 | 风险 |
|---|---|---|
| **A. 整句强制纯数字** | 与「从未选 Path 的首次输入」一致 | 长串 librime 重切分（fan fan）仍可能差 |
| **B. 剩余 focus 与单焦点一致（采用）** | Path 已确认前缀锁定；**当前 remaining 槽** append/Delete/续输按 Core ledger 更新；仅当 remaining 被**唯一**完整音节覆盖时字母 refine（如 `32`→`da`）；多候选（`326`→dan/dao/fan）保持 **confirmed'+纯数字** | **不做** partial cover（曾试 `9698454`→`wo'+98454` 会发明切分，已回滚） |
| **C. remaining 任意 partial 字母化** | 更像「每段都选过」 | **高风险**：错切分、丢槽、与用户未选 Path 意图冲突 |

结论：**在句中对「当前剩余 focus」对齐单焦点 da 的 ledger/续输语义是合理且应做的**；整句盲字母化或 partial cover **不**做。

### 24.3 Hotfix

| Fix | Detail |
|---|---|
| display after Path select | 错误 preedit 尾仍拒绝；**不再** fail-closed 到裸 `qingwei`；用 RIME/comment/catalog **重投影 remaining** |
| `refinedConfirmedPlusRemainingRaw` | 仅 **唯一 full-cover** 完整音节 → 字母；否则 `conf'+digits`；**禁止** partial |
| `T9PreeditResolver.projectCommentLetters` | 供 remaining 尾投影 |
| Tests | 加强 #3 字母数=source；`testGate5InSentenceDaTypoDeleteContinueMatchesStandalone` |

### 24.4 Verification

```text
Gate5|UnconfirmedT9Delete|VisibleT9Delete|AppendDelete|WholeUnresolved|InSentenceDa
→ 22 tests, 1 skip, 0 fail
```

### 24.5 Non-claims

- 未宣称 Human Product Gate 全过  
- 未 commit/push/PR  
- 无 Path 确认的整句纯数字 C 仍依赖 librime 长串质量（与单焦点短串不同引擎面）

### 24.6 Please retest (Human)

1. 单独：`da` → JKL → Delete → `o` → 仍应为 `dao`  
2. 句中：Path 选 `qing/wei/fan` 后 remaining 在 `da` 上 → JKL → Delete → `o` → remaining 成 `dao` 槽，confirmed 保持  
3. Path 只选 `qing/wei`：输入栏须 **qingwei + 后续字母**（长度≈数字槽），不得只剩 `qingwei`，不得 `qingweiuil`  
4. **C** 无 Path：`qingweifa`+JKL+Delete+续输再看是否接近首次  

---

## 25. Human retest #5 — ghost JKL `5` / `qingweifanfal`

**Date:** 2026-07-23 Asia/Shanghai  

### 25.1 Human report (decoded)

| Observation | Encoding / meaning |
|---|---|
| 输入 `qingweifanda` → JKL → Delete → MNO 后输入栏 `qingweifanfan` | `…fan` 重切分；digit 面可能是 prefix+`6` |
| Path 选 qing/wei/fan 后 bar=`fa/da/e/d/f`，输入栏 `qingweifanfal` | **`fal` T9 编码 = `325`** → **错字键 `5` 仍在 Core ledger** |
| 一口气输完再选 Path 不丢尾 | 无 Delete 时 ledger 与按键一致 |
| 中途 Delete 再输再选 Path 丢尾 | Delete 未以 `sourceDigits` 为 SoT，幽灵槽污染后续 Path 投影 |

### 25.2 Root cause

- 无 confirmed 的长串 progressive：Delete 走 **可见字母剥除 / engine.delete**，**不保证**剥掉 Core `segmentSourceDigits` 最后一位。
- 随后 MNO 与 Path 选择在「仍含幽灵 `5`」的 ledger 上工作 → remaining `325` → bar 像二槽 `fa/da` + 展示 `…fal`。

### 25.3 Hotfix

| Change | Rule |
|---|---|
| conf 空 + `sourceDigits.count > 3` | **Append / Delete 均以 Core ledger 增删一位**，再 resync |
| conf 空 + `≤3` | 仍走原 visible letter delete（保 `to`→`t`） |
| conf 非空 | 原 identity peel 不变 |
| Test | `testHumanQingweifandaTypoJKLDeleteMNONoGhostFive` |

### 25.4 Verification

`23 tests, 1 skip, 0 fail`（Gate5 定向矩阵含 Human ghost-5）

### 25.5 人测步骤（请严格按序，只测这一条主路径）

**前置：** 九键拼音 · 中文 · 空输入框 · 新构建。

#### 用例 H5-A（主路径，必测）

1. **不要点 Path**，连续按键输入「请喂饭到」的拼音槽：`qing weifan da`  
   - 等价九键数字串：`7-4-6-4-9-3-4-3-2-6-3-2`（`qingweifanda`）  
2. **故意**按一次 **JKL（5）**  
3. 按一次 **删除**  
4. 按一次 **MNO（6）**（正确补 `o`，使末音节倾向 `dao`）  
5. **观察（此时还未点 Path）**  
   - 输入栏：任意拼音形态均可，但 **不应** 再需要靠「多删一次」才能消掉错键感  
6. 在 Path bar **依次点**：`qing` → `wei` → `fan`  
7. **期望（Pass 标准）**  
   - Path bar 出现 **三槽** 候选族：至少含 `dao` / `dan` / `fan` 之一（常见：`fan/dao/dan/da/…`）  
   - **不要**只剩二槽 `fa/da/e/d/f`  
   - 输入栏 **不要** 以 `fal` 结尾，**不要**出现「明明删过的 JKL 又变成 `l`」  
   - 输入栏字母总长度应 = 数字总槽（`qingweifanda` + 1 位 MNO = 13 个字母位）

#### 用例 H5-B（对照，可选）

1. **一口气**输入完整 `qingweifandaowozuili`（中途不 Delete）  
2. Path 依次 `qing`→`wei`→`fan`→…  
3. **期望：** 后续字母 **不丢弃**（与你描述的「一口气就正常」一致，作对照）

#### 用例 H5-C（回归，可选）

1. 单独短输入：`da` → JKL → Delete → MNO → 仍应为 `dao`  
2. 删到 `qi`：Path **不要**自动选中  

### 25.6 Non-claims

- 未宣称完整 Human Gate Pass  
- 未 commit / push / PR  

---

## 26. Human retest #6 — H5-C short `da` Path bar desync

**Date:** 2026-07-23 Asia/Shanghai  

### 26.1 Human report

| Case | Result |
|---|---|
| H5-A | **Pass** |
| H5-B | **Pass** |
| H5-C | **Fail** — 单独 `da→JKL→删→MNO`：输入栏 `dao`、候选「到/但/刀…」正常，但 Path bar 仍 `ba/ta/e/d/f`（二槽/错焦点），与 3 槽 `326` 不一致 |

### 26.2 Root cause

- H5-A 只把 Core ledger SoT 扩到 **>3 位**长串；短串 `da`(2→3 位) 仍走旧 append/delete，RIME 可到 `dao` 而 Path `segmentSourceDigits` 停在 2 槽。

### 26.3 Hotfix

| Change | Detail |
|---|---|
| conf 空 + multi-digit (`count > 1`) | Append/Delete **一律** Core ledger ±1 再 resync（含 short `da`/`dao`） |
| `shortUnconfirmedResyncRaw` | 优先全覆盖 complete 字母（qin/to/dao）；避免 `t6`；Path 仍绑完整 `sourceDigits` |
| Test | `testHumanStandaloneDaTypoDeleteMNOPathBarTracksFullLedger` |

### 26.4 Verification

24 tests / 1 skip / 0 fail（Gate5 定向矩阵）

### 26.5 请只复测 H5-C（其余 A/B 已过不必重跑）

1. 清空输入  
2. 九键只输入：**`da` → JKL → 删除 → MNO**  
3. **期望（Pass）**  
   - 输入栏：`dao`（或等价字母，无数字泄漏）  
   - 候选：到/但/刀… 类  
   - Path bar：**三槽**相关（至少含 `dao` / `dan` / `fan` 之一），**不要**只剩 `da/fa/e/d/f` 或 `ba/ta/e/d/f` 这类二槽条  

### 26.6 Human H5-C result

| Item | Result |
|---|---|
| H5-C | **Pass** — Path bar `dao/dan/fan/da/fa/e/d/f`（Human 2026-07-23） |

---

## 27. Post-β residual freeze (KOS 2.0 — Executor evidence closeout)

**Date:** 2026-07-23 Asia/Shanghai  
**Role:** Executor (Grok 4.5)  
**KOS step:** Human residual confirmed → freeze Evidence → hand off independent Architecture + Quality  

### 27.1 Human residual matrix (final)

| ID | Scenario | Human result |
|---|---|---|
| H5-A | `qingweifanda` → JKL → Delete → MNO → Path `qing/wei/fan` | **Pass** |
| H5-B | 一口气 `qingweifandaowozuili` 再选 Path | **Pass** |
| H5-C | 单独 `da` → JKL → Delete → MNO；Path `dao/dan/fan/da/fa/e/d/f` | **Pass** |

### 27.2 Automated freeze

```text
swift test --filter 'Gate5|HumanStandalone|HumanQingweifanda|UnconfirmedT9Delete|VisibleT9Delete|AppendDelete|WholeUnresolved|InSentenceDa|DeleteToQi|PartialCommit'
→ 68 tests, 1 skip, 0 fail
```

### 27.3 Hash inventory (freeze)

| SHA-256 | Path |
|---|---|
| `6c0dde4e1132f6114940e6afdacc55b56150c4351c4a09ad63b0c98d554c1b68` | `T9CompositionIdentity.swift` |
| `8415f5ef22b6c8f78dc59fdabf6457b192b6aabd1f6fd91ae1d9b92c26535a5d` | `KeyboardController+T9PinyinPath.swift` |
| `9043743183bc3a3cd6f5656f2e2d3d13b3e648f9f4401866d50e82e22471c149` | `KeyboardController+TextEditing.swift` |
| `9e53ceede57c292d30a05269bb90b031285519c879120631d17a0539e26f51be` | `KeyboardController+PartialCommit.swift` |
| `a635a4eef710afcaaae0bf8832305041e9167663d6227e014605e894af79a545` | `T9PreeditResolver.swift` |
| `8097660e02d319ae0e2783281488fbbb5f5df01e94d4a3c3c97935e60e740350` | `T9PinyinPathTests.swift` |
| `4e724f5efea265cade2602372b0ed4a33e138370ba8e8232f8eb2298cf8a397a` | `PartialCommitControllerTests.swift` |

### 27.4 Handoff package

→ [`keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-review-handoff.md`](keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-review-handoff.md)

### 27.5 Non-claims (mandatory)

- **Not** full 004 Human Product Gate Pass  
- **Not** full B engine-native unchanged-raw coverage  
- **Not** commit / push / PR  
- Independent review **not** performed in this Executor turn  

### 27.6 Independent review disposition (append)

**Record:** [`keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-independent-review.md`](keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-independent-review.md)

| Gate | Disposition |
|---|---|
| Architecture | **Accept with findings** |
| Quality | **Pass-with-findings** |
| Independent re-run | **68 / 1 skip / 0 fail** |
| Hash §27.3 | **Match** |
| Full Human Gate / B / commit | **Not authorized** |

---
### 27.7 Product disposition (append)

**PD:** [`PD-…-GATE5-POST-BETA-RESIDUAL`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-post-beta-residual-disposition.md)

| Decision | Value |
|---|---|
| H5 residual | **Product-accepted** (narrow residual Pass) |
| Local commit + push | **Authorized** |
| Full 004 Human Gate / auto-merge | **Not claimed / not authorized** |

---

## 28. Residual-B Path-ledger peel (Executor implementation)

**Date:** 2026-07-23 Asia/Shanghai  
**Role:** Executor (Grok 4.5)  
**Authority:** Human Product Owner in-session — residual-B still fails on device; process remaining debt under KOS 2.0.  
**PD:** [`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md)

### 28.1 Root cause (bound)

| Observation | Authority used |
|---|---|
| Device B: select「请」leaves RIME raw unchanged | Phase 0.5 / device calibration |
| Path empty after partial | β fail-closed on engine-only |
| User already Path-selected `qing/wei/fan/dao` | Core Path ledger SoT |

**Decision:** peel **first Path-confirmed syllable** when single-CJK + unchanged-raw; resync RIME to remaining identity. Forbidden signals still unused.

### 28.2 Code surface

| File | Change |
|---|---|
| `T9CompositionIdentity.swift` | `afterPathLedgerPeel` + public `digitEncoding(ofMixedRaw:)` |
| `KeyboardController+PartialCommit.swift` | unchanged-raw branch → Path peel + resync + remaining refresh |
| `PartialCommitControllerTests.swift` | device-B expects peel success |
| `T9CompositionIdentityTests.swift` | pure peel / fail-closed contracts |

### 28.3 Automated verification

```text
swift test --filter 'T9CompositionIdentity|Gate5B|Gate5A|Gate5Partial|QingCandidate|QingWeiFanDao'
→ 16 tests, 0 fail

swift test   # Packages/KeyboardCore
→ 708 tests, 1 skip (provisional-only C), 0 fail
```

### 28.4 Hash inventory (residual-B implementation freeze)

| SHA-256 | Path |
|---|---|
| `9e0d9df68e2d726d6e8e4a9a2e229031d0f6c014c1b1dc8ada38e3de2a59e4ed` | `T9CompositionIdentity.swift` |
| `61df934feab18174bc456d12aef5ceffe68b6f12c59775fed9070f1ae6ded4b5` | `KeyboardController+PartialCommit.swift` |
| `be77685d66e1a4f78d151caf0347485d8ee0570b2ae18f8e88b432553b7695df` | `PartialCommitControllerTests.swift` |
| `75bf9186039e9bf72247d11f7f5de3359685fa6b57f104193d4a0d44ffbb20d6` | `T9CompositionIdentityTests.swift` |

### 28.5 Non-claims

- **Not** Human residual-B Pass until device retest  
- **Not** full 004 Human Product Gate Pass  
- **Not** multi-char peel / invent-slot from 汉字数  
- provisional-only C `XCTSkip` still parked  

### 28.6 Next KOS step

1. Feature branch commit + push + open PR (merge = Human).  
2. Human residual-B retest script (see PD).  
3. Independent Architecture/Quality review of residual-B before claiming product Pass.

---

## 29. Residual-B Path-ledger **cursor** (product-confirmed model)

**Date:** 2026-07-23 Asia/Shanghai  
**Role:** Executor (Grok 4.5)  
**Authority:** Human Product Owner confirmed Path cursor model (单字/多字同一原理；soft-select 仅用户曾点选音节；`wo` 不伪造选中). **No PR** until device retest OK.

### 29.1 Model freeze

| Rule | Value |
|---|---|
| K | `min(CJK count, remaining user Path stack)` — step only |
| Digit peel | Sum of peeled syllables’ widths (slots follow syllables) |
| Next focus | First remaining user-stack syllable + soft-select if user chose it |
| Stack empty | Unselected tail (`wo…`) |
| Trigger | Multi-syllable user stack **or** unchanged-raw (preserve `qiu→球` nested pure-digit) |

### 29.2 Automated verification

```text
swift test  # Packages/KeyboardCore
→ 712 tests, 1 skip, 0 fail
```

Gate5 B captures: after「请」`paths=["wei","zei","ye",…] selected=wei`.

### 29.3 Non-claims (pre-device; superseded by §30)

- (historical) Not Human residual-B Pass until device  
- (historical) Not PR / merge until device OK  

---

## 30. Human residual-B device Pass + land PR #28

**Date:** 2026-07-23 Asia/Shanghai  
**Role:** Product Lead / Executor  
**Authority:** Human Product Owner in-session — residual-B 真机「完全没问题」；处理后续 merge / 文档 / 分支清理。

### 30.1 Human residual-B matrix

| ID | Scenario | Result |
|---|---|---|
| RB-1 | Path `qing/wei/fan/dao` →「请」→ Path `wei…` soft-select | **Pass** |
| RB-2 | 多字/游标推进与 `wo` 无选中 | **Pass**（Human overall） |
| RB-3 | 无内部数字 / 既有功能未破坏 | **Pass**（Human overall） |

### 30.2 Automation (pre-merge freeze)

```text
swift test  # Packages/KeyboardCore @ e3d23cd
→ 712 tests, 1 skip, 0 fail
CI Swift 6 Quality build-and-test: SUCCESS (PR #28)
```

### 30.3 Disposition

| Item | Status |
|---|---|
| Residual-B product debt | **Closed** (device Pass + automation) |
| PR #28 merge | **Authorized** |
| Full 004 Assignment Closed | **Not automatic** — provisional-only C SKIP / formal full Gate optional Product decision |
| Non-claim | Not invent-slot; not full App Store ship |
