# Evidence: TYPO-CORRECTION-002 runtime-preflight implementation 001

## Scope and authority

| Field | Value |
|---|---|
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001`](../assignments/typo-correction-002-runtime-preflight-implementation-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-PREFLIGHT-IMPLEMENTATION-001.md), consumed immediately before the first Swift change |
| Code worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard` |
| Baseline commit/tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Worktree state at entry | clean detached checkout |
| Execution boundary | Pure `KeyboardCore`; no controller/RimeBridge/RIME/Simulator/device action |

## Changed-file manifest

Only the three Authorization-permitted Swift files differ from the baseline.
The uncommitted binary diff SHA-256 is
`8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab`.

| Path | Post-change SHA-256 | Purpose |
|---|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift` | `08745e149975b5feb844107a570428cd9a51e1a754ede2f0368ae3177667c949` | Adds a default-off, pure-memory selected-group entry point to the existing preflight plan. |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift` | `f7ba8bec024f71e39b073eb0cef767960fd81dc538923a975d8de267b7136a6a` | Adds the structural selector, separate selection/query caps, operation-private GroupID registry, ordinal operation identity and ledger fence inputs. |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift` | `edbf636f9b66c336189c213769d84fdb4425d440a4ac7b169a0e5cde47315780` | Tests order independence, structural-cap coverage, GroupID scope and ordinal stale-result rejection. |

`git diff --check` passed. Static scope checks confirmed that
`KeyboardController+TypoCorrection.swift`,
`KeyboardViewController+TypoCorrection.swift` and `TypoCorrection.swift` are
unchanged. The production search default remains `12` first-layer states and
`8` hypotheses.

## Implemented preflight contract

1. Generation, selected-group count and query-attempt count are distinct.
   The provisional substitution-only selector has an explicit cap of eight
   selected groups and a separately represented `maxQueryAttempts`; the tests
   demonstrate that a lower query cap does not silently reduce selection.
2. Selection accepts exactly two safe substitutions and orders their structural
   signature by wider edit span, then lower summed neighboring-key order, then
   stable index/input tie-breakers. Reversing the generated hypothesis array
   yields the same selected corrected-input sequence. This is a deterministic
   local coverage policy, not a semantic scorer or candidate-quality claim.
3. A `TypoCorrectionRecallPreflightGroupRegistry` canonicalizes corrected input
   only inside one operation, allocates opaque GroupIDs, and does not expose
   corrected input to ledger accounting. A new operation has a distinct ordinal
   even if revision and epoch match.
4. The existing ledger therefore rejects a cancelled or stale result after a
   query began, including when only the operation ordinal changed. It does not
   create a scheduler, start a query or publish candidates.

## Verification

| Check | Result |
|---|---|
| `xcrun swift-format format --in-place` on all three changed Swift files | Passed |
| `xcrun swift-format lint --strict` on all three changed Swift files | Passed |
| `swift test --package-path Packages/KeyboardCore --filter TypoCorrectionRecallPreflightTests` | Passed — 18 tests / 0 failures |
| `swift test --package-path Packages/KeyboardCore` | Passed — 1143 tests / 0 failures |

The full package emitted one pre-existing warning in
`T9PinyinPathTests.swift` about interpolating an optional. That file is outside
this slice and not in the changed-file manifest.

## Residuals and non-claims

| Architecture residual | This implementation provides | Still open |
|---|---|---|
| AR-01 | A deterministic structural selector and explicit preflight-only selection/query caps, with focused tests. | Whether this selector/cap is appropriate for production runtime. |
| AR-02 | Proof that selection is not the expanded global rank order. | Any latency, throughput, `180 ms`, or semantic-recall claim. |
| AR-03 | Operation ordinal plus ledger tests that discard stale/cancelled results after a started query. | An actual async scheduler, cancellation mechanism and controller integration. |
| AR-04 | Operation-private normalized-input to opaque GroupID mapping. | Binding that mapping to real sidecar accounting or diagnostics. |

This evidence does **not** claim RIME query execution, real `rime_ice`
provenance, candidate visibility or selection, QA-001, INT-003, paired
performance, Product/Quality/Release Gate, publication, merge, or parent
Assignment closure.

## Handoff

Request independent Architecture review of the exact uncommitted diff SHA-256
above, then independent Quality review. Reviewers must preserve the runtime and
product non-claims; this slice is intentionally not wired to any controller.
