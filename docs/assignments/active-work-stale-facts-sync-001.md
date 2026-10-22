# Assignment: ACTIVE-WORK-STALE-FACTS-SYNC-001 — Stale post-merge facts sync (input reliability, TYPO-002 runtime integration, T9 CI mirror)

Policy version: 1.0.0
record_id: ACTIVE-WORK-STALE-FACTS-SYNC-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active（docs-only 同步在本地执行；未 push） |
| Current phase | 三个工作包的镜像已在基于 `origin/main` 的本地分支同步；交接 Reviewer / Human |
| Material non-claims | 不改任何 Assignment 的 Lifecycle 值；不关闭、削弱任何残项；不声称 Release / Release-ready；不声称任何工作项完成、验收或通过独立复核；不对 CI 根因或稳定性作结论；不 push / PR / merge |
| Next handoff / decision | Coordinator 冻结 Reviewer Lane Packet → Architecture / Quality Reviewer → Human 决定 push / PR |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 在 Claude 项目经理会话中批准派发，2026-10-21 Asia/Shanghai；确切时间未记录。本文本由 Coordinator 编写。
- **Product Approver:** Human Product Owner（Product Lead）

## M-02 trigger identities（迟到的同步）

以下事件各自独立发生，本 Assignment 以一次同步事务统一记录；它们的同步迟于事件本身，不得写成当时已同步。

| Work Item | Event | Merge commit | Merged |
|---|---|---|---|
| `INPUT-RELIABILITY-DELIVERY-001` | PR #213 | `bb430f914deaf7b19a61183f744b5dcf2fdb8eae` | `2026-10-19T12:27:34Z`，merger `shchnk1103`（`gh pr view 213`） |
| `INPUT-RELIABILITY-DELIVERY-002` | PR #214 | `d08175b915aee40998398d7fdc03f2fd7cf0833f` | `2026-10-19T13:55:48Z`，merger `shchnk1103`（`gh pr view 214`）；与 002 的对应关系是推断，依据见 [002 同步节](input-reliability-delivery-002.md#pr-214-post-merge-state-sync--2026-10-21) |
| `INPUT-RELIABILITY-DELIVERY-003` | PR #215 | `096183ca118cc40ffc16854d1a5336a42cfcbd89` | `2026-10-19T23:30:33Z`（`2026-10-20 07:30:33 Asia/Shanghai`），merger `shchnk1103`（`gh pr view 215`） |
| TYPO-CORRECTION-002 runtime integration 子任务链 | PR #144 | `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` | `2026-09-22T10:19:31Z`，merger `shchnk1103`（`gh pr view 144`；181 个文件） |

另：PR #218（`7af3f0269caa6e41d522b48fcd253f57c9aedeaf`）与 PR #220（`de98a1ef50635bd0e091aadd28aca641671be1c9`）是 WP3 的来源事实，不是新的 M-02 触发。
Final Merge Gate / Authority record 指针：PR #213、#214、#215、#144 均为 **UNKNOWN** — 仓库内检索（`git grep "Final Merge Gate"` 仅命中 T9 相关记录；各 Assignment、`docs/tasks/` 日志与 `docs/evidence/` 中均无这四个合并事件的 Merge Gate 或 Merge 授权记录）。
本次不对同一事件递归触发 M-02。

## Boundary

