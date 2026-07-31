# Quality Review: R4-Owner (thread-affine owner contract D1–D3)

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（**independent** reviewer） |
| Date | 2026-07-31 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Design freeze | [`t9-responsive-pipeline-001-r4-owner-design.md`](t9-responsive-pipeline-001-r4-owner-design.md) |
| Executor evidence | [`../evidence/t9-responsive-pipeline-r4-owner-2026-07-31.md`](../evidence/t9-responsive-pipeline-r4-owner-2026-07-31.md) |
| Scope | R4-Owner only：D1 bootstrap / D2 ordered delivery+terminal / D3 bounded mailbox+control priority |
| Worktree tip at review | dirty tree on parent `c145f86`; **immutable R4-Owner SHA `768d680`** after Executor checkpoint |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 0**  
**P2: 1**  
**P3: 2**

---

## Scope

Independent Quality review of Executor R4-Owner delivery against:

1. Design freeze D1–D3 falsifiable claims  
2. Playbook `docs/playbooks/test-release.md` evidence honesty  
3. Explicit non-claims (no ADR Accept, Product Gate, R4-B, device/jetsam, production wire)

This review **re-ran tests** and **did not trust** Executor suite counts alone.

---

## Commands re-run (authoritative for this review)

Environment:

| Item | Value |
|---|---|
| Host | macOS 27.0 (Build 26A5388g), arm64 |
| Swift | Apple Swift 6.4 (`swift-driver` 1.168.5) |
| Module cache | `SWIFTPM_MODULECACHE_OVERRIDE` / `CLANG_MODULE_CACHE_PATH` under `/private/tmp/universe-spike-*` |
| Wall clock | 2026-07-31 ~00:40 CST |

### Focused

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard"
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeSpikeTests
```

| Suite | Executed | Failures | Notes |
|---|---:|---:|---|
| `ThreadAffineRimeSpikeTests` | **10** | **0** | Prior Spike 7 + 3 R4-Owner cases |

All cases PASS:

1. `testMainActorAcceptsWhileOwnerEngineCallIsBlocked` (~0.19s stall proof retained)
2. `testDedicatedOwnerPreservesOrderWithoutDropOrDuplicate`
3. `testOldEpochResultIsRejectedAndNewEpochRunsAfterResetBarrier`
4. `testExplicitShutdownDestroysEngineOnItsOwnerThread`
5. `testOwnerDeinitStopsThreadAndDestroysEngineWhenShutdownIsOmitted`
6. `testApplyGateRejectsOlderRevisionDeliveredAfterNewerRevision`
7. `testSpikeIsNotWiredAndGateOffRemainsSynchronous`
8. `testRefuseAtBoundDoesNotDropAcceptedWork` ← **R4-Owner D3**
9. `testOrderedDeliveryAndTerminalBarrierAfterStop` ← **R4-Owner D2**
10. `testControlPriorityStopIsNotBuriedBehindWorkBacklog` ← **R4-Owner D3 control**

### Full package

```bash
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **826** | **0** |

Delta vs Spike remediation **`c0e2373`** (823): **+3** R4-Owner tests — matches Executor evidence arithmetic.

**Evidence honesty:** Executor note claims 10 focused / 826 full. Independent re-run **confirms** both numbers. No invented green.

---

## Evidence matrix

| Claim (design) | Proof surface | Independent result |
|---|---|---|
| D1 config-only bootstrap preferred API | `ThreadAffineRimeEngineBootstrap` + `bootstrap:` convenience; engine local in `runOwnerLoop` | **Held** (structural + tests still create on owner thread) |
| D2 ordered delivery | single `ThreadAffineRimeDeliveryChannel` FIFO pump | **Held** (`testOrderedDeliveryAndTerminalBarrierAfterStop`) |
| D2 terminal after stop | `markOwnerLoopExited` + `waitUntilDeliveryDrained` / `isDeliveryTerminal` | **Held** |
| D3 refuse-at-bound | `maxPendingWorkDepth`; `rejectedAtBoundCount`; accepted work still delivered | **Held** (`testRefuseAtBoundDoesNotDropAcceptedWork`) |
| D3 control-priority stop | stop not buried; `abandonedAtStopCount`; process count = in-flight only | **Held** (`testControlPriorityStopIsNotBuriedBehindWorkBacklog`) |
| Prior Spike isolation / lifecycle | retained 7 tests | **Held** green |
| Gate default off + not wired | `isResponsiveRimePipelineEnabled = false`; isolation test; symbol scan | **Held** |
| No `@unchecked Sendable` in Spike source/tests | ripgrep | **Held** (0 hits) |
| Real librime / device / jetsam / ADR Accept | out of scope | **Not claimed** (correct) |

