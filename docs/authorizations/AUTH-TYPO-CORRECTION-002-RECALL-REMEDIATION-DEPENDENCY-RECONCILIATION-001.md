# AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DEPENDENCY-RECONCILIATION-001

- 状态：consumed
- 建立时间：2026-09-20 Asia/Shanghai
- 消费时间：2026-09-20 Asia/Shanghai
- Assignment：`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`
- Worktree：`/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001`
- Bound base：`origin/main=162b09fd58ba60538a944026b1902efa405c75aa`
- Bound staging tree：`92c5047c5d1a6dd6a751eb5344117f8138c14ef2`
- Trigger Run：`TC2-RECALL-QUALITY-20260920-001`
- Trigger evidence：`docs/evidence/typo-correction-002-recall-remediation-quality-run-2026-09-20-001.md`

## 目的

只读对账 `RimeSettingsStoreTests.swift` 中的 `RimeDeploymentResult` 构造与其 production contract 依赖，确定 canonical recall allowlist 是否遗漏 parent-lane contract，或测试 fixture 是否不应属于本 recall slice。对账必须区分 clean `origin/main`、旧 parent sidecar checkpoint 和当前 staging worktree，不能用旧脏树的可编译状态替代 provenance。

## 允许动作

- 读取并比较 `origin/main=162b09f`、当前 staging worktree 和旧 parent checkpoint `84978748d89d329a7d2c6e89400c1ff556cfd9b5` 的相关 source/test 文件、commit diff 和历史记录；
- 读取 Quality Run 的编译日志与报错位置；
- 静态搜索 `RimeDeploymentResult`、`librimeVersion`、`runtimeSmokePassed` 的声明、初始化器和调用点；
- 生成 dependency classification：recall-owned、parent-contract-owned、test-fixture-only、unrelated；
- 只写入本 Authorization 的 reconciliation evidence，以及在 Assignment/ACTIVE_WORK 中添加镜像链接；
- 提出最小闭包、候选 base 和需要 Product 决定的 scope 分叉。

## 明确禁止

- 不修改 Swift、测试源、Package/Xcode 工程、manifest、schema 或 vendor；
- 不把 `RimeDeploymentService.swift`、parent checkpoint 或整个 `8497874` 自动移植进 staging；
- 不重跑 App/Release，不创建新的产品行为 Run；
- 不消费旧 Authorization，不改旧 evidence 的结论；
- 不 commit、push、PR、merge、TestFlight、Release 或关闭 parent/child Assignment；
- 不替 Product 选择“回退测试 fixture”或“扩展生产 contract”。

## 退出条件

- 报错的声明/初始化器/调用点与 commit provenance 被绑定；
- 给出最小依赖闭包和每个候选范围的 non-claims；
- 若需要代码或 manifest 变化，只提出新的 bounded code-fix/manifest Authorization，不在本授权内实施。

## Consumption receipt

- Evidence：[`dependency reconciliation 001`](../evidence/typo-correction-002-recall-remediation-dependency-reconciliation-2026-09-20-001.md)。
- Result：确认 `RimeSettingsStoreTests.swift` 依赖 parent checkpoint `8497874` 引入的 `RimeDeploymentResult.librimeVersion`，而 clean `origin/main=162b09f` 不含该 contract；recall 三个 KeyboardCore 文件不依赖该 API。
- Recommended frontier：建立新的 bounded code-fix Authorization，优先选择方案 A，保持 pure KeyboardCore scope；方案 B/C 必须另立 parent-scope Product/Architecture/Quality 处理。
- Non-claims：未修改代码、未改 manifest、未重跑、未 commit/push/PR/merge、未关闭任何 Assignment/Gate。
