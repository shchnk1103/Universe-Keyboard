# RELEASE-2026-0801-08 — Q-08-04 最小自动化回归交接

**证据类型：** Executor 实现与验证交接；不包含独立 Quality 结论或 Product Gate。

**日期 / 时区：** `2026-07-21 Asia/Shanghai`

**基线提交：** `c9f2b34bd4b44dc528f39e6120db1af3f23c367e`

**测试实现提交：** `1e73c163411ca92b99c50fb9e3a8e5421e3a635d`

**分支：** `codex/release-2026-0801-kaomoji`（仅本地；未合并、未推送）

## 范围与文件

- [`KaomojiDirectTextRegressionTests.swift`](../../Packages/KeyboardCore/Tests/KeyboardCoreTests/KaomojiDirectTextRegressionTests.swift)
  - 通过真实 `KeyboardController.handle(.insertDirectText)` 验证 `^_^` 精确插入。
  - 活动 composition 场景断言 marked text 清除、composition 状态清空、RIME session reset 一次，以及 `.compositionFinalization` 后接 `.directText` 的提交事件顺序。
- [`test_kaomoji_ui_contract.sh`](../../scripts/test_kaomoji_ui_contract.sh)
  - 直接检查生产源码中的九宫格右侧入口和二级符号页入口是否仍汇合到 `showKaomojiCandidates(_:)`。
  - 检查分类选择状态更新与 reload、条目到 `insertDirectText(_:)` 的绑定，以及“返回”到 `dismissKaomojiPanel(_:)` 和关闭状态的绑定。

本提交没有修改生产源码、输入语义、RIME 生命周期、网络或持久化边界。

## 覆盖矩阵

| Q-08-04 要求 | 自动化覆盖 | 证据边界 |
|---|---|---|
| 九宫格右侧 `^_^` 入口 | UI 源码契约脚本检查按钮标题及 `showKaomojiCandidates(_:)` selector。 | 结构契约，不替代真机点击；运行时观察见 Q-08-02。 |
| 二级符号页 `^_^` 入口 | UI 源码契约脚本检查符号序列、条件分支及共享 selector。 | 结构契约，不替代真机点击；运行时观察见 Q-08-02。 |
| 分类切换 | UI 源码契约脚本检查 `selectedKaomojiCategoryIndex = sender.tag` 与面板 reload。 | 防止 wiring/state 更新被移除；不声称验证 UIKit 动画或视觉状态。 |
| 精确文本插入 | KeyboardCore 行为测试断言最终文本为精确 `^_^`、提交来源为 `.directText`；脚本检查颜表情按钮继续绑定统一 direct-text action。 | 使用合成文本；不读取真实输入。 |
| 返回原键盘 | UI 源码契约脚本检查“返回” selector 与 `isKaomojiPanelVisible = false`。 | 防止返回 wiring/关闭状态被移除；运行时恢复键盘见 Q-08-02。 |
| 现有 composition 最终提交路径 | KeyboardCore 行为测试从活动 `ni` marked composition 插入 `^_^`，断言最终 `ni^_^`、marked text 清空、session reset 一次，并按 `.compositionFinalization`、`.directText` 顺序各发出一次事件。 | 只验证既有 Core 语义；没有修改或替换 RIME 实现。 |

## 当前运行结果

### UI 源码契约

```sh
./scripts/test_kaomoji_ui_contract.sh
```

结果：`PASS: kaomoji UI interaction contract`。

### KeyboardCore 完整套件

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/uk-q0804-clang-cache \
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/uk-q0804-clang-cache \
swift test --disable-sandbox \
  --package-path Packages/KeyboardCore \
  --scratch-path /private/tmp/uk-q0804-keyboardcore-build
```

结果：`KeyboardCoreTests.xctest` 执行 639 项，0 失败；新增 `KaomojiDirectTextRegressionTests` 两项包含在该结果中。计数仅为本次提交、环境和日期的快照，不是长期固定测试总数。

环境说明：直接 `swift test` 首次因受管环境无法写用户 ModuleCache 而未进入编译；将缓存和 scratch path 定向到 `/private/tmp` 后，SwiftPM 的嵌套 `sandbox-exec` 仍被拒绝，因此最终命令使用 `--disable-sandbox`。这属于测试进程的本地执行参数，没有修改仓库或系统权限。

## 文档与架构影响

- 没有生产行为、架构、产品契约、RIME/Full Access 或数据边界变化，不需要 ADR、`CHANGELOG.md`、`PROJECT_CONTEXT.md` 或 `RELEASE_CHECKLIST.md` 更新。
- 新增的是任务专用回归与交接证据；若任一入口、面板状态、direct-text 或 composition 最终提交实现改变，本证据需要重新运行并由 Quality Reviewer 复核。

## 独立复核请求

请现有独立 **Quality Reviewer（Quality, Performance & Release Maintainer）**：

1. 独立审查 `c9f2b34..1e73c16` 的两文件差异，确认没有生产语义变化；
2. 独立复跑 UI 契约脚本及新增 KeyboardCore 定向测试，必要时复跑完整 KeyboardCore 套件；
3. 结合 Q-08-02 的真机证据，判断本次“结构契约 + Core 行为测试”是否足以满足 Q-08-04；
4. 不由本交接推导 Q-08-03、Q-08-05、任务关闭或 Product Gate 结论。
