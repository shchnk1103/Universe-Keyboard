# OWN-EXPORT-001 Grok 执行交接

Human 已批准冻结 Entry 并确认原模拟器仍独占，要求 Grok 执行、Codex root 协调。仅本轮 Environment Executor 从 root 改为 Grok；root 继续 Domain Owner/Coordinator/最终收件，Quality 独立验收不转给 Grok。责任变更仅 E0+E1，不扩大生产源码授权。

## 先读与 ACK

原工作树 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；branch `codex/keyboard-wake-v3-compatibility-gate`；HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`；staged 0；既有 dirty 全保留。读 AGENTS/KNOWLEDGE_INDEX/ACTIVE_WORK/READING_MAPS/ASSIGNMENT_POLICY、本修复 Assignment 与下列精确 Entry、binding、AUTH，不创建替代工作树，不清理/reset/stage/切分支/提交/推送。

Entry：`docs/evidence/keyboard-wake-host-activation-fix-001-owner-export-prepared-entry-2026-10-06.md`，SHA d3673a274ee76fb35cd6bae04723d3ea6a3e1deba6a55da540be4b1b71adf7e0。
binding：`docs/evidence/keyboard-wake-host-activation-fix-001-owner-export-prepared-artifacts/prepared-binding.json`，SHA 2f2f90d94dc9116b30aabed7f8a14b7cdc6670b18d0cfc30d8145c127554a1b3。
AUTH：同 artifacts 目录 `grok-execution-authorization.json`。

先核身份、staged、全部冻结输入、1156 source/App/Vendor与78candidate，保存完整dirty原文和hash。ACK角色／范围／工具就绪／真实预算起点；若不匹配停止，不按Git HEAD覆盖dirty。新run根 `/private/tmp/ukey-host-activation-fix-owner-export-20261006` 当前不存在；只执行开始时创建，存在则停止不覆盖。

## 执行边界与协调检查点

Grok 唯一修改新run私有脚本及运行产物；root不并行写、不启动调试器或设备。共享Assignment／导航由root写，Grok不改。所有旧生产文件、Frozen Entry/binding、历史回执/备份不改；源码/build/test/install/deploy/restore/logging/Release全部不在范围。

60 actual tool calls／3600秒，从Grok首执行工具调用计入全部失败调用、wrapper/nested与人工请求；至少最后12调用留清理／读回。E0建议≤12调用；一runtime attempt、一arm、一freeze、一ReadMemory，停点≤120秒。等待人工/root交付不重置预算；上限到停并交付。不因工具故障扩大或反复跑。

**检查点1：E0结束、尚未接触设备时**，写出新脚本hash、fakeAPI/decoder/格式抑制预检覆盖、实际calls/UTC/monotonic、剩余预算与范围ACK，请Human转回Codex root核Ready。只等一次有界就绪收件，不另派独立泛审。root确认后续E1即是本授权内的推进，不再重申请整个Entry；预算若已不足，停交付而不是自续。此刻不请求Human输入或观测。

**检查点2：E1机器Entry通过后**，Grok才逐步指引Human原iPhone18Pro/iOS27.0，UDID405D994F-28CB-4F89-BB22-B64AD81C05A2，Maps空框→单观测→单n→AppSwitcher直接回Maps→单h→单取证。每步确认，不一次发完引起误操作。记录时间只当收到确认时间。若旧appex仍活，当前消息不授SIGTERM；先核精确PID/start/path再请求一次正常终止授权，不强杀或处理其他进程。独占被撤销／App重装部署／不确定操作时停止并报告。

读缓冲依Entry：actual hit-frame identity+caller borrow全部通过，静态FindVariable/noDynamic/nonSynthetic有效，再最多一次exact-size ReadMemory，176..11352bytes。不可寄存器猜ABI、target expression、改frame、短读重试、恢复运行后读旧地址。默认formatter不得额外显示参数；静态参数只私有0600落盘。元数据失败不读取。采样后立即删/list0、detach/quit及机器/Human Exit；非内容decoder离线执行，不能把缓冲complete当真实通知或整体修复证明。

**交付root**：ACK、私有脚本及冻结hash、机器Entry、回调/读取回执、原始binary及SHA/长度、离线decoded、前后attempt对应、停止/失败证据、完整工具账本/预算、清理/诊断原值存在性、Human视觉Exit、delivery-readback。完整原始UTC与monotonic有缺口就写UNKNOWN，不补造。公开文件不复制指针／任意内容，私有原件保存。只建议root另作定点独立验收，不自称验收通过/父任务完成。备份不删。
