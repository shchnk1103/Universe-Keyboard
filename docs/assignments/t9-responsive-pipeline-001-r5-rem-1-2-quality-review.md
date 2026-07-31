# Quality Review: R5-Rem-1 + R5-Rem-2 (felt metrics + UI latest-only / dual-gate coalesce)

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（**independent** reviewer） |
| Date | 2026-07-31 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Design freeze | [`t9-responsive-pipeline-001-r5-remediation-design.md`](t9-responsive-pipeline-001-r5-remediation-design.md) |
| Product authority | Rem-1 + Rem-2 only（Human Product Owner；**no** Rem-3 / default-on / ADR Accept / Product Gate） |
| Executor evidence | [`../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md) |
| Predecessor | Formal R5 direction **FAIL** [`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md)；baseline tip `87d3e7c` |
| Scope | **R5-Rem-1** (O1 content-free felt metrics + tests) + **R5-Rem-2** (O2 UI latest-only / dual-gate presentation coalesce / R3 context → applied head) |
| Worktree tip at review | parent tip `87d3e7c9b6e3a4cb1bb4242a02679a667ba3aeb7`（R5-Preflight）；Rem-1/Rem-2 产物 **dirty / uncommitted**（见 § Worktree honesty） |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 0**  
**P2: 2**（immutable SHA 未绑定；dual-gate catch-up 在 `pendingDepth==0` 时的 paint 收敛未单测证明）  
**P3: 4**（evidence gitignore；shared tracker 未 session-reset；content-free 断言偏弱；async settle 时序）

---

## Scope

Independent Quality review of Executor R5-Rem-1 + R5-Rem-2 delivery against:

1. Remediation design **O1 / O2** + D3 marker contract + D5 policy freezes  
2. Product authorization boundary（**only** Rem-1 + Rem-2；**not** Rem-3 provisional L1）  
3. Playbook evidence honesty（**re-run**, not trust Executor counts alone）  
4. Explicit non-claims（no Formal R5 rewrite / device re-pair Pass / ADR Accept / Product Gate / Release default-on）

This review **re-ran** KeyboardCore focused and full suites. It did **not** accept Executor green as sole authority.

**Not in scope for this review:**

- Rem-3 provisional L1  
- Formal R5 FAIL rewrite or device A/B re-pair（Rem-Device）  
- Architecture Pass / ADR 0025 Accept  
- Product Gate / Release default-on  
- Numeric product SLO lock  

---

## Commands re-run (authoritative for this review)

Environment:

| Item | Value |
|---|---|
| Host | macOS 27.0 (Build 26A5388g), arm64 |
| Swift | Apple Swift 6.4 (`swift-driver` 1.168.5) |
| Module cache | `SWIFTPM_MODULECACHE_OVERRIDE=/tmp/uk-q-rem-swift`；`CLANG_MODULE_CACHE_PATH=/tmp/uk-q-rem-clang` |
| Wall clock | 2026-07-31 ~13:32–13:35 CST |
| Parent tip | `87d3e7c9b6e3a4cb1bb4242a02679a667ba3aeb7` |

### 1) KeyboardCore focused (felt + wire + R2 + pipeline)

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard"
export SWIFTPM_MODULECACHE_OVERRIDE=/tmp/uk-q-rem-swift
export CLANG_MODULE_CACHE_PATH=/tmp/uk-q-rem-clang
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveRimeFeltMetricsTests|ThreadAffineRimeWireTests|ResponsiveRimeR2CoordinatorTests|ResponsiveRimePipelineTests'
```

| Suite | Executed | Failures | Notes |
|---|---:|---:|---|
| `ResponsiveRimeFeltMetricsTests` | **3** | **0** | lag / content-free lines / tracker+burst |
| `ResponsiveRimePipelineTests` | **23** | **0** | FIFO + latestOnly pipeline |
| `ResponsiveRimeR2CoordinatorTests` | **16** | **0** | includes `testLatestOnlyPublishCountIsBelowKeyCountUnderBurst` |
| `ThreadAffineRimeWireTests` | **6** | **0** | includes `testDualGateCoalescesPresentationUnderOwnerBacklog` |
| **Selected tests total** | **48** | **0** | |

```text
Test Suite 'Selected tests' passed
Executed 48 tests, with 0 failures (0 unexpected) in 1.069 (1.090) seconds
```

### 2) KeyboardCore full package

```bash
export SWIFTPM_MODULECACHE_OVERRIDE=/tmp/uk-q-rem-swift
export CLANG_MODULE_CACHE_PATH=/tmp/uk-q-rem-clang
swift test --package-path Packages/KeyboardCore
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **841** | **0** |

