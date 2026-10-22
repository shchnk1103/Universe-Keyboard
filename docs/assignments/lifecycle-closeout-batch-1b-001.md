# Assignment: LIFECYCLE-CLOSEOUT-BATCH-1B-001 — Close TYPO-CORRECTION-002 INT003-QUERY-COST-MEASUREMENT-001 and PARENT-REVALIDATION-002

Policy version: 1.0.0
record_id: LIFECYCLE-CLOSEOUT-BATCH-1B-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active（docs-only closeout 在本地执行；未 push） |
| Current phase | Executor 已在本地执行并经修正轮 1：A16、A27 均已关闭（Lifecycle 在进入 `main` 时生效；A27 的缺口已撤回，A16 的缺口由 Human accept，见文末 §Remediation round 1），本地提交，待 Coordinator 冻结 Reviewer packet。本批次落实 `LIFECYCLE-CLOSEOUT-BATCH-1-001` 中 Human 对 A16、A27 缺口的处置决定；每项关闭仍以“所有残项均有来源明确的处置”为前提 |
| Material non-claims | 不声称 Release / Release-ready；不改父任务 `TYPO-CORRECTION-002`（已 Closed）；不关闭、削弱任何残项；不新建 tech_debt；不修改任何 `docs/authorizations/` 文件；不处理本批次范围外的任何 Assignment；不 push / PR / merge |
| Human 确认状态 | D-1B-AUTH：**已确认**（Human Product Owner，2026-10-22，Coordinator 会话）。采用确认方案：不修改任何 `docs/authorizations/` 文件；Closeout 逐项记录三份 AUTH 的现状并声明不可重放；处置记为 `accept`；TD-014 仅作为既有同类登记引用、不修改 |
| Next handoff / decision | 派发 Executor → Coordinator 冻结 Reviewer Lane Packet → Architecture / Quality Reviewer → Human 决定 push / PR / merge |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 于 2026-10-22 Asia/Shanghai 在 Coordinator 会话中：(1) 批准 D1（TYPO-CORRECTION-002 子项按批收尾）与 D7；(2) 对 A16、A27 的缺口作出处置决定（下表），并要求在批次 1 合并后起草本批次；(3) 同日确认 D-1B-AUTH 采用下文“确认方案”。决定同时记录在 `docs/assignments/lifecycle-closeout-batch-1-001.md` 的 “Remediation round 1” 一节。本文本由 Coordinator 编写。
- **Product Approver:** Human Product Owner（Product Lead）

## M-02 trigger identities

基线 `origin/main` = `cd0b850cce7f22781c03fb9e66a4590be4357100`（PR #223 合并后）。每个 Close 是一个独立的 Assignment Close 事件，以一次同步事务记录。

| 项 | Work Item | 现状 | 关闭依据（须由 Executor 重新核实） |
|---|---|---|---|
| A16 | `TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001` | Active（`ACTIVE_WORK` 表第 10 行） | P1 PR #184 `03f4d0cc68ce22df60e1f0545afe6ae3b27d30ab` 已合并；P2 已作为证据阶段被 Human 接受；父 Gate 残项台账 |
| A27 | `TYPO-CORRECTION-002-PARENT-REVALIDATION-002` | Active（`ACTIVE_WORK` 表第 4 行） | 父任务 Closed（Gate `PD-TYPO-CORRECTION-002-PARENT-FINAL-PRODUCT-GATE-001`）；QA-001 07、性能 reval-03 已有 Product 残项决定 |

## Human 的处置决定（2026-10-22，Coordinator 会话）

Executor 须回到原文逐条核实来源，不得把此表当作来源本身。

**A16**

| 残项 | 处置 | 须核实的来源 |
|---|---|---|
| `IMPL-R1`（coordinator 级 stage / ready-empty / post-call discard / pre-call cancel / one-event 断言） | `tech_debt:INT003-COORDINATOR-INDEPENDENT-ORACLE` | `docs/TECH_DEBT.md` 同名条目（Open）；父 Gate 台账 `Q-R2-03`；`docs/reviews/typo-correction-002-int003-query-cost-p1-implementation-review-001.md` 第 169 行 |
| `IMPL-R2`（same-call setup / get_context / schema 矩阵） | `tech_debt:INT003-RIME-FAILURE-BOUNDARY` | `docs/TECH_DEBT.md` 同名条目（Open）；父 Gate 台账 `Q-R2-04`；同评审第 170 行 |
| `IMPL-R3`（iOS Simulator / hosted CI lanes） | `fix`，已完成 | `docs/evidence/typo-correction-002-fixed-candidate-delivery-audit-001.md`（CI004，完整本地矩阵已执行）与 `docs/assignments/typo-correction-002-fixed-main-validation-001.md`；须核实其确实写明相应 lane 已执行；同评审第 171 行 |
| `IMPL-R4`（冻结安装 payload、Run 与 raw journal，censoring 报告） | `accept` | P2 Product 决定 `docs/product-decisions/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md`；父 Gate 台账 `P2-CURRENT-OBSERVER-BOUNDARY-001`；同评审第 172 行 |
| `IMPL-R5`（query budget / Gate 的 Product 决定） | `accept` | 父 Gate 台账 `P2-PRODUCT-BUDGET-001`；同评审第 173 行 |

**A27**

| 残项 | 处置 | 须核实的来源 |
|---|---|---|
| `SR-02`（键盘选择 / Full Access / high-fidelity 设置为 Executor 自述） | `accept`，指向父 Gate | `docs/reviews/typo-correction-002-sim-run-2026-09-19-sidecar-reval-01-quality-review.md` 的 SR 处置表与 “Residuals retained” 表；父 Gate 台账（整体性能与观察边界 accept） |
| INT-003 AX reval-03 评审残项（Architecture 3 条、Quality 3 条） | `accept`，指向父 Gate | `docs/reviews/typo-correction-002-sim-run-2026-09-19-int003-ax-reval-03-architecture-review.md` 与 `…-quality-review.md` 的 “Residuals” 节 |
| `PR-05`（候选恢复、QA-001、INT-003 保持独立开放） | `accept`，指向父 Gate | `docs/product-decisions/TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-residual.md` 第 59 行 “Retained open outside this Run”；父 Gate 台账 |

