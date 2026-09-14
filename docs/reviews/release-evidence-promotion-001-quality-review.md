# RELEASE-EVIDENCE-PROMOTION-001 — Independent Quality / Release Review

## Review Metadata

| Field | Value |
|---|---|
| Reviewer | Independent Quality, Performance & Release Maintainer |
| Review thread | `01a09dce-0591-76f1-9ce2-c52d6d7cd474` |
| Review date | 2026-09-14 Asia/Shanghai |
| Review scope | release planner、receipt/promotion 负向语义、Main App evidence store、脚本/Swift 测试与既有 CI 边界 |
| Review mode | 只读独立复核；Reviewer 未修改仓库文件 |

## Decision

**Blocked for Beta → external current-proof** — 当前实现不能把待核对产物或缺少基线的外部候选当作可复用当前证明。以下 P1/P2 修复完成并经独立复测前，不得把 Proposed 设计当作正式发布合同。

## Findings And Disposition

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| `REP-P1-01` | P1 | pending artifact match 仍可能被 UI 手工标成全 pass，并产生泛化的 overall pass。 | `fix`；Main App pending external 聚合强制为 partial，复用步骤保持未核对，待复测 |
| `REP-P1-02` | P1 | current-proof 只覆盖 source/version/build/archive/package，缺少环境、行为合同、证据新鲜度和 source/candidate tuple binding。 | `fix`；增加 candidate context、证据契约版本、运行字段绑定和 30 天 freshness fail-closed，待复测 |
| `REP-P1-03` | P1 | 首次 external baseline 依赖可省略的 `--first-external-candidate`；receipt/promotion 没有在缺少 marker/history 时 fail closed。 | `fix`；首次强制 verified baseline plan，后续强制 previous external receipt 及其 digest，待复测 |
| `REP-P2-01` | P2 | 损坏的 records archive 会阻止新的证据保存。 | `fix`；损坏文件 quarantine 后再原子建立新 archive，待复测 |

## Checks Observed

- Python planner/promotion tests、`py_compile`、Swift format 和已有本地测试证据已被查看。
- 当前评审未宣称真实设备、signed archive/export、App Store Connect processing、external group、Beta Review 或正式 Release 已通过。
- 因工作树包含未提交变更，本评审未把任意 hosted CI/head-diff 结果视为最终合并证据。

## Handoff

修复后先由 Architecture 确认 SoT、生命周期和 clear 隔离，再由本 Reviewer 重新执行负向/性能/发布边界复核。Human Product Owner 仍是 ADR 0035 是否采纳以及任何正式外部动作的决定者。
