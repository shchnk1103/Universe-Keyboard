# Assignment: ENV-TOOLING-001 — Reproducible Environment Digest Capability

**Policy version：** `1.0.0`
**Decision date：** `2026-07-02 Asia/Shanghai`
**Decision source：** Product Lead — ENV-TOOLING-001 Assignment Decision
**Lifecycle status：** `Accepted / Closed`

**Closure synchronization：** Product Review accepted the capability; Engineering Dashboard records `Accepted / Closed`. Header synchronized under DOC-HYGIENE-001 on `2026-07-17` without reopening scope.

---

## Authority

- **Assignment Authority：** 🧭 Product Lead
- **Product Approver：** 🧭 Product Lead
- **Permanent Domain Ownership：** 🔧 RIME Platform Maintainer
- **Assignment Revalidation Authority：** 🧭 Product Lead

本 Assignment 不改变任何长期角色、Product Contract、Architecture Decision 或 Quality Gate。

---

## Assignment

- **Domain Owner：** 🔧 RIME Platform Maintainer
- **Executor：** 🔧 RIME Platform Maintainer
- **Environment Executor：** `Not Applicable — capability implementation and fixture verification do not require a physical-device environment`
- **Human Dependency：** `Not Applicable — implementation does not require physical access, credentials or human system-setting actions`
- **Architecture Reviewer：** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer：** 🧪 Quality, Performance & Release Maintainer
- **Handoff Target：** 🧪 Quality Maintainer；Architecture/Quality Review 后交回 🧭 Product Lead

---

# Scope

ENV-TOOLING-001 负责建立可重复、可审计、非 Runtime 的 environment digest/manifest 工程能力。

允许范围仅包括：

1. Schema digest；
2. Shared runtime digest；
3. User configuration digest；
4. Effective configuration digest；
5. Canonical clean-state manifest digest；
6. 每类 digest 的受控输入集合；
7. deterministic ordering 和 canonical representation；
8. SHA-256 输出；
9. 参与 digest 的文件清单；
10. approved exclusion 记录；
11. 缺失、不可读、越界和不受支持输入的 fail-closed 结果；
12. controlled fixtures；
13. capability tests；
14. `docs/ENVIRONMENT_DIGEST_TOOLING.md`；
15. 给 004C-R1 的使用和 provenance handoff。

Capability 可以被后续 004C-R1 Environment Capture 调用，但本任务不执行该 Capture。

---

# Non-goals

本任务不负责：

- 执行 004C-R1 final Environment Capture；
- 生成 Task 7 Evidence；
- 执行 Benchmark；
- 修改 Environment Template；
- 修改 Environment Capture Procedure；
- 修改 Assignment Policy；
- 修改 Registry 或 ADR；
- 修改 Product Contract；
- 修改 RIME Runtime、Bridge、Session 或 deployment；
- 在 Main App 或 Extension 热路径执行 hashing；
- 收集真实输入、surrounding text 或宿主文本；
- 读取或导出 RIME user dictionary 内容；
- 清理、迁移、部署、恢复或修改环境文件；
- 上传 digest、manifest 或文件；
- 将 source-tree digest 作为 deployed-runtime evidence；
- 决定 Environment Evidence 是否通过；
- 决定 Task 7 是否启动。

---

# Product Constraints

- Capability 必须是离线、显式调用的工程工具或测试能力。
- 不得进入普通按键处理路径。
- 不得改变被检查文件。
- Manifest 不得保存文件内容。
- Manifest 中的路径必须遵守隐私和必要的脱敏规则。
- User configuration 与 RIME user learning data 必须明确分离。
- 同一受控输入必须产生相同 digest。
- 输入内容变化必须产生可观察变化。
- source、deployed runtime、user configuration、effective configuration 和 clean state 不得混淆。
- 不可取得的输入必须 fail closed，不得推断为成功。
- Fixture 结果不能作为物理设备或当前 Runtime Evidence。
- Capability completion 不解除 004C-R1 的实际采集义务。

---

# Required Inputs

以下输入必须在进入 `Ready` 前取得：

1. Assignment Policy v1.0.0；
2. Environment Evidence Template v1.0.0；
3. Environment Capture Procedure v1.0.0；
4. Architecture 已完成的 ENV-TOOLING-001 work package；
5. 004C-R1 固定 schema：`rime_ice`；
6. Template 对五类 digest 的字段和 provenance 要求；
7. 每类 digest 的允许根目录；
8. 每类 digest 的 include contract；
9. 每类 digest 的 exclude contract；
10. User configuration 与 user data 的边界；
11. Manifest canonicalization contract；
12. Quality verification matrix；
13. 实现基线 commit；
14. Executor Acknowledgement；
15. 可隔离的工作树或 worktree；
16. Architecture 对隐私和文件范围的确认。

如 Architecture work package 中的上述事实无法独立取得，Executor 必须标记具体缺失项，不得自行补充合同。

---

# Entry Criteria

任务进入 `Ready` 必须同时满足：

- Assignment Record 已完整发布；
- Executor 已 Acknowledged；
- 没有 Assignment 字段为 `UNKNOWN`；
- 实现基线 commit 已冻结；
- 工作范围能够与其他修改隔离；
- Architecture 已确认允许根目录和排除范围；
- Architecture 已确认 user configuration 不包含 RIME user learning data；
- Quality 已确认 verification matrix；
- Manifest canonicalization contract 明确；
- Capability 实现不依赖物理设备；
- Capability 实现不要求访问真实用户数据；
- Capability 实现不要求修改 Runtime 或治理资产；
- `docs/ENVIRONMENT_DIGEST_TOOLING.md` 的 Source-of-Truth 定位已确认；
- Stop Conditions 已被 Executor 接受。

