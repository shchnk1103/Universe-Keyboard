# 独立 Quality 补充复审 — Pass（仅 R3 两项剩余证据）

> 发布展示副本：仅将历史临时绝对路径链接改为文字。审查原件逐字节保存在[TYPO-CORRECTION-002-INT003-QUERY-COST-P2-QUALITY-REMAINDER-001-quality-review-r3.original.txt](TYPO-CORRECTION-002-INT003-QUERY-COST-P2-QUALITY-REMAINDER-001-quality-review-r3.original.txt)，SHA256 `ffdf42bafc551b7bcb1111c4bb4009e89c1bf8212d4732c78b48b4828c331700`；结论/计数/范围不变。旧manifest中的报告哈希应核对该原件，不能核对展示副本。

- Work item：`TYPO-CORRECTION-002-INT003-QUERY-COST-P2-QUALITY-REMAINDER-001`，quality round 3。
- Candidate SHA-256：`d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2`。
- 入口 packet：`/private/tmp/uk-routeq3/packet.json`，SHA-256 `36f2018c8bd2d46adbd4ff9650d80e26903bb647131fe9264c8709d26ea623a4`；30/30 冻结输入摘要匹配。
- 本轮仅检查 Q-R3-1 与 Q-R3-2；没有重审源代码、52 个测试名称或其他 R2 已覆盖项，也没有运行测试、build、decoder、设备或网络操作。

## Evidence matrix

| Criterion | 结论 | 核对结果 |
|---|---|---|
| Q-R3-1：receipt 的 core/extension argv 与原/更正 binding 对应，attempt/exit/stop 状态符合预期 | **Pass** | `original/receipts.json` 是两个 stage 对象组成的数组。core 与 extension 的 `argv` 分别逐项等于原 binding 和更正 binding 对应数组；两项均 `attempt=1`、`exit_code=0`、`stop_reason=null`。没有运行其中命令。 |
| Q-R3-2：archive-manifest 九项摘要及更正链引用一致 | **Pass** | manifest 是九项 `name → sha256` 对象；九个 `original/` 文件逐字节计算的 SHA-256 全部匹配。更正记录引用的原 binding 摘要与 archive/原 binding 一致，更正 binding 摘要与冻结更正 binding 一致，`test_evidence_reused` 恰含九个 archive 名称且每项摘要均相同；candidate 摘要也一致。 |

## 精确证据定位

1. Receipt stage 和 argv：`original/receipts.json`（历史路径 `/private/tmp/uk-routeq3/original/receipts.json`） 中 core 的 `stage`/`argv` 起始于第 3/4 行，`attempt`、`exit_code`、`stop_reason` 在第 21、22、24 行；extension 对应于第 28/29 行及第 67、68、70 行。数组值经解析后逐项比较。原 binding 的 `core_argv`/`extension_argv` 分别从第 6/23 行开始；更正 binding 对应字段也从第 6/23 行开始。两个 receipt 数组分别与两版 binding 均相等。
2. Archive 摘要：`original/archive-manifest.json`（历史路径 `/private/tmp/uk-routeq3/original/archive-manifest.json`） 第 2、3、4、5、6、7、8、9、10 行逐项列出九个冻结文件；本轮对 `original/<name>` 的九个字节内容计算 SHA-256，9/9 匹配。
3. 更正链：`corrected/...-correction.json`（历史路径 `/private/tmp/uk-routeq3/corrected/typo-correction-002-int003-query-cost-p2-evidence-reconciliation-001-correction.json`） 第 7 行引用原 binding SHA，第 9 行引用更正 binding SHA，第 26 行起列出 `test_evidence_reused`，第 49 行明确 `new_test_runs: 0`。其九项摘要逐一与 archive manifest 相等。更正后的 binding SHA 为 `d76ca5e6d133541dbcb5af97f6451ee1f9841e0b66ebed96d510540fd42fa03b`，原 binding SHA 为 `eb3b865468b9d3945b1b4d5037d6b2a22e241ba96018dbb35f6c217e5c426fdf`。
4. 更正摘要 `corrected/...-evidence-reconciliation-001.md`（历史路径 `/private/tmp/uk-routeq3/corrected/typo-correction-002-int003-query-cost-p2-evidence-reconciliation-001.md`） 第 9、11、13 行说明新 binding 为派生记录、原 binding/归档/审查历史保留、未新运行测试，并且尚待独立 closure。原 R1 报告没有被本轮改写。

## Finding disposition

- 本轮 Q-R3-1 与 Q-R3-2 均完整覆盖且无差异，均为 **Pass**。
- 与 R2 已核实的单字段更正及既有 33 项 Extension 证据相结合，`ROUTE-REVIEW-R1-E01 / AR-01 / F1` 的**单一 finding closure 为 Pass**。这不更改原 R1 整体 `Changes requested` 结论，不代表整体 review 通过，也不构成 Product Gate、merge、Release、root-cause 或 runtime 结论。
- 计时与实际工具调用数见本轮 `quality-usage.json`。
