# Product Decision: TYPO-CORRECTION-002 controller/sidecar runtime implementation

> **Decision ID:** `PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`
>
> **Decision:** `Accepted — bounded Grok implementation Assignment/Authorization, awaiting Human confirmation that AUTH is live`
>
> **Date:** `2026-09-21 Asia/Shanghai`

## Decision

Human Product Owner / Product Lead, in the current Grok session on
`2026-09-21 Asia/Shanghai`, accepted the following bounded package after the
Codex [`runtime integration handoff`](../evidence/typo-correction-002-codex-to-grok-runtime-integration-handoff-2026-09-21.md):

1. Write the implementation Assignment and matching Authorization naming
   **Grok** as Executor. Stop after those records exist. Do not start Swift
   work until the Human confirms the Authorization is live.
2. Keep the reviewed pure-Core checkpoint worktree untouched. After AUTH is
   live, copy its exact three-file uncommitted snapshot into a new Grok
   implementation worktree at the same baseline.
3. Pin the coverage-deficit predicate and runtime budgets below. Keep
   production first-stage `12/8`. Do not wire `60/64` as the always-on
   first-stage path.
4. Keep operation-receipt / diagnostics changes out of this slice. F-04
   remains `tech_debt`.

This decision creates
[`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../assignments/typo-correction-002-runtime-integration-implementation-001.md)
and
[`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md).
The Authorization is `active` / `unconsumed`. It is not yet a live execution
permit.

## Pinned runtime values

| Item | Pinned value |
|---|---|
| Stage-one path | Existing production `12/8`; unchanged |
| Stage-two eligibility | Same operation still current; existing letter/Chinese/minimum-length eligibility holds; stage one produced **zero** accepted display-eligible corrections; the structural selector returns at least one group not already accounted in stage one; remaining query-attempt budget is greater than zero |
| Selected-group budget | `8` |
| Started-query-attempt budget | `8` |
| Per-query candidate limit | `3` |
| Accepted-display-result cap | `4` |
| Stage-two generation pool | Substitution-only structural selector over the existing default-off progressive-recall hypothesis set. That generation pool is selector input only. It is not the first-stage query path. |
| Diagnostics / operation receipt | Out of scope. Existing content-free route and sidecar-query events may remain. Do not add an operation receipt. Do not reuse the DEBUG decision trace. |

## Checkpoint handling

| Field | Value |
|---|---|
| Original worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard` |
| HEAD | `4d1050f4b677494e06448cb40a83ef2da46d7b27` |
| Tree | `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Uncommitted diff SHA-256 | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |
| Changed paths | `ContextualTypoCorrection.swift`, `TypoCorrectionRecallPreflight.swift`, `TypoCorrectionRecallPreflightTests.swift` |
| Disposition | Retain in place. Do not reset, clean, commit, push or merge it. After AUTH is live, copy the exact snapshot into a new Grok implementation worktree. Re-verify the three identities before any Swift edit. |

## Adapter API boundary

Future implementation, after AUTH is live, must expose one
`TypoCorrectionSidecarOwner` adapter over the already-installed
`TypoCorrectionCandidateQuerying` facade:

- `routeLocalOwnerEpoch: UInt64?` is `nil` on default `RimeEngineImpl`.
  MainActor-responsive and thread-affine routes may supply a route-local
  observation. A route-local value may only fail a fence.
- `correctionCandidates(for:limit:)` is the existing synchronous facade.
- Controller-owned `recallEpoch` remains authoritative on every route.
- Do not cast through to a raw engine, construct a second RIME session, use
  `Task.detached`, add a parallel query lane, or invent a native epoch for
  default `RimeEngineImpl`.

## Explicit non-claims

This decision does not start source work, consume the implementation
Authorization, run tests, query RIME, capture a Simulator/device Run, change
QA-001 / INT-003 / paired-performance status, commit, push, open a PR, merge,
close a Gate, or close the parent Assignment.
