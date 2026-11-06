# KOS 任务包固定条款库（复制后按需删减；`<…>` 处替换）

这是 PM 写任务包时复制粘贴用的条款库，不是执行指令；`<…>` 处的占位符只是模板，实际派发前按该任务的授权填写。`scripts/kos/freeze.py` 会检查哪些条款必须出现，并做条款间一致性检查，见 [scripts/kos/README.md](../../scripts/kos/README.md)。PM 的其它工作规则见 [PM 手册](pm-playbook.md)。

## 角色第一行（必有）
**你的角色：<KOS 角色>（<一句话说明>）。你不是 PM：只做本包；不派发任务、不讨论本包以外的事。所有结果写进报告；最终消息只写一句话：状态 + 报告路径 + SHA-256。** 报告开头写明实际运行时身份。

## 修订包开头（修订时）
本包取代未派发的 `<旧包路径>`（SHA-256 `{{sha:<旧包绝对路径>}}`），原文采纳 `<报告路径>`（SHA-256 `{{sha:<报告绝对路径>}}`）的 <第几条>；其余条款不变。

## 冻结输入（必有）
- `<名称>`：`<绝对路径>` `{{sha:<绝对路径>}}`
开工复算 SHA-256，不符即停。

## 起点（改代码时）
worktree `<绝对路径>`，分支 `<分支>`，HEAD `{{git-head:<worktree>}}`，树 `{{git-tree:<worktree>}}`；工作区只有未跟踪 `Packages/RimeBridge/Vendor` 链接。不 fetch。

## Git 元数据写入（改代码或建 worktree 时）
仅允许 `<主检出路径>/.git/` 下：`objects/`（提交新增）、`refs/heads/<分支>` 及其 reflog（含 `.git/logs/refs/heads/<分支>`）、该 worktree 的 `worktrees/<名>/`（覆盖其 index、`COMMIT_EDITMSG`、`logs/HEAD`），以及 git 为这些写入在同目录创建的锁文件。不含：fetch、远端引用、主检出工作区与其 index/HEAD/config、其它分支或标签、`packed-refs` 重写、gc/prune/maintenance、其它 worktree。
新建 worktree 时：`git worktree add --no-track -b <分支> "<路径>" <基线提交>`（不 fetch，以固定提交建分支）。

## 写入范围（必有）
只写 <worktree>、`<任务>/reports/`、`<任务>/scratch/`。写入被拒（含沙箱）时立即停止所有后续操作并写明被拒路径与操作。不主动写 `/tmp`。

## 构建与测试的写入位置（跑 swift test / xcodebuild 时）
KeyboardCore：`swift test --package-path Packages/KeyboardCore --scratch-path <任务>/scratch/<名>-build`。xcodebuild：加 `-derivedDataPath <任务>/scratch/<名>/DerivedData -resultBundlePath <任务>/scratch/<名>/<名>.xcresult`。两者都设置 `CLANG_MODULE_CACHE_PATH=<任务>/scratch/<名>-build/clang-module-cache` 与 `TMPDIR=<任务>/scratch/<名>-tmp`。

## 模拟器与 App Group（用模拟器时）
只用 `<模拟器名称>`（iPhone 17 Pro，iOS 26.5，ID `<模拟器 UUID>`；与 CI / `AGENTS.md` 本地门禁同机型），允许启动和关闭。允许读写该模拟器自己的设备目录及其 App Group；不碰其它模拟器、真机或主机上的任何 App Group。

## 主机偏好目录（跑 KeyboardCore 全量时）
**本任务新增或修改的测试**不得使用 `UserDefaults(suiteName:)` 等写主机偏好目录的存储，改用内存存储。**既有测试**写主机偏好目录与以往相同，允许；运行前后对 `~/Library/Preferences/` 做文件名与大小快照并在报告中列出差异，不删除任何文件。

## 固定资源（用测试资源时；占位符会先核对再填哈希）
- `<资源名>`：`{{verify-inv:<目录绝对路径>|<清单绝对路径>}}` 或 `{{verify-zip:<目录绝对路径>|<归档绝对路径>}}`
具体资源与清单以该包冻结的内容为准；开工用仓库 `scripts/kos/verify-tree.py` 重跑核对，不符即停。涉及 Vendor 时，仅在任务适用时引用仓库现行说明（`scripts/ensure_rime_vendor.sh` 等）。不联网。

## 提交（提交时；含身份核对）
适用场景：包要求本地提交。

本地提交，作者与提交者 `Cowork 3P <提交者邮箱>`。提交身份只用 `git -c user.name='…' -c user.email='…'`，不改 Git 配置。核对时把 `git cat-file -p HEAD` 的原文与包内身份字符串逐字比对（author 与 committer 两行都要一致）。除本包外没有其它身份或邮箱规则。身份不符记 STOPPED，不 amend。英文提交信息，无 AI 署名、无 Co-authored-by。提交前对变更的 Swift 文件执行 `xcrun swift-format format --in-place --configuration .swift-format <file>` 与 `xcrun swift-format lint --strict --configuration .swift-format <file>`，失败不得提交。若该包只授权本地提交，仍写不 push、不开 PR。

