# AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-QUALITY-RUN-001

- 状态：consumed
- 建立时间：2026-09-20 Asia/Shanghai
- 消费时间：2026-09-20 Asia/Shanghai
- Assignment：`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`
- Worktree：`/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001`
- Branch：`codex/typo-correction-002-recall-publication-staging-001`
- Bound HEAD：`162b09fd58ba60538a944026b1902efa405c75aa`
- Bound HEAD tree：`92c5047c5d1a6dd6a751eb5344117f8138c14ef2`
- Run ID：`TC2-RECALL-QUALITY-20260920-001`
- Simulator：`iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`
- Source manifest：`docs/evidence/typo-correction-002-recall-remediation-publication-staging-source-manifest-2026-09-20-001.txt`
- Source manifest SHA-256：`709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207`
- RIME vendor archive SHA-256：`d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`

## 目的

在 clean `origin/main` staging worktree 上，对冻结的 recall-remediation source/test allowlist 执行一次新的、可复算的本地 CI 等价质量 Run。该 Run 只验证代码格式、纯 KeyboardCore、RimeBridge、App + Keyboard Debug tests 和 Release build，不扩大到设备、运行时产品行为或发布流程。

## 允许动作

- 消费本 Authorization 一次并使用上述新 Run ID；
- 对 manifest 中冻结的四个 Swift 文件执行 `swift-format lint --strict`；
- 执行 `swift test --package-path Packages/KeyboardCore`；
- 在指定 iPhone 17 Pro Simulator 上执行 `RimeBridgeTests` 与 `Universe Keyboard` Debug tests；
- 执行同一 destination 的 `Universe Keyboard` Release build；
- 使用独立 DerivedData 路径，记录命令、环境、结果 bundle、测试计数、警告和失败边界；
- 执行 `git diff --check`、manifest/hash/HEAD/tree/vendor provenance 核对；
- 只写入本 Run 的 Authorization consumption receipt 与 evidence。

## 明确禁止

- 不修改 Swift、测试源、Xcode 工程、Package manifest、schema、RIME bridge 或 vendor pin；
- 不执行 `swift-format format --in-place`。如 strict lint 失败，停止并申请独立的 code-fix Authorization；
- 不部署、不安装、不输入、不采集 INT-003、QA-001、paired-performance 或其他 Simulator/真机行为 Run；
- 不把本地测试/build 结果解释为 runtime、真实 RIME、180 ms、Product/Quality/Release Gate 或 parent Close 结论；
- 不 commit、push、PR、merge、TestFlight 或 Release；
- 不把 staging worktree 中的临时 parent revalidation/checkpoint 副本纳入 allowlist 或 staging commit。

## 退出条件

- 每一个适用门禁都记录为 pass、fail、skipped 或 blocked，并绑定命令与运行环境；
- 源文件、manifest、HEAD/tree、vendor archive/receipt 在 Run 前后无漂移；
- 若出现源码漂移、格式失败、测试/build 失败、签名或 Simulator 身份歧义，停在诊断边界，不进入 publication；
- 若全部通过，仅可申请新的 publication Authorization；本 Authorization 本身不授予 publication。

## Consumption receipt

- Run 已完成但在 App + Keyboard 编译阶段阻塞；证据：[`quality run 2026-09-20-001`](../evidence/typo-correction-002-recall-remediation-quality-run-2026-09-20-001.md)。
- PASS：四项 strict lint、manifest/hash、HEAD/tree、`git diff --check`、KeyboardCore `1139/0`、RimeBridge `81/0/20`。
- BLOCKED：App + Keyboard Debug 因 `RimeSettingsStoreTests.swift:1362` 的 `librimeVersion` extra argument；Release build 未执行。
- Result：不得 publication；需要新的 bounded dependency-reconciliation/code-fix Authorization。
- Non-claims：未修改 checked-in source、未部署/安装、未产生产品行为 Run、未 commit/push/PR/merge。
