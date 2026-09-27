# RIME-SYNC-001 bounded iOS V1 — Final independent Quality review — 2026-09-24

## Verdict

**Pass with conditions** for the exact bounded iOS V1 candidate and the scoped
engineering evidence recorded below. This verdict is limited to Quality
evidence sufficiency; it does not close the parent Assignment or grant Product,
merge, TestFlight, or Release authority. `RIME-SYNC-001` remains `Active`.

## Review boundary and independence

- Role: independent Quality, Performance & Release Maintainer.
- Mode: read-only evidence and source/test inspection. No source, test, state
  mirror, device, or network action was performed.
- Candidate identity: detached `HEAD`
  `4a51228fc8e435d538e9a5f7342ae325502e1e66`; tracked diff SHA-256
  `627e18f2a60886cb8d971c18b9d6b5bd7f94c406bc4be7eb464a95036bbc6215`.
- Independent manifest calculation: union of `git diff --name-only
  --no-renames` and `git ls-files --others --exclude-standard -z`, sorted;
  excluded only this receipt and
  `docs/reviews/rime-sync-v1-final-architecture-review-2026-09-24.md`.
  Result: 38 paths; canonical `<sha256(bytes)>  <path>\n` manifest SHA-256
  `87ab2543ed4c79b213eaaabb515933d984f5402d3fd10169437c00b0985fa29a`.
  Count and digest match the requested snapshot. No drift detected.
- Independence: this review was performed as a separate review pass and did
  not reuse historical verdicts as the current conclusion. Historical
  receipts were used only to locate and cross-check evidence. Current hashes
  for the RIME transport, RIME unit tests, UI tests and isolated UI fixture
  match the component hashes in the prior exact-candidate review.
- Evidence artifact inspection was read-only. The primary full-suite
  `.xcresult` summary was independently read; the preserved Xcode enumeration
  JSON was independently compared with all test case IDs in that result.

## Evidence matrix

| Area | Evidence and finding | Quality conclusion / limit |
|---|---|---|
| Full App + Keyboard suite | Quality-reviewed `.xcresult`: `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T15-32-10-266Z_pid5815_cb08a974.xcresult`; iPhone 18 Pro / iOS 27.0 / build 24A434. Its raw log `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-23T15-32-10-266Z_pid5815_b0dff4c5.log` records `build-for-testing` against this exact worktree path and the same test-products bundle. Read-only result summary: 397 total = 387 passed + 10 skipped + 0 failed. | Pass with conditions. Run/worktree path and reviewed component hashes bind the run to this candidate; authoritative result count is 397; no skipped test is a pass. |
| 398/397 reconciliation | Preserved native enumeration JSON and `.xcresult` IDs independently compared: 397 enabled unique IDs, 397 result IDs, zero enumeration errors, zero missing and zero extra after normalizing target prefixes. Both recorded enumeration files have SHA-256 `622366d88fe300149f0a5442973c9e4fd8a1d3efff6ba4e8e43018da02f17b5d`. Product Decision `QR-CURRENT-01` accepts only this exact-run reporting mismatch. | Exact-run set reconciliation is adequate to use the `.xcresult` count. MCP's underlying extra discovery count remains unexplained; no additional or missing test, tool repair, or future-run accuracy is inferred. |
| Skip accounting | The primary `.xcresult` lists all 10 skipped IDs: one pinned vendor archive convergence case; one unsigned-host Keychain CRUD case; five scheme-resource coexistence/installer cases; and three TD-012 authorized physical-device model-staging cases. The Keychain case passed separately in the signed lane. | Skip reasons are visible and bounded. The other nine remain unverified by this run; they are not credited as V1 passes or silently removed from scope. |
| Focused signed Keychain + transport | `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T15-31-31-357Z_pid5815_3e99c755.xcresult`; read-only summary confirms 11 passed / 0 skipped / 0 failed on iPhone 18 Pro / iOS 27.0 Simulator. Includes 10 transport tests and production Security.framework unique-item add/read/update/delete. | Pass for signed Simulator integration; no physical-device Keychain or hosted-CI claim. |
| UI-01 recovery and management | `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T15-07-57-797Z_pid5815_f1640d5d.xcresult`; read-only summary confirms 5 passed / 0 skipped / 0 failed. Assertions exercise WebDAV auth error, recovery-code import then fake corrupted-package response, local disconnect, fake-transport deletion success and failure preservation. | Pass for the tested UI/state paths. Fake transport does not establish live WebDAV behavior, a real cryptographic key mismatch, or provider-side deletion. |
| Test assertions and isolation | Current source hashes match the prior reviewed component hashes: `UniverseKeyboardTests/RimeSyncTests.swift` `657a24764ef25a0b64748e7e2104916c1d272849887f775fc7bd190b8826a7fc`; UI tests `00678a1de9180c082d300649d478ee3cb21848941d9c9555dbc25f3831ffeeeb`; fixture `41550bf022f2d5b039b3b67a8afbf92cf62b1b9fc7b5c74b54d91834de251e99`; transport `7646c523a5fa1309a8162f21dc48fb067913438ec62a57e23bcfe2191b3a6fc4`. Assertions cover merge determinism/unknown-field preservation, authenticated encryption and tamper rejection before publish, local/WebDAV conditional writes and deletion boundaries, diagnostic-code privacy, opt-in/cooldown policy, cancellation lifecycle, and UI error/recovery state. Fixtures isolate defaults and secrets and suppress production background side effects. | Coverage is material for bounded package/transport behavior and selected UI/security transitions. It is not exhaustive provider, physical-device, background scheduler, or full portability evidence. |
| UI-02 physical accessibility | Human-reported iPhone 13 Pro / iOS 27.0 observation on local Debug `1.0 (924)` from the dirty worktree. Fresh supplemental Quality review records the evidence as `Pass with conditions` only for that observation. Product accepted the untested narrow-device check and incomplete full-source/on-device executable binding as residuals. | Supplemental human-attested evidence only. UI-02 is not a formal pass; broader VoiceOver/Dynamic Type conformance is not established. |
| Natural background evidence and Run 02 | Run 02 remains formally `INVALID`; its historical Quality/Architecture `HOLD` is retained. The 2026-09-22/23 success records are supplemental natural observations, not source-bound reproducible qualification. | No claim that Run 02 passed, that its defect was fixed, or that two later natural operations prove general OS scheduling or cross-process safety. |
| Open debts and authority | Assignment and TECH_DEBT retain `TD-002`, `TD-008`, `TD-013` and `TD-017`; the old exact diagnostic error remains unrecoverable `UNKNOWN` under TD-013. Assignment names Quality and Product roles separately and keeps lifecycle Active pending Product Lead action. | Product dispositions do not resolve technical debt or transfer Product/Release authority to Quality. |

