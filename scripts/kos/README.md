# KOS 包生成与报告核对工具

这里的脚本给 KOS 的 PM 用：生成和冻结任务包，核对执行者交回的报告。任何 AI 接手 PM 角色时都可以直接使用。

## KOS 家目录约定

- 任务目录默认在 `~/.kos-work/<项目名>/<TASK-ID>/`，例如 `~/.kos-work/Universe-Keyboard/KOS-TOOLS-REPO-001/`。
- 每个任务目录有四个子目录：`instructions/`（包草稿与冻结包）、`reports/`（报告与授权回执）、`scratch/`（临时文件）、`packets/`（审阅包）。
- 环境变量 `KOS_HOME`（默认 `$HOME/.kos-work`）和 `KOS_PROJECT`（默认 `Universe-Keyboard`）**只对 `new_task_dir.sh` 生效**。其它脚本不读这两个变量：
  - `freeze.py`：路径都来自命令行和草稿里的绝对路径。`HOME` 只用于在派发块里把家目录显示成 `~`。
  - `check_report.py`：任务目录由报告路径推出（报告所在目录的上一级）。
- 依赖：Python 3（只用标准库）、Git（`freeze.py` 的 `git-*` 占位符，以及 `check_report.py`、`claim-check.py` 需要）、Bash（`new_task_dir.sh` 需要）。
- Python 脚本用 `python3 -B` 调用，不直接执行，只有 `new_task_dir.sh` 有可执行位。
- 相对路径的解析规则：
  - `freeze.py` 在自己所在目录查找 `verify-tree.py`，和 cwd 无关。
  - `check_report.py` 把报告里的相对路径依次相对任务目录、`reports/` 和 `--worktree` 解析。
  - `claim-check.py` 和 `verify-tree.py` 按 cwd 解析，所以建议一律传绝对路径。

下面的示例假设仓库在 `/Users/me/Dev/Universe Keyboard`，cwd 固定为该目录。

## new_task_dir.sh：新建任务目录

```bash
cd "/Users/me/Dev/Universe Keyboard"
bash scripts/kos/new_task_dir.sh KOS-EXAMPLE-001
KOS_HOME=/Users/me/kos KOS_PROJECT=Other bash scripts/kos/new_task_dir.sh KOS-EXAMPLE-001
```

- **何时用：** 开新任务时，在写包之前。
- **行为：** 在 `${KOS_HOME:-$HOME/.kos-work}/${KOS_PROJECT:-Universe-Keyboard}/<TASK-ID>/` 下建立四个子目录，并输出该目录的路径。
- **退出码：**
  - 目录已存在：退出 1，不覆盖。请换编号，或改写修订包（R1、R2…）。
  - TASK-ID 不是大写字母、数字和 `-`：退出 2。

## freeze.py：冻结任务包

```bash
cd "/Users/me/Dev/Universe Keyboard"
python3 -B scripts/kos/freeze.py /Users/me/.kos-work/Universe-Keyboard/T-001/instructions/x.draft.md /Users/me/.kos-work/Universe-Keyboard/T-001/instructions/task-package-x.md --title "T-001 实现" --role "Executor" [--forbid 旧名字 ...] [--requires-commit] [--readonly]
```

- **何时用：** 草稿写完，要交给 Human 派发之前。
- **输入：** 草稿里的哈希和资源身份都用占位符，不要手写。
  - `{{sha:/绝对路径}}`：替换为该文件的 SHA-256。
  - `{{verify-zip:/目录|/归档.zip}}`、`{{verify-inv:/目录|/清单.txt}}`：先用同目录的 `verify-tree.py` 核对，一致后替换为归档或清单的 SHA-256，不一致则失败。
  - `{{git-head:/worktree}}`、`{{git-tree:/worktree}}`：替换为该 worktree 的 HEAD 或 tree。
