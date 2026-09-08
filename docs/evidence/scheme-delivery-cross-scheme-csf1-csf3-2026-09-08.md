# Evidence: Cross-scheme CS-F1 / CS-F3 (local)

Date: 2026-09-08 Asia/Shanghai
Checkout: `/private/tmp/uk-scheme-delivery-fix` on `codex/scheme-delivery-fix`
Base tip before slice: `fde42c1`
PR: [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) remains **draft**
Evidence grade: **Executor-recorded**

Independent review: [Pass with conditions](../reviews/scheme-delivery-cross-scheme-csf1-csf3-2026-09-08.md).

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

Focused result: `Test-Universe Keyboard-2026.09.08_14-14-43-+0800.xcresult`
under `/private/tmp/uk-scheme-csf1-csf3-r2-derived/Logs/Test/` — **TEST
SUCCEEDED** (2 focused tests), on the available iOS 26.5 iPhone 17 Pro
Simulator UUID `36BAABED-6846-4F9A-A672-6884B54CF50E`.

Full App + Keyboard result:
`Test-Universe Keyboard-2026.09.08_14-15-38-+0800.xcresult` under
`/private/tmp/uk-scheme-csf1-csf3-r2-full-derived/Logs/Test/` — **TEST
SUCCEEDED**: 332 `UniverseKeyboardTests` (4 skipped) and 11 `KeyboardTests`,
zero failures.

## Evidence boundary

CS-F1 uses the production `SchemaManager` control flow with a test-only archive
installer seam that supplies the T9 fixture and deployment directories, plus a
controlled archive verifier and deployment result. It proves receipt, selection,
peer-setting, deployment-request, and temporary-archive behavior; it is not a
real-installer resource-tree proof. CS-F3 uses the production installer and a
test-only FileManager failure seam to prove resource rollback. Its
`CrossSchemeSelectionTracker` is a harness assertion, not production selection:
the existing manager-level staging-failure test covers selection retention, but
this slice does not combine that manager path with the real-installer mid-move
failure. Neither test is a physical-device input or real pinned-archive
provenance proof.

## Non-claims

No symmetric Wanxiang CS-F1/CS-F3 injection; no combined production-manager
selection assertion plus real-installer CS-F3 move-failure proof; no CS-09/10
retained-scheme deployment/input proof; no Recovery persistence; no
Device-attested or Product Gate evidence; no ADR 0034 Accept; and no
undraft/merge, TestFlight, or App Release. Push to the existing draft branch
was later Human-authorized and does not change these non-claims.
