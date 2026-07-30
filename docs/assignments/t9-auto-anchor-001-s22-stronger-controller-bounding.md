# Assignment: T9-AUTO-ANCHOR-001-S22 — 更强控制器自动锚定设计

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — design remediated after Arch/Quality Fail; re-review pending`
**Parent:** [`T9-AUTO-ANCHOR-001`](t9-auto-anchor-001.md)
**Predecessor:** [`T9-AUTO-ANCHOR-001-S21`](t9-auto-anchor-001-s21-rolling-design.md)
**Repository change types:** `Documentation` (design phase only)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner, in Grok task after the S2.1
  three-pair matrix, on `2026-07-30 Asia/Shanghai`:
  - reaffirmed north star “no Path obligation for smoothness”;
  - positioned S2.1 as mechanism-useful / product-goal-not-met;
  - chose the next knife as **controller automatic bounding**;
  - directed KOS 2.0 advancement with Human device cooperation when required.
- **Product Approver:** Human Product Owner acting as Product Lead
- **Product Decision:**
  [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)
  section “Product routing after S2.1 three-pair matrix (2026-07-30)”

## Boundary

- **Scope (this Assignment — design only):**
  - Diagnose S2.1 product shortfall against the north star using frozen matrix
    evidence and content-free logs only.
  - Freeze one primary S2.2 controller contract (attempt budget, syllable
    increments, eligibility, rollback, diagnostics, arm identity).
  - Define Layer 1–3 acceptance and Human log procedure using existing App
    performance logging (`T9SEG` / `T9AUTO` / `T9ARM` / preflight markers),
    with any **minimum** new content-free fields justified in the design.
  - Update governing docs/links only as needed for the frozen design; no
    production code change under this Assignment’s design phase.
- **Non-goals:**
  - No implementation, no Release-default enablement, no user setting, no
    Product Gate, no public performance claim.
  - No schema/Lua/vendor change; no reopening force_gc as primary remedy.
  - No candidate-window scan, later-page query, second RIME session, background
    RIME, adaptive unbounded retry after rejection, or Path-as-performance
    obligation.
  - No coordinate/XCTest/Computer Use typing into a physical third-party
    keyboard.
- **Required Inputs:**
  - Parent Assignment, PD-T9-AUTO-ANCHOR-001 (including 2026-07-30 routing),
    ADR 0024, S2.1 design Assignment and implementation evidence.
  - S2.1 exploratory + three-pair matrix evidence:
    [`t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md`](../evidence/t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md)
  - force_gc case close and process_key plan (closed Lua/schema primary track).
  - `PERFORMANCE_BASELINE.md`, `DEBUGGING.md`, input pipeline / partial-commit
    docs, `RIME_USER_DICTIONARY.md`.

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor:** Current Grok session on branch
  `codex/t9-auto-anchor-s5-checkpoint` (docs design phase)
- **Environment Executor:** Not Applicable for design phase (no device install
  required until implementation is authorized). Later Human matrix uses the
  same physical-device method as S2.1.
- **Human Dependency:** Human Product Owner for design acceptance wording and,
  after implementation authorization, physical typing and Performance log
  export
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer

## Entry Criteria

- S2.1 three-pair matrix recorded; direction PASS only 1/3; ordinary Release
  restored gate-off.
- Product north star reaffirmed; next knife = controller auto-bounding.
- No Assignment field is `UNKNOWN`.
- Parent PD routing section exists for S2.2 design-only authority.

## Exit Criteria (design phase)

- Frozen design contract below is complete and internally consistent with
  ADR 0024 / PD boundaries.
- Exact attempt budget, syllable rules, eligibility, rollback, Path/Partial/
  Delete ownership and content-free diagnostic fields are unambiguous.
- Layer 1 (KeyboardCore), Layer 2 (pinned real-RIME), Layer 3 (Human + App
  logs) acceptance matrices are specified.
- Architecture and Quality independently review the design with P0–P3 findings
  closed or explicitly waived by Product.
- Product may then authorize implementation under a short amendment; without
  that instruction, no code lands.

## Stop Conditions

Stop and return to Product/Architecture if the design would require:

- more than **three** automatic apply attempts per composition;
- retry after a rejected first transaction;
- more than one automatic transaction on one physical key;
- candidate-window / later-page scans or a second session;
- weakening first-candidate or multiset conservation below S4/S2.1;
- multi-step rollback chains, sync persistence or content-bearing logs;
- production userdb access or learned rank as Path authority;
- Release-default enablement, user setting, schema/Lua/vendor change;
- treating Path education as the primary performance fix.

## Product hypothesis (evidence-based)

From the S2.1 matrix on fixture
`jintiandetianqihenbucuowomenchuquwanba`:

| Observation | Implication for stronger controller bounding |
|---|---|
| ≥100 ms spikes remain ~99% RIME `processKey` | Keep shortening unresolved graph; do not pivot to UI polish |
| First accept ~ action **18**; spike often at **16** | Pre-first-anchor tail is still fully open when the first spike hits |
| Second accept ~ action **20–21**; spikes at **25/33/35** | After two accepts, unresolved slots (~7–8) still large enough for late spikes |
| Direction rule 1/3 PASS; per-spike ms often slightly better under B2 | Dose helps weakly; **count** of ≥100 ms events is the hard product bar |
| force_gc/Lua primary closed | Next knife stays controller-side |

**Primary S2.2 hypothesis (frozen for review):**

> After S2.1’s two accepted anchors, one additional cumulative extension
> (attempt **3**) of exactly two catalog-legal complete syllables—under the
> same conservation, identity, Path/Partial/Delete and fail-closed rules—can
> shrink the unresolved tail early enough to reduce the count of ≥100 ms events
> on the frozen fixture relative to S2.1 B2, without requiring Path.

**Secondary hypothesis (explicitly deferred, not in S2.2 implementation
scope):**

> Allowing a **one-syllable** first anchor when two-syllable evidence is not yet
> available might move first accept before event 16. This weakens the S4
> two-syllable first-anchor product choice and is **out of S2.2**. It may become
> S2.3 only after Product re-authorization.

## Architecture patch

ADR 0024 §17–20 (S2.2 proposed amendment) owns the three-attempt ledger,
exact `replaceInput` endpoint budget, B3 evidence boundary and S2.2 stop
conditions. This Assignment must stay consistent with that patch. S2.1 stop
conditions still forbid a third attempt on the **S2.1 surface**; runtime remains
two-attempt until Product authorizes S2.2 implementation.

## Design contract (remediated for Architecture/Quality re-review)

### Composition ledger

Retain the S2.1 process-local ledger fields:

- full original `sourceDigits`;
- exact applied mixed `replacementRawInput`;
- cumulative anchored syllable and source-slot counts;
- total automatic apply-attempt count (max **3** when B3 enabled; else **2**);
- source-slot count at previous attempt;
- terminal/tombstone state for Path/Partial/rejection/Delete.

Candidate text remains transaction-local only. Never log or persist pinyin,
candidates, committed text or host context.

### Attempt model

| Attempt | Role | Syllable rule | Max cumulative applies |
|---:|---|---|---:|
| 1 | Existing S4 first anchor | exactly **2** complete catalog syllables | 1 |
| 2 | Existing S2.1 rolling extension | preserve accepted prefix; add exactly **2** | 2 |
| 3 | **S2.2** second rolling extension | preserve prefix after attempt 2; add exactly **2** | 3 |

### Attempt-3 eligibility (numbered; page-zero only)

Attempt 3 is eligible only when **all** hold:

1. Attempt 2 was **accepted** (attempt 1 reject remains terminal; attempt 2
   reject exhausts budget — **no** attempt 3).
2. Fewer than three automatic apply attempts have occurred.
3. At least one later physical T9 digit was successfully processed after
   attempt 2, so attempt 3 cannot run on the same physical key as attempt 2.
4. Accepted-identity advancement after that digit completed atomically; live
   raw exactly matches the ledger mixed identity.
5. No Partial Commit, explicit selected Path or confirmed Path segment.
6. Already-returned **page-zero** snapshot produces a catalog-legal cumulative
   proposal whose existing automatic prefix is **byte-for-byte** unchanged.
7. Proposal adds **exactly two** complete catalog-legal syllables beyond the
   existing automatic prefix and leaves a non-empty unresolved digit tail.
8. No extra RIME call is made to discover eligibility. Absent/divergent
   proposal → complete the key **without** consuming attempt 3.

### Physical ordinal identity

For mechanism and direction binding on the frozen 38-key fixture:

- Prefer **`T9SEG event`** (1…38) as the one-based **physical** action ordinal
  of that arm when `T9SEG action` diverges (S2.1 matrix already observed
  continued `action` counters).
- Attempt physical ordinals must be **strictly increasing**.
- B3 attempt 3 is mechanism-valid only when its physical ordinal is **≤ 28**
  and strictly after attempt 2. If Layer 2 cannot meet ≤28 while staying legal,
  **stop-fast** and return to Product — do not loosen safety or raise the cap
  silently.

### Exact extra `replaceInput` budget

Identical to ADR 0024 §19 (copied for Assignment locality):

| Composition path at endpoint | Cumulative extra `replaceInput` | Same-session clear/reset |
|---|---:|---:|
| first accepts; no second transaction | 1 | 0 |
| two accepts; no third transaction | 2 | 0 |
| three accepts | 3 | 0 |
| first rejects and pure digits restore | 2 | 0 |
| first restore fails | 2 | exactly 1 |
| first accepts; second rejects and prior mixed restores | 3 | 0 |
| second prior-mixed restore fails | 3 | exactly 1 |
| two accepts; third rejects and prior mixed restores | 4 | 0 |
| third prior-mixed restore fails | 4 | exactly 1 |
| pre-key identity mismatch after any accepted/restored automatic payload | prior total; 0 new at mismatch | exactly 1 |
| Delete after first acceptance only | 2 total | 0 success / 1 failure |
| Delete after two acceptances | 3 total | 0 success / 1 failure |
| Delete after three acceptances | **4** total | 0 success / 1 failure |
| second rejects/restores, then Delete | 4 total | 0 success / 1 failure |
| third rejects/restores, then Delete | **5** total | 0 success / 1 failure |

No second session, `recoverSession`, deploy or multi-step restore chain.

### Gates and arm identity (frozen names)

Not compiled until implementation is authorized:

| Arm | Flags | Happy-path accepts | Happy-path extra `replaceInput` |
|---|---|---:|---:|
| A0 | no preflight enable | 0 | 0 |
| A1 | `DEVICE_PREFLIGHT` + `DEVICE_PREFLIGHT_ENABLED` | 1 | 1 |
| B2 | A1 + `ROLLING_PREFLIGHT_ENABLED` | 2 | 2 |
| B3 | B2 + **`T9_AUTO_ANCHOR_TRIPLE_ROLLING_PREFLIGHT_ENABLED`** | 3 | 3 |

Ordinary Release: all auto-anchor gates off. Any undeclared gate difference or
positive-fixture rejection/extra automatic call **invalidates** the arm.

### Diagnostics (content-free; App PERF)

| Signal | Required |
|---|---|
| `T9DEVICE` marker / gate | arm identity |
| `T9SEG` event/action/total/rime/ui/session/cands/committed/rawLen | timing + integrity |
| `T9AUTO` status/**attempt**/anchorSlots/unresolvedSlots/applyMs | attempt outcomes; **attempt=3** on third tx |
| `T9ARM` actions/committed/sessionStable | arm close |

Optional content-free `reason=` skip/reject codes if already patterned. Never
log raw/pinyin/candidates/host/userdb.

### Layered acceptance

#### Layer 1 — KeyboardCore (implementation phase)

**Gate-fork inheritance (do not bare-inherit S2.1):**

| S2.1 Layer 1 case family | When B2 only (triple flag off) | When B3 on |
|---|---|---|
| All S2.1 cases that do not mention “third opportunity” or “budget exhausted after second accept” | Apply unchanged | Apply unchanged unless superseded below |
| “Third opportunity after two attempts → No call” | **Apply** (no attempt 3) | **Superseded** → third opportunity may call once when attempt-3 eligibility holds |
| “Second validation accepted → budget exhausted” | **Apply** (ceiling 2) | **Superseded** → after attempt 2 accept, ceiling is **3**; attempt 3 still available until consumed/rejected |
| First reject terminal; Path/Partial/Delete after 1–2 accepts; pre-key mismatch; one auto-tx per key | Apply | Apply (Delete after three accepts uses budget total **4**) |

**B3-required cases (minimum):**

| Case | Required result |
|---|---|
| B3 frozen positive path | exactly 3 accepts; no 4th attempt |
| B2 on, triple flag off | attempt 3 never evaluated; after 2 accepts budget exhausted |
| attempt 1 reject | terminal; no attempt 2/3 |
| attempt 2 reject + prior mixed restore | budget exhausted; no attempt 3 |
| attempt 3 reject | restore **attempt-2** mixed raw once; total extra replaceInput **4** |
| attempt 3 restore fail | total 4 + exactly 1 same-session reset; abandon |
| three accepts then Delete success | extra replaceInput total **4** |
| three accepts then Delete fail | total 4 + exactly 1 reset; normal Delete stops |
| third reject+restore then Delete success | total **5** |
| third reject+restore then Delete fail | total 5 + exactly 1 reset |
| three accepts then Path/Partial | clear automatic payload; tombstone |
| pre-key mismatch after attempt 3 accept | 0 new replace at mismatch; 1 reset |
| one physical key | at most one automatic transaction |

Focused suite + full KeyboardCore green.

#### Layer 2 — pinned real-RIME (implementation phase)

Same fixture/isolation as S2.1. Arm contract:

| Arm | Accepts | Extra replace (happy) | Mechanism ordinal rule |
|---|---:|---:|---|
| A1 | 1 | 1 | S4 |
| B2 | 2 | 2 | attempt2 physical ≤23 and after attempt1 |
| B3 | **3** | **3** | inherits attempt1/2 rules **and** attempt3 physical ≤28 and after attempt2 |

Named integration rows (zero unexpected skips): Delete after 1/2/3 accepts
(success/fail budgets), attempt2/3 reject+restore, Path/Partial tombstone,
pre-key mismatch fail-closed, A1/B2/B3 gate separation. Positive fixture
rejection or undeclared extra automatic call invalidates the arm.

**Ordinal rationale for ≤28:** S2.1 matrix places attempt2 ~20–21 and late
spikes at 25/33/35. Attempt3 must fire after attempt2 and **before** the late
33-class cluster; 28 is the frozen upper bound for mechanism validity (not a
shipping SLO). If legal eligibility cannot meet ≤28, stop-fast to Product.

#### Layer 3 — Human physical (implementation phase)

Same device freeze family and Human method as S2.1 (Reminders, nine-key,
fixture, Performance export, ordinary restore).

**Arm validity (required before direction scoring):**

- `T9ARM actions=38` (or 38 contiguous `event=1…38`);
- one stable valid session; zero commits; candidates available throughout;
- no missing/duplicate keys / keyboard termination (Human report);
- **B2:** exactly 2 `T9AUTO accepted`; attempt2 physical ≤23 and after attempt1;
- **B3:** exactly **3** `T9AUTO accepted`; attempt1/2 rules as B2; attempt3
  physical ≤28 and after attempt2;
- mechanism not triggered as contracted ⇒ **arm invalid**, do not enter
  direction comparison (same discipline as S2.1).

**Order and stop rules:**

1. Exploratory pair 1: **B2 → B3** (same-source internal artifacts).
2. If pair 1 direction **FAIL** (B3 does not reduce ≥100 ms count vs B2, or
   worsens worst) → **stop**; do not fish for better cadence.
3. If B3 cannot achieve attempt3 physical ≤28 on a **valid** typing of the
   frozen fixture (legal eligibility never fires in time) → **stop-fast** to
   Product; do not re-type to hunt ordinals.
4. If pair 1 direction **PASS** → optional counterbalanced expansion only under
   Product instruction; single exploratory PASS is **not** robust product
   direction (S2.1 matrix taught 1/3).
5. Direction rule: B3 vs paired B2 reduces ≥100 ms event count **and** does not
   increase worst total. Experiment routing only — not Product Gate / SLO.
6. North-star diagnostic (not shipping): prefer ≤1 ≥100 ms on fixture without
   Path; Product will not call the goal met while four late RIME spikes remain
   typical.

**Delete ownership (any accepted automatic prefix, including three accepts):**
restore complete accumulated `sourceDigits` once, then perform exactly one
normal user deletion.

## Explicit non-claims

- Design does not authorize implementation.
- Design does not claim RIME table/sentence work will disappear.
- Design does not reopen Lua/force_gc.
- Design does not make Path optional for correctness—only non-mandatory for
  performance.
- Design does not treat one exploratory B2→B3 PASS as Product Gate.

## Independent design review status

| Round | Architecture | Quality |
|---|---|---|
| Initial | **Fail** (P1: ADR third-attempt patch, exact budgets, Layer3 integrity) | **Fail** (P1: physical ordinal binding, Delete budgets) |
| After ADR/budget/ordinal remediation | **Pass** (P0–P3 = 0) | **Fail** (P1: bare Inherit-all vs B3 supersession) |
| After Layer1 gate-fork remediation | Architecture still Pass unless regression | Re-review required |

Remediation closed the listed P1/P2 gaps in-document and added ADR §17–20.

## Handoff

- **Handoff Target:** Architecture & Knowledge Steward and Quality, Performance
  & Release Maintainer for **re-review**; then Product Lead for implementation
  authorization only after both Pass with P0/P1 = 0
- **Required Handoff Content:** this Assignment, ADR 0024 §17–20, PD routing
  section, S2.1 matrix evidence link
- **Revalidation Trigger:** any change to attempt cap, syllable increment,
  first-anchor depth, ordinal caps, device method, privacy boundary or Release
  gate intent

## Design self-check (post-remediation)

| Check | Status |
|---|---|
| Aligns with north star (no Path obligation) | Yes |
| ADR 0024 third-attempt patch present (§17–20) | Yes |
| Exact replaceInput endpoint table (incl. Delete after 3) | Yes |
| Attempt-3 eligibility numbered | Yes |
| Physical ordinal = event-preferred; ≤28; stop-fast | Yes |
| Layer1/2/3 arm integrity + matrix stop rules | Yes |
| Flag name frozen without “e.g.” | Yes |
| Implementation not started | Yes |
| Human device required now | No (after implementation auth) |
