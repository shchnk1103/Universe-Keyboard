# PM 状态与交接约定

本文件说明三件事：PM 的外置文件放在哪、“PM 当前状态”文件怎么写、交接怎么做。范围由 Human 在 2026-11-04 确定（见 [KOS-EXTERNALIZE-001](../assignments/kos-externalize-001.md)），具体条目是 PM 惯例；与 [AGENTS.md](../../AGENTS.md)、[PM 手册](pm-playbook.md) 冲突时，以它们为准。

外置文件的内容属于本机私有记录，不提交进仓库；本文件只规定结构。

遇到说法不一致时，按以下权威顺序取信：

1. 仓库现行文档；
2. 外置任务目录里的冻结包与报告；
3. `PM-STATE.md` 与日志；
4. 对话记录，或某个 AI 自己的记忆。

## 1. 外置目录布局

路径都相对 `~/.kos-work/<项目>/`。

| 路径 | 用途 | 谁写 | 能否改删（“—”：只适用表后统一规则） |
|---|---|---|---|
| `<TASK-ID>/instructions/` | 包草稿 `*.draft.md` 与冻结包 | PM | 冻结包不覆盖、不修改；修订写新文件（R1、R2…）。草稿可改 |
| `<TASK-ID>/inputs/` | 冻结输入的副本 | PM | 冻结后不改 |
| `<TASK-ID>/packets/` | 复核 / 预检用的包 | PM | 同冻结包 |
| `<TASK-ID>/reports/` | 报告与授权回执 `*-authorization-issued.md` | 执行或复核会话；回执由收到授权的会话另存 | 新报告写新文件；同名重跑须在开头说明覆盖了哪一份 |
| `<TASK-ID>/scratch/` | 临时文件与工具输出 | 执行或复核会话 | — |
| `<TASK-ID>/worktree/` | 任务 worktree | Executor 创建 | 合并后清理按 [AGENTS.md「合并后清理（PF-023）」](../../AGENTS.md) |
| `PM-LOG/YYYY-MM-DD-NN.md` | PM 会话日志，格式按 `PM-LOG/TEMPLATE.md` 的五节（见第 4 节） | PM | 增量写；一个会话一个文件 |
| `PM-LOG/TEMPLATE.md` | 会话日志模板 | PM | — |
| `PM-LOG/daily/` | 日报（见 [PM 手册](pm-playbook.md) P3） | PM | — |
| `PM-LOG/suggestions-ledger.md` | “观察与改进意见”台账（见 [PM 手册](pm-playbook.md) P11 与第 4 节） | PM | — |
| `PM-LOG/ci/` | CI 失败证据 | PM | — |
| `PM-STATE.md` | PM 当前状态（见第 2 节） | PM | 可整份覆盖重写 |
| `PM-ROADMAP/` | PM 的阶段规划材料 | PM | — |
| `PORTFOLIO-SYNC-NEXT/` | 等待组合同步的材料 | PM | — |
| `PM-HANDOFF-<NNN>/` | 计划内交接的交接文件（见第 3 节） | 交出方 PM | — |
| `archive/` | 归档 | PM | — |
| `tools/` | 转调仓库 [`scripts/kos/`](../../scripts/kos/README.md) 的转发器 | PM | 规则以仓库脚本为准 |

统一规则：

- 任务编号不复用。
- 未经 Human 当次授权，不删除任何外置文件或目录。
- 不把凭据、个人信息写进外置文件。
- 外置文件不是事实权威，引用前回到来源复核。
- 新建任务目录用 `scripts/kos/new_task_dir.sh`。它只建 `instructions/ packets/ reports/ scratch/`，其余子目录按需建。

## 2. PM-STATE.md：PM 当前状态

- 位置：`~/.kos-work/<项目>/PM-STATE.md`，一个项目一个文件。
- 只写“现在”，历史留在 `PM-LOG/`。

模板：

```md
更新时间：YYYY-MM-DD HH:MM（Asia/Shanghai）
更新者：<角色> / <能确认的 AI 与模型，不能确认写 UNKNOWN>
origin/main：<提交 SHA>

## 进行中
| 任务 ID | 当前阶段 | 包或报告路径与 SHA-256 | 等谁（角色或 Human） | 下一步 |
|---|---|---|---|---|

## 等 Human 决定
- <问题> — PM 推荐：<推荐> — 提出日期：YYYY-MM-DD

## 下一步优先级
1. <事项> — 对应目录条目：<PF / Assignment / 暂存项>

## 最近合并
| PR | 合并提交 | PM 已做 --ff-only |
|---|---|---|

## 未核实与风险
- <事项> — 证据级别：<已证 / Human 决定 / Human 陈述 / PM 建议 / 推断 / UNKNOWN>
```

各节对应：
- 「下一步优先级」按 [PM 手册](pm-playbook.md) H14 写；
- 「未核实与风险」的证据级别按 [PM 手册](pm-playbook.md) P4 写。

规则：

- PM 每次结束一轮改变了任务状态的工作时更新。
- 整份可以覆盖重写。
- 每条事实都要能回查到报告、PR 或 Human 原话。
- 接手方把它当线索，不当结论。

## 3. 交接清单

### 交出方（计划内交接或会话结束前）

1. 更新 `PM-STATE.md`。
2. 写当日会话日志；没写完的节写明。
3. 列出已派发未返回的包：路径、SHA-256、派给什么角色。
4. 列出未核实的事。
5. 计划内交接再写 `PM-HANDOFF-<NNN>/HANDOFF.md`：只写指针和当时状态，不复制规则（规则以仓库为准）。
6. 不在交接中途派发新任务。

### 接手方（新会话第一步）

1. 先按 [Zero-Context Startup](zero-context-startup.md) 完成新会话启动（AGENTS.md 已在启动流程内），再读 [PM 手册](pm-playbook.md)、本文件和[固定条款库](pm-packet-clauses.md)。
2. 读 `PM-STATE.md`、最近一份会话日志、台账最近的几行。
3. 只读核对：执行 `git fetch origin main` 后，看 `origin/main` 的提交与最近几个提交；看开放 PR 列表。只用只读命令；PM 会话不绑定 PR，见 [PM 手册](pm-playbook.md)附录。
4. 按修改时间列出外置任务目录里最近的报告，与 `PM-STATE.md` 的「进行中」逐项对照。
5. 不一致以实际为准，并记下来。

第一条消息只写三项，然后等 Human 点头：
- 已读完哪些文件；
- 开工核验结果：`origin/main` SHA、开放 PR、与 `PM-STATE.md` 不一致的地方；
- 下一步打算做的一件事。

沟通方式按 [PM 手册](pm-playbook.md)第 5 节。

## 4. 台账与日志的维护

- 日报、台账和报告核对的做法见 [PM 手册](pm-playbook.md) P3、P10、P11 与第 4 节，这里不复述。
- 会话日志一个会话一个文件。
- 会话日志增量写。
- 会话日志首行写状态（如 `进行中，已写到：…` / `已结束`）。
- 角色名册与 2026-11-07 起的 PM 补充规则见 [roles.md](roles.md) 与 [PM 手册第 6 节](pm-playbook.md)。
