# INT-003 query-density diagnosis 001

## Status

Bounded source and journal diagnosis. The `query_*` markers are not duplicate log-only events: each `query_begin` brackets one candidate-query facade call and its corresponding `query_outcome`. A fresh run provides operation-level evidence that one recall operation can issue 26–32 real candidate-query calls. Its measured minimum inter-key interval was 285.075 ms. The [2026-09-26 Product decision](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md) removed `<180 ms` as a hard pass condition for this follow-up diagnosis, without claiming rapid-behavior coverage. The earlier Product Capture's rapid-window attribution remains unresolved; its original raw JSONL is still unavailable for rehash and correlation.

This is not a Product Gate, QA-001 Gate, parent close, or release decision. Parent Assignment `TYPO-CORRECTION-002` remains Active.

## Authority and source binding

- Assignment: `TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`.
- AUTH: `AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001`, consumed at `2026-09-25T15:35:47+08:00` under the Human continuation authorization.
- GitHub `main` was verified by an explicit read-only `git ls-remote https://github.com/shchnk1103/Universe-Keyboard.git refs/heads/main`; result: `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c`. The worktree's `origin` points to the protected local checkout, so its stale `main` reference was not used as GitHub evidence. The protected checkout was not modified.
- Capture install tip: `80091f35cc5411b292eca78662f39e2b91694045`, an ancestor of the verified main tip.
- The source blobs for the coordinator, presentation callback, recall driver, Core query helper, sidecar owner, and RimeBridge query adapter match byte-for-byte between the capture install tip and `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c`.
- Capture evidence: [`typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md`](typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md), SHA-256 `3dde0362923fb36071c611134c6c0022ce70d20839afa2dd67894260428835b4` (recomputed and matched).

## Symptom and recorded observations

The Capture evidence reports 574 `typo_recall.query_begin` and 574 `typo_recall.query_outcome` markers over the full journal. In the rapid window `13:04:35Z`–`13:04:37Z`, it reports 16 of each alongside 16 `touch.terminal` events. These are aggregate values copied from the hashed evidence record; this diagnostic host did not recompute them from the raw JSONL.

The bound raw journal was expected at:

`/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/06C5BC3E-7599-4761-A1A2-71DAEA991474/data/Containers/Shared/AppGroup/E9CF1194-00E6-4E56-9B2B-2781B8103B42/Diagnostics/v1/g1/open/keyboard_extension-583B3AB8-86FE-4480-BD1D-5EEF9F1BB1E2-20260923T13-0.jsonl`

The evidence-bound SHA-256 is `a9af14932b1a0b78595c26966a6dd16fe4ba2aa654a91ec760f86fa12bda64cc`. The file was absent at that path and was not found by exact filename under the Simulator device tree or `/private/tmp`; its bytes and hash therefore could not be rechecked during this diagnosis.

### Follow-up diagnostic run — 2026-09-25

The distinct Capture AUTH was consumed before simulator operations and bound to GitHub `main` `4ef275b57d16f116b4edbae99a0e244a28d6bf25`. The scoped runtime source files were unchanged from `e28491a8e4ae6e5127c3241228c6fa9a1f4f082c`. Run `TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001` preserved and hashed its raw Extension JSONL before row inspection; see the [run evidence](typo-correction-002-sim-run-2026-09-25-int003-query-density-diagnostic-001.md), SHA-256 `aa523a6e8330b529e0ffc03283b142f842401b2321e2b323e6ce2762d5b59f84`.

- The journal contains 359 `query_begin` and 359 `query_outcome` events across operation ordinals 1–12, all at composition revision 2. Each operation has 26–32 matching query pairs. All 359 outcomes have reason `typo_recall_query_succeeded`; the code uses this reason for a query that was not discarded by the fence, not as evidence that RIME returned candidates.
- The run has 12 `debounce_scheduled`, 11 `debounce_cancelled`, 2 `epoch_bumped`, and 3 `fence_discarded` events. The latter are recorded as observations only; fence remediation is outside this diagnostic's scope.
- The 19 highlighted key-terminal events have 18 monotonic inter-key intervals from 285.075 to 575.942 ms. None is below 180 ms. The first query for each operation began 218.942–259.581 ms after its corresponding scheduled marker.
- The user's fastest repeatable manual input therefore did not produce the requested rapid segment. It did establish operation-level fan-out and show that this run's query calls began after the debounce delay. It does not reproduce the earlier capture's 16 query pairs in its reported rapid window.

