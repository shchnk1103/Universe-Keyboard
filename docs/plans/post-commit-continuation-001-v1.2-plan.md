# POST-COMMIT-CONTINUATION-001 V1.2 Quality Expansion Plan

> **Status:** Archived
>
> **Closure date:** `2026-07-15 Asia/Shanghai`
>
> **Current source of truth:** [`POST_COMMIT_CONTINUATION.md`](../POST_COMMIT_CONTINUATION.md) and the active [`V1.3 plan`](post-commit-continuation-001-v1.3-plan.md)
>
> **Related ADR:** [ADR 0017](../architecture/decisions/0017-ephemeral-post-commit-continuation.md); this archived plan is no longer current development guidance
>
> **Start date:** `2026-07-15 Asia/Shanghai`
>
> **Authority:** Human Product Owner instruction to continue into the next stage
>
> **Branch:** `codex/post-commit-continuation-v1-2`
>
> **Baseline:** `b66a2f7` (`feat: establish continuation V1.1 quality baseline`)

## Objective

Improve the practical usefulness of post-commit suggestions by widening reviewed everyday coverage and protecting more ranking scenarios, while preserving the small, deterministic, on-device V1 architecture.

## Gate 0 — Preserve Accepted Boundaries

- [x] Start from the clean, Simulator-verified V1.1 commit on a new independent branch.
- [x] Revalidate the Assignment with the current Product authorization and no `UNKNOWN` fields.
- [x] Keep host context, persistence, learning, telemetry, downloaded corpora, network, models and RIME changes out of V1.2.

## Gate 1 — Curated Coverage Expansion

- [x] Expand the manually authored synthetic content pack from 100 to exactly 250 unique contexts.
- [x] Cover 15 declared everyday categories without personal names, private identifiers, advertising or unsafe content.
- [x] Prefer specific multi-character contexts where they prevent an overly generic suffix from dominating.
- [x] Keep candidate order deterministic, suggestions distinct and each list bounded by the existing eight-item ceiling.

## Gate 2 — Ranking Regression Expansion

- [x] Expand the representative benchmark from 30 to exactly 60 cases, with four cases in each declared category.
- [x] Require every registered context to return a reviewed relevant result within Top 3.
- [x] Protect important multi-step chains and longest-suffix specificity.
- [x] Preserve unknown-suffix empty behavior and all fail-closed resource validation.

## Gate 3 — Verification

- [x] Run the complete KeyboardCore suite.
- [x] Run app and keyboard Simulator tests plus strict Swift 6 Release Simulator build.
- [x] Verify resource inventory, JSON validity, duplicate constraints and repository diff hygiene.
- [x] Re-run representative `rime_ice` behavior on the iOS 27.0 iPhone 17 Pro Max Simulator.

## Gate 4 — Handoff

- [x] Update product, quality, release and history documentation with exact evidence and non-claims.
- [x] Record skipped physical-device/performance gates explicitly.
- [x] Commit the bounded V1.2 stage locally without pushing.

## Stop Conditions

- Any need to read host surrounding text or persist/log committed content.
- Any proposal to collect user selections or describe synthetic fixtures as real-user evidence.
- Resource growth beyond the existing 512 KiB / 4,096-entry ceilings without new startup and memory evidence.
- RIME session/deployment changes, unbounded key-path work or an unexplained test/build regression.