- **Scope（docs-only）:**
  - **WP1 输入可靠性：** `docs/assignments/input-reliability-delivery-001.md`、`-002.md`、`-003.md` 各加 S-03 取代说明与带日期的同步节；`docs/ACTIVE_WORK.md` 第 6 行及顶部 2026-10-19 的 delivery-003 当前更新。delivery-002 与 #214 的对应关系须写出依据（基线链），仅凭范围相似的写成“推断”并标明。
  - **WP2 TYPO-CORRECTION-002 运行时集成：** `docs/ACTIVE_WORK.md` 第 7、8、9、10 行；`typo-correction-002-runtime-integration-implementation-001.md`、`-hardening-001.md`、`-hardening-blocker-remediation-001.md`、`typo-correction-002-int003-query-cost-measurement-001.md` 各加 S-03 取代说明。第 8 行须标为被第 9 行的 remediation 取代并保留残项指针；第 9 行与“PR #144 已合并、但 Assignment 仍写未提交”的矛盾要消除；第 7 行 PR #144 是否包含该快照，须用 Assignment 证据与 PR #144 文件列表核对，核对不出写 `UNKNOWN`；第 10 行正文状态表已过期，须在其 Current Status 加取代说明，指向该文件顶部已有的 2026-10-11 收敛说明。
  - **WP3 T9 CI 镜像：** `docs/ACTIVE_WORK.md` 第 3 行与顶部 2026-10-21 的 T9 当前更新；`docs/ENGINEERING_DASHBOARD.md` 中引用 CI run `39598364040` 的一处。只对齐到 `docs/assignments/keyboard-t9-adaptive-row-001.md` 现状：#218 测试缓解、main 其后通过一次（run `39606780704`）、残项 `tech_debt:TD-020`、根因 UNKNOWN、无稳定性声明。不改 T9 Assignment 本身，不改 `keyboard-t9-adaptive-row-001-state-sync-001.md` 这份历史记录。
  - 其余 M-02 镜像逐项检查并记录“已更新”或“不适用及依据”：`docs/ENGINEERING_DASHBOARD.md`、`docs/KNOWLEDGE_INDEX.md`、`CHANGELOG.md`、`docs/TECH_DEBT.md`。
  - 链接检查：最后一次内容编辑后，用 baseline 与最终提交各记录一对。
  - 本 Assignment 记录文件本身。
  - **经 Human Product Owner 于 2026-10-22 批准的修正轮 1 增加：** `docs/KNOWLEDGE_INDEX.md`（INT-003 query-cost 条目，第 48 行）；`docs/plans/typo-correction-002-int003-query-cost-measurement-001.md`（Status 段落之后追加取代说明）。
- **Non-goals:**
  - 任何 Lifecycle 值的修改；关闭、取代或合并任何 Assignment；`ACTIVE_WORK.md` 表的成员、顺序、行数（保持 11 行）；历史“当前更新”快照的重写（只加新的带日期条目）；ACTIVE_WORK 的归档或重构。
  - 第 1、2、4、5 行；`input-reliability-delivery-001/002` 加入 ACTIVE_WORK 表；TYPO-002 的其它子项（含表外的 Active 子项）。
  - 产品、测试、workflow、CI、Xcode 工程改动；诊断或重跑 CI；`TECH_DEBT.md` 的任何改动；修改 `.kos/project.json`；伪造 Task Workspace 载体日志；push / PR / merge。
- **Required Inputs:** `AGENTS.md`；Knowledge Index；Assignment Policy；`kos-2.1-operational-maturity.md` 的 M-02 / S-03；`AI_WORKFLOW.md`；上列 Scope 全部文件；各 PR 的只读 `gh pr view`；`docs/evidence/input-reliability-delivery-003/verification.md`。

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward
- **Executor:** Claude Executor 会话，目标 `claude-sonnet-5-5`，目标 effort medium。实际配置：模型为 `claude-sonnet-5-5`（会话系统信息）；effort 未确认——harness 仅暴露数值 `reasoning_effort` 5，无法确认其等于 medium，**不声称已应用 medium**。
- **Environment Executor:** 同一会话，本地
- **Human Dependency:** Human Product Owner（任何 push / PR / merge）
- **Architecture Reviewer:** codex，全新的独立会话；未参与本次同步实现；由 Human Product Owner 于 2026-10-21 Asia/Shanghai 在 Coordinator 会话中指定；lane ID `AWSF001-ARCH`，会话标识由 Reviewer Lane Packet 记录。
- **Quality Reviewer:** codex，全新的独立会话；独立性要求同上，且不得与 Architecture Reviewer 是同一会话；由 Human Product Owner 于 2026-10-21 Asia/Shanghai 在 Coordinator 会话中指定；lane ID `AWSF001-QUAL`，会话标识由 Reviewer Lane Packet 记录。

## Reviewer claim register

Reviewer packet 的待决问题直接取自本节。每条声称都已核对：证据可读、所需操作被 packet 允许。

