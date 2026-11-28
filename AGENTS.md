# AGENTS.md

本仓库的 AI 协作规则。所有 agent 在开始工作前必须先阅读本文件。低频步骤与命令全文见文中链接；链接不替代本节红线。

## 基本沟通规则

- **语言边界（Human 2026-11-27 批准，长期渐进迁移见 [docs/kos/english-migration-roadmap.md](docs/kos/english-migration-roadmap.md)）**：面向 Human 的对话回复、状态汇报与 Human 常阅台账（如 `docs/PORTFOLIO.md`）保持中文；代码注释、员工报告、指令包及内部工程 / 角色设定文档支持并推荐逐步迁移为英文（节省 token）。历史冻结报告与 Human 界面文字不回改。
- 除非用户明确要求实施或修改，否则先讨论方案，不直接改文件。明确授权后，在该任务范围内持续推进；不因加载技能、角色切换或上下文压缩重复请求相同授权。
- 代码改动必须优先保证可读性。
- 可以适当增加注释，但注释应解释意图、边界或复杂原因，避免复述代码。
- 遇到不确定问题时，先核查事实并区分假设。已授权范围内的常规实现选择可自主决定；影响产品合同、权限、必需证据或不可逆动作的缺口才请求决定。
- 适当使用第一性原理分析：输入是什么、状态在哪里、副作用是什么、输出如何验证。

## 工作入口

新会话按序阅读：`AGENTS.md` → `docs/KNOWLEDGE_INDEX.md` → 任务包或 Human 指定的当前工作（查未完成项读 `docs/PORTFOLIO.md` 并核对所依赖的行；`docs/ACTIVE_WORK.md` 自 2026-11-07 起冻结为历史快照，不再默认加载）→ 按 `docs/READING_MAPS.md` 加载对应文档 → 涉及代码再读 `docs/PROJECT_CONTEXT.md`。运营卫生见 `docs/kos/kos-2.1-operational-maturity.md`（不替代 KOS 2.0 冻结原则）。

KOS 2.2 目前为 **advisory**，Adopted pin v0.9.0；E-01、A-01/B-01、P-01、D-01 仍仅供新记录显式 opt-in。细则见 [docs/kos/UPGRADE_STATUS.md](docs/kos/UPGRADE_STATUS.md) 与 `.kos/project.json`。校验绿不是 Product / merge / Release。未授权 required。

Task Workspace（opt-in，UK-007）只对 Assignment 明确采用的新任务生效，现有任务不迁移。七步入口与停止条件见 [docs/kos/task-workspace-entry.md](docs/kos/task-workspace-entry.md)。无法判断阶段调整是否属于已授权的非实质性细节时，停止并请求 Human。

`CONTEXT_INDEX.md` 是详细注册表，不再是第一导航入口。长期所有权读 `docs/VIRTUAL_ENGINEERING_TEAM.md`。正式任务进入 `Ready` 或开始执行前，必须按 `docs/ASSIGNMENT_POLICY.md` 核对 Assignment；任何必需字段为 `UNKNOWN` 时停止并交回 Product Lead。阶段依赖见 `docs/AI_WORKFLOW.md`。需要领域 agent 时，必须选择 `docs/playbooks/` 下的对应手册，并遵守其停止、交接和证据规则。

## 调试原则

- 根因不清楚时，不要直接猜修。优先增加精准日志、复现路径和观测点。
- 输入法卡死、延迟、候选异常、RIME session 异常，先区分：UI 主线程、KeyboardCore 状态机、RIME session / bridge、App Group / 文件系统 / 部署状态。
- 日志必须放在能缩小问题范围的位置，避免无意义刷屏。输入热路径中的日志和持久化不能同步阻塞按键处理。

## 修改边界

- 不做与任务无关的重构。
- 不随意改动 RIME 部署边界：主 App 可部署，Keyboard Extension 运行期只处理 session。
- 不用 `@unchecked Sendable` 或不安全隔离来绕过 Swift 6 并发问题。
- UI 改动必须遵守 `docs/UI_STYLE_GUIDE.md`。
- 修改 `Packages/KeyboardCore` 时优先补充或更新单元测试。
- 修改历史、决策或已知限制时，更新对应文档，不把流水账塞进 `docs/PROJECT_CONTEXT.md` 或 `CLAUDE.md`。

## GitHub 发布、分支清理与合并后清理（PF-023）