---

## Isolation / concurrency / wiring scans

### `@unchecked Sendable`

```text
Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift  → 0 hits
Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeSpikeTests.swift → 0 hits
```

Owner/mailbox/delivery use `Mutex` + Sendable envelopes; no isolation bypass observed in R4-Owner surface.

### Production wiring

Symbol use of `ThreadAffineRimeSpikeOwner` / `ThreadAffineRimeEngineBootstrap` / R4 owner types:

- **Sources:** only `ThreadAffineRimeSpike.swift`
- **Tests:** only `ThreadAffineRimeSpikeTests.swift`
- **Not referenced** from `KeyboardController`, Extension targets, or `RimeEngineImpl` production paths

Gate remains:

```swift
public var isResponsiveRimePipelineEnabled = false
```

Controller responsive path continues to use R2 `SerialRimeSessionOwner` / `ResponsiveRimeSessionCoordinator` when explicitly enabled in tests — **orthogonal** to R4-Owner spike owner. Isolation test `testSpikeIsNotWiredAndGateOffRemainsSynchronous` PASS (synchronous `processKey`, coordinator nil).

---

## Mapping to design D1–D3

### D1 — Bootstrap config-only

- Public protocol `ThreadAffineRimeEngineBootstrap: Sendable` with `makeEngineOnOwnerThread()`.
- Spike factory name retained as typealias (migration-compatible).
- Owner loop materializes engine as local `let engine` only.
- **Quality note:** “must not store a live engine” is a **Sendable + documentation** contract, not a separate type-system product proof. Acceptable for R4-Owner Fake path; real librime bootstrap remains R4-B. Not elevated to P1.

### D2 — Ordered delivery + terminal

- Replaces per-result unstructured fan-out with one mailbox + coalesced MainActor pump.
- Terminal signaled only after owner loop exit and FIFO drain (or immediately if empty).
- Hot path `accept` does not wait on drain; `waitUntilDeliveryDrained` is test/lifecycle barrier only.

### D3 — Bounded mailbox + control priority

- Dual lane: work FIFO vs control FIFO; control preferred in `next()`.
- Refuse-at-bound returns `nil`, increments `rejectedAtBoundCount`, does not drop accepted work.
- Stop abandons remaining work (`abandonedAtStopCount`) without draining backlog — proven under blocked in-flight + flooded queue.

---

## Findings

### P2-1 — R4-Owner not bound to an immutable git SHA (condition → Closed at `768d680`)

At review time:

| Artifact | Git state |
|---|---|
| `HEAD` | `c145f86` (docs bind Spike re-reviews — **not** R4-Owner impl) |
| `ThreadAffineRimeSpike.swift` | **modified, uncommitted** (+large R4-Owner delta) |
| `ThreadAffineRimeSpikeTests.swift` | **modified, uncommitted** |
| `t9-responsive-pipeline-001-r4-owner-design.md` | **untracked** |
| `docs/evidence/t9-responsive-pipeline-r4-owner-2026-07-31.md` | **present on disk but gitignored** by pattern `evidence/` (needs force-add like prior T9 evidence) |

Independent tests green against **worktree**, not a durable SHA. Same class of condition as Spike-P1-3 first Pass-with-conditions: **Executor must land an immutable checkpoint** (sources + tests + design + force-added evidence) before Product treats dual review as merge-bound.

Does **not** reopen D1–D3 falsification; tests prove the worktree content.

### P3-1 — 50 ms MainActor accept upper bound remains experimental (residual)

`testMainActorAcceptsWhileOwnerEngineCallIsBlocked` still asserts accept `< 50 ms` under a `≥ 150 ms` owner stall. Correct as concurrent falsification, **not** a Product/Release SLO. Retained residual from Spike-P1-3 Quality re-review; do not promote to gate language.

### P3-2 — Bound refuse after revision allocation can burn a revision slot

