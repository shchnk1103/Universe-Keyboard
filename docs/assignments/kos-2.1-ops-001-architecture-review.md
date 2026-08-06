# KOS-2.1-OPS-001 — Architecture Review (design package)

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-06 Asia/Shanghai` |
| **Reviewer role** | 🏛️ Architecture & Knowledge Steward |
| **Independence note** | Design draft was Executor-authored under Steward domain; this review is a **deliberate second pass** against frozen 2.0, not a rubber stamp. It is **not** Product Review and **not** 2.1 Accept. |
| **Objects** | [`PD-KOS-2.1-OPS-001`](../product-decisions/KOS-2.1-OPS-001-authorization.md) · [`Assignment`](kos-2.1-ops-001.md) · [`design draft`](../kos/kos-2.1-ops-design-draft.md) |
| **Frozen SoT** | [`knowledge-os-2.0-specification.md`](../kos/knowledge-os-2.0-specification.md) |
| **Verdict** | **Pass with conditions** — design package is fit for Product Review |
| **Finding counts** | **P0: 0 · P1: 2 · P2: 3 · P3: 2** |

## 1. Verdict summary

The design package is **architecturally sound as a 2.1 *ops maturity* direction**:

- Pain inventory matches real post-MIG failure modes (status drift, history pollution, stack merge, residual soft-close, evidence grade ambiguity).  
- Goals preserve single-track 2.0 and authority separation.  
- Must items are mostly **operational / template / Contract-light**, consistent with “no Migration required.”  
- Non-goals correctly block 3.0, dual-track, and side-effect migration.  

**Not Accept of Knowledge OS 2.1.** Architecture only clears the **design package** for Product disposition, with conditions that should be resolved in the draft or bound into any IMPL Assignment.

## 2. Alignment with Knowledge OS 2.0 frozen principles

| # | Principle | Design package | Arch |
|---|---|---|---|
| 1 | Single owning SoT | M-01/M-05 strengthen current status ownership; Dashboard must not invent | **Pass** |
| 2 | Navigation links, no competing rules | Active Summary + Index links; risk if Summary duplicates Assignment facts | **Pass with condition** (A-P2-01) |
| 3 | Authority separation | Preserved; S-01 risks blurring review independence | **Pass with condition** (A-P1-01) |
| 4 | Assignment ≠ permanent roles | Unchanged | **Pass** |
| 5 | Lifecycle vs phase | Current Status block supports phase clarity | **Pass** |
| 6 | Declare change type | Follow-on IMPL still required to declare types | **Pass** |
| 7 | Migration assigned | §6 recommends no Migration for Must; correct | **Pass** |
| 8 | Conversation ≠ truth | Unchanged | **Pass** |
| 9 | UNKNOWN stops | Unchanged | **Pass** |
| 10 | Validation reports gaps | Evidence grades (M-04) strengthen this | **Pass** |

**Conclusion:** No proposal in Must **requires** rewriting the ten principles. Optional frozen impact is limited to Assignment Policy **templates/addenda**, not principle text.

## 3. Pain inventory quality

| Check | Result |
|---|---|
| Pains are operational, not product-runtime | **Pass** |
| Severity roughly ranked | **Pass** |
| “What is not a pain” protects 2.0 core | **Pass** — essential |
| Completeness | **Adequate** for design; optional add: multi-agent concurrent Assignment collision (P-11 candidate) |

No P0 on inventory honesty.

## 4. Must / Should / Could architecture assessment

### Must — endorse for Product Accept → IMPL

| ID | Arch view |
|---|---|
| **M-01 Current Status block** | **Endorse.** Highest leverage against P-02. Require: only **current** lifecycle, phase, non-claims, next handoff; forbid restating full history. Owner: Assignment Policy template + PD template. |
| **M-02 State sync checklist** | **Endorse.** Maps to Program Manager completeness duty without giving PM decision authority. Must list **minimum sync set** and **who runs it** (Executor vs PM). |
| **M-03 Residual disposition** | **Endorse with rule freeze (A-P1-02).** Prefer: close requires each residual `fix` \| `accept` \| `tech_debt:<id>`; open residuals without TECH_DEBT **block Close**. |
| **M-04 Evidence grades** | **Endorse.** Three grades are enough; do not invent “Quality-recorded without re-run.” Grade must appear on validation tables in evidence docs. |
| **M-05 Active Work Summary** | **Endorse with SoT rule (A-P2-01).** Summary **links** to Assignments; may quote only Current Status fields; **Assignment remains lifecycle SoT**. Cap **N = 10** (Architecture recommendation; Product may choose 7). |

### Should — conditional endorse

| ID | Arch view |
|---|---|
| **S-01 Lightweight State path** | **Conditional (A-P1-01).** Acceptable **only** with a hard allowlist: change type `State` only; no Contract/Implementation/Evidence/ADR/PD claim changes; explicit Work Order or tiny Assignment; Program Manager completeness check **required**; random dual-review still allowed. **Forbidden:** using S-01 to skip Arch when ADR/gate language changes. |
| **S-02 Stacked PR convention** | **Endorse.** Belongs in `AI_WORKFLOW.md`; not frozen KOS. Prefer tip-merge + supersede language (as used on #39–#42). |
| **S-03 Supersession banners** | **Endorse.** Reduces AI misread; PD authoring convention. |
| **S-04 Archive convention** | **Endorse without Migration** if limited to naming/index file; **folder moves = Migration Assignment**. |

### Could — defer

| ID | Arch view |
|---|---|
| **C-01 Status linter** | Valuable; **defer** from Must. If scheduled, separate tooling Assignment; not governance freeze. |
| **C-02 Auto Active Work** | Defer until M-05 stable. |
| **C-03 Conditional ADR status token** | **Do not add** unless DOCUMENTATION_GOVERNANCE proves Accepted+residuals is failing. Extra status tokens increase ambiguity. |
| **C-04 Prompt pack** | Operational; may follow M-05 without 2.1 version bump. |

## 5. Migration readiness

Architecture **agrees** with draft §6:

- Must items **do not require** Migration.  
- Migration warranted for archive **tree moves**, bulk front-matter backfill, domain tree reorg.  
- Dual-track must remain **forbidden**.  

**No Migration Assignment is authorized by this review.**

## 6. Findings

### P0

None.

### P1

#### A-P1-01 — S-01 lightweight path can erode review independence

If “skip dual review” is unbounded, Executors will classify convenience edits as State-only.

**Condition for Product Accept of S-01:** publish an allowlist + stop list in IMPL Assignment before use. Architecture recommends **Must path first without S-01**, then S-01 in a second IMPL slice.

#### A-P1-02 — M-03 residual close rule must be binary and named

“Force residual disposition” without defining whether open `tech_debt` allows Close will re-create soft closes.

**Architecture freeze for IMPL:**

| Disposition | Close allowed? |
|---|---|
| `fix` (with evidence pointer) | Yes |
| `accept` (named residual, non-blocking by design) | Yes if listed in final residual table |
| `tech_debt:<ID>` in `TECH_DEBT.md` | Yes |
| Missing disposition | **No Close** |

### P2

#### A-P2-01 — Active Work Summary must not become competing SoT

Dashboard already drifts. A new Summary that restates lifecycle will become a third status surface.

**Rule:** Summary may only link + copy Current Status block fields; conflicts → Assignment wins; fix Summary.

#### A-P2-02 — Owner-doc column underspecifies Policy vs ops split

M-01/M-03 touch Assignment Policy; M-02/M-05 touch ops. IMPL must declare **which files are Contract** vs **Documentation/State** per change type.

#### A-P2-03 — Draft should name “2.1” carefully

“Knowledge OS 2.1” risks readers treating ops package as frozen-spec bump. Prefer product language:

- **Preferred:** “KOS 2.1 Operational Maturity package (ops track under 2.0)”  
- **If version bump of frozen file:** requires separate Contract Assignment and explicit `2.1.0` frozen doc — **not** in design-only phase.

Architecture recommends **no frozen file version bump** in first IMPL (ops + templates only).

### P3

#### A-P3-01 — Open question answers (Architecture recommendations)

| Q | Architecture recommendation |
|---|---|
| Active Work cap N | **10** (7 if Product wants stricter) |
| S-01 | **Defer to second IMPL**; not in Must |
| Residual close | **Hard blocker** unless `accept` or `tech_debt:ID` |
| Status linter | **Could**; not Must |

#### A-P3-02 — Optional pain P-11

Concurrent multi-agent Assignments on same SoT without revalidation. Out of scope unless Product expands design.

## 7. Stop Conditions check (Assignment)

| Stop | Triggered? |
|---|---|
| Treat draft as Accepted 2.1 | **No** — review explicitly forbids |
| Start Migration / frozen rewrite under this Assignment | **No** |
| Runtime code | **No** |
| Dual-track language | **No** |

## 8. Recommended Product disposition

Architecture recommends Product Review select:

> **Accept design → implement Must (M-01…M-05) only**, with Architecture conditions A-P1-02 and A-P2-01/02/03 bound into `KOS-2.1-OPS-IMPL-001`.  
> **Defer S-01** to a later slice.  
> **Include S-02/S-03** if capacity allows (low risk).  
> **Do not** Accept 2.1 as frozen-track replacement; **do not** open Migration.

Alternative acceptable: **Accept Must + S-02 + S-03** without S-01.

## 9. Explicit non-claims of this review

- Not Knowledge OS 2.1 Accepted  
- Not authorization of IMPL, Migration, or frozen-principle edit  
- Not Quality review of evidence processes beyond design fitness  
- Not Product disposition  

## 10. Handoff

| To | Action |
|---|---|
| **Product Lead** | Disposition: Accept design (Must / Must+Should) / Hold / Reject |
| **Executor** | On Accept: draft `KOS-2.1-OPS-IMPL-001` with Arch conditions; do not edit frozen 2.0 principles unless Product opens separate Contract |
| **Program Manager** | After disposition, State-sync Dashboard/Index only |

---

**Architecture & Knowledge Steward — design package review complete.**  
**Verdict: Pass with conditions (0 P0 / 2 P1 / 3 P2 / 2 P3).**  
**Fit for Product Review.**  
