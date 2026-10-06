# Assignment: KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001 — Extension diagnostic producer and paired v6 rollout

Policy: 1.0.0 — [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Completed — 诊断 producer 与父交接交付**；2026-10-06 Human 批准选项 A 有界完成合同 |
| Current phase | Completed — 分阶段 producer/reader/安装/probe 与 M2R2 owner 对照及父交接已交付；全局 v6 emission / 已审查 v6 Maps / 严格 JSONL 未满足，按残项接受 |
| Material non-claims | C6 failure variant is not uniquely bound to machine events; C7-A source/host tests are not runtime owner-absence evidence, a fix, paired promotion, overall Gate, Release, closure or Git publication. Historical skips remain unverified/not passed. KWOPROBE is not JSONL. HOST-ACTIVATION-FIX E1 owner chain is not this Assignment's Exit. Independent Partial is not Pass. |
| Next handoff | 有界交付已归档。本地 scoped commit `247c6aad3619d8e2f807a864ef3dbe0e9a60e185` 已消费 AUTH-COMMIT；push / draft PR 走 AUTH-PUSH-PR。残项补证 / v6 promotion / merge 均需另核范围授权，不自动执行。 |
| Residuals | [本有界完成 Product 决定](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-bounded-completion-product-decision-2026-10-06.md) R-JSONL / R-V6 / R-COV / R-AUDIT / R-SKIP；M2R2 双 Partial 原件保留。 |

## 2026-10-06 有界完成合同 Addendum（Human 已批准）

[Product 决定](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-bounded-completion-product-decision-2026-10-06.md)限定本次 Completed 为诊断 producer 与父交接交付；[完成交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-bounded-completion-2026-10-06.md)及 [Exit 对照](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-jsonl-parent-exit-map-2026-10-06.md)归档。下方原全局 Exit 保留为历史完整 rollout 目标，未全满足部分按该决定接受为非阻塞未验证，不倒改原测试/独立 Partial。父诊断与宿主修复各自已有 Completed 保持，E1 不并入本合同，不新增其他任务权限。

## Product Residual Dispositions (KOS 2.1 M-03)

| ID | Owner | Disposition | Evidence and boundary |
|---|---|---|---|
| `V5-Q-001` | Executor / Environment Executor; Product Lead decides added scope | `accept` — as a non-blocking bounded count residual for this v5 validation, Product accepts 428 as the actual executed count. The historical MCP 429 discovery message remains unexplained; no further count-only rerun is authorized. | [Quality R1 review](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r1-review.md); rerun summary/log/result bundle under `/private/tmp/ukey-wake-v5-20260930.nBWReN/q001-rerun-01/`. The rerun MCP response body was not retained, so its discovery count is unknown. |
| `V5-Q-002` | Executor / Environment Executor; Product Lead decides future test scope | `accept` — as a non-blocking, unverified environment residual for this v5 validation only; 20 conditional RimeBridge tests remain skipped and are not passed. Revalidate only under a future exact-scope authorized candidate when fixtures are available. | [Quality R1 review](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r1-review.md), [Quality R2 review](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r2-review.md), and [v5 validation record](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-validation-2026-09-30.md). |
| `V5-Q-003` | Executor / Environment Executor; Product Lead decides future test scope | `accept` — as a non-blocking, unverified environment residual for this v5 validation only; 10 conditional App + Keyboard tests remain skipped and are not passed. Revalidate only under a future exact-scope authorized candidate when fixtures are available. | [Quality R1 review](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r1-review.md), [Quality R2 review](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r2-review.md), and [v5 validation record](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-validation-2026-09-30.md). |

All v5 Product residuals are now dispositioned under M-03. Accepting Q002/003 records unverified skips only; it does not change the Quality verdict, count skipped tests as passed, create a Gate, or close this Assignment or its parent. The integrated v6 paired-build, exact-candidate reviews, and authorized Maps reproduction remain future Exit evidence.
---

## Stage B scoped dispositions and read-only review continuation — 2026-09-30

[Supplement authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v6-reader-stage-b-supplement-authorization-2026-09-30.md) / [supplement Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-supplement-entry-2026-09-30.md) record Human approval of the exact two minimal supplements and use of the same independent GPT6 Luna reviewers on their existing lanes. Architecture round3 receives20tools/15min forAS2-AS6; Quality round2 receives10tools/8min forQ3 structured verification and three factual text corrections. EarlierPartial/usage remain immutable; source/test/build/simulator actions are excluded.

| ID | Owner / authority | Disposition | Boundary |
|---|---|---|---|
| B-SKIP-001 | Environment/Quality; Human Product Owner | accept — currentStageB-only nonblocking, unverified residual | 20RimeBridge skip entries remain skipped/notpassed; noStageC/Release carryover |
| B-SKIP-002 | Environment/Quality; Human Product Owner | accept — currentStageB-only nonblocking, unverified residual | 10App+Keyboard full-suite skip entries retained; signedKeychain1/1 evidence is separate; noStageC/Release carryover |

All30skip identities/reasons remain in frozen StageB test-evidence and validation-summary. This Human disposition does not rewrite v5-only acceptance, grant a Gate, close independent review findings or close Assignment/parent.

## C1 stage-specific implementation — 2026-09-30

[Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c1-core-writer-authorization-2026-09-30.md) and [Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c1-core-writer-entry-2026-09-30.md) govern the five-file Core writer/API local slice. This Human-approved C1 split places currentCore scopeACK, exactinputs/provenance and root singlewriter confirmation before local implementation; futureC2 producer/paired identity/reviews/Simulator/Maps remain dependencies and do not become currentCore validation requirements. No permanentrole reassignment or globalEntry/Exit waiver.

## Authority

- **Assignment Authority:** Product Lead; the Human Product Owner authorized establishment of this Assignment and accepted the v6 product contract. A fresh stage-specific authorization covers only the v5 compatibility-candidate validation; a subsequent exact five-file Stage A authorization applies only to v6 reader/test implementation, not writer/producer or promotion.
- **Decision Source / Date:** Assignment establishment: 2026-09-29 Asia/Shanghai, recorded in the [establishment authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-authorization.md). The v6 product contract is recorded in the [wire-version Product Decision](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-product-decision.md) and [ADR 0036 Addendum 002](../architecture/decisions/0036-keyboard-wake-wire-v6-addendum.md). The [pre-revision implementation authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-implementation-authorization.md) was scoped to a writer-v3 compatibility-gate candidate and held at Entry; it remains historical. The Human Product Owner authorized the separate v5 validation stage on 2026-09-30; see [v5-stage authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v5-stage-authorization-2026-09-30.md). This v5 authorization does not authorize v6; the Stage A authorization linked below separately authorizes reader/test work only. |
- **Product Approver:** Human Product Owner in the current Codex task.
- **KOS 2.2 optional contracts:** Not opted in; the project pin remains advisory.

## Objective

Add narrowly scoped, content-free diagnostic markers at Keyboard Extension-owned lifecycle, RIME-resume and existing `UITextDocumentProxy` call boundaries. Preserve the reviewed schema-v5 compatibility candidate with marker production off; only a separately authorized, reviewed v6 promotion candidate may enable production marker emission. Produce an operation/lifecycle timeline usable for the parent App Switcher keyboard-wake diagnosis. Do not infer a root cause or change typing behavior.

## Assignment Responsibilities

| Responsibility | Assignment |
|---|---|
| Domain Owner | **Keyboard Experience Maintainer** — owns Extension lifecycle wiring, UIKit boundaries and proxy adapter. |
| Executor | **Current Codex task** — C7-A local probe implementation and host Core verification delivered under stage-specific authority; root sole repository writer, permanent Domain Owner unchanged. C7-B/C7-C, runtime promotion and publication require separate authority. C4 delivery remains historical. |
| Environment Executor | **Current Codex task** — C7-A isolated host verification only. Historical iPhone18Pro/iOS27 UDID405D994F-28CB-4F89-BB22-B64AD81C05A2 windows are completed; any C7 Simulator work needs separate scope and a fresh exclusive reservation. |
| Human Dependency | **Human Product Owner** — after a separately authorized paired build is installed and diagnostics are armed, perform one Maps App Switcher/app-switch reproduction and report failure/recovery observations. |
| Architecture Reviewer | **Architecture & Knowledge Steward** — independent exact-candidate review. |
| Quality Reviewer | **Quality, Performance & Release Maintainer** — independent exact-candidate and validation review. |
| Product Approver | **Human Product Owner** in the current Codex task. |

These are responsibility assignments, not blanket authorizations. Required role acknowledgments must bind the exact current Assignment identity; the Assignment remains Not Ready until every required acknowledgment and Entry Criterion is complete.

The 2026-09-29 records remain historical and bind the prior Assignment SHA `fa269513e709f4aaeabf85ec434f7240a5ab80e6bb960c54332532f8681eca71`. The 2026-09-30 R2 records bind `f7e8304df7a9d8e56a6fa1387b9815410cccc21f52a0c87929f05b66be0ba6cb` and the earlier writer-v3/v4 sequence; they do not satisfy the revised v5/v6 scope. Current v6-scope ACKs bind pre-status Assignment SHA `3d91b7d599ab34a995a2bb8cc0ccf4a1d4874f0fdf64e6b4c80717cd5a1c7a6d`: [Domain Owner R3](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-domain-owner-ack-2026-09-30-r3.md), [Executor / Environment R3](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-executor-environment-ack-2026-09-30-r3.md), [Human Dependency R3](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-human-dependency-ack-2026-09-30-r3.md), [Architecture R3](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-architecture-r3-rebind-review.md), and [Quality R3](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-quality-r3-rebind-review.md). The lifecycle writeback below changes no reviewed scope. No ACK is a Simulator reservation or implementation authorization.

## Scope and effects

The earlier v5-stage authorization covers only validation of the existing schema-v5 compatibility candidate identified by manifest r2 after this Assignment is Ready and Active. For this stage, the seven paths in the Entry receipt are the source/test identity and edit boundary; Extension source and future v6 work are not authorized. The separately identified v6 promotion candidate still requires its own implementation authorization, Entry and review.

- Emit `keyboard.lifecycle.phase_changed` only for lifecycle callbacks the Extension actually observes and the finite phases accepted by Proposal 0.4. The current source has no confirmed `host_did_become_active` observer; omit that phase and do not infer it from absence. Adding a new host-activation observer needs exact-scope review before implementation.
- Emit `rime.resume.phase_changed` only for states observable at the Extension call boundary. Do not infer session creation, schema selection, owner readiness, success or failure from event absence or unrelated logs. A required internal state that needs KeyboardCore or RimeBridge instrumentation is out of scope and requires a new owner decision.
- Emit `text_proxy.operation_phase_changed` immediately before and after existing `insertText`, `setMarkedText` and `unmarkText` calls. `returned` means only that the call returned; it does not prove host insertion or display.
- Use the reviewed typed payload API, existing process/local sequence and `appearanceID` when available. Include `actionSequence` only when existing causal attribution is reliable. Apply one static writer version to every newly persisted event in each candidate build. Do not add identifiers, text hashes, content lengths or new state semantics.
- Preserve `.debug` level, existing logging/category/high-fidelity capture gates, and the bounded asynchronous ingress. Emit only closed enums and optional finite `UInt64` values; capture no raw text, candidate, host/document context, schema name, path, URL or free-form error.
- Enable v6 production call sites only after the same-build gate proves that the installed Main App and Keyboard Extension are built from the exact reviewed paired candidate, the v6 reader validates retained v3/v4/v5/v6 records against each record's own version, accepts v6-labeled typo_recall and wake-marker payloads, and rejects unsupported/malformed data as incomplete while suppressing legacy fallback.

Candidate source areas include `Keyboard/Controllers/KeyboardViewController.swift`, `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`, `Keyboard/Services/UITextDocumentProxyAdapter.swift`, the KeyboardCore diagnostic event/wire-validator/journal implementation and focused tests, and the Main App diagnostics reader/source-selection code and tests. This is a planning map, not an edit allowlist: the exact source/test manifest, ownership, and provenance must be frozen by a fresh stage-specific authorization before edits. None of these current dirty source or test files is modified by this Assignment update.

The diagnostic records add fixed metadata to the existing journal only while existing capture gates permit it. The intended user-visible keyboard behavior remains unchanged. Core wire-version support and Main App reader changes needed to implement the accepted compatibility contracts are in scope only under the stage-specific authorization above. A need to change another subsystem, capture gate, payload contract, or accepted fallback semantics stops this Assignment and requires a separate decision.

## Paired rollout fence: compatibility first, emission second

Use two separately identified candidates so the compatibility proof cannot itself emit wake markers from the installed Extension:

1. **Schema-v5 compatibility-gate candidate:** preserve the reviewed current writer-v5 behavior, including typo_recall, with production wake-marker emission off. The reader supports retained v3/v4/v5 records. Any v4 wake-marker records used for reader validation remain isolated temporary or in-memory fixtures; the fixture path must not use production App Group storage, DiagnosticsJournalRuntime, or real Extension ingress. The reviewed seven-file manifest-r2 candidate is evidence for its frozen v5 scope only; revalidate and integrate it with the paired Extension source before a future v6 promotion. This phase emits no production wake markers.
2. **Schema-v6 emission-promotion candidate:** only after a new exact-scope v6 implementation authorization, completed Entry, and successful v5 compatibility gate may the Product Lead authorize a separate v6 promotion candidate. The v6 writer labels every newly persisted event as v6, including existing event families and the wake markers; the reader supports v3/v4/v5/v6 with version-specific code/payload/key allowlists. The candidate must bind its source/test manifest, Main App and Extension binaries, and validation scope. Re-run required validation and obtain exact-candidate Architecture/Quality review before installation or the Human Product Owner's Maps reproduction.

There is no remote, persisted, App Group or in-app feature flag in this rollout. The production writer version is the explicit build-time opt-in. The pre-revision implementation authorization was scoped to writer v3 and held at Entry; it, a prior candidate review, or a passing unit test does not authorize this revised scope, v5 integration, or v6 implementation/emission. Obtain a fresh authorization for each candidate stage, plus a separate v6 promotion authorization. If a candidate identity changes, rebind its evidence and reviews before proceeding.

## Non-goals

- No changes to KeyboardCore input/session state, RimeBridge, RIME deployment, keyboard behavior, privacy policy, capture gates, retention, journal layout/ownership, or the accepted incomplete/fallback contract. Wire-version, event/payload allowlist, and Main App reader/source-selection changes required by the accepted v5 compatibility and v6 contracts are in scope only under a fresh, exact stage-specific implementation authorization and frozen manifest.
- No behavioral recovery, candidate-render assertion, host-insertion assertion, user-content collection, synchronous persistence, or root-cause claim.
- No standalone diagnostic-app deployment, App Group mutation, manual runtime reproduction, or installed production v6 emission before the paired-build gate and separate v6 implementation/promotion authorizations. Isolated test-only v4 fixtures are allowed only under the v5 compatibility-gate candidate conditions above.
- No use or modification of another task’s dirty worktree. Preserve all existing changes; any future source edit, build or Simulator operation must satisfy this Assignment's authorization and Entry gates in an isolated writer-owned worktree.
- No commit, push, PR, merge, TestFlight, Release, Product Gate, Quality Gate, or parent closure.

## Required Inputs

- Human-accepted [Proposal 0.4](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md), reviewed design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`.
- [ADR 0036](../architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md), conditionally accepted by the [ADR acceptance decision](../product-decisions/ADR-0036-ACCEPT-authorization.md), read together with the v6 [Product Decision](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-product-decision.md) and [Addendum 002](../architecture/decisions/0036-keyboard-wake-wire-v6-addendum.md), now Accepted; implementation pending.
- [Runtime Record API Assignment](keyboard-wake-diagnostic-runtime-record-api-001.md) reviewed candidate, canonical ten-file source/test manifest SHA-256 `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c`; this is a prerequisite identity, not proof it is integrated into the eventual paired app build.
- [KeyboardCore reader Assignment](keyboard-wake-diagnostic-reader-implementation-001.md) candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7` and [Main App consumer Assignment](keyboard-wake-diagnostic-main-app-consumer-001.md) candidate `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a`. Existing reviews do not prove that either candidate is present in the same installed build as an Extension producer.
- Parent [KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001](keyboard-wake-lifecycle-diagnostics-001.md), still Active with unresolved root cause; predecessor [Extension producer Assignment](keyboard-wake-diagnostic-extension-producer-001.md), Reassigned to this successor.
- Predecessor-recorded Extension patch base `9eb83158e49218c1e8f75dbe7dd9e0390db81409`, five-file patch SHA-256 `c4998815078e790e1a14109ecefde8a3fb467f197c90eece5dbda20b4a7f7a8d`, and `UITextDocumentProxyAdapter.swift` SHA-256 `f5cad10abb6b01594819cbb5dcf72a2989d389ed235364237abdfce7853b6de5`. These are historical identities only; revalidate actual source content and writer ownership before Ready. Do not assume the patch is present in this worktree or overwrite/recreate it from an unverified copy.
- The previously selected iPhone 18 Pro / iOS 27.0 Simulator UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2` is a historical target only. Its current availability and exclusive reservation are unknown; revalidate the exact target and fresh window before any Simulator-backed operation. Do not substitute a different device without a Product decision.

## Stage A reader-first sequencing revision — 2026-09-30

Human Product Owner explicitly authorized the approved five-file packet and its staged Entry revision; see [Stage A authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v6-reader-stage-a-authorization-2026-09-30.md) and [Stage A Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-a-entry-2026-09-30.md). For Stage A only, this section supersedes the global Entry ordering below: current Core/App scope ACK and Executor exact-input/writer confirmation precede edits; fresh Simulator reservation and independent exact-candidate reviews belong to Stage B; archived Runtime API / parent Extension patch byte recovery and Extension observability belong to Stage C. Existing responsibility assignments remain; old-SHA ACKs remain historical. The current Executor may implement reader/test changes and use isolated host validation; App tests are authored/not-run. Production writer stays v5, markers off. Global Exit, Stage B/C, installation, Maps, publication and Gates remain outstanding.

## Stage B verification Entry — 2026-09-30

[Stage B authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v6-reader-stage-b-authorization-2026-09-30.md) and [Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-entry-2026-09-30.md) bind the exact Stage A reader candidate, current Human-confirmed exclusive target, root Environment Executor and separately frozen independent reviewer lanes. Stage B authorizes Simulator tests (including automated test-runner installation/launch), signed Keychain focused validation and Release-configuration build only; production writer remains v5 and markers off. Global rollout Exit and Stage C remain outstanding.

## Entry Criteria

For the full writer/producer rollout, the Assignment is **Not Ready** until all of these conditions are met; the explicit Stage A sequencing revision above governs reader-only execution:

1. The Domain Owner, Executor, Environment Executor, Human Dependency, Architecture Reviewer and Quality Reviewer acknowledge the exact revised Assignment content, dependencies and action boundaries. The Environment Executor re-confirms future Simulator work conditions; the Human Dependency confirms whether the later Maps action applies to a v6 promotion candidate. Prior-scope acknowledgments do not satisfy this criterion. No acknowledgment reserves a Simulator or authorizes implementation.
2. Before the Ready transition, a fresh Product Lead implementation authorization names the exact first-stage v5 compatibility candidate source, build and test scope. Source implementation may begin only after the Assignment reaches Active. Any later v6 source work requires a separate v6 implementation authorization and promotion authorization bound to its exact candidate.
3. Before source edits, revalidate the exact Runtime API, reader, Main App consumer, ADR 0036 plus its v6 addendum, the v6 Product Decision, Proposal 0.4, predecessor Extension patch, KeyboardCore wire implementation/tests, Main App reader/source/tests and UITextDocumentProxyAdapter.swift against their recorded identities and auditable source. Record any mismatch or missing provenance; sibling candidate hashes do not prove integration.
4. Re-read the selected worktree, branch and all in-scope source/test diffs. Preserve other AI work, freeze and account for the exact parent Extension patch, confirm no active writer, and establish an isolated writer-owned worktree and exclusive writer window before source edits. Resolve any missing or changed historical patch through an auditable source rather than reconstruction by guesswork.
5. Revalidate the exact Simulator destination and record a fresh exclusive-use reservation before Ready and before any Simulator-backed validation or installation. Reconfirm the Human Product Owner's later Maps reproduction dependency against the exact v6 promotion candidate before installation. Do not infer availability or ownership from a Shutdown state or profile listing.
6. Before edits, inspect the existing Extension call boundaries and confirm the planned markers are observable there without adding a new observer or inferring unavailable state. Confirm the planned fields remain within Proposal 0.4, and the existing capture gates and bounded asynchronous ingress are implementation constraints. If any part requires out-of-scope state or policy, stop for a Product decision.

## Exit Criteria

- In the v6 emission-promotion candidate, the authorized Extension events are emitted at the specified observed boundaries with correct closed codes, payloads, categories, `.debug` level, and existing IDs; all new records from that writer build use v6. In the v5 compatibility-gate candidate, tests prove that the current v5 behavior is preserved and production wake-marker emission remains off.
- Tests cover event/payload mapping, lifecycle and proxy boundaries, failure-pairing rules available at this layer, capture-gate behavior, and that proxy calls return without waiting for journal persistence. Tests use temporary storage and do not read or mutate the real App Group.
- The v5 compatibility-gate candidate binds the Main App and Keyboard Extension to one reviewed source/build identity, preserves the production writer at v5, and proves through isolated tests that its same-candidate reader handles v3/v4/v5 history and suppresses legacy fallback on incomplete/unsupported status. It produces no installed production wake-marker events; retained history is not rewritten.
- Only after the v5 compatibility gate passes and a fresh exact-scope Product Lead v6 implementation/promotion authorization is recorded, a new promotion candidate explicitly configures the production Extension writer as v6. Its reader validates v3/v4/v5/v6; every event newly written by the candidate is v6. Its paired Main App/Extension identities, complete validation results and exact-candidate Architecture/Quality reviews are recorded before installation or human reproduction.
- Freeze one integrated source/test candidate and record its manifest, source commit, Xcode/Swift/SDK, scheme/configuration, and Main App + Keyboard Extension bundle/version/build identities and executable SHA-256 values. Preserve the build/install provenance and each `.xcresult`; sibling Assignment hashes are prerequisites, not same-build proof.
- Run the full repository CI-equivalent matrix on the freshly reserved exact Simulator destination. Inspect the pinned RIME vendor first; fetch it if it is absent, and verify its exact pinned manifest/digest whether it was already present or just fetched. For every changed Swift file, run `xcrun swift-format format --in-place --configuration .swift-format <file>` and then `xcrun swift-format lint --strict --configuration .swift-format <file>`. Also run:

  ```bash
  swift test --package-path Packages/KeyboardCore
  xcodebuild -project "Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination 'platform=iOS Simulator,id=<REVALIDATED_UDID>' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test -resultBundlePath <RESULTS_DIR>/RimeBridgeTests.xcresult
  xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,id=<REVALIDATED_UDID>' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test -resultBundlePath <RESULTS_DIR>/UniverseKeyboardTests.xcresult
  xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Release -destination 'platform=iOS Simulator,id=<REVALIDATED_UDID>' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build -resultBundlePath <RESULTS_DIR>/UniverseKeyboardRelease.xcresult
  ```

  Record exact command output, toolchain, destination identity, result-bundle paths and any skipped step with its reason. Also run `git diff --check`. A build pass alone proves no runtime, Full Access, RIME-input or Release outcome.
- The v6 integrated paired-build test matrix covers retained v3/v4/v5 history, v6 existing event families and markers, v6 typo_recall, mixed v3/v4/v5/v6 history, unsupported/non-integer/future versions, unknown code and raw key, malformed payload and code/payload mismatch. It directly proves incomplete/unsupported status propagates through the Main App query path and suppresses legacy fallback, including v6-only and mixed v5/v6 histories when legacy text is present. Keep duplicate-JSON-member handling as an explicit residual unless the exact implementation adds and tests detection.
- Provide targeted test or static-call-path evidence that typed event submission uses bounded asynchronous ingress and proxy calls do not wait for journal persistence. Do not claim a Release performance budget or device-performance pass from this diagnostic evidence.
- The Human Product Owner performs the bounded Maps App Switcher/app-switch reproduction only on the reviewed and separately authorized, installed v6 promotion build, after confirming the Human Dependency for that exact candidate. Record build identity, capture time, diagnostic/high-fidelity switches, Full Access state, host app, and whether key feedback, candidates, host text and recovery respond. Record non-reproduction as not reproduced / inconclusive. The report contains no input text or candidate content.
- Architecture and Quality independently review the exact final candidate and its evidence. Product review, Gate decisions, parent closure and publication remain separate lifecycle decisions.
- Handoff the content-free event timeline and evidence limitations to the parent Assignment. This Assignment does not require or claim a root-cause finding or behavior fix.

## Stop Conditions

- Any required event cannot be observed at an Extension-owned boundary without guessing, or needs new KeyboardCore/RimeBridge state, IDs, semantics, schema, or capture policy.
- The exact writer/reader compatibility, strict validation, incomplete status, fallback suppression, or same-build binary provenance cannot be demonstrated.
- Any in-scope source identity changes before Entry, the historical Extension patch cannot be accounted for, another writer is active, or worktree ownership is unclear.
- The exact Simulator is unavailable, another task is using it, or a fresh exclusive-use window cannot be obtained.
- The implementation would persist user content, block the key/proxy path, change input behavior, or require work outside this Assignment.
- Any action falls outside the applicable stage-specific authorization or is attempted before its Entry Criteria are satisfied.

## Handoff and Revalidation

- **Handoff Target:** Parent [KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001](keyboard-wake-lifecycle-diagnostics-001.md), with exact paired-build identity, test/review evidence, content-free event timeline and limitations.
- **Revalidation Triggers:** Changes to Proposal 0.4, ADR 0036, the Runtime API/reader/Main App candidates, Extension source or tests, the parent diagnostic patch, capture gates, paired-build configuration, Simulator identity/availability, writer ownership, or any new reviewer/owner.

## History

- 2026-09-29 Asia/Shanghai — Human Product Owner authorized creating this separate Assignment and recording responsibilities (“授权”). Lifecycle is **Assigned / Not Ready**. This authorizes Assignment establishment only; no code, test, build, Simulator operation, installation, event emission, manual reproduction, publication, or implementation authorization is claimed. Documentation link-check evidence is recorded in the [validation receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-assignment-markdown-links-2026-09-29.log).
- 2026-09-29 Asia/Shanghai — Quality exact-candidate follow-up on Assignment SHA-256 `8f1916a0bdf61bea3bab2b5687925f58ff19333de6c6f83a9d19bbf4c69df31d` returned **Pass with conditions** and required an explicit v4 producer-off and promotion sequence. This revision records a v3 compatibility-gate candidate, a separately authorized v4 promotion candidate, and their identity/review boundaries. Prior role reviews do not bind this revised candidate; exact-scope re-acknowledgment is required. No implementation or runtime action is authorized by this documentation update.
- 2026-09-29 Asia/Shanghai — Domain Owner, Executor, Environment Executor, Human Dependency, Architecture Reviewer and Quality Reviewer completed exact-scope acknowledgment for the current Assignment revision. The lifecycle advanced **Assigned → Acknowledged**; the Assignment remains **Not Ready** because integrated source/build identity, ownership revalidation, a fresh exclusive Simulator window and separate implementation authorization are outstanding. No implementation or runtime action is authorized by this lifecycle update.
- 2026-09-30 Asia/Shanghai — Human Product Owner accepted the minimum Entry/Exit sequencing clarification (“可以按照你的建议继续下一步，之后也继续汇报进度”). Entry now contains pre-edit provenance, source ownership, observability and Simulator-reservation checks; integrated source/test manifest, paired binary identity and behavior proof remain Exit evidence. This is documentation-only revalidation, not implementation, test, build or Simulator authorization. Prior exact-SHA role ACKs remain historical; the revised Assignment returns to **Assigned / Not Ready** pending exact-candidate rebind.
- 2026-09-30 Asia/Shanghai — Domain Owner, Executor, Environment Executor, Human Dependency, Architecture Reviewer and Quality Reviewer completed exact-scope acknowledgments/reviews for pre-status Assignment SHA-256 f7e8304df7a9d8e56a6fa1387b9815410cccc21f52a0c87929f05b66be0ba6cb. The Human Product Owner confirmed a future bounded Maps reproduction dependency; it is conditional on a separately authorized, reviewed and installed paired promotion build, and does not reserve a Simulator or authorize installation/reproduction now. Architecture returned **Pass with conditions** and Quality returned **PASS**. Lifecycle advanced **Assigned → Acknowledged** and remains **Not Ready** pending implementation authorization and Entry revalidation. This history binds only the earlier Assignment revision; it does not satisfy the v6 scope rebind. No source, test, build, Simulator or runtime action was taken.
- 2026-09-30 Asia/Shanghai — The Human Product Owner authorized a separate exact-scope implementation authorization and pre-edit Entry review. The authorization is recorded, and Entry verified the seven-file compatibility manifest, historical Extension patch identity and observable UIKit boundaries. Entry also found that the `.v3` compatibility / `.v4` promotion sequence has not been reconciled with current schema-v5 Extension diagnostics. The separately reviewed Runtime API does provide a writer selector, but its older-base candidate is archived and absent from manifest r2; current Extension `typo_recall` events are v5-only, and same-candidate preservation under ADR 0036's static-version rule remains unproven. See the [Entry receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-pre-edit-entry-2026-09-30.md) and [M-06 decision brief](../plans/keyboard-wake-diagnostic-extension-writer-version-reconciliation-001.md). Lifecycle remains **Acknowledged / Not Ready**. This lifecycle-only update does not change the reviewed scope or role ACK identities. No source edit, test, build, Simulator operation, installation, event emission, manual reproduction, commit, publication, Gate, or root-cause conclusion occurred.
- 2026-09-30 Asia/Shanghai — The Human Product Owner accepted the recommended v6 product contract. This Assignment was revised to separate the writer-v5 producer-off compatibility candidate from the future writer-v6 promotion candidate, make the necessary KeyboardCore/Main App version-reader work explicit, and correct the provenance of the pre-revision writer-v3 authorization (which was held at Entry). The current lifecycle is **Assigned / Not Ready**; all prior role ACKs and reviews remain bound to their recorded earlier SHA. Exact-document Architecture and Quality review, current role rebind, source ownership, fresh stage-specific authorization, and exclusive Simulator reservation remain outstanding. No source/test, build, Simulator, installation, marker emission, or manual reproduction occurred.
- 2026-09-30 Asia/Shanghai — ADR 0036 Addendum 002 became **Accepted; implementation pending** after Architecture R7 and Quality R5 reviewed the exact pre-status v6 candidate with Pass with conditions. This status/history writeback does not bind old role ACKs to this Assignment revision or satisfy its future Ready criteria. The Assignment remains **Assigned / Not Ready**; no source/test, build, Simulator, installation, marker emission, or manual reproduction occurred.
- 2026-09-30 Asia/Shanghai — The Human Product Owner confirmed the current v6-scoped future Maps dependency in response to the exact Assignment confirmation request. Domain Owner, Executor, Environment Executor, Human Dependency, Architecture Reviewer and Quality Reviewer acknowledged pre-status Assignment SHA-256 `3d91b7d599ab34a995a2bb8cc0ccf4a1d4874f0fdf64e6b4c80717cd5a1c7a6d`; Architecture/Quality R3 are role rebinds and retain their R7/R5 conditions. Lifecycle advanced **Assigned → Acknowledged** and remains **Not Ready** pending fresh writer-v5-stage authorization, source/provenance/ownership checks and a fresh exclusive Simulator reservation. This status-only writeback does not authorize source edits, tests, builds, Simulator operations, installation, production marker emission, manual reproduction, publication, Gate, Release or parent closure.
- 2026-09-30 Asia/Shanghai — The Human Product Owner authorized the v5 compatibility-candidate validation stage and confirmed exclusive use of iPhone 18 Pro / iOS 27.0 (405D994F-28CB-4F89-BB22-B64AD81C05A2). The stage-specific [authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v5-stage-authorization-2026-09-30.md) and [Entry receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-entry-2026-09-30.md) bind the seven-file manifest r2 and current worktree. Entry passed; lifecycle advanced Acknowledged → Ready. No validation has run yet, and no v6 work, manual installation/launch, Maps reproduction, production marker emission or publication action is authorized.
- 2026-09-30 Asia/Shanghai — With the v5-stage authorization and Entry complete, the Assignment advanced Ready → Active immediately before validation. The Executor is running the required matrix against the unchanged manifest-r2 candidate and the exclusively reserved iPhone 18 Pro / iOS 27.0 Simulator. No validation result is claimed yet; v6, manual install/launch, Maps reproduction and publication remain outside scope.
- 2026-09-30 Asia/Shanghai — The authorized v5 validation matrix completed against unchanged manifest r2. KeyboardCore passed 1,177 tests; RimeBridgeTests passed 85 with 20 conditional skips; App + Keyboard passed 418 with 10 conditional skips; the signed Keychain test passed; Release build succeeded with zero warnings/errors; vendor verification, strict Swift formatting/lint and `git diff --check` passed. The `Universe Keyboard` MCP discovery message reported 429 tests while `.xcresult` and raw suite totals report 428; no explanation is established. Exact evidence and skips are recorded in the [validation record](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-validation-2026-09-30.md). Lifecycle remains **Active**, awaiting independent Architecture/Quality evidence review. No v6, installation, UI interaction, Maps reproduction, Gate, Release or root-cause conclusion is claimed.
- 2026-09-30 Asia/Shanghai — Independent v5 validation evidence reviews completed under their frozen R1 packets. Architecture returned **Partial / incomplete** at its eight-interaction budget: candidate/document identities matched, but full source/test and raw-log coverage remains open (`ARV5-R1-COV-02`). Quality returned **Pass with conditions** with complete coverage; `V5-Q-001` records the unexplained 429/428 count difference, while `V5-Q-002/003` preserve 20 RimeBridge and 10 App + Keyboard conditional skips. Review receipts and usage records: [Architecture R1](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r1-review.md) · [Architecture usage](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r1-usage-2026-09-30.md) · [Quality R1](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r1-review.md) · [Quality usage](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r1-usage-2026-09-30.md). The Assignment remains **Active**; no Product disposition, Gate, v6 work, install, Maps reproduction, Release or root-cause conclusion is claimed.
- 2026-09-30 Asia/Shanghai — The Human Product Owner authorized dispatch of the exact Architecture R3 packet SHA-256 `1c6d109151087f50b63fe82015cb640f05f235f3717885210ddd7f205c2db876` (maximum 24 interactions, read-only). The `gpt-6-luna` reviewer returned **Partial / incomplete** after 20 interactions: all seven candidate source/test diffs and four `.xcresult` inventories were reviewed; raw skip reasons were not reconciled line by line, and the frozen R2 usage identity was not independently checked because its path was absent from the allowlist. The coordinator later confirmed that the R2 usage file exists and its SHA matches the frozen value; this does not amend reviewer coverage. `ARV5-R1-COV-02` remains open. Quality-owned `ARV5-R1-EVID-04` and Product-owned `V5-Q-001..003` remain undisposed. See [Architecture R3 review](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r3-review.md) and [usage](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r3-usage-2026-09-30.md). Lifecycle remains **Active**; no v6 implementation/promotion, install, Maps reproduction, Gate, Release, root-cause conclusion or parent closure is claimed.
- 2026-09-30 Asia/Shanghai — Following R3's Partial disposition, the coordinator prepared a separate, bounded Architecture R4 draft covering only the R2 usage-file identity allowlist gap and raw skip-reason reconciliation. The packet is **not dispatched or authorized**; Product Lead approval of its exact SHA-256 is required. No R4 reviewer work has started. This preparation does not renew R3's unused interactions or change the current review verdicts.
- 2026-09-30 Asia/Shanghai — The Human Product Owner authorized dispatch of the frozen Architecture R4 packet SHA-256 `5330210ac46941fe510cbe0b123a7bb79203b05953d7f29d2015c0448d78cbcb` (maximum 12 reviewer interactions, read-only). The `gpt-6-luna` reviewer verified the R2 usage-file digest and reconciled all 20 RimeBridge and 10 App + Keyboard skips; the combined R1–R4 Architecture coverage supports closing `ARV5-R1-COV-02`, recorded as `fix` with the [R4 review](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r4-review.md) and [usage record](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r4-usage-2026-09-30.md). The R2 usage digest is `f21c68e000f8c1265db1e39ce80598161f053d4dca3d51908814d28c6a2d45c6`. The MCP 429 / raw and `.xcresult` 428 discrepancy remains unexplained; Quality-owned `ARV5-R1-EVID-04` and Product-owned `V5-Q-001..003` remain open. The paired-rollout Assignment remains Active; the parent remains Active with root cause unresolved. No v6 implementation/promotion, marker emission, Maps reproduction, behavior fix, Gate, Release, parent closure, or publication is claimed.
- 2026-09-30 Asia/Shanghai — The Human Product Owner authorized Quality to handle its owned residual `ARV5-R1-EVID-04`. The Coordinator reused the existing Quality R1 reviewer (`gpt-6-luna`) for the frozen [Quality R2 packet](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r2-packet.md), SHA-256 `e6274703fd2f4b89df34a87e3d697649a49a1ba7cd807fd2ad42bf1ee260828c`, bound to pre-review Assignment SHA `a26957ba3edf96c8f468de6b19f71deefe13b1cf19bb2f360768f39d4deeee74`. Quality R2 independently verified all 20 RimeBridge and 10 App + Keyboard skip identities/reasons and returned **Complete**; `ARV5-R1-EVID-04` is recorded as `fix` with the [Quality R2 review](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r2-review.md) and [usage record](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-quality-r2-usage-2026-09-30.md). Quality R1 remains Pass with conditions; Product-owned `V5-Q-001..003` remain open, including the unexplained MCP 429 / raw and `.xcresult` 428 difference. The paired-rollout Assignment and parent remain Active; root cause remains unresolved. No v6 implementation/promotion, marker emission, Maps reproduction, behavior fix, Gate, Release, parent closure, or publication is claimed.
- 2026-09-30 Asia/Shanghai — Human Product Owner accepted `V5-Q-001` as `accept` under KOS 2.1 M-03: the actual result of the one authorized rerun is 428 cases (418 passed, 10 skipped, 0 failed) on iPhone 18 Pro / iOS 27.0 at the frozen source baseline. The historical MCP discovery message reported 429 and remains unexplained. The rerun MCP response body was not retained after the wrapper failed to serialize it (`TextEncoder` unavailable), so this rerun does not establish the current MCP discovery count. The Product decision is to treat 428 as the actual execution count and perform no further count-only rerun. Evidence: `/private/tmp/ukey-wake-v5-20260930.nBWReN/q001-rerun-01/UniverseKeyboardTests-rerun-01.summary.json` (SHA-256 `c1774afe97112f617de93b03823f3c09799cc455117ab22a0a148bd986181a57`), `.log` (SHA-256 `f7192704ab3ea4d6ee1460bd8d7c6ac90d7256b1adb7f8a19ae4441bd3def9e0`) and `.xcresult`. `V5-Q-002/003` are accepted only as unverified skips for v5; the Assignment and parent remain Active, with no Gate, v6 work, Release or root-cause conclusion claimed.

- 2026-09-30 Asia/Shanghai — Human Product Owner accepted `V5-Q-002` and `V5-Q-003` under KOS 2.1 M-03 only as non-blocking, unverified environment residuals for the v5 validation: 20 conditional RimeBridge tests and 10 conditional App + Keyboard tests remain skipped, not passed. Quality R2 independently verified skip identities and reasons; the disposition does not change the Quality verdict or authorize a rerun. Any future fixture-backed revalidation belongs to a separately authorized exact-scope candidate. All v5 Product residuals are dispositioned, but the paired-rollout Assignment and parent remain Active; integrated v6 paired-build evidence, exact-candidate reviews and authorized Maps reproduction remain future Exit evidence. No v6 source work, build, installation, reproduction, Gate or Release is authorized by this disposition.

- 2026-09-30 Asia/Shanghai — Human authorized the frozen five-file reader Stage A and corresponding phased Entry revision. Current exact-input Core/App scope ACK and Executor confirmation recorded in Stage A Entry. Source work begins only within that scope; Assignment and parent remain Active. Independent reviews, Simulator validation and full rollout Exit remain future work.

- 2026-09-30 Asia/Shanghai — Stage A five-file reader candidate delivered locally: strict format/lint and final host KeyboardCore 1181 tests passed. App query-path test authored/not-run. [Validation](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-a-validation-2026-09-30.md) binds the candidate and limitations; independent reviews, full CI, v6 writer/producer, promotion/install/Maps and global Exit remain outstanding. Assignment and parent stay Active.

- 2026-09-30 Asia/Shanghai — Human authorized Stage B verification and GPT6 Luna delegation, then confirmed fresh exclusive use of the exact iPhone18Pro/iOS27 target through this verification. Stage B scoped Entry satisfied before matrix execution; no new result or Gate claimed.

- 2026-09-30 Asia/Shanghai — Stage B final Simulator gates passed after a test-fixture-only directory repair; host1181/0 reused, Rime105total/20skip, App429total/10skip, signedKeychain1/1, Releaseconfigurationbuildexit0. Architecture remainsPartial AS2–AS6 uncovered with exhaustedbudget; Quality originalreview retained. Current30skips areunverified and do not inheritv5-onlyacceptance. Stage B independentreview/residualdisposition remain pending; noGate orclosure.

- 2026-09-30 Asia/Shanghai — Human explicitly authorized two smallest read-only review supplements and accepted currentStageB30skip entries as nonblockingunverifiedresiduals only. Same independentArchitecture/Quality GPT6Luna runtimes may continue original lanes with newly frozen rounds and approved budgets; no source/test/device/publication authority added.

- 2026-09-30 Asia/Shanghai — Completed the two authorized read-only supplements using the original independent GPT6 Luna reviewers; immutable packets, input hashes, reports and usage saved. See [Stage B supplemental validation](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-supplement-validation-2026-09-30.md). Current Stage B skip disposition remains nonblocking/unverified; Assignment and parent remain Active.

- 2026-09-30 Asia/Shanghai — Human authorized C1 five-file Core writer/API implementation and autonomous subagent use within scope. Current Core scopeACK, source byte recovery and Executorpreflight satisfy C1 Entry only; production v5/marker off retained. No C2/device/publication/Gate authority.

- 2026-09-30 Asia/Shanghai — C1 exact five-file Core writer/API candidate delivered: default v5 preserved; isolated explicit-v6 writer/type APIs validated with focused and full KeyboardCore host tests (1184/0). [Validation](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c1-core-writer-validation-2026-09-30.md) records final hashes and limits. No production opt-in, C2, Simulator, promotion/Maps, independent C1 Gate or Git publication.

## C2 scoped Entry — 2026-10-01

[Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c2-producer-authorization-2026-10-01.md) and [Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-entry-2026-10-01.md) record the Human-approved five-file C2 local producer/Debug Simulator slice. Current scope ACK, exact inputs, sole repo writer and fresh exact-device exclusive window precede edits. Production paired version binding, independent reviews/full paired CI, promotion/install/Maps are future named dependencies. No global Exit/ownership waiver.

- 2026-10-01 Asia/Shanghai — C2 exact five-file local producer/test membership delivered; unified Debug high-fidelity/expiration gate, four observed lifecycle phases/RIME-started/proxy-entered-returned only. Producer focused 2 passed; full App+Keyboard 431 total = 421 passed + 10 skipped + 0 failed, not Stage B acceptance. [Validation](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c2-producer-validation-2026-10-01.md) binds final SHA, raw evidence and limits. Root remains sole repo writer; no production opt-in/manual install/Maps/full paired CI/independent Gate/publication/parent closure. Fresh simulator window completed.

## C3 scoped local paired-version binding — 2026-10-01

Human authorized “那接下来先补齐配对版本绑定吧”. [Entry/authorization](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c3-paired-version-entry-2026-10-01.md) and [delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c3-paired-version-validation-2026-10-01.md) govern the continued local preparation stage: fresh exact source/dirty identity and current author scope ACK precede five product constructor edits. Explicit v6 selected everywhere; old public defaults remain v5. This supersedes current C2 source-v5/marker-off descriptions for this local candidate only, not historical evidence. No build/test/Simulator/install/runtime emission/Maps/Git operation occurred; compiled paired identity, full CI, independent exact integrated reviews and promotion remain future named dependencies. Parent Active, global Entry/Exit unwaived, no Gate.

## C4 integrated freeze, independent reviews and full paired verification — 2026-10-01

Human authorized “冻结整合候选，开展独立评审及完整配对验证吧。” and freshly confirmed exact-target exclusivity. [Authorization/Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-entry-2026-10-01.md), [candidate manifest](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-candidate-manifest.json) and [delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-validation-2026-10-01.md) bind digest `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9`, 568 source/build inputs and 34 review targets. Current source selects v6; public Core defaults and reader history/gates remain unchanged. No source was edited in C4.

Full matrix: 17 Swift format/strict lint passed; pinned vendor verify and 630-file snapshot passed; Core1184/0; Rime105 =85 passed+20 skipped+0 failed; App+Keyboard431 =421 passed+10 skipped+0 failed; signed Keychain1/1; Release build exit0. Paired Debug signed-test retained products/Release products both version1.0/build1, with executable/plist SHA256 and same-source command provenance. This is built pairing, not installed identity or actual callback/marker proof. Test-runner installation/launch belongs to validation; no manual install, diagnostic arming, Maps or Release delivery occurred. Window ended; no lease reuse.

[Architecture A-C4 round1](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-architecture-review.md): Full static A1–A6 coverage, no Architecture blocker. [Quality Q-C4 round1](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-quality-review.md): Blocker with Q1–Q6 fully covered; original findings/usage remain intact. Separate factual receipts reconcile an Architecture packet-digest transcription and Quality's historical Architecture-lane label; they do not rewrite verdicts. Late checkpoints and Architecture guessed absent paths remain disclosed in usage, not represented as strict protocol compliance.

| ID | Owner / authority | Current disposition | Boundary |
|---|---|---|---|
| C4-Q-01 | Environment/Quality inventory; Human Product Owner authority | `accept` — current C4 only, nonblocking/unverified; Q-C4 round2 confirms | Exact20RimeBridge+10App skip records remain Skipped/notpassed; signed Keychain counterpart separately passed. Original round1 Blocker immutable, no later-stage/Release carryover. |

Root sole repo writer; no staging/commit/push/worktree/branch mutation. Pre-existing 2455-file baseline unchanged throughout matrix/reviews; only final owning Assignment bookkeeping is excepted in the final preservation receipt. Parent Active, no global Gate/Release/root cause/closure. Duplicate-member parser limitation remains; true appex callbacks, installed pairing, default runtime emission and Human Maps remain future separately bound dependencies.

## C4 scoped residual acceptance and Quality supplement — 2026-10-01

Human replied “同意” to the concrete proposal to accept only current C4's frozen30skip records as nonblocking/unverified and authorize8tools/8minutes readonly Quality supplement. [Product disposition](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-supplement-product-disposition.md), [packet](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-supplement-packet.md) and [Q-C4 round2 review](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-supplement-quality-review-r2.md) bind unchanged candidate `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9`. D1–D3 covered;568source/build and38prior artifact hashes match;30/30records remain Skipped. C4-Q-01 current disposition confirmed; original round1 Blocker unchanged. This is not overall Quality Pass, Product/Quality/Release Gate or parent closure.

[Usage](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-supplement-quality-usage-r2.json):8/8underlying tools,205.297seconds/480seconds; checkpoint onecall late explicitly disclosed. Root final bookkeeping only changes owning Assignment and adds current supplemental evidence; all other existing files/source/results preserved. No source change, test/build rerun, Simulator/lease reuse, install, diagnostic arming, Maps, Git publication or Release. Future installed identity/actual callbacks/default runtime emission and Maps remain separately authorized/bound dependencies; parent Active.


## C5 real appex promotion/install slice preparation — 2026-10-01

Human authorized preparation only (“下一步可以准备真实 appex 回调验证的最小晋级／安装切片。”). [C5 proposal](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-real-appex-promotion-install-slice.md) separates C5-P independent readonly promotion-readiness review, C5-I one paired Debug install/installed payload verification, and C5-R one controlled Main App host callback capture. **Preparation complete; execution Not Ready.** Exact C4 source/build inputs and retained Debug bundle remain unchanged. New readonly payload evidence includes all 111 bundle file hashes and 11 Mach-O SHA/size/UUID values, including business debug dylibs; built Simulator entitlement evidence is not installed App Group/Full Access proof.

C5-P/I/R remain proposed, not authorized or executed. Required dependencies are exact-scope reviewer packets/new budgets and ACKs, Product's C5-specific readiness/residual decision, fresh exact-device exclusivity and explicit install/settings/capture authority. Current30skip records remain unverified; C4-only acceptance does not carry forward automatically. No source/test/build/Simulator/install/capture/Maps/Git/Release action occurred. Parent remains Active; no Gate, root cause or closure. [Preparation/preservation receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-preparation-final-receipt.json).


## C5-P authorized independent readonly promotion-readiness review — 2026-10-01

Human explicitly authorized “授权 C5-P 晋级前独立补审”. Root remains sole repo writer; original independent Architecture/Quality GPT6 Luna runtimes are reused with new lane packets, round1 and separate 12 underlying-tool / 10-minute budgets, checkpoint at6. Exact source/build inputs, retained Debug whole payload and dirty baseline are revalidated before dispatch. [C5-P Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-entry.md) and frozen packets bind the authorized scope. C5-P review execution may proceed after each reviewer's exact packet ACK; review results are pending.

This authorization covers C5-P only, not C5-I/C5-R, Product promotion/residual acceptance, device lease/discovery/boot/install/launch/settings/capture/input/Maps/source/test/build/Git/Release. C5-I/R remain Not Ready; no current30skip acceptance is inferred from C4. Parent remains Active, no Gate/closure.

- 2026-10-01 Asia/Shanghai — C5-P independent readonly review round1 delivered using original GPT6 Luna lanes. [Validation](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-validation-2026-10-01.md) preserves original reports/usage, input identity and separate factual/procedural reconciliations. Architecture reports P-A1/A2/A3 Covered, no design blocker;338seconds with conservative11interactions accounting/identity rendering limitations disclosed. Quality reports P-Q1/Q2/Q3 Covered, no design blocker, but12underlying calls and610.087seconds exceed600seconds; reviewer confirmed procedural **Partial** under frozen packet. **C5-P Exit not met; C5-I/R remain Not Ready, unauthorized.** Root did not expand budgets, rewrite original verdicts or automatically retry. Suggested Quality round2 is a proposal only, requiring Human's new scope/budget authorization. Current30skips remain unverified and need C5-specific Product disposition; C4 acceptance does not carry over. Source/build inputs and Debug payload unchanged; all2505 other preexisting files preserved. No device/Simulator/build/test/install/capture/input/Maps/Git/Release action occurred. Parent Active; no Gate/closure.


## C5-P Quality round2 bounded readonly confirmation authorization — 2026-10-01

Human replied “授权” to the concrete four-underlying-tool / five-minute Quality-only confirmation proposal. Original independent GPT6 Luna Quality runtime is reused; new QUALITY-C5-P round2 has separate frozen packet/input/Entry, checkpoint after2, budget4tools/300seconds including initial reads and final output. This does not retroactively validate round1's timeout; originalPartial/report/usage remain unchanged. Current authorizations still exclude C5-I/R, C5 Product skip acceptance/promotion, Simulator/device/install/capture/source/build/test/Git/Maps/Release. root sole repo writer; exact source/build/Debug payload revalidated before dispatch. [Round2 Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-r2-entry.md). Parent Active; overallC5-P ProductExit still pending.

- 2026-10-01 Asia/Shanghai — Authorized QUALITY-C5-P round2 readonly confirmation completed in3/4underlying calls,237.973/300seconds, checkpointafter2. [Round2 delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-r2-validation-2026-10-01.md) binds D1–D3Covered,47/47doc/keysource,568/568source/build,111/111Debug hashes and exactpacket ACK. Reviewer clarified before-status digest is the historical pre-freeze baseline, withdrew provisionalD1Partial beforefinal, and confirmed exactinputs; only authorizedround2docs/owningAssignment changed. Originalround1timeoutPartial andreport/usage remainimmutable; Architecture limitations remain disclosed. **C5-P independent confirmation work complete; Product Exit still pending C5-specific30skip/promotion decision.** 30cases remainSkipped/unverified, C4acceptance doesnotcarry; root/reviewer do not accept them. C5-I/R remainNotReady/unauthorized, requiring named install/settings/capture authority,freshexclusivewindow and runtimeEntry.2517otherexisting files/source/artifacts preserved. No source/test/build/Simulator/install/arming/input/Maps/Git/Release action; parentActive, no overallQualityPass/Gate/closure.


## C5 scoped Product residual acceptance — 2026-10-01

Human replied “同意” to the exact currentC5-only30skip acceptance question. [C5 decision](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-product-residual-disposition-2026-10-01.md) records a newstage-specific `accept`, nonblocking/unverified for the exact unchanged C5 candidate and retainedDebugpayload.20RimeBridge+10App entries remainSkipped/notpassed; this is notC4acceptance carryover. C5P-Q-01/C5P-R2-01's residual-acceptance dependency is satisfied only. Product promotion/install execution authority and otherEntry remain outstanding; C5-I/R stillNotReady/unauthorized, nofreshdevicelease. Originalreviews/Partial/usage and allsource/artifacts preserved. No newreview/test/build/Simulator/install/capture/input/Maps/Git/Release authority or action; parentActive, nooverallQualityPass/Gate/closure.


## C5-I exact paired install authorization / Entry — 2026-10-01

Human authorized continuing the proposedC5-I onepairedinstall/readinesscheck and confirmed previousexactSimulator remains exclusivelyreserved throughthisrun. [Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-i-entry-2026-10-01.md) binds unchanged568source/build,111Debugfiles,candidate,priorvalidindependentconfirmation andcurrentC5skipdisposition; exactiPhone18Pro/iOS27.0targetBootedconfirmed. rootsolewriter/EnvironmentExecutor; oneexistingDebugAppinstall,no rebuild/resign/separateappex,theninstalled11Mach-Oidentityandreadiness. NoC5-Rdiagnosticarming/input/Maps orsource/test/build/Git/Releasepermission. Newkeyboard/FullAccesssettingchangesnotassumed; missingreadinessHold. ParentActive,nooverallGate/closure; installationoutcome pending.


- 2026-10-01 Asia/Shanghai — C5-I onepairedDebuginstall succeeded on freshlyHuman-exclusive exactiPhone18Pro/iOS27.0. [Delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-i-validation-2026-10-01.md) records actualApp/embeddedappexversion1.0/build1,111/111fileSHA and11/11Mach-O SHA/size/UUIDexactmatch,MainApplaunch andfinite resource/settings observations. Human confirmedFullAccessON, but visibletrialfieldisinSearchTab, notthe plannedlocaldictionaryhost. **InstalledidentityPass; runtimeExitHold forhostrebind; C5-Rnotauthorized/notexecuted.** SourceonlycheckidentifiedexistingSearchTabState/TextField/settingscatalog andloadsideeffects; nooldreviewcoverageorhostpermissioninferred. SmallQualityhostdelta andHuman-operatedC5-R are proposalsonly requiringnewexplicitauthorization. Logging/highfidelity/categorykeys unchangedabsent; nokeyboardactivation/input/arming/Maps/deploy/build/test/source/Git/Release. MCPprofileephemeral/restored,existingdefaultsunchanged;2527otherexistingrepofilespreserved. ParentActive,nooverallGate/closure;30skipsstillC5acceptedunverified/notpassed.


## C5 SearchTab host-delta readonly review authorization — 2026-10-01

Human replied “授权” to the exactQuality-onlyhostdelta confirmation proposal:4underlyingtools/300seconds,checkpointafter2,reuseoriginalindependentGPT6LunaQualityruntime. Newstablelane QUALITY-C5-HOST-DELTA round1 onlyevaluatesexistingSearchTabtrialfield/querysideeffects andcapture/reader/evidencereuse boundaries. rootsolewriter,568source/build and111builtDebugfiles revalidated; priorC5-I installedproof/humanFullAccess observation are historicalartifactinputs,notcurrentdeviceproof. NoSimulator/device/installedcontainer access,UI,arming/input,build/test/source/Git/Maps/Release; noC5-Rexecutionauthority. OriginallocaldictionaryhostHold andreviews remainimmutable; candidate unchanged. [Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-entry.md). ParentActive,noGate/closure.


## C5 Host Delta Quality round1 outcome — 2026-10-01

**Partial / C5-R Hold**：原reviewer H1–H3报告已落盘，无新增设计级blocker；第4底层调用usage JSON序列化失败，只有起始timer，无完整end/elapsed，4/4已耗尽且未加轮。root保留原报告及timer，另记procedural-status，不追认预算内完成。SearchTab load首次部署intent与query echo仍是futureEntry约束；宿主为独立“搜索”Tab。22输入/568source/111built payload收尾匹配，无设备/输入/源码/Git动作。30C5 skip仍未验证。新最小只读round2与C5-R均待Human授权。见[本轮记录](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-validation-2026-10-01.md)。Parent Active，无Gate/closure。


## C5 Host Delta Quality round2 authorization — 2026-10-01

Human“授权”本轮最小只读确认：同一QUALITY-C5-HOST-DELTA lane round2，复用原独立GPT6Luna reviewer，2底层工具/180秒，第1调用后checkpoint，包含初次读取及最终交付。root唯一repo文档writer；冻结身份/source/builtpayload不变。只核清H1–H3来源和完整本轮交付，不补写或改判round1 Partial。无设备/Simulator/安装目录/AppGroup/prefs/UI/journal访问，不启用诊断或输入，不build/test/install/source/Git/Maps/Release；不授权C5-R。预算耗尽/漂移/缺证据停止，不自动加轮。[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-r2-entry.md)。Parent Active，无Gate/closure。


## C5 Host Delta Quality round2 outcome — 2026-10-01

本轮独立只读确认完成：H1–H3 Covered，无新增设计级Quality blocker；2/2底层工具，第1调用后checkpoint如实披露hash/source尚待第2完成。最终26/26inputs、568/568source-build、111/111built payload匹配。Reviewer146.722秒采样于最终timer写前，root另保留文件mtime146.725秒及稍后可读观察，不编造精确post-close计时。原round1 Partial永不改判。SearchTab为独立“搜索”Tab，onAppear部署intent副作用与query echo保留futureEntry约束。Product宿主采用、fresh独占窗口、actualinstalled/RIME稳定rebind及C5-R一次Human-input/capture/reader/restore权限仍待明确授权；本轮无设备/输入/源码/Git动作。30C5skip仍accepted-unverified/notpass。2543其他既有文件保全，parentActive，无整体Gate/closure。[本轮交付和具体C5-R提案](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-r2-validation-2026-10-01.md)。


## C5-R authorization / Entry — 2026-10-01

Human授权具体一次C5-R、采用独立搜索Tab，并确认原精确模拟器本轮仍独占及App未重建。当前installed111文件/11MachO完全匹配、RIME稳定、source/built不变；root收据/reader/恢复，Human操作一次input，不自动retry。Human已提前开启logging/高保真且确认原两项off；原键存在性未被machine采到，UNKNOWN恢复维度明确保留，不伪造exactabsence。DISP/ENGINEkeysabsent/defaultenabled保持。本轮窗口已建，待Human输入，runtimeExit未完成；无Maps/build/test/install/source/Git/Release，ParentActive、30C5skip仍未验证。[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-entry-2026-10-01.md)。

- C5-R Entry补充：输入尚未开始；精确恢复原键值/存在性UNKNOWN导致Entry Hold，待Human接受仅恢复off/off且将旧值/存在性列为本轮未验证残项。不自动视为Ready；既有单轮执行授权持续有效，除此缺口不重复询问。

- Human接受本C5-R仅恢复logging/高保真off/off、旧键值/存在性未核验为nonblocking-unverified残项；对应Entry Hold已解除，窗口start更新，开始指引一次Human输入。原残项仍未验证、不计通过，无权限扩展或重复轮次。

- C5-R Human完成唯一输入轮，反馈键盘正常/提交有反应。窄采集得到17typed v6事件，同一process/appearance：willAppear、didAppear、resume started及7proxy entered/returned对（6set_marked_text、1unmark_text），UTC02:46:26–02:46:34。无insert_text记录，不伪报该操作通过；无必达尾部要求。Python projection不是MainApp reader证明，当前待Human查看同配对reader和off/off恢复；无automatic retry。


## C5-R bounded run delivery — 2026-10-01

单轮Human输入/采集/reader查看/恢复已完成：同一process/appearance 17typed v6标记（willAppear、didAppear、resume started +6set_marked_text/1unmark_text entered-returned对）；Human反馈键盘正常/提交有反应，并在同配对MainApp reader确认三类可见、无异常提示。没有逐事件reader/internal counters证明；insert_text及tail未观察，不伪报通过。机器确认logging=false、expiry移除、DISP/ENGINE原absence不变，恢复off/off；原logging/expiry值/存在性保持Human已接受的本轮非阻塞未验证残项。installed111/source568/built111收尾匹配，2552其他既有文件保全，1Human轮/0automatic retry。无需新build/test/source/Git/Maps/Release，设备本轮窗口已结束。独立runtime验收尚未执行，Parent Active/no overallGate/rootcause/closure；30C5skips仍Skipped。见[运行证据](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-validation-2026-10-01.md)。


## C5-R independent readonly acceptance authorization — 2026-10-01

Human授权对本轮运行证据一次只读独立验收。复用未参与源码实现/设备执行的原独立GPT6Luna Quality reviewer；新lane QUALITY-C5-R-ACCEPT round1，6底层工具/480秒，第2/4调用checkpoint，root唯一repo文档writer。只审当前已归档C5-R证据/指定source/冻结scratch采集脚本及builtpayload，不读取当前device/Simulator/installed/AppGroup/prefs/journal，不输入或重复验证，不测试/build/install/source/Git/Maps/Release。须正向完整核验R1–R4并决定有限运行结论及reader缺口是否阻塞；不代Product接受新残项或扩大原accept。原reviews/Partial与30skip保留。预算耗尽/越界/缺证据按Policy停止Partial，不自动新轮；AuthorityHumanProductLead。见[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-accept-entry.md)。ParentActive/noGate。


## C5-R independent readonly acceptance outcome — 2026-10-01

QUALITY-C5-R-ACCEPT round1独立审查覆盖Complete，runtime acceptance **Hold / HOST-Q-R-01**。原Quality reviewer独立确认30/3/568/111hash，重算17事件同origin/process/appearance及7有序proxy对；Human三类可见/no warning仅有限读取证据，缺同MainApp同历史窗口17条消费绑定/条数及完整性证明，原恢复残项accept不覆盖此新gap。OwnerEnvironmentExecutor补证、HumanProductLead决定未来Entry；不自动重开设备/输入/采集/接受或加轮。6/6calls、461.006秒before-final-timer-write<480；360soft目标超出、per-call起止未提供，均披露，不声称全部流程严格合规。原证据/report/usage/timer/Partial保留，2561其他既有文件不变，source/built不变，无device/build/test/source/Git/Maps/Release。ParentActive/noGate/rootcause/closure，30skip仍未验证。[独立验收与最小补证提案](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-accept-validation-2026-10-01.md)。


## C5-R same historical reader supplement authorization / Entry — 2026-10-01

Human授权仅补原历史窗口reader条数/对应/完整性，确认原精确设备本轮只读独占。installed111/source568/built111与branch/HEAD/candidate匹配，captureoff/expiryabsent；不输入/arming/新采集/build/install。导航/刷新/滚动同MainApp既有reader，只留原17typed标记渲染有限字段/计数/notice，不copyall或截图。UI不显示process/appearance/seq，隐含字段不得称UI证明。HOST-Q-R-01原Hold及旧Partial保留；无法补足则Hold，未经另授权不修source或增加运行probe/复审。rootsolewriter，待补证。[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-reader-entry-2026-10-01.md)。

- Historical reader补证进度：已机器读同App既有UI67/67总条数，当前目标marker显示多重集已对应10/17；待10:46:30重复行第二对、10:46:29一对及10:46:26三条。仅读历史/导航刷新/滚动，无arming/新输入/采集；自动滚动未产生可见位移，由Human分段滚动辅助。保存有限UI字段快照与expected-rendering，未截图/复制rawUI/rawjournal。原HOST-Q-R-01 Hold不变；等待Human下一段显示，MCP原active profile已恢复，ownprofile保留供继续。不提前声称17/17或完整性验收。


## C5-R historical reader supplement delivery — 2026-10-01

同一历史窗口reader补证完成：有限显示多重集17/17（2lifecycle、1resume started、14proxy），15不同显示行，同秒重复行按出现数保留。Human使用既有reader关键词筛选：text14/67全为目标proxy；10:46:26查询10/67、底部露出3目标行，另7非目标不计入。原UI总数67不冒充目标17；可见语义快照无相关不完整/不可用/分页预算警告，不冒充隐藏internal counters。UI隐藏process/appearance/seq仍依赖原producer/同源绑定，同秒重复不辨识单条隐藏序号。Entry避免query建议被后续Human主动搜索/要求查看及筛选指引授权覆盖，仅reader筛选，无arming或新合成trial；不声称零keyboard/lifecycle激活。source568/built111/installed111收尾匹配，loggingfalse/expiryabsent/DISPENGINEabsent，原MCPprofile恢复。原17projection/运行window/reviews不改写。HOST-Q-R-01原Hold保留，需另授权独立处置；不自动复审/accept/Gate/closure。ParentActive，原30skips仍未验证；无source/build/test/install/Maps/Git发布。[补证交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-reader-validation-2026-10-01.md)。


## C5-R reader supplement independent review authorization — 2026-10-01

Human授权补证独立复审。复用原独立GPT6Luna Quality lane QUALITY-C5-R-ACCEPT round2，6底层工具/480秒，checkpoint第2/4；冻结新补证+原必要上下文，source568/built111/branchHEAD验证无漂移。只读本地归档，不当前device/UI/journal或采集脚本执行，不build/test/install/input/source/Git/Maps/Release；root唯一repo writer。新报告独立决定HOST-Q-R-01是否解除，原round1 Hold/Partial/reviews不改写；ParentActive/noGate。见[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-reader-review-entry.md)。


## C5-R reader supplement independent review round2 stopped — 2026-10-01

本轮Partial/incomplete，480秒硬截止时未收到review/usage；root停止新增分析并interrupt，未续预算。Checkpoint2确认46doc/1script/568source/111built，checkpoint4路径笔误失败且独立多重集尚未完成。实际至少4calls，最终总数/end ledger未知，不编造严格合规或验收结论。Q2/Q3/Q4未形成完整报告，原HOST-Q-R-01 Hold保留。root停止收据不替代独立review；新轮仅提案需Human授权。source/built未变，无设备/输入/build/test/source/Git/Maps/Release，ParentActive/noGate。[停止记录](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-reader-review-root-stop-2026-10-01.md)。


## C5-R focused reader review round3 authorization — 2026-10-01

Human授权仅定点核查17条显示对应关系与reader完整性。复用原独立GPT6Luna lane QUALITY-C5-R-ACCEPT round3，4底层工具/600秒，第2后checkpoint，第420秒优先交付；仅F1/F2与原HOST-Q-R-01处置，历史身份链作为输入不重开全运行复审。rootsource568/built111预检匹配，当前branchHEAD不变。原round1Hold/round2Partial保留。无设备/输入/采集/build/test/source/Git/Maps/Release；root唯一repo writer，ParentActive。见[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-reader-focused-r3-entry.md)。


## C5-R focused reader round3 independent delivery — 2026-10-01

原独立GPT6Luna reviewer最终F1/F2Covered：独立expected/observed均17行/15不同显示值、差集为空，重复行数量一致；reader可见完整性notice与源码路径匹配。HOST-Q-R-01只对原run历史reader窗口解除Hold，不改写原round1Hold/round2Partial或整体Gate。初稿矛盾经同轮第4调用修正，初稿report/usage/timer保留。4/4calls、523.803秒beforeterminaltimer<600，超过420soft；部分percall/end/checkpoint ledger缺项和版本差异如实披露，不声称全部流程严格合规。18直接input/source568/built111收尾匹配，其他既有文件保全，root唯一repo文档writer，无设备/输入/源码/build/test/Git/Maps/Release。原skips/恢复存在性/其他未验证边界保留，ParentActive。下一步真实宿主/Maps仅待Product另定Entry与授权。[本轮独立交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-reader-focused-r3-validation-2026-10-01.md)。


## C6 Maps bounded reproduction authorization / preliminary Entry — 2026-10-01

Human授权下一步Maps受控复现并确认原模拟器本轮独占。root先只读核source568/built111/installed111与11MachO、Maps可用/RIME稳定；machine采到本轮开启前logging存在false、expiryabsent、DISPENGINEabsent。未arming/输入/读取新journal。当前待Human原Maps操作/异常及FullAccess确认，再freeze单次步骤和capture窗口；未Ready，不推测原复现路径。原C5reader17/17限域结论不代Maps结果，历史skip和恢复残项不carry为C6通过。root唯一repo writer，无build/test/install/source/Git/Release；ParentActive。[preliminary Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-preliminary-entry-2026-10-01.md)。

- C6复现路径已由Human绑定：Maps切换前可输入，AppSwitcher返回后键盘/音振/按键反馈正常、候选及宿主输入不更新。已冻结一次未提交合成composition→系统设置→Maps受控变体；历史composition/另一宿主未知不伪称同条件。当前仅待FullAccess确认，仍未arming/window/input。见[本轮步骤](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-frozen-steps-2026-10-01.md)。

- Human确认本轮FullAccess仍开启，C6步骤和前置已满足，Ready for Human arming；先仅开启logging/首屏高保真，再machine核gate/start，尚未Maps输入或切换。原执行授权不重复询问。

- C6 Human开启logging/高保真，machine核gate/expiry有效且DISPENGINE仍原absence，source568/built111/installed111重绑一致。本轮唯一window已建，Active等待Human Maps基线输入；尚未切换/复现，零automaticretry。原C5历史window不更新。

- C6 Human报告两条切换路径：到Settings后返回触发键盘关闭重开且无异常；额外只开AppSwitcher再返回Maps复现key反馈正常但candidate/host不更新。两次Human变体同一capture窗口，variant各自machine起止未知，不能伪报单次严格受控或唯一failure-event对应；零automaticretry。已结束窗口且窄采3typed家族，暂保持异常现场，未重启/恢复。待同配对reader和四键精确恢复，未作根因/边界归因。

- C6窗口窄投影实际30事件、2process/appearance，gate结束有效；两变体无独立时间边界，未归因失败路径。窗口封存后先恢复两个开关，再reader只读历史，减少新增日志；未清空/重采/重试。


## C6 Maps bounded observation delivery — 2026-10-01

Human切换前Maps基线正常；到Settings返回导致keyboard关闭重开且无异常；额外只开AppSwitcher再直接返回复现key反馈正常而candidate/host不更新。两Human变体同一capture window，无独立machine边界，不能唯一绑定failure事件；零automaticretry。实际3family30事件/2process/2appearance，12setMarkedentered-returned对；同MainApp显示30/30多重集差集空，reader总172/filtered50不是本轮计数。四capture键原值/原存在性精确恢复，source568/built111/installed111收尾匹配，原MCPprofile恢复，设备本轮执行窗口已结束。原C5历史/Partial/skip不改写，未推根因或做fix/Gate/closure，futureC6独立验收尚未授权/执行。docs-only归档，无源码/build/test/install/清空/Git/Release，ParentActive。[本轮交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-validation-2026-10-01.md)。

## C7-A Debug owner probe local stage — 2026-10-02

Human在最终并排候选栏方案后授权“可以按这个方案继续”。保持Keyboard Experience primary、KeyboardCore secondary和root唯一repo writer；Luna仅scratch辅助。仅当前C7-A将新scopeACK/root输入与writer确认置于源码之前，Corehost隔离测试为本阶段验证；UI actual target/paired构建/精确独立review属于另授权C7-B，安装/出口/单次现场复现属于C7-C且需fresh独占Entry。原C6/旧skip/review不carry。源码仅9文件，新内存probe不改wire/引擎/恢复，暂无Ready；Core新scopeACK未确认前停止源码。

[当前授权](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c7-owner-probe-local-authorization-2026-10-02.md) · [计划](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-owner-probe-local-slice-2026-10-02.md) · [Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-owner-probe-local-entry-2026-10-02.md)。原GlobalExit/不可blocking key path、隐私、Runtime deployment和并发规则继续有效。当前UI只读ACK，Luna旧ACK仅scratch不代新阶段Ready。

- C7-A新Core exact-scope ACK已取得（Luna实现助手已读取当前plan/authorization/Entry），root Keyboard Experience/Executor ACK和源码前保全已确认，当前仅C7-A Ready/Active for local implementation。无UI target/设备/Gate结论；普通助手预算轮次停止后另派6calls/8min scratch起草，不是独立review自动续轮。

## C7-A local implementation delivery — 2026-10-02

本轮9文件Debug内存probe/UI接线已交付；独立按钮在展开左邻，arm后停手2秒允许旧候选取证，不改变输入/owner恢复。final manifest `9730e254cb8afd48f857ad9bef1659017fe90d26700ea3c9b1809249e3c751c8`。Swift strict format9、UI两模式syntax parse通过；隔离host Core聚焦36/36 passed，其中10新增probe+26原thread-affine，完整Core draft在未改T9PinyinPathTests:1429 optional interpolation编译失败，未执行断言/未修范围外文件；不称完整suite green。实际UIKit/paired/独立review/现场出口/Maps仍未验证，C7-B/C须另授权及相应Entry。root唯一repo writer，Luna仅scratch实现助手；未做设备/App构建测试/install/Git/Release。Parent Active，无Gate或根因结论。[本轮交付/M-02](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-owner-probe-local-validation-2026-10-02.md)。

## C7-B1 scoped continuation — 2026-10-02

Human授权C7-B继续，当前不在Mac前，手动Simulator测试不可用。先独立static review及generic SDK-only编译，actual test执行/安装/交互需未来Entry。原roles/root唯一writer保持，Quality复用独立runtime、Architecture新独立Luna，C7实现助手不做review。packetfreeze先dispatch，18calls/900秒各自lane、6callcheckpoint；无自动预算续轮/范围外修复/设备/Git/Release。见[授权](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c7b-authorization-2026-10-02.md)与[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b-entry-2026-10-02.md)。

## C7-B1 non-device delivery — 2026-10-02

本轮generic SDK四action均exit0：专用Debug paired build、App/Keyboard build-for-testing、Release、普通Debug。候选571inputs+630Vendor hash `0095841393c45895ae5ee861878a03c0c9a8de3643759be47a9ac1cb5d8953f8`，9source identity不变；真实UIKit target编译补齐但未执行tests。专用Debug含UI/export符号，普通Debug/Release不含两入口符号；未安装。Architecture A1-A3全static covered无材料性source blocker，Quality Q1-Q3 Covered/推进Hold；原review仅旧静态inputs，不因root新build而改verdict。完整Corestrict编译blocker/actual device suites/runtime仍Open。预算记录soft未达/时钟缺项/Architecture原soft字段错误以独立factual reconciliation披露，不严格协议全合规。Human未回家，手动动作暂不可用；无设备/source/Git/Release。Parent仍Active。普通状态同步不是独立M-02触发。[本轮交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b-validation-2026-10-02.md)。

## C7-B2 exact single-file authorization / Entry — 2026-10-02

Human接受新增最小单文件修复与完整host Core验证。只将T9PinyinPathTests的pageOnly map index显式为Int，不改数据/断言、不整文件格式化/其他源码。root Core/Executor scopeACK与完整保全已满足，C7-B2 Ready/Active；full suite含全部当前test，strict flags不降。source修改改变测试候选，原SDK product输入未变，但不能把旧review改成新candidate verdict。无device/Git/Release，ParentActive。见[授权](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c7b2-core-test-authorization-2026-10-02.md)及[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-test-entry-2026-10-02.md)。

## C7-B2 single-line repair / full Core delivery — 2026-10-02

授权只改T9PinyinPathTests的map index显式Int，one-line diff，无fixture表达式/断言或业务源码改动。完整同一package204文件host严格套件1194 passed/0fail/0skip，exit0，warnings-as-errors不降。原57strict format诊断原样保留，lint exit1，本轮无commit/push/format或merge Gate。十文件manifest `3c45e4d76a858d4d5484496d216cb8b1dc6a1d59d5bc3311eb5a2e451602e0e0`；产品/SDK实际filelist不消费此host-test文件，已归档等价证明，SDK不重跑。原reviewHold不自动改写，无补审预算续轮/device/Git/Release，ParentActive。仅普通状态同步。[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-validation-2026-10-02.md)。

## C7-B2 focused Quality round2 authorization / Entry — 2026-10-02

Human授权“做这项修复的定点 Quality 补审吧”；复用独立Quality Luna runtime，QUALITY-C7-B1新baseline round2，12底层calls/600秒首预算，420soft/第4callcheckpoint，无自动加轮。26content/210hash-only inputs和R2-Q1/Q2/Q3冻结，单行/完整Core/F1处置；F2/F3/SDK/Architecture/整体Gate排除，原Hold不改写。root唯一repo writer，readonlyreview本阶段Ready，无代码/build/test/设备/Git/Release。见[授权](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c7b2-quality-r2-authorization-2026-10-02.md)、[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-quality-r2-entry-2026-10-02.md)。

## C7-B2 focused Quality round2 delivery — 2026-10-02

独立Quality R2-Q1/Q2/Q3均Covered，仅F1编译阻断Resolved；实际11calls/404.715139秒。原整体Hold及格式/动态边界保留，无代码或测试重跑。见[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-quality-r2-validation-2026-10-02.md)和[报告](../reviews/quality-c7-b1-r2-review-2026-10-02.md)。普通阶段同步，非M-02/Gate/Close。

## C7-C-P取证链准备授权 / Entry — 2026-10-02

Human当前授权非模拟器取证链准备；原roles保持、root唯一writer，复用独立Quality runtime。见[授权](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c7c-prep-authorization-2026-10-02.md)、[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7c-prep-entry-2026-10-02.md)及[执行包](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7c-evidence-chain-plan-2026-10-02.md)。未来实际iOS/安装/attach/Maps为单独依赖，不改观测合同或Product Gate。

## C7-C-P 取证链准备交付 — 2026-10-02

P-Q1/P-Q2/P-Q3 Covered，Positive scoped preparation opinion（仅准备协议）；取证规则准备不等于运行证据。见[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7c-prep-validation-2026-10-02.md)。原整体Hold、F2/F3、格式/iOS/安装/Maps依赖保留；普通状态同步，非M-02/Gate/Close。

## C7-B3 phased authorization / Entry — 2026-10-02

Human继续授权；当前先host standalone candidate build，实际iOS阶段待fresh exclusive与环境/恢复核验。见[授权](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c7b3-authorization-2026-10-02.md)与[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-entry-2026-10-02.md)。未扩大到Maps/probe/LLDB/source/Git或Gate。

## C7-B3 host candidate delivery / waiting actual iOS Entry — 2026-10-02

新standalone candidate及两个独立host artifact补审见[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-validation-2026-10-02.md)。Human本轮exclusive确认尚待收，实际suite未执行；未install/Maps/arm/LLDB/Git/source操作，不晋级Gate/Close。

## C7-B3 actual iOS and restoration Hold — 2026-10-02

[C7-B3 iOS delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-validation-2026-10-02.md) records actual three-suite evidence, immutable Architecture R3 Partial/usage, and App Group restoration failure. Original binary111 files restored; data restoration incomplete. No Product/Gate/Closure.

## Environment rebuild bounded Exit — 2026-10-02

[New baseline](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-environment-rebuild-entry-2026-10-02.md) is deployed and Human verified normal Full Access/candidates/commit. Old data loss is not repaired or accepted away. No broader Gate/closure.

## Architecture R4 bounded supplement — 2026-10-02

[R4 delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-arch-r4-validation-2026-10-02.md) resolves only H2 independent embedded-entitlement/xcent byte comparison. Original Partial/usage immutable, no runtime/Gate/parentClose.

## C7 promotion checkpoint — 2026-10-02

[Checkpoint](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-promotion-validation-2026-10-02.md) records bounded independent preparation opinion, current-stage Human residual acceptance, complete fresh backups and installed candidate/readback. Current App launched; keyboard and runtime probe validation pending. No broader closure.

## C7 UI candidate H1 host authorization / Entry

Human授权执行H1，root SDK-only host Ready，见[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h1-entry-2026-10-02.md)。不含H2/独立新产物review/actual suites/安装/运行/Maps；新source571/Vendor630及实际Xcode/SDK核验完成，不自动跨阶段。

## C7 UI new candidate H1 bounded Exit — 2026-10-02

[H1 delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h1-validation-2026-10-02.md) records new candidate43d85d…/payload78/MachO6, signed paired products and embedded entitlement/xcent exact bytes. No tests/install/runtime or broader Gate.

## C7 UI candidate H2 host authorization / Entry

Human授权执行H2，root仅普通Debug/Release SDK-only隔离验证；[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h2-entry-2026-10-02.md) source571/Vendor630与H1匹配，旧build不复用。不含测试、设备、安装、独立新产物review或Release。

## C7 UI H2 bounded Exit — 2026-10-02

[H2 delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h2-validation-2026-10-02.md) confirms fresh ordinary Debug/Release paired SDK builds exclude probe UI/export, with H1 dedicated positive control. No tests/install/runtime/Release or independent review acceptance.

## C7 UI Q authorization / frozen reviewer lanes

Human授权开始Q。见[Q Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-q-entry-2026-10-02.md)与两份派发前冻结packet；root仅协调独立artifact绑定并归档，不跨入测试/安装/runtime。新lanes各round1，复用现有独立Luna reviewers，按固定calls/elapsed预算停止，Human-only扩围。

## C7 UI Q stopped bounded Exit — 2026-10-02

[Q delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-q-validation-2026-10-02.md) is Partial/incomplete. Architecture substantive A1/A2 matched but hard-exceeded final delivery is not accepted Complete; Quality missing report/usage, interrupted without automatic renewal. No tests/install/runtime or broader Gate.

## Q round2 bounded supplement authorization — 2026-10-03

Human仅授权Quality Q1-Q3新独立交付和Architecture C1-C2报告一致性补证；[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-q-r2-entry-2026-10-03.md)与两份先冻结packet约束范围/新预算。旧Partial和超预算保留，无新的Architecture artifact完整review授权，root不自动晋级T/I/U/M。

## Q R2 bounded supplement delivery — 2026-10-03

[R2 delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-q-r2-validation-2026-10-03.md) completes authorized Quality independent delivery and Architecture consistency only. Old R1 artifact Partial/budget history retained; Q overall not automatically accepted.

## Architecture R3 artifact delivery authorization — 2026-10-03

Human仅授权Architecture A1/A2新正式交付；[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-arch-r3-entry-2026-10-03.md)及派发前冻结R3packet约束同候选/独立核算/6calls900s hard。旧Partial/超预算不倒写，无测试/安装/runtime自动授权。

## Architecture R3 stopped delivery — 2026-10-03

[R3 stop](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-arch-r3-validation-2026-10-03.md) Partial/incomplete: false input-path helper errors and final plist parsing failure, reviewer reports6call limit exhausted; required final report/usage not delivered. No product failure/Gate/runtime claim.

## New independent reader/candidate lane authorization — 2026-10-03

Human授权更换独立reviewer，先R0 reader audit再同候选A1/A2正式交付。[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-reader-new-entry-2026-10-03.md)及新lane packet为派发前冻结，旧R3限额已停，不变更旧轮。无build/test/install/runtime/Git授权。

## New reviewer reader-first bounded stop — 2026-10-03

[Delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-reader-new-validation-2026-10-03.md) preserves R0/A1Covered, A2Partial and report mismatch;8call ceiling reached. No automatic renewal, no product failure or Gate/runtime acceptance.

## Last raw diff/coherence supplement authorization — 2026-10-03

Human答复继续精确已准备最小补审；[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-reader-final-supplement-entry-2026-10-03.md)和authorizedR2packet为派发前冻结，4calls/600s。仅C1rawdiff、C2report/usage及R0/A1证据复用；旧失败轮未续预算、无reader/binary重查或设备动作。

## C7 UI last scoped independent supplement Exit — 2026-10-03

[Delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-reader-final-supplement-validation-2026-10-03.md) records C1/C2 Covered and valid R0/A1 reuse, 4calls/193.653s. Current bounded Q artifact delivery is complete with Quality R2. Prior Partial/header mismatch remain immutable. No new runtime/test/install/overall Gate; next T requires fresh exclusivity and full verified backups before tests.

## C7 UI T Entry preparation — 2026-10-03

Human授权准备并确认当前原模拟器独占；[T Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-entry-2026-10-03.md)记录571 source/630 Vendor匹配，前置限定Q完整。仅文档准备，未访问设备；T0完整fresh备份/恢复方案未取得，Prepared未Ready。T0/T1/T2执行及独立结果验收仍需对应授权；不自动测试/安装/U/M。

## C7 UI T0 bounded Exit — 2026-10-03

Human授权T0并另授权一次精确appex正常SIGTERM；[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t0-validation-2026-10-03.md)完整current main827/group52files+2links/app78备份、源稳定/内容一致/双签名核验及恢复方案。仅副本新增provenance差异完整披露，未实际恢复/启动/测试/安装新候选；T1/T2待授权。原历史数据损失、skip、Partial保留。

## C7 UI T1/T2 freeze — 2026-10-03

Human仅授权冻结；[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t12-frozen-validation-2026-10-03.md)保存精确三套test argv、Core204完整等价及复用条件、T2每套后数据核验/限定条件恢复。包digest `090f2f150b018d5d289cfedbb51315c153f700fce9df8ff094631a8ee6743abf`，未执行；T1/T2实际执行仍需Human授权，不扩安装新候选/Maps/清理/Git。

## C7 UI T1/T2 read-only execution authorization — 2026-10-03

Human授权执行T1＋T2只读核验；[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1-execution-entry-2026-10-03.md)满足本轮source/environment/backup条件。仅三套test及逐套只读读回，异常/数据差异即停止，T2恢复及精确残留进程终止未授权；root不自动install/restore/redeploy/rerun/Maps。

## C7 UI T1/T2 bounded stop — 2026-10-03

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1t2-validation-2026-10-03.md)记录actual Rime85/0/20与AppKeyboard421/0/10；T2发现group不可用/App及main变化，原backup和test-after保全，Keychain未执行、T1整体Partial/Hold。准备具体旧C7恢复清单但不执行，待Human决定；无重跑/新候选晋级/Maps/Git。

## C7 UI T2 listed restoration authorization — 2026-10-03

Human授权仅清单内旧C7安装包及数据恢复；[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-restore-entry-2026-10-03.md)已满足before/after完整保全与backup身份条件，root环境执行；preserve新容器系统metadata/UUID，未列差异停止，启动/健康/Keychain/新candidate/Maps仍未授权。

## C7 UI listed T2 restoration bounded Exit — 2026-10-03

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-restore-validation-2026-10-03.md)旧C7精确安装恢复、main4覆盖/46测试新增清单移除、Group应用内容/2链接恢复，系统身份保留，双签名及两次机器读回通过。provenance45例外披露，未启动/runtime/Keychain；T1仍Partial，原30skip及历史Hold/数据损失保留。

## T2 baseline health continuation authorization / Entry — 2026-10-03

Human授权补归档后继续验证，fresh独占及未打开/重装/部署已确认。[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-health-entry-2026-10-03.md)旧C7和恢复数据机器前置通过，Human正常候选/提交健康待验证；两诊断保持关闭，不扩新candidate/Maps/观测/LLDB。原T1 Partial及skip/Keychain残项保留。

## T2 restoration normal baseline health bounded Exit — 2026-10-03

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-health-validation-2026-10-03.md)记录Human完全访问/候选/提交正常及机器安装身份/两诊断关闭/部署状态读回。仅旧C7正常基线，T1仍Partial；剩余Keychain前需退出与输入后新鲜完整备份，不自动终止进程或扩大恢复清单。

## T1 remaining Keychain continuation Entry — 2026-10-03

Human当前继续授权沿原未执行单个Keychain，[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-continuation-entry-2026-10-03.md)新鲜完整post-health backup/source/工具链/进程退出前置满足；原argv不变。T2只读及异常停止，不扩大新恢复清单/终止/新candidate/Maps。原历史T1 Hold及30skip保留。

## Remaining signed Keychain actual bounded Exit — 2026-10-03

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-continuation-validation-2026-10-03.md)实际1/0/0、原两套不重跑；T2精确test-host111/main3变化及完整after保全，Group无差异。本轮最小恢复清单Prepared、未执行；历史Hold和30skip未验证保留。

## Keychain post-test minimal restoration authorization — 2026-10-03

Human明确授权本轮旧C7安装及3TipKit恢复，[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-minimal-restoration-entry-2026-10-03.md)沿新鲜post-health备份和新清单；不写AppGroup、不删路径、不启动/部署/测试。机器读回后运行健康及独立T验收仍需实际证据。

## Keychain minimal restoration bounded Exit — 2026-10-03

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-minimal-restoration-validation-2026-10-03.md)单次旧C7安装+3TipKit覆盖完成、Group写入0/删除0、机器双签名/完整应用内容/两次稳定读回通过。最新恢复后runtime未补验；30skip处置/独立T验收仍开放。原历史Hold保留。

## Latest post-Keychain-restoration normal health Exit — 2026-10-03

Human另授权并反馈完全访问/候选/提交正常，[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-keychain-minimal-restoration-health-validation-2026-10-03.md)机器旧78/双签名/诊断缺键关闭/部署状态一致；本次恢复健康缺口补齐。30skip当前处置/独立T验收仍开放，旧Hold保留。

## Independent T acceptance authorization / Entry — 2026-10-03

Human授权独立T验收，[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-independent-entry-2026-10-03.md)派发前冻结新Quality lane round1，root仅归档协调，GPT6 Luna独立评审；14calls/1200s硬限，不自动扩围/续审。30skip无当前Product处置，独立意见不替代决定/整体Gate。

## Independent T R1 stopped / R2 Prepared — 2026-10-03

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-independent-r1-validation-2026-10-03.md)4leaf calls/T1-T6全部Partial，摘要算法未显式导致停止，elapsed起点缺失。root已核 canonical自载摘要一致/whole-file另值，旧报告不倒写。R2同范围10calls/900s Prepared、未授权未派发，先澄清算法/先冻结时钟。

## Independent T R2 continuation authorization — 2026-10-03

Human明确授权已Prepared R2继续，[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-independent-r2-entry-2026-10-03.md)同候选/T1-T6、明确digest/派发前时钟，10calls900s硬限；同一Luna独立reviewer复用。R1 Partial/计时UNKNOWN保留，不替代Product skip决定。

## Independent T R2 budget stop — 2026-10-03

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-independent-r2-validation-2026-10-03.md)900s硬限/最终report及usage缺失，last7call检查点保留不代正式coverage。原digest已独立一致，实质Core/保护/最终交付未完；两条更小lanePrepared、未授权未派发。


## 2026-10-03 T split 独立验收授权

Human「批准继续」：执行 S（T1–T3）及 P（T4–T6）两条独立只读 lane，各 GPT6 Luna low，6 leaf calls / 900s，root 协调，输出独立报告/usage，超限停止。[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-split-entry-2026-10-03.md)。30 raw skip /29未验证的本阶段 Product 处置仍开放，不扩展设备或实施授权。


## 2026-10-03 T split 停止交付

S/P各6次调用已耗尽，两条均缺正式review/usage；[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-split-validation-2026-10-03.md)为Partial/incomplete，Overall T Hold。保留原历史、30raw skip/29未验证及独立元数据分类缺口，不自动续预算。


## 2026-10-03 T reader 预检授权与交付

Human授权仅预检reader和写出流程；[预检交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-reader-preflight-validation-2026-10-03.md)已跑通两正常和三失败路径。root协调工具不是独立结论；T仍Partial/Hold，补审须新授权/精准冻结，30raw skip/29未验证处置开放。无设备操作或源码实施。


## 2026-10-03 T split R2 收尾授权

Human明确继续未完成工作；[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-split-r2-entry-2026-10-03.md)：S/P复用两位Luna low，各round2 6calls/900s，新鲜冻结证据，先写交付骨架、第4call前正式交付。旧预算不复活，不含设备/源码/残项接受。


## 2026-10-03 T split R2 交付与T2补证

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-split-r2-validation-2026-10-03.md)：P T4–T6 Complete，S T1/T3 Covered、T2缺逐项skip原因Partial；正式report/usage已归档，两lane各6calls已耗尽。root同一xcresult只读补得30条明确原因，尚未独立接受。2calls/300s仅T2补审Prepared待Human；29未验证当前Product处置开放，整体Hold。


## 2026-10-03 T2 skip 原因补审授权

Human明确授权Prepared最小补审；[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-skip-reasons-entry-2026-10-03.md)，复用Luna low、2calls/300s。仅30条原因与身份对应，无残项接受或设备权限；原S-R2历史不改。


## 2026-10-03 T2原因补审交付 / 当前T覆盖收尾

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-skip-reasons-validation-2026-10-03.md)：T2原因缺口Covered，2calls/163.063s，30条原因身份完全对应；与S-R2/P-R2增量合并T1–T6覆盖已齐。原Partial历史保留，整体T Hold至[当前29残项Product处置](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-product-residual-decision-prepared-2026-10-03.md)明确，尚未接受；不含设备、新候选runtime或Release。


## 2026-10-03 当前T Product残项接受 / 阶段收尾

Human「仅对当前 T 接受这 29 项为非阻塞、未验证残项。」已记录[Product Decision](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-C7-UI-T-residual-product-decision-2026-10-03.md)与[收尾交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-product-residual-validation-2026-10-03.md)。当前T覆盖与阶段残项依赖均闭合，按冻结范围收尾完成，附29项未验证非阻塞残项；30raw skip保留，signed1pass单列，原Partial历史不改。配对与父任务仍Active，根因未确认；新候选runtime尚未验证，下一阶段Entry/设备/安装权限不由本决定授予。


## 2026-10-03 I0 安装前保护继续 / 等待appex退出

Human授权继续，fresh原模拟器独占已确认，当前[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-i0-entry-2026-10-03.md)仅I0核验/备份准备。新43d85d…与旧ddd557…payload/signature核验通过，PID45871精确旧appex仍运行，备份未开始，无信号。完整备份前必须退出；不自动安装/U/LLDB/Maps，T29残项决定不扩大到下一阶段。


## 2026-10-03 I0 SIGTERM授权 / 新鲜备份交付

Human明确授权仅PID45871正常SIGTERM继续，重核SHA后一次发送并退出；[I0交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-i0-validation-2026-10-03.md)新鲜main827/Group53+2links/app78完整稳定备份、复制属性分类/双签名通过，旧4组T快照保留。[I1具体安装包](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-i1-install-prepared-2026-10-03.json)Prepared待安装及该窗口独占授权；本轮未install/run/restore/LLDB/Maps。


## 2026-10-03 I1单次安装授权 / Entry

Human授权具体I1并确认安装窗口独占，见[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-i1-entry-2026-10-03.md)。仅exact43d85d…单次install和只读身份/数据验证；I0基线前置不符停，after先保全，无启动/U/Maps/LLDB/恢复权限。


## 2026-10-03 I1单次安装交付 / U0 Prepared

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-i1-validation-2026-10-03.md)：exact43d85d…单次安装exit0，78SHA/6MachO/配对identity/双签名与H1一致；应用数据/Group保护无差异，4Snapshot改名内容multiset相等，源稳定after完整保全。未启动/runtime。后续[U0](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u0-prepared-2026-10-03.md)仅正常输入+未arm按钮可见性计时Prepared，待具体人工窗口授权；不含U1/LLDB/Maps/部署/Release。


## 2026-10-03 U0人工正常路径授权 / Entry

Human明确U0和人工窗口独占；[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u0-entry-2026-10-03.md)仅完全访问只看、空栏未arm按钮计时及一次合成输入/提交。I1 identity固定；结果Pending，不arm/LLDB/Maps/部署，失败停止。


## 2026-10-03 U0正常路径交付

[U0交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u0-validation-2026-10-03.md)：Human完全访问开、空栏按钮初始可见、候选/提交正常，有候选按钮隐藏、提交后空栏可见；root78SHA与H1匹配，两诊断原ABSENT/off保持。U0按本轮范围完成，未arm/LLDB/Maps，不推普遍延迟修复或根因结论。U1正常观测→冻结→有界导出须下一阶段Entry/授权；父子仍Active，T残项不扩权。


## 2026-10-03 U1准备授权与交付

Human仅授权准备U1。[准备交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-preparation-validation-2026-10-03.md)固定新43d85d…、1279输入零漂移及U0正常路径；命令/账本/decoder/停止与恢复准备齐。Prepared非运行Ready，执行U1及fresh独占待授权；无设备/LLDB/arm操作。caller与逐call账本需新轮实际证明，不复用旧PID/UUID/address/结果。父子Active。


## 2026-10-03 U1单轮执行授权 / Entry

Human授权U1并确认原模拟器本轮独占，补确认环境及未arm。[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-entry-2026-10-03.md)固定43d85d…、freshPID80843/78SHA/1279输入/两诊断off。仅正常路径单次arm-n-freeze、有界导出和明确cleanup，不Maps/恢复/新测试。结果Pending。


## 2026-10-03 U1 pre-arm身份冲突停止

[Hold交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-hold-validation-2026-10-03.md)：MCP回执UDID为其他任务defaults，root未设置断点即continue/detach，0arm/0read。3次调用账本齐、原PID恢复运行、78SHA和两诊断off不变。缓存源码支持默认标签解释，但实际loaded identity未采；[绑定补正](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-binding-amendment-prepared-2026-10-03.md)Prepared待Human，未再次attach；U1未完成、父子Active。


## 2026-10-03 U1身份绑定补正继续授权

Human明确“OK，请你继续吧”，当前U1按最小绑定补正继续：fresh原PID与同session loaded路径+UUID为实际目标身份证据，工具UDID标签冲突保留；不改共享defaults，命令显式session，原单轮操作/有界复制/cleanup合同不变。原Hold不改，尚未arm或导出。


## 2026-10-03 U1提前freeze停止交付

[Incomplete交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-premature-freeze-validation-2026-10-03.md)：实际目标已由loaded路径/UUID绑定，标题取证已确认；Human在输入卡前再次点击导致出口hit1。未读取内存/导出或继续n，实例已消费。MCP remove因LLDB/DAP registry差异失败留痕，continue/detach成功；13debug calls完整账本、payload/诊断原值保持，Human UI Exit待确认。新实例正常退出及新U1单轮Prepared待授权；父子Active。


## 2026-10-03 U1 Human Exit及事后误触

Human确认UI恢复、取证标题，报告cleanup后误触不确定字母并立刻删除，已在U1停止交付附原话。只作为Human Exit和协议外动作，不改Incomplete或0read；不声称误触后的完整data不变。新扩展实例及新单轮仍Prepared待明确授权。


## 2026-10-03 U1R1新实例与单轮授权

Human授权新扩展实例正常退出及新单轮，[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-entry-2026-10-03.md)。fresh独占/关闭App确认待收，尚无SIGTERM或新实例；仅当前已核扩展一次SIGTERM（若未退出），不强杀/重装/部署。原U1Incomplete不改，逐步卡与有界导出/cleanup合同保持。


## 2026-10-03 U1R1采集交付 / Human Exit待确认

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-validation-2026-10-03.md)：新PID88188实际路径/UUID绑定；Human逐步arm/n/freeze、真实caller借用停点核验，单read528bytes/5行/attempt1配对完整。LLDB断点已删除/列表为空、continue/detach成功，15calls完整账本、root工作63.106秒，actualpause开始未知保留。机器Exitpayload/source/原diagnostic off不变；Human UI Exit待回，独立验收未授权未执行，父子Active、Maps根因未确认。


## 2026-10-03 U1R1 Human视觉Exit补齐

Human确认保留n后的候选视觉状态及取证标题，已补进U1R1交付；机器运行/断点清理/detach及人工视觉Exit分别归档，不声称额外试打响应已验证。当前采集交付完成，附该限制，独立验收尚未授权/执行；父子Active、Maps与根因仍开放。


## 2026-10-03 U1R1独立只读验收授权

Human明确授权本运行证据独立验收。[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-review-entry-2026-10-03.md)：复用独立Luna low /root/t_split_p，新QUALITY-C7-UI-U1R1-RUNTIME round1，6calls/600秒；冻结P1身份/P2raw配对/P3borrow-cleanup-ledger有限scope。仅读固定证据，不设备/新采集/源码，无Maps或Release授权，结果Pending。


## 2026-10-03 U1R1独立意见与正式交付一致性停止

[独立交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-review-validation-2026-10-03.md)：Luna P1–P3Covered、窄normal runtime-chain接受，6calls/259.905s。原report/usage/analysis保留；D001调用ordinal、D002external布尔、D003旧status、D004逐次调用时间来源缺口使正式交付一致性Partial。rootactualdigest匹配不能替代作者补正；2calls/180秒精准补正Prepared待Human，不自动续预算。父子Active，无Maps/根因/Release结论。


## 2026-10-03 U1R1作者交付最小补正授权

Human授权2calls/180秒补正D001–D004，[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-delivery-correction-entry-2026-10-03.md)。同独立Luna仅增量作者说明，原runtime lane不续预算，不重审/不读设备或source；未知逐callUTC明确null，不补造。原件及窄意见保留，结果Pending。


## 2026-10-03 U1R1作者补正接收与预算停止

[补正接收](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-delivery-correction-validation-2026-10-03.md)：D001–D004字段补正已交付，packet/14输入及原件摘要匹配，原P1–P3窄运行意见不变。2/2调用耗尽；首调用计时未持久化，180秒预算合规UNKNOWN，作者usage未重复model/effort字段，正式交付仍Partial。原Entry/packet/审查原件保持，不自动续预算，不操作模拟器；Product阶段处置待决定，父子Active。


## 2026-10-03 U1R1 Product阶段残项接受

Human明确“接受”。仅当前U1R1正常路径运行证据／交付补正阶段，将整轮计时缺失及180秒预算合规UNKNOWN、usage未重复model/effort字段接受为非阻塞、未验证残项，见[处置记录](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-delivery-correction-validation-2026-10-03.md)。独立Partial原记录不改，不记Pass或预算合规；原P1–P3窄运行意见保持，不再补审此记录限制。父子Active，Maps／owner／根因开放；无新增实施或设备操作授权，不外推后续阶段及Release。


## 2026-10-03 M阶段准备授权与交付

Human明确“那就做M阶段准备包”。[Prepared](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m-prepared-2026-10-03.md)及[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m-entry-prepared-2026-10-03.md)冻结同候选、原设备、M0保护／M1新实例／M2单轮Maps直接AppSwitcher返回取证依赖，逐步操作卡、一次有界导出／cleanup、owner/receipt判读和停止／恢复边界。准备核1279源输入及78本地payload无漂移，未访问模拟器；U1R1记录限制处置不扩M。M0/M1/M2均未获执行授权、现场条件UNKNOWN，不Ready；root唯一writer，父子Active，无新reviewer预算／源码／构建测试／安装／Maps运行／Release。


## 2026-10-03 M0执行授权与当前保护交付

Human仅授权M0，随后确认主App关闭、未重装／部署、本轮独占。沿M准备包条件步骤，仅对精确核实的旧appex88188发送一次SIGTERM后静止备份；[M0交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-validation-2026-10-03.md)：原UDID、78SHA、双签名与源1279一致，完整main/Group/current43d85d installedApp备份127.63MiB核验通过，两诊断ABSENT/off。[恢复方案](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-recovery-plan-2026-10-03.md)Prepared未执行；[四组T快照清理清单](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-old-backup-cleanup-prepared-2026-10-03.md)约499.83MiB待另批准，尚未删除。M1/M2与恢复／安装／LLDB／Maps复现未授权，父子Active、根因开放。


## 2026-10-03 已授权四组历史T快照清理完成

Human明确授权精确清单4目录删除，[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-old-backup-cleanup-validation-2026-10-03.md)：当前M0副本先复核，4目录身份／大小一致后逐项删除，原分配499.83MiB移除；parent凭据文件摘要不变，I0/I1/M0保留约382.83MiB。历史四组完整raw回滚副本不再可用，不据摘要声称仍能恢复；审查／库存／报告／xcresult保留。未操作模拟器或扩大至M1/M2，父子Active。


## 2026-10-03 M1唯一新实例／Maps入口只读授权与核验

Human仅授权M1，已手动打开原设备Maps空搜索框、观测可见、完全访问开及独占。[M1交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m1-validation-2026-10-03.md)：新3626原UDID/path/SHA匹配，安装78/6MachO/双签名及源1279、M0备份956文件通过，两诊断缺键off、部署正常。人工26键／空候选／未arm未输入补确认待回。初始无标名assert误解与Maps路径别名修正原件保留，未造计时；M1只验installed身份，M2授权后另核loaded/session/断点，不自动附加或扩权。父子Active，无输入／Maps切换复现／M2执行／Release。


## 2026-10-03 M1人工确认／阶段限定收尾

Human“确认”补齐26键、空候选、仍观测及未点击未输入。[M1交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m1-validation-2026-10-03.md)按限定范围完成；机器与Human来源分开、loaded identity/真实engine schema未冒充已读。M2未授权未执行，父子Active；下一具体权限为单轮M2原设备独占、只读附加与真实loaded UUID/出口断点、一次arm／两次合成n／一次AppSwitcher直接回Maps／freeze／有界导出／cleanup，不含恢复/安装/重试。


## 2026-10-03 M2单轮执行授权／pre-arm Entry

Human授权一轮M2并确认原设备仍独占，[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2-entry-2026-10-03.md)：fresh同3626/原设备、78/6身份、源1279与备份956通过，两诊断ABSENT/off。仅当前观测-n-直接AppSwitcher回Maps-n-freeze、有界只读导出及自身断点cleanup；loaded identity/出口断点现场核验后才下发arm。禁止retry或重启补成功，无恢复/安装/新源码测试/Release权限，父子Active。


## 2026-10-03 M2 actual loaded identity／pre-arm就绪

PID3626/session5c2bdb0d…实际原UDID加载路径及两个UUID匹配；出口断点1 resolved单位置0hit，continue成功running。MCP共享profile标签与banner差异原样保留，root未改defaults，命令显式session。仅下发一次观测arm卡，未输入/切换/freeze/内存read；Human回报待收。


## 2026-10-03 M2基线偏离／提前出口停止交付

[停止交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2-baseline-stop-validation-2026-10-03.md)：Human单次arm显示取证并称未再次点取证，基线却多按几次且候选/输入框无更新；未下发AppSwitcher/freeze，机器出口hit1，真实触发未知。0read/无snapshot，不猜Human误触或owner状态。11calls/22账本完整，delete自身断点/list为空/continue/detach及机器/人工视觉Exit齐。新采集/进程退出/重启/只读触发分析均需相应范围授权，不auto retry；父子Active，Maps根因开放。


## 2026-10-03 M2-A最小新实例arm核验授权

Human同意具体最小建议并确认关闭/独占，[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2-arm-check-entry-2026-10-03.md)冻结仅旧3626正常退出／新实例／精确附加／单次arm后立即hit检查，若hit则有限caller最多8帧，0memory read。立即自身断点cleanup/detach，不接输入或切换，不auto retry；原M2Incomplete不改，父子Active。


## 2026-10-03 M2-A单次arm出口检查交付

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2-arm-check-validation-2026-10-03.md)：旧3626一次SIGTERM正常退出，新8491实际原UDID loaded UUID匹配。pre-arm与Human取证回报后的出口hit均0；11calls/22账本和raw完整，自身断点清除/detach与机器Exit齐。多余continue的notStopped原件保留，最终Ss；0read，无输入/切换/freeze，视觉Exit待回。旧M2提前hit原因仍未知，不判owner、不自动续接或retry，父子Active。


## 2026-10-03 提前出口异常仅记录

Human决定旧M2一次提前hit1仅记录，后续再现再讨论；暂停此专项追查，不作为当前阻塞或默认后续验证。旧Incomplete、原始hit1/本轮hit0与原因未确定结论保留。无新增设备操作或修复授权。

## 2026-10-04 M2R1新鲜完整配对授权

Human授权并确认原设备独占、两App关闭及未重新安装/部署。[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r1-entry-2026-10-04.md)明确当前root/Human职责、旧8491一次正常退出、新鲜恢复保护与新实例loaded身份依赖；一次arm/两次n/一次直接AppSwitcher回Maps/freeze/有界read/cleanup，零retry。旧提前hit1仅记录的Product处置保持，旧轮不拼接，独立验收另申请；无源码/安装/恢复/Git/Release权限。


## 2026-10-04 M2R1 pre-arm就绪

新41635真实loaded原UDID/UUID匹配、出口唯一断点0hit，continue running；身份/保护通过。Human观测已出现；按已授权单轮操作卡先单次arm，不提前输入。

## 2026-10-04 M2R1调试会话停止

[停止交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r1-session-loss-stop-2026-10-04.md)：Human正常基线后显式session返回No active session，detach同失败。无目标切换/冻结/read，10calls/20账本保全，原进程Ss及身份/保护/prefs一致；cleanup证明UNKNOWN，不冒充已清理。Human要求权限对照，shell sandbox ps拒绝/主机成功，但不能证明MCP loss根因或恢复session。父子Active、M2R1Incomplete，无auto reattach/retry。


## 2026-10-04 M2R1人工视觉Exit确认

Human确认界面正常、按钮取证、候选/输入框保留。视觉Exit齐；原session断点清除/detach未证，M2R1Incomplete不改，不续接。见[停止交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r1-session-loss-stop-2026-10-04.md)。


## 2026-10-04 M2R1只读工具生命周期核查

Human授权只读继续，[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r1-tool-continuity-audit-2026-10-04.md)：XcodeBuildMCP2.7.0 sessions仅进程内存；现存工具两进程均晚于最后成功调用，支持生命周期/路由变化解释、未证原退出原因。目标41635 Ss且P_TRACED clear；旧断点删除/detach仍UNKNOWN，未附加读内存补证。持续调试通道跨人工回复预检仅Prepared，未获新attach或Maps窗口授权。

## 2026-10-04 稳定调试通道预检授权/pre-Human核验

Human仅授权预检，[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-stable-channel-entry-2026-10-04.md)：原41635核身份后提升权限native PTY附加，真实loaded UUID齐，LLDB45732/debugserver45734，自身断点1=0hit，continue且目标SXs。跨一次人工回复与cleanup待执行；不arm/输入/Maps复现，原M2R1Incomplete不改，无新独立review预算。

## 2026-10-04 稳定调试通道预检交付

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-stable-channel-validation-2026-10-04.md)：Human未操作后同PTY63415/LLDB45732/debugserver45734/目标41635及原断点保留，running/0hit。自身断点删除/list空/detach/quit成功，debugger进程退出、目标Ss/P_TRACED clear，78/1279/诊断键一致。无arm/输入/切换/freeze/read，视觉Exit待回；仅一个回复边界covered，原M2R1Incomplete与旧回执缺口不改，无新Maps权限。


## 2026-10-04 稳定通道预检视觉Exit收尾

Human界面正常/既有候选与输入框保留/按钮取证。仅预检交付完成，machine与视觉Exit齐；原M2R1Incomplete、整体诊断Active和新窗口权限边界不改。

## 2026-10-04 M2R2原生通道新鲜配对授权

Human同意具体新鲜配对建议，[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-entry-2026-10-04.md)冻结root/Human职责、原设备fresh保护/精确旧41635一次正常退出/新实例与native通道、单次完整人工链和一次有限read/cleanup。fresh关闭/独占补确认Pending；不续旧取证状态，不auto retry，不安装/恢复/源码或Git。原停止/孤立hit1记录处置保持。


## 2026-10-04 M2R2静止保护完成

Human现场补确认齐；旧41635仅一次正常退出。956保护文件完整，main/App复用核验M0，Group新增约36.1MiB、source三读一致及双签名通过，两诊断ABSENT/off。新实例/loaded/人工条件仍待核；见[Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-entry-2026-10-04.md)，无arm输入/恢复安装。


## 2026-10-04 M2R2 native pre-arm就绪

本轮新55759实际loaded身份/保护齐，native单出口断点0hit且continue成功；按授权逐卡先单次观测，不提前输入。

## 2026-10-04 M2R2 frame参数停止交付

[交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-frame-stop-validation-2026-10-04.md)：本轮Human正常基线/直接AppSwitcher返回失败齐，进程与原生通道保持。明确freeze之后出口hit1/caller同步borrow可见，但frame0为mach_msg_trap且byteCount未声明；按合同停止0read/no snapshot，不从caller/ABI猜读。10steps/20账本保全，delete/list/continue/detach/quit和机器Exit齐，视觉Exit待回。M2R2Incomplete，不判owner，不auto retry；旧提前hit1仅记录处置不改。


## 2026-10-04 M2R2视觉Exit收尾

Human确认返回后界面状态保留/按钮取证，附截图（不复制候选宿主内容进repo）。视觉Exit齐，不代表输入恢复；本轮Incomplete/0read/no snapshot不改。见[停止交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-frame-stop-validation-2026-10-04.md)。

## M2R2 historical re-export preparation — 2026-10-04

[Read-only findings and Prepared Entry](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-reexport-prepared-2026-10-04.md) replace the earlier proposed fresh-normal/fresh-Maps retry with a narrower same-PID retained-window supplement. Execution remains pending; original Incomplete/0read stays immutable. Tonight completion target does not waive parent Exit or independent acceptance.

## M2R2 historical snapshot supplement — 2026-10-04

[Delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-reexport-validation-2026-10-04.md) preserves original Incomplete/0read; one new bounded1056 read obtains paired baseline/failure attempts. Boundary owner absence at schedule observed; precise recovery cause unresolved. Tool-poll ledger gap disclosed. Parent/child Active, no Gate/closure.

## M2R2 exact-evidence independent review — 2026-10-04

[Independent delivery and owner handoff](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-m2r2-reexport-review-validation-2026-10-04.md) preserves Architecture/Quality Partial and Quality file-write residual. Runtime local owner-absent boundary covered; no parent Exit waiver, new reviewer budget, source/Simulator action or Gate.

## Parent-only bounded diagnostic completion — 2026-10-04

Human approved [parent Product Decision](../product-decisions/KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001-bounded-completion-product-decision-2026-10-04.md) and [delivery](../evidence/keyboard-wake-lifecycle-diagnostics-001-bounded-completion-2026-10-04.md). Parent diagnostic now Completed under its own bounded addendum. This paired-rollout Assignment remains Active; independent Partial, skip identities and scope/gate residuals are not automatically accepted away or closed. No new source/runtime/installation/review/Git/Release authority.

## Separate host-activation fix preparation — 2026-10-04

Human authorized read-only preparation of [minimal repair proposal](../plans/keyboard-wake-host-activation-minimal-fix-proposal-2026-10-04.md). Static resign/appear recovery asymmetry aligns with the proven owner boundary. Proposed separate five-file UI lifecycle/gate/test/project slice only; no implementation Assignment/ACK, new capture or source/build/test authority. This rollout lifecycle remains Active and completed parent stays Completed.

## Host-activation repair Architecture design R1 — 2026-10-04

[Independent R1](../evidence/keyboard-wake-host-activation-minimal-fix-architecture-r1-validation-2026-10-04.md) is Partial: proposal hypothesis/scope covered, executable lifecycle and pre-resume canary contract missing. [Author supplement](../plans/keyboard-wake-host-activation-minimal-fix-state-contract-supplement-2026-10-04.md) Prepared within existing design-preparation authority, not independently accepted. No implementation or automatic R2 budget; old R1 unchanged, parentCompleted/childActive preserved.

## Host-activation repair supplement Architecture R2 — 2026-10-04

Human authorized only focused supplement review. [R2 delivery](../evidence/keyboard-wake-host-activation-minimal-fix-architecture-r2-validation-2026-10-04.md) is Pass with conditions for Proposed design: S1/S2/S3 covered; state-table, pre-owner canary permission and cross-target test constraints required in any later implementation. Original independent packet hash transcription error disclosed with root byte receipt; report immutable. R1 Partial and parent Completed retained. No implementation Assignment/ACK/authority, runtime, new review budget or Git publication granted. Next is separate formal five-file implementation preparation/authorization.

## JSONL / parent Exit mapping prepared — 2026-10-06

Human authorized a docs-only [Exit map](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-jsonl-parent-exit-map-2026-10-06.md). Parent JSONL-to-parent Exit mapping is already recorded in the parent historical map and PEXIT-R1; this child does not repeat that capture. Diagnostic handoff to the parent is delivered via M2R2. Global v6 emission and reviewed v6 Maps remain unmet. HOST-ACTIVATION-FIX E1 is excluded from this contract. Lifecycle remains **Active** pending Product bounded-completion or keep-Active. No source, simulator, review budget, backup delete, Git or Release.

## Bounded completion — 2026-10-06

Human accepted Option A. [Product decision](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-bounded-completion-product-decision-2026-10-06.md) and [delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-bounded-completion-2026-10-06.md) record **Completed — 诊断 producer 与父交接交付** with R-JSONL / R-V6 / R-COV / R-AUDIT / R-SKIP accepted-unverified. Independent Partial unchanged. No source, simulator, Git, Release or backup deletion.
