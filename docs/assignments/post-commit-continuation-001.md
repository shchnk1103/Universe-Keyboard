# Assignment: POST-COMMIT-CONTINUATION-001 — Ephemeral Post-Commit Continuation V1–V1.3

**Policy version:** `1.0.0`

**Lifecycle status:** `Completed`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner instructions authorizing V1, the cautious V1.1 start, V1.2 expansion and continuation into V1.3 with explicit Simulator preflight requirements in the active Codex task / `2026-07-15 Asia/Shanghai`; physical-device behavior acceptance and authorization to complete paired performance verification / `2026-07-16 Asia/Shanghai`
- **Product Approver:** Product Lead acting under the human owner's explicit authorization

## Boundary

- **Scope:** Product contract, ADR, bounded bundled continuation resource, resource validation, synthetic quality benchmark, KeyboardCore state/provider/selection semantics, candidate-bar integration, default-on setting, tests and release documentation. V1.3 may replace ambiguous synthetic entries, strengthen reviewed Top-1 naturalness and suppression fixtures, and codify Simulator preflight without increasing the 250-context inventory or changing runtime and privacy boundaries.
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

- **Implementation:** V1.0 through V1.3 are integrated into `origin/main` at merge commit `eaa72d5207deacab1dc0b94024c67af96448ad19` through PR #13.
- **Automated quality:** V1.3 resource validation, focused and complete KeyboardCore tests, app/keyboard Simulator tests and strict Swift 6 Release Simulator build passed. The unchanged RimeBridge boundary retains the passing V1.0 branch evidence.
- **Privacy review:** No host-context read, content persistence, logging, synchronization or network path was added; only the enabled preference persists.
- **Simulator behavior:** On `2026-07-16`, the booted iOS 27.0 iPhone 17 Pro Max Simulator (`06C5BC3E-7599-4761-A1A2-71DAEA991474`) passed the ordered V1.3 preflight: normal signing, App Group availability, installed/current/basic-check-passed `rime_ice`, system keyboard registration and globe-key switching. In Messages, `chile -> 吃了 -> 吗 -> ？` and `wozaiditie -> 我在地铁 -> 上` inserted exactly once per selection; committing the single character `我` exposed no continuation, and Delete cleared state. The draft was cleared and no message was sent. This is Simulator behavior evidence, not physical-device, performance or population-quality evidence.
- **Physical-device behavior:** The human owner accepted candidate behavior on a physical iPhone 13 Pro running iOS 27.0 beta 3. The instrumented Release run then reconfirmed `chile -> 吃了`, the enabled V1.3 continuation sequence, disabled-state suppression, cold-process recovery, repeated commits and draft cleanup without sending a message.
- **Performance review package:** The paired physical-device snapshot records disabled/enabled cold start, repeated final commit, candidate refresh, CPU samples, physical footprint and 250-ms hang rows with no unexplained feature regression. Exact environment, metrics, limitations, local trace locations and integrity summaries are in the [V1.3 physical-device acceptance record](../evidence/post-commit-continuation-v1.3-physical-device-2026-07-16.md).
- **Review state:** The independent Quality, Performance & Release and Architecture & Knowledge reviews passed on `2026-07-16`; their scope, recomputed trace values, boundary findings and limitations are in the [independent review record](../evidence/post-commit-continuation-v1.3-independent-review-2026-07-16.md). The Product Gate remains pending, so this Assignment stays `Completed` rather than advancing to `Reviewed` or `Closed`.

## Completion Handoff

- **Executor conclusion:** `Completed` — implementation, automated verification, Simulator behavior, physical-device behavior and paired performance evidence are delivered.
- **Quality conclusion:** `Passed` — six retained bundles, the reported CPU/memory/sample/hang values, cold-process data, exclusions and SHA-256 summaries were independently reproduced; the conclusion remains a bounded snapshot.
- **Architecture conclusion:** `Passed` — the implementation remains within [`0017-ephemeral-post-commit-continuation.md`](../architecture/decisions/0017-ephemeral-post-commit-continuation.md), with no host-context, persistence, network or RIME-boundary expansion.
- **Product handoff:** The human owner has accepted physical candidate behavior. An explicit Product Gate conclusion is the remaining condition before lifecycle closure; see the independent review record.
- **Closure rule:** Do not mark this Assignment `Reviewed` or `Closed`, and do not archive the V1.3 plan, merely because this evidence branch is pushed or its PR exists.

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

## V1.3 Revalidation Record

- The human owner explicitly authorized V1.3 on `2026-07-15 Asia/Shanghai` and required the known Simulator setup failures to become ordered preconditions rather than ad-hoc troubleshooting; no Assignment field is `UNKNOWN`.
- V1.3 keeps the accepted state machine, candidate UI, resource ceilings, RIME boundary and privacy contract unchanged. It does not increase the 250-context inventory.
- Quality work is limited to replacing high-ambiguity synthetic suffixes, correcting reviewed ranking naturalness and strengthening test-only Top-1 and suppression fixtures.
- Simulator behavior testing must stop before typing unless the selected device is confirmed, a normal signed Simulator build exposes the App Group, `rime_ice` is installed/basic-check-passed/current, and Universe Keyboard is enabled and switchable in the system keyboard list.
- `CODE_SIGNING_ALLOWED=NO` remains valid for compile/test evidence but must not be used for the app installation that supplies runtime App Group or RIME deployment evidence.
