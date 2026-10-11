# Architecture 单 finding closure 复审（round 2）

## 结论

**Pass — 仅关闭 AR-01 / F1 的计数绑定差异。** 冻结的派生执行 binding 只将 `expected_extension_tests` 从 34 更正为 33；命令、环境与候选身份不变。原始 coverage、summary 和日志都对应 Extension 33（8 + 15 + 10），归档清单中的原证据摘要均匹配。更正链明确保留原 binding、原 archive 和原 review 历史，并记录没有新测试运行。

这项结论只覆盖本轮唯一的 finding closure；**不改写或升级 round 1 的整体结论**。原 Architecture review 仍为 `Changes requested`（`prior/architecture-review-r1.md:5`），且本轮不重审候选源码或原 52 项测试。

## 身份与覆盖

- Packet：`/private/tmp/uk-routecount1/packet.json`，SHA-256 `1235f074caad3c9793470f601ff99d4754cf8e76813c312288246371822cc4a2`；31/31 冻结输入摘要匹配。
- 本 lane 唯一 criterion：核对派生 binding 的字段差异、原命令/环境及候选不变；确认 8+15+10 与既有回执一致；确认更正链保留原件、未宣称新测试或整体 R1 Pass。该 criterion 已完整覆盖，无未解决差异。

## 证据核对

1. **仅改预期计数字段，命令与环境保持不变。** 对原 binding 与派生 binding 作 JSON 结构比较，仅将 `/expected_extension_tests` 从 `34` 改为 `33`；`core_argv`、`extension_argv`、`environment`、其余字段和 candidate SHA 均相等。定位：`original/execution-binding.json:70–71`；`governance/docs/evidence/typo-correction-002-int003-query-cost-p2-evidence-reconciliation-001-execution-binding-corrected.json:70–71`。修正记录明确指向该 JSON Pointer 和旧/新数值：`governance/docs/evidence/typo-correction-002-int003-query-cost-p2-evidence-reconciliation-001-correction.json:10–14`。

2. **修正值与既有原始证据吻合。** `coverage.json` 的三组 Extension suite 为 8/8、15/15、10/10（`original/coverage.json:7–19`）；冻结 summary 记录 `passedTests=33`、`failedTests=0`、`skippedTests=0`、`totalTestCount=33`（`original/extension-summary.json:14–15,25–28,48`）。原始 extension stdout 分别记录三 suite `Executed 8`、`Executed 15`、`Executed 10`，总计 `Executed 33` 且 0 failures（`original/extension.stdout:2136–37,2169–70,2192–97`）；Core 原日志为 19/0（`original/core.stdout:42–47`），final identity 为 52/0/0（`original/final-identity.json:7–9`）。这些均为对既有冻结证据的静态复核，不是新测试运行。

3. **原件和历史链保持可审计。** 原 execution binding 的实际 SHA-256 与 correction record 及 archive manifest 一致：`eb3b8654…e5c426fdf`；修正 binding 的实际 SHA-256 与 correction record 一致：`d76ca5e6…42fa03b`。`original/archive-manifest.json` 所列 9 个原始文件摘要全部与归档字节匹配。更正说明记录 `new_test_runs: 0` 且说明派生记录不是新执行；当前 reconciliation 文档称复用原 52 项证据、未新运行测试，也明确尚不宣称 finding 已独立关闭或原 review 已 Pass（`governance/docs/evidence/typo-correction-002-int003-query-cost-p2-evidence-reconciliation-001-correction.json:1–58`；`governance/docs/evidence/typo-correction-002-int003-query-cost-p2-evidence-reconciliation-001.md:3–12`）。R1 原件未改写，仍保留 `Changes requested` 与 AR-01 描述（`prior/architecture-review-r1.md:5,37–42`）。

## Finding disposition

- `AR-01 / F1`：**本轮 closure Pass**。唯一差异已在派生 binding 中对齐到冻结的 Extension suite 实际数量，证据摘要链保持原样并可核验。
- 新发现：无。
- 没有据此作出 Gate、Release、可合并或实际根因结论。
