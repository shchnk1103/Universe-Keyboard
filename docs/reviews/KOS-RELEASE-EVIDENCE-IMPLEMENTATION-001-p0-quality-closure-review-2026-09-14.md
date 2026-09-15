# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 — P0 Quality / Evidence closure review

## Review identity and boundary

| Field | Value |
|---|---|
| Reviewer | Independent Quality / Evidence Reviewer |
| Agent ID | `01a09b4a-6226-7f50-8b29-a5647bf1620e` (current Codex task/runtime binding) |
| Review date | `2026-09-14 Asia/Shanghai` |
| Review mode | Fresh-runtime, read-only independent closure review |
| Worktree | `/private/tmp/universe-keyboard-kos-upgrade-uk-005` |
| Worktree branch / HEAD | `codex/kos-upgrade-uk-005-release-evidence` / `3139f8d3bdb6be6622504ea731988f42681896fb` |
| Exact P0 manifest digest | `7652edc667749ef2fb1c6d6172639a85d531eba5fa48e7bb3a5b6b2748aeaed6` |
| P0 digest scope | Freeze receipt-defined ordered raw-byte concatenation of eight P0 files; receipt and all review artifacts excluded |

本 review 仅核对前一轮 P0 closure：leaf-exact owner map、derived output 排除、source ID 与
pre-freeze/`REP-Q-01` 边界、invalid/`as_of`/derived precedence、`daily_beta` →
`external_candidate`、P-01/D-01、P0 receipt/not-run 及 pointer grammar。未进入实现、测试或发布审查。

## Verdict

**Changes Requested — P0 closure 尚未通过；唯一剩余 finding 为 P1 leaf-exactness。**

| Priority | Count |
|---|---:|
| P0 | 0 |
| P1 | 1 |
| P2 | 0 |
| P3 | 0 |

该 verdict 只针对本 review 绑定的精确 P0 digest，不替代 Product、Architecture、Quality/Release
Gate、Human Product/Release authority 或后续 P1/P2 handoff。

## Integrity and evidence boundary

- 按 P0 freeze receipt 的八文件顺序独立重算 raw-byte concatenation：结果为
  `7652edc667749ef2fb1c6d6172639a85d531eba5fa48e7bb3a5b6b2748aeaed6`，与冻结 receipt
  完全一致。
- 对 pinned schema 的输入叶路径与 Profile owner-map 行做只读结构对照：14 个 identity map
  继续按 Profile 明示的 bounded-key 规则聚合；其余非 identity leaves 中仅发现下面列出的
  6 个缺行。此对照不是 P1 fixture、schema evaluation 或 Envelope evaluation。
- P0 freeze receipt 已记录 executor 的 JSON、Markdown/link、whitespace 和 KOS validator
  命令及结果；本 review 不把 executor-recorded 结果升级为本次 Quality 重跑结果。
- P0 receipt 明确 pinned release-evidence schema/evaluator **not-run**，原因是 P0 没有
  standalone Envelope；本 review 没有执行 evaluator、schema、fixture、测试、xcodebuild 或 CI。
- 已存在的 `8958ecc6…` spot-check 绑定不同的旧 manifest digest，不能作为本 review 的当前
  digest 结论；本结论只绑定 `7652edc…`。

## Requested closure checks

