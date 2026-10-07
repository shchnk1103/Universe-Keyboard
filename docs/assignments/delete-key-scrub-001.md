# Assignment: DELETE-KEY-SCRUB-001 — 删除键滑动擦除、回放与删除全部气泡

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Reviewed` |
| **Phase** | Product Gate **Passed with accepted conditions**，钉 `origin/main` `cee4f914be03d45c6d8deae8af5427ff1587d5c1`。[`product-gate`](../product-decisions/DELETE-KEY-SCRUB-001-product-gate.md) |
| **Non-claims** | 不等于 Close、push、TestFlight 或 Release。微信 / Safari / 密码框未声称已测 |
| **Next** | Gate 文档 commit `45c84a773c0c8c6da6679e12667aa52ae1f367ff`。push 仍需新 AUTH。Close 另授权 |
| **Residuals** | DKS-CLOSE-01 单击/长按仍可能删成对两侧；DKS-CLOSE-02 预编辑左滑重置 session 并清 T9 Path。均已接受，留在本切片 |

---

- **Task ID:** `DELETE-KEY-SCRUB-001`
- **Date / timezone:** `2026-10-01 Asia/Shanghai`（合同捕获）；实施 Assignment Decision `2026-10-07 Asia/Shanghai`
- **Repository Change Type:** `Feature` + `Implementation`
- **Product Decision source:** [`PD-DELETE-KEY-SCRUB-001-PRODUCT-CONTRACT`](../product-decisions/DELETE-KEY-SCRUB-001-product-contract.md)

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner 当前会话，`2026-10-07 Asia/Shanghai`；公测用户反馈要求第三方键盘式「按住删除左右滑」；合同捕获见 `2026-10-01`
- Product Approver: Human Product Owner / 当前 Product 线程
- Authorization (role fill / Ready): [`AUTH-DELETE-KEY-SCRUB-001-ASSIGN-READY`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-ASSIGN-READY.md) — consumed
- Authorization (implementation): [`AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT.md) — active / unconsumed until delivery
- Historical docs publication: [`AUTH-DELETE-KEY-SCRUB-001-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-COMMIT.md)、[`AUTH-DELETE-KEY-SCRUB-001-PUSH-PR`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-PUSH-PR.md)、[`AUTH-DELETE-KEY-SCRUB-001-MERGE`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-MERGE.md) — consumed；不可复用于实施

## KOS v0.9.0 optional-contract selection

项目 pin 为 [`PD-KOS-UPGRADE-UK-006`](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md) advisory。本 Assignment **未** Profile-include；E-01 / P-01 / D-01 不 opt-in。A-01/B-01 为手工 advisory。新指定的独立审查车道适用 v0.9.0 reviewer scope/budget/stop。

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | 实施交付用既有 KeyboardTests / App+Keyboard；不新开 E-01 观测包 |
| A-01 / B-01 authorization chain and briefing | Adopted (advisory, not Profile-included) | 本 Assignment、ASSIGN-READY、IMPLEMENT 与产品合同构成本切片权威链 |
| P-01 publication facts | Not applicable | 未授权 commit/push/PR |
| D-01 final-documentation receipt | Not applicable | 本切片不宣称 D-01 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Role fill / Ready / slot 6 | Authorized | `assign_roles_and_enter_ready_delete_key_scrub` | Consumed [`AUTH-DELETE-KEY-SCRUB-001-ASSIGN-READY`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-ASSIGN-READY.md) |
| Keyboard UI implementation | Authorized / live | `implement_delete_key_scrub_v1` | Active [`AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT.md) |
| Independent Architecture | Concluded | Pass with conditions。[`architecture-close`](../reviews/delete-key-scrub-001-architecture-close.md)。该 AUTH 不授权 commit | Consumed [`AUTH-DELETE-KEY-SCRUB-001-ARCHITECTURE-CLOSE`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-ARCHITECTURE-CLOSE.md) |
| Independent Quality | Concluded | Pass with conditions。[`quality-review`](../reviews/delete-key-scrub-001-quality-review.md)。该 AUTH 不授权 commit | Consumed [`AUTH-DELETE-KEY-SCRUB-001-QUALITY`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-QUALITY.md) |
| Local implementation commit | Consumed | 实现 `ff149ac7fe8386399f39568f88f722c768153330`。不授权 push | Consumed [`AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-COMMIT.md) |
| Implementation push | Consumed | `origin/grok/delete-key-scrub-001` `6cae5b261d65cb1b47f3966db78f02df1fa79dd7`。未开 PR | Consumed [`AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-PUSH`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-PUSH.md) |
| Implementation PR | Consumed | PR [#202](https://github.com/shchnk1103/Universe-Keyboard/pull/202)，head `6cae5b2`。未 merge | Consumed [`AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-PR`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-PR.md) |
| PR #202 squash merge | Consumed off this head | `origin/main` `1560488664f6e51450a441f14e465760c0635820`；树与 `95fd0dc` 相同；hosted run [37567879900](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/37567879900)。收据不进入功能分支 | In-session merge AUTH，文件留在工作区未提交 |
| Follow-up commit | Consumed | 内容 `252d72666070372b7d92b473d75aea3a156071ee`。不授权 push | Consumed [`AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-COMMIT.md) |
| Follow-up Quality | Concluded | Pass。只覆盖 `1560488..f94a8a7`。[`followup-quality-review`](../reviews/delete-key-scrub-001-followup-quality-review.md)。不授权 push | Consumed [`AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-QUALITY`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-QUALITY.md) |
| Follow-up Quality docs commit | Consumed | 文档 `39badbc612b91b74fd2180f5de41457eace421b1`。不授权 push | Consumed [`AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-QUALITY-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-QUALITY-COMMIT.md) |
| Follow-up push | Consumed | `origin/grok/delete-bubble-001` `b9a9038e6e6206a316fb33705d071c080a8de811`。未开 PR。消费回写未再 push | Consumed [`AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-PUSH`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-PUSH.md) |
| Follow-up PR | Consumed | PR [#203](https://github.com/shchnk1103/Universe-Keyboard/pull/203)，head `b9a9038`。未 merge。开 PR 回写未 push | Consumed [`AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-PR`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-PR.md) |
| Follow-up blur push | Consumed | `7c804a08b1e7161b69dbef07a7abfc7aa1534a3e` 已在 PR #203。未 merge。消费回写未再 push | Consumed [`AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-BLUR-PUSH`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-BLUR-PUSH.md) |
| Follow-up squash merge | Consumed off this head | `origin/main` `cee4f914be03d45c6d8deae8af5427ff1587d5c1`；树与 `7c804a0` 相同。收据留在本地，未推送 | Consumed [`AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-MERGE`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-MERGE.md) |
| Product Gate | Concluded | Passed with accepted conditions。`Reviewed`，未 Close。[`product-gate`](../product-decisions/DELETE-KEY-SCRUB-001-product-gate.md) | Consumed [`AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE.md) |
| Product Gate docs commit | Consumed | 文档 `45c84a773c0c8c6da6679e12667aa52ae1f367ff`。不授权 push | Consumed [`AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-COMMIT.md) |
| Assignment Close | Unauthorized | 另需 AUTH | Product Lead |

## Boundary

### Scope

1. 已捕获的 V1 产品合同仍是行为 Source of Truth（见下方 Product Contract）。
2. 本切片实施该合同：删除键 `touchDown` 会话、松手单击、已上屏播放头擦除/回放、预编辑左滑一次 abandon、长按重复 + 垃圾桶 overlay、离开键盘 bounds 结束会话。
3. 占用 Active Work 第 6 号空位。工作只写在隔离 worktree / 功能分支，不改主 checkout 脏树。
4. Keyboard UI 为主；有界、无内容的播放头数学可放 KeyboardCore。清拼音走现有 abandon / reset session；删除全部用 host `deleteBackward` 循环，只清光标前。

### Non-goals

- 不改 RIME 部署边界、不新开第二条 host 写入路径
- 不做词级/按词跳删、不做跨会话撤销、不落盘删除账本、不上传上下文
- 不保证清空整篇长文或光标后文字
- 不把字母 `KeyPopupView` 抽成可复用组件（V1 删除键专用 overlay；后续另议）
- 不改空格光标、候选栏下滑收起、KEY-TOUCH-FILL 填缝合同
- 不授权独立 Architecture/Quality 结论、Product Gate、commit、push、merge、TestFlight 或 Release

### Required Inputs

- 本会话 Human 历次产品抉择（见 Product Contract）
- [`input-pipeline-and-marked-text.md`](../architecture/input-pipeline-and-marked-text.md) Delete 优先级
- [`partial-commit.md`](../architecture/partial-commit.md) 第一下 Delete restore
- [`0007-full-access-and-privacy-boundary.md`](../architecture/decisions/0007-full-access-and-privacy-boundary.md)
- 现有 `DeleteRepeatController`（0.5s / 0.08s）、`makeDeleteButton` 的 `touchDragExit` 停重复、空格光标长按滑动、`KeyPopupView`（高 38pt、缝 6pt）
- [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md) 键盘冻结与功能键符号
- [`playbooks/keyboard-ui.md`](../playbooks/keyboard-ui.md)

## Assignment

- Domain Owner: ⌨️ Keyboard Experience Maintainer
- Executor: Current Grok session acting as Keyboard Experience Maintainer / Keyboard UI
- Environment Executor: Current Grok session — App+Keyboard Debug on the already-booted iPhone 18 Pro `405D994F-28CB-4F89-BB22-B64AD81C05A2`（Human 指定，2026-10-07）。CI 文档里的默认机型仍是 `iPhone 17 Pro`；本切片模拟器证据以这台已启动的 iPhone 18 Pro 为准。
- Human Dependency: Human Product Owner — 真机 glance（Notes / 微信 / Safari / 密码框）与 Product Gate；不替代 Simulator 测试绿
- Architecture Reviewer: 🏛️ Architecture & Knowledge Steward — 独立 subagent；交付后另授 AUTH；禁止 git `/review` 替代。Budget：一次独立审查；Stop：Core 语义越界、ADR 0007 上传、新 host 写入路径、`selectAll`
- Quality Reviewer: 🧪 Quality, Performance & Release Maintainer — 独立 subagent；Architecture 结论之后另授 AUTH。Budget：一次独立审查 + 复现 Executor 的 KeyboardTests / App+Keyboard 命令
- Product Approver: Human Product Owner / 当前 Product 线程
- Supporting Domain: [`playbooks/keyboard-ui.md`](../playbooks/keyboard-ui.md)

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-10-07 Asia/Shanghai` — Human 指定上述责任人，授权填第 6 号空位，并确认实施 AUTH 生效。
- **Executor acknowledgement:** `2026-10-07 Asia/Shanghai` — Scope、Non-goals、Stop Conditions 已接受。工作在隔离 worktree `/private/tmp/universe-keyboard-delete-key-scrub-001`，基线 `origin/main` `781ca45dfe53cd8d90f49f60370a2efae9d3e749`，不触碰主工作区脏树。
- **Entry Criteria status:** **Met** for `Active` implementation slice（审查结论仍是后续 Gate，不是 Ready 前置）。
- **Product lifecycle decision:** `Assignment Pending → Assigned / Ready → Active` on the in-session answers “按建议填责任人” and “记录 Ready + 隔离 worktree + 实施 AUTH 生效”.

## Product Contract (V1)

会话从 **手指必须落在删除键上的 `touchDown`** 开始。从其他键滑入不算。所有带删除键的页面（26 键、九键、英文、数字、符号）同一套逻辑。

### 按下反馈

手指落到删除键上：立刻有按下态、按键音、震动。空框、光标在开头、密码框同样要有，避免用户以为键盘卡住。

### 单击

位移小于水平阈值（V1 约 10pt）且在长按重复开始前松手：松手时删一个。不在按下时删字。连点接受「每次抬手才少一个字」。

### 已上屏左右擦除

无活跃预编辑、水平位移过阈值后进入擦除，本次按住不再出气泡、也不能再转成长按重复。

- **播放头：** 按下点水平位置为 0。往左的距离决定本次按住删了几个已上屏字素；往右按距离从本次内存账本 `insertText` 回放。
- 速度只决定扫过这段位移有多快，不在同一距离上多删字。
- 手指停住但不松手：播放头不动，删和回放都停。
- 按下时不先删一个字。
- 账本只在本次按住的进程内存，松手、取消、离开键盘 bounds、`viewWillDisappear` 时丢弃。不写日志、不落盘。
- 一次字数上限日后评估；V1 必须有界，避免长文卡住扩展。

### 预编辑（composing）

指未上屏的拼音/marked preedit/T9 Path 仍在（含部分确认后的剩余拼音）。已上屏字不动。

- 左滑过同一约 10pt 阈值：一次丢弃全部剩余预编辑（abandon / reset session，不上屏）。不按距离或速度剥。
- 右滑：空操作，无恢复。
- 预编辑期间 **不出** 垃圾桶气泡。
- 长按仍可按现有节奏一个一个剥拼音；剥光后若已能看见光标前已上屏字，本次按住可以再出气泡。

### 长按重复

几乎无水平位移：前 0.5s 不删字（日后可调）；到点后按现有 0.08s 节奏开始删（做法甲：不补「单击那一个」）。长按开始后 **不能** 改成左右擦除。

开始重复后再约 0.15s（约按下后 0.65s，可调）出气泡。

### 删除全部气泡

- 只有键盘 **看得见** 光标前至少有一个已上屏字时才出现（截断但非空仍出现；密码框等读不到则不出现）。
- 第一版：键上方 overlay，仅 template SF Symbol `trash`（不用 Configuration 填色、不用 emoji 文案）。
- 可覆盖候选栏和 Path，**不得画出键盘整体区域**（浮动键盘不含宿主页面）。九键删除在右列最上，气泡须随剩余高度缩小（字母变体参考：面板 38pt + 缝 6pt；V1 预期约 28–32pt 或更扁）。
- 手指在气泡命中区内松手：尽力循环 host `deleteBackward`，只清 **当时还剩下的** 光标前已上屏字；不清光标后；不把本次已经删掉的字找回来。
- 进过气泡再滑走、只要松手前又停在气泡里，仍可清空。滑回键上松手：取消清空，继续长按重复。
- 去气泡路上停掉重复删除。
- 文案/能力：尽力而为，不保证整篇长文。

### 空与删尽

光标前已无可删的已上屏字且无预编辑：不再删、不出/收起气泡、不再擦除。按下那一下仍有视觉和声音；之后的重复节拍不再出声。一次按住中途删空：立刻收气泡、停止删除；键可保持按下态直到松手。

例 D（光标在开头、字在后面）与空框相同：删不动光标后。例 E（密码框）：不出气泡；点按/长按/滑动仍尝试 `deleteBackward`，删到了才有少字反馈。

### 离开键盘

手指坐标落到键盘 view bounds 外（仍不松手）：结束本次会话。已删的保持。不再继续删、回放或清空。滑回来必须重新按下。

### 其它

- 擦除时其它键不变淡。
- VoiceOver：删除键仍是普通键盘键；气泡需要无障碍标签。实施时补合同。
- `touchDragExit` 不得结束按住会话；滑动必须允许离开键面。
- Overlay 命中仍挂在真删除键上（KEY-TOUCH-FILL）。

### V1 默认可调、不挡合同收口

- 长按 0.5s、气泡再 0.15s
- 水平阈值约 10pt
- 气泡约 28–32pt 并随剩余高度缩小
- 擦除账本 / 删除全部循环上限（内存与主线程有界）

## Gates

### Entry Criteria

- [x] Product 授权本切片：起草 Assignment + 挂待办（`2026-10-01`）
- [x] 隔离 worktree，不改脏主 checkout（`2026-10-07` 重建于 `781ca45d`）
- [x] Executor / Architecture Reviewer / Quality Reviewer / Environment Executor 已指定
- [x] 实施 AUTH 生效
- [x] Active Work Ready/Active cap 第 6 号空位
- [x] 独立 Architecture 对实施切片 Pass with conditions，残差已 disposition — [`architecture-close`](../reviews/delete-key-scrub-001-architecture-close.md)
- [x] 独立 Quality 结论 Pass with conditions — [`quality-review`](../reviews/delete-key-scrub-001-quality-review.md)

### Exit Criteria（整项功能）

- 合同行为在 26 键与九键、中英/数字/符号页可演示
- KeyboardTests / 相关 KeyboardCore 覆盖单击、擦除播放头、预编辑一次清光、气泡松手清空光标前、离开 bounds 结束
- 真机：Notes、微信、Safari、密码框、光标在中间、空框（Human glance）
- 浅色/深色；热路径不把输入内容写入日志或磁盘
- 独立 Architecture / Quality / Product Gate 各有结论

本实施切片 Executor Exit：V1 行为在隔离 worktree 落地且约定测试已跑；不等于 Reviewed / Closed。

### Stop Conditions

- 需要读完整 host 文档或 `selectAll` 才能声称「删除全部」
- 删除全部误伤光标后
- 预编辑左滑上屏了剩余拼音
- 账本持久化或离开设备
- 在主 checkout / 脏树上改 Swift
- 未授 AUTH 就 commit / push / merge / TestFlight / Release
- 用 git `/review` 替代独立 Architecture / Quality

## Handoff

- Handoff Target: 独立 Architecture Reviewer（交付后）；随后 Quality；Product Gate 仍归 Human
- Required Handoff Content: 本 Assignment、PD 合同、实施 AUTH、隔离 worktree 路径、测试命令与结果、未做的审查/发布
- Revalidation Trigger: 改 Delete 优先级、Partial Commit restore、ADR 0007、删除键布局、或 Human 改口播放头/气泡/空框反馈

## History

- `2026-10-01 Asia/Shanghai`：Human 要求评估第三方「按住删除左右滑」；后续补单击松手、播放头、长按气泡、预编辑一次清光、看见才出气泡、离开键盘结束等合同。Human 授权起草 Assignment 并挂待办，今天不实施。Lifecycle → `Assignment Pending`。隔离 worktree `/private/tmp/universe-keyboard-delete-key-scrub-001`，分支 `grok/delete-key-scrub-001`。
- `2026-10-01 Asia/Shanghai`：Human 授权本切片文档 commit、push，必要时开 PR。不授权 merge、实施或 TestFlight。
- `2026-10-01 Asia/Shanghai`：隔离分支 docs commit `037e42ced1f208a08a0799382aebfebb78ae86dc`；[`AUTH-DELETE-KEY-SCRUB-001-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-COMMIT.md) consumed。
- `2026-10-01 Asia/Shanghai`：已 push 并开 PR [#196](https://github.com/shchnk1103/Universe-Keyboard/pull/196)；[`AUTH-DELETE-KEY-SCRUB-001-PUSH-PR`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-PUSH-PR.md) consumed。Human 观察 hosted CI。不授权 merge。
- `2026-10-01 Asia/Shanghai`：PR #196 squash-merge `8f0fa58c57f11891f4e8c6783e7f4bce6a788984`（same-head docs_only run [36823864783](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/36823864783)）。[`AUTH-DELETE-KEY-SCRUB-001-MERGE`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-MERGE.md) consumed。功能分支与隔离 worktree 已清理。Lifecycle 仍 `Assignment Pending`。无实施 / TestFlight / Release。
- `2026-10-07 Asia/Shanghai`：Human 指定 Executor = 当前 Grok，独立 Architecture / Quality，Environment = Grok Simulator，Human = 真机 glance / Gate；授权填第 6 号空位并让实施 AUTH 生效。隔离 worktree 重建于 `origin/main` `781ca45d`，分支 `grok/delete-key-scrub-001`。Lifecycle → `Active`。无 commit / push / Quality / Gate / TestFlight / Release。
- `2026-10-07 Asia/Shanghai`：同一 Architecture 车道只做一页收口，不重审整项。当前结论是 Architecture Pass with conditions（[`architecture-close`](../reviews/delete-key-scrub-001-architecture-close.md)）。Round 1 原文仍是 Reject。不授权 Quality、commit、push、merge。
- `2026-10-07 Asia/Shanghai`：独立 Quality Pass with conditions（[`quality-review`](../reviews/delete-key-scrub-001-quality-review.md)）。KeyboardCore 1201 与 App+Keyboard Debug test 在 iPhone 18 Pro `405D994F-28CB-4F89-BB22-B64AD81C05A2` 上通过。未真实点按删除键。不授权 commit、push、merge。
- `2026-10-07 Asia/Shanghai`：本地实现 commit `ff149ac7fe8386399f39568f88f722c768153330`（[`IMPLEMENT-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-COMMIT.md)）。未 push。无 Product Gate / merge / TestFlight / Release。
- `2026-10-07 Asia/Shanghai`：已推送 `origin/grok/delete-key-scrub-001` `6cae5b261d65cb1b47f3966db78f02df1fa79dd7`（[`IMPLEMENT-PUSH`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-PUSH.md)）。未开 PR。无 merge / TestFlight / Release。
- `2026-10-07 Asia/Shanghai`：已开 PR [#202](https://github.com/shchnk1103/Universe-Keyboard/pull/202)，head `6cae5b2`（[`IMPLEMENT-PR`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-IMPLEMENT-PR.md)）。未 merge。无 TestFlight / Release。
- `2026-10-07 Asia/Shanghai`：PR [#202](https://github.com/shchnk1103/Universe-Keyboard/pull/202) squash-merged `1560488664f6e51450a441f14e465760c0635820`。树与 PR head `95fd0dc07b191d8dee3c43bd58904e31d84cf781` 相同。hosted Swift 6 Quality run [37567879900](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/37567879900) 全绿。merge 收据留在工作区，不进入本分支。Lifecycle 仍 `Active`。无 Product Gate / TestFlight / Release。
- `2026-10-07 Asia/Shanghai`：真机 iPhone 13 Pro `00008110-000A08440198801E` 上，长按期间 0.08s 重复不断重置 0.15s 气泡计时器，气泡不出现。改为只武装一次，并挂到 `RunLoop` `.common`。Human 确认气泡出现且清空正确。
- `2026-10-07 Asia/Shanghai`：气泡改为 iOS 26 regular Liquid Glass；手指在内时玻璃和符号带轻微 `systemRed`。Human 接受。
- `2026-10-07 Asia/Shanghai`：删除键发声按约定表调整。按下一次；单击松手不加第二声；连删和擦除每个实际删除的字素一声；进入气泡一次稍重确认；清空循环、回放、滑出键盘和取消不出声。Human 真机详测接受。`DeleteKeyScrubContractTests` 3/3 在 iPhone 18 Pro `405D994F-28CB-4F89-BB22-B64AD81C05A2` 通过。产品合同未改写。无 Product Gate。
- `2026-10-07 Asia/Shanghai`：有界跟进 commit `252d72666070372b7d92b473d75aea3a156071ee`（[`FOLLOWUP-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-COMMIT.md) consumed）。不授权 push。
- `2026-10-07 Asia/Shanghai`：跟进差值独立 Quality **Pass**（[`followup-quality-review`](../reviews/delete-key-scrub-001-followup-quality-review.md)）。`DeleteKeyScrubContractTests` 3/3 与三文件 `swift-format lint --strict` 由审查者复现。未重跑全套，未真实点按。DKS-CLOSE-01/02 仍在。[`FOLLOWUP-QUALITY`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-QUALITY.md) consumed。无 push / Product Gate。
- `2026-10-07 Asia/Shanghai`：有界文档 commit `39badbc612b91b74fd2180f5de41457eace421b1`（[`FOLLOWUP-QUALITY-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-QUALITY-COMMIT.md) consumed）。只含审查页、Quality 授权和账本。不授权 push。无 Swift。
- `2026-10-07 Asia/Shanghai`：已推送 `origin/grok/delete-bubble-001` `b9a9038e6e6206a316fb33705d071c080a8de811`（[`FOLLOWUP-PUSH`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-PUSH.md) consumed）。未开 PR。消费回写留在本地。无 merge / Product Gate。
- `2026-10-07 Asia/Shanghai`：已开 PR [#203](https://github.com/shchnk1103/Universe-Keyboard/pull/203)，head `b9a9038`（[`FOLLOWUP-PR`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-PR.md) consumed）。未 merge。开 PR 回写留在本地。无 Product Gate。
- `2026-10-07 Asia/Shanghai`：接受 Codex 对气泡模糊的一条建议。iOS 26 以下改为自适应 `systemUltraThinMaterial`，已推送 `7c804a08b1e7161b69dbef07a7abfc7aa1534a3e`（[`FOLLOWUP-BLUR-PUSH`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-FOLLOWUP-BLUR-PUSH.md) consumed）。PR #203 head 已前进。未 merge。消费回写留在本地。
- `2026-10-07 Asia/Shanghai`：PR [#203](https://github.com/shchnk1103/Universe-Keyboard/pull/203) squash-merged `cee4f914be03d45c6d8deae8af5427ff1587d5c1`。树与 `7c804a0` 相同。hosted run [37574313596](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/37574313596) 在 merge 前全绿。Lifecycle 仍 `Active`。无 Product Gate / TestFlight / Release。功能分支保留。
- `2026-10-07 Asia/Shanghai`：Human Product Gate **Passed with accepted conditions**（[`product-gate`](../product-decisions/DELETE-KEY-SCRUB-001-product-gate.md)，[`PRODUCT-GATE`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE.md) consumed）。接受发声表、玻璃变红、自适应模糊，以及 DKS-CLOSE-01 / DKS-CLOSE-02。微信、Safari、密码框未声称已测。Lifecycle → `Reviewed`。未 Close。本页未 commit / push。无 TestFlight / Release。
- `2026-10-07 Asia/Shanghai`：有界文档 commit `45c84a773c0c8c6da6679e12667aa52ae1f367ff`（[`PRODUCT-GATE-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-PRODUCT-GATE-COMMIT.md) consumed）。只含 Gate 页、授权和账本。不授权 push。无 Swift。无 Close。
