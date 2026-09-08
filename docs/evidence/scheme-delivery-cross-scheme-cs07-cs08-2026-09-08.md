# Evidence: Cross-scheme CS-07 / CS-08 (local)

Date: 2026-09-08 Asia/Shanghai
Checkout: `/private/tmp/uk-scheme-delivery-fix` on `codex/scheme-delivery-fix`
Base tip before slice: `8dbfe2c`
PR: [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) remains **draft**
Evidence grade: **Executor-recorded**

## Policy

Human superseded the earlier peer-prefer B decision. Active-scheme uninstall
now always follows **Luna-only fallback**: deploy builtin `luna_pinyin` before
staging target removal. The retained downloaded peer is preserved but is never
selected as fallback. This keeps the state machine stable as more downloadable
schemes are introduced.

## Tests

`SchemaManagerTests`:

- `testCS07_ActiveIceUninstallWithWanxiangPeerDeploysLunaBeforeRemovingIce`
- `testCS08_ActiveWanxiangUninstallWithIcePeerDeploysLunaBeforeRemovingWanxiang`
- `testCSF2_ActiveIceUninstallWithWanxiangPeerRestoresIceWhenLunaDeployFails`
- `testCSF2_ActiveWanxiangUninstallWithIcePeerRestoresWanxiangWhenLunaDeployFails`

Focused result: `Test-Universe Keyboard-2026.09.08_13-38-46-+0800.xcresult`
under `/private/tmp/uk-scheme-cs07-cs08-derived/Logs/Test/` — **TEST SUCCEEDED**
(4 focused tests).

Full App + Keyboard result:
`Test-Universe Keyboard-2026.09.08_13-39-52-+0800.xcresult` under
`/private/tmp/uk-scheme-cs07-cs08-full-derived/Logs/Test/` — **TEST SUCCEEDED**.

## Evidence boundary

These manager-level tests use the existing Stub installer to control staging
and assert the transaction order, selection, receipts, peer settings, and
deployment requests. CS-05/06 separately covers real-installer ownership
removal and peer resource preservation. This is not a physical-device input
proof, nor an end-to-end RIME deployment against a real peer resource tree.

## Non-claims

No CS-09/10 retained-scheme deployment/input proof; no CS-F1 or CS-F3 closure;
no Recovery persistence; no Device-attested or Product Gate evidence; no ADR
0034 Accept; no push, undraft/merge, TestFlight, or App Release.
