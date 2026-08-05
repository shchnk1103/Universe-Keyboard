# Assignment: T9-RESPONSIVE-PIPELINE-001 / P2-Regression-Matrix-001

| Field | Value |
|---|---|
| Lifecycle status | **Active — bounded Core Pass with conditions; P2-EPC closed at Core/Fake-host scope; UI/owner-call/real-performance residuals remain** |
| Parent assignment | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) |
| Parent design | [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) Amendment B（Proposed） |
| Product direction | [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) |
| Executor | Current Codex task（仅测试与证据文档） |
| Architecture reviewer | 🏛️ Architecture & Knowledge Steward（独立） |
| Quality reviewer | 🧪 Quality, Performance & Release Maintainer（独立） |
| Date | 2026-08-01 Asia/Shanghai |

## Authority and boundary

本子件承接 P1-D2 Amendment B 最终复审留下的回归债务。Product Lead 在本任务中
指示继续推进此前建议的下一步；本刀只新增 KeyboardCore 回归契约和证据文档，
不改变生产逻辑、不改变双 gate、不接真实 librime/Extension，不进入 R6 或
Product Gate。

允许范围：

1. 为 `provisionalAhead` 下的候选、纠错、翻页、Path、空格等快照绑定入口补齐
   fail-closed 矩阵；
2. 证明 L1 视觉影子不会改变已发布的 RIME output、候选/Path 状态或 Extension
   presentation 通知；
3. 证明 visibility abandon 的 epoch barrier 后，旧 L1/L2 工作不会再次写入
   宿主 `markedTextHistory`；
4. 运行 focused/full KeyboardCore、vendor verify 和工作树 diff 校验；
5. 将未覆盖的 UI prefetch、真实性能和发布验证明确记录为残余债务。

禁止范围：

- 不修改 `KeyboardCore` 或 Extension 生产逻辑来“迎合”测试；
- 不改变输入事件保序、候选/Path 授权、Partial Commit、26 键或 T9 host-digit
  安全合同；
- 不新增 UI target 依赖，不把 UIKit Extension prefetch 测试伪装成 SwiftPM
  KeyboardCore 证据；
- 不执行真实设备、Release、jetsam、Product Gate、ADR 0025 Accept 或默认开启。

## Acceptance matrix

| ID | Scenario | Required assertion | Evidence |
|---|---|---|---|
| P2-ACT-01 | L1 ahead + candidate/correction/page/Path/Space actions | 每个入口返回空 effect；Core state 与 host history 不变 | `testDualGateStaleActionMatrixFailsClosedWithoutStateMutation` |
| P2-CHR-01 | 已 settle 的 L2 后再进入 blocked key | L1 只追加 host dots；last RIME output、Path、Partial Commit、纠错状态和 Extension notify 保持稳定 | `testDeferredL1LeavesSettledChromeSnapshotUntouched` |
| P2-EPC-01 | blocked owner + visibility abandon | epoch 单调增加；abandon 后无 dots；旧 epoch 后续不再增加 host history，且 stale work 被计数/丢弃 | `testAbandonEpochDropsDeferredHostWritesAndStaleResult` |
| P2-UI-01 | Extension bar/expanded candidate prefetch while ahead | `candidateWindow` 不调用、不刷新 owner、candidate snapshot 不变 | **未执行；保留 P2 债务** |
| P2-PERF-01 | real librime / device long-sequence | 主观不卡顿、队列/内存/jetsam 与 Release 证据 | **未执行；保留 P2 债务** |

## Verification command set

```text
swift test --package-path Packages/KeyboardCore --filter ResponsiveProvisional
swift test --package-path Packages/KeyboardCore
bash scripts/ensure_rime_vendor.sh verify
git diff --check
```

本子件的 bounded Core 复审已完成，但因 UIKit/owner-call/真实性能残余仍保持
`Active`；即使矩阵通过，也只能形成 bounded Core evidence，不得改写为 ADR
Accept、Product Gate 或 Release ready。

## Handoff and stop point

Executor 在本次 bounded Core slice 完成后停止，已提交：

1. 测试变更列表与 focused/full 结果；
2. content-free evidence 文档；
3. 未执行的 UI prefetch、真实 librime、真机、jetsam、Release/Product Gate
   明细；
4. 交独立 Architecture 与 Quality 复审；两者均给出 **Pass with conditions**，
   并确认 P2-EPC 仅在 Core/Fake-host 层关闭。

剩余 UI prefetch/owner-call/真实设备与发布证据不在本子件内；任何生产接线、默认
开启或 R6 需求必须重新取得 Product Lead 授权。
