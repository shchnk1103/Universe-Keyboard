# Evidence: APP-SWITCH-CONTRAST-001 — SHA 绑定的 Human-attested 观察

> **Status:** Recorded — Human-attested visual observation
> **Observed:** 2026-09-15 Asia/Shanghai
> **Implementation source:** `5d3880b13109a65b8e441ded74b82f9927ffb9b4`
> **Evidence grade:** **Human-attested**；不是 Device-attested

## Observation boundary

Human Product Owner 在实现 SHA `5d3880b13109a65b8e441ded74b82f9927ffb9b4`
对应的主 App 上完成观察。此前的 `63f1a6d95316187249bcd3f85c5f7883bc13bf7d`
是实现后的文档 SHA 回写；本记录及其后续状态同步也只包含文档，不改变本片
Swift 实现。

| Field | Observed value |
|---|---|
| Device | iPhone 13 Pro |
| OS | iOS 27 |
| Surfaces | 设置首页；设置 → 诊断；设置 → RIME → 模糊音 Form |
| Matrix | 浅色开启、浅色关闭、深色开启、深色关闭 |
| Result | 四态均可读；未观察到问题；与既定对比度合同一致 |
| Operator | Human Product Owner |

## Claim boundary

这条记录只支持上述设备、系统、页面和四态开关可读性的人工观察。
它不包含已安装 executable / Extension UUID、SHA-256、dSYM、冻结 manifest
或截图附件，因此不升级为 Device-attested，也不构成 Quality 真机复验、
Product Gate、TestFlight、Release 或 App Store 证据。

既有 Quality 结论仍为 **Pass with conditions**；本观察不替代独立 Quality
审查，也不改变 Product Gate 仍需另行授权的边界。
