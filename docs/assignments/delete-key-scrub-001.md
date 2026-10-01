# Assignment: DELETE-KEY-SCRUB-001 — 删除键滑动擦除、回放与删除全部气泡

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Assignment Pending` |
| **Phase** | Product 合同已写入本记录；今天不实施 |
| **Non-claims** | 无 Swift、无实施 AUTH、无 Ready/Active、无 Architecture/Quality、无 merge/TestFlight/Release。文档 commit/push/PR 由独立 AUTH 覆盖，不等于实施或可合并 |
| **Next** | 文档框架按 AUTH 发布后，仍须 Human 指定 Executor / 审查人并另授实施 AUTH 才能进入 `Assigned` / `Ready` |
| **Residuals** | None |

---

- **Task ID:** `DELETE-KEY-SCRUB-001`
- **Date / timezone:** `2026-10-01 Asia/Shanghai`
- **Repository Change Type:** `Feature`（本切片仅为文档框架）
- **Product Decision source:** [`PD-DELETE-KEY-SCRUB-001-PRODUCT-CONTRACT`](../product-decisions/DELETE-KEY-SCRUB-001-product-contract.md)

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner 当前会话，`2026-10-01 Asia/Shanghai`；公测用户反馈要求第三方键盘式「按住删除左右滑」
- Product Approver: Human Product Owner / 当前 Product 线程

## KOS v0.8.0 optional-contract selection

本 Assignment **未** opt-in E-01 / A-01/B-01 / P-01 / D-01。省略的合同保持在本记录之外。

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | 无实施、无观测包 |
| A-01 / B-01 authorization chain and briefing | Not applicable | 尚无实施或审查 AUTH |
| P-01 publication facts | Not applicable | 未授权 commit/push/PR |
| D-01 final-documentation receipt | Not applicable | 本切片不宣称 D-01 |

## Boundary

### Scope

1. 捕获删除键手势 V1 产品合同（见下方 Product Contract），作为后续实施的 Source of Truth。
2. 在 Active Work **Queued** 区、Knowledge Index、Engineering Dashboard 挂待办指针。不进入 Ready/Active 十项 cap。
3. 文档只写在隔离 worktree / 功能分支，不改主 checkout、不改 Swift。

后续实施（需新 AUTH，不在今天范围内）预期落在 Keyboard UI：删除键 `touchDown` 会话、`DeleteRepeatController`、类 `KeyPopupView` 的垃圾桶 overlay、已上屏擦除账本；清拼音走现有 abandon / reset session；删除全部用 host `deleteBackward` 循环，只清光标前。

### Non-goals

- 今天不写 Swift、不改 RIME 部署边界、不新开第二条 host 写入路径
- 不做词级/按词跳删、不做跨会话撤销、不落盘删除账本、不上传上下文
- 不保证清空整篇长文或光标后文字
- 不把字母 `KeyPopupView` 抽成可复用组件（V1 删除键专用 overlay；后续另议）
- 不改空格光标、候选栏下滑收起、KEY-TOUCH-FILL 填缝合同
- 不进入 Ready/Active，不占用 M-05 十项名额
- 不授权 merge / TestFlight / Release / 实施；文档 commit/push/PR 见 [`AUTH-DELETE-KEY-SCRUB-001-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-COMMIT.md) 与 [`AUTH-DELETE-KEY-SCRUB-001-PUSH-PR`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-PUSH-PR.md)

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
- Executor: UNKNOWN — 实施尚未指定；本切片文档由当前 Grok 会话按 Human「起草 Assignment」写入隔离 worktree
- Environment Executor: UNKNOWN — 真机/模拟器验收尚未到阶段
- Human Dependency: Human Product Owner — 今天只搭框架、不继续实施；日后真机 glance 与 Product Gate
- Architecture Reviewer: UNKNOWN — 实施进入 Ready 前必须指定独立 Architecture（禁止用 git `/review` 替代）
- Quality Reviewer: UNKNOWN — 实施进入 Ready 前必须指定独立 Quality
- Product Approver: Human Product Owner / 当前 Product 线程

`UNKNOWN` 为诚实披露，故本 Assignment **不能**进入 `Ready` 或 `Active`。

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

- [x] Product 授权本切片：起草 Assignment + 挂待办
- [x] 隔离 worktree，不改脏主 checkout
- [ ] Executor / Architecture Reviewer / Quality Reviewer / Environment Executor 已指定（现为 UNKNOWN）
- [ ] 实施 AUTH
- [ ] 独立 Architecture 对实施切片 Pass（或 Pass with conditions 且残差有 disposition）
- [ ] Active Work Ready/Active cap 有空位（若实施时要进表）

未勾选的条目挡住 `Ready`。

### Exit Criteria（整项功能，非本切片）

- 合同行为在 26 键与九键、中英/数字/符号页可演示
- KeyboardTests / 相关 KeyboardCore 覆盖单击、擦除播放头、预编辑一次清光、气泡松手清空光标前、离开 bounds 结束
- 真机：Notes、微信、Safari、密码框、光标在中间、空框
- 浅色/深色；热路径不把输入内容写入日志或磁盘
- 独立 Architecture / Quality / Product Gate 各有结论

本切片 Exit：Assignment 记录存在且 Queued 指针可发现。

### Stop Conditions

- 需要读完整 host 文档或 `selectAll` 才能声称「删除全部」
- 删除全部误伤光标后
- 预编辑左滑上屏了剩余拼音
- 账本持久化或离开设备
- 在主 checkout / 脏树上改 Swift
- 把本 Pending 项写入 Active 十项表
- 未授 AUTH 就实施或发布

## Handoff

- Handoff Target: Human Product Owner（今日停在框架）；恢复时由 Product 指定 Executor 并开实施 AUTH，交 ⌨️ Keyboard Experience Maintainer
- Required Handoff Content: 本 Assignment、PD 合同、隔离 worktree 路径与分支名、未做的实施/审查/发布
- Revalidation Trigger: 改 Delete 优先级、Partial Commit restore、ADR 0007、删除键布局、或 Human 改口播放头/气泡/空框反馈

## History

- `2026-10-01 Asia/Shanghai`：Human 要求评估第三方「按住删除左右滑」；后续补单击松手、播放头、长按气泡、预编辑一次清光、看见才出气泡、离开键盘结束等合同。Human 授权起草 Assignment 并挂待办，今天不实施。Lifecycle → `Assignment Pending`。隔离 worktree `/private/tmp/universe-keyboard-delete-key-scrub-001`，分支 `grok/delete-key-scrub-001`。
- `2026-10-01 Asia/Shanghai`：Human 授权本切片文档 commit、push，必要时开 PR。不授权 merge、实施或 TestFlight。
- `2026-10-01 Asia/Shanghai`：隔离分支 docs commit `037e42ced1f208a08a0799382aebfebb78ae86dc`；[`AUTH-DELETE-KEY-SCRUB-001-COMMIT`](../authorizations/AUTH-DELETE-KEY-SCRUB-001-COMMIT.md) consumed。