```text
Test Suite 'KeyboardCoreTests.xctest' passed
Executed 841 tests, with 0 failures (0 unexpected) in 4.794 (4.883) seconds
Test Suite 'All tests' passed
Executed 841 tests, with 0 failures (0 unexpected) in 4.794 (4.884) seconds
```

Matches Executor arithmetic（**48** focused / **841** full）。**Evidence honesty: confirmed.**  
（Preflight Quality full 为 836；+5 量级与 Rem-1/2 新增测例及中间增量一致，以本机 **841** 为准。）

---

## Evidence matrix vs design O1 / O2

| Case | Requirement | Independent result |
|---|---|---|
| **O1 D3 ACCEPT** | content-free accept marker + lag bookkeeping | **Held** — `ResponsiveRimeFeltMetrics.acceptMarkerLine`；`recordResponsiveAcceptMetrics` on dual-gate + MainActor R2 insert paths |
| **O1 D3 VISIBLE / PUBLISH lag** | accept→visible / publish lagMs + pendingAfter + coalesced | **Held** — tracker + `performResponsivePresentationApply` logs `PUBLISH lagMs` / `VISIBLE source=engine` / optional `BURST` |
| **O1 unit tests** | lag computation + coalesce/burst counters | **Held** — 3/0 `ResponsiveRimeFeltMetricsTests` |
| **O1 no UX claim** | observability only for Rem-1 | **Held** — Rem-1 surface is markers + tests |
| **O2 MainActor latestOnly** | stop forcing `.everyResult` for R3 1:1 paints | **Held** — `rebuildResponsiveRimeCoordinatorIfNeeded` now passes `publishPolicy` through（removed `latestOnly → everyResult` force） |
| **O2 dual-gate UI coalesce** | pending ≥ `presentationCoalescePendingThreshold`（default **2**）→ latest presentation | **Held structurally** — `applyResponsivePublishedSnapshot` + `scheduleDualGateCoalescedPresentation`；threshold named constant, not SLO |
| **O2 R3 context head** | contexts bind to **applied head** / last pk context, not every paint | **Held** — `performResponsivePresentationApply` drains same-epoch pk contexts and keeps **last** |
| **O2 engine FIFO** | no drop/reorder of session actions | **Held** — coalesce is presentation-only；pipeline / wire suites still green；design residual explicit |
| **O2 paint ≪ keyCount** | Fake burst: UI paint count &lt; key count | **Held in unit tests** — dual-gate: `paintCount < 5` for 5 keys；R2 latestOnly: `paintCount < 5` for 5 keys；both assert `paintCount >= 1` |
| **D5 gates default off** | dual-gate / responsive remain default **false** | **Held** — `isResponsiveRimePipelineEnabled = false`；`isThreadAffineRimeOwnerEnabled = false`；`testDualGatesDefaultOff` / R2 gate-default tests still pass |
| **D5 no Rem-3** | no provisional L1 | **Held** — `VISIBLE source=provisional` exists in enum only；no L1 product path in this knife |
| **D5 Formal R5** | FAIL not rewritten | **Held** — no new device A/B；evidence non-claims explicit |
| **Content-free markers** | no pinyin / candidates / host text in marker builders | **Held** — pure builders take only rev/epoch/pending/lagMs/coalesced/count；call sites do not feed raw keys into marker strings |
| **No `@unchecked Sendable`** | isolation without bypass | **Held** — Rem-1/2 surfaces scanned：**0** |
| **Full suite green** | KeyboardCore all tests | **Held** — **841 / 0** |
| **Executor count honesty** | evidence 48 / 841 | **Held** — independent re-run matches |

