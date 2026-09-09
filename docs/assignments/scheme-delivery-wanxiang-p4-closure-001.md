# Assignment: SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001 — 万象 P4 闭合（A34-R1）

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Ready |
| Current Phase | Assignment 已起草；等待 Human 单独授权进入 `Active` / 实现。目标：闭合 ADR 0034 Architecture Accept 残余 **A34-R1**（Wanxiang P4 相对 ADR 全文未全闭合） |
| Material non-claims | 本 Assignment **不是** ADR 0034 Accept；**不是**完整 Product Gate / TestFlight / Release；不把 Ice `dofile`（A34-R2 / TD-011）或 `RTRD-01`/`RTRD-02` 塞进本片；起草授权 ≠ 编码授权 |
| Next handoff / decision | Human 确认本 Assignment 范围后，再授权 `Active` 与首个实现切片（建议先：缺口清单 + 测试/证据计划，再最小代码） |
| Residuals | 进入 Active 前无执行残余；闭合后须回写 A34-R1 disposition 与 ADR Accept 路径 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in-session — 拒绝书面 `accept` A34-R1，并批准起草独立 Assignment（`2026-09-09 Asia/Shanghai`）
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:**
  1. 相对 ADR 0034 候选 A 与已合入 `main` @ `814abfd` 的现状，盘点 **Wanxiang P4 仍未闭合** 的具体缺口（升级、卸载、跨方案矩阵、设备/自动化证据、与 exact-hash / upgrade-rollback 切片的差距）。
  2. 在 Human 授权 `Active` 后，按最小切片闭合那些缺口：生产行为仅限万象归属/升级/卸载合同所需；补充自动化测试与 Independent Quality（及 Human 另授权时的设备证据）。
  3. 闭合证据足够后，更新 Assignment / ACTIVE_WORK，并将 Architecture Accept 残余 **A34-R1** 从 `fix` 改为可 Accept 的处置（通常 `Closed` 或书面范围说明）；**仍不自动 Accept ADR 0034**。
- **Non-goals:**
  - 修改 ADR 0034 Status 为 Accepted，或无 Human「Accept ADR 0034」授权时改 ADR 正文决策；
  - Ice `dofile`/`loadfile` 全量闭合（属 A34-R2 / `TD-011`）；
  - `RTRD-01` / `RTRD-02` 诊断 UI / elapsed；
  - Recovery persistence、peer-prefer B、TestFlight、App Release、完整 Product Gate；
  - 更换 Wanxiang pin / 扩大到非 CNB `17.5.9` 范围（除非 Human 另授权）；
  - 整目录删除 `lua/` / `opencc/`，或削弱 ADR 0033 官方不可变字节合同。
- **Required Inputs:**
  - [ADR 0034](../architecture/decisions/0034-multi-scheme-resource-ownership.md)（Proposed）
  - [Architecture Accept checklist](../reviews/adr-0034-architecture-accept-checklist-2026-09-09.md)
  - [Architecture Accept review — Conditional Accept](../reviews/adr-0034-architecture-accept-review-2026-09-09.md)（A34-R1）
  - [SOURCE-STATE-001](scheme-delivery-source-state-001.md)
  - [Wanxiang Lua ownership evidence](../evidence/scheme-delivery-wanxiang-lua-ownership-2026-09-08.md)
  - [Wanxiang upgrade-rollback contract](../plans/scheme-delivery-wanxiang-upgrade-rollback-contract-2026-09-08.md) 及相关 IQ reviews
  - [TD-011](../TECH_DEBT.md#td-011-multi-scheme-lua--advanced-input-compatibility-雾凇--万象)（并行债，本片不关闭除非 Human 另说）
  - `main` tip `814abfd`（或后续 Human 冻结 tip）

## Assignment

- **Domain Owner:** 📱 Main App UI / Scheme Delivery — Wanxiang install/upgrade/uninstall ownership and transaction correctness.
- **Executor:** Current authorized executor（Grok Bot / Codex，以 Active 时 Human 指定为准）；仅本 Scope。
- **Environment Executor:** 同 Executor — 本地 format 硬门槛、Simulator / package tests；真机仅在另授权时。
- **Human Dependency:** Product Lead — 授权本 Assignment 进入 `Active` 与每个对外 push/merge；Device Operator — 仅当本片 Exit 要求真机证据时。
- **Architecture Reviewer:** Independent 🏛️ Architecture — 只读；本片若扩大 ADR 0034 决策面则先停。
- **Quality Reviewer:** Independent 🧪 Quality — 只读；实现切片完成后的 IQ / delta。

## Gates

- **Entry Criteria (Ready → 已满足起草):**
  - 无 `UNKNOWN` 责任字段；
  - Human 已拒绝 `accept` A34-R1 并批准起草本 Assignment；
  - Architecture Accept review 已记录 Conditional Accept 与 A34-R1。
- **Entry Criteria (→ Active / 实现):** （需另一次 Human 明确授权）
  - Human 批准进入 Active；
  - 冻结工作 tip / 分支策略已写明；
  - 首个切片的缺口清单已附在 Evidence 或 Progress 笔记。
- **Exit Criteria:**
  - 书面「Wanxiang P4 closure」范围与 ADR 0034 候选 A 对齐的核对表完成；
  - 缺口项均有 `Closed` 证据或 Human 书面缩窄范围（缩窄须 Architecture 知情）；
  - 自动化 + Independent Quality 对冻结 tip 无开放 P0/P1；
  - A34-R1 回写为非 Accept 阻断；**ADR Status 仍为 Proposed 直至另授权 Accept**；
  - Assignment / ACTIVE_WORK Current Status 已更新。
- **Stop Conditions:**
  - 需要 Accept ADR、改 pin、动 RimeBridge/Extension 核心 session 边界、或整目录清空共享资源；
  - 与 ADR 0001/0003/0006/0032/0033 冲突；
  - 真机/密钥/App Group 越权取证；
  - 任一责任变为 `UNKNOWN`。

## Relation to ADR 0034 Accept

Human 拒绝书面接受 A34-R1 后，Architecture 路径上 A34-R1 视为 **`fix`（Accept 前必修）**。
本 Assignment 是该 `fix` 的载体。完成本片 **不** 自动 Accept ADR；Accept 仍需 Human 在 Architecture 结论满足后的单独授权。

## Handoff

- **Handoff Target:** Independent Quality，然后 Human Product Owner（再决定是否重回 ADR Accept）。
- **Required Handoff Content:** 缺口清单；冻结 tip；测试/IQ 指针；A34-R1 新 disposition；明确 non-claims。
- **Revalidation Trigger:** Wanxiang pin/版本变更；ADR 0034 正文决策变更；卸载/升级事务模型变更。

## Evidence

（Active 后追加）

## History

- `2026-09-09 Asia/Shanghai`: Human 拒绝接受 Architecture Accept 残余 A34-R1，批准起草本独立 Assignment；Lifecycle = Ready；**未**授权实现 / Active。
