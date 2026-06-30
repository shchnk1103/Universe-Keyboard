# Typo Correction Benchmark v1.0 Registry

> **Status:** Accepted — Registry Frozen
>
> **Registry version:** `1.0.0`
>
> **Published:** 2026-06-30 Asia/Shanghai
>
> **Effective task:** `TYPO-BENCHMARK-006B`
>
> **Owner:** 🏛️ Architecture & Knowledge Steward
>
> **Product approver:** 🧭 Product Lead
>
> **Domain reviewer:** 🧠 Input Intelligence Maintainer
>
> **Evidence reviewer:** 🧪 Quality, Performance & Release Maintainer

## Purpose And Authority

This document is the repository Source of Truth for Typo Correction Benchmark v1.0 identifiers and their relationships. It freezes:

- `TC-CTR-*` Contract IDs;
- `TC-CASE-*` Case IDs;
- `TC-PERF::{CaseID}::{ScenarioClass}` Performance Evidence references;
- cross-layer references, aliases, lifecycle and version rules.

The Registry freezes identity and reference relationships. It does not assert that a Case has passed an Evidence Gate, establish a performance budget, change product behavior, or define implementation constants. Current behavior explanation remains in [`TYPO_BENCHMARK.md`](TYPO_BENCHMARK.md), measurement procedure remains in [`PERFORMANCE_BASELINE.md`](PERFORMANCE_BASELINE.md), and Partial Commit architecture remains in [`architecture/partial-commit.md`](architecture/partial-commit.md).

Archived plans and historical evidence are not authoritative Registry sources. They may reference Canonical IDs but must retain their original dates, environments and evidence status.

## Registry Model

### Contract ID

Format: `TC-CTR-{LAYER}-{NNN}`.

| Layer | Meaning | Release boundary |
|---|---|---|
| `STB` | Stable Contract | Stable and Release-default behavior |
| `EXP` | Experimental Contract | Available only inside explicitly enabled experimental scope; Release remains default-off |
| `LRN` | Learning Contract | Applies only to eligible experimental corrections and cannot enable them by itself |
| `INT` | Integration Regression Contract | Cross-boundary regression and Release integration behavior |

A Contract ID represents stable product intent. It does not encode evidence status, implementation constants, software version or test name.

### Case ID

Format: `TC-CASE-{LAYER}-{NNN}`. Every Case has exactly one Primary Contract and one Primary Layer. Secondary references add evidence relationships and never add another coverage count.

### Performance Evidence Reference

Format: `TC-PERF::{CaseID}::{ScenarioClass}`.

Allowed Scenario Classes:

- `GENERATION`
- `PROVIDER_LOOKUP`
- `MERGE`
- `CANDIDATE_REFRESH`
- `SELECTION`
- `STORE_READ`
- `STORE_WRITE`
- `MEMORY`
- `LIFECYCLE`

A Performance Evidence reference must contain an existing Canonical Case ID. Performance is a horizontal evidence dimension: it creates neither a Contract nor a Case, does not count toward the four-layer behavior coverage, and cannot substitute for behavior evidence. Behavior evidence cannot substitute for performance evidence.

`P-01` through `P-17` below are frozen measurement profiles, not alternative Registry IDs. A concrete performance record uses a `TC-PERF::*` reference and cites the applicable profile.

## Contract Registry

All Contracts in v1.0 have lifecycle status `Active` and freeze product intent only.

### Stable Contracts

| Contract ID | Name | Frozen product intent |
|---|---|---|
| `TC-CTR-STB-001` | Valid Input Preservation | 正常有效输入不被 Typo Correction 干扰。 |
| `TC-CTR-STB-002` | RIME Satisfaction Guard | RIME 已给出 corrected best 首候选时，整组旁路纠错被抑制。 |
| `TC-CTR-STB-003` | Final Substitution | 安全末尾邻键 substitution 可贡献纠错候选。 |
| `TC-CTR-STB-004` | Initial Substitution | 安全首字符邻键 substitution 可贡献 near-front 候选。 |
| `TC-CTR-STB-005` | Middle Safe Substitution | 中间同类邻键 substitution 可贡献 near-front 候选。 |
| `TC-CTR-STB-006` | Repeated-final Deletion | 重复末尾字符删除可保守展示，不默认首位提升。 |
| `TC-CTR-STB-007` | Unsafe Edit Rejection | 短输入、跨类替换、非安全 edit 和歧义输入不产生强纠错。 |
| `TC-CTR-STB-008` | Candidate Verification | corrected input 必须存在 provider 验证候选才能展示。 |
| `TC-CTR-STB-009` | Candidate Quality Boundary | 候选文本必须满足保守质量语义；不冻结具体长度常量。 |
| `TC-CTR-STB-010` | Suggestion Boundedness | generation、lookup、resolved groups 和展示必须有界；不冻结具体数量。 |
| `TC-CTR-STB-011` | Stable Candidate Position | Stable promotion 以最终 Candidate Position Class 为合同语义。 |
| `TC-CTR-STB-012` | Stable Suggestion Protection | 开启实验能力时不得使原有 Stable suggestion 消失、降级或被挤出。 |
| `TC-CTR-STB-013` | Unsupported-by-default Isolation | insertion/transposition 在 Stable 和 Release 默认行为中关闭。 |

