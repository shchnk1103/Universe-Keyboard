# Architecture A2 定点独立复审（round 2）

**结论：Partial / incomplete。** 冻结 packet SHA-256：`d3eac7837fe86fd7623c9e1f62cc2a42c4184adc111bc604a6dedf0664c6d965`。未参与 Grok 实施。本轮仅裁决 A2-1 至 A2-4，并独立判断旧 A2-F1；不重开旧报告或全 F3 审查。

| 条款 | 覆盖 | 证据与判断 |
|---|---|---|
| A2-1 stale tick 身份/代际 | Covered | `KeyboardFirstFrameDisplayLinkTarget`携带arm token与presentation generation；生产handler核对回调CADisplayLink身份及当前target token/generation；gate只接受live token/generation。新stale-token用例在23项目标集中。 |
| A2-2 arm、两帧、拒绝与取消配对 | Covered | arm要求visible+window；有效重复begin复用当前token；gate计数以当前arm第二tick完成；viewDidAppear在shared-resume/rearm后不重复arm且要求visible/window。gate拒绝使token失效，调用方只取消对应link；生命周期状态变更另行失效token。隐藏/无window、stale token、第二tick与幂等用例均已纳入。 |
| A2-3 恢复权限、身份及ADR0002边界 | Covered | 通知仍按当前extension context配对；canary visibility resume授权先于Core resume，ready/markCanaryReady仍fail-closed；修正未扩至Core、RIME部署或I/O；保留ADR0002清理语义，不恢复旧composition。四文件限定差异与指定ADR/调用链符合范围。 |
| A2-4 23项测试及四Swift编译证据 | Uncovered | 测试源码定义23项，23项含XCTest断言（共112处）；required-gate-methods与实际结果逐项匹配：23/23 Passed。四个Swift文件的actual-compile记录及零new-diagnostics证据：未能完整核验。gate测试不证明真实CADisplayLink运行时取消、系统通知投递或Maps行为。 |

**旧 finding A2-F1：Covered（新候选静态实现及定点回归证据覆盖原token/代际缺口）。** 由于表中存在Uncovered项，不能把A2-F1外推为整体通过。

关键代码定位：`Keyboard/Controllers/KeyboardViewController.swift`（display-link target、viewDidAppear）、`Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`（arm、tick handler、cancel与host通知）、`Keyboard/Services/KeyboardHostLifecycleRecoveryGate.swift`（token/generation、begin/note/reject）、`KeyboardTests/KeyboardHostLifecycleRecoveryGateTests.swift`（23项目标测试）。

未覆盖项按冻结包要求保持Partial/incomplete；未扩大输入或预算。