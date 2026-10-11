# 单次arm条件诊断002：恢复后的状态准入未通过

Status: Partial / Blocked / Executor-recorded；AUTH consumed / exhausted

## 绑定与已完成检查

[Assignment](../assignments/typo-correction-002-int003-query-cost-p2-arm-conditions-capture-002.md)与[AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ARM-CONDITIONS-CAPTURE-002.md)先消费。本次仅一次attach，固定405D994F-28CB-4F89-BB22-B64AD81C05A2、PID28957；旧AUTH均不复用。

- source25及installed78 hash全部匹配。candidate `6d1e5c285b49717f53546b94e673cebf053903b351383bb9f3206e88ad7c31a9`；manifest `c5d921c821f38ec5532aaa813870ce69a39254b423b4c2213a80d32a1a2b5c34`。
- 加载的Keyboard与Keyboard.debug.dylib完整安装路径均匹配；UUID分别为 `4346DC9B-B55B-3B85-8A5E-F389DF48A2EC` 与 `68CF9C79-7CC2-3C88-9E9A-26BD3C08D062`。
- exact helper `$s8Keyboard27queryCostArmDiagnosticReadyyySV_SitF` 的运行时resolved locations为1。离线API与file-location预检已通过，未重复。

## 首失败与安全停止

`Continue()`返回成功后，driver在5秒内轮询`GetState()==eStateRunning`未通过，记录 `NOT_RUNNING_BEFORE_HUMAN`。session耗时12.894109125秒；原生LLDB exit0只是脚本捕获停止原因后正常退出，**不等于快照诊断Pass**。

本轮未保存轮询中的状态枚举、事件或线程stop reason，也没有附加期间OS进程状态。故无法判定是LLDB状态观察机制、目标实际停止还是其他情况；不能声称键盘卡死、Continue失败或listener缺陷已证实。driver使用自定义SBListener且没有显式处理事件，可作为后续工具审查假设，不能当根因。

finally删除断点并`Detach(False)`成功；已执行同PID精确ps核对，状态Ss、安装路径不变，无T/Z；未用CONT。未生成ready.json，未向Human给出点击指引：**0 Human arm / 0输入 / 0快照 / 0正式P2 Capture**。无需Human恢复或重复操作。

## 下一最小建议（Proposed，未执行）

只核查当前LLDB的状态/事件处理文档与本地driver，设计可审计的恢复准入：保存Continue回执、状态枚举、事件/stop reason及同PID状态。先确定标准listener/命令通道是否更合适，再修本地工具；不能删除“恢复运行后才让Human点击”的准入来获得通过。

实际复验须新独立AUTH、一次attach上限和原清理边界。复用当前安装包与候选，不改Swift、不重新build/install、不追逐main、不先让Human重复点击。此处只收尾与方案建议，不执行工具修正或新的attach。

## 证据与非声明

原始回执 `/private/tmp/uk-armcap2`：binding/preflight、driver/launch、loaded-identity、breakpoint、lldb.stdout/stderr/receipt、session-result、stop、detach、process-after-detach。保留当前必要回执；未删除唯一证据。

本轮文档收尾未改源码，docs-only，跳过xcodebuild；未做新测试、Git提交/推送/合并、Gate、ADR Accept或Release。CHANGELOG及架构合同无需更新。父TYPO-CORRECTION-002保持Active；P2实际query成本和旧“不可启用”根因仍未获得。
