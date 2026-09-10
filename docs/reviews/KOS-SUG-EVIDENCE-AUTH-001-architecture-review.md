# Architecture Review: KOS-SUG-EVIDENCE-AUTH-001

## Review identity and boundary

| Field | Value |
|---|---|
| Reviewer | `/root/kos_suggestions_arch_review` — independent Architecture reviewer |
| Review date / timezone | `2026-09-10 Asia/Shanghai` |
| Review mode | Read-only document-architecture review; only this reviewer file may be written |
| Review baseline | Worktree `codex/kos-v080-upgrade-review`, `HEAD` `0757f47c934bba420b5cc47033b563e40c0cb8e9` |
| Independence basis | This runtime did not edit the scoped governance documents or implement SUG-01/SUG-02; it only inspected the final tree and writes this independent review |

This review is limited to the final docs-only slice for `KOS-SUG-EVIDENCE-AUTH-001`:

- the E-01 claim/outcome convention in
  [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md);
- the optional v0.8.0 contract selection and A-01/B-01 frontier template in
  [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md);
- the bound Assignment, Authorization, Product Decision and `ACTIVE_WORK` mirror;
- compatibility with the adopted v0.8.0 advisory/new-record opt-in boundary.

The review does not decide any Product disposition, change KOS 2.0/2.1, evaluate
SUG-03 through SUG-09, enable `required`, migrate a historical record or Active
Assignment, or authorize CI, code, privacy, diagnostics, device, publication or
external work.

## Frozen review inputs

