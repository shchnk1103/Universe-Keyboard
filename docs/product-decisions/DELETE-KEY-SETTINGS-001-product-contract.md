# PD-DELETE-KEY-SETTINGS-001 — 删除键设置

## Current Status

| Field | Value |
|---|---|
| Status | Accepted for this implementation slice |
| Date | `2026-10-07 Asia/Shanghai` |
| Non-claims | 不修改 [`DELETE-KEY-SCRUB-001` 合同](DELETE-KEY-SCRUB-001-product-contract.md)。不是 Product Gate、TestFlight 或 Release |

Human Product Owner 在同一会话定稿放置、开关和离开按键规则，随后授权按现行 KOS 开工。

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-DELETE-KEY-SETTINGS-001",
  "record_type": "product_decision",
  "title": "Delete-key settings page",
  "status": "accepted",
  "updated_at": "2026-10-07T14:47:00+08:00",
  "revalidation_triggers": ["product_choice_changed"],
  "product_decision": {
    "decision": "Add a Delete Key settings subpage with three default-on switches.",
    "assignment": "DELETE-KEY-SETTINGS-001",
    "supersedes_ref": null
  }
}
```

## 放置

设置 → 输入体验 →「删除键」，排在「键盘反馈」后面。不放进 App 设置、键盘布局或键盘反馈。开关只存在于主 App，经 App Group `group.com.DoubleShy0N.Universe-Keyboard` 给键盘扩展。

## 开关

点按删除和长按重复始终可用。本页没有长按开关，也不说明长按。

三个开关默认开。没有对应 UserDefaults 键时视为开。26 键、九键、英文、数字、符号共用。

| 开关 | 开 | 关 |
|---|---|---|
| 长按垃圾桶 | 按住后出现垃圾桶。移进去松手，清空光标前能看见的文字。 | 按住后不出现垃圾桶。 |
| 滑动擦除 | 按住后向左按距离删除，向右滑回刚删的字。 | 手指离开删除键就停止这一次删除。 |
| 组字时左滑 | 正在组字时向左滑，放弃还没上屏的拼音。 | 正在组字时向左滑，不再放弃剩余拼音。 |

发声和触感仍用「键盘反馈」。取消或停止本次删除不额外出声。一次按住使用按下时读到的值；下一次按下再用新值。

## 关闭滑动之后

手指还在删除键上时，点按和长按与现在相同。键面上的水平移动不因此停止长按。

手指离开删除键边界：已经删掉的字保留；松手不再补一次点按删除；不松手滑回键上也不恢复重复。需要重新按下。

垃圾桶仍开、气泡已经出现时，键与气泡之间大约 6 pt 的缝还不算离开后的最终判定。穿过缝走进气泡再松手，仍然清空。停在缝里、移到别处，或滑回删除键，都结束这次删除：保留已删文字，不再重复，也不清空。气泡还没出现时，离开键面就直接停止，不为尚未出现的气泡预留清空。

## 组字

组字时不出垃圾桶。组字左滑开着时，向左超过现有水平阈值只放弃剩余预编辑，不擦除已上屏文字，也不继续长按。组字左滑关着且滑动擦除也关着时，向左离开只是停止这一次。组字左滑关着但滑动擦除开着时，向左滑既不放弃剩余拼音，也不擦除已上屏文字。

## 保持不变

滑动擦除开着时，维持现有 V1：大约 10 pt 水平锁定、向右回放、擦除抑制气泡、长按不能改成擦除、朝气泡离开键面不结束按住。读不到光标前文字时不出气泡。清空仍有 256 字素上限。这两条不写入设置页文案。
