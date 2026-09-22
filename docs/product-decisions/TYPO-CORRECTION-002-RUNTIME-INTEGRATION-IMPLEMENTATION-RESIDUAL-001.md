# Product Decision: TYPO-CORRECTION-002 runtime-integration implementation residual

> **Decision ID:** `PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001`
>
> **Decision:** `Accepted — bounded uncommitted controller/sidecar runtime snapshot, with named residuals`
>
> **Date:** `2026-09-21 Asia/Shanghai`

## Decision

Human Product Owner / Product Lead accepts the independently reviewed
uncommitted runtime-integration snapshot as a **bounded engineering package**.
Architecture **Conditional Accept** and Quality **Pass with conditions** are
accepted within that boundary. The named residuals below are accepted as
known, untested-but-bounded conditions of this snapshot.

This decision does not accept user-visible sentence recovery, does not
authorize publication, and does not close the implementation or parent
`TYPO-CORRECTION-002` Assignment.

| Input | Disposition |
|---|---|
| [Implementation evidence](../evidence/typo-correction-002-runtime-integration-implementation-001.md) | Accepted as exact-snapshot executor evidence |
| [Architecture review](../reviews/typo-correction-002-runtime-integration-implementation-architecture-review-2026-09-21.md) | Accepted as Conditional Accept of this snapshot |
| [Quality review](../reviews/typo-correction-002-runtime-integration-implementation-quality-review-2026-09-21.md) | Accepted as Pass with conditions of this snapshot |
| Exact identities | HEAD `4d1050f4b677494e06448cb40a83ef2da46d7b27` / tree `5f864a6f6f139810ed59c7e00ab6c33caad7e500` / tracked `git diff` SHA-256 `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b` |
| Original pure-Core checkpoint | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` remains retained and must not be reset |

Worktree retained:
`/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001`

## Accepted residuals

1. **F-01 invalidate-first gaps:** `handleTogglePage`, letter hot-path
   `refreshTypoCorrectionSuggestions`, canary/P3D1 install, and empty-composition
   mode toggle do not bump `recallEpoch` first. Page change is fail-closed by
   fence comparison. Yield after each sidecar return is accepted at the driver
   contract; `RunLoop.main.perform(inModes: [.default])` is untested.
2. **F-02 three-route adapter:** default wrap + `nil` epoch is accepted.
   MainActor-responsive / thread-affine no-bypass is unproven. Dual-gate /
   canary / P3D1 still install `CandidateProviderTypoCorrectionQuery`.
3. **F-03 second writer and empty/budget-stop:** recall path
   `applyTypoCorrectionRecallMaterial` is accepted. Hot-path
   `refreshTypoCorrectionSuggestions` remains a second Core writer.
   Empty / budget-stop is not a proven display no-op.
4. **Q-01:** `#ActorIsolatedCall` warning at
   `TypoCorrectionRecallCoordinator.swift:132`. Local TEST SUCCEEDED does not
   prove hosted CI will treat it the same.
5. **Identity-recipe:** AUTH full-content hash `3cf0d23c…` remains unreproduced;
   independent concatenation is `4b701835…`. HEAD / tree / tracked diff remain
   the binding identities.
6. **F-04 diagnostics** remains `tech_debt`. Real RIME, QA-001, INT-003, paired
   performance and `180 ms` remain `UNKNOWN`.

## Publication

Product does not request commit, push, PR or merge now. The exact uncommitted
worktree and reviews remain the reproducible checkpoint. Publication needs a
separate Authorization.

## Explicit non-decisions

This is not a Quality Gate, Product Gate, Release decision, publication,
commit, push, PR, merge, TestFlight, Release, QA-001, INT-003, performance
result, runtime enablement of `60/64` as the always-on first stage, or
Assignment Close.

**Decision source:** Human Product Owner / Product Lead, current task
instruction `接受` on `2026-09-21 Asia/Shanghai`.
