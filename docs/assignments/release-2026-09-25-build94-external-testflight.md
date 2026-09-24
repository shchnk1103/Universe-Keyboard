# Assignment: RELEASE-2026-09-25-BUILD94-EXTERNAL-TESTFLIGHT — Build 94 外部 TestFlight 更新

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Complete — bounded external TestFlight distribution is active. |
| **Phase** | `1.0 (94)` 已由 Transporter 交付，App Store Connect 处理 Complete、Beta Review Approved；已加入既有 `Build 55 Public Beta` 组并显示 Testing。 |
| **Non-claims** | 独立 Quality/Release 仍为 Blocked；不声称正式 Release Gate Pass、App Store 发布或每位测试者已安装/收到通知。 |
| **Next** | 观察测试反馈；按 Product Owner 指示于 `2026-09-26` 开始复核 Build 55 的近期反馈。 |
| **Residuals** | TD-003、TD-004、TD-005、TYPO-CORRECTION-002 继续 Open；Product 风险决定见 [Build 94 决策](../product-decisions/RELEASE-2026-09-25-BUILD94-public-beta-decision.md)。 |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 在当前 Codex task 明确授权 Build 94 外部 TestFlight 更新，并接受本 Assignment 所列风险；`2026-09-25 Asia/Shanghai`
- **Product Approver:** Human Product Owner / Product Lead
- **Domain Owner:** Test / Release Maintainer
- **Executor:** 当前 Codex task
- **Environment Executor:** 当前 Codex task（Transporter 与 App Store Connect）
- **Human Dependency:** 当前授权范围内无待处理的人类前置事项；如 Apple 之后要求新的法律协议或权限变更，停止并交回 Human Product Owner
- **Architecture Reviewer:** Not Applicable — 本 Assignment 不修改代码、架构或产品合同
- **Quality Reviewer:** Build 94 独立 Quality reviewer；结论仍为 Blocked，见当前任务审阅结果
- **Handoff Target:** Human Product Owner；Build 94 现已在既有 TestFlight 外部组提供测试

## Scope

- 将精确的 Build 94 Store IPA 上传到 App Store Connect。
- 处理完成后，将 Build 94 加入已有外部组 `Build 55 Public Beta`，沿用现有组成员与公开链接。
- 按审核要求填写本 build 的 What to Test；Beta Review 必要时提交。
- Apple 批准并可分发后，通知现有组并核实 Build 94 对组内测试者可用。

## Non-goals

- 不创建新测试组或新邀请链接，不改变公开链接访问设置，不移除测试者。
- 不发布到 App Store 正式渠道，不修改源代码，不提交/推送/合并 Git。
- 不关闭技术债或改变独立 Quality/Release 结论。

## Candidate and Required Inputs

- Xcode Cloud Build ID: `13b91c4a-e672-4c6f-97a7-7867be644082`
- App Store Connect build ID: `029c1a01-a168-408f-b922-2e1c462adad8`
- Source commit: `50cdccc8d07e70cb02987c9fe0a17be55291701`
- App: Universe Keyboard; App Store Connect ID `6804236252`; bundle ID `com.DoubleShy0N.Universe-Keyboard`
- Store IPA: `Universe Keyboard.ipa` (executor-local temporary export; not retained as a durable repository artifact)
- IPA SHA-256: `500105b71b5cf532a32db18032c4c257d672d056955600dc8b2363ac984a772f`
- Export metadata: app and keyboard extension `1.0 (94)`; App Store Connect destination; `testFlightInternalTestingOnly=false`; Team `C33N6HTS9N`
- Archive/dSYM metadata: `1.0 (1)`; App and Keyboard executable UUIDs match their archived dSYMs and the IPA executables. Product Owner accepted this exact-build metadata risk; do not relabel the Archive as build 94.
- Existing external group: `Build 55 Public Beta`, group ID `7d76e4b0-e24c-4c2e-a46f-3d14dd9afe16`; preflight snapshot `2026-09-25 Asia/Shanghai`: 356 testers, one build and public link `https://testflight.apple.com/join/t48JR3Q3`.

## Entry Criteria

- [x] Product Lead explicitly authorized Build 94 external TestFlight scope and accepted the deferred risks in the linked Product Decision.
- [x] Exact candidate commit, IPA hash, version/build, team and external eligibility were verified.
- [x] App Store Connect showed no existing Build 94 before upload.
- [x] Existing group and public link were verified; no new group is needed.
- [x] Transporter delivered `1.0 (94)`; App Store Connect upload status is `Complete`.
- [x] App Store Connect accepted external Beta Review; Build 94 status is `Approved`.
- [x] Build 94 was added to the existing external group and its group build list shows `Testing`.

## Exit Criteria

- [x] App Store Connect shows the exact `1.0 (94)` build processed.
- [x] The existing group contains Build 94 and still has its pre-existing 356 testers and public link.
- [x] What to Test reflects the accepted test scope, Full Access prerequisite and privacy boundary.
- [x] Beta Review is approved.
- [x] Build 94 is listed as `Testing` in the existing group. Automatic tester notification was enabled at review submission; App Store Connect did not expose per-tester notification delivery receipts in the inspected views.
- [x] Execution evidence records tester count, group link, review state and build expiry.

## Execution Evidence

Observed in App Store Connect on `2026-09-25 Asia/Shanghai`:

- Transporter lists Universe Keyboard `1.0 (94)` as delivered; App Store Connect upload status is `Complete`.
- App Store Connect build ID is `029c1a01-a168-408f-b922-2e1c462adad8`; external Beta Review status is `Approved`; expiry is shown as `90 days`.
- The existing `Build 55 Public Beta` group (ID `7d76e4b0-e24c-4c2e-a46f-3d14dd9afe16`) shows `356 Testers` and `2 Builds`, with the existing public link `https://testflight.apple.com/join/t48JR3Q3` unchanged.
- The group Builds tab lists Build `1.0 (94)` as `Testing` alongside `1.0 (55)`. The review submission dialog had `Automatically notify testers` enabled. The inspected App Store Connect views showed availability, but no per-tester notification-delivery receipt.
- The What to Test text saved on Build 94 describes current test scope and open limitations; it requests Full Access and prohibits sharing actual typed content or other private information.
- No new group, invitation link, or individual tester invitation was created. No App Store release, Git commit, push, or merge was performed.

## Stop Conditions

Stop before external group assignment or notification if the uploaded build's ID, version, bundle ID, hash lineage or signing team is wrong; Apple reports a blocking validation issue; the existing group/link no longer matches; an unanticipated agreement, account permission or access change is required; tester instructions cannot truthfully describe the approved scope; or a stop condition in the Product Decision is observed.

## Revalidation Trigger

Any IPA/hash/build change, different ASC app/group, membership or link change, Product Owner withdrawal, material Apple review issue, or risk/scope change invalidates this Assignment.
