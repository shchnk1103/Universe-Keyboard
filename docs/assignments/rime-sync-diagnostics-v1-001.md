# Assignment: RIME-SYNC-DIAGNOSTICS-V1-001 — Automatic Sync Typed Diagnostics

**Policy version:** `1.0.0`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | 首轮独立复核 findings 已处置、最终完整本地门禁通过；Architecture / Quality 最终 diff 复核 pending |
| **Non-claims** | 不恢复旧轮次 legacy 日志，不证明自然后台调度、真机成功、Product Gate、merge 或 Release |
| **Next** | 分别完成 Architecture / Quality 独立复核并处置条件；随后交回 Product Review，另行决定是否冻结新真机载荷 |
| **Residuals** | [`TD-013`](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化)；旧轮次精确错误码保持 `UNKNOWN` |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 在当前 RIME 自动同步排查线程中确认记录总开关和全部分类开启，并于 `2026-09-01 Asia/Shanghai` 授权在合同后实现最小 v1 自动同步诊断。
- **Product Approver:** Product Lead acting under the Human Product Owner's explicit direction

## Boundary

- **Scope:**
  1. 为前台自动私密设置同步和后台自动标准/私密同步建立内容无关的 `Diagnostics/v1` typed events。
  2. 以 operation ID 关联入口、阶段、跳过与唯一终态；覆盖 BGTask expiration 与异步取消竞争。
  3. 使用有限枚举记录来源、阶段、结果、跳过原因和失败分类。
  4. 为协议编码/解码、隐私字段、进程 gate 竞争、阶段顺序和唯一终态增加自动化测试。
  5. 更新 RIME sync、debugging、技术债和执行证据。
- **Non-goals:**
  - 不桥接、批量迁移或删除其他 legacy `Logger(String)` producer。
  - 不读取、复制或迁移现有 `rime_diag_log`；不追认旧轮次错误码。
  - 不改变同步、通知、文件夹授权、RIME bridge、冷却时间或进程 gate 产品语义。
  - 不记录路径、文件名、bookmark、NSError domain/text、词典、候选、输入内容、密钥或凭据。
  - 不把诊断放入 Universe 私密同步包或任何网络传输。
- **Required Inputs:** `RIME-SYNC-001`、`RIME_SYNC.md`、ADR 0003/0007/0027、`DEBUGGING.md`、`PRIVACY_POLICY.md`、TD-013、当前进程 gate 实现与自然真机失败证据。

## Assignment

- **Domain Owner:** App & Data Operations Maintainer
- **Executor:** App & Data Operations Maintainer
- **Environment Executor:** Quality, Performance & Release Maintainer for local Swift 6 test/build evidence
- **Human Dependency:** Human Device Operator only for a later separately frozen physical-device round; not required for implementation readiness
- **Architecture Reviewer:** Architecture & Knowledge Steward, independently reviewing persisted protocol, privacy allowlist and terminal ownership
- **Quality Reviewer:** Quality, Performance & Release Maintainer, independently reviewing event completeness, test evidence and non-claims
- **Product Approver:** Product Lead
- **Handoff Target:** Product Lead for Product Review and authorization of a new frozen device round

## Entry Criteria

- Human implementation authorization is explicit and all Assignment responsibilities are known.
- The existing process-gate remediation remains a separate committed checkpoint.
- Event fields are finite enums and cannot carry arbitrary strings or synchronized/user content.
- Diagnostics failure, filtering or backpressure cannot change synchronization behavior or task completion.

## Exit Criteria

- Every foreground/background automatic invocation has one operation ID and an observable invoked, skipped or phase-start path.
- A claimed operation records finite phase transitions and at most one terminal event, including expiration/cancellation races.
- A competing automatic entry records `process_busy` and does not record a phase start or publish sync notifications.
- Tests cover typed round-trip, invalid payload rejection, privacy key absence, phase sequence, contention and unique terminal ownership.
- Swift format, KeyboardCore, RimeBridgeTests, App + Keyboard tests, strict Debug and Release builds pass on the final diff.
- Independent Architecture and Quality reviews publish conclusions and every condition has an explicit disposition.
- Documentation states that these events apply only to a new build and do not recover the old natural-run error code.

## Stop Conditions

- A needed field cannot be represented by a reviewed finite enum.
- Implementation requires paths, raw errors, bookmarks, dictionary/input content, synchronous diagnostic I/O in business execution, or network transmission.
- Logging failure changes a sync result, notification, retry, gate lease or BGTask completion.
- Existing v1 schema compatibility cannot be preserved without a broader migration decision.
- Work overlaps unrelated dirty files or requires RIME/Extension behavior changes.

## Revalidation Trigger

Revalidate on any new sync source, phase, field, failure category, retention/export behavior, Extension producer, network/upload path, product copy, or change to synchronization semantics.
