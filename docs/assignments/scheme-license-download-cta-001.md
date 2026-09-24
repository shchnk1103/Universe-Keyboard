# Assignment: SCHEME-LICENSE-DOWNLOAD-CTA-001 — 统一第三方方案许可下载 CTA

**Policy version:** `1.0.0`
**Task ID:** `SCHEME-LICENSE-DOWNLOAD-CTA-001`
**Decision source / date:** [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md), `2026-09-23 Asia/Shanghai`
**Repository Change Type:** `Implementation` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | Human Product Gate **Pass with conditions**；`SLD-CTA-GATE-01`–`04` 均由 Product Owner 接受；见 [Product Decision](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md) |
| **Non-claims** | 不声称真实网络下载/RIME 部署成功；Simulator observation 仍为 Human-attested；Quality receipt 只绑定写回前 22-file package；无 commit / push / PR / merge / TestFlight / Release |
| **Next** | None for this Assignment；任何 commit 或 publication 另行授权 |
| **Residuals** | [Gate conditions](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md#accepted-evidence-conditions)：`SLD-CTA-GATE-01`–`04`，逐项处置见下表并保留在关闭记录 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Product Approver:** Human Product Owner
- **Authorization:** [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-001`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-001.md) — consumed for record + implementation
- **Domain Owner / Executor:** 📱 App & Data Operations Maintainer / current Grok session
- **Architecture Reviewer:** **Not Applicable** while the change stays on existing `SchemeLicenseView` + `startDownload`
- **Quality Reviewer:** GPT-6 Luna independent Quality reviewer；最终 22-file package [`Pass with conditions`](../reviews/scheme-license-download-cta-quality-revalidation-001.md)，仅对其绑定的写回前摘要有效
- **Human Product Gate:** [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001-PRODUCT-GATE`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md) — Pass with conditions；四项条件均接受

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 | Not applicable | |
| A-01 / B-01 | Adopted | 本 Assignment 与 AUTH |
| P-01 | Not applicable | |
| D-01 | Not applicable | |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Record + implementation | Authorized | Unify first-download CTA | Consumed AUTH |
| Independent Quality | Consumed | Exact 22-file package; Pass with conditions | [`revalidation`](../reviews/scheme-license-download-cta-quality-revalidation-001.md) |
| Human Product Gate | Consumed | Pass with conditions; close parent with all four conditions accepted | [`Gate AUTH`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PRODUCT-GATE-DECISION-001.md) → [`Product Decision`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md) |
| Commit / push / PR / merge | Not authorized | Isolated worktree only | New AUTH |

### Accepted Gate conditions retained at close

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `SLD-CTA-GATE-01` — no live network download or subsequent RIME deployment | Human Product Owner | `accept` | [Product Gate decision](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md#accepted-evidence-conditions) |
| `SLD-CTA-GATE-02` — Simulator model/OS and installed payload identity unbound | Human Product Owner | `accept` | [Human-attested observation and boundary](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md#bound-candidate-and-evidence) |
| `SLD-CTA-GATE-03` — nine non-CTA tests skipped in Quality Debug run | Human Product Owner | `accept` | [Quality evidence condition](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md#accepted-evidence-conditions) |
| `SLD-CTA-GATE-04` — candidate remains uncommitted and publication readiness unassessed | Human Product Owner | `accept` | [Publication boundary](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md#accepted-evidence-conditions) |

## Boundary

### Scope

1. `SchemaDownloadCardView` 及所有调用点（含 `RimeSettingsView`、遗留 `SchemaSelectionSection`）
2. 启用引导 `ActivationResourcePreparePanel` 首次下载 CTA
3. `KeyboardLayoutSettingsView` 为九键安装而弹出的同一许可证 sheet 底部按钮文案
4. 共享文案 owner + 指南一句 + 文案测试

### Non-goals

- 已安装管理网格、失败重试、下载引擎、Keyboard Extension、commit/push

### Stop Conditions

Stop if a download starts from the card without opening the sheet, if a second first-download CTA remains, or if work lands on the dirty main checkout.

## History

- `2026-09-23 Asia/Shanghai` — Human 用设置页双按钮截图要求统一为「查看许可并下载」→ sheet「同意并下载」。Assignment `Ready → Active`。隔离 worktree `/private/tmp/universe-keyboard-scheme-license-download-cta-001`。
- `2026-09-23 Asia/Shanghai` — Codex 修复 Swift 6 隔离错误：共享 CTA 文案移至 Foundation-only、`Sendable`、`nonisolated` 模型；设置详情卡、启用引导与九键安装流程共用同一许可证 sheet，九键资源缺失时不因历史许可接受状态而绕过 sheet。首次下载 CTA 只展示许可证，sheet 确认才接受并启动下载。`xcrun swift-format` format + strict lint 通过。App+Keyboard Debug `TEST SUCCEEDED`（iPhone 17 Pro / iOS 26.0 Simulator：UniverseKeyboardTests 389 passed / 9 skipped；KeyboardTests 15 passed / 0 failed）。Implementation `Active → Completed`。无 Quality / Product Gate / commit / push / merge / TestFlight / Release。
- `2026-09-23 Asia/Shanghai` — Human 同意先修复 Quality finding `SLD-CTA-Q-02`。Coordinator 将 Active Work 与 Dashboard 中“Quality 未授权”同步为当前有界 Quality 状态；状态镜像同步改变 tracked diff，原 Quality receipt 仍只绑定同步前精确快照，当前树 revalidation 需新 AUTH。P2 UI 回归缺口未改动。
- `2026-09-23 Asia/Shanghai` — Human 授权 child [`SCHEME-LICENSE-DOWNLOAD-CTA-REGRESSION-001`](scheme-license-download-cta-regression-tests-001.md) 补齐 `SLD-CTA-Q-01`。三入口共享流程路由回归完成；strict Swift format 通过；iPhone 17 Pro / iOS 26.0 App + Keyboard Debug 通过：UniverseKeyboardTests **379 passed / 9 skipped**，KeyboardTests **15 passed**，xcresult 合计 **394 passed / 9 skipped**。Child `Active → Completed`，AUTH consumed。计数区分校正由 [`SCHEME-LICENSE-DOWNLOAD-CTA-TEST-COUNT-RECONCILIATION-001`](scheme-license-download-cta-test-count-reconciliation-001.md) 记录。最终树 independent Quality revalidation 仍需新 AUTH；无 Product Gate / commit / push / merge / Release。
- `2026-09-23 Asia/Shanghai` — Human Product Owner 决定 **Pass with conditions** 并确认接受 `SLD-CTA-GATE-01`–`04`。依据 [`Product Gate Decision`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md) 与 consumed [`AUTH`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PRODUCT-GATE-DECISION-001.md)，父 Assignment `Completed → Closed`。接受条件保留在关闭记录；Quality revalidation 仍只绑定状态写回前 22-file digest `4f097b…f9f3e`，写回后的文档树未重新 Quality review。无 source/test 改动、commit、push、PR、merge、TestFlight 或 Release。