已有处置的（核实即可，不重新决定）：QA-001 07 的各项（`docs/product-decisions/TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL.md`）；性能 reval-03 的 `PR-01…PR-04`（同上性能 Product 决定）；sidecar 的 `SR-01`、`SR-03`、`SR-04` 与 startup `unavailable`（sidecar Quality / Architecture 评审）。

**条件规则：** Executor 必须自己从原文枚举每个 Work Item 的全部残项。凡不在上面两张表和“已有处置”清单里的残项，该 Work Item **不关闭**，写入报告的“未关闭”清单并给出缺口，**不得**自行下处置结论，也不得新建 tech_debt。

## AUTH 状态与 D-1B-AUTH（Human 已确认，2026-10-22）

核对发现，两个 Work Item 引用的 Authorization 中有未消费者：

- A16：`AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001`，`status: active`，`consumption_state: unconsumed`。
- A27：`AUTH-TYPO-CORRECTION-002-INT003-REVALIDATION-001`（active — unconsumed）、`AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001`（active）。

其余被引用的 AUTH 均已 consumed。关闭 Assignment 后，这三份 AUTH 仍是 active / unconsumed 而其所属 Assignment 已 Closed。`docs/TECH_DEBT.md` 的 TD-014（AUTH consumption_state 卫生）已记录此类问题及建议的处理方向：“明确 terminal Assignment 对 consumed AUTH 的合法绑定，**或形成等价的不可重放规则**”。

**D-1B-AUTH 确认方案（Human 已确认）：** 不修改任何 `docs/authorizations/` 文件；在两个 Work Item 的 Closeout 中逐项记录这三份 AUTH 的现状，并声明：“所属 Assignment 已 Closed；该 AUTH 不得再被消费或重放；任何后续采集或复核须由 Human 另行签发新的 AUTH”；处置记为 `accept`（Human 决定），并注明 TD-014 是同类问题的既有登记，本批次不修改 TD-014。

未采用的备选方案（需要 Human 另行授权才能执行，不在本 Assignment 范围内）：由 Human 授权修改这三份 AUTH 文件，将其标为已撤销或被取代。

## Boundary

- **Scope（docs-only）:**
  1. A16 与 A27 的 Assignment 文件，三处且仅三处：(a) A16 文件顶部 `kos-record` JSON 的 `lifecycle` 改为 `closed`、`current_phase` 改写为 “Closed — …”、更新 `updated_at`（A27 无 JSON）；(b) Current Status 表的 Lifecycle 一格：A16 中把行首的 `**Active**` 改为 `**Closed**`，其后的叙述保留作为历史（已被文件顶部既有的 2026-10-11 收敛说明和 S-03 说明标为历史）；A27 中 `Active` 改为 `Closed`；并在 Current Status 顶部加 S-03 取代说明；(c) 文末追加 “Closeout (<实际日期>)” 一节：决定来源、证据指针、残项处置表（ID | owner | 处置 | 来源指针）、三份 AUTH 的现状与不可重放声明（按 D-1B-AUTH 确认后的方案）、非声称。历史文字不删不改。
  2. `docs/ACTIVE_WORK.md`：仅当某项实际关闭时，从表中移出其行（A27→第 4 行，A16→第 10 行；先 `grep -n '^| 4 |'` 与 `'^| 10 |'` 核实行号，批次 1 合并后文件已有变化）；其余行的编号、工作项、Lifecycle 三列逐行一致；新增一条带日期的当前更新，写明本批次实际关闭了哪些项、移出了哪些行、哪些未关闭。历史快照不重写。
  3. `docs/ENGINEERING_DASHBOARD.md`：新增一条带日期条目；既有的 INT003-QUERY-COST 三处提及位于 `### History` 小节之下，保持不改，在 Exit evidence 写依据。
  4. 若 A16 关闭：`docs/KNOWLEDGE_INDEX.md` 第 48 行末尾追加带日期说明；`docs/plans/typo-correction-002-int003-query-cost-measurement-001.md` 在既有取代说明之后追加一行带日期说明。原文不改。
  5. 本 Assignment 记录文件本身与 “Closeout Decision” 结果小节。
  6. 链接检查与行尾空白检查。
  7. `CHANGELOG.md`、`docs/TECH_DEBT.md`、`docs/authorizations/**`：逐项检查并写“不适用及依据”，**不修改**。
- **Non-goals:**
  - 关闭本表之外的任何 Assignment（含 A4、A10 到 A15 的运行时集成链、A17、A18、A22、A24 到 A26、A28、A29、C2、B 区）；改动父 Assignment、产品代码、测试、CI、Xcode 工程、`.kos/project.json`；修改 `docs/TECH_DEBT.md` 或新建 tech_debt；修改任何 AUTH 文件；改写历史快照；push / PR / merge。
- **Required Inputs:** `AGENTS.md`；Knowledge Index；Assignment Policy（Lifecycle 与 “Close is blocked while any residual lacks a disposition”）；`kos-2.1-operational-maturity.md` 的 M-02 / S-03 / M-03；`AI_WORKFLOW.md`；Scope 内全部文件；上文各来源文件；三份 AUTH 文件（只读）；父 Gate `docs/product-decisions/TYPO-CORRECTION-002-PARENT-FINAL-PRODUCT-GATE-001.md`。

## Closeout Decision

