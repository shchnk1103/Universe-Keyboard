# RIME-SYNC-001 Architecture re-review — stable diagnostic error codes — 2026-09-23

## Verdict

**Accept** for `ARCH-RIME-SYNC-001-P2-01` only. The bounded diagnostic-code
change removes arbitrary NSError domain/code/message values from this mapping
while retaining stable application-level categories for known failures. This
does not accept the broader Assignment or authorize Product Close, merge,
TestFlight, or Release.

## Exact review binding

- Base `HEAD`: `4a51228fc8e435d538e9a5f7342ae325502e1e66`
- Reviewer: fresh independent GPT-6 Luna runtime, Hypatia
  (`01a0ceeb-6769-78f0-9d6d-332f76a1dd0d`)
- Review mode: read-only; reviewer confirmed the three supplied SHA-256 values.
- `Universe Keyboard/Services/RimeSyncTransport.swift`:
  `7646c523a5fa1309a8162f21dc48fb067913438ec62a57e23bcfe2191b3a6fc4`
- `UniverseKeyboardTests/RimeSyncTests.swift`:
  `657a24764ef25a0b64748e7e2104916c1d272849887f775fc7bd190b8826a7fc`
- `docs/RIME_SYNC.md`:
  `1440643d4a78cafd6e50b78c61cd1c003fa735efa302a8a7492921337a04fe7c`

## Finding disposition

`RimeSyncDiagnosticErrorCode` uses a finite set of fixed raw values. Known
folder preflight stages, `RimeSyncError` cases, and `RimeStandardSyncError`
cases map to stable application categories; associated underlying errors are
not interpolated. Unknown errors map to `unknown`. Regression tests verify
classification and exclusion of underlying NSError domain/code/message, and
the RIME contract documents the stability/privacy boundary.

The reviewer found no blocking issue in the mapping, its call sites, or the
nonisolated enum's Swift 6 boundary. The reviewer did not run tests or builds;
the signed focused Simulator run is recorded separately in the readiness
ledger.

## Scope and non-claims

This Accept is limited to the P2 diagnostic mapping on the three bound files.
It does not inherit or replace the P1 Architecture conclusion, does not provide
a Quality or Product conclusion, and does not validate physical devices,
CloudKit, cross-platform compatibility, hosted CI, or full RIME synchronization.
The RIME-SYNC-001 parent remains `Active` pending remaining evidence and the
Product lifecycle decision.
