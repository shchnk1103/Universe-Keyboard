# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-MEMORY-TEST-NUMBER-BINDING-001 — 限定修正与本地验证收敛

2026-10-09T09:53:31+08:00

## 修改及原因

仅移除 RimeCorrectionQueryIntegrationTests.swift 的7处冗余 `as? NSNumber`。ObjC typed dictionary 下标已返回 NSNumber?，冗余转换会触发现有 warnings-as-errors。全部断言、XCTUnwrap、nil默认值、DEBUG、fixture和生命周期保持。单文件format与strict lint通过；22候选文件中其他21文件未变。无需 CHANGELOG/ADR 更新：无产品或架构合同变化。

## 实际验证

| 阶段 | 通过 | 跳过 | 失败 |
|---|---:|---:|---:|
| RimeBridge Debug |90|20|0|
| App + Keyboard 默认 Debug |422|10|0|
| 签名 Keychain 独立用例 |1|0|0|
| probe Extension |21|0|0|

Release build exit0。五个绑定命令各一次，均exit0；使用仅405D994F-28CB-4F89-BB22-B64AD81C05A2 / iPhone18Pro iOS27.0。两个新增Bridge scope测试及probe集成3项已实际执行。Keychain用例与默认套件有重叠，不能相加视为不同覆盖。跳过项及原因完整记录于[结构证据](typo-correction-002-int003-query-cost-p2-memory-test-number-binding-001.json)，不计为通过；10项App跳过中的签名Keychain用例由独立命令覆盖，其余需按用途分别验收，不为本轮自动补跑。

Core默认1171/0与probe1196/0按206输入/固定工具链/相同参数核对复用；18原始Swift lint、前轮生产getter的新lint、本轮测试新lint合计覆盖20文件。Vendor匹配原verify证据。源固定HEAD `72dd21710f2a86c9f951d489f645bae89b053b58`，22文件manifest `d0eb9d1474de069d9301a31b3a434b99cf97fc5e788b1793e711c5dc36a58fd8`，binding `a7a0204c4a6fc6624ed473232adcdb203cc842394123eeaa89e7f52d811476e3`。未追随main/新增完整复审/重跑Core。

## 开关与产物检查

实际Swift编译命令确认默认关闭probe，Release无DEBUG/probe，opt-in路径KeyboardCore/RimeBridge/Keyboard获得DEBUG和probe；TESTING条件仅KeyboardExtensionTests。ObjC response file与对象符号确认Debug定义DEBUG且scope getter存在，Release均无。默认Debug和Release生产产物无memory-probe符号，opt-in生产Extension包含memory-probe符号；协调器installSyntheticQueryCostProbeForTesting仅测试bundle存在。编译命令、response、nm匹配输出及产物哈希在结构证据中。

## 边界及下一步

本轮Assignment Completed（仅上述交付范围），AUTH Consumed/exhausted。父TYPO-CORRECTION-002仍Active。原R5 Partial保留，Executor验证不是独立Quality Pass。性能测试exit与原始性能证据尚需有限验收，未证明观察者适用性或真实输入行为；正式P2 Capture未开始。下一步建议仅开展绑定此候选的证据验收，复用已绿验证；验收后另绑payload/Run进行P2采集，不因main更新而重试。无commit/push/PR/merge/Gate/父关闭/ADR Accept/TestFlight/Release。

## 执行记录说明

原执行binding gates文本沿用two casts标签；本轮7处范围在AUTH、精确patch及候选hash中一致，五项argv精确绑定，标签不授予额外权限。保留原绑定不改历史。xcresulttool自动报告缓存需native权限读取，未重跑测试；ObjC定义按实际response token检查。