### Experimental Contracts

| Contract ID | Name | Frozen product intent |
|---|---|---|
| `TC-CTR-EXP-001` | Insertion Flag Isolation | insertion 仅在实验开关启用时生成。 |
| `TC-CTR-EXP-002` | Conservative Insertion | eligible near-final insertion 可 near-front 展示，默认不首位提升。 |
| `TC-CTR-EXP-003` | Transposition Flag Isolation | transposition 仅在实验开关启用时生成。 |
| `TC-CTR-EXP-004` | Adjacent Transposition | eligible adjacent transposition 可 near-front 展示，默认不首位提升。 |
| `TC-CTR-EXP-005` | Provider-dependent Transposition | transposition 是否展示取决于真实 RIME 是否已满足目标。 |
| `TC-CTR-EXP-006` | Experimental Safety Preservation | 实验开关开启后，正常输入和危险输入保护保持不变。 |
| `TC-CTR-EXP-007` | Combined Experimental Isolation | insertion/transposition 同开不得破坏 Stable Contract。 |
| `TC-CTR-EXP-008` | Release Default-off | Release 必须忽略实验开关残留，不能启用实验 edit。 |
| `TC-CTR-EXP-009` | Experimental Promotion Boundary | 默认实验候选仅 near-front；Top Promotion 只能来自 Learning Contract。 |

### Learning Contracts

| Contract ID | Name | Frozen product intent |
|---|---|---|
| `TC-CTR-LRN-001` | No-record Baseline | 无学习记录时使用实验默认 near-front 行为。 |
| `TC-CTR-LRN-002` | Learning Eligibility | 仅 eligible insertion/transposition 的明确选择可学习。 |
| `TC-CTR-LRN-003` | Ineligible Isolation | substitution、deletion、multi-edit、rejected correction 不学习。 |
| `TC-CTR-LRN-004` | Threshold Progression | 明确选择次数按冻结阶段推进；达到阈值前不得 Top。 |
| `TC-CTR-LRN-005` | Learned Near-front Ordering | 阈值前只调整 correction candidates 内部优先级。 |
| `TC-CTR-LRN-006` | Conditional Top Promotion | 达到冻结阈值后，guards 全通过时允许最终第 1 位。 |
| `TC-CTR-LRN-007` | Assessment Guard | 学习记录不得扩大或恢复 correction eligibility。 |
| `TC-CTR-LRN-008` | Prefix Guard | 与 normal top 互为前缀时禁止 learned Top Promotion。 |
| `TC-CTR-LRN-009` | Satisfaction Guard | 学习记录不得绕过 RIME Satisfaction Guard。 |
| `TC-CTR-LRN-010` | Pair Isolation | 学习只影响完全匹配的 correction key，不污染 unrelated input。 |
| `TC-CTR-LRN-011` | Reset | Reset 后恢复 No-record Baseline。 |
| `TC-CTR-LRN-012` | Expiry | 过期记录不再影响排序。 |
| `TC-CTR-LRN-013` | Bounded Store | Learning 数据范围保持有界，不冻结具体容量常量。 |
| `TC-CTR-LRN-014` | Store Failure Fallback | store unavailable 或 malformed 时安全回退为空记录。 |
| `TC-CTR-LRN-015` | Privacy Boundary | 不保存 surrounding text、不上传、不写 RIME User Dictionary。 |
| `TC-CTR-LRN-016` | Release Learning Isolation | Release 下历史记录不能自行启用实验 edit 或 promotion。 |

### Integration Regression Contracts

