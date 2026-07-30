# Assignment: T9-AUTO-ANCHOR-001-S23 — 更早首锚设计

**Policy version:** `1.0.0`
**Lifecycle status:** `Exploratory complete — B3→B3e mechanism PASS, direction FAIL; product goal not met; no default attempt-N`
**Parent:** [`T9-AUTO-ANCHOR-001`](t9-auto-anchor-001.md)
**Predecessor:** [`T9-AUTO-ANCHOR-001-S22`](t9-auto-anchor-001-s22-stronger-controller-bounding.md)
**Repository change types:** `Documentation` (design phase only)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner, in Grok task after S2.2
  exploratory B2→B3 evidence, on `2026-07-30 Asia/Shanghai`:
  - replied “按推荐执行” to the KOS 2.0 routing package;
  - accepted S2.2 close for default attempt-N expansion;
  - authorized **design only** of earlier first-anchor as the next controller
    knife against residual pre-first-anchor **e16-class** spikes.
- **Product Approver:** Human Product Owner acting as Product Lead
- **Product Decision:**
  [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)
  section “Product routing after S2.2 B2→B3 exploratory pair (2026-07-30)”

## Boundary

- **Scope (this Assignment — design only):**
  - Diagnose why S4/S2.1/S2.2 first accept still lands near physical **18** on
    the frozen fixture while **e16** remains a ≥100 ms RIME spike before any
    automatic anchor.
  - Freeze one primary S2.3 earlier-first-anchor contract (digit/slot floors,
    eligibility, arm identity, ordinal mechanism validity, inheritance of
    rolling/triple stacks, rollback/ownership, diagnostics).
  - Define Layer 1–3 acceptance and Human log procedure using existing App
    performance logging (`T9SEG` / `T9AUTO` / `T9ARM` / preflight markers),
    with any **minimum** new content-free fields justified in the design.
  - Update governing docs/links only as needed for the frozen design; no
    production code change under this Assignment’s design phase.
- **Non-goals:**
  - No implementation, no Release-default enablement, no user setting, no
    Product Gate, no public performance claim.
  - No attempt 4+, no retry after a rejected first transaction, no adaptive
    unbounded loop.
  - No schema/Lua/vendor change; no reopening force_gc as primary remedy.
  - No candidate-window scan, later-page query, second RIME session, background
    RIME, or Path-as-performance obligation.
  - No silent one-syllable first-anchor as the default S2.3 primary (see
    stop-fast fork below).
  - No coordinate/XCTest/Computer Use typing into a physical third-party
    keyboard.
- **Required Inputs:**
  - Parent Assignment, PD-T9-AUTO-ANCHOR-001 (including 2026-07-30 S2.2 routing),
    ADR 0024 (esp. S4, §17–20 and S2.3 proposed amendment).
  - S2.2 exploratory evidence:
    [`t9-auto-anchor-s22-b2b3-2026-07-30.md`](../evidence/t9-auto-anchor-s22-b2b3-2026-07-30.md)
  - S2.1 matrix evidence:
    [`t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md`](../evidence/t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md)
  - `T9ReversibleAutoAnchorPolicy.Configuration` floors
    (`minimumSourceDigitCount = 18`, `minimumClosedSyllableCount = 2`,
    experimental `maximumAnchoredSyllableCount = 2`).
  - force_gc case close and process_key plan (closed Lua/schema primary track).
  - `PERFORMANCE_BASELINE.md`, `DEBUGGING.md`, input pipeline / partial-commit
    docs, `RIME_USER_DICTIONARY.md`.

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor:** Current Grok session on branch
  `codex/t9-auto-anchor-s5-checkpoint` (docs design phase)
- **Environment Executor:** Not Applicable for design phase (no device install
  required until implementation is authorized). Later Human matrix uses the
  same physical-device method as S2.1/S2.2.
- **Human Dependency:** Human Product Owner for design acceptance wording and,
  after implementation authorization, physical typing and Performance log
  export
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer

## Entry Criteria