本节是本批次的“所属 Gate 关闭”记录。Human Product Owner 于 2026-10-22 批准关闭方式并作出上述处置决定；每个具体 Close 以 Executor 核实来源后写入各 Assignment 的 “Closeout” 一节为准，Reviewer 评审后由 Human 决定是否 push 与合并。评审完成后在本节追加最终结果（追加式）。

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward
- **Executor:** Executor 角色（AI 不限）；建议模型 `claude-sonnet-5-5`、effort medium；实际配置：运行时为 Claude（Claude Code）；模型 `claude-sonnet-5-5`（会话系统信息）；effort 未确认——harness 仅暴露数值，无法确认其等于 medium，**不声称已应用 medium**；会话标识未确认。
- **Environment Executor:** 同一会话，本地
- **Human Dependency:** Human Product Owner（任何 push / PR / merge；D-1B-AUTH 确认）
- **Architecture Reviewer:** 独立 Reviewer 会话（AI 不限）；独立性条件：未参与本批次实现，且不是 Quality Reviewer 的同一会话；lane `LCB1B-ARCH`；实际 AI、模型与会话标识由 Reviewer 在报告开头声明并记入 Reviewer Lane Packet；指名与派发由 Human 确认
- **Quality Reviewer:** 独立 Reviewer 会话（AI 不限）；独立性条件：未参与本批次实现，且不是 Architecture Reviewer 的同一会话；lane `LCB1B-QUAL`；其余同上

## Reviewer claim register

| ID | 声称 |
|---|---|
| D1 | 每个被关闭的 Work Item：JSON `lifecycle`（A16）、Current Status 的 Lifecycle、文末 “Closeout” 三者一致；仅改了允许的三处；历史文字未改；S-03 写法正确 |
| D2 | 每个被关闭项的残项由 Executor 从原文完整枚举，与上述 Human 处置表和“已有处置”清单逐条对应，无遗漏；每条处置的来源指针真实存在；引用的 `tech_debt:<ID>` 在 `docs/TECH_DEBT.md` 真实存在且仍 Open；没有残项被削弱或改写 |
| D3 | 映射的内容对应性成立：`IMPL-R1`↔`Q-R2-03`、`IMPL-R2`↔`Q-R2-04` 的内容确实对应（该映射是 Human 的决定，Reviewer 只核对其是否有依据、记录是否准确，不评决定本身）；`IMPL-R3` 的“已完成”有证据 |
| D4 | A27 缺口陈述所引的三份评审（AX reval-03 Architecture / Quality、sidecar-reval-01 Quality）的内容与 Closeout 中的残项描述一致 |
| D5 | 三份 AUTH 文件未被修改；Closeout 如实记录其状态并作不可重放声明；未把 TD-014 冒充为这些 AUTH 的处置 |
| D6 | `docs/ACTIVE_WORK.md` 表只移出实际关闭项对应的行，其余行三列逐行一致；新增条目带日期；历史快照未重写 |
| D7 | 所有已登记镜像逐项“已更新”或“不适用并有依据”；`CHANGELOG.md`、`docs/TECH_DEBT.md`、`docs/authorizations/**` 未改 |
| D8 | 引用的 PR 号、合并提交、合并时间、证据路径与 `gh`/`git` 一致 |
| D9 | 无越权声明：Release、Gate、验收、独立复核、父任务状态改变、残项关闭或削弱 |
| D10 | diff 只含 Scope 内文件，未关闭项的文件相对 base 逐字节一致，删除行归属逐项核对 |
| D11 | 最终提交的链接检查与 `git diff --check` 通过 |
| D12 | Executor 报告与仓库事实一致，UNKNOWN 清单未被偷偷填充；报告开头有运行时身份声明 |

Executor 自述的模型与 effort 不作为验收标准，只登记为残项。

## Reports

Executor 与 Reviewer 的最终报告、指令、packet 均保存为文件，根目录 `~/.kos-work/Universe-Keyboard/LIFECYCLE-CLOSEOUT-BATCH-1B-001/`（`instructions/`、`packets/`、`reports/`）。仓库内只记录路径与 SHA-256。

## Gates

- **Entry:** Human 确认 D-1B-AUTH 并批准派发；基线为派发时 `origin/main`（起草时 `cd0b850`），Executor 重新核验；独立 worktree 与新分支 `docs/lifecycle-closeout-batch-1b-001`；Human 本地 main 的 dirty 文件不得触碰。
- **Reviewer 前置:** Executor 提交后、派发 Reviewer 之前，由 Coordinator 冻结 Reviewer Lane Packet，并机械扫描 Executor 报告与本 Assignment 引用的每个路径是否都在允许集内（见 `tools/scan_cited_paths.py`）。
- **Exit:** 条件判断已记录；每个已关闭项三处一致；镜像已处理；链接检查已记录；本地提交；报告文件已保存。
- **Stop:** 基线移动且影响 Scope；残项缺处置（该项不关闭并上报）；需要新建 tech_debt、修改 AUTH 文件或改 Scope 之外文件；被要求处理 CI；任何 push / merge。
- **Handoff Target:** Human Product Owner。**Revalidation:** Scope / Owner / Reviewer 变化、基线漂移、授权撤回、D-1B-AUTH 方案变化。

## Exit evidence

