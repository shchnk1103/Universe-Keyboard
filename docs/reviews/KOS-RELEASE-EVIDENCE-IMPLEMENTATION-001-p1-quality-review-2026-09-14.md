# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1 — Quality / Performance / Release review

## Review identity and boundary

| Field | Value |
|---|---|
| Reviewer | Independent Quality, Performance and Release reviewer |
| Review mode | Fresh-runtime, read-only review of the P1 scope package |
| Worktree | `/private/tmp/universe-keyboard-kos-upgrade-uk-005` |
| Branch / HEAD | `codex/kos-upgrade-uk-005-release-evidence` / `3139f8d3bdb6be6622504ea731988f42681896fb` |
| Exact P1 package digest | `e2ab44303b84d62043bf545d6cfd61cd086e28a9becd18cf7a0ea9bafc8faee8` |
| Digest scope | P1 scope-freeze receipt's ordered raw-byte concatenation of ten manifest files; this review artifact is excluded |
| Review observed at | `2026-09-14T19:27:24+0800` |

本 review 只审阅 P1-A 的 Assignment、Authorization、P0 Profile、状态镜像和
scope-freeze receipt。没有修改任何既有文件、Swift、项目源代码、测试、工作流或外部状态；
本文件是本次唯一新增 artifact。结论不扩展到 P1 实现、设备、性能实测、发布、TestFlight
或 Release。

## Overall

**PASS WITH CONDITIONS** — 精确的 P1 package digest 可复现，P1-A 的授权边界和核心
release-evidence 语义总体足够清楚；但 P0 predecessor digest 在当前 worktree 不能复现，且
delta-aware / fail-closed 的执行级证据尚未产生。因此本 review 不能关闭 P1，也不能授予
current-proof、Product Gate、Quality/Release Gate、Beta Review、上传或 Release 结论。

| Priority | Count |
|---|---:|
| P0 | 0 |
| P1 | 1 |
| P2 | 3 |
| P3 | 0 |

### Conditions for P1 implementation exit

1. 修复或重新冻结 `P0` predecessor receipt，使其 manifest digest 与明确的不可变快照
   一致；在此之前不得把 `e1fc…` 当作当前可复现的 P0 package identity。
2. 由 P1 implementation receipt 产生并运行受固定 schema/evaluator pins 约束、带显式
   `--as-of` 的 Envelope fixtures；逐项记录 fixture ID、命令、输出、exit code 和
   non-claims。当前 receipt 已正确声明这些检查尚未执行，因此这里是未完成的 exit
   condition，不是把“未运行”误报成失败。
3. 将 delta-aware 的 changed-surface → affected-claim 依赖和未知/歧义输入的
   fail-closed 行为写成可执行测试；所有 P-01/D-01、freshness、source identity 和
   `REP-Q-01` 条件仍须分别满足。

## Independent verification

### Package identity and structural checks

- 按 receipt [`P1 manifest and reproduction command`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L19-L46)
  独立重算十个文件的 raw-byte concatenation，结果为
  `e2ab44303b84d62043bf545d6cfd61cd086e28a9becd18cf7a0ea9bafc8faee8`，与 review 输入完全一致。
- 十个 manifest 文件均存在；`python3 -m json.tool .kos/project.json` 通过；对十个
  manifest 文件执行有界的 Markdown 本地链接/尾随空白检查通过。
- `git diff --check` 通过（该命令本身只覆盖 tracked diff）；KOS validator exit `0`。
  validator 只报告既有无关历史记录 warning，没有报告本 P1 Assignment、Authorization、
  Profile、状态镜像或 `.kos/project.json` 的新增诊断。
- 当前 worktree 的变更范围未发现 Swift、`Sources`、`Packages`、测试 target、Xcode 工程或
  CI workflow 路径；这不是对运行时正确性或性能的证明。

### Scope and semantic coverage