## Findings

| ID | Level / disposition | Evidence and effect |
|---|---|---|
| `QR-CURRENT-01` | P2 — Product-accepted, exact-run residual | Reconciliation receipt, lines 12–16, 33–52 and 80–89; Product Decision, lines 5–17 and 29–41. XcodeBuildMCP says 398 discovered while the result and native enumeration contain 397. The two exact ID sets match; internal cause and future tool accuracy remain unknown. Accepted only for the specified 2026-09-23 reviewed run and 2026-09-24 confirmation. |
| `UI-02-RES-01` | P2 — Product-accepted bounded residual; criterion remains not met | UI-02 Quality receipt, lines 23–35; Product Decision, lines 7–14 and 25–32. Narrow-device coverage is absent and the human observation lacks a frozen full-source manifest, device executable readback, media/action trace and per-control detail. Acceptance does not promote the observation to a pass. |
| `TEST-SKIP-10` | P2 — condition retained | Full-suite result reports 10 skipped; reconciliation Product Decision, lines 34–40 explicitly says they remain skips and its ID comparison adds no coverage claim. One Keychain skip is compensated only by the separate signed Simulator run; nine listed cases remain unverified in this broad run. |
| `EVIDENCE-BOUNDARY-01` | P2 — explicit non-claim | Current Quality review, lines 41–51; readiness ledger, lines 88–98. UI-01 fake transport, signed Simulator Keychain, and supplemental human UI-02 observation do not prove provider deletion, physical Keychain, or formal accessibility conformance. |

These are bounded conditions and non-claims, not evidence of a failing test in
the reviewed artifacts. No finding changes the accepted Product dispositions.

## Overall rationale

The exact candidate identity is verified by the requested 38-path manifest.
The primary `.xcresult` is accessible and internally reports 387 passes, 10
skips and no failures; its 397 case IDs agree with the preserved native Xcode
enumeration. Focused signed transport/Keychain and UI-01 bundles independently
report 11/11 and 5/5 respectively. Test source assertions address core package,
security, conditional-write, recovery and state-transition behavior, while
fixture isolation avoids attributing production background effects to UI
tests. The outstanding limits are explicit and, where accepted, have bounded
Product decisions. Therefore the evidence supports a conditional Quality pass
for this bounded iOS V1 engineering candidate, with the findings above kept
visible.

## Review environment and unexecuted items

- Reviewed repository: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`.
- Host: macOS 27.0; evidence Simulator: iPhone 18 Pro / iOS 27.0, Xcode 27.0
  (27A266a). This reviewer did not boot or operate a Simulator.
- Read-only artifact commands: `xcrun xcresulttool get test-results summary`
  and `tests` on existing result bundles; inspected the existing build log and
  JSON enumeration/result-ID comparison. No test, build, or Xcode enumeration
  run was started.
- Not run: build, unit/UI/integration tests, Swift format, CI scripts, Release
  build, performance profiling, hosted CI, device/App/Keychain queries,
  background-task delivery, WebDAV/provider account exercise, provider-side
  deletion, or network access. These were outside the authorized read-only
  review and would create new evidence or state.
- No performance trace or latency/memory measurement was supplied for this
  bounded package; no performance claim is made.
- No source test, source file, state mirror, or prior receipt was modified.
  This receipt is the sole file added by this review.

## Explicit non-claims

This review does not claim formal UI-02 pass, full accessibility conformance,
physical-device Keychain behavior, hosted CI success, production
`BGProcessingTask` delivery or timing, cross-process RIME exclusion, provider
deletion semantics, full cross-platform compatibility, CloudKit completion,
resolution of the 398/397 MCP internal cause, closure of Run 02, or resolution
of `TD-002`, `TD-008`, `TD-013`, `TD-017` or historical `UNKNOWN`. It grants no
parent closure, Product Gate, commit, push, merge, TestFlight or Release
authority.
