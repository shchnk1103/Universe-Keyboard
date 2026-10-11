# Authorization: AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-002

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — inconclusive; fresh UI capture had no keyboard input or sidecar events; post-capture audit found the high-fidelity window expired` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Case | `TC2-CASE-QA-001` / `TC2-CTR-QA-001` |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | Make one fresh formal designated-Simulator QA-001 attempt on the current exact source snapshot |
| Run ID | `TC2-SIM-20260919-192740-QA001-REVAL-03` |
| Supersedes | `AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-001`, which remains unconsumed and must not be reused because its bound source diff SHA predates the coordinate-harness change |

## Exact Execution Identity

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` / `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- `origin/main` context: `162b09fd58ba60538a944026b1902efa405c75aa`; no same-head claim
- Tracked Swift diff SHA-256: `f1e4e17637bf6aaaaf314f882b229d50751792cfafc488f0d2cd8197863c7862`
- Untracked Swift manifest SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Designated target: iPhone 17 Pro Max / iOS 27.0 Simulator, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, conversation `+1 (888) 555-1212`

## Authorized Scope

- Build and install the current exact worktree snapshot on the designated
  Simulator when needed to bind the capture to the current source identity.
- Use the deployed real `rime_ice` runtime and the curated synthetic input
  `wimenjintianquhongyuan`.
- Require human confirmation that Universe Keyboard is active and Full Access
  is enabled. Apple-style appearance and the AX label “简体拼音” are not
  identity proof or disproof.
- Observe candidate visibility and, only if the intended candidate is visibly
  present, manually select it and exercise the authorized interaction checks:
  Delete, Space, Return, paging, Partial Commit and switch-away where safely
  available. Do not send the host message.
- Preserve content-free diagnostics, direct sidecar route markers and raw
  artifact hashes; do not retain raw host text or candidate strings in raw
  diagnostic artifacts.

## Required Evidence

- Fresh build/install/device/schema/archive/provenance identity and raw-artifact
  SHA-256 values bound to this Run ID.
- Human keyboard/access-state attestation and direct keyboard-extension
  diagnostics proving that the observed input came from Universe Keyboard.
- Candidate visibility/selection and interaction-regression observations,
  including explicitly unrun items.
- Explicit distinction between a missing candidate under the current bounded
  production recall and an unproven keyboard/runtime identity.

## Explicit Exclusions

- No expanded recall path, semantic scorer, AI model, schema/vendor change or
  production search-budget change.
- No FakeCandidateProvider, old Ice directory, synthetic RIME fixture, host
  injection, pasteboard, `typeText`, `documentContext`, `setMarkedText` or
  automatic commit.
- No physical-device substitution, INT-003 cadence claim, paired-performance
  result, Product/Quality Gate, Release, merge or parent-closure conclusion.

## Stop / Completion

Stop if the designated Simulator, active Universe Keyboard, Full Access, exact
RIME provenance or direct sidecar route cannot be established. A missing target
candidate is a valid evidence-grade inconclusive result and is not by itself a
code-failure verdict. Completion produces one fresh QA-001 Run Receipt; this
Authorization does not authorize review, publication or closure.
