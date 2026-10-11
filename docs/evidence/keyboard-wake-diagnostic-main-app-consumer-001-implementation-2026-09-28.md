# KEYBOARD-WAKE-DIAGNOSTIC-MAIN-APP-CONSUMER-001 — 实现候选证据

状态：Main App 实现及必需 CI 等价验证已完成；精确候选的 Architecture 与 Quality 独立复审均为 **Pass with conditions**。Human Product Owner 已接受整次查询聚合，child Assignment 按“query-wide completeness 经 continuation 保留”验收；page-local first-rejection discovery 不在本范围。本记录不是 Product Gate、Assignment Close、根因结论或 Release 证据。

## 候选身份

- 采集日期：2026-09-29 Asia/Shanghai。
- 隔离 worktree：`/Users/doubleshy0n/.codex/worktrees/keyboard-wake-diagnostics/Universe Keyboard`。
- 基线 `HEAD`：`9eb83158e49218c1e8f75dbe7dd9e0390db81409`。
- 本 Assignment 两个 Swift 文件的按文件 SHA-256 再求 SHA-256，最终候选摘要为 `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a`。

| 文件 | SHA-256 |
|---|---|
| `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift` | `5b57373506212769d653263fdf00eb7f73ec0985ef8a72cd85b4a6fa7993ab7c` |
| `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift` | `fe1253b5800bab9d7402f02d3d70e2feccbfb36d745ca3faa025e9d41d52b1ff` |

## 实现范围

- `V1DiagnosticsLogSource` 聚合并保留一次查询的 `DiagnosticsJournalPage.completeness`，覆盖严格首屏、`recentPreview` 和 continuation page；失败转为不可用状态时保留此前已观察的不完整信息。
- v1 查询只要不完整，即便没有任何有效事件，也会设置 v1 ownership，阻止旧 `rime_diag_log` 被误当作有效空日志或覆盖当前状态。成功且完整的空 journal 仍允许既有 legacy 只读回退。
- 新增固定、内容无关的不完整提示，并与原有分页/读取预算提示组合；有效 typed events 继续显示。
- formatter 增加 Keyboard Lifecycle、RIME Resume、Text Proxy 三种已接受 payload，只展示有限枚举和可选 `UInt64` 计数，不输出自由文本。
- `CompositeDiagnosticsLogSource` 增加可选 journal-root provider，测试只传临时目录；legacy 使用每个测试新建的 `UserDefaults` suite，不读取真实 App Group。
- 没有修改 KeyboardCore、RimeBridge、Keyboard Extension、schema/Proposal、日志 producer、捕获开关或运行时键盘行为。

## 测试覆盖

- `CompositeDiagnosticsLogSource` 的 complete-empty 可回退、incomplete-empty 禁止回退、mixed valid/rejected 保留有效事件并提示。
- 不完整查询有 501 条有效事件时加载 continuation page，之后仍保留固定不完整提示且不混入 legacy；这验证 reader 在 `beginPage` 冻结的 query-wide completeness 能跨 continuation 保留，不验证拒绝首次在后续页才被发现。
- recent-preview 同时包含被拒记录时，不完整提示与既有预算/partial-window 提示并存。
- lifecycle、RIME resume、text-proxy formatter 字段为有限枚举/计数；自由文本没有进入展示行。
- 最终测试 fixture 修复：v4 事件使用有效的 Keyboard Extension `DEBUG` envelope；incomplete-empty 用真实空 `.jsonl` segment；unknown raw key fixture 使用 schema v4。

## 已执行验证

| 检查 | 结果 | 证据等级 | 边界 |
|---|---|---|---|
| `swift-format lint --strict --configuration .swift-format`（本 Assignment 两个 Swift 文件） | Pass | Executor-recorded | 按最终候选执行；Swift 格式硬门通过。 |
| `git diff --check` | Pass | Executor-recorded | 在本轮 Assignment、evidence、父 Assignment 与 Active Work 状态镜像最终更新后重跑。 |
| Repository Markdown local-link、whitespace、final-newline check（4 个受影响文档） | Pass | Executor-recorded | 使用仓库 `check_markdown_links.py` 的 link resolver 对当前 worktree 文档逐个检查；untracked Assignment/evidence 文件也包含在内。 |
| `swift test --package-path Packages/KeyboardCore` | 1132 passed / 0 failed | Executor-recorded | Swift 6.4 host-side macOS test；KeyboardCore 五文件 aggregate 与 reader 候选一致：`c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`。日志 SHA-256：`e7ad7647f4caa7dfa710969592c1b2fc1f179859bfcfc1908b353c8023f07ac9`。 |
| `RimeBridgeTests` Debug Simulator tests | 81 passed / 20 skipped / 0 failed（xcresult 共 101） | Executor-recorded | Xcode 27.0；iPhone 17 Pro Max / iOS 26.0，UDID `5E2A235C-98EA-45BA-922B-EF99B1B9B87C`。Result bundle：`/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-28T23-53-47-044Z_pid46639_952e8321.xcresult`；日志：`/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-28T23-53-47-043Z_pid46639_73ba1a98.log`。 |
| `Universe Keyboard` Debug App + Keyboard tests | 380 passed / 9 skipped / 0 failed（xcresult 共 389） | Executor-recorded | 同一 Simulator / UDID；包含本 Assignment 的 `DiagnosticsLogSourceTests`。Result bundle：`/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-28T23-54-23-760Z_pid46639_5ebfee05.xcresult`；日志：`/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-28T23-54-23-759Z_pid46639_0c4484e8.log`。 |
| `Universe Keyboard` Release Simulator build | Build succeeded | Executor-recorded | 同一 Simulator / UDID；日志中另有两条 AppIntents metadata warning，没有构建错误。日志：`/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-09-28T23-56-00-348Z_pid46639_6428138c.log`。 |

