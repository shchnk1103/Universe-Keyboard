# Assignment: PORTFOLIO-REFRESH-001 — 任务组合目录第一次刷新

Policy version: 1.0.0
record_id: PORTFOLIO-REFRESH-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active（docs-only，在本地执行；未 push） |
| Current phase | 定稿，待派发 Executor。把任务组合目录更新到 2026-10-22 的实际进展：修正 PF-004（已 accept 的 `PD001-ARCH-R2-F01`）、更新 PF-001 / PF-003、新增 UI-4 详情文档与相关条目、补决定记录、在 `docs/READING_MAPS.md` 的 “Enter With Zero Context” 加必读来源，并给已合并的 `portfolio-directory-001` 追加 Environment Executor 的 Policy 字段更正 |
| Material non-claims | 目录是优先级与指针索引，不是状态权威；不声称 UI-4 已立项、已授权或已有 Product Decision；不声称 Dynamic Task Portfolio 完整 MVP 已立项；不声称任何 UNKNOWN 行的真实状态；不改任何代码、测试、CI 或其它 Assignment 的状态；不 push / PR / merge |
| Human 确认状态 | 刷新立项与 `READING_MAPS.md` 入口：**已确认**（Human Product Owner，2026-10-22，Coordinator 会话：“先做目录刷新，在 READING_MAPS.md 中加上吧”）。UI-4 先于 UI-3、最高行高待模拟器实测、无完全访问时的行为待真机验证：**已确认**（同日同会话）。Environment Executor 填 `Not Applicable — repository documentation only`，以及对 `portfolio-directory-001` 追加同值的更正：**已确认**（Human Product Owner，2026-10-22，Coordinator 会话） |
| Next handoff / decision | 派发 Executor → Coordinator 冻结 Reviewer Lane Packet → Architecture / Quality Reviewer → Human 决定 push / PR / merge |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 于 2026-10-22 Asia/Shanghai 在 Coordinator 会话中：(1) 采纳目录更新规则（每个任务合并后顺带更新 + 问题触发的独立刷新，并把刷新作为键盘数值文档合并后的下一项）；(2) 指示先做目录刷新并在 `docs/READING_MAPS.md` 加入口；(3) 决定先只做 UI-4、UI-3 后做、最高行高待模拟器实测、无完全访问时的行为待真机验证；(4) accept `PD001-ARCH-R2-F01` 并同意在第一次刷新里修正。本文本由 Coordinator 编写。
- **Product Approver:** Human Product Owner（Product Lead）

## 内容来源与基线

基线 `origin/main` = `477c042e5c69d00eb6752ed52c58b0f441707c16`（PR #227 合并后；起草时 `Swift 6 Quality` run 39772862683 为 success）。Executor 开工时重新核验。冻结内容保存在 `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-001/content/`；Executor **逐字节复制**，发现事实错误时不要自行改，停止并报告。

| 目标 | 来源文件 | SHA-256 |
|---|---|---|
| `docs/PORTFOLIO.md`（替换） | `content/PORTFOLIO.md` | `c270e22810f2ae48963f0931cd9c55dc4380711ed153988edf830aba5ebf5355` |
| `docs/portfolio/kos-optimization.md`（替换） | `content/portfolio/kos-optimization.md` | `89f1c7105dcc939d431de46c737da72d634344eaba3242787b1f1a83cec872bd` |
| `docs/portfolio/ui-4-keyboard-height.md`（新增） | `content/portfolio/ui-4-keyboard-height.md` | `f485903eace612d9a82f55aeb82bd319376ea1b3e9ccbeaf9c6d282f8826e3bc` |
| `docs/assignments/portfolio-directory-001.md`（文末追加一节） | `content/policy-correction-portfolio-directory-001.md` | `6c0329cda8d05d682c6feddc862f38a9b4ef8cf259946ecfbcf435619f049ad0` |

`docs/portfolio/lifecycle-closeout.md` 本次不变。

## 内容修订记录

