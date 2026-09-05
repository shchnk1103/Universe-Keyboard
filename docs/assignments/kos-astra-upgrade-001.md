# Assignment: KOS-ASTRA-UPGRADE-001 — 修复执行指令并准备 KOS v0.7.0 采用

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Blocked |
| Current Phase | Independent review complete; local App parity not green |
| Material non-claims | Adopted remains v0.6.0 advisory; no released v0.7.0, required, product Swift, device or Release claim |
| Next handoff / decision | Resolve local parity environment; Human decides merge/release/adoption |
| Residuals | 19 baseline-reproduced App crashes; stable Xcode missing simulator component; hosted CI green |

## Authority

- Assignment Authority / Product Approver: Human Product Owner acting as Product Lead.
- Decision Source / Date: 当前 Codex 会话，2026-09-05 Asia/Shanghai，用户要求“把刚才你找出来的问题都修复并推进升级KOS”。
- 本次任务允许修复已审查问题、准备上游可选运行包与本项目采用差异、隔离提交和 PR；最终 merge/Kit Release/采用状态由具体结果的 Human Gate 决定。
- Governance baseline: pinned Kit v0.6.0 (`a16c93281718f97cb580935c5043562c39f3a1d1`)，当前项目 KOS 2.0 + 2.1 ops。候选 v0.7.0 不追溯赋予本任务权限。

## Boundary

- Scope: 八项审查发现；AGENTS/兼容入口/启动、Assignment 阶段说明、AI workflow/playbooks、测试/发布技能、导航与架构漂移、健康评估及升级记录。
- Non-goals: Swift/工程/CI 分类器改变、放宽本地质量门、UNKNOWN 自动补全、既有 Active Assignment 迁移、required、TestFlight、第三方项目升级。
- Repository Change Types: Contract clarification, Documentation, State, Evidence.
- Required Inputs: 当前 AGENTS、治理/Assignment/依赖文件、v0.6.0 与上游候选、官方模型指南、实际源码及测试 target。

## Assignment

- Domain Owner / Executor: Architecture & Knowledge Steward / 当前 Codex executor。
- Environment Executor: 当前 Codex executor，隔离副本本地验证与功能分支/PR 操作。
- Human Dependency: Human Product Owner，具体候选的最终 merge/Release/采用决定。
- Architecture Reviewer: KOS-EXECUTION-001/architecture 独立只读 CLI runtime，覆盖两仓库接口。
- Quality Reviewer: KOS-EXECUTION-001/quality 独立只读 CLI runtime，覆盖行为场景和验证。
- 技术分工属于本次用户授权的有界实施安排，不改变永久角色；缺少独立 runtime 时保留未评审状态。

## Gates and Handoff

Entry: 用户明确实施授权；已读权威入口；干净且独立的副本；实际基线已获取。
Preparation: 修复并验证已授权内容，Reviewer 无法启动则阻塞独立结论；不阻塞可独立完成的准备。
Exit: 八项发现映射、独立 review、适用验证、精确提交/PR、上游发布前后采用步骤可审计。
Stop: 权威/生命周期实质变化、未知责任、降低证据或并发写冲突；最终发布动作未授权时停止在动作前。
Handoff Target: Human Product Owner；内容包括 [evidence](../evidence/kos-astra-upgrade-001.md)、review、验证缺口、上游候选与采用 pin。
Revalidation: scope、基线、发布意图、独立性、所采用规则或环境改变。

## Envelope boundary

本任务按 legacy Markdown 进入；v0.6.0 advisory 不要求所有新任务自动进入 Profile。
本片审阅后选择不改 include/schema；此决定不豁免未来 required 迁移，不把模板假值写成授权。

## Historical 2026-09-05 execution checkpoint (availability superseded)

Candidate implementation is retained in an isolated feature branch. Reviewer CLI attempts reached account
usage limits before final output; no independent conclusion exists. Draft PR only, not merge-ready.
See [review attempts](../reviews/kos-execution-001-review-status.md).
