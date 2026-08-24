# Assignment: RELEASE-2026-0801-08 — 首发颜表情内容

**Policy version:** `1.0.0`
**Lifecycle status:** `Completed — Human Product Gate Passed; Closed pending merge`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed — Human Product Gate Passed; Closed pending merge` |
| **Phase** | Arch [`Pass`](release-2026-08-01-08-architecture-review.md)；Quality Q1 [`Pass with conditions`](release-2026-08-01-08-quality-review.md)；05 卡已接受；Human Gate [`Passed`](../evidence/release-2026-08-01-08-product-gate-2026-08-24.md)（iPhone 13 Pro / iOS 27.0，G-01…G-16） |
| **Non-claims** | 不是 Closed；不是可合并；不是 RC / TestFlight 上传；构建配置与 SHA 未报 |
| **Next** | 干净提交 / PR 前须跑与 CI 等价门禁（Q1-C-01）；05 可按已接受文案卡写颜表情 What to Test / 过 Gate 后的商店句 |
| **Residuals** | Q1-C-01 全套 CI；A30-P2-04 撕裂矩阵未做（常规路径 Gate Pass）；A30-P2-06 代码仍无 `.selected`（Human 报 VoiceOver 可用）；A30-P2-05 近形重复；Q1-C-04 26 键 chrome 合同测试 |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner decided that kaomoji content cannot be excluded from V1.0 and authorized the current Codex task to select and perform KOS-compatible remaining release execution roles in the active Codex task, `2026-07-20 Asia/Shanghai`; on `2026-08-23 Asia/Shanghai` authorized the current Grok task to start `RELEASE-2026-0801-08` under KOS; later the same day froze default `^_^`, first-party catalog, shared action for both `^_^` keys, and pending+candidate-bar interaction without cycle; still later the same day accepted ADR 0030 and authorized KeyboardCore implementation; on `2026-08-24 Asia/Shanghai` reported iPhone 13 Pro / iOS 27.0 G-01…G-16 success and thereby passed Human Product Gate.
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** ⌨️ Keyboard Experience Maintainer
- **Executor:** Current Grok task acting as ⌨️ Keyboard Experience execution thread
- **Environment Executor:** Current Grok task for simulator interaction operations; the Human Product Owner remains the physical-device interaction operator and final Product Gate
- **Human Dependency:** Human Product Owner — approves the bounded launch catalog, content policy and final product behavior
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward if storage, synchronization, privacy, user-data or cross-target contracts are proposed
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer
- **Supporting Domain:** 📱 App & Data Operations Maintainer only if a main-App content/settings surface is explicitly approved
- **Handoff Target:** Quality Reviewer, then Product Lead and task 05

## Boundary

- **Scope:** Define and deliver a bounded, offline launch catalog of kaomoji that the existing user-visible control can present and insert truthfully; cover selection, insertion, accessibility and supported-device behavior.
- **Non-goals:** No network catalog, user-generated/shared catalog, account, analytics, remote sync, learning/ranking system or unrelated keyboard redesign. No persistent user content without a separate Product/privacy/architecture decision.
- **Required Inputs:** [`RELEASE-2026-0801-02`](release-2026-08-01-02-scope-freeze.md), `UI_STYLE_GUIDE.md`, current nine-key chrome contract, `PRIVACY_POLICY.md`, `RELEASE_CHECKLIST.md`, and task 05 copy/screenshot requirements.

## Reassignment

- **Previous Executor:** Codex task named on the original 08 record
- **New Executor:** Current Grok task
- **Reason:** Human Product Owner started 08 after 06 executable polish, with discussion first
- **Effective date:** `2026-08-23 Asia/Shanghai`
- **Remaining work:** publication (commit / PR / Closed) is **not** authorized by this Gate. Q1-C-01 still blocks claiming merge-ready. Residual host-tear and `.selected` implementation gaps are accepted, not reopened.

## Proposed interaction (not frozen)

Human Product Owner proposed: tap 颜表情 → pending kaomoji in the host → compact candidate bar of common kaomoji → expand / swipe-down for more; like 九键 `，。？！` but **no same-key cycle**. Displacement: do not break punctuation, continuation, typo, T9 Path, or RIME composition.

Superseded for freezing purposes by [`PD-RELEASE-2026-0801-08-KAOMOJI-CATALOG`](../product-decisions/RELEASE-2026-0801-08-kaomoji-catalog.md). Still not implementation authority.

### Sequencing Decision

[`PD-RELEASE-2026-0801-EXTERNAL-TESTFLIGHT-CANDIDATE`](../product-decisions/RELEASE-2026-0801-external-testflight-candidate.md) places this implementation after the other necessary external-TestFlight preparation and before RC freeze. This is a sequencing decision only: it does not satisfy the catalog/source/license Entry Criteria and does not authorize implementation in the current governance-sync phase.

## Gates

- **Entry Criteria:** Executor and interaction operator named; Product Lead approves catalog source/licensing/content boundaries; insertion behavior and storage boundary are explicit; no required field is `UNKNOWN`.
- **Exit Criteria:** The control is no longer a no-op; catalog and insertion behavior pass accessibility/device checks; license/privacy/copy implications are handed to task 05; Quality records an explicit conclusion. **Device/a11y check:** Human Product Gate Passed `2026-08-24` ([`evidence`](../evidence/release-2026-08-01-08-product-gate-2026-08-24.md)) with accepted residuals A30-P2-04 / A30-P2-06. **05 copy:** Product-accepted [`card`](../evidence/release-2026-08-01-08-handoff-to-05-copy-constraints.md). **Quality:** Q1 Pass with conditions. Closed still requires a merge that carries the commit; this Gate does not merge.
- **Stop Conditions:** Catalog provenance or license is unclear; a network, persistence, sync or user-data requirement appears; input commit semantics regress; final behavior would require an unapproved major UI or architecture change.

## Handoff

- **Required Handoff Content:** approved catalog/provenance, interaction and insertion contract, changed files, tests, accessibility/device evidence, privacy/license assessment, screenshots, known limits and App Store copy constraints.
- **Revalidation Trigger:** catalog source, insertion behavior, persistence/network boundary, keyboard geometry, supported devices or release archive changes.
