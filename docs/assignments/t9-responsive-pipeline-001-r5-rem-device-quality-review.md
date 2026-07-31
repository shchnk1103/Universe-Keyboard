# Quality Review: R5-Rem-Device (Human A/B direction evidence)

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（**independent** reviewer） |
| Date | 2026-07-31 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Design freeze | [`t9-responsive-pipeline-001-r5-remediation-design.md`](t9-responsive-pipeline-001-r5-remediation-design.md)（D3 felt metrics；§ Rem-Device phase） |
| Product authority | Rem-Device Human A/B after Arch P1-1 close（**not** Product Gate / ADR Accept / default-on / Rem-3） |
| Executor evidence under review | [`../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md) |
| FAIL baseline | [`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md) |
| Rem-1+2 + P1-1 predecessor | [`../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md)；Quality [`t9-responsive-pipeline-001-r5-rem-1-2-quality-review.md`](t9-responsive-pipeline-001-r5-rem-1-2-quality-review.md) |
| Scope | **R5-Rem-Device evidence only** — honesty of direction metrics / non-claims / unit green on Rem-1+2+P1-1 tree / teardown claim. **Not** re-implement. **Not** Architecture re-review. **Not** Product Gate. |
| Worktree tip at review | parent tip `87d3e7c9b6e3a4cb1bb4242a02679a667ba3aeb7`；Rem-1+2+P1-1 + device evidence **dirty / uncommitted** |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 0**  
**P2: 2**（immutable SHA 未绑定；device O2 coalesce 本 pair 几乎未触发）  
**P3: 3**（evidence gitignore；extension SHA 截断；teardown 仅 ledger claim）

---

## Scope

Independent Quality review of Executor **R5-Rem-Device** evidence against four required axes:

1. **Evidence honesty** — metrics tables match claimed **direction** (ACCEPT / VISIBLE / PUBLISH / BURST + subjective；**not** KEY END alone)  
2. **Non-claims held** — not Product Gate / ADR Accept / Release default-on / multi-pair robustness  
3. **Tests green** after Rem-1+2+P1-1 code — independent re-run, not trust Executor  
4. **Teardown claimed** — gate-off restore documented  

This review **re-ran** KeyboardCore focused and full suites. It did **not** re-install on device, re-type the fixture, or re-export logs. Device numbers are audited for **internal consistency and design alignment**, not physical re-measurement.

**Not in scope:**

- Re-implementation / code design Architecture Pass  
- Product Gate / Release-like matrix / multi-device  
- Rem-3 provisional L1  
- Rewriting Formal R5 FAIL as never-happened  
- Numeric product SLO lock  

---

## Verdict summary (four axes)

| Axis | Result | Notes |
|---|---|---|
| 1. Evidence honesty | **Held** | Direction tables use D3 markers + subjective; KEY END secondary; caveats (lag spikes, coalesced≈0, truncation, single pair, Debug) explicit |
| 2. Non-claims held | **Held** | Status / Non-claims / Product disposition all refuse Gate / ADR Accept / default-on / multi-pair |
| 3. Tests green (Rem-1+2+P1-1 tree) | **Held** | Independent: focused **26/0**；full **842/0** |
| 4. Teardown claimed | **Held (claim-level)** | Ledger: Done ~13:47 `dualGate=false` + Arm A binary；**not** re-verified on device this review |

### **Pass with conditions**

Rem-Device direction **PASS** claim is **honest relative to the documented single Debug pair** and does **not** overreach into Product Gate. Unit suite on the dirty Rem-1+2+P1-1 tree is green. Conditions below keep this Pass from being misread as Gate or immutable close.

---

## Commands re-run (authoritative for this review)

Environment:

| Item | Value |
|---|---|
| Host | macOS arm64 |
| Module cache | `SWIFTPM_MODULECACHE_OVERRIDE=/tmp/uk-qd-swift`；`CLANG_MODULE_CACHE_PATH=/tmp/uk-qd-clang` |
| Wall clock | 2026-07-31 ~13:51 CST |
| Parent tip | `87d3e7c9b6e3a4cb1bb4242a02679a667ba3aeb7` |

### 1) KeyboardCore focused (felt + wire + R2)

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard"
export SWIFTPM_MODULECACHE_OVERRIDE=/tmp/uk-qd-swift CLANG_MODULE_CACHE_PATH=/tmp/uk-qd-clang
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveRimeFeltMetricsTests|ThreadAffineRimeWireTests|ResponsiveRimeR2CoordinatorTests'
```

| Suite | Executed | Failures | Notes |
|---|---:|---:|---|
| `ResponsiveRimeFeltMetricsTests` | **3** | **0** | lag / content-free / tracker+burst |
| `ResponsiveRimeR2CoordinatorTests` | **16** | **0** | includes latestOnly burst paint |
| `ThreadAffineRimeWireTests` | **7** | **0** | includes dual-gate coalesce + **P1-1 abandon** |
| **Selected tests total** | **26** | **0** | |

```text
Test Suite 'Selected tests' passed
Executed 26 tests, with 0 failures (0 unexpected) in 0.727 (0.734) seconds
```

### 2) KeyboardCore full package

```bash
export SWIFTPM_MODULECACHE_OVERRIDE=/tmp/uk-qd-swift CLANG_MODULE_CACHE_PATH=/tmp/uk-qd-clang
swift test --package-path Packages/KeyboardCore
```

| Suite | Executed | Failures |
|---|---:|---:|
| `KeyboardCoreTests` / All tests | **842** | **0** |

```text
Test Suite 'KeyboardCoreTests.xctest' passed
Executed 842 tests, with 0 failures (0 unexpected) in 5.042 (5.138) seconds
Test Suite 'All tests' passed
Executed 842 tests, with 0 failures (0 unexpected) in 5.042 (5.140) seconds
```

**Count note vs Rem-1+2 Quality baseline:** prior full was **841/0**（Wire **6**）；P1-1 abandon test brings Wire **7** and full **842**. Focused filter for this review intentionally omits `ResponsiveRimePipelineTests`（per task command）→ **26** not **48**.

---

## Axis 1 — Evidence honesty (metrics vs direction)

### Design direction metrics (mandatory for dual-gate)

From remediation design D3 / device evidence plan:

| Required | Must use for dual-gate direction? |
|---|---|
| ACCEPT + pending | Yes |
| VISIBLE lagMs | Yes（accept→visible） |
| PUBLISH lagMs / coalesced / BURST | Yes |
| Subjective stall | Yes |
| KEY END total alone | **No**（Formal R5 lesson） |

### Extracted pair (evidence tables)

| Metric | Arm A (gate-off) | Arm B (dual-gate + Rem-1/2) | Direction read |
|---|---|---|---|
| Integrity | OK | OK | Pass both |
| Subjective stall | **~2** | **~0–1** | **B better** |
| Freeze-then-burst | no | **no**（vs Formal B severity **4**） | **B improved vs Formal FAIL** |
| KEY END ≥100 / worst | **4** / **211.1 ms** | **0** / **2.3 ms** | Expected dual-gate；**not primary** — evidence correctly demotes |
| VISIBLE lagMs | n/a | n=25 · mean **50.5** · p50 **11** · p95 **202** · worst **246** · ≥100 **5** | Result lag **honestly retained** |
| PUBLISH lagMs | n/a | n=25 · mean **50.4** · p50 **11** · p95 **202** · worst **246** · ≥100 **5** | Aligns with VISIBLE |
| BURST | n/a | **1** line `count=3 windowMs=50` | Mild；**not** Formal catch-up storm |
| coalesced=1 | n/a | **0**（all observed paints `coalesced=0`） | O2 threshold rarely engaged this pair |
| SLOW RIME | in KEY END | **4** peaks ~190–246 ms off KEY END | Cost moved, not removed — stated |
| Large idle / freeze-burst | — | **Not observed** | Contrasts Formal B idleMs ≈ **5025** |

### Consistency with claimed **Rem-Device direction: PASS**

| Claim in evidence | Supported by tables? | Honesty |
|---|---|---|
| B key-feel better than A (subjective) | Yes（~2 → ~0–1） | Held；single Human pair |
| No Formal-style freeze-then-burst on B | Yes（no multi-second idle；BURST mild） | Held vs Formal FAIL baseline |
| Direction supports dual-gate **key feel** | Yes relative A and Formal B | Held **with caveats** |
| Result lag still real | Yes（VISIBLE/PUBLISH spikes 190–246 ms） | **Honest** — not claimed away |
| KEY END not primary success metric | Explicit “context only” / “not primary” | **Held** — design-aligned |
| O2 coalesce drove the win | **Not claimed as primary**；caveat: win may be accept-without-wait + no storm | **Held** — avoids false O2 device proof |
| Formal R5 FAIL remains historically true | Explicit comparison section | **Held** |
| Product Gate | Explicitly **not** claimed | **Held**（Axis 2） |

### Comparison block vs Formal R5 FAIL (same device / fixture family)

| | Formal R5 B | Rem-Device B | Evidence honesty |
|---|---|---|---|
| Subjective | stall **4** freeze-then-burst | stall **~0–1** progressive | Plausible successor knife claim |
| KEY END | ~1 ms | ~1 ms | Correctly **not** the differentiator |
| Catch-up burst | severe（many PUBLISH &lt;50 ms after stall） | not observed | Supported by BURST=1×count=3 + no idle claim |
| Felt markers | absent | present with lag spikes | Rem-1 value demonstrated |

**Status wording check:**  
“Formal R5 FAIL superseded for dual-gate *key feel* only” is acceptable **only** if read as: *this successor pair shows improved key-feel direction*, **not** as “Formal FAIL was measurement error.” Evidence also states Formal FAIL remains historically true for that build — **net honest**.

### Truncation / sample integrity

| Issue | Evidence handling | Quality read |
|---|---|---|
| Diagnostics ~500 lines；early PATH/ACCEPT may missing | Explicit caveat | Acceptable stop-fast；does not invent missing lines |
| ACCEPT **24** observed；rev up to **39** | Truncation + continuous markers claimed | Consistent with truncated paste |
| VISIBLE/PUBLISH n=**25** | After truncate | Internally consistent with KEY END n=25 on B |
| Arm PATH line missing on B head | “path proven by markers + install” | Same class as Formal R5 B；acceptable if install hashes + dual-gate markers present |

**Axis 1 conclusion: Held.** Metrics tables support direction PASS; primary dual-gate felt metrics used; KEY END demoted; residual lag and coalesce-miss stated.

---

## Axis 2 — Non-claims held (not Product Gate)

Evidence **Non-claims** section and Status header refuse:

| Forbidden claim | Present as claim? | Present as non-claim? |
|---|---|---|
| Product Gate | No | Yes |
| Release default-on | No | Yes |
| ADR 0025 Accept | No | Yes |
| R6 | No | Yes |
| Numeric product SLO | No | Yes |
| Multi-device / multi-pair robustness | No | Yes（single pair stop-fast） |
| Rem-3 L1 complete | No | Yes |
| “VISIBLE lag always low” | No | Yes（spikes 190–246 ms） |
| Debug ⇒ Release conclusion | No | Caveat “Debug only” |

Product disposition row: Rem-Device **Closed direction PASS**；**not** Product Gate / default-on / ADR Accept.

**Axis 2 conclusion: Held.** No Product Gate smuggling.

---

## Axis 3 — Tests green after Rem-1+2+P1-1

| Suite | Independent | Failures |
|---|---:|---:|
| Focused (Felt+Wire+R2) | **26** | **0** |
| KeyboardCore full | **842** | **0** |

Code tree at review includes Rem-1 felt metrics, Rem-2 coalesce/latestOnly, P1-1 generation/epoch fail-closed abandon test — all exercised by the filter and full suite.

**Axis 3 conclusion: Held.**

---

## Axis 4 — Teardown claimed

| Step | Evidence ledger |
|---|---|
| Build A/B | BUILD SUCCEEDED |
| Install A → Human A | Done ~13:43 |
| Install B → Human B | Done ~13:44 / ~13:45 |
| Teardown gate-off | **Done ~13:47**（`dualGate=false` + Arm A binary） |
| Device disposition | Restored **gate-off** Debug + `dualGate=false` |

Independent Quality **did not** re-query device App Group key or re-install. Teardown is **claim-level Pass** matching Formal R5 evidence style.

**Axis 4 conclusion: Held (claim-level).** Residual P3 if Product requires operator re-confirm.

---

## Residuals

### P2 — Worktree honesty（no immutable Rem-Device / Rem-1+2 SHA）

At review time parent tip remains **`87d3e7c`**（R5-Preflight）. Rem-1+2+P1-1 sources/tests and Rem-Device evidence are **dirty / untracked or modified**. Device arm binaries differ from Formal R5 hashes（expected）but are not bound to a clean implementation SHA.

**Condition:** This Pass binds to **this dirty tree + this evidence file content**. Semantic code or evidence change requires re-review. Product/Executor should create an immutable checkpoint SHA before treating the knife as permanently closed.

### P2 — Device pair did not exercise O2 coalesce（`coalesced=0`）

Evidence correctly states pending rarely ≥2 at paint time and O2 threshold was rarely engaged. Direction win is therefore **not** device proof that presentation coalesce fires under Formal-style backlog；it is proof that **this pair** felt better and lacked freeze-then-burst. Unit tests still cover coalesce under owner backlog.

**Condition:** Do not cite this Rem-Device pair as “O2 coalesce validated on device.” Cite as dual-gate key-feel direction after Rem-1+2+P1-1 code, with progressive result lag still present.

### P3 — Evidence path gitignored

`git check-ignore` reports `docs/evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md` ignored by `evidence/` rule. Versioning needs `git add -f` or ignore-policy change.

### P3 — Extension SHA256 truncated in ledger

Arm A/B hashes shown abbreviated（`81909d3…` / `86fadce…`）. Formal R5 used full digests. Acceptable for stop-fast direction；weaker for forensic install binding.

### P3 — Teardown not re-verified on device

Ledger claim only（same class as Formal R5 Quality practice）.

### Carry-forward（not reopen of this knife）

- Formal R5 FAIL remains closed as FAIL for **that** build  
- Rem-3 provisional L1 still absent — long stall may still blank until L2（this pair: progressive lag, not multi-second freeze）  
- ADR 0025 remains **Proposed**  
- Dirty-tree review ≠ immutable SHA-bound close  
- Single Debug pair ≠ Product Gate  

---

## Explicit non-claims（Quality will not endorse）

This review **does not** claim, authorize, or partially satisfy:

1. Product Gate / Release default-on / user-facing dual-gate settings  
2. ADR 0025 **Accept**  
3. Formal R5 FAIL rewritten as never true  
4. Multi-pair / multi-device / Release-like robustness  
5. Numeric product SLO on VISIBLE/PUBLISH lag or coalesce threshold  
6. Rem-3 provisional L1 complete  
7. “VISIBLE lag always low” or “librime is faster”  
8. Device O2 coalesce exercised（`coalesced=0` this pair）  
9. Physical re-run of Human A/B by Quality  
10. Dirty-tree evidence equals immutable SHA-bound close  

R5-Rem-Device evidence only supports（under independent audit）:

- Single Debug Human pair A→B on Rem-1+2+P1-1 dirty tree  
- Direction metrics used correctly（not KEY END-only）  
- Subjective key-feel B better；no Formal-style freeze-then-burst  
- Result lag spikes still real and disclosed  
- Non-claims refuse Product Gate  
- Teardown **claimed**  
- Unit: focused **26/0**；full **842/0**  

---

## Verdict

### **Pass with conditions**

| Axis | Status |
|---|---|
| Evidence honesty | **Pass** |
| Non-claims held | **Pass** |
| Tests green | **Pass**（26/0 · 842/0） |
| Teardown claimed | **Pass**（claim-level） |

Authorized Rem-Device **direction PASS** is **honest** for the documented single Debug pair and is **not** a Product Gate.

### Conditions (must hold for this Pass to remain valid)

1. **No over-claim:** 不得将本 Pass 表述为 Product Gate、ADR Accept、Release default-on、Rem-3 完成、multi-pair 稳健、或 Formal R5 FAIL 作废。  
2. **Formal R5 FAIL remains historical truth** for pre-Rem dual-gate build；本 knife 仅证明 **Rem 后** 同设备 fixture 家族 key-feel **direction** 改善。  
3. **Immutable SHA bind** before permanent close；dirty 语义变更则 re-review。  
4. **O2 device residual explicit:** 本 pair `coalesced=0` — 不作为 device coalesce 证明。  
5. **Result lag residual explicit:** VISIBLE/PUBLISH spikes ~190–246 ms 仍在；产品若要 “零空白 lag” 需另授权 Rem-3 或后续 knife。  
6. **Gates remain default-off** until new Product authorization.  

### Stop / escalate if

- 将 Rem-Device direction PASS 当作 Product Gate 或 default-on  
- 用 KEY END ~1 ms 单独宣称 “不卡”  
- 忽略 VISIBLE lag spikes 宣称 “lag 已解决”  
- Silent 塞入 Rem-3 并 claim 完成  
- Engine session drop/reorder 以 “追赶”  
- Teardown 未执行却宣称 Closed  

---

## Handoff

| To | Payload |
|---|---|
| 🧭 Product | Verdict **Pass with conditions**；Rem-Device direction **PASS** 证据诚实；**not** Gate；可选 dual Arch review；Rem-3 only if product wants lower blank lag under stall |
| 🏛️ Architecture | Felt markers live on device；O2 coalesce 本 pair 未触发；L1 still absent but key-feel direction held this pair |
| 🔧 Executor | `git add -f` evidence if versioning；full extension SHA；immutable SHA for Rem-1+2+P1-1+device tree |
| 🧪 (self) | Review artifact: this file |

---

## Appendix — machine lines (independent)

```text
# Focused
Test Suite 'ResponsiveRimeFeltMetricsTests' passed
Executed 3 tests, with 0 failures (0 unexpected)
Test Suite 'ResponsiveRimeR2CoordinatorTests' passed
Executed 16 tests, with 0 failures (0 unexpected)
Test Suite 'ThreadAffineRimeWireTests' passed
Executed 7 tests, with 0 failures (0 unexpected)
Test Suite 'Selected tests' passed
Executed 26 tests, with 0 failures (0 unexpected) in 0.727 (0.734) seconds

# Full
Test Suite 'KeyboardCoreTests.xctest' passed
Executed 842 tests, with 0 failures (0 unexpected) in 5.042 (5.138) seconds
Test Suite 'All tests' passed
Executed 842 tests, with 0 failures (0 unexpected) in 5.042 (5.140) seconds
```

## Appendix — counts

| Suite | Independent re-run |
|---|---:|
| Focused (Felt+Wire+R2) | **26 / 0** |
| KeyboardCore full | **842 / 0** |
| P0 | **0** |
| P1 | **0** |
| P2 | **2** |
| P3 | **3** |

**Verdict file path:**  
`/Users/doubleshy0n/Dev/Universe Keyboard/docs/assignments/t9-responsive-pipeline-001-r5-rem-device-quality-review.md`