## Source correlation

- [`TypoCorrectionRecallCoordinator.swift`](../../Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift#L154): `performQuery` writes `query_begin` immediately before calling `owner.correctionCandidates(...)`, then writes `query_outcome` after that call and after the driver's result is classified (lines 164–182). The capture and current-main source blobs match. This rules out a second, independent `query_*` logging site or a repeated marker call without a query facade invocation in this path.
- [`TypoCorrectionSidecarOwner.swift`](../../Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift#L57) delegates each facade call to the installed query. The captured `RimeEngineImpl` adapter delegates to `bridge.correctionCandidates(...)` in [`RimeEngineImpl+CorrectionQuery.swift`](../../Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift#L3).
- [`TypoCorrectionRecallMaterial.swift`](../../Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift#L136) yields one `.query` event per suggestion/hypothesis. A recall operation can query multiple stage-one hypotheses and then bounded stage-two hypotheses. Thus `query_*` counts are candidate-query attempts, not debounce-operation counts; 574 does not mean 574 pauses or 574 distinct compositions.
- [`KeyboardViewController+Presentation.swift`](../../Keyboard/Controllers/KeyboardViewController+Presentation.swift#L271) schedules recall after candidate presentation refresh. The coordinator uses a 180 ms delayed work item in [`TypoCorrectionRecallCoordinator.swift`](../../Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift#L56), and fences later turns against the live composition.
- Adjacent marker caveat: `debounce_cancelled` is emitted when the stored work-item reference is non-nil (`TypoCorrectionRecallCoordinator.swift`, lines 27–29 and 56–80); the reference is not cleared in the work-item closure. Consequently this marker alone does not prove that the referenced item was still pending when canceled. This does not explain or invalidate the `query_*` pair counts, and no change is made under this diagnosis.

## Root-cause status

**Resolved:** duplicate `query_*` marker emission is not the cause. In the captured source path, every pair surrounds a real candidate-query facade call. `query_*` counts are per hypothesis query, not per debounce operation.

**Bounded explanation:** the follow-up run observed 26–32 real queries per operation and 12 operations. The coordinator waits for the 180 ms debounce before starting an operation; the follow-up's first query began 219–260 ms after scheduling. Thus the event density can arise from hypothesis fan-out within operations, compounded by multiple operations when the user's key intervals exceed the debounce threshold. The run does not identify which of Stage 1 or Stage 2 accounts for each query because the journal does not record a stage label or candidate count.

**Still unresolved:** whether the earlier Product Capture's 16 query pairs in its rapid window came from an operation continuing across touches, multiple operations, or another cadence interaction. The original journal is unavailable and the follow-up's actual key intervals do not support a rapid-behavior claim. The Product Capture's `fence_discarded=0` remains its original aggregate only; the follow-up's three fence discards are separate run evidence.

No Swift or test changes were made. No fence remediation, Product Gate, QA-001 Gate, parent close, TestFlight, Release, or ADR acceptance was performed. No source fix is indicated by this bounded result alone.

## Next decision boundary

The diagnostic Capture AUTHs are Consumed. The first run supplies the bounded source/journal diagnosis. The prepared second rapid Run ID has a [no-run disposition](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md): a read-only UI snapshot preceded Product's criterion change, but no key input or new journal was collected. Do not ask the Human to repeat the same manual sequence. If exact rapid-window correlation is still required, make a new evidence plan and distinct AUTH; a rapid-behavior claim still needs measured qualifying intervals. The broader Product residual remains open. Any Swift change requires a distinct, consumed remediation authorization and evidence of a source defect; keep the parent Active and do not infer a Product Gate.
