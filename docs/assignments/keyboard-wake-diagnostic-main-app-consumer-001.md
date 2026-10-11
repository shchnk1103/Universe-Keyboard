# Assignment: KEYBOARD-WAKE-DIAGNOSTIC-MAIN-APP-CONSUMER-001 — Main App completeness, status and legacy fallback

Policy: 1.0.0 — [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | **Reviewed** |
| **Phase** | Executor deliverables and required CI-equivalent checks are complete on candidate `5f46d259…`; Architecture and Quality independently returned **Pass with conditions** on this exact candidate. On 2026-09-29 the Human Product Owner accepted query-wide completeness as the Assignment contract and approved the corresponding Exit Criterion wording. |
| **Material non-claims** | No standalone app install/launch or interactive repro under this Assignment; no v4 event production, Extension instrumentation, runtime/root-cause conclusion, keyboard behavior fix, Quality/Product Gate, Release, or parent Assignment Close. Simulator results are integration evidence from the combined worktree, not an isolated quality conclusion for sibling changes. |
| **Next** | Hand the reviewed candidate and evidence back to `KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001`. This child remains **Reviewed**, not Closed; no Product Gate, Release or parent closure is implied. |
| **Residuals** | `MAC-ARCH-01`: Human Product Owner accepted the reader's query-wide completeness contract; continuation verifies retention of that aggregate across pages. Page-local first-rejection discovery is outside this Assignment. Disposition and rationale are recorded in the implementation evidence and History. |

---

## Authority

- **Assignment Authority:** Product Lead.
- **Decision Source / Date:** Human Product Owner message “明确授权按这个 Assignment 开始 Main App 实现” on 2026-09-28 Asia/Shanghai. This authorizes implementation within this Assignment only; it does not authorize simulator interaction before destination reservation, Extension/KeyboardCore/RimeBridge work, runtime behavior changes, commit, push, PR, merge, Product Gate or Release.
- **Product Approver:** Human Product Owner in the current Codex task.
- **Product Criterion Disposition / Date:** On 2026-09-29 Asia/Shanghai the Human Product Owner accepted query-wide aggregation (“可以按照你的建议接受整次查询聚合”). `DiagnosticsJournalReader.beginPage` forms the query-wide completeness aggregate; continuation must preserve it. This changes the Exit Criterion interpretation only: page-local first-rejection discovery is out of scope, and this is not a Product Gate, child Close, parent Close or rollout authorization.
- **KOS 2.2 optional contracts:** Not opted in; the project pin remains advisory.

## Objective

Prepare the Main App consumer stage required by accepted [Schema Proposal 0.4](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md): consume `DiagnosticsJournalPage.completeness`, keep a bounded content-free incomplete/unsupported status visible, and prevent legacy `rime_diag_log` from masking a v1 journal that is not known to be complete and empty. Display only validated typed events, including the newly accepted lifecycle, RIME-resume and text-proxy payloads.

This stage follows the KeyboardCore reader Assignment, which is **Reviewed — Pass with conditions** on candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`. The reader owns strict raw-key validation; this Assignment owns Main App consumption, formatting, source selection and status presentation. The v4 producer remains disabled until a separately authorized paired-build rollout gate is completed.

## Assignment Bindings

| Responsibility | Assignment |
|---|---|
| Domain Owner | **App & Data Operations Maintainer** — owns Main App diagnostics query, formatter, source selection and user-visible status. |
| Executor | **Current Codex task** — authorized to implement this Assignment after its acknowledged entry criteria were revalidated and it advanced through `Ready` to `Active`. |
| Environment Executor | **Current Codex task** — future local test/build operations only after the exact destination is checked for exclusive use; no standalone diagnostic-app install/launch, App Group mutation or RIME deployment. Standard `xcodebuild test` may boot the reserved destination and install/launch its test host. |
| Human Dependency | **Not Applicable** — no manual reproduction is needed for this Main App consumer slice. Any later human runtime reproduction belongs to a separate Assignment. |
| Architecture Reviewer | **Architecture & Knowledge Steward** — reviews reader boundary, completeness semantics and cross-target/rollout exclusions. |
| Quality Reviewer | **Quality, Performance & Release Maintainer** — independently reviews the exact Main App candidate and required test/build evidence. |
| Product Approver | **Human Product Owner** in the current Codex task. |

### Scope Acknowledgments

| Role | Status |
|---|---|
| App & Data Operations Maintainer (Domain Owner) | **Acknowledged** 2026-09-28 Asia/Shanghai against scope revision `4d8e861c…`; no implementation authority or Product decision. |
| Current Codex task (Executor) | **Acknowledged** 2026-09-28 Asia/Shanghai against scope revision `4d8e861c…`; Assignment preparation only, no implementation authority inferred. |
| Current Codex task (Environment Executor) | **Acknowledged** 2026-09-28 Asia/Shanghai against scope revision `4d8e861c…`; will verify an exclusive destination before any Simulator-backed test/build. No Simulator action occurred during Assignment preparation. |
| Architecture & Knowledge Steward | **Acknowledged** 2026-09-28 Asia/Shanghai against scope revision `4d8e861c…`; no later Architecture verdict inferred. |
| Quality, Performance & Release Maintainer | **Acknowledged** 2026-09-28 Asia/Shanghai against scope revision `4d8e861c…`; no later Quality Gate inferred. |

Role assignment follows the ownership roster and [`main-app-ui.md`](../playbooks/main-app-ui.md). All five required roles acknowledged the original exact scope revision; their acknowledgments are distinct from implementation authorization and subsequent reviews. The later query-wide criterion disposition was explicitly made by the Product Owner and confirmed by the Domain Owner, Architecture Reviewer and Quality Reviewer; it did not expand implementation scope or authorize new code/environment work.

## Required Inputs and Baseline

- Human-accepted, document-only Proposal 0.4: complete-file SHA-256 `c20038a8c33acd9ce777eb6b1fe0ea72d0076bcbcaa82e6aaec9293ac9b75774`; reviewed design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`.
- KeyboardCore reader Assignment and exact candidate above, plus its [implementation evidence](../evidence/keyboard-wake-diagnostic-reader-implementation-001-2026-09-28.md) and [Quality review](../reviews/keyboard-wake-diagnostic-reader-implementation-001-quality-review-2026-09-28.md). Residual KWR-01 requires downstream Main App consumers to use `DiagnosticsJournalReader`; direct `JSONDecoder` decoding does not provide the same strict raw-key boundary. KWR-02 records the accepted Foundation duplicate-member limitation.
- Pinned repository baseline: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`. At Assignment preparation, the following current Main App files are byte-identical to that baseline; SHA-256 identities are recorded for revalidation:
  - `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift` — `4fa4a32e40be357a840f87b2c1e4695d0eaf6ae371a11eddc665c5498c151ff3`.
  - `Universe Keyboard/Views/Diagnostics/DiagnosticsStore.swift` — `5036ce52647b5d5383450b8b7e99e9b09d43c3cb308075aee967843c5073aed4`.
  - `Universe Keyboard/Views/Diagnostics/DiagnosticsLogContentView.swift` — `0cac3632266f9934391510c0fc4e97aa96eb69bf3da1aab1f046c164c72b04b1`.
  - `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift` — `aeb7e75c30614af255e0a224eaae422ac06527e75accccbb1db41510aff934af`.
  - `UniverseKeyboardTests/DiagnosticsStoreTests.swift` — `5374ae55fd68f9ac1aa3c0380e9f7e9e3763967d4988b1459cf9cefcb268d38f`.
- Existing source facts to preserve: `CompositeDiagnosticsLogSource` falls back to shared-defaults `rime_diag_log` when the v1 source reports no content and no result that claims v1 ownership; `V1DiagnosticsLogSource` currently tracks page status and selected-day state; the diagnostics UI already displays the source's bounded `pagingNotice` for both empty and non-empty results. `T9DevicePreflightEvidenceView` has a separate internal-only filtered-token read of the legacy key; it does not decode v1 JSONL events and is outside this source-selection change.
- This worktree contains unrelated in-progress Keyboard Extension, KeyboardCore and parent-assignment changes. Do not revert, reformat, stage or include them in this Assignment.

## Scope and Effects

### In scope, after implementation is separately authorized

- Main App reader/source integration under `Universe Keyboard/Views/Diagnostics/`:
  - consume `DiagnosticsJournalPage.completeness` from the initial page, bounded recent-preview path and subsequent pages;
  - retain incomplete/unsupported state alongside existing page/budget status, including mixed cases, and show a fixed content-free notice when any examined record is rejected;
  - keep valid typed events available while never displaying rejected raw JSON or arbitrary decoder errors;
  - select the v1 source and suppress legacy fallback whenever the v1 result is incomplete/unsupported, even if it contains no valid events;
  - preserve the existing legacy read-only fallback only for its currently intended complete-empty v1 case and preserve existing selected-day/error behavior;
  - format only the reviewed typed fields for `keyboard.lifecycle.phase_changed`, `rime.resume.phase_changed` and `text_proxy.operation_phase_changed`, including optional finite failure/session counters where present.
- Focused Main App tests in `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift` and, if needed, `DiagnosticsStoreTests.swift`. They must exercise the real `CompositeDiagnosticsLogSource` decision for complete-empty, incomplete-empty, mixed valid/rejected and a multi-page query whose query-wide completeness was aggregated by `beginPage` and must remain intact through continuation. They do not need to simulate a rejection first discovered on a later page. If production dependencies prevent deterministic coverage, add the smallest injectable source seam backed only by a temporary journal directory and an isolated UserDefaults suite; never use the real App Group. Touch `DiagnosticsStore.swift` or `DiagnosticsLogContentView.swift` only if the existing notice plumbing cannot faithfully present combined completeness/page status.
- Confirm the primary diagnostics journal display/export path continues through `DiagnosticsJournalReader`; direct raw `JSONDecoder` use for journal events is out of scope and must be returned for Product reassignment if found. The internal-only T9 preflight token reader remains a separate, filtered legacy-log path.

### Non-goals

- No edits to `Packages/KeyboardCore`, `Packages/RimeBridge`, Keyboard Extension sources, event schema/allowlists, ADR 0027, Proposal 0.4 or retention/writer behavior.
- No enabling v4 writing, changing diagnostic capture gates, adding event producers, or claiming the paired Main App + Keyboard Extension rollout gate is satisfied.
- No manual Simulator boot, standalone diagnostic-app installation/launch, interactive runtime reproduction, keyboard behavior fix, RIME deployment, App Group data mutation, physical-device use, commit, push, PR, merge, TestFlight or Release action. The authorized `xcodebuild test` harness may boot the exact reserved Simulator destination and install/launch its test host.
- No new unbounded log text, paths, host text, input/candidate content, free-form error strings or details from rejected records.

## Entry Criteria

Before lifecycle advances to `Ready`:

1. Domain Owner, Executor, Environment Executor, Architecture Reviewer and Quality Reviewer acknowledge this exact Assignment revision and its dependencies.
2. Revalidate the pinned Main App source hashes and exact KeyboardCore reader candidate. Any mismatch requires a new baseline and reviewer rebind.
3. Confirm by source scan that the primary diagnostics journal display/export path uses `DiagnosticsJournalReader` as the strict raw-key boundary; any bypass in that path blocks this scope. Preserve the separately filtered, internal-only T9 token reader as out of scope.
4. Architecture and Quality agree that incomplete/unsupported state is preserved across initial, preview and continuation reads and cannot be mistaken for a complete empty result.
5. Product Owner explicitly authorizes Main App implementation in this Assignment. Assignment creation and reviewer acknowledgment alone do not grant this permission.
6. Before any Simulator-backed test/build, Environment Executor verifies an exact destination and a no-concurrent-use window. Do not boot, install or launch a shared Simulator as part of environment discovery; a reserved destination may be used only by the authorized `xcodebuild` test harness.

## Exit Criteria

- Complete-empty v1, incomplete-empty v1, mixed valid/rejected records, unsupported schema/code/key, and multi-page query cases demonstrate correct source selection, bounded notice and legacy-fallback suppression; only valid typed events are formatted.
- A deterministic `CompositeDiagnosticsLogSource` integration matrix proves that legacy `rime_diag_log` is used only after a successful complete-empty v1 read and remains suppressed whenever the query-wide completeness aggregate is incomplete, including when that aggregate is retained through continuation. The criterion does not require page-local first discovery of a rejection.
- Existing v3 formatting, date selection, paging, partial-window and legitimate complete-empty legacy fallback behavior remain covered.
- The three accepted new event families are rendered from finite typed values only; no arbitrary/raw data is surfaced.
- Main App UI evidence maps loading, successful content/empty, bounded incomplete/unsupported status and read failure to the existing UI state transitions; document physical-device evidence as **Not Applicable** because this slice changes neither Full Access nor cross-target runtime behavior.
- Required CI-equivalent checks for Main App source changes are run in repository order: Swift format hard gate, KeyboardCore package tests, `RimeBridgeTests`, `Universe Keyboard` Debug tests and Release build, using the repository's configured iOS Simulator destination. Record exact source/test candidate, destination, toolchain and outputs. No standalone candidate install/launch or shared user-data mutation is required; the standard test harness may launch its host app.
- Independent Architecture and Quality reviews bind to the exact final candidate. Their conclusions remain separate from Product Gate, Release and this parent Assignment's closure.
- Handoff to `KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001` records the exact candidate/evidence, source-selection matrix, bounded status semantics, formatter allowlist, findings and the still-disabled v4 producer.

## Stop Conditions

- Reader candidate, schema contract, source baseline or strict-key validation boundary changes.
- Any v1 incomplete/unsupported condition cannot be distinguished from successful empty completion, or a required consumer bypasses `DiagnosticsJournalReader`.
- The UX requires new privacy-sensitive fields, unbounded diagnostics, altered capture defaults, a changed legacy-fallback contract, or a new persistent/writer behavior.
- The exact test/build destination is occupied, cannot be independently reserved, or would require changing another task's simulator state.
- Implementation requires KeyboardCore, RimeBridge, Extension or paired-build rollout work; stop and request a separate Assignment.

## Handoff and Revalidation

- **Handoff Target:** Return the reviewed candidate and evidence to `KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001` and the Human Product Owner. This child remains Reviewed until its owning Gate closes it; no Close decision is recorded here.
- **Revalidation Triggers:** Any change to Proposal 0.4, KeyboardCore reader candidate, Main App source/API, fallback semantics, formatter allowlist, privacy/display behavior, build target or simulator availability.

## History

- 2026-09-29 Asia/Shanghai — Main App implementation candidate `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a` passed Swift strict lint, KeyboardCore `1132/0`, iPhone 17 Pro Max / iOS 26.0 `RimeBridgeTests` `81 passed / 20 skipped / 0 failed`, App + Keyboard tests `380 passed / 9 skipped / 0 failed`, Simulator Release build, and final documentation checks; full result paths and executor evidence grades are in the [implementation evidence](../evidence/keyboard-wake-diagnostic-main-app-consumer-001-implementation-2026-09-28.md). Architecture and Quality both returned **Pass with conditions** on the exact candidate and rechecked the final evidence/status mirrors. The prior test failures were invalid fixtures fixed only in the test file. Simulator exclusivity was confirmed by the Human before use; the approved destination is back to Shutdown. At this point the only open condition was `MAC-ARCH-01`, pending Product disposition; no Product Gate, Release, runtime reproduction/root-cause, behavior fix, or parent Close.
- 2026-09-29 Asia/Shanghai — Human Product Owner accepted query-wide completeness as the contract for this Assignment (“可以按照你的建议接受整次查询聚合”). Scope and Exit Criteria now require the reader-aggregated status from `beginPage` to remain intact through continuation; page-local first-rejection discovery is out of scope. Architecture and Quality reviewers confirmed this disposition resolves their `MAC-ARCH-01` condition while their exact-candidate conclusions remain **Pass with conditions**. Executor deliverables are **Completed** and the child Assignment advances to **Reviewed**; `MAC-ARCH-01` is recorded as an accepted residual. This is not Assignment Close, Product Gate, Release, runtime/root-cause conclusion, behavior fix or parent closure.
- 2026-09-29 Asia/Shanghai — App & Data Operations Maintainer re-reviewed the revised Main App criterion against Assignment SHA-256 `7dd647c1080936285289c01b5abe32a9b2359ac2c3cb25e044d9c3be13fb5bff` and acknowledged that it accurately reflects the Main App source-selection/status responsibility and `beginPage` query-wide contract. No code, test or Simulator action was taken for this confirmation.
- 2026-09-29 Asia/Shanghai — Independent reviews returned on exact candidate `5d152894ff2ed855e1cf127407d4fdd65225916c70fdc6d840e7095da2afd549`: Architecture **Pass with conditions**; Quality **BLOCKED — verification incomplete**. Architecture and Quality agree that continuation coverage proves retention of reader-aggregated query completeness, not first rejection discovery on a later page. The evidence now records this boundary and preserves it as an unresolved Exit Criterion interpretation. Simulator-backed `RimeBridgeTests`, App + Keyboard Debug tests and Simulator Release build remain pending. CI-default iPhone 17 Pro is Booted and referenced by active TYPO-CORRECTION-002 profiles; the separate iPhone 17 Pro Max / iOS 26.0 is Shutdown but still needs Human exclusivity confirmation. No behavior/runtime/root-cause or Gate/Release claim.
- 2026-09-29 Asia/Shanghai — Main App consumer candidate `5d152894ff2ed855e1cf127407d4fdd65225916c70fdc6d840e7095da2afd549` recorded in the [implementation evidence](../evidence/keyboard-wake-diagnostic-main-app-consumer-001-implementation-2026-09-28.md). Swift strict lint and diff check passed; KeyboardCore exact reader candidate passed 1132 tests; generic iOS Debug `build-for-testing` compiled app/test bundles, and generic iOS Release build succeeded. These generic builds did not run tests or touch a Simulator. Independent Architecture / Quality candidate reviews were requested. Simulator-backed checks remain pending because CI-default iPhone 17 Pro is Booted and referenced by the active TYPO-CORRECTION-002 XcodeBuildMCP profiles; a separate iPhone 17 Pro Max / iOS 26.0 is Shutdown but still needs Human exclusivity confirmation. No behavior/runtime/root-cause or Gate/Release claim.
- 2026-09-28 Asia/Shanghai — Human Product Owner explicitly authorized implementation with “明确授权按这个 Assignment 开始 Main App 实现”. Revalidated the five pinned Main App source hashes and exact KeyboardCore reader aggregate candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`; confirmed the strict raw-key boundary remains `DiagnosticsJournalReader`, and all five roles had acknowledged scope revision `4d8e861c63b97ff7bcd484cc736a0317ea063dac4fa0c47b5c92271d9d2f889d`. Entry criteria 1–5 are satisfied, so lifecycle advanced through **Ready** to **Active**. Entry criterion 6 remains a gate before Simulator-backed checks; no Simulator was touched. Implementation stays within Main App and its tests.
- 2026-09-28 Asia/Shanghai — Human Product Owner authorized preparing this separate Main App consumer Assignment after accepting Proposal 0.4 as a document-only design. Ownership was routed to App & Data Operations Maintainer with Architecture and Quality reviewers. Assignment creation and reviewer acknowledgments did not grant implementation authority; no source, test, build or Simulator action occurred during preparation. Lifecycle advanced from **Assigned** to **Acknowledged** against exact scope revision `4d8e861c63b97ff7bcd484cc736a0317ea063dac4fa0c47b5c92271d9d2f889d`.
