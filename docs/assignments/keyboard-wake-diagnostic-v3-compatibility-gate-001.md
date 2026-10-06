# Assignment: KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Reviewed** |
| Current phase | **Stage A and the full Stage B CI-equivalent matrix are complete on manifest r2. Architecture R8 and Quality R9 returned Pass with conditions. On 2026-09-30, the Human Product Owner accepted `AR8-SCOPE-01` with the candidate identity limited to the seven source/test files in manifest r2; no whole-worktree equality is claimed. The reviewed candidate and remaining runtime questions have been handed back to the parent Assignment; see the [handoff receipt](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-parent-handoff-2026-09-30.md).** Manifest r2 is the source/test identity; Stage A evidence remains linked to superseded pre-fix [manifest r1](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29.json). The Simulator reservation and Stage B results are recorded [here](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-reservation-2026-09-29.md) and [here](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-validation-2026-09-29.md). |
| Material non-claims | No manual Maps reproduction, production marker promotion, runtime/root-cause conclusion, behavior fix, Product/Quality Gate, Release, or parent closure is claimed. The Stage B result is limited to its authorized validation matrix and exact reserved Simulator. |
| Next handoff | The parent Assignment remains Active. Product accepted the future v6 contract and ADR 0036 Addendum 002 is Accepted; implementation pending. This Reviewed candidate remains limited to writer v5, reader v3/v4/v5 and production wake-marker emission off; its evidence does not validate or promote v6. The paired Extension rollout remains Assigned / Not Ready pending current-scope role rebind, fresh writer-v5 stage authorization, source ownership and exclusive Simulator reservation. Future v6 implementation and promotion require separate exact-candidate authorization and review. |
| Residuals | See [review residual dispositions](#review-residual-dispositions): `AR8-SCOPE-01` and `AR7-ACCEPT-01` are accepted; `Q7-COV-01` and `Q7-SKIP-01` were closed by Quality R9; `Q7-DIFF-01` was supplemented with its historical-capture limitation preserved. This child remains Reviewed, not Closed. |

---

## Authority

- **Assignment Authority:** Product Lead.
- **Decision Source / Date:** Human Product Owner authorization and accepted scope revision on 2026-09-29 Asia/Shanghai; recorded in [Product Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001-authorization.md).
- **Product Approver:** Human Product Owner in the current Codex task.
- **Product residual disposition / date:** On 2026-09-30 Asia/Shanghai, the Human Product Owner accepted `AR8-SCOPE-01` as the narrow claim that manifest r2 identifies the seven source/test files reviewed by Architecture R8 and Quality R9. This does not claim whole-worktree equality.
- **KOS contract:** KOS 2.2 remains advisory. The project’s prospective v0.9.0 independent-review scope, budget, and stop clauses apply to newly dispatched Architecture and Quality review lanes.

## Objective

Produce one isolated, local compatibility-gate candidate based on exact `origin/main` commit `84b9c19227330b0fe6ff391be001ee398010fd6a`. Integrate the previously reviewed Runtime API, KeyboardCore reader, Main App consumer, and Keyboard Extension diagnostic work; revalidate every input against the new base; preserve current schema-v5 behavior; and validate the candidate against the repository’s current CI-equivalent matrix.

The candidate supports engineering diagnosis of the reported keyboard-wake failure. It does not claim a root cause or change normal typing behavior.

## Responsibilities

| Responsibility | Assignment |
|---|---|
| Domain Owner | **Keyboard Experience Maintainer** — primary owner for Extension lifecycle and proxy instrumentation. Required domain consultation: **Input Intelligence Maintainer** for KeyboardCore event/writer/reader semantics and **App & Data Operations Maintainer** for Main App query/fallback behavior. |
| Executor | Current Codex task — authorized only within this Assignment and its local worktree. |
| Environment Executor | Current Codex task — may run local host checks now; Simulator-backed commands require a fresh exclusive-use reservation for the exact destination recorded in the evidence. |
| Human Dependency | **Not Applicable** for this source compatibility candidate; app installation and manual Maps reproduction are excluded and require a later Assignment. |
| Architecture Reviewer | Architecture & Knowledge Steward — independent review; the exact producer/version question is in the Architecture packet. |
| Quality Reviewer | Quality, Performance & Release Maintainer — independent review of the validation plan and then the exact candidate/evidence. |
| Product Approver | Human Product Owner in the current Codex task. |

Role ACKs are not blanket permissions. All role acknowledgments must bind the final Assignment identity before its implementation phase enters `Ready`.

The role ACKs and R4 reviews bind the pre-transition Assignment scope candidate SHA-256 `18bbe05e953d71c0189b08985ecdb5194c8986ab26f1f758fe450a40e3c80a14`. The lifecycle/status and review-link writeback below does not change the accepted scope, dependencies, or authority.

Architecture R5 and Quality R6 reviewed the exact integrated candidate and Stage A evidence on Assignment SHA-256 `8a74c6587dab0b65799fe3cdad4ad9b0362a927e26474a8d2da4c5325c198586`; their conclusions and usage records are linked below. This status writeback records those results without changing source/test scope, authorization, or the producer-off boundary.

### Required domain consultations

| Maintainer | Consultation boundary |
|---|---|
| **Input Intelligence Maintainer** | KeyboardCore event model, per-record schema validation, bounded writer ingress, and reader completeness behavior. |
| **App & Data Operations Maintainer** | Main App query aggregation, source selection, incomplete/unsupported status, and legacy fallback suppression. |

These are narrow domain consultations under the single Keyboard Experience Domain Owner; they do not make the consulted roles co-owners or grant them broader scope.

Current exact-scope receipts: [Input Intelligence ACK](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-input-intelligence-consultation-2026-09-29-r4.md) · [App & Data Operations ACK](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-app-data-operations-consultation-2026-09-29-r4.md) · [Domain Owner ACK](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-domain-owner-ack-2026-09-29-r4.md) · [Executor / Environment Executor ACK](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-executor-environment-ack-2026-09-29-r4.md).

## Independent reviewer lanes

The target branch adopts KOS Kit v0.9.0 reviewer scope/budget/stop clauses prospectively. The Assignment lane is divided into bounded, numbered review rounds:

- **Architecture / round 1:** resolve the persisted-version and new-marker boundary against current schema v5 before implementation. Frozen packet: [Architecture R1 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r1-packet.md); result: [Architecture R1 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r1-review.md) (**Pass with conditions**).
- **Quality / round 1:** review the validation matrix, including the current signed Keychain CI job and the fresh Simulator reservation condition. Frozen packet: [Quality R1 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r1-packet.md); result: [Quality R1 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r1-review.md) (**Pass with conditions**).
- **Architecture / round 2:** verify that this exact Assignment revision and its candidate-scoped Proposal/ADR addenda faithfully encode the R1 producer/version boundary without broadening Product scope. Frozen packet: [Architecture R2 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r2-packet.md); result: [Architecture R2 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r2-review.md) (**Pass with conditions**).
- **Quality / round 2:** verify that the producer-off boundary and test-only fixture restriction leave the validation matrix complete and executable for this exact Assignment revision. Frozen packet: [Quality R2 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r2-packet.md); result: [Quality R2 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r2-review.md) (**Pass with conditions**).
- **Architecture / round 3:** the lifecycle-sequencing review returned **Partial / incomplete** after the independent lane exhausted its 8-call budget before verifying all frozen inputs. See [Architecture R3 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r3-review.md) and its usage record. The five claims remain uncovered; a new numbered review is required.
- **Quality / round 3:** **Pass with conditions** on Assignment SHA-256 `d2d254dea05ec8fbadc8b7ff783b429e9097a5013877482b3440cfd79989f0f5`. Conditions and lane usage are recorded in [Quality R3 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r3-review.md) and its usage record. Provenance must be rebound to the final pre-edit Assignment before source changes.
- **Architecture / round 4:** **Pass with conditions** on the exact Assignment scope candidate. See the [Architecture R4 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r4-packet.md) and [review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r4-review.md).
- **Quality / round 4:** **Pass with conditions** on the exact Assignment scope candidate. See the [Quality R4 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r4-packet.md) and [review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r4-review.md).
- **Architecture / round 6:** **Partial / incomplete** because the frozen packet named a prior Architecture R5 receipt without allowing its path; see [Architecture R6 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r6-review.md).
- **Architecture / round 7:** **Partial / incomplete**; identity checks passed, but full candidate-diff and test-assertion coverage did not fit the review budget. See [Architecture R7 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r7-packet.md) and [review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r7-review.md).
- **Quality / round 7:** **Partial / incomplete**; identities matched, but raw logs, CI text, and individual skip reasons were not fully inspected. See [Quality R7 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r7-packet.md) and [review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r7-review.md).
- **Architecture / round 8:** **Pass with conditions** on source/test manifest r2; see [Architecture R8 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r8-packet.md) and [review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r8-review.md). Source/test coverage is complete; no whole-worktree equality claim is made.
- **Quality / round 8:** **Partial / incomplete**. CI lane comparison and all 30 skip names/reasons were verified. Full raw command/result binding, signed Keychain pass-line verification, fresh source/test hash checks, and a standalone diff-check receipt remain open; see [Quality R8 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r8-packet.md) and [review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r8-review.md).
- **Quality / round 9:** **Pass with conditions** on the unchanged manifest-r2 candidate. All seven source/test hashes, raw lane commands/results, signed Keychain correspondence, result metadata, and supplemental diff-check receipt were verified. See [Quality R9 packet](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r9-packet.md) and [review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r9-review.md).

### Review residual dispositions

| ID | Owner | Disposition | Status / evidence |
|---|---|---|---|
| `AR8-SCOPE-01` | Product Lead / Coordinator | `accept` | Human Product Owner accepted the bounded claim: manifest r2 identifies the seven source/test files; no whole-worktree equality is claimed despite the later status-only `docs/ACTIVE_WORK.md` edit. See [Architecture R8 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r8-review.md) and the [handoff receipt](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-parent-handoff-2026-09-30.md). |
| `AR7-ACCEPT-01` | Product Lead / Architecture Authority | `accept` | Duplicate JSON member detection remains an explicit non-claim per accepted Proposal 0.4 / ADR 0036 addenda. |
| `Q7-DIFF-01` | Evidence owner / Coordinator | `fix` | Supplemented by [later diff-check receipt](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-git-diff-check-supplement-2026-09-29.md); it is not a historical Stage B capture. |
| `Q7-COV-01` | Product Lead / Coordinator and Quality reviewer | `fix` | Closed by Quality R9 after verification of all seven source/test hashes, five raw lane commands/results, and frozen evidence bindings. See [Quality R9 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r9-review.md). |
| `Q7-SKIP-01` | Product Lead / Coordinator and Quality reviewer | `fix` | Closed by Quality R9 after verifying the signed Keychain pass line against the unsigned-lane skip; remaining skips stay itemized in Quality R8. See [Quality R9 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r9-review.md). |
- **Domain ACK and consultations:** exact-scope rebinds are recorded in the [Domain Owner ACK](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-domain-owner-ack-2026-09-29-r4.md), [Input Intelligence consultation](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-input-intelligence-consultation-2026-09-29-r4.md), and [App & Data Operations consultation](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-app-data-operations-consultation-2026-09-29-r4.md).
- Exact implementation-candidate Architecture and Quality reviews require new numbered rounds and new frozen packets after the source/test manifest and validation evidence are immutable. Round 1 conclusions are not candidate reviews or Gates.

## Accepted compatibility contract

- Preserve the latest-main event behavior and the global schema-v5 event family, including `typo_recall`.
- The integrated reader must explicitly validate and read v3, v4, and v5 records. A record is interpreted using its own schema version; mixed-version history is supported without rewriting retained records.
- A known-complete empty v1 journal is the only v1 state that may allow the existing legacy `rime_diag_log` fallback. Unsupported, malformed, or otherwise incomplete journal results must remain incomplete through query continuation and suppress legacy fallback.
- Preserve typed event validation, strict raw-key handling at `DiagnosticsJournalReader`, and the documented duplicate-JSON-member parser limitation unless implementation adds and tests detection.
- Keep the current production writer at schema v5, including `typo_recall`; do not force it back to v3 or relabel existing events.
- Add no production Extension call site that emits the new keyboard-wake markers in this candidate. A v4 wake-marker payload may appear only in an isolated test fixture backed by temporary or in-memory storage; it must not use production App Group storage, `DiagnosticsJournalRuntime`, or real Extension ingress.
- Apply the candidate-scoped interpretation recorded in the [Proposal 0.4 addendum](../plans/keyboard-wake-diagnostic-v3-compatibility-gate-001-addendum.md) and [ADR 0036 addendum](../architecture/decisions/0036-v3-compatibility-gate-001-addendum.md). A future production marker version, production mixed-version writer, changed legacy-fallback contract, or duplicate-member parser requirement needs a separate Product/Architecture decision.
- All event data stays content-free: no typed text, candidates, marked/host text, document context, text lengths, hashes of content, schema names, paths, URLs, or free-form errors.

## Scope

After this Assignment reaches `Active`, the Executor may:

1. Revalidate and integrate the reviewed Runtime API, reader, Main App consumer, and compatible Extension diagnostics into this one candidate. Preserve the latest-main typo-recall lifecycle changes and existing schema-v5 event behavior. Do not add a production wake-marker call site.
2. Update the affected tests to cover per-record v3/v4/v5 validation and mixed-version histories, current v5 typed events, strict rejection/incomplete propagation, query-wide completeness across continuation, and legacy-fallback suppression.
3. Keep new wake-marker production disabled for this candidate. Use v4 marker payloads only in isolated test fixtures backed by temporary or in-memory storage. If a fixture would touch production App Group storage, `DiagnosticsJournalRuntime`, or real Extension ingress, stop and return to Architecture.
4. Produce one source/test manifest and local validation evidence bound to the exact integrated candidate.

### Staged execution

**Stage A — isolated integration and host-side checks.** Entry requires the exact Assignment ACKs, Architecture’s version-contract disposition, source provenance, and a clean isolated writer worktree. This stage can integrate sources and run host-side checks such as `swift test --package-path Packages/KeyboardCore`, formatting, and static/diff checks. It does not use or boot a Simulator.

**Stage B — full CI-equivalent Simulator validation.** Before any command that boots, runs tests on, installs to, or otherwise mutates a Simulator, the Environment Executor must record a fresh exclusive window naming exact device model, iOS runtime, and UDID. Run all required simulator-backed validation on that same reserved UDID. If no exclusive window is available, stop this stage and report it blocked; do not silently substitute another device.

## Non-goals

- No production promotion or installation of new keyboard-wake markers.
- No manual Maps reproduction, human-operated runtime evidence, root-cause diagnosis, behavioral recovery, candidate-render or host-insertion assertion.
- No changes to normal input/session semantics, RIME deployment, deployment ownership, capture switches, retention, or App Group data outside isolated tests.
- No use or modification of the shared dirty primary checkout or either predecessor dirty worktree; read-only inspection and copying of verified source inputs into this isolated worktree are allowed.
- No commit, push, PR, merge, TestFlight, Release, Product/Quality Gate, or parent Assignment closure.

## Required inputs

- Exact base `origin/main` `84b9c19227330b0fe6ff391be001ee398010fd6a` in the managed worktree `paired-rollout-preflight`.
- Historical Runtime API candidate manifest `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c` from the retained `runtime-record-api-impl` worktree.
- Historical KeyboardCore reader candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7` and Main App consumer candidate `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a` from the retained reviewed worktree inputs.
- Historical Extension patch digest `c4998815078e790e1a14109ecefde8a3fb467f197c90eece5dbda20b4a7f7a8d`; it is an input identity only and must be re-integrated over the new Extension source, preserving current-main changes.
- Product-accepted [Schema Proposal 0.4](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md) and conditionally accepted [ADR 0036](../architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md), with the recorded [ADR acceptance](../product-decisions/ADR-0036-ACCEPT-authorization.md). Their v3/v4 claims must be checked against current schema v5; old review conclusions are not re-used as approval of the v5 revision.
- Predecessor [Runtime API](keyboard-wake-diagnostic-runtime-record-api-001.md), [KeyboardCore reader](keyboard-wake-diagnostic-reader-implementation-001.md), [Main App consumer](keyboard-wake-diagnostic-main-app-consumer-001.md), [Extension producer](keyboard-wake-diagnostic-extension-producer-001.md), and [paired-rollout Assignment](keyboard-wake-diagnostic-extension-paired-rollout-001.md). Their historical candidates and review receipts are preserved as inputs only; all source and evidence identities must be rebound to this candidate.
- Current `AGENTS.md`, `docs/CI_CHANGE_CLASSIFICATION.md`, `.github/workflows/swift6-quality.yml`, current KOS Assignment Policy and the CI test targets.
- Fresh Simulator reservation before Stage B. No reservation is recorded at Assignment creation.

## Entry criteria

1. Architecture, Domain Owner, both required domain consultants, Executor, and Quality acknowledge the exact Assignment and its boundaries. Architecture R1 resolved the current-v5 producer boundary; the linked Proposal/ADR addenda record it without rewriting their accepted historical bodies.
2. Before source edits, verify the exact base and document the provenance of every historical input. Revalidate current-base source/test identities and account for all proposed file changes; no old patch or review digest is treated as a new-base identity. The integrated candidate's complete source/test manifest is an Exit Criterion, not a prerequisite to entering `Ready` or `Active`.
3. The current dirty primary checkout and predecessor worktrees remain untouched. Confirm no other writer or process owns the new worktree before source edits.
4. Stage B is not entered until the exact Simulator has a fresh exclusive reservation. Stage A remains independently available after its own Entry criteria are met.
5. No stage may enable production marker emission or perform external publication actions.

## Exit criteria

- One local uncommitted candidate integrates the reviewed API, reader, Main App consumer, and Extension diagnostics on the exact base while preserving current v5 behavior.
- The reader test matrix covers valid v3, v4, and v5 records; mixed v3/v4/v5 histories; retained schema-v5 `typo_recall` events; unsupported/non-integer versions; unknown code and raw keys; malformed payload and code/payload mismatch; query-wide incomplete propagation through continuation; and suppression of legacy fallback on incomplete/unsupported status.
- New Extension marker behavior matches the exact Architecture-reviewed producer/version disposition, and existing v5 production diagnostics continue to behave as before.
- The exact source/test manifest and evidence identify base commit, current file hashes, toolchain, commands, environment, and result bundles. No predecessor test result is claimed for this candidate.
- Run `xcrun swift-format format --in-place --configuration .swift-format <file>` and `xcrun swift-format lint --strict --configuration .swift-format <file>` for each changed Swift file, then `git diff --check`.
- Inspect the pinned RIME vendor and verify the pinned manifest/digest; fetch only if missing.
- Run the full current CI-equivalent matrix, including the recently added Keychain job:

  ```bash
  swift test --package-path Packages/KeyboardCore
  xcodebuild -project "Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination 'platform=iOS Simulator,id=<RESERVED_UDID>' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test -resultBundlePath <RESULTS_DIR>/RimeBridgeTests.xcresult
  xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,id=<RESERVED_UDID>' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test -resultBundlePath <RESULTS_DIR>/UniverseKeyboardTests.xcresult
  xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,id=<RESERVED_UDID>' CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES -only-testing:UniverseKeyboardTests/RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem test -resultBundlePath <RESULTS_DIR>/RimeSyncKeychain.xcresult
  xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Release -destination 'platform=iOS Simulator,id=<RESERVED_UDID>' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build -resultBundlePath <RESULTS_DIR>/UniverseKeyboardRelease.xcresult
  ```

  Record exact commands, toolchain, reserved destination, output, result-bundle paths, and any failure. A test/build result is engineering evidence, not a Product/Quality Gate or runtime diagnosis.
- Independent Architecture and Quality reviews pass or disposition every residual on the exact integrated candidate. Any new baseline requires a new numbered review round and frozen packet under the adopted reviewer-lane policy.
- Handoff source identity, validation evidence, event-version limits, and unresolved runtime questions to the parent keyboard-wake diagnostic Assignment. Do not close the parent.

## Stop conditions

- The reader cannot preserve schema-v5 behavior while explicitly handling v3/v4/v5 histories, or the mixed-version semantics remain ambiguous after Architecture review.
- A change to existing v5 production events, legacy fallback semantics, privacy/capture policy, or another subsystem is required beyond this accepted scope.
- Any source identity or active writer is uncertain; a predecessor patch cannot be accounted for; or the isolated worktree is not exclusively writable.
- The exact Simulator is in use, lacks a fresh exclusive reservation, or differs from the recorded Stage B destination.
- Any test, strict formatting, pinned-vendor check, or CI-equivalent validation fails and the cause is not resolved within scope.
- Work would require installing an app, enabling production new-marker emission, manual reproduction, publication, Gate, Release, or parent closure.

## Handoff and revalidation

- **Handoff Target:** Parent `KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001`; source/test candidate and unresolved runtime questions handed back on 2026-09-30. See the [parent handoff receipt](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-parent-handoff-2026-09-30.md).
- **Handoff content:** integrated source/test manifest, exact candidate/base identity, full validation outputs and result bundles, producer-version disposition, compatibility coverage, privacy limits, unresolved observations, and explicit non-claims.
- **Revalidation trigger:** any base or in-scope source/test change, Assignment/ADR/Proposal scope change, new writer, test matrix change, Simulator identity or exclusivity change, or reviewer packet change.

## History

- 2026-09-30 Asia/Shanghai — Human Product Owner accepted the recommended disposition for `AR8-SCOPE-01`: identity is limited to manifest r2's seven source/test files, with no whole-worktree equality claim. The exact source/test candidate on base `84b9c19227330b0fe6ff391be001ee398010fd6a` has Stage A/B evidence and independent Architecture R8 / Quality R9 **Pass with conditions**; Quality residuals are closed or supplemented as listed above. Lifecycle advanced **Active → Completed → Reviewed**, and the candidate plus unresolved runtime questions were handed back to parent `KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001` in the [handoff receipt](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-parent-handoff-2026-09-30.md). This is not a Product/Quality Gate, runtime diagnosis, root-cause conclusion, behavior fix, Release, or parent closure; production wake-marker emission remains disabled.
- 2026-09-30 Asia/Shanghai — The parent paired-rollout Assignment received a separate implementation authorization and completed a read-only pre-edit Entry pass. That Entry found a conflict between the paired Assignment's explicit `.v3` production writer and this reviewed candidate's schema-v5 writer/producer-off contract; see the [paired-rollout Entry receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-pre-edit-entry-2026-09-30.md) and [writer-version reconciliation brief](../plans/keyboard-wake-diagnostic-extension-writer-version-reconciliation-001.md). This status-only handoff update does not change this Assignment's reviewed source/test scope, manifest identity, or producer-off boundary. No source, test, build, Simulator, or runtime action was taken.
- 2026-09-29 Asia/Shanghai — Human Product Owner supplied and authorized the fresh exclusive Stage B reservation: **iPhone 17 / iOS 26.0 / `D3C353BE-3AA6-499B-8F87-349073D65BE4`**. XcodeBuildMCP inventory at 2026-09-29 14:25:01 UTC confirmed this exact device/runtime was Booted; no other task profile pointed at this UDID. Reservation receipt: [Stage B reservation](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-reservation-2026-09-29.md). This lifecycle writeback does not change source/test scope, device ownership, or the producer-off boundary. Matrix execution had not started at the time of reservation recording.
- 2026-09-29 Asia/Shanghai — The first App + Keyboard Debug attempt on the pre-fix manifest r1 failed to compile `V1DiagnosticsLogSource.merging` at three calls because the pure static helper inherited actor isolation across awaited reader operations; test execution was cancelled before any test ran. The bounded fix marks that helper `nonisolated` because it combines only `Sendable` completeness values and does not access actor state. See the [run-1 failure receipt](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-run1-compilation-failure-2026-09-29.md). The source/test manifest is now r2; no r1 validation result is reused for final-candidate acceptance, so the full matrix will be rerun on r2.
- 2026-09-29 Asia/Shanghai — On source/test manifest r2, the full Stage B matrix passed on the reserved iPhone 17 / iOS 26.0 UDID. KeyboardCore: 1,177/0; RimeBridge: 105 total, 20 skipped, 0 failed; App + Keyboard: 428 total, 10 skipped, 0 failed; signed Keychain selector: 1/0; Release build succeeded. All seven manifest file hashes matched; strict Swift format lint, pinned RIME structural verification (12 framework artifacts), and `git diff --check` passed. Exact commands, toolchain, raw log hashes, result-bundle identities, and the r1 failure disposition are recorded in the [Stage B validation receipt](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-b-validation-2026-09-29.md). Exact-candidate Architecture R6 and Quality R7 reviews are now pending. This writeback records validation and does not change source scope or authority; no manual Maps reproduction, root-cause conclusion, Product/Quality Gate, Release, or parent closure is claimed.
- 2026-09-29 Asia/Shanghai — Stage A integration and host-side validation are recorded in the [source/test manifest](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29.json), [host-validation evidence](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-a-host-validation-2026-09-29.md), and [evidence addendum](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-a-evidence-addendum-2026-09-29-r2.md). All seven changed Swift files pass strict format lint; KeyboardCore reports 1,177 tests and 0 failures; the pinned RIME verify reports 12 framework artifacts. Architecture R5 returned **Pass with conditions** (see [review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r5-review.md)); Quality R5 was **Partial / incomplete** because raw lint/vendor outputs were missing (see [review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r5-review.md)). After preserving those outputs, Quality R6 returned **Pass with conditions scoped to Stage A evidence** (see [review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r6-review.md)); R5 residuals Q1/Q5 are resolved. Stage B remains pending a fresh exclusive exact Simulator reservation and full matrix. No Simulator, installation, production marker promotion, manual Maps reproduction, runtime/root-cause conclusion, Gate, Release, or parent closure occurred. This status writeback does not change the accepted scope.
- 2026-09-29 Asia/Shanghai — On exact scope candidate SHA-256 `18bbe05e953d71c0189b08985ecdb5194c8986ab26f1f758fe450a40e3c80a14`, Architecture R4 and Quality R4 returned **Pass with conditions**; the Domain Owner, both required domain consultants, and Executor/Environment Executor acknowledged the same scope. The exact base and all 15 pre-edit source/test hashes were rechecked with zero mismatches, and the isolated worktree ownership check found no other active agent or open-file owner. With Entry Criteria for Stage A met, lifecycle advanced **Assigned → Acknowledged → Ready → Active**. This status/history/review-link writeback does not change the accepted scope or authority. No source edit or validation run existed at the transition. See the [Stage A entry receipt](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-a-entry-2026-09-29.md). Stage B remains gated on a fresh exclusive Simulator reservation.
- 2026-09-29 Asia/Shanghai — Architecture R1 returned **Pass with conditions** on Assignment SHA-256 `f19ee343da3347c04f89fa0cf99bbf96c9e82d4b94fc16fdd3d56260fff38245`: preserve current schema-v5 production behavior; keep new wake markers producer-off in the production Extension; allow v4 marker payloads only in isolated temporary/in-memory fixtures; validate retained v3/v4/v5 records per record; preserve query-wide incompleteness and suppress legacy fallback except for known-complete empty v1; keep duplicate-key detection as an explicit non-claim. The result is recorded in [Architecture R1 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r1-review.md). Candidate-scoped addenda were created for [Proposal 0.4](../plans/keyboard-wake-diagnostic-v3-compatibility-gate-001-addendum.md) and [ADR 0036](../architecture/decisions/0036-v3-compatibility-gate-001-addendum.md); no production writer or Product contract was broadened.
- 2026-09-29 Asia/Shanghai — Quality R1 returned **Pass with conditions** on the same Assignment revision. The six-job CI matrix, signed Keychain selector, and one-UDID Simulator reservation gate are complete. Candidate implementation must freeze a new source/test manifest, prove fallback suppression in the integrated candidate, check the pinned RIME digest, and receive new numbered exact-candidate Architecture/Quality reviews. See [Quality R1 review](../reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r1-review.md).
- 2026-09-29 Asia/Shanghai — The R1 disposition was recorded in this Assignment. This revision still requires exact-identity acknowledgments and has not entered `Ready` or `Active`; no code, tests, builds, Simulator action, or production marker was performed.
- 2026-09-29 Asia/Shanghai — Architecture and Quality R2 returned **Pass with conditions** on Assignment SHA-256 `49638b87156ff489aa444307833e7a354259418818dd148762c60527c4b2fa2b`; both confirmed the addenda accurately record the R1 decision, with candidate-level evidence still required. Keyboard Experience, Input Intelligence, and App & Data Operations returned **ACK with conditions** on that same SHA. The [pre-edit provenance record](../evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-pre-edit-provenance-2026-09-29.md) records current-base identities and historical input boundaries.
- 2026-09-29 Asia/Shanghai — Human Product Owner authorized a minimal lifecycle clarification after the Executor identified that the former Entry Criterion 2 required an already-integrated candidate before `Ready`, although source changes were permitted only after `Active`. Entry Criterion 2 now requires exact-base and historical-input provenance before edits; the integrated source/test manifest remains an Exit Criterion. This changes lifecycle sequencing only, not product behavior or authorized scope. The exact Assignment and role ACKs must be rebound before Stage A.
- 2026-09-29 Asia/Shanghai — Architecture R3 returned **Partial / incomplete** on Assignment SHA-256 `d2d254dea05ec8fbadc8b7ff783b429e9097a5013877482b3440cfd79989f0f5`; its reviewer budget ended before full coverage, so no Architecture conclusion is inferred. Quality R3 returned **Pass with conditions** on the same revision. Domain Owner, Input Intelligence, and App & Data Operations provided narrow **ACK with conditions** rebinds on that revision. The pre-edit provenance was rechecked and rebound; see its dedicated evidence. At that historical checkpoint the Assignment remained `Assigned / Not Ready`; fresh numbered reviews and exact-scope role ACKs were still required before Ready, and are recorded above for R4.
