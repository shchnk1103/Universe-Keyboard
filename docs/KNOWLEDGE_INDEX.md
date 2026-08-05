# Universe Keyboard Knowledge Index

> Open this after `AGENTS.md` at the start of every new Codex thread. This file is navigation only.

## Start By Intent

- Task-specific implementation or investigation: [`READING_MAPS.md`](READING_MAPS.md)
- New contributor learning: [`ONBOARDING.md`](ONBOARDING.md)
- Unfamiliar term: [`GLOSSARY.md`](GLOSSARY.md)
- Documentation change: [`DOCUMENTATION_GOVERNANCE.md`](DOCUMENTATION_GOVERNANCE.md)
- Change impact: [`KNOWLEDGE_DEPENDENCIES.md`](KNOWLEDGE_DEPENDENCIES.md)
- Change classification: [`DECISION_TREES.md`](DECISION_TREES.md)

## Current System

- Architecture overview: [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md)
- Shared container and RIME lifecycle: [`architecture/shared-container-and-rime-lifecycle.md`](architecture/shared-container-and-rime-lifecycle.md)
- Input pipeline and marked text: [`architecture/input-pipeline-and-marked-text.md`](architecture/input-pipeline-and-marked-text.md)
- OpenCC integration: [`architecture/opencc-integration.md`](architecture/opencc-integration.md)
- Swift 6 ownership: [`architecture/swift6-migration.md`](architecture/swift6-migration.md)
- RIME artifacts: [`architecture/rime-artifacts.md`](architecture/rime-artifacts.md)
- Partial Commit: [`architecture/partial-commit.md`](architecture/partial-commit.md)
- UI rules: [`UI_STYLE_GUIDE.md`](UI_STYLE_GUIDE.md)

## Decisions

- ADR directory: [`architecture/decisions/`](architecture/decisions/)
- Architecture evolution: [`ARCHITECTURE_TIMELINE.md`](ARCHITECTURE_TIMELINE.md)

## Domain Sources

