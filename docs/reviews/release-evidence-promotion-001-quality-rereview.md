# RELEASE-EVIDENCE-PROMOTION-001 — Quality / Release Re-review

## Review Metadata

| Field | Value |
|---|---|
| Reviewer | Independent Quality, Performance & Release Maintainer |
| Review thread | `01a09dce-0591-76f1-9ce2-c52d6d7cd474` |
| Review date | 2026-09-14 Asia/Shanghai |
| Review scope | P1/P2 修复、负向/恢复/兼容测试、CI 边界与发布权限边界 |
| Review mode | 只读独立复审；Reviewer 未修改仓库文件 |

## Decision

**Conditional Accept（仅限本地工程实现与证据合同）**。

## Findings

- `REP-P1-01`、`REP-P1-02`、`REP-P1-03`、`REP-P1-04`、`REP-P2-01`、`REP-P2-02` 均已闭合。Pending external 不会因手工步骤全 pass 而成为总体 pass；current-proof 绑定五字段 artifact、source/target candidate ID、行为合同、profile、候选/版本/构建、设备/系统、evidence contract 与 0–30 天 freshness；首次/后续 external baseline provenance 缺失时 fail closed；损坏 archive、note bound、legacy UNKNOWN、clear isolation 均有覆盖。
- `REP-Q-01`（开放）：当前工作树没有明确最终 commit SHA，尚不能保存实际 final base/head 的 hosted CI/lightweight provenance。该项是发布证据链的收尾，不是当前实现语义的失败。

## Direct Checks

- Swift strict format/lint：本轮 4 个变更 Swift 文件通过。
- Python release tests：22/22 通过；`py_compile` 通过。
- 主 App + Keyboard 全量 Simulator XCTest：`UniverseKeyboardTests` 369 执行、9 skipped、0 failed；`KeyboardTests` 11 执行、0 skipped、0 failed。
- 定向 `ReleaseEvidenceStoreTests`：12/12 通过。
- 同一最终 Swift 源码状态的 KeyboardCore：1125/0；RimeBridgeTests：101/0、20 skipped；Debug/Release build 成功；RIME vendor verify 成功。
- 复审时工作树 Markdown 链接 31 个文件通过；`bash scripts/ci/run_lightweight_checks.sh HEAD HEAD` 的 0 changed Markdown 仅表示已提交 `HEAD..HEAD` 无差异，不能替代工作树或最终 commit 检查。复审记录写入后，最终工作树的 33 个 Markdown 文件另行复核通过。

## Skipped And Non-claims

未执行真机、签名 archive/export、UUID/dSYM、设备性能/崩溃、App Store Connect、TestFlight、Beta Review、commit、push 或 merge；这些动作没有本 Assignment 的授权，且不能由 Simulator/脚本推导。本结论不是 Product Gate、Release Pass 或外部发布授权。

## Handoff

`REP-Q-01` 由 Executor / App & Data Operations 在形成明确 final SHA 后，以真实 base/head 保存 CI/lightweight receipt。Human Product Owner 仍单独决定是否采纳 Proposed ADR 0035；任何外部动作仍需单独授权。