- S2.2 exploratory B2→B3 recorded; direction PASS; product goal not met;
  ordinary Release restored gate-off.
- Product closed default attempt-N expansion and authorized S2.3 design only.
- Residual product diagnosis attributes a hard remaining spike class to
  **pre-first-anchor e16** under first-accept ~18.
- No Assignment field is `UNKNOWN`.
- Parent PD routing section exists for S2.3 design-only authority.

## Exit Criteria (design phase)

- Frozen design contract below is complete and internally consistent with
  ADR 0024 / PD boundaries.
- Exact earlier-first-anchor floors, eligibility, ordinal caps, arm identity,
  Path/Partial/Delete ownership and content-free diagnostic fields are
  unambiguous.
- Layer 1 (KeyboardCore), Layer 2 (pinned real-RIME), Layer 3 (Human + App
  logs) acceptance matrices are specified.
- Architecture and Quality independently review the design with P0–P3 findings
  closed or explicitly waived by Product.
- Product may then authorize implementation under a short amendment; without
  that instruction (**“授权 S2.3 实现”**), no code lands.

## Stop Conditions

Stop and return to Product/Architecture if the design would require:

- a **fourth** automatic apply attempt, or retry after a rejected first
  transaction;
- more than one automatic transaction on one physical key;
- candidate-window / later-page scans or a second session;
- weakening first-candidate or multiset conservation below S4/S2.1/S2.2;
- multi-step rollback chains, sync persistence or content-bearing logs;
- production userdb access or learned rank as Path authority;
- Release-default enablement, user setting, schema/Lua/vendor change;
- treating Path education as the primary performance fix;
- silently shipping **one-syllable** first-anchor without the stop-fast Product
  re-authorization path below.

## Product hypothesis (evidence-based)

From S2.2 valid Human B2→B3 on fixture
`jintiandetianqihenbucuowomenchuquwanba`:

| Observation | Implication for earlier first-anchor |
|---|---|
| First accept still ~ physical **18** under B2/B3 | S4 floor `minimumSourceDigitCount = 18` delays the first bound |
| ≥100 ms **e16** present on both B2 and B3 (~179–182 ms) | Spike is **before** any automatic anchor; extra rolling dose cannot fix it |
| B3 removed e25-class spike; e33/e35 remain | Mid-string dose helps; late residual is a separate class |
| Direction PASS but goal not met | Need a different knife, not attempt 4 by default |
| Two-syllable first-anchor remains the S4 product choice | Prefer moving the **same** two-syllable first-anchor earlier |

**Primary S2.3 hypothesis (frozen for review):**

> Under a new default-off earlier-first-anchor gate, lowering the first-anchor
> source-digit floor while **retaining exactly two** complete catalog-legal
> first-anchor syllables allows attempt 1 to accept at a physical ordinal
> **≤ 15** on the frozen fixture (before the residual e16-class window),
> reducing ≥100 ms event count and/or removing e16-class from the ≥100 ms set
> relative to paired same-stack arms without earlier floor, without requiring
> Path, without adding attempt 4, and without reopening Lua/force_gc.

**Secondary fork (explicitly not the silent default):**

> If Layer 2 cannot produce a legal two-syllable first accept at physical ≤15
> on the frozen fixture while keeping conservation and ownership rules, **stop
> and return to Product**. One-syllable first-anchor may be considered only
> after that stop-fast evidence and a new Product instruction. It is **not**
> authorized by this design as the primary implementation path.

## Architecture patch

ADR 0024 **§21–24** (S2.3 proposed amendment) owns the earlier-first-anchor
floors, arm identity, ordinal mechanism validity and stop conditions. This
Assignment must stay consistent with that patch. Runtime remains at the
current S4 floors (`minimumSourceDigitCount = 18`) until Product authorizes
S2.3 implementation.

## Design contract (frozen for Architecture/Quality review)

### Root cause statement (content-free)

Current experimental configuration defaults keep:

- `minimumSourceDigitCount = 18`
- `minimumClosedSyllableCount = 2`
- `maximumAnchoredSyllableCount = 2` (S4 cap)