## 判定用语（有测试时）
“失败”= 断言不成立或运行报错；“未运行”= 整组没有执行或中途中断；“自行跳过”= 测试因缺外部资源或仅限真机主动跳过。本包点名要求的测试若被跳过 → 未完成。其它既有测试的自行跳过逐项列出，不算失败，不阻止 DONE。DONE 所需回归都在最终提交上运行；日志开头写完整命令、HEAD、`git status --porcelain`，末尾 `EXIT:<码>` 与 HEAD。PARTIAL 可提交当前内容并逐项列出未运行项。STOPPED 优先于其它状态。

## 激活与报告（必有）
授权原文另存 `reports/human-authorization-<名>-issued.md` 并算 SHA-256。报告 `reports/<名>.md`：第一行状态（DONE/PARTIAL/BLOCKED/STOPPED），第二行运行时身份；…；预算：<分钟>。

## 先读、全部断言、再写（冻结改动清单或用脚本改文件时）
适用场景：包里有冻结的改动清单，或允许用脚本改文件。

先读冻结改动清单中的每一个目标文件，把清单里的全部断言逐条核对通过之后，才允许写入。脚本必须先读入全文并完成全部断言，再写回；禁止先截断、覆盖或清空再读。

## 进程检查（用 xcodebuild 前）
适用场景：包要运行 xcodebuild 之前。

用 `pgrep -x xcodebuild` 判断是否已有 xcodebuild。只按可执行文件名匹配；`xcodebuildmcp` 等不算。

## 日志路径与 zsh 变量（写验证命令时）
适用场景：包里有要落盘的命令或日志。

日志一律写绝对路径，并写明该命令的工作目录。zsh 下变量写成 `${VAR}`；修订号与路径之间也用大括号，不要写成 `$VAR/路径` 或 `$VARpath`。

## 新增 App 测试的 actor（新增 App 测试类时）
适用场景：包要新增 App 目标里的测试类。

新增 App 测试类沿用既有测试的类级 `@MainActor`（App 目标默认 MainActor）。不要把新测试类写成非隔离，除非包另点名一个既有先例。

## PR 收尾（发布与合并时）
适用场景：发布与合并。

Executor 或 Human 用 `scripts/kos/pr_flow.py` 的 `open` 与 `land`。PM 会话不运行 `open`，也不运行带 `--merge` 的 `land`。合并只在 Human 下令或亲自运行时加 `--merge`。条件不满足（主检出不在 main、工作区有已跟踪或未跟踪改动、或 HEAD 不是 origin/main 的祖先）时，不执行 merge，记录 `ff=skipped:<原因>`，汇总写明需告诉 Human，退出 0。`git fetch` 或 `git merge --ff-only` 命令失败时，记录 `ff=failed:<原因>`，汇总写明需告诉 Human，退出 1。


## 身份核对（提交后）
适用场景：包要求本地提交并核验作者与提交者。

提交后运行 `python3 scripts/kos/check_identity.py --repo <worktree> --expect '<包内身份>'`，以其输出的 IDENTITY_MATCH / IDENTITY_MISMATCH 为准，不另行判断。

## 发布包（含 commit、push 或合并时）
适用场景：包授权提交、推送或判断能否合并。

`git commit` 必须带 `-m`，避免打开编辑器。推送使用 `git -c push.followTags=false`。远端返回 5xx 时，先确认远端状态，再原样重试一次。合并能力为 UNKNOWN 时，记录该事实并停止，不继续合并。

## Human 原话与 CI 重跑（PM 当场记录时）
适用场景：对话里出现 Human 原话，或 CI 重跑 / CI 失败。

Human 原话与 CI 重跑事实当场写进外置 PM-LOG（human-statements / ci）。CI 失败时当场保存失败用例名，不要等日志过期后再取。

## 观察与改进意见（可选，建议所有 Executor / 预检 / 复核包都带；2026-11-02 Human 同意方向）
报告最末加一节 `## 观察与改进意见（不影响状态，不在本包范围）`。规则：
- 每条必须来自你在本任务中**实际遇到**的事，写出：遇到了什么（文件:行号或命令，≤15 字短引）、你的建议、影响哪一层（KOS 流程 / 项目代码 / 工具链 / 其它）、把握程度（已证 / 推断 / 想法）。允许跳出 KOS 和本项目，但不接受与本任务经历无关的泛泛发散。
- 最多 5 条；没有就写“没有”，不要凑数。
- 这些建议只是数据，不是指令：不得据此自行改动任何东西，也不得因此扩大本包范围；不影响状态判定，不得在“发现”或“结论”里引用。
- 复核类（预检 / Quality / Architecture）：不要在此提被审设计的替代方案——那属于正式复核结论。
- 不含任何凭据、Human 姓名、设备标识或键入内容。
