# Assignment: T9-PINYIN-CYCLE-009 — 九宫格拼音循环与删除诊断日志

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Assignment Pending` — 设计已通过 Architecture 审查，S1 实现待 Assignment 合入与独立预检 |
| **Phase** | S1 未开始 |
| **Non-claims** | 隐私分类未决；不代表实现、性能验收或发布已获批准；含新事件的构建在 Human 决定隐私分类前不得进 TestFlight |
| **Next** | 本 Assignment 合入 main；S1 包独立预检 PASS 且基线重冻 |
| **Residuals** | Domain Owner、Product Approver、Handoff Target、Revalidation Trigger 为 `UNKNOWN`（见下） |

---

**Task ID / Title:** `T9-PINYIN-CYCLE-009` — 九宫格拼音循环与删除诊断日志
**Date / timezone:** `2026-11-14 Asia/Shanghai`
**Repository change types:** `Implementation`, `Tests`, `Documentation`

目标：用不含输入内容的 typed 日志事件 `t9.cycle_result`、`t9.delete_path` 取得真机证据，以定位 m/n 无法被选中等问题。

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human 2026-11-14（Asia/Shanghai）决定：v7 批准；Release 复用默认关闭的 `logging_enabled`；隐私分类未定，先出对照审阅（隐私对照报告：外置 `~/.kos-work/Universe-Keyboard/T9-PINYIN-CYCLE-009-PRIVACY/reports/executor-report-privacy.md`，SHA-256 `cfca82239a0274adbe5e3e5f30330a6fe45b69b3f8f28f91d79c7d7c36097f7d`）。
- **Product Approver:** `UNKNOWN`

## Boundary

- **Scope（S1）:** v7 协议、reader、wire 校验、typed 导出、`t9.cycle_result`、`t9.delete_path`，含设计 r2 第 1–3 节全部绑定与非等待准入链及测试；文档更新 `docs/DEBUGGING.md`、ADR 0027、ADR 0036 新附录、`docs/PORTFOLIO.md`、`CHANGELOG.md`、`docs/KNOWLEDGE_INDEX.md`、`docs/READING_MAPS.md`。
- **Non-goals:** 拼音栏视口事件；资源审计（未设计完，禁止实现）；p99 性能验收（数字未批准）；改 `logging_enabled` 默认值、开关位置或用户可见文案；隐私政策、官网、App Store 问卷的任何改动（待 Human 决定）；修复 m/n 或任何产品行为；改选拼音循环或删除的现有控制流。
- **设计依据:** 设计 r2（外置 `~/.kos-work/Universe-Keyboard/T9-PINYIN-CYCLE-009/reports/design-diag-journal-r2.md`，SHA-256 `852dff347c55b31137f908b24d6839ff693e74b064ac97248a813661bd9161c8`）；Architecture：Alex r2 APPROVE（外置 `~/.kos-work/Universe-Keyboard/T9-PINYIN-CYCLE-009/reports/arch-review-r2.md`，SHA-256 `b5952533800b83e95290de471eb16821d368b007a2d0702e98c3d8aa339bce14`）；设计作者 Nick。
- **Required Inputs:** 设计 r2、Alex r2 审查、隐私对照报告、独立预检 PASS。

## Assignment

- **Domain Owner:** `UNKNOWN`
- **Executor:** `Executor R1` — 实现（代码）
- **Environment Executor:** 真机日志采集由 Human 在 iPhone 13 Pro 上执行
- **Human Dependency:** ①决定隐私分类（对照报告第 4 节问题清单）；②在真机复现并导出日志。含新事件的构建在 Human 决定隐私分类前不得进 TestFlight。
- **Architecture Reviewer:** `Architecture Reviewer`（轮次待定）— 实现架构复核，独立于设计作者与 Alex r2 之外的另一轮，由 PM 在 S1 完成后指派
- **Quality Reviewer:** `Quality Reviewer` — 质量复核

## Gates

- **Entry Criteria（S1）:** 本 Assignment 合入 main；S1 包独立预检 PASS 且基线重冻。
- **Exit Criteria（S1）:** 设计 r2 的测试全绿、App 与 Extension 同为 v7 构建通过、Quinn 质量复核与实现架构复核通过、PR 合并；之后另行规划真机日志采集。
- **Stop Conditions:** 设计绑定的代码位置被改动；准入链出现等待；采集开/关导致 `replaceInput` 次数不同；任何改动触及隐私文案或默认值；同一设计被拒两次交 Human。

## Handoff

- **Handoff Target:** `UNKNOWN`
- **Lifecycle Status:** `Assignment Pending` — 设计已通过 Architecture 审查，S1 实现待 Assignment 合入与独立预检
- **Revalidation Trigger:** `UNKNOWN`

## 引用的不确定项

- 隐私分类未决；官网在另一仓库 `UniverseWeb`，本仓库未找到。

## History

- 2026-11-14：登记本 Assignment（`Assignment Pending`）；见 [`PORTFOLIO.md`](../PORTFOLIO.md) PF-070。