- **修订 1（2026-10-22，Coordinator）：** 第一轮 Executor（报告 `reports/executor-report-r1.md`，SHA-256 `8e541e64b2705c001e6bb6f1bfe4ab48ba6ee71182e4447e77287591d4614e26`）在复制前的事实核验里发现 1 项不一致并停止：`ui-4-keyboard-height.md` 的 “治理提示” 称该文件是 UI-4 “目前唯一的仓库内记录”，但基线 `docs/PORTFOLIO.md` 已有 PF-013 行、`keyboard-values-doc-001.md` 与 `docs/KEYBOARD_VALUES.md` 也提到 UI-4。这是 Coordinator 的疏漏，已改为如实列出现有的仓库内提及。同时按 Human 当日对 UI-4 的回答补充了决定（调节页不可按动的硬要求、接受宿主限高与横屏需要上限规则、连续步进、模拟器加 iPhone 13 Pro 验证）、一段对另一款 iOS 第三方键盘调节界面的截图描述（仓库外、仅一张图），以及两条新的待决问题。受影响内容与摘要：`docs/PORTFOLIO.md`（PF-013 一行与一条决定记录）旧 `7ce5b0fdd22176f2248feb4a231381f42a7642d005533fef339d240570ba0821` 新 `9ddb7742c7ccc674319e204b442f90aab7810d721951a0964f1e86dff6b3ac54`；`docs/portfolio/ui-4-keyboard-height.md` 旧 `1ac21c8f08ba56c1a6f908cb860068a63babf6e958d5d2987d25b13a775e1f7a` 新 `8203c7c7dc709f61aef59ab01f1fd0aa6abdc2d8ce8a6ed73f6083ef49948cec`。`kos-optimization.md` 与更正节内容不变。第一轮没有产生提交。

- **修订 2（2026-10-22，Coordinator）：** 第二轮 Executor（报告 `reports/executor-report-r2.md`，SHA-256 `0e347ce96cc661c1257a67cb1533d18fb57434ac534e7ebf7f90bd2af73e79e2`）再次在复制前停止：`ui-4-keyboard-height.md` 的“验证方式”已写明可用真机为一台 iPhone 13 Pro，文末“治理提示”却仍写“哪些设备与系统版本可用，待 Human 提供”，同一信息两处状态不一致。这是 Coordinator 在加入新决定时没有同步旧句的疏漏，已统一。同时按 Human 当日补充的截图加入：容器 App 里“键盘高度调节”入口卡片的形态、调节页的形态与范围的粗略观察、拖动过程中外框滞后的现象、一条待决问题（何时向宿主请求新高度），以及 Human 的质量线（第一版功能可用即可、不追求拖动流畅度）；`PORTFOLIO.md` 里对应的决定记录同步。受影响内容与摘要：`docs/PORTFOLIO.md` 旧 `9ddb7742c7ccc674319e204b442f90aab7810d721951a0964f1e86dff6b3ac54` 新 `c270e22810f2ae48963f0931cd9c55dc4380711ed153988edf830aba5ebf5355`；`docs/portfolio/ui-4-keyboard-height.md` 旧 `8203c7c7dc709f61aef59ab01f1fd0aa6abdc2d8ce8a6ed73f6083ef49948cec` 新 `f485903eace612d9a82f55aeb82bd319376ea1b3e9ccbeaf9c6d282f8826e3bc`。修订 1 里记录的摘要是当时的真实值，不改。前两轮都没有产生提交。

## Boundary

- **Scope（docs-only）:**
  1. 按上表替换 / 新增 / 追加。
  2. `docs/READING_MAPS.md`：只改 “Enter With Zero Context” 小节的第 2 项那一行，由 `2. \`KNOWLEDGE_INDEX.md\` — top-level navigation.` 改为（逐字）：`2. `KNOWLEDGE_INDEX.md` — top-level navigation; then `PORTFOLIO.md` — unfinished-task and priority index (not a status authority): read it and verify the rows you rely on before starting.`。先 `grep -n` 核实原行存在且唯一；其余字节不动，因此该文件恰为 1 行删除 1 行新增。
  3. 本 Assignment 记录文件 `docs/assignments/portfolio-refresh-001.md` 及其 Exit evidence / “Closeout Decision — 结果”。
  4. 链接检查与行尾空白检查。
  5. `CHANGELOG.md`、`docs/ACTIVE_WORK.md`、`docs/ENGINEERING_DASHBOARD.md`、`docs/TECH_DEBT.md`、`docs/KNOWLEDGE_INDEX.md`、`docs/KEYBOARD_VALUES.md`、`docs/UI_STYLE_GUIDE.md`、`docs/KEYBOARD_LAYOUT.md`、`docs/PROJECT_CONTEXT.md`、`docs/authorizations/**`、全部代码与测试：逐项检查并写“不适用及依据”，**不修改**。
