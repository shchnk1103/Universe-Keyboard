# Evidence: Cross-scheme CSF-PAIR-01 / CSF-PAIR-02

Date: 2026-09-08 Asia/Shanghai
Checkout: `/private/tmp/uk-scheme-delivery-fix` on `codex/scheme-delivery-fix`
Base: `8acabd9`; reviewed commits: `1efb886` + `a6771ed`
PR: [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) remains **draft**
Evidence grade: **Executor-recorded; independently reviewed Pass with conditions; GitHub CI green**

Independent review: [Pass with conditions](../reviews/scheme-delivery-cross-scheme-csf-pair-2026-09-08.md).

The reviewed commits were pushed to `codex/scheme-delivery-fix` at `a6771ed`;
GitHub CI completed green. This does not alter the evidence boundaries below.

## Scope and result

- **CSF-PAIR-01:** adds the Wanxiang direction missing from CS-F1. With Ice
  selected and retained, a Wanxiang install whose deployment fails writes no
  Wanxiang receipt, keeps Ice's settings and bytes, retains Ice selection, and
  removes the temporary archive.
- **CSF-PAIR-02:** adds both active-uninstall directions using production
  `SchemaManager` control flow and a real
  `SharedContainerSchemaArchiveInstaller`. A test-only `FileManager` fails
  exactly on the second target-to-staging move. The manager first deploys
  Luna, the real installer rolls back the first move, and the manager restores
  the original selection and deploys it. Both target-owned bytes and the peer
  bytes remain unchanged.

The deploy-directory adapter is test infrastructure only: it supplies the
temporary-root directory pair so the manager can invoke its normal deployment
service while the real installer owns staging and rollback. It does not alter
production code.

## Tests

`SchemaManagerTests`:

- `testCSF1_WanxiangDeployFailureWithIcePeerKeepsPeerAndSkipsWanxiangReceipt`
- `testCSF3_ManagerIceStagingFailureRestoresSelectionAndWanxiangPeerFiles`
- `testCSF3_ManagerWanxiangStagingFailureRestoresSelectionAndIcePeerFiles`

Focused result: `Test-Universe Keyboard-2026.09.08_19-09-55-+0800.xcresult`
under `/private/tmp/uk-scheme-csf-pair-derived/Logs/Test/` — **TEST
SUCCEEDED** (3 tests), using the available iOS 26.5 iPhone 17 Pro Simulator
UUID `36BAABED-6846-4F9A-A672-6884B54CF50E`.

Full App + Keyboard result:
`Test-Universe Keyboard-2026.09.08_19-10-16-+0800.xcresult` under
`/private/tmp/uk-scheme-csf-pair-full-derived/Logs/Test/` — **TEST
SUCCEEDED**: 346 passed, 4 skipped, zero failures.

`xcrun swift-format format` and `xcrun swift-format lint --strict` both passed
for `UniverseKeyboardTests/SchemaManagerTests.swift`.

## Evidence boundary

This slice closes the automated symmetry and combined-manager/real-installer
gaps named as `CSF-PAIR-01/02`. It does not prove the complete pinned resource
inventory, a real RIME runtime input transaction, or App Group/device behavior.
Those remain covered by `CS09-10-01/02` and the Assignment's device/Product
gates. It does not accept ADR 0034, close Wanxiang P4, authorize Recovery,
undraft or merge PR #100, TestFlight, or App Release.
