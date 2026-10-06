# Quality R2 增量补审：QT1–QT3

WorkItem `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`，lane `UK-WAKE-V6-B-QUALITY`，round 2。冻结 packet SHA-256 `a1cf0362a878ea3020a50db2592a32df57c761309a311112ed2c3f9b3423f103` 与 sidecar 一致；29 个绝对输入逐项复算为 missing=0、hash mismatch=0。候选仍是 `candidate-r2` SHA 绑定的 HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`、branch `codex/keyboard-wake-v3-compatibility-gate`；本轮只读，没有改源代码、结果包或 round 1 文件。

本轮结论：**Partial / incomplete**。Q3 的底层 result-tree 对账现已完成，补正 round 1 报告中错误标记为 Covered 的 Q3；round 1 报告原文和 usage 均保留。当前 Human M-03 接受的是这一个 Stage B 候选的 30 个未验证 skip 残项，skip 仍然不是 passed。此 Quality lane 结论不授予完整 paired Gate、Release、parent closure 或 Stage C 权限；Architecture 是独立并行 lane，不能替代或被本报告替代。

## QT1：底层 legacy metrics、ActionTestMetadata 与日志对账

我按实际 xcresult JSON 的 `_type._name`、`_values`、`_value` 包装递归遍历四份 test-tree；对每个 `ActionTestMetadata` 读取 identifier、testStatus 和 summaryRef。每份 legacy JSON 同时读 root `metrics` 与 `actions._values[0].actionResult.metrics`。用未简化的用例状态与冻结 test-evidence 对照，并将 skip identifier 集与 validation summary、raw log 的 `Test skipped - …` 条目交叉核对；没有调用 xcresult summary 查询。

| Frozen pair | Root legacy / ActionResult metrics | `ActionTestMetadata` bottom nodes | 与 test-evidence | Raw log |
|---|---|---|---|---|
| RimeBridgeTests | 105 total / 0 failed / 20 skipped，root 与 ActionResult 相等 | 105 unique；85 Success、20 Skipped | 105 cases 状态逐项一致；20 skip IDs 集一致 | `RimeBridgeTests.log`：105 total / 0 failures / 20 skipped；解析到 20 个 skip reason，与 summary 映射一致=True |
| AppV6Focused-r2 | 1 / 0 / 0 | 1 unique；1 Success | 1 case 状态一致 | `AppV6Focused-r2.log`：`testV6HistoriesPropagateCompletenessThroughCompositeQuery` passed，1/0/0 |
| AppKeyboardTests-r2 | 429 / 0 / 10，root 与 ActionResult 相等 | 429 unique；419 Success、10 Skipped | 429 cases 状态逐项一致；10 skip IDs 集一致 | `AppKeyboardTests-r2.log`：新增 v6 case passed；解析到 10 个 skip reason，与 summary 映射一致=True |
| SignedKeychain-r2 | 1 / 0 / 0 | 1 unique；1 Success | 1 case 状态一致 | `SignedKeychain-r2.log`：选定 Keychain 用例 passed，1/0/0 |

底层数值复核结果：

- RimeBridgeTests: root legacy metrics {'testsCount': '105', 'testsFailedCount': '0', 'testsSkippedCount': '20'}; ActionResult metrics {'testsCount': '105', 'testsFailedCount': '0', 'testsSkippedCount': '20'}; ActionTestMetadata 105，status {'Success': 85, 'Skipped': 20}；与 test-evidence status 和 skip ID 集合匹配=True
- AppV6Focused-r2: root legacy metrics {'testsCount': '1', 'testsFailedCount': '0', 'testsSkippedCount': '0'}; ActionResult metrics {'testsCount': '1', 'testsFailedCount': '0', 'testsSkippedCount': '0'}; ActionTestMetadata 1，status {'Success': 1}；与 test-evidence status 和 skip ID 集合匹配=True
- AppKeyboardTests-r2: root legacy metrics {'testsCount': '429', 'testsFailedCount': '0', 'testsSkippedCount': '10'}; ActionResult metrics {'testsCount': '429', 'testsFailedCount': '0', 'testsSkippedCount': '10'}; ActionTestMetadata 429，status {'Success': 419, 'Skipped': 10}；与 test-evidence status 和 skip ID 集合匹配=True
- SignedKeychain-r2: root legacy metrics {'testsCount': '1', 'testsFailedCount': '0', 'testsSkippedCount': '0'}; ActionResult metrics {'testsCount': '1', 'testsFailedCount': '0', 'testsSkippedCount': '0'}; ActionTestMetadata 1，status {'Success': 1}；与 test-evidence status 和 skip ID 集合匹配=True
- Rime 与 App full 的 skip node 分别 20 / 10；每个 bottom node 的 identifier 与 frozen summary 的 skip ID 集相等。raw logs 分别给出 20 / 10 条原因，逐项与 summary reason 相符；reason mismatches=0。
- `DiagnosticsLogSourceTests/testV6HistoriesPropagateCompletenessThroughCompositeQuery()` 在 focused 与 full App 的 `ActionTestMetadata` 均为 Success；新用例包含在 full App 429 中。
- Keychain 用例在 unsigned App full tree 中是 Skipped，但在 signed lane 的唯一 bottom node 中为 Success。unsigned skip 仍保留为 skip；这是独立 1/1 证据。
- full App 429 与历史 v5 raw 428 对得上新增的一个 v6 测试；Assignment 的历史记录明确写明 v5 raw xcodebuild 与 xcresult 为 428 actual cases。此次不做 count-only rerun。
- 当前完整 skip ID 与原因清单仍见不可变的 round 1 Q5 表 (`quality-review.md#skipped-with-reason`)。本轮验证了 20+10 个底层 skip identities 与摘要 / raw log 的映射；两条 CS09-10-01 的逐项原因以本轮核对为准：
  - `SchemeResourcePreparationCoexistenceTests/testCS0910_RealInstallerIceRemovalPreservesCompleteWanxiangInventory()` → `CS09-10-01 requires the fixed Wanxiang extract tree`。
  - `SchemeResourcePreparationCoexistenceTests/testCS0910_RealInstallerWanxiangRemovalPreservesCompleteIceInventory()` → `CS09-10-01 requires the fixed Ice extract tree`。

