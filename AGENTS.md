# AGENTS.md

本仓库的 AI 协作规则。所有 agent 在开始工作前必须先阅读本文件。

## 基本沟通规则

- 始终使用中文回复。
- 除非用户明确要求实施或修改，否则先讨论方案，不直接改文件。明确授权后，在该任务范围内持续推进；不因加载技能、角色切换或上下文压缩重复请求相同授权。
- 代码改动必须优先保证可读性。
- 可以适当增加注释，但注释应解释意图、边界或复杂原因，避免复述代码。
- 遇到不确定问题时，先核查事实并区分假设。已授权范围内的常规实现选择可自主决定；影响产品合同、权限、必需证据或不可逆动作的缺口才请求决定。
- 适当使用第一性原理分析：输入是什么、状态在哪里、副作用是什么、输出如何验证。

## 工作入口

新会话开始时先阅读：

1. `AGENTS.md`
2. `docs/KNOWLEDGE_INDEX.md`
3. `docs/ACTIVE_WORK.md`（当前 Active 工作项 ≤10；生命周期以 Assignment 为准）
4. 按 `docs/READING_MAPS.md` 中的任务类型加载对应文档
5. 涉及代码改动时再阅读 `docs/PROJECT_CONTEXT.md`
6. 运营卫生规则见 `docs/kos/kos-2.1-operational-maturity.md`（不替代 KOS 2.0 冻结原则）
7. KOS 2.2 目前为 **advisory**，Adopted pin v0.9.0：E-01、A-01/B-01、P-01、D-01 仍仅供新记录显式 opt-in；v0.9.0 的 M-02 触发身份/非递归收尾适用于本决定后的触发，reviewer 范围/预算/停止条款适用于决定后新分配的独立 lane。细则见 [docs/kos/UPGRADE_STATUS.md](docs/kos/UPGRADE_STATUS.md) 与 .kos/project.json。校验绿不是 Product / merge / Release。未授权 required。
8. **Task Workspace（opt-in，UK-007）**：只对 Assignment 明确写明采用 `ops/task-workspace.md`（Kit commit `9ca6dc015bf01084150538aac65cedc25b2a33a5`，见 [docs/kos/UPGRADE_STATUS.md](docs/kos/UPGRADE_STATUS.md)）的新任务生效；现有 Active 任务、Codex 任务与 Worktree 不迁移、不修改。拿到 Task ID 时：① 在 `docs/assignments/` 按 `record_id` 定位 Assignment（找不到再按 Task ID 搜 PR 与远端分支）；② 定位 carrier 分支；③ fetch 后读该分支 head 上的 `docs/tasks/<TASK-ID>/BRIEF.md`、`log.md`，以及 AUTH、Plan 和 `read_on_demand` 指向的必要证据；④ 确认当前阶段、Checkpoint 与剩余工作；⑤ 先按合同第四、八节核对 Writer，再动手：若无待接收 `P`，且从 `log.md` 推出的 `W` 是本 Agent、授权有效，可以继续写任务；若待接收 `P` 指向本 Agent，且第八节核对满足接收条件（共同前置条件成立并命中第 3 行，含 `H == S`），只可提交并推送 `ACCEPT`，`ACCEPT` 推送成功后才取得任务代码和其他授权路径的写权；镜像与 log 冲突、状态未知或不满足接收条件，必须停止，不得推测权限；Human 署名的异常接管仍按合同第四节执行，本条不扩大其权限；⑥ 在有效授权内继续；⑦ 重要进度变化时写 Checkpoint。无法访问仓库或 GitHub 的 Agent 须明确请求所需资料，或由 Human 中转。无法判断阶段调整是否属于已授权的非实质性细节时，停止并请求 Human。本入口不绑定模型、客户端或厂商，也不是完全自动化的跨平台接管或排他锁。

