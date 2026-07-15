# Assignment: POST-COMMIT-CONTINUATION-001 — Ephemeral Post-Commit Continuation V1/V1.1

**Policy version:** `1.0.0`

**Lifecycle status:** `Active`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner instructions authorizing V1 and the cautious V1.1 start in the active Codex task / `2026-07-15 Asia/Shanghai`
- **Product Approver:** Product Lead acting under the human owner's explicit authorization

## Boundary

- **Scope:** Product contract, ADR, bounded bundled continuation resource, resource validation, synthetic quality benchmark, KeyboardCore state/provider/selection semantics, candidate-bar integration, default-on setting, tests and release documentation.
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

- **Implementation:** V1.0 is complete; the V1.1 bounded resource validation, synthetic benchmark and first curated expansion are implemented on the same isolated feature branch.
- **Automated quality:** The complete KeyboardCore suite, app/keyboard Simulator tests and strict Release Simulator build passed for V1.1. The unchanged RimeBridge boundary retains the passing V1.0 branch evidence.
- **Privacy review:** No host-context read, content persistence, logging, synchronization or network path was added; only the enabled preference persists.
- **Open human gate:** Physical-device behavior, latency and memory comparison. This prevents Assignment closure but does not invalidate the automated implementation evidence.

## V1.1 Revalidation Record

- V1.1 keeps the accepted privacy, state-machine, RIME and candidate-presentation boundaries unchanged.
- The content pack changes under a new declared content version and adds fail-closed size/structure limits.
- The benchmark contains only synthetic fixture metadata and expectations; it does not collect execution telemetry or user text.
- Architecture and Quality review of the final V1.1 diff remains required before Assignment closure.
