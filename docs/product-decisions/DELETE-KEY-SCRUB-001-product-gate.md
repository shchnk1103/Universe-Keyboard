# Product Decision: DELETE-KEY-SCRUB-001 — Human Product Gate

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-DELETE-KEY-SCRUB-001-PRODUCT-GATE",
  "record_type": "decision",
  "title": "Accept the delete-key scrub, bubble, and sound follow-up",
  "status": "accepted",
  "updated_at": "2026-10-07T13:21:42+08:00",
  "revalidation_triggers": ["scope_changed", "delete_key_contract_changed"],
  "parent_refs": ["DELETE-KEY-SCRUB-001", "PD-DELETE-KEY-SCRUB-001-PRODUCT-CONTRACT"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "In-session 2026-10-07 Asia/Shanghai: 按这个写 Product Gate，先不要 Close。",
    "scope": "Human Product Gate for the delete-key behavior on origin/main cee4f914be03d45c6d8deae8af5427ff1587d5c1. Accept the sound table, bubble glass, and residuals DKS-CLOSE-01 and DKS-CLOSE-02. Do not Close the Assignment.",
    "outcome": "Passed with accepted conditions. Lifecycle may become Reviewed. Close, TestFlight, and Release remain unauthorized.",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-DELETE-KEY-SCRUB-001-PRODUCT-GATE`
- **Lifecycle status:** `Accepted`
- **Date / timezone:** `2026-10-07 Asia/Shanghai`
- **Assignment:** [`DELETE-KEY-SCRUB-001`](../assignments/delete-key-scrub-001.md) — **Reviewed**，未 Close
- **Authorization:** [`AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE.md)
- **Contract source:** [`PD-DELETE-KEY-SCRUB-001-PRODUCT-CONTRACT`](DELETE-KEY-SCRUB-001-product-contract.md)
- **Architecture:** [`delete-key-scrub-001-architecture-close.md`](../reviews/delete-key-scrub-001-architecture-close.md) — Pass with conditions
- **Quality:** [`delete-key-scrub-001-quality-review.md`](../reviews/delete-key-scrub-001-quality-review.md) — Pass with conditions；[`delete-key-scrub-001-followup-quality-review.md`](../reviews/delete-key-scrub-001-followup-quality-review.md) — Pass，只覆盖 `1560488..f94a8a7`

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Phase | Human Product Gate **Passed with accepted conditions**。Assignment `Reviewed`，未 `Closed` |
| Evidence | `origin/main` `cee4f914be03d45c6d8deae8af5427ff1587d5c1`，树与 PR [#203](https://github.com/shchnk1103/Universe-Keyboard/pull/203) head `7c804a08b1e7161b69dbef07a7abfc7aa1534a3e` 相同。merge 前 hosted run [37574313596](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/37574313596) 全绿 |
| Non-claims | 不是 Close、TestFlight、Release 或 CHANGELOG。不是微信 / Safari / 密码框已测。不是 Quality 车道的真机日志。`main` run [37575560853](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/37575560853) 在决定之后全绿，不是本 Gate 的输入 |
| Next | 文档 commit `45c84a773c0c8c6da6679e12667aa52ae1f367ff`。不授权 push。Close 另授权 |

## Decision

Human Product Owner 接受 `cee4f914be03d45c6d8deae8af5427ff1587d5c1` 上的删除键行为。冻结合同仍只写「按下要有按键音」。下列发声、玻璃和模糊以本页为补充，不回头改合同。

接受的行为：

- 按下一次点击；空框同样有。单击松手不加第二声。
- 长按 0.5 秒后每删一个字一声。左擦每多删一个字一声。右擦回放无声。
- 手指进入垃圾桶一声稍重确认。清空过程不再逐字响。滑出键盘和取消保持安静。
- 现有按键音和震动开关仍然有效。
- 长按约 0.15 秒后出现垃圾桶。松手在气泡内清空光标前已上屏文字。iOS 26 上底板是 regular Liquid Glass，手指在内时轻微变红。iOS 26 以下使用自适应 `systemUltraThinMaterial`。
- 26 键和 9 键共用这套删除键。

## Accepted evidence

1. 产品树是 `origin/main` `cee4f91`。本地未推送的 `40f93bc` 与 `fb8486c` 只是回写，不是验收对象。
2. 第一段独立 Architecture 与 Quality 均为 Pass with conditions。跟进差值独立 Quality 为 Pass，范围停在模糊材质改动之前。模糊那一行由合同测试和 hosted run 37574313596 覆盖。
3. Human 在 iPhone 13 Pro `00008110-000A08440198801E` 上的观察：修复计时器后垃圾桶出现且清空正确；Liquid Glass 与手指进入时变红已接受；发声表装到真机详测后接受。该机构在 iOS 26 上走玻璃分支，没有覆盖 iOS 18–25 的自适应模糊。这些是 Human 观察，没有设备日志。
4. 合同测试是源码字符串，不是模拟器里的真实点按。

## Hosts not claimed

退出条件里的微信、Safari、密码框没有记成已通过。备忘录上的 26 键 / 9 键手势、气泡和发声是本 Gate 接受的范围。未覆盖的宿主不挡这次接受，也不算整项退出条件已齐。

## Accepted residuals

| Residual | Gate disposition |
|---|---|
| DKS-CLOSE-01 — 单击和长按仍可能删成对标点或颜文字的两侧 | `accept` — 留在产品里。擦除和清空走单字素路径 |
| DKS-CLOSE-02 — 预编辑左滑重置 RIME session 并清 T9 Path | `accept` — 保留已确认前缀，不上屏剩余拼音 |
| DKS-GATE-HOST-01 — 微信、Safari、密码框未在本 Gate 声称已测 | `accept` — 不挡备忘录范围的接受；补测前不把退出条件写成已齐 |
| DKS-GATE-BLUR-01 — 真机没有看 iOS 26 以下的自适应模糊 | `accept` — 该分支由源码与 hosted CI 覆盖；iOS 26 玻璃是 Human 看过的路径 |

本 Gate 不关闭 Assignment，也不授权 TestFlight、Release 或 CHANGELOG。
