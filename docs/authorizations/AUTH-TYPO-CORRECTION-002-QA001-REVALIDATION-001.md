# Authorization: AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-001

## Current Status

| Field | Value |
|---|---|
| Status | `superseded — unconsumed; exact source snapshot changed before capture; do not reuse` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Case | `TC2-CASE-QA-001` / `TC2-CTR-QA-001` |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | Make one fresh formal designated-Simulator QA-001 attempt |
| Run ID | Allocate `TC2-SIM-20260919-<HHMMSS>-QA001-REVAL-<n>` immediately before capture |

## Exact Execution Identity

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` / `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- `origin/main` context: `162b09fd58ba60538a944026b1902efa405c75aa`; no same-head claim
- Tracked production/test diff SHA-256: `c9225a435b833aa1c637c21bead8f85f1465d2b6d161c30a74b5789408c523be`
- Untracked production/test file-content SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Designated target: iPhone 17 Pro Max / iOS 27 Simulator, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`, Messages, `+1 (888) 555-1212`

## Authorized Scope

- Use the real, deployed `rime_ice` runtime on the designated Simulator only.
- Use the curated synthetic input `wimenjintianquhongyuan` and observe whether the intended candidate `我们今天去公园` enters the authorized production candidate area and whether manual candidate selection, Delete, Space, Return, paging, Partial Commit and switch-away behavior remain intact where exercised.
- Require human confirmation that Universe Keyboard is the active keyboard and Full Access is enabled; do not treat Apple-style appearance or the AX label “简体拼音” as identity proof or disproof.
- Record an explicit inconclusive result if the intended candidate is outside the current authorized production recall budget or if keyboard identity/provenance is not independently established.

## Required Evidence

- Fresh exact build/device/schema/archive/provenance identity and raw-artifact hashes.
- UI/runtime observations tied to direct sidecar diagnostics, with no sent host message and no raw host text retained.
- Candidate visibility, selection result and interaction-regression observations, including unrun items.
- Explicit distinction between “candidate absent under the current budget” and “runtime/keyboard identity not proven.”

## Explicit Exclusions

- No expanded progressive-recall production path, semantic scorer, AI model, schema/vendor change or search-budget change.
- No `FakeCandidateProvider`, old Ice directory, host injection, pasteboard, `typeText`, `documentContext`, `setMarkedText` or automatic commit.
- No physical-device substitution, performance budget, Product Gate, Quality Gate, Release or parent-closure conclusion.

## Stop / Completion

Stop when the designated Simulator, active Universe Keyboard, Full Access, exact RIME provenance or direct sidecar route cannot be established. Completion produces a fresh QA-001 Run Receipt; a missing target candidate is a valid inconclusive outcome and not by itself a code-failure verdict.
