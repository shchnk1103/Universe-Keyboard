# RELEASE-2026-0801-02 Scope Freeze — Independent Review Handoff

> **Handoff status:** Awaiting independent Architecture and Quality conclusions
>
> **Source Assignment:** [`RELEASE-2026-0801-02`](release-2026-08-01-02-scope-freeze.md)
>
> **Scope under review:** Product scope record only; no implementation, archive, device evidence or release decision is supplied by this handoff.

## Frozen Inputs

- Product Lead decision source: active Codex task, `2026-07-20 Asia/Shanghai`.
- Included launch claims: iPhone + iPad; iOS 26.0+; existing baseline input, Chinese nine-key, precise-pinyin selection, post-commit continuation and kaomoji content.
- Excluded launch claims: Typing Intelligence and contextual typo correction.
- New child closure paths: [`07 iPad support`](release-2026-08-01-07-ipad-support.md) and [`08 kaomoji content`](release-2026-08-01-08-kaomoji-content.md).
- Current project fact: every current deployment-target entry is iOS 26.4; the iOS 26.0 decision has not been implemented.

## Architecture Review Request

The Architecture & Knowledge Steward independently determines whether the scope record is compatible with current accepted contracts and identifies the smallest required implementation/decision boundaries for:

1. Lowering the deployment target from iOS 26.4 to iOS 26.0, including API availability, all affected targets/tests and the stable-toolchain/archive dependency.
2. Treating iPad as supported while preserving the established keyboard geometry, input lifecycle, RIME deployment boundary, Full Access boundary and target-family contract.
3. Delivering kaomoji as an offline bounded catalog without creating a new persistence, network, synchronization, user-data or cross-target contract.
4. Ensuring excluded Typing Intelligence and contextual typo correction cannot be accidentally represented as V1.0 product scope.

**Required output:** `Pass`, `Pass with required follow-ups`, `Fail`, or `Blocked`; source links; conflicts/required amendments; named owner for every required follow-up. A passing Architecture conclusion does not authorize implementation, archive creation or release.

## Quality Review Request

The Quality, Performance & Release Maintainer independently determines whether the frozen scope has an executable release-validation matrix and whether it truthfully separates scope from evidence:

1. iPhone and iPad physical-device, appearance, accessibility, orientation, Full Access on/off, host and performance matrix implications.
2. iOS 26.0 validation requirements after a separately assigned target change and before any App Store support claim.
3. Kaomoji interaction, insertion, catalog provenance/license and supported-device acceptance requirements.
4. The requirement that task 04, task 05 and the exact final archive—not current simulator or historical evidence—close release evidence.

**Required output:** `Pass`, `Pass with required follow-ups`, `Fail`, or `Blocked`; required evidence rows; failed/skipped-gate owner; expiry/revalidation trigger. A passing Quality conclusion does not constitute Product Gate, submission authorization or manual-release authorization.

## Handoff Boundaries

- Reviewers must preserve the completed Executor deliverable and write their own independent conclusion; they do not convert it to `Reviewed` or `Closed` without recording their conclusion and the Product Lead's subsequent Gate decision.
- No reviewer may implement the iOS target change, iPad support or kaomoji content through this review handoff.
- No App Store screenshot, copy, archive or device observation may claim iPad, iOS 26.0 or kaomoji readiness until the relevant child task and final-release evidence close.