| ID | 声称 |
|---|---|
| C1 | `ACTIVE_WORK` 第 6 行与顶部 delivery-003 更新反映 PR #215 已合并，保持 Active，无 Closeout 声称，`verification.md` 的残项指针保留 |
| C2 | delivery-001/002/003 三份 Assignment 有 S-03 取代说明与带日期的同步节，历史文字未改，002↔#214 的对应有出处或标为推断 |
| C3 | 第 7–10 行与证据一致；第 8 行被第 9 行的 remediation 取代；第 7 行 #144 包含关系有证据或写 `UNKNOWN`；第 9 行的“已合并 vs 未提交”矛盾已消除 |
| C4 | `ACTIVE_WORK` 第 3 行与顶部更新、Dashboard 一处与 T9 Assignment 现状一致，无稳定性或根因声称，T9 Assignment 与其 state-sync 记录未被改 |
| C5 | diff 只含 Scope 内文件；没有任何 Lifecycle 值被改；`ACTIVE_WORK` 表仍是 11 行且成员与顺序不变；历史快照未被重写 |
| C6 | Dashboard、Knowledge Index、CHANGELOG、TECH_DEBT 各自“已更新”或“不适用并有依据” |
| C7 | 最终提交对 baseline 的链接检查通过 |
| C8 | 无越权声明：Release、完成、验收、独立复核、残项关闭、CI 稳定或根因 |

Executor 自述的模型与 effort 不作为验收标准，只登记为残项。

## Reports

Executor 与 Reviewer 的最终报告均保存为文件：
`~/.kos-work/Universe-Keyboard/ACTIVE-WORK-STALE-FACTS-SYNC-001/reports/`，文件名为 `executor-report-r1.md`、`architecture-review-r<N>.md`、`quality-review-r<N>.md`。仓库内只记录路径与 SHA-256，不复制全文。

## Gates

- **Entry:** Human 批准派发；Reviewer 已指名；基线为派发时 `origin/main`（起草时 `9f7a88a`），Executor 重新核验；基于它的隔离 worktree 与新分支；Human 本地 main 的 dirty 文件不得触碰。
- **Reviewer 前置:** Executor 提交后、派发 Reviewer 之前，由 Coordinator 冻结 Reviewer Lane Packet，并确认每条 claim 所需的文件与操作都在允许集内。
- **Exit:** Scope 内每个镜像已更新或写明不适用；无过期的合并前文字可被读成当前事实；链接检查已记录；本地提交；报告文件已保存；交接。
- **Stop:** 基线移动且影响 Scope；关键事实无来源；需要改动 Scope 之外的文件或任何 Lifecycle；被要求处理 CI；任何 push / merge。
- **Handoff Target:** Human Product Owner。**Revalidation:** Scope / Owner / Reviewer 变化、基线漂移、授权撤回。

## Exit evidence

Entry 核验：`git fetch origin` 后 `origin/main` = `9f7a88a1b1c31106c26555bed4a7e324f6ed7b5d`，与派发时一致，未移动；分支 `docs/active-work-stale-facts-sync-001` 由它新建，位于隔离 worktree。

执行中发现并处理的与定稿 Scope 的出入（均未越出 Scope 文件）：

- Scope 写“`docs/ACTIVE_WORK.md` 顶部 2026-10-19 的 delivery-003 当前更新”，但 `ACTIVE_WORK.md` 中不存在该条；该条位于 `docs/ENGINEERING_DASHBOARD.md`。因此 WP1 的顶部更新以新的带日期条目同时加在 ACTIVE_WORK 和 Dashboard（Dashboard 在 Scope 内）。
- Scope 写 Dashboard “引用 CI run `39598364040` 的一处”；该处是 Dashboard 顶部 2026-10-21 的 T9 条目。按“历史快照不重写”，该条保持原样，新增带日期条目并加一行“历史”提示，沿用 Dashboard 既有写法。
- Scope 要求第 10 行的 Assignment 加取代说明；`ACTIVE_WORK` 第 10 行本身的短文本仍准确，故该行未改，只改 Assignment。

