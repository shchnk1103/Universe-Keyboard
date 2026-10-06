# Assignment: KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001 — wake-diagnostic wire-version reconciliation

Policy: 1.0.0 — [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Reviewed** |
| Current phase | **Reviewed — Product accepted the v6 contract; ADR 0036 Addendum 002 is Accepted; implementation pending.** Architecture R7 and Quality R5 returned Pass with conditions on the exact pre-status Addendum and paired-rollout candidates. The paired rollout is now Acknowledged / Not Ready after current-scope role rebind; no implementation authorization or Simulator reservation is in place. |
| Material non-claims | No source/test change, build, Simulator action, installation, production marker emission, root-cause conclusion, Product/Quality Gate, Release or parent closure is claimed or authorized by this document-only Assignment. |
| Next handoff | Return the accepted contract and review conditions to the Active parent and paired-rollout Assignment. Current-scope role ACKs are complete. Before source work, obtain fresh writer-v5 stage authorization, verify source/provenance/ownership, and reserve an exclusive Simulator window. Future v6 implementation and promotion require separate exact-candidate authorizations and reviews. See the [M-02 state-sync receipt](../evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-adr-0036-addendum-002-state-sync-2026-09-30.md). |
| Residuals | ENTRY-ID-DRIFT-01 remains narrowly accepted as exclusion of the erroneous historical identity row. Implementation conditions remain: add v6 reader/query-completeness/legacy-fallback coverage (V6-READER-FALLBACK-MATRIX); resolve or obtain exact Product disposition for duplicate JSON members (DUPLICATE-JSON-MEMBER); retain older-reader safety as a non-claim; obtain fresh v5-stage authorization, source ownership/provenance and exclusive-Simulator evidence (PAIRED-ENTRY-REBIND); bind the acknowledged future Maps dependency to the exact v6 candidate before installation (V6-MAPS-DEPENDENCY). See [Architecture R7](../reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r7-review.md) and [Quality R5](../reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-quality-r5-review.md). |

## Authority

- **Assignment Authority:** Product Lead.
- **Decision Source / Date:** The Human Product Owner's 2026-09-30 Asia/Shanghai instruction to proceed with the recommended next step authorizes establishment of this independent document-only Assignment. The matching [Assignment-establishment authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-authorization.md) records its exact boundary. It does not select a production wire version or authorize implementation.
- **Product Approver:** Human Product Owner in the current Codex task.
- **KOS 2.2 optional contracts:** Not opted in; the project pin remains advisory.
- **Creation baseline:** Worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`, branch `codex/keyboard-wake-v3-compatibility-gate`, `HEAD` `84b9c19227330b0fe6ff391be001ee398010fd6a`. The worktree contains pre-existing uncommitted candidate changes. This commit is a navigation baseline only; Entry must revalidate the exact input document and source/test identities and must not infer that the worktree is clean or that its candidate is integrated or published.

## Objective

Resolve the schema and architecture-contract mismatch that blocks the Extension paired-rollout Assignment from becoming Ready. Produce a Product/Architecture-reviewed, content-free wire-version contract that preserves the existing schema-v5 diagnostic behavior, including v5-only `typo_recall` events, while defining a safe version and reader-compatibility path for future keyboard-wake markers.

The design must follow ADR 0036's static writer-version rule: one writer build writes all newly persisted events under its declared schema version; retained history is not relabeled or rewritten; a version-incompatible or unknown record remains visible as bounded incomplete/unsupported state and cannot be mistaken for a complete empty journal. The exact future writer version is deliberately undecided at Assignment establishment.

## Scope

This is a document-only design and review Assignment. After it reaches `Active`, the Executor may analyze only the input identities frozen and reviewed at Entry. It may:

1. Analyze the exact Proposal 0.4, ADR 0036 and acceptance decision, v3 compatibility-gate candidate manifest, paired-rollout Assignment, and relevant writer/reader/Extension source and tests whose paths and SHA-256 identities were frozen at Entry. Verify each frozen identity before use; stop and rebind if any input has drifted. Distinguish accepted contracts from unmerged candidate behavior.
2. Compare protocol options that preserve existing v5-only events and static per-build versioning. At minimum, assess extending the current v5 contract for the new markers versus introducing a forward wire version; explain the required reader support for retained v3/v4/v5 history and the selected marker version. Treat production per-event version mixing, silent downgrade, relabeling, and in-place history rewrite as prohibited unless a separately accepted decision explicitly supersedes the current contract.
3. Define the writer, event/payload, reader, incomplete-status, legacy-fallback and isolated-fixture compatibility matrix, including unsupported/unknown-version behavior and the producer-off boundary.
4. Prepare a bounded ADR 0036 addendum or successor decision record, and update the paired-rollout Assignment's compatibility/promotion sequence only after Architecture review and Product disposition.
5. Record Architecture and Quality conclusions and the Human Product Owner's disposition against exact document identities. If Product retains the current contract without authorizing a compatible producer path, hand off an explicit producer-off result rather than implying rollout readiness.

## Non-goals

- No Swift, test, project, schema implementation, parser, source-call-site or build-setting changes.
- No build, test execution, Simulator boot/use, installation, App Group mutation, manual Maps reproduction, production marker emission or production writer promotion.
- No change to ADR 0027 privacy, capture gates, retention, journal layout, asynchronous ingress, input behavior or the parent diagnostic's evidence claims.
- No schema downgrade, mixed per-event production writer versions, relabeling of v5 events, or rewrite of retained journal records under this Assignment.
- No commit, push, PR, merge, TestFlight, Product/Quality Gate, Release or parent Assignment closure.
- No root-cause or keyboard-behavior-fix conclusion.

## Required Inputs

- Human-accepted [Schema Proposal 0.4](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md), with accepted design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`; its acceptance was document-only and did not adopt a production schema contract.
- [ADR 0036](../architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md) and [conditional acceptance decision](../product-decisions/ADR-0036-ACCEPT-authorization.md).
- [M-06 writer-version reconciliation brief](../plans/keyboard-wake-diagnostic-extension-writer-version-reconciliation-001.md), which records the current contract mismatch and recommendation without itself changing the protocol.
- [V3 compatibility-gate Assignment](keyboard-wake-diagnostic-v3-compatibility-gate-001.md), exact seven-file source/test manifest r2 SHA-256 `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`, and its producer-off contract.
- [Extension paired-rollout Assignment](keyboard-wake-diagnostic-extension-paired-rollout-001.md) and its [pre-edit Entry receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-pre-edit-entry-2026-09-30.md).
- Reviewed [Runtime Record API Assignment](keyboard-wake-diagnostic-runtime-record-api-001.md) and its exact ten-file manifest SHA-256 `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c`, as historical evidence only; its older-base candidate is not proof of integration with the v5 compatibility candidate.
- Parent [KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001](keyboard-wake-lifecycle-diagnostics-001.md), which remains Active with unresolved root cause.
- `docs/ASSIGNMENT_POLICY.md`, `docs/VIRTUAL_ENGINEERING_TEAM.md`, `docs/AI_WORKFLOW.md`, `docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md`, and the relevant KeyboardCore, Keyboard UI, Main App and test-release Playbooks.

Every linked input whose content may affect the decision must be rehashed and recorded in the Entry identity packet before this Assignment becomes `Ready`; Architecture and Quality must review that packet before Ready. Historical hashes above identify predecessor evidence; they do not replace the Entry freeze. After `Active`, analysis uses only that frozen identity set. Any drift requires stopping and rebinding before the affected evidence is used.

## Assignment Responsibilities

The Human Product Owner has previously authorized KOS-based role allocation for this task series. The following bindings apply to this new bounded Assignment and require exact-scope acknowledgments:

| Responsibility | Assignment |
|---|---|
| Domain Owner | **Input Intelligence Maintainer** — owns the typed event model and KeyboardCore wire-version semantics. |
| Executor | **Current Codex task** — prepare and maintain the document-only design packet; no implementation or runtime work. |
| Environment Executor | **Not Applicable** — no build, test, Simulator, deployment or device operation is within scope. |
| Human Dependency | **Not Applicable for execution** — no human reproduction or external action is required; product disposition is a separately defined Product Approver responsibility. |
| Architecture Reviewer | **Architecture & Knowledge Steward** — independent review of version invariants, ADR impact, migration and source-of-truth updates. |
| Quality Reviewer | **Quality, Performance & Release Maintainer** — independent review of compatibility matrix, negative cases, evidence identity and scope boundaries. |
| Product Approver | **Human Product Owner** in the current Codex task — decides whether to accept a concrete, reviewed protocol recommendation. |

Keyboard Experience Maintainer and App & Data Operations Maintainer are consulted on producer and Main App reader consequences. Their consultation does not transfer Domain Ownership.

## Entry Criteria

Before this Assignment becomes `Ready` (and therefore before it may become `Active`):

- Every required assignee acknowledges the exact Assignment scope SHA-256 and confirms the stated boundary; Architecture and Quality review the same exact scope.
- After scope acknowledgments, the Executor records a fresh, exact identity set for every Required Input and the specific source/test paths needed to distinguish v5 behavior from the proposed marker contract. Architecture and Quality review that exact identity packet before Ready. The worktree's pre-existing dirty files remain outside this Assignment's edit ownership.
- The parent remains Active, the paired-rollout child remains held from source work, and no new source, reader, privacy, fallback or deployment dependency changes the question.
- Product confirms this document-only scope is still the intended decision slice if the reviewed evidence materially changes the alternatives.

This sequence is deliberate: ACK the bounded Assignment first, freeze and review the evidence identities second, then enter `Ready`; only after `Active` may substantive analysis begin. Until all Entry conditions are met, status remains **Assigned / Not Ready**. Assignment establishment itself does not satisfy Entry.

## Exit Criteria

- A complete alternatives analysis states the static writer invariant, retained-history behavior, v5 `typo_recall` preservation, marker payload/version choice or explicit producer-off disposition, v3/v4/v5/future-version reader matrix, incomplete/unsupported propagation, fallback behavior and test-fixture boundary.
- Architecture review returns a conclusion on the exact final packet and any ADR addendum; unresolved conditions are explicit and owned.
- Quality review returns a conclusion on the exact packet, evidence identities, negative cases and rollout separation; skipped checks are marked not applicable because the Assignment is document-only.
- The Human Product Owner records an exact-candidate Product disposition. Scope acceptance alone does not accept the wire-version contract.
- The accepted decision and paired-rollout handoff are reflected in one authoritative ADR/addendum and the paired-rollout Assignment; the parent diagnostic record points to that handoff. The Assignment remains separate from implementation authorization.
- Link and documentation-scope checks are recorded after the final edit. No code, tests, build or Simulator claim is made.

## Stop Conditions

- The existing schema-v5 behavior or any Required Input identity cannot be revalidated.
- A proposed path silently loses v5-only events, violates one-static-version-per-writer-build, permits unsupported history to appear complete/empty, or depends on unproven integration across different candidate bases.
- Resolving the question requires changing privacy, capture, fallback, retention, journal ownership, source, tests or runtime behavior beyond this document-only Assignment.
- Product wants to supersede the accepted ADR 0036 contract or accept a downgrade/mixed-version risk; stop and request a separate explicit Product/Architecture decision with a concrete impact record.
- Required ACK/review is missing, evidence identity drifts, or worktree ownership becomes unclear.

## Handoff and Revalidation

- **Handoff Target:** Human Product Owner for a decision on the exact Architecture-reviewed recommendation; after disposition, hand back to the Extension paired-rollout Assignment for scope rebind and Entry revalidation.
- **Required Handoff Content:** exact Assignment/design/ADR hashes; source/test manifest identities; alternatives and compatibility matrix; Architecture and Quality conclusions; Product disposition; updated paired-rollout scope or explicit producer-off result; outstanding conditions. State clearly that this does not authorize code or production emission.
- **Revalidation Triggers:** Any change to Proposal 0.4, ADR 0036, the v3 compatibility manifest, v5 event schema/producer/reader source, runtime API integration, the paired-rollout scope, a reviewer, or the parent evidence boundary.

## History

- 2026-09-30 Asia/Shanghai — The Human Product Owner authorized establishment of this independent, document-only schema/ADR reconciliation Assignment. Input Intelligence Maintainer returned exact-scope `ACK`; Architecture & Knowledge Steward and Quality, Performance & Release Maintainer returned `Pass` on the frozen round-1 packets; the Executor accepted the bounded documentation role. Environment Executor and Human Dependency are `Not Applicable` for this scope for the reasons above. Lifecycle is **Acknowledged / Not Ready**: the exact Entry identity packet and its independent review remain outstanding. The Human Product Owner's protocol disposition remains a separate Exit action. This establishes the work boundary only: no wire-version choice, protocol adoption, source/test change, build, Simulator operation, installation, marker emission, manual reproduction, Product/Quality Gate, Release or parent closure is authorized or claimed.
- 2026-09-30 Asia/Shanghai — Entry completed on Assignment scope SHA-256 `edf450b3dbfbe621849d0fbf6bc641518cbc22e992fde6239034d05d2e7729c6`. The exact identity packet is `docs/evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-entry-identity-2026-09-30.md` (SHA-256 `3a0a27291fe653daf02191622fa1392522d17b648bd5cdf74e5f13155000179b`); Quality returned `Pass with conditions` and Architecture completed its identity review across R3–R5. The residual `ENTRY-ID-DRIFT-01` is dispositioned `accept` only to exclude the erroneous historical row from current identity proof. Parent remains Active, paired rollout remains held from source work, and the identity discrepancy does not change the selected document-only decision slice. Lifecycle advanced **Acknowledged → Ready → Active** for the authorized document-only analysis. This status/history writeback does not modify the reviewed scope, authority, Required Inputs or stop conditions. See the [Entry identity record](../evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-entry-identity-2026-09-30.md), [Quality review](../reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-quality-r3-entry-review.md), [Architecture R5 review](../reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r5-receipt-identity-review.md), and [Entry transition evidence](../evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-entry-transition-2026-09-30.md). No wire version was selected or adopted, and no source/test, build, Simulator, installation or marker-emission action occurred.
- 2026-09-30 Asia/Shanghai — The bounded alternatives analysis and compatibility matrix were completed on the frozen Entry identities. The exact proposal candidate SHA-256 `3962a2f9bac051737319666775cd560c2730d776e89a141ae1ee8bcdfc71a9ed` received Architecture R6 **Pass with conditions** (packet SHA-256 `b5042e18752e6d920c9cf0be09d7f601416e66f827d91b137adaa9dc9953e778`; [review receipt](../reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r6-review.md), SHA-256 `20d861d81585c490588676e858725c1851a8183654efc5ed49d18d0dfd611af5`) and Quality R4 **Conditional / Pass with conditions** (packet SHA-256 `fc7afe2d3bdfc469b7df6b166c26ddcc12ffbb116f770e4bd8c35f44f9d9e579`; [review receipt](../reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-quality-r4-review.md), SHA-256 `3a64f5084818a1dcc9d7dfedc6caed26851ca4947c1019adc8509674955891fc`). Both reviewers allow the candidate to proceed to Human Product disposition with `ENTRY-ID-DRIFT-01` carried narrowly; Architecture's duplicate-key and future v6 test conditions remain implementation residuals. Tests/builds were not applicable to this document-only Assignment. Lifecycle remains **Active**; Human Product disposition is the next handoff. This is a status/history-only update and does not change Assignment scope, select/adopt a wire version, amend ADR 0036, update paired rollout, or authorize implementation, testing, build, Simulator, installation, marker emission, Product/Quality Gate, Release or parent closure.
- 2026-09-30 Asia/Shanghai — The Human Product Owner selected the reviewed v6 recommendation and recorded the exact v6 product contract in the [Product Decision](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-product-decision.md). This remains a Product Decision; exact Architecture/Quality review of the ADR 0036 addendum and paired-rollout translation is still pending. The revised paired Assignment corrects the historical authorization provenance: its pre-revision implementation authorization specified writer v3 and was held at Entry. This document-only Assignment remains Active and has not authorized implementation or runtime work.

- 2026-09-30 Asia/Shanghai — The Human Product Owner accepted the v6 Product Decision; the exact ADR 0036 Addendum 002 and revised paired-rollout candidates then received Architecture R7 and Quality R5 Pass with conditions. The Addendum is Accepted; implementation pending. Executor delivery is complete and the reconciliation Assignment advances Active → Completed → Reviewed; its remaining implementation conditions are carried above and in the two reviews. The paired rollout remains Assigned / Not Ready and the parent remains Active. This is a document-only M-02 status sync; it grants no source/test, build, Simulator, installation, production-emission, Gate, Release, or parent-closure authority.
