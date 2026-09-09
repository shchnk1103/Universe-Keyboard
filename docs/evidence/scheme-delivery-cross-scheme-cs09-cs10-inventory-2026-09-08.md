# Evidence: Cross-scheme CS09-10-01 production installer inventory (local candidate)

Date: 2026-09-08 Asia/Shanghai
Checkout: `/private/tmp/uk-scheme-delivery-fix` on `codex/scheme-delivery-fix`
Base: `5e527b7`
PR: [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) remains **draft**
Evidence grade: **Executor-recorded; independently reviewed Pass with conditions**

Independent review: [Pass with conditions](../reviews/scheme-delivery-cross-scheme-cs09-cs10-inventory-2026-09-08.md).
GitHub CI: **green, Human-reported after push of `6da6267`**.

## Scope

This separately authorized slice closes the CS09-10 review condition that
CS-09/10 did not rerun production installer inventory or retained-peer byte
proof. It adds both directions using the real
`SharedContainerSchemaArchiveInstaller` and the locally available fixed Ice and
Wanxiang extract trees.

- Install the complete admitted Wanxiang tree, then Ice; uninstall Ice and
  require every non-Ice-owned shared runtime file to remain byte-for-byte
  identical.
- Install the complete admitted Ice tree, then Wanxiang; uninstall Wanxiang
  and require every non-Wanxiang-owned shared runtime file to remain
  byte-for-byte identical.
- In each direction, target-owned paths present in the pre-uninstall snapshot
  must be absent afterwards, and a `Rime/user` sentinel must remain unchanged.

The Wanxiang target classification mirrors the production installer: static
plan ownership plus exact-hash `WanxiangLuaOwnership` paths. Therefore a
hash-matched `lua/data/chaifen.txt` is correctly expected to be removed, while
all other snapshot paths are retained.

## Tests

`SchemeResourcePreparationCoexistenceTests`:

- `testCS0910_RealInstallerIceRemovalPreservesCompleteWanxiangInventory`
- `testCS0910_RealInstallerWanxiangRemovalPreservesCompleteIceInventory`

Focused result: `Test-Universe Keyboard-2026.09.08_20-13-02-+0800.xcresult`
under `/private/tmp/uk-scheme-cs0910-inventory-r4-derived/Logs/Test/` — **TEST
SUCCEEDED** (2 tests), on the available iOS 26.5 iPhone 17 Pro Simulator UUID
`36BAABED-6846-4F9A-A672-6884B54CF50E`.

Full App + Keyboard result:
`Test-Universe Keyboard-2026.09.08_20-14-51-+0800.xcresult` under
`/private/tmp/uk-scheme-cs0910-inventory-r2-full-derived/Logs/Test/` — **TEST
SUCCEEDED**: 348 passed, 4 skipped, zero failures.

`xcrun swift-format format` and `xcrun swift-format lint --strict` both passed
for `UniverseKeyboardTests/SchemeResourcePreparationCoexistenceTests.swift`.

## Evidence boundary

This proves production installer file placement and removal against the local
fixed extract trees. It does not reverify archive provenance in this slice,
does not invoke a real RIME deployment or candidate-input transaction, and
does not access an App Group or physical device. `CS09-10-02` remains the
separate device/runtime evidence gate. No ADR acceptance, Product Gate,
undraft/merge, TestFlight, or App Release is implied.
