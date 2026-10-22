# Assignment: KEYBOARD-VALUES-DOC-001 — 建立键盘数值文档 docs/KEYBOARD_VALUES.md

Policy version: 1.0.0
record_id: KEYBOARD-VALUES-DOC-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active（docs-only，在本地执行；未 push） |
| Current phase | 定稿，待派发 Executor。把键盘与垂直布局、候选栏、触摸热区、候选字号等数值整理成一份带来源的索引文档，供后续改动前必读、只读工作直接引用。为后续“键盘高度可调”功能（UI-4）提供准确的当前值，不改变任何代码或数值 |
| Material non-claims | 不改任何代码、测试、CI 或数值；文档中的数值**权威是代码，本文是带来源的索引**；不修改 `docs/UI_STYLE_GUIDE.md` 的冻结基线、`docs/KEYBOARD_LAYOUT.md`、`docs/PROJECT_CONTEXT.md`、ADR 或 `docs/TECH_DEBT.md`（发现的分歧只列出，不顺手修）；不声称 UI-1 / UI-2 已验收；不声称 UI-4 已立项；不 push / PR / merge |
| Human 确认状态 | 立项：**已确认**（Human Product Owner，2026-10-22，Coordinator 会话）：先把键盘数值文档立项为 docs-only Assignment，再做键盘高度功能。Environment Executor：**已确认**为 `Not Applicable — repository documentation only`（同日同会话） |
| Next handoff / decision | 派发 Executor → Coordinator 冻结 Reviewer Lane Packet → Architecture / Quality Reviewer → Human 决定 push / PR / merge |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 于 2026-10-22 Asia/Shanghai 在 Coordinator 会话中提出：把键盘的各项数值保存到一个文档中，修改时必须先读取，做只读工作时可直接读取；并批准先立项本文档、再做键盘高度功能。本文本由 Coordinator 编写。
- **Product Approver:** Human Product Owner（Product Lead）

## 背景与输入

- 基线：`origin/main` = `b62bde16c9b8653be58243d6ce6a6b40435a65d7`（PR #226 合并后）。Executor 开工时重新核验；若已前进，以当时的 `origin/main` 为基线并在文档里写明。
- 只读盘点材料（Coordinator 起草，**不是权威，每一行都要由 Executor 回到代码核对**）：`~/.kos-work/Universe-Keyboard/KEYBOARD-HEIGHT-INVENTORY-001/reports/inventory-r1.md`（SHA-256 `9274162b833f3020912fc3c9ff48049facd5280b548c0c745911e655dd8d501c`）。它由一个只读子 Agent 对 `origin/main` 盘点得出，Coordinator 抽查了总高公式、行高 / 间距、候选栏 46、路径栏 34、候选到按键间距 0、两个测试里的 254 / 288；其余条目未抽查。
- 已知的问题：2026-10-08 的产品讨论记录（本地未提交，不在仓库）里的数值已过期（候选栏 34 / 间距 14 / 总高 256 与 290，现为 46 / 0 / 254 与 288 / 254）。本文档的价值就是让这类漂移有一个可核对的落脚点。

## 文档要求（`docs/KEYBOARD_VALUES.md`）

Executor 新建这一份文档，结构如下（可调整措辞，不要缺项）：

