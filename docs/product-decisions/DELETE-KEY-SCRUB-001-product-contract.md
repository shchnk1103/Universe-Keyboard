# PD-DELETE-KEY-SCRUB-001 — 删除键滑动擦除产品合同

> **Status:** Accepted as a **product-contract capture**
>
> **Date:** `2026-10-01 Asia/Shanghai`
>
> **Assignment:** [`DELETE-KEY-SCRUB-001`](../assignments/delete-key-scrub-001.md)
>
> **Authority:** Human Product Owner / Product Lead

本文件冻结公测反馈所要的删除键手势 V1 合同。它不是实施授权，不是 Architecture/Quality/Product Gate，也不授权 commit、push、PR、merge、TestFlight 或 Release。

详细状态机、空框/密码框例子、非目标与 UNKNOWN 责任人见 Assignment。摘要：

1. 手指必须从删除键按下才开始本次会话。
2. 按下即有视觉、按键音、震动（含空框），避免以为键盘卡住。
3. 单击：松手删一个；滑动按下不先删字。
4. 已上屏：水平播放头 + 位移决定字数，速度只影响扫过快慢；停住则停；右滑回放本次内存账本。
5. 预编辑：左滑一次清全部剩余拼音，无右滑恢复；期间不出气泡。
6. 长按：0.5s 内不删，到点 0.08s 重复；不能转为擦除；约再 0.15s 出 `trash` 气泡。
7. 气泡在键上方 overlay，可盖候选/Path，不画出键盘区域；在气泡内松手尽力清光标前剩余已上屏字。
8. 看得见光标前至少一个已上屏字才出气泡。
9. 离开键盘 bounds 结束本次；已删保持。
10. 所有带删除键的页面同一套逻辑。

`2026-10-07 Asia/Shanghai`：责任人已填写，实施 AUTH 生效。见 [`DELETE-KEY-SCRUB-001`](../assignments/delete-key-scrub-001.md) 与 [`AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT.md)。本文件仍只冻结产品合同，不是 Architecture/Quality/Product Gate，也不授权 commit、push、merge、TestFlight 或 Release。
