# Assignment: RIME-ENV-001 — Restore Pinned librime XCFramework Verification Environment

**Policy version：** `1.0.0`
**Decision source：** Product Lead — RIME-ENV-001 Routing Decision
**Lifecycle status：** `Assigned / Not Ready`
**Assignment Authority：** 🧭 Product Lead

---

## Assignment

- **Domain Owner：** 🔧 RIME Platform Maintainer
- **Executor：** 🔧 RIME Platform Maintainer
- **Environment Executor：** 🔧 RIME Platform Maintainer
- **Human Dependency：** Universe Keyboard 人类项目负责人（当前用户）— 在 Executor 发起恢复操作时批准访问唯一 canonical public artifact URL 和必要的外部网络访问；不需要提供账号、token 或其他凭据
- **Architecture Reviewer：** `Not Required — unless artifact source、version、manifest 或 integration boundary must change`
- **Quality Reviewer：** 🧪 Quality, Performance & Release Maintainer
- **Product Approver：** 🧭 Product Lead
- **Handoff Target：** 🧪 Quality Maintainer；Quality Environment Review 后交给 ENV-TOOLING-001 和 🧭 Product Lead

本 Assignment 不改变 RIME Platform 的长期所有权。

---

# Scope

RIME-ENV-001 只负责恢复 ENV-TOOLING-001 动态 Release graph 验证所需的 pinned librime XCFramework 环境。

允许范围：

- 使用当前受信任 artifact manifest；
- 使用仓库既有 artifact restoration 流程；
- 恢复缺失的 11 个 librime XCFramework；
- 验证 artifact identity；
- 验证 artifact version；
- 验证 checksum；
- 验证所需平台和 architecture slices；
- 验证 Main App 构建环境能够解析依赖；
- 验证 Keyboard Extension 构建环境能够解析依赖；
- 验证 RimeBridge 构建环境能够解析依赖；
- 记录恢复来源、命令、receipt 和环境状态；
- 为 Q-SHP-002、Q-SHP-003、Q-SHP-004 重跑提供环境 Handoff。

本任务只恢复验证环境，不执行 ENV-TOOLING-001 的最终 Quality Gate。

---

# Non-goals

本任务不负责：

- 升级 librime 版本；
- 替换 artifact 来源；
- 修改 artifact manifest；
- 使用 Homebrew librime 替代 pinned XCFramework；
- 从源码重新构建并发布新的 vendor artifact；
- 修改 Runtime、RimeBridge 行为或 Session Contract；
- 修改 Main App 或 Keyboard Extension 产品逻辑；
- 修改 ENV-TOOLING-001 实现；
- 修改 Quality Matrix；
- 降低或跳过 Q-SHP-002/003/004；
- 判定 ENV-TOOLING-001 Accepted；
- 执行 004C-R1；
- 执行 Benchmark；
- 启动 Task 7。

---

# Product Constraints

- 只能恢复当前 manifest 已固定的 artifact。
- artifact version、source、checksum 和 slices 必须与当前合同一致。
- 不得使用“能够链接”代替 identity/checksum 验证。
- 不得使用静态 membership 代替动态 Release graph。
- 不得使用 Homebrew 或本机临时库作为 iOS XCFramework 证据。
- 不得修改生产代码以适配缺失 artifact。
- 不得降低签名、链接或 dependency exclusion 要求。
- 不得把环境恢复结果标记为 ENV-TOOLING-001 Quality Passed。
- 外部下载、凭据或网络访问必须具有明确授权。
- 恢复过程必须可重复并可追溯。

---

# Required Inputs

进入 `Ready` 前需要：

