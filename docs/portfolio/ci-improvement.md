# PF-024 — GitHub CI 的后续改进

本文是指针与讨论背景，**不是状态权威**。状态 `Backlog`。它不是设计，不改 `.github/**` 或 `scripts/**`，也不授权实施。耗时来自 Coordinator 于 2026-10-23 用只读 `gh` 收集的抽样，未经 Executor 复现。

## Human 的想法（不是授权）

把 GitHub CI 进一步拆分：能并行的并行，缩短整体时间，也更容易定位问题。没有 Assignment，没有设计。

## 仓库里的现有结构

[`.github/workflows/swift6-quality.yml`](../../.github/workflows/swift6-quality.yml)：`classify_change` 与 `lightweight_checks`（`ubuntu-latest`）之后，六个 macOS job 并行（`macos-26`：`format_swift`、`test_keyboardcore`、`test_rimebridge`、`test_app_keyboard`、`test_rime_sync_keychain`、`build_release`），再由 `final_quality_gate` 汇总。依赖见该文件第 82、105、119、152、183、219 行：六个 heavy job 都只依赖分类和轻量检查。[分类说明](../CI_CHANGE_CLASSIFICATION.md) 第 36–44 行的图把这段标成 full only、parallel。

已有一次拆分：[CI-HEAVY-JOB-SPLIT-001](../assignments/ci-heavy-job-split-001.md) 第 36–37 行，Lifecycle Closed，PR #130 合并为 `52a400e`。“进一步拆分”没有 Assignment。

抽样里最长的 heavy job 是 `test-app-keyboard`（7.6–10.2 分钟）。

## 抽样（未经复现）

最近 100 条 `Swift 6 Quality` run：中位数 0.5 分钟（多数是文档轻量路径）。最长 8 条（分钟）：74.2、36.6、24.8、15.9、14.1、10.7、10.7、10.4。最后一条是 run 39598364040，结论 failure。

## 更正后的发现

早先把 74.2 分钟读成“可能在排队”，这个读法不对。

- run [39579404750](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/39579404750) 是 attempt 2，head `ec7fd04`。`createdAt` 到第一个 job 开始相隔 66.1 分钟，job 本身约 8.1 分钟。[TD-020](../TECH_DEBT.md) 第 340 行写明：第一次尝试失败（`T9AdaptiveRowTests` 间歇失败），同一 head 的第二次尝试通过。74 分钟 = 第一次失败 + 等待重跑 + 第二次尝试。
- run 39431043068（24.8 分钟）同样是 attempt 2。
- run 39279966879（36.6 分钟）是 attempt 1，job 跨度只有 11.2 分钟，原因 UNKNOWN。
- 所以最长的几条里，至少两条的主因是间歇失败后的重跑，不是 job 本身慢，也不是排队。

step 级（完整 run 39606780704，抽样）：`test-app-keyboard` 总 10.2 分钟，其中 “Test app and keyboard contracts” 9.7 分钟；检出、拉取 RIME、准备模拟器各约 0.0–0.1 分钟。`test-rime-sync-keychain` 总 6.3 分钟，测试步骤 5.7 分钟，且该 job 只用 `-only-testing` 跑一个用例，所以这 5.7 分钟里大部分应是 `xcodebuild test` 的构建（未把构建和测试拆开核实）。重复准备合计约 0.3–0.5 分钟，不是主要开销。主要开销是 `xcodebuild` 的构建加测试。

另有三条样本里，macOS runner 有时要等：一条约 5 分钟后六个 job 才开始，一条几乎同时开始，一条像是后面的 job 在等前面的 job 结束。只有三条，不能下结论。公开仓库的并发上限未核实。

## 拆分提速的收益上限（估算，不是拆分后的时长）

墙钟主要由 `test-app-keyboard` 决定。只拆这一个 job 时，墙钟最多降到当时第二长的 job，可节省的分钟数在四条完整 run 上是 2.4、4.0、3.9、1.9。这是可节省的上限，不是拆分之后的总时长，也没有计入每个新 job 都要再编译一次。因此“拆分提速”不是优先项。

## 更值得考虑的候选（都未决定）

1. TD-020 的根因。[TD-020](../TECH_DEBT.md) 第 337 行写根因 UNKNOWN，第 346 行写不要再放宽超时。本文不建议放宽相关超时或断言。
2. 编译一次、多处复用。app / keychain / release 的签名与配置不同，可行性 UNKNOWN。
3. 不拆 job 也能改善定位：拆 step，或产出测试结果摘要。效果 UNKNOWN。
4. 先收集更多 step 耗时与排队样本，再决定要不要改工作流。

## 治理提示

任何 `.github/workflows/**`、`scripts/ci/**` 或分类规则改动都不能用 docs-only 例外，并要在 merge 前取得 hosted run 证据（`AGENTS.md` 第 101–102 行）。本文没有这类授权。

## 待 Human 决定

- 要不要为 TD-020 根因、编译复用或定位摘要单独立项。
- 公开仓库的 macOS 并发上限，需 Human 对照 GitHub 文档核实后再当作约束。
- 是否继续只收集数据，而不改工作流。