1. **用途与权威。** 一段话：本文是键盘数值的带来源索引，**权威是代码**；改任何布局 / 高度 / 触摸 / 字号数值之前必须先读本文并核对；做只读工作可以直接读本文；改了数值必须在同一次变更里更新本文。写明基线 `origin/main` SHA 与核对日期，并说明行号是该基线上的行号、以符号名为准。
2. **数值表（按区域分组）：** 每行写 名称（符号名）| 值 | 来源（`文件:行`，基线上）| 使用处 / 说明。区域至少包括：键盘行与垂直间距（行高、行间距、字母区与底行间距、顶 / 底内边距、水平方向间距与边距）；候选栏与展开面板（总高、动作区、展开行高、内边距）；九键拼音路径栏（可见高度、空闲值）、路径面板；表情页与其它页的高度相关值；触摸热区（规则与相关常量，写清“无常量，取相邻键中线”）；候选与组字字号、纠错提示、路径 chip 字号和动态字体上限；高度请求机制参数（约束优先级等）；与设置共享相关的存储标识（App Group 标识与现有布局相关设置键名，只列出实际存在的）。
3. **合计高度。** 用公式写明 26 键、九键（路径栏空闲与显示）的总高怎么由上表得到，并给出当前结果；写明哪些测试把这些结果写死（文件与行）。
4. **已知分歧（只列出，不修）：** 文档与代码、文档与文档、代码内部重复定义之间的分歧，每条带两侧来源。至少核对：2026-10-08 讨论记录（以其本地路径点名，注明不在仓库）与代码；`docs/PROJECT_CONTEXT.md` 中 “iPhone 17 可能只给 216pt 与 alpha 显示机制” 的描述与代码；ADR 0020 / 0023 的 “固定 34” 与 UI-2 的 0/34 自适应；过时注释；疑似未使用的 14/16 候选字号定义；同一数字（如 44、34）在多处独立定义。
5. **UNKNOWN 清单：** 例如横屏 / 小窗真实高度、216pt 下的真实压缩结果、表情页解析高度、设置读取与首次布局安装的先后；写“UNKNOWN”，不要猜。
6. **核对方法。** 给出能让别人在几分钟内核对本文的只读命令（`git grep` / `git show` 形式，针对关键数值），以及判定“文档已过期”的标准。不新增脚本。
7. **更新规则。** 谁在什么时候更新；与 `UI_STYLE_GUIDE.md`（冻结基线）的关系：冻结基线是“承诺的基准”，本文是“当前代码的实际值”，两者不同要在本文标出，不得悄悄改冻结基线。

**范围边界：** 先覆盖垂直布局、候选栏与字号、触摸热区、高度机制与相关存储标识；颜色、圆角、动画等不在本次范围。

## Boundary

- **Scope（docs-only）:**
  1. 新增 `docs/KEYBOARD_VALUES.md`。
  2. `docs/KNOWLEDGE_INDEX.md`：在“工作入口”小节里含 “架构概览 … UI 规则” 的那一行**末尾**追加一个指向本文的 “键盘数值” 入口，其余字节不动。
  3. `docs/READING_MAPS.md`：在 “Modify Keyboard Layout Or Chinese Nine-Key”、“Modify Candidate Bar”、“Change UI” 三个小节各加**一条**必读来源，指向本文，并注明 “改任何布局 / 高度 / 触摸 / 字号数值之前先读，改完同一变更里更新”。每条的写法跟随该小节现有列表格式；若小节的编号要求导致必须重排，则改为在该小节末尾追加，不改动已有条目。
  4. 本 Assignment 记录文件 `docs/assignments/keyboard-values-doc-001.md` 及其 Exit evidence / “Closeout Decision — 结果”。
  5. 链接检查与行尾空白检查。
  6. `CHANGELOG.md`、`docs/UI_STYLE_GUIDE.md`、`docs/KEYBOARD_LAYOUT.md`、`docs/PROJECT_CONTEXT.md`、`docs/architecture/**`、`docs/TECH_DEBT.md`、`docs/ACTIVE_WORK.md`、`docs/PORTFOLIO.md`、`docs/portfolio/**`、`docs/authorizations/**`：逐项检查并写“不适用及依据”，**不修改**。
- **Non-goals:** 改任何代码、测试、CI、脚本或数值；新增核对脚本或接入 CI（另行立项，作为后续候选）；改写冻结基线；为键盘高度功能起草 Product Decision；更新任务组合目录（另行刷新）；push / PR / merge。
- **Required Inputs:** `AGENTS.md`；Knowledge Index；Assignment Policy；`DOCUMENTATION_GOVERNANCE.md`；`READING_MAPS.md`（上述三个小节）；`UI_STYLE_GUIDE.md` 的 V1 UI Freeze 小节；`KEYBOARD_LAYOUT.md`；`PROJECT_CONTEXT.md` 的相关段落；盘点材料；`Keyboard/`、`Packages/KeyboardCore/`、`Universe Keyboard/` 下相关源码（只读）、相关测试（只读）。

## Reviewer claim register