- **Non-goals:** 起草 UI-4 的 Product Decision 或 Assignment；启动 Spike；改任何代码、测试、CI、脚本或数值；改写已合并的 Assignment 的既有内容（`portfolio-directory-001.md` 只追加一节）；核实或补全任何 UNKNOWN 行；新增核对脚本；push / PR / merge。
- **Required Inputs:** `AGENTS.md`；Knowledge Index；Assignment Policy（Required Assignment Fields）；`DOCUMENTATION_GOVERNANCE.md`；`docs/PORTFOLIO.md`、`docs/portfolio/**`（基线版本）；`docs/READING_MAPS.md`；`docs/assignments/portfolio-directory-001.md`、`keyboard-values-doc-001.md`；`docs/KEYBOARD_VALUES.md`；上表冻结内容；Human 提供的 ChatGPT 讨论整理仅以 `ui-4-keyboard-height.md` 里的摘要形式进入仓库，原文件不入库。

## Reviewer claim register

| ID | 声称 |
|---|---|
| R1 | 四份内容与冻结来源逐字节一致（`git hash-object` 对比）；`READING_MAPS.md` 恰为 1 行删除 1 行新增且新行与指定文字一致；`portfolio-directory-001.md` 只在文末追加，旧内容是新内容的字节前缀 |
| R2 | 事实陈述与仓库一致，或明确标 UNKNOWN：PR #226、#227 及其合并提交；`Swift 6 Quality` 三个 run 编号与提交；Assignment 的 Lifecycle（`portfolio-directory-001`、`keyboard-values-doc-001`）；`ACTIVE_WORK` 第 11、3、6 项；`docs/KEYBOARD_VALUES.md` 在 main 上；`ui-4-keyboard-height.md` 里引用的仓库事实（`keyHeight`、优先级、设置读取时机、完全访问原语、TD-020 等）可在 `docs/KEYBOARD_VALUES.md` 或源码里找到 |
| R3 | 对整张表重新审计：凡状态不是 UNKNOWN 的行，“来源”列都指向仓库内可核对的材料（满足目录规则 3）；`PF-004` 的自指问题已修；`PF-012`、`PF-013`、`PF-022` 的来源成立 |
| R4 | `ui-4-keyboard-height.md` 忠实：把 “Human 已决定”“来源 1 的历史需求基线（未核验）”“与本地记录的差异”“盘点事实”“待决问题” 分开；没有把基线写成已冻结合同；没有声称授权、Product Decision 或 Spike 已开始；没有引入内容里没有的数值；与 `docs/KEYBOARD_VALUES.md` 不冲突 |
| R5 | 没有越权：目录仍是索引非权威；UI-4 / UI-3 / 完整 MVP 的描述不超出 Human 的决定；更正节只补 Environment Executor，不改 `portfolio-directory-001` 的结论 |
| R6 | 链接检查与 `git diff --check` 通过；新增文档没有会被检查器误解析的字面链接示例 |
| R7 | 本 Assignment 含 Policy 要求的全部 19 个必填字段（逐项映射），包括 Environment Executor 与 Human 的确认状态 |
| R8 | diff 只含 Scope 内文件；删除行归属逐项核对（`PORTFOLIO.md` 与 `kos-optimization.md` 的被修改行、`READING_MAPS.md` 的 1 行）；Executor 报告与仓库事实一致，UNKNOWN 未被偷偷填充，报告开头有运行时身份 |

Executor 自述的模型与 effort 不作为验收项，只登记为残项。

## Closeout Decision

Human Product Owner 于 2026-10-22 批准立项；Reviewer 评审后由 Human 决定是否 push 与合并。本 Assignment 依 D7（同步 / 记录类）在评审后直接 Close，**Close 在进入 `main` 时生效**。评审完成后在本节追加最终结果（追加式）。

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward
- **Executor:** Executor 角色（AI 不限）；建议模型 `claude-sonnet-5-5`、effort medium；实际配置：Codex / GPT-6；具体变体、effort、会话标识未确认
- **Environment Executor:** `Not Applicable — repository documentation only`（Human 已于 2026-10-22 确认，见 “Human 确认状态”）
- **Human Dependency:** Human Product Owner（任何 push / PR / merge）
- **Architecture Reviewer:** 独立 Reviewer 会话（AI 不限）；独立性条件：未参与本批次实现，且不是 Quality Reviewer 的同一会话；报告开头声明运行时身份、加载的记忆与独立性级别；lane `PR001-ARCH`
- **Quality Reviewer:** 同上；lane `PR001-QUAL`

