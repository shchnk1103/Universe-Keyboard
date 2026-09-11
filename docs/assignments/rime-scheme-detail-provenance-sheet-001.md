# Assignment: RIME-SCHEME-DETAIL-PROVENANCE-SHEET-001 — 方案信息入口收纳版本与下载来源

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Current phase** | Human device visual Pass. Isolated commit `19de5e4` on `grok/rime-scheme-detail-provenance-sheet-001` from `origin/main`. Push/PR in progress. |
| **Non-claims** | No download/install/deploy behavior change; no Discovery UI; no Scheme Platform P1-5; no Keyboard Extension; no Product Gate / TestFlight / Release / merge |
| **Next** | Feature-branch push + PR. Merge remains separately gated. |
| **Residuals** | None |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in-session, `2026-09-12 Asia/Shanghai` — authorized the provenance-sheet product contract after a no-code alignment pass; asked to record an Assignment before implementation
- **Product Approver:** Human Product Owner acting as Product Lead

## KOS v0.8.0 optional-contract selection

This Assignment does **not** opt into KOS 2.2 advisory contracts. Omitted contracts remain outside this record.

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | Presentation-only; no observation claim |
| A-01 / B-01 authorization chain and briefing | Not applicable | Human in-session Product Decision is recorded here; no Envelope/receipt chain |
| P-01 publication facts | Not applicable | This Assignment did not opt into P-01; commit/PR identity is still recorded in History |
| D-01 final-documentation receipt | Not applicable | No Close/publication packet in this slice |

## Boundary

- **Scope:**
  1. Main-App scheme **detail** page only (`RimeSchemaDetailView` in `Universe Keyboard/Views/Settings/RimeSettingsView.swift` and any small extracted helper/tests it needs).
  2. Keep the **方案信息** summary on the detail page (name, source/current badges, description, compact metrics). Make the **entire** 方案信息 block tappable.
  3. Add a trailing / top-trailing tap affordance: one SF Symbol (preferred `info.circle`) in a **neutral** color (`.secondary` / tertiary label — not brand accent, not the 内置/开源 capsule color). VoiceOver must expose that the block opens 版本与下载来源.
  4. On tap, present a **bottom sheet** (`.sheet` + `presentationDetents` + visible drag indicator, matching existing main-App sheets such as diagnostics route detail). Sheet content is **only** the current 版本与下载来源 rows; do not move download/manage/license/advanced-input actions into the sheet.
  5. **One row set for every catalog scheme**, including builtin Luna and any future third-party catalog entry. Do **not** gate the sheet or the row set on `schemaID` or on `isDownloadable` visibility. Derive values from catalog/distribution/source-variant/receipt already owned by `SchemaManager` / `RimeSettingsStore`.
  6. Builtin / no-distribution schemes fill the same rows with honest copy: **随 App 内置** or **不适用** (see Product contract below). Downloadable schemes keep their existing unresolved/verified placeholders (`下载时自动选择` / `下载完成后显示` / `下载后验证` / `SHA-256 已验证`).
  7. Future third-party schemes apply automatically when they are added to `RimeSchemeCatalog` with or without `distribution`. No new `if schemaID == …` branches.
  8. Update `docs/RIME_SCHEME_MANAGEMENT.md` scheme-detail UX to match. Add `CHANGELOG.md` on implementation. Add focused tests for the row-mapping helper so builtin vs downloadable vs verified-receipt cases stay catalog-driven.

- **Non-goals:**
  - Keyboard Extension UI
  - Download, install, deploy, uninstall, license, or source-selection **behavior**
  - Scheme Platform Discovery UI / layout-picker (`SCHEME-DELIVERY-SCHEME-PLATFORM-001` P1-5 and later Discovery Assignment)
  - ADR 0034 Accept, Product Gate, TestFlight, Release
  - Merge / Release unless separately authorized
  - Committing this UI onto `codex/scheme-platform-001` / PR #102
  - Redesigning 下载 / 管理 / 高级输入功能 sections
  - Per-scheme special-case copy beyond the two fill rules (builtin vs distribution-backed)

- **Required Inputs:**
  - This Assignment’s Product contract
  - `docs/RIME_SCHEME_MANAGEMENT.md`
  - `docs/UI_STYLE_GUIDE.md` (main App Form, sheets, neutral palette, `AppTokens` / existing components)
  - `docs/playbooks/main-app-ui.md`
  - `Universe Keyboard/Views/Settings/RimeSettingsView.swift`
  - `SchemaManager` catalog / `sourceVariant` / `manifestVersion` / `hasVerifiedReceipt`
  - Existing sheet pattern: `DiagnosticsLogContentView` (`.presentationDetents` + drag indicator)

## Assignment

