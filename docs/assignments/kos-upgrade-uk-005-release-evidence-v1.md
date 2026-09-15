# Assignment: KOS-UPGRADE-UK-005 — 审查未发布 `kos.release-evidence` v1.0

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed |
| Current Phase | 冻结 packet 的 Architecture / Quality same-lane continuation review 已完成；Human Product Owner 已记录项目级 prospective adoption，并以 Option A 完成 P1-B residual disposition |
| Material non-claims | 不改变当前 `v0.8.0` pin、advisory/required 模式、现有 Active Assignment、Main App 行为或 Release Gate；本 Assignment 仍不代表实现、current-proof、publication 或 Release |
| Next handoff / decision | 本 review Assignment 无进一步执行动作；P1-A 的 `REP-Q-01` 与 hosted provenance 仍由实现 Assignment 继续承接，P1-B 仅在 Product 以后明确 supersede Option A 时重新建 Assignment |
| Residuals | `Q-UK005-01`–`Q-UK005-08` 已由 exact-digest re-review 通过；UK-005 review 无阻塞 residual。`REP-Q-01`、hosted provenance 与 P1-A/P1-B 的后续边界不属于本 review Assignment 的关闭条件 |

---

## Authority

- Assignment Authority: Human Product Owner acting as Product Lead
- Decision Source / Date: current Codex session, `2026-09-14 Asia/Shanghai`; Human Product Owner approved continuing with a project-level Upgrade Review
- Product Approver: Human Product Owner acting as Product Lead
- Related current adoption source: [`KOS Kit v0.8.0 Upgrade Status`](../kos/UPGRADE_STATUS.md)
- Related current P1-B disposition: [`PD-KOS-UPGRADE-UK-005-P1-B-SCOPE`](../product-decisions/KOS-UPGRADE-UK-005-P1-B-scope.md)

## Boundary

### Scope

1. Freeze the upstream `kos.release-evidence` v1.0 contract, standalone schema,
   reference evaluator, adopter profile and exact digests as an untagged Kit
   candidate; do not represent it as a new Kit Release.
2. Compare the generic contract's candidate identity/context, observation,
   provenance, delivery, final-validation and promotion boundaries with the
   current Universe Keyboard release-evidence design.
3. Decide whether Universe Keyboard should adopt the contract prospectively for
   new release-evidence records and handoffs, including the daily Beta → formal
   external-candidate reuse boundary.
4. Record project-specific owners, privacy limits, evidence grades, freshness,
   baseline/history requirements and migration exclusions needed before any
   future implementation or adoption decision.

### Non-goals

- 不把未发布 Kit commit 写入当前 `docs/kos/UPGRADE_STATUS.md` 或 `.kos/project.json`。
- 不自动采用 `kos.release-evidence`，不把当前 Proposed ADR 0035 改为 Accepted。
- 不迁移现有 Active Assignment、历史 Build 证据或当前 release-evidence 工作树。
- 不修改 Swift、Main App、Keyboard Extension、App Group 存储、CI、Release Checklist
  或现有 `RELEASE-EVIDENCE-PROMOTION-001` 实现。
- 不执行 archive/export、设备操作、App Store Connect、TestFlight、commit、push、merge、tag
  或 Release。
- 不把 KOS evaluator、主 App 证据页面或本 Assignment 的结论当作 Quality、Product、Gate
  或 Release 结论。

## Required Inputs

- 当前项目 KOS pin：`v0.8.0`，commit
  `2c9907565bf6b6fcd00e698cc539d9e2db573bc5`，模式为 `advisory`。