- **检查：** 固定条款是否齐全（角色行、“你不是 PM”、“最终消息只写一句话”、“写入被拒”、`/tmp`、授权回执另存、报告路径）。`--forbid` 列出的旧字符串不得残留。另有条款间一致性检查，报错以 `CONSISTENCY:` 开头：
  - 冻结输入只有文件名，没有绝对路径（写了“均位于 `/绝对目录/`”时不报）；
  - 禁止测试或构建，却要求 `run_lightweight_checks`，又没说明允许；
  - “停止”和 PARTIAL 出现在同一句；
  - “恰为 N 个文件”又允许 PARTIAL，却没有子集规则；
  - “不联网”与联网预批准并存（“联网只限……只读 `gh`”这种限定句不算冲突），或 HEAD 与 GET 混用；
  - 提到构建并在写入范围句限定“只写”（含“写入”或以“只写：”开头；`pgrep -x xcodebuild` 句不计为构建），却没给构建输出位置（`--readonly` 整包不报；某一句同时写了构建工具和“不运行”或“不启动”时，这一句不计入）；
  - 引用或采纳的报告（任意以 `/` 开头的绝对路径）没有哈希。
- **`--requires-commit`：** 还要有 `Cowork 3P <cowork-3p@localhost>`。包里有 `.swift` 路径时才要求 `lint --strict`（只有 `.swift-format` 或单独的 `.swift` 字样不算路径）。还要有 `docs/assignments/<名>.md`，或同一句在“无 Assignment”四字之后写了非空理由；只写 `docs/ASSIGNMENT_POLICY.md` 不算。
- **构建输出与“自行跳过”：** 非只读、且出现 `xcodebuild` / `swift test` / `模拟器`、又没有“不运行……构建与测试”或“不启动……设备”时，要求 `derivedDataPath`（或 `scratch-path` / `DerivedData`）和“自行跳过”。`--readonly` 不要求这两项。
- **输出：** 输出文件已存在就拒绝覆盖。成功时写出冻结包，打印其 SHA-256 和可直接粘贴的派发块。
- 固定条款库见 [`docs/kos/pm-packet-clauses.md`](../../docs/kos/pm-packet-clauses.md)，PM 工作规则见 [`docs/kos/pm-playbook.md`](../../docs/kos/pm-playbook.md)。

## check_report.py：核对返回的报告

```bash
cd "/Users/me/Dev/Universe Keyboard"
python3 -B scripts/kos/check_report.py /Users/me/.kos-work/Universe-Keyboard/T-001/reports/report.md [--worktree /Users/me/.kos-work/Universe-Keyboard/T-001/worktree] [--base <基线提交>]
```

- **何时用：** 报告交回后、向 Human 总结之前。
- **输出：**
  - 报告的状态行、身份行和 SHA-256；
  - 报告中成对出现的“路径 + SHA-256”逐项复算的结果（OK / MISMATCH / MISSING）；
  - 所引用 `.log` 的头部和 `EXIT:`、`HEAD:`；
  - 给了 `--worktree` 时：HEAD、tree、status，以及自 `--base` 起每个提交的身份；
  - skip 行；
  - “观察与改进意见”原文。
- **找不到报告时：** 列出 `reports/` 最近修改的文件。
- 结果“全部一致”只说明引用的文件对得上，不说明报告内容正确。

## claim-check.py：文档事实来源检查

```bash
cd "/Users/me/Dev/Universe Keyboard"
python3 -B scripts/kos/claim-check.py [--recomputed-hashes /绝对路径/已复算哈希.txt] "/Users/me/Dev/Universe Keyboard" <BASE> <HEAD> /绝对路径/来源1.md [/绝对路径/来源2 ...]
```

- **何时用：** 涉及事实的文档改动送审之前。
- **输出：**
  - 新增行里的 SHA、PR 号、编号、日期、数字加单位，在来源和基线文件里都找不到的项；
  - 含因果或定性词的新增行，需要人工确认证据等级；
  - Markdown 表格列数与表头不符的行。