| M-02 item | Result |
|---|---|
| 1. 各拥有者 Assignment Current Status | 已更新：delivery-001/002/003、runtime-integration implementation-001 / hardening-001 / blocker-remediation-001、int003 query-cost 共 7 份加 S-03 取代说明（delivery-001/002/003 另有带日期的同步节）；历史文字与 Lifecycle 值均未改 |
| 2. Parent Assignment | 不适用 — 不改任何父 Assignment；`TYPO-CORRECTION-002` 的 Lifecycle 与内容均未触碰 |
| 3. `docs/ENGINEERING_DASHBOARD.md` | 已更新：顶部新增两条 2026-10-21 带日期条目（T9 CI；INPUT-RELIABILITY 链）及一行“历史”提示；既有条目未重写；TYPO-002 runtime 链在 Dashboard 无对应条目，不新增 |
| 3a. Dashboard INT003-QUERY-COST 三处（修正轮 1 核对） | 不需要改动：第 689、690、691 行均位于 `### History — 以下阶段快照不表示当前待办` 小节之下（该小节标题自身声明其为阶段快照，不表示当前待办），第 690 行的 “P2 AUTH is Active/unconsumed” 已按历史快照对待；当前状态由 ACTIVE_WORK 第 10 行与 Assignment 顶部收敛说明承载。依据：`docs/ENGINEERING_DASHBOARD.md` 第 687 行标题与 689–691 行位置 |
| 4. `docs/KNOWLEDGE_INDEX.md` | 已更新（修正轮 1）：INT-003 query-cost 条目（第 48 行）编码了已过期的 “P2 AUTH Active/unconsumed” 状态，已追加 2026-10-22 取代说明，指向 Assignment 顶部 2026-10-11 收敛说明与 ACTIVE_WORK 第 10 行；其余条目无需更新（INPUT-RELIABILITY-DELIVERY、其余 runtime-integration 子项在 Index 无条目） |
| 5. Active plan Status line | 已更新（修正轮 1）：`docs/plans/typo-correction-002-int003-query-cost-measurement-001.md` 的 Status 写着 “P2 execution not yet live”，已在 Status 段落后追加 2026-10-22 取代说明（原 Status 文字未改）。`docs/plans/typo-correction-002-runtime-integration-design-2026-09-21.md` 命中的只是对 review 文件的链接，不是 Status，不适用。搜索范围：`docs/plans/` 下对 INPUT-RELIABILITY-DELIVERY、runtime-integration、T9-ADAPTIVE-ROW、INT003 query-cost 的引用 |
| 6. `docs/ACTIVE_WORK.md` | 已更新：第 3、6、7、8、9 行改写（Lifecycle 列不变），顶部新增三条 2026-10-21 带日期条目；第 10 行未改（文本仍准确）；表仍为 11 行，成员与顺序不变 |
| 7. Markdown link check（baseline/HEAD） | 命令 `python3 -B scripts/ci/check_markdown_links.py --base 9f7a88a1b1c31106c26555bed4a7e324f6ed7b5d --head <最终提交 SHA>`；因在本文件内记录 HEAD 会改变 HEAD，baseline/HEAD 一对与结果记录在 Executor 报告 `executor-report-r1.md`（仓库外，路径见下）中 |
| `CHANGELOG.md` | 不适用 — 条目记录行为/特性变更，不作状态镜像；既有条目中的“本地候选 / 待独立 Review”为历史叙述，按规则不重写 |
| `docs/TECH_DEBT.md` | 不适用 — Non-goal，未改动；TD-020 内容仅作为 WP3 的来源事实被引用 |
| Executor 报告路径与 SHA-256 | 路径 `~/.kos-work/Universe-Keyboard/ACTIVE-WORK-STALE-FACTS-SYNC-001/reports/executor-report-r1.md`；SHA-256 由 Executor 在对话末尾报告（报告不能包含自身哈希，也不在仓库内循环记录） |

## Remediation round 1

经 Human Product Owner 于 2026-10-22 批准的修正轮 1。对提交 `7f11ab93647763e3d783cacb91db8f3150833b10` 的两份评审（Architecture Partial、Quality Blocker）作为历史保留，不改写；修正提交需要新一轮独立评审，本节不声称已通过。

| 发现 | 改了什么 |
|---|---|
| AWSF001-ARCH-F01 | `docs/KNOWLEDGE_INDEX.md` 第 48 行（INT-003 query-cost 条目）追加 2026-10-22 取代说明；Exit evidence 第 4 项改为准确依据 |
| AWSF001-ARCH-F02 | `docs/plans/typo-correction-002-int003-query-cost-measurement-001.md` 在 Status 段落后追加取代说明（原 Status 不改）；Exit evidence 第 5 项改为准确依据，并写明 runtime-integration design plan 的命中只是对 review 的链接、不是 Status |
| AWSF001-QUAL-F01 | `docs/assignments/input-reliability-delivery-003.md` 的 PR #215 同步节追加对应依据：分支名等于 Carrier、PR 正文基线等于 Baseline、PR 正文链接本 Assignment 证据目录；分类为“文档性对应”，不是推断（PR 正文叙述中未直接写出 Assignment ID，仅出现在证据目录链接里） |
| AWSF001-QUAL-F02 | Executor 报告 `executor-report-r2.md` 更正 r1 中“plans 目录无相关匹配”的措辞，写清搜索范围与判断依据；仓库内 Exit evidence 第 5 项同步改写 |

