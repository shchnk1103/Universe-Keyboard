# Product Decision: KEYBOARD-LAYOUT-9KEY-PUNCT-001 — 九键常用标点待确认与同键轮换

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-PUNCT-001`
**Lifecycle status:** `Recorded` — Assignment `KEYBOARD-LAYOUT-9KEY-PUNCT-001` 已 `Closed`
**Date / timezone:** `2026-08-15 Asia/Shanghai`
**Assignment:** [`KEYBOARD-LAYOUT-9KEY-PUNCT-001`](../assignments/keyboard-layout-9key-punct-001.md)
**Parent contract:** [`KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md) nine-key chrome（`KEYBOARD-LAYOUT-9KEY-UI-001` Closed）

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Recorded` |
| **Phase** | 产品合同已冻结；Human Product Gate Passed；PR [#75](https://github.com/shchnk1103/Universe-Keyboard/pull/75) 已交付并合并 |
| **Non-claims** | 不占 Active Work 槽；不改 26 键 / 数字页 / 符号页；不做系统整页标点盘 |
| **Next** | 无 |
| **Residuals** | 产品合同无未决项。实现残余见 Assignment Q2（`A2-P2-04` / `Q2-C-03`） |

---

## Decision

Human Product Owner 在 `2026-08-15 Asia/Shanghai` 以系统中文九宫格截图为参照，要求强化九键 `，。？！` 键，并当场冻结下列合同。

> **Delivery supersession（2026-08-15）：** 合同已由 PR [#75](https://github.com/shchnk1103/Universe-Keyboard/pull/75) 交付。下文「只记录产品意图 / 不授权改 Swift / 当前实现仍是 ASCII `",?!"`」是 Recorded 当时的授权边界，不是现在的代码事实。键面现为 `，。？！`，单击走 ADR 0029 pending 状态机。

## Bound Product Decisions

1. **键面**  
   中文九键字母页该键显示 `，。？！`（中文逗号、句号、问号、叹号），不再使用 `,?!`。

2. **展示面**  
   标点选择复用现有候选栏（可横滑、可按现有方式展开）。不做系统那种键区顶栏 + 整页标点盘，也不做 `半` 角标。

3. **默认上屏**  
   单击该键：立即上屏待确认标点 `，`，并打开本地标点候选。  
   `，` 在被接受或删除前，不是普通已完成文本。

4. **候选点选 = 替换**  
   点候选栏中的标点，用该标点**替换**当前待确认文本，不是追加。  
   点选后：轮换窗关闭，pending 仍在，候选栏继续对着这份 pending。

5. **同键短时轮换**  
   距上次**同键**点击 ≤ **1.0 秒**，再点该键：按  
   `， → 。 → ？ → ！ → ，`  
   替换当前待确认标点，并刷新轮换窗。  
   轮换集合只有键面上这 4 个符号。

6. **轮换窗与 pending 寿命分离**  
   - 轮换窗：只决定再点该键是轮换还是新开逗号。  
   - pending：由字母 / 空格 / 回车 / 离开中文九键字母页（`123` / `#+=` / 切英文 / 切 emoji）/ Delete 结束，不随 1.0 秒一起消失。  
   - 空格结束 pending 后**再插入空格**，不是选中候选栏第一项。  
   - 窗外再点该键：接受当前 pending，再新开一个待确认 `，`。

7. **候选点选后再点该键**  
   视为新开逗号：接受刚点选的标点，再插入新的待确认 `，`。  
   即使仍在 1.0 秒内，也不再沿 4 键轮换，避免把 `……` 等非轮换项吃掉。

8. **拼音进行中**  
   有可提交首选时：先提交首选汉字，清空 Path，再进入 pending。  
   不得把 preedit/display 当首选上屏，不得把 `，` 交给 RIME punctuator。  
   L1 / responsive provisional ahead：拒绝该键，保持组字，不准放弃后再塞逗号。  
   这不是「拼音中废掉该键」，只挡住无法安全提交的那一帧。

9. **V1 候选清单（first cut）**  
   紧凑栏至少能看到当前 pending 之外的 `。？！`，并继续提供常用标点。授权的第一版完整表：

   `。？！……～#：、；“”‘’（）@`

   紧凑栏从该表中排除当前 pending。展开面板可显示整表，当前 pending 给已选态。  
   成对符号复用已有 `paired_symbol_completion_enabled`，不另做一套。  
   pending 载荷是一段可替换文本（成对符号可能长于 1 个 Character），不是写死的单字符。

10. **状态归属**  
    pending 标点、轮换下标、轮换窗、候选清单都是 KeyboardCore 状态。  
    禁止复用 post-commit continuation，禁止假装成 RIME 候选。  
    实现前若新增 `CandidateKind` 或本地候选源，必须先立 ADR。

## Authorization Source

Human Product Owner，当前会话 `2026-08-15 Asia/Shanghai`：

- 提供系统九键截图，要求先上屏 `，`，再在候选栏展示可滑、可展开的常用标点。  
- 补充同键短时轮换：`，` → `。` → `？` → `！` → `，`。  
- 当场确认：轮换窗 **1.0 秒**；候选点选后再点该键 = **新开逗号**；授权起草本 Assignment，先不写实现。  
- 当场确认 Architecture Review 条件项：空格 = 接受后再插入空格；离开中文九键字母页（含切 emoji）即接受 pending。

## Explicit non-authorization

下列条目是 Recorded 当时的授权边界。实现与 chrome 更新后来已另授并随 #75 交付；其余 non-goals 仍有效。

- ~~实现、PR、改 `KEYBOARD_LAYOUT.md` 既有 chrome 图为已交付状态~~ — 已由后续实现授权 + #75 覆盖
- 系统整页标点盘、`半` 角标、半角变体表
- 26 键、数字页、符号页现有标点行为
- 颜表情候选、RIME `punctuator` / 方案配置
- 九键字母 multi-tap、Path Bar / 拼音合同
- ~~把本项写入 Active Work 10 槽（当前生命周期是 Assignment Pending）~~ — 实现期曾占槽；现已 Closed，不再占 Active

## Revalidation

改变展示面、替换/追加语义、轮换集合、1.0 秒窗口、候选点选后的同键语义，或把 pending 并进 continuation / RIME 候选，必须停止并修订本 Decision。
