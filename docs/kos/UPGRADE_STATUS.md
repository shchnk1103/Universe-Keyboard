# KOS Kit Upgrade Status

> 此文件是本项目采用 KOS Agent Kit 的升级状态唯一事实来源。

| Field | Value |
|---|---|
| Upstream repository | `shchnk1103/kos-agent-kit` |
| Adopted version | `v0.8.0` |
| Latest checked version | `v0.8.0` |
| Last checked at | `2026-09-10T00:19:00+08:00` |
| Upgrade owner | Human Product Owner |
| Current disposition | Adopted — `v0.8.0` advisory; E-01, A-01/B-01, P-01 and D-01 are opt-in for new records only |
| Next review | When enabling `required`; when changing the adopted optional-contract scope; when fixing [`TD-014`](../TECH_DEBT.md#td-014-kos-22-auth-consumption_state-卫生); or when a newer Kit Release appears |
| Latest decision record | [PD-KOS-UPGRADE-UK-004](../product-decisions/KOS-UPGRADE-UK-004-adoption.md) |

---

## v0.7.0 adoption (historical)

> **Superseded for current pin:** see [PD-KOS-UPGRADE-UK-004](../product-decisions/KOS-UPGRADE-UK-004-adoption.md) and the v0.8.0 section below. Text below is the historical v0.7.0 record.

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

## v0.8.0 adoption

[KOS-UPGRADE-UK-004](../assignments/kos-upgrade-uk-004-v0.8.0.md) records the
Human Product Owner's `2026-09-10 Asia/Shanghai` adoption decision. The project
pins `v0.8.0` in advisory mode. E-01, A-01/B-01, P-01 and D-01 are available
only when a newly created Assignment or handoff explicitly opts in; existing
Active Assignments remain pinned and are not migrated. H-02/W-01 and `required`
remain outside this adoption. Default-branch publication landed as PR
[#104](https://github.com/shchnk1103/Universe-Keyboard/pull/104) merged `77e5658`.