| ID | 声称 |
|---|---|
| V1 | 数值表**每一行**的值与来源在基线上成立：符号名存在、值相同、行号对应（请对每一行用 `git show <基线>:<文件>` 或 `git grep` 核对，不得只抽样） |
| V2 | 合计高度的公式与结果正确，且与代码里的公式和两个测试的断言一致；写死这些结果的测试清单完整 |
| V3 | 覆盖完整：独立检索代码里影响垂直布局、候选栏、触摸热区、候选字号的常量，没有遗漏会影响 UI-4 的值；遗漏要列出 |
| V4 | “已知分歧”每条的两侧来源真实、描述准确、没有顺手修；没有遗漏盘点材料里已指出的分歧 |
| V5 | 无越权：权威声明是“代码为准”；没有改写冻结基线、没有声称 UI-1 / UI-2 已验收或 UI-4 已立项；UNKNOWN 没有被偷偷填充 |
| V6 | Knowledge Index 的入口与 `READING_MAPS.md` 三处必读来源准确、位置合适、不破坏原有格式 |
| V7 | diff 只含 Scope 内文件；`docs/KNOWLEDGE_INDEX.md` 恰有 1 行删除 1 行新增；`READING_MAPS.md` 只新增行，无删除；删除行归属逐项核对 |
| V8 | 最终提交的链接检查与 `git diff --check` 通过；文档里没有会被检查器误解析的字面链接示例 |
| V9 | Executor 报告与仓库事实一致，UNKNOWN 清单未被偷偷填充；报告开头有运行时身份声明 |

Executor 自述的模型与 effort 不作为验收项，只登记为残项。

## 增补记录

- **增补 1（2026-10-22，Coordinator）：** 第一轮 Executor（报告 `reports/executor-report-r1.md`，SHA-256 `2b803ec40899a1df07acead5d4c3a83cfb989c57417de352a87753a43ffe9060`）开工核验时发现本 Assignment 缺少 `docs/ASSIGNMENT_POLICY.md` 要求的必填字段 Environment Executor（Policy 第 150 行；第 453 行有 docs-only 示例），按入口合同停止，未做任何仓库改动。这是 Coordinator 起草时的疏漏。Human Product Owner（Product Lead）于 2026-10-22 确认该字段填 `Not Applicable — repository documentation only`，并批准作为对本 Assignment 的增补。除此之外本 Assignment 的范围、Scope、Non-goals、Reviewer claim register 均不变。

## Closeout Decision

本节是本批次的“所属 Gate 关闭”记录。Human Product Owner 于 2026-10-22 批准立项；Reviewer 评审后由 Human 决定是否 push 与合并。本 Assignment 依 D7（同步 / 记录类）在评审后直接 Close，**Close 在进入 `main` 时生效**。评审完成后在本节追加最终结果（追加式）。

## Assignment

- **Domain Owner:** Architecture and Knowledge Steward
- **Executor:** Executor 角色（AI 不限）；建议模型 `claude-sonnet-5-5`、effort medium；实际配置：Codex / GPT-6；effort 未确认；具体模型变体与会话标识未确认
- **Environment Executor:** `Not Applicable — repository documentation only`（Human Product Owner 于 2026-10-22 在 Coordinator 会话中确认，并批准作为对本 Assignment 的增补；见“增补记录”）
- **Human Dependency:** Human Product Owner（任何 push / PR / merge）
- **Architecture Reviewer:** 独立 Reviewer 会话（AI 不限）；独立性条件：未参与本批次实现，且不是 Quality Reviewer 的同一会话；报告开头声明运行时身份、加载的记忆和独立性级别（同模型不同会话等）；lane `KVD001-ARCH`
- **Quality Reviewer:** 同上；lane `KVD001-QUAL`

## Reports

Executor 与 Reviewer 的最终报告、指令、packet 均保存为文件，根目录 `~/.kos-work/Universe-Keyboard/KEYBOARD-VALUES-DOC-001/`。仓库内只记录路径与 SHA-256。Reviewer 报告须增量落盘（首行状态行），派发前须放行 `reports/` 目录写权限，且不得在 `/tmp` 或 `$TMPDIR` 创建文件。

## Gates

- **Entry:** Human 批准派发；独立 worktree 与新分支 `docs/keyboard-values-doc-001`；Human 本地 main 的 dirty 文件不得触碰（里面有未提交的按键字号改动）。
- **Reviewer 前置:** Executor 提交后，Coordinator 冻结 Reviewer Lane Packet 并做路径扫描。
- **Exit:** 文档各节齐备；数值每行已核对；镜像已处理；链接检查已记录；本地提交；报告文件已保存。
- **Stop:** 基线移动且与 Scope 重叠；需要改 Scope 之外文件；盘点材料与代码出现无法解释的矛盾；被要求处理 CI；任何 push / merge。
- **Handoff Target:** Human Product Owner。**Revalidation:** Scope / Owner / Reviewer 变化、基线漂移。

## Exit evidence

