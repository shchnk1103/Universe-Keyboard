# Assignment: TYPING-INTELLIGENCE-001 — Local Typing Intelligence Foundation

**Policy version:** `1.0.0`

**Decision source / date:** Human Product Owner authorization in the active Typing Intelligence objective and KOS 2.0 role delegation / `2026-07-11 Asia/Shanghai`

**Lifecycle status:** `Active`

**Repository change types:** `Contract`, `Implementation`, `Evidence`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Product Approver:** Product Lead acting under the human owner's explicit role delegation
- **Assignment Revalidation Authority:** Product Lead
- **Product Contract:** [`docs/TYPING_INTELLIGENCE.md`](../TYPING_INTELLIGENCE.md)

This Assignment does not change permanent role ownership. Each role acts only within the authority defined by KOS 2.0 and `VIRTUAL_ENGINEERING_TEAM.md`.

## Acknowledgement And Activation

- **Executor acknowledgement:** `2026-07-11 Asia/Shanghai` — Scope, Non-goals, Stop Conditions and cross-domain handoffs accepted.
- **Architecture acknowledgement:** ADR 0011 accepted with implementation pending before cross-target implementation began.
- **Quality acknowledgement:** Verification Matrix accepted as the required evidence scope; no Quality conclusion has been issued.
- **Product lifecycle decision:** `Ready -> Active`, 2026-07-11 Asia/Shanghai.
- **Current phase:** Automated implementation validation complete; physical-device and complete accessibility/appearance release gates remain open.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer
- **Executor:** Input Intelligence Maintainer, coordinating bounded work packages across named supporting domains
- **Environment Executor:** Quality, Performance & Release Maintainer for Simulator/build evidence; Keyboard Experience Maintainer with the human owner for required physical-device interactions
- **Human Dependency:** Human owner for physical-device keyboard enablement, Full Access toggling and final product acceptance only; not required for contract, implementation or automated verification phases
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** Product Lead for Product Review, followed by Program Manager for owner-confirmed status synchronization

## Objective

Deliver an enterprise-quality, privacy-first Typing Intelligence feature with:

- exact final-commit statistics;
- bounded, non-blocking Extension persistence;
- robust App Group ownership and recovery;
- a polished native main-App experience;
- explicit Full Access and lifecycle behavior;
- extensible versioned data contracts;
- measurable performance and release evidence;
- complete isolation from the frozen NE1 evidence chain.

## Scope

1. Publish and maintain the Typing Intelligence Product Contract.
2. Publish and implement ADR 0011.
3. Add a UI-independent committed-text observation contract in KeyboardCore.
4. Emit one event for each final committed text operation and no event for unfinished composition.
5. Include direct text and Emoji paths without changing candidate generation or RIME semantics.
6. Classify committed text ephemerally into approved aggregate categories.
7. Add bounded, asynchronous App Group statistics persistence owned by the Extension runtime.
8. Add versioning, retention, reset epoch, corruption recovery and deterministic migration behavior.
9. Add main-App read, enable/disable, clear and presentation flows.
10. Add polished statistics UI following the repository style guide.
11. Add focused unit, integration, UI, privacy and performance tests.
12. Add current privacy manifests and App Store privacy documentation required by the APIs actually used.
13. Add debugging, performance and release acceptance paths.
14. Preserve NE1 protocol, evidence, metadata and historical baseline without modification.

## Non-goals

- No RIME Bridge, session, deployment, Lua or OpenCC modification.
- No candidate generation, merge, ranking or selection-policy modification.
- No keyboard visibility, presentation or composition lifecycle redesign.
- No raw text, word, phrase, n-gram, host context or per-event persistence.
- No network upload, cloud sync, analytics SDK or tracking.
- No user profiling, sensitive-content inference or host-App identification.
- No claim that App Store approval is guaranteed.
- No reopening, rewriting or completing NE1 as a side effect.
- No unrelated refactor or cleanup of the existing dirty worktree.

## Required Inputs

