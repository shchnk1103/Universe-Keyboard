# Architecture Review: TYPO-CORRECTION-002 test-contract/environment remediation

## Verdict

**Pass with conditions** — 仅限 test-only fixture contract 与 App + Keyboard Debug 证据边界。

本复核由独立 Architecture reviewer 在不改文件、不重跑测试、不构建、不安装的条件下完成，绑定：

- Worktree：`/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001`
- HEAD：`d0df9a6342d8209b5aa7f9826541d0b430b9da04`
- Fixture SHA-256：`788d6fd0fc814a034a61873cda6ba67432e21042f7953c8849212f350e8066f9`
- Assignment：[`test-contract/environment remediation`](../assignments/typo-correction-002-recall-remediation-test-contract-environment-001.md)
- Evidence：[`test-contract/environment evidence`](../evidence/typo-correction-002-recall-remediation-test-contract-environment-001.md)

## Findings

1. `StoreDeploymentService` 只在成功 fixture 路径补齐现有 `RimeRuntimeProvenanceReceipt` 所需的非空 `librimeVersion` 与 `runtimeSmokePassed=true`；失败和取消路径仍返回 `nil`，没有放宽生产 fail-closed 语义。
2. `SchemaManager`/部署逻辑、RIME bridge、checked-in entitlements 与 signing 配置没有被本次 test-only 修复改变。日志中的 107 条 `client is not entitled` 保留为 `CODE_SIGNING_ALLOWED=NO` 测试环境 residual，不支持修改生产 entitlement。
3. 计数口径需要在 publication-preflight 前固定：XcodeBuildMCP 外层记录过 `389 discovered`，但权威 xcresult 为 `totalTestCount=388`、`379 passed`、`9 skipped`、`0 failed`；原始日志为 `UniverseKeyboardTests=377` 与 `KeyboardTests=11`，同样合计 388。最终证据应以 388 为执行总数，并明确 389 仅是未被工件复核的外层 discovered 摘要。

## Residuals

- App Group entitlement warning 仍未关闭；本复核不授权修改签名或 entitlement。
- 工作树还有其他属于 parent/preflight 的未提交改动；本 verdict 只覆盖指定 test fixture 与生产边界。
- 本复核未证明真实 RIME、设备运行、性能、180 ms、QA-001、INT-003 或任何 Product/Quality/Release Gate。

## Handoff

可以进入下一阶段的 Authorization 申请，但有条件：先在新的 bounded docs-only reconciliation / publication-preflight Authorization 中绑定最终 snapshot manifest，并把 App + Keyboard 的执行总数口径固定为 388；随后才可重跑完整 CI 等价门禁。此 verdict 不授权测试重跑、commit、push、PR、merge、TestFlight 或 Release。
