# Product Decision: HELP-J3-RESOURCES-001 — 帮助内嵌 J3 资源准备

**Decision ID:** `PD-HELP-J3-RESOURCES-001`  
**Lifecycle status:** `Recorded`  
**Date / timezone:** `2026-07-25 Asia/Shanghai`  
**Assignment:** [`HELP-J3-RESOURCES-001`](../assignments/help-j3-resources-001.md)  
**Related:** [`PD-HELP-TIPKIT-001`](HELP-TIPKIT-001-authorization.md), [`PD-RELEASE-2026-0801-03`](RELEASE-2026-0801-03-activation-authorization.md), [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)

## Authority

- **Product Approver:** Human Product Owner via explicit product lock in Grok session (`2026-07-25 Asia/Shanghai`): recommend 雾凇, user-initiated select with license gate, complete only when chosen scheme installed and deployed; slim embed preferred.
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 📱 App & Data Operations Maintainer.
- **Architecture / Quality:** Architecture review only if deployment ownership or App Group semantics change beyond ADR 0001/0003; Quality for independent evidence.

## Product Problem

Activation step J3 (prepare input resources) only told users to find RIME/deploy in Settings. New users had no in-Help actions while J1/J2 offered clear CTAs. Completing J3 on bare `rime_deployed` also under-specified “chosen scheme ready.”

## Bound Product Decisions

### 1. Presentation: slim embed in Help (not full RIME settings clone)

1. When `nextStep == prepareResources` (or user expands J3 for re-read while incomplete), Help shows a **slim resource-prepare panel** in the main App.
2. Panel reuses main-App store/actions (`RimeSettingsStore` / SchemaManager). No second deployment engine.
3. Full **设置 → RIME 方案设置** remains the complete management surface. Help must not offer uninstall, force redownload, update check, or advanced-input diagnostics.
4. Optional link: “在设置中管理全部方案.”

### 2. Default recommendation: 雾凇 (`rime_ice`)

1. UI marks 雾凇 as **推荐**.
2. Recommendation is not auto-download, auto-accept license, or forced selection.

### 3. User-initiated selection; license gate for open-source downloadables

1. User must **tap to select** a scheme (same gate intent as Settings).
2. For downloadable open-source schemes (雾凇): user must **view license** and **accept** before download is enabled — same semantics as Settings (`LicenseView` / `acceptLicense` / `startDownload`).
3. Builtin 朙月 (`luna_pinyin`) has no download license gate; user may select it and deploy.

### 4. J3 completion criteria (stricter observation)

J3 is complete only when **all** hold:

1. A scheme is the **active** schema for the keyboard (`rime_active_schema` / store active id).  
2. That active scheme is **installed**.  
3. Main-App **deployment succeeded** (`rime_deployed` / deployment success semantics) and is not currently failed or in-progress.

Not sufficient alone: weak “I prepared it” affirmation; deploy flag without installed active scheme.

### 5. Non-goals

- Extension TipKit or Extension deployment  
- Auto-download 雾凇 without license accept  
- Cloning full Rime settings Form into Help  
- Changing ADR 0001 deployment ownership  

## Relationship

Amends presentation and J3 readiness observation used by Help packaging under `PD-HELP-TIPKIT-001` without changing Full Access optionality or J1/J2/J4 success definitions in `PD-RELEASE-2026-0801-03`, except that J3 readiness is now scheme-installed + deployed as above.

## Change Policy

Changing recommended scheme, license gate, or J3 completion criteria requires Product Lead amendment of this Decision and revalidation of the Assignment.
