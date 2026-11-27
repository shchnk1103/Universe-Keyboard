# 4 档路由、部门池与直通（O129）

本文件是 4 档站点表、选人路由与直通条件的操作全文。绑定红线在 `AGENTS.md`：4 档不改变本地 CI、CI 分级与 Swift 格式硬门槛；只有 `feature` 必走设计 + 架构审查；`doc-light` 免预检、免独立复核；升降级只升不降；部门池实名领牌、禁止代领、子代理不占第二张牌。PM 操作摘要见 [pm-playbook.md](pm-playbook.md)。

## 部门池派发细节（O113 / O118 / O110）

- **部门池派发与实名领岗（O113）**：按部门池派发时，派发块只写部门名（如 `Executor（代码）部门`、`Quality 部门`、`Publish 部门`），不点名具体员工。部门全员名单与流转规则见外置 KOS 家目录 `KOS-ROLES-001/roles/ROSTER.md`（`KOS_HOME`，默认 `~/.kos-work/Universe-Keyboard`）。接单者开工前运行 `python3 <KOS_HOME>/tools/kos-board.py claim --role <部门> --task <TASK-ID>`，在排他锁下原子领取一个空闲牌；报告以领到的真实姓名署名，收尾以同一实名运行 `kos-board.py set <名字> idle <TASK-ID>`。严禁代领或冒用同部门同事名字。
- **子代理沿用父会话身份（O118）**：`claim` 与 `set ... idle` 仅由顶层主会话各执行一次；主会话派生的 `subagent` 沿用父会话已领取的员工身份开展工作，严禁重复运行 `claim` 或 `set ... idle` 占用第二张牌。
- **PM 状态表与轮询入口（O113）**：PM 回复中的并行状态表包含 `部门` 列；查返报统一通过外置 `kos-pm-poll.py`（及 `kos-report-lint` / 技能入口）完成，不逐会话私查。
- **Publish 排队兜底（O110）**：Publish 支持交回 `WAITING_CI`——托管 CI 连续 `queued` 超过 10 分钟时，Publish 可交回报告并释放看板；CI 恢复运行后重新领牌继续，不长期占牌等待。落实本条时可用仓库脚本 `scripts/kos/ci_watch.sh`（`--queued-limit-min` 默认 10 分钟，退出码 3 表示 `WAITING_CI`）。

## 直通接力开工领牌（O129）

`scripts/kos/kos_handoff.py` 的 `relay-exec` / `relay-quality` 两处直通已按部门池出块，只写部门名（Executor（代码）部门 / Executor（文档）部门 / Quality 部门），并附 `kos-board.py claim --role <code|doc|quality> --task <TASK-ID>`；前序参与者只出现在 `--exclude` 提示里，不再指定接班人。这两处直通不再调用 `kos-board.py pick`，也不以 `PICK [` 为出块门禁。

## 分级原则

- 任务按范围与风险进入 4 档流程。只有 `feature` 档必走设计 + 架构审查；`code-fix` / `doc-rule` / `doc-light` 按各自档位执行，`doc-light` 免预检、免独立复核。
- `doc-rule` / `code-fix` / `feature` 档涉及实现或要原样写入仓库文字的包，按档位经独立只读预检；`doc-light` 不进入预检站。
- 有独立复核站的档位按复核发现分级：仅文字的小问题发布前以小提交修正、只复核改动部分；代码 / 设计问题按整轮处理。
- 本节只分流协作站点，不改变 `AGENTS.md` 本地 CI 门禁、[CI 分级](../CI_CHANGE_CLASSIFICATION.md)、Swift 格式硬门槛与既有文档 / 测试 / CI 分类要求。Assignment 仍按 `docs/ASSIGNMENT_POLICY.md` 与 Human 2026-11-06 小任务口径处理，4 档不推翻该口径。

## 4 档任务流程与职责路由（Human 2026-11-14 批准）

依据 Human 2026-11-14「按你的建议定」及 `KOS-WORKFLOW-001` 设计稿 v1 / `human-decision-20261114.md`。箭头表示当前站 PASS / DONE 后进入下一站；`*` 为需要 Human 授权的站，脚本只出块，不自动越过。

