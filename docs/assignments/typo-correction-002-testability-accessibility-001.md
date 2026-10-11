# Assignment: TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001

## Keyboard UI testability and accessibility contract

### Current status

- Lifecycle: `Closed`.
- Phase: bounded implementation, independent Architecture/Quality review, Product residual acceptance, publication and PR #140 merge are complete.
- Child closure is recorded by `AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-CLOSE-001`; this does not close the parent assignment.
- Exact merged tip: PR #140, merge commit `162b09fd58ba60538a944026b1902efa405c75aa`, with implementation commit `bf460ea3abd5df9b55fc1401006fd33d4859ad56` and publication tip `9403a84d32a48a33de106c6fd67f43594109089c`.
- Product-accepted residuals remain bounded: gap taps, nine-key, and physical VoiceOver are UNKNOWN/out of child scope; no INT-003, QA-001, performance, parent, or Release conclusion.

### Authority and parentage

- Parent assignment: `TYPO-CORRECTION-002`.
- Decision source: direct Human Product Owner instruction in the current task, 2026-09-19 (Asia/Shanghai).
- Product authority: Product Lead / Human Product Owner.
- Matching authorization: `docs/authorizations/AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001.md`.

### Objective

Establish the smallest testability/accessibility contract that makes the existing visible keyboard controls independently discoverable and actionable by an authorized UI automation harness. The harness must exercise the same keyboard key controls and normal UIKit action path that a human uses.

The immediate motivation is that the current Simulator UI tree exposes the host text field and keyboard-switch control but not independent Universe Keyboard key targets, while the source already contains partial key accessibility semantics. The executor must determine the actual discoverability boundary before changing code.

### Scope

The executor may:

- inspect the current keyboard view hierarchy, accessibility tree, hit-routing canvas, and existing key action wiring;
- make the smallest source change needed for independently discoverable/actionable key controls, if a source change is justified;
- cover at least the alphabetic keys needed for the bounded INT-003 interaction, plus Delete, Space, Return, and keyboard-switch controls where the existing hierarchy supports them;
- preserve the existing UIKit target/action path, touch geometry, hit forwarding, RIME session boundary, privacy boundary, and visual contract;
- add or update focused `KeyboardTests` accessibility/testability contract tests;
- capture bounded Simulator UI/accessibility or touch evidence showing what is discoverable and how a permitted harness invokes it;
- run the formatting, focused tests, and affected build/test checks required by `AGENTS.md`, when the executor has the required local environment;
- return a handoff that binds all findings to the exact source baseline and worktree.

Affected areas are limited to the keyboard UI/controller and focused keyboard tests. The parent sidecar/provenance implementation and the current dirty parent worktree are inputs only, not edit targets.

### Non-goals and explicit exclusions

This assignment does not authorize:

- a general end-user AI keyboard-control API or an AI product feature;
- an LLM, model, cloud service, network request, App Intent, Shortcut, or Siri integration;
- direct host text-field injection, pasteboard insertion, marked-text mutation, arbitrary text replacement, or host-context access;
- reading, persisting, or emitting raw user composition, candidate text, host text, credentials, or other sensitive input;
- candidate ranking, search budget, debounce, cancellation, RIME schema/vendor/archive, sidecar, deployment, or session changes;
- `FakeCandidateProvider`, the old Ice directory, synthetic candidates, or simulator-only fixture substitution;
- visual redesign or a change to the Apple-style appearance;
- edits to `main`, the parent dirty worktree, or the F-01 remediation worktree;
- Product/Quality/Performance/TestFlight/Release decisions or gate closure;
- commit, push, pull request, merge, tag, branch deletion, or remote-state mutation.

### Assignment roles

- Domain Owner: Input Intelligence / Keyboard Experience Maintainer.
- Executor: Grok (external AI), completed in the isolated child worktree.
- Environment Executor: Grok, completed the bounded Simulator evidence under the separate F-02 revalidation Assignment.
- Human dependency: the Human Product Owner supplies the isolated worktree/repository access and performs any required device or UI action; Grok returns the implementation and evidence handoff.
- Architecture reviewer: Architecture & Knowledge Steward.
- Quality reviewer: Quality, Performance & Release Maintainer.
- Product approver: Product Lead / Human Product Owner.
- Handoff target: current Codex coordinator, followed by independent Architecture/Quality review; Product retains acceptance authority.

