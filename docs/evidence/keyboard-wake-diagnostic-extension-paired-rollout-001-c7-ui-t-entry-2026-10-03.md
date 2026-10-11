# C7 UI 新候选 T 测试 Entry（Prepared，未 Ready）

## 当前授权与责任

Human于2026-10-03 Asia/Shanghai授权“准备 T 测试 Entry，当前模拟器还是独占的”。仅授权文档准备与本地来源核验；记录原 iPhone 18 Pro / iOS 27.0、UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2` 本轮独占。未授权本轮设备读取、备份/恢复、测试或安装执行。Product Authority/Approver为Human；root继续既定Coordinator/Executor与Environment Executor，唯一repo writer；Human负责独占及需要时人工健康核验，既定独立Quality负责未来T结果验收，Architecture保留当前限定产物意见。既定Assignment责任不变，非新分配。

## 已满足的来源条件

- 原worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`、branch `codex/keyboard-wake-v3-compatibility-gate`、HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a` 本轮再次核对一致。
- 新candidate `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50`；571 source/build输入与630 Vendor本轮逐文件hash匹配H1冻结manifest。[本地核验 receipt](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-entry-artifacts/preflight.json)。
- [H1](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h1-validation-2026-10-02.md)、[H2](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h2-validation-2026-10-02.md)、[Quality R2](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-q-r2-validation-2026-10-03.md)与[最后Architecture补审](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-reader-final-supplement-validation-2026-10-03.md)组成同候选限定产物前置证据。旧Partial及预算缺陷保留，不声称整体Gate或runtime通过。

## T 分段 Entry 与停止条件

| 子阶段 | 必需条件与工作 | 当前状态 |
|---|---|---|
| T0 设备只读与备份 | 另获最小执行授权后核实际设备/OS/boot、当前App及appex身份、main data与App Group实际路径；不启动App、不部署、不输入。完整备份当前main data、App Group、已安装App全部payload到private scratch，保存目录结构/文件hash/数量与复制后独立一致性核验；核两项诊断原值及存在性，记录原容器路径。 | 独占由Human本轮确认；设备实际状态、诊断键、容器、完整备份均UNKNOWN/未执行。 |
| T0 恢复可行性 | 明确备份App的可重新安装性、签名/配对身份、data/group路径变化的映射、恢复顺序及恢复后hash/readback和RIME健康核验；复制前后文件若变化，停下查明，不接受不一致快照。现有不可访问文件、符号链接/权限或恢复来源缺失则停止，不进入测试。 | UNKNOWN；旧备份不替代当前备份。恢复/重装副作用须纳入另获的明确授权，不先试恢复。 |
| T1 实际测试 | T0全部取得证据后再获测试授权；固定原UDID、新独立DerivedData/xcresult，不更新依赖、不并行、不创建clone或改用其它设备。source/vendor/工具链须执行前无漂移。 | 未授权/未执行，当前未Ready。 |
| T2 测后保护核验 | 按新容器路径重新发现main data/group/installed App，比较测试前备份并分类变化；测试无失败不代表数据未变。必要恢复仅依批准方案执行；无法验证恢复则Hold。 | 未授权/未执行。 |
| T3 独立结果验收 | 保存实际suite/执行数/pass/skip/failure、完整日志/xcresult与数据保护证据，再以独立冻结packet/预算验收。残项由Product对当前实际记录决定。 | 后续单独Entry，不预填通过。 |

## 拟执行覆盖（命令冻结于 T1 放行前）

按当前AGENTS/CI与最终内容复用条件核清：完整KeyboardCore strict证据可在最终内容、基线、环境和覆盖均相同后明确复用，不能仅凭旧1194计数；若不满足则执行完整Core。实际iOS运行RimeBridge全套、App+Keyboard全套，以及签名Keychain专项，使用Swift6/complete/warnings-as-errors。App+Keyboard须实际执行相关target，syntax/test-target编译不替代。新测试产物需记录实际专用probe编译条件，并与H1最终源绑定；test-host产物不是可安装standalone候选，也不将旧installed App当新候选runtime证据。普通模式隔离证据H2按覆盖条件复用。

原20 RimeBridge与10 App+Keyboard skip历史保留，不计通过；本轮新skip逐项记录，旧阶段accept不自动沿用。按xcresult实际执行数记账，不为429/428或432/431等历史差额重跑。单套失败时先保全日志及数据状态，不自动重跑、重部署或扩到源码修复。

## 可执行的下一最小切片

建议先仅授权 **T0设备只读核验、完整备份和恢复方案准备**：原UDID，保持App关闭、不输入、不切诊断、不部署、不测试、不安装；如无法安全取得一致备份则停止。raw数据只留private scratch，repo仅保存hash/数量及不含用户内容的receipt。T0完成后交回具体测试命令和保护方案，再申请T1及必要T2恢复授权。

本Entry不会启动模拟器、App、测试或修改偏好。准备完成，因当前备份/恢复证据缺失保持Prepared、未Ready；不是将正式Assignment责任字段填UNKNOWN。父子Assignment Active。I新候选安装、U正常单轮观测和M Maps复现仍分开授权，T不包含这些动作。独占撤销、设备/候选/源漂移、备份不完整或必要身份缺失即停止。无需CHANGELOG/架构合同变更或M-02 Gate/Close收尾。
