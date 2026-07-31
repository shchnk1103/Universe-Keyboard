# Quality Review: R5-Rem-3 **implementation** (provisional L1 composition)

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（**independent** implementation reviewer） |
| Date | 2026-07-31 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Design freeze | [`t9-responsive-pipeline-001-r5-rem-3-design.md`](t9-responsive-pipeline-001-r5-rem-3-design.md)（含 Amendment A / D9） |
| Design Quality (prior) | [`t9-responsive-pipeline-001-r5-rem-3-quality-review.md`](t9-responsive-pipeline-001-r5-rem-3-quality-review.md) — design-only |
| Design Architecture (prior) | [`t9-responsive-pipeline-001-r5-rem-3-architecture-review.md`](t9-responsive-pipeline-001-r5-rem-3-architecture-review.md) |
| Executor evidence | [`../evidence/t9-responsive-pipeline-r5-rem-3-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-3-2026-07-31.md) |
| Product authority | Human Product Owner authorized **Rem-3 implementation** only（option 1 after design freeze） |
| Scope | **Implementation Quality** of dual-gate provisional L1（`·`×N）；D7 matrix honesty；digit safety；gate-off；fail-closed；progressive bar |
| Bound tip (task) | **`9b9bbeb`** |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 2**  
**P2: 4**  
**P3: 3**

---

## Scope

Independent Quality review of **R5-Rem-3 implementation** against:

1. Design D1–D9（ledger / `·`×N / watermark floor / provisionalAhead / D5 dual VISIBLE / D7 matrix）  
2. Executor evidence honesty（counts, non-claims）  
3. Digit safety / gate-off / fail-closed / progressive bar  
4. Explicit **non-claims**（no Product Gate / ADR Accept / default-on / device Pass）

This review **does not**:

- authorize Product Gate, ADR 0025 Accept, Release dual-gate default-on, or Rem-3-Device  
- rewrite Formal R5 FAIL or upgrade Rem-Device PASS  
- claim Architecture Pass  
- change production code（review markdown only）

---

## Commands / counts (authoritative honesty)

### Re-run posture

Task required independent re-run of:

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard"
swift test --package-path Packages/KeyboardCore --filter 'ResponsiveProvisional|ThreadAffineRimeWire|ResponsiveRimeFeltMetrics'
swift test --package-path Packages/KeyboardCore
```

| Layer | Result |
|---|---|
| **Independent process re-run in this subagent** | **Not executed** — this Quality subagent tool surface has **no shell/exec** capability; cannot spawn `swift test`. |
| **Static test inventory**（source-of-truth for method counts） | Focused filter set = **18** methods（see below） |
| **Full-suite arithmetic vs prior Quality** | Rem-Device Quality full **842** + Rem-3 new **8** pure/wire tests = **850** — matches Executor claim arithmetic |
| **Executor claim**（not independently process-verified） | focused **18/0**；full **850/0** |

### Focused filter inventory（static）

| Suite / file | `func test*` count | Notes |
|---|---:|---|
| `ResponsiveProvisionalCompositionTests` + `ResponsiveProvisionalL1WireTests` | **8** | pure builder 4 + tracker 1 + wire 3 |
| `ThreadAffineRimeWireTests` | **7** | includes dual-gate default-off / coalesce / abandon |
| `ResponsiveRimeFeltMetricsTests` | **3** | lag / content-free / tracker+burst |
| **Selected filter total** | **18** | Matches Executor **18** |

### Full suite

| Source | Executed | Failures |
|---|---:|---:|
| Executor evidence | **850** | **0**（claim） |
| Prior independent Quality（Rem-Device tree） | **842** | **0** |
| Static Δ for Rem-3 (+8 in `ResponsiveProvisional*`) | **850** expected | n/a |
| **This review process re-run** | **—** | **—** |

**Honesty rule for consumers of this document:**

- Do **not** cite “Quality re-ran 850/0” from this file.  
- Cite instead: *Quality static inventory confirms 18 focused methods; full 850 is Executor claim + arithmetic-consistent with prior 842 baseline; process re-run blocked in harness.*  
- **Condition:** a follow-up Quality (or Product-side Environment Executor) **must** paste live `Executed N tests, with 0 failures` lines before this knife may be treated as suite-closed.

---

## Verdict summary

| Axis | Result | Notes |
|---|---|---|
| 1. D7 matrix honesty | **Held with gaps** | Progressive length + L2 replace + gate-off + abandon + candidate fail-closed unit-backed；coalesce+L1、VISIBLE marker progressive bar、Delete path A、Space/Path/Partial Commit surfaces thinner |
| 2. Digit safety | **Held** | Builder only U+00B7；pure tests assert no ASCII digits；host digit reject path unchanged for digits |
| 3. Gate-off | **Held** | L1 requires dual-gate；`testGateOffHasNoL1`；defaults remain `false` |
| 4. Fail-closed (provisionalAhead) | **Partial** | Candidate / Path / cycle / Space **code-gated**；candidate **unit-tested**；**Return / direct-text can host-commit `·`×N** while ahead → **P1-1** |
| 5. Progressive bar | **Held (length authority)** | N=8 blocked owner → composition `········` and slotCount≥ceil(N/2)；marker-count progressive bar **not** unit-asserted → **P2-1** |
| 6. Non-claims / Gate resistance | **Held** | Evidence + Assignment refuse Gate / ADR Accept / default-on / device |
| 7. Independent suite re-run | **Not held** | Process re-run blocked；see counts section |

### **Pass with conditions**

Rem-3 **core delivery**（structure-only L1 ledger, dual-gate paint, L2 atomic replace + revision floor, provisional→engine VISIBLE upgrade, gate-off no L1, abandon clear, progressive dots under owner stall）is **present in code and covered by the Rem-3 unit suite design**.  

It is **not** Product Gate green, device Pass, ADR Accept, or default-on.  
It is **not** a complete fail-closed surface for all composition-finalization actions（Return / direct text）.  
It is **not** independently process-re-run green in this review.

---

## Artifacts reviewed

| Artifact | Path |
|---|---|
| Pure L1 types | `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveProvisionalComposition.swift` |
| Felt metrics upgrade | `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimeFeltMetrics.swift` |
| Mirror + gates + L1 paint + live snapshot | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift` |
| Dual-gate accept hook | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+RimeRecovery.swift` |
| Candidate fail-closed | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+Candidates.swift` |
| Space fail-closed | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift` |
| Path / cycle fail-closed | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift` |
| Commit helpers（digit check only） | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift` |
| Tests | `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveProvisionalCompositionTests.swift` |
| Design | `docs/assignments/t9-responsive-pipeline-001-r5-rem-3-design.md` |
| Executor evidence | `docs/evidence/t9-responsive-pipeline-r5-rem-3-2026-07-31.md` |

---

## Evidence matrix vs design D7 / D1–D5

| D7 / design case | Expectation | Independent result |
|---|---|---|
| Fake stall, dual-gate ON, N≥8 before L2 | ≥ ceil(N/2) provisional **before** matching L2 | **Held (composition / slots)** — `testDualGateL1PaintsDotsBeforeEngine` uses blocked first `processKey`, N=8, asserts `currentComposition == ·×8` and slotCount≥ceil(N/2). **Not** Fake 150 ms clock；**not** count of `source=provisional` VISIBLE lines → **P2-1** |
| L2 replace after L1 | Engine composition；no digit leak；L2 VISIBLE | **Held** — after flush/settle, `isResponsiveProvisionalAhead == false` and composition has no `·`；tracker unit proves provisional→engine same rev |
| Selection while provisionalAhead | Fail closed even with stale L2 | **Held for candidate**（empty effects）；Path/Space code-gated but **not** wire-tested → **P2-2** |
| Gate-off | No L1；baseline behaviour | **Held** — `testGateOffHasNoL1`；`isResponsiveProvisionalAhead == false`；no `·` |
| Delete v1 path A | L2-driven shorten；no double-shorten | **Structural** — no Rem-3 Delete redesign；**no dedicated L1+Delete test** → **P3-1** |
| Abandon / epoch | Stale L1 dropped | **Held** — `testAbandonClearsL1`；`clearResponsive…` clears mirror + bumps presentation generation |
| 26-key / non-composition | No L1 | **Partial** — non-T9 skip path logs/skips；dual-gate non-T9 not wire-tested → **P3-2** |
| Coalesce backlog + L1 | L1 paints on accept；L2 latest-only；no selection while ahead | **Not unit-proven as co-joined case** — L1 path independent of coalesce；prior Wire has coalesce-only test → **P1-2** |
| Pure builder | length 0 empty；k→k dots；never digits | **Held** — pure tests |
| D1 dual-gate only | no dual → no L1 | **Held** — `applyResponsiveProvisionalL1IfEligible` requires both gates |
| D1 revision floor | L2 needs `revision ≥` floor while ahead | **Held structurally** — `isLivePresentationSnapshot` provisional branch |
| D2 structure-only `·` | no digits / pinyin / CJK in L1 | **Held** |
| D4 provisionalAhead selection | all selection fail closed | **Partial** — see P1-1 Return/direct-text |
| D5 dual VISIBLE | provisional then engine | **Held** — tracker allows upgrade；paint path uses `.provisional` then `.engine` |
| D5 L1_SKIP closed reasons | token-only | **Held** — enum；`gate_off` / `unsafe` largely unused → **P3-3** |
| Defaults off | dual-gate false | **Held** — controller defaults + Wire `testDualGatesDefaultOff` |
| No `@unchecked Sendable` | isolation | **Held** on Rem-3 surfaces scanned |
| Naming vs Path provisional | no Path API reuse | **Held** — `ResponsiveProvisionalComposition*` |

---

## Code-backed fail-closed map

| Action | provisionalAhead guard | Unit proof |
|---|---|---|
| Candidate / composition kind | `rejectIfResponsiveProvisionalAhead` | **Yes**（wire） |
| Path select / cycle | same | Code only |
| Space / 选定 first | same on `handleInsertSpace` | Code only |
| Partial Commit entry | mostly via candidate / empty chrome（L1 clears `lastRimeOutput` / Path） | **No explicit Partial Commit guard** → **P2-3** |
| Return | **None** | **Gap** — can `finishActiveCompositionAsRawInput` with `preferred = currentComposition` = `·`×N；digit guard does **not** reject middle dots → **P1-1** |
| Direct text | **None** | **Gap** — `finishActiveCompositionAsDisplayText` can commit `·`×N → **P1-1** |
| Language switch under T9 | typically abandon path（clear, no commit） | Safer than Return；not Rem-3-specific test |

---

## Residuals

### P1-1 — Return / direct-text can host-commit structure-only L1 while ahead

**Finding:** Design Rule 3 + D4 intent: L1 is non-commit authority；selection/选定 fail closed while `provisionalAhead`. Implementation gates candidate / Path / Space, but:

- `handleInsertReturn` has **no** `rejectIfResponsiveProvisionalAhead`  
- with `lastRimeOutput == nil` and `currentComposition == "····…"`, Return falls through to `finishActiveCompositionAsRawInput`  
- `compositionProjectionContainsInternalDigit` only rejects **ASCII digits**, so **`·` is committed to host**  
- `handleInsertDirectText` similarly finalizes display composition without the ahead guard  

**Risk:** User hits Return (or symbol/direct insert) during owner stall → host receives middle-dot run as committed text；violates fail-closed / non-commit spirit of L1.

**Required for clean close:** fail closed Return (and direct-text composition finalize) while `provisionalAhead`, **or** refuse to commit placeholder-only preedit；add wire test.

### P1-2 — D7 coalesce backlog + L1 case not co-joined in tests

**Finding:** Design D7 requires coalesce backlog + L1（L1 still paints on accept；L2 latest-only；no selection while ahead）. Implementation paints L1 on accept independently of coalesce（structurally plausible）but **no test** asserts L1 + dual-gate presentation coalesce together.

**Risk:** Coalesce + watermark interaction regressions slip past suite；D7 matrix over-claimed as fully green.

**Required:** dedicated Fake backlog test（pending≥threshold）asserting L1 dots while stalled **and** paint count / latest-only still held after flush.

### P2-1 — Progressive bar unit proof is slot/composition, not `source=provisional` count

D7 text: ≥ceil(N/2) accepts show `source=provisional` **before** matching L2 VISIBLE. Wire test asserts progressive **slots / `·`×N**, not marker lines. Tracker unit proves dual emission only for a single revision. Acceptable for length-authority north-star；**do not** claim D7 marker progressive bar fully unit-closed.

### P2-2 — Space / Path fail-closed not wire-tested

Code paths exist；only candidate selection is exercised under stall.

### P2-3 — Partial Commit has no dedicated `provisionalAhead` reject

Practical path is weak（chrome cleared；candidate gated）. Explicit D4 “Partial Commit fail closed” is not a single named guard.

### P2-4 — Suite process re-run not available in this review

Cannot independently confirm Executor **18/0** and **850/0** process exit codes. Static inventory supports **18** focused methods；**850** is arithmetic-consistent only. Close requires live re-run evidence.

### P3-1 — Delete v1 + L1 not tested

Path A frozen；residual only.

### P3-2 — Dual-gate non-T9 / 26-key L1 skip not wire-tested

### P3-3 — `L1_SKIP` reasons `gate_off` / `unsafe` unused in live paths

`no_dual` used instead of `gate_off` when gates off（and often suppressed）. Closed set remains content-free.

---

## Isolation / defaults scan

| Check | Result |
|---|---|
| `isResponsiveRimePipelineEnabled` default | `false` |
| `isThreadAffineRimeOwnerEnabled` default | `false` |
| L1 only on dual-gate accept path | **Yes**（`KeyboardController+RimeRecovery` affine branch） |
| Second live MainActor RIME session | **No** |
| `@unchecked Sendable` on Rem-3 surfaces | **0** |
| Path `provisionalPathID` API reuse | **No** |
| L1 never calls librime | **Yes**（pure ledger + host paint） |

---

## Explicit non-claims（Quality will not endorse）

This review **does not** claim, authorize, or partially satisfy:

1. Product Gate / Release readiness  
2. ADR 0025 **Accept**  
3. Dual-gate **default-on**  
4. Rem-3-Device / physical progressive A/B Pass  
5. Formal R5 FAIL rewritten  
6. Rem-Device PASS upgraded to Gate  
7. Numeric product SLO for lag / provisional share  
8. Architecture implementation Pass（separate role）  
9. “Independent Quality re-ran full suite 850/0” without a follow-up process re-run  
10. Complete fail-closed for Return / direct-text while L1 ahead  

Rem-3 implementation only proves（on code + unit design review）:

- dual-gate structure-only progressive length (`·`×N) while owner stalls  
- L2 atomic replace with revision floor  
- candidate fail-closed while ahead（unit）  
- Space/Path fail-closed（code）  
- gate-off has no L1（unit）  
- provisional→engine VISIBLE upgrade（unit）  
- defaults remain off  

---

## Conditions (must hold for this Pass to remain valid)

1. **No over-claim:** 不得将本 Pass 表述为 Product Gate、ADR Accept、default-on、device Pass、Formal R5 改判、或 “Return 在 L1 ahead 下也 fail-closed”。  
2. **Process re-run before suite-close:** 必须有独立进程输出 focused **18**（或当前实际）/0 与 full **850**（或当前实际）/0 的 `Executed … failures` 行；本文件 alone 不够。  
3. **P1-1 remediate or Product-accept residual:** Return/direct-text host-commit of `·` while ahead is a real fail-closed hole；clean close needs fix+test **or** explicit Product residual acceptance（not Gate language）。  
4. **P1-2 coalesce+L1 test** before claiming full D7 matrix closed.  
5. **Gates remain default-off** until separate Product knife.  
6. **Rem-3-Device** only if Product authorizes after implement green + dual review.

### Stop / escalate if

- Release 或用户设置 default-on dual-gate  
- 将本 Pass 写成 Product Gate  
- `@unchecked Sendable` 被引入 “修” L1  
- L1 向 host 泄 ASCII digits  
- L1 猜拼音/中文  
- 引擎 session 动作为 “追赶” 被 drop/reorder  
- dirty 树语义变更后仍引用本 Pass 而不 re-review  

---

## Owner handoffs

| Owner | Ask |
|---|---|
| 🧠 Executor / Input Intelligence | Fix **P1-1**（Return/direct-text fail-closed or placeholder non-commit）；add **P1-2** coalesce+L1 test；optional Space/Path/Return wire cases；optional assert `source=provisional` count for N≥8 |
| 🧪 Follow-up Quality / Environment Executor | Re-run the two `swift test` commands；record actual Executed/failures；if P1 fixes land, re-review |
| 🏛️ Architecture | Independent **implementation** architecture review still required（this file is Quality only） |
| 🧭 Product | Do **not** Gate / default-on / ADR Accept；optional accept P1-1 residual only with explicit language；Rem-3-Device only after dual implement reviews green |

---

## Final verdict

### **Pass with conditions**

| Item | Value |
|---|---|
| Verdict | **Pass with conditions** |
| P0 | **0** |
| P1 | **2**（Return/direct-text commit while ahead；D7 coalesce+L1 untested） |
| P2 | **4** |
| P3 | **3** |
| Focused tests（static inventory） | **18** methods in filter set |
| Focused tests（process re-run） | **not executed** |
| Full suite（Executor claim / arithmetic） | **850 / 0** claim；**not** process-re-run here |
| Product Gate / ADR Accept / default-on / device | **Not claimed** |

Rem-3 implements the frozen structure-only L1 north-star under dual-gate with honest unit proof of progressive length, L2 replace, gate-off, abandon, and candidate fail-closed. Residual fail-closed holes on Return/direct-text and incomplete D7 coalesce coverage keep this from an unconditional Pass. Suite process re-run remains a hard condition for knife close.

**Review path:**  
[`docs/assignments/t9-responsive-pipeline-001-r5-rem-3-implementation-quality-review.md`](t9-responsive-pipeline-001-r5-rem-3-implementation-quality-review.md)

---

*End of Rem-3 implementation Quality review — tip bind `9b9bbeb`；process suite re-run blocked in harness.*

---

## Addendum A — P1 remediation + parent-process suite (same day)

**Role:** Quality recording Executor fix + **parent process** suite re-run  
**Parent process commands:**

```text
swift test --package-path Packages/KeyboardCore --filter 'ResponsiveProvisional|ThreadAffineRimeWire'
→ Executed 17 tests, with 0 failures

swift test --package-path Packages/KeyboardCore
→ Executed 852 tests, with 0 failures
```

| Finding | Disposition |
|---|---|
| **P1-1** Return/direct-text host `·` | **Closed** + `testReturnWhileAheadDoesNotCommitDots` |
| **P1-2** coalesce+L1 missing test | **Closed** + `testCoalesceBacklogStillPaintsL1` |
| Suite re-run honesty | **Parent process 852/0** supersedes “blocked in harness” for this addendum |

Non-claims unchanged: no Product Gate / ADR Accept / default-on / device Pass.
