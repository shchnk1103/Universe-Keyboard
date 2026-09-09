# Assignment: SCHEME-DELIVERY-SCHEME-PLATFORM-001 — Scheme Platform（Ice-as-reference）

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Ready** |
| Current Phase | Human 已批准 Ice-as-reference Scheme Platform **目标**（`2026-09-09 Asia/Shanghai`）。本 Assignment 已起草为 **Ready**；**尚未** Human Active。P0 = 接口 + 「Ice already satisfies / Wanxiang gaps」矩阵（仅文档）。工作可与分支 `codex/wanxiang-p4-closure-001` 上 docs-only 共存；**不**自动接管 Wanxiang P4 Active 实现权。 |
| Material non-claims | **不是** ADR 0034 Accept；**不是** Product Gate / TestFlight / Release；**不是** Swift 实现授权；不把 Wanxiang 内容改写成 Ice；不单方面 Pause `SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001` |
| Next handoff / decision | **Human Product Owner：** (1) 是否 **Active** 本 Assignment（方可推进正式 P0 矩阵 / 后续 P1）；(2) 对仍 Active 的 Wanxiang P4 选择 **(a)** Active 本片并 Pause/收窄 P4，或 **(b)** 继续窄 A34-R1（Scope 明确排除平台抽取） |
| Residuals | A34-R1 仍由 Wanxiang P4 Assignment 跟踪直至 Human 决定平台优先或窄闭合；A34-R2 / TD-011 / RTRD-* 仍并行债 |
| Frozen tip | 起草时分支 tip ~`8006413` on `codex/wanxiang-p4-closure-001`（docs-only）；实现冻结 tip 在 Active 时由 Human 重申 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in-session — approved Ice-as-reference Scheme Platform target; authorized local docs + Ready Assignment (`2026-09-09 Asia/Shanghai`)
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:**
  1. **P0（docs）：** 定义 Scheme Platform 接口草案 + 矩阵「Ice already satisfies / Wanxiang gaps」；编码 Human 已批准的 north star（见 Required Inputs target plan）。
  2. **P1：** 将 Ice hooks 抽到 platform；**Ice 行为不变**（Ice regression）。
  3. **P2：** 将 Wanxiang 迁到 platform（lua / layout / default 按 reference / adapter）。
  4. **P3：** 删除冗余 forks；**仅在此后**再审视 A34-R1 处置与 ADR Accept 路径（Accept 仍需另授权）。
  5. 共享层能力：lifecycle（download→filter→stage-verify→upgrade checkpoint→install→deploy→receipt；fail-closed restore）；active uninstall→Luna-only；inactive 保 peer/unknown/Prelude；layout capability 声明式；resource ownership 统一 API；never overwrite Prelude `default.yaml`（scheme defaults via private preset / Ice mode）。
  6. 方案层：per-scheme manifest + optional adapters（preset、layout fallback、ownership strategy、post-process）。最小化 `if schemaID == …`。
- **Non-goals:**
  - 在 Human **Active** 本 Assignment 之前开始 P1+ Swift；
  - 将 Wanxiang **内容**改写成 Ice；
  - Accept ADR 0034；Product Gate / TestFlight / App Release；
  - 把 `SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001` 扩成平台 mega-refactor（本 Assignment **supersedes** 该扩展意图）；
  - Ice `dofile` 全量（A34-R2 / TD-011）、`RTRD-01`/`RTRD-02`、Recovery persistence、peer-prefer B、整目录 `lua/`/`opencc/` 清空；
  - 单方面 Pause / Closed Wanxiang P4（须 Human 选择）。
- **Required Inputs:**
  - [Ice-as-reference target plan](../plans/scheme-platform-ice-reference-target-2026-09-09.md)（Human Approved）
  - [Wanxiang P4 closure Assignment](scheme-delivery-wanxiang-p4-closure-001.md)（关系 / 边界）
  - [Cross-scheme matrix contract](../plans/scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md)
  - [Coexistence plan](../plans/scheme-resource-ownership-and-coexistence-plan.md)
  - [Wanxiang P4 gap inventory](../evidence/scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md)
  - [ADR 0034](../architecture/decisions/0034-multi-scheme-resource-ownership.md)（Proposed）
  - [Architecture Accept review](../reviews/adr-0034-architecture-accept-review-2026-09-09.md)（Conditional Accept；A34-R1）
  - `ASSIGNMENT_POLICY.md` / `AGENTS.md` / `ACTIVE_WORK.md`

