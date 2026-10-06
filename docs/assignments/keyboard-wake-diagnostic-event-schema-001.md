# Assignment: KEYBOARD-WAKE-DIAGNOSTIC-EVENT-SCHEMA-001 — lifecycle / host-proxy 诊断事件契约

> Policy: [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) v1.0
> Decision source: Human Product Owner explicitly authorized creation on 2026-09-27 and narrowed this Assignment to schema design and review on 2026-09-27 Asia/Shanghai. No source-code implementation is in scope or authorized.

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Reviewed** |
| Current phase | Proposal 0.4 was accepted by the Human Product Owner on 2026-09-28 as a document-only design, bound to pre-disposition complete-file SHA-256 `c20038a8c33acd9ce777eb6b1fe0ea72d0076bcbcaa82e6aaec9293ac9b75774` and reviewed design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57` |
| Material non-claims | No Swift implementation, build, test execution, simulator operation, behavior fix, root-cause conclusion, Quality Gate, Product Gate or Release claim is authorized or completed. |
| Next handoff | The accepted design is handed to the parent lifecycle Assignment. Any implementation, Extension emission, tests, builds or runtime evidence requires a separate Assignment and explicit authorization. |
| Residuals | [Future implementation conditions](#residual-dispositions) remain accepted as out of scope for this design Assignment; no implementation authorization is granted. |

---

## Authority

- **Assignment Authority:** Product Lead.
- **Decision Source / Date:** Human Product Owner instructions in this Codex task, 2026-09-27 Asia/Shanghai: authorized creation of this Assignment, then confirmed schema design/review-only scope.
- **Product Approver:** Human Product Owner in the current Codex task.
- **Product disposition:** Accepted on 2026-09-28 Asia/Shanghai as a document-only design, bound to the exact pre-disposition proposal file SHA-256 `c20038a8c33acd9ce777eb6b1fe0ea72d0076bcbcaa82e6aaec9293ac9b75774` and reviewed design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`. This does not adopt an implementation contract or ADR and does not authorize implementation.
- **Implementation Authorization:** **Out of scope and not granted.** Any later Swift implementation, tests, build or runtime validation requires a separate Assignment and explicit Product authorization.
- **KOS 2.2 optional contracts:** Not opted in. The project pin remains advisory; this Assignment does not make any optional contract required.

## Objective

Define a small, content-free typed event schema that can distinguish Extension lifecycle transitions, RIME resume/owner readiness, and calls crossing the `UITextDocumentProxy` adapter during a future App Switcher reproduction. The schema should let a later Keyboard Experience Assignment correlate those observations to an existing `appearanceID` without claiming that a void proxy call succeeded in the host.

The current lifecycle diagnosis and user-observed test are recorded in [KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001](keyboard-wake-lifecycle-diagnostics-001.md) and its [evidence report](../evidence/keyboard-wake-lifecycle-diagnostics-2026-09-27.md), report SHA-256 `d9c416b24380ac56d6bc17c7d0660aefe852ac1e376c46f979c9bb2d83c86f0f`. [Schema Proposal 0.4](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md) was accepted as a document-only design on 2026-09-28; no implementation is authorized.

## Boundary and Scope

This Assignment is limited to an architecture-ready, content-free schema proposal and independent review. It may:

1. Review ADR 0027's event-code, typed-field, privacy, high-fidelity and hot-path constraints for the named observation gap.
2. Define allowlisted event/field values for lifecycle phase, resume phase/readiness, and proxy operation/phase. Reuse existing envelope identities such as `processInstanceID`, `appearanceID`, local sequence, `sessionEpoch` and revision wherever applicable.
3. Produce and review a schema proposal in this Assignment record or a linked design document. The proposal must state event/payload pairing, allowlisted values, versioning and old-reader behavior, privacy limits, and ownership handoff. It must not edit Swift or test files.
4. Identify whether ADR 0027 needs a durable-documentation change. Any change to its policy or privacy contract requires a separate Architecture/Product decision and Assignment before editing that contract.

Candidate event dimensions for review (not yet an approved schema):

- Extension `viewWillAppear`, `viewDidAppear`, `viewWillDisappear`, host resign-active and host active-return callbacks;
- RIME resume start/terminal state plus bounded owner readiness and session epoch;
- proxy call method (`setMarkedText`, `insertText`, `unmarkText`) and entered/returned phase, with only bounded counts if Architecture finds them necessary.

`returned` means only that the synchronous API call returned to the adapter. It must not be named or interpreted as host insertion success.

## Non-goals