| 项 | Result |
|---|---|
| 每个 Work Item 的关闭/不关闭结论与依据 | **A16 关闭；A27 关闭**（修正轮 1；r1 曾为“均不关闭”，见文末 §Remediation round 1）。A27 的缺口 `AR-01`/`QR-01`/`QR-02` 已撤回——Product 决定 `TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-PRODUCT-RESIDUAL.md` 已存在；A16 的 “original query-density Product residual” 由 Human 作为受限未知 accept（不是性能 Pass）。其余残项均已枚举并对应到 Human 处置决定或既有来源明确的处置 |
| 残项枚举与处置表（每项每条残项、处置、来源指针） | 完整枚举见 A16、A27 各自文件的 “Closeout (2026-10-22)” 残项处置表；批次内的汇总与 r1 的原始枚举见文末 §Closeout Decision — 结果（r1 的缺口陈述已由 §Remediation round 1 更正） |
| 三份 AUTH 的现状与不可重放声明 | 三份 AUTH 均只读核对，状态与本 Assignment 所述一致（原文行号见 A16、A27 各自的 Closeout 与文末 §三份 AUTH 的现状）。不可重放声明已写入：A16 的 Closeout（`…P2-SIM-CAPTURE-001`）、A27 的 Closeout（`…INT003-REVALIDATION-001`、`…PARENT-REVALIDATION-001`）；处置 `accept`（D-1B-AUTH）；TD-014 仅引用、未修改 |
| 1. 各拥有者 Assignment Current Status | 已更新：A16、A27 的 JSON `lifecycle`（仅 A16 有 JSON）、Current Status 的 Lifecycle 格、S-03 取代说明（A16 与既有 “2026-10-11 current convergence” 及既有 S-03 说明并存）、文末 Closeout 三者一致 |
| 2. Parent Assignment | 不适用 — 不改任何父 Assignment（Executor 确认：`docs/assignments/typo-correction-002.md` 未改动） |
| 3. `docs/ENGINEERING_DASHBOARD.md` | 已更新：顶部新增一条 2026-10-22 带日期条目（修正轮 1 就地更正为“已关闭”）；既有的 INT003-QUERY-COST 三处提及位于 `### History — 以下阶段快照不表示当前待办` 小节之下的 INT-003 query-density / query-cost P1/P2 / P0 publication 三条（行号会随文件顶部插入而变，不以行号为准），保持不改 |
| 4. `docs/KNOWLEDGE_INDEX.md` | 已更新：A16 已关闭，第 48 行末尾追加 2026-10-22 带日期补充说明，原文不改 |
| 5. Active plan Status line | 已更新：A16 已关闭，`docs/plans/typo-correction-002-int003-query-cost-measurement-001.md` 在既有取代说明之后追加一条带日期说明，原文不改 |
| 6. `docs/ACTIVE_WORK.md`（移出的行、保留行校验） | 已更新：新增一条 2026-10-22 带日期的当前更新（修正轮 1 就地更正）；**移出 2 行**——A27 的原第 4 行、A16 的原第 10 行；表由 11 行变为 9 行，其余 9 行经脚本与 base 逐行对比，全部表行逐字一致 |
| 7. Markdown link check（baseline/最终提交） | 命令 `python3 -B scripts/ci/check_markdown_links.py --base cd0b850cce7f22781c03fb9e66a4590be4357100 --head <最终提交 SHA>`；因在本文件内记录最终 SHA 会改变 HEAD，baseline/最终提交一对与结果记录在 Executor 报告 `executor-report-r2.md`（仓库外，路径见下；`executor-report-r1.md` 保留） |
| `CHANGELOG.md` | 不适用 — 条目记录行为/特性变更，不作生命周期镜像；未改动 |
| `docs/TECH_DEBT.md` | 不适用 — Non-goal，未改动；未新建 tech_debt；仅核实被引用的 `INT003-COORDINATOR-INDEPENDENT-ORACLE`（第 357 行起）、`INT003-RIME-FAILURE-BOUNDARY`（第 367 行起）真实存在且 Status 仍为 Open |
| `docs/authorizations/**` | 未改动（三份 AUTH 只读） |
| Executor 报告路径与 SHA-256 | 路径 `~/.kos-work/Universe-Keyboard/LIFECYCLE-CLOSEOUT-BATCH-1B-001/reports/executor-report-r2.md`（`executor-report-r1.md` 保留）；SHA-256 由 Executor 在对话末尾报告（报告不能包含自身哈希，也不在仓库内循环记录） |

## Closeout Decision — 结果（Executor，2026-10-22，评审前）

> **修正轮 1 更正（追加于 2026-10-22）：** 本节是 Executor r1 的原始结论，保留作历史。其中 “A16、A27 均不关闭” 以及 “A27 的缺口 `AR-01` / `QR-01` / `QR-02`” 已被文末 §Remediation round 1 取代：A27 的缺口不存在（Product 决定已存在），A16 的缺口已由 Human accept；A16、A27 均已关闭。下文关于 A16、A27 的枚举表仍可用作残项来源的原始记录。

本节追加式记录 Executor 的核实结果。所有结论待 Reviewer 评审；Executor 不自行评审，不声称已评审。规则：`docs/ASSIGNMENT_POLICY.md` §Residual Disposition Before Close、`docs/kos/kos-2.1-operational-maturity.md` M-03，以及本 Assignment 的条件规则——Executor 自己从原文枚举残项，凡不在 Human 处置表和“已有处置”清单里、也没有既有来源明确处置的残项，该 Work Item 不关闭，不自行下结论，不新建 tech_debt。

### 结论

| 项 | Work Item | 结论 | 唯一阻断的缺口 |
|---|---|---|---|
| A16 | `TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001` | **不关闭**（文件与 base 逐字节一致） | “original query-density Product residual / wider `query_*` residual / 旧 rapid-window 归因” 在仓库中没有任何处置记录（见下） |
| A27 | `TYPO-CORRECTION-002-PARENT-REVALIDATION-002` | **不关闭**（文件与 base 逐字节一致） | rime-ice deployment-smoke 两份评审的残项 `AR-01`、`QR-01`、`QR-02` 不在 Human 处置表或“已有处置”清单里，也没有 Product 层面的处置记录（见下） |

除上述缺口外，两个 Work Item 的其余残项都已枚举并能对应到 Human 处置表或既有来源明确的处置。**若 Human 对该缺口作出处置决定（或声明它不属于该 Work Item 的残项），可在后续批次中据下表直接关闭。**

### A16 残项枚举与处置

