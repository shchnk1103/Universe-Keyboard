# Evidence: TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001

Recorded: `2026-09-21T22:14:42+08:00 Asia/Shanghai`

Executor: Grok, after Human Product Owner confirmed
`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001` is live.

## Exact identities

| Field | Value |
|---|---|
| Implementation worktree | `/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001` |
| Branch | `grok/typo-correction-002-runtime-integration-implementation-001` |
| HEAD | `4d1050f4b677494e06448cb40a83ef2da46d7b27` |
| Tree | `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Original preflight worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard` |
| Original checkpoint diff SHA-256 after copy | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |
| Original checkpoint after implementation | still `8bb105c5…`; original worktree was not reset, cleaned or committed |

## What landed

1. `InstalledTypoCorrectionSidecarOwner` wraps the already-installed
   `TypoCorrectionCandidateQuerying` facade. Default route-local epoch is
   `nil`. Thread-affine / MainActor-responsive routes may observe
   `sessionEpoch`. The adapter does not cast to a raw engine or open a
   second RIME session.
2. `TypoCorrectionRecallCoordinator` on `KeyboardViewController` owns one
   MainActor recall lifecycle: 180 ms debounce, `recallEpoch`, cancellation,
   `RunLoop.main.perform(inModes: [.default])` one-query turns, fences, and
   candidate-bar refresh after one Core apply.
3. Stage one uses the existing production `12/8` hypothesis set. Stage two
   starts only when stage one has zero accepted display results, the
   structural selector still has unaccounted groups, and query budget
   remains. Runtime caps are 8 / 8 / 3 / 4.
4. `KeyboardController.applyTypoCorrectionRecallMaterial` is the only
   recall-path writer of `state.typoCorrection`. Stale composition is a
   display no-op.
5. Invalidation increments `recallEpoch` from `clearTypoCorrectionSuggestions`
   (via the installed owner), visibility teardown, and engine install /
   dual-gate rebind.

## Tests and format

| Check | Result |
|---|---|
| `swift-format lint --strict` on every changed Swift file | Pass |
| `swift test --package-path Packages/KeyboardCore --filter TypoCorrectionRuntimeIntegrationTests` | 7 passed |
| `swift test --package-path Packages/KeyboardCore` | 1150 passed |
| RimeBridgeTests, iPhone 17 Pro `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` | `TEST SUCCEEDED` |
| Universe Keyboard scheme test, same destination | UniverseKeyboardTests 373 executed / 9 skipped; KeyboardTests 15 passed; `TEST SUCCEEDED` |

## Non-claims

No commit, push, PR, merge, TestFlight, Release or Gate. No Simulator/device
capture, new Run ID, QA-001, INT-003, paired performance or `180 ms` result.
No operation-receipt / diagnostics change. No always-on `60/64` first-stage
path. Parent `TYPO-CORRECTION-002` remains Active.

Next: independent Architecture review of this exact uncommitted snapshot.
