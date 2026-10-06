# Assignment: KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001 — App Switch 后键盘输入失活诊断

> Policy: [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) v1.0
> Product decision source: Human Product Owner instructions in this Codex task, 2026-09-23 through 2026-09-27 Asia/Shanghai; responsibility configuration explicitly confirmed and current target revalidated as iPhone 18 Pro / iOS 27.0 on 2026-09-27 after the prior target became unavailable.

## Lifecycle

**Completed — bounded diagnostic delivery, 2026-10-04.** Human Product Owner approved the exact parent-only completion-scope amendment and PEXIT-R1/R2/R3 accepted-unverified residuals in [Product Decision](../product-decisions/KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001-bounded-completion-product-decision-2026-10-04.md). Proven schedule-owner boundary and named domain handoff are delivered. Architecture/Quality overall Partial remains; this is not Reviewed/Closed, a Quality Gate, fix or Release. The paired-rollout child separately reached **Completed — 诊断 producer 与父交接交付** on 2026-10-06 under its own Product decision; this parent addendum is unchanged.

Historical Active-entry record (retained): all role acknowledgments for this lifecycle-diagnostic scope are recorded. Product revalidated iPhone 18 Pro / iOS 27.0 (`405D994F-28CB-4F89-BB22-B64AD81C05A2`) on 2026-09-27; explicit-UDID read-only checks confirmed it Booted. The Human Product Owner attested keyboard and Full Access setup and enabled logging/high-fidelity sampling; shared preferences and active content-free Extension journal segments independently confirm diagnostic arming. One working baseline, one App Switcher failure report and one keyboard-switch recovery are recorded in [the evidence report](../evidence/keyboard-wake-lifecycle-diagnostics-2026-09-27.md). Root cause remains unresolved; no fix or Gate conclusion.

### Current Status

