# Authorization: AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-003

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — inconclusive; fresh input/candidate activity observed, target candidate not visible` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Case | `TC2-CASE-QA-001` / `TC2-CTR-QA-001` |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | One fresh formal QA-001 attempt after the diagnostic observability smoke passed |
| Run ID | `TC2-SIM-20260919-195848-QA001-REVAL-04` |
| Supersedes | The consumed and inconclusive `AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-002`; no prior artifacts are reused as current-run input evidence |

The diagnostic smoke receipt proved that the high-fidelity journal can emit a
fresh product key event. This Authorization now permits one QA-001 capture on
the same unchanged package. It does not authorize a performance arm, code
change or closure.

## Exact execution identity

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` /
  `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- `origin/main` context: `162b09fd58ba60538a944026b1902efa405c75aa`; no same-head claim
- Tracked Swift diff SHA-256: `f1e4e17637bf6aaaaf314f882b229d50751792cfafc488f0d2cd8197863c7862`
- Untracked Swift manifest SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Main executable SHA-256: `6f3ad3ea8e0dccb85af0ddc00c1885f6bb0d4101beee5c71283f976ec882cbba`
- Main debug dylib SHA-256: `ce2c05a3e665c3fb3d5eaec15a8a7f4d1b157f7108b39f7cfcd7c7732c25d58a`
- Keyboard executable SHA-256: `0ec6b1e8467de8edca3603e3e4db226e1094343f0a70497e4e87ed5d87a07f91`
- Keyboard debug dylib SHA-256: `6c7c2d26727a63102987faf07477fae0167271bc98e21093d0ed0473bcdef6d2`
- Designated target: iPhone 17 Pro Max / iOS 27.0 Simulator,
  UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, conversation `+1 (888) 555-1212`
- Schema/provenance: `rime_ice`, artifact `rime-ice-20260630-675d23b0`,
  archive SHA `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac`,
  installed SHA `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26`,
  receipt `078F7EA2-F9CA-4033-B7DD-48BE636BEB38`

Any source change, rebuild, reinstall, schema change, device/host change or
new diagnostic process after the capture begins invalidates this identity and
requires another Authorization and Run ID.

## Authorized procedure

- Human operator confirms Universe Keyboard is selected and Full Access is on.
- Before input, verify the high-fidelity expiration is in the future and a new
  keyboard-extension process/journal is active. If it is expired before input,
  re-enable it and verify again; do not continue with an unverified window.
- Clear the Messages draft and manually enter exactly
  `wimenjintianquhongyuan`; pause without sending.
- Observe whether `我们今天去公园` is visibly present. Select it only if it is
  visibly present and record the selection as a human action.
- If selected, run the authorized interaction checks that are safely available:
  Delete, Space, Return, paging, Partial Commit and switch-away. Record
  explicitly which were not run.
- Preserve only content-free diagnostics and raw artifact hashes. Do not use
  `typeText`, pasteboard, host injection, `documentContext`, `setMarkedText`,
  FakeCandidateProvider, an old Ice directory or a synthetic RIME fixture.
- Do not send the host message.

## Required evidence and stop conditions

- The fresh journal must contain the current process's key lifecycle event(s),
  not only historical `rime_diag_log` text. The receipt must bind the fresh
  journal, package/provenance identity and SHA-256 values.
- If the target candidate is absent, record `inconclusive`; do not call it a
  product failure. If the fresh input route is absent, stop before claiming a
  candidate result.
- Stop if high-fidelity diagnostics expire before capture, the keyboard identity
  is unclear, provenance cannot be read, or the package identity changes.
- This Authorization does not authorize paired performance, INT-003, Product,
  Quality, Release or merge Gates, commit, push, PR, merge, TestFlight,
  Release or Assignment closure.