- **Domain Owner:** App & Data Operations Maintainer (Main App UI)
- **Executor:** Current Grok session
- **Environment Executor:** Current Grok session for Simulator `swift-format` + targeted `UniverseKeyboardTests` / scheme build as required by the changed files. Physical-device operator is **Not Applicable** for this presentation slice.
- **Human Dependency:** Not Applicable for remaining coding — Human Product Owner already confirmed `Ready` and authorized implementation (`2026-09-12 Asia/Shanghai`). Visual accept after implementation is a handoff, not an Entry blocker.
- **Architecture Reviewer:** Not Applicable — presentation-only; no ADR, App Group, deploy, or Extension boundary change. UI_STYLE_GUIDE compliance stays with Executor.
- **Quality Reviewer:** Current Grok session for the row-mapping tests and local lint/build required by changed Swift. Independent Quality / Product Gate is **Not Applicable** unless Human later requests a review slice.
- **Product Approver:** Human Product Owner
- **Handoff Target:** Human Product Owner — implementation report, visual check of Luna / Ice / Wanxiang detail pages, then a separate publish decision

## Product contract (locked)

### Interaction

| Surface | Contract |
|---|---|
| Entry | Whole **方案信息** block is the control. Trailing/top-trailing `info.circle` (or equally quiet system symbol) in `.secondary` signals tappable. |
| Sheet | Bottom sheet; title **版本与下载来源**; only provenance rows + existing footer intent (“App 仅在你开始下载后轻量选择来源…” remains for distribution-backed schemes; builtin may use a shorter honest footer such as “此方案随 App 内置，无需下载来源。”) |
| Page after change | 方案信息 summary stays; the inline **版本与下载来源** Form section is removed from the detail page |

### Shared rows (all schemes)

| Row | Distribution-backed (`entry.distribution != nil`) | Builtin / no distribution |
|---|---|---|
| 版本 | `manifestVersion` else `未知` | installed/`schema.version` else **随 App 内置** |
| 下载来源 | variant `displayName` else `下载时自动选择` | **随 App 内置** |
| 下载地址 | URL else `下载完成后显示` | **不适用** |
| 上游版本 | `upstreamRevision` else `下载完成后显示` | **不适用** |
| 归档大小 | formatted `expectedByteCount` else `下载完成后显示` | **不适用** |
| 归档 SHA-256 | hash else `下载完成后显示` | **不适用** |
| 完整性 | `SHA-256 已验证` or `下载后验证` | **不适用** |

Do not hide rows for builtin schemes. Do not invent GitHub URLs or hashes for Luna.

## Gates

- **Entry Criteria:**
  1. This Assignment record is complete (no `UNKNOWN` required fields). **Met.**
  2. Human Product Owner confirms `Ready` and authorizes implementation start. **Met** `2026-09-12 Asia/Shanghai`.
- **Exit Criteria:**
  1. Luna, Ice, and Wanxiang detail pages share the same 方案信息 → sheet interaction.
  2. Inline 版本与下载来源 section is gone from the detail Form.
  3. Row mapping is catalog/distribution-driven; adding a future catalog scheme does not require a new UI branch.
  4. Tests cover builtin fill, downloadable unresolved fill, and verified-receipt fill.
  5. `docs/RIME_SCHEME_MANAGEMENT.md` and `CHANGELOG.md` match the shipped UI.
  6. Changed Swift passes `swift-format lint --strict`.
- **Stop Conditions:**
  - Any request to change download/source-selection/deploy behavior
  - Schema-ID special-casing (`rime_ice` / `luna_pinyin` / `wanxiang` UI forks)
  - Folding this into Scheme Platform Discovery UI
  - Merge / Release without a new Human authorization
  - Mixing this slice into Scheme Platform #102

## Handoff

- **Required Handoff Content:** files changed; row-mapping location; test names/results; format/lint; docs updated; what was not verified (device screenshots unless Human asks)
- **Revalidation Trigger:** Product changes the row set, icon/color, or sheet vs push navigation; catalog metadata shape changes; this work is asked to ride Discovery UI or Scheme Platform P1-5

## History

- `2026-09-12 Asia/Shanghai` — Human: no-code alignment, then authorized the contract (whole 方案信息 tappable + trailing icon; sheet = provenance only; builtin same rows with 随 App 内置 / 不适用; future third-party schemes inherit automatically) and asked to write this Assignment before code.
- `2026-09-12 Asia/Shanghai` — Human: 批准进入 Ready，并开始实现. Lifecycle `Assigned` → `Ready` → `Active`.
- `2026-09-12 Asia/Shanghai` — Implementation: tappable 方案信息 + provenance sheet; `SchemeProvenancePresentation` catalog fill; 6 `SchemeProvenancePresentationTests` passed on iPhone 17 Pro / iOS 26.0. Markdown link check `--base origin/main --head HEAD` PASS (15 files). No push.
- `2026-09-12 Asia/Shanghai` — Human: 真机目视效果很好；批准按 KOS 继续下一步。Device visual Pass. Next authorized slice = isolated feature-branch commit + push + PR; **no merge**.
- `2026-09-12 Asia/Shanghai` — Isolated commit `19de5e4` on `grok/rime-scheme-detail-provenance-sheet-001` (base `origin/main` `ecbd6b7`). Not on `codex/scheme-platform-001`.
