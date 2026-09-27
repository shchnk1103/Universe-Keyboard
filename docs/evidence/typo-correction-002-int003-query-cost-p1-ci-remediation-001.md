# INT-003 P1 CI remediation 001

Status: **bounded source repair and local CI-equivalent checks passed; commit/push and hosted revalidation pending.** PR #184 remains Draft.

## Authority and trigger

- Assignment: [`TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001`](../assignments/typo-correction-002-int003-query-cost-measurement-001.md), still **Active**.
- The Human's 2026-09-27 instruction to repair GitHub CI authorized this bounded follow-up. The separate [CI remediation AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-CI-REMEDIATION-001.md) was consumed at `2026-09-27T19:32:19+08:00` for the newly required diagnostics-display path and existing Draft PR update. The prior consumed P1 instrumentation AUTH was not reused.
- PR: [#184](https://github.com/shchnk1103/Universe-Keyboard/pull/184), open Draft.
- Failed hosted run: [36315031868](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/36315031868), head `9d7739e9e43c3349da313b582551be602f99c4b7`, base `1160ac6fd8696c3036391cdf59bc9fe096d0b219`. Lightweight checks, Swift format and KeyboardCore passed; RimeBridge, App/Keyboard, Keychain and Release jobs failed during compilation.

## Reproduced causes and bounded fixes

1. `RimeCandidate` resolves to both `KeyboardCore.RimeCandidate` and the Objective-C struct imported from `rime_api.h`. The production facade and its RimeBridge test fake now explicitly name `KeyboardCore.RimeCandidate`.
2. The App diagnostics formatter exhaustively switched over `DiagnosticEvent.Field` but omitted `.typoRecallQuery`. It now renders only that payload's closed enums and numeric values. A focused display test verifies those values and checks that input/candidate text is absent.

No query scheduling, event semantics, payload schema, product behavior or runtime budget changed.

## Local verification

All checks used the isolated worktree and the non-conflicting iPhone 17 Pro / iOS 26.0 simulator `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`, selected after the Human said another thread owns iPhone 18 Pro. The iPhone 18 Pro and the P2-designated iPhone 17 Pro Max were not operated.

| Check | Result | Evidence |
|---|---|---|
| Strict Swift format on every changed Swift path against base `1160ac6…` | Pass | `xcrun swift-format lint --strict --configuration .swift-format` |
| Whitespace validation | Pass | `git diff --check` |
| KeyboardCore | **1,170 passed, 0 failed** | `swift test --package-path Packages/KeyboardCore` |
| RimeBridge | **105 tests passed** | `/private/tmp/uk-int003-p1-ci-rimebridge-retry-20260927.xcresult` |
| App + Keyboard | **421 tests passed**, including the new formatter case | `/private/tmp/uk-int003-p1-ci-app-keyboard-retry-20260927.xcresult` |
| RIME Keychain integration | **1 test passed** | `/private/tmp/uk-int003-p1-ci-keychain-20260927.xcresult` |
| Release build | Pass | `xcodebuild … -configuration Release … build` |

The new `xcresulttool get test-results summary` command could not read TestReport due host permissions. The legacy result-object API returned the counts above; each `xcodebuild test` exited successfully.

Hosted CI for the repaired head has not run yet. No independent Architecture/Quality verdict is claimed for the repair delta. The parent remains **Active**; P2 AUTH remains Active/unconsumed, and no capture, Gate, merge, parent Close, TestFlight, Release, ADR Accept or `RimeRuntimeProvenance` restoration occurred.
