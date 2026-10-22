# Assignment: PORTFOLIO-DIRECTORY-001 — 建立任务组合目录（docs/PORTFOLIO.md 与 docs/portfolio/）

Policy version: 1.0.0
record_id: PORTFOLIO-DIRECTORY-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active（docs-only，在本地执行；未 push） |
| Current phase | 定稿，待派发 Executor。把 Coordinator 起草的任务组合目录（优先级与指针索引）作为仓库文档提交，使任何 AI 接手时不依赖对话记忆。这是 KOS Dynamic Task Portfolio（Portfolio MVP）的种子版，不是其完整设计或实现 |
| Material non-claims | 不声称 Dynamic Task Portfolio 已完成或其设计已评审通过；目录是**优先级与指针索引，不是状态权威**，不替代 Assignment、Authorization、Product 决定、`docs/TECH_DEBT.md` 或 `docs/ACTIVE_WORK.md`；不声称任何 `UNKNOWN` 行的真实状态；不关闭、削弱任何残项；不改 `docs/ACTIVE_WORK.md`；不 push / PR / merge |
| Human 确认状态 | 立项与路径：**已确认**（Human Product Owner，2026-10-22，Coordinator 会话）：提案放在 `docs/PORTFOLIO.md` 和 `docs/portfolio/` 下 |
| Next handoff / decision | 派发 Executor → Coordinator 冻结 Reviewer Lane Packet → Architecture / Quality Reviewer → Human 决定 push / PR / merge |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 于 2026-10-22 Asia/Shanghai 在 Coordinator 会话中提出需求（把待办按优先级整理成可持续保存的目录，用 ACTIVE_WORK 式的表，不设数量上限，文档不要大，复杂任务单独成文、只引用地址），并批准立项与路径。本文本由 Coordinator 编写。
- **Product Approver:** Human Product Owner（Product Lead）

## 内容来源与基线

基线 `origin/main` = `e828a9969f6d41414d8bb991da9f7202fe056636`（PR #224 合并后）。待提交的三份文件由 Coordinator 起草并冻结，保存在 `~/.kos-work/Universe-Keyboard/PORTFOLIO-DIRECTORY-001/content/`：

| 目标路径 | 来源文件 | SHA-256 |
|---|---|---|
| `docs/PORTFOLIO.md` | `content/PORTFOLIO.md` | `b2a59bf6eea1fba5dad87e5fd53f61eaf1ff38458285d68270f750fd43928842` |
| `docs/portfolio/lifecycle-closeout.md` | `content/portfolio/lifecycle-closeout.md` | `6c5c111ad575ee2e05d92750d63be521c9b3b54de6206f4ea63aab509de7d04c` |
| `docs/portfolio/kos-optimization.md` | `content/portfolio/kos-optimization.md` | `7b384ae65d9a90c141381db2e985fe67a2f019e8517b6e2a5f80749031e383c6` |

Executor **逐字节复制**这三份文件，不润色、不增删。发现内容有事实错误或链接问题时，**不要自行改**：停止并报告，由 Coordinator 修改内容并更新摘要。内容中的状态是 2026-10-22 的快照（例如 PF-003 的批次 1c 状态可能在合并时已过期）；这是已声明的“核对日期”，不算错误，Executor 在报告里记录当时 `main` 上批次 1c 的实际状态即可。

## 内容修订记录

- **修订 1（2026-10-22，Coordinator）：** Executor 第一轮（报告 `reports/executor-report-r1.md`，SHA-256 `d8d018642689eb6b90ec27528d35dadb5f566873d4e3805e1b59e9e0c91a4fa5`）按 Stop 条件停止，发现 `PORTFOLIO.md` 的 PF-018 写“共 16 条候选”而详情文档实际编号 1 至 17。Coordinator 修订 `content/PORTFOLIO.md`（旧摘要 `99aa31a931740fe6f4360a0881d8f78ce0c0424eb3072c7bb93ae8b3d28cb7cf`，新摘要 `b2a59bf6eea1fba5dad87e5fd53f61eaf1ff38458285d68270f750fd43928842`）：PF-018 改为“共 17 条候选（第 17 条即本目录）”；同时发现 PF-002 把 PR #222 误作 UI-2 同步（#222 实为过期事实同步），改为只列 PR #221 为 UI-1 同步，UI-2 同步范围写 UNKNOWN。两份详情文档未变。本 Assignment 随之更新上表摘要；Executor 第一轮没有创建分支或提交，无需回退。