- Assignment Policy v1.0.0；
- RIME-ENV-001 Routing Decision；
- ENV-TOOLING-001 Assignment；
- ENV-TOOLING-001 Quality Verification Matrix；
- Q-SHP-002、Q-SHP-003、Q-SHP-004 的验证要求；
- 当前受信任 librime artifact manifest；
- 11 个预期 XCFramework 的完整清单；
- 预期 artifact version；
- 预期 checksums；
- 预期平台和 architecture slices；
- 仓库既有 artifact restoration 流程；
- implementation/environment baseline commit：`74c8ff3b578b4b28d831bf63df914ee6c3093165`；
- canonical artifact source：`https://github.com/shchnk1103/Universe-Keyboard/releases/download/rime-vendor-ios-1.16.1-lua.1/universe-keyboard-rime-vendor-ios-1.16.1-lua.1.zip`（实际可访问性须在进入 `Ready` 前验证）；
- network/external access requirement：`Required — HTTPS access to the single pinned public GitHub Release asset above; no external credentials required`；
- Human Dependency 决策：`Required and assigned to the Universe Keyboard human project owner`；
- Executor Acknowledgement；
- Quality 对环境 Handoff 字段的确认；
- 可隔离的工作树或 worktree。

---

# Entry Criteria

RIME-ENV-001 进入 `Ready` 必须满足：

- Assignment Record 已发布；
- 所有 Required Assignment 字段已明确；
- Human Dependency 已指定或 justified `Not Applicable`；
- baseline commit 已冻结；
- Executor 已 Acknowledged；
- 11 个目标 XCFramework 清单已确认；
- manifest、version、checksum 和 slice contract 已确认；
- canonical restoration workflow 已确认；
- artifact source access 已确认；
- 必要网络、凭据或外部访问已授权；
- Quality 已确认 Handoff 所需证据字段；
- 工作范围能够与其他修改隔离；
- 不需要改变 artifact source、version、manifest 或 integration boundary；
- 不存在 Architecture Stop Condition。

任一 `UNKNOWN` 未解决时不得进入 `Ready` 或 `Active`。

---

# Deliverables

Executor 必须交付：

1. 11 个目标 XCFramework 清单；
2. 每个 XCFramework 的恢复状态；
3. artifact source；
4. artifact version；
5. expected checksum；
6. observed checksum；
7. required slices；
8. observed slices；
9. restoration commands；
10. restoration timestamps；
11. artifact receipts；
12. manifest alignment report；
13. Main App dependency-resolution result；
14. Keyboard Extension dependency-resolution result；
15. RimeBridge dependency-resolution result；
16. 动态 Release graph 验证的环境可用性结论；
17. 缺失、损坏或不匹配 artifact 清单；
18. 未执行项及原因；
19. 环境和工具版本；
20. baseline commit；
21. 工作树状态；
22. `git diff --check` 或不适用说明；
23. production-code scope report；
24. Quality Environment Review package；
25. 给 ENV-TOOLING-001 的 Handoff；
26. residual risks 和 retry conditions。

---

# Exit Criteria

任务只有在以下条件全部满足后才能标记 `Completed`：

- 11 个 XCFramework 全部存在；
- identity 与 manifest 一致；
- version 与 manifest 一致；
- checksums 全部匹配；
-所需平台和 architecture slices 完整；
-没有使用 Homebrew 或未经批准的替代 artifact；
- Main App 构建环境能够解析依赖；
- Keyboard Extension 构建环境能够解析依赖；
- RimeBridge 构建环境能够解析依赖；
- Quality 确认环境足以重跑 Q-SHP-002/003/004；
-恢复过程和 artifact receipt 可追溯；
-没有修改 artifact version、source、manifest 或 integration contract；
-没有修改生产逻辑；
-所有未执行项和风险已报告；
-完整 Handoff 已交付。

`Completed` 不等于 `Closed`。Quality Environment Review 和 Product closure 仍然必须完成。

---

# Stop Conditions

出现以下任一情况必须停止并标记 `Blocked`：

