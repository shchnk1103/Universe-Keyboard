# Universe Keyboard Knowledge Index

本页只路由。当前工作读 [Active Work](ACTIVE_WORK.md)，按 [Reading Maps](READING_MAPS.md)
选择一个任务路径；足以回答或行动后停止扩读。历史从 Assignment/ADR 目录按 ID 查找。

## 工作入口

- [任务路径](READING_MAPS.md) · [当前工作](ACTIVE_WORK.md) · [Assignment 目录](assignments/)
- [架构概览](PROJECT_CONTEXT.md)（代码/架构任务）· [UI 规则](UI_STYLE_GUIDE.md)
- [文档治理](DOCUMENTATION_GOVERNANCE.md) · [依赖影响](KNOWLEDGE_DEPENDENCIES.md) · [决策树](DECISION_TREES.md)
- [AI 协作](AI_WORKFLOW.md) · [领域 playbooks](playbooks/) · [长期所有权](VIRTUAL_ENGINEERING_TEAM.md)
- [新开发者](ONBOARDING.md) · [术语](GLOSSARY.md) · [详细文档图](DOCUMENTATION_GRAPH.md)

## 架构与决策

- [共享容器/RIME 生命周期](architecture/shared-container-and-rime-lifecycle.md)
- [输入管线/marked text](architecture/input-pipeline-and-marked-text.md) · [Partial Commit](architecture/partial-commit.md)
- [Swift 6](architecture/swift6-migration.md) · [RIME artifacts](architecture/rime-artifacts.md) · [OpenCC](architecture/opencc-integration.md)
- [ADR](architecture/decisions/) · [架构时间线](ARCHITECTURE_TIMELINE.md)
- [Build 55 公开外部测试例外提案](product-decisions/RELEASE-2026-09-13-build55-limited-external-trial-exception-proposal.md) — **已接受公开测试例外；不等于 Release Gate Pass**

## 领域权威

- [键盘布局与九键](KEYBOARD_LAYOUT.md) · [方案管理](RIME_SCHEME_MANAGEMENT.md)
- 方案下载来源状态 / 多方案资源归属（工程 Assignment **Closed**；ADR 0034 **Accepted (Conditional)**；Product/Release 仍分离）：[`SCHEME-DELIVERY-SOURCE-STATE-001`](assignments/scheme-delivery-source-state-001.md) · [`Close receipt`](evidence/scheme-delivery-source-state-001-close-2026-09-16.md) · [`plan`](plans/scheme-resource-ownership-and-coexistence-plan.md) · [`P0`](evidence/scheme-delivery-source-state-001-p0-2026-09-07.md) · [`P1`](evidence/scheme-delivery-source-state-001-p1-2026-09-07.md) · [`device`](evidence/scheme-delivery-source-state-001-p3-device-2026-09-07.md) · [`ADR 0034`](architecture/decisions/0034-multi-scheme-resource-ownership.md) · [`Accept`](evidence/adr-0034-accept-2026-09-12.md)
- [模糊音](RIME_FUZZY_PINYIN.md) · [用户词典](RIME_USER_DICTIONARY.md) · [同步](RIME_SYNC.md)
- [输入智能](TYPING_INTELLIGENCE.md) · [纠错](TYPO_CORRECTION.md)
- [纠错 Benchmark](TYPO_BENCHMARK.md) · [Registry](TYPO_BENCHMARK_REGISTRY.md) · [V2 Registry](TYPO_BENCHMARK_REGISTRY_V2.md)
- [TYPO-CORRECTION-002 recall remediation](assignments/typo-correction-002-recall-remediation-001.md) · [quality Run 002](evidence/typo-correction-002-recall-remediation-quality-run-2026-09-20-002.md) · [Architecture review](reviews/typo-correction-002-recall-remediation-final-architecture-review-2026-09-20.md) · [Quality review](reviews/typo-correction-002-recall-remediation-final-quality-review-2026-09-20.md) · [Product decision](product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-BOUNDED-PUBLICATION-PREPARATION-DECISION-2026-09-20.md) · [post-merge state sync](evidence/typo-correction-002-recall-remediation-post-merge-state-sync-2026-09-20.md) — PR #141 已 squash merge `7e151598`；final manifest `e2b4373c…` 的工程 review 与 Product Accept 仍是 bounded 证据，parent 继续 Active
- [上屏续写](POST_COMMIT_CONTINUATION.md) · [续写内容质量](POST_COMMIT_CONTINUATION_QUALITY.md)
- [App 通知](APP_NOTIFICATIONS.md) · [隐私](PRIVACY_POLICY.md)
- [首次启用 / 完全访问旅程](ONBOARDING_ACTIVATION.md) — 语义 `PD-RELEASE-2026-0801-03`；展示 `PD-HELP-TIPKIT-001` / [`HELP-GUIDE-SHEET-001`](assignments/help-guide-sheet-001.md)（Closed；Product Gate [`记录`](product-decisions/HELP-GUIDE-SHEET-001-product-gate.md)）