| Contract ID | Name | Frozen product intent |
|---|---|---|
| `TC-CTR-INT-001` | Segmented Preedit Normalization | display segmentation 不改变 typo matching 的原始输入语义。 |
| `TC-CTR-INT-002` | Provider Resolution | corrected-input provider 查询、过滤和空结果安全处理。 |
| `TC-CTR-INT-003` | Candidate Merge | 最终候选合并保持 normal order 和 Position Contract。 |
| `TC-CTR-INT-004` | Candidate Deduplication | normal/correction 重复候选只保留一个最终条目。 |
| `TC-CTR-INT-005` | Correction Selection | 选择 correction 后正确提交并清理 composition。 |
| `TC-CTR-INT-006` | Lifecycle Cleanup | visibility、mode、composition 和 recovery 不保留 stale typo state。 |
| `TC-CTR-INT-007` | Candidate Paging | typo merge 不破坏分页、快照和普通候选选择引用。 |
| `TC-CTR-INT-008` | Partial Commit Flag Isolation | Typo Partial Commit 默认关闭。 |
| `TC-CTR-INT-009` | Partial Commit Eligibility | 仅 eligible Stable substitution 可进入 Typo Partial Commit。 |
| `TC-CTR-INT-010` | Partial Commit Restore | 首次 Delete 恢复精确 original input。 |
| `TC-CTR-INT-011` | Partial Commit Invalidation | 继续输入后 checkpoint 失效。 |
| `TC-CTR-INT-012` | Partial Commit Fallback | 非 eligible correction 和失败边界保持 full commit。 |
| `TC-CTR-INT-013` | Cross-layer Release Integration | Release 下 Stable、Experimental、Learning 和 Integration 边界同时成立。 |

## Case Registry

All Cases in v1.0 have lifecycle status `Active`. Position Class is a frozen observable outcome, not an implementation index or numeric constant.

### Stable Cases

| Case ID | Primary Contract | Frozen Case | Position Class |
|---|---|---|---|
| `TC-CASE-STB-001` | `TC-CTR-STB-001` | 正常输入 `nihao` | Correction Absent |
| `TC-CASE-STB-002` | `TC-CTR-STB-001` | 正常输入集合：`women/jintian/xiexie/shijian/zhongwen/ceshi` | Correction Absent |
| `TC-CASE-STB-003` | `TC-CTR-STB-002` | normal top 等于 corrected best | Entire Correction Group Absent |
| `TC-CASE-STB-004` | `TC-CTR-STB-003` | `nihap → nihao → 你好` | Top when prefix condition passes |
| `TC-CASE-STB-005` | `TC-CTR-STB-004` | `bihao → nihao → 你好` | Near-front |
| `TC-CASE-STB-006` | `TC-CTR-STB-005` | `nigao → nihao → 你好` | Near-front |
| `TC-CASE-STB-007` | `TC-CTR-STB-005` | `zhonghuo → zhongguo → 中国` | Near-front |
| `TC-CASE-STB-008` | `TC-CTR-STB-006` | `nihaoo → nihao → 你好` | Non-top conservative |
| `TC-CASE-STB-009` | `TC-CTR-STB-007` | 短输入保护 | Correction Absent |
| `TC-CASE-STB-010` | `TC-CTR-STB-007` | `nihso` 中间跨类替换 | Correction Absent |
| `TC-CASE-STB-011` | `TC-CTR-STB-007` | `nihau` 非安全末尾错误 | Correction Absent |
| `TC-CASE-STB-012` | `TC-CTR-STB-007` | `haop/xianp` 歧义危险输入 | Correction Absent |
| `TC-CASE-STB-013` | `TC-CTR-STB-008` | corrected input 无 provider candidate | Correction Absent |
| `TC-CASE-STB-014` | `TC-CTR-STB-009` | candidate 不满足保守长度/质量语义 | Correction Absent |
| `TC-CASE-STB-015` | `TC-CTR-STB-010` | 高生成量输入仍保持全链路有界 | Bounded |
| `TC-CASE-STB-016` | `TC-CTR-STB-011` | Stable final substitution 最终位置 | Top |
| `TC-CASE-STB-017` | `TC-CTR-STB-011` | Stable initial/middle substitution 最终位置 | Near-front |
| `TC-CASE-STB-018` | `TC-CTR-STB-011` | repeated-final deletion 最终位置 | Non-top |
| `TC-CASE-STB-019` | `TC-CTR-STB-013` | Stable 默认 omission 关闭 | Correction Absent |
| `TC-CASE-STB-020` | `TC-CTR-STB-013` | Stable 默认 transposition 关闭 | Correction Absent |