Human and Simulator evidence show attempt 1 accepting at physical ~**18**, so
the open graph still includes the e16 key. Rolling extensions (attempts 2–3)
cannot retroactively bound that pre-accept window.

### Composition ledger

Retain the S2.1/S2.2 process-local ledger fields unchanged:

- full original `sourceDigits`;
- exact applied mixed `replacementRawInput`;
- cumulative anchored syllable and source-slot counts;
- total automatic apply-attempt count (max **2** under B2 / **3** under B3;
  S2.3 does **not** raise the ceiling);
- source-slot count at previous attempt;
- terminal/tombstone state for Path/Partial/rejection/Delete.

Candidate text remains transaction-local only. Never log or persist pinyin,
candidates, committed text or host context.

### Attempt model (unchanged ceilings; earlier attempt-1 eligibility only)

| Attempt | Role | Syllable rule | Max cumulative applies |
|---:|---|---|---:|
| 1 | S4 first anchor, **earlier eligibility under S2.3 gate** | exactly **2** complete catalog syllables | 1 |
| 2 | S2.1 rolling extension (if ROLLING gate on) | preserve accepted prefix; add exactly **2** | 2 |
| 3 | S2.2 second rolling extension (if TRIPLE gate on) | preserve prefix after attempt 2; add exactly **2** | 3 |

S2.3 does **not** authorize attempt 4.

### Earlier-first-anchor configuration (primary lever)

When the S2.3 earlier-first-anchor gate is enabled, attempt-1 proposal uses a
frozen earlier configuration **delta** relative to
`T9ReversibleAutoAnchorPolicy.Configuration.experimental`:

| Field | Current experimental | S2.3 earlier (gate on) |
|---|---:|---:|
| `minimumSourceDigitCount` | **18** | **12** |
| `minimumClosedSyllableCount` | 2 | **2** (unchanged) |
| `maximumAnchoredSyllableCount` | 2 | **2** (unchanged) |
| `minimumAnchoredSlotCount` | 6 | **6** (unchanged) |
| `minimumUnresolvedSlotCount` | 4 | **4** (unchanged) |
| conservation / first-candidate rules | S4 | S4 (unchanged) |

**Rationale for floor 12:** keeps two-syllable + unresolved-tail room
(`minimumAnchoredSlotCount` 6 + `minimumUnresolvedSlotCount` 4) while removing
the artificial wait until 18 that places first accept after e16. The floor is
a policy input, not a shipping SLO.

When the S2.3 gate is **off**, attempt-1 floors remain exactly as today (18).

Controller/policy applies the earlier configuration **only** when evaluating
attempt-1 eligibility/proposal under the S2.3 gate. Attempts 2–3 continue to
use the existing cumulative-extension path and do not re-interpret the lowered
digit floor as a new first-anchor opportunity.

### Attempt-1 eligibility under S2.3 (numbered; page-zero only)

Attempt 1 remains the only first automatic transaction. It is eligible only
when **all** hold:

1. No automatic apply attempt has yet occurred in this composition.
2. Live raw is pure T9 digits of length ≥ the active `minimumSourceDigitCount`
   (12 under S2.3 gate; 18 otherwise).
3. No Partial Commit, explicit selected Path or confirmed Path segment.
4. Already-returned **page-zero** snapshot produces a catalog-legal proposal of
   **exactly two** complete syllables under the active configuration.
5. Anchored/unresolved slot floors and conservation thresholds pass.
6. No extra RIME call is made to discover eligibility. Absent/divergent
   proposal → complete the key **without** consuming attempt 1.

Attempts 2 and 3 keep their existing S2.1/S2.2 eligibility, identity
advancement, prior-mixed rollback and budgets **unchanged**.

### Physical ordinal identity

For mechanism and direction binding on the frozen 38-key fixture:

- Prefer **`T9SEG event`** (1…38) as the one-based **physical** action ordinal
  when `T9SEG action` diverges.