`CONTEXT_INDEX.md` 保留为详细文档注册表，不再是新会话的第一导航入口。
需要确定长期团队所有权、跨线程协作或永久线程 bootstrap 时，阅读 `docs/VIRTUAL_ENGINEERING_TEAM.md`。
正式任务进入 `Ready` 或开始执行前，必须按 `docs/ASSIGNMENT_POLICY.md` 核对 Assignment；任何必需字段为 `UNKNOWN` 时停止并交回 Product Lead。边界明确的只读问题使用该 Policy 的例外。阶段依赖与当前授权解释见 `docs/AI_WORKFLOW.md`。
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
- 发布按用户授权的具体动作推进：commit、push、PR、merge、Release 分别核对范围。仅要求本地提交不推送；推送使用边界清晰的功能分支。技能不能扩展外部动作权限。
- **合并 / 视为可合并之前，必须先在本地跑通与 CI 等价的质量门**（见下「本地 CI 门禁」）。禁止在相关套件未绿时推送并请求合并到默认分支；若用户明确说「只推不合并 / 草稿 PR」，可推功能分支但必须在报告中写明本地未跑或未绿的步骤。**例外不豁免 Swift 格式：** 只要本次提交/推送包含 `.swift` 变更，无论是否草稿 PR、是否只推不合并，都必须先通过下方「Swift 格式硬门槛」；格式失败不得 push。
- “已推送功能分支”不等于“可以清理分支”。PR 未合并、检查失败或远端状态无法确认时，必须同时保留本地和远端功能分支。
- 只有在拉取最新远端状态后，确认该工作的提交已经可从 `origin` 的默认分支到达，才允许清理功能分支。
- 清理时先同步默认分支，再使用安全删除方式删除本地分支；确认远端默认分支仍包含对应提交后，才删除远端功能分支。禁止用强制删除掩盖未合并状态。
- 发布与清理过程必须报告提交、远端分支、PR、合并可达性检查和实际删除结果；任一步失败都停止清理并保留可恢复检查点。

### 合并后清理（PF-023）

- 时点与负责人：PR 合并、核对合并结果时，由该任务的 Executor 列出本任务创建的 worktree 与分支。
- 清理前检查：拉取最新远端后，确认已并入 `origin/main`、未提交改动为 0、不受保护。复查不满足的对象跳过，其余继续；任何删除命令失败或被拒，立即停止整批并保留检查点（同本节已有规则）。
- 授权方式：Human 一条消息授权一批，点名清单与 SHA。
- 执行方式：安全删除（`worktree remove` 不加 `--force`、`branch -d`、`push --delete`）。禁止强制删除。PR 未合并、检查失败或远端状态无法确认时，保留本地和远端分支。
- 记录：外置回执写明对象、删前 SHA、检查结果与实际结果。
- 受保护对象：B-001 工作区与分支、`preserve/`、`local/`、`backup`、有未提交改动的、进行中任务的、其它工具目录。
- 远程分支是否在合并时自动删除，取决于 GitHub 仓库设置（由 Human 决定）。
- 主检出快进：Human 2026-10-28 决定可以快进主检出的 `main`，并固定为流程。PM 执行细则：每次合并并经 PM 核对后，若主检出在 `main`、没有本地改动或未跟踪文件、且 `HEAD` 是 `origin/main` 的祖先，执行 `git merge --ff-only origin/main` 并报告新旧 SHA；任一条件不满足则不动，并告诉 Human。

## KOS 协作约定

- 派发只按角色与会话约束，不指定哪个 AI（Human 2026-10-26 决定，见 `docs/PORTFOLIO.md` 决定记录）。
- 每日复盘（Human 2026-10-27 决定）：当天确实做了工作时，在适当的时候总结当天遇到的问题和能纳入经验的举措；PM 用大白话说明当天做了什么。
- PM 会话独立：Human 2026-10-28 要求 PM 角色的会话尽量保持相对独立。PM 执行做法：不开 PR、不推送分支、不在任务 worktree 中工作；合并后的主检出快进（见「合并后清理（PF-023）」）不属于任务 worktree。
- 会话归档（Human 2026-10-28 陈述）：会话被归档会断开 Remote Control，取消归档后不会自动恢复。

### 任务包与派发（Human 2026-10-28 批准）

- 非 PM 角色的任务包首行写明角色（如 Executor / Quality Reviewer）与“你不是 PM”；全部结果写进报告；最终消息只写一句话：状态 + 报告路径 + SHA-256。
- 写入被拒（含执行器沙箱）时立即停止，并写明被拒的路径与操作。执行器侧的可写目录由 Human 配置，文字授权不能改变沙箱。
- 在链接 worktree 中提交、fetch 或 push 时，任务包点名允许写入的主检出 `.git` 路径（`worktrees/<名>/`、`objects/`、相关 refs 与 reflog）并列出排除项。
- 任务包作者发包前自审：验收条件里的结构数字用命令得出；同包规则互不冲突；每条验收先在模拟结果上跑一遍；事实句逐句有出处且不升级证据级别。
- 冻结要求互相冲突时，执行者停止并请求修订；修订包须点名哪些冻结输入作废，并保留原 BLOCKED 报告。
- 授权与派发消息保持简短，固定为：任务名、角色、包路径、SHA-256 与“授权，直接执行”；批准项写进任务包的“Human 预批准项”，随 SHA 冻结。

