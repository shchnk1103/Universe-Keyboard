# LLDB状态/事件处理限定只读审查

Status: Completed — read-only analysis；实际根因未证实

## 权限与边界

Human“继续”承接单次诊断002收尾后的建议，批准只读核查本地driver与LLDB接口并制定下一方案。使用Assignment Policy的范围明确只读例外，Owner为Test / Release Maintainer，Executor为当前Codex；输出为本文与Proposed方案。不复用耗尽的Capture AUTH，0 LLDB执行/attach、0模拟器操作、0工具或Swift修正、0Human点击。

## 症状与时间线

[诊断002](typo-correction-002-int003-query-cost-p2-arm-conditions-capture-002.md)中loaded identity和live breakpoint通过，Continue成功，随后GetState轮询未通过；缺少中间状态/事件，detach安全。只读driver发现：直接把临时`SBListener('armdiag')`传入AttachToProcessWithID；没有保留可用的listener变量，也未调用GetNextEvent/WaitForEvent。恢复及Human等待都只轮询GetState。

## 官方接口与机制证据

1. 当前Xcode安装的Python wrapper `.../LLDB.framework/Versions/A/Resources/Python/lldb/__init__.py`，AttachToProcessWithID说明：有效的传入listener接收全部process事件；无效listener才由target debugger监听。当前driver使用有效自定义listener，因此不能依赖默认debugger替它处理事件。对应[官方SBTarget文档](https://lldb.llvm.org/python_api/lldb.SBTarget.html#lldb.SBTarget.AttachToProcessWithID)。
2. 当前wrapper暴露GetNextEvent(SBEvent)、WaitForEvent(uint32,SBEvent)、EventIsProcessEvent、GetProcessFromEvent、GetStateFromEvent和GetRestartedFromEvent。相应[官方SBListener文档](https://lldb.llvm.org/python_api/lldb.SBListener.html)及[SBProcess文档](https://lldb.llvm.org/python_api/lldb.SBProcess.html)确认这些接口。
3. 固定版本[LLVM llvmorg-20.1.8 Process.cpp](https://github.com/llvm/llvm-project/blob/llvmorg-20.1.8/lldb/source/Target/Process.cpp#L3974)的ProcessEventData::DoOnRemoval在公开事件移出队列时调用SetPublicState。它提供“未消费事件可能导致公开状态未更新”的机制依据；不是当前Apple LLDB的精确源码版本，也不补回上次缺失的运行时事实。

**结论：driver存在没有消费自定义listener事件的明确缺口；这是值得最小修正的工具机制问题。上次NOT_RUNNING_BEFORE_HUMAN是否由它造成，仍需新一次真实回执。**不推定键盘卡死或arm拒绝原因。

## 下一步

采用[限定方案](../plans/typo-correction-002-int003-query-cost-p2-lldb-event-loop-validation-001.md)：只修本地driver，保留并消费同一listener；把恢复与断点等待统一为有界事件处理，保存数字状态，仍保留恢复运行准入。新验证另建独立Assignment/AUTH，不新增源码、build/install或输入轮次。

原始审查绑定保存在 `/private/tmp/uk-armevent-review1/binding.json`；实际driver及当前wrapper hashes已记录。本文是Executor分析，不冒称独立Architecture/Quality复审；无需为这次只读查文档再派agent。

父TYPO-CORRECTION-002 Active；实际P2 query-cost Capture尚未完成，无Gate/Release/发布。docs-only，跳过xcodebuild；不更新CHANGELOG或架构合同。
