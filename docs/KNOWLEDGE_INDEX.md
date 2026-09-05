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

## 领域权威

- [键盘布局与九键](KEYBOARD_LAYOUT.md) · [方案管理](RIME_SCHEME_MANAGEMENT.md)
- [模糊音](RIME_FUZZY_PINYIN.md) · [用户词典](RIME_USER_DICTIONARY.md) · [同步](RIME_SYNC.md)
- [输入智能](TYPING_INTELLIGENCE.md) · [纠错](TYPO_CORRECTION.md)
- [纠错 Benchmark](TYPO_BENCHMARK.md) · [Registry](TYPO_BENCHMARK_REGISTRY.md) · [V2 Registry](TYPO_BENCHMARK_REGISTRY_V2.md)
- [上屏续写](POST_COMMIT_CONTINUATION.md) · [续写内容质量](POST_COMMIT_CONTINUATION_QUALITY.md)
- [App 通知](APP_NOTIFICATIONS.md) · [隐私](PRIVACY_POLICY.md)

## 验证与运维

- [调试](DEBUGGING.md) · [性能](PERFORMANCE_BASELINE.md) · [发布](RELEASE_CHECKLIST.md)
- [CI 分级](CI_CHANGE_CLASSIFICATION.md) · [GitHub 环境诊断](kos/codex-github-cli-auth-troubleshooting.md)
- [Crash/Jetsam](CRASH_JETSAM_SYMBOLICATION.md) · [环境采集](ENVIRONMENT_CAPTURE_PROCEDURE.md) · [环境摘要](ENVIRONMENT_DIGEST_TOOLING.md)
- [技术债](TECH_DEBT.md) · [文档健康](DOCUMENTATION_HEALTH.md) · [协调状态镜像](ENGINEERING_DASHBOARD.md)

## KOS

- [运行入口](KNOWLEDGE_OS.md) · [冻结规范](kos/knowledge-os-2.0-specification.md) · [零上下文启动](kos/zero-context-startup.md)
- [Assignment Policy](ASSIGNMENT_POLICY.md) · [2.1 ops](kos/kos-2.1-operational-maturity.md)
- [实际采用版本](kos/UPGRADE_STATUS.md) · [Profile](../.kos/project.json) · [人工证据](kos/universe-keyboard-human-operated-evidence-profile.md)
