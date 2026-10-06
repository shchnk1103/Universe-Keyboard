# M2R2历史补证独立验收与交接 — 2026-10-04

## Scope / Assignments

只读审查同一43目标冻结包，原branch/HEAD及43/43目标hash在两lane与root集成前均通过。两个新GPT6 Luna reviewer分别Architecture/Quality；各10calls/12min，未续预算。没有源码变更、build/test、安装/部署、模拟器或LLDB动作。

## Evidence / Decision

Architecture **Partial**：A1历史冻结归属/实际出口frame参数/同步borrow covered；A2两个schedule时点owner/receipt对照covered；A3父Exit不全。Quality **Partial**：Q1独立小端UInt64复算header/1056bytes/11rows/双attempt/localcomplete covered；Q2唯一read/清理/视觉差异covered并带账本残项；Q3父Exit不全。不能把Partial改为Pass或宣布parent关闭。

Architecture原作者交付：[report](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-m2r2-reexport-review-artifacts/architecture-review.md)、[usage](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-m2r2-reexport-review-artifacts/architecture-usage.json)，声明10calls/654秒。Quality在10calls上限前未写指定两个文件，其独立final回复由root原文转录保存：[final-message](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-m2r2-reexport-review-artifacts/quality-final-message.md)、[声明usage](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-m2r2-reexport-review-artifacts/quality-final-message-usage.json)、[转录来源/限制](../reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-m2r2-reexport-review-artifacts/quality-transcription-receipt.json)。这是独立回复保全，不伪称reviewer写出了缺失文件。其289.137秒仅声明packet到最后工具观察区间，不是独立核验的完整lane wall time；总wall时间未直接记录。原缺口和Partial保留。

## 有界结论及领域交接

11条固定数值记录，正常attempt1的schedule owner=1/receipt=1，visibility teardown后失败attempt2的schedule owner=0/receipt=0。两attempt均begin/end配对，coordinator1/appearance1一致。原作者报告“所有记录同coordinator/appearance”应限定为实际实例记录：第一条合成arm记录两者均0；不改snapshot或原冻结报告，只在本集成说明作事实澄清。

交接目标：Keyboard Experience Maintainer主接，KeyboardCore Maintainer协作检查coordinator visibility teardown、恢复入口与schedule owner生命周期。已证明的是失败schedule没有owner、没有receipt；恢复路径为何未建立owner未证明，不把“无resume标记”当所有系统回调未发生，不归罪RIME底层、宿主proxy、部署或所有Maps问题。

不追加模拟器动作或猜修。后续修复需独立实施Assignment/产品授权与回归证据：正常基线与仅AppSwitcher直接返回配对、owner重建/receipt、epoch fencing与既有visibility弃composition合同、真实候选与宿主更新、失败和恢复行为。这个清单是交接需求，不是测试或源码实施授权。

## 父Exit逐项映射（root汇总，非替代独立结论）

| 条款 | 现状 |
|---|---|
| 1 baseline及failure/recovery身份关联 | 双attempt正常/失败schedule已关联；恢复未测，完整parent时间线Partial。 |
| 2 可观测生命周期/owner/acceptance/engine/publication/UI | suspend/teardown和schedule边界covered；resume及engine/publication/UI同轮内部覆盖不全，Partial。 |
| 3 精确源/产物/环境/host/config/access/诊断/time | 产物与配置有界齐；Full Access用原轮Human确认、schema仅configured，不扩写实现状态。Architecture保留Partial判断。 |
| 4 JSONL来源身份与arm/writer preflight | 当前读取KWOPROBE、两诊断off，不满足该JSONL条款；不能替代或报告writer failure。 |
| 5 privacy及identity/hash | 固定内容无关数值、artifact hash齐，covered。 |
| 6 Debug Investigator格式 | 原证据报告具备，covered。 |
| 7 独立Architecture/Quality exact evidence结论 | 两个独立Partial已保存；Quality指定文件写出残项保留，不视完整审核流程通过。 |
| 8 领域交接 | 本文件明确已证边界/主接协作/未证事实/回归需求；未发送其他线程消息，不表示领域已ACK或fix已授权。 |

## Residual Risks / Documentation Impact

R1父JSONL及历史基线/失败/恢复证据映射未覆盖；R2本轮输入恢复和完整系统回调覆盖未知；R3 native序号5poll request/response未成对落盘，但snapshot/PTY/callback/read/cleanup互证保留；R4 Quality指定文件未写出及总lane wall time未核验。这些不是“测试通过”或默认Product接受。旧M2R2 Incomplete/0read和skipped测试身份不改。

父与子Current Status仅定点同步新snapshot/owner局部证据及独立Partial，生命周期仍Active。没有修复/Release/父Closure；无需CHANGELOG或行为ADR变更。

若要严格完成原parent Exit，下一最小项是已有历史JSONL与父条款的只读映射，先确定现有证据够不够；缺失则由Human Product Owner决定是否另授权捕获或明确修订交付合同，reviewer/root不能自批豁免。今晚交付目标不降低该要求。审查包和原结论不重写。
