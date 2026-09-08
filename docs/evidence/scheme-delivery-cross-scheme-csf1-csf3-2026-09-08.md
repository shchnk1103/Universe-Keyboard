# Evidence: Cross-scheme CS-F1 / CS-F3 (local)

Date: 2026-09-08 Asia/Shanghai
Checkout: `/private/tmp/uk-scheme-delivery-fix` on `codex/scheme-delivery-fix`
Base tip before slice: `fde42c1`
PR: [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) remains **draft**
Evidence grade: **Executor-recorded**

## Scope

- **CS-F1:** Ice deployment fails after install while Wanxiang is selected and
  installed. The failed Ice operation writes no installed or staged-content
  receipt, restores Wanxiang selection, preserves Wanxiang bytes, and cleans
  the temporary archive.
- **CS-F3:** Ice uninstall staging fails mid-move while Wanxiang is active.
  Production installer rollback restores Ice target files; Wanxiang and an
  unknown/user path remain unchanged.

## Tests

`SchemaManagerTests`:

- `testCSF1_IceDeployFailureWithWanxiangPeerKeepsPeerAndSkipsIceReceipt`

`SchemeResourcePreparationCoexistenceTests`:

- `testCSF3_IceUninstallStagingFailureRetainsWanxiangPeerAndTargetFiles`

Focused result: `Test-Universe Keyboard-2026.09.08_13-55-25-+0800.xcresult`
under `/private/tmp/uk-scheme-csf1-csf3-derived/Logs/Test/` — **TEST SUCCEEDED**
(2 focused tests).

Full App + Keyboard result:
`Test-Universe Keyboard-2026.09.08_13-56-12-+0800.xcresult` under
`/private/tmp/uk-scheme-csf1-csf3-full-derived/Logs/Test/` — **TEST SUCCEEDED**.

## Evidence boundary

CS-F1 uses the production `SchemaManager` path with a real container installer,
a controlled archive verifier, and a controlled deployment result. CS-F3 uses
the production installer and a test-only FileManager failure seam. Neither is a
physical-device input or real pinned-archive provenance proof.

## Non-claims

No symmetric Wanxiang CS-F1/CS-F3 injection, no CS-09/10 retained-scheme
deployment/input proof, no Recovery persistence, no Device-attested or Product
Gate evidence, no ADR 0034 Accept, and no push, undraft/merge, TestFlight, or
App Release.
