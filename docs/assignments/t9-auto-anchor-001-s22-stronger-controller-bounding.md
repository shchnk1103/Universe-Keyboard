# Assignment: T9-AUTO-ANCHOR-001-S22 — 更强控制器自动锚定设计

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — design; Architecture/Quality review pending`
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

## Design contract (frozen for Architecture/Quality review)

### Composition ledger

Retain the S2.1 process-local ledger fields:

- full original `sourceDigits`;
- exact applied mixed `replacementRawInput`;
- cumulative anchored syllable and source-slot counts;
- total automatic apply-attempt count (now max **3**);
- source-slot count at previous attempt;
- terminal/tombstone state for Path/Partial/rejection/Delete.

Candidate text remains transaction-local only. Never log or persist pinyin,
candidates, committed text or host context.

### Attempt model

| Attempt | Role | Syllable rule | Max cumulative applies |
|---:|---|---|---:|
| 1 | Existing S4 first anchor | exactly **2** complete catalog syllables | 1 |
| 2 | Existing S2.1 rolling extension | preserve accepted prefix; add exactly **2** syllables | 2 |
| 3 | **S2.2 new** second rolling extension | preserve accepted prefix after attempt 2; add exactly **2** syllables | 3 |

Rules carried forward unchanged unless stated:

- At most one automatic transaction per physical key.
- Attempt \(n+1\) requires attempt \(n\) **accepted**, at least one later
  successful physical T9 digit, atomic accepted-identity advancement, no
  Path/Partial ownership, page-zero snapshot only, non-empty unresolved tail.
- First rejection of attempt 1 remains terminal (no rolling unlock).
- Rejection of attempt 2 or 3 restores the **prior accepted mixed raw** once;
  restore failure → one same-session fail-closed reset, no recover/replay.
- Pre-key live/ledger mismatch → same-session reset, clear automatic payload,
  zero new processKey/replaceInput for ordinary digit advancement.

### Extra `replaceInput` budget (S2.2 upper bound)

Beyond ordinary key/Delete processKey:

| Endpoint | Max extra `replaceInput` |
|---|---:|
| three accepts | 3 |
| attempt 3 reject + prior mixed restore | 4 |
| then Delete restore success | 5 |
| any pre-key identity mismatch after accepted payload | 0 new at mismatch + exactly 1 same-session reset |

No second session, recoverSession, deploy or multi-step restore chain.

### Gates and arm identity (implementation phase only)

Design-phase freeze of names; not compiled until implementation is authorized:

| Arm | Meaning |
|---|---|
| A1 | existing S4 one-anchor only (current A1 preflight) |
| B2 | S2.1 two-attempt rolling (current B2) |
| B3 | S2.2 three-attempt rolling: B2 conditions + new internal flag e.g. `T9_AUTO_ANCHOR_TRIPLE_ROLLING_PREFLIGHT_ENABLED` requiring B2 flags |

Ordinary Release: all auto-anchor gates off.

### Diagnostics (content-free; prefer existing App PERF)

Must remain usable from the App Performance export Human already uses:

| Signal | Required |
|---|---|
| `T9DEVICE` marker / gate | arm identity |
| `T9SEG` event/action/total/rime/ui/session/cands/committed/rawLen | timing + integrity |
| `T9AUTO` status/attempt/anchorSlots/unresolvedSlots/applyMs | attempt outcomes |
| `T9ARM` actions/committed/sessionStable | arm close |

**Minimum new field (design intent for implementation):** when attempt 3 is
evaluated, `T9AUTO` must carry `attempt=3` on accept/reject and must not log
raw/pinyin/candidates. Optional content-free `reason=` codes for skip/reject
remain allowed if already patterned in Debug.

Human procedure stays: Reminders blank title, Chinese nine-key, frozen 38-key
fixture, no Path/candidates mid-arm, export Performance filter, ordinary
Release restore after internal arms.

### Layered acceptance

#### Layer 1 — KeyboardCore (implementation phase)

- A1/B2/B3 gate separation; attempt 3 only when B3 enabled.
- Exactly three accepts on the frozen synthetic policy path when eligible.
- No fourth attempt; rejection restore budgets exact; Path/Partial/Delete
  ownership; pre-key mismatch fail-closed; focused + full KeyboardCore green.

#### Layer 2 — pinned real-RIME (implementation phase)

- Same fixture/isolation policy as S2.1.
- B3 accepts exactly three times with attempt ordinals strictly increasing and
  attempt 3 action ordinal **≤ 28** on the frozen fixture (must fire before the
  historical e33-class late spikes; if the real-RIME matrix cannot meet ≤28
  while staying legal, stop and return to Product rather than loosen safety).
- Zero unexpected skips on ownership/Delete/Path/Partial matrix.

#### Layer 3 — Human physical (implementation phase)

- Same device freeze family as S2.1 matrix (iPhone 13 Pro class, Human method).
- Exploratory order: **B2 → B3** first (does triple help over S2.1?), then
  optional A1 baseline if Product wants absolute comparison.
- Direction rule for B3 vs paired B2 (same Human cadence caveats as S2.1):
  reduce ≥100 ms event count **and** do not increase worst total.
- Product goal bar (north star diagnostic, not shipping SLO): on the frozen
  fixture without Path, prefer ≤1 event ≥100 ms; matrix need not hit this on
  first exploratory pair, but Product will not call the goal met while 4 late
  RIME spikes remain typical.

## Explicit non-claims

- Design does not authorize implementation.
- Design does not claim RIME table/sentence work will disappear.
- Design does not reopen Lua/force_gc.
- Design does not make Path optional for correctness—only non-mandatory for
  performance.

## Handoff

- **Handoff Target:** Architecture & Knowledge Steward and Quality, Performance
  & Release Maintainer for independent design review; then Product Lead for
  implementation authorization
- **Required Handoff Content:** this Assignment, PD routing section, S2.1
  matrix evidence link, exact attempt/syllable/rollback/diagnostic tables
- **Revalidation Trigger:** any change to attempt cap, syllable increment,
  first-anchor depth, device method, privacy boundary or Release gate intent

## Design self-check (pre-review)

| Check | Status |
|---|---|
| Aligns with north star (no Path obligation) | Yes |
| Extends S2.1 rather than rewriting S4 | Yes (attempt 3 only) |
| Safety family preserved | Yes (stated) |
| Content-free log plan uses existing App PERF | Yes |
| Implementation not started | Yes |
| Human device required now | No (after implementation auth) |
