# Authorization: AUTH-TYPO-CORRECTION-002-INT003-AX-COORDINATE-FEASIBILITY-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — inconclusive; XCTest coordinate actions completed but no product key event was observed in fresh diagnostics` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Case | `TC2-CASE-INT-003` / `TC2-CTR-INT-002` |
| Feasibility basis | [`INT-003 low-overhead AX feasibility`](../evidence/typo-correction-002-int003-ax-low-overhead-feasibility-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Run ID | `TC2-SIM-20260919-190945-INT003-AX-COORDINATE-FEAS-01` |
| Scope owner | `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift` only |

The implementation and the one authorized capture are complete. The selected
XCTest method passed, but the fresh keyboard-extension journal contained only
`presentation.appeared`; it contained no `touch.terminal` or
`key_highlighted` event. The coordinate path therefore does not prove product
touch delivery or INT-003 cadence. This Authorization is consumed and must not
be reused for another dispatch variant.

This Authorization is a bounded amendment to the parent INT-003 lane. It
permits a test-only implementation and one corresponding Simulator feasibility
capture. It does not authorize a production behavior change or a Product Gate.

## Authorized implementation

- Add an opt-in XCTest coordinate-touch path in the named UI-test file.
- Preserve the existing exact Universe Keyboard activation and product-owned
  AX key discovery before deriving key-center coordinates.
- Send the fixed content-free synthetic key fixture through real
  `XCUICoordinate` touch actions in one XCTest runner loop. A short coordinate
  press is allowed if it is required to produce a down/up touch pair.
- Keep the existing host-injection exclusions: no `typeText`, pasteboard,
  `documentContext`, `setMarkedText`, fake provider, old Ice directory or
  synthetic RIME fixture.
- Build/install the resulting test-only package on iPhone 17 Pro Max / iOS 27.0
  Simulator `06C5BC3E-7599-4761-A1A2-71DAEA991474`, then collect fresh
  content-free diagnostics and raw-artifact hashes under the new Run ID.

## Explicit exclusions

- No production Swift, Objective-C, KeyboardCore, RimeBridge, schema, vendor
  archive, search-budget or recall change.
- No reuse of the invalid external-batch refs or the
  `TC2-SIM-20260919-184155-INT003-AX-LOW-OVERHEAD-REVAL-01` artifacts.
- No QA-001, sidecar observability, paired-performance, Product/Quality/Release
  Gate, commit, push, PR, merge, TestFlight, Release or Assignment closure.

## Evidence and stop conditions

- The receipt must bind the changed test source, build/install identity,
  simulator, active schema/provenance and fresh raw-artifact SHA-256 values.
- Actual adjacent key-event timestamps in the product diagnostics are
  authoritative; requested sleeps and XCTest wall-clock duration are not.
- Stop with an explicit inconclusive receipt if current Universe Keyboard
  identity, product-owned key discovery, real coordinate touch delivery or
  fresh diagnostics cannot be proven.
- Even if the observed cadence is below 180 ms, stale-work cancellation must
  be evidenced separately before INT-003 can pass.
- Any further code change, rebuild, reinstall, schema change, device change or
  restarted capture requires another Authorization and Run ID.