| 残项 | owner | 处置 | 来源指针 / 核实 |
|---|---|---|---|
| `IMPL-R1`（coordinator 级 stage / ready-empty / post-call discard / pre-call cancel / one-event 断言） | Input Intelligence Maintainer | Human 决定：`tech_debt:INT003-COORDINATOR-INDEPENDENT-ORACLE` | review-001 第 169 行；`docs/TECH_DEBT.md` 第 357 行起（Status 第 359 行：Open / retained）；父 Gate 第 49 行（`Q-R2-03`）。内容对应的两边原文：review-001 要求补“coordinator-level stage、ready-empty … assertions”；`Q-R2-03`（`docs/evidence/typo-correction-002-fixed-candidate-delivery-audit-001-p1-convergence-original.txt` 第 40 行）写“ready-empty 的期望 stage trace 与 `TypoCorrectionRecallDriver` 共享，独立 hard-coded stage oracle 缺失”；TECH_DEBT 条目 Risk 写“ready-empty 的期望 stage trace 与实现共享 … 并非完全独立 hard-coded oracle”。二者都是 coordinator 级 stage 断言的独立性问题 |
| `IMPL-R2`（same-call setup / get_context / schema 矩阵） | RimeBridge owner + Test/Release | Human 决定：`tech_debt:INT003-RIME-FAILURE-BOUNDARY` | review-001 第 170 行；`docs/TECH_DEBT.md` 第 367 行起（Status 第 369 行：Open / retained）；父 Gate 第 50 行（`Q-R2-04`）。两边原文：review-001 要求在 RimeBridge target 运行 same-call setup/get_context/schema 矩阵；`Q-R2-04`（convergence-original 第 41 行）写“真实 Rime setup/schema-selection/get-context 失败行为未被集成证据展示”；TECH_DEBT Risk 写“现有集成证据未直接展示真实 setup/schema-selection/get-context 失败”。convergence 记录三项 RimeBridge correction-query 集成测试已通过（Quality R4），因此未展示的是真实失败行为那一部分 |
| `IMPL-R3`（iOS Simulator / hosted CI lanes） | Test/Release | Human 决定：`fix`，已完成 | review-001 第 171 行。证据原文：A16 Current Status 第 79 行写 “Hosted run 36322160611 passed all jobs at exact head `a572765`”，`gh run view 36322160611` 为 `conclusion: success`、`event: pull_request`、`headSha: a5727659cbe4622a86c620f06b9a884c4d11a04c`，且与 `gh pr view 184` 的 `headRefOid` 相同（PR #184 合并 `03f4d0cc68ce22df60e1f0545afe6ae3b27d30ab`，2026-09-27T13:59:18Z）；`docs/evidence/typo-correction-002-fixed-main-validation-001.md` 第 10–20 行逐 suite 记录 Simulator lanes（RimeBridge 90/20/0、UniverseKeyboardTests 403/10/0、KeyboardTests 44/0/0、KeyboardExtensionTests 6/0/0 等）与 “Release：passed”（Executor-recorded，并明确自称不是 hosted CI）；`…delivery-audit-001.md` 第 2 节记录原 CI004 的完整本地矩阵已执行。两个 lane（hosted、Simulator）各有明确写明已执行的原文 |
| `IMPL-R4`（冻结安装 payload / Run / raw journal，censoring 报告） | Test/Release / P2 executor | Human 决定：`accept` | review-001 第 172 行；P2 Product 决定 `…P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md` §“2026-10-11：接受本轮结论限制并结束限定P2收敛”（第 60 行起）；父 Gate 第 51 行（`P2-CURRENT-OBSERVER-BOUNDARY-001` / `QPA-R2-LEGACY-SYNTHETIC-NONREUSE-001`：accept） |
| `IMPL-R5`（query budget / Gate 的 Product 决定） | Human Product Owner | Human 决定：`accept` | review-001 第 173 行；父 Gate 第 52 行（`P2-PRODUCT-BUDGET-001` / `QPA-R2-PRODUCT-RESIDUAL-DECISION-001`：accept bounded observation without numerical budget） |
| `Q-R2-02`（433 发现 / 432 结果节点差异） | Test / Release reviewer | accept（既有处置；不在 Human 表中） | convergence-original 第 39 行；父 Gate 第 48 行 |
| `Q-R2-05`（最终十文件候选为组合式覆盖） | Test / Release reviewer | accept（既有处置；不在 Human 表中） | convergence-original 第 42 行；父 Gate 第 48 行 |
| `P2-ADMISSION-R1-REPORT-001` | 原 Quality lane | fix completed（既有处置；不在 Human 表中） | `docs/reviews/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-REVIEW-DELIVERY-001-closeout-r2.md` 第 20 行 |
| `ROUTE-REVIEW-R1-E01`（Architecture AR-01 / Quality F1） | Test / Release | fixed 并独立 closure Pass（既有处置；不在 Human 表中） | `…ROUTE-SCOPE-REVIEW-001-residuals-r1.md` 顶部当前状态说明；`…QUALITY-REMAINDER-001-closeout-r3.md` |
| **“original query-density Product residual”**（A16 文末 Handoff 段写 “remains open”）：即 2026-09-23 Product Capture 的 `fence_discarded=0`、高 `query_*` 574/574、旧 rapid-window 查询归因、更宽的 `query_*` fan-out 是否可接受 | Human Product Lead（owner 在来源中为 Product） | **无处置记录 — 缺口** | `docs/product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md` 第 84–91 行；`…QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md` 的 “Remaining boundary” 与 “Non-claims”（写明 “No … acceptance of the wider `query_*` residual”，且 “Product may separately decide …”）；`typo-correction-002-int003-query-cost-assessment-001.md` 第 12 行 “Product decision on the wider residual remains open”。我在 `docs/` 中检索 “wider residual / rapid-window attribution / old rapid-window”，没有找到后续的 accept / fix / tech_debt 记录；父 Gate 台账与 `PARENT-PERFORMANCE-SCOPE-PROPOSAL-001` 均未提及 `query_*`、fan-out 或 rapid-window |

说明：P2-PRODUCT-BUDGET-001 的 accept 只覆盖 “不编造数值预算、接受有界观测”，没有写到上一行的归因与 fan-out 问题；因此我不把它当作上一行的处置。该行是否属于 A16 的残项、或是否由 Human 另行接受 / 登记，是 Human 的决定，Executor 不代写。

### A27 残项枚举与处置

