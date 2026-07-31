# Quality Review: R4-Wire (thread-affine controller wire)

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（**independent** reviewer） |
| Date | 2026-07-31 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Design freeze | [`t9-responsive-pipeline-001-r4-wire-design.md`](t9-responsive-pipeline-001-r4-wire-design.md) |
| Product authority | [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) § R4-Wire |
| Executor evidence | [`../evidence/t9-responsive-pipeline-r4-wire-2026-07-31.md`](../evidence/t9-responsive-pipeline-r4-wire-2026-07-31.md) |
| Scope | R4-Wire only：dual-gate controller wire + full `ResponsiveRimeWork` owner surface；gates default-off；no Release default-on |
| Worktree tip at review | dirty tree on parent tip `8f697e6`；R4-Wire 产物 **uncommitted**（见 § Worktree honesty） |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 0**  
**P2: 1**（immutable SHA 未绑定；语义变更会使本 Pass 失效）  
**P3: 2**（missing-bootstrap 缺显式单测；属性缩进/cosmetic）

---

## Scope

Independent Quality review of Executor R4-Wire delivery against:

1. Design freeze D1–D5 + evidence bullets  
2. Product R4-Wire authorization boundary（dual gate default-off；controller wire；no R5 / ADR Accept）  
3. Playbook evidence honesty（re-run, not trust Executor counts alone）  
4. Explicit non-claims（no ADR Accept / Product Gate / Release default-on / device non-stutter）

This review **re-ran** KeyboardCore focused and full suites. It did **not** accept Executor green as sole authority.

---

## Commands re-run (authoritative for this review)

Environment:

| Item | Value |
|---|---|
| Host | macOS 27.0 (Build 26A5388g), arm64 |
| Swift | Apple Swift 6.4 (`swift-driver` 1.168.5) |
| Module cache | `SWIFTPM_MODULECACHE_OVERRIDE` / `CLANG_MODULE_CACHE_PATH` under `/private/tmp/universe-spike-*` |
| Wall clock | 2026-07-31 ~12:18 CST |
| Parent tip | `8f697e6e3fd6a2c7426b4274818d90f5af6e7d64` |

### 1) KeyboardCore focused (`ThreadAffineRime`)

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard"
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore --filter ThreadAffineRime
```

| Suite | Executed | Failures | Notes |
|---|---:|---:|---|
| `ThreadAffineRimeSpikeTests` | **10** | **0** | Owner / spike contract retained |
| `ThreadAffineRimeWireTests` | **4** | **0** | R4-Wire dual-gate proofs |
| **Focused total** | **14** | **0** | |

### 2) KeyboardCore full package

```bash
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **830** | **0** |

Matches Executor arithmetic（14 focused via Spike+Wire / 830 full; Executor listed 10 Spike + 4 Wire + 830 full）. **Evidence honesty: confirmed.**

---

## Evidence matrix vs design

| Case | Requirement | Independent result |
|---|---|---|
| **Gate defaults** | `isResponsiveRimePipelineEnabled` + `isThreadAffineRimeOwnerEnabled` both default `false` | **Held** — `KeyboardController` property initializers `= false`；`testDualGatesDefaultOff`；production sources do not assign `= true` |
| **Gate-off sync** | Either gate false → ADR 0004 sync path | **Held** — `testGateOffStillSynchronousWhenThreadAffineFlagAloneIsTrue`（threadAffine alone still sync） |
| **Responsive-only** | responsive=true, threadAffine=false → MainActor R2 bridge | **Held** — `testResponsiveOnlyWithoutThreadAffineKeepsMainActorBridge` |
| **Dual-gate + bootstrap** | both true + bootstrap → thread-affine owner; handle does not wait on blocked engine | **Held** — `testThreadAffineWireAcceptsWithoutWaitingForBlockedEngine` (`elapsedMS < 50`; presentation fires) |
| **Fail-closed missing bootstrap** | threadAffine requested without bootstrap → MainActor R2 (or no half-wire) | **Held structurally** — `rebuildResponsiveRimeCoordinatorIfNeeded` falls through to MainActor R2 when bootstrap nil；comment documents fail-closed. **No dedicated Wire test**（P3） |
| **Full work surface** | owner executes full `ResponsiveRimeWork` | **Held** — `ThreadAffineRimeSpikeWork = ResponsiveRimeWork`；`execute` covers processKey / delete / select / replace / reset / recover / page |
| **Presentation path** | results re-enter MainActor via ordered delivery → `applyResponsivePublishedSnapshot` | **Held** — coordinator publish handler → controller apply；thread-affine branch is presentation-only when `underlyingRimeEngine == nil` |
| **Lifecycle** | suspend uses explicit stop/shutdown; deinit safety net only | **Held** — `suspendForVisibilityChange` / `shutdown` / `resumeAfterVisibilityChange` wired from controller |
| **No `@unchecked Sendable`** | isolation without bypass | **Held** — see scan below |
| **Full suite green** | KeyboardCore all tests | **Held** — **830 / 0** |
| **D4 residual** | engine-mutating auto-anchor follow-ups suppressed in thread-affine mode | **Held as residual** — `underlyingRimeEngine` returns nil for `ThreadAffineRimeEngineBridge`；apply path skips MainActor engine post-process |