## Assignment

- **Domain Owner:** 📱 Main App UI / Scheme Delivery — multi-scheme install platform.
- **Executor:** Grok Bot / iOS开发大师（**仅在** Human Active 后执行 Scope；Ready 阶段仅允许 Human 已授权的 docs 起草/勘误）。
- **Environment Executor:** 同 Executor — 本地 format / Simulator / package tests（P1+）；真机仅另授权。
- **Human Dependency:** Product Lead — Ready→Active；每个对外 push/merge；是否 Pause/收窄 Wanxiang P4。
- **Architecture Reviewer:** Independent 🏛️ Architecture — 只读；P0 接口/矩阵与 P1 抽取边界；扩大 ADR 决策面则先停。
- **Quality Reviewer:** Independent 🧪 Quality — 只读；P1 Ice regression / P2 Wanxiang migration 后的 IQ。

## Gates

- **Entry Criteria (→ Ready):** （**已满足** `2026-09-09 Asia/Shanghai`）
  - 无 `UNKNOWN` 责任字段；
  - Human 已批准 Ice-as-reference Scheme Platform 目标；
  - Target plan 已落盘并链接本 Assignment。
- **Entry Criteria (→ Active / 实现):**
  - Human 明确批准本 Assignment **Active**；
  - 冻结工作 tip / 分支策略写明；
  - 若与 Wanxiang P4 并行：Human 已书面选择 (a) 或 (b)（见 Current Status）。
- **Exit Criteria:**
  - P0 矩阵 + 接口草案经 Human/Architecture 知情；
  - P1：Ice 行为回归通过（授权范围内的自动化 + IQ）；
  - P2：Wanxiang 经 platform/adapters 路径，无新增 `schemaID` 硬分叉作为主策略；
  - P3：冗余 forks 删除计划完成或 Human 书面保留清单；
  - Assignment / ACTIVE_WORK 更新；**仍不**自动 Accept ADR。
- **Stop Conditions:**
  - Human 拒绝 Ice-as-reference；
  - 需要 Accept ADR、改 pin、动 RimeBridge/Extension 核心 session 边界、或整目录清空共享资源；
  - 未 Active 却开始 Swift 平台抽取；
  - Product Gate / TestFlight 被当作本片隐含出口；
  - 与 ADR 0001/0003/0006/0032/0033 冲突；
  - 任一责任变为 `UNKNOWN`。

## Relationship to Wanxiang P4 / A34-R1

本 Assignment **supersedes**「把 Wanxiang P4 / A34-R1 扩成平台级 mega-refactor」的意图。

- **推荐路径：** Human Active 本片 → 至少完成 P0（优选至 P2）后再用平台结果回看 A34-R1。
- **可选窄路径：** Human 保持 Wanxiang P4 Active，但 Scope **明确排除**平台抽取，仅做文档闭合 / 残余 disposition / 已发现的最小生产缺口。
- Executor **不得**在未获 Human 选择前自行 Pause Wanxiang P4 或把 P4 工作改写成 P1 extract。

## Handoff

- **Handoff Target:** Human Product Owner（Active 决策）；Active 后 Independent Architecture（P0/P1 边界）→ Independent Quality（P1/P2）→ Human（是否再开 ADR Accept）。
- **Required Handoff Content:** target plan；P0 矩阵；冻结 tip；Ice/Wanxiang regression 指针；与 Wanxiang P4 的边界声明；明确 non-claims。
- **Revalidation Trigger:** Human 撤销 Ice-as-reference；ADR 0034 正文决策变更；Wanxiang/Ice pin 变更；layout 产品合同变更。

## Evidence

- Target (Human Approved): [`../plans/scheme-platform-ice-reference-target-2026-09-09.md`](../plans/scheme-platform-ice-reference-target-2026-09-09.md)
- Prior matrix / gaps: cross-scheme contract；Wanxiang P4 gap inventory；coexistence plan（见 Required Inputs）

## History

- `2026-09-09 Asia/Shanghai`: Human 批准 Ice-as-reference Scheme Platform 目标；Lifecycle = **Ready**；授权本地 docs（target + 本 Assignment + ACTIVE_WORK / Wanxiang P4 状态注记）。**未**授权 Active / Swift / push / ADR Accept。
