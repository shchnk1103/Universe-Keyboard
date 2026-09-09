# Assignment: SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001 — 主 App 活动卸载运行路由接线

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current Phase | P1 recovery contract、完整诊断序列与 live lease identity 证据已通过最终独立复审；后续真机门由 [`SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001`](scheme-delivery-runtime-route-device-001.md) 承接并已记录功能 Pass with conditions + docs tip `a007681`；Human 已授权 CI 绿后 undraft+merge #100 |
| Material non-claims | 不改 Luna-only 产品策略、资源所有权、archive 删除范围、RimeBridge/Extension 代码；merge 不意味着 TestFlight、Release、Product Gate Passed 或本 Assignment / `RTRD-*` Closed |
| Next handoff / decision | 集成工程片无新增编码动作。Human 已授权 docs tip + hosted CI 绿后 undraft+merge #100；`RTRD-01`/`RTRD-02` 仍另案；勿在本 Assignment 内扩展诊断 UI 或耗时测量 |
| Residuals | `RTRI-01` resolver/snapshot 同源、`RTRI-02` route-state rollback、`RTRI-03` 部署与暂存顺序、`RTRI-04` Extension/真机矩阵均为 `fix`；`RTRI-05` recovery-incomplete 语义、完整序列与 lease 证据已满足 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in-session approval “批准单独建立并集成”, `2026-09-09 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:**
  1. 在主 App `SchemaManager` active-uninstall transaction 中，从与 `RimeRuntimeSelection` 相同的 layout、binding、T9 readiness 与资源 fingerprint facts 构建已复审的 `RimeRuntimeRouteSnapshot`。
  2. 只在 pure reconciler 认定被卸载方案为 effective route 时，以 bindings → layout → legacy alias 的安全顺序应用其 route mutation，再在既有 commit lease 内完成 Luna 部署；遇到可恢复的部署或暂存失败时恢复完整 before-state 并重新部署原运行方案。
  3. 保留现有 inactive-uninstall 路径、既有 archive staging/commit/rollback 边界和 Ice 的 readiness invalidation；为集成行为补充主 App 测试与 content-free operation diagnostics。
  4. 以现有 `RimeRuntimeSelection` 验证持久化 after-state 的有效路由，不新增 Extension 生产逻辑。
- **Non-goals:**
  - 新 fallback scheme、peer-prefer、资源所有权/删除规则、Luna bundle、ADR 0026/0034 Acceptance；
  - RimeBridge 或 Keyboard Extension 源码修改、部署实现重写、网络下载、真实 App Group/用户数据操作；
  - 真机 CS09-10-02 运行、PR 发布、merge、TestFlight、Release 或 Product Gate。
- **Required Inputs:**
  - [Route proposal](../plans/scheme-delivery-active-uninstall-runtime-route-reconciliation-2026-09-08.md)
  - [Pure Core Assignment](scheme-delivery-runtime-route-contract-001.md) and its [Architecture review](../reviews/scheme-delivery-runtime-route-contract-001-architecture-review.md) / [Quality review](../reviews/scheme-delivery-runtime-route-contract-001-quality-review.md)
  - [CS09-10-02 device observation](../evidence/scheme-delivery-cross-scheme-cs09-cs10-device-2026-09-08.md), ADR 0001/0003/0004/0006/0026, `RIME_SCHEME_MANAGEMENT.md`
  - `SchemaManager+Installation`, `SchemaManager+T9Layout`, `RimeRuntimeSelection`, `RimeRuntimeRouteReconciler`, and `SchemaManagerTests`

## Assignment

- **Domain Owner:** 📱 Main App UI — schema install/deploy orchestration and App Group preference transaction correctness.
- **Executor:** Current Codex executor, limited to this Assignment Scope.
- **Environment Executor:** Current Codex executor for local strict format, KeyboardCore package tests, and no-signing Simulator test targets.
- **Human Dependency:** Not Applicable for source implementation and automated verification. Physical-device CS09-10-02 evidence is explicitly excluded and needs a separate Human Device Operator authorization.
- **Architecture Reviewer:** Independent 🏛️ Architecture & Knowledge Steward subagent; read-only, no implementation or Gate substitution.
- **Quality Reviewer:** Independent 🧪 Quality, Performance & Release Maintainer subagent; read-only, no implementation or Gate substitution.

## Gates

- **Entry Criteria:**
  - This Assignment has no `UNKNOWN` responsibility field.
  - Human has explicitly authorized establishment and implementation of this isolated integration slice.
  - The preceding pure Core contract has current format, full package and independent-review evidence.
  - The executor has confirmed that all production writes remain main-App-owned under the existing commit lease.
- **Exit Criteria:**
  - The active decision follows actual `RimeRuntimeSelection` rather than persisted layout or legacy active-schema alias alone.
  - Before Luna deployment, route mutation 以安全顺序写入 selected layout、legacy alias 和每个 affected binding；可恢复的部署/暂存失败在 lease 内恢复 complete before-state。
  - Existing inactive-uninstall behavior remains non-fallback and unaffected bindings stay unchanged.
  - Main App tests cover both active directions, readiness fail-closed, deployment failure, staging failure and post-state resolution; affected target tests and required format checks pass.
  - Independent Architecture and Quality reviews identify no open P0/P1 in this integration slice.
- **Stop Conditions:**
  - Required behavior changes Luna-only fallback, archive ownership/deletion rules, a persistent product preference, an Accepted ADR or Extension deployment boundary.
  - A route snapshot cannot be built from the same resolver facts without duplicating or contradicting `RimeRuntimeSelection`.
  - A failure would require touching real App Group/user data, physical device, RimeBridge/Extension code, or any Assignment responsibility becomes `UNKNOWN`.

## Failure Recovery Contract

`SchemaUninstallRecoveryError.rollbackIncomplete` means the archive installer could
not prove restoration of the original resource tree. It is not a normal staging
failure and must never be reported as a complete before-state restore.

The Main App therefore keeps the already-deployed Luna route, retains recovery
files and installation metadata, skips original-route redeploy, and stops the
uninstall before commit. Diagnostics must report the following fixed tuple
under the same operation:

| field | required value |
|---|---|
| `phase` | `staging` |
| `result` | `recovery_incomplete` |
| `isFailure` | `true` |

This is a fail-closed
terminal state: a later explicit recovery operation, not this uninstall
transaction, owns any retry after the resource tree becomes provable again.

For successful staging, `staging:started` records entry to the installer and
`commit:succeeded` records that `commitSchemaUninstall` returned. The latter
is the approved staging-completion evidence for this transaction; it does not
claim every internal cleanup step or crash-restart recovery succeeded.

This contract does not change archive ownership, remove extra files, or claim
crash/restart recovery. It narrows “failure restore” in this Assignment to
failures whose original resource tree remains provably deployable.

## Handoff

- **Handoff Target:** Independent Architecture and Quality reviewers, then Human Product Owner for a separately authorized physical-device matrix decision.
- **Required Handoff Content:** frozen diff; route-before/after and rollback table; exact test commands/results; structured diagnostic schema; residual dispositions; explicit non-claims.
- **Revalidation Trigger:** changes to `RimeRuntimeSelection`, layout-binding keys, T9 readiness, fallback policy, schema transaction/lease semantics, archive ownership, deployment behavior or reviewer P0/P1.

## History

- `2026-09-09 Asia/Shanghai`: Human Product Owner authorized this separate Assignment and its implementation after the pure KeyboardCore contract was implemented and independently re-reviewed. This record does not authorize device, publication, release or product acceptance actions.
- `2026-09-09 Asia/Shanghai`: Human Product Owner authorized reconciliation of the `rollbackIncomplete` contract. The accepted in-scope meaning is the fail-closed terminal state in “Failure Recovery Contract”; P1 evidence, independent review and all later gates remain required.
- `2026-09-09 Asia/Shanghai`: P1 final independent review passed. The seven frozen route sequences now prove their structured phase/result, operation UUID, bounded monotonic elapsed time, failure flag and route fields; deployment callbacks observe that same UUID while the commit lease is live. Local format, KeyboardCore, RimeBridgeTests, App/Keyboard tests and Debug/Release builds passed. This does not close `RTRI-01` through `RTRI-04` or authorize device, publication, merge or release work.
- `2026-09-09 Asia/Shanghai`: Human Product Owner authorized undraft+merge of PR #100 after docs sync (tip includes `a007681`) + hosted CI green. `RTRD-01`/`RTRD-02` remain out of scope for this merge; Product Gate / TestFlight / Release / ADR Accept remain unauthorized.
