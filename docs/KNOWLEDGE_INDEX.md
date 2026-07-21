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
- Release procedure: [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)
- 2026-08-01 release control: [`RELEASE-2026-0801`](assignments/release-2026-08-01.md) and its [evidence ledger](evidence/release-2026-08-01-acceptance.md)
- New-user activation / Full Access journey: [`ONBOARDING_ACTIVATION.md`](ONBOARDING_ACTIVATION.md), Product Decision [`PD-RELEASE-2026-0801-03`](product-decisions/RELEASE-2026-0801-03-activation-authorization.md)
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
- Execution / acceptance: [`assignments/keyboard-layout-9key-pinyin-002.md`](assignments/keyboard-layout-9key-pinyin-002.md), [`assignments/keyboard-layout-9key-pinyin-002-product-gate-human-handoff.md`](assignments/keyboard-layout-9key-pinyin-002-product-gate-human-handoff.md)
- Canonical behavior: confirmed-prefix session continuity, bounded complete-syllable discovery, and one visible letter per entered T9 slot.
- Amendment H / Grok continuation: [`assignments/keyboard-layout-9key-pinyin-002-grok-handoff-2026-07-21.md`](assignments/keyboard-layout-9key-pinyin-002-grok-handoff-2026-07-21.md)
