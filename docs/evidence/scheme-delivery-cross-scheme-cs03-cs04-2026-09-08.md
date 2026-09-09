# Evidence: Cross-scheme CS-03 / CS-04 (local)

Date: 2026-09-08 Asia/Shanghai
Checkout: `/private/tmp/uk-scheme-delivery-fix` on `codex/scheme-delivery-fix`
Base tip before slice: `944477a` (synced with origin; CI green at that tip)
PR: [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) remains **draft**
Evidence grade: **Executor-recorded**

## Scope

- **CS-03:** Dual-installed Ice+Wanxiang; repeat Ice with unchanged staged identity → idempotent no-op; peer Wanxiang retained; selection not thrashed.
- **CS-04:** Symmetric Wanxiang same-identity no-op; identity-change path uses existing Wanxiang upgrade-rollback and preserves Ice peer + unknown/user paths.

## Production seam

`SchemaManager.shouldSkipIdenticalReinstall(schemaID:stagedContentSHA256:)` skips replace when installed flag + on-disk schema presence + staged-content receipt match the verified staged digest. Wired in `fetchAndDownload` **before** commit lease / upgrade checkpoint / live replace. `forceRedownload` passes `force: true` and bypasses the gate.

`testFetchAndDownloadSkipsIdenticalIceReceiptBeforeLiveMutation` additionally
drives the production `fetchAndDownload` path through ZIP extraction and
post-processing with controlled dependencies. It proves the matching-receipt
branch does not replace live files, acquire a commit lease, deploy, or change
the active peer selection, and cleans the downloaded temporary archive.

Honest limit: the production-path test uses controlled downloader/verifier
dependencies; real pinned-archive binding remains covered by the dedicated
artifact-verifier tests.

## Tests

`SchemeResourcePreparationCoexistenceTests`:

- `testCS03_RepeatIceSameIdentity_NoOpKeepsWanxiangPeerAndSelection`
- `testCS04_RepeatWanxiangSameIdentity_NoOpKeepsIcePeerAndSelection`
- `testCS04_WanxiangIdentityChange_UpgradeRollbackPreservesIcePeer`

`SchemaManagerTests`:

- `testShouldSkipIdenticalReinstallWhenReceiptMatchesStagedContent`
- `testShouldSkipIdenticalReinstallRequiresInstalledSchemaPresence`
- `testFetchAndDownloadSkipsIdenticalIceReceiptBeforeLiveMutation`

Focused result: `Test-Universe Keyboard-2026.09.08_12-57-15-+0800.xcresult`
under `/private/tmp/uk-scheme-takeover-derived/Logs/Test/` — **TEST SUCCEEDED**
(6 focused tests).

## Independent review

Independent Quality / Architecture delta review: **Pass with conditions**.
The reviewer found no new blocking issue in `d1bf7eb`; this remains a local
candidate only. The review did not repeat the executor's local gates.

The controlled verifier means this test is not real pinned-archive end-to-end
evidence. It exercises the Ice production path only; Wanxiang continues to
have decision and coexistence-harness coverage. The installed-presence check
also intentionally checks the main schema file rather than a full ownership
inventory, so this slice makes no claim about repair after arbitrary external
file deletion.

## Non-claims

No push (unless later Human-authorized). No undraft/merge. No TestFlight / App Release. No ADR 0034 Accept. No Recovery persistence. No CS-05–CS-08 / peer-prefer **B** production work. Not Product Gate / not Device-attested / not Wanxiang P4 close.