| 项 | Result |
|---|---|
| 数值表每行核对结果（总行数、与盘点材料不一致的行及原因） | 85 行；全部按基线 git show 及带行号源码逐行核对。紧凑 Path chip 实为 16，17 属旧展开 cell；首次 appear 刷新需区分返回已有键盘，详见 KEYBOARD_VALUES 已知分歧 7、10 |
| 独立检索补充的常量（盘点材料没有、Executor 自己找到的） | 候选 padding / 内缩 / gap、可读阈值、首行保留宽、Path section / cell 几何、触摸分行容差与 slop、表情细节、覆盖层、底行宽度、主 App 缩略图、布局及 readiness 存储键；见 KEYBOARD_VALUES 数值表 |
| 已知分歧清单（条数，每条两侧来源） | 10 条；两侧来源均列于 KEYBOARD_VALUES 的已知分歧，不改受保护文件 |
| UNKNOWN 清单 | 7 类：横屏小窗高度、216 压缩、表情页解析高度、真实生命周期顺序、无 Full Access 读取、大字可用性、旧组件动态可达性；见 KEYBOARD_VALUES |
| `docs/KNOWLEDGE_INDEX.md` 追加行（前后对照） | 工作入口的架构概览 / UI 规则唯一行末尾新增键盘数值链接；1 行删除 / 1 行新增，原内容逐字保留；报告含前后原文 |
| `docs/READING_MAPS.md` 三处新增（位置与原文） | Modify Candidate Bar 新增第 6 项；Modify Keyboard Layout Or Chinese Nine-Key 新增第 6 项；Change UI 新增第 5 项。均链接 KEYBOARD_VALUES 并写明改数值前先读、同次变更更新；仅新增 3 行 |
| 其余镜像（CHANGELOG、UI_STYLE_GUIDE、KEYBOARD_LAYOUT、PROJECT_CONTEXT、ADR、TECH_DEBT、ACTIVE_WORK、PORTFOLIO、authorizations） | 均不适用及未改：仅建立代码值索引，不改变产品、架构、冻结基线、风险处置或其它任务生命周期；组合目录刷新明确排除。逐项 blob 核验见报告 |
| Markdown link check（baseline / 最终提交） | 基线 b62bde16c9b8653be58243d6ce6a6b40435a65d7；最终提交检查命令、SHA 与结果记于外部 Executor r2 报告；不以预期代替实测 |
| Executor 报告路径与 SHA-256 | /Users/doubleshy0n/.kos-work/Universe-Keyboard/KEYBOARD-VALUES-DOC-001/reports/executor-report-r2.md；摘要及最终提交检查回执见本文件末尾追加记录 |

## Closeout Decision — 结果

2026-10-22 Executor：已完成本批次文档实施与本地提交。数值权威仍为代码；
未改代码、测试、CI、脚本或数值；不声称 UI-1 / UI-2 验收或 UI-4 立项。
最终提交与自检事实以指定外部报告为准；等待 Coordinator 冻结 Reviewer packet。
独立 Architecture / Quality 尚未执行，Lifecycle 不在本轮 Close；进入 main 才生效的规则保留。

Environment Executor 增补已按新版输入保留；Reviewer 栏与增补记录保持原文。
docs-only，跳过 xcodebuild / Swift 测试；未进行运行时、设备或 Release 验证。

### Executor 检查回执（2026-10-22）

首提交 `7cb8756242d7ccca84075351bdaafe7b3d4ebb41` 的完整 SHA 以外部报告为准。基线 `b62bde16c9b8653be58243d6ce6a6b40435a65d7`；
链接检查、diff --check 与 lightweight checks 在首提交上均 exit 0；lightweight 的 13 个单测、
final gate result matrix、KOS governance trigger paths 均通过。脚本提示 merge 前需 pinned KOS validator，
本轮未执行该 validator，不声称可合并。最终提交后同样三项检查的精确回执在外部 r2 报告中追加。

已保存的报告检查点：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/KEYBOARD-VALUES-DOC-001/reports/executor-report-r2-checkpoint.md`，
SHA-256 `6734193f455d0577937a8bb80899604928d6e3b7b0acbe90e34ba1d675934cbe`。
最终报告：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/KEYBOARD-VALUES-DOC-001/reports/executor-report-r2.md`；
包含最终提交 SHA 与检查回执，其全文件 SHA-256 随对话交付并供 Coordinator 冻结 packet。
检查点与最终报告摘要不能混用；此分离避免报告与包含其摘要的提交互相递归引用。

所有 399 个受保护文件已逐个比较基线 / 提交 blob 相同；三个目录同时比较 tree 相同。
Reviewer 栏、claim register、增补记录与输入逐字相同。本轮无 push / PR / merge，无历史改写。