| 档位 | 适用 | 站点 |
|---|---|---|
| `doc-light`（轻文档） | 仅改说明文字、台账；不碰规则、已冻结事实与对外文案 | `PM 写包 → 实现·文档 → PM 终审（链接门 / 机械核对）→ 发布* → 合并*`；免预检、免独立复核 |
| `doc-rule`（规则文档） | 改手册、`AGENTS.md`、KOS 规则、对外文案、隐私 / 官网 | `PM 写包 → 预检 → 实现·文档 → PM 终审 → 发布* → 合并*` |
| `code-fix`（小型代码修复） | 单个 PR；不碰数据格式 / 存储 / 同步 / 网络 / 权限 / 隐私承诺 / RIME 方案语义 | `PM 写包 → 预检 → 实现·代码（红测）→ 独立复核 → PM 终审 → 发布* → 真机(Human)* → 合并*` |
| `feature`（大型功能） | 多 PR、跨模块，或触及上述核心 / 语义边界 | `设计(Nick) → 架构审查(Alex) → PM 写包 → 预检 → 实现·代码 → 独立复核 → PM 终审 → 发布* → 真机(Human)* → 合并*`；架构审查 PASS 报告进入包冻结输入后，预检→实现 与 实现→独立复核 两处可 relay 直通 |

表内「设计(Nick)」「架构审查(Alex)」保留 Human 2026-11-14 批准原文。自 O125 起两人同属「架构 / 设计」部门池：两站仍都必须有人做且不自审，派发不预绑个人，按空闲与 `--exclude` 分配。本表不改批准原文。

另保留两类单站任务：**只读诊断**（只读 → PM）与**纯 Human 事务**（不过流程）。`code-fix` 档按 Human 决定在下一个新的代码缺陷任务试行，一个任务跑完前不转正；这保留当前试行边界，不推翻 2026-11-06 小任务口径。

## 两个已实操的子型（外置工具 code-fix 与 ops-approved 单站维护）

以下是近期实操中已跑通、随 O210 明确成文的两个子型。它们是 4 档主干上的特例，不推翻上表；红线全部不变：禁止未授权强删或 `--force`，写入被拒即停，冻结冲突即停。

### `code-fix`（外置 KOS 工具子型）

适用：修改外置 KOS 工具脚本（如 `~/.kos-work/Universe-Keyboard/tools/*.py`）等外置产物，且不涉及主仓库 Swift / CI / 规则文本的小修。站点序列：

`PM 写包 → 实现·代码（/tmp 隔离红测）→ 独立复核（Quality）→ PM 闭环`

- **免 `预检` 站、免 `发布/真机/合并` 站**：外置文件不入主仓库，无 push / PR 动作；包经 `kos-pm-next.py freeze-and-dispatch` 校验（含冻结 SHA 与互斥检查）后即可派发。
- 红测在 `/tmp` 等仓库外隔离目录进行，不写主检出。
- 一旦改动触及主仓库文件（Swift、`scripts/kos/`、`AGENTS.md`、`docs/**`），本子型不再适用，回到标准 `code-fix` / `doc-rule` / `feature` 档。

### 单站授权维护（`ops-approved`）

适用：清理 / 对齐 / 脱水等一次性维护动作。规则：

1. **不借用 `doc-light` 帽子**：维护动作与「仅改说明文字」是两类事，走本子型而非降档。
2. 任务包必须带 **`Human 预批准项`**（随 SHA 冻结），并优先附**只读盘点前置依据**（先盘点出对象清单与证据，再授权执行）。
3. 经 **1 站安全执行并回执**即闭环：执行者按包内对象清单操作，产出回执报告（对象、删前 SHA、检查结果、实际结果），交回 PM 终审。
4. 硬禁令不变：禁止未授权强删 / `--force`；任何删除命令失败或被拒立即停止整批并保留检查点；受保护对象豁免。

### 接力派发出块（O207 对齐方向）

