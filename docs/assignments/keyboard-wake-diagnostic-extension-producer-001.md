# Assignment: KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PRODUCER-001 — Lifecycle, RIME-resume and text-proxy events

Policy: 1.0.0 — [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Reassigned** |
| Current phase | Human Product Owner authorized establishing the separate [paired-build rollout Assignment](keyboard-wake-diagnostic-extension-paired-rollout-001.md), now **Acknowledged / Not Ready**. This predecessor remains Reassigned; implementation is not authorized. |
| Material non-claims | No v4 event emission, paired-build rollout, manual reproduction, root-cause conclusion, behavior fix, Quality/Product Gate, Release or parent closure is claimed. |
| Next handoff | Revalidate prerequisites/source/environment and obtain a fresh exclusive Simulator window plus separate implementation authorization under the successor Assignment before any implementation. |
| Residuals | The successor is Not Ready; its integrated build identity, source baseline, exclusive Simulator window and implementation authority are not established. |

---

## Authority

- **Assignment Authority:** Product Lead.
- **Decision Source / Date:** On 2026-09-29 Asia/Shanghai, the Human Product Owner accepted the v4 writer scope and deferred Extension call-site wiring to a separate paired-build rollout Assignment (“接受，可以按照你的建议继续”), then authorized establishing that Assignment (“授权”). See the [Assignment-establishment authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-authorization.md). This predecessor remains Reassigned and the new authorization does not authorize implementation.
- **Product Approver:** Human Product Owner in the current Codex task.
- **KOS 2.2 optional contracts:** Not opted in; the project pin remains advisory.

## Deferred Objective — successor Assignment required

The future paired-build rollout may add content-free event call sites at Keyboard Extension-owned lifecycle, RIME-resume and `UITextDocumentProxy` boundaries. That work must be assigned separately after the Runtime Record API prerequisite and v4 reader/writer contract are reviewed. Event emission must follow Proposal 0.4 and must not change keyboard input behavior.

## Historical Responsibility Proposal

The following roles were proposed for this producer scope. They are not bindings for the future successor Assignment.

| Responsibility | Prior proposal |
|---|---|
| Domain Owner | **Keyboard Experience Maintainer** — owns Extension lifecycle wiring, UIKit boundaries and proxy adapter. |
| Executor | **Current Codex task**, after the prerequisite and a separate implementation authorization. |
| Environment Executor | **Current Codex task** for the authorized `xcodebuild` suites only, after the exact Simulator destination is freshly reserved and confirmed exclusive. |
| Human Dependency | **Not Applicable** — manual failure/recovery capture remains in the parent lifecycle task after paired rollout authorization. |
| Architecture Reviewer | **Architecture & Knowledge Steward**. |
| Quality Reviewer | **Quality, Performance & Release Maintainer**. |
| Product Approver | Human Product Owner in the current Codex task. |

## Deferred Scope — not authorized by this record

Product selected the separate paired-build rollout path. No call-site implementation, enablement or runtime emission belongs to this Reassigned predecessor. A successor Assignment must define and review the same-build gate and validation plan.

- Add event emission at existing Extension-owned lifecycle callbacks for the accepted `keyboard.lifecycle.phase_changed` phases that the Extension actually observes.
- Add `rime.resume.phase_changed` at the Extension call boundary: record only observed `started`, `completed`, `owner_ready`, or a failure that maps to an existing finite typed reason. Do not infer `session_created`, `schema_selected`, failure, or success from absence or from an unrelated log line. If those internal states require KeyboardCore or RimeBridge instrumentation, stop and request a separate owner assignment.
- Add `text_proxy.operation_phase_changed` immediately before and after the existing `insertText`, `setMarkedText`, and `unmarkText` proxy calls. `returned` means only that the call returned; it is not proof that the host inserted or displayed text.
- Use the existing process/local sequence and `appearanceID` when available. Include `actionSequence` only when existing causal attribution is reliable; do not introduce operation UUIDs, text hashes, content lengths or new state semantics.
- Emit only fixed enums and optional finite `UInt64` values from Proposal 0.4. Preserve `.debug` level and existing high-fidelity/category gating. No raw text, candidate text, host text, document context, schema name, path, URL or free-form error.
- Use the bounded asynchronous diagnostics ingress. The in-scope files are limited to `Keyboard/Controllers/KeyboardViewController.swift`, `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`, `Keyboard/Services/UITextDocumentProxyAdapter.swift`, and focused tests under `KeyboardTests/`.
- The parent diagnostic patch currently dirties five Extension controller files: `KeyboardViewController.swift`, `KeyboardViewController+Bootstrap.swift`, `KeyboardViewController+CandidateDataSource.swift`, `KeyboardViewController+InputActions.swift`, and `KeyboardViewController+KeyPressFeedback.swift`. Freeze and protect all five; do not reformat, revert, stage, or edit them until the parent candidate is frozen and an exclusive writer window is confirmed.
- Keep v4 production disabled until the future paired-build rollout gate is separately authorized and evidenced.

### Non-goals

- No changes to KeyboardCore input/session state, RimeBridge, event schema/allowlists, Main App reader/formatter/fallback, or RIME deployment.
- No behavioral recovery/fix, candidate-render assertion, host-insertion assertion, user-data collection or synchronous persistence.
- No standalone diagnostic-app installation/launch, App Group mutation, manual runtime reproduction, paired-build enablement, commit, push, PR, merge, TestFlight or Release. An authorized `xcodebuild test` harness may install or launch its required test host only after the exact Simulator destination and exclusive-use window are recorded; that does not authorize standalone app deployment or runtime reproduction.

## Required Inputs

- Human-accepted document-only Proposal 0.4, design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`.
- KeyboardCore reader candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7` and Main App consumer candidate `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a`; their existing evidence does not certify this Extension work.
- The Runtime Record API and accepted v4 reader/writer contract are prerequisites to any future paired-build rollout Assignment.
- Parent Extension patch: base `9eb83158e49218c1e8f75dbe7dd9e0390db81409` plus five-file patch SHA-256 `c4998815078e790e1a14109ecefde8a3fb467f197c90eece5dbda20b4a7f7a8d`. It touches `KeyboardViewController.swift`, `KeyboardViewController+Bootstrap.swift`, `KeyboardViewController+CandidateDataSource.swift`, `KeyboardViewController+InputActions.swift`, and `KeyboardViewController+KeyPressFeedback.swift`. Do not reformat, revert, stage or edit any of these five files until the parent candidate is frozen and an exclusive writer window is confirmed.
- `UITextDocumentProxyAdapter.swift` current SHA-256 `f5cad10abb6b01594819cbb5dcf72a2989d389ed235364237abdfce7853b6de5`; revalidate all in-scope identities before `Ready`.
- Current Main App and KeyboardCore changes share this worktree. Their test results remain evidence for their own Assignments and are not independent Quality evidence for this Extension Assignment.

## Successor Assignment Entry / Exit Requirements

This Reassigned record has no implementation Entry or Exit Criteria. A future paired-build rollout Assignment must, at minimum:

1. Bind an exact reviewed Runtime Record API candidate and an accepted ADR 0036.
2. Revalidate the five-file parent Extension patch and every in-scope source/test identity; confirm no active writer and preserve all dirty work.
3. Name one Domain Owner, Executor, Environment Executor, Human Dependency, Architecture Reviewer, Quality Reviewer and Product Approver, with justified `Not Applicable` values.
4. Bind an exact Simulator target and fresh exclusive-use window before any Simulator-backed test or manual reproduction.
5. Prove same-build Main App + Keyboard Extension identity, explicit v3/v4 reader behavior, strict event/payload/raw-key validation, controlled incomplete/unsupported status and suppression of legacy fallback before enabling v4 call sites.
6. Preserve the privacy, bounded asynchronous ingress and no-input-behavior-change constraints; run and review the repository-required CI-equivalent checks on the frozen final candidate.

## Stop Conditions

- The runtime API prerequisite is incomplete or changes the accepted payload contract.
- An event requires changing KeyboardCore input semantics, RimeBridge/session internals, the event schema, reader, Main App consumer or accepted privacy/capture policy.
- A required phase cannot be observed without guessing, or proxy correlation would require new Core action-identity propagation.
- Before Ready or implementation, an unapproved external change alters any frozen source/test input identity; at any time, a concurrent writer is editing an in-scope file; or final candidate identities are not frozen before review. Authorized implementation changes create a new candidate and are not themselves a stop condition. Stop and rebind if these conditions are not met.
- Enabling v4, installing/launching the diagnostic app, mutating App Group data or performing user reproduction without a separate explicit authorization.

## Handoff and Revalidation

- **Handoff Target:** [KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001](keyboard-wake-diagnostic-extension-paired-rollout-001.md) (**Acknowledged / Not Ready**) and parent `KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001`.
- **Revalidation Triggers:** Changes to Proposal 0.4, reader/API candidates, current parent Extension patch, proxy adapter, producer-off mechanism, paired-rollout gate, capture gates, Simulator target, or reviewer/owner assignment.

## Review Findings — reviewed draft identity only

- Architecture reviewed the prior draft SHA-256 `6aa3ef82e52bdebce1e2326ebd896e515fdd69e4dc352d3a2ccf1e1fff456149` and returned **Blocked from Ready**: the v4 writer prerequisite is not executable as proposed; the producer-off mechanism is unspecified; and all five dirty Extension controller files require freeze/exclusive-writer protection.
- Quality reviewed that same prior draft identity and found the scope understandable but blocked from Ready by the API prerequisite and dirty writer. Quality also required exact Simulator reservation evidence, clarification that only harness-managed test-host install/launch is permitted, hot-path evidence for bounded asynchronous ingress, and exact-candidate handoff identities. These points were incorporated. At the time this historical review note was drafted, the edited producer scope was awaiting exact-SHA review. The scope at SHA-256 `825aec679b3aefb0ef6618813e9b0ceac7b08c057e988fbda6e72828b47a25ff` later received Architecture and Quality **Pass with conditions** as a Pending draft only. This review does not create a Product Assignment Decision, Ready status or implementation authorization.

## History

- 2026-09-29 Asia/Shanghai — Draft prepared at the Human Product Owner request. Proposed owner is Keyboard Experience Maintainer. A source preflight found that current Extension call sites cannot submit typed composite payloads through `DiagnosticsJournalRuntime`; the linked Input Intelligence prerequisite is proposed. No Product Assignment Decision, role acknowledgment, code or environment action is claimed.
- 2026-09-29 Asia/Shanghai — Human Product Owner accepted the v4 persisted-writer scope and deferred Extension call-site wiring to a separate paired-build rollout Assignment. This record is Reassigned; no successor Assignment, implementation, v4 emission, Simulator activity or installation is claimed.
- 2026-09-29 Asia/Shanghai — Human Product Owner authorized establishing the separate paired-build rollout Assignment. The successor record is now Assigned / Not Ready; this does not authorize implementation, v4 emission, Simulator activity, installation or reproduction.
