# Assignment: LAUNCH-STABILITY-001 — 主 App 挂起时的诊断日志与部署保护

Policy version: 1.0.0
record_id: LAUNCH-STABILITY-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active — 已合并（[PR #270](https://github.com/shchnk1103/Universe-Keyboard/pull/270)，合并提交 `9c988dcd398b59894655531fc3446178c41950d5`，2026-11-05），待 Product Lead 决定 Close |
| Current phase | PF-057 实现 R2a（`9a053f847614e8a207c5d43d9fbb850be7a92984`）独立复核 Pass；PF-060 缝隙修复（`e743173571f46709ed0e441e05c500d6966e29ae`）独立复核 Pass with conditions；两者随整合 PR #270 合并；Human 2026-11-05 概括反馈真机通过 |
| Material non-claims | 不声称挂起时零共享锁；PF-057 不改键盘扩展；clear / snapshot 不上门控；PF-060 缝隙修复涉及键盘扩展 |
| Next handoff / decision | Product Lead 决定是否 Close；上线后项见 PORTFOLIO 的 PF-061 至 PF-064 |
| Residuals | R1-01：排空只覆盖主 App 诊断日志 append。已经开始的 clear（`advanceGenerationForClear`）不在排空范围内。R1-03：现有自动备份是主线程同步磁盘拷贝，没有单独的后台时间保护；上线后再处理。PF-060：按下顺序未改；M5（同一缝隙两指、同一按键的缝隙与键帽同时按下）行为未定义。Human 接受同一缝隙双指作为上线前已知限制；另一场景的单独接受情况 UNKNOWN。 |

---

## Authority

- **Task ID / Title:** LAUNCH-STABILITY-001 — 主 App 挂起时的诊断日志与部署保护
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** 2026-11-05（Asia/Shanghai）。Human 原话「可以列为上线前必修，但是要控制，不能无休无止地修下去。」实现包 SHA-256 `1069a78487d82a2bd075c662e39ce2723708180bfa51e9926e94a2650ffa0688`。
- **Product Approver:** Human Product Owner

## Boundary

- **Scope:** 主 App 在 inactive/background 时为诊断日志 append 申请后台时间并排空已登记调用；新建 RIME 部署任务时申请后台时间；retention 真正执行前看前台状态。PF-060：按键缝隙控件不再独占触摸（只修缝隙）。
- **Non-goals:** PF-057 不保证挂起时零共享锁，不处理 librime/leveldb 锁、clear/snapshot 门控与在途排空，也不改键盘扩展。
- **Required Inputs:** 本包冻结输入（实现包 `task-package-pf057-impl-r2a.md` 及其点名的决定、设计与预检）。

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Executor
- **Environment Executor:** Executor Human 真机验证
- **Human Dependency:** 真机概括反馈已收到；Product Lead 决定是否 Close，后续发布另需授权。
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
| PF-060 R2 | 实现包 `task-package-pf060-gap-r2.md`，SHA-256 `ed3f4f7edbd8524a559acfb8505ded9897fe693ee206ad6c8730c6ee354baf83`。 |
| 合并 | 随外置 RELEASE-20261105 整合合并：PR #270，合并提交 `9c988dcd398b59894655531fc3446178c41950d5`。 |