### Experimental Cases

| Case ID | Primary Contract | Frozen Case | Position Class |
|---|---|---|---|
| `TC-CASE-EXP-001` | `TC-CTR-EXP-001` | insertion flag-off：`niho` | Correction Absent |
| `TC-CASE-EXP-002` | `TC-CTR-EXP-002` | insertion flag-on：`niho → nihao → 你好` | Near-front |
| `TC-CASE-EXP-003` | `TC-CTR-EXP-003` | transposition flag-off：`nihoa` | Correction Absent |
| `TC-CASE-EXP-004` | `TC-CTR-EXP-005` | `nihoa-unsatisfied` | Near-front |
| `TC-CASE-EXP-005` | `TC-CTR-EXP-005` | `nihoa-satisfied` | Entire Correction Group Absent |
| `TC-CASE-EXP-006` | `TC-CTR-EXP-004` | `zohngguo → zhongguo → 中国` | Near-front |
| `TC-CASE-EXP-007` | `TC-CTR-EXP-006` | 实验 flag-on + 正常输入集合 | Correction Absent |
| `TC-CASE-EXP-008` | `TC-CTR-EXP-006` | 实验 flag-on + 危险输入集合 | Correction Absent |
| `TC-CASE-EXP-009` | `TC-CTR-STB-012` | Stable + insertion | Stable position preserved |
| `TC-CASE-EXP-010` | `TC-CTR-STB-012` | Stable + transposition | Stable position preserved |
| `TC-CASE-EXP-011` | `TC-CTR-EXP-007` | Stable + insertion + transposition | Stable position preserved |
| `TC-CASE-EXP-012` | `TC-CTR-EXP-008` | Release + stale insertion flag | Correction Absent |
| `TC-CASE-EXP-013` | `TC-CTR-EXP-008` | Release + stale transposition flag | Correction Absent |
| `TC-CASE-EXP-014` | `TC-CTR-EXP-009` | unlearned insertion/transposition | Near-front, never Top |

`TC-CASE-EXP-004` and `TC-CASE-EXP-005` are independent environment-dependent Cases. Each Case freezes its own schema, artifact, build, clean state and provider output. Their evidence must not be merged into one run. If a release-relevant Real RIME environment cannot produce the unsatisfied state, `TC-CASE-EXP-004` is `Blocked / Environment unavailable`, not `Failed`; Fake Provider evidence may exercise the branch but cannot replace Real RIME evidence.

### Learning Cases

| Case ID | Primary Contract | Frozen Case | Position Class / Outcome |
|---|---|---|---|
| `TC-CASE-LRN-001` | `TC-CTR-LRN-001` | Eligible + No Record | Near-front baseline |
| `TC-CASE-LRN-002` | `TC-CTR-LRN-002` | Eligible insertion 明确选择 | Record Created |
| `TC-CASE-LRN-003` | `TC-CTR-LRN-002` | Eligible transposition 明确选择 | Record Created |
| `TC-CASE-LRN-004` | `TC-CTR-LRN-003` | Ineligible substitution + learned history | Stable position unchanged |
| `TC-CASE-LRN-005` | `TC-CTR-LRN-003` | Ineligible deletion/multi-edit/rejected + history | No learning effect |
| `TC-CASE-LRN-006` | `TC-CTR-LRN-004` | 第一次明确选择后的下一次输入 | Near-front |
| `TC-CASE-LRN-007` | `TC-CTR-LRN-004` | 第二次明确选择后的下一次输入 | Near-front |
| `TC-CASE-LRN-008` | `TC-CTR-LRN-006` | 第三次明确选择且 guards 通过 | Top |
| `TC-CASE-LRN-009` | `TC-CTR-LRN-005` | 多个 correction candidates，阈值前内部排序 | Near-front |
| `TC-CASE-LRN-010` | `TC-CTR-LRN-008` | Prefix-related normal + learned history | Top prohibited |
| `TC-CASE-LRN-011` | `TC-CTR-LRN-009` | Learned + RIME Satisfied | Entire Correction Group Absent |
| `TC-CASE-LRN-012` | `TC-CTR-LRN-007` | Learned history + assessment rejected | Correction Absent |
| `TC-CASE-LRN-013` | `TC-CTR-LRN-010` | Learned pair A + unrelated input B | B unchanged |
| `TC-CASE-LRN-014` | `TC-CTR-LRN-010` | 多个 learned pairs 相互隔离 | Pair-local behavior |
| `TC-CASE-LRN-015` | `TC-CTR-LRN-011` | Reset 后重新输入 | Near-front baseline |
| `TC-CASE-LRN-016` | `TC-CTR-LRN-012` | Expired record 后重新输入 | Near-front baseline |
| `TC-CASE-LRN-017` | `TC-CTR-LRN-013` | Store 超过语义容量边界 | Store remains bounded |
| `TC-CASE-LRN-018` | `TC-CTR-LRN-014` | Store unavailable | Empty-snapshot fallback |
| `TC-CASE-LRN-019` | `TC-CTR-LRN-014` | Malformed store | Empty-snapshot fallback |
| `TC-CASE-LRN-020` | `TC-CTR-LRN-015` | Persisted payload scope inspection | Privacy boundary preserved |
| `TC-CASE-LRN-021` | `TC-CTR-LRN-015` | Learning operation 前后 RIME user data | No RIME dictionary write |
| `TC-CASE-LRN-022` | `TC-CTR-LRN-016` | Release + stale learning records | Experimental correction absent |
| `TC-CASE-LRN-023` | `TC-CTR-LRN-016` | Release + stale flags + stale learning records | Experimental correction absent |

