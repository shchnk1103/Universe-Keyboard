# KOS Kit Upgrade Status

> 此文件是本项目采用 KOS Agent Kit 的升级状态唯一事实来源。

| Field | Value |
|---|---|
| Upstream repository | `shchnk1103/kos-agent-kit` |
| Adopted version | `v0.5.0` |
| Latest checked version | `v0.6.0` |
| Last checked at | `2026-09-02T18:53:00+08:00` |
| Upgrade owner | Human Product Owner |
| Current disposition | Adopted — advisory only (`v0.5.0`); `v0.6.0` Deferred |
| Next review | `v0.6.0` re-review when a workflow will use multi-agent or multi-provider orchestration; or when enabling `required` / fixing [`TD-014`](../TECH_DEBT.md#td-014-kos-22-auth-consumption_state-卫生) / a newer Kit Release appears |
| Latest decision record | [`KOS-UPGRADE-UK-001-v0.5.0`](upgrade-records/KOS-UPGRADE-UK-001-v0.5.0.md) · [`KOS-UPGRADE-UK-002-v0.6.0`](upgrade-records/KOS-UPGRADE-UK-002-v0.6.0.md) |

---

- 钉住 GitHub Release [`v0.5.0`](https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.5.0)（commit `e11cbfb`）。
- Envelope 模式为 `advisory`。校验绿不等于 Product / Quality / merge / Release 通过。
- 未启用 `required`。未自动给历史 Assignment 补 Envelope。
- 渐进纳管规则：新建且明确加入 Profile 的 formal workflow 使用 Envelope；既有记录在实质修改、明确 onboarding 或未来另行授权的 required-mode Migration 时再迁移。不得猜测历史 authority、claim、environment、artifact、freshness 或 Gate 结论。
- 未采用独立 H-01 运行模板；真机证据继续使用既有 [`universe-keyboard-human-operated-evidence-profile.md`](universe-keyboard-human-operated-evidence-profile.md)，记为等价既有合同。
- 发现更新时人工核对上游 latest Release，并写新的 upgrade-record。不得把未检查写成“已是最新”。
- `v0.6.0`（可选 AI 编排合同）：`Deferred`，见 [`KOS-UPGRADE-UK-002-v0.6.0`](upgrade-records/KOS-UPGRADE-UK-002-v0.6.0.md)。理由：当前无 workflow 需要多 agent / 多 provider 编排。既有 Active Assignment 保持 pinned、不迁移。`v0.6.0` 不改冻结 `core/`、不加 schema 强制，不改变本项目的 advisory 义务。重叠 writer 不再阻塞把本条 Deferred 记录合入 `main`。
