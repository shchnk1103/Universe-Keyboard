# Assignment: SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001 — 万象 P4 闭合（A34-R1）

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Active**（Resume authorized `2026-09-12 Asia/Shanghai`） |
| Current Phase | **S6 A34-R1 writeback Done**（narrow Exit）。**A34-R1 Closed（narrow）**；**E14 Closed**。S5 IQ [`scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md`](../reviews/scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md) — **Pass with conditions**；**E15 Closed**。Human **E16/E17/E20 = Accepted（narrow Exit）**。Freeze tip = draft #102 tip `72b5987`；S5 tip `6f29f64`；S6 = this docs tip。Platform Assignment stays **Active**（P3 Exit certified；no Close）。历史分支 `codex/wanxiang-p4-closure-001` tip ~`e83e635` 保留本地未推送 docs 历史。 |
| Material non-claims | S6 **≠** Assignment Close / Done-as-Human-Close；**不** Accept ADR 0034；A34-R1 **Closed（narrow）** ≠ ADR Accept / device failure-rollback attested / App Group 全路径升格；**不是** Product Gate / TestFlight / Release；leave draft #101 alone；keep #101≠#102；不把 Ice `dofile`（A34-R2 / TD-011）或 `RTRD-01`/`RTRD-02` 塞进本片 |
| Next handoff / decision | Human may decide **Assignment Close** / whether to reopen ADR Accept path via #101 later — **not authorized now**。**仍不** Accept ADR；leave #101；**ask before push**。 |
| Residuals | **A34-R1 Closed（narrow）** via S6；**E14 Closed**；E16/E17/E20 **Accepted（narrow Exit）**；**E15 Closed** via S5 IQ；IQ residuals `WX-P4-S5-IQ-01` accept / `02` accept / `03` closed via S6 writeback / `04` accept；**仍不**自动 Accept ADR 0034；**不** Close Assignment |
| Frozen tip | Resume path freeze = draft #102 tip `72b5987dc4434221f4b4aa57c836369723bd7fb9` on `codex/scheme-platform-001`；base `814abfd7c03002256978d7658c176b80002d2539`；historical work branch `codex/wanxiang-p4-closure-001` tip ~`e83e635`（未推送） |

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
  4. **Progress / Boundary (platform):** Gate 0（`2026-09-09`）曾 **Paused**（shelved for Scheme Platform）。Human Resume（`2026-09-12`）本片 **Active** 再走 A34-R1 narrow path。Platform Assignment = [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](scheme-delivery-scheme-platform-001.md) 仍 **Active**（P3 Exit certified；no Close）。**A34-R1 Closed（narrow）** via S6 — **不** Close 本 Assignment / **不** Accept ADR。Freeze tip `72b5987` on `codex/scheme-platform-001`。
- **Non-goals:**
  - 修改 ADR 0034 Status 为 Accepted，或无 Human「Accept ADR 0034」授权时改 ADR 正文决策；
  - Ice `dofile`/`loadfile` 全量闭合（属 A34-R2 / `TD-011`）；
  - `RTRD-01` / `RTRD-02` 诊断 UI / elapsed；
  - Recovery persistence、peer-prefer B、TestFlight、App Release、完整 Product Gate；
  - 更换 Wanxiang pin / 扩大到非 CNB `17.5.9` 范围（除非 Human 另授权）；
  - 整目录删除 `lua/` / `opencc/`，或削弱 ADR 0033 官方不可变字节合同；
  - 将本片扩成 Scheme Platform 抽取 / Ice-as-reference P1–P3 / mega-refactor（Human **(b)**；由 `SCHEME-DELIVERY-SCHEME-PLATFORM-001` 另 Active 承接）。
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
- **Executor:** Grok Bot / iOS开发大师（Human Active 授权）；仅本 Scope。
- **Environment Executor:** 同 Executor — 本地 format 硬门槛、Simulator / package tests；真机仅在另授权时。
- **Human Dependency:** Product Lead — 授权本 Assignment 进入 `Active` 与每个对外 push/merge；Device Operator — 仅当本片 Exit 要求真机证据时。
- **Architecture Reviewer:** Independent 🏛️ Architecture — 只读；本片若扩大 ADR 0034 决策面则先停。
- **Quality Reviewer:** Independent 🧪 Quality — 只读；实现切片完成后的 IQ / delta。

## Gates

- **Entry Criteria (Ready → 已满足起草):**
  - 无 `UNKNOWN` 责任字段；
  - Human 已拒绝 `accept` A34-R1 并批准起草本 Assignment；
  - Architecture Accept review 已记录 Conditional Accept 与 A34-R1。
- **Entry Criteria (→ Active / 实现):** （**已满足** `2026-09-09 Asia/Shanghai`）
  - Human 批准进入 Active（会话授权 Active + full KOS adherence）；
  - 冻结工作 tip / 分支策略已写明（见 Current Status Frozen tip）；
  - 首个切片的缺口清单已附在 Evidence（见下）。
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

