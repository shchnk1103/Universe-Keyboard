# AGENTS.md

本仓库的 AI 协作规则。所有 agent 在开始工作前必须先阅读本文件。

## 基本沟通规则

- 始终使用中文回复。
- 除非用户明确要求写代码，否则先讨论方案，不直接改文件。
- 代码改动必须优先保证可读性。
- 可以适当增加注释，但注释应解释意图、边界或复杂原因，避免复述代码。
- 遇到不确定问题时，先澄清事实和假设，再行动。
- 适当使用第一性原理分析：输入是什么、状态在哪里、副作用是什么、输出如何验证。

## 工作入口

新会话开始时先阅读：

1. `AGENTS.md`
2. `docs/KNOWLEDGE_INDEX.md`
3. `docs/ACTIVE_WORK.md`（当前 Active 工作项 ≤10；生命周期以 Assignment 为准）
4. 按 `docs/READING_MAPS.md` 中的任务类型加载对应文档
5. 涉及代码改动时再阅读 `docs/PROJECT_CONTEXT.md`
6. 运营卫生规则见 `docs/kos/kos-2.1-operational-maturity.md`（不替代 KOS 2.0 冻结原则）
7. KOS 2.2 目前为 **advisory**，Adopted pin `v0.6.0`：入口是 [`docs/kos/UPGRADE_STATUS.md`](docs/kos/UPGRADE_STATUS.md) 与 `.kos/project.json`。校验绿不是 Product / merge / Release。未授权 `required`。

`CONTEXT_INDEX.md` 保留为详细文档注册表，不再是新会话的第一导航入口。
需要确定长期团队所有权、跨线程协作或永久线程 bootstrap 时，阅读 `docs/VIRTUAL_ENGINEERING_TEAM.md`。
正式任务进入 `Ready` 或开始执行前，必须按 `docs/ASSIGNMENT_POLICY.md` 核对 Assignment；任何必需字段为 `UNKNOWN` 时停止并交回 Product Lead。
需要领域 agent 时，必须选择 `docs/playbooks/` 下的对应操作手册，并遵守其停止、交接和证据规则。

## 调试原则

- 根因不清楚时，不要直接猜修。
- 优先增加精准日志、复现路径和观测点。
- 对输入法卡死、延迟、候选异常、RIME session 异常等问题，先区分：
  - UI 主线程问题
  - KeyboardCore 状态机问题
  - RIME session / bridge 问题
  - App Group / 文件系统 / 部署状态问题
- 日志必须放在能缩小问题范围的位置，避免无意义刷屏。
- 输入热路径中的日志和持久化不能同步阻塞按键处理。

## 修改边界

- 不做与任务无关的重构。
- 不随意改动 RIME 部署边界：主 App 可部署，Keyboard Extension 运行期只处理 session。
- 不用 `@unchecked Sendable` 或不安全隔离来绕过 Swift 6 并发问题。
- UI 改动必须遵守 `docs/UI_STYLE_GUIDE.md`。
- 修改 `Packages/KeyboardCore` 时优先补充或更新单元测试。
- 修改历史、决策或已知限制时，更新对应文档，不把流水账塞进 `docs/PROJECT_CONTEXT.md` 或 `CLAUDE.md`。

## GitHub 发布与分支清理

- Codex 沙箱内的 GitHub CLI 认证失败不得单独解释为 token 过期。先按
  [`docs/kos/codex-github-cli-auth-troubleshooting.md`](docs/kos/codex-github-cli-auth-troubleshooting.md)
  做一次沙箱／主机对照；主机成功后停止重复登录，不猜测或复用旧代理配置。
- 完成的独立工作应先通过发布前检查，创建边界清晰的本地提交，再推送功能分支并创建 Pull Request。
- **合并 / 视为可合并之前，必须先在本地跑通与 CI 等价的质量门**（见下「本地 CI 门禁」）。禁止在相关套件未绿时推送并请求合并到默认分支；若用户明确说「只推不合并 / 草稿 PR」，可推功能分支但必须在报告中写明本地未跑或未绿的步骤。
- “已推送功能分支”不等于“可以清理分支”。PR 未合并、检查失败或远端状态无法确认时，必须同时保留本地和远端功能分支。
- 只有在拉取最新远端状态后，确认该工作的提交已经可从 `origin` 的默认分支到达，才允许清理功能分支。
- 清理时先同步默认分支，再使用安全删除方式删除本地分支；确认远端默认分支仍包含对应提交后，才删除远端功能分支。禁止用强制删除掩盖未合并状态。
- 发布与清理过程必须报告提交、远端分支、PR、合并可达性检查和实际删除结果；任一步失败都停止清理并保留可恢复检查点。

## 本地 CI 门禁（与 `.github/workflows/swift6-quality.yml` 对齐）

远端工作流按 [`docs/CI_CHANGE_CLASSIFICATION.md`](docs/CI_CHANGE_CLASSIFICATION.md)
分级：分类、轻量检查和 `final-quality-gate` 始终运行；只有严格的 docs/KOS allowlist
可跳过 `build-and-test`。未知路径、workflow 或 `scripts/ci/**` 变更必须走完整门禁。

在 **push 后预期合并**、或用户要求「上传并合并 / 修 CI / ship」时，在推送前（至少在 merge 前）于本地执行与 CI 同序的检查。默认模拟器名与 CI 一致：`iPhone 17 Pro`（本机无该机型时可用等价 iOS Simulator，并在报告中写明）。

1. **（若改了 RIME 二进制依赖）** `bash scripts/ensure_rime_vendor.sh fetch`
2. **（若有 Swift 改动）** 对相对默认分支的变更 `.swift` 跑  
   `xcrun swift-format lint --strict --configuration .swift-format <file>`
3. **KeyboardCore：** `swift test --package-path Packages/KeyboardCore`
4. **RimeBridgeTests：**  
   `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test`
5. **App + Keyboard 测试（含 UniverseKeyboardTests / KeyboardTests）：**  
   `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test`
6. **Debug / Release build：** 同上 destination，分别 `-configuration Debug|Release` 的 `build`（参数与 CI 一致）

**范围收窄（仅当改动极小时）：** 纯文档且无 Swift / 工程 / 测试文件改动时，可跳过 3–6，但须在完成报告中写明「docs-only，跳过 xcodebuild」。只改 `Packages/KeyboardCore` 时至少跑步骤 3；改主 App / Extension / 测试 target 时 **不得** 只跑 KeyboardCore 就声称可合并。

修改 `.github/workflows/**`、`scripts/ci/**` 或分类规则本身时不得使用 docs-only
例外；必须验证完整路径和 docs-only 路径，并在 merge 前取得 hosted run 证据。

**改完测试或部署意图后：** 必须跑到会执行该用例的 target（例如改了 `UniverseKeyboardTests` 就必须跑步骤 5，不能只跑 KeyboardCore）。  
历史教训：#48 合并后 CI 红在 `RimeSettingsStoreTests`（签名 `schema=all` 与测试种子不一致）——本地若只跑 KeyboardCore 过滤套件会漏掉。

## 完成标准

每次实现类任务完成时，应说明：

- 改了什么
- 为什么这样改
- 验证了什么
- 哪些验证未执行及原因
- 是否需要更新 `CHANGELOG.md` 或架构文档
