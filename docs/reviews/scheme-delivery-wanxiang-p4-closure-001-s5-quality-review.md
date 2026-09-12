# SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001 — S5 Independent Quality Review (narrow Exit)

## Review identity

| Field | Value |
|---|---|
| Reviewer | Independent Quality（read-only; this review session） |
| Date / timezone | `2026-09-12 Asia/Shanghai` |
| Code freeze | `72b5987dc4434221f4b4aa57c836369723bd7fb9` (`72b5987`) on `codex/scheme-platform-001` — Scheme Platform P3 Exit certify tip；Wanxiang on platform: `privatePreset` `wanxiang_preset`、plan2/post2、`exactHash` |
| Docs tip at review start | `0b552a3`（Resume + E16/E17/E20 disposition）— already pushed；本 S5 review commit = new tip after `0b552a3` |
| Assignment | [`SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001`](../assignments/scheme-delivery-wanxiang-p4-closure-001.md) — Lifecycle **Active（Resumed）** |
| Checklist / gaps / disposition | [`checklist`](../evidence/scheme-delivery-wanxiang-p4-closure-checklist-2026-09-09.md) · [`gaps`](../evidence/scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md) · [`E16/E17/E20 disposition`](../evidence/scheme-delivery-wanxiang-p4-e16-e17-e20-disposition-2026-09-12.md) |
| Platform | [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) — stays **Active**（P3 Exit certified；no Close） |
| Prior IQ | upgrade-rollback [Pass with conditions](scheme-delivery-wanxiang-upgrade-rollback-quality-2026-09-08.md)（`Q-UR-P2-01` Closed）；[P1 platform IQ](scheme-delivery-scheme-platform-001-p1-quality-review.md) Pass with conditions；lua ownership + cross-scheme CS reviews on `main` |
| Independence | 生产 Swift **只读**。未为 Pass 改代码或弱化测试。唯一写入：本审查文件 + Assignment / checklist / gaps / ACTIVE_WORK / platform · KOS 治理联动（S5 docs）。**未**改 Architecture Accept review A34-R1 为 Closed（那是 S6）。 |
| Scope | **Narrow Wanxiang P4 closure / A34-R1 fix path** only（E01–E28 Exit 映射；汇总无开放 P0/P1 于本片范围）。**不是** ADR Accept；**不是** A34-R1 Closed；**不是** Product Gate / TF；**不是** device failure-rollback attested；leave #101。 |

**HEAD 核对（review start）：** `git rev-parse HEAD` = `0b552a3a48ddc1cedef09fe3f3a7320f385283ff`；code freeze subject = `72b5987`。`.codex-p4-wip.patch` 保持 **untracked**（不纳入本审查 / 不 commit）。

---

## Verdict

**Pass with conditions**

Narrow Wanxiang P4 closure on code freeze `72b5987` meets Independent Quality for this Exit delta: **no open P0 / P1 findings in narrow P4 closure scope**. Engineering slices already on tip（skip `default.yaml`；exact-hash Lua ownership；upgrade-rollback；cross-scheme matrix automation；platform Wanxiang `privatePreset` / plan2/post2）align with checklist Closed（evidence）items E01–E13 / E18 / E19。Human **Accepted（narrow Exit）** for E16/E17/E20（cite disposition）。本 review **addresses E15**。

Finding counts at freeze `72b5987`（narrow scope）：**P0: 0 · P1: 0 · P2: 1 · P3: 3**（见 Findings / Residuals；均有显式 disposition，**未**静默关闭）。

本 Verdict：

- **不是** ADR 0034 Accept；leave draft **#101** alone；
- **不是** A34-R1 Closed / Done（E14 / S6 still needed；**do not silent-close**）；
- **不是** Product Gate / TestFlight / App Release / Device-attested failure-rollback；
- **不是** Assignment Exit Criteria 全部满足 → **不** Close Wanxiang P4 Assignment；**不** Close Platform Assignment；
- E16/E17/E20 = Human-accepted **narrow** — **不**等同 device evidence Closed。

### Conditions（保持有效方可维持 Pass with conditions）

