# Quality Review: R4-B (real librime thread-affine bootstrap)

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（**independent** reviewer） |
| Date | 2026-07-31 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Design freeze | [`t9-responsive-pipeline-001-r4-b-design.md`](t9-responsive-pipeline-001-r4-b-design.md) |
| Product authority | [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) § R4-B |
| Executor evidence | [`../evidence/t9-responsive-pipeline-r4-b-2026-07-31.md`](../evidence/t9-responsive-pipeline-r4-b-2026-07-31.md) |
| Independent real-engine re-run | [`../evidence/r4b-runtime/quality-rerun/`](../evidence/r4b-runtime/quality-rerun/) |
| Scope | R4-B only：config-only real bootstrap + Simulator/RimeBridge affinity proof；gate-off；无 Extension wire |
| Worktree tip at review | dirty tree on parent tip `8486b5e`；R4-B 产物多数 **uncommitted**（见 § Worktree honesty） |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 0**  
**P2: 1**（owner QoS vs librime helper 优先级反转 residual，阻塞后续生产接线而非本刀 Pass）  
**P3: 2**（essay db 只读噪声日志；immutable SHA 条件在 `cb45f1c` 关闭）

---

## Scope

Independent Quality review of Executor R4-B delivery against:

1. Design freeze D1–D4 + evidence matrix M1–M5  
2. Product R4-B authorization boundary（default-off；disconnected real-engine proof）  
3. Playbook evidence honesty（re-run, not trust Executor counts alone）  
4. Explicit non-claims（无 ADR Accept / Product Gate / Extension production wire / R5 device）

This review **re-ran** KeyboardCore suites and the R4-B real-engine harness. It did **not** accept Executor green as sole authority.

---

## Commands re-run (authoritative for this review)

Environment:

| Item | Value |
|---|---|
| Host | macOS 27.0 (Build 26A5388g), arm64 |
| Swift | Apple Swift 6.4 (`swift-driver` 1.168.5) |
| Module cache | `SWIFTPM_MODULECACHE_OVERRIDE` / `CLANG_MODULE_CACHE_PATH` under `/private/tmp/universe-spike-*` |
| Simulator | `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5` |
| Wall clock | 2026-07-31 ~00:55–00:56 CST |

### 1) KeyboardCore focused

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard"
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeSpikeTests
```

| Suite | Executed | Failures | Notes |
|---|---:|---:|---|
| `ThreadAffineRimeSpikeTests` | **10** | **0** | Spike + R4-Owner Fake owner 仍绿；iOS availability 未破坏 macOS `swift test` |

### 2) KeyboardCore full package

```bash
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-spike-swift-module-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-spike-clang-module-cache \
swift test --package-path Packages/KeyboardCore
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **826** | **0** |

Matches Executor arithmetic（10 focused / 826 full）. **Evidence honesty: confirmed.**

### 3) R4-B real engine harness（independent re-run）

```bash
UK_R4B_EVIDENCE_DIR="/Users/doubleshy0n/Dev/Universe Keyboard/docs/evidence/r4b-runtime/quality-rerun" \
  scripts/run_t9_responsive_r4b.sh
```

| Item | Independent result |
|---|---|
| xcodebuild exit | **0** |
| `** TEST SUCCEEDED **` | **Present** |
| `testGateOffDefaultUnchangedByR4BBootstrapPresence` | **PASS** (0.011 s) |
| `testRealEngineBootstrapCreatesAndCallsOffMainThroughOwner` | **PASS** (~11.7 s incl. deploy) |
| Machine line | `R4B_REAL_ENGINE_RESULT passed=true schema=rime_ice keys=4 delivered=4 offMain=true sameThread=true` |
| Full log | `docs/evidence/r4b-runtime/quality-rerun/logs/xcodebuild-r4b.log` |
| Full log SHA-256 | `0104e2cdcf4bf7d8e5b88d01e9909ab74b03eebb02c56ae0a1061dbbea4da252` |
| Result file | `docs/evidence/r4b-runtime/quality-rerun/r4b-result.md` — **PASSED** |

Also inspected Executor `manual-run2` log for cross-check:

- `R4B_REAL_ENGINE_RESULT passed=true schema=rime_ice keys=4 delivered=4 offMain=true sameThread=true`
- `** TEST SUCCEEDED **`
- Log SHA-256 (Executor): `77cb218ab6c7fb11bbd0bde0f56f2c80b536125971c239da1b641b0e2822c658`

Independent re-run **reproduced** the same machine contract; not a one-off.

---

## Evidence matrix vs design