- Attempt physical ordinals must be **strictly increasing**.
- Under any S2.3-enabled arm, attempt 1 is mechanism-valid only when its
  physical ordinal is **≤ 15**. If Layer 2 cannot meet ≤15 while staying
  legal under the two-syllable primary contract, **stop-fast** to Product —
  do not silently open one-syllable or raise attempt caps.
- Rolling/triple ordinal caps inherit S2.1/S2.2: attempt 2 ≤23 after attempt 1;
  attempt 3 ≤28 after attempt 2 (when those gates are on).

### Exact extra `replaceInput` budget

**Unchanged** from ADR 0024 §19 / S2.2. S2.3 only changes **when** attempt 1
may become eligible; it does not add endpoints or raise cumulative replace
counts.

### Gates and arm identity (frozen names)

Not compiled until implementation is authorized:

| Arm | Flags | Happy-path accepts | First-accept floor |
|---|---|---:|---|
| A0 | no preflight enable | 0 | n/a |
| A1 | `DEVICE_PREFLIGHT` + `DEVICE_PREFLIGHT_ENABLED` | 1 | 18 (current) |
| B2 | A1 + `ROLLING_PREFLIGHT_ENABLED` | 2 | 18 |
| B3 | B2 + `TRIPLE_ROLLING_PREFLIGHT_ENABLED` | 3 | 18 |
| **A1e** | A1 + **`T9_AUTO_ANCHOR_EARLIER_FIRST_PREFLIGHT_ENABLED`** | 1 | **12** |
| **B2e** | B2 + earlier-first | 2 | **12** |
| **B3e** | B3 + earlier-first | 3 | **12** |

Ordinary Release: all auto-anchor gates off. Any undeclared gate difference or
positive-fixture rejection/extra automatic call **invalidates** the arm.

Nesting: earlier-first is orthogonal to rolling/triple; it only changes
attempt-1 configuration floors. It must not enable rolling/triple by itself.

### Diagnostics (content-free; App PERF)

| Signal | Required |
|---|---|
| `T9DEVICE` marker / gate | arm identity including earlier-first |
| `T9SEG` event/action/total/rime/ui/session/cands/committed/rawLen | timing + integrity |
| `T9AUTO` status/**attempt**/anchorSlots/unresolvedSlots/applyMs | attempt outcomes |
| `T9ARM` actions/committed/sessionStable | arm close |

Optional content-free `reason=` skip/reject codes if already patterned. Never
log raw/pinyin/candidates/host/userdb.

No new content-bearing field is authorized. If implementation needs one extra
content-free digit-floor marker for arm proof, it must be justified in the
implementation amendment and remain non-PII.

### Layered acceptance

#### Layer 1 — KeyboardCore (implementation phase)

**Gate-fork inheritance:**

| Case family | When earlier-first off | When earlier-first on |
|---|---|---|
| All S2.1/S2.2 cases that do not depend on the 18-digit first-accept floor | Apply | Apply |
| Positive first-accept path under 18-digit floor | Apply | Still valid when source ≥18 |
| First-accept eligibility at source length **12…17** with legal two-syllable page-zero evidence | **No call** (current) | **May call once** when eligibility holds |
| Source length **11** (or any length below the active floor) | No call | No call |
| One-syllable-only evidence at any length | No call | **No call** (primary contract) |
| Path/Partial/Delete / pre-key mismatch / one auto-tx per key / attempt 2–3 rules | Apply | Apply unchanged |

**S2.3-required cases (minimum):**

| Case | Required result |
|---|---|
| A1e at source length **12** with legal two-syllable page-zero synthetic evidence | exactly 1 `replaceInput` accept path; no attempt 2 |
| A1e at source length **11** with the same syllable evidence shape | **no** automatic `replaceInput` |
| A1 / B2 / B3 (earlier-first off) at source length 12…17 | **no** attempt 1 |
| B2e frozen positive path | exactly 2 accepts; attempt1 at a strictly earlier source length than the paired B2 baseline behavior on the same fixture family |
| B3e frozen positive path | exactly 3 accepts when triple evidence holds; no 4th attempt |
| attempt 1 reject after early eligibility | terminal; pure-digit restore; no attempt 2/3 |
| Path/Partial after early accept | clear automatic payload; tombstone |
| Delete after early accept | restore full `sourceDigits` once then one normal Delete |
| one physical key | at most one automatic transaction |