- **修订 2（2026-10-22，Coordinator）：** Executor 第二轮（报告 `reports/executor-report-r2.md`，SHA-256 `88d2993ae10be078c37e6ff6ba899f535f9fb8003c6535f14091dbef3ce71f4e`）再次按 Stop 条件停止：内容写“UI-1 仅到 Completed”，而 `main` 上 UI-1 Assignment 的 Lifecycle 为 Active，其 2026-10-21 PR216 post-merge sync 明确写无完成 / 验收 / 独立复核声称、Lifecycle 处置待 Human 另行决定。该错误来自 Coordinator 把“拟推进到 Completed”的设想写成了现状。Coordinator 修订 `content/PORTFOLIO.md`（PF-005、PF-006；旧摘要 `b578d271db86e15da4ec2560d75343f62f0f0c8473aee9d975d78fff0521db3d`，新摘要 `b2a59bf6eea1fba5dad87e5fd53f61eaf1ff38458285d68270f750fd43928842`）与 `content/portfolio/lifecycle-closeout.md`（B 区；旧摘要 `75c6aa5666e36598e423a5fa5b14825be5b3901fdfbb3e0bccf70f1075ed1046`，新摘要 `6c5c111ad575ee2e05d92750d63be521c9b3b54de6206f4ea63aab509de7d04c`）：改为如实陈述 Active，并把“只推进到 Completed”标为未经 Human 决定、未执行的设想。`kos-optimization.md` 未变。Executor 第二轮同样没有创建分支或提交。

## Boundary

- **Scope（docs-only）:**
  1. 新增 `docs/PORTFOLIO.md`、`docs/portfolio/lifecycle-closeout.md`、`docs/portfolio/kos-optimization.md`（逐字节来自上表）。
  2. `docs/KNOWLEDGE_INDEX.md`：只在“工作入口”小节（现第 18 到 20 行附近）已有的 `任务路径 · 当前工作 · Assignment 目录` 那一行**末尾**追加 `· [任务组合](PORTFOLIO.md)`，其余字节不动。
  3. 本 Assignment 记录文件 `docs/assignments/portfolio-directory-001.md` 及其 Exit evidence / “Closeout Decision — 结果”。
  4. 链接检查与行尾空白检查。
  5. `CHANGELOG.md`、`docs/ACTIVE_WORK.md`、`docs/ENGINEERING_DASHBOARD.md`、`docs/TECH_DEBT.md`、`docs/READING_MAPS.md`、`AGENTS.md`、`docs/authorizations/**`：逐项检查并写“不适用及依据”，**不修改**。
- **Non-goals:**
  - 实现任何自动化、脚本、校验器或 CI 规则；设计 Portfolio 的完整数据模型或机器可读 schema；修改 `.kos/project.json`；核实、改写或补全任何 `UNKNOWN` 行；为本目录新增 ACTIVE_WORK 行；改动产品代码、测试、CI、Xcode 工程、任何 Assignment 或 AUTH 文件；push / PR / merge。
- **Required Inputs:** `AGENTS.md`；Knowledge Index；Assignment Policy；`AI_WORKFLOW.md`；`kos-2.1-operational-maturity.md` 的 M-02；`docs/ACTIVE_WORK.md` 开头说明（用于核对本目录与它的分工叙述一致）；上表三份来源文件。

## Reviewer claim register

| ID | 声称 |
|---|---|
| P1 | 三份文档与 Assignment 中登记的来源文件逐字节一致（SHA-256 匹配）；`docs/KNOWLEDGE_INDEX.md` 只在指定一行末尾追加了一个链接，其余字节不变 |
| P2 | 文档中的相对链接全部可解析；`docs/PORTFOLIO.md` 对 `portfolio/*.md` 的链接正确 |
| P3 | 文档中的事实性陈述与仓库一致，或明确标 `UNKNOWN`：PR 编号 #210、#221、#222、#223、#224；批次 1、1b 的关闭项与合并提交；`ACTIVE_WORK` 第 11、3、6 项所述；TD-020、TD-014、F-04 tech_debt 的描述；`docs/plans/keyboard-height-and-candidate-size-discussion-2026-10-08.md` 在 `main` 上不存在，文档已如实标注 |
| P4 | 没有越权：目录自称“优先级与指针索引、不是状态权威”，且与 `ACTIVE_WORK`、Assignment Policy、TECH_DEBT 的权威关系叙述不冲突；没有把 `UNKNOWN` 行写成已知；没有声称 Dynamic Task Portfolio 已完成 |
| P5 | 目录规则自洽可执行：状态词、30 天过期、Done 移到文末、决定记录、接手须知；没有与 `ACTIVE_WORK.md` 的现有规则冲突（需核对 ACTIVE_WORK 的开头说明和 `docs/AI_WORKFLOW.md` 的 State sync 清单） |
| P6 | 引用的本地路径（`~/.kos-work/...`）只作为非仓库的补充说明，没有让任何仓库内结论依赖它们 |
| P7 | 与批次 1c 的潜在冲突已识别：本批次不改 `docs/ACTIVE_WORK.md`；`docs/KNOWLEDGE_INDEX.md` 若与 1c 的改动重叠，Executor 已按 `git merge-tree` 报告 |
| P8 | diff 只含 Scope 内文件；`docs/KNOWLEDGE_INDEX.md` 恰有 1 行删除 1 行新增（同一行追加）；删除行归属逐项核对 |
| P9 | 最终提交的链接检查与 `git diff --check` 通过 |
| P10 | Executor 报告与仓库事实一致，UNKNOWN 清单未被偷偷填充；报告开头有运行时身份声明 |