---

## Isolation / concurrency / wiring scans

### `@unchecked Sendable`

| Surface | Hits |
|---|---|
| `ThreadAffineRimeSpike.swift` | **0** attribute uses |
| `ThreadAffineRimeSession.swift`（new wire） | **0** |
| `ThreadAffineRimeWireTests.swift` | **0** |
| `ThreadAffineRimeSpikeTests.swift` | **0** |
| `KeyboardController.swift` R4-Wire edits | **0** |
| `Packages/**/*.swift` attribute uses | **0**（仅 `SerialRimeSession.swift` 注释 forbid） |
| `nonisolated(unsafe)` in KeyboardCore ThreadAffine / wire files | **0** |

**No isolation bypass observed.** Wire types use `Mutex` + Sendable bootstrap type-eraser + owner thread loop.

### Gate defaults (production)

| Flag | Default in source | Production force-enable |
|---|---|---|
| `isResponsiveRimePipelineEnabled` | `false` | **None** outside tests |
| `isThreadAffineRimeOwnerEnabled` | `false` | **None** outside tests |
| `threadAffineEngineBootstrap` | `nil` | **None** in Extension (`Keyboard/`) |

Extension / app production Swift sources: **0** references to `isThreadAffineRimeOwnerEnabled` / `threadAffineEngineBootstrap`. Dual-gate remains **opt-in for tests / future knives only**.

### Dual-entry safety (spot check)

| Path | Observation |
|---|---|
| Composition processKey dual-gate | `scheduleProcessKey` — MainActor accept, no librime wait |
| Other session APIs via bridge | `ThreadAffineRimeEngineBridge` → `performOrderedNow` on owner |
| MainActor live session under dual-gate | **Not held** — `underlyingRimeEngine == nil` for affine bridge |
| Responsive-only path | Unchanged MainActor `ResponsiveRimeEngineBridge` |

---

## Artifacts reviewed

| Artifact | Path |
|---|---|
| Wire coordinator + bridge | `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift` |
| Owner + full work surface | `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift` |
| Controller dual gate | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` |
| Composition accept path | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift` |
| Wire tests | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeWireTests.swift` |
| Spike tests | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeSpikeTests.swift` |
| Design | `docs/assignments/t9-responsive-pipeline-001-r4-wire-design.md` |
| Executor evidence | `docs/evidence/t9-responsive-pipeline-r4-wire-2026-07-31.md` |
| Product | `docs/product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md` § R4-Wire |

---

## Residuals

### P2 — Worktree honesty（no immutable R4-Wire SHA）

At review time:

- Parent tip: `8f697e6`（docs bind R4-B reviews；not an R4-Wire implementation SHA）  
- R4-Wire implementation largely **modified / untracked**:
  - `M` `KeyboardController.swift`, `KeyboardController+RimeRecovery.swift`, `ThreadAffineRimeSpike.swift`, Wire/Spike tests, Package.swift, Assignment/PD docs  
  - `??` `ThreadAffineRimeSession.swift`, `ThreadAffineRimeWireTests.swift`, `r4-wire-design.md`  
- Unlike R4-Owner (`768d680`) / R4-B (`cb45f1c`), **R4-Wire has no frozen commit SHA** for this Pass.

**Condition:** Product / Executor must create a **clean immutable R4-Wire checkpoint SHA** and re-bind Arch+Quality reviews to that SHA before treating R4-Wire as closed for downstream authorization. If the tree mutates D1–D5 / dual-gate semantics after this review, this Pass is **void** and requires re-review.

### P3 — Missing-bootstrap fail-closed lacks a dedicated test