| Area | Result | Fresh review finding / evidence boundary |
|---|---|---|
| Leaf-exact owner map | **P1 residual** | Profile 已拆开顶层 `contract_version.major/minor`，且所有 14 个 identity map 有 bounded-key 行；但 pinned schema 的 `promotion.target_binding.contract_version`、`promotion.baseline.contract_version`、`promotion.previous_target_receipt.contract_version` 各自仍是含 `major`/`minor` 的对象。Profile 仍以对象级行表示，缺少 6 个非 identity leaf rows。见 Profile `L50-L155`、pinned schema `L243-L324`。 |
| Derived output exclusion | Pass | Profile 明确 evaluator output 是 derived、non-authoritative，位于 portable Envelope owner map 之外；只能在绑定精确 Envelope 与 `as_of` receipt 后由 Main App 镜像，不能变成 project fact、Source of Truth 或 Product/Quality/Release decision。见 Profile `L156-L164`。 |
| Source IDs / pre-freeze / `REP-Q-01` | Pass | `SRC-KOS-CONTRACT`、`SRC-PD`、`SRC-ASSIGNMENT`、`SRC-MAIN-PROMOTION`、`SRC-MAIN-STORE`、`SRC-P0-RECEIPT`、`SRC-P1-RECEIPT` 均有路径、身份或明确的 future-receipt boundary。Main-worktree promotion input 明确是 uncommitted、frozen worktree 中 absent、pre-freeze；稳定 identity、final SHA、actual base/head、hosted provenance 和 P1 receipt 仍显式保留给 `REP-Q-01`，没有写成 current-proof。见 Profile `L35-L48`、`L70-L113`。 |
| Invalid input / `as_of` / freshness / derived precedence | Pass for contract closure; not executed | Profile 保留 pinned evaluator 的顺序：invalid `validate_payload` 或外部带时区 `--as-of` 不产生 derived classification；未绑定 promotion target 为 `pending`；已绑定 target 但 promotion blocker 为 `none`；随后才可能是 `current-proof`、candidate unresolved=`none`、全 required claims 为 `non-comparable`=`comparator`、否则 `none`。`observed_at`、`freshness.valid_until`、外部 `as_of` 和 exact `policy.max_age_days` 已分开。见 Profile `L236-L279`；P0 matrix 仅为契约文字，未执行。 |
| `daily_beta` → `external_candidate` | Pass for contract closure; not executed | Profile 固定 `source_stage=daily_beta`、`target_stage=external_candidate`；`first` 要求当前 candidate-bound baseline 且 `previous_target_receipt=null`；`subsequent` 要求 `baseline=null`、不同 candidate 的 previous receipt，并以 `release_lineage` 在两侧 identity 中 resolved。未绑定 target 才是 `pending`，已绑定组合错误是 `none`。见 Profile `L281-L310`。未来 fixtures 仍未执行。 |
| P-01 | Pass for declared boundary; no receipt claimed | 只有 fresh、candidate-bound、`relation=same-head`、`hosted_ci_result=pass`、comparison basis 相等，且 `local_head == published_head == hosted_ci_head == candidate_head` 才可覆盖当前 candidate；缺失/unknown head、非 pass 或其他 relation fail closed。见 Profile `L312-L320`。这不是当前 P-01 receipt。 |
| D-01 | Pass for declared boundary; no receipt claimed | 只有 fresh、candidate-bound、`final_tree_digest == candidate.final_tree_digest`，checker ref/version、scope、comparison baseline、output ref resolved，`result=pass` 且 `exit_code=0` 才可覆盖；final tree 改变必须新 receipt。见 Profile `L321-L325`。这不是当前 D-01 receipt。 |
| P0 receipt / not-run wording | Pass | Freeze receipt 绑定了精确 P0 digest、manifest order、executor checks 及其非权威边界，并明确 schema/evaluator 因无 Envelope **not-run**，没有从 KOS validator 推导 Envelope 结果。见 freeze receipt `L19-L30`、`L44-L106`。 |
| Pointer grammar / lifecycle | Pass | 三种 pointer form（`repo://`、`appdiag://`、`opaque://`）均要求 `sha256=<64-lower-hex>` 与枚举 retention class；`release-candidate`、`diagnostic-short`、`review-record` 已关闭取值域。missing target、digest mismatch、expired class 或 inaccessible redacted export 为 blocker；写入、retention decision 与到期删除责任仍归 release-evidence owner。见 Profile `L202-L234`。 |

## Finding requiring closure

### `Q-RE-P1-CLOSURE-01` — promotion 子对象的 `contract_version` 仍非 leaf-exact

Profile `L52-L56` 声明只有 bounded identity maps 可以聚合，但以下三行仍把 schema object
作为单行 owner-map entry：

- `promotion.target_binding.contract_version`
- `promotion.baseline.contract_version`
- `promotion.previous_target_receipt.contract_version`

Pinned schema 的每个对象都要求并定义两个 leaves：`major` 与 `minor`。因此当前 map
仍缺少以下 6 个非 identity portable leaves：

- `promotion.target_binding.contract_version.major`
- `promotion.target_binding.contract_version.minor`
- `promotion.baseline.contract_version.major`
- `promotion.baseline.contract_version.minor`
- `promotion.previous_target_receipt.contract_version.major`
- `promotion.previous_target_receipt.contract_version.minor`

Required closure：在 Profile 中为这 6 个 leaves 分别给出一个 canonical owner 和一个
canonical source/identity，或修改 Profile 的聚合声明以定义一个明确、封闭且适用于
`contract_version` 的 object boundary；随后重新生成 P0 digest 并进行 fresh dual-lane
review。该 finding 不授权实现、fixture、runtime persistence 或 publication action。

## Non-claims

- 没有执行或声称执行任何 P0 derived-state matrix row、未来 P1 fixture、standalone schema
  evaluation、pinned evaluator 或 Envelope evaluation。
- 没有关闭 `REP-Q-01`；没有 Universe implementation final SHA、实际 base/head equality、
  hosted-CI provenance、P-01 delivery receipt 或 D-01 final-validation receipt。
- 没有声称 `current-proof`、external-candidate proof、Product Gate、Quality/Release Gate、
  Release Pass、publication readiness、TestFlight、App Store Connect、archive/export、
  device/Simulator、App Group、Swift/runtime、performance 或 network evidence。
- 没有把 `7652edc…`、P0 freeze receipt、KOS validator 结果或本 review 当作 Product、
  Architecture、Quality、merge 或 Release authority；`v0.8.0` advisory pin、untagged
  candidate 和 `required` 未改变。
- 没有迁移/backfill 历史 Assignment/evidence；没有实现、测试、xcodebuild、CI、设备操作、
  commit、push、merge、tag、upload、publication 或 Release action。
- 除本文件外，没有修改或新增任何其他文件；本文件是本次唯一允许新增的 artifact。