另：按修正轮 1 要求核对了 Dashboard 的 INT003-QUERY-COST 三处，结论见 Exit evidence 第 3a 行（不需要改动）。已披露的 Scope 差异（delivery-003 的当前更新实际位于 Dashboard）保持不动。本轮未改任何 Lifecycle 取值，未改 `docs/ACTIVE_WORK.md`、`CHANGELOG.md`、`docs/TECH_DEBT.md`。

## Review results and residual disposition

Post-review, append-only. 以上各节在 Reviewer 评审时固定为提交 `c9838f1e97f768520911421ecdeafdec6a4f3f3b`；本节之前的内容不因本节改动。本节所列报告与 packet 保存在仓库外，仓库内只记录路径与 SHA-256，路径前缀为 `~/.kos-work/Universe-Keyboard/ACTIVE-WORK-STALE-FACTS-SYNC-001/`。

### 提交链

`9f7a88a1b1c31106c26555bed4a7e324f6ed7b5d`（base，origin/main）→ `7f11ab93647763e3d783cacb91db8f3150833b10`（同步）→ `f0dc74576e5cde0771bda1d2e3c513db41fdec81`（修正轮 1）→ `c9838f1e97f768520911421ecdeafdec6a4f3f3b`（Round 2 评审的最终目标）。本节所在的评审后记录提交是此后追加的，只新增本节。

### 评审结果

| Lane | Round | 结论 | 报告（相对前缀） | SHA-256 |
|---|---|---|---|---|
| `AWSF001-ARCH` | 1 | Partial | `reports/architecture-review-r1.md` | `a9ed282535dfb3801f3a78f1d7ff28b67e37e85f724698c08b7e4e4fa62c1051` |
| `AWSF001-ARCH` | 2 | Pass with conditions | `reports/architecture-review-r2.md` | `90eb0cde3d1909323dda63baec58a7d07dac39c0a18ae62c9ff4850d1b5a057e` |
| `AWSF001-QUAL` | 1 | Blocker | `reports/quality-review-r1.md` | `4c0efb5ef939852ae26d06b5628288df8d405442ed37b8749d8d7a1d1b438247` |
| `AWSF001-QUAL` | 2 | Pass with conditions | `reports/quality-review-r2.md` | `d0d84ea0c5a009ac14ed463f3e8240d11983d03bd8df01b8e59f7e13e02b136d` |

Reviewer 均为全新的 codex 独立会话，未参与本次同步实现；会话标识未在仓库内记录（UNKNOWN）。Round 2 两位 Reviewer 的覆盖均完整，无 Uncovered。

### Executor 报告与更正说明

| 文件 | SHA-256 |
|---|---|
| `reports/executor-report-r1.md` | `f135c52f41c63078e00cc0b5bc903129705dc800844949aeb667a3b8ec815e1b` |
| `reports/executor-report-r2.md`（原文保留） | `1677d08ca6febf35ecbbeab0806f219362c5cc4c370be925e043dfec20e1e332` |
| `reports/executor-report-r3.md` | `cf68384272b8e54a5f1eb9b34549097488e3fba95734975ae40be0ed84aada81` |
| `reports/coordinator-correction-to-executor-report-r2.md`（Coordinator 写，非 Executor） | `7153938abee174d7eb9d6808ad67f57d9137f16a1e510bbb3b4b62e5ba76868e` |

评审后记录提交本身的 Executor 报告为 `reports/executor-report-r4.md`；报告不能包含自身哈希，其 SHA-256 由 Executor 在对话末尾报告。

### Reviewer Lane Packet 与指令

Packet 在派发前冻结，按 Round 保存在 `packets/`，指令保存在 `instructions/`。