| Review area | Result | Evidence / boundary |
|---|---|---|
| Authority chain and scope | Pass | P1 Assignment 的 `authorization_refs`、parent refs、职责和 Product approver 明确；P1 Authorization 的 action/target/issuer 与之匹配，并明确不扩大 P0 Authorization（[`Assignment`](../assignments/kos-release-evidence-implementation-001-p1.md#L3-L61)、[`Authorization`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L10-L67)）。 |
| Evaluator state semantics | Pass as contract text; execution pending | Profile 保留 `invalid → no classification`、unbound target=`pending`、bound blocker=`none`、完整条件=`current-proof`、unresolved candidate=`none`、all non-comparable=`comparator` 和 fallback=`none`（[`matrix`](../kos/release-evidence-profile.md#L239-L282)）。P1 receipt 明确没有执行 evaluator/schema（[`not-run`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L60-L65)）。 |
| First/subsequent baseline | Pass as contract text; negative fixtures required | `daily_beta → external_candidate`、`first` 的 baseline/null previous receipt、`subsequent` 的 null baseline/different previous receipt/`release_lineage` 绑定已明确（[`promotion rules`](../kos/release-evidence-profile.md#L284-L313)）。 |
| P-01 / D-01 | Pass as contract text; receipt pairs pending | P-01 要求 fresh candidate-bound、`same-head`、hosted pass、comparison basis 相等和全部 head 等于 candidate head；D-01 要求 final-tree digest、checker/version/scope/baseline/output、result 和 exit code 全部闭合（[`P-01/D-01`](../kos/release-evidence-profile.md#L315-L328)）。 |
| Delta-aware reuse | Direction is fail-closed, executable dependency proof incomplete | Assignment 要求 touched claim/binding 重跑、identity/freshness 仍有效才可复用，并列出升档类别（[`validation contract`](../assignments/kos-release-evidence-implementation-001-p1.md#L131-L149)）。需要补充本 review 的 `QPR-P2-02` 条件。 |
| Freshness / `as_of` / provenance | Boundary is explicit; per-receipt execution pending | `as_of` 被保持为带时区的 evaluator input，和 `observed_at`、`valid_until`、`max_age_days` 分离；provenance/current-proof 约束已写入 Profile（[`freshness`](../kos/release-evidence-profile.md#L239-L248)、[`owner map`](../kos/release-evidence-profile.md#L100-L104)）。 |
| Privacy / hot path / network | Pass for the declared scope | raw keyboard/host text、credentials、full logs、同步 Extension I/O、runtime network 和新 App Group ownership 均被禁止（[`Profile exclusions`](../kos/release-evidence-profile.md#L179-L203)、[`P1 exclusions`](../assignments/kos-release-evidence-implementation-001-p1.md#L151-L165)）。运行时/性能证据尚未执行且未被伪造。 |
| Daily Beta → external candidate | Pass | 允许复用的是精确绑定的 claim/observation history；delivery、Beta Review、hosted provenance、Product/Release 仍是独立事实和 Gate，明确不是自动 external approval（[`Assignment boundary`](../assignments/kos-release-evidence-implementation-001-p1.md#L96-L103)、[`Authorization boundary`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L107-L118)）。 |
| Docs-only receipt | P1 digest pass; predecessor-chain condition open | P1 十文件 digest 与输入一致；但 P0 receipt 的八文件 digest 不能在当前状态重现，见 `QPR-P1-01`。 |

## Findings

### QPR-P1-01 — P0 predecessor digest is not reproducible

**Severity:** P1 · **Disposition:** `fix` before P1 implementation exit

P1 scope-freeze receipt 将 predecessor P0 digest 记录为
`e1fc4382418c793850814c0d231ca651d328055954f57e75fe4ed50874468706`，并将其作为前置
证据（[`P1 predecessor reference`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L7-L17)）。
P0 receipt 自己也定义了同一组八文件和同一 digest（[`P0 manifest`](../evidence/kos-release-evidence-implementation-001-p0-freeze-2026-09-14.md#L19-L42)）。

在本次 exact worktree 中按 P0 receipt 的原八文件顺序独立重算，实际得到：

```text
db57cc64d46797e2292f07feca7ca6cc51d7afb83e01db1f3ed5970464065fca
```

这与记录的 `e1fc…` 不一致。P1 十文件 package 的 `e2ab…` 本身是可复现的；问题只在
P0 predecessor 的历史 manifest 包含了后来被 P1 状态同步修改的文件，却没有新的不可变
快照或 successor receipt。影响是审计者无法仅凭当前 worktree 重建 P1 所引用的 P0
package identity；这不是运行时缺陷，但会削弱 predecessor provenance。

建议由 Executor/Architecture owner 生成一个明确标注 successor/status-sync 的 P0 receipt，
或绑定一个真正不可变的提交/快照，并让 P1 receipt 引用新的可复现 identity。此 review
不修改既有 receipt，遵守本次“只创建 review artifact”的边界。

### QPR-P2-01 — P1 docs-only receipt 没有记录有界链接检查的精确命令和输出

**Severity:** P2 · **Disposition:** `fix` in the next scope/implementation receipt

P1 receipt 声明十个 manifest 文件完成 Markdown/link/trailing-whitespace 检查，但只给出
JSON、`git diff --check` 和 KOS validator 的命令；链接检查的实际脚本和输出没有进入 receipt
（[`preparation checks`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L48-L65)）。
相比之下，P0 receipt 记录了具体 Python 检查体和输出（[`P0 check output`](../evidence/kos-release-evidence-implementation-001-p0-freeze-2026-09-14.md#L48-L94)）。

本 reviewer 重新执行了一个有界十文件检查并得到 pass，但这不能把未记录的 executor 命令
追溯性地补写进 P1 receipt。下一份 receipt 应记录精确命令、脚本/解释器版本、文件清单和
原始摘要，或引用一个不可变的 review log；否则 docs-only 结论可由独立 reviewer 重做，
但不能按 receipt 原样重现。

### QPR-P2-02 — delta-aware scope 尚未形成可执行的依赖闭包和未知输入规则

**Severity:** P2 · **Disposition:** `fix` before P1 implementation review

Assignment 已给出正确的原则：只复用 identity/freshness 未变化的 evidence，触及 claim 或
binding 必须重跑，schema/evaluator、owner/source、promotion、privacy、build/release 和
final-validation 变化要升档（[`delta rule`](../assignments/kos-release-evidence-implementation-001-p1.md#L90-L95)）。
变化分类表也给出了各类大方向（[`change classes`](../assignments/kos-release-evidence-implementation-001-p1.md#L139-L149)）。

但它没有要求一份可执行的 `changed surface → affected claim/binding → required checks`
依赖表，也没有明确说 classifier 对未知/歧义 diff、无法解析的 path 或缺失 changed-surface
输入必须 **不复用任何旧 evidence 并升为 full/fail-closed**。如果实现者把 serializer、
source owner、comparison basis 或 freshness policy 的变化误判为“单字段变化”，仍可能
错误复用旧 daily-Beta evidence。

P1 implementation receipt 应至少包含一条安全复用正例，以及 candidate/artifact/context/
environment/profile/source/coverage/comparison/freshness、contract/schema/evaluator、
promotion/history、delivery/hosted、final-validation 和未知 diff 的逐项失效负例；每项都
要证明旧 evidence key 被 invalidated 或重新执行，不能只报告最终状态。

### QPR-P2-03 — fail-closed fixture 的负例和 per-receipt freshness 覆盖还未成为可核验清单

**Severity:** P2 · **Disposition:** `fix` in P1 implementation receipt

Profile 的语义矩阵确实覆盖了 invalid、pending、none、comparator、current-proof 以及
first/subsequent、P-01/D-01 的边界（[`derived-state matrix`](../kos/release-evidence-profile.md#L250-L328)）。
但是 P1 Assignment 目前以“添加 fixture matrix”和“P-01/D-01 fixture/receipt conditions
pass”描述 exit，未明确要求每一条高风险负例都能单独追溯到 fixture ID（[`P1 exit`](../assignments/kos-release-evidence-implementation-001-p1.md#L214-L229)）。

为避免只测 pass path，implementation receipt 应明确列出并运行至少这些负例：无效 JSON/
schema/key/policy/带时区的 `as_of`、unbound target=`pending`、bound target 的 baseline/
history failure=`none`、all non-comparable=`comparator`、mixed claim=`none`、first 带
previous、subsequent 带 baseline、same-candidate/mismatched `release_lineage`；并分别对
observation、delivery、final-validation、provenance 测 future、超过 `max_age_days`、
`valid_until` 过期和 identity mismatch。P-01 要覆盖 missing/unknown/mismatched head、
non-pass hosted result；D-01 要覆盖 final-tree mismatch、unresolved checker/scope/
baseline/output、non-zero exit 和 non-pass result。当前没有执行这些 fixtures，receipt 也
明确记录了这一点，因此不把它误报为当前实现失败，但它必须成为 P1 exit evidence。

## P0 / P3 disposition

- **P0：0 findings。** 在本 scope package 中没有发现把凭 fixture/validator 结果直接提升为
  Product/Quality/Release authority 的 P0 级越界，也没有发现授权 Main-App 新 store、Extension
  同步 I/O、runtime network 或 raw user content 的 P0 级风险；这些边界反而被显式禁止
  （[`Authorization exclusions`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L33-L47)）。
- **P3：0 findings。** 当前优先级集中在 predecessor provenance 和实现前必须补齐的可执行
  fail-closed evidence，没有另列不影响结论的排版或措辞建议。

## Non-claims and unexecuted work

- 没有 standalone `kos.release-evidence` Envelope；没有运行 pinned schema/reference
  evaluator，也没有生成 `current-proof`、`pending`、`none` 或 `comparator` 的实际运行结果。
  这是 P1 receipt 明示的未执行边界（[`receipt non-claims`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L60-L69)、[`non-claims`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L85-L93)）。
- 没有执行 Swift format、KeyboardCore、RimeBridgeTests、Universe Keyboard tests、Debug/
  Release build、Simulator/真机、性能/内存/生命周期测量、CI hosted run、archive/export、
  App Store Connect、TestFlight、Beta Review、upload、commit、push、merge、tag 或 Release。
- `REP-Q-01`、final SHA/base-head、hosted provenance 和 P1-B Main-App Diagnostics UI/storage
  仍是明确的后续边界；P1-A 文档没有把日常 Beta 证据伪装成 Beta Review、外部交付或 Release
  acceptance（[`P1 stop/residuals`](../assignments/kos-release-evidence-implementation-001-p1.md#L231-L254)）。

## Final conclusion

对 exact digest `e2ab44303b84d62043bf545d6cfd61cd086e28a9becd18cf7a0ea9bafc8faee8`，P1-A 的
合同/授权设计可以进入“修复 predecessor receipt 后再开始实现”的状态；不能标为 P1
implementation complete 或 publication-ready。修复 `QPR-P1-01`，并在 P1 implementation
receipt 中满足 `QPR-P2-01` 至 `QPR-P2-03` 后，才适合进行下一轮独立 Architecture / Quality
exit review。