| 残项 | owner | 处置 | 来源指针 / 核实 |
|---|---|---|---|
| `SR-01`（包 SHA-256 未从安装重算） | Quality | 既有处置：Closed for this lane | sidecar Quality 评审第 53 行 |
| `SR-02`（键盘选择 / Full Access / high-fidelity 设置为 Executor 自述） | Quality / Human | Human 决定：`accept`，指向父 Gate | sidecar Quality 评审第 54、64 行；sidecar Architecture 评审第 117 行；父 Gate 第 51、55 行（观察边界 / 整体性能 accept）。注：仓库内没有一条记录点名 `SR-02` 的 Product 处置，这条对应关系是 Human 的决定 |
| `SR-03`（`liveSessionStable` 为派生字段） | Architecture | 既有处置：Accept | sidecar Quality 评审第 55 行 |
| `SR-04`（`simctl get_app_container` CoreSimulatorService 掉线） | Quality | 既有处置：Accept as historical tool limitation | sidecar Quality 评审第 56 行 |
| startup `route=unavailable` 生命周期 | Architecture | 既有处置：accept | sidecar Architecture 评审第 120 行；Quality 评审第 58、65 行；性能 Product 决定 `PR-02`（第 56 行） |
| INT-003 AX reval-03 Architecture 残项（3 条：stale-work 取消仍 inconclusive；`XCUIElement.tap()` 仅证明 AX 可达；QA-001 与 paired performance 未建立） | Architecture | Human 决定：`accept`，指向父 Gate | `docs/reviews/typo-correction-002-sim-run-2026-09-19-int003-ax-reval-03-architecture-review.md` 第 27–33 行 |
| INT-003 AX reval-03 Quality 残项（3 条：无合格 rapid stimulus 与取消标记；无 QA-001 / 性能 / 语义结论；receipt 仍为 Executor-recorded） | Quality | Human 决定：`accept`，指向父 Gate | `…int003-ax-reval-03-quality-review.md` 第 21–30 行 |
| `PR-01…PR-04`（性能 reval-03） | Quality / Product | 既有处置：Product Accepted | 性能 Product 决定第 55–58 行 |
| `PR-05`（候选恢复、QA-001、INT-003 保持独立开放） | Product / Quality | Human 决定：`accept`，指向父 Gate | 性能 Product 决定第 59 行 “Retained open outside this Run”；性能 Quality 评审第 181 行 `QR-PR-05` |
| QA-001 07：`AR-QA07-01/02/03`、`QR-QA07-01/02/03/04` | Architecture / Quality | 既有处置：Product Accepted | QA-001 07 Product 决定第 61–66 行；Architecture 评审第 124–126 行；Quality 评审第 83–86 行 |
| **rime-ice deployment-smoke 评审残项：`AR-01`（下载的归档文件未单独导出并重算 SHA）、`QR-01`（同上，“Non-blocking”）、`QR-02`（当前 worktree HEAD 不是已安装包的 source snapshot）** | Architecture / Quality | **无 Product 层面的处置记录 — 缺口** | `docs/reviews/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01-architecture-review.md` 第 66–70 行；`…-quality-review.md` 第 48–53 行。A27 自己写明 “Both reviews retain the archive re-hash residual”。评审者层面只有 “Accepted as a provenance-detail residual” / “Non-blocking”，与 `SR-02` 同类；但它们既不在 Human 处置表，也不在“已有处置”清单，且 QA-001 07 Product 决定的 `AR-QA07-03` 说的是另一次评审的包二进制 |

A27 的其余 lane（INT-003 attempt 01 / retry 02 / retry 03 / low-overhead / coordinate feasibility，QA-001 revalidation 03 / 04 / 06，performance revalidation 02，diagnostic smoke，Simulator App Group 对账）只有 “inconclusive” 回执，没有独立评审的残项表；它们的未建立目标由 `PR-05` 与 AX reval-03 残项的 Human 决定覆盖，这一对应关系同样是 Human 的决定。

> **修正轮 2 更正指针：** 上一句把 diagnostic smoke 与 Simulator App Group 对账也概括成 “只有 inconclusive 回执”，不准确。分组后的核实结果见文末 §Remediation round 2。本句保留作 r1 原始记录，不倒写。

### 三份 AUTH 的现状（只读核对，与本 Assignment 所述一致）

| AUTH | 原文 |
|---|---|
| `AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001`（A16） | `docs/authorizations/…P2-SIM-CAPTURE-001.md` 第 9 行 `"status": "active"`、第 38 行 `"consumption_state": "unconsumed"`、第 52 行 “P2 is **Active / unconsumed**” |
| `AUTH-TYPO-CORRECTION-002-INT003-REVALIDATION-001`（A27） | `docs/authorizations/…INT003-REVALIDATION-001.md` 第 7 行 `Status | active — unconsumed` |
| `AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001`（A27） | `docs/authorizations/…PARENT-REVALIDATION-001.md` 第 7 行 `Status | active — bounded evidence revalidation only`、第 28 行 `"status": "active"`、第 103 行 `"consumption_state": "active"` |

A16、A27 本批次均未关闭，因此这三份 AUTH 的 “不可重放声明”（D-1B-AUTH 确认方案：所属 Assignment 已 Closed；该 AUTH 不得再被消费或重放；任何后续采集或复核须由 Human 另行签发新的 AUTH；处置 `accept`；TD-014 仅作为同类问题的既有登记引用、不修改）**没有写入任何 Work Item**。三份 AUTH 文件未被修改；在对应 Work Item 关闭之前，它们仍是 active，本批次不对其可否使用作任何新声明。

### 判断点（请 Reviewer 重点复核）

1. A16 的 “original query-density Product residual”：Executor 把 A16 文末的 “remains open” 视为 A16 自己文本中的残项并判为缺口。若 Reviewer 认为它属于上游 Work Item 的残项而非 A16 的，请指出依据；该分类需 Human 决定。
2. A27 的 rime-ice smoke 残项：Executor 把评审者层面的 “Accepted / Non-blocking” 视为不足以构成 “来源明确的处置”（与批次 1 对 `SR-02` 的处理标准一致，Human 对 `SR-02` 另作了决定）。
3. `Q-R2-02`、`Q-R2-05`、`P2-ADMISSION-R1-REPORT-001`、`ROUTE-REVIEW-R1-E01` 不在 Human 处置表中，Executor 依据既有来源明确的处置将其记为已处置；若 Reviewer 认为应严格要求出现在表中，请指出。
4. 本节引用的行号取自基线 `cd0b850` 的文件。