Focused suite + full KeyboardCore green.

#### Layer 2 — pinned real-RIME (implementation phase)

Same fixture/isolation family as S2.1/S2.2. Arm contract:

| Arm | Accepts | Extra replace (happy) | Mechanism ordinal rule |
|---|---:|---:|---|
| A1 | 1 | 1 | S4; first ~18 historically |
| A1e | **1** | 1 | attempt1 physical **≤15** |
| B2 | 2 | 2 | attempt2 ≤23 after attempt1 |
| B2e | **2** | 2 | attempt1 ≤15; attempt2 ≤23 after attempt1 |
| B3 | 3 | 3 | attempt3 ≤28 after attempt2 |
| B3e | **3** | 3 | attempt1 ≤15; attempt2 ≤23; attempt3 ≤28 |

Named integration rows (zero unexpected skips): early first-accept positive,
B2e/B3e stacks, Delete after early accept, attempt1 reject+restore,
Path/Partial tombstone, pre-key mismatch fail-closed, gate separation vs
non-earlier arms. Positive fixture rejection or undeclared extra automatic call
invalidates the arm.

If legal two-syllable eligibility **cannot** meet attempt1 ≤15 on the frozen
fixture under A1e/B3e, **stop-fast** to Product — do not loosen conservation or
open one-syllable silently.

#### Layer 3 — Human physical (implementation phase)

Same device freeze family and Human method as S2.1/S2.2 (Reminders, nine-key,
fixture, Performance export, ordinary restore).

**Primary exploratory pair (required order):**

1. **B3 → B3e** (same-source internal artifacts; only declared difference is
   earlier-first gate). This answers the product residual question on top of
   the current best default-off dose. Layer 2 **A1e** is the isolation proof
   that the floor lever alone can produce attempt1 ≤15.
2. Direction rule: B3e vs paired B3 reduces ≥100 ms event count **and** does
   not increase worst total. Experiment routing only — not Product Gate / SLO.
3. North-star diagnostic (not shipping): e16-class preferably drops below
   100 ms or leaves the ≥100 ms set; Product will not call the goal met while
   late 33/35-class RIME spikes still dominate perception.
4. If pair 1 direction **FAIL** → **stop**; do not fish for better cadence or
   open attempt 4.
5. If B3e (or Layer 2 A1e) cannot achieve attempt1 physical ≤15 on a **valid**
   frozen-fixture run → **stop-fast** to Product (secondary one-syllable fork
   only after new PD).
6. Optional A1→A1e or B2→B2e Human expansion only under Product instruction
   after pair 1 (useful if attribution beyond Layer 2 is needed).

**Arm validity (required before direction scoring):**

- `T9ARM actions=38` (or 38 contiguous `event=1…38`);
- one stable valid session; zero commits; candidates available throughout;
- no missing/duplicate keys / keyboard termination (Human report);
- **B3:** exactly 3 `T9AUTO accepted` with existing ordinal rules;
- **B3e:** exactly 3 `T9AUTO accepted`; attempt1 physical **≤15** and after that
  attempt2/3 rules as B3;
- mechanism not triggered as contracted ⇒ **arm invalid**, do not enter
  direction comparison.

**Delete ownership:** restore complete accumulated `sourceDigits` once, then
perform exactly one normal user deletion (unchanged for any accepted automatic
prefix depth).

## Explicit non-claims

- Design does not authorize implementation.
- Design does not claim RIME table/sentence work will disappear after earlier
  first-anchor.
- Design does not reopen Lua/force_gc.
- Design does not authorize attempt 4 or one-syllable first-anchor by default.
- Design does not make Path optional for correctness—only non-mandatory for
  performance.
- Design does not treat one exploratory B3→B3e PASS as Product Gate.
- Design does not claim late e33/e35 residuals will clear without further work.

