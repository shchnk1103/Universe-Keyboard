# Authorization: AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-REVALIDATION-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — evidence recorded; independent review pending` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Parent Product Assignment | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | Collect one bounded, provenance-first sidecar observability evidence slice |
| Run ID | `TC2-SIM-20260919-171730-SIDECAR-REVAL-01` |

## Consumption

- Consumed at: `2026-09-19T17:17:30+08:00`
- Authorized operation started: signed Simulator build/run, exact `rime_ice` provenance inspection and direct sidecar observability capture.
- Consumption does not authorize source edits, schema/vendor changes, publication, or any parent Gate conclusion.

## Capture Facts

- Build/run: XcodeBuildMCP `build_run_sim` succeeded on the designated Simulator and installed the signed Debug package from `/tmp/universe-keyboard-typo-correction-002-parent-revalidation-002-derived/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`.
- Main executable SHA-256: `6b5dbc6230dda4ac30c6de62376f14279d82a370e88f59744087d7efb6072072`.
- Keyboard executable SHA-256: `cff9029d5fe70ea5a77a51a60a9bc8788d33dacf2f859834a80c326a14df9190`.
- Main debug dylib SHA-256: `b546385685794607950c0fce756dd0c1ec37e89f1cc96d89832f5a69ca90a1fa`.
- Keyboard debug dylib SHA-256: `15900c7dedc80bd152181717c6d1ed45ea1c9876f08c7d9649ffdbb55722ef0d`.
- Runtime provenance path: `AppGroup/97142D9B-ED12-4FFE-8C3A-58F175731B4F/Rime/user/rime-runtime-provenance.json`.
- Runtime provenance SHA-256: `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54`.
- Runtime identity: active schema `rime_ice`; artifact `rime-ice-20260630-675d23b0`; version `2026.06.30`; archive SHA-256 `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac`; installed-content SHA-256 `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26`.
- Main-App runtime snapshot showed `输入方案 = 雾凇拼音` and `资源状态 = 已就绪`.
- Tool limitation: direct host-path inspection found the App Group and provenance file; a parallel `xcrun simctl get_app_container` call lost its CoreSimulatorService connection. That tool error is retained as a limitation and is not classified as App Group absence.
- Direct sidecar capture: 70 content-free records with route `real_rime_sidecar`, schema `rime_ice`, outcome `returned`, result count/limit `3/3`, elapsed `1–6 ms`, and stable live-session identity. The bounded summary and raw-artifact manifest are recorded in [`Run Receipt`](../evidence/typo-correction-002-sim-run-2026-09-19-sidecar-reval-01.md).
- Capture outcome: bounded sidecar observability evidence recorded. The earlier startup event with route `unavailable` remains an explicit lifecycle limitation; it is not hidden or reclassified.

## Exact Execution Identity

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch: `codex/typo-correction-002-provenance-sidecar`
- Worktree HEAD: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- `origin/main` context: `162b09fd58ba60538a944026b1902efa405c75aa`; no same-head claim
- Tracked production/test diff SHA-256: `c9225a435b833aa1c637c21bead8f85f1465d2b6d161c30a74b5789408c523be`
- Untracked production/test file-content SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Designated target: iPhone 17 Pro Max / iOS 27 Simulator, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`, Messages, `+1 (888) 555-1212`

## Authorized Scope

- Read and record the exact deployed runtime provenance for `rime_ice`, including active schema, artifact version, archive SHA-256, provenance receipt identity/SHA-256 and raw artifact hashes.
- Capture content-free diagnostics that directly identify the real-RIME sidecar query route, operation/session identity, bounded outcome and live-session identity preservation.
- Correlate the direct sidecar query event with the same Run ID and App Group artifact window.
- Record `UNKNOWN` or inconclusive when the route, receipt, or live-session boundary cannot be independently observed.

## Required Evidence

1. Signed main/extension identity and exact raw artifact SHA-256.
2. App Group availability and the actual `rime-runtime-provenance.json` (or repository-equivalent provenance artifact) read from the designated runtime.
3. Direct `real_rime_sidecar` query-route evidence and result/outcome bounds without raw input, candidate text or host text.
4. Evidence that the live composition/session identity remains unchanged across the sidecar query.
5. Immutable Run Receipt with tool limitations and a SHA-256 manifest of retained raw artifacts.

## Explicit Exclusions

- No source/test/schema/vendor/archive change, rebuild or publication is authorized by this receipt.
- No `FakeCandidateProvider`, old Ice directory or unit-test fixture may be used as runtime evidence.
- No raw pinyin, candidate text, host text, pasteboard, `typeText`, `documentContext`, `setMarkedText` or automatic commit may be captured or injected.
- No INT-003, QA-001, paired-performance, Product, Quality, TestFlight, Release, merge or Assignment-closure conclusion may be written under this receipt.

## Stop / Completion

Stop if App Group access, exact provenance, direct sidecar route or live-session identity is unavailable. A stopped or incomplete slice must produce an explicit inconclusive note, not a pass. Completion means only a new sidecar Run Receipt is ready for independent Architecture review; this Authorization does not close a Gate.
