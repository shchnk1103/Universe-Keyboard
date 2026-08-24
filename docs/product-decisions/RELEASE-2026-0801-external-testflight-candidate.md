# Product Decision: RELEASE-2026-0801 — 外部 TestFlight 候选执行边界

**Decision ID:** `PD-RELEASE-2026-0801-EXTERNAL-TESTFLIGHT-CANDIDATE`
**Lifecycle status:** `Recorded`
**Date / timezone:** `2026-08-21 Asia/Shanghai`
**Assignment:** [`RELEASE-2026-0801`](../assignments/release-2026-08-01.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Recorded` |
| **Phase** | 外部 TestFlight 候选准备；Cloud Archive/签名 pilot 与部分 TestFlight test information 已完成，最终 RC 仍未冻结 |
| **Non-claims** | Pilot 不授权冻结 RC、上传、外部测试、提交审核或接受 TD-003/004/005 风险 |
| **Next** | 进入颜表情与剩余修复，最后冻结 RC；内容版权与主要类别已由 Human 报告在线保存 |
| **Residuals** | 见 [`release-2026-08-01-acceptance.md`](../evidence/release-2026-08-01-acceptance.md) |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead
- **Decision Source:** Human Product Owner 在 Active Codex 任务中于 `2026-08-21 Asia/Shanghai` 明示：目标为外部 TestFlight 候选；颜表情在其余必要准备后完成；后续修复提交完成后再冻结 RC；开通 Apple Developer Program 后优先使用 Xcode Cloud 构建上传；当前只有 iPhone 13 Pro / iOS 27 真机，最低系统与 iPad 前置兼容性使用 Simulator 补充
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

本 Decision 只确定本次发布的阶段顺序、构建环境意图与候选证据边界。它不改变 App/Keyboard 架构、RIME 所有权、Full Access 合同或外部发布权限。

## Bound Product Decisions

1. 当前中间目标是 **可提交 TestFlight App Review 的外部测试候选**，不是仅限内部的开发构建，也不是 App Store 正式提交。
2. 执行顺序固定为：
   1. 完成除颜表情外的发布前必要准备；
   2. 完成 [`RELEASE-2026-0801-08`](../assignments/release-2026-08-01-08-kaomoji-content.md) 颜表情及剩余修复；
   3. 独立复验后冻结精确 RC commit/tag、版本与 build；
   4. 在稳定工具链上执行最终 CI、签名 Archive、内部预检与外部 TestFlight Review 交接。
3. 当前 `macOS 27 beta + Xcode 27 beta` 只可作为开发/诊断环境，不得升格为最终稳定发布证据。本机 Xcode 26.6 不作为受支持发布环境的默认假设。Apple Developer Program、App Store Connect App Record 与权限可用后，优先通过 **Xcode Cloud 的稳定 Xcode 环境**执行最终 CI、Archive、签名和上传准备；Cloud pilot 必须先证明仓库依赖、scheme、签名与 artifact retention 可用。
4. 外部候选的前置设备矩阵收窄为：
   - **物理设备：** iPhone 13 Pro / iOS 27，负责 Keyboard Extension 真实生命周期、Full Access、性能、内存、终止与宿主切换；
   - **兼容性 Simulator：** iOS 18 iPhone 与 iPad，负责最低系统启动、基础功能、布局和自动化；
   - Simulator 不得替代物理设备性能、Jetsam、Full Access 或硬件相关结论。物理 iPad 与较低系统真机证据可在外部 TestFlight 获批后的定向测试中补齐，并在 App Store 正式提交前重新裁决。
5. [`TD-003`](../TECH_DEBT.md#td-003-collect-extension-performance-baseline)、[`TD-004`](../TECH_DEBT.md#td-004-implement-full-access-degradation-matrix)、[`TD-005`](../TECH_DEBT.md#td-005-complete-crash-jetsam-and-symbolication-handbook) 仍是外部测试候选 Gate；本 Decision 不接受或跳过它们。精确处置继续遵守 [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md) 的 TestFlight Debt And Risk Decision。
6. 若需要先用同一最终构建做内部预检，上传方式必须保持该构建可进入外部 TestFlight；不得把最终候选标记为 `TestFlight Internal Only`。内部组预检、上传和后续外部 Review 仍分别需要 Human Product Owner 的明确外部动作授权。
7. ADR 0005 的恢复前安全备份已有源码与单测覆盖，但这不关闭 [`TD-002`](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access) 的跨进程并发边界。外部测试若保留手动 restore/reset，必须在 Product Gate 中选择并记录：关闭 Extension 后操作的明确测试约束，或完成并验证并发协调；不得因改用 Xcode Cloud 而跳过。

## Explicit Non-authorization

- 现在冻结 `0de510d` 或任何其他提交为 RC
- 开通或付费加入 Apple Developer Program
- 创建/修改 App Store Connect App、测试组、权限、证书或 Cloud 工作流
- 上传 Archive、分发内部/外部 TestFlight、提交 TestFlight App Review 或 App Store Review
- 把 Simulator 结果写成真机性能、Full Access、Jetsam、iPad 物理设备或完整兼容性结论
- 在其余准备未完成前开始颜表情实现
- 接受、跳过或关闭 TD-003/004/005

## Subsequent Bounded Authorization

- `2026-08-21 Asia/Shanghai`：Human Product Owner 完成 Apple Developer Program 开通，并在 Codex 明示 GitHub 持久仓库访问边界后回复 `继续`，授权连接当前仓库与配置一个不含 TestFlight 分发的 Cloud pilot。
- Xcode Cloud 已连接 GitHub，并创建 `Default` workflow。手动 Build 1 已在功能分支 `codex/external-testflight-cloud-prep` / 提交 `cdc6bfe` 上通过：Xcode 26.6（17F113）、macOS Tahoe 26.6.2（25G83）、`ci_post_clone.sh` 成功、12 个 RIME framework artifacts 验证成功、`Universe Keyboard` iOS build 完成且无 Issues。
- 该 Build action 不是 Archive，也未验证签名、dSYM/artifact retention 或上传；不得外推为可分发候选。
- 本授权不包含合并 `main`、冻结 RC、添加 TestFlight post-action、上传、分发、Beta Review、App Store Review 或风险接受。
- `2026-08-22 Asia/Shanghai`：Human Product Owner separately authorized creating `Archive Pilot (No Distribution)` and running one manual `main` Archive. Build 3 on `4fd3ce7` succeeded with Xcode 26.6 / macOS Tahoe 26.6.2, including App Store distribution signing. Distribution Preparation remained `None`, no post-action existed, and TestFlight remained empty. Artifact/dSYM retention was not yet verified; this pilot is not final RC evidence.
- `2026-08-22 Asia/Shanghai`：Human Product Owner then authorized a read-first App Store Connect audit, fact-supported external TestFlight metadata completion and KOS handoff updates. Beta App Description and Beta Review Notes were saved; feedback/review contacts, public privacy URL, privacy/export/content-rights/category/age decisions and build-specific What to Test remain open. Evidence: [`release-2026-08-01-05-testflight-metadata-audit-2026-08-22.md`](../evidence/release-2026-08-01-05-testflight-metadata-audit-2026-08-22.md).
- `2026-08-23 Asia/Shanghai`：Human Product Owner confirmed TestFlight contacts were saved and the public privacy URL plus `No data collected` App Privacy answer were published, then authorized continuation of the export-compliance read-only audit and KOS handoff update. The audit recommends `ITSAppUsesNonExemptEncryption = NO` for the current Apple-OS-provided crypto path, but does not authorize the Info.plist change, upload encryption documents, upload a build or submit review. Possible annual self-classification remains a Human legal obligation.
- `2026-08-23 Asia/Shanghai`：Human Product Owner completed the age questionnaire, confirmed `工具` as the primary-category direction, and authorized remediation of the hard-coded scheme-license UI. Per-scheme, revision-bound disclosures and a persistent open-source notice page are implemented. Account-side content-rights/category save, visual Product verification, upload and RC freeze remain unauthorized/uncompleted.
- `2026-08-23 Asia/Shanghai`：Human Product Owner confirmed the three disclosure surfaces and authorized bounded Phase A provenance recovery. Phase A completed without changing shipped artifacts: `librime-lua@ec52e48…` plus the empty OpenCC stub reproduces 9/10 members on device arm64 and Simulator arm64/x86_64; `types.o` uses `re_detail_500` but has no official Boost.Regex tag SHA-256 match at the 1.88.0/1.89.0 header-version boundary. Luna is exactly derived from official `rime/brise` blob `728f883…` with one attribution-URL update.
- `2026-08-23 Asia/Shanghai`：Human Product Owner explicitly accepted those Phase A derived receipts as an external TestFlight candidate residual and declined Phase B rebuild/replacement. Record: [`PD-RELEASE-2026-0801-05-PROVENANCE-A-ACCEPT`](RELEASE-2026-0801-05-provenance-a-accept.md).
- `2026-08-23 Asia/Shanghai`：Human Product Owner reported saving App Store Connect content rights as “Yes, the app contains or accesses third-party content and has the necessary rights,” primary category `工具`, and secondary category `效率`. The executor did not reopen App Store Connect to verify the fields. Upload and RC freeze remain unauthorized.
- `2026-08-23 Asia/Shanghai`：Human Product Owner subsequently and explicitly authorized that narrow Info.plist change. `config/Info.plist` now declares `ITSAppUsesNonExemptEncryption = NO`; source-plist validation and an Xcode 27 beta Release Simulator integration build passed. This authorization did not include encryption-document upload, build upload, review submission, RC freeze or acceptance of the possible annual self-classification legal residual.

## Revalidation Triggers

- 目标从外部 TestFlight 候选改为内部限定构建或 App Store 正式提交
- Apple Developer Program / App Store Connect / Xcode Cloud 的实际能力与本意图不符
- Cloud 可用稳定 Xcode、macOS、Simulator 或签名行为变化
- 受支持设备/系统范围、颜表情范围、RC 顺序或测试设备可用性变化
- TD-002/003/004/005 或 ADR 0005 的 Gate 处置变化

## Related Documents

- [`assignments/release-2026-08-01.md`](../assignments/release-2026-08-01.md)
- [`evidence/release-2026-08-01-acceptance.md`](../evidence/release-2026-08-01-acceptance.md)
- [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md)
- [`assignments/release-2026-08-01-01-stable-archive.md`](../assignments/release-2026-08-01-01-stable-archive.md)
- [`assignments/release-2026-08-01-04-device-performance.md`](../assignments/release-2026-08-01-04-device-performance.md)
- [`assignments/release-2026-08-01-07-ipad-support.md`](../assignments/release-2026-08-01-07-ipad-support.md)
- [`assignments/release-2026-08-01-08-kaomoji-content.md`](../assignments/release-2026-08-01-08-kaomoji-content.md)
