# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-A Architecture review — r4

| 项目 | 结论 |
|---|---|
| Reviewer | Independent Architecture reviewer |
| 日期 / worktree | 2026-09-14 Asia/Shanghai / `/private/tmp/universe-keyboard-kos-upgrade-uk-005` |
| 范围 | P1-A 六文件 implementation package；只读审阅，未改六文件、未触碰主工作区、未跑完整 CI、未 commit/push |
| Package SHA-256 | `45afdbf879c6b0054790342861254abbc6d9cde846f61b43a160bd22064d0382`（与目标一致） |
| 固定 fixture report | `/private/tmp/uk-kos-kos-fixtures-fix10/report.json`，SHA-256 `2398180e02bf7cf1338b773e0ebfd3920c98b477d3ef36b1d1798adda53b9a3c`（与目标一致） |
| Fixture aggregate | Envelope `52/52`；Delta `24/24`；合计 `76/76` |

## 总结

**Pass — P1-A Architecture review；不阻止 P1-A。**

六文件 raw-byte 身份、固定机器报告和审阅边界均已独立核对。实现保持 P1-A/P1-B、验证器/权限、source owner 与 Product/Quality/Release authority 的分离。`REP-Q-01` 未闭合、代码 gate unresolved，且当前没有 adapter-generated current-proof，这是预期且正确的 fail-closed 状态；它阻止后续 publication/current-proof readiness，不构成本次 P1-A 架构 finding。

## 检查结果

- **Source-owner / provenance：Pass。** Adapter 只消费显式 `main_app_source` seam；要求 canonical `SRC-MAIN-STORE`、安全 record id、canonical UUID、SHA-256、`diagnostic-short` retention 和 resolved record/operation/digest binding。未读取或接管 Main-App store，也未制造 owner identity。`REP-Q-01` gate 保持 unresolved，并将 adapter-generated observations 限制为 `inconclusive`。
- **Canonical Main-App wrapper / steps / outcome：Pass。** 仅接受 exact wrapper keys、`recordType=release_evidence_run`、固定 schema/contract、exact `nonClaims`；`run.steps` 必须是数组，拒绝 object shorthand、重复 scope、未知字段和非法 outcome。aggregate outcome 按 canonical step-derived precedence 计算，并拒绝 outer outcome 矛盾；source `note` 不进入 portable Envelope。
- **Baseline / lineage：Pass。** 首个 external candidate 要求当前 candidate-bound baseline；后续 candidate 要求 previous-target receipt，且保持唯一历史 key `release_lineage`。baseline/previous receipt 的 candidate、artifact、context、stage、Profile、contract 等身份均作一致性约束，错误配对 fail-closed。
- **Delta fail-closed：Pass。** 缺失/非法 base-head、空或歧义 changed surface、重复 surface、unsafe path、base=head、缺失 as-of、缺失 candidate/source/basis/freshness 或 dependency mismatch 均清空可复用 evidence、升级 release scope/CI tier 并设置 `stop_before_current_proof`。release validation profile 与 repository CI tier 独立，未将 release delta 降级为 docs-only CI。
- **Pointer/path canonicalization：Pass。** repository-relative path 拒绝 traversal、绝对路径和歧义形式；App-Diagnostics pointer、review-record pointer、UUID、digest 和 opaque token 均按固定 grammar/allowlist 校验，未发现通过路径规范化绕过 owner boundary 的路径。
- **Authority boundaries：Pass。** 实现未添加 Main-App UI/store、Extension I/O、网络、迁移、Retention/Clear、P-01/D-01 实际 owner receipt、Product/Quality/Release decision 或 publication action。绿色 fixture/evaluator 仅作为 contract evidence，不被改写为 gate 或 release acceptance。

## Findings（P0–P3）

| 优先级 | Findings | 是否阻止 P1-A |
|---|---|---|
| P0 | 0 | 否 |
| P1 | 0 | 否 |
| P2 | 0 | 否 |
| P3 | 0 | 否 |

## Evidence boundary / handoff

本 review 仅覆盖上述 exact six-file package 与已固定的 fix10 machine report；未宣称 Swift/runtime、设备、hosted provenance、P-01/D-01 实际事实、current-proof、Product Gate、Quality Gate、Release Pass 或 publication readiness。后续若关闭 `REP-Q-01`、改变 source/profile/evaluator/contract、变更六文件任一字节或引入 P1-B，必须重新冻结 package digest 并重新 Architecture review；之后仍需独立 Quality review。