- 当前项目 Source of Truth：[`UPGRADE_STATUS`](../kos/UPGRADE_STATUS.md#L3)、
  [`.kos/project.json`](../../.kos/project.json#L1)、
  [`DOCUMENTATION_GOVERNANCE`](../DOCUMENTATION_GOVERNANCE.md#L12)、
  [`ASSIGNMENT_POLICY`](../ASSIGNMENT_POLICY.md#L137)、
  [`RELEASE_CHECKLIST`](../RELEASE_CHECKLIST.md#L1)、
  [`PRIVACY_POLICY`](../PRIVACY_POLICY.md#L55)、
  [`PERFORMANCE_BASELINE`](../PERFORMANCE_BASELINE.md#L32) 与现行 KOS 2.1/2.2 边界。
- KOS Kit `kos.release-evidence` 实现 commit：
  [`8e55551a`](https://github.com/shchnk1103/kos-agent-kit/commit/8e55551a3b56b57e7fc5ab5544d653f9c6854df9)。
- KOS Kit adoption metadata commit：
  [`f5c88d5`](https://github.com/shchnk1103/kos-agent-kit/commit/f5c88d57f599d7ef352322ea7664f637fb288d60)。
- KOS Kit contract source digest：
  `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673`；standalone
  schema digest：`4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce`；
  evaluator digest：`a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9`。
- KOS Kit implementation receipt：[`implementation evidence`](https://github.com/shchnk1103/kos-agent-kit/blob/8e55551a3b56b57e7fc5ab5544d653f9c6854df9/docs/evidence/KOS-RELEASE-EVIDENCE-PORTABILITY-002-implementation.md#L15)，其中保留 candidate manifest、digest 命令和本地测试结果；本 Upgrade Review 的重新计算 receipt 见 [`UK-005 preparation evidence`](../evidence/kos-upgrade-uk-005-release-evidence-v1-preparation-2026-09-14.md)。
- 当前 Universe release-evidence 实现切片的非权威 pre-freeze 输入：
  `RELEASE-EVIDENCE-PROMOTION-001`、Proposed ADR 0035、其 Architecture / Quality
  re-review 与 Main App 诊断记录。它们在 `2026-09-14 Asia/Shanghai` 的主工作树
  `3139f8d3bdb6be6622504ea731988f42681896fb` 上仍含未提交变更；`REP-Q-01` 的 final
  SHA/base-head provenance 必须先单独闭合，不能从工作树状态推导。
- KOS Kit source-of-truth contract、schema/evaluator/template 与其 own adoption
  decision；该 source map 不等于 Universe adoption。

### Candidate tree digest reproducibility

`candidate tree digest` 使用 SHA-256 对下列文件按列出顺序进行无分隔符的原始字节串联；
evidence receipt 本身不参与 digest。它不是 Git tree object，也不是只对某一个文件计算
的 digest：

```text
README.md
docs/adoption-guide.md
docs/assignments/KOS-RELEASE-EVIDENCE-PORTABILITY-001.md
docs/assignments/KOS-RELEASE-EVIDENCE-PORTABILITY-002.md
ops/release-evidence.md
schemas/release-evidence-v1.schema.json
scripts/validate_release_evidence.py
templates/docs/RELEASE_EVIDENCE_PROFILE.md
tests/fixtures/release_evidence_cases.json
tests/test_release_evidence.py
```

Reproduce from the KOS Kit root with:

```bash
cat README.md docs/adoption-guide.md \
  docs/assignments/KOS-RELEASE-EVIDENCE-PORTABILITY-001.md \
  docs/assignments/KOS-RELEASE-EVIDENCE-PORTABILITY-002.md \
  ops/release-evidence.md schemas/release-evidence-v1.schema.json \
  scripts/validate_release_evidence.py templates/docs/RELEASE_EVIDENCE_PROFILE.md \
  tests/fixtures/release_evidence_cases.json tests/test_release_evidence.py \
  | shasum -a 256
```

The independently recomputed result at `2026-09-14T17:07:29+0800` is
`fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9`. The source
manifest, root, command, observation time and limitations are recorded in the
executor evidence receipt; changing any listed file invalidates this snapshot.

## Assignment

- Domain Owner: Architecture & Knowledge Steward
- Executor: current Codex executor in isolated worktree
  `codex/kos-upgrade-uk-005-release-evidence`
- Environment Executor: Not Applicable — document-only Upgrade Review preparation；不访问设备、
  账户、凭证、App Store Connect 或发布环境
- Human Dependency: Human Product Owner — independent review disposition and the later
  `Adopted` / `Deferred` / `Not applicable` decision
- Architecture Reviewer: independent Architecture & Knowledge Steward, logical lane
  `KOS-UPGRADE-UK-005/architecture`; current round runtime `Archimedes`, agent
  `01a09f1b-3556-7d11-9d2d-f693dc111400`, read-only on `2026-09-14 Asia/Shanghai`;
  any re-review must record a fresh runtime or an explicitly justified same-lane continuation
- Quality Reviewer: independent Quality, Performance & Release Maintainer, logical lane
  `KOS-UPGRADE-UK-005/quality`; current round runtime `Pauli`, agent
  `01a09f1b-349f-77e0-9800-2ba17a7cabcc`, read-only on `2026-09-14 Asia/Shanghai`;
  any re-review must record a fresh runtime or an explicitly justified same-lane continuation

## KOS v0.8.0 optional-contract selection

This preparation Assignment intentionally does not opt into E-01, A-01/B-01, P-01 or
D-01. Those contracts remain available under the current project's `v0.8.0` advisory
policy, but this review must first decide whether the separate `kos.release-evidence`
contract is adopted. A future implementation or publication Assignment may opt in to
the applicable v0.8.0 contracts with its own owner mapping and receipts.

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | No new evidence claim is being asserted by this preparation packet |
| A-01 / B-01 authorization chain and briefing | Not applicable | This packet records scope and handoff; it does not authorize implementation or publication |
| P-01 publication facts | Not applicable | No commit/PR/hosted-CI publication handoff is in scope |
| D-01 final-documentation receipt | Not applicable | Preparation checks are ordinary executor checks, not a project adoption or publication receipt |

## Review Questions

- Does the generic contract add a portable evidence boundary without taking ownership
  of Universe-specific artifact fields, device facts, privacy rules or Product Gates?
- Can the current Main App release-evidence record map to the generic candidate,
  artifact/input, context, observation and provenance owners without duplicating a
  Source of Truth?
- Does daily Beta evidence remain reusable for a formal external candidate only as
  an exact, fresh, contract-compatible proof; otherwise as comparator/pending/none?
- Are first-external baseline and subsequent-external previous-receipt requirements
  compatible with the current `RELEASE-EVIDENCE-PROMOTION-001` boundary and `REP-Q-01`?
- Can adoption stay prospective, content-free and Main-App-owned without adding file
  I/O to the Keyboard Extension hot path or requiring runtime network access?
- What exact local Profile/owner mapping and future Assignment opt-in are needed, and
  which existing records must remain untouched?

## Freshness and derived-state boundary

The KOS contract supplies the executable semantics; this packet does not invent a new
project policy value. For a future adopting Profile, `policy.max_age_days` and the
`as_of` timestamp must be explicit project-owned fields. The current Universe design
proposes a 30-day window, but that value remains a review input until the release owner
records it in the adopting Profile/Assignment.

At evaluation time, the following rules are mandatory:

| Input condition | Derived state / permitted meaning | Prohibited inference |
|---|---|---|
| Observation timestamp is future, unparsable, older than `max_age_days`, or after `valid_until` | `stale`/blocked; no current proof | Freshness cannot be inferred from build number or upload time |
| Fresh `pass` with exact candidate, artifact/input, context, environment, coverage and comparison bindings, no comparable conflict, valid delivery and final validation | May support `current-proof` only when promotion prerequisites also pass | Not Product, Quality, Gate or Release acceptance |
| Observation exists but does not bind the current candidate/artifact/context | `comparator` | Historical Beta evidence is not current external proof |
| Target stage is declared but target binding, first-target baseline or subsequent-target history is missing | `pending` with all visible blockers | Pending is never a pass or upload authorization |
| Identity/context mismatch or unknown, stale/conflicting/non-pass evidence, delivery failure or final-validation failure | `none` or blocker | No silent promotion to current proof |

Promotion must declare `target_sequence=first` or `subsequent`. `first` requires
`previous_target_receipt=null` and a verified baseline bound to the current candidate;
`subsequent` requires a different previous target receipt with the same stage/context/profile/
contract binding and all policy-declared history identity keys resolved. Missing or unknown
fields remain fail-closed.

### Privacy-safe profile and runtime boundary

Any future adopter Profile must keep the release-evidence record content-free and
Main-App-owned. The portable allowlist is limited to opaque candidate/artifact/context
identifiers, build/version/digest metadata, claim and coverage identifiers, outcome,
`as_of`/validity fields, evidence references, comparison state, delivery/final-validation
status, checker/version/scope, exit code and bounded provenance heads. The Profile must
not persist or transmit raw keyboard text, candidate text, host text, credentials or
tokens, full diagnostic-log payloads, or unrelated user data. The Keyboard Extension
remains outside this storage boundary: no synchronous Extension file I/O and no runtime
network dependency are permitted. These are design constraints to be verified against
the linked project sources, not runtime or device evidence produced by this packet:
[`Privacy Policy`](../PRIVACY_POLICY.md#L55),
[`Performance Baseline`](../PERFORMANCE_BASELINE.md#L32) and
[`ADR 0027`](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md#L13).

## Publication-fact snapshot (not a P-01 receipt)

This preparation packet has no Universe publication handoff. The explicit values are:

| Fact | Value | Meaning |
|---|---|---|
| `local_candidate` | `UNKNOWN` | Current release-evidence worktree has no final SHA |
| `published_head` | `none` | No Universe branch/PR publication is part of this packet |
| `hosted_ci_head` | `unknown` | No hosted CI run covers this uncommitted packet |
| `hosted_ci_result` | `not-run` | No hosted CI result is claimed |
| `coverage` | `unknown` | Not enough heads exist for same-head coverage |
| `pr_state` | `none` | No PR is opened for UK-005 |

These values are an explicit non-claim snapshot, not a P-01 receipt and not permission
to commit, push, merge or Release.

## Gates

### Entry Criteria

- [x] Current project pin, advisory mode and current Upgrade Status are frozen.
- [x] Upstream implementation/adoption commits and contract/schema/evaluator digests are frozen.
- [x] The upstream candidate is explicitly classified as untagged and not a Kit Release.
- [x] Current release-evidence implementation is treated as an uncommitted, non-authoritative input;
      `REP-Q-01` is visible as an open dependency.
- [x] Review preparation runs in an isolated worktree and does not touch the ambient dirty main worktree.
- [x] Concrete independent Architecture and Quality reviewer runtimes are recorded for the first review round;
      re-review requires a new runtime record or a justified same-lane continuation.

### Exit Criteria

- [x] Frozen upstream source map and project applicability matrix are complete.
- [x] Every portable field has one owner; project-specific fields remain parameterized.
- [x] Daily Beta → external-candidate reuse, freshness, comparator and baseline/history semantics are
      mapped without granting a Release conclusion.
- [x] Privacy, App Group/Main-App ownership, Extension hot-path and no-network boundaries are explicitly
      verified against current project sources and linked evidence.
- [x] Independent Architecture and Quality conclusions are recorded against the exact review packet.
- [x] Human Product Owner records the project-level `Adopted` disposition and the separate P1-B
      `Not applicable` / `Deferred` boundaries; the current `v0.8.0` pin remains authoritative.

The exit checks are executable only when the following owner/evidence pair is present:

| Exit item | Owner | Required closure evidence |
|---|---|---|
| Source map, candidate digest and applicability matrix | Executor + Architecture | This Assignment, Upgrade Record and the packet preparation receipt at the frozen digest |
| Daily Beta → external reuse and baseline/history | Quality + release-evidence owner | Exact identity/freshness/comparison matrix plus the open `REP-Q-01` closure evidence; until then the result is not current proof |
| Privacy, Main-App ownership and Extension hot-path boundary | Architecture + Performance/Privacy owners | The allowlist above linked to current project sources; no runtime/network evidence is implied |
| Independent review | Architecture and Quality reviewers | Concrete reviewer runtime IDs, review date, exact packet digest and P0/P1/P2/P3 disposition |
| Project decision | Human Product Owner | A recorded `Adopted`, `Deferred` or `Not applicable` disposition; no validator or reviewer may supply it |

### Stop Conditions

- Required source, owner, candidate identity, final SHA or provenance is missing and would require guessing.
- Review would require changing production code, existing CI classification, App Group ownership or ADR 0035.
- An untagged Kit commit is treated as a released version, or a validator/result is treated as adoption.
- The generic contract would require raw keyboard text, candidate text, host text, credentials, full logs,
  runtime network access or synchronous Extension file I/O.
- A comparator, pending or unknown result is promoted to current-proof without exact identity/context,
  freshness, baseline/history and independent review.
- Reviewer independence or a required Product decision is absent.

## Remediation Matrix

The current remediation is limited to this document packet and its executor evidence receipt.
It does not authorize product/runtime changes or adoption:

| Finding | Disposition | Bounded remediation |
|---|---|---|
| `Q-UK005-01` | `closed` | Exact Architecture/Quality runtime IDs, date and continuation basis recorded; Architecture and Quality re-review passed |
| `Q-UK005-02` | `closed` | Candidate manifest, raw-byte concatenation algorithm, root, command, digest and evidence pointer recorded |
| `Q-UK005-03` | `closed` | `as_of`, `max_age_days`, `valid_until`, future/expired/conflict semantics and owner boundary recorded |
| `Q-UK005-04` | `closed` | Comparator/pending/none and first/subsequent baseline/history matrix recorded |
| `Q-UK005-05` | `closed` | Privacy/performance/diagnostic owners and content-free/hot-path/no-network boundaries recorded |
| `Q-UK005-06` | `closed` | Local/published/hosted head fields and their non-claim meanings recorded |
| `Q-UK005-07` | `closed` | Source links, stable anchors, owners and evidence pointers recorded |
| `Q-UK005-08` | `closed` | Exact tag/Release check method, unavailable-network boundary and revalidation trigger recorded |

## Handoff

- Handoff Target: review packet closed after independent Architecture reviewer → independent Quality reviewer → Human Product Owner disposition.
- Required Handoff Content: exact Kit pins/digests, current project baseline, source-of-truth owner map,
  applicability matrix, open `REP-Q-01`, privacy/hot-path boundary, migration exclusions, review findings,
  residuals and the exact Product disposition required.
- Revalidation Trigger: any new Kit tag/Release, change to the pinned upstream commit/digest, finalization
  or semantic change of `RELEASE-EVIDENCE-PROMOTION-001`, ADR 0035 status change, App Group/privacy owner
  change, external-action authorization, or a request to modify an existing Active Assignment.

## History

- `2026-09-14 Asia/Shanghai`: Human Product Owner approved continuing to the Universe Keyboard project-level
  Upgrade Review after KOS Kit side adoption of the optional `kos.release-evidence` contract. An isolated
  worktree was created from `main` at `3139f8d3bdb6be6622504ea731988f42681896fb`; no main-worktree files,
  commit, push, merge, tag or Release action was performed.
- `2026-09-14 Asia/Shanghai`: The review was bounded as a pre-adoption document packet because the upstream
  contract has no Kit tag/Release and the current Universe release-evidence slice has an open final-SHA /
  base-head provenance residual. Current `v0.8.0` adoption remains unchanged.
- `2026-09-14 Asia/Shanghai`: Independent Architecture reviewer `Archimedes`
  (`01a09f1b-3556-7d11-9d2d-f693dc111400`) returned `Pass`, P0/P1/P2/P3 = `0/0/0/0`,
  limited to packet architecture, Source of Truth, authority and migration boundaries.
- `2026-09-14 Asia/Shanghai`: Independent Quality reviewer `Pauli`
  (`01a09f1b-349f-77e0-9800-2ba17a7cabcc`) returned `Hold`, P0/P1/P2/P3 = `0/6/2/0`.
  The Human Product Owner authorized this bounded documentation remediation; the packet remains
  `Assignment Pending` and no reviewer conclusion grants adoption or Release authority.
- `2026-09-14T17:11:49+0800`: The bounded packet remediation was completed in the isolated
  worktree. The manifest/algorithm, freshness and derived-state rules, privacy-safe allowlist,
  publication-fact fields, executable owner/evidence exit checks and tag/Release revalidation
  method are now recorded; the packet remains `Assignment Pending` until both independent
  reviewer lanes re-review this exact packet digest.
- `2026-09-14 Asia/Shanghai`: Architecture same-lane continuation re-review and Quality
  same-lane continuation re-review both bound exact packet digest
  `18eb208bec1bd4ee29968bc9bf1989000ceea51c50848a5f74da47ee2eeb9d3a`. Architecture
  returned Pass with P0/P1/P2/P3 `0/0/0/0`; Quality returned Pass with P0/P1/P2/P3
  `0/0/0/1`, with the sole P3 non-blocking receipt wording issue recorded in the review.
- `2026-09-15 Asia/Shanghai`: Human Product Owner adopted the project-level contract
  prospectively and selected Option A for P1-B. The decision records duplicate Main-App
  UI/storage as `Not applicable`, historical migration/backfill as `Deferred`, and
  background sync/network as `Deferred` and unauthorized. This review Assignment is now
  `Closed`; no implementation, commit, push, merge or publication action is implied.
