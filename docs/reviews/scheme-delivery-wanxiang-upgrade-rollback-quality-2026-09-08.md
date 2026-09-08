# SCHEME-DELIVERY — Wanxiang upgrade-rollback Independent Quality (2026-09-08)

## Review identity

| Field | Value |
|---|---|
| Reviewer | Independent Quality Reviewer（本会话只读审查；未为 chase Pass 改写生产） |
| Date / timezone | `2026-09-08 Asia/Shanghai` |
| Freeze SHA | `d1c88e3c0646d110e7275557a0842a8ab76bb48b` — `feat: Wanxiang upgrade checkpoint + fail-closed restore` |
| Contract | [`scheme-delivery-wanxiang-upgrade-rollback-contract-2026-09-08.md`](../plans/scheme-delivery-wanxiang-upgrade-rollback-contract-2026-09-08.md) — **Human Approved** |
| Parent / related | Assignment [`SCHEME-DELIVERY-SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md)；matrix [`scheme-delivery-p4-remaining-matrix-2026-09-08.md`](../plans/scheme-delivery-p4-remaining-matrix-2026-09-08.md)；P4 Quality 先例 [`scheme-delivery-source-state-001-p4-quality-review.md`](scheme-delivery-source-state-001-p4-quality-review.md) |
| Independence | 生产 / 测试 Swift **只读**于本 Quality 写入。未 Accept ADR 0034；未宣称 Product Gate / Device-attested；未 undraft/merge PR #100；未 push；未 TestFlight。 |
| Scope | Wanxiang upgrade-rollback **最小切片** only（checkpoint + fail-closed restore + receipt gating + focused tests）。不闭合完整 Wanxiang P4。 |

---

## Verdict

**Pass with conditions**

Finding residual note：**P2: 0 open** after delta [`scheme-delivery-wanxiang-upgrade-rollback-quality-rereview-qurp201.md`](scheme-delivery-wanxiang-upgrade-rollback-quality-rereview-qurp201.md) closes **Q-UR-P2-01** (manager-level deploy-failure injection). Open items below are **non-claims / out-of-scope**, not blocking P2 findings for this slice.

---

## What was reviewed (freeze `d1c88e3`)

### Production

1. `SchemaArchiveInstaller.swift`
   - `SchemaUpgradeCheckpoint` / `SchemaUpgradeRecoveryError.upgradeRollbackIncomplete` (distinct from uninstall staging types).
   - `createUpgradeCheckpoint` — copy prior plan-owned (+ exact-hash Wanxiang Lua) paths aside; `nil` on first install.
   - `restoreUpgradeCheckpoint` — restore bytes; on any failure retain checkpoint and throw `upgradeRollbackIncomplete`.
   - `commitUpgradeCheckpoint` — delete checkpoint after successful receipt path.
2. `SchemaManager+Download.swift`
   - Before live replace: `createUpgradeCheckpoint` then `installSchemaFiles`.
   - Deploy path uses shared seam `deployInstalledUpgradeOrRestoreOnFailure` (activate → `deployRimeConfig`; on failure → `restoreAfterFailedUpgradeIfNeeded`).
   - Success-only: `persistVerifiedInstallation` then `commitUpgradeCheckpoint`.
   - Catch paths (cancel / error): `restoreAfterFailedUpgradeIfNeeded`; if checkpoint retained → user-facing upgrade recovery copy.
3. `SchemaManagerTypes.swift` — user-facing strings for upgrade / uninstall recovery errors.

### Tests

| Test | Layer | Intent |
|---|---|---|
| `testWanxiangUpgradeMidCopyFailureRestoresPriorGeneration` | Installer | Mid-copy inject; prior generation restore **or** retained checkpoint |
| `testWanxiangUpgradeRestoreFailureRetainsCheckpoint` | Installer | Restore failure retains checkpoint |
| `testWanxiangFirstInstallCreatesNoUpgradeCheckpoint` | Installer | First install → no checkpoint |
| `testWanxiangUpgradeFailurePreservesUnknownUserPath` | Installer | Unknown/user path not checkpointed / preserved |
| `testWanxiangUpgradeRestoresPriorSelectionAndSkipsReceiptWhenDeployFails` | Manager (Q-UR-P2-01) | Deploy-fail inject; restore + prior selection; version/receipt keys unchanged |

### Evidence run (this freeze)

- Log: `/private/tmp/uk-wanxiang-upgrade-qurp201-test.log`
- Destination: iOS Simulator `KOS v070 Gate iPhone 17 Pro` (id `36BAABED-…`, OS 26.5)
- Result: **5 tests, 0 failures** — `** TEST SUCCEEDED **`
- Note: bare `iPhone 17 Pro` (OS 26.0) hit an unrelated malloc abort inside bundled-resource staging for coexistence tests; re-run on the KOS 26.5 sim is the recorded gate for this slice.

### Docs in freeze

- Human Approved contract (new).
- Assignment / matrix progress pointers updated (no Product Gate / ADR Accept claims).

---

## Checks performed

1. Contract §2 / §3 vs production: checkpoint-before-replace; restore or retain on failure; prior scheme selection restore; no new-version receipt until successful deploy; unknown/user preservation covered by installer tests; types distinct from uninstall.
2. Receipt gating: `persistVerifiedInstallation` only after `deploymentSucceeded`; manager Q-UR-P2-01 asserts `wanxiang_version` / checksum / staged / source keys unchanged on deploy failure.
3. Seam honesty (Q-UR-P2-01): full `fetchAndDownload` zip/staged-SHA orchestration is heavy under stubs; production exposes `deployInstalledUpgradeOrRestoreOnFailure`, which **is** the post-install deploy exit used by `fetchAndDownload`. Test drives that seam after stub checkpoint + `installSchemaFiles`, with `StubDeploymentService(succeeded: false)` — same deploy-fail injection style as `testActiveUninstallKeepsFilesAndRestoresSchemaWhenLunaDeployFails`. Catch-path still calls `restoreAfterFailedUpgradeIfNeeded` (idempotent if seam already restored).
4. Format: dirty Swift under freeze were `swift-format` format + lint `--strict` clean before commit.
5. Integrity: `git cat-file -t d1c88e3` → `commit` (executor verification; no invented SHAs).

---

## Findings

### Q-UR-P2-01 (Closed — see delta)

**Severity (pre-close):** P2 — production catch → `restoreAfterFailedUpgradeIfNeeded` after deploy failure existed, but was not test-pinned at manager level (installer tests covered copy/restore only).

**Remediation in freeze `d1c88e3`:** shared seam + `testWanxiangUpgradeRestoresPriorSelectionAndSkipsReceiptWhenDeployFails`.

**Status:** **Closed** by [`scheme-delivery-wanxiang-upgrade-rollback-quality-rereview-qurp201.md`](scheme-delivery-wanxiang-upgrade-rollback-quality-rereview-qurp201.md).

### Conditions / non-claims (not P2 findings)

- Crash/restart discovery of retained upgrade checkpoints — out of scope (contract §2.6).
- Full Wanxiang P4 / cross-scheme matrix — open.
- ADR 0034 remains **Proposed** — not Accepted.
- No Product Gate / Device-attested upgrade / TestFlight / PR #100 undraft/merge / push from this slice.
- Physical device upgrade-failure run not required for engineering done of this slice.

---

## Explicit non-claims

- Not Assignment Closed / Reviewed lifecycle upgrade beyond Progress wording.
- Not Product Gate Passed; not Device-attested; not App Release.
- Not ADR 0034 Accept.
- Not undraft/merge of PR #100; **no push** performed in this Quality session.
- Not full Wanxiang P4 closure.