| Case | Requirement | Independent result |
|---|---|---|
| **M1** | ≥3 processKey；`engineCreatedOffMainThread` + `engineCallStayedOnCreationThread` | **Held** — 4 keys；`offMain=true` / `sameThread=true` on quality-rerun |
| **M2** | Delivery order = accept actionID FIFO | **Held** — test asserts `rk0…rk3` |
| **M3** | Shutdown + no hang；delivery terminal | **Held** — `waitUntilStopped` / `waitUntilDeliveryDrained` / `isDeliveryTerminal`；suite completed |
| **M4** | Missing fixture → XCTSkip（not fabricated Pass） | **Held structurally** — `realRuntimeDirectories()` throws `XCTSkip` when env/dirs/schema missing；this re-run had fixture so did not re-execute skip path |
| **M5** | Gate default off；R4-B does not enable responsive path | **Held** — `testGateOffDefaultUnchangedByR4BBootstrapPresence`；`isResponsiveRimePipelineEnabled == false`；`responsiveRimeCoordinator == nil` |
| **D1** | Config-only Sendable bootstrap；engine only on owner thread | **Held** — `ThreadAffineRimeEngineImplBootstrap` stores only path/schema strings；`makeEngineOnOwnerThread()` materializes `RimeEngineImpl` |
| **D3** | Isolated runtime；not sole formal App Group | **Held** — harness copies into `docs/evidence/r4b-runtime/.../runtime/{shared,user}` |
| **D4** | iOS availability for owner APIs | **Held** — `@available(iOS 18.0, macOS 15.0, *)` on ThreadAffine surface + bootstrap |
| **S1/S2** stretch | T9 content / MainActor stall with real key | **Not required / not claimed**（correct） |

---

## Isolation / concurrency / wiring scans

### `@unchecked Sendable`

| Surface | Hits |
|---|---|
| `ThreadAffineRimeSpike.swift` | **0** attribute uses |
| `ThreadAffineRimeEngineImplBootstrap.swift` | **0** |
| `ThreadAffineRimeRealEngineTests.swift` | **0** |
| `ThreadAffineRimeSpikeTests.swift` | **0** |
| `Packages/RimeBridge` (whole package) | **0** |
| `Packages/**/*.swift` attribute uses | **0**（仅 `SerialRimeSession.swift` 注释 forbid） |

**No isolation bypass observed.** Bootstrap is a pure `Sendable` value type; live engine is local to `runOwnerLoop` on the dedicated thread.

### Production Extension wire

Symbol scan for `ThreadAffineRime*` / `ThreadAffineRimeEngineImplBootstrap`:

| Location | Result |
|---|---|
| `Keyboard/` (Extension target sources) | **0 hits** |
| Production app sources (non-test) | **No** owner / real-bootstrap wire |
| `Packages/KeyboardCore/Sources/.../ThreadAffineRimeSpike.swift` | Owner implementation only |
| `Packages/RimeBridge/Sources/.../ThreadAffineRimeEngineImplBootstrap.swift` | Bootstrap only |
| Tests only | `ThreadAffineRimeSpikeTests` + `ThreadAffineRimeRealEngineTests` |

**Confirmed: no production Extension wire of the thread-affine owner.**

### Gate default

RimeBridge real-engine suite asserts responsive gate remains **false** and coordinator **nil**. KeyboardCore Fake suite retains `testSpikeIsNotWiredAndGateOffRemainsSynchronous`. R4-B does not flip Release defaults.

---

## Artifacts reviewed

| Artifact | Path |
|---|---|
| Bootstrap | `Packages/RimeBridge/Sources/RimeBridge/ThreadAffineRimeEngineImplBootstrap.swift` |
| Real-engine tests | `Packages/RimeBridge/Tests/RimeBridgeTests/ThreadAffineRimeRealEngineTests.swift` |
| Owner + iOS availability | `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift` |
| Harness | `scripts/run_t9_responsive_r4b.sh` |
| Design | `docs/assignments/t9-responsive-pipeline-001-r4-b-design.md` |
| Executor evidence | `docs/evidence/t9-responsive-pipeline-r4-b-2026-07-31.md` |
| Independent re-run | `docs/evidence/r4b-runtime/quality-rerun/` |

---

## Residuals

### P2 — Owner QoS priority inversion under real librime

Independent quality-rerun still emits Thread Performance Checker:

> Thread running at **User-initiated** QoS waiting on a lower QoS thread at **Default**  
> Site: `ThreadAffineRimeSpike.swift` mailbox `next()` / owner loop