- No call-site instrumentation in `Keyboard/` or `Packages/RimeBridge/` in this Assignment.
- No input, candidate, marked-text, host text, context-before/after, coordinates, schema names, free-form errors, or other user content in the journal.
- No production behavior/session policy changes, RIME deployment, App Group mutation, simulator build/install/operation, or human reproduction in this Assignment.
- No conclusion that App Switcher caused a specific callback, process restart, session failure, candidate render failure, or host-proxy failure.
- No commit, push, PR, merge, TestFlight, Product Gate, Quality Gate or Release action.

## Required Inputs

- Baseline source: `9eb83158e49218c1e8f75dbe7dd9e0390db81409` (must be revalidated read-only before finalizing the proposal).
- Lifecycle evidence report above and the read-only Keyboard Experience source review recorded in the parent Assignment.
- [`ADR 0027`](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md), [`KeyboardCore Playbook`](../playbooks/keyboard-core.md), [`Debug Investigator Playbook`](../playbooks/debug-investigator.md), and [`Assignment Policy`](../ASSIGNMENT_POLICY.md).
- Parent lifecycle Assignment remains **Active** and owns any later Extension event emission and simulator reproduction after its own scope is revalidated.

## Assignment Responsibilities

| Responsibility | Assignment value |
|---|---|
| Domain Owner | **Input Intelligence Maintainer**. Owns the typed event model in `Packages/KeyboardCore`; Keyboard Experience Maintainer is consulted for the later Extension emission interface. Proposal 0.4 **Acknowledged**. |
| Executor | **Current Codex task**. Scope is limited to preparing the schema proposal and coordinating its review; no source-code, test, build or environment execution. |
| Environment Executor | **Not Applicable**: this Assignment produces and reviews a document-only schema proposal; no simulator, device, deployment, account, build or test operation is in scope. |
| Human Dependency | **Not Applicable**: no human-operated reproduction or external action is needed in this Assignment. The parent Assignment retains its own human reproduction dependency. |
| Architecture Reviewer | **Architecture & Knowledge Steward** for ADR 0027/privacy/hot-path, compatibility and ownership-boundary review. Proposal 0.4 **Pass**. |
| Quality Reviewer | **Quality, Performance & Release Maintainer** for schema-proposal completeness and diagnostic evidence-boundary review. Proposal 0.4 **Acknowledged with conditions**; no test execution, Quality Gate or Release conclusion. |
| Product Approver | Human Product Owner in the current Codex task. |

## Assignee Acknowledgments

| Responsibility | Status | Boundary |
|---|---|---|
| Input Intelligence Maintainer (Domain Owner) | **Acknowledged** revised scope; Proposal 0.4 **Acknowledged** | Owns KeyboardCore event schema. Confirms the `failed` event/failure pairing, `UInt64` bound, wire allowlists, and reader behavior proposal. |
| Current Codex task (Executor) | **Acknowledged** 2026-09-27 Asia/Shanghai | Prepares and coordinates a document-only proposal and review; no source-code, test, build or environment execution. |
| Architecture & Knowledge Steward | Proposal 0.4 **Pass** | Confirms strict unknown-key rejection, incomplete/fallback semantics, same-build artifact-level v4 rollout gate, and ADR 0027 disposition. |
| Quality, Performance & Release Maintainer | Proposal 0.4 **Acknowledged with conditions** | Confirms proposal completeness and evidence boundaries. Schema v4 still needs Architecture/Product decision; duplicate JSON member handling and rollout evidence belong to a future implementation Assignment. No tests, Quality Gate or Release conclusion. |
| Keyboard Experience Maintainer (consulted) | **Acknowledged** revised boundary, 2026-09-27 Asia/Shanghai | Parent retains future Extension emitters, runtime reproduction, candidate/UI observation, and host insertion validation. Child scope is proposal/review only. |

### Role Review Results

- Domain Owner acknowledges the revised design-only scope and owns the KeyboardCore schema proposal. The proposal must distinguish `Diagnostics/v1` journal layout from `DiagnosticEvent.schemaVersion`, decide whether the latter remains 3 or advances to 4, and state old/new reader-writer compatibility. Implementation tests are outside this Assignment.
- Architecture acknowledges the revised scope and ownership boundary. The proposal must not claim old readers validate versions they currently ignore; it must state mixed-generation behavior, fail-closed unknown-value behavior, privacy limits, high-fidelity gating and hot-path constraints. Changes to ADR 0027, Main App reader behavior, RimeBridge or Extension emission require separate scope/owners.
- Quality's earlier **Needs changes** finding is resolved by Product's scope narrowing. Quality accepts the document-only reviewer role with conditions: the proposal must specify schema/version compatibility, complete allowlists, fail-closed handling, privacy exclusions and handoff requirements. Test execution and test-case verification are out of scope here.
- Keyboard Experience accepts the revised consultation boundary: future Extension event emission, runtime reproduction, candidate/UI observation and host insertion validation remain in the parent Assignment.

