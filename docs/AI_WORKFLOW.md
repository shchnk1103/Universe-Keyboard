# AI_WORKFLOW.md

本文件负责有界执行、协作与交接；领域权限见 [playbooks](playbooks/)，Assignment 合同见
[Policy](ASSIGNMENT_POLICY.md)，架构事实从 [Knowledge Index](KNOWLEDGE_INDEX.md) 路由。
本次澄清依据 [KOS-ASTRA-UPGRADE-001](assignments/kos-astra-upgrade-001.md)；不修改冻结内核。

## 当前指令与项目事实

项目事实、已完成 Gate 和既有合同须回到权威文件。用户在本任务中明确给出的目标、约束、
授权和纠正持续有效；不能因技能、上下文压缩或切换角色重复请求相同授权。
当前有权用户改变既有决定时，记录来源、范围及生效边界，完成适用的 Contract/Assignment
revalidation 后执行依赖动作。不能用聊天摘要替代证据，也不能用旧模板否定当前有效指令。
所有执行仍服从宿主更高优先级指令和权限。用户问进度或补充要求时保留原任务，除非明确取消。

## 阶段与停止

- 先判断请求类型。边界明确的只读问题按 Assignment Policy 例外回答。
- 正式实施先核对 Assignment 和当前阶段 Entry；必填 UNKNOWN 仍阻止 Ready/Active，Executor
  不自行选择 assignee 或改为 N/A。未来阶段依赖必须有命名 owner 与解除证据。
- 当前工作按已批准的阶段依赖进行；未来真机/Gate 未完成不自动阻止独立机器准备，但已有
  全局 Entry 仍有效，不能临时解释为未来依赖以绕开阻塞。
- 阻塞时保存检查点，完成其他独立、已授权且 Entry 满足的工作；缺少决定时给出具体待审结果、
  阻塞动作、来源文件/条款，说明哪些是明文、哪些是自己的解释。
- 根因不清先收集证据；已确定故障边界后执行授权修复。常规可逆实现选择自主完成；产品、
  隐私、架构、独立评审和 Release 权威不由执行者推定。

## 验证与证据复用

必需检查与本地 CI 门禁以 [AGENTS](../AGENTS.md)、[CI 分级](CI_CHANGE_CLASSIFICATION.md)
和当前 Assignment 为准。测试验证行为/不变式；机械编辑不强制新增镜像测试，合法合同变化
可更新旧测试，不得弱化断言掩盖失败。改变测试必须运行实际 target。

复用先核对：精确最终内容、比较基线、依赖、命令/覆盖 target、环境、通过结果、采集时间与
重验证触发均适用；证据引用写入交付。rebase/merge 后默认重验证，除非有可审核的等价性证据
且当前门禁允许。过期、内容/环境/依赖改变、覆盖不足、失败或用户明确要求重跑时重新执行。
再次要求 merge 本身不使合格证据失效。必需检查通过后，无新变更/失败/未解疑点就推进交付。

修 CI 时继续修复已授权、本 PR 拥有的失败；范围外失败记录并交回其 owner。测试通过不授予
push、merge 或 Release 权限，草稿 PR 的验证缺口必须明确。

## 委派与连续性

当两个调查或评审子问题独立、有界，且并行能改善速度或覆盖时使用可用 subagent；短任务、
共享状态或依赖链顺序处理。先给出精确输入、输出、文件边界与验收。一个责任区一个 writer，
隔离 worktree/副本；不同时修改相同文件区域。
Coordinator 负责汇总结论与范围控制；Product/Architecture/Quality 各自保留决定权。
独立 reviewer 必须是未参与实现的 runtime；executor 自检不算独立评审。不可用时记录缺口。
保持逻辑 review lane 和开放 findings，复审绑定新基线。可选上游编排合同只有被项目显式采用
时才约束 lane；[升级状态](kos/UPGRADE_STATUS.md) 记录当前是否实例化，不自行声称采用。

## 推荐角色

| 角色 | 执行手册 |
|---|---|
| Coordinator | `docs/playbooks/coordinator.md` |
| Context Scout | `docs/playbooks/context-scout.md` |
| Bug Investigator | `docs/playbooks/debug-investigator.md` |
| KeyboardCore Agent | `docs/playbooks/keyboard-core.md` |
| RimeBridge Agent | `docs/playbooks/rime-bridge.md` |
| Keyboard UI Agent | `docs/playbooks/keyboard-ui.md` |
| Main App UI Agent | `docs/playbooks/main-app-ui.md` |
| Test / Release Agent | `docs/playbooks/test-release.md` |
| Documentation Maintainer | `docs/playbooks/documentation-maintainer.md` |

## Stacked PR 约定（KOS 2.1 ops · S-02）

当多个 PR 形成提交栈（前缀 PR 的 commits 是 tip 的子集）时：

1. PR 正文声明：`Stack: base=<branch-or-main> tip=<tip-branch>`，并列出前缀 PR 编号。
2. **优先合并 tip**（含全部 commits）；前缀 PR 在 tip 合入后标记 superseded 或由 GitHub 识别为已合并。
3. tip 合并后执行 State sync 清单（Dashboard / Index / Assignment Current Status / `ACTIVE_WORK.md`）。
4. 不要对同一栈做互相冲突的 squash 重写，除非 Product 明确授权并重开 PR。

## 交接与输出

交接包含目标/范围、精确基线、完成输出、证据、开放 findings、环境、副作用、授权边界与下一
合法动作。跨任务/新会话将这些放进仓库记录；不能只靠聊天重建。
用户回复默认简洁中文，先结果再证据和限制；playbook 格式是交接字段，不要求每次回复复制长表。

KOS validator 是结构证据，不能替代独立 review、Product Gate 或真机证据。
GitHub 认证失败按 [诊断手册](kos/codex-github-cli-auth-troubleshooting.md) 做有界环境对照。
Gate/合并后的状态同步按 [2.1 ops](kos/kos-2.1-operational-maturity.md)，只同步有关镜像。