1. Hosted CI on code freeze `72b5987` — run [`34676751887`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/34676751887) **attempt 2** full success：`classify-change` / `lightweight-checks` / `build-and-test` / `final-quality-gate` / GitGuardian。Attempt 1 failed on flake `DiagnosticsJournalRetentionSchedulerTests.testSchedulerReturnsBeforeRunningReclaimAndCoalescesConcurrentRequests` then re-run succeeded — residual **WX-P4-S5-IQ-01** `accept`（flake；同 SP-P1-IQ-02 风格，**not** silent）。
2. IQ **未**独立重跑全量 `xcodebuild` / Simulator suite；采信 prior-slice IQ + 上述 hosted CI + 只读生产抽样（**WX-P4-S5-IQ-02**）。
3. E14 writeback / A34-R1 仍 open until Human-authorized **S6**；E16/E17/E20 保持 Accepted（narrow）限度；不把条件项静默写成 Closed。

---

## Method

**Read-only** code/test review + prior IQ + hosted CI evidence.

| Done this session | Not re-run locally |
|---|---|
| Read gaps / checklist / disposition / Assignment / P1 IQ template / upgrade-rollback IQ | Local `xcodebuild` / full App+Keyboard / CS matrix / NineKey |
| Spot-check freeze production：`RimeWanxiangSharedDefaultAdapter`（`privatePreset` / `wanxiang_preset`）；`SchemeAdapter` Wanxiang `exactHash` + `wanxiang-post-2`；`ExactHashResourceOwnershipStrategy` `wanxiang-plan-2`；`SchemaManagerTypes` `skippedFiles` 含 `default.yaml` + admits `wanxiang_preset.yaml` | Local `swift-format` |
| Hosted CI run `34676751887` attempt 1 failure log + attempt 2 success + GitGuardian check-run | Device failure-rollback；App Group full-path transaction |
| Map E01–E28 from checklist；confirm E16/E17/E20 disposition file | Architecture Accept review status rewrite（forbidden until S6） |

---

## Exit checklist map（E01–E28）— S5 disposition

Source statuses from [`scheme-delivery-wanxiang-p4-closure-checklist-2026-09-09.md`](../evidence/scheme-delivery-wanxiang-p4-closure-checklist-2026-09-09.md)；S5 only flips **E15**.

| # | Exit status after S5 | Note |
|---|---|---|
| E01–E13 | **Closed（evidence）** | Unchanged；freeze spot-check still supports skip `default.yaml` / ownership / upgrade-rollback / CS automation / no whole-dir wipe |
| **E14** | **Open — writeback path** | Still open for **S6** A34-R1 disposition writeback + Human auth；**not** closed by S5 |
| **E15** | **Closed（evidence）** | Addressed by **this** Independent Quality review — no open P0/P1 in narrow scope；Pass with conditions |
| E16 | **Accepted (narrow Exit)** | Human `2026-09-12`；[disposition](../evidence/scheme-delivery-wanxiang-p4-e16-e17-e20-disposition-2026-09-12.md) |
| E17 | **Accepted (narrow Exit)** | Same disposition |
| E18–E19 | **Closed（evidence）** | Unchanged |
| E20 | **Accepted (narrow Exit)** | Same disposition |
| E21–E28 | **Out-of-scope** | Unchanged（含 ADR Accept / PG / TF / Recovery / Ice dofile / RTRD / pin change） |

### Counts after S5

| Exit status | Count |
|---|---|
| **Closed（evidence）** | 17（E01–E13, E15, E18, E19） |
| **Open — writeback path** | 1（E14） |
| **Open — IQ** | 0 |
| **Accepted (narrow Exit)** | 3（E16, E17, E20） |
| **Out-of-scope** | 7（E21–E28）+ platform extract |

---

## Findings

### WX-P4-S5-IQ-01 — Hosted CI attempt-1 flake on unrelated Diagnostics scheduler test

**Severity: P2（environment / flake）**