### 设计、预检与复核分级（Human 2026-10-28 批准）

- 代码任务先写设计、交独立 Architecture 只读复核，通过后再写实现包。
- 涉及实现或要原样写入仓库文字的包，派发前必须经独立只读预检。
- 复核发现分级：仅文字的小问题发布前以小提交修正、只复核改动部分；代码 / 设计问题按整轮处理。

## 本地 CI 门禁（与 `.github/workflows/swift6-quality.yml` 对齐）

远端工作流按 [`docs/CI_CHANGE_CLASSIFICATION.md`](docs/CI_CHANGE_CLASSIFICATION.md)
分级：分类、轻量检查和 `final-quality-gate` 始终运行；只有严格的 docs/KOS allowlist
可跳过全部 heavy jobs（`format-swift`、`test-keyboardcore`、`test-rimebridge`、
`test-app-keyboard`、`test-rime-sync-keychain`、`build-release`）。未知路径、workflow 或 `scripts/ci/**`
变更必须走完整门禁。不得按 UI/Rime 等源路径跳过其中一部分。

在 **push 后预期合并**、或用户要求「上传并合并 / 修 CI / ship」时，在推送前（至少在 merge 前）于本地执行与 CI 同序的检查。默认模拟器名与 CI 一致：`iPhone 17 Pro`（本机无该机型时可用等价 iOS Simulator，并在报告中写明）。

### Swift 格式硬门槛（任何含 `.swift` 的 commit / push）

相对推送目标分支（通常为默认分支或当前 PR 基线）的变更 `.swift` 文件，在 **commit 前且 push 前** 必须全部通过：

```bash
xcrun swift-format format --in-place --configuration .swift-format <file>
xcrun swift-format lint --strict --configuration .swift-format <file>
```

`lint --strict` 失败即停止；**不得** commit 或 push。草稿 PR、「只推不合并」、本地已跑过部分测试等情形 **均不豁免** 本条。推荐先 `format --in-place` 再 `lint`，避免 CI `Check Swift formatting` 反复红灯（历史：PR #100 多次卡在换行/折行）。

1. **（若改了 RIME 二进制依赖）** `bash scripts/ensure_rime_vendor.sh fetch`
2. **（若有 Swift 改动）** 先满足上方「Swift 格式硬门槛」（与 CI `Check Swift formatting` 对齐）
3. **KeyboardCore：** `swift test --package-path Packages/KeyboardCore`
4. **RimeBridgeTests：**  
   `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test`
5. **App + Keyboard 测试（含 UniverseKeyboardTests / KeyboardTests）：**  
   `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test`
6. **签名 Keychain 集成：** `Universe Keyboard` Debug scheme、同上 destination，使用
   `CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO`，并以
   `-only-testing:UniverseKeyboardTests/RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem`
   执行 `test`（与 CI 的 `test-rime-sync-keychain` 对齐）。无签名的步骤 5 不替代此检查。
7. **Release build：** 同上 destination，`-configuration Release` 的 `build`（参数与 CI 一致）。Debug `test` 已覆盖 Debug 编译，不再单独跑 Debug `build`。

**范围收窄（仅当改动极小时）：** 纯文档且无 Swift / 工程 / 测试文件改动时，可跳过 3–7，但须在完成报告中写明「docs-only，跳过 xcodebuild」。只改 `Packages/KeyboardCore` 时至少跑步骤 3；改主 App / Extension / 测试 target 时 **不得** 只跑 KeyboardCore 就声称可合并。

修改 `.github/workflows/**`、`scripts/ci/**` 或分类规则本身时不得使用 docs-only
例外；必须验证完整路径和 docs-only 路径，并在 merge 前取得 hosted run 证据。

**改完测试或部署意图后：** 必须跑到会执行该用例的 target（例如改了 `UniverseKeyboardTests` 就必须跑步骤 5，不能只跑 KeyboardCore）。  
历史教训：#48 合并后 CI 红在 `RimeSettingsStoreTests`（签名 `schema=all` 与测试种子不一致）——本地若只跑 KeyboardCore 过滤套件会漏掉。

质量证据可按 `docs/AI_WORKFLOW.md` 的最终内容、基线、环境和覆盖条件复用；不能因此跳过必需门禁。
明确要求重跑时重跑；证据仍有效时，仅再次要求 merge 不自动触发重复全套验证。

## 完成标准

每次实现类任务完成时，应说明：

- 改了什么
- 为什么这样改
- 验证了什么
- 哪些验证未执行及原因
- 是否需要更新 `CHANGELOG.md` 或架构文档
