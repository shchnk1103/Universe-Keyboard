# LLDB事件处理修正与一次验证方案

Status: Approved — Human“继续吧”；执行由新独立Assignment/AUTH绑定

依据：[只读审查](../evidence/typo-correction-002-int003-query-cost-p2-lldb-event-handling-review-001.md)。目的只有一个：让已有128字节条件快照工具可靠接收真实运行/停点事件，避免继续盲目轮询与返工。

## 固定输入与权限

- 复用source25 candidate `6d1e5c285b49717f53546b94e673cebf053903b351383bb9f3206e88ad7c31a9`、installed78 manifest `c5d921c821f38ec5532aaa813870ce69a39254b423b4c2213a80d32a1a2b5c34`；已完成的离线identity/symbol检查不重跑。main更新不触发重试。
- 仅 iPhone 18 Pro iOS27.0 / 405D994F-28CB-4F89-BB22-B64AD81C05A2，执行前核对唯一当前精确path PID；不硬编码历史28957。独占授权未撤销方可操作。
- Executor/Environment Executor：当前Codex；Owner：Test / Release Maintainer；Human：ready后只点观测成本一次，其他无操作；证据属于Executor-recorded诊断，非独立Gate。
- 新Assignment/AUTH拟名 `TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LLDB-EVENT-LOOP-VALIDATION-001`，批准后建立并消费。旧Capture/工具预检AUTH不复用。

## 最小工具改动

仅新private目录中的driver/launcher，不修改仓库Swift、工程或测试。

1. 用持久变量保存自定义SBListener，并将它用于同一次attach与所有process事件读取。避免再临时创建后仅轮询GetState。
2. 非阻塞GetNextEvent消费队列；每个事件只记录数字type、同process PID、state、restarted及读取后的GetState。忽略其他进程/非状态事件的内容，不读stdout/stderr payload、event描述或任意frame。
3. attach停止、Continue后的恢复、Human等待以及cleanup使用同一事件处理逻辑；分别保存checkpoint。attach残留事件先处理清楚；恢复准入只接受Continue之后的同PID running事件，消费当时队列后GetState仍running，并以精确同PID/path ps确认非T/Z。任何真实异常stop或terminal state立即停止，不自动Continue绕过。
4. 停点只读取线程id、stop reason数字及有限reason data以核对唯一获准breakpoint；只有匹配helper才读取既定address/count与exact128，保留原严格decode。
5. cleanup先保存现场数字状态；删除本次断点、必要时停止本次附加、finally Detach(False)，同PID/path ps。仅detach后仍T且identity完全匹配才一次CONT清理；不kill、不重启。

## 一次执行预算与停止条件

- 在同一新AUTH内，先一次不attach的有限新增API检查（仅event/listener方法存在/签名和空listener GetNextEvent调用，≤30秒）。这不是另一轮build或离线符号全检；失败即停止，不进入attach。
- preflight source/installed/uniquePID ≤30秒；一LLDB session ≤420秒，包括attach ≤30秒、恢复 ≤5秒、Human ≤300秒、cleanup ≤10秒。事件每周期最多64个，累计最多4096个；数量或期限超限先留回执再停止，无无界日志。
- 只有loaded twoUUID/path、unique live breakpoint、running事件+实际state+同PID检查均通过才发Human指引。没有ready不让Human试点。
- 一次attach、最多一次Human arm、一次exact128；首必需失败安全停止、AUTH耗尽，不复用或自行重试。若仍失败，新数字回执用于下一决策，不自动扩大scope。

## 通过与输出

工具通过要求同一attempt完整identity→事件恢复准入→Human实际标题→唯一helper→严格128decode→安全detach。arm_result允许armed/rejected/alreadyAttempted，如实说明；工具通过不等于arm成功或P2正式Capture通过。

保存driver/launcher hashes、API/preflight/事件checkpoint、Continue结果、Human标题、snapshot/严格decode或首失败、detach/ps与elapsed。原始有限数字回执保留private，项目文档记录结论和经验。

不改产品合同、Swift或部署，不新build/install，不输入/预热/reset，不做Git发布、合并、Gate、父Close、ADR Accept或Release。成功后仅据实际vector建议下一最小步骤。
