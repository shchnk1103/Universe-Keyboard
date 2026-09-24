# KOS Kit Upgrade Status

> 此文件是本项目采用 KOS Agent Kit 的升级状态唯一事实来源。

| Field | Value |
|---|---|
| Upstream repository | shchnk1103/kos-agent-kit |
| Adopted version | v0.9.0 |
| Latest checked version | v0.9.0 |
| Last checked at | 2026-09-25 Asia/Shanghai; exact query time is not recorded in the independent Quality Round 3 receipt |
| Upgrade owner | Human Product Owner |
| Current disposition | Adopted — v0.9.0 advisory; the selected M-02 update applies to triggers from the effective date and reviewer scope/budget/stop clauses apply to newly assigned independent lanes; v0.8-origin optional contracts remain opt-in for new records; UK-005 release-evidence stays unchanged; no required mode, migration or backfill |
| Next review | When the adopted scope or Kit pin changes; before enabling required mode or migrating records; when a newer Kit Release appears; or when changing the UK-005 contract/Profile |
| Latest decision record | [PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md) |
| Latest project contract-scope decision | [PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md) — M-02 and newly assigned independent reviewer lanes |
| Preserved project optional contract | [PD-KOS-UPGRADE-UK-005 release-evidence adoption](../product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md) |
| Latest residual-scope decision | [PD-KOS-UPGRADE-UK-005-P1-B-SCOPE](../product-decisions/KOS-UPGRADE-UK-005-P1-B-scope.md) — Option A: duplicate UI/storage Not applicable; migration/backfill and background sync Deferred/unauthorized |

---

## v0.7.0 adoption (historical)

> **Superseded for current pin:** see [PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md) and the v0.9.0 section below. Text below is the historical v0.7.0 record.

