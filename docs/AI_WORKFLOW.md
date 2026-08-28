# AI_WORKFLOW.md

本文件定义多个 agent 协作时的分工、交接格式和决策边界。

本文件只负责多 agent 编排。每个角色的可执行权限、证据、停止与交接规则以 `docs/playbooks/` 下的对应 playbook 为准；架构事实仍以 Knowledge Index 指向的权威文档为准。

## 核心原则

- Coordinator 负责最终判断，subagent 只提供受限范围内的调查、建议或补丁。
- 不让多个 subagent 同时修改同一责任区。
- 并行适合调查，不适合无协调地并行写代码。
- 先确认问题属于哪个系统边界，再决定是否写代码。
- 正式任务先按 [`ASSIGNMENT_POLICY.md`](ASSIGNMENT_POLICY.md) 核对 Assignment；`UNKNOWN` 阻止进入 `Ready`，Coordinator/Program Manager 不得自行指派。
- 运营卫生（Current Status、State sync、证据档位、Active Work）见
  [`docs/kos/kos-2.1-operational-maturity.md`](kos/kos-2.1-operational-maturity.md)。
- KOS 2.2 记录按 [`.kos/project.json`](../.kos/project.json) 渐进纳管；包含的工作先核对 Authorization → Assignment → Evidence/Review → Gate/Decision 引用。advisory validator 只证明结构，不替代 Coordinator 或 Human Gate。
- GitHub CLI 在 Codex 沙箱内失败时，先按 [`kos/codex-github-cli-auth-troubleshooting.md`](kos/codex-github-cli-auth-troubleshooting.md) 做一次主机对照；沙箱文案不能单独证明 token 过期，也不能授权修改代理或重复登录。
- GitHub Actions 变更分级以 [`CI_CHANGE_CLASSIFICATION.md`](CI_CHANGE_CLASSIFICATION.md) 为准；`final-quality-gate` 是稳定聚合结果，docs-only 的 heavy skip 必须来自已通过的 fail-closed 分类，不得靠 `paths-ignore`。

## Stacked PR 约定（KOS 2.1 ops · S-02）

当多个 PR 形成提交栈（前缀 PR 的 commits 是 tip 的子集）时：

1. PR 正文声明：`Stack: base=<branch-or-main> tip=<tip-branch>`，并列出前缀 PR 编号。  
2. **优先合并 tip**（含全部 commits）；前缀 PR 在 tip 合入后标记 superseded 或由 GitHub 识别为已合并。  
3. tip 合并后执行 State sync 清单（Dashboard / Index / Assignment Current Status / `ACTIVE_WORK.md`）。  
4. 不要对同一栈做互相冲突的 squash 重写，除非 Product 明确授权并重开 PR。

## 推荐角色

| 角色 | 执行手册 |
|---|---|
| Coordinator | `docs/playbooks/coordinator.md` |
| Context Scout | `docs/playbooks/context-scout.md` |
| Bug Investigator | `docs/playbooks/debug-investigator.md` |
| KeyboardCore Agent | `docs/playbooks/keyboard-core.md` |
| RimeBridge Agent | `docs/playbooks/rime-bridge.md` |
| Keyboard UI Agent | `docs/playbooks/keyboard-ui.md` |
| Main App UI Agent | `docs/playbooks/main-app-ui.md` |
| Test / Release Agent | `docs/playbooks/test-release.md` |
| Documentation Maintainer | `docs/playbooks/documentation-maintainer.md` |

### Coordinator

主协调者，负责：

- 理解用户目标
- 划分任务范围
- 决定需要哪些 subagent
- 合并结论
- 控制最终修改边界
- 向用户说明方案和结果

### Context Scout

只读上下文，不改代码。负责：

- 从 `docs/KNOWLEDGE_INDEX.md` 和 `docs/READING_MAPS.md` 定位任务上下文
- 找出任务相关文档
- 摘要当前架构约束
- 标记可能过时的信息

