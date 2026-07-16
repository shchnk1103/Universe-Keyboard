# Assignment: KEYBOARD-LAYOUT-9KEY-001 — 26 键 / 9 键布局切换

**Policy version:** `1.0.0`

**Lifecycle status:** `Closed`

**Repository change types:** `Contract`, `Documentation`, `Evidence`, `Implementation`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Stable repository Product Decision [`PD-KEYBOARD-LAYOUT-9KEY-001`](../product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md), recorded `2026-07-16 Asia/Shanghai`.
- **Product Approver (Assignment / Product Gate):** Product Lead under `docs/ASSIGNMENT_POLICY.md` (KOS 2.0). Human Product Owner is **not** the Product Lead role; they act as Human Dependency for device capture where required.
- **Product Plan (non-authority input):** [`docs/plans/keyboard-layout-9key-implementation-plan.md`](../plans/keyboard-layout-9key-implementation-plan.md)
- **Architecture Decision:** [ADR 0018](../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md)
- **Product Gate Decision:** [`PG-KEYBOARD-LAYOUT-9KEY-001`](../evidence/keyboard-layout-9key-001-product-gate-decision.md) — **PASS**, `2026-07-16 Asia/Shanghai`

## Acknowledgement And Lifecycle History

- **Executor acknowledgement:** `2026-07-16 Asia/Shanghai` — Assignment, ADR, T9 Spike, stop conditions accepted.
- **Spike gate:** Codex re-review-2 authorized `Ready -> Active` for plan steps 3–10.
- **Implementation code-review:** Codex `codex-implementation-rereview-3.md` — **Code Review Approved**.
- **Device evidence:** Human Product Owner captured `docs/evidence/keyboard-layout-9key-001/product-gate/20260716-device/` (Human Dependency satisfied).
- **Product Gate:** Product Lead `PG-KEYBOARD-LAYOUT-9KEY-001` — **PASS**; Assignment `Active → Completed → Reviewed → Closed`.

## Assignment

- **Domain Owner:** RIME Platform Maintainer (primary — T9 schema, effective schema selection, deployment ownership and fixed-librime compatibility)
- **Executor:** Grok (bounded packages under RIME Platform, Input Intelligence, Keyboard Experience, App & Data Operations)
- **Environment Executor:** Grok for Spike/simulator/builds; Human Product Owner for physical-device keyboard-extension capture
- **Human Dependency:** Human Product Owner — physical-device operation and screenshot capture (**satisfied** `2026-07-16`)
- **Architecture Reviewer:** Architecture & Knowledge Steward via Codex review handoff
- **Quality Reviewer:** Quality, Performance & Release Maintainer via Codex review handoff
- **Product Approver:** Product Lead
- **Handoff Target:** Closed — no further handoff required for V1 scope

## Boundary

### Scope (delivered)

1. Assignment + verifiable Product Decision Source.
2. ADR 0018 binding base vs effective scheme, versioned T9 readiness, fail-closed lifecycle.
3. Keyboard-layout domain documentation and index routing.
4. Hardened T9 Spike on pinned librime with transferable archive.
5. Product implementation: layout settings, readiness, effective selection, enable/deploy/smoke, T9 semantics, Extension nine-key, main-App UI, tests/builds.
6. Section 13 / implementation handoff + Codex implementation re-reviews through rereview-3.
7. Physical-device Product Gate evidence package.

### Non-goals (unchanged; still out of scope)

- English nine-key / multi-tap; swipe letter selection; independent nine-key for 朙月.
- Live layout hot-switch while keyboard remains visible.
- Librime vendor upgrade or Extension-side RIME deploy.
- Raw-digit host commit; new persistence of raw digits/dict/composition.

## Gates

### Exit Criteria — closure check

| Criterion | Status |
|---|---|
| Spike archived with logs/hashes on harness commit | **Met** |
| Implementation under ADR 0018 complete | **Met** (`5a1c407` + prior feat commits) |
| Fail-closed 26-key on enable/runtime failures (code-reviewed) | **Met** |
| Architecture/Quality independent conclusions | **Met** (Codex rereview-3) |
| Product Gate independent conclusion | **Met** (`PG-KEYBOARD-LAYOUT-9KEY-001` PASS) |
| Device interactive evidence | **Met** (`product-gate/20260716-device/`) |

### Stop Conditions

None active. Future English nine-key / vendor upgrade / deployment-boundary change requires a **new** Assignment.

## Handoff

- **Status:** Complete for V1.
- **Revalidation Trigger:** Spike regression, librime/vendor change, deployment-boundary change, product decision for English nine-key or live hot-switch, or conflict with ADR 0001/0004/0006/0018.

## Completion Record (Product Lead)

| Item | Result |
|---|---|
| Lifecycle | **`Closed`** |
| Code-review gate | Approved — `keyboard-layout-9key-001-codex-implementation-rereview-3.md` |
| Product Gate | **PASS** — `keyboard-layout-9key-001-product-gate-decision.md` |
| Device archive | `docs/evidence/keyboard-layout-9key-001/product-gate/20260716-device/` |
| Implementation lineage | Feature branch `feature/keyboard-layout-9key-spike`; code-review commit `5a1c407` |
| Accepted residuals | No dedicated T4 delete screenshot; failure-path device matrix not fully photographed — accepted for V1 per Product Gate decision |

## Current Evidence Status (final)

- **Spike:** PASSED on harness `337dd30…` (see tracked archive under `docs/evidence/keyboard-layout-9key-001/`).
- **Implementation reviews:** Codex review + rereview + rereview-2 + rereview-3 (immutable).
- **Product Gate:** **PASS** — Product Lead `2026-07-16 Asia/Shanghai`.
- **Physical-device gate:** **Closed** (Human Dependency capture satisfied; Product Lead acceptance recorded).
