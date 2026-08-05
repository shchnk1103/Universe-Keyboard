# CANARY-001 bounded build/test evidence — 2026-08-03

Status: **run004 automated build/test + Simulator evidence complete: bounded Pass; overall CANARY-001 remains Partial**

Authority: Product Lead explicitly activated local build, automated tests and
Simulator only. Physical device, production wiring, App Group/userdb cleanup,
commit and push remain prohibited.

Command manifests:

- v1: `t9-responsive-pipeline-canary-001-build-test-command-manifest-2026-08-03.txt`
  — retained; C02 exposed an ordinary compile failure.
- v2: `t9-responsive-pipeline-canary-001-build-test-command-manifest-v2-2026-08-03.txt`
  — not executed after source fingerprint drift.
- v3: `t9-responsive-pipeline-canary-001-build-test-command-manifest-v3-2026-08-04.txt`
  — retained; C02R3 exposed the active-kill MainActor circular wait.
- v4: `t9-responsive-pipeline-canary-001-build-test-command-manifest-v4-2026-08-04.txt`
  — retained; C02/C03 passed and C04 exposed internal callback/coalescing gaps.
- v5: `t9-responsive-pipeline-canary-001-build-test-command-manifest-v5-2026-08-04.txt`
  — retained; C02–C06 passed and C07 exposed one strict unused-result error.
- v6: `t9-responsive-pipeline-canary-001-build-test-command-manifest-v6-2026-08-04.txt`
  — current manifest after explicit unused-result consumption and independent
  0/0/0/0 reviews; SHA-256
  `10447f04d76fa57dbc37e37019aa58b52755ac1217614d07375226b1e2f3f5a8`.
- v7: `t9-responsive-pipeline-canary-001-build-test-command-manifest-v7-2026-08-04.txt`
  — immutable QEF-01 provenance-repair pre-run freeze; SHA-256
  `3880a49af4c3a02cbcab04d17197998d1faeca18f4de4c1141ed3bb853cc0507`;
  rejected by pre-run Architecture/Quality review and never executed.
- v8: `t9-responsive-pipeline-canary-001-build-test-command-manifest-v8-2026-08-04.txt`
  — rejected by pre-run Architecture/Quality review and never executed; SHA-256
  `04b9a040238a7418473923b3fe562b3ee07d61f1a136646ba4247e6049f36283`;
  bound to run header by SHA-256
  `09133e2e26efaeaed31a8c72a5beb00cef775cedc3d4a9eaef498884b460af03`.
- v9: `t9-responsive-pipeline-canary-001-build-test-command-manifest-v9-2026-08-04.txt`
  — current mechanically gated immutable pre-run refreeze; earlier SHA
  `d04eea23e67b34439fc350985ec499d84d53fab4ae8e9b7bb1a24243ea805009`
  was rejected pre-run and never executed; run001, run002 and run003 terminal
  identities are preserved; current run004 SHA-256
  `5f39593c5641266f38e810ab316d6533bd3bb852e15934a4a78b2c07318c8ae2`;
  bound to the JSON run header, expected-artifact manifest and evidence tool by
  binding SHA-256
  `b11e318a8f9f55df2bde38dd28ea449d87dda38be7a92b5f9fc448a1d062d72d`.
  No v9 command may run before independent Architecture and Quality approval
  with P0/P1 = 0 and a pre-run approval receipt.

## Environment

- HEAD: `3585a540ba8389673acd49128d87040ac9619f27`
- Xcode: `27.0 (27A5228h)`
- Swift: `6.4`
- Simulator: iPhone 17 Pro Max / iOS 27.0 /
  `06C5BC3E-7599-4761-A1A2-71DAEA991474` / Booted at v6 freeze
- Worktree: ambient dirty; frozen fingerprints are in the immutable manifest
- Full Access / host / geometry: `not-observed` for this automated build/test
  layer; no physical-device or manual runtime claim is permitted

## Results

