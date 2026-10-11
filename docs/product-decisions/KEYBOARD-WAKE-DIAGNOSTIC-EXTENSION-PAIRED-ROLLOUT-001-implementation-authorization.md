# Product Authorization: KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001 Implementation

## Status

**Authorized for the bounded Assignment scope; Entry hold.** The Human Product Owner authorized a separate implementation authorization and pre-edit Entry work on 2026-09-30 Asia/Shanghai. The Assignment is not Ready or Active, and no source implementation has started.

## Authority and identity

- **Decision source:** The Human Product Owner replied “可以按照你的建议继续下一步，之后也继续汇报进度” to the proposal to record a separate exact-scope implementation authorization and begin Entry verification.
- **Assignment:** [KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001](../assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md), pre-status SHA-256 `91b78be7d7fafe6688487bbd9c77eed946af1f114ede9fd9dca80ec790fba253`.
- **Source baseline:** `84b9c19227330b0fe6ff391be001ee398010fd6a`, branch `codex/keyboard-wake-v3-compatibility-gate`.
- **Executor / Product Approver:** Current Codex task / Human Product Owner.

## Authorized scope

After the Assignment reaches **Active** and all Entry criteria are satisfied, this authorization covers only its current local paired-build compatibility-gate scope:

- Revalidate and integrate the reviewed Runtime Record API, KeyboardCore reader, Main App consumer, and the historical Extension patch into the exact candidate.
- Limit Extension source edits to `Keyboard/Controllers/KeyboardViewController.swift`, `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`, and `Keyboard/Services/UITextDocumentProxyAdapter.swift`; add focused tests under `KeyboardTests/`.
- Preserve the Assignment's explicit production `writerVersion: .v3` requirement, test-only isolated v4 fixtures, paired reader/fallback checks, content-free payloads, existing capture gates, and asynchronous journal ingress. Any conflict with accepted current schema behavior is a stop condition, not delegated implementation discretion.
- Run the formatting, KeyboardCore, RimeBridgeTests, App + Keyboard, Release build, pinned RIME vendor, and diff checks required by the Assignment, bound to its exact candidate and a freshly reserved Simulator destination.

The historical Simulator target is iPhone 18 Pro / iOS 27.0, UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`. Its recorded identity is not a current reservation. No Simulator action is authorized until a fresh exclusive window is recorded under the Assignment.

## Entry hold and limits

The pre-edit Entry review found a contract mismatch that prevents this authorization from becoming executable as written: the reviewed compatibility-gate candidate preserves schema-v5 production writing and explicitly keeps production wake-marker emission off; its manifest declares `writer_version: 5`. The separately reviewed Runtime Record API evidence describes an explicit `.v3` / `.v4` selector, but that older API candidate is not included in manifest r2, and its recorded worktree is archived, so its source bytes were not rehashed during this Entry pass. The current schema-v5 candidate accepts v5-writable events and rejects v4-only marker payloads; its Extension also emits v5-only `typo_recall` diagnostics. Selecting `.v3` or `.v4` for the Extension writer therefore needs same-candidate proof that existing v5 diagnostics remain supported under ADR 0036's static-version rule. The paired-rollout Assignment does not specify that reconciliation, and Product/Architecture must decide the protocol contract.

Accordingly, this authorization does not waive the Assignment's `Not Ready` state or its Entry/Stop Conditions. Do not begin source edits, formatting, tests, builds, installation, Simulator operations, marker emission, or manual Maps reproduction until Product and Architecture reconcile the protocol contract and the Assignment is revalidated. The [pre-edit Entry receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-pre-edit-entry-2026-09-30.md) and [M-06 reconciliation brief](../plans/keyboard-wake-diagnostic-extension-writer-version-reconciliation-001.md) record the evidence and requested decision.

This authorization does not permit production marker promotion, app installation, human reproduction, root-cause or behavior-fix claims, commit, push, PR, merge, Product/Quality Gate, TestFlight, Release, or parent Assignment closure.