## 验证与运维

- [调试](DEBUGGING.md) · [性能](PERFORMANCE_BASELINE.md) · [发布](RELEASE_CHECKLIST.md)
- [发布证据增量与候选晋级](assignments/release-evidence-promotion-001.md) · [ADR 0035](architecture/decisions/0035-release-evidence-accumulation-and-promotion.md) · [正式采纳 Product Decision](product-decisions/ADR-0035-ACCEPT-authorization.md) · [REP-Q-01 receipt](evidence/release-evidence-promotion-001-rep-q-01-provenance-2026-09-15.md) · [P1-A / ADR 0035 状态对账](evidence/release-evidence-promotion-001-p1-a-adr-0035-status-reconciliation-2026-09-15.md) · [PR #128](https://github.com/shchnk1103/Universe-Keyboard/pull/128) merged `1a405143`
- [CI 分级](CI_CHANGE_CLASSIFICATION.md) · [拆分 full 路径 heavy job（Closed；#130 merged）](assignments/ci-heavy-job-split-001.md) · [Architecture](reviews/ci-heavy-job-split-001-architecture-review.md) · [Quality](reviews/ci-heavy-job-split-001-quality-review.md) · [GitHub 环境诊断](kos/codex-github-cli-auth-troubleshooting.md)
- [Crash/Jetsam](CRASH_JETSAM_SYMBOLICATION.md) · [环境采集](ENVIRONMENT_CAPTURE_PROCEDURE.md) · [环境摘要](ENVIRONMENT_DIGEST_TOOLING.md)
- [技术债](TECH_DEBT.md) · [文档健康](DOCUMENTATION_HEALTH.md) · [协调状态镜像](ENGINEERING_DASHBOARD.md)

## KOS

- [运行入口](KNOWLEDGE_OS.md) · [冻结规范](kos/knowledge-os-2.0-specification.md) · [零上下文启动](kos/zero-context-startup.md)
- [Assignment Policy](ASSIGNMENT_POLICY.md) · [2.1 ops](kos/kos-2.1-operational-maturity.md)
- [实际采用版本](kos/UPGRADE_STATUS.md) · [Profile](../.kos/project.json) · [人工证据](kos/universe-keyboard-human-operated-evidence-profile.md)
- [UK-005 release-evidence（parent/P1 engineering scope Closed；Product/Release 分离）](assignments/kos-release-evidence-implementation-001.md) · [P1-A](assignments/kos-release-evidence-implementation-001-p1.md) · [Close receipt](evidence/kos-release-evidence-implementation-001-close-2026-09-16.md) · [F-001 remediation](assignments/kos-release-evidence-implementation-001-p1-f001.md) · [P-01/D-01 fact-only handoff](assignments/kos-release-evidence-implementation-001-p01-d01.md) · [P1-A provenance closure](evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md) · [P1-B Option A](product-decisions/KOS-UPGRADE-UK-005-P1-B-scope.md) · [Upgrade Record](kos/upgrade-records/KOS-UPGRADE-UK-005-release-evidence-v1.md)
- [外部公测发布复盘建议稿](kos/kos-improvement-suggestions-public-beta-release-2026-09-13.md) — **建议稿；未采纳**
