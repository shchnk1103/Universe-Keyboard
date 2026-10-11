# C7 UI I0 安装前保护 Entry

## Scope / Ownership / Authorization

Human「那么接下来我们应该做什么呢？授权你继续」：按已有H/Q/T/I/U/M阶段路线，当前执行下一阶段的I0安装前只读核验、完整新鲜备份与恢复方案准备。root为Coordinator/Environment Executor/唯一repo writer；独立review无新派发，Human为Product Authority。当前不执行I1安装/U单轮观测/M Maps/LLDB/源码/build/test/Git/Release。

Human确认原UDID405D994F-28CB-4F89-BB22-B64AD81C05A2本轮核验备份独占；说明此前健康后一直前台、现在已关闭Main App。MCP只读确认iPhone18Pro/iOS27.0 Booted；不改共享session defaults。精确simctl容器查询在沙箱XPC被拒，按已授权只读范围使用主机fallback，未boot/install/kill。

## Confirmed facts / Evidence

- 分支/HEAD保持codex/keyboard-wake-v3-compatibility-gate /84b9c19227330b0fe6ff391be001ee398010fd6a。Q/T限定独立产物/测试阶段已交付，T的29非阻塞未验证残项仅本阶段接受，不直接授予I/U/Release。
- 待安装新候选43d85d…，78payload逐文件hash及App/appex strict签名重新核验。当前安装仍旧C7 ddd557…；78payload全映射匹配其c7b3 paired-products，双签名有效。
- 两诊断键原ABSENT、默认关闭；rime_deployed=true、rime_needs_deploy=false、rime_is_deploying原ABSENT。保留存在性，不把absence写成原false值。
- Main App无精确路径进程，但Keyboard appex PID45871仍在同一安装容器运行；Executable SHA e059dfbfef672553b51d9ce2a3097348f3c40129c8afaa27b58fd90918cbd692已与旧候选绑定。未发送任何信号。

## Current Decision / Stop

I0核验已做，完整备份尚未开始：静止进程前置缺失。**待该精确appex正常退出后才能备份；不把Main App关闭当作appex退出。** 进程退出动作需具体范围授权，发送前须重新核PID/路径/字节、禁止SIGKILL/重启/替代设备。不因读取断言错误推断进程消失。

root曾误把postinstall-verification的installed_files计数当SHA字典，随后改用c7b3 paired-products.file_hashes并完整核对；旧中间断言不作为安装字节不符或进程消失证据。

## Backup / recovery preparation contract

进程退出后：重新发现主App data、唯一App Group、installed App路径，完整私有ditto备份；三次源读回与容器身份/进程缺席稳定，核bytes/结构/mode/owner/原xattrs/内部symlinks及副本新增provenance分类，App/appex双签名。用户原内容只留private backup，不读出或写入repo。键盘完全访问先沿上次Human健康证据标historical，安装后需新Human核验，不伪造当前机器测量。

恢复方案绑定此次新鲜基线；保存旧C7完整可安装包与main/group内容、恢复规则及系统rootmetadata/Snapshot例外。若安装后发现差异，先保全after，再列逐路径最小恢复清单；未授权清单不执行恢复。旧T备份不替代新鲜I0。备份失败/变化/进程回归/外部symlink/签名或身份不符→停。

## Exit / Remaining

当前Exit为精确候选/旧基线/进程/键存在性只读收据；backup=NOT STARTED、I1=NOT AUTHORIZED/NOT EXECUTED、U/M=NOT EXECUTED。后续完成新鲜备份与恢复包后再呈现具体I1安装切片。30raw skip及T独立历史不改，父子Assignment仍Active，根因未确认。