## Independent design review status

| Round | Architecture | Quality |
|---|---|---|
| Initial draft + Layer1 source-length clarification | **Pass** (P0–P3 = 0) | **Pass** (P0–P3 = 0) |

### Architecture review notes (2026-07-30)

- Primary lever is a policy floor delta on attempt 1 only; attempt ceilings and
  §19 replace budgets stay inherited — no silent fourth transaction.
- Two-syllable first-anchor product choice retained; one-syllable remains
  stop-fast/Product-only, matching S2.2 deferred language and ADR §24.
- Gate name frozen; orthogonal nesting with rolling/triple is explicit.
- ADR §21–24 present and consistent with this Assignment.
- Residual e16 targeting is architecture-coherent: pre-accept open graph is
  the failure class extra rolling cannot fix.

### Quality review notes (2026-07-30)

- Layer 1 gate-fork is explicit (not bare inherit-all); unit cases pin source
  length **11 vs 12** and earlier-first-off behavior at 12…17.
- Layer 2 ordinal ≤15 + stop-fast prevents fishing for early accepts by
  weakening conservation.
- Layer 3 primary pair B3→B3e matches the product residual on the best current
  dose; A1e isolation is owned by Layer 2 (and optional Human expansion).
- Direction rule, arm validity, ordinary Release restore and content-free
  diagnostics match S2.1/S2.2 method discipline.
- No implementation, Release enablement or Product Gate claimed.

Design Exit Criteria for Architecture/Quality independent review are met for
the **design phase**. Product authorized implementation on `2026-07-30`
(“授权 S2.3 实现”).

### Implementation and evidence progress

Evidence:
[`../evidence/t9-auto-anchor-s23-implementation-2026-07-30.md`](../evidence/t9-auto-anchor-s23-implementation-2026-07-30.md)

- KeyboardCore: 43 focused + 778 full passed
- Simulator A0/A1/B2/B3/A1e/B2e/B3e matrix: **passed**
  - A1e/B2e/B3e attempt1 @ physical **12** (≤15)
  - B3e continues 12 → 18 → 22
- Human B3→B3e exploratory:
  [`../evidence/t9-auto-anchor-s23-b3b3e-2026-07-30.md`](../evidence/t9-auto-anchor-s23-b3b3e-2026-07-30.md)
  - Mechanism **PASS** (attempt1 @12 on device)
  - Direction **FAIL** (≥100 ms 3→3; worst 188.1→156.7)
- Ordinary Release restored gate-off

### Product routing after B3→B3e (2026-07-30)

| Decision input | Status |
|---|---|
| S2.3 product goal | **Not met** |
| Default attempt-N (attempt 4+) | Still **forbidden** without new PD |
| Earlier-first base | Retain default-off (mechanism useful) |
| Next knife | Product chooses residual route (see evidence Remaining) |

## Handoff

- **Handoff Target:** Product Lead for residual routing after direction FAIL
- **Required Handoff Content:** this Assignment, Human B3→B3e evidence, S2.2
  residual pattern, ADR 0024 stop conditions
- **Revalidation Trigger:** any change to digit floor, syllable rule for
  attempt 1, attempt cap, ordinal caps, device method, privacy boundary or
  Release gate intent

## Design self-check

| Check | Status |
|---|---|
| Aligns with north star (no Path obligation) | Yes |
| Attacks residual pre-first-anchor e16-class | Yes (moved anchor; did not clear ≥100 set) |
| Retains two-syllable first-anchor as primary | Yes |
| No attempt 4 / no force_gc reopen | Yes |
| ADR 0024 earlier-first patch present (§21–24) | Yes |
| Exact floors frozen (18→12 under gate) | Yes |
| Attempt1 ordinal ≤15 with stop-fast | Yes (device @12) |
| Layer1/2/3 arm integrity + pair order | Yes |
| Flag name frozen without “e.g.” | Yes |
| Automated + Human exploratory complete | Yes |
| Human device required now | No (pair closed; ordinary restored) |