### Required inputs

- Exact source baseline: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`.
- A clean isolated worktree created from that baseline, recommended branch name `codex/typo-correction-002-testability-accessibility-001`.
- The executor must not use the dirty `main` checkout or the dirty parent sidecar worktree as its implementation workspace.
- Required project documents: `AGENTS.md`, `docs/KNOWLEDGE_INDEX.md`, `docs/ACTIVE_WORK.md`, `docs/READING_MAPS.md`, `docs/PROJECT_CONTEXT.md`, and `docs/playbooks/keyboard-ui.md`.
- Parent records: `docs/assignments/typo-correction-002.md`, the parent revalidation authorization, and the current sidecar/provenance evidence.
- Relevant source to inspect first: `Keyboard/Controllers/KeyboardViewController+KeyAccessibility.swift`, `Keyboard/Controllers/KeyboardViewController+KeyFactory.swift`, `Keyboard/Controllers/KeyboardViewController+Rows.swift`, `Keyboard/Controllers/KeyboardKeyButton.swift`, and `Keyboard/Controllers/KeyboardInputHitAreaStackView.swift`.

### Entry criteria

Work may become `Ready` only after all of the following are true:

- the matching authorization is present and current;
- Grok acknowledges the exact baseline, isolated worktree, scope, non-goals, stop conditions, and required output;
- the isolated worktree is clean and demonstrably based on the exact baseline;
- the executor has inspected the current accessibility hierarchy and normal key-action path;
- no parent/main or unrelated dirty files are in the implementation scope.

### Exit criteria

The executor must not claim completion until it returns:

- the exact worktree path, branch, baseline, and final local identity;
- a bounded list of changed files and a description of the accessibility/testability contract;
- focused contract tests and their results;
- required Swift formatting and affected build/test results, or an explicit environment-limited non-claim;
- fresh Simulator AX/touch evidence, if the environment permits it, showing independent key discovery/actionability;
- evidence that invocation uses the normal visible key action path rather than host-text injection or private simulator APIs;
- privacy and non-goal checks, including what remains unverified;
- a concise handoff for independent Architecture/Quality review.

Completion of this assignment is not Product acceptance and does not close `TYPO-CORRECTION-002`.

### Stop conditions

Stop and return a blocked handoff if:

- the proposed route requires direct text injection, pasteboard mutation, private simulator APIs, or host-context access;
- exposing individual keys would require weakening privacy, input isolation, or the normal hit-routing contract;
- the root cause is an iOS keyboard-extension AX limitation that cannot be fixed safely within this boundary;
- the work would touch RIME, schema/vendor/archive deployment, sidecar observability, search, ranking, debounce, or cancellation;
- the exact baseline, clean worktree, executor, reviewer, or required environment cannot be established;
- the request expands into a general AI control feature or any publication/gate action.

### Handoff contract

The handoff must state:

1. what the executor inspected;
2. whether a source change was necessary and why;
3. how a permitted harness discovers and activates a visible key;
4. which normal key-action and privacy boundaries remain intact;
5. exact test/evidence identities and hashes where applicable;
6. residual risks, UNKNOWNs, and recommended independent review questions.

### Revalidation triggers

Revalidation is required if the source baseline, worktree, keyboard hierarchy, iOS/Symbol environment, accessibility contract, privacy boundary, test target, or evidence artifact changes. A later commit, push, PR, merge, Product/Quality decision, or parent closure requires a separate authorization.

### History

- 2026-09-19: created as `Assignment Pending` for a bounded keyboard UI testability/accessibility slice. Implementation and publication have not started.
- 2026-09-19: implementation commit `bf460ea3abd5df9b55fc1401006fd33d4859ad56`, publication tip `9403a84d32a48a33de106c6fd67f43594109089c`, PR #140 merged as `162b09fd58ba60538a944026b1902efa405c75aa`; Product accepted the bounded residuals and the child was closed under the dedicated Close Authorization. Parent remains Active.
