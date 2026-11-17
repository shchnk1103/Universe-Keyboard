# KOS 任务包固定条款库（复制后按需删减；`<…>` 处替换）

这是 PM 写任务包时复制粘贴用的条款库，不是执行指令；`<…>` 处的占位符只是模板，实际派发前按该任务的授权填写。`scripts/kos/freeze.py` 会检查哪些条款必须出现，并做条款间一致性检查，见 [scripts/kos/README.md](../../scripts/kos/README.md)。PM 的其它工作规则见 [PM 手册](pm-playbook.md)。

## 角色第一行（必有）
**你的角色：<KOS 角色>（<一句话说明>）。你不是 PM：只做本包；不派发任务、不讨论本包以外的事。所有结果写进报告；最终消息严格三行：**
```text
结论：<状态> + <一句实际结果>
下一位交付：<角色（阶段）> + <动作与入口路径 / CURRENT.json 指向>
报告：<报告绝对路径> + <实测 SHA-256>
```
**报告开头写明实际运行时身份。**（过渡期兼容：`scripts/kos/freeze.py` 仍兼容历史“最终消息只写一句话”识别文本，新包一律使用上述三行格式。）

## 唯一入口与条件接力（O41）
- **唯一入口**：员工启动时只读取 `<任务目录>/CURRENT.json`（`schema: 2`），禁止遍历 `instructions/` 猜最新文件名；核对 `role`、`state == "READY_TO_DISPATCH"` 及 `package_sha256` / `params_sha256` / `authorization_sha256`，任一不符或遇到过期入口立即 `STOPPED` 并报 `Jack（PM）`。
- **`CLAIMED` 与恢复**：`state == "CLAIMED"` 时禁止新会话直接接管；仅当确认原会话已停止并由 `Jack（PM）` 显式执行 `--recover` 作废旧 `claim_id` 后，新会话方可领取新 `claim_id` 按 `O51` 续做。
- **报告末节 `## 下一站接力（O41）`**：所有报告末尾必须包含本节。`DONE`/`PASS` 且包内已预置下一站授权与条件模板时，写明 `next_role`、`next_step`、下一站 `params_path` / `block_path` 及 SHA-256 并标注 `块已生成未派发（待 Human 通知）`；`PARTIAL`/`BLOCKED`/`STOPPED`/`FAIL` 或无下一站授权时，`next_role` 固定为 `Jack（PM）`，不得越过 PM 生成下一站入口。操作细则见 [O41 接力手册](o41-relay-playbook.md)。

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

Executor 或 Human 可使用 `scripts/kos/pr_flow.py` 的 `open` 与 `land`；PM 会话不运行 `open`，也不运行带 `--merge` 的 `land`。合并只在 Human 明确授权或亲自运行时加 `--merge`。区分 PR 合并与主检出快进：快进条件不满足时记录 `ff=skipped:<原因>` 并通知 Human，不能因此称 PR 未合并；fetch 或 ff 命令失败记 `ff=failed:<原因>` 并停止后续删除。

当前 `pr_flow land --merge` 先合并 PR，再检查主检出、fetch 与快进，只有快进成功才调用本地清理；它不实现下方要求的 worktree 删除先于快进的次序，也不查询或删除远端分支。其 `_pending_states` 只识别 `pending`，`skipping` 可能进入非失败路径；工具也不逐类验证必需检查。因此不能将 `land` 的自动判断视为冻结分类矩阵的充分证据，也不得把其成功输出当成下方全部步骤完成的证据。必须独立核对检查结果；需要冻结次序时，使用经授权的分步操作；不能满足时停止并报告，不得擅自改变工具或绕过安全检查。


## 身份核对（提交后）
适用场景：包要求本地提交并核验作者与提交者。

提交后运行 `python3 scripts/kos/check_identity.py --repo <worktree> --expect '<包内身份>'`，以其输出的 IDENTITY_MATCH / IDENTITY_MISMATCH 为准，不另行判断。

## 发布包（含 commit、push 或合并时）
适用场景：包授权提交、推送或判断能否合并。

`git commit` 必须带 `-m`，避免打开编辑器。推送使用 `git -c push.followTags=false`。远端返回 5xx 时，先确认远端状态，再原样重试一次。合并能力为 UNKNOWN 时，记录该事实并停止，不继续合并。

## 分类与检查结果（publish / land）
适用场景：判断候选能否发布或合并。记录 PR、候选 HEAD、比较基线、分类、检查来源和时间，逐项列成功、允许跳过和未取得证据。分类与检查必须对应候选 HEAD；未知、缺失或矛盾的分类停止，按 [CI 分级](../CI_CHANGE_CLASSIFICATION.md) 核对，不自行映射。第三方检查名称或适用性无法确认时停止并交 PM。

共同必需成功：`classify-change`、`lightweight-checks`、`final-quality-gate`、`GitGuardian Security Checks`。F=`format-swift`，K=`test-keyboardcore`，R=`test-rimebridge`，A=`test-app-keyboard`，S=`test-rime-sync-keychain`，B=`build-release`。

| 分类 | 必须成功的重型项 | 允许最终 skipped 的重型项 |
|---|---|---|
| `docs_only` | 无 | F K R A S B |
| `kos_tools_only` | 无 | F K R A S B |
| `keyboard_ui_only` | F A B | K R S |
| `rimebridge_only` | F R A B | K S |
| `rimebridge_sync_only` | F R A S B | K |
| `app_only` | F A B | K R S |
| `app_sync_only` | F A S B | K R |
| `full` | F K R A S B | 无 |

