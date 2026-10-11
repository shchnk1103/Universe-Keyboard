# Authorization: TYPO-CORRECTION-002 recall remediation final Product decision 001

## Status

| Field | Value |
|---|---|
| **Authorization ID** | `AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-PRODUCT-DECISION-001` |
| **Status** | `Consumed` — see dated consumption receipt |
| **Issued by** | Human Product Owner / Product Lead via current Codex task |
| **Issued at** | `2026-09-20 Asia/Shanghai` |
| **Decision mode** | Bounded Product decision for publication preparation only |
| **Parent Assignment** | `TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001` |

## Exact binding

This Authorization binds the decision to the reviewed engineering snapshot:

| Item | Value |
|---|---|
| **Worktree** | `/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001` |
| **Branch** | `codex/typo-correction-002-recall-publication-staging-001` |
| **HEAD** | `162b09fd58ba60538a944026b1902efa405c75aa` |
| **HEAD tree** | `92c5047c5d1a6dd6a751eb5344117f8138c14ef2` |
| **Source manifest SHA-256** | `e2b4373c0797a0959b0b0da10c1db01cf4fa81cfe25903c7d9726942edab465c` |
| **Architecture review SHA-256** | `25dba823b50d12c3090346f408ae681719c852e998b3044a6751f525b9d4412b` |
| **Quality review** | `docs/reviews/typo-correction-002-recall-remediation-final-quality-review-2026-09-20.md` |
| **Quality review SHA-256** | `9e498f60b7bb7477f994089137f797424c90d4e308ae580ca2bf4e73116fb6ae` |
| **Quality Run** | `TC2-RECALL-QUALITY-20260920-002` |

## Allowed decision scope

The Product reviewer may create or update exactly one decision file:

`docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-BOUNDED-PUBLICATION-PREPARATION-DECISION-2026-09-20.md`

The decision must state whether Product accepts the following as bounded residuals for continued
publication preparation:

- App + Keyboard authoritative result `387 total / 378 passed / 9 skipped / 0 failed`, while
  wrapper/discovery observation `388` remains explicitly non-authoritative;
- KeyboardCore `1139/0`, RimeBridge `81/0/20`, and Release `BUILD SUCCEEDED` as local engineering
  evidence only;
- 20 RimeBridge skipped tests, 9 App + Keyboard skipped tests, optional-interpolation and current
  AppIntents warnings, and the `CODE_SIGNING_ALLOWED=NO` environment limitation;
- pure KeyboardCore evidence not proving production runtime wiring, real RIME acceptance, device
  behavior, INT-003, QA-001, paired performance, 180 ms, or contextual 7/8.

The decision may recommend a separate publication Authorization only if it keeps all residuals and
non-claims explicit. It must not itself authorize publication.

## Explicit prohibitions

This Authorization does **not** allow:

- modifying Swift, tests, Xcode, RIME, schema, vendor materialization, runtime code, Assignment
  files, `ACTIVE_WORK.md`, `KNOWLEDGE_INDEX.md`, or review files;
- running builds, tests, formatters that rewrite files, vendor verification, installation,
  deployment, or a new Simulator/device Run;
- creating or consuming a publication/commit/push/PR/merge Authorization;
- commit, push, PR, merge, TestFlight, Release, or closing any Assignment/Gate;
- declaring Product/Quality/Release Gate, runtime/device acceptance, or parent/child closure.

## Consumption receipt

The reviewer must append a dated consumption receipt here before or together with the bounded
Product decision. If the exact binding or residual inventory cannot be reproduced, record `Blocked`
and stop; do not repair the snapshot under this Authorization.

## Dated consumed receipt — 2026-09-20

Historical receipt below retains its originally recorded hash. The current binding above
is corrected by the [2026-09-20 docs-only reconciliation](../evidence/typo-correction-002-recall-remediation-digest-reconciliation-2026-09-20.md):
the committed Quality review differs from the old hash by exactly one trailing LF.

- **Consumed at**：`2026-09-20 16:20:08 CST (+08:00)`
- **Consumer**：bounded Product reviewer / current Codex task
- **Status after receipt**：`consumed`
- **Decision record**：`docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-BOUNDED-PUBLICATION-PREPARATION-DECISION-2026-09-20.md`
- **Disposition**：`Bounded Accept with conditions`，仅接受 exact snapshot 上的工程 residual 继续进入 publication preparation；不授权 publication。
- **Binding recheck**：HEAD `162b09fd58ba60538a944026b1902efa405c75aa`、tree `92c5047c5d1a6dd6a751eb5344117f8138c14ef2`、manifest SHA `e2b4373c0797a0959b0b0da10c1db01cf4fa81cfe25903c7d9726942edab465c`、Architecture review SHA `25dba823b50d12c3090346f408ae681719c852e998b3044a6751f525b9d4412b`、Quality review SHA `a7070f9ff8c5e26312eed45cc9a6207de187acd99f086caa58036b95ac0a5692` 与 Quality Run `TC2-RECALL-QUALITY-20260920-002` 均匹配。
- **Consumed scope**：保留 App + Keyboard 权威 `387 = 378 passed + 9 skipped`、`388` 仅 wrapper/discovery、KeyboardCore `1139/0`、RimeBridge `81/0/20`、Release `BUILD SUCCEEDED` 及 skipped、当前 AppIntents warnings、optional-interpolation warning、`CODE_SIGNING_ALLOWED=NO` 环境边界；保留 runtime/device、真实 RIME、INT-003、QA-001、paired performance、180 ms、contextual 7/8 与所有 Product/Quality/Release Gate non-claims。
- **Explicit non-authority**：本 receipt 与 decision 不授权 publication、commit、push、PR、merge、TestFlight、Release 或 Assignment close。
- **Next recommendation**：如需进入实际 publication 流程，只能另立独立 publication Authorization；本 receipt 不创建或消费该 Authorization。