### O2 residual (not O2 fail of this knife)

Design O2 wants catch-up to prefer **one** latest paint under lag. Dual-gate implementation gates coalesce on `pendingWorkDepth ≥ 2` **or** an already-buffered/scheduled presentation. Unit proof is **blocked-owner backlog** (`testDualGateCoalescesPresentationUnderOwnerBacklog`), not a pure post-drain MainActor notification flood with `pendingDepth == 0` for every delivery. Formal R5 storm shape may still need device `BURST` / `PUBLISH lagMs` scoring（Rem-Device）— see P2.

---

## Isolation / gate / marker scans

### Gate defaults (production)

| Flag | Default | Force-enable in Rem-1/2 knife |
|---|---|---|
| `isResponsiveRimePipelineEnabled` | `false` | **No** product default-on；tests only |
| `isThreadAffineRimeOwnerEnabled` | `false` | **No** product default-on；tests / preflight arm path only |
| `presentationCoalescePendingThreshold` | `2` | Named constant；**not** an SLO |

### Content-free marker grammar (code-backed)

```text
T9RESP marker=ACCEPT action=k rev=… pending=… epoch=… fixture=T9RESP-R5P
T9RESP marker=VISIBLE lagMs=… rev=… source=engine|provisional fixture=T9RESP-R5P
T9RESP marker=PUBLISH lagMs=… rev=… pendingAfter=… coalesced=0|1 fixture=T9RESP-R5P
T9RESP marker=BURST count=… windowMs=… fixture=T9RESP-R5P
```

Pure builders never accept composition / candidate / host-text parameters. Preflight `PATH` / epoch-rev `PUBLISH` lines retained on dual-gate apply path.

### Coalesce assertions (tests actually assert paintCount &lt; keyCount)

| Test | Assertion |
|---|---|
| `ThreadAffineRimeWireTests.testDualGateCoalescesPresentationUnderOwnerBacklog` | `paintCount < 5` for 5 keys；`paintCount >= 1` |
| `ResponsiveRimeR2CoordinatorTests.testLatestOnlyPublishCountIsBelowKeyCountUnderBurst` | `paintCount < 5` for 5 keys；`paintCount >= 1` |
| `ResponsiveRimeR2CoordinatorTests.testMultiKeyDrainDoesNotStealContextsViaNestedReplace` | `publishCount <= 2` under latestOnly multi-key |

### `@unchecked Sendable` / `nonisolated(unsafe)`

| Surface | Hits |
|---|---|
| `ResponsiveRimeFeltMetrics.swift` | **0** |
| `ResponsiveRimeFeltMetricsTests.swift` | **0** |
| `KeyboardController.swift` Rem-1/2 delta | **0** |
| `KeyboardController+RimeRecovery.swift` accept metrics | **0** |
| Wire / R2 test deltas | **0** |

---

## Artifacts reviewed

