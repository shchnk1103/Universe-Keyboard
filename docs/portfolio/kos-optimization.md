# PF-018 — KOS 流程优化候选

2026-10-21 起在 UI-1 / UI-2 同步与生命周期收尾中积累。尚未授权实施；先排序，再按需立项。

## 建议优先做

- 第 6、16 条：派发前放行 Reviewer / Executor 的 `reports/` 目录写权限。多批次第一次写报告都被权限拦过。
- 第 11 条：冻结 packet 时机械扫描 Executor 报告与 Assignment 引用的每个路径是否都在允许集内（工具原型 `tools/scan_cited_paths.py`，位于 `~/.kos-work/Universe-Keyboard/LIFECYCLE-CLOSEOUT-BATCH-1B-001/tools/`）。

## 全部候选

1. 把 Reviewer / Executor 报告存成仓库内或约定路径的文件，不再靠人复制粘贴。
2. Reviewer Lane Packet 与 Assignment 一致性预检：每条声称和每条 Exit evidence 都必须被 packet 允许的文件与操作覆盖。
3. 不设 Reviewer 无法验证的验收标准（如 Executor 的真实模型 / effort，只登记为残项）。
4. 链接检查证据的约定（提交信息不能含自身 SHA）。
5. 不给 Executor 日后要删的措辞（Assignment 草稿不带范围外事实）。
6. 为 Reviewer 会话预先放行报告目录。
7. Scope 起草时列全已知提到该 Work Item 的镜像文件。
8. Packet 声称不得从一例推广到另一例（“同理”）。
9. Coordinator 指令也存成文件，形成完整的文件交接。
10. 按角色派发，不按厂商；报告声明实际运行时身份。
11. 冻结预检覆盖 Executor 报告引用的每个路径。
12. Reviewer 进度增量落盘，首行写状态行。
13. 中断 lane 会话的标准交接记录（模板见批次 1b 的 `handoff-architecture-lane-r2-01.md`）。
14. 供应商额度中断不等于预算耗尽；packet 写明接手者的预算处理。
15. 交接不得依赖某个 AI 的私有会话数据，只用 KOS 文件。
16. 首次真实交接测试（批次 1b Architecture Round 2）：新 Codex 会话仅凭冻结 packet 与交接记录完成评审，交接成立；剩余缺口是首次写报告被权限拦截。
17. 目录化的任务组合（本目录）：把“还没有 Assignment 的意图、优先级、依赖与决定”从对话里搬到文件里。