### Integration Regression Cases

| Case ID | Primary Contract | Frozen Case | Position Class / Outcome |
|---|---|---|---|
| `TC-CASE-INT-001` | `TC-CTR-INT-001` | segmented preedit `ni h a p` | Same correction as normalized input |
| `TC-CASE-INT-002` | `TC-CTR-INT-002` | corrected provider 空结果 | Correction Absent |
| `TC-CASE-INT-003` | `TC-CTR-INT-003` | normal + correction 最终合并 | Contract-defined position |
| `TC-CASE-INT-004` | `TC-CTR-INT-004` | normal/correction 候选文本重复 | Single final item |
| `TC-CASE-INT-005` | `TC-CTR-INT-005` | 点击 correction candidate | Correct commit and cleanup |
| `TC-CASE-INT-006` | `TC-CTR-INT-006` | visibility/mode/recovery 后 typo state | No stale state |
| `TC-CASE-INT-007` | `TC-CTR-INT-007` | candidate paging/expanded panel | Stable snapshot/reference |
| `TC-CASE-INT-008` | `TC-CTR-INT-008` | Typo Partial Commit flag-off | Full commit |
| `TC-CASE-INT-009` | `TC-CTR-INT-009` | eligible substitution + Partial Commit flag-on | Partial Commit |
| `TC-CASE-INT-010` | `TC-CTR-INT-010` | Partial Commit 后首次 Delete | Exact original input restored |
| `TC-CASE-INT-011` | `TC-CTR-INT-011` | Partial Commit 后继续输入 | Checkpoint invalidated |
| `TC-CASE-INT-012` | `TC-CTR-INT-012` | deletion/multi-edit/low-confidence fallback | Full commit |
| `TC-CASE-INT-013` | `TC-CTR-INT-012` | candidate missing/no remainder/active checkpoint | Full commit |
| `TC-CASE-INT-014` | `TC-CTR-INT-013` | Release 全层联合隔离 | Stable only |

## Cross-layer Reference Matrix

The Primary Contract alone counts the Case toward coverage. Secondary references may attach evidence but must not count the Case again.