| Field | Status |
|---|---|
| Lifecycle | **Completed — bounded diagnostic delivery** |
| Current phase | Completed — Human-approved parent-only bounded diagnostic: baseline schedule owner/receipt present; post-return failure schedule both absent after teardown. Exact-evidence handoff delivered; PEXIT-R1/R2/R3 accepted nonblocking/unverified, overall independent Partial unchanged. |
| Material non-claims | Owner/receipt absence is proven only at this failed schedule boundary; precise missing-recovery cause, complete system/JSONL/recovery coverage and realized schema remain unknown. No behavioral fix, overall review Pass, Quality/Product/Release Gate, physical-device claim or Git publication. |
| Next handoff | Keyboard Experience Maintainer primary / KeyboardCore Maintainer collaboration receive immutable evidence and regression requirements. PR [#198](https://github.com/shchnk1103/Universe-Keyboard/pull/198) squash-merged `4b102a9f33e1535da6be23280e912a84d2766c3c`. [M-02](../evidence/keyboard-wake-bounded-publication-001-post-merge-state-sync-2026-10-06.md). Any fix/new capture/TestFlight/Release requires separate authorization. Paired-rollout child separately **Completed — 诊断 producer 与父交接交付** on 2026-10-06; this parent contract is unchanged. |

## Problem and objective

In Maps, after opening the iOS App Switcher while Universe Keyboard is visible and returning to Maps, keys continue to show visual feedback and key sounds, but candidates and host text stop updating. The Human confirmed that System Keyboard text entry works; after switching back to Universe Keyboard, composition, first-candidate selection and Maps insertion work again. The captured journal contains action, owner-publication, UI-application and candidate-structure events during the reported failure; these do not establish visible candidate rendering or host-text insertion, nor which lifecycle, owner-readiness, key-acceptance or publication step failed.

Establish a content-free, operation-correlated event timeline that distinguishes those boundaries, then hand the evidence to the owning domain. Do not implement a behavioral fix in this Assignment.

## Read-only source preflight

At baseline `9eb83158e49218c1e8f75dbe7dd9e0390db81409`, the Extension already emits structured `presentation.appeared`, `touch.terminal`, `rime.owner.published` and `ui.applied` events. Debug `KBDVIS` snapshots also include `ownerReady`, session epoch and structural input/candidate lengths. `viewWillAppear` requests RIME resume; `viewDidAppear` separately arms runtime activation after the keyboard is visible, and the Extension-host resign-active notification is another suspend boundary.

The structured diagnostic schema has an `input.action` code but no call site currently emits it. The schema also has no structured owner-start/readiness/failure or per-action engine-acceptance/completion events. These are candidate observation gaps, not proof that the corresponding runtime step failed. Before adding fields or events, review the schema/privacy contract in ADR 0027 and determine whether the existing `KBDVIS` path already supplies the needed evidence.

## Additional read-only boundary audit — 2026-09-23

The following facts come from the pinned source baseline; they are not a runtime trace:

- `keyTouchDown` provides immediate visual and audio feedback, while text dispatch occurs later in `insertKey` through `controller.handle(.insertKey)` and `syncUI`. A `touch.terminal` event therefore does not prove that the input action ran or that RIME accepted it. Sources: `Keyboard/Controllers/KeyboardViewController+KeyPressFeedback.swift` and `Keyboard/Controllers/KeyboardViewController+InputActions.swift`.
- The `input.action` enum is not emitted at that path. Structured `rime.owner.published` and `ui.applied` events are emitted from `onResponsivePresentationNeeded`; the ordinary `insertKey` → `syncUI` path does not emit those same events. Therefore, an absent owner/UI event cannot by itself prove RIME inactivity until the captured build's runtime pipeline mode is identified. Sources: `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` and `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`.
- `viewWillAppear` calls `resumeRimeAfterVisibilityChange`; `viewDidAppear` separately arms the first-frame runtime activation gate. Both `viewWillDisappear` and `NSExtensionHostWillResignActive` can suspend the runtime. The Extension observes the host resign-active notification, but this source path has no corresponding host did-become-active observer. This makes the observed return lifecycle sequence a key discriminator, not a proven defect. Sources: `Keyboard/Controllers/KeyboardViewController.swift` and `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`.
- If `viewWillAppear` does run, `RimeEngineImpl.resumeAfterVisibilityChange` must initialize the engine, create a session and reselect a schema; failure leaves the engine suspended and emits an error. Capture must distinguish that failure from the case where no resume boundary ran. Source: `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl.swift`.

The initial read-only audit performed no code, build, test or runtime capture. The later bounded diagnostic implementation reuses the existing allowlisted `input.action`, `ui.applied`, `rime.owner.published` and candidate-visibility codes, plus content-free `KBDVIS` markers. Paired `input.action` records share the touch-derived action sequence and their local journal order distinguishes entry to and return from `controller.handle`; the return record does not prove deferred RIME execution. A 64-entry in-memory epoch/revision map carries the action sequence into later owner/UI events. The provisional hypothesis remains limited to a possible missing resume boundary or failed resume; runtime behavior is not yet captured.

## Scope and effects

1. Inspect the exact source baseline and map existing diagnostics at keyboard visibility, suspension/resume, RIME owner start/readiness/failure, key acceptance, engine processing and result publication.
2. If existing diagnostics cannot separate these stages, add narrowly scoped **Debug/high-fidelity-only, content-free** typed markers only in the Keyboard Extension UI-owned boundary. Reuse existing `appearanceID`, `actionSequence`, process identity, local sequence, session epoch and revision where applicable; do not add arbitrary UUIDs, strings, paths or free-form error text. `DiagnosticEvent.Field` remains limited to its reviewed value types and allowlists. If a new event code or typed payload is required, complete the ADR 0027 allowlist/privacy review before implementation. If observing the missing boundary requires changes under `Packages/KeyboardCore` or `Packages/RimeBridge`, stop and request a separate Assignment or Product Lead reassignment to that domain owner.
3. Build a diagnostic artifact from the pinned baseline plus only this Assignment's diagnostic changes.
4. On the Product-revalidated designated iPhone 18 Pro / iOS 27.0 Simulator (`405D994F-28CB-4F89-BB22-B64AD81C05A2`), capture one working baseline and one App Switcher reproduction only after an Assignment-specific route and exclusive reservation are verified. Preserve the simulator's current settings and app data; do not reuse an environment occupied by another task.
5. Produce an evidence-bound timeline, state what it proves and leaves unknown, and hand off to the proven domain owner.

The diagnostics are test-only and must not change production behavior, input semantics, RIME deployment, session policy or UI behavior.

## Non-goals

- No speculative fix, refactor, input-path redesign or permanent production instrumentation.
- No logging of user input, candidate content, host text, coordinates or personal data.
- No RIME deployment, App Group data mutation, settings reset, reinstall of a physical device or release action.
- No physical-device, Product Gate, Quality Gate, TestFlight or Release claim.
- No access to or modification of the shared dirty checkout or any simulator used by another task.

## Responsibility assignments

| Responsibility | Assignment |
|---|---|
| Assignment Authority | Product Lead |
| Domain Owner | Keyboard Experience Maintainer |
| Executor | Current Codex task |
| Environment Executor | Current Codex task, limited to the Product-revalidated iPhone 18 Pro / iOS 27.0 Simulator (`405D994F-28CB-4F89-BB22-B64AD81C05A2`), with explicit UDID routing during the human-confirmed no-concurrent-use window |
| Human Dependency | Human Product Owner performs one App Switcher reproduction and reports observed behavior if the scripted/automated capture is insufficient |
| Architecture Reviewer | Architecture & Knowledge Steward |
| Quality Reviewer | Quality, Performance & Release Maintainer; independent of the Executor and evidence author |
| Product Approver | Human Product Owner in the current Codex task |

The Product Lead confirmed the responsibility configuration on 2026-09-23 Asia/Shanghai, initially revalidated iPhone 17 Pro Max / iOS 27.0 on 2026-09-24, then selected iPhone 18 Pro / iOS 27.0 on 2026-09-27 after the prior target was unavailable. The Human Product Owner confirmed no AI was using simulators before the current target was used. All current simulator inspection used the exact iPhone 18 Pro UDID; no other simulator was operated. Domain Owner, Executor, Environment Executor, Architecture Reviewer, Quality Reviewer and Human Dependency have acknowledged the scope; final Architecture and Quality conclusions remain pending.

## Assignee acknowledgments

| Responsibility | Status | Boundary |
|---|---|---|
| Keyboard Experience Maintainer (Domain Owner) | **Acknowledged** via isolated read-only role unit on 2026-09-23 Asia/Shanghai | Confirms lifecycle/UI ownership and this diagnostic scope; no root-cause or Quality conclusion. |
| Executor (current Codex task) | **Acknowledged** on 2026-09-23 Asia/Shanghai | Accepts the bounded diagnosis-only scope; no implementation before `Ready`. |
| Environment Executor (current Codex task) | **Acknowledged; explicit target route in use** | Product initially selected iPhone 17 Pro Max / iOS 27.0, then revalidated iPhone 18 Pro / iOS 27.0 (`405D994F-28CB-4F89-BB22-B64AD81C05A2`) on 2026-09-27. Current checks use the explicit iPhone 18 Pro UDID; no other simulator was operated. |
| Architecture & Knowledge Steward | **Acknowledged** via isolated read-only role unit on 2026-09-23 Asia/Shanghai | Confirms ADR 0002/0004/0027 and lifecycle boundary fit; no final Architecture verdict. Typed-event, privacy and hot-path constraints are recorded below. |
| Quality, Performance & Release Maintainer | **Acknowledged** via isolated read-only role unit on 2026-09-23 Asia/Shanghai | Confirms evidence and review boundaries; no Quality verdict. Final evidence review remains a later stage. |
| Human Dependency (Human Product Owner) | Acknowledged by confirming the assigned App Switcher reproduction role on 2026-09-23 Asia/Shanghai | Human action only if automated capture is insufficient. |

## Required inputs

- Exact source baseline: repository `HEAD` `9eb83158e49218c1e8f75dbe7dd9e0390db81409` in the isolated worktree created for this Assignment. Revalidate the baseline immediately before implementation; do not import dirty-checkout changes.
- Prior installed diagnostic build source identity: `80091f35cc5411b292eca78662f39e2b91694045`; this is a comparison reference, not the implementation base.
- User-provided diagnostic log at `/Users/doubleshy0n/.codex/attachments/602fa653-15fe-4e1d-a0db-34cfe879d8d3/Pasted text.txt` and the user's observed Maps/System Keyboard recovery sequence.
- `docs/PROJECT_CONTEXT.md`, `docs/DEBUGGING.md`, `docs/READING_MAPS.md`, `docs/architecture/shared-container-and-rime-lifecycle.md`, ADR 0002 and ADR 0004.
- A Product-revalidated iPhone 18 Pro / iOS 27.0 simulator target (`405D994F-28CB-4F89-BB22-B64AD81C05A2`) with explicit UDID routing and a human-confirmed no-concurrent-use window.
- Diagnostic build and install from the pinned baseline are complete. Keyboard / Full Access and Main App diagnostics settings still need to be visibly verified in the designated simulator.

## Execution checkpoint — 2026-09-24

- Source base remains `9eb83158e49218c1e8f75dbe7dd9e0390db81409`; diagnostic changes are confined to five Keyboard Extension UI controller files. No source changes were made under `Packages/KeyboardCore` or `Packages/RimeBridge`, and no behavior fix was added.
- The isolated worktree had no RIME vendor directory. `bash scripts/ensure_rime_vendor.sh fetch` retrieved the manifest-pinned `rime-vendor-ios-1.16.1-lua.1-octagram.1` archive and verified SHA-256 `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`; the required 12-framework structural inventory passed.
- Generic iOS Simulator Debug build used Xcode 27.0 SDK, Swift 6.0, strict concurrency and warnings-as-errors settings; exit status `0`. Linker emitted non-fatal warnings that three Boost simulator archives lack `x86_64` slices; the selected iPhone simulator is `arm64`. No automated test suite was run.
- Bundle `com.DoubleShy0N.Universe-Keyboard` was installed and launched via explicit UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`. `simctl get_app_container` confirmed installation. After macOS was unlocked, an XcodeBuildMCP UI snapshot confirmed the Main App activation screen and built-in `朙月拼音` marked `未部署`. Two UI taps did not change the screen; keyboard installation, Full Access and diagnostics settings remain unverified. The temporary Assignment profile was non-persistent, and the previous XcodeBuildMCP profile was restored afterward.
- `xcrun swift-format lint --strict --configuration .swift-format` passed for all five changed Swift files; `git diff --check` passed. No commit, push or publication was authorized or performed.

## Execution checkpoint — 2026-09-27

- Product selected iPhone 18 Pro / iOS 27.0 (`405D994F-28CB-4F89-BB22-B64AD81C05A2`) after the previously assigned iPhone 17 Pro Max became unavailable. All inspection used the explicit UDID; no other simulator was operated.
- The Human Product Owner built and launched from this diagnostic worktree in Xcode. The installed app is version `1.0 (1)`; its Main App and Keyboard executables have SHA-256 identities recorded in the [evidence report](../evidence/keyboard-wake-lifecycle-diagnostics-2026-09-27.md). The five-file source patch digest matches the recorded Assignment patch. An Xcode result bundle was not retained, so exact binary-to-source build provenance is not independently closed. Both installed bundles pass ad-hoc code-signature verification, but entitlement readback is empty even though shared App Group diagnostics are written; record this as an unresolved artifact-evidence discrepancy.
- Read-only App Group checks confirmed Luna resources/receipts, `rime_deployed=true`, `rime_needs_deploy=false`, `rime_deploying=false`, and enabled diagnostics. No settings or RIME data were modified by the executor.
- One baseline, the user-reported App Switcher failure, and the user-performed System Keyboard → Universe Keyboard recovery were captured. The Human confirms System Keyboard text entry, followed by successful Universe Keyboard composition, first-candidate selection and Maps insertion. The failure-window journal contains input-action, RIME-owner, UI-application and candidate-visibility events despite the reported lack of visible candidate change and host insertion. Recovery is associated with a new journal writer `processInstanceID` and appearance identity; this does not prove OS process termination or restart. These observations do not prove a root cause; see the evidence report for event hashes and limitations.
- Independent reviews bind to evidence report SHA-256 `d9c416b24380ac56d6bc17c7d0660aefe852ac1e376c46f979c9bb2d83c86f0f`: Architecture **Pass with conditions** for content-free diagnostic handoff only; Quality **Partial / Incomplete**, acceptable as evidence handoff only. Neither review is a Quality Gate or Assignment exit/close.
- Keyboard Experience Maintainer completed a read-only source review against the pinned source baseline. It found that touch feedback and `controller.handle`/`syncUI` are separate from proof of host insertion; the proxy adapter forwards marked/final text calls without an acknowledgement; lifecycle source resumes RIME in `viewWillAppear`, suspends on `viewWillDisappear` and host resign-active, and has no corresponding host-active observation. These facts make presentation/proxy synchronization and an unobserved lifecycle transition plausible boundaries, but do not prove failure or bind this source to the installed binary. No KeyboardCore/RimeBridge ownership escalation is justified yet. Next useful evidence would correlate lifecycle callbacks, owner readiness/session epoch and content-free proxy-call markers for the same appearance ID; implementing those markers remains pending explicit Product authorization.
- No production behavior was changed in this turn; no automated tests, Product Gate, Quality Gate, commit, push, PR, merge or Release action occurred. Architecture, Quality and Keyboard Experience read-only reviews are complete; any further instrumentation is pending explicit Product authorization.

## Follow-up Assignment dependency

> **S-03 — Current status:** ADR 0036 was conditionally accepted on 2026-09-29; see [ADR-0036-ACCEPT](../product-decisions/ADR-0036-ACCEPT-authorization.md). The Human Product Owner separately authorized local Runtime Record API implementation on 2026-09-29; its fresh worktree/source-test baseline is recorded in the [authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001-implementation-authorization.md) and [baseline receipt](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-fresh-worktree-baseline-2026-09-29.md). The child advanced from Assigned through Acknowledged, Ready and Active to **Completed** after exact role rebinds, implementation authorization, isolated source/test baseline, bounded ownership check, implementation evidence, strict formatting and a passing KeyboardCore suite. Its corrected ten-file implementation candidate is bound to canonical manifest `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c`; Runtime/ingress default to v3, and v4 typed submission requires explicit opt-in. Architecture and Quality independently returned **Pass with conditions**; see their [Architecture](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-architecture-implementation-review-2026-09-29.md) and [Quality](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-quality-implementation-review-2026-09-29.md) receipts. The Human Product Owner accepted the exact implementation candidate with conditions on 2026-09-29; the Product review is recorded at [KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001 product review](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001-product-review.md), and the child is now **Reviewed**. See the [implementation evidence](../evidence/keyboard-wake-diagnostic-runtime-record-api-001-implementation-2026-09-29.md), [Architecture review](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-architecture-implementation-review-2026-09-29.md) and [Quality review](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-quality-implementation-review-2026-09-29.md). The Extension producer predecessor was Reassigned; its separate paired-build successor is **Acknowledged / Not Ready**, and the Human Product Owner has now authorized an exact-scope implementation record ([Assignment](keyboard-wake-diagnostic-extension-paired-rollout-001.md), [implementation authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-implementation-authorization.md)). Pre-edit Entry found the `.v3` versus schema-v5 writer conflict, so Product/Architecture reconciliation is required before implementation; the [Entry receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-pre-edit-entry-2026-09-30.md) and [decision brief](../plans/keyboard-wake-diagnostic-extension-writer-version-reconciliation-001.md) record it. The exact Simulator remains unreserved. Production marker emission remains disabled; no implementation, Product Gate, parent closure, or root-cause conclusion is claimed.

The Human Product Owner authorized creation and assigned responsibilities for [KEYBOARD-WAKE-DIAGNOSTIC-EVENT-SCHEMA-001](keyboard-wake-diagnostic-event-schema-001.md) on 2026-09-27 Asia/Shanghai, then narrowed it to document-only schema design and review. Domain Owner acknowledged, Architecture passed, and Quality acknowledged with conditions against Proposal 0.4. On 2026-09-28 the Product Owner accepted Proposal 0.4 as a document-only design, bound to pre-disposition complete-file SHA-256 `c20038a8c33acd9ce777eb6b1fe0ea72d0076bcbcaa82e6aaec9293ac9b75774` and reviewed design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`. On 2026-09-29 the Product Owner separately accepted the bounded persisted-v4-writer scope and version invariant in [PD-KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001-authorization.md); the exact-scope Architecture review returned **Pass with conditions** and Quality acknowledged the scope. The Human Architecture Authority and Product Lead then conditionally accepted [ADR 0036](../architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md), recorded in [ADR-0036-ACCEPT](../product-decisions/ADR-0036-ACCEPT-authorization.md); the reviews remain historical receipts for their listed pre-acceptance candidates. The separate [reader implementation Assignment](keyboard-wake-diagnostic-reader-implementation-001.md) was authorized for KeyboardCore only and is now **Reviewed — Pass with conditions** on candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`; its evidence and the downstream raw-key consumer responsibility are recorded in the [implementation evidence](../evidence/keyboard-wake-diagnostic-reader-implementation-001-2026-09-28.md) and [Quality review](../reviews/keyboard-wake-diagnostic-reader-implementation-001-quality-review-2026-09-28.md). The child does not enable v4 writing or close this parent. The separate [Main App consumer Assignment](keyboard-wake-diagnostic-main-app-consumer-001.md) was acknowledged against scope revision `4d8e861c63b97ff7bcd484cc736a0317ea063dac4fa0c47b5c92271d9d2f889d`; on 2026-09-28 the Product Owner explicitly authorized its Main App implementation, and the child advanced to **Active**. It remains limited to completeness/status, strict-reader consumption, event formatting and legacy fallback behavior. On 2026-09-29 its final candidate `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a` received Architecture and Quality **Pass with conditions** after required CI-equivalent checks passed on iPhone 17 Pro Max / iOS 26.0; detailed hashes and result artifacts are in the [implementation evidence](../evidence/keyboard-wake-diagnostic-main-app-consumer-001-implementation-2026-09-28.md). `DiagnosticsJournalReader` exposes query-wide completeness from `beginPage`; Human Product Owner accepted that query-wide contract on 2026-09-29, so continuation coverage is correctly scoped to aggregate retention and page-local first-rejection discovery is excluded. The Runtime Record API child now has separate Human implementation authorization and a fresh isolated KeyboardCore source/test baseline, recorded in its [implementation authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001-implementation-authorization.md) and [worktree baseline receipt](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-fresh-worktree-baseline-2026-09-29.md); exact Domain Owner, Executor, Architecture and Quality rebinds are recorded. Its bounded KeyboardCore implementation is **Completed** on corrected candidate `abbe6154…`; Runtime/ingress default to v3, typed v4 submissions require explicit opt-in, and 1137 KeyboardCore tests pass. Architecture and Quality independently returned **Pass with conditions** on the exact ten-file candidate; the Human Product Owner later accepted the exact implementation candidate with conditions; the Product review is recorded at [KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001 product review](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001-product-review.md), and the child is now Reviewed. See the [implementation evidence](../evidence/keyboard-wake-diagnostic-runtime-record-api-001-implementation-2026-09-29.md), [Architecture review](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-architecture-implementation-review-2026-09-29.md) and [Quality review](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-quality-implementation-review-2026-09-29.md). The Extension producer predecessor remains **Reassigned**; the Human Product Owner authorized establishment of its separate [paired-build rollout Assignment](keyboard-wake-diagnostic-extension-paired-rollout-001.md), now **Acknowledged / Not Ready**, after exact-current role rebinds and independent reviews, under this [Assignment-establishment authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-authorization.md). That authorization does not cover implementation. Production v4 emission remains disabled. This parent remains Active and root cause unresolved; no behavior fix, Product Gate, Release or parent closure is claimed.

The successor-status sentence immediately above records its current state. On 2026-09-29, all six required responsibilities acknowledged the then-current paired-rollout Assignment. On 2026-09-30, the Human Product Owner accepted a minimum Entry/Exit sequencing clarification; because those ACKs bind the earlier candidate, the child returned to **Assigned / Not Ready** pending exact-current role rebinds. Its authorization remains documentation-only; implementation authorization and a fresh exclusive Simulator reservation are still outstanding. Later on 2026-09-30, all six responsibilities acknowledged or reviewed the clarified Assignment on pre-status SHA-256 f7e8304df7a9d8e56a6fa1387b9815410cccc21f52a0c87929f05b66be0ba6cb; the child advanced **Assigned → Acknowledged** and remains **Not Ready**. The lifecycle writeback changed status/history only. A separate implementation authorization, pre-edit source/provenance/ownership checks and fresh exclusive Simulator reservation remain outstanding; no current Simulator is reserved.

## Entry criteria

### Before `Ready`

- Product Lead responsibility configuration is recorded (satisfied by the current Product instruction).
- Domain Owner, Executor, Architecture Reviewer, Quality Reviewer and Environment Executor have acknowledged the scope and dependencies.
- Exact source baseline and diagnostic patch digest are recorded; Product revalidated the iPhone 18 Pro / iOS 27.0 target on 2026-09-27, and the Human Product Owner confirmed no AI was using simulators before capture.
- Existing diagnostics are inspected first; any new typed marker is justified by a named unresolved boundary and reviewed for privacy and hot-path cost.
- ADR 0027's allowlist is reviewed before changing the event protocol; the existing `input.action` enum is not assumed to be emitted merely because it exists. Reuse current correlation identities and field types; no arbitrary/free-form values.
- The Assignment remains limited to Keyboard Extension UI-owned files. If a required event must be emitted from KeyboardCore or RimeBridge, stop for a separate Assignment or Product Lead reassignment.
- Before the first `Ready` or `Active` transition, add the Policy-required Current Status block with phase, non-claims and next handoff.

### Before simulator capture (after `Active`)

- The diagnostic build, model/runtime, host app, keyboard and Full Access state are verified in the isolated simulator.
- Main App diagnostics are armed; display-category logging and Debug high-fidelity expiration are confirmed before entering the Extension, which is re-entered to refresh lifecycle-bound settings.
- Record writer/generation preflight state and locate the dynamic Extension JSONL segment by process instance, hour and part before interpreting a missing event.
- The Assignment has no `UNKNOWN` required field and entered `Ready` before implementation or environment capture began.

## Exit criteria

**Current parent-only completion addendum (2026-10-04):** [Human-approved Product Decision](../product-decisions/KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001-bounded-completion-product-decision-2026-10-04.md) explicitly revises current completion to the proven owner/schedule boundary and domain handoff, with PEXIT-R1/R2/R3 accepted-unverified. The original strict criteria below remain historical and are not represented as all satisfied. Independent overall Partial and old failure/0read records remain unchanged.

- One successful baseline and one failure/recovery timeline are correlated using existing `appearanceID`, `actionSequence`, process/local sequence, session epoch and revision identities where applicable; do not introduce unreviewed operation IDs or free-form strings.
- The timeline distinguishes, where observable: disappearance/appearance, suspend/resume, owner start/readiness/failure, key action acceptance, engine processing, result publication and UI application.
- Source/build SHA, simulator model/runtime, host app, keyboard configuration, Full Access state, diagnostics configuration and capture time are recorded.
- The Extension JSONL source identity includes its dynamic path, origin, process instance, generation and SHA-256; absence is reported only after arming/writer preflight is proven.
- Diagnostic output contains no private input or host data; artifact identity and evidence hashes are recorded.
- The report uses the Debug Investigator format: Symptom → Reproduction → Observed Timeline → Boundary Evidence → Root Cause Status → Next Diagnostic Step/Owner.
- Independent Architecture and Quality reviews record their conclusions against the exact evidence identity; unresolved causes remain explicitly unknown.
- Findings are handed to Keyboard Experience Maintainer, or to KeyboardCore / RIME Platform Maintainer only if the evidence proves that boundary.

## Stop conditions

- Any required assignee has not acknowledged or is unavailable.
- The designated simulator cannot be exclusively reserved or isolated from an environment used by another task.
- The Product-revalidated iPhone 18 Pro / iOS 27.0 environment is unavailable; any further simulator model/runtime change requires Product Lead revalidation before capture.
- A proposed marker would expose input/user data, synchronously persist on the key path, or materially affect behavior or timing.
- The source baseline differs from the pinned SHA, or an unrelated checkout change would need to be imported or overwritten.
- Evidence points to a product-contract, privacy, data-ownership or architecture change.
- The first correlated timeline proves a boundary and identifies a different owner; stop this diagnostic slice and hand off without implementing a fix.

## Handoff target

First: Keyboard Experience Maintainer, with the exact baseline/build, privacy-reviewed event timeline, evidence hashes, proven boundary, open questions and regression evidence needed. If the boundary is proven to be KeyboardCore or RIME session/bridge, hand off to the corresponding Maintainer without expanding this Assignment.

## Revalidation triggers

- The source baseline, event schema, diagnostic build, simulator runtime/model, host app, keyboard configuration or Full Access state changes.
- Scope expands to a fix, production behavior, RIME deployment, persistent data or physical-device validation.
- A responsibility changes, a reviewer loses independence, or a simulator becomes shared.
- The diagnostic capture no longer represents the same reported failure sequence.

## C7-B3 actual iOS and restoration Hold — 2026-10-02

[C7-B3 iOS delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-validation-2026-10-02.md) records actual three-suite evidence, immutable Architecture R3 Partial/usage, and App Group restoration failure. Original binary111 files restored; data restoration incomplete. No Product/Gate/Closure.

## Environment rebuild bounded Exit — 2026-10-02

[New baseline](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-environment-rebuild-entry-2026-10-02.md) is deployed and Human verified normal Full Access/candidates/commit. Old data loss is not repaired or accepted away. No broader Gate/closure.

## Architecture R4 bounded supplement — 2026-10-02

[R4 delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-arch-r4-validation-2026-10-02.md) resolves only H2 independent embedded-entitlement/xcent byte comparison. Original Partial/usage immutable, no runtime/Gate/parentClose.

## C7 promotion checkpoint — 2026-10-02

[Checkpoint](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-promotion-validation-2026-10-02.md) records bounded independent preparation opinion, current-stage Human residual acceptance, complete fresh backups and installed candidate/readback. Current App launched; keyboard and runtime probe validation pending. No broader closure.

## C7 UI new candidate H1 bounded Exit — 2026-10-02

[H1 delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h1-validation-2026-10-02.md) records new candidate43d85d…/payload78/MachO6, signed paired products and embedded entitlement/xcent exact bytes. No tests/install/runtime or broader Gate.

## C7 UI H2 bounded Exit — 2026-10-02

[H2 delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h2-validation-2026-10-02.md) confirms fresh ordinary Debug/Release paired SDK builds exclude probe UI/export, with H1 dedicated positive control. No tests/install/runtime/Release or independent review acceptance.

## C7 UI Q stopped bounded Exit — 2026-10-02

[Q delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-q-validation-2026-10-02.md) is Partial/incomplete. Architecture substantive A1/A2 matched but hard-exceeded final delivery is not accepted Complete; Quality missing report/usage, interrupted without automatic renewal. No tests/install/runtime or broader Gate.

## Q R2 bounded supplement delivery — 2026-10-03

[R2 delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-q-r2-validation-2026-10-03.md) completes authorized Quality independent delivery and Architecture consistency only. Old R1 artifact Partial/budget history retained; Q overall not automatically accepted.

## Architecture R3 stopped delivery — 2026-10-03

[R3 stop](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-arch-r3-validation-2026-10-03.md) Partial/incomplete: false input-path helper errors and final plist parsing failure, reviewer reports6call limit exhausted; required final report/usage not delivered. No product failure/Gate/runtime claim.

## New reviewer reader-first bounded stop — 2026-10-03

[Delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-reader-new-validation-2026-10-03.md) preserves R0/A1Covered, A2Partial and report mismatch;8call ceiling reached. No automatic renewal, no product failure or Gate/runtime acceptance.

## 2026-10-03 M2-A增量状态

[新实例仅arm交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2-arm-check-validation-2026-10-03.md)：8491单次观测后出口hit0，自身断点cleanup/detach及机器Exit完成，人工视觉Exit待回。未输入/切换/freeze/read，旧M2早期出口与Maps根因仍开放；不扩后续授权。


## 2026-10-03 提前出口记录处置

Human决定旧M2单次提前hit1仅记录，后续再现再讨论；专项追查暂停，历史证据/Incomplete保留，Maps根因仍开放。未授权新设备操作。

## 2026-10-04 M2R1停止与视觉Exit

[停止交付](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r1-session-loss-stop-2026-10-04.md)：Human基线正常，MCP原session丢失后未切换/freeze/read；视觉界面正常且取证/候选保留。cleanup未核验，不冒充完成；Maps根因开放。

## M2R2 owner-boundary independent handoff — 2026-10-04

[Exact-evidence delivery](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-m2r2-reexport-review-validation-2026-10-04.md) records two independent Partial conclusions with local owner/receipt absence covered. Earlier failed capture/0read remains historical, not current absence of all owner evidence. Required parent JSONL/recovery clauses remain unmet; this is an owner handoff, not closure or repair.

## Historical-only Exit mapping and Proposed bounded handoff closure — 2026-10-04

[Mapping](../evidence/keyboard-wake-lifecycle-diagnostics-001-historical-exit-map-2026-10-04.md) verifies existing history without merging candidate/run identities. [Prepared Product proposal](../plans/keyboard-wake-lifecycle-diagnostics-001-bounded-diagnostic-closure-proposal-2026-10-04.md) explicitly requires Human approval of parent-only source/coverage/audit residuals and completion-scope amendment. No closure is currently effective; no new capture/fix or child closure.

## Human-approved bounded diagnostic completion — 2026-10-04

[Completion delivery](../evidence/keyboard-wake-lifecycle-diagnostics-001-bounded-completion-2026-10-04.md) and [Product Decision](../product-decisions/KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001-bounded-completion-product-decision-2026-10-04.md) complete this parent diagnostic delivery only. Active → Completed under the approved addendum; no Reviewed/Closed/overall Gate is asserted and no child or fix authorization is implied.
