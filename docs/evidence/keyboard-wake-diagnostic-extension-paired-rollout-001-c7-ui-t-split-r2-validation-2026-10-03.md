# T split R2 独立验收及 skip 原因补证

## Decision / Scope

Human授权预检后继续未完成工作。两位Luna low复用，新round2各6calls/900s；正式独立report/usage已落盘并归档。**P T4–T6 Complete；S T1/T3 Covered、T2 Partial；整体T Hold。** 无设备或测试操作。

## Evidence Matrix

| 项 | 独立意见 | 原因/剩余 |
|---|---|---|
| T1 | Covered | H1 candidate binding、来源571/Vendor630/payload78及argv/compiler/toolchain/测试设备身份闭合；standalone、test-host、已装旧C7边界明确 |
| T2 | Partial | 537actual/507pass/0fail/30skip、case identity及signed唯一case核对；原allowlist摘要树不含逐项skip原因 |
| T3 | Covered | Core204最终fileset/hash吻合，1194 host全量可复用，非iOS运行 |
| T4 | Covered | 两段恢复baseline、provenance/install_uuid分类、117动作和仅3TipKit动作、签名与机器/人工健康界限闭合 |
| T5 | Covered | 30raw skip保留，另轮signed1pass同identity、29未验证，当前Product处置仍open |
| T6 | Covered | 历史Partial/旧C7来源和scope/nonclaim一致，不声称新候选runtime/Maps/Gate/Release |

## 交付用量及一致性

S6calls/199.935s，P6calls/201.675066s。报告hash与usage匹配，冻结内容归档前无漂移。S原usage中额外independent_leaf_calls=5与总数6不一致；作者仅用消息确认5是错误遗留字段、真实总数6。原文件不改，coordinator-receipt单独归档作者澄清，不隐去错误或借此续预算。

## 同一历史 xcresult 的只读补证（协调者）

根据S缺口，root只读原Rime/AppKeyboard xcresult的 test-details，逐用例核testIdentifier、Skipped、原UDID与Test skipped原因。全部30条均有明确原因，原始details30份及index/读取argv/hash已归档，无重跑。原因包括未提供固定资源/运行目录/冻结commit、真机专用，以及无签名宿主缺Keychain entitlement（同case另轮signed1pass）。不能将“原因解释完备”视为这些用例通过。

该补证是原同一测试历史窗口内容，不是新测试；尚未独立验收，不自动消除T2 Partial。

## 下一步 / Product

已准备仅30条skip原因及case对应的T2补审（同一Luna，2calls/300s，先写report/usage，再核与回读），未授权/未启动；两轮6calls均已耗尽，Policy预算不自动续期。批准后再新鲜冻结packet及clock。

独立覆盖补齐后仍需Human仅对当前T接受29未验证残项为非阻塞；原30skip保留，1signedpass单列。不自动沿用旧阶段接受，不为发现/执行数差异重跑，不含新候选安装或Release。