| Primary Case | Primary Layer | Secondary Contract References | Frozen relationship |
|---|---|---|---|
| `TC-CASE-STB-003` | Stable | `TC-CTR-EXP-005`, `TC-CTR-LRN-009`, `TC-CTR-INT-003` | Satisfaction Guard 由 Stable 计数一次。 |
| `TC-CASE-STB-014` | Stable | `TC-CTR-STB-008` | candidate length 只作为 Stable 质量语义。 |
| `TC-CASE-STB-015` | Stable | All-layer Performance Evidence | boundedness 是产品语义；具体数量不是合同。 |
| `TC-CASE-EXP-004` | Experimental | `TC-CTR-INT-002`, `TC-CTR-INT-003` | `nihoa-unsatisfied`。 |
| `TC-CASE-EXP-005` | Experimental | `TC-CTR-STB-002`, `TC-CTR-INT-003` | `nihoa-satisfied`，不重复计入 Stable coverage。 |
| `TC-CASE-EXP-009` | Experimental | `TC-CTR-STB-012`, `TC-CTR-INT-003` | Stable + insertion。 |
| `TC-CASE-EXP-010` | Experimental | `TC-CTR-STB-012`, `TC-CTR-INT-003` | Stable + transposition。 |
| `TC-CASE-EXP-011` | Experimental | `TC-CTR-STB-012`, `TC-CTR-EXP-007`, `TC-CTR-INT-003` | Stable + insertion + transposition。 |
| `TC-CASE-LRN-008` | Learning | `TC-CTR-EXP-009`, `TC-CTR-INT-003` | Learning Top Promotion 仍为 Experimental 边界。 |
| `TC-CASE-LRN-010` | Learning | `TC-CTR-STB-001`, `TC-CTR-INT-003` | Prefix Guard。 |
| `TC-CASE-LRN-011` | Learning | `TC-CTR-STB-002`, `TC-CTR-INT-003` | Learned + Satisfaction。 |
| `TC-CASE-LRN-013` | Learning | `TC-CTR-STB-001` | Unrelated Input Isolation。 |
| `TC-CASE-LRN-015` | Learning | `TC-CTR-INT-006` | Reset 后 Extension 状态。 |
| `TC-CASE-LRN-018` | Learning | `TC-CTR-INT-006` | Store unavailable degradation。 |
| `TC-CASE-LRN-022` | Learning | `TC-CTR-EXP-008`, `TC-CTR-INT-013` | Release learning isolation。 |
| `TC-CASE-LRN-023` | Learning | `TC-CTR-EXP-008`, `TC-CTR-INT-013` | Release flags + records 组合。 |
| `TC-CASE-INT-001` | Integration | `TC-CTR-STB-003` | segmented preedit 不重复计入 Stable correction。 |
| `TC-CASE-INT-014` | Integration | `TC-CTR-EXP-008`, `TC-CTR-LRN-016` | Release 全层联合回归。 |

## Performance Registry

### Evidence Contract

All performance runs use synthetic input and must not collect real user text. Results record sample count, median, worst observed value and the complete retained distribution. No absolute budget exists before a reviewed baseline.

Every conclusion is a paired comparison under the same device, OS, host, input field, schema/artifact, build configuration, Full Access state, thermal/power condition, synthetic input sequence and cadence. A changed key condition creates a new environment baseline and cannot produce a regression pass/fail comparison.

Required evidence dimensions include end-to-end key latency, RIME time, Typo generation, candidate refresh/merge, `syncUI`, longest main-thread block, sustained per-key distribution and stalls, resident/peak/growth memory, bounded candidate/suggestion accumulation, dropped feedback, crash, jetsam and session recovery.

### Measurement Profiles

| Profile | Scenario | Frozen configuration and comparison | Required environment |
|---|---|---|---|
| `P-01` | Stable baseline | Stable Case set; no experimental edit; no learning. Repeated runs establish the first baseline. | Real RIME + physical device |
| `P-02` | Experimental all off | Experimental flags explicitly off; stale settings may be preset. Compare with `P-01`. | Real RIME + physical device |
| `P-03` | Insertion only | insertion on; transposition off; no record. Compare with `P-02`. | Real RIME + physical device |
| `P-04` | Transposition only | insertion off; transposition on; no record. Compare with `P-02`. | Real RIME + physical device |
| `P-05` | Insertion + transposition | both on; no record. Compare with `P-02`, `P-03`, `P-04`. | Real RIME + physical device |
| `P-06` | Learning no-record | experiment enabled; empty learning snapshot. Compare with matching `P-03`, `P-04` or `P-05`. | Real RIME + physical device |
| `P-07` | Learning near-front | eligible record below Top Promotion state. Compare with `P-06`. | Real RIME + physical device |
| `P-08` | Learning Top Promotion | frozen Top Promotion state satisfied. Compare with `P-06`, `P-07`. | Real RIME + physical device |
| `P-09` | RIME satisfied/suppression | normal RIME already satisfies target, such as `TC-CASE-EXP-005`. Compare with experiment-off for the same input. | Real RIME + physical device |
| `P-10` | Stable + Experimental competition | Stable and Experimental paths compete for the same input. Compare with Stable-only and Experimental-only. | Real RIME + physical device |
| `P-11` | Sustained Stable input | fixed normal/Stable sequence at controlled cadence. Compare with short `P-01`. | Physical device |
| `P-12` | Sustained Experimental input | fixed mixed experimental hit/miss sequence. Compare with `P-11`. | Real RIME + physical device |
| `P-13` | Candidate refresh/merge | first page, paging, near-edge, expanded panel and post-selection refresh; compare experiment off/on and three learning states. | Real RIME + physical device |
| `P-14` | Memory growth | cold start, sustained input, paging, expansion and host switching; compare experiment off with maximum test scope. | Physical device |
| `P-15` | Release default-off | Release artifact with preset experimental flags and learning records. Compare with clean Release state. | Release + physical device |
| `P-16` | Session recovery | fresh session, host return and session rebuild; compare experiment off/on. | Real RIME + physical device |
| `P-17` | Fake Provider diagnostic | deterministic fixtures corresponding to core Cases; internal same-build comparison only. | Fake Provider |