输出格式：

```md
## Relevant Context

- 相关文件：
- 必须遵守的约束：
- 可能过时或需要验证的信息：
```

### Bug Investigator

负责诊断问题，不急于修复。适合卡死、延迟、状态错乱、候选异常等问题。

职责：

- 建立复现路径
- 分析输入、状态、副作用、输出
- 提出日志点
- 区分 UI / Core / RIME / 文件系统 / App Group 边界
- 给出最小诊断改动建议

输出格式：

```md
## Diagnosis Plan

- 现象：
- 初始假设：
- 需要观测的状态：
- 建议日志点：
- 不建议现在做的猜测性修复：
```

### KeyboardCore Agent

负责 `Packages/KeyboardCore`。

职责：

- 处理纯逻辑状态机
- 更新 `KeyboardAction` / `KeyboardState` / `KeyboardEffect`
- 增加或修改单元测试
- 避免引入 UIKit、文件系统或 RIME 具体实现依赖

### RimeBridge Agent

负责 `Packages/RimeBridge` 和 RIME 边界。

职责：

- 处理 RIME session、部署服务、ObjC bridge
- 保持主 App 部署、Keyboard Extension session-only 的边界
- 不把 full deployment 放进输入热路径

### Keyboard UI Agent

负责 `Keyboard/`。

职责：

- UIKit 键盘视图、候选栏、按键布局、手势、无障碍
- 只把业务动作转交给 `KeyboardController`
- 不把核心输入逻辑塞回 ViewController

### Main App UI Agent

负责 `Universe Keyboard/`。

职责：

- SwiftUI 设置页、引导页、诊断页
- 遵守 Settings 风格和共享组件约束
- 不影响 Keyboard Extension 输入路径

### Test / Release Agent

负责验证和发布前检查。

职责：

- 选择最小必要验证命令
- 汇总测试结果
- 检查是否需要更新 `CHANGELOG.md`
- 标记需要真机验证的风险

## 标准任务流程

1. 检查 Assignment：Product Decision、Domain Owner、Executor、依赖、Reviewer、Entry/Exit/Stop Conditions 和 Handoff；存在 `UNKNOWN` 时停止并升级。
2. 若 Assignment 被 `.kos/project.json` 纳管，核对 canonical envelope、Authorization receipt 和 Current Status mirror；未纳管的 legacy 记录在 advisory 下仍按 Markdown 权威执行，不擅自批量迁移。
3. 归类任务：bug / UI / Core / RIME / docs / release。
4. 读取上下文：先读 `AGENTS.md` 和 `docs/KNOWLEDGE_INDEX.md`，再按 `docs/READING_MAPS.md` 和领域 playbook 加载对应文档。
5. 第一性原理拆解：输入、状态、副作用、输出、验证方式。
6. 决定策略：
   - 根因不清楚：先加日志或复现工具。
   - 逻辑明确：先写测试，再改实现。
   - UI 问题：先确认设计约束，再改界面。
   - RIME 问题：先确认部署/session 边界。
7. 执行修改。
8. 验证；KOS validator 结果单列为结构证据，不写成 Product/Quality 通过。
9. 汇报结果和残余风险并交给 Assignment Record 中的 Handoff Target。

## 交接格式

subagent 的结论必须短、具体、可验证：

```md
## Summary

一句话结论。

## Evidence

- 文件/行号：
- 命令输出：
- 复现步骤：

## Recommendation

建议做什么，不做什么。

## Risk

剩余风险或未验证项。
```

## 禁止事项

- 没有证据就大规模重构。
- 为了消除编译错误而降低并发安全。
- 在 Keyboard Extension 输入路径里做重部署、重文件同步或重 IO。
- 把历史流水账加入 `docs/PROJECT_CONTEXT.md` 或 `CLAUDE.md`。
- 同时让多个 agent 修改同一个文件区域。
