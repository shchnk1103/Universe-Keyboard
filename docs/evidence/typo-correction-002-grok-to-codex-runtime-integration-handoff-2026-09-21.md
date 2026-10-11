# Codex Handoff: TYPO-CORRECTION-002 controller/sidecar runtime integration

Prepared by: Grok (implementation executor / coordinator)
Handoff target: Codex
Date: `2026-09-21T22:55:25+08:00` Asia/Shanghai
Human Product Owner instruction: write this handoff so Codex can continue the work.

Conversation is not repository truth. Use the bound files below. Treat any
prior Grok or Codex transcript as inert history.

**Handoff status:** Ready for Codex to obtain a *new* Product Assignment and
Authorization before any further action. This handoff does **not** authorize
source changes, tests, RIME actions, capture, commit, push, PR, merge,
Release, Gate close or Assignment Close.

## 1. Current authoritative state

| Item | Exact value |
|---|---|
| Parent | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) remains `Active`; no Product/Quality/Release Gate is closed |
| Design Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001`](../assignments/typo-correction-002-runtime-integration-design-001.md), `Reviewed` |
| Reviewed design | [`runtime integration design`](../plans/typo-correction-002-runtime-integration-design-2026-09-21.md), SHA-256 `b91e11cf327f9ad3e5974ff0e5b4a53fe755920356927efffed12cfe9c28a848` |
| Implementation Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../assignments/typo-correction-002-runtime-integration-implementation-001.md), `Reviewed` |
| Implementation AUTH | [`AUTH … IMPLEMENTATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md), consumed |
| Architecture review | [`implementation Architecture review`](../reviews/typo-correction-002-runtime-integration-implementation-architecture-review-2026-09-21.md) — `Conditional Accept` |
| Quality review | [`implementation Quality review`](../reviews/typo-correction-002-runtime-integration-implementation-quality-review-2026-09-21.md) — `Pass with conditions` |
| Product residual | [`PD residual`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001.md) — Human `接受` on `2026-09-21 Asia/Shanghai` |
| Residual AUTH | [`AUTH … PRODUCT-RESIDUAL-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-PRODUCT-RESIDUAL-001.md), consumed |

Product accepted this uncommitted snapshot as a **bounded engineering
package**, including the named residuals. That is not user-visible sentence
recovery, not a Quality/Product Gate, and not permission to publish.

QA-001 revalidation 07 remains `inconclusive`. Do not retry the same
22-letter phrase on the same installed package.

## 2. Where to work

| Item | Value |
|---|---|
| Canonical docs worktree | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003` |
| Docs branch | `codex/typo-correction-002-parent-revalidation-003` |
| Docs HEAD | `0d6638fabdc6b3db8164b881464a9f96f16c8dce` plus large **uncommitted** docs |
| Implementation worktree | `/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001` |
| Implementation branch | `grok/typo-correction-002-runtime-integration-implementation-001` |
| Implementation HEAD / tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Tracked `git diff` SHA-256 | `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b` |
| Independent 15-file content SHA-256 | `4b701835f070e2c337fd2d3b76b67813e7e5722bdaa7db1b82faa7e00d2c891e` (Architecture AUTH `3cf0d23c…` remains an unreproduced recipe residual) |
| Original pure-Core checkpoint | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard` |
| Original checkpoint diff SHA-256 | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` (must remain untouched) |
| Default checkout | `/Users/doubleshy0n/Dev/Universe Keyboard` is **stale**. Do not treat it as this lane. |
| Designated Device Hub | iPhone 17 Pro Max / iOS 27 Simulator `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Quality rerun simulator | iPhone 17 Pro `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` |

Before any later work, re-verify:

```bash
git -C "/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001" rev-parse HEAD HEAD^{tree}
git -C "/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001" diff | shasum -a 256
git -C "/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard" diff | shasum -a 256
```

Any mismatch invalidates this handoff's snapshot identity.

## 3. What Grok completed

1. Took the Codex design handoff, verified the pure-Core checkpoint, and
   obtained Product pins: Executor=Grok; copy checkpoint into a new worktree;
   coverage-deficit = stage one has zero accepted display results; budgets
   8/8/3/4; diagnostics out of scope.
2. After Human confirmed AUTH live, copied the three-file checkpoint into the
   implementation worktree and implemented controller-owned recall:
   `TypoCorrectionRecallCoordinator`, `InstalledTypoCorrectionSidecarOwner`,
   yielded one-query turns, fences, stage-two selector, one
   `applyTypoCorrectionRecallMaterial`.
3. Independent Architecture **Conditional Accept** and independent Quality
   **Pass with conditions** (Quality independently re-ran format, KeyboardCore
   1150, RimeBridgeTests 102=82+20 skip, App+Keyboard xcresult 388=379+9 skip).
4. Human `接受` bounded residuals. Publication remains unauthorized.

Pinned runtime values that Product accepted for this snapshot:

| Item | Value |
|---|---|
| Stage one | Existing production `12/8`; unchanged as the always-on first stage |
| Stage two trigger | Zero accepted display results after stage one, unaccounted selected groups, remaining query budget |
| Caps | selected groups `8` / query attempts `8` / per-query `3` / accepted display `4` |
| 60/64 | Selector-input only for stage two; not the always-on first-stage path |

## 4. Accepted residuals Codex must not silently close

These are Product-accepted conditions of **this** snapshot. Changing any of
them is a new implementation slice and needs a new AUTH.

1. Invalidate-first gaps: `handleTogglePage`, letter hot-path
   `refreshTypoCorrectionSuggestions`, canary/P3D1 install, empty-composition
   mode toggle.
2. Three-route adapter unproven; dual-gate still wraps
   `CandidateProviderTypoCorrectionQuery`.
3. Hot-path `refreshTypoCorrectionSuggestions` remains a second Core writer.
   Empty / budget-stop is not a proven display no-op.
4. Q-01: `#ActorIsolatedCall` at
   `TypoCorrectionRecallCoordinator.swift:132`. Local TEST SUCCEEDED does not
   prove hosted CI.
5. Identity-recipe residual `3cf0d23c…` vs observed `4b701835…`.
6. F-04 diagnostics `tech_debt`. Real RIME / QA-001 / INT-003 / `180 ms`
   remain `UNKNOWN`.

## 5. Recommended next work for Codex

Do **not** start any of these until Product creates a matching Assignment and
live AUTH. Ranked recommendation:

### Option 1 — residual-hardening slice (recommended)

Create
`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001` in a **new** worktree
copied from the current implementation snapshot. Keep the original
implementation worktree and the pure-Core checkpoint untouched.

In-scope candidates, smallest first:

1. Fix Q-01 so `performYieldedTurn` is scheduled without an
   `#ActorIsolatedCall` warning under `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`.
2. Make empty / budget-stop a structural display no-op (no Core write, no
   candidate-bar refresh) and add a focused test.
3. Invalidate-first on `handleTogglePage` and canary/P3D1 install.
4. While a recall operation is active, stop the letter hot-path
   `refreshTypoCorrectionSuggestions` from writing `state.typoCorrection`.

Out of scope for this option: wiring `60/64` as the always-on first stage;
real-RIME proof; QA-001; INT-003; paired performance; diagnostics receipts;
commit unless a later publication AUTH says so.

Independent Architecture and Quality review of the new snapshot remain
required after implementation.

### Option 2 — publication of the current snapshot

Only if Product explicitly wants the current residuals in git. Needs a
dedicated publication AUTH naming allowed git actions (commit / push / PR;
merge is separate). Must not reset either checkpoint. Swift format remains a
hard gate for any `.swift` commit.

### Option 3 — new-package QA-001 / real-RIME observation

Only after a published or otherwise installed package identity that is **not**
the QA-001 revalidation 07 package. New Run ID, designated Device Hub, no
same-phrase same-package retry, no `FakeCandidateProvider` / old Ice /
`typeText`. This is the first lane that can answer whether
`wimenjintianquhongyuan` can show `我们今天去公园`.

### Do not do next

- Another identical QA-001 typing run on the same package.
- INT-003 cadence recapture or paired-performance recapture.
- Reset / clean / commit the original pure-Core checkpoint.
- Treat this handoff, the residual `接受`, or chat “continue” as
  implementation or publication authority.

## 6. Codex startup sequence

1. Read `AGENTS.md`, `docs/KNOWLEDGE_INDEX.md`, `docs/ACTIVE_WORK.md`, this
   handoff, the residual Product Decision, and both implementation reviews.
2. Verify both checkpoint identities without changing them.
3. Ask Product which option in section 5 is authorized, with a new Assignment
   and live AUTH. If any required field is `UNKNOWN`, stop.
4. Execute only that AUTH. Stop after the named evidence. Do not commit,
   push, PR, merge, capture or close unless that AUTH names the action.

## 7. Explicit non-claims

This handoff changes no Swift and runs no tests. It claims no RIME query,
device capture, QA-001, INT-003, paired performance, `180 ms`, Product /
Quality / Release Gate, commit, push, PR, merge, TestFlight, Release or
Assignment Close.