## Remediation round 1 (2026-10-22)

追加式。Executor r1 提交 `ab4e8f548e1bdc5cf3ce872080cc63a04b332414` 的结论（A16、A27 均不关闭）经 Coordinator 复核后修正；本节与对应的修正提交需要新一轮评审，Executor 不声称其已通过。

### (i) A27 缺口撤回及原因

r1 报告的 A27 缺口 `AR-01`、`QR-01`、`QR-02`（rime-ice deployment-smoke 评审残项）**并不存在，已撤回**。原因是 Executor 的检索遗漏：Product 决定 `docs/product-decisions/TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-PRODUCT-RESIDUAL.md` 在仓库中已存在（Status: Accepted — bounded residual disposition；决定人 Human Product Owner / Product Lead，2026-09-20），其中：

- 第 24 行 “QR-01 / AR-01: downloaded archive not independently re-hashed — Accepted for this deployment precondition”；
- 第 25 行 “QR-02: documentation HEAD differs from installed package source — Accepted with exact package binding”；
- 第 49 行 “This docs-only decision closes the Product disposition of QR-01/QR-02 for the named setup run only”。

`docs/ACTIVE_WORK.md` 表第 4 行（基线 `cd0b850` 中即已）链接了该决定（“Product residual decision”）。r1 的检索词（围绕 “wider residual / rapid-window / archive re-hash” 等）没有覆盖到这份文件，且当时只把 A27 文本里直接出现的两份 Product 决定当作全集——这是 Executor 的疏漏。

撤回后，Executor 重新做了更广的核对：把 `docs/product-decisions/` 下全部 `TYPO-CORRECTION-002-*` 文件逐个按 “PARENT-REVALIDATION-002” 与 A27 的残项关键词（`SR-0`、`AX`、`reval-03`、`diagnostic smoke`、`App Group`、`coordinate`）检索，引用 A27 作为 Parent 的 Product 决定恰为三份——QA-001 07、性能 reval-03、RIME Ice deployment——均已纳入；`docs/reviews/` 与 `docs/evidence/` 中引用 A27 的文件已逐类核对（sidecar、AX reval-03、performance reval-03、QA-001 07、rime-ice smoke 各自的评审；其余为 “inconclusive” 回执）；`TYPO-CORRECTION-002-QA001-REVALIDATION-08-*` 属另一个 child，A27 文件并不引用，不在 A27 残项范围内。**没有发现第二处遗漏。**

> **修正轮 2 更正指针：** 上一句末尾 “其余为 inconclusive 回执” 沿用了不准确的概括。diagnostic smoke 是有范围的 pass，Simulator App Group 对账列了 Remaining residuals。分组核实见文末 §Remediation round 2。本句保留作修正轮 1 的原始记录，不倒写。

### (ii) Human 对 A16 的决定

A16 的 “original query-density Product 残项”（更宽的 `query_*` fan-out；2026-09-23 Product Capture 的 `fence_discarded=0`、`query_*` 574/574、旧 rapid-window 归因）：Human Product Owner（Product Lead）于 2026-10-22 在 Coordinator 会话中**明确 accept，作为受限未知接受**。边界：**不是性能 Pass**；更宽 fan-out 是否可接受仍未建立；与父 Gate 对整体性能未知的接受范围一致；**不新建 tech_debt**。决定人：Human Product Owner（Product Lead）；决定来源：Coordinator 会话，2026-10-22。A18（`typo-correction-002-int003-stale-cancel-product-capture-001`）的同一残项由后续批次按同一决定落实，本批次不改 A18 文件。此前的决定（D-1B-AUTH；A16 的 `IMPL-R1…R5`；A27 的 `SR-02`、AX reval-03 评审残项、`PR-05`）仍然有效。

### (iii) 实际关闭清单

- A16 `TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001`：**关闭**（JSON `lifecycle` = `closed`、Current Status 的 Lifecycle = `**Closed**`、文末 Closeout 三者一致）。
- A27 `TYPO-CORRECTION-002-PARENT-REVALIDATION-002`：**关闭**（无 JSON；Current Status 的 Lifecycle = `Closed`、文末 Closeout）。
- 镜像：`docs/ACTIVE_WORK.md` 移出原第 4、10 行（表 11 行 → 9 行）；`docs/KNOWLEDGE_INDEX.md` 第 48 行与 INT003 plan 各追加一条带日期说明；`docs/ENGINEERING_DASHBOARD.md` 条目更正。Lifecycle 在本改动进入 `main` 时生效。
- 未关闭其它 Work Item（A18 由后续批次落实）；三份 AUTH、`docs/TECH_DEBT.md`、`CHANGELOG.md`、父 Assignment、`.kos/project.json` 未改。

### (iv) 对 r1 提交 `ab4e8f5` 自有文字的就地更正

以下均为 Executor 在 r1 新写、尚未评审也未发布的文字，因结论改变而过期，就地更正（删除行即被替换的旧行）：