- Gap inventory (slice 1): [`../evidence/scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md`](../evidence/scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md)
- Narrow closure checklist (S2): [`../evidence/scheme-delivery-wanxiang-p4-closure-checklist-2026-09-09.md`](../evidence/scheme-delivery-wanxiang-p4-closure-checklist-2026-09-09.md)
- E16/E17/E20 Human disposition: [`../evidence/scheme-delivery-wanxiang-p4-e16-e17-e20-disposition-2026-09-12.md`](../evidence/scheme-delivery-wanxiang-p4-e16-e17-e20-disposition-2026-09-12.md)
- S5 Independent Quality (E15 Closed): [`../reviews/scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md`](../reviews/scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md) — Pass with conditions on freeze `72b5987`
- Architecture Accept review (A34-R1 = **Closed** narrow): [`../reviews/adr-0034-architecture-accept-review-2026-09-09.md`](../reviews/adr-0034-architecture-accept-review-2026-09-09.md)
- S6 writeback evidence: [`../evidence/scheme-delivery-wanxiang-p4-a34-r1-writeback-2026-09-12.md`](../evidence/scheme-delivery-wanxiang-p4-a34-r1-writeback-2026-09-12.md)
- Baseline: `main` @ `814abfd7c03002256978d7658c176b80002d2539`；Resume freeze tip `72b5987` on `codex/scheme-platform-001`；S5 tip `6f29f64`

## History

- `2026-09-09 Asia/Shanghai`: Human 拒绝接受 Architecture Accept 残余 A34-R1，批准起草本独立 Assignment；Lifecycle = Ready；**未**授权实现 / Active。
- `2026-09-09 Asia/Shanghai`（稍后）: Human 授权本 Assignment **Active** + full KOS adherence（`SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001`）。冻结 tip `814abfd` / 分支 `codex/wanxiang-p4-closure-001`；slice 1 = 缺口清单 + Active 治理（无 Swift）。**仍不** Accept ADR 0034。
- `2026-09-09 Asia/Shanghai`（再后）: Human 批准 Ice-as-reference **Scheme Platform** 目标；新建 Ready Assignment `SCHEME-DELIVERY-SCHEME-PLATFORM-001`。本片 Lifecycle **仍 Active**（未授权 Pause）。Current Status / Boundary：下一工作 **blocked pending** Human 选择 (a) Active 平台并 Pause/收窄本片，或 (b) 继续窄 A34-R1 且 Scope 排除平台抽取。**仍不** Accept ADR；无 Swift 平台抽取。
- `2026-09-09 Asia/Shanghai`（再再后）: Human 选择 **(b)** — keep Wanxiang P4 Active for **narrow A34-R1**；Scope **明确排除** Scheme Platform extract / Ice-as-reference P1–P3。`(a)/(b)` blocker cleared。下一阶段 S2 narrow closure checklist（E14）+ E15–E17/E20 residual disposition notes（E16/E17/E20 **仍需 Human disposition**）。Scheme Platform Assignment **仍 Ready**（未 Active）。**仍不** Accept ADR；无 push；无 Scheme Platform P1 Swift；无 mega-refactor。
- `2026-09-09 Asia/Shanghai`（Gate 0）: Human 授权 **Pause** 本 Assignment（reason: shelved for Scheme Platform）。Lifecycle = **Paused** — **NOT** Closed/Done。A34-R1 仍 open（`fix`）；writeback later。Active 指向 [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](scheme-delivery-scheme-platform-001.md)。无 ADR Accept；无 Swift。
- `2026-09-12 Asia/Shanghai`（**Resume**）：Human 授权 A34-R1 path + accept draft defaults for **E16/E17/E20**（narrow Exit；no device failure-rollback；keep Pass-with-conditions for App Group）。Lifecycle **Paused → Active**。Freeze tip = draft #102 tip `72b5987` on `codex/scheme-platform-001`。Next：**S5** IQ closure delta on freeze tip → **S6** A34-R1 writeback（**仍不** Accept ADR）。E14/E15 still open；A34-R1 still open until S6。Platform Assignment stays Active（P3 Exit certified；no Close）。**Local docs only**；**no push**；leave #101 alone；**no** ADR Accept；**no** undraft/merge #102。
- `2026-09-12 Asia/Shanghai`（**S5 IQ**）：Independent Quality **Pass with conditions** on freeze tip `72b5987` — [`scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md`](../reviews/scheme-delivery-wanxiang-p4-closure-001-s5-quality-review.md)。**E15 Closed**；**E14** still open；A34-R1 still open until S6（**不** silent-close）。Hosted CI run `34676751887` attempt 2 full green（attempt 1 flake `DiagnosticsJournalRetentionSchedulerTests…` → residual `WX-P4-S5-IQ-01` accept）。Lifecycle **仍 Active** — **不** Assignment Close。Next：**S6** A34-R1 writeback **awaiting Human**；**仍不** Accept ADR；leave #101；Platform stays Active；**local docs only**；**ask before push**；**no** undraft/merge #102。
- `2026-09-12 Asia/Shanghai`（**S6**）：Human-authorized A34-R1 disposition writeback。**A34-R1 → Closed（narrow Wanxiang P4 Exit）**；**E14 Closed**。Exit Criteria for **narrow** path recorded met；Lifecycle **仍 Active** — Human 未授权 Assignment Close。Next：Human may decide Assignment Close / whether to reopen ADR Accept path via #101 later — **not authorized now**。**仍不** Accept ADR；leave #101；Platform stays Active；**local docs only**；**ask before push**；**no** undraft/merge #102。
