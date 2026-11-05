# Assignment: LAUNCH-STABILITY-001 — 主 App 挂起时的诊断日志与部署保护

Policy version: 1.0.0
record_id: LAUNCH-STABILITY-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active — 本地提交，待复核 |
| Current phase | 本地一个提交待独立复核 |
| Material non-claims | 不声称挂起时零共享锁；不改键盘扩展；clear / snapshot 不上门控 |
| Next handoff / decision | Product Lead 决定是否合并 |
| Residuals | R1-01：排空只覆盖主 App 诊断日志 append。已经开始的 clear（`advanceGenerationForClear`）不在排空范围内。R1-03：现有自动备份是主线程同步磁盘拷贝，没有单独的后台时间保护；上线后再处理。 |

---

## Authority

- **Task ID / Title:** LAUNCH-STABILITY-001 — 主 App 挂起时的诊断日志与部署保护
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** 2026-11-05（Asia/Shanghai）。Human 原话「可以列为上线前必修，但是要控制，不能无休无止地修下去。」实现包 SHA-256 `1069a78487d82a2bd075c662e39ce2723708180bfa51e9926e94a2650ffa0688`。
- **Product Approver:** Human Product Owner

## Boundary

- **Scope:** 主 App 在 inactive/background 时为诊断日志 append 申请后台时间并排空已登记调用；新建 RIME 部署任务时申请后台时间；retention 真正执行前看前台状态。
- **Non-goals:** 挂起时零共享锁、librime/leveldb 锁、clear/snapshot 门控与在途排空、键盘扩展改动。
- **Required Inputs:** 本包冻结输入（实现包 `task-package-pf057-impl-r2a.md` 及其点名的决定、设计与预检）。

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Executor
- **Environment Executor:** Executor Human 真机验证
- **Human Dependency:** 授权本包、真机锁屏验证、日后决定是否合并
- **Architecture Reviewer:** 独立只读复核
- **Quality Reviewer:** 独立只读复核
- **Product Approver:** Human Product Owner

## Gates

- **Entry Criteria:** Human 点名本包 SHA。
- **Exit Criteria:** 本地一个提交、验证全部通过、独立复核完成、真机清单执行。
- **Stop Conditions:** 冻结输入或起点不符、白名单外改动、新文件未进对应 target、写入被拒、提交身份不符或出现 AI 署名或 Co-authored-by、协议或设备问题需要扩大范围。STOPPED 优先。

## Handoff

- **Handoff Target:** Product Lead
- **Required Handoff Content:** 提交 SHA、报告路径与 SHA-256、验证日志与残余风险。
- **Revalidation Trigger:** 诊断日志锁协议、部署执行层或 Human 决定变化。

---

## History

| 阶段 | 记录 |
|---|---|
| R2a | 实现包 `task-package-pf057-impl-r2a.md`，SHA-256 `1069a78487d82a2bd075c662e39ce2723708180bfa51e9926e94a2650ffa0688`。 |
