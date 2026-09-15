# RELEASE-EVIDENCE-PROMOTION-001 — Architecture Re-review

## Review Metadata

| Field | Value |
|---|---|
| Reviewer | Independent Architecture & Knowledge Steward |
| Review thread | `01a09dca-843d-73b0-92dd-33886bf9f9ce` |
| Review date | 2026-09-14 Asia/Shanghai |
| Review scope | `REP-P1-02` candidate binding、`REP-P2-02` legacy archive decoding，以及 ADR 0035 / Release Checklist / Assignment 同步 |
| Review mode | 只读独立复审；Reviewer 未修改仓库文件 |

## Decision

**Accept（仅限本轮 Architecture 修复范围）**。

## Findings Closed

- `REP-P1-02`：`current_proof_candidate_binding_matches()` 要求 source 与 target 的 candidate ID 均已知且完全一致；五字段 artifact identity 仍与 candidate/provenance 分层。Python 负向测试证明仅 target candidate ID 不同时，artifact 仍可为 exact，但不得产生 `current-proof`。
- `REP-P2-02`：旧 archive fixture 覆盖缺失 `behaviorContract` 解码为 `UNKNOWN`，以及超长 note 解码时裁剪到 160；实现与 ADR 0035、Release Checklist、Assignment 描述一致。

## Evidence Boundary

本结论不是 Quality Pass、Release Pass、Product Gate、设备验收、签名 artifact 验收或 App Store Connect/TestFlight 授权。在本次 `2026-09-14` 复核时 ADR 0035 仍为 Proposed；后续采纳由 Human Product Owner 单独记录。

## Revalidation Evidence

- `python3 -m unittest discover -s scripts/release/tests -p 'test_*.py'`：22/22 通过。
- `git diff --check`：通过。
- `ReleaseEvidenceStoreTests`：12/12 通过；本复审未替代完整 Quality 门禁。

## Handoff

继续交给 [Quality re-review](release-evidence-promotion-001-quality-rereview.md)。本 Architecture Accept 不扩大任何外部动作授权。