In `accept`, `nextRevision` is advanced before `mailbox.tryEnqueueWork`. On MainActor serial accept the pre-check `pendingWorkDepth >= max` makes the second refuse path rare; if it fires, revision gaps without enqueue. Fail-closed (no phantom execution) but diagnostics/`revision` monotonicity for non-enqueued accepts is slightly leaky.

Not a P1: no accepted work is dropped; bound refuse returns `nil`. Optional polish: allocate revision only after successful enqueue, or roll back on refuse.

---

## Explicit non-claims

本审查 **明确不主张 / 不授权**：

| Non-claim | Status |
|---|---|
| **ADR 0025 Accept** | 保持 `Proposed`；本审查不 Accept |
| **Product Gate** | 未执行、未通过 |
| **R4-B** real librime Simulator matrix / gate-off vs on | 未授权、未证明 |
| **Device / jetsam / crash SLO numbers** | 仅有 policy hooks + counters；无真机证据 |
| **Production wiring** to `KeyboardController` / Keyboard Extension / `RimeEngineImpl` | **未接线**（且必须保持） |
| **Release default-on** / user-visible gate flip | gate 仍 default `false` |
| **Architecture Pass** | 由独立 Architecture reviewer 判定结构；Quality 不代审 |
| Full RimeEngine surface (Delete / Path / select / page / recover) | 仍 processKey-first |
| UI 帧响应、marked-text 原子事务、进程死亡恢复 | 未证明 |

---

## Passed / Failed / Skipped

### Passed

- Independent focused suite **10 / 10**
- Independent full KeyboardCore suite **826 / 826**
- D2 ordered delivery + terminal drain falsification
- D3 refuse-at-bound without dropping accepted work
- D3 control-priority stop under backlog
- Prior Spike isolation, epoch/revision, lifecycle, 150 ms stall path retained
- No `@unchecked Sendable` in Spike source/tests
- No production wiring; gate default off
- Executor evidence counts match independent re-run

### Failed

- None at P0/P1 for R4-Owner scope

### Skipped (with reason)

| Check | Reason |
|---|---|
| R4-B real librime | Out of scope; not Product-authorized |
| Device / jetsam measurement | Design explicitly non-claims numbers |
| Xcode Extension / app target build matrix | R4-Owner is KeyboardCore package unit-proof only |
| Architecture structural dual-Pass | Separate reviewer lane |

---

## Release decision

**Not a release candidate.** R4-Owner is a **disconnected contract spike** inside KeyboardCore.

| Decision surface | Recommendation |
|---|---|
| Merge of R4-Owner **after** immutable SHA + force-added evidence | Allowed from Quality perspective once P2-1 closed, **if** Architecture also Pass (or Pass with non-P0/P1 conditions) |
| Product Gate / default-on / R4-B | **Do not** advance on this review alone |
| ADR 0025 | Remain `Proposed` |

---

## Owner handoffs

| To | Action |
|---|---|
| 🧠 Executor | Create **immutable commit** binding R4-Owner sources/tests + design; `git add -f` evidence note (pattern `evidence/` ignores new files); refresh evidence with commit SHA + independent counts **10 / 826** |
| 🏛️ Architecture | Independent structure review vs D1–D3 freeze (Quality does not substitute) |
| 🧭 Product Lead | After dual Arch+Quality disposition on a **fixed SHA**, decide optional **R4-B** knife only — **this file does not authorize R4-B, Gate, or ADR Accept** |
| 🧪 Quality (follow-up) | Re-bind review to that SHA if Product requires merge-ready disposition; no re-test required if tree is identical to this worktree tip |

---

## Verdict summary

| Item | Result |
|---|---|
| Independent Spike/R4-Owner tests | **10 / 10 PASS** |
| Independent KeyboardCore suite | **826 / 826 PASS** |
| D1–D3 falsifiable claims | **Held** under Fake/probe engines |
| `@unchecked Sendable` (Spike source/tests) | **None** |
| Production wiring / gate default | **Unchanged (off / disconnected)** |
| Evidence count honesty | **Matches** independent re-run |
| Immutable SHA binding | **Missing** → P2 condition |
| Overall | **Pass with conditions** |

**Conditions to close before treating as merge-bound:**

1. Immutable git commit of R4-Owner implementation + design freeze linkage  
2. Force-add / durable evidence artifact with that SHA  
3. Architecture independent disposition recorded  

No P0/P1 reopen of Spike lifecycle or R4-Owner D1–D3 proofs based on current worktree tests.