| Input | SHA-256 |
|---|---|
| [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) | `d7cbe1f730a7f0da98a1f6f765b1d8b260289eda49fc080f87010539778b7dac` |
| [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) | `50527220e0e9c96dadff1162f57730827c2d712e12de79a76f45a103a326ebe1` |
| [`KOS-SUG-EVIDENCE-AUTH-001` Assignment](../assignments/kos-sug-evidence-auth-001.md) | `2154360db5ca20368bf2bae10ad6ca65c5fdfd4d787cecfb463619d50bac2f0a` |
| [`AUTH-KOS-SUG-EVIDENCE-AUTH-001`](../authorizations/AUTH-KOS-SUG-EVIDENCE-AUTH-001.md) | `631364f82dcaa01c40798d81442636d79d3f9e3b961335e1161e0d158a3557ed` |
| [`KOS-SUG-EVIDENCE-AUTH-001` Product Decision](../product-decisions/KOS-SUG-EVIDENCE-AUTH-001-authorization.md) | `de7891a72476459d160f85db1307ec70ace551106c860ad1dbd56a3868947ff3` |
| [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) | `adf01fd1956841ae543e5e29fca5930e4994b04dffee631e60c161d48dbef1b4` |
| [`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md) | `6666e9be6dbd7e0208dc3b0d5f776f9f04f2660e7793e122ab6bf8d189d8f634` |
| [`.kos/project.json`](../../.kos/project.json) | `890e590eb4963a9f028581135eab3b3f01484f05bb8bd614a3c944318ff3615f` |
| v0.8.0 project-fit source map | `c41bf46bfcba5eb2c28005c2c75207ddaa902c0d663b179a334f02e6724c6358` |

The baseline was checked with `git diff --check`, which passed. No code, CI,
device, upstream or external operation was run.

## Compatibility and boundary result

The E-01 section is correctly scoped to an explicitly opted-in new evidence
record. It requires one `pass`/`fail`/`inconclusive`/`not-run` outcome per claim
in addition to exactly one M-04 evidence grade, explains that outcome describes
what was established while grade describes who established it, and handles
conflict/supersession without replacing the Assignment authority
([`DOCUMENTATION_GOVERNANCE.md:134-155`](../DOCUMENTATION_GOVERNANCE.md#L134)).
It explicitly forbids historical backfill and says the block cannot authorize a
device run, raw-data access, Product decision, publication or closure.

The current Assignment selects only E-01 and A-01/B-01, marks P-01 and D-01
`Not applicable`, and states that the slice is documentation/local-static only
([`Assignment:24-43`](../assignments/kos-sug-evidence-auth-001.md#L24)). Its
scope and non-goals exclude SUG-03 through SUG-09, KOS 2.0/2.1 changes,
`required`, historical or Active-Assignment migration, CI, privacy, diagnostics,
device, code and publication ([`Assignment:45-69`](../assignments/kos-sug-evidence-auth-001.md#L45)).
The Authorization binds only the two named policy files and carries matching
exclusions ([`Authorization:23-37`](../authorizations/AUTH-KOS-SUG-EVIDENCE-AUTH-001.md#L23)).
The Product Decision is a bounded, advisory, new-record opt-in implementation
and preserves the same non-claims ([`Product Decision:7-23`](../product-decisions/KOS-SUG-EVIDENCE-AUTH-001-authorization.md#L7)).
The `ACTIVE_WORK` row reflects this Assignment as Active and pending the two
independent reviews ([`ACTIVE_WORK.md:38-41`](../ACTIVE_WORK.md#L38)).

These boundaries agree with the project’s v0.8.0 advisory pin and explicit
new-record opt-in rule ([`UPGRADE_STATUS.md:7-13`](../kos/UPGRADE_STATUS.md#L7));
they do not change the project Profile or make any contract `required`.

## Findings

| ID | Severity | Finding and exact boundary | Required residual / disposition |
|---|---|---|---|
| `A-SUG-EA-P1-01` | P1 | The active Assignment does not bind named Architecture and Quality reviewers: [`Assignment:85-86`](../assignments/kos-sug-evidence-auth-001.md#L85) says only “To be bound before Close”. The Policy requires named reviewer fields and says a missing required field blocks `Ready`/`Active` ([`ASSIGNMENT_POLICY.md:137-161`](../ASSIGNMENT_POLICY.md#L137), [`:338-346`](../ASSIGNMENT_POLICY.md#L338)); independent reviewer identity is also a stop condition ([`:376-385`](../ASSIGNMENT_POLICY.md#L376)). A conversation-level delegation and this review’s identity cannot replace the Assignment record’s binding. | **HOLD.** Product Lead/Assignment owner must bind both actual independent runtime identities in the Assignment, confirm neither participated in implementation, then re-run/append both reviews against the resulting final baseline before Close. Do not fill the fields from inference or mark them `Not Applicable`. |
| `A-SUG-EA-P2-01` | P2 | The generic A-01/B-01 frontier table says it “records authority; it never creates it” and shows an `Authorized` current slice, but does not state the fail-closed condition that an unresolved or mismatched Assignment → Authorization → accepted Product Decision chain must remain `UNKNOWN`/not authorized. The adopted project-fit map requires a current matching Decision and Authorization before a slice may be called authorized and prohibits inference from a Current Status, briefing, chat or validator ([`v0.8.0 source map:37,49-50`](../kos/upgrade-records/KOS-UPGRADE-UK-004-v0.8.0.md#L37)). The current concrete Assignment has the correct matching chain, so this is a reusable-template ambiguity rather than a current authorization grant ([`Assignment:33-43`](../assignments/kos-sug-evidence-auth-001.md#L33)). | **`fix` residual.** Add an explicit template rule that unresolved, stale or scope-mismatched authority is `UNKNOWN`/`Not authorized`, and that `Authorized` requires exact action/target/scope/exclusion matching. Keep the current slice bounded; do not add a new lifecycle state or grant authority. |

No P0 or P3 findings were identified. No finding alleges implementation of
SUG-03 through SUG-09, `required`, CI, code, privacy, diagnostics, device or
publication work; the issue is limited to Assignment completeness and
fail-closed template semantics.

## Verdict and counts

**Architecture verdict: HOLD.** The E-01 outcome/grade separation, opt-in and
no-backfill rules, current authority chain, and SUG-01/SUG-02 scope are
architecturally compatible. Close is blocked by `A-SUG-EA-P1-01`; the
reusable-frontier clarification `A-SUG-EA-P2-01` must also be dispositioned
before treating the template as complete.

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 1 |
| P2 | 1 |
| P3 | 0 |

This review does not choose or alter any Product Decision, contract selection,
Assignment lifecycle, Authorization, Active Work status, KOS rule or external
state. It is an independent Architecture conclusion only; Quality must issue
its own review and conclusion.

---

## Final template delta re-review

**复核日期 / 时区：** `2026-09-10 Asia/Shanghai`

Parent 修复后的最终增量只涉及 A-01/B-01 frontier 的状态词表和 fail-closed
说明。当前 `ASSIGNMENT_POLICY.md:255-269` 规定每个已填 `Status` 必须是单一
受控值，并明确 `UNKNOWN` 必须在进入 `Ready` 或 `Active` 前解决或停下返回
命名 authority；这直接关闭 `A-SUG-EA-P2-01`。它没有增加生命周期状态，也没有
把 frontier 变成授权源。当前 concrete Assignment 的匹配链仍由其
`:33-43` 和 v0.8.0 owner map `docs/kos/upgrade-records/KOS-UPGRADE-UK-004-v0.8.0.md:37,49-50`
约束。

| Finding | Final delta result |
|---|---|
| `A-SUG-EA-P2-01` | **Resolved — `fix` closed.** Controlled status vocabulary and explicit `UNKNOWN` fail-closed behavior now prevent an unresolved frontier from being represented as an authorized slice. Exact chain matching remains required by the adopted project-fit source map and the concrete Assignment authority chain. |
| `A-SUG-EA-P1-01` | **Open.** `docs/assignments/kos-sug-evidence-auth-001.md:85-86` still says Architecture and Quality reviewers are “To be bound before Close”, while the Assignment remains `Active` and `ACTIVE_WORK.md:38` awaits both reviews. This required Assignment binding is unchanged. |

No new Architecture finding was introduced. The E-01 outcome/grade separation,
new-record opt-in, no-backfill boundary, SUG-01/SUG-02-only scope and all
exclusions remain unchanged. This delta does not close the task or substitute
for Quality's independent conclusion.

**Final Architecture verdict: HOLD.** The template P2 is closed, but the
unresolved reviewer binding remains a P1 stop condition. Current final counts:
**P0/P1/P2/P3 = 0/1/0/0**. Bind both actual independent reviewer runtimes in
the Assignment and then re-review the resulting final tree before Close.

---

## Final reviewer-binding delta re-review

**复核日期 / 时区：** `2026-09-10 Asia/Shanghai`

本次只复核 `A-SUG-EA-P1-01` 的修复及最终边界。Assignment 现在已具名绑定
`/root/kos_suggestions_arch_review` 和 `/root/kos_suggestions_quality_fast` 两个
不同的独立逻辑 lane（[`Assignment:79-87`](../assignments/kos-sug-evidence-auth-001.md#L79)），
并在 Entry Criteria 勾选 reviewer binding（[`Assignment:91-96`](../assignments/kos-sug-evidence-auth-001.md#L91)）。
Current Status 已说明处于最终独立审查收口阶段（[`Assignment:5-13`](../assignments/kos-sug-evidence-auth-001.md#L5)），
History 也记录了两条 reviewer 在最终审查收口前完成绑定（[`Assignment:117-120`](../assignments/kos-sug-evidence-auth-001.md#L117)）。
这满足 Policy 对具名责任、独立性和 Active 前完整性的要求；`A-SUG-EA-P1-01`
已关闭。

最终范围仍未扩大：Assignment 的 Non-goals 继续排除 SUG-03–SUG-09、KOS
2.0/2.1、`required`、历史/Active-Assignment 迁移、CI、隐私、诊断、设备、代码和
发布（[`Assignment:61-69`](../assignments/kos-sug-evidence-auth-001.md#L61)）；
Authorization 与 Product Decision 仍只绑定两个政策文档的 E-01/A-01/B-01
可选切片。`ACTIVE_WORK.md:38` 仍只把该 Assignment 镜像为 Active 并链接其
权威记录，没有制造新的授权。Quality review 已由具名的
`/root/kos_suggestions_quality_fast` 独立记录最终词表修复后的 `Pass`，计数为
`0/0/0/0`（[`Quality review:81-97`](KOS-SUG-EVIDENCE-AUTH-001-quality-review.md#L81)）。

| Finding | Final disposition |
|---|---|
| `A-SUG-EA-P1-01` | **Resolved — `fix` closed.** Both reviewer runtimes are named, independent, and mirrored in the Assignment's Entry/History. |
| `A-SUG-EA-P2-01` | **Resolved — `fix` closed.** The controlled frontier vocabulary and `UNKNOWN` fail-closed rule remain present at `ASSIGNMENT_POLICY.md:255-269`. |

No new Architecture finding or residual was introduced. The review remains
independent of Quality and does not mark the Assignment closed or authorize any
later implementation.

**Final Architecture verdict: Pass.** Final counts: **P0/P1/P2/P3 = 0/0/0/0**.
The remaining procedural action is the owning Product/Assignment lane's normal
close and handoff after its ordinary docs-only validation; this review does not
create that closure or a D-01/publication claim.