Executor already lowered owner QoS from `userInteractive` → `userInitiated` with an explanatory comment. Residual **remains** under real librime helper threads.

**Impact on R4-B Pass:** does **not** falsify M1–M5 affinity / ordering / shutdown claims.  
**Impact on later knives:** **must** be re-evaluated before Extension production wire or R5 subjective-latency claims. Do not treat R4-B green as “QoS / stutter closed”.

### P3 — Observational RIME logs

- `Error opening db 'essay' read-only` during deploy/setup under isolated fixture — does not fail tests; not product content claim.  
- `[RIME] claiming process runtime on non-main thread` — observational under this fixture; **not** a product guarantee that production Extension runtime ownership is redesigned.

### P3 — Worktree honesty（immutable SHA → Closed at `cb45f1c`）

At review time:

- Parent tip: `8486b5e`  
- R4-B implementation files largely **untracked / dirty**（bootstrap, real-engine tests, harness, design, owner availability edits）  
- Unlike R4-Owner which bound dual reviews to immutable SHA `768d680`, **R4-B has no frozen commit SHA** for this Pass.

**Condition:** Product / Executor must create a **clean immutable R4-B checkpoint SHA** and re-bind Arch+Quality reviews to that SHA before treating R4-B as closed for downstream authorization. If the tree mutates D1/M1–M5 semantics after this review, this Pass is **void** and requires re-review.

---

## Explicit non-claims（Quality will not endorse）

This review **does not** claim, authorize, or partially satisfy:

1. Extension / `KeyboardController` production migration of the thread-affine owner  
2. ADR 0025 **Accept**  
3. Product Gate / Release default-on / user-facing settings  
4. R5 device A/B or subjective non-stutter SLO  
5. R6 shipping decision  
6. Full session API production routing（Delete / Path / select / page / recover）  
7. Formal jetsam / mailbox-depth product SLOs  
8. That owner QoS is production-ready under real librime  
9. That “claiming process runtime on non-main thread” is a permanent runtime law  
10. Content correctness of Chinese composition beyond content-free key count / order / affinity flags  

R4-B proves only: **config-only real bootstrap + off-main create/call affinity + FIFO delivery + shutdown on Simulator**, with **gate-off** and **no production wire**.

---

## Verdict

### **Pass with conditions**

R4-B authorized intent is **met** on independently re-run evidence:

- KeyboardCore Fake owner: **10/0** focused, **826/0** full  
- Real librime Simulator: **TEST SUCCEEDED** + `R4B_REAL_ENGINE_RESULT passed=true`  
- Design M1–M5 / D1 / D3 / D4 held  
- No `@unchecked Sendable`  
- No production Extension wire  
- Gate remains default-off  

### Conditions (must hold for this Pass to remain valid)

1. **No over-claim:** this Pass **must not** be used as ADR Accept, Product Gate, R5, or Extension wire authorization.  
2. **P2 QoS residual:** any future production-wire / R5 design must address owner-vs-librime priority inversion with fresh evidence; do not paper over with isolation bypass.  
3. **Immutable SHA bind:** Executor/Product should commit R4-B knife and bind Arch+Quality to a clean SHA; post-review semantic changes require re-review.  
4. **Fixture honesty:** never claim real-engine Pass from skip-only runs; harness must keep isolated dirs and machine line parsers.

### Stop / escalate if

- Someone enables responsive gate or wires owner into Extension without a new Product knife  
- Swift 6 isolation “fixed” via `@unchecked Sendable` / `nonisolated(unsafe)`  
- Formal App Group user data is mutated as the sole test runtime without isolation  

---

## Handoff

| To | Payload |
|---|---|
| 🧭 Product | Verdict **Pass with conditions**；R4-B proof held；downstream knives still closed |
| 🏛️ Architecture | P2 QoS residual for production-wire design；ADR 0025 remains **Proposed** |
| 🔧 Executor | Create immutable R4-B SHA；optional doc sync of quality-rerun path/SHA into executor evidence |
| 🧪 (self) | Review artifact: this file |

---

## Appendix — machine lines (independent)

```text
# KeyboardCore
ThreadAffineRimeSpikeTests: Executed 10 tests, with 0 failures
KeyboardCore All tests: Executed 826 tests, with 0 failures

# quality-rerun harness
R4B_REAL_ENGINE_RESULT passed=true schema=rime_ice keys=4 delivered=4 offMain=true sameThread=true
** TEST SUCCEEDED **
log SHA-256: 0104e2cdcf4bf7d8e5b88d01e9909ab74b03eebb02c56ae0a1061dbbea4da252
```
