# POST-COMMIT-CONTINUATION-001 V1.3 Naturalness Refinement Plan

> **Status:** Active
>
> **Current stage:** Executor work complete; independent review and closure synchronization pending
>
> **Start date:** `2026-07-15 Asia/Shanghai`
>
> **Authority:** Human Product Owner instruction to continue V1.3 and preserve learned Simulator setup order
>
> **Implementation branch:** `codex/post-commit-continuation-v1-3` (merged through PR #13)
>
> **Integrated implementation:** `eaa72d5207deacab1dc0b94024c67af96448ad19`

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

## Gate 6 — Physical Device And Paired Performance

- [x] Confirm the physical device, exact OS build, wired pairing, Developer Mode, system keyboard registration and Full Access before testing.
- [x] Install the normally signed Release build from the integrated V1.3 commit and keep the Messages draft unsent.
- [x] Record human Product acceptance of the physical-device candidate behavior separately from automated evidence.
- [x] Compare the same controlled `chile -> 吃了` final-commit sequence with post-commit continuation disabled and enabled.
- [x] Capture paired Activity Monitor and Time Profiler traces for repeated final commits, candidate refresh, CPU, memory and 250-ms hang rows.
- [x] Terminate the Extension process and capture paired disabled/enabled cold-process Activity Monitor runs followed by a real RIME commit.
- [x] Restore the user's enabled setting and clear the Messages draft after testing.

Recorded on `2026-07-16 Asia/Shanghai` against Release commit `eaa72d5` on a physical iPhone 13 Pro (`iPhone14,2`) running iOS 27.0 beta 3 (`24A5380h`). The paired steady-state runs observed 792/787 one-millisecond Time Profiler samples for enabled/disabled, 751.4/719.3 ms Activity Monitor CPU time, 23.67/24.36 MiB median physical footprint and zero 250-ms potential hangs in both states. Cold-process first-five-second CPU and memory were comparable, and both states completed a real RIME commit. Exact method, limitations, metrics and raw-bundle integrity summaries are in the [physical-device acceptance record](../evidence/post-commit-continuation-v1.3-physical-device-2026-07-16.md). These values are a dated snapshot, not a permanent budget.

## Gate 7 — Independent Review And Closure

- [ ] Obtain an independent Quality/Architecture review of the merged implementation and the physical-device evidence package.
- [ ] Advance the Assignment from `Completed` to `Reviewed` only after review conclusions are recorded.
- [ ] After Product/Quality closure and repository integration, mark the Assignment `Closed`, archive this plan with the required closure metadata and synchronize the Engineering Dashboard.

PR #13 was merged and its Swift 6 Quality and GitGuardian checks passed, but GitHub reports no submitted review and no review decision. CI success and merge state do not satisfy this Gate. Until an independent review is recorded, this plan remains `Active` and remains current only for closure coordination.

## Stop Conditions

- Any need to read host surrounding text, persist/log committed text or collect user selections.
- Any downloaded corpus, learned ranker, network path, model or RIME deployment/session implementation change.
- Resource growth above 250 contexts or any accepted safety-ceiling change without a new Product and performance decision.
- Starting behavior testing before the ordered Simulator preflight is complete.
- Missing App Group, inactive/unhealthy `rime_ice`, unavailable system keyboard entry or unexplained automated regression.
