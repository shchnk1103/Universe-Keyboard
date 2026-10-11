# Authorization: AUTH-TYPO-CORRECTION-002-DIAGNOSTIC-SMOKE-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — bounded pass; fresh high-fidelity journal contained real key events` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | Establish one fresh high-fidelity diagnostic window and prove one real keyboard key event before any QA/performance retry |
| Run ID | `TC2-SIM-20260919-194824-DIAG-SMOKE-01` |
| Scope | Observability precondition only; no QA-001 or paired-performance data collection |

This is a bounded precondition check for the two consumed QA/performance
Authorizations. It exists because their fresh journals contained only
`presentation.appeared` and a post-capture audit found the high-fidelity
expiration had already elapsed. It does not reinterpret either prior receipt.

## Exact Execution Identity

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` /
  `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- `origin/main` context: `162b09fd58ba60538a944026b1902efa405c75aa`; no same-head claim
- Tracked Swift diff SHA-256: `f1e4e17637bf6aaaaf314f882b229d50751792cfafc488f0d2cd8197863c7862`
- Untracked Swift manifest SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Build product: `/tmp/universe-keyboard-typo-correction-002-qa-perf-reval-20260919-derived/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`
- Main executable SHA-256: `6f3ad3ea8e0dccb85af0ddc00c1885f6bb0d4101beee5c71283f976ec882cbba`
- Main debug dylib SHA-256: `ce2c05a3e665c3fb3d5eaec15a8a7f4d1b157f7108b39f7cfcd7c7732c25d58a`
- Keyboard executable SHA-256: `0ec6b1e8467de8edca3603e3e4db226e1094343f0a70497e4e87ed5d87a07f91`
- Keyboard debug dylib SHA-256: `6c7c2d26727a63102987faf07477fae0167271bc98e21093d0ed0473bcdef6d2`
- Designated target: iPhone 17 Pro Max / iOS 27.0 Simulator,
  UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, conversation `+1 (888) 555-1212`

No source change, rebuild, reinstall or schema change is authorized by this
record. If any of those becomes necessary, stop and obtain a new Authorization
and Run ID.

## Preconditions and authorized actions

- Human operator confirms that Universe Keyboard is selected and Full Access is
  enabled. Apple-style appearance and the AX label “简体拼音” are not identity
  proof or disproof.
- Human operator enables high-fidelity diagnostics in the app's diagnostic
  settings and verifies, by a read-only App Group preference check, that
  `diagnostics_high_fidelity_expiration` is in the future before input.
- Reopen or foreground the designated Messages keyboard as needed to create a
  fresh keyboard-extension process/journal. No package reinstall is needed.
- Human operator performs exactly one ordinary key tap, with no phrase entry,
  candidate selection, send, pasteboard, host injection, `typeText`,
  `documentContext` or `setMarkedText`.
- Capture the fresh process-bound content-free JSONL, its SHA-256, the current
  App Group provenance and the preference value used to prove the diagnostic
  window.

## Pass condition

The fresh keyboard-extension JSONL for this Run contains the new process's
`presentation.appeared` plus at least one product key event such as
`touch.terminal` or `key_highlighted`, with timestamps after the verified
future expiration. This only proves that the diagnostic channel is usable for
the next capture; it does not prove candidate recovery or performance.

## Stop conditions and non-claims

- Stop as `inconclusive` if high-fidelity diagnostics cannot be enabled, the
  expiration is not in the future, or the fresh journal has no real key event.
- Stop if current Universe Keyboard identity, Full Access, exact package
  identity, App Group provenance or process-bound artifact ownership cannot be
  established.
- Do not use persistent `rime_diag_log` text or historical JSONL as a
  substitute for the fresh process-bound journal.
- This Authorization does not authorize QA-001, paired performance, INT-003,
  sidecar conclusions, Product/Quality/Release Gates, commit, push, PR, merge,
  TestFlight, Release or Assignment closure.

Completion produces one smoke receipt and consumes this Authorization. A pass
permits requesting separate new QA-001 and paired-performance Authorizations;
it does not automatically reuse the consumed ones.
