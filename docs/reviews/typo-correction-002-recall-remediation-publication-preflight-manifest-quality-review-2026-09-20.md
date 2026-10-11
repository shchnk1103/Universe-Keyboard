# Quality Review: TYPO-CORRECTION-002 recall remediation publication preflight manifest 002

## Verdict

**Pass with conditions — bounded local CI-equivalent publication-preflight evidence only.**

本 review 独立绑定：

- preflight ID：`TC2-RECALL-PREFLIGHT-20260920-002`
- HEAD：`d0df9a6342d8209b5aa7f9826541d0b430b9da04`
- HEAD tree：`27ae44bec1b157e391ef1e0b859db3a068e21ba8`
- `Packages/KeyboardCore/Package.swift` SHA-256：`9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764`
- canonical manifest：`docs/evidence/typo-correction-002-recall-remediation-publication-preflight-source-manifest-2026-09-20-002.txt`
- canonical manifest SHA-256：`709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207`
- simulator：`iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`

该 Verdict 足以支持 Product 对“是否继续下一步有界 publication preparation”的 bounded decision；不等于 Quality Gate、Product Gate、Release Gate 或 publication authorization。

## Evidence / Boundary

### Provenance and manifest

独立只读核对得到：

| 项目 | 结果 |
|---|---|
| canonical manifest | 652 bytes、5 行、按 path 排序、LF 结尾、无空行/code fence；文件 SHA-256 为 `709370…9f207` |
| 五个 entry hash | 当前工作树逐一重算，全部匹配 manifest、reconciliation、Architecture review 与 Authorization |
| HEAD/tree/Package | 与本轮 Authorization、Assignment、preflight evidence、reconciliation、vendor evidence 和 Architecture review 一致 |
| vendor archive/tree | 记录一致：`d17aab9a…99dd9` / `d446b0a4…f14fd`；本 review 未重新 verify |
| simulator | 所有相关 receipt 一致绑定上述 iPhone 17 Pro Simulator；本 review 未创建新 Run |
| 旧 digest | `bcbabcb7…` 仅作为 `superseded_not_reproducible` 历史记录；未被当作当前 digest |

manifest 的五个 entry 为：`Package.swift`、`ContextualTypoCorrection.swift`、`TypoCorrectionRecallPreflight.swift`、其测试文件和 `UniverseKeyboardTests/RimeSettingsStoreTests.swift`。当前工作树有预期的未提交 source/test/docs 变更；因此 HEAD/tree 是基线身份，canonical manifest 才是本次 preflight 的 working-tree source snapshot。不能把它表述为已提交或已发布的 artifact。

### Original xcresult/log evidence

原始 Xcode 收据可读，且与 receipt 对齐：

| Target | 原始证据支持的 authoritative 结果 |
|---|---|
| RimeBridgeTests | xcresult：`105 total / 85 passed / 20 skipped / 0 failed`；日志末尾为 `Executed 105 tests, with 20 tests skipped and 0 failures` |
| Universe Keyboard Debug | xcresult：`388 total / 379 passed / 9 skipped / 0 failed`；日志中的各 test bundle 也以 0 failures 结束 |
| Universe Keyboard Release | 原始 log 含 `** BUILD SUCCEEDED **` |

日志还直接支持以下边界：

- RimeBridgeTests 的 20 项是显式 fixture/runtime 条件不足而 skip，例如固定 commit、T9 Spike 目录或 R4-B real-engine 目录未设置；“suite passed”不把这些 skip 变成覆盖。
- App + Keyboard 的 9 项保留为 xcresult skip，例如固定 Ice/Wanxiang fixture 缺失；不能从 `379 passed` 推出完整 runtime/fixture 覆盖。
- App + Keyboard log 中 `client is not entitled` 恰为 107 条，源于 `CODE_SIGNING_ALLOWED=NO`；这不是 checked-in entitlement 成功或失败的替代证据。
- AppIntents metadata extraction warning 在测试/Release log 中出现；Release 仍成功，但 warning 必须保留为 residual。

`389 discovered` 只出现在外层 XcodeBuildMCP wrapper summary。authoritative xcresult 是 `388 total`，本 review 采用 388，不把 wrapper observation 混入 pass 计数。

### Executor-recorded checks not re-executed here

preflight receipt 记录：KeyboardCore `1143 passed / 0 failed`、治理 Python validators `12/12`、`test_verify_final_gate.sh` 与 `test_kos_trigger_paths.sh` 通过，以及初始 cache/SwiftPM sandbox 尝试曾被环境阻断后改用 writable temporary cache。上述记录与 receipt/Assignment 一致；本 reviewer 没有重新运行 Swift、Xcode、vendor 或治理命令，因此不把这些数字改写为本轮独立执行结果。初始 cache/sandbox diagnostics 是环境诊断，不是测试 failure。