| ID | Layer | Result | Evidence |
|---|---|---|---|
| C02V9 run001 | KeyboardCore ordinary full (v9 one-shot) | Fail / environment | exit 1 before test execution; SwiftPM manifest compilation could not write the Clang module cache under the managed sandbox; log and fail-closed receipt retained; xunit not created |
| C02V9 run002 | KeyboardCore ordinary full | Tests Pass / evidence capture Fail | child exit 0; XCTest `All tests` executed 906 with 0 failures; Swift 6.4 wrote a zero-test `C02-keyboardcore-full.xunit-swift-testing.xml` instead of the requested XCTest xunit path; runner returned 96 and retained the terminal receipt/log |
| D01 run002 | Focused xunit behavior probe | Diagnostic | `--disable-swift-testing` produced no XCTest xunit; confirms `--xunit-output` cannot supply the required XCTest record in this toolchain |
| C02V9 run003 | KeyboardCore ordinary full | Pass | 906 tests, 0 failures; strict sanitized `All tests` count record captured |
| C03V9 run003 | Canary contract focused | Tests Pass / evidence capture Fail | child exit 0; XCTest `Selected tests` executed 9 with 0 failures; strict parser rejected the aggregate label and the one-shot chain stopped |
| C04V9–C11V9 / P01V9–P05V9 run003 | Remaining v9 chain | NotRun | one-shot sequence stopped at first non-zero and mechanically rejected continuation/overwrite |
| C02V9 run004 | KeyboardCore ordinary full | Pass | 906 passed, 0 failed, 0 skipped; `All tests` aggregate captured |
| C03V9 run004 | Canary contract focused | Pass | 9 passed, 0 failed, 0 skipped; `Selected tests` aggregate captured |
| C04V9 run004 | Thread-affine/canary focused | Pass | 18 passed, 0 failed, 0 skipped; `Selected tests` aggregate captured |
| C05V9–C07V9 run004 | Ordinary Debug/Release and internal Debug strict builds | Pass | all three builds exit 0; binary identities retained locally |
| C08V9 run004 | Ordinary Simulator tests | Pass | 139 passed, 0 failed, 0 skipped |
| C09V9 run004 | Canary lifecycle Simulator test | Pass | 1 passed, 0 failed, 0 skipped |
| C10V9 run004 | RimeBridge Simulator tests | Partial | 34 passed, 0 failed, 20 classified `NotObserved` skips; unknown skip = 0 |
| C11V9 / P02V9 run004 | Ordinary restore | Bounded Pass | ordinary package installed to Simulator; built/installed App and Extension executable hashes match; internal condition absent; Main App launch smoke NotRun |
| P03V9–P05V9 run004 | Aggregate result, publication scan, inventory | Pass | result verdict pass; frozen publishable scope pass; final inventory and sidecar pass |
| C01 | RIME vendor | Pass | Structural inventory verified for 11 framework artifacts |
| C02 | KeyboardCore ordinary full (v1) | Fail | `ThreadAffineRimeEngineBridge` did not satisfy writable `onRuntimeSelectionChanged` protocol requirement |
| C02R | KeyboardCore ordinary full (v2 retry) | Blocked | Codex usage-limit gate rejected execution before process creation; retry time reported as 2026-08-08 13:20 |
| C02R3 | KeyboardCore ordinary full (v3) | Fail | 905 tests, 15 assertion failures in 3 active-kill tests; deterministic MainActor/owner circular wait, not flake |
| D01V3 | Focused active-kill diagnostic after correction | Pass | 3 tests, 0 failures; diagnostic only, source drift requires v4 formal rerun |
| C02R4 | KeyboardCore ordinary full (v4) | Pass | 905 tests, 0 failures; exit 0 |
| C03V4 | Canary contract focused (v4) | Pass | 9 tests, 0 failures; exit 0 |
| C04V4 | Thread-affine/canary focused (v4) | Fail | 17 tests, 3 assertion failures in 2 presentation tests; diagnostic replay reproduced |
| D02V4 | Post-correction dual-mode focused diagnostics | Pass | Internal 18/0; ordinary 15/0; latest rev5 visible/painted, rev1–4 coalesced |
| C02R5 | KeyboardCore ordinary full (v5) | Pass | 906 tests, 0 failures; exit 0 |
| C03V5 | Canary contract focused (v5) | Pass | 9 tests, 0 failures; exit 0 |
| C04V5 | Thread-affine/canary focused (v5) | Pass | 18 tests, 0 failures; active-kill, completion-depth and latest-visible regressions |
| C05V5 | Ordinary Debug strict build (v5) | Pass | `BUILD SUCCEEDED`; exit 0; x86_64 vendor-slice notes retained |
| C06V5 | Ordinary Release strict build (v5) | Pass | `BUILD SUCCEEDED`; exit 0; x86_64 vendor-slice notes retained |
| C07V5 | Internal canary strict build (v5) | Fail | exit 65; strict warnings-as-errors rejected an unused `withLock` result in `ThreadAffineRimeSession.swift` |
| D03V5 | Strict internal diagnostic after explicit unused-result fix | Pass | exit 0; x86_64 vendor linker warnings retained as residual |
| C02R6 | KeyboardCore ordinary full (v6) | Pass | 906 tests, 0 failures; exit 0 |
| C03V6 | Canary contract focused (v6) | Pass | 9 tests, 0 failures; exit 0 |
| C04V6 | Thread-affine/canary focused (v6) | Pass | 18 tests, 0 failures; exit 0 |
| C05V6 | Ordinary Debug strict build (v6) | Pass | `BUILD SUCCEEDED`; exit 0; x86_64 vendor-slice notes retained |
| C06V6 | Ordinary Release strict build (v6) | Pass | `BUILD SUCCEEDED`; exit 0; x86_64 vendor-slice notes retained |
| C07V6 | Internal canary strict build (v6) | Pass | `BUILD SUCCEEDED`; exit 0; strict internal condition; x86_64 vendor residual retained |
| C08V6 | Ordinary concrete Simulator tests (v6) | Pass | 139 tests, 0 failures; `TEST SUCCEEDED`; xcresult retained at `/private/tmp/canary-001-sim-default-v6.xcresult` |
| C09V6 | Canary lifecycle Simulator test (v6) | Pass | 1/1, 0 failures; `TEST SUCCEEDED`; xcresult retained at `/private/tmp/canary-001-sim-internal-v6.xcresult` |
| C10V6 | RimeBridge Simulator tests (v6) | Pass / Partial coverage | 34 passed, 20 skipped, 0 issues; 19 skips lack RIME/Lua/spike/userdb environment and 1 lacks an immutable 40-character S4 commit; `TEST SUCCEEDED`; xcresult retained at `/private/tmp/canary-001-rimebridge-v6.xcresult` |
| C08V5–C10V5 | Concrete Simulator tests (v5) | Blocked | No Simulator currently Booted; Human must boot one |
| C05V4 | Ordinary Debug strict build (v4) | Pending | Generic iOS Simulator destination |
| C06V4 | Ordinary Release strict build (v4) | Pending | Generic iOS Simulator destination |
| C07V4 | Internal canary strict build (v4) | Pending | Generic iOS Simulator destination |
| C08V4–C10V4 | Concrete Simulator tests (v4) | Blocked | No Simulator currently Booted; Human must boot one |
| C03 | Canary contract focused | NotRun | Blocked behind C02R baseline retry |
| C04 | Thread-affine/canary focused | NotRun | Blocked behind C02R baseline retry |
| C05 | Ordinary Debug strict build | NotRun | Blocked behind C02R baseline retry |
| C06 | Ordinary Release strict build | NotRun | Blocked behind C02R baseline retry |
| C07 | Internal canary strict build | NotRun | Blocked behind C02R baseline retry |
| C08 | Ordinary Simulator tests | NotRun | Blocked behind C02R baseline retry |
| C09 | Canary lifecycle Simulator test | NotRun | Blocked behind C02R baseline retry |
| C10 | RimeBridge Simulator tests | NotRun | Blocked behind C02R baseline retry |

