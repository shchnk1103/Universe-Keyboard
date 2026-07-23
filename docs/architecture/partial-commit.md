# Partial Commit Architecture

> Typo Benchmark v1.0 Integration Contract and Case identities are defined only in [`../TYPO_BENCHMARK_REGISTRY.md`](../TYPO_BENCHMARK_REGISTRY.md), including `TC-CTR-INT-008...012` and `TC-CASE-INT-008...013`. This document remains the authority for current Partial Commit architecture and product boundary.

This document records the completed Partial Commit milestone and the current product boundary. It is a merge-readiness reference, not a roadmap for new features.

## Product Decision

Typo correction Partial Commit keeps Delete restore behavior for now:

- Selecting an eligible correction candidate may create a reversible checkpoint.
- First Delete restores the exact original typo input.
- Continued typing invalidates the checkpoint, so Delete resumes normal composition deletion.

This behavior is accepted for the current Chinese input flow. Do not continue optimizing it in this milestone. Re-evaluate the restore model when English input mode architecture is revisited, because English composition expectations may require a different undo model.

## Feature Matrix

| Capability | Status | Notes |
|---|---|---|
| Normal RIME Partial Commit | implemented | Selecting a shorter normal RIME candidate inside an active composition keeps the remaining composition active. |
| Delete Restore | implemented | A single checkpoint restores the previous raw RIME input by rebuilding and replaying the session. |
| Typo Partial Commit V1 | implemented behind flag | Eligible high-confidence single-character substitution corrections can reuse the Partial Commit pipeline. |
| Phase 3 V2 Stabilization | completed | Added tests for fallback boundaries, lifecycle behavior, paging stability, final commit, and parity with normal RIME Partial Commit. |
| Feature Flag | default off | `isTypoCorrectionPartialCommitEnabled == false` in production. Tests may enable it explicitly. |
| T9 Path residual-B cursor (004 Gate 5) | implemented + Human Pass | After user Path-select stack + candidate partial: peel `K=min(CJK, stack)` syllables (slots follow syllables); soft-select next user-chosen Path syllable; unselected tail (`wo…`) has no forged select. PD: [`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md). |

## T9 Path × Partial Commit (004 residual-B)

When `usesT9InputSemantics` and the user has Path-confirmed syllables:

1. **Authority for advance** is the user Path stack + CJK step count `K` — not comment / `sel_*` / inventing digit cuts without a stack.
2. **Digit consumption** follows peeled syllable letter widths on Core `sourceDigits`.
3. **Path Bar** focuses the next remaining user-stack syllable and restores soft-select only if the user previously Path-selected it (or 选拼音). Never auto-select unselected remainder.
4. Nested single-syllable pure-digit cases (e.g. `qiu'53` →「球」→ remaining `5`) still use shortened-remainder identity, not residual-B multi-stack cursor.
5. Host remaining preedit must not expose internal T9 digits.

Evidence: remediation §28–§30; PR [#28](https://github.com/shchnk1103/Universe-Keyboard/pull/28) on `main`.

## Current Boundaries

Typo correction Partial Commit may only run when all eligibility checks pass:

- The internal feature flag is enabled.
- The correction is a high-confidence single-character substitution already produced by the current typo engine.
- The corrected RIME session can select the intended candidate on the current page.
- Candidate selection leaves non-empty remaining composition.
- Delete restore can replay the exact original user input.

These cases stay full commit:

- Repeated-final deletion, such as `nihaoo -> nihao`.
- Multi-edit or low-confidence corrections.
- Missing corrected candidates.
- Corrected candidates outside the current page.
- Corrections with no remaining composition.
- Typo correction selected while another Partial Commit checkpoint is active.

Unsupported by this milestone:

- Intermediate-syllable typo correction, such as `nihapanpai -> nihaoanpai`.
- Multi-level checkpoints.
- Cross-page corrected candidate selection.
- Red slash UI, marked text underline, or candidate visual changes.
- Typo engine coverage expansion, confidence scoring, or ranking changes.

## Merge Readiness

The `feature/typo-v0-2-6` milestone is merge-ready when all of these are true:

- Working tree is clean after the final commit.
- `git diff --check` passes before commit.
- `swift test --package-path Packages/KeyboardCore` passes.
- Xcode simulator build passes for the `Universe Keyboard` scheme.
- Flag-off real-device regression passes.
- Flag-on real-device validation passes for normal RIME Partial Commit, typo Partial Commit, Delete restore, continued typing invalidation, fallback full commit, final commit, paging, and recovery.
- No temporary diagnostics or validation-only flag changes remain.

## Recommended Merge Strategy

Use a squash merge into the main development branch. The feature branch contains several implementation and stabilization commits that are useful during development but should become one milestone commit in main history.

Suggested squash title:

```text
feat(keyboard): add reversible partial commit infrastructure
```

Suggested tag after merge:

```text
partial-commit-v1
```

Keep the feature branch until at least one post-merge build and smoke test has passed. Delete it later only after the tag is pushed and main is confirmed healthy.