Run [`34676751887`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/34676751887) on `72b5987`：**attempt 1** `build-and-test` failed on `DiagnosticsJournalRetentionSchedulerTests.testSchedulerReturnsBeforeRunningReclaimAndCoalescesConcurrentRequests`（`XCTAssertTrue failed`）— **not** Wanxiang / scheme-delivery path。**Attempt 2**（re-run）full success：classify / lightweight / build-and-test / final-quality-gate；GitGuardian check-run **success**.

**Disposition:** `accept` as residual flake（same honesty class as **SP-P1-IQ-02**）— Owner: Env Executor / Quality。**Not** silent；does **not** rewrite Verdict to unconditional Pass。Machine gate for this freeze = attempt-2 green + GitGuardian.

### WX-P4-S5-IQ-02 — IQ did not re-run local xcodebuild

**Severity: P3（process）**

Docs-only S5 slice：no local format / xcodebuild re-execution this session.

**Disposition:** `accept` — machine evidence = hosted CI on `72b5987` + prior slice IQ + source spot-check. Same class as SP-P1-IQ-06 / prior scheme-delivery IQ practice.

### WX-P4-S5-IQ-03 — E14 / A34-R1 still open（governance）

**Severity: P3（scope / non-claim）**

S5 closes **E15** only。E14 writeback path and Architecture residual **A34-R1** remain **open** until Human-authorized **S6**。**Do not** silent-close A34-R1；**do not** Accept ADR 0034；leave #101.

**Disposition:** `open` — Owner: Product Lead / Architecture（S6）。Explicitly **not** closed by this IQ.

### WX-P4-S5-IQ-04 — Device failure-rollback / App Group full-path not attested

**Severity: P3（scope / Human narrow）**

E16/E17/E20 Human **Accepted（narrow Exit）**：no device failure-rollback required；keep Pass-with-conditions App Group限度。This IQ does **not** claim device attestation.

**Disposition:** `accept` per Human disposition `2026-09-12` — Owner: Product Lead。Re-open only if Human later authorizes Device / extra evidence.

---

## Residuals table（explicit； no silent close）

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `WX-P4-S5-IQ-01` | Env Executor / Quality | `accept` | Hosted CI flake attempt 1 → attempt 2 green on run `34676751887` @ `72b5987` |
| `WX-P4-S5-IQ-02` | Quality (this review) | `accept` | No local xcodebuild re-run |
| `WX-P4-S5-IQ-03` | Product Lead / Architecture | `open` | E14 + A34-R1 until S6；no ADR Accept；leave #101 |
| `WX-P4-S5-IQ-04` | Product Lead | `accept` | E16/E17/E20 narrow；no device failure-rollback claimed |
| E14 | Wanxiang P4 / Human | `open` | S6 writeback awaiting Human |
| A34-R1 | Architecture Accept residual | `open`（`fix` until S6） | **Do not silent-close** |
| A34-R2 / TD-011 / RTRD-* | parallel debt | `open` | Out of narrow P4 |
| Platform Assignment | Product Lead | keep **Active** | P3 Exit certified ≠ Close |

---

## Explicit non-claims

- Not ADR 0034 Accept； leave draft **#101** alone； keep #101 ≠ #102
- Not A34-R1 Closed / Done； not Architecture Accept review rewrite
- Not Product Gate Passed； not Device-attested failure-rollback； not TestFlight / App Release
- Not Wanxiang P4 Assignment Closed； not Platform Assignment Closed
- E16/E17/E20 Accepted（narrow）≠ device evidence Closed ≠ A34-R1 Closed
- Not a claim that IQ re-ran full local suites / CS matrix / NineKey
- Production Swift unchanged by this review
- Hosted CI flake residual recorded explicitly（not silent greenwash）

---

## Handoff

1. Close **E15** on checklist / Assignment Current Status； cite this review； **keep** Wanxiang P4 **Active**.
2. Next：**S6** A34-R1 disposition writeback — **awaiting Human auth**； still **no** ADR Accept； still **do not** silent-close A34-R1 before S6.
3. Platform stays **Active**（P3 Exit certified； no Close）。
4. **Ask Human before push** of this S5 docs tip； leave #101； no undraft/merge #102 without auth.
5. Do **not** start Product Gate / TF / Assignment Close from this file alone.