No test count is frozen or claimed in advance.

## Completion boundary

- v3 stopped at the first formal failure, C02R3. C03V3–C10V3 were not run.
- Architecture and Quality independently classified the failure as a P0
  production-shaped active-kill circular wait. The correction is restricted to
  the frozen allowlist and does not alter defaults or positive terminal rules.
- v5 stopped at C07V5. C08V5–C10V5 were not run. v6 supersedes all future
  commands; any further source/test drift requires a new immutable manifest.
- C02R6–C10V6 completed in manifest order. Of the 20 C10V6 skips, 19 require
  external RIME/Lua/spike/userdb environment and 1 requires an immutable
  40-character S4 commit. All remain explicit `NotObserved` coverage and do
  not prove the skipped runtime behavior.
- This closes only the authorized local build/automated-test/Simulator layer.
  Physical-device execution, Full Access/host provenance, production wiring,
  Product Gate, Release approval and ADR 0025 acceptance remain prohibited or
  unproved. Ordinary defaults remain unchanged.
- Generic Simulator builds retained x86_64 vendor-slice/linker diagnostics.
  The concrete evidence destination was arm64 iPhone 17 Pro Max / iOS 27.0;
  no x86_64 RIME runtime-compatibility claim is made.

## Bounded disposition

- **Proved at this layer:** frozen ordinary/internal sources compile under
  strict Swift concurrency and warnings-as-errors; the executed KeyboardCore,
  canary-contract, thread-affine, app/Extension lifecycle and available
  RimeBridge Simulator tests have zero failures; the ordinary build does not
  receive the internal canary compilation condition.
- **Not proved at this layer:** physical-device behavior, real-engine tests
  gated by external RIME spike/userdb directories, Full Access and host
  provenance, manual input/runtime presentation, performance SLO, x86_64 RIME
  compatibility, restore after a physical-device install, privacy beyond the
  retained automated evidence, Product Gate, Release or ADR 0025 acceptance.
- The default enable gate remains off, the explicit kill-switch remains
  independently available, and no production rollout wiring was authorized.

## Independent evidence review

- Quality independently verified the frozen source/diff/manifest hashes and the
  retained xcresults: C08 139 success / 0 issue; C09 1 success / 0 issue; C10
  34 success / 20 skipped / 0 issue.
- Quality verdict: **P0/P1/P2/P3 = 0/1/1/0** before the skip-classification
  correction above; the P2 classification issue is now documented, but the P1
  remains.
- Architecture verdict: **Bounded Pass / QEF provenance Partial,
  P0/P1/P2/P3 = 0/0/1/0**; its P2 is the same incomplete pre-run provenance
  viewed as architectural handoff debt rather than a result-integrity failure.
- **P1 provenance gap:** the pre-run v6 manifest omitted the destination-
  discovery output hash and per-command expected-artifact records; xcresults
  have retained temporary paths but no frozen digest/archive identity, and
  C02R6–C07V6 lack retained command-output artifact hashes. These facts cannot
  be reconstructed post hoc as pre-run provenance.
- Disposition: execution results are retained as a bounded diagnostic layer,
  but this run cannot formally close QEF-01. Formal closure requires a newly
  authorized immutable manifest and rerun; that is outside the current frozen
  matrix and has not been performed.
