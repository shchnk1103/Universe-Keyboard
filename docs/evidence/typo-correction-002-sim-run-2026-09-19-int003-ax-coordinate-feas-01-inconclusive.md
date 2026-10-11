# TYPO-CORRECTION-002 Simulator Run Receipt — INT-003 coordinate-touch feasibility

> **Run ID:** `TC2-SIM-20260919-190945-INT003-AX-COORDINATE-FEAS-01`
>
> **Status:** `inconclusive — XCTest coordinate actions completed, but fresh product diagnostics observed no key event`
>
> **Authorization:** [`AUTH-TYPO-CORRECTION-002-INT003-AX-COORDINATE-FEASIBILITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-COORDINATE-FEASIBILITY-001.md)
>
> **Assignment:** [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)

## Decision boundary

This is an evidence-grade feasibility result for a test-only coordinate path.
The selected XCTest method passed, but the result does not establish that
coordinate touches reached Universe Keyboard, does not provide an INT-003
stimulus cadence, and does not close any Gate.

The distinction is important: XCTest's own action log recorded coordinate
actions associated with the letter-key elements, while the fresh
keyboard-extension diagnostic journal recorded no `touch.terminal` or
`key_highlighted` event. The product diagnostic path is authoritative for
touch delivery, so no product input event is claimed.

## Authority and identity

| Field | Value |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar` |
| Branch | `codex/typo-correction-002-provenance-sidecar` |
| Parent HEAD | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` |
| Testability production input | merged PR #140 at `162b09fd58ba60538a944026b1902efa405c75aa` |
| Changed test file SHA-256 | `3b4a57c1dc6033ce572b89812bb2ab80c4a079bcfdc8d4e166d273859b5be5f2` |
| Tracked Swift worktree diff SHA-256 | `f1e4e17637bf6aaaaf314f882b229d50751792cfafc488f0d2cd8197863c7862` |
| Simulator | iPhone 17 Pro Max / iOS 27.0 |
| UDID | `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Host | Messages, conversation `+1 (888) 555-1212` |
| Configuration | Debug, signed Simulator package |
| Derived data | `/private/tmp/universe-keyboard-typo-correction-002-int003-ax-coordinate-feas-01-derived` |

The changed source is test-only. No production Swift, Objective-C, RIME,
schema or vendor source was changed by this Authorization.

## Build and harness result

- Swift format and strict lint passed for
  `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift`.
- `test_sim` built/installed the package and ran the selected test on the
  designated Simulator.
- Selected test:
  `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests/testTypoCorrectionINT003ControlledAXCoordinateCadence`
- XCTest result: `1 passed / 0 failed / 0 skipped`; selected test duration
  `69.933 s`; test operation duration `129.219 s`.
- Existing exact Universe activation and product-owned AX key discovery passed
  inside the test before coordinate derivation.
- The test derived each key center once and called `XCUICoordinate.tap()` in
  one XCTest loop. It used no `typeText`, pasteboard, host-text injection,
  `documentContext` or `setMarkedText`.

## Package and RIME provenance

| Artifact | SHA-256 |
|---|---|
| Main executable | `ce702b287cef740fa26fe2bc0db57052d415ab76b7d0cbc43999c30123d013ed` |
| Keyboard executable | `b1ef2b5efdb10b3c66ef9c47d80f2c5664092c65a87cbd93222281a9b87e3c0f` |
| Main debug dylib | `e0e9eaf72b79b7514b6736cb4b74188067005afc86e20c6b0e10d27edda54325` |
| Keyboard debug dylib | `5e373c5c44fc43d8718fc03b77a08b5bbf6f247ff2b2e38059682a9f5725ed87` |
| Provenance file | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

The installed provenance remains bound to the previously reviewed `rime_ice`
artifact `rime-ice-20260630-675d23b0`, upstream revision
`6810e8916d160498620a16fef2135956fecbd485`, archive SHA-256
`675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac`,
installed-content SHA-256
`2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26`, and
receipt `078F7EA2-F9CA-4033-B7DD-48BE636BEB38`.

## Diagnostic result

Fresh keyboard-extension artifact:

`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260919-190945-INT003-AX-COORDINATE-FEAS-01/raw/keyboard_extension.jsonl`

| Measure | Observed value |
|---|---|
| Lines | `1` |
| SHA-256 | `141b7d0d289cc0f2aebb8deaaca8d11967a2186333c0b93530f2afdd2ec63300` |
| Only event | `presentation.appeared` at `2026-09-19T11:14:31Z` |
| `touch.terminal` events | `0` |
| `key_highlighted` terminal events | `0` |
| Adjacent key intervals | Not computable |
| Intervals below 180 ms | Not measurable; no product key event |

The copied main-app artifact was unchanged from the prior package-bound
capture, SHA-256 `4d827a30554a3daeb01a81e0e6d30f32b9a57ccc42538c0724f660f3646dfe14`.
The copied provenance artifact was unchanged, SHA-256
`b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54`.

## Claim outcomes

| Claim | Outcome | Boundary |
|---|---|---|
| Coordinate harness compiles and executes its selected XCTest method | `pass for test-runner sub-claim` | 1 passed / 0 failed / 0 skipped |
| Existing Universe AX activation and key discovery completed | `pass for harness precondition` | Test reached coordinate derivation without skip/failure |
| Coordinate touch reached a Universe product key | `unproven` | Fresh product diagnostics contain no key event |
| Actual stimulus satisfies INT-003 `<180 ms` | `not measured` | No product key event; no interval exists |
| INT-003 stale-work cancellation | `inconclusive; not a formal pass` | No qualifying stimulus and no cancellation evidence |
| Sidecar observability / QA-001 / paired performance | `not-run / not claimed` | Outside this feasibility slice |

## Preserved artifacts

Raw artifacts are retained outside Git:

`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260919-190945-INT003-AX-COORDINATE-FEAS-01/raw/`

| File | SHA-256 | Freshness |
|---|---|---|
| `keyboard_extension.jsonl` | `141b7d0d289cc0f2aebb8deaaca8d11967a2186333c0b93530f2afdd2ec63300` | fresh; presentation only |
| `main_app.jsonl` | `4d827a30554a3daeb01a81e0e6d30f32b9a57ccc42538c0724f660f3646dfe14` | unchanged copy from prior capture |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` | unchanged provenance |

XCTest artifacts:

- Result bundle: `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-19T11-13-10-025Z_pid25092_7f1b66b6.xcresult`
- Test log: `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-19T11-13-10-024Z_pid25092_fe64415d.log`
- Test products: `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/test-products/test_sim_2026-09-19T11-13-10-025Z_pid25092_87292910.xctestproducts`

## Non-claims and next boundary

- This receipt does not close INT-003, QA-001, paired performance or any
  Product/Quality/Release Gate.
- It does not prove that coordinate taps are a valid replacement for
  `XCUIElement.tap()`; it proves only that the test method executed.
- The current coordinate implementation must not be reused for another Run.
  A follow-up dispatch variant, if desired, requires a new Authorization and
  Run ID. The next variant must make a single-key diagnostic smoke event
  observable before attempting a 22-key cadence capture.
