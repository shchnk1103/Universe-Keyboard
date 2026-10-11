# Assignment: KEYBOARD-WAKE-DIAGNOSTIC-READER-IMPLEMENTATION-001 — KeyboardCore v3/v4 event reader

> Policy: [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) v1.0
> Product decision source: Human Product Owner instruction “可以按照你的建议继续” on 2026-09-28 Asia/Shanghai, authorizing the recommended bounded reader-compatibility Assignment.
> This Assignment is separate from the document-only schema Assignment and does not authorize v4 event production, Main App changes, Extension emission, simulator work, or a behavioral fix.

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Reviewed** |
| Current phase | Independent Quality review returned **Pass with conditions** on exact candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`; implementation exit criteria are met. |
| Material non-claims | The v4 producer remains disabled; no Main App reader/fallback behavior, Keyboard Extension emission, runtime reproduction, root cause, behavior fix, Quality Gate, Product Gate or Release conclusion is included. |
| Next handoff | App & Data Operations Maintainer for a separately authorized Main App reader/status/fallback Assignment. No simulator, app/extension, RIME or runtime work is included here. |
| Residuals | [`Quality review and residual dispositions`](../reviews/keyboard-wake-diagnostic-reader-implementation-001-quality-review-2026-09-28.md). |

---

## Authority

- **Assignment Authority:** Product Lead.
- **Decision Source / Date:** Human Product Owner instruction in this Codex task on 2026-09-28 Asia/Shanghai, following the recommendation to create a separate reader-compatibility implementation Assignment before enabling new event production.
- **Product Approver:** Human Product Owner in the current Codex task.
- **Product-selected slice:** Implement only the KeyboardCore schema model/decoder and journal-reader completeness result described below; preserve v3 writing. This Assignment is **Active** under the Human Product Owner's 2026-09-28 authorization.
- **Implementation Authorization:** This record captures the bounded implementation decision. Execution may begin only after required assignees acknowledge the exact scope and all Entry Criteria are satisfied. It does not authorize any excluded cross-target or runtime work.
- **KOS 2.2 optional contracts:** Not opted in; the project pin remains advisory.

## Objective

Implement the accepted [Schema Proposal 0.4](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md) in `Packages/KeyboardCore` as a read-side compatibility foundation: retain v3 decoding and writing, add explicit v3/v4 event decoding for the proposed typed event model, and surface rejected/unsupported records as an incomplete journal result instead of silently treating the retained journal as a normal empty result.

This is a prerequisite only. It does not enable a v4 producer; the paired Main App read/fallback behavior and same-build App + Keyboard Extension rollout gate remain future work.

## Assignment Bindings

| Responsibility | Assignment |
|---|---|
| Domain Owner | **Input Intelligence Maintainer** — owns KeyboardCore typed event and decoder correctness. |
| Executor | **Current Codex task** — implements only this Assignment after it reaches `Ready`. |
| Environment Executor | **Current Codex task** — local KeyboardCore package test, configured Swift format/lint, and result capture only; no Simulator, device, app deployment, RIME deployment or account operation. |
| Human Dependency | **Not Applicable** — no manual reproduction is part of this reader-only stage. |
| Architecture Reviewer | **Architecture & Knowledge Steward** — confirms protocol/version, strict-key, duplicate-member and ownership boundaries. |
| Quality Reviewer | **Quality, Performance & Release Maintainer** — independently reviews exact test and decoder evidence; no Release conclusion. |
| Product Approver | **Human Product Owner** in the current Codex task. |

The Domain Owner, Architecture Reviewer and Quality Reviewer have acknowledged this implementation scope. Their scope acknowledgments and the completed pre-`Ready` checks satisfied the start conditions; they do not represent a Quality Gate, Product Gate or Release conclusion. Earlier schema-design acknowledgments alone would not substitute for this implementation-scope confirmation.

### Scope Acknowledgments

| Role | Status |
|---|---|
| Input Intelligence Maintainer (Domain Owner) | **Acknowledged** 2026-09-28 Asia/Shanghai for this exact KeyboardCore reader scope; confirms the parser limitation is accurately stated and Architecture has accepted it for this stage. |
| Current Codex task (Executor) | **Acknowledged** 2026-09-28 Asia/Shanghai: accepts only the KeyboardCore reader scope and its v3-writer/non-runtime boundaries. |
| Current Codex task (Environment Executor) | **Acknowledged** 2026-09-28 Asia/Shanghai: local KeyboardCore package testing, configured Swift format/lint and evidence capture only; no Simulator, device, deployment or account operations. |
| Architecture & Knowledge Steward | **Acknowledged** 2026-09-28 Asia/Shanghai: confirms source identity, accepted duplicate-member parser limitation, v3 writer invariant and additive public completeness carrier. |
| Quality, Performance & Release Maintainer | **Acknowledged** 2026-09-28 Asia/Shanghai: accepts the planned rejection-class × read-path matrix and local package/format evidence; no Quality Gate conclusion. |

## Required Inputs and Baseline

- Product-accepted schema design: [Proposal 0.4](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md), accepted pre-disposition complete-file SHA-256 `c20038a8c33acd9ce777eb6b1fe0ea72d0076bcbcaa82e6aaec9293ac9b75774`; reviewed design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`. The complete-file digest was corrected from a truncated transcription against the prior recorded `shasum` output; this repairs identity metadata only.
- Pinned source baseline: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`.
- Current relevant source identities, confirmed unchanged from the pinned baseline at Assignment creation:
  - `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` — SHA-256 `1bd22fde04849e6a5f85ebc2750e80b7888931a3dc9a9e59c1aef3376ead3613`.
  - `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` — SHA-256 `9c999e18645573da1519d0f84be0f83152e800a41b109783b5730788f7a4f005`.
- Existing focused tests:
  - `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` — SHA-256 `89e60f281385a447a2475e1866325cfcaa8ec3dd134356c159ff6b47cd4d6a30`.
  - `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` — SHA-256 `a712ec5b004af538346b63deac2ffad4980bb4d80c35a4c9c91fdaba8095820d`.
  - `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalRuntimeTests.swift` — SHA-256 `ce92f25fd0d0666582217c78cd233615e18c78c65f3036fe78d77ccdf66459f0`.
- The worktree has pre-existing Keyboard Extension controller edits for the parent diagnostic effort. They are outside this Assignment, are not part of this baseline’s KeyboardCore sources, and must not be imported, reverted or reformatted as part of this slice.

## Boundary and Scope

### In scope

- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` and, if needed, a new source file under `Packages/KeyboardCore/Sources/KeyboardCore/`:
  - add the exact finite v4 codes, payload wrappers, field allowlists, value constraints and code/payload pairings in Proposal 0.4;
  - decode retained v3 events and proposed v4 events explicitly, rejecting unsupported versions and invalid pairings;
  - validate each event against its version-specific code/payload allowlist; a v4-only code or payload is invalid when labeled v3;
  - keep newly constructed/written events at schema version 3. Do not switch the static writer version or enable v4 writing in this Assignment.
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` and its snapshot/page result types:
  - inspect raw JSON keys before typed decoding; strictly reject unknown top-level, payload and field keys for v4 records, while preserving valid historical v3 records;
  - propagate a bounded, content-free incomplete/unsupported result when a record is skipped for an unsupported version/code, unknown key/value, malformed payload, or invalid event/payload pairing;
  - carry completeness through every public journal read path (`latest`, `beginPage`, `recentPreview` and `nextPage`); continue reading valid lines, but never report a source containing rejected records as a normal complete empty journal.
- Focused tests in the existing KeyboardCore diagnostics test files, or a new test file under `Packages/KeyboardCore/Tests/KeyboardCoreTests/`.
- Add a bounded, content-free completeness carrier to each existing public journal result (`DiagnosticsJournalSnapshot` and `DiagnosticsJournalPage`) while preserving source compatibility. Do not add cases to `DiagnosticsJournalPageStatus`, which has exhaustive Main App consumers. The Main App may ignore the new carrier until a separate Assignment; this work makes no user-visible or fallback-suppression claim.
- Preserve the v3 writer invariant even when v4 events are decoded: a v4-only code or payload must never be silently re-created and serialized with `schemaVersion = 3`. Either reject non-v3/non-writable events at the writer boundary or isolate reader-only v4 values from the writable v3 event type; add focused regression coverage.
- Document the selected duplicate-member limitation: the current Foundation `JSONDecoder` keyed decoding path does not expose repeated raw member occurrences. This Assignment does not claim duplicate-name detection or incomplete signaling for duplicate-name records. Obtain Architecture confirmation before `Ready`; if the limitation is not accepted, stop and return for a separately bounded raw-token scanner decision.

### Out of scope

- Any source change in the Main App target, Keyboard Extension, `Packages/RimeBridge`, or another package.
- Main App display/formatter/source-selection/legacy-fallback changes. In particular, no claim is made that the current Main App will correctly surface this new incomplete result.
- Emitting any v4 event or changing the writer schema version from 3.
- Simulator/device use, manual App Switcher reproduction, app install/reinstall, App Group mutation or RIME deployment.
- Changing keyboard behavior, determining the root cause, changing ADR 0027, or claiming Quality/Product/Release Gate completion.

## Entry Criteria

- Product has selected this bounded KeyboardCore reader stage (satisfied by the 2026-09-28 instruction); the scope remains separate from the accepted design-only Assignment.
- Input Intelligence Maintainer, Executor, Environment Executor, Architecture Reviewer and Quality Reviewer acknowledge this exact implementation scope and its non-goals.
- Before `Ready`, the Domain Owner and Architecture Reviewer confirm the v3-writer/v3+v4-reader boundary, v4-to-v3 writer rejection/isolation invariant, additive completeness carrier (without changing `DiagnosticsJournalPageStatus`), and the explicit duplicate-member parser limitation.
- Revalidate the exact Git base and all relevant source/test hashes immediately before implementation. If relevant KeyboardCore files differ from the pinned baseline or have unreviewed local changes, stop and record the new candidate identity before proceeding.
- No v4 producer is active or being enabled by parallel work; any conflict in that condition blocks this Assignment.

## Exit Criteria

- KeyboardCore explicitly supports valid v3 and v4 event decoding per Proposal 0.4 while all newly constructed and persisted writable events remain v3; a decoded v4-only value cannot be serialized as v3.
- A separate bounded completeness value is carried by `latest`, `beginPage`, `recentPreview` and `nextPage` results; existing `DiagnosticsJournalPageStatus` cases and Main App source compatibility remain unchanged. Main App presentation and legacy-fallback suppression remain out of scope.
- For each detectable rejection class below, the implementation report includes a matrix covering every applicable public read path (`latest`, `beginPage`, `recentPreview`, `nextPage`): input class, whether valid neighboring records remain available, and returned completeness. `latest`, `beginPage` and `recentPreview` cover both mixed and rejected-only histories; rejected-only `beginPage` must return incomplete with no cursor, never a normal complete empty result. `nextPage(after:)` applies only to cursor-bearing mixed history and must preserve query-level incompleteness even when a rejected record is outside the first event page. Rejected-only `nextPage` is not applicable by contract because no valid cursor exists; do not manufacture a status-only cursor. Mark legacy-fallback behavior `out of scope` for this KeyboardCore Assignment.
- The rejection matrix and focused regression coverage include unsupported schema versions/codes, v4-only code or payload labeled v3, unknown raw top-level/payload/field keys, unknown enum values, malformed or missing payload members, invalid code/payload pairings, mixed valid and rejected history, writer-version behavior, and privacy-key exclusions. Every detectable class must be checked through each applicable public read path.
- The required read-path matrix is:

  | Rejected input class | `latest` | `beginPage` | `recentPreview` | `nextPage` |
  |---|---|---|---|---|
  | Unsupported schema version or code | Required | Required | Required | Required |
  | v4-only code/payload labeled v3 or invalid code/payload pairing | Required | Required | Required | Required |
  | Unknown raw top-level, payload or field key; unknown enum value | Required | Required | Required | Required |
  | Malformed or missing payload member | Required | Required | Required | Required |

  For `latest`, `beginPage` and `recentPreview`, each required cell covers mixed valid/rejected history (valid events remain available and completeness is incomplete) and rejected-only history (never a normal complete empty result). For `nextPage`, each cell covers cursor-bearing mixed history only and proves frozen query completeness remains incomplete even when the rejected record is outside the current event page. A rejected-only `beginPage` has no cursor, so rejected-only `nextPage` is not applicable by contract. Duplicate member names are intentionally excluded from this matrix under the documented parser limitation.
- Duplicate JSON member names remain an explicit parser limitation in this Assignment: do not claim detection, rejection, or incomplete status for them. Record Architecture’s acceptance of the limitation in the final review evidence. All other detectable rejection classes still propagate completeness on every public read path.
- Run the full target: `swift test --package-path Packages/KeyboardCore`.
- For each changed Swift file, run `xcrun swift-format format --in-place --configuration .swift-format <file>` and `xcrun swift-format lint --strict --configuration .swift-format <file>`; also run `git diff --check`.
- Record exact base/source/test digests, toolchain, commands, full output/result, coverage and known parser limitation, if any; state explicitly that `swift test --package-path Packages/KeyboardCore` is a host-side package test with no Simulator destination or Simulator conclusion; obtain independent Quality review against the exact final candidate.
- Handoff the typed reader status and consumer obligations to App & Data Operations for a separate Main App reader/fallback Assignment. Keep the writer at v3 until that downstream work and the paired-build rollout gate are separately complete and authorized.

## Stop Conditions

- The accepted Proposal 0.4 design-content identity changes, or implementation requires changing the payload/code allowlist, privacy boundary, or product semantics.
- Architecture does not accept the documented duplicate-member limitation, or strict raw-key inspection / incomplete status requires an unassigned parser or cross-target change.
- A v4-decoded event could be persisted as schema v3, or the additive completeness carrier would require changing the existing Main App consumer within this Assignment.
- Correct handling requires Main App, Extension, RimeBridge, persistence-root or runtime changes; create a separate Assignment or return to Product for reassignment.
- A writer or other task begins producing v4 before paired-reader readiness; stop and coordinate without changing that producer.
- Any test fails, Swift strict formatting fails, relevant baseline identity is uncertain, or a required reviewer cannot independently inspect the exact candidate.

## Handoff

- **Primary target:** App & Data Operations Maintainer for a separately assigned Main App reader, incomplete-status presentation and legacy-fallback suppression stage.
- **Later target:** Keyboard Experience Maintainer / parent `KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001` for a separately assigned Extension event-emission and controlled reproduction stage after the reader rollout gate is met.
- **Required handoff content:** exact candidate/source/test hashes; rejection-class × public-read-path matrix; v3/v4 decode and writer matrix; additive completeness-carrier contract; incomplete/unsupported semantics; explicit duplicate-member parser limitation and Architecture disposition; full KeyboardCore test and format results; explicit statement that the producer remains v3 and no Main App behavior or runtime evidence was changed.
- **Revalidation triggers:** Proposal/design identity, source baseline, JSON parsing behavior, reader result semantics, affected target ownership, or writer rollout changes.

## Quality Review and Residuals

The independent Quality Reviewer returned **ACKNOWLEDGED — Pass with conditions** against the exact five-file candidate digest recorded in Current Status. This review closes the Assignment's required Quality review, but is not a Quality Gate, Product Gate or Release decision.

| ID | Residual | Owner | Disposition |
|---|---|---|---|
| KWR-01 | Strict raw-key rejection is guaranteed at `DiagnosticsJournalReader`; direct `JSONDecoder().decode(DiagnosticEvent.self, from:)` can ignore unknown keys. | App & Data Operations Maintainer | **accept** for this Assignment. Main App/export consumers must use the journal reader; any direct decoding path requires a separate strict-decoder Assignment. |
| KWR-02 | Foundation's current parsing path cannot expose repeated JSON object member occurrences, so duplicate member names are not detected or reported incomplete. | Architecture & Knowledge Steward | **accept** for this Assignment, consistent with the pre-`Ready` Architecture disposition. Duplicate-name coverage is not claimed. |

Main App display/fallback behavior, Extension emission, v4 producer enablement, paired-build rollout, Simulator/runtime reproduction, performance and root-cause work remain separate future scopes. No close authorization is recorded here.

## History

- 2026-09-28 Asia/Shanghai — Human Product Owner authorized creation of this separate reader-compatibility implementation Assignment in response to the recommendation. Product selected Input Intelligence / KeyboardCore as the first slice; Main App consumption and Extension emission remain later independent stages. Assignment is **Assigned** pending implementation-scope acknowledgments. No code, tests, build or simulator action has been performed under this Assignment.
- 2026-09-28 Asia/Shanghai — Human Product Owner authorized the Coordinator to assign the KOS roles and continue the next step. Initial Domain, Architecture and Quality reviews returned `BLOCKED`; corrected the truncated pre-disposition proposal digest from the prior recorded command output, assigned local package/format evidence collection to the Environment Executor, and clarified the duplicate-member limitation, v3 writer invariant, additive completeness carrier and evidence matrix. The corrected Assignment requires exact-snapshot role re-review. No source, test, build or simulator action has been performed.
- 2026-09-28 Asia/Shanghai — Input Intelligence Maintainer, Architecture & Knowledge Steward and Quality, Performance & Release Maintainer acknowledged the corrected scope against Assignment SHA-256 `3ec7470b9ad599bd1bedf6f265bf917f35c5d2b5ae8e9fc35855b57a8904ce2d`. Lifecycle advanced to **Acknowledged**. Git/source/test and parallel-producer revalidation remain before `Ready`; no source, test, build or simulator action has been performed.
- 2026-09-28 Asia/Shanghai — Pre-`Ready` revalidation completed against Assignment SHA-256 `fc693d85d7c7784b6305fc6685c935778cf565130e182a64fd33a8f9a978403c`. `HEAD` remains pinned at `9eb83158e49218c1e8f75dbe7dd9e0390db81409`; both KeyboardCore source hashes and all three focused test hashes match the recorded baseline. The KeyboardCore diff is empty. A targeted code scan found the event writer remains at `DiagnosticEvent.schemaVersion = 3` and no v4 writer marker; current same-project active-thread summaries cover INT-003 mainline/PR review and tests under the wetype input-reliability task, with no v4 producer work identified. The other thread's simulator work was not touched. Domain Owner, Architecture Reviewer and Quality Reviewer confirmed their acknowledgments apply to this exact Assignment SHA; the final status writeback changes lifecycle/history only and does not alter the reviewed scope. Lifecycle advanced to **Ready**. This is not a Quality, Product or Release Gate conclusion. No source, test, build or simulator action has been performed under this Assignment.
- 2026-09-28 Asia/Shanghai — Human Product Owner authorized entry into the implementation stage. Lifecycle advanced from **Ready** to **Active**; the scope and exclusions are unchanged. Implementation begins only in `Packages/KeyboardCore`, with the required local package tests and configured Swift formatting evidence; no simulator, Main App, Extension, RIME deployment or runtime operation is included.
- 2026-09-28 Asia/Shanghai — Before source edits, Architecture and Quality identified that rejected-only `nextPage` coverage is impossible under the existing cursor contract: a rejected-only `beginPage` has no valid event and therefore returns no cursor. Clarified the required matrix so root reads (`latest`, `beginPage`, `recentPreview`) cover rejected-only history and `nextPage` covers only cursor-bearing mixed history, preserving frozen-query incompleteness. No reader behavior or Assignment scope changed. Domain Owner, Architecture and Quality exact-version ACK rebind is pending for this clarification; source edits have not started.
- 2026-09-28 Asia/Shanghai — Input Intelligence Maintainer, Architecture & Knowledge Steward and Quality, Performance & Release Maintainer re-bound their acknowledgments to the clarified Assignment SHA-256 `2815d51aab2127d47324722ab0c34bde5c02bab00512a5219d745f2a6a12234a`. They confirmed rejected-only `nextPage` is N/A because there is no valid cursor, root reads must report incomplete, and cursor-bearing mixed-history pages must preserve query-level incompleteness. No scope or behavior contract changed. Source implementation may proceed under the existing Active Assignment.
- 2026-09-28 Asia/Shanghai — Implemented the bounded v3/v4 KeyboardCore reader, raw-key/enum validator, read-result completeness carrier and focused rejection/read-path coverage. Candidate SHA-256 over the five in-scope Swift file digests: `affc31dd673351990d02ddff2330dcd454bcb56a814278c5959969db7cf83a7d` (individual identities and full test output are recorded in [`implementation evidence`](../evidence/keyboard-wake-diagnostic-reader-implementation-001-2026-09-28.md)). Strict Swift formatting and `git diff --check` passed; host `swift test --package-path Packages/KeyboardCore` passed 1132 tests / 0 failures on Swift 6.4, Xcode 27.0 / macOS 27. The first run exposed a test-fixture segment-boundary assumption; the fixture now writes all five records at one timestamp and the full rerun passed. One ingress async assertion failure from that earlier run did not recur in the full rerun; no out-of-scope ingress code or tests were changed. This is executor-recorded evidence only; independent Quality review is pending. No simulator, app/extension, RIME, deployment, v4 producer, commit or publication action occurred.
- 2026-09-28 Asia/Shanghai — Independent Quality review of candidate `affc31dd…` returned **Pass with conditions** and confirmed the prior v3-null payload, nested unknown enum, reader-path and privacy/multiple-wrapper findings were closed. Review also identified that the existing Runtime Route `elapsedMilliseconds` invariant (`0...600_000`) was not rechecked on raw decode, and that nonpositive budgets were undocumented caller errors. The validator now rejects out-of-range elapsed values as malformed payload; boundary fixtures cover `-1` and `600_001` through all applicable read paths. Public read API docs now state the nonpositive-budget caller contract and warn that the empty no-read result does not establish journal emptiness or cursor completion. Exact strict raw-key enforcement remains intentionally at `DiagnosticsJournalReader`; direct `JSONDecoder` use must not replace that consumer boundary. Revised candidate digest is `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`; format, diff check, and full KeyboardCore suite passed again (1132 / 0). Updated evidence and log hashes are recorded in the implementation evidence document. Awaiting independent Quality re-review; no runtime or simulator work occurred.
- 2026-09-28 Asia/Shanghai — Executor delivered the revised implementation candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`, exact source/test identities, coverage matrix, full KeyboardCore test output, toolchain and parser limitation in the linked evidence record. Strict formatting and `git diff --check` passed; the host package suite passed 1132 / 0. Lifecycle advanced from **Active** to **Completed**. No Simulator, App, Extension, RIME or runtime work occurred.
- 2026-09-28 Asia/Shanghai — Independent Quality re-review recomputed and confirmed candidate digest `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7` and test-log digest; disposition **ACKNOWLEDGED — Pass with conditions**, with no P0/P1 blocker. Runtime Route bounds and nonpositive-budget caller semantics are confirmed addressed. KWR-01 (strict raw-key enforcement is guaranteed only through `DiagnosticsJournalReader`; downstream consumer responsibility) and KWR-02 (Foundation duplicate-member parser limitation, previously accepted by Architecture) are explicitly dispositioned in the linked review record. Lifecycle advanced from **Completed** to **Reviewed**, not Closed; no close authorization, Product/Quality Gate, Simulator or runtime conclusion is implied.