`P-17` cannot replace or waive any Real RIME or physical-device requirement in `P-01` through `P-16`.

### Performance Status

| Status | Meaning |
|---|---|
| `Baseline collected` | First comparable baseline is complete; it does not claim superiority to a budget. |
| `Passed` | Comparison conditions and evidence are complete, with no unexplained degradation, stall, sustained memory growth, crash or jetsam. |
| `Failed` | Comparable evidence shows repeatable degradation, hot-path violation, sustained memory growth, crash or jetsam. |
| `Blocked` | Required device, Real RIME, Release artifact, trace, stable fixture or comparable environment is unavailable. |
| `Skipped` | An auxiliary scenario is explicitly outside the run scope. Fake results cannot justify skipping Real RIME, physical-device, memory or Release-isolation requirements. |

### Hot-path Safety

From touch/action entry until visible UI stabilizes, the key path must not introduce synchronous file I/O, directory scanning, hashing, network/deployment work, per-key App Group reads/writes, per-key learning JSON encoding/decoding, unbounded generation/accumulation/sorting, persisted user-input logs, synchronous high-frequency log flush, unrelated schema/backup/recovery work, or main-thread waits on background work.

Key processing uses an already loaded learning snapshot. Learning persistence after an explicit selection is measured separately and must not block the next input feedback. RIME, Typo generation, merge and UI synchronization remain separately attributable. Sustained input memory must approach a stable trend; lifecycle exit, crash and jetsam are classified separately.

Required Hot-path Safety evidence includes Time Profiler main-thread stacks, decomposed key intervals, Allocations or Memory Graph, sustained input results, candidate refresh/merge traces, Release default-off comparison, and verifiable absence of synchronous I/O or persistence in the ordinary per-key path.

### Reference Examples

- `TC-PERF::TC-CASE-EXP-011::PROVIDER_LOOKUP`
- `TC-PERF::TC-CASE-LRN-008::CANDIDATE_REFRESH`
- `TC-PERF::TC-CASE-LRN-017::STORE_READ`

## Alias Registry

### Deprecated Contract Aliases

| Historical Alias | Canonical target | Status and constraint |
|---|---|---|
| `ST-SUB-FINAL` | `TC-CTR-STB-003` | Deprecated Alias |
| `ST-SUB-INITIAL` | `TC-CTR-STB-004` | Deprecated Alias |
| `ST-SUB-MIDDLE` | `TC-CTR-STB-005` | Deprecated Alias |
| `ST-DEL-FINAL` | `TC-CTR-STB-006` | Deprecated Alias |
| `ST-NORMAL` | `TC-CTR-STB-001` | Deprecated Alias |
| `ST-SATISFIED` | `TC-CTR-STB-002` | Deprecated Alias |
| `ST-BOUNDED` | `TC-CTR-STB-010` | Deprecated Alias |
| `EX-INS-TARGET` | `TC-CTR-EXP-002` | Deprecated Alias |
| `EX-TRANS-UNSAT` | `TC-CTR-EXP-005` | Deprecated Alias; use `TC-CASE-EXP-004` for evidence |
| `EX-TRANS-SAT` | `TC-CTR-EXP-005` | Deprecated Alias; use `TC-CASE-EXP-005` for evidence |
| `LN-TOP` | `TC-CTR-LRN-006` | Deprecated Alias |
| `LN-PREFIX-GUARD` | `TC-CTR-LRN-008` | Deprecated Alias |
| `LN-SATISFIED` | `TC-CTR-LRN-009` | Deprecated Alias |
| `IR-PREEDIT` | `TC-CTR-INT-001` | Deprecated Alias |
| `IR-PARTIAL-COMMIT` | `TC-CTR-INT-008` through `TC-CTR-INT-012` | Deprecated Aggregate Alias; must be expanded and cannot be counted directly |

### Historical Case-name Aliases