| Artifact | Path |
|---|---|
| Felt metrics | `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimeFeltMetrics.swift` |
| Felt tests | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimeFeltMetricsTests.swift` |
| Presentation coalesce + R3 head | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` |
| ACCEPT call sites | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift` |
| Dual-gate coalesce test | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeWireTests.swift` |
| R2 latestOnly paint test | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimeR2CoordinatorTests.swift` |
| Design | `docs/assignments/t9-responsive-pipeline-001-r5-remediation-design.md` |
| Executor evidence | `docs/evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md` |
| Formal R5 FAIL | `docs/evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md` |

---

## Residuals

### P2 — Worktree honesty（no immutable Rem-1/2 SHA）

At review time:

- Parent tip: `87d3e7c`（**R5-Preflight** feat commit；非 Rem-1/2 实现冻结）  
- Rem-1/2 实现 **dirty / untracked**（至少）:
  - `M` `KeyboardController.swift`、`KeyboardController+RimeRecovery.swift`、R2/wire tests  
  - `??` `ResponsiveRimeFeltMetrics.swift`、`ResponsiveRimeFeltMetricsTests.swift`、remediation design  
  - Executor evidence 文件存在，但根 `.gitignore` 的 `evidence/` 规则使 **新建** `docs/evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md` **被 ignore**（`git check-ignore` 确认）

**Condition:** Product / Executor 必须创建 **clean immutable Rem-1/2 checkpoint SHA**，并将 Arch+Quality 绑定到该 SHA 后，才可将本 knife 视为可交接关闭。若树在本 review 后改变 O1/O2 语义，本 Pass **作废** 并需 re-review。

### P2 — Dual-gate catch-up with `pendingDepth == 0` not unit-proved

Coalesce is proven under **owner backlog** (`pendingWorkDepth ≥ 2` or buffered presentation). A pure post-drain MainActor notification flood（every delivery sees `pendingDepth == 0` and no buffer yet）is **not** covered by a dedicated test. Formal R5’s “many PUBLISH in &lt;50 ms after stall” remains a **device measurement** problem for Rem-Device（use `BURST` / paint counts / subjective），not claimed fixed by this review.

### P3 — Shared `ResponsiveRimeFeltMetricsTracker.shared` never reset on rebuild/abandon

Accept map / paint window can carry across sessions unless external reset. Lag lines remain content-free； measurement correctness across epoch barriers may be soft. Optional: reset on `clearResponsiveKeyApplyContexts` / rebuild / epoch bump.

### P3 — Content-free unit assertions are structural, not adversarial

`testMarkerLinesAreContentFree` checks markers do not contain `"ni"` / `"你"` but builders never receive those strings. Structural content-free (no composition parameters) is held；adversarial leakage via fixture strings is low risk.

### P3 — Coalesce tests use short async settle windows

Dual-gate test uses `Task.yield` + `0.15 s` settle；R2 burst uses `0.2 s`. Passed this re-run（not observed flaky here）. Note only.

### P3 — Evidence path gitignored by default

Same class as Preflight residual: new files under `docs/evidence/` need `git add -f` or ignore-policy change if they must be versioned.

### Carry-forward（not Rem-1/2 fail reopen）

- Formal R5 direction **FAIL** stands  
- Rem-3 provisional L1 **not** implemented — long owner stalls may still feel empty until first L2 paint  
- ADR 0025 remains **Proposed**  
- R4-Wire QoS residual unchanged  
- Path/auto-anchor under multi-key latestOnly uses **last** context only（intentional Rem-2）  

---

## Explicit non-claims（Quality will not endorse）

This review **does not** claim, authorize, or partially satisfy:

1. Formal R5 FAIL rewritten as Pass / success  
2. Device Rem-Device A/B re-pair Pass or subjective non-stutter  
3. ADR 0025 **Accept**  
4. Product Gate / Release default-on / user-facing dual-gate settings  
5. Rem-3 provisional L1 progressive composition  
6. Numeric product SLO for lag / coalesce threshold  
7. “librime is faster” or KEY END-only dual-gate comfort  
8. Architecture Pass of remediation design implementation beyond this Quality scope  
9. Dirty-tree review equals immutable SHA-bound close  
10. Multi-device generality / jetsam / mailbox product SLOs  

R5-Rem-1 + R5-Rem-2 only prove（on independent re-run）:

- content-free felt markers + lag helpers + unit tests  
- MainActor R2 honors `.latestOnly` for UI publish（no force-`everyResult`）  
- dual-gate presentation coalesce under owner backlog + R3 last-context head  
- coalesce tests assert **paintCount &lt; keyCount**  
- dual-gate defaults remain **off**  
- KeyboardCore **48/0** focused and **841/0** full  

---

## Verdict

### **Pass with conditions**

Authorized Rem-1 + Rem-2 intent is **met** on independently re-run evidence:

- Focused (felt + wire + R2 + pipeline): **48/0**  
- KeyboardCore full: **841/0**  
- Executor evidence counts **match** independent re-run（honesty confirmed）  
- O1 D3 markers present and content-free by construction  
- O2 latestOnly + dual-gate coalesce + R3 applied-head contexts present and unit-backed  
- Gates remain default-off  
- No `@unchecked Sendable`  
- No Rem-3 / default-on / ADR Accept / Product Gate in delivery  

### Conditions (must hold for this Pass to remain valid)

1. **No over-claim:** 本 Pass **不得** 被用作 Formal R5 改判、device Rem-Device Pass、ADR Accept、Product Gate、Release default-on、Rem-3 完成或 subjective non-stutter 证据。  
2. **Immutable SHA bind:** Executor/Product 应提交 Rem-1/2 knife 并绑定 Arch+Quality 到 clean SHA；提交后语义变更需 re-review。  
3. **Gates remain default-off** 于普通 DEBUG/Release 工程配置，直至新的 Product knife。  
4. **Device residual explicit:** 长 owner stall 空白感（无 L1）与 catch-up `BURST` 形状留给 **Rem-Device**；threshold `2` 不是 SLO。  
5. **Formal R5 FAIL remains closed as FAIL** — remediation is a successor knife, not a rewrite.

### Stop / escalate if

- Release 默认或 user-facing settings 打开 dual-gate  
- Rem-3 / provisional L1 被 silent 塞进本 knife 并 claim 完成  
- Swift 6 isolation 用 `@unchecked Sendable` / `nonisolated(unsafe)`「修好」  
- Engine session actions 被 drop/reorder 以“追赶”  
- `T9RESP` 日志出现 raw key / pinyin / candidates / host text  
- dirty-tree 语义在 re-review 前被当作 Formal R5 或 Product Gate 已通过  
- 将本 Pass 表述为 device 体感已验证  

---

## Residual for Rem-Device（not authorized here）

| Item | Why still open |
|---|---|
| Human A/B dual-gate vs gate-off | Unit paint coalesce ≠ felt non-freeze |
| Score `accept→visible` / `PUBLISH lagMs` / `BURST` | Formal R5 taught KEY END alone is invalid on dual-gate |
| Blank freeze without L1 | Rem-3 still optional if coalesced paints still feel empty |
| Path/auto-anchor multi-key latestOnly on device | Last-context-only intentional; device parity not re-proved |
| Immutable install hashes | Need Rem-1/2 tip SHA + arm binaries if re-pair runs |

---

## Handoff

| To | Payload |
|---|---|
| 🧭 Product | Verdict **Pass with conditions**；Rem-1+2 unit/tooling held；**not** Gate / device / ADR；next auth unit likely Rem-Device and/or Rem-3 |
| 🏛️ Architecture | O1/O2 实现与 freeze 对齐；dual-gate coalesce 依赖 pending/buffer；post-drain flood 未单测证明 → Rem-Device 观察 `BURST` |
| 🔧 Executor | 创建 immutable Rem-1/2 SHA；`git add -f` evidence（若需入库）；可选 P3 tracker reset / stronger content-free tests |
| 🧪 (self) | Review artifact: this file |

---

## Appendix — machine lines (independent)

```text
# Focused
Test Suite 'ResponsiveRimeFeltMetricsTests' passed
Executed 3 tests, with 0 failures (0 unexpected)
Test Suite 'ResponsiveRimePipelineTests' passed
Executed 23 tests, with 0 failures (0 unexpected)
Test Suite 'ResponsiveRimeR2CoordinatorTests' passed
Executed 16 tests, with 0 failures (0 unexpected)
Test Suite 'ThreadAffineRimeWireTests' passed
Executed 6 tests, with 0 failures (0 unexpected)
Test Suite 'Selected tests' passed
Executed 48 tests, with 0 failures (0 unexpected) in 1.069 (1.090) seconds

# Full
Test Suite 'KeyboardCoreTests.xctest' passed
Executed 841 tests, with 0 failures (0 unexpected) in 4.794 (4.883) seconds
Test Suite 'All tests' passed
Executed 841 tests, with 0 failures (0 unexpected) in 4.794 (4.884) seconds
```

## Appendix — Executor vs independent

| Suite | Executor claim | Independent re-run |
|---|---:|---:|
| Focused filter | 48 / 0 | **48 / 0** |
| KeyboardCore full | 841 / 0 | **841 / 0** |

**Honesty: match.**
