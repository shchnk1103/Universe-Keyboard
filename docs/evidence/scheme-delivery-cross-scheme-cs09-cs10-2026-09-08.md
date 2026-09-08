# Evidence: Cross-scheme CS-09 / CS-10 (local candidate)

Date: 2026-09-08 Asia/Shanghai
Checkout: `/private/tmp/uk-scheme-delivery-fix` on `codex/scheme-delivery-fix`
Base tip before slice: `81e6652`
PR: [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) remains
**draft**
Evidence grade: **Executor-recorded**

## Scope

- **CS-09:** Uninstall the only active downloaded Ice or Wanxiang scheme and
  verify the existing fail-closed path deploys builtin Luna before removal,
  clears the target receipt, and selects Luna.
- **CS-10:** After active peer uninstall selects Luna, select the retained
  downloaded scheme and deploy it without reinstallation. The deployment
  request carries that retained schema as its runtime-smoke target; the test
  asserts that no installation path ran.

## Tests

`SchemaManagerTests`:

- `testCS09_UninstallLastActiveIceDeploysLunaAndClearsIceReceipt`
- `testCS09_UninstallLastActiveWanxiangDeploysLunaAndClearsWanxiangReceipt`
- `testCS10_RetainedWanxiangDeploysAfterActiveIceUninstall`
- `testCS10_RetainedIceDeploysAfterActiveWanxiangUninstall`

Focused result: `Test-Universe Keyboard-2026.09.08_15-14-29-+0800.xcresult`
under `/private/tmp/uk-scheme-cs09-cs10-r3-derived/Logs/Test/` — **TEST
SUCCEEDED** (4 focused tests), on the available iOS 26.5 iPhone 17 Pro
Simulator UUID `36BAABED-6846-4F9A-A672-6884B54CF50E`.

Full App + Keyboard result:
`Test-Universe Keyboard-2026.09.08_15-05-36-+0800.xcresult` under
`/private/tmp/uk-scheme-cs09-cs10-full-derived/Logs/Test/` — **TEST
SUCCEEDED**: 336 `UniverseKeyboardTests` (4 skipped) and 11 `KeyboardTests`,
zero failures.

## Evidence boundary

These are `SchemaManager` tests with a controlled deployment service and a
stub installer. They prove the selection, receipt, staging/commit gate, and
runtime-smoke request contract. They do not prove production installer file
inventory for this slice, real RIME candidate input, physical-device behavior,
or pinned-archive provenance. Existing P4 and cross-scheme installer evidence
remains the separate proof for those resource-ownership boundaries.

## Non-claims

No CSF-PAIR-01/02 closure; no Recovery persistence; no Device-attested or
Product Gate evidence; no ADR 0034 Accept; and no undraft/merge, TestFlight,
or App Release. This candidate is not yet independently reviewed or pushed.