## Findings

### Q-001 — exact manifest and count accounting are reconciled

**通过；不阻止 bounded Quality verdict。**

canonical manifest 的字节序列、五个 entry hash、Package hash、HEAD/tree、vendor identity 和 simulator identity 在本轮输入与相关 receipt 间一致。旧 `bcbabcb7…` 的不可复算问题已由 docs-only reconciliation 以明确的五行 LF serialization 修正；旧 Architecture `Blocked` receipt 仍是不可变历史，不能倒写成当时通过。

### Q-002 — original test/build evidence supports the bounded preflight claim

**通过；范围受限。**

原始 xcresult/log 足以支持 RimeBridgeTests、App + Keyboard Debug 和 Release build 的 receipt-level 结论；KeyboardCore 与 governance 结论可作为 executor-recorded evidence 复用。整体可称为该 exact manifest 的 bounded local CI-equivalent preflight，但不能升级为本 reviewer 新执行的完整门禁。

### Q-003 — dirty working-tree provenance remains a publication condition

**条件保留；不判为本次测试失败。**

当前 source snapshot 包含未提交的四个 Swift 变更及相关 docs。它与 canonical manifest 一致，但不等同于 HEAD commit tree，也不等同于已发布包。任何后续 commit、push、PR 或 publication 都必须重新绑定最终提交、最终 tree 和最终 manifest；本 review 不为这些动作提供权限。

### Q-004 — pure-Core and fixture evidence do not establish runtime behavior

**条件保留；不阻止 bounded Product decision，阻止更宽质量结论。**

Architecture review 已确认 preflight ledger 保持纯 KeyboardCore 边界、生产 `12/8` 与独立预检预算边界，以及 test-only provenance fixture 的 fail-closed 语义。但这不证明 corrected-input 到 canonical `GroupID` mapping、async scheduler 接受、真实 RIME candidate、production controller 接线或 sidecar 行为。

## Residuals

| Residual | Disposition / next owner | Status |
|---|---|---|
| App + Keyboard 9 skipped | 保留为非覆盖项；由后续 Quality/Product/Release 范围决定 | open |
| 107 `CODE_SIGNING_ALLOWED=NO` entitlement warnings | 保留为环境 residual；不得据此修改 checked-in entitlement，也不得包装成 runtime pass | open |
| AppIntents metadata warning | 保留为 build warning；Release 成功不消除该 warning | open |
| 初始 cache/sandbox environment diagnostics | 保留为环境事实；最终 `1143/0` 只按 executor receipt 复用 | documented |
| working-tree source snapshot 尚未成为 commit/publication artifact | 后续 publication/commit Authorization 绑定最终 identity | open |
| async runtime、真实 RIME、设备行为、INT-003、QA-001、paired performance、180 ms | 另立 Assignment/Authorization；不得从本 preflight 推断 | `UNKNOWN` / not authorized |
| contextual `7/8` | 保留 `UNKNOWN`；本 review 不关闭 | `UNKNOWN` |

## Non-claims

本 review 不声称：

- 本 reviewer 重新执行或独立通过了 KeyboardCore、RimeBridgeTests、App + Keyboard、Release、vendor verification 或治理 validators；
- 389 wrapper observation 是 authoritative test total；authoritative total 为 388；
- skipped tests、warnings、cache/sandbox diagnostics 是 test failures，或相反可以忽略；
- 生产 scheduler/controller、真实 RIME deployment、candidate ranking/visibility、sidecar、runtime privacy boundary 或输入端到端行为已验证；
- Simulator/device acceptance、INT-003、QA-001、paired performance、180 ms 或 contextual `7/8` 已完成；
- hosted CI、Quality/Product/Release Gate、publication、commit、push、PR、merge、TestFlight、Release 或 parent/child Close 已通过或被授权。

## Handoff

对本 exact manifest，没有发现阻止 Product 做 bounded continuation/publication-preparation decision 的 Quality finding。Product 若要作实际 publication、commit、push、PR、merge、TestFlight 或 Release 决定，仍必须取得对应授权，并把最终提交身份、最终 manifest、9 skipped、107 warnings、AppIntents warning 及所有 runtime/device/performance non-claims 明确带入下一份记录。

本 review 只写入本文件；未修改源码、测试、Xcode、vendor、schema、Assignment、`ACTIVE_WORK.md` 或 Authorization，未运行新 build/test/install/deploy/vendor verification，未创建新 Run，也未消费本 Quality Authorization。
