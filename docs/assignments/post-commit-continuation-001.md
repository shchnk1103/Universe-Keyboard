# Assignment: POST-COMMIT-CONTINUATION-001 — Ephemeral Post-Commit Continuation V1–V1.2

**Policy version:** `1.0.0`

**Lifecycle status:** `Active`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner instructions authorizing V1, the cautious V1.1 start and continuation into the next V1.2 stage in the active Codex task / `2026-07-15 Asia/Shanghai`
- **Product Approver:** Product Lead acting under the human owner's explicit authorization

## Boundary

- **Scope:** Product contract, ADR, bounded bundled continuation resource, resource validation, synthetic quality benchmark, KeyboardCore state/provider/selection semantics, candidate-bar integration, default-on setting, tests and release documentation. V1.2 may expand the manually authored resource to 250 contexts and the representative benchmark to 60 cases across 15 declared categories without changing runtime or privacy boundaries.
- **Non-goals:** Host context, personal learning, persistence of text, models, network, RIME deployment/session changes, English prediction and unrelated typo-correction work.
- **Required Inputs:** Product contract, ADR 0017, candidate/input architecture, UI style guide, privacy policy, performance baseline and release checklist.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer
- **Executor:** Input Intelligence Maintainer with bounded Keyboard Experience and App & Data Operations work packages
- **Environment Executor:** Quality, Performance & Release Maintainer for automated evidence; human owner for physical-device interactions
- **Human Dependency:** Human owner for final physical-device and product acceptance
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer

## Gates

- **Entry Criteria:** Clean independent branch/worktree; accepted product contract and ADR; no `UNKNOWN`; no synchronous key-path I/O; current dirty main worktree excluded.
- **Exit Criteria:** Contract implemented, automated tests/builds pass, privacy/performance review complete, physical-device gate recorded, documentation updated and independent reviews issued.
- **Stop Conditions:** Raw/host text persistence, network, live RIME-session prediction, unbounded lookup, unrelated user-change overwrite, unexplained latency/memory regression or missing release evidence.

## Handoff

- **Handoff Target:** Architecture and Quality Review, then Product Lead.
- **Required Handoff Content:** Changed behavior, resource contract, automated evidence, device evidence status, performance comparison, privacy review, residual risks and documentation impact.
- **Revalidation Trigger:** Any host-context access, learning/persistence/model addition, resource format or safety-ceiling change, RIME boundary change, default-setting change or branch rebase over conflicting candidate semantics.

## Current Evidence Status

- **Implementation:** V1.0, V1.1 and the bounded V1.2 content and benchmark expansion are complete on the isolated `codex/post-commit-continuation-v1-2` branch.
- **Automated quality:** The complete KeyboardCore suite, app/keyboard Simulator tests and strict Swift 6 Release Simulator build passed for V1.2. The unchanged RimeBridge boundary retains the passing V1.0 branch evidence.
- **Privacy review:** No host-context read, content persistence, logging, synchronization or network path was added; only the enabled preference persists.
- **Simulator behavior:** On the iOS 27.0 iPhone 17 Pro Max Simulator, the App Group was available and `rime_ice` downloaded, passed its basic check and became the active scheme. `chile -> 吃了 -> 吗 -> ？` inserted exactly once per selection; the new V1.2 contexts exposed `早餐 -> 吃了吗` and `下雨 -> 了`; host Delete cleared committed text and continuation state. This is Simulator behavior evidence, not physical-device or population-quality evidence.
- **Open human gate:** Physical-device behavior, latency and memory comparison. This prevents Assignment closure but does not invalidate the automated or Simulator implementation evidence.

## V1.1 Revalidation Record

- V1.1 keeps the accepted privacy, state-machine, RIME and candidate-presentation boundaries unchanged.
- The content pack changes under a new declared content version and adds fail-closed size/structure limits.
- The benchmark contains only synthetic fixture metadata and expectations; it does not collect execution telemetry or user text.
- Architecture and Quality review of the final V1.1 diff remains required before Assignment closure.

## V1.2 Revalidation Record

- The human owner explicitly authorized entering the next stage on `2026-07-15 Asia/Shanghai`; no required Assignment field is `UNKNOWN`.
- V1.2 keeps the accepted state-machine, candidate-bar, RIME, privacy and resource safety ceilings unchanged.
- The content pack may grow only through manually authored synthetic entries with deterministic ordering and documented review rules.
- The expanded benchmark remains regression evidence for registered cases only and must not be described as real-user coverage, acceptance rate or corpus-frequency evidence.
- The final V1.2 snapshot contains exactly 250 unique contexts and a 60-case benchmark spanning 15 declared categories; automated suites, strict Release build and representative `rime_ice` Simulator behavior passed.
- Any host context, telemetry, downloaded corpus, learning, persistence, model or network proposal remains a Stop Condition requiring a new Product Decision.
