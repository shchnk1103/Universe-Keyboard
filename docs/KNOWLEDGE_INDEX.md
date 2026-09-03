# Universe Keyboard Knowledge Index

> Open this after `AGENTS.md` at the start of every new Codex thread. This file is navigation only.

## Start By Intent

- **Active formal work (≤10):** [`ACTIVE_WORK.md`](ACTIVE_WORK.md) — links only; Assignment is lifecycle SoT
- Task-specific implementation or investigation: [`READING_MAPS.md`](READING_MAPS.md)
- New contributor learning: [`ONBOARDING.md`](ONBOARDING.md)
- Unfamiliar term: [`GLOSSARY.md`](GLOSSARY.md)
- Documentation change: [`DOCUMENTATION_GOVERNANCE.md`](DOCUMENTATION_GOVERNANCE.md)
- Change impact: [`KNOWLEDGE_DEPENDENCIES.md`](KNOWLEDGE_DEPENDENCIES.md)
- Change classification: [`DECISION_TREES.md`](DECISION_TREES.md)
- KOS 2.1 ops hygiene (under 2.0): [`kos/kos-2.1-operational-maturity.md`](kos/kos-2.1-operational-maturity.md)
- KOS 2.2 advisory pin (`v0.6.0`): [`kos/UPGRADE_STATUS.md`](kos/UPGRADE_STATUS.md) · [`.kos/project.json`](../.kos/project.json) · [`KOS-UPGRADE-UK-003`](assignments/kos-upgrade-uk-003.md)
- Human-operated iOS evidence profile: [`kos/universe-keyboard-human-operated-evidence-profile.md`](kos/universe-keyboard-human-operated-evidence-profile.md)

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
- Built-in offline Luna quality (F-02, Active；PR [#93](https://github.com/shchnk1103/Universe-Keyboard/pull/93) merged `ec6c277`): [`RIME-BUILTIN-LUNA-QUALITY-001`](assignments/rime-builtin-luna-quality-001.md) · ADR [`0033`](architecture/decisions/0033-main-app-owned-offline-rime-resource-closure.md) · [`Gate`](product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-product-gate.md)
- Keyboard layout (26-key / Chinese nine-key runtime + chrome): [`KEYBOARD_LAYOUT.md`](KEYBOARD_LAYOUT.md)
- Nine-key chrome Assignment (closed): [`assignments/keyboard-layout-9key-ui-001.md`](assignments/keyboard-layout-9key-ui-001.md)
- Path Bar upper-half tap delivery (`Completed`；Human 复验通过): [`assignments/path-bar-touch-001.md`](assignments/path-bar-touch-001.md)
- Nine-key common punctuation pending/cycle (`Closed`；PR [#75](https://github.com/shchnk1103/Universe-Keyboard/pull/75) merged；Human Product Gate Passed；ADR [`0029`](architecture/decisions/0029-t9-pending-punctuation-palette.md) Accepted): [`assignments/keyboard-layout-9key-punct-001.md`](assignments/keyboard-layout-9key-punct-001.md), Product Decision [`PD-KEYBOARD-LAYOUT-9KEY-PUNCT-001`](product-decisions/KEYBOARD-LAYOUT-9KEY-PUNCT-001-authorization.md)
- Pending kaomoji palette (`Closed`；PR [#80](https://github.com/shchnk1103/Universe-Keyboard/pull/80) `54ce3bd`；ADR [`0030`](architecture/decisions/0030-pending-kaomoji-palette.md) Accepted): [`RELEASE-2026-0801-08`](assignments/release-2026-08-01-08-kaomoji-content.md), [`PD catalog`](product-decisions/RELEASE-2026-0801-08-kaomoji-catalog.md)
- Nine-key precise pinyin selection (`Accepted / Closed`; PR [#20](https://github.com/shchnk1103/Universe-Keyboard/pull/20) merged): [`assignments/keyboard-layout-9key-pinyin-001.md`](assignments/keyboard-layout-9key-pinyin-001.md), ADR [`0020`](architecture/decisions/0020-t9-precise-pinyin-path-selection.md), Product Gate [`assignments/keyboard-layout-9key-pinyin-001-product-gate-pass.md`](assignments/keyboard-layout-9key-pinyin-001-product-gate-pass.md)
- Nine-key deterministic choices + segmented/progressive paths + safe remaining/Delete (`Blocked — superseded through 003 by closed 004; historical evidence only`): [`assignments/keyboard-layout-9key-pinyin-002.md`](assignments/keyboard-layout-9key-pinyin-002.md), Product Decision [`PD-...-002`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md), ADR [`0021`](architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md), segmented Spike [`summary`](assignments/keyboard-layout-9key-pinyin-002-segmented-spike-summary.md)
- Nine-key atomic Path presentation + fixed foreground discovery (`Superseded by closed 004 — Human Product Gate failed; historical evidence only`): [`assignments/keyboard-layout-9key-pinyin-003.md`](assignments/keyboard-layout-9key-pinyin-003.md), Product Decision [`PD-...-003`](product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-003-authorization.md), ADR [`0022`](architecture/decisions/0022-t9-atomic-presentation-and-bounded-path-discovery.md), Stage A [`evidence`](assignments/keyboard-layout-9key-pinyin-003-stage-a-evidence.md)
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
- Codex GitHub CLI auth/network classification: [`kos/codex-github-cli-auth-troubleshooting.md`](kos/codex-github-cli-auth-troubleshooting.md)
- CI change classification and stable final gate: [`CI_CHANGE_CLASSIFICATION.md`](CI_CHANGE_CLASSIFICATION.md)
- Environment evidence capture procedure: [`ENVIRONMENT_CAPTURE_PROCEDURE.md`](ENVIRONMENT_CAPTURE_PROCEDURE.md)
- Environment digest tooling architecture: [`ENVIRONMENT_DIGEST_TOOLING.md`](ENVIRONMENT_DIGEST_TOOLING.md)
- Current engineering status: [`ENGINEERING_DASHBOARD.md`](ENGINEERING_DASHBOARD.md)
- Debugging: [`DEBUGGING.md`](DEBUGGING.md)
- Performance measurement: [`PERFORMANCE_BASELINE.md`](PERFORMANCE_BASELINE.md)
- Crash/Jetsam acquisition and symbolication: [`CRASH_JETSAM_SYMBOLICATION.md`](CRASH_JETSAM_SYMBOLICATION.md)
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
  (`T9-RESPONSIVE-PIPELINE-001`, **Reviewed** — Formal R5 **direction FAIL** retained;
  CANARY-001 **Stop/Retain** 2026-08-05; **ADR 0025 Accepted** 2026-08-06;
  **RESPONSIVE-ALL-LAYOUTS-001** L0 universal; **RESPONSIVE-DEFAULT-ON-001**
  Product Gate dual-gate Release default-on delivered 2026-08-06; parent
  removed from Active Work `2026-08-14`):
  [`Product Decision`](product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md),
  [`Assignment`](assignments/t9-responsive-rime-pipeline-001.md),
  [`plan`](plans/t9-responsive-rime-pipeline-plan.md),
  [`ADR 0025 Accepted`](architecture/decisions/0025-responsive-rime-serial-input-pipeline.md),
  [`ADR-0025-ACCEPT-001 Assignment`](assignments/adr-0025-accept-001.md),
  [`ADR-0025-ACCEPT Product Decision`](product-decisions/T9-RESPONSIVE-PIPELINE-001-ADR-0025-ACCEPT-authorization.md),
  [`ADR-0025-ACCEPT readiness dossier`](assignments/adr-0025-accept-001-readiness-dossier.md),
  [`ADR-0025-ACCEPT Architecture review`](assignments/adr-0025-accept-001-architecture-review.md),
  [`ADR-0025-ACCEPT Quality review`](assignments/adr-0025-accept-001-quality-review.md),
  [`POST-ACCEPT-001 Assignment`](assignments/t9-responsive-pipeline-001-post-accept-001.md),
  [`POST-ACCEPT-001 R3 residual inventory`](evidence/t9-responsive-pipeline-post-accept-001-r3-residual-inventory-2026-08-06.md),
  [`RESPONSIVE-ALL-LAYOUTS-001 Assignment`](assignments/responsive-all-layouts-001.md),
  [`RESPONSIVE-ALL-LAYOUTS-001 evidence`](evidence/responsive-all-layouts-001-2026-08-06.md),
  [`RESPONSIVE-DEFAULT-ON-001 Assignment`](assignments/responsive-default-on-001.md),
  [`RESPONSIVE-DEFAULT-ON-001 Product Decision`](product-decisions/RESPONSIVE-DEFAULT-ON-001-authorization.md),
  [`RESPONSIVE-DEFAULT-ON-001 evidence`](evidence/responsive-default-on-001-2026-08-06.md),
  [`RESPONSIVE-CANDIDATE-ANOMALY-001`](assignments/responsive-candidate-anomaly-001.md) (Completed — select double-commit + paging window; Executor-recorded tests),
  [`RESPONSIVE-DELETE-ANOMALY-001`](assignments/responsive-delete-anomaly-001.md) (Completed — flush-before-bind Delete),
  [`PD-T9-SINGLE-KEY-MIXED-CANDIDATES-001`](product-decisions/T9-SINGLE-KEY-MIXED-CANDIDATES-001-authorization.md) (**Closed — Won’t do** — accept rime-ice `t9` sparse raw-digit menus; not dual-gate bug class),
  [`T9-SINGLE-KEY-MIXED-CANDIDATES-001 Assignment`](assignments/t9-single-key-mixed-candidates-001.md) (`Closed — Won’t do`),
  [`discussion draft`](plans/t9-single-key-mixed-candidates-001-discussion.md) (historical plain-language),
  [`PD-RIME-SCHEME-WANXIANG-001`](product-decisions/RIME-SCHEME-WANXIANG-001-authorization.md) (**Completed** — V1 catalog/layout path),
  [`RIME-SCHEME-WANXIANG-001 Assignment`](assignments/rime-scheme-wanxiang-001.md) (`Completed` — independent review/close handoff pending),
  [`PD-TD-012-OCTAGRAM-VENDOR-G1`](product-decisions/TD-012-OCTAGRAM-VENDOR-G1-authorization.md) and [`TD-012-G1 Assignment`](assignments/td-012-octagram-vendor-g1.md) (**Closed** — vendor/module capability; no `.gram`),
  [`TD-012 G1 Architecture`](assignments/td-012-octagram-vendor-g1-architecture-review.md) · [`Quality`](assignments/td-012-octagram-vendor-g1-quality-review.md),
  [`PD-TD-012-LMDG-MODEL-G2`](product-decisions/TD-012-LMDG-MODEL-G2-authorization.md) · [`G2 Assignment`](assignments/td-012-lmdg-model-g2.md) · [`G2 plan`](plans/td-012-lmdg-model-g2-plan.md) · [`latest G2-B evidence`](evidence/td-012-lmdg-model-g2-device-ab-2026-08-12.md) · [`retrospective`](evidence/td-012-lmdg-model-g2-execution-retrospective-2026-08-12.md) (**Closed — Product Hold**; G2-B invalidated; no G3),
  [`ADR 0026`](architecture/decisions/0026-layout-bound-rime-scheme-selection.md) (**Accepted** — layout-bound RIME scheme selection; amends 0018),
  [`ADR-0026-ACCEPT-001`](assignments/adr-0026-accept-001.md),
  multi-scheme debts: [`TECH_DEBT.md`](TECH_DEBT.md) **TD-009/010 repaid**; **TD-011 A done** / B–D open; **TD-012 open** (model G2+; Vendor G1 Closed),
  [`CANARY-001 Stop/Retain disposition`](product-decisions/T9-RESPONSIVE-PIPELINE-001-CANARY-001-disposition.md),
  [`CANARY-001/DEVICE-001 device evidence`](evidence/t9-responsive-pipeline-canary-001-device-001-2026-08-04.md),
  [`P2-PERF-03 replicated A/B evidence`](evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-2026-08-03.md),
  [`Formal R5 evidence`](evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md)
- Release procedure: [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)
- Build 7 internal TestFlight first-run/scheme-delivery feedback (`Assignment Pending`; F-03 cross-region download urgent): [`RELEASE-2026-0801-11`](assignments/release-2026-08-01-11-internal-testflight-feedback.md) · [`intake evidence`](evidence/release-2026-08-01-11-internal-testflight-feedback-2026-08-25.md)
- Multi-endpoint verified RIME scheme delivery (`Closed`; PR [#83](https://github.com/shchnk1103/Universe-Keyboard/pull/83) merged `e9aea57`; Human Product Gate Passed; GitHub source and acceptable-use are `accept` residuals; not TestFlight): [`RIME-SCHEME-DELIVERY-001`](assignments/rime-scheme-delivery-001.md) · [`INTEGRITY-001`](assignments/rime-scheme-delivery-integrity-001.md) · [`SCHEME-DELIVERY-JOURNAL-001`](assignments/scheme-delivery-journal-001.md) · [`Gate`](product-decisions/RIME-SCHEME-DELIVERY-001-product-gate.md) · [`ADR 0032`](architecture/decisions/0032-verified-scheme-source-recovery-and-integrity-classification.md) · [`success evidence`](evidence/rime-scheme-delivery-wanxiang-success-2026-08-28.md)
- App Store release control: [`RELEASE-2026-0801`](assignments/release-2026-08-01.md) (`Active` — 现行目标 `2026-08-26`; Cloud Archive/签名 pilot 与部分 TestFlight 文案完成；[redate](product-decisions/RELEASE-2026-0801-target-redate.md)), [evidence ledger](evidence/release-2026-08-01-acceptance.md), [2026-08-22 metadata audit](evidence/release-2026-08-01-05-testflight-metadata-audit-2026-08-22.md), [2026-08-23 third-party notice provenance](evidence/release-2026-08-01-05-third-party-notice-provenance-2026-08-23.md), [`PROVENANCE-A`](assignments/release-2026-08-01-05-provenance-recovery-phase-a.md), and [accepted derived receipts](product-decisions/RELEASE-2026-0801-05-provenance-a-accept.md)
- New-user activation / Full Access journey: [`ONBOARDING_ACTIVATION.md`](ONBOARDING_ACTIVATION.md), Product Decision [`PD-RELEASE-2026-0801-03`](product-decisions/RELEASE-2026-0801-03-activation-authorization.md)
- Help / soft first-run / TipKit packaging: [`PD-HELP-TIPKIT-001`](product-decisions/HELP-TIPKIT-001-authorization.md), Assignment [`HELP-TIPKIT-001`](assignments/help-tipkit-001.md) (`Completed` — P1–P3 implemented, Product Gate pending)
- Help J3 slim resource prepare: [`PD-HELP-J3-RESOURCES-001`](product-decisions/HELP-J3-RESOURCES-001-authorization.md), Assignment [`HELP-J3-RESOURCES-001`](assignments/help-j3-resources-001.md) (`Completed`)
- Main-App Search tab + J4 trial field: [`PD-APP-SEARCH-001`](product-decisions/APP-SEARCH-001-authorization.md), Assignment [`APP-SEARCH-001`](assignments/app-search-001.md) (`Completed`)
- Debug key hit-range overlay: [`PD-DEBUG-KEY-HITBOX-001`](product-decisions/DEBUG-KEY-HITBOX-001-authorization.md), Assignment [`DEBUG-KEY-HITBOX-001`](assignments/debug-key-hitbox-001.md) (`Closed` — Debug-only overlay + 九键/26 键共用中线命中)
- 26-key touch fill / overlay-independent hits: [`PD-KEY-TOUCH-FILL-001`](product-decisions/KEY-TOUCH-FILL-001-authorization.md), Assignment [`KEY-TOUCH-FILL-001`](assignments/key-touch-fill-001.md) (`Completed` — Human Product Gate Passed)
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
- Knowledge OS 2.1 operational maturity **published under 2.0** (frozen 2.0 unchanged): [`ops package`](kos/kos-2.1-operational-maturity.md), [`ACTIVE_WORK.md`](ACTIVE_WORK.md), [`IMPL Assignment`](assignments/kos-2.1-ops-impl-001.md), [`design disposition`](product-decisions/KOS-2.1-OPS-001-design-disposition.md)
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
