# Assignment: SCHEME-DELIVERY-RUNTIME-ROUTE-CONTRACT-001 — 有效运行路由卸载契约修订

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Reviewed |
| Current Phase | 纯 KeyboardCore P1/P2 契约修订、严格格式检查、完整 package 测试和独立 Architecture/Quality 复审均已完成；已移交独立主 App 集成 Assignment |
| Material non-claims | 不接入 `SchemaManager`；不改 App Group 持久化、部署、暂存、RimeBridge、Keyboard Extension 或真机矩阵；不改变 Luna-only 回退产品策略 |
| Next handoff / decision | [SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001](scheme-delivery-runtime-route-integration-001.md) 已获 Human 授权；其单独界定 snapshot builder、事务、部署/rollback、Extension 与设备矩阵 |
| Residuals | 纯 Core 无 open P0/P1；调用方仍须从同一 resolver/capability Source of Truth 提供 effective route 与 availability，后续还需验证 App Group 原子事务、部署/rollback、Extension 和 CS09-10-02 双向真机矩阵 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in-session approvals “批准建立Assignment” and “批准实施”, `2026-09-08 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:**
  1. 仅修订 `Packages/KeyboardCore` 中的 active-uninstall effective-route 输入、回退 descriptor 完整性校验、失败结果分类，以及为后续持久化回滚提供的纯数据快照契约。
  2. 用确定性单元测试冻结 26/9 键、Ice/Wanxiang、`t9 → rime_ice` 逻辑依赖、readiness fail-closed effective route、无关偏好、future descriptor、malformed/duplicate descriptor 和 inactive-uninstall 行为。
  3. 在每次修订后由独立 🏛️ Architecture & Knowledge Steward 与 🧪 Quality, Performance & Release Maintainer 只读复审。
- **Non-goals:**
  - `SchemaManager`、`UserDefaults`、App Group、commit lease、部署、stage/commit/rollback 实现；
  - RimeBridge、Keyboard Extension session/UI、真机、PR undraft/merge、TestFlight、Release 或 Product Gate；
  - 新 fallback scheme、peer-prefer 策略、ADR 0026/0034 Acceptance 或资源所有权变更。
- **Required Inputs:**
  - [Active-uninstall route proposal](../plans/scheme-delivery-active-uninstall-runtime-route-reconciliation-2026-09-08.md)
  - [CS09-10-02 failing device evidence](../evidence/scheme-delivery-cross-scheme-cs09-cs10-device-2026-09-08.md)
  - [ADR 0026](../architecture/decisions/0026-layout-bound-rime-scheme-selection.md)
  - [Independent Architecture review](../reviews/scheme-delivery-runtime-route-contract-001-architecture-review.md) and [Independent Quality review](../reviews/scheme-delivery-runtime-route-contract-001-quality-review.md)
  - `RimeRuntimeSelection`, `RimeRuntimeRouteReconciliation`, and their KeyboardCore tests
  - `keyboard-core.md`, `coordinator.md`, and `test-release.md`

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer — pure KeyboardCore route/state contract correctness.
- **Executor:** Current Codex executor, limited to a later explicit implementation authorization and this Assignment Scope.
- **Environment Executor:** Current Codex executor for local `swift-format` and KeyboardCore package tests; no simulator or device operation is assigned.
- **Human Dependency:** Human Product Owner must explicitly authorize implementation after this Assignment is established, and separately authorize any later cross-layer integration.
- **Architecture Reviewer:** Independent 🏛️ Architecture & Knowledge Steward subagent; read-only, no implementation or Gate substitution.
- **Quality Reviewer:** Independent 🧪 Quality, Performance & Release Maintainer subagent; read-only, no implementation or Gate substitution.

## Gates

- **Entry Criteria:**
  - This Assignment has no `UNKNOWN` responsibility field.
  - Human has issued a separate explicit implementation authorization.
  - The executor has recorded the current isolated-worktree status and bound review findings to the exact diff under review.
  - The pure contract identifies the effective route from the same resolution facts as `RimeRuntimeSelection`; a persisted layout preference alone is insufficient.
- **Exit Criteria:**
  - Active effective-route, inactive-uninstall, malformed snapshot and future-slot outcomes are distinct and tested.
  - A fallback never targets the removed schema; fallback slot/layout/schema identity is validated before any mutation exists.
  - The pure mutation carries enough pre-mutation route state for a later Main-App transaction to restore the complete route state after deployment or staging failure.
  - Strict format and full KeyboardCore package tests have current evidence.
  - Independent Architecture and Quality reviews record no open P0/P1 for this pure slice.
- **Stop Conditions:**
  - Fix requires changing Luna-only fallback policy, user preference retention policy, or an Accepted ADR.
  - Fix requires reading/writing App Group state, deployment, session work, filesystem mutation or UI behavior.
  - Effective-route facts cannot be shared with `RimeRuntimeSelection` without duplicating or contradicting its resolver.
  - Any Assignment responsibility becomes `UNKNOWN`, review independence is lost, or a reviewer finds an unaddressed P0/P1.

## Handoff

- **Handoff Target:** 🏛️ Architecture & Knowledge Steward and 🧪 Quality, Performance & Release Maintainer for independent re-review; after both pass, Human Product Owner decides whether to create a separate 📱 App & Data Operations integration Assignment.
- **Required Handoff Content:** exact diff and worktree status; state-input/output table; focused and full test commands/results; open residuals; explicit non-claims; reviewer findings and dispositions.
- **Revalidation Trigger:** changes to ADR 0026, `RimeRuntimeSelection`, layout-binding keys, fallback policy, T9 readiness contract, any persistence/deployment boundary, or reviewer conditions.

## History

- `2026-09-08 Asia/Shanghai`: Human authorized delivery of a pure KeyboardCore route seam and tests. The initial delivery passed `swift-format` and `KeyboardCore` `1082/1082`; [independent Architecture](../reviews/scheme-delivery-runtime-route-contract-001-architecture-review.md) and [independent Quality](../reviews/scheme-delivery-runtime-route-contract-001-quality-review.md) each returned `Pass with conditions`. Their P1/P2 findings are not treated as closed.
- `2026-09-08 Asia/Shanghai`: Human approved establishing this Assignment. That approval created the task record without authorizing remediation implementation.
- `2026-09-08 Asia/Shanghai`: Human Product Owner explicitly approved implementation. Assignment lifecycle changed to `Active` for the pure KeyboardCore P1/P2 remediation only; cross-layer integration, merge, device work, TestFlight and Release remain separately unauthorized.
- `2026-09-09 Asia/Shanghai`: 纯 KeyboardCore 实现已完成。`swift-format lint --strict` 通过；focused route suite `19/19` 与完整 KeyboardCore `1095/1095` 通过。独立 Architecture 与 Quality post-implementation reviews 均为 `Pass with conditions`，且纯 slice 无 open P0/P1。Assignment 保持 `Active`，不把该证据升级为主 App 接线、CS09-10-02 修复、merge 或 Release。
- `2026-09-09 Asia/Shanghai`: Human Product Owner approved the separate main-App integration Assignment. 本纯 Core Assignment 的 required reviews 已产生结论，lifecycle 变为 `Reviewed`；后续跨层结果由新 Assignment 负责，仍未构成 Product Gate 或 CS09-10-02 closure。