满足上述条件前，任务不得进入 `Ready` 或 `Active`。

---

# Deliverables

Executor 必须交付：

1. Reproducible digest capability；
2. Schema digest 支持；
3. Shared runtime digest 支持；
4. User configuration digest 支持；
5. Effective configuration digest 支持；
6. Clean-state manifest digest 支持；
7. Canonical ordering/representation；
8. 受控文件清单；
9. Approved exclusions；
10. Manifest schema；
11. SHA-256 结果；
12. 缺失输入处理；
13. 不可读输入处理；
14. 越界输入处理；
15. deterministic repeatability tests；
16. input-change detection tests；
17. privacy/user-data exclusion tests；
18. source/deployed-runtime separation tests；
19. `docs/ENVIRONMENT_DIGEST_TOOLING.md`；
20. 修改文件清单；
21. focused tests；
22. 相关完整测试或未执行原因；
23. `git diff --check`；
24. production/runtime scope check；
25. Architecture Review；
26. Quality Review；
27. implementation commit；
28. 给 004C-R1 的 capability usage handoff；
29. residual risks 和 unsupported conditions。

---

# Exit Criteria

任务只有在以下条件全部满足后才能标记 `Completed`：

- 五类 digest 均具备明确输入、输出和 provenance；
- 同一输入重复运行结果一致；
-批准范围内的输入变化能够被检测；
-参与文件集合可审计；
-排除项可审计；
-缺失、不可读和越界输入 fail closed；
-没有读取或导出 user dictionary 内容；
-没有记录真实用户输入；
-没有生产 Runtime、Bridge、Session 或 deployment 修改；
-没有按键热路径 hashing；
-Template、Procedure、Policy、Registry、ADR 和 Product Contract 未修改；
-文档 Source of Truth 已建立；
-测试结果和未执行项完整报告；
-Architecture Review 通过；
-Quality Review 给出明确结论；
-implementation commit 可追溯；
-004C-R1 能够在新 Assignment Revalidation 后使用该 capability。

`Completed` 不等于 `Accepted / Closed`。最终关闭由 Product Lead 决定。

---

# Stop Conditions

出现以下任一情况，Executor 必须停止并将任务标记为 `Blocked`：

- 需要修改 RIME Runtime、Bridge、Session 或 deployment；
- 需要修改 Main App/Extension 产品行为；
- 需要在按键热路径扫描或 hashing；
- 需要访问 RIME user database；
- 无法区分 user configuration 与 user learning data；
- 需要读取真实输入、surrounding text 或宿主文本；
- 需要修改、删除或迁移被检查文件；
- digest 语义与 Accepted Template 冲突；
- 需要改变 Environment Capture Procedure；
- 只能从 source tree 推断 deployed-runtime digest；
- Manifest 必须包含敏感文件内容或未脱敏路径；
- Capability 本身必须依赖物理设备才能验证；
- 需要新增或 supersede ADR；
- 需要修改 Product Contract 或 Registry；
- Scope 扩大到 Environment Capture、Benchmark 或 Task 7；
- Quality verification matrix 与 Architecture boundary 冲突；
- Required Input 发生变化或失效。

架构问题交给 Architecture Steward；证据问题交给 Quality；产品范围和 Assignment 问题交回 Product Lead。

---

# Lifecycle Definition

最终状态：

> `Accepted / Closed`

已执行路径：

```text
Assigned
  → Acknowledged
  → Ready
  → Active
  → Completed
  → Architecture Reviewed
  → Quality Reviewed
  → Product Reviewed
  → Accepted / Closed
```

关闭表示 ENV digest capability 已被 Product 接受。`004C-R1` 仍需独立 Entry Criteria 与 lifecycle，不得因本关闭而自动进入 Ready。

---

# Revalidation Trigger

以下任一变化触发 Assignment Revalidation：

- Domain Owner、Executor 或 Reviewer 变化；
- Scope 或 Non-goals 变化；
- 新增第六类 digest；
- include/exclude contract 变化；
- User configuration/user data 边界变化；
- Manifest canonicalization 变化；
- Environment Template 或 Procedure 变化；
- Registry、ADR 或 Product Contract 变化；
- 实现需要物理设备；
- 实现需要 Runtime/App Group live access；
- 实现基线 commit 变化；
- Quality Gate 变化；
- Architecture Stop Condition 被触发；
- 任务暂停后依赖版本已更新；
- 004C-R1 对 capability 的 provenance 要求发生变化。

Revalidation 只能由 Product Lead批准。

---

# Required Handoff Content

Executor 完成后必须向 Quality 提交：

- Assignment ID 和 Policy version；
- 实现基线与最终 commit；
- Scope/Non-goals 符合性；
- 修改文件；
-五类 digest 的输入输出；
- include/exclude contract；
- Manifest 示例；
-测试命令和结果；
-隐私与 user-data 边界；
- Stop Condition 状态；
-未验证项；
- Architecture Review；
-给 004C-R1 的使用说明；
- residual risks；
- closure recommendation。

Quality Review 后，完整 Handoff 返回 Product Lead。

---

# Final Assignment Decision

> **ENV-TOOLING-001：Accepted / Closed**

该记录是 ENV-TOOLING-001 的完整 Product Assignment Contract 与关闭同步。

后续使用该 capability 的任务（例如 `004C-R1`）必须通过各自 Assignment 与 Quality handoff 路由，不得重新打开本 Work Item 的 Scope。

不授权实现。

Task 7 继续保持 `Not Authorized`。
