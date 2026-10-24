# PF-018 — KOS 流程优化候选

2026-10-21 起在 UI-1 / UI-2 同步与生命周期收尾中积累。尚未授权实施；先排序，再按需立项。

## 建议优先做

- 第 6、16 条：派发前放行 Reviewer / Executor 的 `reports/` 目录写权限。多批次第一次写报告都被权限拦过。
- 第 17、18 条：独立性按上下文判断并分级（Human 已同意方向，见 PF-019）。
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
17. Reviewer 独立性按“会话 + 加载的记忆”共同判断（批次 1c Architecture 暴露）：一个全新的 Grok Build 会话读到工作区记忆里记录着自己此前对同一条链做过实现与评审，无法声明独立性并停止；另一个新 Grok 会话读到同一记忆却作了声明。packet 只写了“未参与”。需要规则：独立性同时看会话和记忆里是否有对被评审对象的自有记录；packet 点名哪些工具已做过该链；报告声明加载的记忆。
18. 独立性分级（Human 2026-10-22 同意方向，起因是只有一家 AI 的用户）：L1 同一模型不同会话；L2 同一厂商不同模型；L3 不同厂商。由 Assignment 按风险规定最低级别（记账性质的文档收尾 L1，发布 / 安全 / 对外公开类 L3 或 Human 亲评），报告声明实际级别；Reviewer 只读产物、不读 Executor 或另一位 Reviewer 的推理；优先写成可用命令复现的声称。不改变正在进行的批次；政策文本待起草并经评审。
19. 目录化的任务组合（本目录）：把“还没有 Assignment 的意图、优先级、依赖与决定”从对话里搬到文件里。
20. Assignment 草稿定稿前对照 `docs/ASSIGNMENT_POLICY.md` 的 Required Assignment Fields 表做机械自查：`KEYBOARD-VALUES-DOC-001` 与 `PORTFOLIO-DIRECTORY-001` 的 Assignment 都漏了必填的 Environment Executor，前者被 Executor 在入口合同处拦下，后者合并后才发现。
21. Executor 与 Reviewer 把报告写成文件后，对话里的最终消息只给状态、路径、SHA-256 与文件里没有的内容，不要复述报告（Human 2026-10-22 反馈）。
22. 冻结 Reviewer 包之前做自洽性检查：要求读取或复算的材料必须都在允许集内。停止条件按项区分。整轮停止只用于独立性无法声明、冻结表摘要不符、HEAD 不对、越权写入。其它缺口标成未覆盖并停该条，不把整轮停掉。
23. 派发 = 角色 + 文件路径 + SHA-256。不在对话里粘贴长指令；指令先落盘，派发消息只指向那份文件和它的 SHA-256。
24. “任务完成”的定义：报告与 Reviewer 结论交付即完成。待 Human 决定的事写进报告的固定一节。最终消息只写一句，指向该节，不在对话里展开。
25. PM 每次决定后在回复中明确写“已记入 X / 暂存在 Y，尚未入目录”，并有机制核对（PM 提议，Human 2026-10-24 同意列入优化项，见 PORTFOLIO-REFRESH-004）。
26. bot 任务单必须包含“输出限制”与“越界分级（硬 / 软）”，平台个人规则不属于任务单（GROK-BOT-TRIAL-013 补充 1）。
27. 取新任务编号前先检查目录是否已存在（TRIAL-010 重复事件）。
28. Reviewer packet 自查：每项 claim 所需材料都在允许集内、冻结表里不放另一 lane 的输出（UI3 与 UI4 入库评审的 packet 缺口，见 docs/assignments/ui4-pd-landing-001.md 与 docs/assignments/ui3-pd-landing-001.md 的评审结果节）。
29. 涉及手势或触觉的功能，真机验收先于冻结 Reviewer 包（UI-4 真机验收发现的拖动缺陷，见 docs/assignments/ui4-height-001.md 的 Exit evidence）。
