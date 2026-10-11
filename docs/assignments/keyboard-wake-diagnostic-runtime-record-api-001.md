# Assignment: KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001 — Typed v4 event submission

Policy: 1.0.0 — [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Reviewed** |
| Current phase | Human Product Owner accepted the exact ten-file implementation candidate with Architecture/Quality conditions on 2026-09-29 (manifest SHA-256 abbe6154…17f975c); Runtime/Ingress remain v3 by default and v4 requires explicit opt-in. Architecture and Quality are **Pass with conditions**; see the [Product review](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001-product-review.md). |
| Material non-claims | This Product review is not a Quality/Product Gate, Release, Simulator/device result, production v4 emission, Extension call-site enablement, paired-build implementation, behavior fix, root-cause finding or parent closure. No commit, push, PR or merge is claimed. |
| Next handoff | The separate [Extension paired-build rollout Assignment](keyboard-wake-diagnostic-extension-paired-rollout-001.md) is now **Acknowledged / Not Ready** under an Assignment-establishment-only authorization. Its exact role ACKs are recorded; paired prerequisite/source/environment revalidation, a fresh exclusive Simulator window and separate implementation authorization remain before `Ready`. This Runtime API Assignment remains Reviewed, not Closed. |
| Residuals | Carry forward Architecture/Quality conditions: preserve v3 default and explicit-v4 opt-in; satisfy the separate paired-build Assignment’s same-build Main App + Extension compatibility gate before production emission; retain the recorded coverage gaps and Reader duplicate-key limitation; re-freeze/re-review if any of the ten manifest files changes. |

---

## Authority

- **Assignment Authority:** Product Lead.
- **Decision Source / Date:** The Human Product Owner accepted the bounded v4 persisted-writer scope on 2026-09-29 Asia/Shanghai (“接受，可以按照你的建议继续”), then separately authorized local implementation on 2026-09-29 Asia/Shanghai (“授权该 Assignment”). The prior instruction “角色分配你可以按照KOS设定自行分配” authorizes the responsibility configuration below. The bounded implementation authorization is recorded in the linked Product Authorization; it does not authorize publication or the deferred paired-build rollout.
- **Product Approver:** Human Product Owner in the current Codex task.
- **KOS 2.2 optional contracts:** Not opted in; the project pin remains advisory.

## Accepted Product Objective

Add the three typed `DiagnosticsJournalRuntime` methods together with the minimum v4 event-construction, encoding and journal-append support needed to persist the accepted Proposal 0.4 envelopes through the existing bounded asynchronous ingress when a build explicitly opts into writer v4. Runtime and ingress remain v3 by default; typed v4 submissions fail closed unless that version is explicitly selected. This expands the original API-only proposal because the current v3-only writer cannot persist v4 payloads.

## Assignment Responsibilities

The Human Product Owner delegated role allocation according to KOS and accepted continuation of this scope. These are the task-level bindings for this Assignment.

| Responsibility | Assignment |
|---|---|
| Domain Owner | **Input Intelligence Maintainer** — owns KeyboardCore runtime/event submission API. |
| Executor | **Current Codex task** — implement the accepted KeyboardCore Runtime Record API scope in the dedicated worktree; no publication action is authorized. |
| Environment Executor | **Not Applicable** — the scope uses the host-side KeyboardCore package suite only; no Simulator or device operation is required. |
| Human Dependency | **Not Applicable** — no manual reproduction or user data is in this scope; that evidence remains with the parent lifecycle task. |
| Architecture Reviewer | **Architecture & Knowledge Steward**. |
| Quality Reviewer | **Quality, Performance & Release Maintainer**. |
| Product Approver | Human Product Owner in the current Codex task. |

## Accepted Scope and Effects

**Product scope and architecture contract accepted conditionally.** ADR 0036 is binding under its conditional acceptance decision. The separate implementation authorization and fresh source/test/writer-isolation evidence are recorded in the linked Product Authorization, fresh-worktree baseline receipt and ownership recheck. Domain Owner, Executor, Architecture and Quality acknowledged the exact pre-transition scope candidate before the lifecycle-only Ready writeback. The corrected Executor candidate and validation are recorded in the [implementation evidence](../evidence/keyboard-wake-diagnostic-runtime-record-api-001-implementation-2026-09-29.md); exact-candidate Architecture and Quality reviews returned **Pass with conditions** in the [Architecture receipt](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-architecture-implementation-review-2026-09-29.md) and [Quality receipt](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-quality-implementation-review-2026-09-29.md). The Human Product Owner accepted the exact corrected implementation candidate with conditions; see the [Product review](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001-product-review.md).

- Add typed `DiagnosticsJournalRuntime` submission methods for `keyboard.lifecycle.phase_changed`, `rime.resume.phase_changed`, and `text_proxy.operation_phase_changed`, using the reviewed payload types.
- Add the minimum v4 construction/encoding and `DiagnosticsJournal.append` handling required to persist these accepted composite payloads.
- Preserve the writer-version invariant: a v3 writer emits all new events as v3; a v4 writer emits all new events from that build as v4, including existing event codes; persisted v3 history remains v3 and is never rewritten in place.
- Keep Runtime and ingress defaults at v3. The three typed v4 methods accept submissions only when the caller explicitly constructs a v4 Runtime; no production call site in this Assignment opts in.
- Never encode a v4-only code or payload as v3; a v3 writer rejects or omits it. Mixed retained v3/v4 history is interpreted only by the explicitly version-aware v4 reader.
- Fix `.debug`, `.display` for lifecycle/proxy, and `.engine` for RIME resume in the typed methods; callers cannot override those contract values.
- Keep generic `fields` empty. Generate process identity and local sequence in the runtime; accept only the optional `appearanceID` and `actionSequence` values explicitly passed by the caller. Validate phase/failure pairings at the API boundary and fail closed.
- Submit only through the existing bounded asynchronous `DiagnosticsJournalIngress`. The hot-path API must not encode JSON, access preferences/files, wait for persistence, accept strings, or perform synchronous I/O; serialization and append remain owned by the ingress/journal writer.
- Expected production files: `DiagnosticEvent.swift`, `DiagnosticsJournal.swift`, and `DiagnosticsJournalRuntime.swift`. Tests must use temporary journal storage. Because current shared work already modifies `DiagnosticEventTests.swift` and `DiagnosticsJournalTests.swift`, create isolated test coverage or obtain an explicit writer handoff before touching either file; do not mix or overwrite their dirty changes.

### Non-goals

- No new event code, payload field, enum value, or semantic change beyond accepted Proposal 0.4; no reader completeness, Main App formatting/fallback, or Extension call sites. Extension event emission remains deferred to a separate paired-build rollout Assignment.
- No RimeBridge/session instrumentation or capture-gate changes. ADR 0036 acceptance does not authorize implementation or change this Assignment's boundaries.
- No v4 producer enablement, paired-build rollout, Simulator operation, manual reproduction, behavior fix, commit, push, PR, merge or Release.

## Required Inputs

- [Product Decision PD-KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001-authorization.md), accepting the bounded persisted-writer scope and the writer-version invariant.
- [ADR 0036](../architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md) is **Accepted (Conditional)** by the [acceptance decision](../product-decisions/ADR-0036-ACCEPT-authorization.md). The separate implementation authority and fresh worktree source/test identities are recorded in the [Product Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001-implementation-authorization.md) and [baseline receipt](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-fresh-worktree-baseline-2026-09-29.md).
- Human-accepted document-only Proposal 0.4, reviewed design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`.
- KeyboardCore reader Assignment **Reviewed — Pass with conditions**, candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`, which supplies the typed payload model and wire validation.
- Fresh nine-file KeyboardCore source/test manifest SHA-256 `3e7338898e88d5732d98da210d31df915bfe4b8880a9704273c96d38b6240f2c` at base `9eb83158e49218c1e8f75dbe7dd9e0390db81409`; see the [baseline receipt](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-fresh-worktree-baseline-2026-09-29.md).
- Parent [KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001](keyboard-wake-lifecycle-diagnostics-001.md) remains Active. The linked [Extension producer Assignment](keyboard-wake-diagnostic-extension-producer-001.md) has been Reassigned to the separate [paired-build rollout Assignment](keyboard-wake-diagnostic-extension-paired-rollout-001.md), now Acknowledged / Not Ready under establishment-only authorization.

## Entry Criteria

The Assignment entered `Ready` and then `Active`; the following Entry Criteria were completed before the Ready transition:

1. Domain Owner, Executor, Architecture Reviewer and Quality Reviewer acknowledge the exact final Assignment/ADR revisions.
2. Architecture review and conditional Human Architecture Authority / Product Lead acceptance of ADR 0036 are complete; the accepted ADR binds the writer-version and v3/v4 reader-compatibility contract. This satisfies only the ADR-acceptance portion of the Entry Criteria.
3. The Human Product Owner separately authorizes implementation. **Satisfied** by the linked Product Authorization.
4. Revalidate reader, `DiagnosticEvent.swift`, `DiagnosticsJournal.swift`, `DiagnosticsJournalRuntime.swift`, and test-file identities. Confirm no active writer on any in-scope production or test file; preserve existing dirty KeyboardCore changes and record the isolated test baseline. **Satisfied for the dedicated managed worktree** by the linked baseline receipt; modified reader tests remain protected.
5. Confirm typed submission uses the existing bounded asynchronous ingress; v4 construction, encoding and append remain writer-owned and content-free. The existing generic runtime submission path reaches the ingress. The new typed methods must retain that path, require explicit v4 opt-in, and prove both default-v3 rejection and v4 persistence in focused tests before completion.

## Exit Criteria

- With explicit writer-v4 opt-in, the three typed methods persist accepted payloads with the correct code/category/level, a schemaVersion 4 envelope, empty `fields`, and runtime-generated identity/sequence through bounded ingress. Default Runtime/ingress remain v3 and reject these typed submissions; a v4 writer emits all new events from that build as v4, including existing codes; retained v3 history is not rewritten; a v3 writer emits new events as v3 and never encodes v4-only data.
- Focused tests verify constructor validation, `phase`/`failure` pairing, exact v4 encoding and journal append using temporary storage only; tests do not access the real App Group.
- Prove the hot path only submits values to bounded ingress and performs no synchronous encoding, persistence, preference access or waiting.
- Run strict Swift formatting for changed Swift files and `swift test --package-path Packages/KeyboardCore`; record exact source/test identities, toolchain and result.
- This Assignment adds no Extension call site and does not enable v4 production. Call-site wiring and paired-build enablement belong to a separate future Assignment.
- Handoff records the exact API candidate and test evidence for the separate paired-build rollout Assignment; this Runtime API Assignment neither implements Extension call sites nor authorizes paired-build enablement.

## Stop Conditions

- The implementation would change an event code/payload contract beyond Proposal 0.4 or the accepted ADR 0036 contract.
- A payload cannot be submitted without generic fields, free-form data, direct persistence or synchronous waiting.
- Before Ready or implementation, an unapproved external change alters any frozen production/test input identity, or another task has an active writer on any in-scope production/test file; stop and rebind. Changes made by the authorized implementation form a new candidate and are not themselves a stop condition; freeze their identities before review.
- Work requires Keyboard UI, RimeBridge, Main App reader/fallback or paired-build rollout changes.

## Handoff and Revalidation

- **Handoff Target:** Keyboard Experience Maintainer for a separately assigned paired-build rollout, with API candidate identity, focused test evidence and unchanged Extension v4-emission status.
- **Revalidation Triggers:** Changes to Proposal 0.4, the reader candidate, typed payload API, ingress behavior, ownership or the exact runtime source baseline.

## Review Findings — reviewed draft identity only

- Architecture reviewed the prior draft SHA-256 `500a5411cc4c4b2a5d458b12e3855c9ac4a3aee043bf2fe90ab13994cf690f6e` and returned **Blocked as written**: `DiagnosticEvent` construction/encoding and `DiagnosticsJournal.append` are v3-only, so the proposed typed methods cannot persist v4 events through the existing ingress. Architecture required a Product/Architecture decision to re-scope the writer contract.
- Quality reviewed that same prior draft identity and found the narrow typed-API scope **Pass with conditions**, but not eligible for Ready/implementation. Quality also required isolated test-file ownership, exact source/test identities, independent exact-candidate reviews, and no claims beyond envelope/ingress behavior.
- The scope at SHA-256 `b23f7c226ef6ed23bb786c99086bf50b713bac390b8fb6a13094762f0f322d81` later received Architecture and Quality **Pass with conditions** as a Pending draft only. That review did not include the Product decision or ADR 0036 changes in this revision and must not be reused as current review.

## Product Review — 2026-09-29 Asia/Shanghai

- **Disposition:** Accepted with conditions for this exact implementation candidate; lifecycle advanced **Completed → Reviewed**.
- **Decision source:** The Human Product Owner replied “接受” in the current Codex task after being asked to accept the candidate bound to manifest SHA-256 abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c with the Architecture/Quality conditions listed in the decision record.
- **Candidate identity:** The canonical ten-file source/test manifest and every listed current file SHA-256 were rechecked immediately before recording this decision and match the manifest. The source/test candidate remains uncommitted in the dedicated managed worktree.
- **Review basis:** Architecture **Pass with conditions** ([review](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-architecture-implementation-review-2026-09-29.md)); Quality **Pass with conditions** ([review](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-quality-implementation-review-2026-09-29.md)); both reviewers independently confirmed that later Assignment/parent/Active Work changes were status/history synchronization only and did not change scope or candidate identity.
- **Conditions carried forward:** Keep Runtime/Ingress default v3 and v4 explicitly opt-in. Production .v4 call sites require a separately issued and authorized paired-build Assignment, the same Main App + Extension build, and the reader/writer compatibility evidence named by Architecture. Preserve Quality residuals: incomplete exhaustive combinations for lifecycle/proxy/RIME phases, backpressure, writer I/O failure and suspend races; preserve the documented Reader duplicate JSON-key limitation. Any change to the ten-file manifest requires a fresh identity and exact-candidate reviews.
- **Boundary:** This is Product review of the implementation result only. It does not close this Assignment or the parent, establish a Product/Quality Gate or Release, authorize production event emission or paired rollout, or claim a behavior fix or root cause.

## History

- 2026-09-29 Asia/Shanghai — Human Product Owner accepted the exact corrected implementation candidate with conditions carried forward; the Product decision is recorded in [KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001 product review](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001-product-review.md). After the Architecture, Quality and Product conclusions, this child advanced **Completed → Reviewed**. This is not Assignment Close, a Gate, Release, production v4 enablement or paired-build authorization.
- 2026-09-29 Asia/Shanghai — Executor self-review found that the first candidate selected writer v4 unconditionally in the production ingress path, which conflicted with the explicit no-production-v4 boundary. That candidate (`647894b0…`) was superseded before exact-candidate review. The corrected candidate restores default v3 and requires explicit v4 opt-in for typed events; no production source call site opts in. Its ten-file canonical manifest is `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c`; strict Swift format, `git diff --check` and KeyboardCore tests passed (1137 tests, 0 failures). Architecture and Quality returned **Pass with conditions** for that exact candidate; see the [Architecture receipt](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-architecture-implementation-review-2026-09-29.md) and [Quality receipt](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-quality-implementation-review-2026-09-29.md). At that review point the Product Approver decision was pending; it was later resolved by the [Product review](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001-product-review.md). No Gate, Release, production v4 emission, paired-build rollout or parent closure is claimed.
- 2026-09-29 Asia/Shanghai — After Ready identity rebinds and an immediate pre-edit ownership recheck (`4fb7ed66…`), the Executor advanced the Assignment **Ready → Active** to begin the authorized bounded implementation. The lifecycle writeback changed no scope or authorization; no source/test result existed at the instant of transition.
- 2026-09-29 Asia/Shanghai — Domain Owner, Executor, Architecture and Quality completed exact-candidate acknowledgments for Assignment `f55fe752…` and ADR 0036; the Product authorization, nine-file baseline and bounded ownership recheck were verified. With the existing generic submission path confirmed to use bounded ingress, lifecycle advanced **Assigned → Acknowledged → Ready**. This status writeback does not alter scope; implementation had not started at the transition.
- 2026-09-29 Asia/Shanghai — Human Product Owner authorized local implementation of this Assignment (“授权该 Assignment”) and asked that an exclusive new worktree be created if ownership in the existing worktree was unknown. A dedicated managed worktree was created at `/Users/doubleshy0n/.codex/worktrees/runtime-record-api-impl/Universe Keyboard`, based on the reviewed `9eb83158e49218c1e8f75dbe7dd9e0390db81409`; the five-file Reader dependency was copied byte-for-byte and revalidated as candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`. The nine-file source/test manifest is recorded in the [fresh-worktree receipt](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-fresh-worktree-baseline-2026-09-29.md). The older combined worktree was preserved. `origin/main` could not be queried because network access was unavailable; no latest-main claim is made. Exact reviewer rebind remains pending; implementation has not started.
- 2026-09-29 Asia/Shanghai — Domain Owner acknowledged the exact scope candidate `412004c39cab3239fa3a174dab0a38106c26e52fadc47f478b198de771469a92` as **Pass with conditions**; see the [Domain Owner ACK](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-domain-owner-ack-2026-09-29.md). Executor acknowledged the same bounded documentation/review-preparation Assignment scope. Existing Architecture **Pass with conditions** and Quality **ACKNOWLEDGED** records bind the pre-acceptance reviewed candidate. Human Architecture Authority and Product Lead subsequently accepted ADR 0036 conditionally; see the [acceptance decision](../product-decisions/ADR-0036-ACCEPT-authorization.md). The Assignment remains **Assigned** because separate implementation authorization and source/test/writer-ownership revalidation remain outstanding Entry Criteria. This writeback records status/history only and does not change the reviewed scope. No implementation or runtime action is authorized.
- 2026-09-29 Asia/Shanghai — At Assignment creation, the Human Product Owner accepted the bounded v4 persisted-writer scope and delegated role allocation according to KOS. Responsibilities were recorded; lifecycle was Assigned pending exact-scope acknowledgments and ADR 0036 review/acceptance. Extension call sites were deferred to a separate paired-build rollout Assignment. No source code, tests, build, Simulator, installation, runtime event production or implementation authorization was claimed at that point.
