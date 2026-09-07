# SCHEME-DELIVERY-SOURCE-STATE-001 — P4 Independent Quality Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | `quality_review` / 独立 Quality Reviewer（本审查会话；非 `e213a25` / `a01dbd3` 作者） |
| Date / timezone | `2026-09-07 Asia/Shanghai` |
| Frozen commit | `18f0d07b14f46c35ec95253e46051c2caa49024a` (`codex/scheme-delivery-fix` tip = `origin/codex/scheme-delivery-fix`) |
| Engineering subjects | `e213a25` — fail-closed active scheme uninstall（P4）；`a01dbd3` — Ice recovery transaction / unreadable-receipt fail-closed（prior Quality residual）；CI fixes `eed453d` / `afa0c0e`；Human-attested P4 device record `18f0d07` |
| Assignment / plan / ADR | [`SCHEME-DELIVERY-SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md) · [ownership plan §P4](../plans/scheme-resource-ownership-and-coexistence-plan.md) · [ADR 0034 Proposed](../architecture/decisions/0034-multi-scheme-resource-ownership.md) |
| Objects | `SchemaManager+Installation.swift` · `SchemaArchiveInstaller.swift` · `SchemaManager.swift` lease · `SchemaManager+Deployment.swift` · `UniverseKeyboardTests/SchemaManagerTests.swift` · `SchemeResourcePreparationCoexistenceTests.swift` · `RimeBuiltinResourceInstaller.swift` + `RimeBuiltinResourceInstallerTests.swift` · [`p4-device`](../evidence/scheme-delivery-source-state-001-p4-device-2026-09-07.md) · prior review [`scheme-delivery-source-state-001.md`](scheme-delivery-source-state-001.md) |
| Independence | 生产 Swift/ObjC **只读**。未实现、未“修”代码以求 Pass。未 Accept ADR 0034；未宣称 Product Gate；未 merge / undraft PR #100；未弱化测试。唯一写入：本审查文件 + Assignment / ACTIVE_WORK / reviews 索引联动。 |
| Scope | P4 活跃卸载 fail-closed 工程切片；以及仍开放的 prior P2/P3 Quality「不可读 receipt」delta 缺口。不是 Architecture 重写，不是 Wanxiang P4 闭合，不是 merge / TestFlight。 |

**HEAD 核对：** `git rev-parse HEAD` = `18f0d07b14f46c35ec95253e46051c2caa49024a`；与 `origin/codex/scheme-delivery-fix` 一致。`e213a25` / `a01dbd3` Author = `shchnk <761962425@qq.com>`，与本审查会话分离。

---

## Verdict

**Pass with conditions**

P4 活跃卸载在代码与单元/共置测试层面满足 Human 冻结合同：活跃目标在 **commit lease 内** 先 `setActiveSchemaWithoutDeployment("luna_pinyin")` + `await deployRimeConfig(leaseOperationID:)`，**禁止** `switchToSchema` 仅登记延迟部署；Luna 成功后才 `stage → commit`；Luna / staging 失败保留原方案选择与文件，且 restore redeploy 在同一 lease 内 `await` 完成（无 detached Task 与 `defer release` 竞态）。`SharedContainerSchemaArchiveInstaller` 的 stage 失败路径会 rollback 已 move 文件；commit 仅在 stage 成功返回后由 manager 调用。

prior Quality P1（present-but-unreadable receipt 被当成缺省）在冻结 tip 上已有生产代码 + 确定性测试证据，**本审查单独关闭该 residual**（见 §Prior Quality residual）。

无未处置 **P0 / P1**。条件（不把 Verdict 升为 Fail，也不升为无条件 Pass）：

1. 本 Quality **未**独立重跑 xcodebuild / 全量门禁；采信分支记录的 CI green 与测试源码审查。
2. 真机仅为 Human-attested 成功烟雾；失败回滚未真机测；非 Device-attested、非 Product Gate。
3. Wanxiang P4 / 升级、Ice Lua `dofile`、ADR Proposed、merge / TestFlight 等必须保持开放（见 Residuals）。
4. 生产 installer「stage 中途失败」缺显式故障注入测试（Q-P2-01）；不阻断本切片合同，但不得宣称文件系统 fail-closed 已被全矩阵钉死。

Finding counts: **P0: 0 · P1: 0 · P2: 1 · P3: 4**

本 Verdict：

- **不是** Assignment Close；
- **不是** Product Gate Passed / Device-attested；
- **不** Accept ADR 0034；
- **不**授权 merge、undraft PR #100、TestFlight / App Release；
- **不**闭合 Wanxiang P4 升级/卸载或 Ice 动态 Lua 引用。

---

## Answers to review questions

### 1. 活跃卸载是否在 commit lease 下等待 Luna 部署成功后，才 stage/删除？

**是。** 证据：`performSchemaUninstall`（`e213a25`）先 `acquireSchemeDeliveryCommitLease`，`defer release`；若 `originalSchemaID == schemaID`，调用 `setActiveSchemaWithoutDeployment("luna_pinyin")` 后 **`await deployRimeConfig(leaseOperationID: operationID)`**，`guard fallbackSucceeded` 失败则 restore 并 return，**不会**进入 `stageSchemaUninstall`。注释明确禁止 `switchToSchema`（其只登记后续部署）。`testActiveUninstallAwaitsLunaDeployBeforeCommittingFiles`：部署请求 `runtimeSmokeSchemaID == luna_pinyin`，且 `didStageUninstall` / `didCommitUninstall` 为真。

### 2. Luna / staging 失败时是否保留原选择与文件，且 restore redeploy 在同一 lease 内完成？

**是。**

| 失败 | 文件 | 选择 | redeploy |
|---|---|---|---|
| Luna deploy 失败 | 未 stage（`didStageUninstall == false`） | 恢复 `rime_ice` | 同 `operationID` 下第二次 `deployRimeConfig`（测试期望 2 次请求：luna → ice） |
| staging 失败（活跃） | 生产 installer `catch` 内 `rollbackSchemaUninstall` 后抛错；manager 不 commit | 恢复原 schema | 同 lease `await restoreSchemaAfterFailedUninstall` |
| staging 失败（非活跃） | 不 commit；保留 installed 元数据 | 保持 luna | 无 Luna fallback |

`restoreSchemaAfterFailedUninstall` 为 `async`，在 `defer { release… }` 之前 `await deployRimeConfig(leaseOperationID:)`；注释写明禁止 detached Task。测试：`testActiveUninstallKeepsFilesAndRestoresSchemaWhenLunaDeployFails`、`testActiveUninstallRestoresSchemaWhenStagingFailsAfterLunaDeploy`。

### 3. stage→commit→rollback 是否 fail-closed？

**是（代码合同 + 有界测试）。** `stageSchemaUninstall` 逐项 `moveItem` 到 `.schema-uninstall-<UUID>`；任一步失败则对已记录 `movedRelativePaths` 调用 `rollbackSchemaUninstall` 再抛 `postProcessingFailed`。`commitSchemaUninstall` 仅在 manager 取得 staging 成功值之后调用（先 `clearBuildCache`，再删 staging root）。`testIceUninstallStagingRollbackRestoresOwnedFiles` 验证 stage 后显式 rollback 恢复 owned 文件字节。部分 stage 的中途故障注入见 Q-P2-01。

### 4. 测试矩阵是否覆盖活跃成功 / Luna 失败 / staging 失败 / 非活跃路径？CI green 证明什么？

**有且有意义。**

| 用例 | 证明 |
|---|---|
| `testActiveUninstallAwaitsLunaDeployBeforeCommittingFiles` | 活跃成功：先 Luna deploy，再 stage+commit，清元数据 |
| `testActiveUninstallKeepsFilesAndRestoresSchemaWhenLunaDeployFails` | Luna 失败：不 stage；选择/文件保留；restore redeploy |
| `testActiveUninstallRestoresSchemaWhenStagingFailsAfterLunaDeploy` | staging 失败：不 commit；选择/installed 保留；restore |
| `testNonActiveUninstallStillRemovesFilesWithoutLunaFallback` | 非活跃：无 deploy 请求；stage+commit；`rime_needs_deploy` |
| `testNonActiveUninstallKeepsFilesWhenStagingFails` | 非活跃 staging 失败：保留文件与选择 |
| `testIceUninstallStagingRollbackRestoresOwnedFiles` | 真实 shared-container installer rollback 字节 |
| `testIceUninstallStagingMidMoveFailureRestoresOwnedFiles` | **Executor rem.** Q-P2-01：生产 path 第 N 次 `moveItem` 故障注入 + fail-closed 恢复（见 Findings 注） |

**CI green 证明：** 上述自动化与既有门禁在托管 CI 上通过。**不证明：** 真机失败回滚、Device-attested 身份、Wanxiang P4、Product Gate、ADR Accepted。

### 5. Human-attested 真机证据绑定是否正确？

**是。** [`p4-device`](../evidence/scheme-delivery-source-state-001-p4-device-2026-09-07.md) 明确 **Human-attested ONLY**：活跃 Ice 卸载烟雾（先切 Luna、无报错、Luna 可输入、设置显示未安装）；**failure rollback 未测**；无 App/Extension UUID·SHA；**不是** Product Gate / Device-attested / ADR Accepted / merge / TestFlight。本审查接受该分级，不升级。

### 6. Prior P2/P3 Quality（不可读 receipt）是否可关闭？

**本审查结论：Pass（关闭该 residual）。** 详见下一节。此前 delta-review 文本缺失不能再阻挡：冻结 tip 上已有可复核的代码 + 测试证据。

### 7. 必须保持开放的 residuals

- Wanxiang P4 升级/卸载合同未闭合
- Ice Lua `dofile` / `loadfile` 动态引用未闭合
- Device-attested 载荷身份缺失
- ADR 0034 仍为 **Proposed**
- PR #100 merge / undraft、TestFlight、真机 Product Gate 均未授权
- backup / staging 目录 cleanup 仍含 best-effort（`try?`）成分

---

## Prior Quality residual（unreadable receipt）— 单独结论

| Field | Value |
|---|---|
| Prior finding | present-but-unreadable builtin resource receipt 被 `try? Data(contentsOf:)` 当成缺省，可能授权 clean-install 覆盖未知 live bytes（P1 Fail） |
| Remediation commits | `a01dbd3`（仍在冻结 ancestry 中）；后续 tip 未回退该行为 |
| Independent conclusion | **Pass** — 关闭该 residual |

证据：

1. `RimeBuiltinResourceInstaller.install`：`fileExists` 为真时 `try Data(contentsOf:)`；catch 抛 `.fileOperationFailed`，注释禁止当作 clean install。
2. `testUnreadableReceiptObjectFailsBeforeUnknownRuntimeMutation`：将 receipt 路径建成目录（不可读为 Data），断言抛 `.fileOperationFailed`，且未知 `default.yaml` 字节不变。
3. 同批强化：`testKnownPollutionRecoveryRollsBackWhenLaterInstallationFails`、`testOverlayFailureAfterKnownPollutionRecoveryRestoresEntirePriorState`；`RimeIcePinnedArtifactTests` 对适配 schema 拒绝残留 `__include: default:/`。

条件：本审查未重跑 RimeBridgeTests；采信测试源码与分支 CI。不把该 Pass 写成 ADR Accepted 或 Product Gate。

---

## Findings

### Q-P2-01 — 生产 installer 缺少 stage 中途失败故障注入

**Severity: P2**

`SharedContainerSchemaArchiveInstaller.stageSchemaUninstall` 的 `catch` 会 `rollbackSchemaUninstall`，但自动化只覆盖「stage 成功后显式 rollback」与 manager 层 Stub 抛错。没有把「第 N 个 `moveItem` 失败」注入到生产 installer 的测试。代码审查支持 fail-closed，但不得宣称中途失败矩阵已被测试钉死。

**不要求本切片为 Pass 而改生产代码**；后续可加故障注入而不弱化现有断言。

**Executor remediation (2026-09-07 Asia/Shanghai):** addressed by `testIceUninstallStagingMidMoveFailureRestoresOwnedFiles` in `SchemeResourcePreparationCoexistenceTests.swift`. Seam: existing production `SharedContainerSchemaArchiveInstaller(fileManager:)` dependency + test-only `MoveItemFailureFileManager` that fails once on the 2nd `moveItem` into the production `stageSchemaUninstall` path; asserts throw + owned bytes restored + no live `.schema-uninstall-*` pollution. No production fail-closed weakening. Does **not** rewrite this review Verdict — residual closed by engineering evidence pending independent delta Quality if required.

### Q-P3-01 — stage 成功到 commit 之间的崩溃窗口

**Severity: P3**

stage 已把文件移出 live tree 后、commit 删除 staging root 前若进程崩溃，元数据可能仍显示已安装，字节仅在 `.schema-uninstall-*`。属事务窗口残留，类似其他 best-effort cleanup；非本切片 P0/P1。

### Q-P3-02 — restore redeploy 失败被忽略

**Severity: P3**

`restoreSchemaAfterFailedUninstall` 使用 `_ = await deployRimeConfig(...)`。选择与文件按合同保留，但 redeploy 失败时可能留下待部署状态。测试未断言 restore deploy 失败分支。

### Q-P3-03 — Quality 未独立重跑 xcodebuild

**Severity: P3**

按独立性与交接，本审查以代码/测试审查 + 记录的 CI green 为准，不把「全量本地门禁已由 Quality 复跑」写入结论。

### Q-P3-04 — 真机证据边界

**Severity: P3（记录性）**

Human-attested 成功烟雾与工程合同方向一致；失败回滚未测；无 Device-attested 身份。evidence 已正确非声明；此处仅登记为开放手递。

---

## Explicit non-claims

- 未 Accept / 未将 ADR 0034 标为 Accepted
- 未宣称 Product Gate Passed、Device-attested、Assignment Closed
- 未 merge、undraft 或批准 PR #100
- 未授权 TestFlight / App Release
- 未闭合 Wanxiang P4、Ice 动态 Lua、升级合同
- 未将 CI green 或 Human 口头烟雾升级为失败回滚真机证明
- 未修改生产 Swift/ObjC，未弱化测试