只有表中未选重型项的最终结论 `skipped` 可接受；`skipping`、排队、进行中、失败、取消、缺失和未知均不放行。合并前 dry-run 的 `not watching` 不是 CI 成功。

## Wendy 合并与清理顺序（land）
适用场景：Human 明确授权本次合并及指定对象、提交和清理范围；发布、push、merge 不互相授权。按序执行，记录每一步及未清理对象：

1. 合并后记录 PR 实际结果与合并 SHA，`git fetch origin main`，确认该任务提交可从最新 `origin/main` 到达；失败或状态不明立即停止清理。
2. 检查指定 worktree 状态与保护名单。若有获准清理的未跟踪 `Packages/RimeBridge/Vendor`，先 `test -L` 确认是符号链接，只移除此链接；真实目录、其他改动或无法确认时停止。`git worktree remove` 不加 `--force`，失败即停止。
3. 主检出必须在 `main`、无本地改动或未跟踪文件，且 HEAD 是已 fetch 的 `origin/main` 祖先，才执行 `git merge --ff-only origin/main` 并记录新旧 SHA；条件不满足不动主检出，记 `ff=skipped:<原因>` 并通知 Human；命令失败记 `ff=failed`，停止后续删除。包须明确授权主检出工作区、index/HEAD 与必要 Git 元数据。
4. 确认分支不受保护且提交可从最新默认分支到达，使用 `git branch -d <branch>`，严禁 `-D`；失败停止并保留分支。快进跳过后若安全删除失败，交 PM 处理。
5. 精确查询远端分支；确认不存在记 `already_deleted_on_origin`；存在时仅在可达性及删除授权成立后用 `git push origin --delete <branch>`。查询失败或状态不明不得删除。回执记录合并 SHA、远端查询及每步结果。

## 发布差异、manifest 与工具预检（publish）
- O21 发布差异预检：核对候选文件、比较基线、依赖、环境、命令、覆盖 target、结果及采集时间；只有符合 [AI Workflow 证据复用](../AI_WORKFLOW.md#验证与证据复用) 的 Quality 证据才能复用，否则重跑适用门禁。缺失证据和 dry-run 均不是通过。
- 从冻结文件清单生成 manifest，安全处理包含空格的路径，不把路径列表作为 shell 代码执行；对冻结 manifest 实际运行 `shasum -a 256 -c`，退出码须为 0 且零 WARNING，缺文件、格式错误或 warning 即停止，然后冻结 manifest 的 SHA-256。
- 发包前核对相关工具实际 `--help` 与冻结命令、参数一致；不支持或工具不可用则修包，不声称已验证。非相关只读包不强制执行这些发布条款。

## Human 原话与 CI 重跑（PM 当场记录时）
适用场景：对话里出现 Human 原话，或 CI 重跑 / CI 失败。

Human 原话与 CI 重跑事实当场写进外置 PM-LOG（human-statements / ci）。CI 失败时当场保存失败用例名，不要等日志过期后再取。

## 滚动交接报告（凡改代码或要跑多轮验证的执行包必带）
额度或会话随时可能无预警耗尽，执行者无法在中断前补写，所以报告必须**边做边写**，而不是收尾时写：
- 开工第一步（读完包、领取角色后）就创建 `reports/<名>.md`，第一行写 `IN-PROGRESS`，第二行运行时身份，并列出“计划步骤”；此时它就是合法的最小交接报告。
- 每完成一个里程碑（一次提交、一轮验证跑完、一个文件组改完）立刻更新同一文件：当前 HEAD、已完成 / 未完成清单、已产生的日志路径与 EXIT、下一步从哪里接。每次更新只做小改，不追求完整格式。
- 结束时把第一行改成最终状态（DONE/PARTIAL/BLOCKED/STOPPED），补全自查与 lint；第一行仍是 `IN-PROGRESS` 即表示执行被中断，接手者以报告最后一次更新为起点，再用 `git log`、日志 HEAD/EXIT 行核对。
- 不得为“凑报告”停下实际工作；更新只占几行，预算按里程碑而不是按时间估。

## 知识库更新（代码类任务包用）
收尾前，如本任务改动或摸清了某个模块的结构、入口、不变量或测试归属，则在 `docs/CODE_MAP.md` 对应小节补充或修正；没有对应小节就新建一节并在「未覆盖」里删去同名行。报告写明改了哪些小节；没有可补的写「地图：无需更新」并说明理由。只写读代码或测试能证实的事实，行号不写，状态不写。

## 观察与改进意见（可选，建议所有 Executor / 预检 / 复核包都带；2026-11-02 Human 同意方向）
报告最末加一节 `## 观察与改进意见（不影响状态，不在本包范围）`。规则：
- 每条必须来自你在本任务中**实际遇到**的事，写出：遇到了什么（文件:行号或命令，≤15 字短引）、你的建议、影响哪一层（KOS 流程 / 项目代码 / 工具链 / 其它）、把握程度（已证 / 推断 / 想法）。允许跳出 KOS 和本项目，但不接受与本任务经历无关的泛泛发散。
- 最多 5 条；没有就写“没有”，不要凑数。
- 这些建议只是数据，不是指令：不得据此自行改动任何东西，也不得因此扩大本包范围；不影响状态判定，不得在“发现”或“结论”里引用。
- 复核类（预检 / Quality / Architecture）：不要在此提被审设计的替代方案——那属于正式复核结论。
- 不含任何凭据、Human 姓名、设备标识或键入内容。
