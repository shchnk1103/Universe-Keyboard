# Assignment: SCHEME-DELIVERY-SCHEME-PLATFORM-001 — Scheme Platform（Ice-as-reference）

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Active** |
| Current Phase | **P0 docs slice complete**（`2026-09-09 Asia/Shanghai`）：接口草案 [`scheme-platform-p0-interfaces-2026-09-09.md`](../plans/scheme-platform-p0-interfaces-2026-09-09.md) + Ice/Wanxiang 矩阵 [`scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md`](../evidence/scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md)。**Human approved P1 vs Discovery split**（同日）：本 Assignment **P1** = declarative LayoutCapability + ResourceCapability/ownership seams（adapter lookup；Ice-only nine-key answers；Wanxiang `supportsNineKey = false`；Lua/OpenCC via strategy APIs）；**Installed Capability Discovery / layout-picker** = later Assignment (not yet drafted；须另 Human Active；**Human approved layout-page A/B UX + uninstall layout-fallback + Luna presence + readiness greying** `2026-09-09` — see Non-goals / History / [`scheme-platform-discovery-layout-ux-2026-09-09.md`](../plans/scheme-platform-discovery-layout-ux-2026-09-09.md))。冻结 tip base：`origin/main` @ `814abfd7c03002256978d7658c176b80002d2539`；工作分支 `codex/scheme-platform-001`（draft PR #102 存在 — **本片仅本地 commit，不 push** unless Human 另说）。Gate 0 治理仍有效；Wanxiang P4 **Paused**（A34-R1 open — NOT Closed/Done）。**无** ADR Accept；**无** Product Gate / TF；**无** Swift。下一动作：Human/Architecture 知情 P0；**另授权**后才进 P1 Swift；push/PR 仍须先问 Human。 |
| Material non-claims | **不是** ADR 0034 Accept；**不是** Product Gate / TestFlight / Release；**不是** Swift / P1 实现授权；不把 Wanxiang 内容改写成 Ice；**不**自动 Closed Wanxiang P4 / A34-R1（Pause ≠ Done）；本片 **不 push** |
| Next handoff / decision | P0 docs 已本地落盘 — 交 Human/Architecture 知情。**ask before push/PR**（draft #102 不自动更新）。P1 Swift / ADR Accept / Product Gate / TF / A34-R1 writeback 均须另授权。 |
| Residuals | A34-R1 仍 open（`fix`）于 Paused Wanxiang P4 Assignment；平台路径优先后回看 writeback。A34-R2 / TD-011 / RTRD-* 仍并行债 |
| Frozen tip | base `814abfd7c03002256978d7658c176b80002d2539` (`origin/main` / PR #100 merge)；branch `codex/scheme-platform-001` |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in-session — approved Ice-as-reference Scheme Platform target; authorized local docs + Ready Assignment (`2026-09-09 Asia/Shanghai`)
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:**
  1. **P0（docs）：** 定义 Scheme Platform 接口草案 + 矩阵「Ice already satisfies / Wanxiang gaps」；编码 Human 已批准的 north star（见 Required Inputs target plan）。
  2. **P1（Human-approved scope `2026-09-09`）：** 将 Ice hooks 抽到 platform；**Ice 行为不变**（Ice regression）。本片 P1 明确包含：
     - **declarative LayoutCapability** + **ResourceCapability / ownership** seams；
     - 用 adapter lookup 替换硬编码 `isNineKeyCapable == t9`，**保留当前 Ice-only nine-key answers**；
     - Wanxiang adapter **`supportsNineKey = false`**（不 enable）；
     - Lua / OpenCC ownership 经 **strategy APIs**（统一 **ResourceOwnership** / ResourceCapability）；**long-term dual strategies** = Ice **`namedList`** + Wanxiang **`exactHash`**（**not** forced to one）。
     - **SharedDefault / P1 boundary：** extract Ice **`privatePreset` only** behind adapter；Wanxiang may **temporarily** keep skip / `consumePrelude` as **transitional** adapter（**not** end-state）。
     - **Ownership / P1 boundary：** wire Ice `namedList` + Wanxiang `exactHash` strategies；**behavior unchanged**；**no** dangerous filename heuristics auto-removing lua/opencc；**no** whole-dir wipe。
     - **不含** Installed Capability Discovery / layout-picker UI（动态枚举已装方案能力驱动 layout UI，及 Lua/OpenCC 产品面同类 honesty）— 见 Non-goals / later Assignment；**P1** may add **readiness query** seams only if needed for later greying honesty (not the Discovery UI)。
  3. **P2：** 将 Wanxiang 迁到 platform（lua / layout / **SharedDefault → `privatePreset`** same mode as Ice；**Ownership stays dual strategy** — Wanxiang uses platform path **keeping `exactHash`**）；**`consumePrelude` / skip-only is not Wanxiang end-state**；**不含** Wanxiang nine-key productization（Human deferred — later Assignment；may ride Discovery later or stay further deferred）。**Fidelity risk：** Wanxiang preset migration needs **product regression**（separate from silent change）。**Contrast：** SharedDefault consolidates to `privatePreset` in P2；Ownership does **not** force one strategy。
  4. **P3：** 删除冗余 forks；**仅在此后**再审视 A34-R1 处置与 ADR Accept 路径（Accept 仍需另授权）。
  5. 共享层能力：lifecycle（download→filter→stage-verify→upgrade checkpoint→install→deploy→receipt；fail-closed restore）；active uninstall→Luna-only；inactive 保 peer/unknown/Prelude；layout capability 声明式；**ResourceOwnership** 统一 API with **long-term dual strategies** (`namedList` + `exactHash`)；never overwrite Prelude `default.yaml`；**SharedDefault end-state** = Ice-shaped **`privatePreset`** as reference mode for **third-party** schemes（**Luna** may remain Prelude/builtin exception）；OpenCC：Wanxiang may keep `admitted=false`（same API）。
  6. 方案层：per-scheme manifest + optional adapters（preset、layout fallback、ownership strategy、post-process）。最小化 `if schemaID == …`。
- **Non-goals:**
  - 在 Human **Active** 本 Assignment 之前开始 P1+ Swift；
  - 将 Wanxiang **内容**改写成 Ice；
  - **Wanxiang nine-key productization**（enablement / capability claim）— **deferred to a later Assignment (not yet drafted)**（may ride Discovery later or stay further deferred）；本 Assignment 的 P1/P2 **不得** enable Wanxiang nine-key；Ice `t9` 仍为 reference shape；`wanxiang_t9*` 可留在 install plan ownership，但 **product capability 保持 false** 直至该未来 Assignment；
  - **Installed Capability Discovery / layout-picker** — 动态枚举已装方案的 capabilities 以驱动 layout UI（及 Lua/OpenCC 产品面同类 honesty）— **later Assignment (not yet drafted)**；须 **separate Human Active**；**不是**本 Assignment P1；P1 只落 declarative seams + adapter lookup（Ice-only answers）。**Human approved layout-page UX**（`2026-09-09`）for that later Assignment: **Section A Confirmed** = user override > package capability manifest > catalog adapter declaration（installed + `supported=true`）；**Section B Filename suggestions (try)** = weak filename/`schema_id` hints（e.g. t9/nine），labeled unverified，user may try；**never auto-write binding** from filename alone；successful/explicit confirm **promotes** to user override (A)；filename never sole authority（RIME has no official layout-naming constraint — wiki conclusion）；Wanxiang nine-key仍 deferred，`wanxiang_t9*` may appear in B later until productized。**Package capability manifest = Universe convention, not RIME built-in.** **Human approved uninstall layout-fallback**（同日）：when deleting a scheme that backs current layout binding(s) — **warn** (not silent) → among **remaining installed** find **ready A-only** supporters (override > manifest > adapter; **never** auto-pick B; **unready** A not auto-rebind) → rebind (prefer previously used > primary > stable default) **or else** 26-key + Luna (`luna_pinyin`) and clear invalid nine-key → then uninstall; existing Luna-only active-uninstall still applies. Platform `onUninstallPrepare` / UninstallHooks consume this contract. **Human approved Luna presence + readiness greying**（同日）：Luna **always** on **26-key Section A**; **never** on nine-key A; **not** a B filename suggestion; **builtin exception**. Confirmed-but-unready (missing deps / not deployable / readiness fail) → **greyed in A with reason** (prefer grey over hide); click guides fix; **no direct layout binding** until ready. Discovery Assignment scope; **P1** only seams if needed for readiness query. 详情：[`scheme-platform-discovery-layout-ux-2026-09-09.md`](../plans/scheme-platform-discovery-layout-ux-2026-09-09.md)；
  - Accept ADR 0034；Product Gate / TestFlight / App Release；
  - 把 `SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001` 扩成平台 mega-refactor（本 Assignment **supersedes** 该扩展意图）；
  - Ice `dofile` 全量（A34-R2 / TD-011）、`RTRD-01`/`RTRD-02`、Recovery persistence、peer-prefer B、整目录 `lua/`/`opencc/` 清空；**dangerous filename heuristics auto-removing** lua/opencc（heuristics only as confirm-gated hints if ever；Settings = confirmed ownership/strategy honesty + optional user marking for third-party）；
  - Closed Wanxiang P4 / 静默关闭 A34-R1（Pause ≠ Closed/Done；须另授权 writeback）；
  - 未获 Human 授权的对外 push/PR（本片 **ask before first push/PR**）。
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
- **Human Dependency:** Product Lead — Ready→Active（**已授权** `2026-09-09`）；**ask before first push/PR**（无 ongoing draft push auth）；P1+ Swift / ADR Accept / Product Gate / TF 另授权；A34-R1 writeback 另授权。
- **Architecture Reviewer:** Independent 🏛️ Architecture — 只读；P0 接口/矩阵与 P1 抽取边界；扩大 ADR 决策面则先停。
- **Quality Reviewer:** Independent 🧪 Quality — 只读；P1 Ice regression / P2 Wanxiang migration 后的 IQ。

## Gates

- **Entry Criteria (→ Ready):** （**已满足** `2026-09-09 Asia/Shanghai`）
  - 无 `UNKNOWN` 责任字段；
  - Human 已批准 Ice-as-reference Scheme Platform 目标；
  - Target plan 已落盘并链接本 Assignment。
- **Entry Criteria (→ Active / 实现):** （**已满足** `2026-09-09 Asia/Shanghai` Gate 0）
  - Human 明确批准本 Assignment **Active**；
  - 冻结工作 tip / 分支策略已写明（见 Current Status Frozen tip：`origin/main` @ `814abfd7c03002256978d7658c176b80002d2539` / `codex/scheme-platform-001`）；
  - Wanxiang P4 已 Human **Paused**（shelved for Scheme Platform；A34-R1 仍 open）。
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

- **Current path (Gate 0):** Human **Active** 本片；Wanxiang P4 **Paused**（shelved for Scheme Platform）。A34-R1 仍 open — **NOT** Closed/Done；writeback later after platform progress。
- **推荐路径：** 至少完成 P0（优选至 P2）后再用平台结果回看 A34-R1 disposition。
- Executor **不得**把 Pause 写成 Closed/Done，也不得在未获 Human 授权时开始 P1 Swift / Accept ADR。

## Execution / KOS cadence

- **Docs / commit / push:** 可更新本 Assignment 与关联 docs 并 **本地 commit**；**ask before first push/PR**（无 ongoing draft push 授权）。首次对外动作须 Human 明示。
- **Gates:** **P0** = 接口草案 + 「Ice already satisfies / Wanxiang gaps」矩阵（docs only）→ **P1** Ice hooks → platform（Ice 行为不变）→ **P2** Wanxiang 迁到 platform → **P3** 删冗余 forks；其后才再审视 A34-R1 / ADR Accept（Accept 仍另授权）。本 Active 切片 **止于** 治理 + bring docs + cadence；**无** Swift until 另授权进入 P1。
- **PR policy:** 新 draft PR（**not** #101）；**#101 left alone**。勿复用 PR #101 分支。
- **Wanxiang P4:** **Paused**（shelved for Scheme Platform）；A34-R1 writeback later — Pause ≠ Closed/Done。
- **Non-claims this slice:** no ADR Accept；no Product Gate / TF；no Swift。

See also: [`../plans/scheme-platform-execution-kos-2026-09-09.md`](../plans/scheme-platform-execution-kos-2026-09-09.md).

## Handoff

- **Handoff Target:** Human Product Owner（Active 决策）；Active 后 Independent Architecture（P0/P1 边界）→ Independent Quality（P1/P2）→ Human（是否再开 ADR Accept）。
- **Required Handoff Content:** target plan；P0 矩阵；冻结 tip；Ice/Wanxiang regression 指针；与 Wanxiang P4 的边界声明；明确 non-claims。
- **Revalidation Trigger:** Human 撤销 Ice-as-reference；ADR 0034 正文决策变更；Wanxiang/Ice pin 变更；layout 产品合同变更。

## Evidence

- Target (Human Approved): [`../plans/scheme-platform-ice-reference-target-2026-09-09.md`](../plans/scheme-platform-ice-reference-target-2026-09-09.md)
- P0 interfaces: [`../plans/scheme-platform-p0-interfaces-2026-09-09.md`](../plans/scheme-platform-p0-interfaces-2026-09-09.md)
- Discovery layout-page UX (Human Approved; later Assignment): [`../plans/scheme-platform-discovery-layout-ux-2026-09-09.md`](../plans/scheme-platform-discovery-layout-ux-2026-09-09.md)
- P0 Ice↔Wanxiang matrix: [`../evidence/scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md`](../evidence/scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md)
- Prior matrix / gaps: cross-scheme contract；Wanxiang P4 gap inventory；coexistence plan（见 Required Inputs）

## Progress

| When | Slice | Outcome |
|---|---|---|
| `2026-09-09 Asia/Shanghai` | Gate 0 Active | Assignment Active；Wanxiang P4 Paused；branch `codex/scheme-platform-001`；ask-before-push |
| `2026-09-09 Asia/Shanghai` | **P0 start** | Begin docs-only interfaces + Ice/Wanxiang matrix (Ice-as-reference) |
| `2026-09-09 Asia/Shanghai` | **P0 complete** | Interfaces + matrix landed；Assignment/ACTIVE_WORK updated；**local commit only**（no push） |
| `2026-09-09 Asia/Shanghai` | Human deferral | Wanxiang nine-key productization deferred to later Assignment; P1/P2 must not enable; local docs + commit only |
| `2026-09-09 Asia/Shanghai` | Human P1↔Discovery split | **P1** = LayoutCapability + ResourceCapability/ownership seams (adapter lookup; Ice-only nine-key; Wanxiang `supportsNineKey=false`; Lua/OpenCC strategy APIs). **Discovery / layout-picker** = later Assignment (not yet drafted; separate Human Active). Local docs + commit only |
| `2026-09-09 Asia/Shanghai` | Human Discovery layout UX | Layout settings page A/B for **later Discovery Assignment**: A Confirmed (override > manifest > adapter; installed+supported); B Filename suggestions (try; unverified; **never auto-bind**; confirm→A). Filename never sole authority; RIME no official layout-naming constraint. Wanxiang nine-key still deferred (`wanxiang_t9*` may appear in B later). **P1 = query seams only — not this UI.** Local docs + commit only |
| `2026-09-09 Asia/Shanghai` | Human uninstall layout-fallback | When uninstall deletes scheme backing layout binding(s): **warn** → A-only rebind among remaining installed (override > Universe package manifest > adapter; **never** B) → prefer previously used > primary > stable default; else **26-key + Luna (`luna_pinyin`)** + clear invalid nine-key → then uninstall; Luna-only active-uninstall still applies. Manifest ≠ RIME built-in. Local docs + commit only |
| `2026-09-09 Asia/Shanghai` | Human SharedDefault decision | **End-state:** Ice-shaped **`privatePreset`** = reference SharedDefault mode for third-party schemes. **P1:** extract Ice `privatePreset` only; Wanxiang may temporarily keep skip/`consumePrelude` transitional. **P2:** Wanxiang migrates to `privatePreset` (same as Ice); `consumePrelude` **not** Wanxiang end-state. Luna may remain Prelude/builtin exception. Fidelity risk: Wanxiang preset migration needs product regression (not silent). Local docs + commit only |
| `2026-09-09 Asia/Shanghai` | Human Lua/OpenCC Ownership decision | Unified **ResourceOwnership**/ResourceCapability API (P1). **Long-term dual strategies:** `namedList` (Ice) + `exactHash` (Wanxiang) — **not** forced to one. **No** dangerous filename heuristics auto-removing lua/opencc; **no** whole-dir wipe. Settings: confirmed ownership/strategy honesty; optional user marking for third-party; heuristics only as confirm-gated hints if ever. OpenCC: Wanxiang may keep `admitted=false` (same API). **P1:** wire both strategies, behavior unchanged; **P2:** Wanxiang uses platform path keeping `exactHash`. Contrast vs SharedDefault: SharedDefault → `privatePreset` in P2; Ownership stays dual. Local docs + commit only |
| `2026-09-09 Asia/Shanghai` | Human Luna + readiness greying | **Luna:** always on **26-key Section A**; never on nine-key A; not a B filename suggestion; builtin exception; uninstall fallback already → 26+Luna. **Readiness:** confirmed-but-unready → **greyed in A with reason** (prefer grey over hide); click guides fix; **no direct binding** until ready. Uninstall auto-rebind = **ready** A only. Discovery Assignment scope; P1 seams only if needed for readiness query. Local docs + commit only |

## History

- `2026-09-09 Asia/Shanghai`: Human 批准 Ice-as-reference Scheme Platform 目标；Lifecycle = **Ready**；授权本地 docs（target + 本 Assignment + ACTIVE_WORK / Wanxiang P4 状态注记）。**未**授权 Active / Swift / push / ADR Accept。
- `2026-09-09 Asia/Shanghai`（稍后）: Human 选择 **(b)** — deferred Active for this Assignment；Lifecycle **仍 Ready**。Wanxiang P4（`SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001`）继续 **narrow A34-R1** in parallel without platform extract / Ice-as-reference P1–P3。**未**授权 Active / P1 Swift / push / ADR Accept。
- `2026-09-09 Asia/Shanghai`（Gate 0）: Human 授权本 Assignment **Active**；Pause `SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001`（shelved for Scheme Platform；A34-R1 仍 open — NOT Closed/Done）。冻结 tip `814abfd` / 分支 `codex/scheme-platform-001`（自 `origin/main` 新建；不用 PR #101）。切片 = 治理 + bring docs + embed Execution/KOS cadence；**ask before first push/PR**；新 draft PR（not #101）。**无** ADR Accept；**无** Product Gate/TF；**无** Swift。
- `2026-09-09 Asia/Shanghai`（P0 start）: 开始 P0 docs — platform interfaces/seams + Ice vs Wanxiang matrix（Ice-as-reference；对照 SchemaManagerTypes / RimeIceSharedDefaultAdapter / WanxiangLuaOwnership / Download+Installation Ice hooks）。
- `2026-09-09 Asia/Shanghai`（P0 complete）: 落盘 [`scheme-platform-p0-interfaces-2026-09-09.md`](../plans/scheme-platform-p0-interfaces-2026-09-09.md) 与 [`scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md`](../evidence/scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md)；更新 Progress/ACTIVE_WORK。**本地 commit only**；**未 push**；**无** ADR Accept；**无** Swift。
- `2026-09-09 Asia/Shanghai`（Human decision）: **Defer Wanxiang nine-key productization** to a later Assignment (not yet drafted). Scheme Platform P1/P2 must **not** enable Wanxiang nine-key; Ice `t9` remains reference shape; `wanxiang_t9*` may remain in install plan ownership; product capability stays false until that future Assignment. Recorded in Non-goals / Boundary / P0 interfaces / matrix（local commit only; no push）.
- `2026-09-09 Asia/Shanghai`（Human approved split）: **P1 (this Assignment)** = declarative LayoutCapability + ResourceCapability/ownership seams; replace hardcoded `isNineKeyCapable == t9` with adapter lookup preserving Ice-only nine-key answers; Wanxiang `supportsNineKey = false`; Lua/OpenCC ownership via strategy APIs. **Later Assignment (not yet drafted):** Installed Capability Discovery / layout-picker — dynamically enumerate installed schemes’ capabilities for layout UI (and similar honesty for Lua/OpenCC product surfaces); **separate Human Active** required. Wanxiang nine-key productization remains deferred (may ride Discovery later or stay further deferred). Recorded in Boundary / Non-goals / P0 interfaces / matrix / KOS（local commit only; no push）.
- `2026-09-09 Asia/Shanghai`（Human approved Discovery layout UX）: Layout settings page (26-key / nine-key / future) UX for **later Discovery Assignment** — **Section A Confirmed:** user override > package capability manifest > catalog adapter declaration; installed + `supported=true`. **Section B Filename suggestions (try):** weak filename/`schema_id` hints (e.g. t9/nine); labeled unverified; user may try; **never auto-write binding** from filename alone; successful/explicit confirm **promotes** to user override (A). Filename never sole authority; RIME has no official layout-naming constraint (wiki conclusion). Wanxiang nine-key productization still deferred; both `wanxiang_t9*` may appear in B later until productized. **P1 this Assignment** = capability query seams only — **not** this UI. Recorded in Non-goals / P0 Layout / [`scheme-platform-discovery-layout-ux-2026-09-09.md`](../plans/scheme-platform-discovery-layout-ux-2026-09-09.md) / KOS（local commit only; no push）.
- `2026-09-09 Asia/Shanghai`（Human approved uninstall layout-fallback）: When deleting a scheme that **backs current layout binding(s)** — (1) **warn** user (must not silent); (2) among **remaining installed**, find **confirmed A** supporters (user override > package capability manifest > catalog adapter; **never** auto-pick B filename suggestions); (3) if candidate → rebind (prefer previously used > primary > stable default); (4) else → **26-key + Luna (`luna_pinyin`)** and clear invalid nine-key binding if needed; (5) then proceed with uninstall; existing **Luna-only active-uninstall** rules still apply. **Package capability manifest = Universe convention, not RIME built-in.** Section B try-failure stubbed separately. Platform `onUninstallPrepare` / UninstallHooks consume this contract. Recorded in Boundary / Non-goals / P0 Layout uninstall hooks / [`scheme-platform-discovery-layout-ux-2026-09-09.md`](../plans/scheme-platform-discovery-layout-ux-2026-09-09.md) / KOS（local commit only; no push）.
- `2026-09-09 Asia/Shanghai`（Human SharedDefault decision）: SharedDefault **end-state** = Ice-shaped **`privatePreset`** as reference mode for **third-party** schemes. **P1:** extract Ice `privatePreset` only; Wanxiang may temporarily keep skip/`consumePrelude` as transitional adapter. **P2:** Wanxiang migrates to `privatePreset` (same mode as Ice); `consumePrelude` is **not** Wanxiang end-state. **Luna** may remain Prelude/builtin exception. **Fidelity risk:** Wanxiang preset migration needs **product regression** (separate from silent change). Recorded in Boundary P1/P2 / P0 SharedDefault / ice-reference / KOS（local commit only; no push）.
- `2026-09-09 Asia/Shanghai`（Human Lua/OpenCC Ownership decision）: Unified **ResourceOwnership** / ResourceCapability API (P1 extract). **Long-term dual strategies:** `namedList` (Ice reference) + `exactHash` (Wanxiang) — **not** forced to one. **No** dangerous filename heuristics auto-removing lua/opencc; **no** whole-dir wipe of lua/opencc. Settings: confirmed ownership/strategy honesty; optional user marking for third-party; heuristics only as confirm-gated hints if ever. OpenCC: Wanxiang may keep `admitted=false`; same API. **P1:** wire Ice+Wanxiang strategies, behavior unchanged; **P2:** Wanxiang uses platform path keeping `exactHash`. **Contrast vs SharedDefault:** SharedDefault Wanxiang → `privatePreset` in P2; Ownership stays dual strategy. Recorded in Boundary P1/P2 / P0 ResourceOwnership / matrix / ice-reference / KOS（local commit only; no push）.
- `2026-09-09 Asia/Shanghai`（Human Luna + readiness greying）: **Luna** always present on **26-key Section A**; **never** on nine-key A; **not** a B filename suggestion; **builtin exception**; uninstall fallback already → 26-key + Luna. **Confirmed-but-unready** (missing deps / not deployable / readiness fail) → **greyed in A with reason** (prefer grey over hide); click guides fix; **no direct layout binding** until ready. Uninstall auto-rebind only among **ready** A candidates. Discovery Assignment scope; **P1** only seams if needed for readiness query. Recorded in Boundary / Non-goals / P0 Layout / [`scheme-platform-discovery-layout-ux-2026-09-09.md`](../plans/scheme-platform-discovery-layout-ux-2026-09-09.md) / KOS（local commit only; no push）.
