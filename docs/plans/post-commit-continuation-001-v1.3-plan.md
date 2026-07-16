# POST-COMMIT-CONTINUATION-001 V1.3 Naturalness Refinement Plan

> **Status:** Active
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

- [ ] Keep exactly 250 unique manually authored synthetic contexts.
- [ ] Replace eight single-character, high-ambiguity suffixes with eight specific multi-character contexts drawn from reviewed synthetic cases.
- [ ] Correct reviewed cases where longest-suffix matching currently exposes an awkward first continuation.
- [ ] Keep deterministic resource ordering and all V1.1 fail-closed ceilings unchanged.

## Gate 2 — Stronger Quality Evidence

- [ ] Preserve the existing registered Top-3 representative baseline across all 15 categories.
- [ ] Add one reviewed exact Top-1 naturalness guard per category.
- [ ] Add suppression cases proving retired ambiguous single-character suffixes no longer fabricate recommendations.
- [ ] Continue to describe every fixture as synthetic regression evidence, never real-user coverage or acceptance-rate evidence.

## Gate 3 — Automated Verification

- [ ] Validate JSON, content version, inventory, uniqueness, bounds and duplicate constraints.
- [ ] Run focused continuation tests and the complete KeyboardCore suite.
- [ ] Run app/keyboard Simulator tests and strict Swift 6 Release Simulator build.
- [ ] Review repository diff hygiene and documentation impact.

## Gate 4 — Simulator Preflight Before Behavior Testing

The following order is mandatory. A failure stops behavior testing until the environment is repaired.

- [ ] Confirm the intended Simulator is booted and record its current model, OS and UDID.
- [ ] Build, install and launch with normal Simulator signing. Never use a `CODE_SIGNING_ALLOWED=NO` artifact for App Group or RIME runtime evidence.
- [ ] Confirm `simctl get_app_container <UDID> com.DoubleShy0N.Universe-Keyboard groups` returns the expected App Group container.
- [ ] In the main App, confirm `rime_ice` is installed, its basic check passes and it is the active scheme; install/deploy/select it before continuing when any condition is false.
- [ ] Confirm Universe Keyboard is present in the system keyboard list, apply the repository keyboard baseline if needed, then prove it can be selected with the globe key in the host app.
- [ ] Only after all prior checks, run synthetic continuation chains and deletion/invalidation checks without sending host messages.

## Gate 5 — Handoff

- [ ] Update product, quality, debugging, release and history documents with exact evidence and non-claims.
- [ ] Record physical-device/performance gates as open unless new comparable evidence is collected.
- [ ] Commit the bounded V1.3 stage locally without pushing.

## Stop Conditions

- Any need to read host surrounding text, persist/log committed text or collect user selections.
- Any downloaded corpus, learned ranker, network path, model or RIME deployment/session implementation change.
- Resource growth above 250 contexts or any accepted safety-ceiling change without a new Product and performance decision.
- Starting behavior testing before the ordered Simulator preflight is complete.
- Missing App Group, inactive/unhealthy `rime_ice`, unavailable system keyboard entry or unexplained automated regression.