- **合并前须通过本机定向快验及适用的 GitHub Actions 托管 CI 质量门**（见「本地 CI 门禁」与 [docs/kos/local-ci-commands.md](docs/kos/local-ci-commands.md)）。未通过适用门禁不得请求合并；若用户明确说「只推不合并 / 草稿 PR」，须在报告中写明未跑或未绿的步骤。**例外不豁免 Swift 格式：** 只要本次提交/推送包含 `.swift` 变更，无论是否草稿 PR、是否只推不合并，都必须先通过「Swift 格式硬门槛」；格式失败不得 push。
- “已推送功能分支”不等于可以清理。PR 未合并、检查失败或远端状态无法确认时，必须同时保留本地和远端功能分支。禁止用强制删除掩盖未合并状态。
- **squash 双验前全局禁止 `git branch -D`（O123）。** 仅当 [docs/kos/pf-023-cleanup.md](docs/kos/pf-023-cleanup.md) 的三条硬条件同时满足，才允许对该单一已合并功能分支带证据删除。受保护对象（B-001、`preserve/`、`local/`、`backup`、未提交改动、进行中任务、在用分支）严格豁免。`worktree remove` 不加 `--force`。任何删除命令失败或被拒，立即停止整批并保留检查点。
- 真机验收或 Xcode 装机前，必须核对当前构建目录 `HEAD` 与 PM 提供的目标封版 SHA 一致（O122-D）。核对命令、沙箱认证对照、清理回执与快进条件见 [docs/kos/github-publish.md](docs/kos/github-publish.md) 与 [docs/kos/pf-023-cleanup.md](docs/kos/pf-023-cleanup.md)。
- 发布按用户授权的具体动作推进：commit、push、PR、merge、Release 分别核对范围。仅要求本地提交不推送。技能不能扩展外部动作权限。任一步失败都停止并保留可恢复检查点。

## KOS 协作约定

- 派发只按角色与会话约束，不指定哪个 AI。PM 不开 PR、不推送分支、不在任务 worktree 中工作；合并后的主检出快进由合并清理 Executor 按 PF-023 执行。
- 非 PM 角色最终消息只写一句话：状态 + 报告路径 + SHA-256。写入被拒（含执行器沙箱）时立即停止，并写明被拒的路径与操作；文字授权不能改变沙箱。
- 冻结要求互相冲突时，执行者停止并请求修订；修订包须点名哪些冻结输入作废，并保留原 BLOCKED 报告。发包前自审见 [PM 手册](docs/kos/pm-playbook.md) 第 3 节。
- **部门池实名领牌（O113 / O118）**：派发块只写部门名，不点名员工。开工前运行 `kos-board.py claim --role <部门> --task <TASK-ID>` 原子领取一张空闲牌；报告以领到的真实姓名署名，收尾以同一实名 `set <名字> idle`。严禁代领或冒名。`claim` 与 `set idle` 仅由顶层主会话各执行一次；子代理沿用父会话身份，严禁占第二张牌。名册、轮询与 `WAITING_CI` 见 [docs/kos/tier-routing.md](docs/kos/tier-routing.md)。
- **4 档只分流协作站点，不改变**下方本地 CI 门禁、[CI 分级](docs/CI_CHANGE_CLASSIFICATION.md)、Swift 格式硬门槛与既有文档 / 测试 / CI 分类。只有 `feature` 必走设计 + 架构审查；`doc-light` 免预检、免独立复核。升降级只升不降。直通条件（O129，含 `ci_watch.sh`）的权威文本见 [docs/kos/tier-routing.md](docs/kos/tier-routing.md)。

## 本地 CI 门禁

- 远端按 [docs/CI_CHANGE_CLASSIFICATION.md](docs/CI_CHANGE_CLASSIFICATION.md) 分级：分类、轻量检查和 `final-quality-gate` 始终运行。未知或混合路径走完整门禁。纯文档且无 Swift / 工程 / 测试改动可跳过重型任务，但须在完成报告写明「docs-only，跳过 xcodebuild」。修改 `.github/workflows/**`、`scripts/ci/**` 或分类规则本身不得使用 docs-only 例外。
- 只改 `Packages/KeyboardCore` 时至少跑该包测试；改主 App、Keyboard Extension 或测试 target 时必须跑到会执行该用例的 scheme，不能只跑 KeyboardCore。
- **Swift 格式硬门槛（任何含 `.swift` 的 commit / push，无豁免）：** 相对推送目标分支的变更 `.swift` 文件，在 commit 前且 push 前必须全部通过 `xcrun swift-format format --in-place --configuration .swift-format <file>` 与 `xcrun swift-format lint --strict --configuration .swift-format <file>`。`lint --strict` 失败即停止，不得 commit 或 push。草稿 PR 与「只推不合并」均不豁免。
- 本机定向快验（local-fast）、分级矩阵、七步 xcodebuild 与证据复用的命令全文见 [docs/kos/local-ci-commands.md](docs/kos/local-ci-commands.md)。

## 完成标准

每次实现类任务完成时，应说明：改了什么、为什么这样改、验证了什么、哪些验证未执行及原因、是否需要更新 `CHANGELOG.md` 或架构文档。
