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
3. 按 `docs/READING_MAPS.md` 中的任务类型加载对应文档
4. 涉及代码改动时再阅读 `docs/PROJECT_CONTEXT.md`

`CONTEXT_INDEX.md` 保留为详细文档注册表，不再是新会话的第一导航入口。
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

## 完成标准

每次实现类任务完成时，应说明：

- 改了什么
- 为什么这样改
- 验证了什么
- 哪些验证未执行及原因
- 是否需要更新 `CHANGELOG.md` 或架构文档
