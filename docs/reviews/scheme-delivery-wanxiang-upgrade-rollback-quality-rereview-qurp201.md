# Wanxiang upgrade-rollback Quality delta — Q-UR-P2-01 only

## Review identity

| Field | Value |
|---|---|
| Reviewer | Independent Quality Reviewer（本 delta；**只读**确认关闭；未再改生产） |
| Date / timezone | `2026-09-08 Asia/Shanghai` |
| Freeze SHA | `d1c88e3c0646d110e7275557a0842a8ab76bb48b` — includes remediation + original upgrade-rollback engineering |
| Parent Quality | [`scheme-delivery-wanxiang-upgrade-rollback-quality-2026-09-08.md`](scheme-delivery-wanxiang-upgrade-rollback-quality-2026-09-08.md) — **Pass with conditions** |
| Independence | 未为 chase Pass 改写生产。未 Accept ADR 0034；未 Product Gate；未 merge/undraft/push/TestFlight。唯一写入：本 delta + 父审查指针。 |
| Scope | **仅** Quality residual **Q-UR-P2-01**（manager-level deploy-failure injection for Wanxiang upgrade-rollback）。 |

---

## Delta Verdict（Q-UR-P2-01 only）

**Closed**

Finding residual note：**P2: 0**（对本 residual）。父审查整体仍为 **Pass with conditions**（out-of-scope non-claims unchanged）。本 delta **不**把 Assignment 升为 Reviewed/Closed，**不**宣称 Product Gate。

---

## Q-UR-P2-01 meaning (closed)

Production `SchemaManager+Download` already restored via `restoreAfterFailedUpgradeIfNeeded` after deploy failure on the upgrade path, but that exit was not test-pinned at **manager** level (installer coexistence covered copy/restore only).

Required pin:

1. Prior Wanxiang generation / installed state exists
2. Upgrade proceeds far enough to create checkpoint and mutate/install
3. **`deployRimeConfig` fails** (inject)
4. Assert: prior generation restored **or** checkpoint retained; **prior scheme selection restored**; **no new-version receipt** (`persistVerifiedInstallation` not applied / version keys unchanged)

---

## Checks performed

1. Production seam `deployInstalledUpgradeOrRestoreOnFailure` in `SchemaManager+Download.swift`:
   - `activateSchema` → `deployRimeConfig`
   - on failure → real `restoreAfterFailedUpgradeIfNeeded` (restore checkpoint and/or retain; restore prior selection)
   - **never** calls `persistVerifiedInstallation`
   - `fetchAndDownload` uses this seam on the deploying phase (receipt remains on the success path after `true`)
2. Test `testWanxiangUpgradeRestoresPriorSelectionAndSkipsReceiptWhenDeployFails` in `SchemaManagerTests`:
   - Settings seed prior `wanxiang_version` / checksum / staged / source + `luna_pinyin` active
   - Stub installer returns checkpoint; `installSchemaFiles` marks mutation
   - `StubDeploymentService(succeeded: false)` — same deploy-fail injection style as `testActiveUninstallKeepsFilesAndRestoresSchemaWhenLunaDeployFails`
   - Asserts: `didRestoreUpgradeCheckpoint`, not `didCommitUpgradeCheckpoint`, selection back to `luna_pinyin`, receipt keys unchanged
3. Seam honesty: full download/unzip/staged-SHA orchestration under catalog stubs is too heavy; the shared post-install deploy exit is the faithful manager seam. Documented in parent Quality.
4. Evidence log `/private/tmp/uk-wanxiang-upgrade-qurp201-test.log`: manager test **passed** with the four installer upgrade tests (**TEST SUCCEEDED**, 5/5) on KOS iOS 26.5 simulator.

结论：Q-UR-P2-01 所要求的 manager-level deploy-failure pin 已充足，**关闭该 Quality residual**。

---

## Evidence (pointers)

- Freeze / remediation: `d1c88e3c0646d110e7275557a0842a8ab76bb48b`
- Test: `UniverseKeyboardTests/SchemaManagerTests.swift` → `testWanxiangUpgradeRestoresPriorSelectionAndSkipsReceiptWhenDeployFails`
- Production: `Universe Keyboard/Services/SchemaManager+Download.swift` → `deployInstalledUpgradeOrRestoreOnFailure` / `restoreAfterFailedUpgradeIfNeeded` / success-only `persistVerifiedInstallation`
- Log: `/private/tmp/uk-wanxiang-upgrade-qurp201-test.log`
- Parent finding text: 父审查 `### Q-UR-P2-01`

---

## Explicit non-claims

- 不改写父审查整体 Verdict 为无条件 Pass / Fail beyond “P2: 0 open for Q-UR-P2-01”
- 不 Accept ADR 0034；不宣称 Product Gate / Device-attested / Assignment Closed
- 不授权 merge、undraft PR #100、TestFlight / App Release；**no push**
- 不闭合完整 Wanxiang P4、crash/restart checkpoint discovery、真机升级失败
- 未在本 delta 会话修改生产 Swift