Code path and comment implement design-recommended fail-closed（MainActor R2 when bootstrap nil）. Wire suite covers default-off, threadAffine-alone, responsive-only, and dual-gate+bootstrap — **not** “both gates true + nil bootstrap”. Residual is **coverage honesty**, not a proven production default-on risk.

### P3 — Cosmetic property indentation in `KeyboardController`

Several new properties / helpers use irregular leading whitespace (still class-scope members; Swift is whitespace-insignificant for nesting). Does not affect runtime. Optional cleanup before SHA freeze.

### Carry-forward（not re-opened as R4-Wire fail）

- **R4-B P2 QoS residual** (owner vs librime helper priority inversion) remains relevant before any real-engine dual-gate experiment on device. R4-Wire Fake path does not close it.  
- **D4 residual:** engine-mutating auto-anchor follow-ups intentionally suppressed under thread-affine mode — product content parity of auto-anchor under dual-gate is **not** claimed.

---

## Explicit non-claims（Quality will not endorse）

This review **does not** claim, authorize, or partially satisfy:

1. ADR 0025 **Accept**  
2. Product Gate / Release default-on / user-facing settings flipping either gate  
3. R5 device A/B or subjective non-stutter SLO  
4. R6 shipping decision  
5. Extension production **enablement** of dual-gate（installing real bootstrap + turning both flags true）  
6. That gate-on dual-gate is default runtime for users  
7. Formal jetsam / mailbox-depth / delivery backpressure product SLOs  
8. That owner QoS is production-ready under real librime  
9. Full auto-anchor / Path engine-mutating parity under thread-affine mode  
10. Content correctness of Chinese composition beyond Fake-engine wire contracts  
11. That dirty-tree review equals an immutable SHA-bound close  

R4-Wire proves only: **KeyboardController dual-gate wire exists**, **both gates default false**, **Fake bootstrap dual-gate accepts processKey without MainActor stall**, **responsive-only and gate-off paths retained**, **owner work surface = full `ResponsiveRimeWork`**, **KeyboardCore suite green**, **no `@unchecked Sendable`**.

---

## Verdict

### **Pass with conditions**

R4-Wire authorized intent is **met** on independently re-run evidence:

- Focused ThreadAffine: **14/0**（Spike 10 + Wire 4）  
- KeyboardCore full: **830/0**  
- Design dual-gate matrix held（defaults / sync / responsive-only / dual+bootstrap non-blocking）  
- No `@unchecked Sendable`  
- No production force-enable of either gate  
- Fail-closed missing bootstrap implemented（documented; test residual P3）  

### Conditions (must hold for this Pass to remain valid)

1. **No over-claim:** this Pass **must not** be used as ADR Accept, Product Gate, R5, or Release default-on authorization.  
2. **Immutable SHA bind:** Executor/Product should commit R4-Wire knife and bind Arch+Quality to a clean SHA; post-review semantic changes require re-review.  
3. **Gates remain default-off** until a new Product knife authorizes otherwise.  
4. **QoS / device residual:** do not treat R4-Wire Fake green as R4-B QoS close or device non-stutter.  
5. **Optional hardening:** add missing-bootstrap Wire test before or with SHA freeze（P3, non-blocking）.

### Stop / escalate if

- Someone enables either gate by default in production / settings without a new Product knife  
- Swift 6 isolation “fixed” via `@unchecked Sendable` / `nonisolated(unsafe)`  
- Dual-entry reappears（MainActor live engine **and** owner engine for the same session）  
- Dirty-tree semantics diverge from this review without re-review  

---

## Handoff

| To | Payload |
|---|---|
| 🧭 Product | Verdict **Pass with conditions**；R4-Wire dual-gate wire held；downstream R5 / ADR Accept / default-on still closed |
| 🏛️ Architecture | D4 residual (auto-anchor suppress) remains product residual；ADR 0025 remains **Proposed** |
| 🔧 Executor | Create immutable R4-Wire SHA；optional missing-bootstrap test + cosmetic indent cleanup |
| 🧪 (self) | Review artifact: this file |

---

## Appendix — machine lines (independent)

```text
# Focused
ThreadAffineRimeSpikeTests: Executed 10 tests, with 0 failures
ThreadAffineRimeWireTests: Executed 4 tests, with 0 failures
Selected tests: Executed 14 tests, with 0 failures

# Full
KeyboardCore All tests: Executed 830 tests, with 0 failures
```
