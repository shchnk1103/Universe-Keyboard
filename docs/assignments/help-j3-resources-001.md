# Assignment: HELP-J3-RESOURCES-001 — 帮助内嵌 J3 资源准备

**Policy version:** `1.0.0`  
**Task ID:** `HELP-J3-RESOURCES-001`  
**Decision source / date:** [`PD-HELP-J3-RESOURCES-001`](../product-decisions/HELP-J3-RESOURCES-001-authorization.md), `2026-07-25 Asia/Shanghai`  
**Related packaging:** [`HELP-TIPKIT-001`](help-tipkit-001.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | Help 内嵌 J3 slim 资源准备已交付；等待 Quality 与 Human Product Gate |
| **Non-claims** | 不宣称真机雾凇下载、Quality 或 Product Gate 已过 |
| **Next** | Quality Reviewer → Human Product Lead（可选真机下载 smoke） |
| **Residuals** | 可选真机网络下载；Settings 仍拥有完整 RIME 管理 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** `PD-HELP-J3-RESOURCES-001`, `2026-07-25 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead for J3 embed decisions

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** Grok session as App & Data Operations / Main App UI
- **Environment Executor:** Grok for Simulator / unit tests; Human optional device download smoke
- **Human Dependency:** Optional physical-device 雾凇 download if network required for Product Gate
- **Architecture Reviewer:** Not Applicable unless App Group / deployment ownership changes
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer
- **Handoff Target:** Quality Reviewer → Product Lead

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-07-25 Asia/Shanghai` — J3 slim embed authorized.
- **Executor acknowledgement:** `2026-07-25 Asia/Shanghai` — Scope/Non-goals/Stop accepted on implement instruction.
- **Entry Criteria:** Met — PD recorded; roles named; no `UNKNOWN`.
- **Lifecycle:** `Ready → Active` on “按此写 PD/Assignment 并实现”; Product Lead authorized `Active → Completed` `2026-08-14 Asia/Shanghai` after Executor delivery.

## Boundary

### Scope

1. Document J3 completion (active scheme installed + deploy success), 雾凇 recommended, license gate, slim embed.
2. Extend `ActivationChecklistState` resource readiness to require active schema installed + deploy healthy.
3. Wire Help/`GuideTab` to `RimeSettingsStore` with real deploy/download observation.
4. Slim in-Help panel: select scheme → license (if needed) → download → set active & deploy; reuse existing store APIs and shared download/license UI where practical.
5. Unit tests for readiness; keep Settings full RIME page as authority for advanced management.

### Non-goals

- Full Rime settings clone in Help  
- Uninstall / force redownload / update in Help  
- Extension tips or Extension deploy  
- Auto-download without license  
- App Store submission  

### Required Inputs

- `PD-HELP-J3-RESOURCES-001`, `ONBOARDING_ACTIVATION.md`, `PD-HELP-TIPKIT-001`
- `GuideTab`, `RimeSettingsStore`, `LicenseView`, `RimeIceDownloadCardView` / download state
- ADR 0001, 0003

## Gates

### Entry Criteria

- [x] PD recorded; Executor named; no UNKNOWN

### Exit Criteria

- Help J3 shows selectable schemes with 雾凇 recommended  
- 雾凇 download disabled until license accepted  
- J3 incomplete until active scheme installed and deploy succeeded  
- Unit tests for readiness matrix  
- Settings still owns full management  

### Stop Conditions

- Deploy moved to Extension  
- License gate bypassed for 雾凇 download  
- Competing deployment state machine outside store  
- Claiming live Extension FA from main App  

## Handoff

- Changed files, test results, J3 flow summary, known limits (network for 雾凇 download on device)

## Completion Record

### Implementation (`2026-07-25 Asia/Shanghai`)

- PD + this Assignment recorded; `ONBOARDING_ACTIVATION` J3 updated.
- `ActivationChecklistState.isResourcesReadyForProgress` requires **active schema installed** + deploy success (not failed/in-progress).
- Help embeds `ActivationResourcePreparePanel`: select scheme (雾凇 recommended), license gate, download, activate+deploy; full RIME via Settings link.
- `GuideTab` / `ContentView` / `Settings` / `Home` wired with `RimeSettingsStore` observation.
- Evidence: `UniverseKeyboardTests/ActivationChecklistStateTests` **16/16 PASS** (iPhone 17 Pro Sim / iOS 26.5).
- **Remaining:** Human Product Gate (optional device 雾凇 download); Quality review.