| Historical name | Canonical Case ID |
|---|---|
| `nihoa-unsatisfied` | `TC-CASE-EXP-004` |
| `nihoa-satisfied` | `TC-CASE-EXP-005` |
| `Stable + insertion` | `TC-CASE-EXP-009` |
| `Stable + transposition` | `TC-CASE-EXP-010` |
| `Stable + insertion + transposition` | `TC-CASE-EXP-011` |
| `Learned + Satisfaction` | `TC-CASE-LRN-011` |
| `Release Learning Isolation` | `TC-CASE-LRN-022` |
| `Release flags + records isolation` | `TC-CASE-LRN-023` |

## Version And Lifecycle Policy

Registry version uses Semantic Versioning:

- **Major:** incompatible Registry schema change, removal of a compatibility mapping, or semantic replacement requiring consumer migration.
- **Minor:** new approved Canonical IDs, aliases, deprecations or supersessions that preserve existing meanings.
- **Patch:** link, spelling or non-semantic metadata corrections.

Canonical IDs are immutable and never reused. A product-intent change creates a new ID and marks the old ID `Superseded`; implementation-constant changes update evidence metadata and do not create a new Case ID.

Lifecycle states:

- `Active`: canonical and valid for new evidence.
- `Deprecated`: resolvable for compatibility but prohibited in new evidence.
- `Superseded`: retained for history and linked to its replacement; it no longer defines current intent.

Rules:

- New evidence uses Canonical IDs only.
- Deprecated Aliases exist only to read historical Task 2–5 outputs and never count independently.
- Aggregate Aliases must be expanded to concrete Canonical IDs.
- Historical device evidence retains its original name, date and environment while adding a Canonical mapping.
- Mapping historical evidence does not promote it to current evidence.
- Alias mappings remain resolvable; removal requires a Major version and zero repository references.
- A superseded entry records replacement ID, reason and effective Registry version.

## Repository Dependency Map

```text
Product-approved frozen inputs
  -> ADR 0009 (why the Registry is independent and versioned)
       -> TYPO_BENCHMARK_REGISTRY.md (ID and relationship authority)
            -> TYPO_BENCHMARK.md (behavior explanation)
            -> PERFORMANCE_BASELINE.md (measurement procedure)
            -> architecture/partial-commit.md (Partial Commit architecture)
            -> RELEASE_CHECKLIST.md (future evidence gates)
            -> future evidence and observability tasks
            -> KNOWLEDGE_INDEX / READING_MAPS / DOCUMENTATION_GRAPH

Archived plans and dated evidence
  -> Canonical Registry IDs
  -> never become current authority
```

## Task Alignment

| Accepted Task | Registry responsibility | v1.0 publication |
|---|---|---|
| Task 4: Real RIME Evidence Matrix | Real RIME evidence references Canonical Cases; environment-dependent `nihoa` Cases remain separate | Aligned |
| Task 5: Learning Evidence Contract | Learning Contracts and `TC-CASE-LRN-001...023` | Aligned |
| Task 6: Performance Evidence Contract | `TC-PERF::{CaseID}::{ScenarioClass}`, profiles `P-01...P-17`, comparison and hot-path rules | Aligned |
| Task 6A: Contract & Case Registry | Four Contract layers, four Case layers, primary coverage and aliases | Published as Repository Source of Truth |
| Task 4A: Real RIME Readiness Preflight | Blocked evidence remains distinct from failed behavior; Fake Provider cannot replace Real RIME | Aligned |

Alignment means the accepted identifiers and relationships are published. It does not assert Evidence Gate completion.

## Change Procedure

1. Product Lead approves any new or changed product intent.
2. Domain and Evidence reviewers confirm Contract/Case and evidence relationships.
3. Architecture & Knowledge Steward allocates a new immutable ID when semantics change.
4. Update this Registry first, then review downstream documents using [`KNOWLEDGE_DEPENDENCIES.md`](KNOWLEDGE_DEPENDENCIES.md).
5. Validate duplicate IDs, Primary Contract targets, secondary references, `TC-PERF::*` Case targets, aliases and supersession targets.
6. Run local Markdown file/fragment checks and `git diff --check`.
7. Record the accepted Registry version without converting historical evidence into current evidence.

## Task 7 Boundary

Task 7 remains prohibited. Registry publication satisfies the knowledge-continuity prerequisite only. Environment freeze, observability, physical-device availability, Release evidence artifacts and a formal Quality `Ready` decision remain separate Entry Criteria.
