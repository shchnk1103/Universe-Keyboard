# POST-COMMIT-CONTINUATION-001 Implementation Plan

> **Status:** Active
>
> **Start date:** `2026-07-15 Asia/Shanghai`
>
> **Assignment:** [`POST-COMMIT-CONTINUATION-001`](../assignments/post-commit-continuation-001.md)
>
> **Current source of truth:** [`Post-Commit Continuation Product Contract`](../POST_COMMIT_CONTINUATION.md) and [ADR 0017](../architecture/decisions/0017-ephemeral-post-commit-continuation.md)
>
> **Archive condition:** Archive after Product Review closes the Assignment and durable behavior moves to current architecture and release sources.

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