Executor 自述的模型与 effort 不作为验收标准，只登记为残项。

## Closeout Decision

本节是本批次的“所属 Gate 关闭”记录。Human Product Owner 于 2026-10-22 批准立项与路径；Reviewer 评审后由 Human 决定是否 push 与合并。本 Assignment 依 D7（同步 / 记录类）在评审后直接 Close，**Close 在进入 `main` 时生效**。评审完成后在本节追加最终结果（追加式）。

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward
- **Executor:** Executor 角色（AI 不限）；建议模型 `claude-sonnet-5-5`、effort medium；实际配置：Codex / GPT-6（具体变体未确认）；effort、会话标识未确认
- **Human Dependency:** Human Product Owner（任何 push / PR / merge）
- **Architecture Reviewer:** 独立 Reviewer 会话（AI 不限）；独立性条件：未参与本批次实现，且不是 Quality Reviewer 的同一会话；lane `PD001-ARCH`；实际 AI、模型与会话标识由 Reviewer 在报告开头声明；指名与派发由 Human 确认
- **Quality Reviewer:** 独立 Reviewer 会话（AI 不限）；独立性条件同上；lane `PD001-QUAL`

## Reports

Executor 与 Reviewer 的最终报告、指令、packet 均保存为文件，根目录 `~/.kos-work/Universe-Keyboard/PORTFOLIO-DIRECTORY-001/`（`instructions/`、`packets/`、`reports/`、`content/`）。仓库内只记录路径与 SHA-256。Reviewer 报告须增量落盘（首行状态行），派发前须放行 `reports/` 目录写权限。

## Gates

- **Entry:** Human 批准派发；基线为派发时 `origin/main`（起草时 `e828a99`），Executor 重新核验；独立 worktree 与新分支 `docs/portfolio-directory-001`；Human 本地 main 的 dirty 文件不得触碰。
- **Reviewer 前置:** Executor 提交后、派发 Reviewer 之前，由 Coordinator 冻结 Reviewer Lane Packet，并机械扫描 Executor 报告与本 Assignment 引用的每个路径是否都在允许集内。
- **Exit:** 三份文件摘要匹配；索引行已追加；镜像已处理；链接检查已记录；本地提交；报告文件已保存。
- **Stop:** 基线移动且与 `docs/KNOWLEDGE_INDEX.md` 重叠；内容摘要不符；需要改 Scope 之外文件；发现内容事实错误；被要求处理 CI；任何 push / merge。
- **Handoff Target:** Human Product Owner。**Revalidation:** Scope / Owner / Reviewer 变化、基线漂移、内容变更。

## Exit evidence

| 项 | Result |
|---|---|
| 三份文件摘要匹配（来源 vs 提交内 blob） | Executor-recorded：三份来源与工作树逐字节一致；最终提交 blob 核对见报告。 |
| `docs/KNOWLEDGE_INDEX.md` 追加行（前后对照） | 原行 `- [任务路径](READING_MAPS.md) · [当前工作](ACTIVE_WORK.md) · [Assignment 目录](assignments/)`；仅末尾追加 ` · [任务组合](PORTFOLIO.md)`，其余字节不动。 |
| `docs/ACTIVE_WORK.md`、`CHANGELOG.md`、`docs/TECH_DEBT.md`、`docs/ENGINEERING_DASHBOARD.md`、`docs/READING_MAPS.md`、`AGENTS.md` | 不适用，全部未改：本任务只增加目录导航，不发生 Product Gate、ADR Accept、Assignment Close 或 merge；不改变现有工作项、产品、技术债或权限。`docs/authorizations/**` 同样只检查，未修改。 |
| 批次 1c 在 `main` 上的实际状态（供 PF-003 过期核对） | 未合并；指定 main 树无 batch-1c Assignment；其本地分支 tip 不为 origin/main 祖先，来源 git ls-tree / git merge-base --is-ancestor。PF-003 是已声明日期快照。 |
| Markdown link check（baseline/最终提交） | 最终内容提交后执行，精确 baseline / HEAD 与命令结果登记于 Executor 报告；本 Assignment 无后续改动。 |
| Executor 报告路径与 SHA-256 | `~/.kos-work/Universe-Keyboard/PORTFOLIO-DIRECTORY-001/reports/executor-report-r3.md`；最终 SHA-256 在 Executor 对话交付，避免报告自身摘要、最终提交 SHA 之间的循环引用。 |

## Closeout Decision — 结果

2026-10-22，Executor：本地 docs-only 交付；三份冻结文档逐字节复制，仅追加 Knowledge Index 指定入口。事实核验无新增确定性不一致，UNKNOWN 未补全；前两轮 finding 已修复。独立 Architecture / Quality 尚未执行，等待 Coordinator 冻结 Reviewer packet。Assignment 保持 Active；本轮不作 Human Close / push / PR / merge 决定。最终本地提交身份、检查结果、文件级 numstat、blob 与摘要证据见 Executor 报告。
