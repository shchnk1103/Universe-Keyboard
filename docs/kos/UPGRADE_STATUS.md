# KOS Kit Upgrade Status

> 此文件是本项目采用 KOS Agent Kit 的升级状态唯一事实来源。

| Field | Value |
|---|---|
| Upstream repository | `shchnk1103/kos-agent-kit` |
| Adopted version | `v0.5.0` |
| Latest checked version | `v0.5.0` |
| Last checked at | `2026-08-27T19:50:00+08:00` |
| Upgrade owner | Human Product Owner |
| Current disposition | Adopted — advisory only |
| Next review | Before enabling `required`; when fixing [`TD-014`](../TECH_DEBT.md#td-014-kos-22-auth-consumption_state-卫生); or when a newer Kit Release appears |
| Latest decision record | [`KOS-UPGRADE-UK-001-v0.5.0`](upgrade-records/KOS-UPGRADE-UK-001-v0.5.0.md) |

---

- 钉住 GitHub Release [`v0.5.0`](https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.5.0)（commit `e11cbfb`）。
- Envelope 模式为 `advisory`。校验绿不等于 Product / Quality / merge / Release 通过。
- 未启用 `required`。未自动给历史 Assignment 补 Envelope。
- 未采用独立 H-01 运行模板；真机证据继续使用既有 [`universe-keyboard-human-operated-evidence-profile.md`](universe-keyboard-human-operated-evidence-profile.md)，记为等价既有合同。
- 发现更新时人工核对上游 latest Release，并写新的 upgrade-record。不得把未检查写成“已是最新”。
