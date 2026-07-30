# Assignment: T9-AUTO-ANCHOR-001-S21 — 滚动影子锚定设计

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — three-pair matrix complete (1/3 direction PASS); Product routing pending`
**Parent:** [`T9-AUTO-ANCHOR-001`](t9-auto-anchor-001.md)
**Repository change types:** `Implementation`, `Tests`, `Documentation`,
`Diagnostic Evidence`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner directed the team to retain
  the manual physical-device method and continue the S2.1 rolling-shadow-anchor
  design under KOS 2.0 on `2026-07-29 Asia/Shanghai`, then explicitly replied
  “授权” after the reviewed design handoff in the same Codex task, authorizing
  implementation under this frozen contract.
- **Product Approver:** Human Product Owner acting as Product Lead
- **Product Decision:**
  [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)

## Boundary

- **Scope:**
  - Implement the KOS-governed S2.1 design for at most one cumulative extension
    after the existing S4 two-syllable anchor has already been accepted.
  - Define transaction ownership, exact RIME-call budget, rollback targets,
    explicit Path/Partial Commit precedence, personalization boundary,
    content-free diagnostics and a layered acceptance matrix.
  - Update `Packages/KeyboardCore` state/policy/controller logic and focused
    tests, extend the pinned-RIME integration matrix, and add only the minimum
    internal preflight identity needed to distinguish `A0`, `A1` and `B2`.
  - Make manual Human input plus content-free App performance logs the
    canonical physical-device method for third-party-keyboard performance
    evidence.
- **Non-goals:**
  - No schema, Lua, RIME vendor, user-facing setting or Release-default change.
  - No retry after the first transaction rejects, adaptive backoff, loop,
    candidate-window scan, later-page query, second RIME session or background
    RIME execution.
  - No Product Gate, shipping latency budget, public performance claim or
    physical-device evidence collection in this design Assignment.
  - No coordinate-driven/XCTest/Computer Use typing into a physical
    third-party keyboard.
- **Required Inputs:**
  - Parent Assignment, Product Decision and ADR 0024.
  - S4 implementation/evidence and S6-A manual A/B evidence.
  - `PERFORMANCE_BASELINE.md`, `DEBUGGING.md`,
    `architecture/input-pipeline-and-marked-text.md`,
    `architecture/partial-commit.md` and `RIME_USER_DICTIONARY.md`.
  - Current implementation checkpoint represented by repository HEAD at
    design start; source inspection is read-only.

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor:** Current Codex task
  `019f9dac-ff8d-7872-a913-d5dd3f930dc1`
- **Environment Executor:** Current Codex task for local tests, Simulator
  integration/build evidence and reviewed internal artifact preparation;
  Human Product Owner remains the physical-device input operator
- **Human Dependency:** Human Product Owner for physical-device readiness and
  Product acceptance
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer

## Entry Criteria

- The physical-device pair proves the existing single accepted anchor is
  directionally useful but insufficient for the product goal.
- The B arm retained one stable session, zero commits and candidate
  availability, so the next question is bounded extension strength rather than
  recovery from functional corruption.
- Existing S2/S4 safety rules, user Path authority and Partial Commit ownership
  remain available as frozen inputs.
- No Assignment field is `UNKNOWN`.
- Architecture and Quality independently passed the frozen design with P0–P3
  all zero.
- Product Lead explicitly authorized implementation after that handoff.

## Design Contract

### Product hypothesis

The current S4 transaction accepts a seven-slot/two-syllable prefix at the
18th input action, but leaves eleven unresolved source slots. On the observed
physical-device run, the same RIME-dominated failure class still appeared at
events 24, 32 and 34. S2.1 tests this narrower hypothesis:

> After one accepted anchor, one later key may provide enough fresh candidate
> evidence to safely extend the same automatic prefix by at most two additional
> complete syllables before the unresolved tail reaches the first known spike.

This is cumulative refinement of one reversible preference. It is not a retry
after rejection and does not create user-confirmed Path ownership.

### Composition ledger

The implementation design must keep one process-local ledger with:

- full original `sourceDigits`, updated after every accepted T9 digit;
- exact currently applied mixed `replacementRawInput`;
- cumulative anchored syllable and source-slot counts;
- total automatic apply-attempt count;
- source-slot count at the previous attempt;
- terminal/tombstone state needed to prevent a later Path, Partial Commit,
  rejection or Delete from silently granting another attempt.

Candidate text remains transaction-local. It is never retained in the ledger,
logged or persisted.

### Accepted-identity advancement

After attempt 1 accepts, ordinary T9 digit processing advances the two
identities as one atomic state transition:

1. before sending the digit to RIME, the accepted phase requires the previous
   live raw to exactly equal the ledger's `replacementRawInput`;
2. RIME must successfully process that single digit and return a usable,
   non-committing composition;
3. only then append the digit to `sourceDigits` and replace
   `replacementRawInput` with the exact raw returned by that same RIME output;
4. publish that one updated ledger before evaluating attempt-2 eligibility.

The transition does not change cumulative anchor counts or consume attempt 2.
It does not advance on an ignored/failed key, commit, unusable output, Path,
Partial Commit, reset, fallback or lifecycle abandonment. Commit and the
documented ownership/lifecycle transitions perform their existing clear or
tombstone behavior instead.

A pre-key live/ledger identity mismatch is an invariant failure: it performs no
ordinary digit or rolling transaction, clears the current composition through
exactly one same-session reset and leaves no automatic payload. It must not
silently rebase the ledger, recover/create a session or replay input.

### Eligibility

The first transaction remains the accepted S4 policy unchanged. A second
transaction is eligible only when:

1. the first transaction was accepted;
2. fewer than two automatic apply attempts have occurred;
3. at least one later physical T9 digit was successfully processed, so the
   second transaction cannot execute on the same key as the first;
4. the accepted-identity advancement above completed atomically and the
   returned live raw exactly matches the newly updated ledger mixed identity;
5. there is no Partial Commit, explicit selected Path or confirmed Path
   segment;
6. the already-returned page-zero snapshot produces a catalog-legal cumulative
   proposal whose existing automatic prefix is byte-for-byte unchanged;
7. the proposal adds at least two and at most two complete syllables beyond
   the existing automatic prefix, satisfies the existing slot/tail bounds and
   leaves a non-empty unresolved digit tail.

No extra RIME call may be made to discover eligibility. If the cumulative
proposal is absent, divergent or not strictly extending, the key completes
without consuming the second attempt.

### Transaction and rollback

For the second transaction:

1. capture the exact current accepted mixed raw as the transaction rollback
   target;
2. consume attempt 2 before crossing the RIME boundary;
3. call `replaceInput` once with the cumulative extended raw;
4. require exact raw identity, no commit, usable composition, unchanged first
   candidate and the existing bounded multiset-overlap threshold;
5. on acceptance, publish the refined output and update the cumulative ledger;
6. on rejection, call `replaceInput` once with the prior accepted mixed raw;
7. if that restore succeeds, retain the first accepted anchor but leave the
   attempt budget exhausted;
8. if it fails, reset the session and abandon the composition fail-closed.

The second transaction must never roll back directly to pure digits during
validation. Pure digits remain the full-composition user-Delete authority.
There is no multi-step restore chain.

### Extra RIME boundary-mutation budget

The table counts cumulative auto-anchor-owned `replaceInput` calls and
fail-closed same-session resets beyond ordinary successful key/Delete
processing. Ordinary RIME `processKey` for a successful digit or the normal
Delete is baseline work and is not counted as an auto-anchor mutation.

| Composition path at the stated endpoint | Cumulative extra `replaceInput` | Same-session clear/reset |
|---|---:|---:|
| first accepted; no second transaction occurs | 1 | 0 |
| first accepted; second accepted | 2 | 0 |
| first rejected and pure digits restored | 2 | 0 |
| first rejected and restore fails | 2 | exactly 1 |
| first accepted; second rejected and prior mixed raw restored | 3 | 0 |
| first accepted; second rejected and prior mixed restore fails | 3 | exactly 1 |
| accepted ledger has a pre-key identity mismatch after attempt 1 acceptance, attempt 2 acceptance, or attempt 2 rejection/prior-mixed restore | 1, 2 or 3 total; 0 new calls at mismatch | exactly 1 |
| Delete restore succeeds after first acceptance and no second transaction | 2 total | 0; normal Delete continues |
| Delete restore fails after first acceptance and no second transaction | 2 total | exactly 1; normal Delete stops |
| Delete restore succeeds after two acceptances | 3 total | 0; normal Delete continues |
| Delete restore fails after two acceptances | 3 total | exactly 1; normal Delete stops |
| second rejected, prior mixed raw restored, then Delete restore succeeds | 4 total | 0; normal Delete continues |
| second rejected, prior mixed raw restored, then Delete restore fails | 4 total | exactly 1; normal Delete stops |

Only one automatic transaction may run during one physical key action. A first
rejection remains terminal and cannot unlock the S2.1 extension.
Every reset above clears composition on the existing session only. S2.1 must
not call `recoverSession`, create another session, rebuild/replay input, deploy
resources or perform a second fallback mutation chain.

### User authority and lifecycle

- Explicit Path selection always wins and must never inherit automatic
  ownership.
- Partial Commit and explicit Path transitions clear all automatic rollback
  payload while retaining a data-free exhausted tombstone until the original
  composition ends.
- Delete after an accepted automatic prefix first restores the complete
  accumulated `sourceDigits`, then performs exactly one normal user deletion.
- Candidate/Space/Return/direct-text commit, visibility abandonment, mode/page
  invalidation, fallback and reset clear the composition ledger according to
  the existing lifecycle contract.
- Internal digits, guessed pinyin and automatic ownership must never reach host
  text or Path selection state.

### Personalization boundary

Existing RIME user-dictionary learning may influence which candidate is ranked
first in the already-returned snapshot. S2.1 consumes that ranking only through
the same first-candidate and conservation checks used for an unpersonalized
session:

- no userdb query, copy, hash, write or duplicate phrase store;
- no candidate-selection call and no new learning event;
- learned rank is preference evidence, never Path authority;
- a personalized ordering cannot bypass prefix compatibility, exact extension,
  first-candidate preservation or candidate conservation;
- a user-confirmed Path supersedes any learned or automatic preference.

### Diagnostics

Debug/internal preflight diagnostics may add only:

- attempt index and bounded status/reason;
- cumulative and newly added anchored syllable/slot counts;
- unresolved slot count;
- baseline/result/overlap counts;
- apply/restore duration;
- stable opaque run identity plus the same content-free, one-based physical
  action ordinal used by the 38 ordered key records.

Raw digits, pinyin, candidate text, committed text, user-dictionary data and
host context remain prohibited. Logging stays asynchronous and outside the
decision path. An attempt-2 outcome is comparable only when its run identity
matches the arm and its action ordinal proves `2...23`: it occurred after the
first accepted transaction and before physical action 24.

## Acceptance Matrix

### Layer 1 — deterministic KeyboardCore contracts

| Case | Required result |
|---|---|
| First S4 proposal accepted | Existing one-anchor behavior is unchanged |
| Accepted phase + matching pre-key raw + successful later digit | `sourceDigits` and exact returned mixed raw publish indivisibly before attempt-2 eligibility; cumulative anchor counts and attempt count remain unchanged; attempt 2 is not consumed; eligibility reads only the fully published ledger and cannot observe a half update |
| Accepted phase + pre-key identity mismatch | No digit/attempt; exactly one same-session reset; payload cleared |
| Pre-key identity mismatch after attempt 2 accepted | No third attempt or digit processing; 0 new replacement calls; exactly one same-session reset; payload cleared |
| Pre-key identity mismatch after attempt 2 rejected and prior mixed raw restored | Prior cumulative replacement total remains exactly 3; no digit or new replacement; exactly one same-session reset; payload cleared |
| Later digit commits, fails or returns unusable output | No ledger advancement; only the existing clear/tombstone transition may run; zero `recoverSession`, session creation or input replay |
| No later successful digit | No second transaction |
| Same physical key as first acceptance | No second transaction |
| Later snapshot cannot extend prior prefix | No call and attempt 2 remains available |
| Cumulative prefix rewrites prior automatic syllables | Blocked |
| Valid two-syllable cumulative extension | Exactly one second apply call |
| Second validation accepted | Cumulative ledger updated; budget exhausted |
| Second validation rejected | Prior mixed raw restored once; first anchor retained; budget exhausted |
| Prior mixed restore fails | Session reset and composition abandoned fail-closed |
| First restore or Delete restore fails | Exactly one same-session reset; no recover/create/replay chain |
| Second rejected/restored, then Delete succeeds/fails | Cumulative replacement total is exactly 4; failure adds one same-session reset and does not continue normal Delete |
| First transaction rejected | No later retry |
| Third opportunity after two attempts | No call |
| Delete after two accepts | Full digits restored, then one normal Delete |
| Explicit Path or Partial Commit | Automatic payload removed; no re-entry in the same composition |
| Duplicate candidate text | Existing multiset denominator remains intact |
| 26-key / gate disabled / ordinary Release | Behavior unchanged |

### Layer 2 — pinned real-RIME integration

Use three same-source arms:

- `A0`: automatic anchor disabled;
- `A1`: existing one-anchor S4 policy;
- `B2`: S2.1 rolling extension enabled.

The source-visible gates are intentionally nested:

- ordinary Release: neither gate is compiled or enabled;
- internal `A1`: `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` plus
  `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`;
- internal `B2`: the same two conditions plus
  `T9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED`.

`KeyboardController.isRollingT9AutoAnchorEnabled` is false by default and does
not replace the existing base gate. This preserves the A1 comparator.

The arm contract is exact:

| Arm | Automatic apply attempts | Accepted outcomes | Extra `replaceInput` calls in the valid frozen fixture |
|---|---:|---:|---:|
| `A0` | 0 | 0 | 0 |
| `A1` | exactly 1 | exactly 1 existing S4 acceptance | 1 |
| `B2` | exactly 2 | exactly 2 cumulative acceptances | 2 |

All three use the same source checkpoint, optimization, fixture, schema,
isolated user directory policy, session construction, event instrumentation
and cadence. Their only logical differences are the declared gates: `A0`
disables automatic behavior, `A1` enables only existing S4, and `B2` enables
the S2.1 extension on top of S4. Any rejection/restore in this positive frozen
fixture, undeclared gate difference or extra automatic call invalidates the
arm rather than being averaged into performance.

The frozen 38-action fixture and declared corpus must report complete
content-free event streams, call counts, transaction outcomes, stable session
identity, candidate availability and matched timing positions. For the frozen
fixture, `B2` must accept exactly two transactions and complete its second
transaction at a same-run physical action ordinal `<= 23`; otherwise S2.1 has
not exercised the mechanism needed by the observed product failure. Its
attempt-2 outcome must also prove that ordinal is later than the attempt-1
ordinal, so the second transaction cannot be attributed to the first key.

The integration gate also covers first-rejection terminal behavior,
second-rejection prior-mixed restore, Delete after two accepts, explicit Path
supersession, Partial Commit tombstone behavior and isolated personalized
ordering without production userdb access.

### Layer 3 — physical-device exploratory gate

Physical third-party-keyboard input follows the canonical Human method in
`PERFORMANCE_BASELINE.md`; coordinate/XCTest/Computer Use typing is prohibited.

The first device decision uses one manually entered `A1 → B2` pair on the same
connected device and same source checkpoint:

- Release-optimized signed internal artifacts differ only by the S2.1 gate;
- the Human opens an otherwise-empty Reminders field, selects Universe Chinese
  nine-key and manually types the frozen synthetic sequence without selecting
  Path or candidates;
- the App exports content-free performance logs; artifact/log hashes and
  device/build/schema/access identity are recorded;
- each arm requires all 38 ordered events, one stable valid session, zero
  commit, candidate availability and no missing/duplicate input, digit leak,
  candidate disappearance or keyboard termination;
- `A1` requires exactly one accepted transaction; `B2` requires exactly two,
  with the second outcome bound to the same run at action ordinal `<= 23` and
  strictly after attempt 1.

The exploratory direction advances only when `B2`, relative to its paired
`A1`, both reduces the count of matched events at or above `100 ms` and does
not increase the paired worst event. This is an experiment stop rule, not a
shipping SLO. If either condition fails, stop after the first pair instead of
repeating manual runs.

Only after that direction gate passes may Quality complete a three-pair
counterbalanced Human matrix. The exploratory `A1→B2` is pair 1 and is reused;
only pair 2 `B2→A1` and pair 3 `A1→B2` are added. The total is three pairs, not
four. Manual cadence remains an acknowledged confound; results are matched by
local event identity and reported as diagnostic physical-device evidence, not
a fixed-cadence benchmark.

Every internal-device sequence ends with replacement installation of a
reviewed ordinary gate-off Release. No uninstall, container deletion, userdb
reset, Reminders deletion, automated host input or Product Gate inference is
allowed.

## Exit Criteria

- Product, Assignment, ADR, plan and reusable performance-procedure sources
  describe one consistent S2.1 contract.
- State, call, rollback, privacy, personalization and user-ownership boundaries
  contain no unresolved design ambiguity.
- Architecture and Quality reviewers independently return their findings.
- Documentation link/status and `git diff --check` validation pass.
- Focused rolling-ledger/policy/controller tests and the full KeyboardCore suite
  pass.
- The explicit pinned-RIME `A0/A1/B2`, rollback, Delete, Path/Partial and
  isolated-personalization matrix passes with zero unexpected skips.
- Strict Debug and Release Simulator builds plus RIME vendor verification pass;
  ordinary Release behavior remains disabled.
- Architecture and Quality independently review the implementation checkpoint.
- Physical `A1→B2` evidence remains a later Human-input gate and is not inferred
  from automated evidence.

## Independent Design Review

Architecture and Quality independently reviewed the complete uncommitted design
snapshot after all remediation rounds:

- **Architecture:** `Pass`; P0/P1/P2/P3 all zero.
- **Quality:** `Pass`; P0/P1/P2/P3 all zero.
- All intermediate findings were closed in the reviewed snapshot.
- `git diff --check -- docs` passed.

These reviews authorized Product handoff of the design. Product subsequently
authorized implementation; the prior reviews still do not prove implementation
correctness, authorize Release enablement or satisfy Product Gate.

## Implementation Evidence

The implementation and automated evidence are recorded in
[`t9-auto-anchor-s21-implementation-2026-07-29.md`](../evidence/t9-auto-anchor-s21-implementation-2026-07-29.md).
The immutable remediation checkpoint `4c1baff` independently passed:

- **Architecture:** `Pass`; P0/P1/P2/P3 all zero;
- **Quality:** `Pass`; P0/P1/P2/P3 all zero, with focused, full KeyboardCore
  and four-test real-RIME reruns.

This closes automated implementation review and permits preparation of the
Human physical-device `A1→B2` pair. It does not satisfy that Human gate,
Product Gate or Release approval.

## Physical exploratory A1→B2 evidence

The first Human pair is recorded in
[`t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md`](../evidence/t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md):

- source checkpoint `90642c3`;
- both arms valid (38 events, stable session, zero commits, candidates present);
- A1 accepted exactly once; B2 accepted exactly twice with attempt 2 at action
  ordinal 20 (≤23 and after attempt 1);
- direction stop rule **PASS**: ≥100 ms count 4→3 and worst 175.9→142.3 ms;
- residual stalls remain RIME-dominated; not Product Gate;
- ordinary gate-off Release restored by replacement after the pair.

Quality may now schedule the optional three-pair counterbalanced Human matrix
(reuse this pair as pair 1). Product Lead retains acceptance authority.

### Three-pair matrix outcome (2026-07-30)

Completed under the same freeze and recorded in the evidence file above:

| Pair | Order | Direction |
|---:|---|---|
| 1 | A1→B2 | PASS |
| 2 | B2→A1 | FAIL (≥100 ms count unchanged) |
| 3 | A1→B2 | FAIL (≥100 ms count unchanged) |

Synthesis: **1/3** direction PASS; B2 remains contract-valid (two accepts) with
mild per-spike softening, but does not robustly reduce ≥100 ms event count.
Residual stalls stay RIME-dominated. Not Product Gate. Product Lead must route
next work (stop vs new RIME-side Assignment).

## Stop Conditions

Stop and return to Product/Architecture if implementation would require:

- more than two automatic apply attempts or a second attempt after first
  rejection;
- more than one automatic transaction per physical key;
- adaptive backoff, candidate-window/later-page queries or another session;
- rewriting an already accepted automatic prefix instead of extending it;
- weakening first-candidate or multiset conservation;
- a multi-step rollback chain, synchronous persistence or content-bearing log;
- production userdb access, new retention/deletion policy or learned rank as
  Path authority;
- Release-default enablement, a user setting, 26-key/schema/vendor change or
  host-text semantic change.

## Handoff

- **Handoff Target:** Architecture & Knowledge Steward and Quality,
  Performance & Release Maintainer for independent implementation review, then
  Product Lead
- **Required Handoff Content:** exact state machine, call/rollback table,
  user-authority and personalization boundaries, Layer 1–3 matrix, manual
  device method and reviewer findings
- **Revalidation Trigger:** Any change to attempt count, trigger timing,
  syllable-depth increment, overlap threshold, rollback target, userdb
  boundary, device method, Release gate or RIME/session ownership
