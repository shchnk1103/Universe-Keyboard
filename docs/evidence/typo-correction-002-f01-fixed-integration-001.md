# PR139 / F-01 固定基线整合与一次完整验证

日期：2026-10-11。父 TYPO-CORRECTION-002 保持 Active。子整合/验证 Completed，独立 AUTH 已消费并耗尽成功；未更新、解除 draft 或合并 PR139。

## 精确身份与整合

固定 main `a44f850d638204aa5c992ac13fb71f5f5424734c`；原 PR139 head `e20e7c8a3a48822e2e712d36453e2cf574088e87`，原 base `9eb83158e49218c1e8f75dbe7dd9e0390db81409`。仅五个 Swift 路径。两个生产文件和两个测试文件与原 PR139 字节相同；唯一冲突在 RimeSettingsStoreTests 部署替身，加入 librimeVersion 并保留 main 的 runtimeSmokePassed。主 App 仍拥有部署，不恢复 RimeRuntimeProvenance。

[候选manifest](typo-correction-002-f01-fixed-integration-001-candidate.json)、[等价性](typo-correction-002-f01-fixed-integration-001-equivalence.json)、[精确命令](typo-correction-002-f01-fixed-integration-001-binding-original.json)、[方案](../plans/typo-correction-002-f01-fixed-integration-001.md)。源仍只在隔离 worktree 修改，未commit/push。

## 真实验证

Run `TC2-CI-20261011-F01-FIXEDA44-001`。正式 Xcode.app；Human当前确认独占的 iPhone18Pro/iOS27.0/405D994F。独立产物 `/private/tmp/uk-f01ci-a44-001`；必要缓存、私有fixture及唯一Keychain项操作绑定独立AUTH。每项一次、首失败停止；本轮全成功，无产品测试重跑。不随 main 前进自动 retry/rebase。

| 检查 | 实际结果 |
|---|---|
| Swift strict lint | 五文件通过 |
| 轻量 CI | Python13项、final matrix、KOS trigger通过 |
| Core | 1207通过、0失败 |
| RimeBridge | 112总数=92通过+20条件跳过、0失败 |
| App | 417总数=407通过+10条件跳过、0失败 |
| Keyboard | 44通过、0失败 |
| 默认 Extension | 6通过、0失败 |
| 签名 Keychain | 唯一指定用例1通过 |
| Release | build succeeded |

F01两个RimeBridge用例及四个SchemaManager拒绝用例实际通过。[精确通过行](typo-correction-002-f01-fixed-integration-001-focused-pass-lines.txt)。跳过不算通过；默认Keychain skip与签名阶段通过单独记录，不重复累计。未重跑无变更的opt-in52或P2采集。五源哈希与git状态前后匹配。此为executor-recorded CI，非独立review。

[执行回执](typo-correction-002-f01-fixed-integration-001-execution-receipt.json)、[计数](typo-correction-002-f01-fixed-integration-001-result-accounting.json)、[归档清单](typo-correction-002-f01-fixed-integration-001-archive-manifest.json)。完整日志/xcresult留在本轮私有目录，小型回执/摘要进入仓库；不删除唯一原始证据。

## 工具与整合经验

1. 成功身份与成功冒烟是两条证据，替身应同时表达，不删除已有字段解决冲突。
2. worktree创建引用merge对象前先fetch；返回最终路径后才使用。
3. AUTH记录脚本编码失败后，依赖补丁误先执行，是本轮流程缺口。Human任务授权已有，独立AUTH未成功落盘；按实际时间补齐并暂停后续动作，不倒填、不冒称事前消费。后续记录步骤单独执行，核对退出码及文件内容后才启动依赖mutation。使用明确UTF-8或ASCII JSON。
4. 正在执行的receipt可能无log字段，按可选字段读取。计数解析也必须兼容`1 test`与`N tests`；本轮首次归档读数因单数形式断言失败，仅修正解析并重新归档，0产品测试重跑。
5. 保存源hash、命令及状态可将后续独立复核限于此次差异和CI适用性，不重开已接受旧残项。

## 剩余边界

PR208已合并`a44f850`，行政完成属于PR207唯一M-02，无递归同步。PR139仍为旧draft/open候选；下一[一次限定独立增量复核](../plans/typo-correction-002-f01-fixed-integration-001-review-proposal.md)，然后另授保留ancestry的正常发布，不默认force-push。

源码发布时补CHANGELOG及部署守卫事实说明；无新架构选择，不新增或Accept ADR，PROJECT_CONTEXT不放流水账。父Gate/Close/Release另授；CPU/UI/内存未验证残项按已批准范围保留，不重新采集。