- 这个检查不证明结论为真。
- `--recomputed-hashes` 默认关闭，不改变 `REPO BASE HEAD SOURCE` 的位置。文件每行一枚 64 位十六进制；这些哈希不再报“缺来源”（文件自身的 SHA 常如此）。

## verify-tree.py：目录与清单或归档对照

```bash
cd "/Users/me/Dev/Universe Keyboard"
python3 -B scripts/kos/verify-tree.py /绝对路径/目录 --inventory /绝对路径/清单.txt
python3 -B scripts/kos/verify-tree.py /绝对路径/目录 --zip /绝对路径/归档.zip
```

- **何时用：** 核对资源身份时。`freeze.py` 的 `verify-*` 占位符也会调用它。
- **输入：** 清单每行格式为 `<sha256>  <相对路径>`。
- **退出码：** 文件集合与每个哈希都一致，并且没有符号链接时退出 0，否则退出 1，并打印缺失、多余和不一致的文件。

## pr_flow.py：推送开 PR，以及等待 CI（可选合并）

```bash
cd "/Users/me/Dev/Universe Keyboard"
python3 -B scripts/kos/pr_flow.py open --worktree <dir> --branch <name> --base-sha <sha> --expect-head <sha> --files <清单> --title <标题> --body-file <正文> [--dry-run]
python3 -B scripts/kos/pr_flow.py land <PR号> --expect-head <sha> --main-checkout <主检出> --pm-log <PM-LOG> --log-dir <目录> [--merge] [--dry-run]
```

- **何时用：** Executor 或 Human 做发布收尾。PM 会话不运行 `open`，也不运行带 `--merge` 的 `land`。合并只在 Human 下令或亲自运行时加 `--merge`。
- **`open`：** 核对 HEAD、工作区、提交身份、改动文件集合、正文署名和远端分支不存在。全部通过才推送（不 force、不 `-u`），然后 `gh pr create`。`--dry-run` 只核对。推送返回 5xx 或 `remote rejected` 时，确认远端分支仍不存在再原样重试一次。
- **`land`：** 确认 PR 为 OPEN 且 head 不变，然后 `gh pr checks --watch`。失败日志里的用例若都在 `known-flaky.txt`，且已重跑次数小于 `--max-reruns`（默认 1），才 `gh run rerun --failed` 一次。全绿且给了 `--merge` 才合并。条件不满足（主检出不在 main、工作区有已跟踪或未跟踪改动、或 HEAD 不是 origin/main 的祖先）时，不执行 merge，记录 `ff=skipped:<原因>`，汇总写明需告诉 Human，退出 0。`git fetch` 或 `git merge --ff-only` 命令失败时，记录 `ff=failed:<原因>`，汇总写明需告诉 Human，退出 1。`--dry-run` 只做只读的 `gh pr view`。
- **退出码：** 0 表示核对通过、或按策略完成等待 / 合并；1 表示某项核对或策略要求停止；2 表示参数错误。
- 已知偶发清单是同目录的 [`known-flaky.txt`](known-flaky.txt)。

## tests：脚本行为测试

`scripts/kos/tests/` 用 Python 标准库 `unittest` 覆盖 `freeze.py` 与 `pr_flow.py`。`pr_flow` 的测试注入命令执行器，不访问网络。夹具在 `scripts/kos/tests/fixtures/`。

```bash
cd "/Users/me/Dev/Universe Keyboard"
PYTHONDONTWRITEBYTECODE=1 python3 -I -B -m unittest discover -s scripts/kos/tests -v
```

## 来源与同步

这些脚本原先位于 PM 本机的技能目录（`~/.claude/skills/kos-packet-author/`、`~/.claude/skills/kos-report-check/`）和 `~/.kos-work/Universe-Keyboard/tools/`。仓库内的这一份是权威来源，本机技能目录只应转调这里。测试见 [`../ci/tests/test_kos_tools.py`](../ci/tests/test_kos_tools.py)。
