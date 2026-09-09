# SCHEME-DELIVERY-SOURCE-STATE-001 — P4 Quality delta（Q-P2-01 only）

## Review identity

| Field | Value |
|---|---|
| Reviewer | Independent Quality Reviewer（本 delta 会话；**未**撰写 remediation commit `0315908`） |
| Date / timezone | `2026-09-07 Asia/Shanghai` |
| Freeze SHA | `0315908ed4ebc0f9b947e0f922db9fd4d9add7dd` — `test: inject mid-stage uninstall move failure for Q-P2-01` |
| Parent Quality | [`scheme-delivery-source-state-001-p4-quality-review.md`](scheme-delivery-source-state-001-p4-quality-review.md) — **Pass with conditions**（冻结 `18f0d07`；sole P2 = Q-P2-01） |
| Independence | 生产 Swift **只读**。未实现更多测试。未 Accept ADR 0034；未宣称 Product Gate；未 merge / undraft PR #100；未整体改写原 P4 Quality Verdict。唯一写入：本 delta 文件 + 父审查指针 / finding-count 注记 + Assignment residuals 轻量措辞。 |
| Scope | **仅** Quality residual **Q-P2-01**（生产 installer stage 中途 `moveItem` 故障注入）。不重开 P3；不闭合 Wanxiang / ADR / Product Gate。 |

---

## Delta Verdict（Q-P2-01 only）

**Closed**

Finding residual note：**P2: 0**（对本 residual）。原 P4 审查整体仍为 **Pass with conditions**（P3 与其它开放手递不变）；本 delta **不**把 Assignment 升为 Reviewed/Closed，**不**宣称 Product Gate。

---

## Checks performed

1. `git show 0315908`：变更文件仅为 `UniverseKeyboardTests/SchemeResourcePreparationCoexistenceTests.swift` + Assignment / 父 Quality 文档注记。**无**生产 `SchemaArchiveInstaller.swift`（或其它生产 Swift）diff。既有生产 seam `SharedContainerSchemaArchiveInstaller(appGroupID:fileManager:containerURL:)` 默认 `fileManager: .default` 路径不变；测试仅注入 test-only `FileManager` 子类。
2. 阅读 `testIceUninstallStagingMidMoveFailureRestoresOwnedFiles` 与 `MoveItemFailureFileManager`：
   - `failOnMoveNumber: 2` → 在生产 `stageSchemaUninstall` 路径上对 **非首次** `moveItem` 注入一次失败；
   - 期望抛出 `DownloadError.postProcessingFailed`（与生产 catch→rollback→rethrow 合同一致）；
   - 断言 owned 文件原字节恢复（schema / preset / opencc / lua）；
   - 断言 shared 无残留 live `.schema-uninstall-*` 污染；
   - 注入后委托 `super.moveItem`，使生产 `rollbackSchemaUninstall` 可继续 move 回活树。
3. 对照生产 `stageSchemaUninstall`：逐项 `moveItem`；失败时对已记录 `movedRelativePaths` 调用 `rollbackSchemaUninstall` 再抛 `postProcessingFailed`。测试走真实生产方法，非 manager Stub。

结论：Q-P2-01 所要求的「中途故障注入钉死 fail-closed」证据已充足，**关闭该 Quality residual**。

---

## Evidence (pointers)

- Remediation: `0315908ed4ebc0f9b947e0f922db9fd4d9add7dd`
- Test: `UniverseKeyboardTests/SchemeResourcePreparationCoexistenceTests.swift` → `testIceUninstallStagingMidMoveFailureRestoresOwnedFiles` + `MoveItemFailureFileManager`
- Production (unchanged in remediation): `Universe Keyboard/Services/SchemaArchiveInstaller.swift` → `stageSchemaUninstall` / `rollbackSchemaUninstall`；`init(..., fileManager: FileManager = .default, ...)`
- Parent finding text: 父审查 `### Q-P2-01`（含 Executor remediation 注；本 delta 独立确认 Closed）

---

## Explicit non-claims

- 不改写原 P4 Quality 整体 Verdict 为无条件 Pass / Fail
- 不 Accept ADR 0034；不宣称 Product Gate / Device-attested / Assignment Closed
- 不授权 merge、undraft PR #100、TestFlight / App Release
- 不闭合 Wanxiang P4、Ice Lua `dofile`、真机失败回滚、P3 窗口（崩溃窗口 / restore redeploy / 未独立 xcodebuild / 真机边界）
- 未独立重跑 xcodebuild；采信测试源码审查 + 既有分支 CI 叙事
- 未修改生产 Swift/ObjC；未弱化既有断言
