# Authorization: AUTH-TYPO-CORRECTION-002-INT003-AX-LOW-OVERHEAD-REVALIDATION-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — inconclusive; external batch used the system Simplified Pinyin keyboard after current-keyboard identity was misread` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Case | `TC2-CASE-INT-003` / `TC2-CTR-INT-002` |
| Feasibility basis | [`INT-003 low-overhead AX feasibility`](../evidence/typo-correction-002-int003-ax-low-overhead-feasibility-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Run ID | `TC2-SIM-20260919-184155-INT003-AX-LOW-OVERHEAD-REVAL-01` |
| Consumed at | `2026-09-19T18:41:55+08:00` |

The authorized attempt is closed as an evidence-grade inconclusive capture. The
fresh runtime inspection did not prove that Universe Keyboard was the current
keyboard before the batch. The observed `下一个键盘 | Universe Keyboard` label
identified the *next* keyboard, so the batch was delivered to system Simplified
Pinyin. This Authorization must not be reused; a valid retry needs a new
Authorization and Run ID.

This is a fresh runtime Authorization. It does not reuse the retry 03 Run ID,
although it may validate the same already-installed package identity if no
rebuild or reinstall occurs.

## Authorized scope

- Use the already-installed Debug Simulator package from retry 03, binding its
  exact package hashes and App Group provenance in the new receipt.
- Use a fresh `snapshot_ui` to prove Messages, Universe Keyboard identity and
  current independent AX key refs.
- Use one same-screen external AX `batch` sequence with correctly mapped key
  refs and short requested inter-step delays, sending real key taps to the
  visible product controls.
- Record only content-free diagnostics, actual timestamps, package/provenance
  identity and raw-artifact SHA-256 values.
- Preserve the `<180 ms` cadence requirement as an observed diagnostic
  condition, not a planned delay.

## Explicit exclusions

- No Swift, Objective-C, test, schema, vendor archive or production behavior
  changes.
- No `typeText`, pasteboard, host-text injection, `documentContext` or
  `setMarkedText`.
- No FakeCandidateProvider, old Ice directory, synthetic RIME fixture or
  candidate-count inference.
- No reuse of stale AX element refs from a prior snapshot.
- No QA-001, paired-performance, Product/Quality/Release Gate, commit, push,
  PR, merge or Assignment closure.

## Stop conditions

Stop with an explicit inconclusive receipt if Universe Keyboard identity,
current AX refs, real touch delivery or actual `<180 ms` cadence cannot be
proven. A restarted capture or any build/install/schema/device change requires
another fresh Authorization and Run ID.
