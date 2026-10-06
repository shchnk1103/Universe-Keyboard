# Quality Review Record — Paired Rollout v5 Validation Evidence R1

## Identity and verdict

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`
- Stable lane / round: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001/v5-validation-quality` / `1`
- Packet SHA-256: `6a6d8f435ce01d215fd8a19014e93b4a198885905db0395cca1d6332b35ff9b6`
- Baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256: `bf0bc3f3b2fd2fdd1bd2df1a5a197484f4eb5a815e2968eeb45b4d12cbfb18a7`
- Validation report SHA-256: `f35b9e13a546450616a32c852f88e84fddfd7f638f5efc5e3a435440a2a88cde`
- Manifest r2 SHA-256: `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- Stage authorization SHA-256: `7204731eb1af58ab428b56235e0602aeff86373f395fbf9e7681bb5cf0576375`
- Entry receipt SHA-256: `d0f5092e458778ec0e1eac387edcdf3dd9f8e9bc7dc6d9983e9fce9228727842`
- Verdict: **Pass with conditions**
- Reviewer runtime: `/root/v5_quality_review` using the requested `gpt-6-luna` model.

The five frozen criteria were fully covered. The evidence supports only that the authorized v5 validation matrix completed without reported failures, with the skips and unexplained count difference below. It is not a Product/Quality Gate, Release decision or Assignment closure.

## Findings

1. **Candidate identity and environment — Pass.** All seven manifest source/test hashes, baseline and frozen documents matched. Artifact-index SHA-256 is `80147fb5288926695569dc33f411e1e6687e1212b4a22b7ee728e7d0621151c2`; recursive `.xcresult` manifest SHA-256 is `8c429cc52f0b1c020454b8646c53c6c169b2286b4dfc0fd53f8a916507ede138`. The destination is iPhone 18 Pro / iOS 27.0, UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`, runtime build `24A434`; Xcode 27.0 build `27A266a`, Swift 6.4.0.34.1, Swift 6.0 mode, complete strict concurrency and warnings-as-errors are recorded consistently.
2. **Required matrix — Pass.** Pinned RIME vendor verification: 12 framework artifacts; strict format/lint: seven Swift files; KeyboardCore: 1,177 passed / 0 failed; RimeBridgeTests: 105 total, 85 passed, 20 skipped, 0 failed; App + Keyboard: `.xcresult` 428 total, 418 passed, 10 skipped, 0 failed, raw suites 412 + 16; signed Keychain test: 1 passed / 0 skipped / 0 failed; Release build: succeeded, 0 errors / 0 warnings; `git diff --check`: exit 0. The signed lane covers only the unsigned-lane Keychain skip for the same test.
3. **429 / 428 difference — Bounded residual.** The validation report records the contemporaneous XcodeBuildMCP response as 429 discovered tests; saved `.xcresult` and raw suite totals are 428 (412 + 16), with 0 failures. The evidence identifies both values but does not explain their difference. Do not select one number as a replacement or infer a cause.
4. **Conditional skips — Pass with stated limits.** RimeBridgeTests: 20 skips (2 Lua smoke fixture gaps; 1 immutable S4 identity gap; 9 isolated T9 runtime-matrix fixture gaps; 1 T9 compatibility Spike fixture gap; 6 T9 pinyin-selection Spike fixture gaps; 1 R4-B real-engine fixture gap). App + Keyboard: 10 skips (2 Ice archive-source fixture gaps; 3 fixed Wanxiang/Ice extract-tree gaps; 1 pinned `default.yaml` gap; 1 unsigned-host Keychain entitlement skip, covered only by the corresponding signed test; 3 physical-device-only TD-012 checks). None were counted as passed.
5. **Claim boundary — Pass.** Evidence claims only completion of the authorized validation matrix without reported failures. It does not establish manual keyboard operation, real-device behavior, Full Access, Lua runtime behavior, installed paired-build behavior, production marker emission, root cause, Product/Quality Gate, Release, Maps reproduction, v6 authorization or parent closure.

## Conditions and residuals

These are proposed dispositions for Product Lead review; none is recorded as Product-approved.

| ID | Owner | Proposed disposition | Evidence pointer |
|---|---|---|---|
| `V5-Q-001` | Executor / Environment Executor; Product Lead decides added scope | `accept` as a bounded unexplained count residual, unless a later decision depends on the exact discovery denominator | Validation report; `UniverseKeyboardTests.summary.json` and `.log` |
| `V5-Q-002` | Executor / Environment Executor; Product Lead decides future test scope | `accept` as unverified conditional RimeBridge coverage, or `fix` only under a future exact fixture-backed authorization | Validation report “Skips and coverage limits”; `RimeBridgeTests.log` |
| `V5-Q-003` | Executor / Environment Executor; Product Lead decides future test scope | `accept` as unverified conditional App + Keyboard coverage, or `fix` only under a future exact fixture-backed authorization | Validation report “Skips and coverage limits”; `UniverseKeyboardTests.log`; `RimeSyncKeychain` results |

Assignment close remains blocked until residual disposition is recorded.

## Usage and stop

- Coverage: all five packet criteria complete; no uncovered review criterion.
- Interactions: 8 including the required checkpoint; within budget. Checkpoint followed interaction 4.
- Elapsed time: end-to-end time unavailable; visible execution calls totaled about 2 seconds.
- Stop reason: budget reached after complete coverage; no scope expansion requested.
- Read-only confirmed. The reviewer attempted a read-only Release `.xcresult` query, but the tool failed to save a temporary report; the saved Release summary and artifact index were used instead. No successful write was observed.
- No tests, builds, formatting, Simulator/CoreSimulator/XcodeBuildMCP, installation, UI, Maps or network operations were performed by the reviewer.