- Typing Intelligence: [`TYPING_INTELLIGENCE.md`](TYPING_INTELLIGENCE.md)
- Post-commit continuation: [`POST_COMMIT_CONTINUATION.md`](POST_COMMIT_CONTINUATION.md)
- Post-commit continuation synthetic quality and content review: [`POST_COMMIT_CONTINUATION_QUALITY.md`](POST_COMMIT_CONTINUATION_QUALITY.md)
- Scheme management: [`RIME_SCHEME_MANAGEMENT.md`](RIME_SCHEME_MANAGEMENT.md)
- Keyboard layout (26-key / Chinese nine-key runtime + chrome): [`KEYBOARD_LAYOUT.md`](KEYBOARD_LAYOUT.md)
- Nine-key chrome Assignment (closed): [`assignments/keyboard-layout-9key-ui-001.md`](assignments/keyboard-layout-9key-ui-001.md)
- Nine-key precise pinyin selection (`Accepted / Closed`; PR [#20](https://github.com/shchnk1103/Universe-Keyboard/pull/20) merged): [`assignments/keyboard-layout-9key-pinyin-001.md`](assignments/keyboard-layout-9key-pinyin-001.md), ADR [`0020`](architecture/decisions/0020-t9-precise-pinyin-path-selection.md), Product Gate [`assignments/keyboard-layout-9key-pinyin-001-product-gate-pass.md`](assignments/keyboard-layout-9key-pinyin-001-product-gate-pass.md)
- Nine-key deterministic choices + segmented/progressive paths + safe remaining/Delete (`Active — Amendment D local implementation validated; review/Product Gate pending`): [`assignments/keyboard-layout-9key-pinyin-002.md`](assignments/keyboard-layout-9key-pinyin-002.md), Product Decision [`PD-...-002`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md), ADR [`0021`](architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md), segmented Spike [`summary`](assignments/keyboard-layout-9key-pinyin-002-segmented-spike-summary.md)
- Nine-key atomic Path presentation + fixed foreground discovery (`Active — Automated Quality Pass; Human Product Gate failed; superseded by 004`): [`assignments/keyboard-layout-9key-pinyin-003.md`](assignments/keyboard-layout-9key-pinyin-003.md), Product Decision [`PD-...-003`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-003-authorization.md), ADR [`0022`](architecture/decisions/0022-t9-atomic-presentation-and-bounded-path-discovery.md), Stage A [`evidence`](assignments/keyboard-layout-9key-pinyin-003-stage-a-evidence.md)
- Nine-key complete local Path catalog + atomic sync (`Accepted / Closed` · `2026-07-23`): [`assignments/keyboard-layout-9key-pinyin-004.md`](assignments/keyboard-layout-9key-pinyin-004.md), close [`PD-…-004-ASSIGNMENT-CLOSE`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-assignment-close.md), Product Decision [`PD-...-004`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md), residual-B [`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md), ADR [`0023`](architecture/decisions/0023-t9-complete-local-path-catalog-and-atomic-presentation.md), catalog provenance [`t9-pinyin-syllable-catalog.md`](architecture/t9-pinyin-syllable-catalog.md), plan [`004 plan`](plans/keyboard-layout-9key-pinyin-004-complete-path-catalog-and-atomic-sync-plan.md), Gate5 plan [`gate5 plan`](plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md), evidence [`004 evidence`](assignments/keyboard-layout-9key-pinyin-004-implementation-evidence.md), Gate5 evidence [`gate5 evidence`](assignments/keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md) §21–§33, PR [#27](https://github.com/shchnk1103/Universe-Keyboard/pull/27) · [#28](https://github.com/shchnk1103/Universe-Keyboard/pull/28) · [#29](https://github.com/shchnk1103/Universe-Keyboard/pull/29)
- Fuzzy pinyin: [`RIME_FUZZY_PINYIN.md`](RIME_FUZZY_PINYIN.md)
- User dictionary: [`RIME_USER_DICTIONARY.md`](RIME_USER_DICTIONARY.md)
- Portable RIME settings sync: [`RIME_SYNC.md`](RIME_SYNC.md)
- App notifications and operation prompts: [`APP_NOTIFICATIONS.md`](APP_NOTIFICATIONS.md)
- Typo correction benchmark: [`TYPO_BENCHMARK.md`](TYPO_BENCHMARK.md)
- Typo correction Contract/Case/Performance Registry: [`TYPO_BENCHMARK_REGISTRY.md`](TYPO_BENCHMARK_REGISTRY.md)
- Typo correction V2 incremental Registry: [`TYPO_BENCHMARK_REGISTRY_V2.md`](TYPO_BENCHMARK_REGISTRY_V2.md)
- Contextual multi-error typo correction: [`TYPO_CORRECTION.md`](TYPO_CORRECTION.md)

## Operations And Risk

- Privacy policy: [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md)
- Environment evidence capture procedure: [`ENVIRONMENT_CAPTURE_PROCEDURE.md`](ENVIRONMENT_CAPTURE_PROCEDURE.md)
- Environment digest tooling architecture: [`ENVIRONMENT_DIGEST_TOOLING.md`](ENVIRONMENT_DIGEST_TOOLING.md)
- Current engineering status: [`ENGINEERING_DASHBOARD.md`](ENGINEERING_DASHBOARD.md)
- Debugging: [`DEBUGGING.md`](DEBUGGING.md)
- Performance measurement: [`PERFORMANCE_BASELINE.md`](PERFORMANCE_BASELINE.md)
- T9 continuous-digit latency — force_gc track case close (2026-07-24): [`evidence/t9-continuous-digit-latency-force-gc-case-close-2026-07-24.md`](evidence/t9-continuous-digit-latency-force-gc-case-close-2026-07-24.md)
- T9 long-composition `process_key` latency and safe auto-anchor roadmap
  (`T9-AUTO-ANCHOR-001`, S1–S4 Debug/test evidence validated, S5 isolated
  personalization reviewed, S6-A manual physical pair complete, S2.1 rolling
  automated implementation review passed, physical three-pair matrix complete
  on `90642c3` with 1/3 direction PASS (product goal not met), north star
  reaffirmed (no Path obligation), S2.2 B3 implemented with exploratory
  B2→B3 direction PASS on `459908d` (product goal still not met; default
  attempt-N expansion closed), S2.3 earlier-first implemented with Human
  B3→B3e mechanism PASS / direction FAIL; Product Hold/harvest; default-off
  S2.1–S2.3 retained; no next knife authorized; product goal not met):
  [`plan`](plans/t9-long-composition-process-key-latency-plan.md),
  [`Assignment`](assignments/t9-auto-anchor-001.md),
  [`S2.1 design`](assignments/t9-auto-anchor-001-s21-rolling-design.md),
  [`S2.1 matrix evidence`](evidence/t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md),
  [`S2.2 design`](assignments/t9-auto-anchor-001-s22-stronger-controller-bounding.md),
  [`S2.2 B2→B3 evidence`](evidence/t9-auto-anchor-s22-b2b3-2026-07-30.md),
  [`S2.3 design`](assignments/t9-auto-anchor-001-s23-earlier-first-anchor.md),
  [`S2.3 implementation evidence`](evidence/t9-auto-anchor-s23-implementation-2026-07-30.md),
  [`S2.3 B3→B3e evidence`](evidence/t9-auto-anchor-s23-b3b3e-2026-07-30.md),
  [`S6-A device preflight`](assignments/t9-auto-anchor-001-s6a-device-preflight.md),
  [`Product Decision`](product-decisions/T9-AUTO-ANCHOR-001-authorization.md),
  [`ADR 0024`](architecture/decisions/0024-t9-auto-anchor-shadow-observation-boundary.md)
- T9 responsive RIME input pipeline
  (`T9-RESPONSIVE-PIPELINE-001`, **Active** — Formal R5 **direction FAIL** retained;
  R5-Rem-3 device/Polish-2 direction PASS; P1-D2 Amendment B bounded
  Architecture/Quality **Pass with conditions**, P1-1/P1-2 closed; P2 Core
  regression subset **Pass with conditions** (19/0 focused, 861/0 full),
  P2-EPC closed at bounded Core/Fake-host scope; dual-gate
  **default-off**; Product Gate / ADR Accept
  **not** claimed; auto-anchor Hold/harvest):
  [`Product Decision`](product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md),
  [`Assignment`](assignments/t9-responsive-rime-pipeline-001.md),
  [`plan`](plans/t9-responsive-rime-pipeline-plan.md),
  [`ADR 0025 Proposed`](architecture/decisions/0025-responsive-rime-serial-input-pipeline.md),
  [`P1-D2 evidence`](evidence/t9-responsive-pipeline-p1-d2-amendment-b-2026-08-01.md),
  [`P1-D2 Architecture final review`](assignments/t9-responsive-pipeline-001-p1-d2-amendment-b-architecture-rereview-2.md),
  [`P1-D2 Quality final review`](assignments/t9-responsive-pipeline-001-p1-d2-amendment-b-quality-rereview-2.md),
  [`P2 regression assignment`](assignments/t9-responsive-pipeline-001-p2-regression-matrix.md),
  [`P2 regression evidence`](evidence/t9-responsive-pipeline-p2-regression-matrix-2026-08-01.md),
  [`P2 Architecture re-review`](assignments/t9-responsive-pipeline-001-p2-regression-matrix-architecture-rereview.md),
  [`P2 Quality re-review`](assignments/t9-responsive-pipeline-001-p2-regression-matrix-quality-rereview.md),
  [`P2-PERF-02 canonical A/B assignment`](assignments/t9-responsive-pipeline-001-p2-perf-02-canonical-ab-20260803.md),
  [`P2-PERF-02 canonical A/B evidence`](evidence/t9-responsive-pipeline-p2-perf-02-canonical-ab-2026-08-03.md),
  [`P2-PERF-03 replicated A/B proposal`](assignments/t9-responsive-pipeline-001-p2-perf-03-replicated-ab-proposal.md),
  [`P2-PERF-03 replicated A/B evidence`](evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-2026-08-03.md),
  [`P2-PERF-03 Architecture review`](assignments/t9-responsive-pipeline-001-p2-perf-03-architecture-review.md),
  [`P2-PERF-03 Quality review`](assignments/t9-responsive-pipeline-001-p2-perf-03-quality-review.md),
  [`CANARY-001 production-shaped canary (device evidence complete; disposition Stop/Retain 2026-08-05)`](assignments/t9-responsive-pipeline-001-production-shaped-canary-001.md),
  [`CANARY-001 Architecture design freeze`](assignments/t9-responsive-pipeline-001-canary-001-architecture-design-freeze.md),
  [`CANARY-001 Quality evidence freeze`](assignments/t9-responsive-pipeline-001-canary-001-quality-evidence-freeze.md),
  [`CANARY-001 live-session API inventory`](assignments/t9-responsive-pipeline-001-canary-001-live-session-api-inventory.md),
  [`CANARY-001 Architecture review`](assignments/t9-responsive-pipeline-001-canary-001-architecture-review.md),
  [`CANARY-001 Quality review`](assignments/t9-responsive-pipeline-001-canary-001-quality-review.md),
  [`CANARY-001/DEVICE-001 device evidence`](evidence/t9-responsive-pipeline-canary-001-device-001-2026-08-04.md),
  [`CANARY-001 Stop/Retain disposition`](product-decisions/T9-RESPONSIVE-PIPELINE-001-CANARY-001-disposition.md),
  [`CANARY-001 session handoff`](assignments/t9-responsive-pipeline-001-canary-001-handoff-2026-08-05.md),
  [`R5-Rem-3-Polish evidence`](evidence/t9-responsive-pipeline-r5-rem-3-polish-2026-08-01.md),
  [`R5-Rem-3-Polish Architecture review`](assignments/t9-responsive-pipeline-001-r5-rem-3-polish-architecture-review.md),
  [`R5-Rem-3-Polish Quality review`](assignments/t9-responsive-pipeline-001-r5-rem-3-polish-quality-review.md),
  [`R5-Rem-3-Device evidence`](evidence/t9-responsive-pipeline-r5-rem-3-device-2026-08-01.md),
  [`R5-Rem-3 design`](assignments/t9-responsive-pipeline-001-r5-rem-3-design.md),
  [`R5-Remediation design`](assignments/t9-responsive-pipeline-001-r5-remediation-design.md),
  [`Formal R5 evidence`](evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md)
- Release procedure: [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)
- 2026-08-01 release control: [`RELEASE-2026-0801`](assignments/release-2026-08-01.md) and its [evidence ledger](evidence/release-2026-08-01-acceptance.md)
- New-user activation / Full Access journey: [`ONBOARDING_ACTIVATION.md`](ONBOARDING_ACTIVATION.md), Product Decision [`PD-RELEASE-2026-0801-03`](product-decisions/RELEASE-2026-0801-03-activation-authorization.md)
- Help / soft first-run / TipKit packaging: [`PD-HELP-TIPKIT-001`](product-decisions/HELP-TIPKIT-001-authorization.md), Assignment [`HELP-TIPKIT-001`](assignments/help-tipkit-001.md) (`Active` — P1–P3 implemented, Product Gate pending)
- Help J3 slim resource prepare: [`PD-HELP-J3-RESOURCES-001`](product-decisions/HELP-J3-RESOURCES-001-authorization.md), Assignment [`HELP-J3-RESOURCES-001`](assignments/help-j3-resources-001.md) (`Active`)
- Main-App Search tab + J4 trial field: [`PD-APP-SEARCH-001`](product-decisions/APP-SEARCH-001-authorization.md), Assignment [`APP-SEARCH-001`](assignments/app-search-001.md) (`Active`)
- Technical debt: [`TECH_DEBT.md`](TECH_DEBT.md)
- Documentation health: [`DOCUMENTATION_HEALTH.md`](DOCUMENTATION_HEALTH.md)
- Latest documentation hygiene audit: [`evidence/doc-hygiene-001-audit.md`](evidence/doc-hygiene-001-audit.md)

## Collaboration And Governance

- Task Assignment contract: [`ASSIGNMENT_POLICY.md`](ASSIGNMENT_POLICY.md)
- Product Decision records (stable authorization sources): [`product-decisions/`](product-decisions/)
- Permanent team ownership and bootstrap prompts: [`VIRTUAL_ENGINEERING_TEAM.md`](VIRTUAL_ENGINEERING_TEAM.md)
- Knowledge OS operational entry: [`KNOWLEDGE_OS.md`](KNOWLEDGE_OS.md)
- Knowledge OS 2.0 frozen governance + startup + migration records: [`docs/kos/`](kos/)
- Zero-Context Startup for new AI sessions: [`kos/zero-context-startup.md`](kos/zero-context-startup.md)
- Knowledge OS operational migration (closed): [`assignments/kos-mig-001.md`](assignments/kos-mig-001.md), [`kos/migration-001-record.md`](kos/migration-001-record.md)
- Documentation graph: [`DOCUMENTATION_GRAPH.md`](DOCUMENTATION_GRAPH.md)
- Governance: [`DOCUMENTATION_GOVERNANCE.md`](DOCUMENTATION_GOVERNANCE.md)
- Multi-agent workflow: [`AI_WORKFLOW.md`](AI_WORKFLOW.md)
- Coordinator: [`playbooks/coordinator.md`](playbooks/coordinator.md)
- Context Scout: [`playbooks/context-scout.md`](playbooks/context-scout.md)
- KeyboardCore: [`playbooks/keyboard-core.md`](playbooks/keyboard-core.md)
- RimeBridge: [`playbooks/rime-bridge.md`](playbooks/rime-bridge.md)
- Keyboard UI: [`playbooks/keyboard-ui.md`](playbooks/keyboard-ui.md)
- Main App UI: [`playbooks/main-app-ui.md`](playbooks/main-app-ui.md)
- Test / Release: [`playbooks/test-release.md`](playbooks/test-release.md)
- Debug Investigator: [`playbooks/debug-investigator.md`](playbooks/debug-investigator.md)
- Documentation Maintainer: [`playbooks/documentation-maintainer.md`](playbooks/documentation-maintainer.md)
- Detailed legacy routing registry: [`../CONTEXT_INDEX.md`](../CONTEXT_INDEX.md)

## History

- Completed changes: [`../CHANGELOG.md`](../CHANGELOG.md)
- Archived/active plans: [`plans/`](plans/)
- Swift 6 acceptance history: [`architecture/swift6-manual-acceptance.md`](architecture/swift6-manual-acceptance.md)

Playbooks define how agents work; domain facts remain in the linked architecture, ADR and operational sources.

### T9 Amendments E/F/G (2026-07-21)

- Product authorization: [`product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md)
- Architecture: [`architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md`](architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md)
- Architecture: [`architecture/decisions/0022-t9-atomic-presentation-and-bounded-path-discovery.md`](architecture/decisions/0022-t9-atomic-presentation-and-bounded-path-discovery.md)
- Execution / acceptance: [`assignments/keyboard-layout-9key-pinyin-002.md`](assignments/keyboard-layout-9key-pinyin-002.md), [`assignments/keyboard-layout-9key-pinyin-002-product-gate-human-handoff.md`](assignments/keyboard-layout-9key-pinyin-002-product-gate-human-handoff.md)
- Canonical behavior: confirmed-prefix session continuity, bounded complete-syllable discovery, and one visible letter per entered T9 slot.
- Amendment H / Grok continuation: [`assignments/keyboard-layout-9key-pinyin-002-grok-handoff-2026-07-21.md`](assignments/keyboard-layout-9key-pinyin-002-grok-handoff-2026-07-21.md)
