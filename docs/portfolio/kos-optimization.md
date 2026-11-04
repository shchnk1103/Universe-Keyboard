# PF-018 — KOS 流程优化候选

2026-10-21 起在 UI-1 / UI-2 同步与生命周期收尾中积累。部分候选已于 2026-10-28 采纳并写入 `AGENTS.md`（见文末“已采纳”）；其余尚未授权实施；先排序，再按需立项。

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
30. 激活规则措辞摩擦：PM 提议任务单明确激活方式，派发附 Human 授权原话，Executor 另存签发回执并复算 SHA-256；涉及 worktree / 分支时明写授权创建；尚未采纳为 KOS 规则（来源：`~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-005/content/backlog-notes.md`（SHA-256 `bbf9c298e4b728a5123a74ba3119d5f82c3c8983d90aa3163bb0925bc9a81371`） B2，REFRESH-004a 首次停止）。
31. 角色回复规范：Human 2026-10-24 提出，待讨论、未决定；PM 提议按职责边界、输出结构、证据用语、停止与升级条件及报告头试点，不做人设、不重复 Assignment Policy 的角色定义（来源：`~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-005/content/backlog-notes.md`（SHA-256 `bbf9c298e4b728a5123a74ba3119d5f82c3c8983d90aa3163bb0925bc9a81371`） B3；PM 回复已有试行约定，不代表全角色规范已决定）。
32. PR 中英结合风格：Human 2026-10-24 提出希望固定；拟议标题 `<type>(<scope>): English summary / 中文概要`，描述先一行英文 Summary 再中文正文，标识符 / SHA / 测试名与提交信息保持英文；落在哪份规则文档仍待 Human 决定，未采纳为仓库规则（来源：`~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-005/content/backlog-notes.md`（SHA-256 `bbf9c298e4b728a5123a74ba3119d5f82c3c8983d90aa3163bb0925bc9a81371`） B5）。
33. 测试环境与 CI 对齐（提议，待 Human 批准）：新增或修改界面测试的包，必须在 `.github/workflows/swift6-quality.yml` 与 `AGENTS.md` 本地 CI 门禁所用的模拟器机型与系统版本上运行；其它版本只作补充。
34. 提交身份写全（提议，待 Human 批准）：凡要求提交的包，写明作者与提交者 `Cowork 3P`（含邮箱）。
35. 门禁用语定义（提议，待 Human 批准）：推送 / 通过条件中区分“失败”“整组未运行或中断”“测试自行跳过（缺资源、仅真机）”；自行跳过不算未执行，但须列出。
36. 独立性条件写准（提议，待 Human 批准）：只排除被审对象的作者与实现者；之前的预检者或复核者可继续，须声明。
37. 修订包不整体继承旧条款（提议，待 Human 批准）：逐项写明哪些旧条款继续有效、哪些开工条件（旧 HEAD、旧哈希、旧报告名）不再适用。
38. 要原样写入仓库的说明文字（提议，待 Human 批准）：每个“每次 / 一定 / 只 / 指向哪次”类说法须沿代码的早退、拦截、丢弃路径核对，并配能区分该说法的测试；预检重点检查。
39. 一轮只解决一类问题、预算按实际估（提议，待 Human 批准）：修订项多时拆包，避免 PARTIAL 续做轮。
40. 报告路径防冲突（提议，待 Human 批准）：同一任务重复派发的预检 / 复核用带尝试序号的报告名，避免占用已有文件。
41. 返工度量（提议，待 Human 批准）：每个任务在外置目录记录轮次与返工原因分类（PM 文字 / 设计 / 环境 / 执行 / 外部），组合同步时汇总，用于判断 KOS 改动是否有效。

已采纳（2026-10-28）：KOS-DOC-UPDATE-001 把任务包首行与一句话最终消息、写入被拒即停、worktree 的 `.git` 写入白名单、包作者自审、冻结冲突时的修订规则、授权与派发消息格式六条写入 `AGENTS.md`「KOS 协作约定」，由 Human 2026-10-28 批准。它们与上面第 6、11、16、21、22、23、24 条相关；这些旧候选各自的状态本次不改。

已采纳（2026-10-28，Human 原话“全部批准”）：代码任务先设计并经独立 Architecture 只读复核、实现或原样写入仓库文字的包派发前经独立只读预检、复核发现分级处理三条，写入 `AGENTS.md`「KOS 协作约定」。

背景（事实，PM 整理）：B34-COMMIT-TRACE-001 从派发到合并（PR #256）执行轮 8 次、另有 2 个修订包被预检拦下未派发、独立复核 3 轮、发包前预检 3 次、发布 2 次；第 33–41 条由此整理（外置 `PORTFOLIO-SYNC-NEXT/kos-lessons-20261028.md` 第一节）。

第 27 条补充（2026-10-29）：PM 误用已存在的任务编号 POST-MERGE-CLEANUP-003，覆盖了 10-28 的包与授权回执，已逐字恢复（外置 `POST-MERGE-CLEANUP-003/README-recovery.md`）；PM 提议把第 27 条升级为规则：新建任务目录一律用“已存在即失败”的方式创建（提议，待 Human 批准）。