| 文件 | SHA-256 |
|---|---|
| `packets/packet-architecture-r1.md` | `7452ddf4b75178d08f55bd6da3a924f357b916798565e0e4d444d1ecc5aaf0d6` |
| `packets/packet-quality-r1.md` | `e50efb006f45a916ae352dc532706146d8bfd3a2eb50146ff940f910f7b6e556` |
| `packets/packet-architecture-r2.md` | `208477e0a7b4b076ca27083dfe9ccde34c67d5c6c32aef93ee511034aa40f8c5` |
| `packets/packet-quality-r2.md` | `0ac1a2b6158ad17ec4adfbf0277a1d0060ff81603eb89f7707e82e746976cfc5` |
| `instructions/reviewer-architecture-r2.md` | `e194e06fec735e466838b2dff3d449311a62ed486f1faa70e3f86e49d5a441f9` |
| `instructions/reviewer-quality-r2.md` | `60a85140908c456eed9785551102a9694a13f39155b6a2ce1646a0e26164082a` |

Round 1 的派发指令与 Executor 的各轮简报只存在于对话中，未保存为文件；其实质内容保存在本 Assignment 中。

### Round 1 发现的状态

| 发现 | 状态 |
|---|---|
| `AWSF001-ARCH-F01`（Knowledge Index 第 48 行） | 已修正；Architecture Round 2 A6 复核通过 |
| `AWSF001-ARCH-F02`（INT003 plan Status） | 已修正；Architecture Round 2 A6 复核通过 |
| `AWSF001-QUAL-F01`（delivery-003 对应依据） | 已解决：Round 1 packet 的 Q2 把 #215 要求标为“推断”过严，Round 2 改写；#215 的对应依据在 delivery-003 同步节中写清，分类为文档性对应；Quality Round 2 Q2 通过 |
| `AWSF001-QUAL-F02`（“plans 无相关匹配”措辞过宽） | 已解决；Quality Round 2 Q7 确认 `executor-report-r2.md` 的更正准确 |

两个 Round 1 的不通过结论，部分源于 Coordinator 的缺陷，如实记录：packet 的 Q2 对 #215 的要求过严；Assignment 的 Scope 起草时未点名已知提及 INT003 的 Knowledge Index 条目与 plan，导致 Executor 以过窄的检索得出“无匹配”。

### 残项

| 残项 | 严重度 | 内容 | Owner | 处置 |
|---|---|---|---|---|
| `AWSF001-ARCH-R2-F01` | Minor | `executor-report-r2.md` 第 18 行对三条删除行归属的解释错误（实际为 Knowledge Index 1 行加本 Assignment 2 行） | Executor；Coordinator 跟踪 | 已处置：Human Product Owner 于 2026-10-22 在 Coordinator 会话中批准按“补一份更正说明”处置；更正说明为 `reports/coordinator-correction-to-executor-report-r2.md`（SHA-256 见上）；r2 原文保留。Reviewer 尚未重新核对该说明 |
| `AWSF001-QUAL-R2-F01` | Low | 同上，同一问题 | 同上 | 同上 |

两项指向同一个问题，仓库内容不受影响。处置不改变任何 Lifecycle，不关闭其它残项。

### 授权与边界

- Human Product Owner 于 2026-10-22 在 Coordinator 会话中授权：追加本评审后记录提交、push 分支 `docs/active-work-stale-facts-sync-001`、开一个 docs-only PR。**不含 merge。**
- 基线：评审与本记录均以 `origin/main` = `9f7a88a1b1c31106c26555bed4a7e324f6ed7b5d` 为 base；Coordinator 于 2026-10-22 核对该基线未前进。
- 仍为 `UNKNOWN`：PR #213、#214、#215、#144 的 Final Merge Gate / Merge 授权记录；PR #214 合并时的 hosted CI；delivery-003 两项 TestFlight 前事项是否已处置；delivery-001 的 Lifecycle 矛盾；#144 合并树与 implementation-001 冻结快照的逐字节关系。
- 不声称 Release / Release-ready；不声称任何工作项完成或验收；本任务未改变任何 Assignment 的 Lifecycle；本 Assignment 的 Lifecycle 处置待 PR 合并后另行决定。
- Executor 自述的模型为 `claude-sonnet-5-5`，effort 未确认，不作为验收项。pinned KOS validator 在本地未配置、未运行。