初次 App Debug test run 暴露了上述三类 fixture 问题；修正仅改变测试文件，没有修改生产源文件。随后按仓库要求顺序重跑完整门禁，表中为最终候选结果。Simulator `xcodebuild` 由三个隔离的非持久化 XcodeBuildMCP profiles 调用，显式使用 UDID `5E2A235C-98EA-45BA-922B-EF99B1B9B87C` 与 Swift 6 / strict-concurrency / warnings-as-errors 参数；各日志保存完整 `build-for-testing`、`test-without-building` 和 Release `build` 命令行。早期 generic iOS compile/typecheck 仅作补充，不替代 Simulator 测试或 Release build。

**构建输入边界：** 日志中的项目路径指向该隔离 worktree；运行时除了此 Assignment 的 Main App 两文件和依赖的 reader 候选，还包含 parent wake-diagnostic / schema work 已有的 Keyboard Extension 与 KeyboardCore 改动。Executor 没有修改这些 sibling-scope 文件。结果绑定当前组合 worktree；Main App 范围结论仅限已核验的候选源文件及其测试，不代表完全隔离的 Main App 构建，也不构成对其他并行改动的独立 Quality 结论；它们继续由各自 Assignment 负责。

## Simulator、UI 状态映射与残差

- 2026-09-29，只有得到 Human 对该 UDID 的独占确认后，测试/构建才使用 `iPhone 17 Pro Max / iOS 26.0`（UDID `5E2A235C-98EA-45BA-922B-EF99B1B9B87C`）；所有目标通过三个独立、非持久化 XcodeBuildMCP profiles 路由。CI-default iPhone 17 Pro（`8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`）、iPhone 17 Pro Max / iOS 27.0（`06C5BC3E-7599-4761-A1A2-71DAEA991474`）及其 profiles 均未操作。最终只读盘点显示获批 iOS 26.0 Simulator 已回到 Shutdown。
- **UI 状态映射（源码检查；没有截图或交互运行证据）：** `DiagnosticsStore.loadLog` / `replaceWithLatestPage` 读取 source text、分页状态与 bounded notice；`DiagnosticsView` 将 `isRefreshing`、`displayedNotice`、分页信息传给 `DiagnosticsLogContentView`。当无行且刷新中显示 loading；无行且不刷新时显示 notice 与 empty state；有行时在事件列表前显示 notice 并保留有效行。涉及文件：`Universe Keyboard/Views/Diagnostics/DiagnosticsStore.swift`、`DiagnosticsView.swift`、`DiagnosticsLogContentView.swift`。
- `DiagnosticsJournalReader.beginPage` 在查询冻结时汇总 query-wide completeness，后续页携带同一 aggregate；真实 reader API 不自然地产生“拒绝记录首次在 continuation page 才发现”的序列。当前测试证明 incomplete 状态经过 continuation 后仍保留。Human Product Owner 已接受此 reader 合同：验收只要求 query-wide completeness 跨 continuation 保留，page-local first-rejection discovery 属于范围外；未添加 fake reader 或修改 Reader 合同。
- **Architecture review — Pass with conditions**，最终摘要 `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a`。Reviewer 重新计算了两文件 SHA 并确认一致；确认生产逻辑、strict reader 边界、隔离测试和 fixture 修复无新架构 blocker。Human Product Owner 接受 query-wide completeness 并修订 Exit Criterion 后，Architecture 确认 `MAC-ARCH-01` 条件已解决；无需 page-local seam 或 Reader 合同变更。原 `MAC-EVID-01` 已按最终候选、门禁结果和状态镜像同步。
- **Quality review — Pass with conditions**，绑定同一最终摘要与上述 Simulator 门禁。Reviewer 独立核对 xcresult、Release 日志和候选文件，确认新增 Main App tests 通过，且 skipped cases 的原因来自环境/fixture/resource 条件；Release log 有两条 AppIntents metadata warning，无构建错误。Quality 已复核跨文档候选与验证状态一致。Human Product Owner 接受 query-wide contract 并同步 Exit Criterion 后，Quality 确认 `MAC-ARCH-01` 语义条件已解除；原 Pass with conditions 结论保持不变。该结论不是 Product Gate、Release 或 parent Assignment Close。
- `MAC-ARCH-01` — Owner：Human Product Owner（Product Lead），Architecture / Quality 咨询；Disposition：`accept`（2026-09-29 Human Product Owner 接受 query-wide completeness；Continuation 验证保留 `beginPage` 聚合状态，page-local first-rejection discovery 不属于此 Assignment）；Pointer：本 Assignment History 中的产品处置与验收措辞，及本节。
- `MAC-EVID-01` — Owner：Executor；Disposition：`fix`（已完成；Architecture 和 Quality 均已复核候选、验证结果和状态镜像一致）；Pointer：本证据文件候选身份、验证表及 [Main App Assignment](../assignments/keyboard-wake-diagnostic-main-app-consumer-001.md)。
- 物理设备证据为 **Not Applicable**：本切片不改 Full Access、Extension 行为或跨 target runtime。
- 不声称安装、人工运行时复现、键盘行为修复、根因已定、v4 producer enabled、Product Gate、Release 或 parent Assignment Close。