### Product Scope Decision

On 2026-09-27 Asia/Shanghai, the Human Product Owner selected the design/review-only scope: Environment Executor and Human Dependency remain Not Applicable; this Assignment will produce a reviewed schema proposal and will not include source edits, test execution, builds, or simulator/device operations. Any later implementation requires a separate Assignment and explicit authorization.

### Proposal Review Results

- Reviewed design-content identity: [Schema Proposal 0.4](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md), SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`.
- Accepted pre-disposition complete proposal file identity: SHA-256 `c20038a8c33acd9ce777eb6b1fe0ea72d0076bcbcaa82e6aaec9293ac9b75774`. The difference from the reviewed design-content identity is limited to review/status metadata; no schema, compatibility, privacy, or rollout-gate content changed.
- Domain Owner: **Acknowledged** for the reviewed design content and confirmed the conclusion remains applicable to the current complete file identity.
- Architecture: **Pass** for the reviewed design content and confirmed the conclusion remains applicable to the current complete file identity; no remaining architecture blocker. Product accepted the v4 recommendation as a design choice only; no ADR or production contract was adopted.
- Quality: **Acknowledged with conditions** for the reviewed design content and confirmed the conclusion remains applicable to the current complete file identity. This is a document review, not a Quality Gate. Future duplicate-JSON-key behavior and artifact-level v4 rollout evidence must be settled and proven in a separate implementation Assignment.
- Product disposition: **Accepted** on 2026-09-28 Asia/Shanghai as the document-only design, bound to the exact pre-disposition complete-file identity above and reviewed design-content identity above. This is not acceptance of a production implementation contract, an ADR, or implementation authorization.
- Post-disposition proposal file SHA-256: `e501a4075c24a79de560e7381ae361708c1a085250470e69840e23c930b53c06`; the status wording and checksum-reconciliation note changed, while the reviewed design-content SHA-256 remains `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`.

## Entry Criteria

- Product Lead has recorded one primary Domain Owner and named the Executor and applicable reviewers; no required responsibility remains `UNKNOWN` (satisfied 2026-09-27 Asia/Shanghai).
- Product has selected the document-only schema design/review scope and the record reflects matching Not Applicable Environment Executor and Human Dependency bindings.
- Required Domain Owner, Executor, Architecture Reviewer and Quality Reviewer acknowledge this exact scope. Keyboard Experience acknowledges its consulted handoff boundary.
- Architecture confirms the design/review scope fits ADR 0027's privacy, high-fidelity, hot-path and ownership constraints. Specific schema/version/reader decisions are deliverables for proposal review, not prerequisites to drafting.
- Exact source baseline `9eb83158e49218c1e8f75dbe7dd9e0390db81409` and existing diagnostic-event contract are revalidated read-only before drafting; no code or tests are changed or run. (Satisfied 2026-09-27 Asia/Shanghai.)

## Exit Criteria

- [Schema Proposal 0.4](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md) records its date and exact baseline source SHA, and specifies:
  - an explicit decision on whether `schemaVersion = 3` remains or changes, with rationale and an old-reader/new-writer compatibility matrix;
  - the complete event-code, payload, field, type, allowed-value, origin and high-fidelity applicability allowlists;
  - legal event/payload pairings and fail-closed behavior for unknown codes/values, malformed payloads, unsupported fields and mismatches;
  - privacy exclusions, including input, candidates, marked text, host context, schema names, paths and free-form strings;
  - bounded semantics for proxy operations and phases, with `returned` meaning only that the adapter call returned;
  - hot-path constraints and the boundary to later Extension emission and host insertion evidence.
- Domain Owner, Architecture and Quality provide review conclusions bound to the exact proposal revision and referenced source baseline. (Satisfied for Proposal 0.4; identity and conclusions are recorded above.)
- The proposal states that `returned` means only that the adapter call returned, not that host text insertion succeeded.
- Handoff to the parent Keyboard Experience Assignment names the reviewed contract and remaining Extension emission, runtime reproduction, candidate/UI observation and host insertion evidence. This Assignment makes no performance, implementation, Quality Gate, Product Gate or Release claim.
- Handoff states that any later implementation Assignment must separately authorize source changes and tests, and must include `swift test --package-path Packages/KeyboardCore` in its exit criteria; this Assignment does not run that command.

## Residual Dispositions

The Human Product Owner accepts these items as explicit future implementation conditions outside this design-only Assignment. The `accept` dispositions close no implementation or Quality Gate and grant no authority to begin that work.

| Residual ID | Residual | Owner | Disposition | Pointer |
|---|---|---|---|---|
| `SCHEMA-RES-01` | `schemaVersion = 4` is accepted as this proposal's recommendation only; adopting a durable production contract or changing an ADR needs a separate Architecture/Product decision. | Product Lead / Architecture & Knowledge Steward | `accept` | [Proposal version decision](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md#version-decision-proposed) |
| `SCHEMA-RES-02` | Strict raw-key validation and duplicate JSON member-name handling are not implemented or tested; the future implementation must prove detection or document a parser limitation without claiming detection. | Input Intelligence Maintainer | `accept` | [Proposal wire-key contract](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md#event-and-payload-allowlist) |
| `SCHEMA-RES-03` | Paired installed Main App / Keyboard Extension build identity, explicit v3/v4 reader support, incomplete-status behavior, legacy-fallback suppression and rollout evidence remain unimplemented. | Input Intelligence Maintainer / App & Data Operations Maintainer / Quality Reviewer | `accept` | [Proposal rollout gate](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md#readerwriter-compatibility-matrix) |
- Human Product Owner records a disposition on the exact reviewer-bound proposal revision. Scope approval alone is not schema approval; this disposition is not a Product Gate or Release decision.

## Stop Conditions

- Required role acknowledgment or the schema proposal's version/privacy/ownership decision remains unresolved.
- The necessary observation requires arbitrary text, candidate values, host context, coordinates, synchronous I/O, or hot-path persistence.
- The proposal requires changing ADR 0027, Keyboard UI emission, RimeBridge internals, a lifecycle/product contract, source-code edits, tests or any runtime activity; stop and obtain a separate Assignment and Product authorization.
- ADR 0027 would need a durable policy change without Architecture/Product authorization.
- Evidence or source identity differs from the pinned baseline without revalidation.

## Handoff

- **Target:** `KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001` (Keyboard Experience Maintainer owns the Extension lifecycle/UI event-emission and reproduction stage under that Assignment).
- **Required handoff content:** exact proposal revision and referenced source baseline; reviewed code/field allowlist; privacy/performance constraints; schema-version/reader behavior; reviewer conclusions and unresolved alternatives; explicit statement that source implementation, schema tests, call-site emission and simulator reproduction are still pending. Any later implementation Assignment must include the full KeyboardCore test command `swift test --package-path Packages/KeyboardCore` in its exit criteria.
- **Revalidation triggers:** baseline changes, event/field scope changes, privacy or retention contract changes, a new simulator target, or evidence establishing a KeyboardCore/RimeBridge runtime failure.

## History

- 2026-09-27 Asia/Shanghai — Product authorized creation of this independent Assignment record only. No code or environment action occurred.
- 2026-09-27 Asia/Shanghai — Product assigned Input Intelligence Maintainer as Domain Owner; current Codex task as Executor; Architecture & Knowledge Steward and Quality, Performance & Release Maintainer as reviewers; Environment Executor and Human Dependency are Not Applicable for the schema-only scope. Keyboard Experience Maintainer is consulted on the emission handoff. Lifecycle is **Assigned** pending acknowledgments. Implementation authorization remains not granted.
- 2026-09-27 Asia/Shanghai — Product narrowed this Assignment to document-only schema design and review. Swift edits, tests, builds and simulator/device operations were removed; any later implementation requires a separate Assignment and explicit authorization. Domain Owner, Architecture, Quality and consulted Keyboard Experience acknowledged the revised boundary; Quality resolved the earlier Environment/Human binding mismatch with proposal-content conditions. Exact pinned source baseline was revalidated read-only, and proposal drafting began. Lifecycle advanced through Acknowledged and Ready to Active.
- 2026-09-28 Asia/Shanghai — Human Product Owner accepted Proposal 0.4 as a document-only design, bound to pre-disposition complete-file SHA-256 `c20038a8c33acd9ce777eb6b1fe0ea72d0076bcbcaa82e6aaec9293ac9b75774` and design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`. Executor deliverables and the required Domain, Architecture, Quality and Product conclusions are complete; the lifecycle advanced through **Completed** to **Reviewed**. The accepted residuals remain future implementation conditions; no schema implementation, ADR adoption, tests, build or simulator action is authorized. The reviewed deliverable is handed to the parent Assignment; this child lifecycle is **Reviewed**, not Closed.