QT1：**covered**。四个 pair 的 root metrics、ActionResult metrics、bottom `ActionTestMetadata` counts/status、frozen summary case status、skip identity set 和原始日志均相符。

## QT2：round 1 文字事实更正

| Round 1 wording / ambiguity | Corrected fact | Evidence locator |
|---|---|---|
| 把 iPhone 17 Pro 不可用说成选择 iPhone 18 Pro 的原因。 | iPhone 17 Pro 当时可用；Human 明确选择本次精确的 iPhone 18 Pro / iOS 27.0 UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`。此选择不是因 17 Pro 缺失而采用的 fallback。 | frozen Stage B supplemental Entry `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-supplement-entry-2026-09-30.md`；当前授权 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v6-reader-stage-b-supplement-authorization-2026-09-30.md`。 |
| 将 Release 验证描述为 Debug Simulator 配置。 | `ReleaseBuild-r2-command.json` 的实际 argv 是 `-configuration Release … build`，raw log 是 `** BUILD SUCCEEDED **`。该事实更正不扩展为 Release Gate。 | `/private/tmp/ukey-wake-v6-stage-b-20260930-01a0f254/ReleaseBuild-r2-command.json`；`/private/tmp/ukey-wake-v6-stage-b-20260930-01a0f254/ReleaseBuild-r2.log`。 |
| CS09-10-01 两个 skip 的 Ice / Wanxiang fixture 描述没有正确逐项对应。 | Ice removal 测试缺 Wanxiang extract tree；Wanxiang removal 测试缺 Ice extract tree，精确 test ID 与 reason 如 QT1。 | `/private/tmp/ukey-wake-v6-stage-b-20260930-01a0f254/validation-summary.json` 的 skip message 与 `/private/tmp/ukey-wake-v6-stage-b-20260930-01a0f254/AppKeyboardTests-r2.log` 的 raw skip 行。 |

QT2：**covered**。Round 1 文件未编辑；上述内容只进入本次增量补审。

## QT3：当前 M-03、继承边界与 Quality verdict

Human Product Owner 当前授权文件 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v6-reader-stage-b-supplement-authorization-2026-09-30.md` 第 13 行记录：B-SKIP-001 接受当前 Stage B RimeBridge 20 条 skip，B-SKIP-002 接受当前 Stage B App + Keyboard 10 条 skip，均仅为当前 reader candidate 的非阻塞、未验证残项。Assignment 的 B-SKIP-001/002 记录了相同范围。接受不把 skip 改成 pass，也不传递到 Stage C、writer/producer、promotion、Release 或别的 candidate；signed Keychain 1/1 仍与 unsigned full-suite skip 分开记录。

round 1 的 Q1、Q2、Q4–Q7 可在相同 candidate-r2 identity 与已冻结输入下继承；它们的既有边界与 limitation 保持原样。Round 1 的 Q3 虽在表格里标成 Covered，却没有独立遍历底层四对 JSON，不能沿用该标签；本 QT1 才完成这项覆盖。

**Quality lane：Pass with conditions / 完成当前 Stage B 精确候选的 Quality 接受。** 条件是 Human 的当前 M-03 明确接受上述 30 条为未验证残项，它们继续以 Skipped 记录；不表示测试通过或覆盖完成。若不把 full paired Gate 与 Architecture verdict 混入 Quality lane，则当前 Q1–Q7 criteria 已覆盖。完整 paired Gate 仍未授予。

**Architecture 独立状态：** Architecture R1/R2 的 AS2–AS6 未覆盖仍属并行 lane；Architecture R3 不在本 Quality packet 输入中，也不是本结论的替代证据。本 Quality review 不作 Architecture 判断。duplicate JSON member detection limitation、vendor 当前字节虽与 receipt/manifest pin 匹配但没有原始 archive 独立逐字节比较，以及未作 production v6 emission/install、Maps/root-cause、真实设备/性能、Gate/Release 的边界均继续保留。

| 补审项 | 结果 | 精确证据 |
|---|---|---|
| QT1 底层 status / skip mapping | Covered | 四个 `*-legacy.json`、四个 `*-test-tree.json`、`test-evidence.json`、`validation-summary.json` 与四个 raw test logs；输入 29 项均 hash match。 |
| QT2 三项文字更正 | Covered | Supplemental Entry、supplement authorization、ReleaseBuild-r2 command/log、App skip summary/log。 |
| QT3 当前 residual disposition | Covered | Human M-03 授权文件与 Assignment B-SKIP-001/002；仅当前 Stage B。 |

## Handoff

下一最小步骤：Coordinator 将本增量文件与 usage 交回当前 Assignment。保留 `quality-review.md` / `quality-usage.json` 原文，只在 Stage B handoff 中引用 QT1–QT3 的更正与新 verdict。没有新增输入请求；无新增测试、设备、source、result bundle 或发布动作。