- `docs/TYPING_INTELLIGENCE.md`
- ADR 0003 and ADR 0007
- ADR 0011
- `docs/PROJECT_CONTEXT.md`
- `docs/architecture/input-pipeline-and-marked-text.md`
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/UI_STYLE_GUIDE.md`
- `docs/PERFORMANCE_BASELINE.md`
- `docs/DEBUGGING.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/DOCUMENTATION_GOVERNANCE.md`
- current source and tests for KeyboardController, Extension bootstrap/input actions, App Group stores and Settings UI
- current Apple keyboard-extension, App Review, App Privacy and privacy-manifest requirements before release
- a cleanly separable file boundary from unrelated NE1/UI-test worktree changes

## Entry Criteria

- Product Contract is accepted.
- Assignment contains no `UNKNOWN` field.
- Executor acknowledges Scope, Non-goals and Stop Conditions.
- ADR 0011 is accepted before implementation crosses target or data boundaries.
- Existing RIME, candidate and lifecycle contracts remain unchanged.
- Storage design is bounded and has no synchronous key-path persistence.
- Prohibited data is testable as a negative contract.
- Work can avoid unrelated dirty files.
- Quality verification matrix is defined in this Assignment and the Active plan.

The Product Lead confirms these criteria are satisfied for the contract and implementation-entry phase. Physical-device evidence remains an Exit Criterion, not an implementation-entry dependency.

## Work Packages And Owners

| Work package | Responsible role | Required handoff |
|---|---|---|
| Product/data semantics | Product Lead | Frozen Product Contract |
| Commit event and classification | Input Intelligence Maintainer | Protocol, invariants and KeyboardCore tests |
| Extension wiring and lifecycle-safe writer | Keyboard Experience Maintainer | Non-blocking integration and device scenarios |
| App Group store and main-App data operations | App & Data Operations Maintainer | Ownership, migration, reset and recovery evidence |
| Main-App statistics UI | App & Data Operations Maintainer | Rendered states and accessibility evidence |
| Cross-target/data architecture | Architecture & Knowledge Steward | ADR and architecture review |
| Performance, privacy and release | Quality, Performance & Release Maintainer | Independent evidence and Gate conclusion |
| Program status | Program Manager | Source-linked Dashboard synchronization only |

## Quality Verification Matrix

- KeyboardCore unit tests for classification and exactly-once commit observation.
- Negative tests proving marked/preedit updates and abandoned composition do not count.
- Tests for candidate, Space, Return, direct text, double-space replacement, Partial Commit and Emoji paths.
- Store tests for retention, versioning, reset epoch, corruption, disable/enable and bounded size.
- Concurrency tests for queued writes racing with clear/reset.
- Main-App model tests for empty, active, disabled, unavailable and corrupted states.
- SwiftUI/UI tests or deterministic previews for all principal visual states.
- Debug and Release builds with Swift 6 warnings treated as errors.
- Privacy scan for prohibited payload fields and logging.
- Before/after key-path and memory evidence using controlled synthetic input.
- Physical-device Full Access on/off, process death, host switching and sustained typing acceptance.
- NE1 file/diff audit proving no baseline contamination.

## Exit Criteria

TYPING-INTELLIGENCE-001 may become `Completed` only when:

- Product Contract and ADR are implemented without scope drift;
- all approved commit paths are counted exactly once;
- prohibited data never reaches persistence, logs or network code;
- collection is disabled by default and user-controlled;
- clear is permanent across queued-write races and process restart;
- storage remains bounded and recoverable;
- typing remains functional when statistics or App Group access fails;
- main-App UI is complete, accessible and visually verified;
- automated tests and required builds pass;
- physical-device acceptance is recorded or explicitly remains an unresolved release blocker;
- performance evidence shows no unexplained regression;
- privacy manifest and privacy-policy impacts are reviewed against current implementation;
- documentation, debugging, release and changelog impacts are complete;
- NE1 evidence remains untouched and traceable;
- Architecture Review and Quality Review have explicit conclusions;
- Product Lead performs final Product Review.

`Completed` does not imply `Reviewed`, `Accepted` or `Closed`.

## Stop Conditions

Stop the affected work package and route to its authority if:

- implementation requires storing raw or reconstructable input;
- a requested insight cannot be produced from approved aggregates;
- synchronous file/database/defaults work is required in the key path;
- RIME, candidate generation or visibility lifecycle behavior would need to change;
- Full Access absence would break basic typing;
- a migration could restore data after user deletion;
- a third-party SDK or network path would receive keyboard-derived data;
- SwiftData or another store cannot prove safe cross-process ownership and recovery;
- unrelated NE1 or user changes would need to be overwritten;
- current Apple requirements contradict the accepted privacy contract;
- required physical-device or release evidence is unavailable at the final Gate.

## Handoff

Required handoff content:

- implemented behavior and data-schema version;
- changed-file inventory by work package;
- automated command results;
- visual and accessibility evidence;
- performance comparison and environment metadata;
- Full Access and physical-device evidence;
- privacy manifest and App Privacy assessment;
- residual risks, skipped gates and owner;
- NE1 non-contamination evidence;
- documentation-impact review.

## Revalidation Trigger

Product Lead revalidation is required for any change to persisted data categories, default enablement, retention, deletion, upload/network behavior, Full Access semantics, Product acceptance, Domain Owner, Executor, reviewers or NE1 isolation. Architecture revalidation is required for any change to commit collection, cross-target ownership, storage technology or lifecycle boundary.
