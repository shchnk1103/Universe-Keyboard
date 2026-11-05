# Assignment: CI-LIGHT-KOS-001 — 只改 KOS 工具的变更走轻量 CI

Policy version: 1.0.0
record_id: CI-LIGHT-KOS-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active — 本地提交，待复核 |
| Current phase | 本地一个提交，待独立复核 |
| Material non-claims | 不改 workflow；不做缓存或拆分；不代表 Product Gate、合并或 Release |
| Next handoff / decision | Product Lead 决定是否合并 |
| Residuals | 无 |

---

## Authority

- **Task ID / Title:** CI-LIGHT-KOS-001 — 只改 KOS 工具的变更走轻量 CI
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** 2026-11-05（Asia/Shanghai）。Human 原话「按推荐改」。实现包 SHA-256 `b2fff8f95f212f2e9c0e90b539a3b5d53b63dfff195280c310fd9efc8d17949c`。
- **Product Approver:** Human Product Owner

## Boundary

- **Scope:** 本包 A–D：分类规则增加 `scripts/kos/**` → `kos_tools_only`；轻量检查运行其单测；分类测试与 workflow 守卫；更新分类真相源、ADR 0031 的 2026-11-05 修订节，并新建本 Assignment。
- **Non-goals:** 不改 workflow、不做缓存或拆分。
- **Required Inputs:**
  - `/Users/doubleshy0n/.kos-work/Universe-Keyboard/CI-DURATION-ANALYSIS-001/reports/ci-duration-analysis.md`，SHA-256 `84ad7aff4bfff82ce83ea9a583ee00287f4bee437254fd21c89bb37112214556`
  - `/Users/doubleshy0n/.kos-work/Universe-Keyboard/CI-LIGHT-KOS-001/inputs/human-decision-20261105.md`，SHA-256 `cc5dbe28bbe2c915a0c0aed1efb2cfd0ab62d40c1acd88dc610149c625cd1133`

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Executor
- **Environment Executor:** Not Applicable — 不跑 Swift/Xcode、不碰设备。
- **Human Dependency:** Human 授权本包并日后决定是否合并。
- **Architecture Reviewer:** 独立只读复核会话
- **Quality Reviewer:** 独立只读复核会话
- **Product Approver:** Human Product Owner

## Gates

- **Entry Criteria:** 预检通过且 Human 点名本包 SHA。
- **Exit Criteria:** 本地一个提交、轻量检查与两次分类符合预期、独立复核完成。
- **Stop Conditions:** 冻结输入或起点不符、白名单外改动、写入被拒、运行了 gh 或联网命令、提交身份不符或出现 AI 署名或 Co-authored-by。STOPPED 优先。

## Handoff

- **Handoff Target:** Product Lead
- **Required Handoff Content:** 提交 SHA、报告路径与 SHA-256、分类输出原文。
- **Revalidation Trigger:** 分类规则、基线或 Human 决定变化。

---

## History

| 阶段 | 记录 |
|---|---|
| R1 | 实现包 `task-package-impl-r1.md`，SHA-256 `b2fff8f95f212f2e9c0e90b539a3b5d53b63dfff195280c310fd9efc8d17949c`。 |
