# Assignment: APP-NOTIFICATIONS-001 — App 通知与操作提示统一管理

**Policy version:** `1.0.0`

**Decision source / date:** Human Product Owner approved the notification settings plan and explicitly authorized implementation, then revalidated independent RIME standard / Universe settings notification controls shared by both settings pages / `2026-07-15 Asia/Shanghai`

**Lifecycle status:** `Active`

**Repository change types:** `Contract`, `Architecture`, `Implementation`, `Test`, `Documentation`

## Authority

- **Assignment Authority:** Product Lead
- **Product Approver:** Product Lead acting under the human owner's explicit role delegation
- **Product Contract:** [`docs/APP_NOTIFICATIONS.md`](../APP_NOTIFICATIONS.md)
- **Architecture Decision:** [ADR 0017](../architecture/decisions/0017-app-notification-and-toast-settings.md)

## Boundary

- **Scope:** Add one main-App notification settings source of truth; expose the same RIME notification category and its RIME standard / Universe settings notification children in the global settings page and RIME sync page; centralize local-notification authorization, scope filtering, combined delivery and failure semantics; add an independent global operation-Toast switch; document and test migration, parent/child invariants, denied permission and foreground presentation.
- **Non-goals:** No remote push, badges, notification actions, critical/time-sensitive notifications, Keyboard Extension notification work, RIME hot-path changes or unrelated UI refactor.
- **Required Inputs:** `docs/UI_STYLE_GUIDE.md`, `docs/RIME_SYNC.md`, ADR 0014, current RIME sync notification implementation, global operation Toast implementation and Apple local-notification authorization behavior.

## Assignment

- **Domain Owner:** App & Data Operations Maintainer
- **Executor:** App & Data Operations Maintainer
- **Environment Executor:** Quality, Performance & Release Maintainer for build and simulator tests; human owner for physical-device notification-center and background-delivery evidence
- **Human Dependency:** Human owner for physical-device notification permission, foreground/background and Notification Center verification
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer

## Gates

- **Entry Criteria:** Product behavior is explicitly approved; notification categories, defaults, migration, denied-permission behavior and foreground Toast priority are unambiguous; worktree changes remain isolated from unrelated active work.
- **Exit Criteria:** One durable state source drives both settings surfaces; parent/category/scope invariants and migration pass tests; RIME delivery is centrally gated and accurately filtered or combined without changing actual sync settings; Toast disablement immediately suppresses all global operation Toasts; Swift 6 build and focused tests pass; physical-device checks are reported truthfully.
- **Stop Conditions:** Implementation requires notification work in Keyboard Extension, typed content in notifications, silent permission prompting, duplicated persisted switches or overlap with unrelated dirty-worktree files.

## Handoff

- **Handoff Target:** Product Lead for product review, then Quality Reviewer for physical-device evidence
- **Required Handoff Content:** implementation diff, automated test results, unexecuted device checks, migration behavior and residual iOS scheduling limits
- **Revalidation Trigger:** new notification category, remote push, badges/actions, changed defaults, new data in notification copy, Keyboard Extension participation or foreground presentation-policy changes
