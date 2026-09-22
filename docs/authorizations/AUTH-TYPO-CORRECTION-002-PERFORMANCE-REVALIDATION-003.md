# Authorization: AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — inconclusive; both arms captured, but treatment used a new keyboard-extension process and no paired conclusion is valid` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Scope | Diagnostic paired `BASELINE` / `TREATMENT` comparison only |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | One fresh paired-performance evidence slice after the diagnostic observability smoke passed |
| Run ID | `TC2-PERF-20260919-195848-REVAL-03` |
| Arm labels | `BASELINE` and `TREATMENT` |
| Supersedes | The consumed and inconclusive `AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-002`; no prior arm is reused |

The diagnostic smoke receipt proved that the high-fidelity journal can emit a
fresh product key event. This Authorization permits one comparable diagnostic
pair on the same unchanged package. It does not establish a Release budget.

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
new diagnostic process after an arm begins invalidates the pair and requires
another Authorization and Run ID.

## Authorized procedure

- Keep the same device, OS, host, schema, Full Access state, installed package,
  diagnostic categories and measurement method in both arms.
- Before each arm, verify a future high-fidelity expiration and a fresh
  process-bound journal. Do not use persistent `rime_diag_log` as the arm's
  fresh event stream.
- `BASELINE`: contextual correction sidecar disabled.
- `TREATMENT`: contextual correction sidecar enabled.
- Use the declared synthetic sequence and no candidate selection or host send.
  Human cadence, duplicate/deleted keys and visible stalls must be recorded as
  confounds; they are not engine timing samples.
- Record direct sidecar route/outcome, elapsed distributions, candidate-refresh
  timing where emitted, event counts, session identity and comparability.
- Stop before `TREATMENT` if `BASELINE` does not produce a qualifying fresh
  product event stream. Do not manufacture a pair from UI screenshots or
  historical logs.

## Required evidence and non-claims

- Preserve both arm journals, provenance, package identity and SHA-256 values.
- Report sample count, median and worst observed values only where the fresh
  diagnostics support them; do not invent a 180 ms Release threshold.
- Debug/Simulator evidence is diagnostic only. This Authorization does not
  authorize a physical-device substitution, INT-003, QA-001, Product,
  Quality, Release or merge Gate, commit, push, PR, merge, TestFlight,
  Release or Assignment closure.