| 位置 | 更正内容 | 删除行归属 |
|---|---|---|
| `docs/ACTIVE_WORK.md` 顶部 2026-10-22 条目（1 行） | 由 “没有关闭任何项” 改为 “关闭 2 项、移出原第 4、10 行、表 11→9 行” | 该条目旧文字（同一物理行内的替换） |
| `docs/ENGINEERING_DASHBOARD.md` 顶部 2026-10-22 条目（1 行） | 由 “均未关闭” 改为 “已关闭”，补 “不是性能 Pass” | 该条目旧文字（同一物理行内的替换） |
| 本文件 Current Status 的 `Current phase` 一格 | 由 “A16、A27 均未关闭” 改为 “均已关闭（A27 缺口撤回、A16 缺口由 Human accept）” | 该格旧文字（同一物理行内的替换） |
| 本文件 Exit evidence：`每个 Work Item 的关闭/不关闭结论与依据`、`残项枚举与处置表`、`三份 AUTH 的现状与不可重放声明`、`1. 各拥有者 Assignment Current Status` 四行 | 结论、枚举指向与 AUTH 声明按关闭后的事实改写 | 这四行旧文字（每行一行） |
| 本文件 Exit evidence：`3. Dashboard` 一行（括注）、`4. Knowledge Index`、`5. Active plan Status line`、`6. ACTIVE_WORK` 四行 | 由 “不适用 / 未移出” 改为 “已更新 / 移出 2 行” | 这几行旧文字（每行一行） |
| 本文件 Exit evidence：`7. Markdown link check` 与 `Executor 报告路径与 SHA-256` 两行 | 报告指向由 `executor-report-r1.md` 改为 `executor-report-r2.md`（r1 保留） | 这两行旧文字（每行一行） |
| 本文件 §Closeout Decision — 结果 | **未改写**，仅在节首追加一条 “修正轮 1 更正” 提示，原文保留作 r1 的原始记录 | 无删除 |

### Round 1 之后的 Reviewer 栏与运行时身份

Reviewer 栏保持原文，未填任何具体 AI。Executor 运行时身份同 r1：Claude（Claude Code），模型 `claude-sonnet-5-5`，effort 未确认，会话标识未确认。

## Remediation round 2 (2026-10-22)

追加式。提交 `eeeb1539f68d73eb73359136c9508d62ed5d82fb` 经 Architecture 与 Quality 独立评审，均为 Pass with conditions。本节只记录两条低严重度条件的文档更正，不改写 r1 / r2 报告，也不改写上面各节的原文。

### (i) LCB1B-QUAL-R1-F01

Quality 指出 A27 Closeout 把一组 lane 概括成 “只有 inconclusive 回执，没有独立评审的残项表”，与两份回执不符：

- `docs/evidence/typo-correction-002-sim-run-2026-09-19-diagnostic-smoke-01.md` 第 97 行写明 Smoke result 为 `pass`，范围是 fresh high-fidelity keyboard observability。
- `docs/evidence/typo-correction-002-simulator-app-group-signing-reconciliation-2026-09-20.md` 第 131–143 行列了 Remaining residuals。

修正轮 2 的 Executor 回到每份回执核实，没有沿用旧概括。核实结果：

| lane | 回执 | 实际结果 |
|---|---|---|
| diagnostic smoke | `docs/evidence/typo-correction-002-sim-run-2026-09-19-diagnostic-smoke-01.md` | 范围 pass（仅 fresh high-fidelity keyboard observability）；候选恢复、目标选择、交互回归、INT-003、计时预算、Product Gate 未建立 |
| Simulator App Group / signing 对账 | `docs/evidence/typo-correction-002-simulator-app-group-signing-reconciliation-2026-09-20.md` | 纠正了未签名包缺少 Simulator entitlement 的解释；明列四条 Remaining residuals，各有来源明确的处置（见 A27 Closeout） |
| INT-003 attempt 01、retry 02、low-overhead、coordinate feasibility；QA-001 revalidation 03 / 04 / 06；performance revalidation 02 | 各 lane 自己的 inconclusive 回执（路径见 A27 Closeout） | inconclusive，或 retry 02 在运行前编译阻断、无运行时证据 |
| INT-003 retry 03 | `docs/evidence/typo-correction-002-sim-run-2026-09-19-int003-ax-reval-03-inconclusive.md` | INT-003 目标仍为 inconclusive；回执内另有 harness 与 sidecar 的范围 pass。其独立评审残项已在 Closeout 表内，不在“其余 lane”组 |

四条 App Group 残项的处置均能指回来源，没有无处置残项，因此没有停止、也没有新建 tech_debt：

1. 当时的 `rime_ice` deployment `not-run`：由随后的 deployment-smoke 回执（bounded pass）与 Product 决定第 49–50 行承接；该决定只关闭 named setup run 的 QR-01/QR-02，不关闭 QA-001 / INT-003 / paired performance。
2. 本机没有 Apple Development 身份：回执自己写明它与物理设备构建有关，不是该 Simulator entitlement 证明的阻断项；本 Close 不把它改记为已解决。
3. `simctl get_app_container` 工具失败：sidecar Quality `SR-04` 已 Accept 为 historical tool limitation。
4. 旧 signed-rebuild Authorization 不可重用：回执自己保留该边界；本 Close 不重放它。

A27 Closeout（`docs/assignments/typo-correction-002-parent-revalidation-002.md` 文末 “Closeout (2026-10-22)” 残项表之后的那一段）已就地替换为上述分组。未建立的目标仍由 `PR-05` 与 AX reval-03 残项的 Human 决定覆盖。

### (ii) 保留的历史文字与更正指针

下列句子沿用了旧概括，原文保留，不倒写成从未发生：

- 本文件 §Closeout Decision — 结果 的 A27 枚举之后那一句（“只有 inconclusive 回执 …”）。节内已附指向本节的更正指针。
- 本文件 §Remediation round 1 (i) 末句里的 “其余为 inconclusive 回执”。节内已附指向本节的更正指针。
- Executor 报告 r1 第 53 行、r2 第 32 行。两份报告不改；更正以本节与 `executor-report-r3.md` 为准。

### (iii) LCB1B-ARCH-R1-C01

Exit evidence 第 3 项原先写 History 标题在第 687 行、三条在第 689–691 行。那是顶部插入两行之前的行号。修正轮 2 开工时在 HEAD `eeeb1539f68d73eb73359136c9508d62ed5d82fb` 上核实：标题 `### History — 以下阶段快照不表示当前待办` 在第 691 行，INT-003 query-density、query-cost P1/P2、P0 publication 三条在第 693–695 行。该行号引用已改为不依赖行号的描述。A16 与 A27 文件中没有 Dashboard 行号引用。行号会随文件顶部插入而变，以后不以行号为准。

本轮 Executor 运行时身份见 `executor-report-r3.md`。没有 push，没有开 PR。
