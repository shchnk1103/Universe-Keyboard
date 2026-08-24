# RELEASE-2026-0801-08 — Human Product Gate 清单

Prepared by: 当前 Grok 任务（08 Executor）  
Handoff target: **Human Product Owner**（真机操作）→ 回报后由 **Product Lead**（同一人）裁定 Pass / Fail / 带残差接受  
Date / timezone: `2026-08-24 Asia/Shanghai`

> **Gate result (`2026-08-24`):** Human Product Owner 在 iPhone 13 Pro / iOS 27.0 上报 G-01…G-16 成功。Product Lead 裁定 **Passed**。证据：[`release-2026-08-01-08-product-gate-2026-08-24.md`](../evidence/release-2026-08-01-08-product-gate-2026-08-24.md)。本清单正文仍是操作合同；不得把 Passed 读成 Closed 或可合并。

先前口述「26 键和九宫格都没问题」仍是 smoke（[`证据`](../evidence/release-2026-08-01-08-human-device-smoke-2026-08-23.md)），**不能**勾掉下表。可用同一台已安装的构建再走一遍场景。

---

## 1. 已证明、不必在真机上辩论

| 项 | 状态 |
|---|---|
| ADR 0030 Accepted；平行 `pendingKaomoji`，无同键轮换 | [`ADR`](../architecture/decisions/0030-pending-kaomoji-palette.md) |
| Architecture | [`Pass`](release-2026-08-01-08-architecture-review.md) |
| Quality Q1 | [`Pass with conditions`](release-2026-08-01-08-quality-review.md) |
| 05 文案约束 | Product 已接受 [`卡`](../evidence/release-2026-08-01-08-handoff-to-05-copy-constraints.md) |

## 2. 开始前请记下（越全越好）

最少：机型、iOS、Debug 或 Release、宿主 App（建议备忘录）、全访问开/关、当前是九键还是 26 键。

没有 commit SHA / 二进制摘要时，证据偏弱，但 **不自动 Fail**；请在回报里写「未记 SHA」。不要中途重装键盘再把两轮混成一轮。

一台 iPhone 就够。不要求 iPad、不要求第二台机。

## 3. 必测场景

在 **中文**、普通文本框里做。每项填 `Pass` / `Fail` / `Skip`（Skip 必须写原因）。

| ID | 操作 | 期望 | 你的结果 |
|---|---|---|---|
| G-01 | 九键点 `^_^` | 输入框出现 `^_^`；候选栏出现颜表情；`^_^` 在最左且看起来是当前项 | |
| G-02 | 点另一个脸（例如 `＾ω＾`） | **换成**那一张，不是 `^_^＾ω＾` | |
| G-03 | 再点一次 `^_^` **键**（不是候选） | 留下当前脸，再新开一个 `^_^`；**不要**在几个脸之间轮换 | |
| G-04 | 空格 | 接受当前脸，后面多一个空格；不要变成点选栏里第一项 | |
| G-05 | 回车 | 接受后换行（或宿主回车语义），pending 结束 | |
| G-06 | 插入后立刻删除 | 只去掉这段颜表情，前面的字还在 | |
| G-07 | 先打 `ni` 出候选，再点 `^_^` | 先上屏首选（如「你」）再跟 `^_^`；不要丢拼音也不要变成生拼音+表情 | |
| G-08 | 先点 `，。？！` 再点 `^_^` | 逗号留下，再出 `^_^`；两套不要互相删字 | |
| G-09 | 点 `^_^` 后立刻连点 `，。？！` 两次（1 秒内） | 应能 `，`→`。` 轮换；颜表情不要被标点逻辑带跑 | |
| G-10 | 中文符号页的 `^_^` | 与九键同一套：插入、候选可换 | |
| G-11 | 26 键字母页 | **没有**多出一枚颜表情键；普通拼音不回归即可 | |
| G-12 | 候选栏展开或下滑 | 能看到更多；宽脸在紧凑栏被截断可接受 | |

G-01…G-12 任一项 **Fail** → 本轮 Gate 不得标 Pass。Skip 只允许「当前布局进不去」（例如当时不在符号页），并补做或接受为残差。

## 4. 建议但可不挡 Pass 的项

| ID | 操作 | 期望 | 不做时 |
|---|---|---|---|
| G-13 | 切到英文再切回 | 切走时接受 pending，不删已上屏的脸 | 可 Skip，记残差 |
| G-14 | 收起键盘再打开 | 已上屏的脸还在，不再处于可替换 pending | 可 Skip |
| G-15 | VoiceOver：键、当前候选 | 键为「颜表情」；候选 **可以没有**「已选中」（Q1-C-03 / A30-P2-06） | 不做 = 接受无障碍残差，**不要**为补它改成空格选第一项 |
| G-16 | 任意第三方输入框（微信等）光标怪异 | 与 0029 同类 host 风险（A30-P2-04） | 不做 = 接受 host 手术残差，不得对外宣称任意 App 已认证 |

## 5. 你可以带残差接受、但必须说出口的项

Quality 要求 Gate **带着**这些，而不是假装测过：

- **A30-P2-04 / Q1-C-02：** 真机 host 手术未按撕裂矩阵验证。
- **A30-P2-06 / Q1-C-03：** VoiceOver `.selected` / 「已选中」未落地。
- **A30-P2-05：** 抄录表近形重复。
- **Q1-C-01：** 未跑与 CI 等价全套（与本 Gate 正交；Pass 仍不可合并）。

写法示例：「G-01…G-12 Pass；G-15 Skip，接受 Q1-C-03；A30-P2-04 接受。」

## 6. 怎么回报

直接回复，复制填好的表即可。最少三句：

1. 机型 / iOS / Debug 或 Release / 宿主  
2. G-01…G-12 哪些 Pass / Fail  
3. Product Gate 裁定：`Pass` / `Fail` / `Pass with residuals`（列出接受的残差 ID）

截图加分，不是必须。Fail 时写「实际看到什么」。

## 7. 本清单之后谁做什么

- **Fail：** 停在 08 Assigned；不要改商店卖点；Executor 等你的复现再谈修。
- **Pass / Pass with residuals：** Product Lead 书面裁定后，08 Exit 的「设备检查」可勾；05 才可以把颜表情写进商店主文案（仍受文案卡约束）。**仍不是** merge / RC / TestFlight 上传授权。
- Executor **不得**根据本聊天里的旧 smoke 自行勾 Pass。

## 8. 明确不做

- 不要求第二台设备或 iPad  
- 不要求与系统颜文字面板像素级对比  
- 不要求测网络词库（没有）  
- 不把空格改成「选定第一项」来凑无障碍