接力 / 直通派发块统一由**顶层主会话**输出；派发块角色**固定写部门名**（如 `Executor（代码）部门`、`Quality 部门`），不点名具体员工，也不写中间人名字。子会话只按块内指引领牌开工，不自行出块、不重复领牌。

**通用站点转移**：PASS / DONE 进下一站；FAIL（预检 / 复核）回到写包者 PM 出 `-rN` 修订包，并原样交回同一位审查者复检；PARTIAL 交 PM 判断是否可继续；STOPPED / BLOCKED 升级 PM；同一站连续 FAIL 达 3 轮升级 Human。每站的 PASS 是该角色独立结论，不由流程脚本替代。

**升降级只升不降**：任一站发现范围超出当前档位时，在报告写「请求升档：<目标档>，理由…」，PM 按更重一档的剩余站点继续；拿不准时选更重一档。降档仅限 PM 或 Human 决定。

**选人路由与必填字段**：派发按职责而非固定 AI 品牌；同职责内优先选「空闲 + 最久未工作」（配合外置 `kos-board.py pick --role ...`），排除忙碌人员和存在独立性冲突的人员；无人空闲则写「无人空闲」并升级 PM，Human 可改派。执行包首部必须写明**包头档位**与**复核重点**（PM 最关心的 1–3 点）。其中 `scripts/kos/kos_handoff.py` 的 `relay-exec` / `relay-quality` 两处直通已改为 O129 部门池 + 开工领牌，不适用本段的 pick 选人，也不把人名写入派发块；`kos-board.py pick` 仅适用于仍走 pick 的路径（例如 `kos_handoff.py final` 的自动选下一站）。

**本轮未含范围**：设计稿第 6 节外部新工具 `kos-handoff.sh`、第 10 节的 `docs/kos/workflow-profiles.md` 与 KOS 家目录名册职责列不在本轮写入仓库，也不新增仓库脚本依赖。继续使用现行 `scripts/kos/kos_handoff.py`：`relay-exec` / `relay-quality` 按 O129 部门池 + `kos-board.py claim` 出块；`kos-board.py pick` 仍用于上述仍走 pick 的路径（例如 `final` 自动选下一站），并非已废弃。后续工具 / 名册改造须另包授权并经同样预检。

**执行者自主权（Human 2026-11-20 批准）**：执行者可自主使用 `subagent`、`herdr` 等工具完成任务，在报告如实写明是否使用；独立审查（预检 / 架构 / 质检）保持跨会话独立性声明不变。

**PM 职责边界与台账同步（Human 2026-11-20 批准）**：PM 只定目标、边界、不变量与验收门禁，具体技术实现交由架构 / 设计部门与代码执行者决定；合并后的 `PORTFOLIO.md` 与 `docs/releases/vX.Y.Z.md` 台账同步交由文档执行者处理。

4 档流程已同步固化为 `scripts/kos/kos_handoff.py` 的 `TIER_PROFILES`（`kos_handoff.py profile --grade <档位> [--action <relay-exec|relay-quality>]`）：`relay-exec` 允许 `doc-rule` / `code-fix`，`relay-quality` 允许 `code-fix`；`feature` 档架构审查 PASS 后放开两处 relay 直通（`relay-exec` 与 `relay-quality` 均强制复算冻结输入中 `arch-*` 报告的 SHA-256 与首行 PASS，缺项/篡改/非 PASS 一律 STOPPED 回 PM）；`doc-light` 严禁越级直通。工具子命令与该表同源校验。

## 协作约定中的低频条目

- 每日复盘（Human 2026-10-27）：当天确实做了工作时，总结当天遇到的问题和能纳入经验的举措；PM 用大白话说明当天做了什么。
- 会话归档（Human 2026-10-28）：会话被归档会断开 Remote Control，取消归档后不会自动恢复。
- 在链接 worktree 中提交、fetch 或 push 时，任务包点名允许写入的主检出 `.git` 路径（`worktrees/<名>/`、`objects/`、相关 refs 与 reflog）并列出排除项。
- 授权与派发消息保持简短，固定为：任务名、角色、包路径、SHA-256 与“授权，直接执行”；批准项写进任务包的“Human 预批准项”，随 SHA 冻结。
