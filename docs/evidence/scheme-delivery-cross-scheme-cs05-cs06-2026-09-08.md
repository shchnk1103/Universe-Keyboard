# Evidence: Cross-scheme CS-05 / CS-06 (local)

Date: 2026-09-08 Asia/Shanghai
Checkout: `/private/tmp/uk-scheme-delivery-fix` on `codex/scheme-delivery-fix`
Base tip before slice: `1895876`
PR: [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) remains **draft**
Evidence grade: **Executor-recorded**

## Scope

- **CS-05:** with Wanxiang active, uninstall inactive Ice; retain Wanxiang and
  do not deploy Luna.
- **CS-06:** with Ice active, uninstall inactive Wanxiang; retain Ice and do
  not deploy Luna.

The existing `SchemaManager.performSchemaUninstall` already branches on whether
the target is active. This slice adds the dual-scheme proof that the inactive
branch preserves the active peer selection, clears only the target receipt,
and leaves a later deploy request pending without invoking the Luna fallback.

The manager tests exercise that branch with a Stub installer. Separate tests
use `SharedContainerSchemaArchiveInstaller` with real catalog plans to prove
target ownership removal and peer preservation. This is not a single complete
`SchemaManager` plus production-installer end-to-end uninstall proof.

When a pinned extraction directory is unavailable, the resource harness uses
a minimal synthetic fixture. The tests therefore prove removal and retention
mechanics, not full pinned-archive provenance or every upstream resource path.

## Tests

`SchemaManagerTests`:

- `testCS05_UninstallInactiveIceKeepsWanxiangSelectionWithoutLunaDeploy`
- `testCS06_UninstallInactiveWanxiangKeepsIceSelectionWithoutLunaDeploy`

`SchemeResourcePreparationCoexistenceTests`:

- `testCS05_UninstallInactiveIceRetainsWanxiangPeerInventory`
- `testCS06_UninstallInactiveWanxiangRetainsIcePeerInventory`

Focused result: `Test-Universe Keyboard-2026.09.08_13-17-14-+0800.xcresult`
under `/private/tmp/uk-scheme-cs05-cs06-derived/Logs/Test/` — **TEST SUCCEEDED**
(4 focused tests).

Full App + Keyboard result:
`Test-Universe Keyboard-2026.09.08_13-18-46-+0800.xcresult` under
`/private/tmp/uk-scheme-cs05-cs06-full-derived/Logs/Test/` — **TEST SUCCEEDED**.

## Independent review

Independent Quality / Architecture delta review: **Pass with conditions**.
No new P0/P1 production blocker was found in `7d68633`. The reviewer did not
repeat the executor's test gates. This remains a local candidate and keeps the
limitations above as open evidence boundaries.

## Non-claims

No active-uninstall peer fallback (**CS-07/08**), no Recovery persistence, no
cross-scheme failure-overlay closure, no device-attested input proof, no ADR
0034 Accept, no push, no undraft/merge, and no TestFlight or App Release.