[KOS-ASTRA-UPGRADE-001](../assignments/kos-astra-upgrade-001.md) records the historical v0.7.0 adoption.
The profile then pinned released `v0.7.0` at `f7f4dad6750b59dc827c1366fcd276447b2820b2`.
Default-branch publication landed as PR [#99](https://github.com/shchnk1103/Universe-Keyboard/pull/99) merged `4c9f424`.
Existing Active Assignments remained pinned. The optional orchestration plan stayed uninstantiated.

- Release: [v0.7.0](https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.7.0).
- Adopt optional `ops/agent-execution.md` for new tasks; existing Active task contracts do not migrate.
- Envelope 模式为 `advisory`。校验绿不等于 Product / Quality / merge / Release 通过。
- 未启用 `required`。未自动给历史 Assignment 补 Envelope。
- 渐进纳管规则：新建且明确加入 Profile 的 formal workflow 使用 Envelope；既有记录在实质修改、明确 onboarding 或未来另行授权的 required-mode Migration 时再迁移。不得猜测历史 authority、claim、environment、artifact、freshness 或 Gate 结论。
- 未采用独立 H-01 运行模板；真机证据继续使用既有 [`universe-keyboard-human-operated-evidence-profile.md`](universe-keyboard-human-operated-evidence-profile.md)，记为等价既有合同。
- 发现更新时人工核对上游 latest Release，并写新的 upgrade-record。不得把未检查写成“已是最新”。
- 可选编排合同（`ops/agent-orchestration.md`）随 `v0.6.0` **可用**，仅供后续明确需要多 agent / 多 provider 的新 Assignment。既有 Active Assignment 保持 pinned、不迁移。本仓库 **未** 实例化 `ORCHESTRATION_PLAN.md`。
- 历史：[`KOS-UPGRADE-UK-001-v0.5.0`](upgrade-records/KOS-UPGRADE-UK-001-v0.5.0.md) 首次 advisory 采用；[`KOS-UPGRADE-UK-002-v0.6.0`](upgrade-records/KOS-UPGRADE-UK-002-v0.6.0.md) 为 Deferred 检查记录，Adopted pin 已被 UK-003 取代（S-03）。

Historical v0.7.0 adoption record: [KOS-ASTRA-UPGRADE-001](upgrade-records/KOS-ASTRA-UPGRADE-001-v0.7.0.md).

## v0.8.0 adoption (historical)

> Historical adoption record. The current pin and expanded prospective scope are defined by [PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md) below.

[KOS-UPGRADE-UK-004](../assignments/kos-upgrade-uk-004-v0.8.0.md) records the
Human Product Owner's `2026-09-10 Asia/Shanghai` adoption decision. The project
pins `v0.8.0` in advisory mode. E-01, A-01/B-01, P-01 and D-01 are available
only when a newly created Assignment or handoff explicitly opts in; existing
Active Assignments remain pinned and are not migrated. H-02/W-01 and `required`
remain outside this adoption. Default-branch publication landed as PR
[#104](https://github.com/shchnk1103/Universe-Keyboard/pull/104) merged `77e5658`.

## v0.9.0 prospective adoption

[PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md)
records the Human Product Owner's prospective adoption on 2026-09-25
Asia/Shanghai. The project pins released v0.9.0 at commit
c98b2813240e22b2ac7fec44b2445321b03f73e0 in advisory mode. The exact latest
Release query and immutable tag/commit identity are recorded in the [Quality
Round 3 receipt](../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r3-review.md).

- M-02 uses a stable Work Item + exact event + authority-record identity; merge
  triggers also bind the merged tip PR and commit. One closeout transaction
  completes that trigger and never recursively starts M-02 for itself. This
  applies to triggers from the effective date onward; historical closeouts are
  not reopened.
- The reviewer scope/budget/stop clauses apply to independent reviewer lanes
  first assigned from the effective date onward. Existing Active Assignments
  and already assigned lanes are not migrated. See
  [ASSIGNMENT_POLICY](../ASSIGNMENT_POLICY.md) and
  [AI_WORKFLOW](../AI_WORKFLOW.md).
- This is selective adoption of reviewer packet boundaries, not adoption of
  the full optional agent-orchestration package. No global ORCHESTRATION_PLAN
  is instantiated or required.
- E-01, A-01/B-01, P-01 and D-01 remain explicit opt-ins for new records under
  the existing project mapping.
- The existing UK-005 kos.release-evidence v1.0 decision, exact contract
  bytes, schema/evaluator, Profile and implementation remain unchanged; the
  v0.9.0 release carries byte-identical source files.
- record_envelopes.mode remains advisory; supported schema remains v1.0.
  No required cutover, historical migration or backfill is authorized.
- Simulator/CoreDevice discovery and Device Hub/Accessibility health
  classification are outside v0.9.0 and remain separate project work.

The UK-006 upgrade review is recorded in the [Round 2 applicability
assessment](KOS-UPGRADE-UK-006-v0.9.0-round-2.md), with its exact sources in
the [Round 2 source map](../evidence/kos-upgrade-uk-006-v0.9.0-round-2-source-freeze-2026-09-25.md).
Local application is tracked by
[KOS-UPGRADE-UK-006-ADOPTION](../assignments/kos-upgrade-uk-006-v0.9.0-adoption.md).

## Project optional contract: `kos.release-evidence` v1.0

The Human Product Owner's `2026-09-14 Asia/Shanghai` decision in
[`PD-KOS-UPGRADE-UK-005`](../product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md)
adopts the exact untagged candidate recorded by the UK-005 review packet. This does
not change the adopted Kit version or claim that the candidate is a new Kit Release.
Later, UK-006 adopted the upstream v0.9.0 Kit pin prospectively; that pin does not change the UK-005 contract/Profile scope or make this a second contract adoption.

- Scope is prospective: new release-evidence records and handoffs only; no historical
  backfill or Active-Assignment migration.
- The parent implementation handoff is
  [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001`](../assignments/kos-release-evidence-implementation-001.md);
  its P0 contract/Profile handoff is complete.
- The separately authorized child implementation scope is
  [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](../assignments/kos-release-evidence-implementation-001-p1.md)
  with [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md).
- Its accepted scope decision is [`PD-KOS-UPGRADE-UK-005-P1-A-SCOPE`](../product-decisions/KOS-UPGRADE-UK-005-P1-A-scope.md);
  the Product Decision is the repository-resolvable authority reference for P1-A.
- Its current adopter Profile is [`release-evidence-profile.md`](release-evidence-profile.md),
  which remains a project adapter rather than a copied Kit schema or a second
  evidence authority. Its Project pin row is preserved as the UK-005 adoption-
  time snapshot; the current project pin is recorded in the status header above.
- E-01, P-01 and D-01 are explicitly adopted in the parent/child Assignments for this
  contract; A-01/B-01 is outside the current P1-A slice and `required` remains unauthorized.
- Daily Beta evidence remains current proof only after exact identity, freshness,
  coverage and comparison checks. Otherwise it remains comparator/pending/none.
- The P1-A scope adds delta-aware validation: rerun the evidence touched by a change and
  reuse only unchanged, identity-bound, still-fresh daily-Beta evidence. Daily-Beta
  evidence can feed an external-candidate record, but external delivery, Beta Review,
  hosted provenance and Product/Release decisions remain separate.
- The P1-A adapter, fixed evaluator matrix and delta planner are implemented in the
  isolated execution branch; the current `fix10` implementation receipt reports
  52/52 Envelope and 24/24 Delta cases passing (76/76 total), including fail-closed
  source/wrapper, identity, claim/coverage, authority-path and P-01/D-01 boundary cases.
  The exact package digest is
  `45afdbf879c6b0054790342861254abbc6d9cde846f61b43a160bd22064d0382`; fresh
  independent Architecture and Quality/Release reviews both Passed that digest. The
  [P1-A provenance receipt](../evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md)
  now binds the Main-App source-owner identity and the same-head hosted CI run for the
  UK-005 candidate; it closes `REP-Q-01` and candidate-bound hosted provenance only.
  It does not produce current-proof, P-01/D-01, Product/Release or publication
  readiness.
- The P1-B residual disposition is [`PD-KOS-UPGRADE-UK-005-P1-B-SCOPE`](../product-decisions/KOS-UPGRADE-UK-005-P1-B-scope.md): duplicate Main-App
  Diagnostics UI/storage is `Not applicable` for the current objective because the
  existing release-evidence implementation already owns that boundary. Historical
  migration/backfill is `Deferred`; background sync/network is `Deferred` and
  unauthorized. No new P1-B implementation Assignment exists unless Product later
  supersedes this decision with a precise residual scope.
- `REP-Q-01` and candidate-bound hosted CI provenance are closed by the [P1-A provenance
  receipt](../evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md).
  Upstream tag/Release metadata, P-01/D-01 facts and any publication readiness remain
  separately owned and unclaimed; adoption itself is not a Product, Quality, Gate or
  Release approval.
