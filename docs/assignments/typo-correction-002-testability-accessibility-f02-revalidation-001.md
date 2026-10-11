# Assignment: TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-REVALIDATION-001

## F-02 overlay-state touch-hit revalidation

### Current status

- Lifecycle: `Reviewed` — **未 Closed**。
- Phase: 证据采集完成；匹配 AUTH **consumed**；Assignment **未 Closed**；disposition 以 child 收据为准（sidecar 不另写 residual 表）。
- This is a bounded evidence revalidation slice. It does not authorize source changes or publication.
- Parent assignment: `TYPO-CORRECTION-002`.
- Child implementation context: `TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001`.
- Residual SoT: [`reconciliation evidence`](../evidence/typo-correction-002-testability-accessibility-f02-reconciliation.md) · Architecture [`final disposition`](../reviews/typo-correction-002-testability-accessibility-f02-architecture-final.md) — QR-01/F-02 **有界 Pass**（26 键 Messages `q` 键面中心、overlay OFF/ON、iPhone 17 Pro Max / iOS 27 Simulator）。缝区 / 九键 / 真机 VoiceOver 仍 UNKNOWN。

### Authority and parentage

- Decision source: Human Product Owner confirmation in the current task, 2026-09-19 (Asia/Shanghai).
- Product authority: Product Lead / Human Product Owner.
- Matching authorization: `docs/authorizations/AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-REVALIDATION-001.md`.
- This Assignment does not close the implementation child, the parent assignment, or any Product/Quality Gate.

### Objective

Close or precisely preserve the F-02 evidence boundary by comparing the same visible key hit at the same screen coordinate with the existing Debug touch-range overlay in its available states. The revalidation must demonstrate that overlay visibility does not change the normal key hit path or create a second text/action path.

The intended subject is the existing diagnostic/debug overlay referenced by the KEY-TOUCH-FILL contract. It must not be confused with the production `KeyboardTouchRoutingCanvas` or with the AX metadata change itself. If the intended overlay cannot be identified without modifying source, stop and report the ambiguity.

### Frozen implementation context

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-testability-accessibility-001`.
- Branch: `codex/typo-correction-002-testability-accessibility-001`.
- Base commit: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`.
- The worktree contains the uncommitted bounded implementation diff from the testability/accessibility child. That diff is an input to this revalidation and must be frozen before capture.
- Before capture, record `git status --short`, changed-path manifest, and hashes for the exact files under test. Any additional source or test change invalidates this Assignment and requires revalidation.
- Designated Simulator: iPhone 17 Pro Max / iOS 27.0 / UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`, unless an explicit environment failure is recorded.
- A new unique Run ID must be allocated immediately before the actual capture. Do not reuse the previous AX harness Run ID or xcresult.

### Scope

The executor may:

- inspect the existing Debug overlay toggle and the normal key hit-routing path;
- run the existing implementation without changing source;
- choose one deterministic visible alphabetic key, preferably `q`, and one fixed point inside its visible key face;
- capture the same-coordinate touch result with the Debug overlay off and on, or in the two states actually supported by the existing diagnostic control;
- use normal UI/hardware touch events and existing privacy-safe diagnostics;
- record whether both states reach the same `KeyboardKeyButton`/existing target-action path;
- produce a bounded evidence receipt with the new Run ID, exact worktree identity, raw artifact paths, and SHA-256 values;
- return a Quality handoff that assigns a disposition to `QR-01`.

### Non-goals and explicit exclusions

This Assignment does not authorize:

- any source, test, project, schema, RIME, sidecar, candidate, debounce, cancellation, or deployment change;
- adding a new debug toggle, accessibility element, instrumentation path, business action path, or test-only production hook;
- using direct host-text injection, `typeText`, pasteboard, `setMarkedText`, `documentContext`, private Simulator APIs, or synthetic candidate fixtures;
- changing `KeyboardTouchRoutingCanvas`, `KeyTouchCellLayout`, key geometry, row spacing, visual design, or hit formulas;
- treating AX discovery as proof of text insertion, candidate quality, INT-003, QA-001, performance, or Product behavior;
- nine-key AX, true-device VoiceOver, globe availability, or functional-key identifier expansion;
- commit, push, pull request, merge, release, tag, branch cleanup, or parent/child Assignment closure.

### Assignment roles

- Domain Owner: Keyboard Experience / Input UI Maintainer.
- Executor: Quality Reviewer, implemented by Grok in a fresh review runtime, pending acknowledgement.
- Environment Executor: Grok on the designated Simulator host, pending confirmation; if a human toggle is required, the Human Product Owner is the named dependency for that action only.
- Human Dependency: only if the existing overlay control requires a manual action; otherwise `Not Applicable` after preflight proves the harness can control it.
- Architecture Reviewer: Architecture & Knowledge Steward for disposition of the F-02 condition.
- Quality Reviewer: Quality, Performance & Release Maintainer / designated independent Quality runtime.
- Product Approver: Product Lead / Human Product Owner.
- Handoff Target: current Codex coordinator, then Architecture/Quality residual disposition; Product retains acceptance authority.

### Entry criteria

Work may become `Ready` only after:

- the matching Authorization is current;
- the executor confirms it is a fresh review runtime, not the implementation runtime's self-check;
- the exact worktree and uncommitted implementation diff are frozen and recorded;
- the intended existing Debug overlay and its available states are identified;
- the Simulator identity is verified;
- the new Run ID is allocated before capture;
- no source or test modification is needed to perform the comparison.

### Exit criteria

The handoff must contain:

- the new Run ID, worktree/branch/base commit, pre/post status, changed-path manifest, and file hashes;
- exact overlay states and how each state was reached;
- the fixed screen coordinate or deterministic coordinate derivation for the selected visible key;
- one bounded result for each state, including normal key action/touch evidence;
- raw artifact paths and SHA-256 values;
- an explicit statement that no host-text injection or private Simulator API was used;
- disposition of `QR-01`: `fix`, `accept`, `tech_debt:<ID>`, or `UNKNOWN` with owner and pointer;
- residual non-claims for nine-key, true-device VoiceOver, parent INT/QA/performance, and Product Gate.

### Stop conditions

Stop without modifying code if:

- the existing overlay cannot be toggled or identified without a source change;
- the only available route is coordinate injection outside the permitted UI/hardware touch path, host-text injection, pasteboard, marked text, or private Simulator API;
- overlay state changes alter layout or require changing the hit formula;
- operation-correlated touch evidence cannot be distinguished from unrelated historical diagnostics;
- the worktree identity or exact implementation diff cannot be frozen;
- the task expands into a bug fix, new automation API, nine-key/VoiceOver work, or any publication action.

### Revalidation triggers

Revalidation is required if the implementation diff, worktree, Simulator/device, overlay state mechanism, selected key/coordinate, diagnostic evidence, reviewer runtime, or Run ID changes. Any source change or publication action requires a separate Authorization.

### History

- 2026-09-19: created after Architecture and Quality returned `Pass with conditions`; bounded to the unresolved F-02/QR-01 same-coordinate overlay-state touch evidence.
- 2026-09-19: Current status updated — capture complete, AUTH consumed, Assignment not Closed; disposition follows the child receipt / Architecture final.
