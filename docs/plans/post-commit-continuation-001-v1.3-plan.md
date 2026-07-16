# POST-COMMIT-CONTINUATION-001 V1.3 Naturalness Refinement Plan

> **Status:** Active
>
> **Current stage:** Implementation and Simulator validation complete; physical-device acceptance pending
>
> **Start date:** `2026-07-15 Asia/Shanghai`
>
> **Authority:** Human Product Owner instruction to continue V1.3 and preserve learned Simulator setup order
>
> **Branch:** `codex/post-commit-continuation-v1-3`
>
> **Baseline:** `49e4946` (`feat: post-commit continuation suggestions (V1 → V1.2)`)

## Objective

Improve the first visible continuation and suppress noisy high-ambiguity matches without growing the V1.2 inventory or changing the deterministic, on-device runtime architecture.

## Gate 0 — Preserve Accepted Boundaries

- [x] Start from the clean, integrated and published V1.2 baseline on a new branch.
- [x] Revalidate the Assignment against the current human authorization with no `UNKNOWN` fields.
- [x] Keep host context, persistence, learning, telemetry, downloaded corpora, network, models, RIME runtime and candidate UI changes out of V1.3.

## Gate 1 — Naturalness And Suppression

- [x] Keep exactly 250 unique manually authored synthetic contexts.
- [x] Replace eight single-character, high-ambiguity suffixes with eight specific multi-character contexts drawn from reviewed synthetic cases.
- [x] Correct reviewed cases where longest-suffix matching currently exposes an awkward first continuation.
- [x] Keep deterministic resource ordering and all V1.1 fail-closed ceilings unchanged.

## Gate 2 — Stronger Quality Evidence

- [x] Preserve the existing registered Top-3 representative baseline across all 15 categories.
- [x] Add one reviewed exact Top-1 naturalness guard per category.
- [x] Add suppression cases proving retired ambiguous single-character suffixes no longer fabricate recommendations.
- [x] Continue to describe every fixture as synthetic regression evidence, never real-user coverage or acceptance-rate evidence.

## Gate 3 — Automated Verification

- [x] Validate JSON, content version, inventory, uniqueness, bounds and duplicate constraints.
- [x] Run focused continuation tests and the complete KeyboardCore suite.
- [x] Run app/keyboard Simulator tests and strict Swift 6 Release Simulator build.
- [x] Review repository diff hygiene and documentation impact.

## Gate 4 — Simulator Preflight Before Behavior Testing

The following order is mandatory. A failure stops behavior testing until the environment is repaired.

- [x] Confirm the intended Simulator is booted and record its current model, OS and UDID.
- [x] Build, install and launch with normal Simulator signing. Never use a `CODE_SIGNING_ALLOWED=NO` artifact for App Group or RIME runtime evidence.
- [x] Confirm `simctl get_app_container <UDID> com.DoubleShy0N.Universe-Keyboard groups` returns the expected App Group container.
- [x] In the main App, confirm `rime_ice` is installed, its basic check passes and it is the active scheme; install/deploy/select it before continuing when any condition is false.
- [x] Confirm Universe Keyboard is present in the system keyboard list, apply the repository keyboard baseline if needed, then prove it can be selected with the globe key in the host app.
- [x] Only after all prior checks, run synthetic continuation chains and deletion/invalidation checks without sending host messages.

Recorded on `2026-07-16 Asia/Shanghai`: iPhone 17 Pro Max, iOS 27.0, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`. The normally signed runtime exposed the expected App Group; the main App showed `rime_ice` as installed, current and passing its basic check; the repository keyboard baseline made Universe Keyboard selectable in Messages. `吃了 -> 吗 -> ？` and `我在地铁 -> 上` committed exactly once per selection, while the single-character `我` case exposed no continuation. The Messages draft was cleared and no message was sent.

## Gate 5 — Handoff

- [x] Update product, quality, debugging, release and history documents with exact evidence and non-claims.
- [x] Record physical-device/performance gates as open unless new comparable evidence is collected.
- [x] Commit the bounded V1.3 stage locally without pushing.

## Stop Conditions

- Any need to read host surrounding text, persist/log committed text or collect user selections.
- Any downloaded corpus, learned ranker, network path, model or RIME deployment/session implementation change.
- Resource growth above 250 contexts or any accepted safety-ceiling change without a new Product and performance decision.
- Starting behavior testing before the ordered Simulator preflight is complete.
- Missing App Group, inactive/unhealthy `rime_ice`, unavailable system keyboard entry or unexplained automated regression.
