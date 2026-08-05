# Quality Review: T9-RESPONSIVE-PIPELINE-001 / R5-Rem-3-Polish

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（独立、只读增量复审） |
| Review date | 2026-08-01 Asia/Shanghai |
| Assignment | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) |
| Code tip under review | `80ef54b`（当前文档 tip `3585a54`） |
| Verdict | **Pass with conditions** |
| P0 / P1 / P2 / P3 | **0 / 1 / 3 / 0** |

## Independent execution

工作树在测试前后均为 `main...origin/main` 干净。Quality 实际执行：

```text
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveProvisional|ThreadAffineRimeWire|ResponsiveRimeFeltMetrics'
→ 22 tests, 0 failures（约 40.164s）

swift test --package-path Packages/KeyboardCore
→ 854 tests, 0 failures（约 45.125s）
```

## P1-Polish-2-D2 — 设备稳定与 D2 合同未同时闭合

Polish-2 的 device evidence 证明 Candidate/Path chrome 闪烁明显减少，且
L1 仍更新 host preedit；但实现保留了 stale chrome。Rem-3 D2 要求
provisionalAhead 时 Candidate/Path affordance disabled 或 cleared，当前没有
独立 Amendment 接受该合同变化。Core 的 Candidate/Path/Space 入口会 fail-closed，
但“可见且可点击、点击无效果”的 UI 仍是产品可见风险。

这不是 Product Gate 或 default-on 证据。必须由 Product + Architecture 选择
“禁用/清空”或正式接受稳定旧 chrome 的新合同，并补相应测试/复审。

## 其他 Quality gaps

- `testDeferredL1DoesNotNotifyExtensionChrome` 只验证 callback 不增加，未验证
  现有 Candidate/Path 快照稳定、marked-text history 时序或 stale tap 矩阵。
- `testCoalesceBacklogStillPaintsL1` 已不再断言 paint count/latest-only，旧的
  coalesce+L1 联合证据仍不完整。
- `handleCandidatePageUp/Down`、`handleInsertCorrectionCandidate` 尚无当前
  Polish 的 provisionalAhead 专门保护/回归证据，需确认是否纳入 D2 合同。
- 854/0 是当前 tip 的自动化结果，但设备证据仍只有单台 iPhone 13 Pro、
  iOS 27 Debug 的单组方向性 A/B，不是 Release 或 Product Gate 证据。

## Non-claims

本复审不声称 Product Gate、ADR 0025 Accept、Release default-on、Formal R5
FAIL 改判、真实 iOS 26.0/Release 证据或跨设备稳定性。

## Handoff

保持 dual-gate 默认关闭。P1-D2 契约决定后，补齐 current-tip 回归矩阵并由
独立 Architecture / Quality 重新确认，再由 Product Lead 决定 Hold 或 R6
readiness；当前不应直接进入 R6 Product Gate。
