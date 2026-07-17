# POST-COMMIT-CONTINUATION-001 Implementation Plan

> **Status:** Archived
>
> **Closure date:** 2026-07-16 Asia/Shanghai
>
> **Current source of truth:** `docs/POST_COMMIT_CONTINUATION.md`, Assignment POST-COMMIT-CONTINUATION-001, ADR 0017.
>
> **Related ADR:** ADR 0017
>
> **Guidance:** This plan is no longer current development guidance; V1.3 closed the Product Gate.

## Gate 0 — Isolation And Contract

- [x] Create `codex/post-commit-continuation-v1` from `origin/main` at `21e3455` in an independent worktree.
- [x] Publish Product Contract, Assignment and ADR with no `UNKNOWN` fields.
- [x] Exclude the original main worktree's staged typo-correction changes.

## Gate 1 — KeyboardCore

- [x] Add the provider/resource and bounded continuation state.
- [x] Update state only at successful final-commit boundaries.
- [x] Add a distinct candidate kind and chained selection behavior.
- [x] Add focused positive, negative, lifecycle and exactly-once tests.

## Gate 2 — Candidate UI And Setting

- [x] Present continuation only when composition is inactive and Chinese letters mode is eligible.
- [x] Reuse candidate-bar geometry and disable RIME paging semantics for continuation lists.
- [x] Add the default-on main-App setting and Extension lifecycle cache.

## Gate 3 — Verification And Knowledge

- [x] Run Core, app/keyboard, RimeBridge, strict-concurrency build and repository checks.
- [x] Record startup/key-path design comparison and resource bounds; physical-device measurements remain open.
- [x] Update architecture, privacy, debugging, release and changelog sources.
- [x] Record remaining physical-device gates and hand off for review.

## Remaining Gate

The automated implementation is complete. The Assignment remains `Active` until a physical device verifies candidate-bar behavior, representative chaining, setting refresh, lifecycle clearing and comparable startup/key-path/memory evidence.
