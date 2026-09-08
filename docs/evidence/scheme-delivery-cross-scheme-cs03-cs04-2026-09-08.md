# Evidence: Cross-scheme CS-03 / CS-04 (local)

Date: 2026-09-08 Asia/Shanghai  
Checkout: `/private/tmp/uk-scheme-delivery-fix` on `codex/scheme-delivery-fix`  
Base tip before slice: `944477a` (synced with origin; CI green at that tip)  
PR: [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) remains **draft**

## Scope

- **CS-03:** Dual-installed Ice+Wanxiang; repeat Ice with unchanged staged identity → idempotent no-op; peer Wanxiang retained; selection not thrashed.
- **CS-04:** Symmetric Wanxiang same-identity no-op; identity-change path uses existing Wanxiang upgrade-rollback and preserves Ice peer + unknown/user paths.

## Production seam

`SchemaManager.shouldSkipIdenticalReinstall(schemaID:stagedContentSHA256:)` skips replace when installed flag + on-disk schema presence + staged-content receipt match the verified staged digest. Wired in `fetchAndDownload` **before** commit lease / upgrade checkpoint / live replace. `forceRedownload` passes `force: true` and bypasses the gate.

Honest limit: coexistence harness asserts the decision + peer inventory without driving a full network download; SchemaManager unit tests cover true/false decision edges.

## Tests

`SchemeResourcePreparationCoexistenceTests`:

- `testCS03_RepeatIceSameIdentity_NoOpKeepsWanxiangPeerAndSelection`
- `testCS04_RepeatWanxiangSameIdentity_NoOpKeepsIcePeerAndSelection`
- `testCS04_WanxiangIdentityChange_UpgradeRollbackPreservesIcePeer`

`SchemaManagerTests`:

- `testShouldSkipIdenticalReinstallWhenReceiptMatchesStagedContent`
- `testShouldSkipIdenticalReinstallRequiresInstalledSchemaPresence`

Log: `/private/tmp/uk-cross-scheme-cs03-cs04-test.log` — **TEST SUCCEEDED** (5 focused tests).

## Non-claims

No push (unless later Human-authorized). No undraft/merge. No TestFlight / App Release. No ADR 0034 Accept. No Recovery persistence. No CS-05–CS-08 / peer-prefer **B** production work. Not Product Gate / not Device-attested / not Wanxiang P4 close.