## Reports

Executor 与 Reviewer 的最终报告、指令、packet 均保存为文件，根目录 `~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-001/`（`instructions/`、`packets/`、`reports/`、`content/`）。仓库内只记录路径与 SHA-256。Reviewer 报告须增量落盘（首行状态行），派发前须放行 `reports/` 目录写权限，且不得在 `/tmp` 或 `$TMPDIR` 创建文件。**Executor 与 Reviewer 的最终对话消息要短，不复述报告。**

## Gates

- **Entry:** Human 批准派发（Environment Executor 值已确认）；独立 worktree 与新分支 `docs/portfolio-refresh-001`；Human 本地 main 的 dirty 文件不得触碰。
- **Reviewer 前置:** Executor 提交后，Coordinator 冻结 Reviewer Lane Packet 并做路径扫描；packet 的允许集必须覆盖被评审文档引用的全部仓库文件。
- **Exit:** 冻结内容已逐字节落地；事实核验已记录；`READING_MAPS.md` 单行修改；更正节已追加；链接检查已记录；本地提交；报告文件已保存。
- **Stop:** 基线移动且与 Scope 重叠；冻结内容出现事实不一致（**一次性列全再停**）；需要改 Scope 之外文件；被要求处理 CI；任何 push / merge。
- **Handoff Target:** Human Product Owner。**Revalidation:** Scope / Owner / Reviewer 变化、基线漂移、冻结内容变更。

## Exit evidence

| 项 | Result |
|---|---|
| 开工前事实核验清单与结果（PR、run、Lifecycle、ACTIVE_WORK 行） | Executor-recorded：r1/r2 事实证据复用；r3 内部一致性通过，前两轮问题已修正。 |
| 四份内容逐字节落地（blob 与来源对比） | 三份完整 blob 及追加节与来源一致，最终提交核对见报告。 |
| `docs/READING_MAPS.md` 单行修改（前后对照） | 仅第 54 行替换；精确前后对照见报告。 |
| `portfolio-directory-001.md` 追加节（前缀检查） | 旧内容末尾有换行，旧字节为新文件前缀；追加部分等于冻结更正节。 |
| 其余镜像（CHANGELOG、ACTIVE_WORK、TECH_DEBT、KNOWLEDGE_INDEX、KEYBOARD_VALUES、UI_STYLE_GUIDE、KEYBOARD_LAYOUT、PROJECT_CONTEXT、authorizations、代码与测试） | 不适用，逐项未改：CHANGELOG 不记录未评审交付；ACTIVE_WORK / ENGINEERING_DASHBOARD 无状态变更；TECH_DEBT 无债务处置；KNOWLEDGE_INDEX 已有入口；KEYBOARD_VALUES / UI_STYLE_GUIDE / KEYBOARD_LAYOUT / PROJECT_CONTEXT 无产品或数值变化；authorizations 无权限变更；代码与测试无行为变化。 |
| Markdown link check（baseline / 最终提交） | 最终提交后按指定 baseline/head 执行；结果与最终 SHA 见报告，避免自身提交 SHA 循环引用。 |
| Executor 报告路径与 SHA-256 | ~/.kos-work/Universe-Keyboard/PORTFOLIO-REFRESH-001/reports/executor-report-r3.md；最终 SHA-256 由对话交付，避免循环引用。 |

## Closeout Decision — 结果

2026-10-22，Executor：本地 docs-only 交付，冻结内容逐字节落地，READING_MAPS 仅改一行；旧 Assignment 只追加。最终检查、提交身份和报告摘要见 Executor 报告及对话交付。未 push / PR / merge，未补全 UNKNOWN；独立评审尚未执行，Lifecycle 保持 Active，等待 Coordinator 冻结 Reviewer packet，Close 仍须原 Gate 满足并进入 main 后生效。