- canonical artifact source 不可访问；
-恢复需要未授权网络、凭据或外部访问；
- manifest 缺少 artifact identity 或 checksum；
- artifact checksum 不匹配；
- artifact version 不匹配；
-所需 architecture slice 不存在；
-必须升级或降级 librime；
-必须替换 artifact source；
-必须修改 artifact manifest；
-必须使用 Homebrew 或临时本机库替代；
-必须从源码重建并发布 vendor artifact；
-必须修改 RimeBridge、Runtime、Session 或产品逻辑；
-必须降低 Q-SHP-002/003/004；
-工作范围扩大到 ENV-TOOLING-001 实现整改；
-工作范围扩大到 004C-R1、Benchmark 或 Task 7；
- baseline、manifest 或 dependency contract 发生变化；
-需要新的 Architecture Decision 或 ADR。

artifact source、version、manifest 或 integration boundary 变化必须交给 Architecture 与 Product Lead。

---

# Lifecycle

当前状态：

> `Assigned / Not Ready`

正常转换：

```text
Assignment Pending
  → Assigned
  → Acknowledged
  → Ready
  → Active
  → Completed
  → Quality Environment Reviewed
  → Product Reviewed
  → Closed
```

异常转换：

```text
Assigned / Acknowledged / Ready / Active
  → Blocked
  → Product Revalidation
  → Reassigned or Ready
```

所有 Assignment responsibility 和原有 `UNKNOWN` 字段均已解决。当前尚不允许进入 `Ready`，直到 Executor Acknowledgement、canonical source 实际可访问性、网络访问批准、隔离工作树、Quality Handoff 字段和 manifest/checksum/slice contract 均已确认。

---

# Revalidation Trigger

以下任一变化触发 Assignment Revalidation：

- Domain Owner、Executor、Environment Executor 或 Reviewer 变化；
- Human Dependency 变化；
- baseline commit 变化；
- artifact manifest 变化；
- librime version 变化；
- artifact source 变化；
- checksum 变化；
- XCFramework 清单变化；
- platform 或 architecture slice contract 变化；
- restoration workflow 变化；
- Quality Matrix 或 Q-SHP 要求变化；
- Scope 或 Non-goals 变化；
-需要源码重建 vendor artifact；
-需要 Runtime/RimeBridge/Session 修改；
-任务暂停后依赖状态失效；
- ENV-TOOLING-001 取消或改变其动态 Release graph 要求。

Revalidation 只能由 Product Lead批准。

---

# Required Handoff

完成后向 Quality 提交：

- Assignment ID 和 Policy version；
- baseline commit；
-恢复环境身份；
- 11 个 XCFramework inventory；
- source/version/checksum/slice matrix；
- artifact receipts；
- restoration commands；
- Main App、Extension、RimeBridge dependency-resolution 状态；
-动态 Release graph readiness；
-未执行项；
- Stop Condition 状态；
- residual risks；
- retry conditions；
-是否足以重跑 Q-SHP-002/003/004。

Quality Review 后向 ENV-TOOLING-001 和 Product Lead 提交：

- Quality Environment Decision；
-可重跑的 checks；
-剩余 blocker；
-环境有效期和 Revalidation Trigger；
- closure recommendation。

---

# Final Assignment Decision

> **RIME-ENV-001：Assigned / Not Ready**

该记录是 RIME-ENV-001 canonical Assignment 的唯一 Product Source of Truth。

当前只允许：

- RIME Platform Maintainer 基于 baseline `74c8ff3b578b4b28d831bf63df914ee6c3093165` 审阅并 Acknowledge Assignment；
- RIME Platform Maintainer 准备隔离 worktree；
- RIME Platform Maintainer 验证 canonical source 的访问前置；
- Quality 确认 Handoff 字段；
- Program Manager 检查 Entry Criteria 并记录 Readiness Handoff。

不授权环境恢复。

不授权 ENV-TOOLING-001 Quality rerun。

不授权 004C-R1、Benchmark 或 Task 7。
