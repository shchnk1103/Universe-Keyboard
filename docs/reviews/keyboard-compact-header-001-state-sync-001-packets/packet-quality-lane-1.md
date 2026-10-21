# Reviewer Lane Packet — Quality / Round 1

## 1. 身份与待决问题
- Work Item：`KEYBOARD-COMPACT-HEADER-001`；Assignment：`KEYBOARD-COMPACT-HEADER-001-STATE-SYNC-001`
- Lane ID：`KCH001-SS001-QUAL`；Round：1（新 lane）
- 基线：base `b266be269cd978772a7f532efe862631a16b3da7`（origin/main）；目标提交 `ec580ac4bb097a7a9de70d639eff39b8db1fc0e4`；分支 `docs/keyboard-compact-header-001-state-sync-001`；只读 worktree 路径 `/Users/doubleshy0n/Dev/Universe Keyboard/.claude/worktrees/keyboard-compact-header-001-state-sync-001`
- Packet digest：本文件的 SHA-256，由 Coordinator 在派发消息中给出
- 待决问题：
  - Q1：每条状态事实是否有可追溯来源。须亲自抽查：#216 的 merge commit 与合并时间、#217 与 UI-1 的集成关系。
  - Q2：无来源的事实是否如实写成 UNKNOWN（#216 的 Final Merge Gate 指针；UI-1 Human 真机对比是否完成），没有补造。
  - Q3：重新运行链接检查，结果与记录的 baseline/HEAD 一对是否一致。
  - Q4：diff 是否只含 docs，范围与 Assignment Scope 一致；Exit evidence 是否全部填写。
  - Q5：Executor 的模型与 effort 描述是否如实，无未经核实的“已应用 medium”。
  - Q6：Claude 的 Architecture/Quality Partial 结果是否被误写成“已通过独立复核”。

## 2. 允许与排除的材料
- 允许：base..目标提交 的 diff（3 个 docs 文件）；`AGENTS.md`；`docs/ASSIGNMENT_POLICY.md`；`docs/kos/kos-2.1-operational-maturity.md`；`docs/assignments/keyboard-compact-header-001.md`；`docs/assignments/keyboard-compact-header-001-state-sync-001.md`；`docs/assignments/keyboard-t9-adaptive-row-001.md`；`scripts/ci/check_markdown_links.py`；只读 `gh pr view 216` / `gh pr view 217`。
- 排除：产品代码与测试、CI/workflow 改动评审、其它 Work Item、UI-1 残项实质评价、CI #705 事实更正、Human 本地 main 的 dirty 文件、另一位 Reviewer 的输出。

## 3. 读写边界
- 只读。允许：`git log/show/diff/status/rev-parse/ls-tree/cat-file`、`rg`/`cat`/`sed -n`、只读 `gh pr view`、`python3 -B scripts/ci/check_markdown_links.py --base b266be269cd978772a7f532efe862631a16b3da7 --head ec580ac4bb097a7a9de70d639eff39b8db1fc0e4`（`-B` 避免写缓存）。
- 禁止：任何写入（含 `git add/commit/checkout/switch/stash/reset`）、push、开 PR、xcodebuild/测试、除 `gh` 只读以外的网络访问、修改 worktree 内任何文件。
- 不得读取或输出凭据、token、个人数据。

## 4. 输出与验收
- 输出（写在最终消息里，由 Coordinator 另存，Reviewer 不写文件）：独立性声明；Q1–Q6 逐项 Covered/Uncovered；结论 Pass / Pass with conditions / Blocker / Partial；发现列表（严重度、文件:行号、依据、复现命令）；你亲自执行过的命令及结果；未能核验内容及原因；用量记录。
- 正向验收：Q1–Q6 每项均有结论并附证据，Q1 与 Q3 须有亲自执行的命令输出。
- 完整覆盖：Q1–Q6 全部为 Covered。任一为 Uncovered，结论只能是 Partial，不得是 Pass / Pass with conditions。
- 发现记录位置：Coordinator 保存为 `docs/reviews/keyboard-compact-header-001-state-sync-001-quality-review.md`（由 Coordinator 另行提交，不在本 lane）。

## 5. 预算与检查点
- 首个上限：40 分钟墙钟、50 次工具调用。
- 检查点：约 15 分钟、30 分钟各一次，用一两句话报告已覆盖的 Q 项。
- 用量记录：写在最终消息（耗时、实际工具调用数、停止原因、已覆盖/未覆盖项）。
- 耗尽：立即停止，记录上述内容，剩余项标 Uncovered，结论 Partial；预算不自动续期。

## 6. 停止条件与扩权
- 停止：独立性声明无法如实作出；worktree HEAD 不是目标提交；需要读取允许集之外的材料（报告一个定位符和理由，将相关项标 Uncovered，并停止该部分）；被要求任何写入。
- 扩权：仅 Assignment Authority（Human Product Owner / Product Lead）可批准具体增加的范围与预算；Reviewer 与 Coordinator 不得自行扩权，批准后须冻结新 packet 与新 digest。
