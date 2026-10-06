# 持续调试通道预检交付 — 2026-10-04

## 限定结果

跨一次Human回复，原生持续PTY LLDB通道、同调试器进程/目标及原出口断点保持可查询；仅此预检covered。自身断点删除/list空、detach、quit及machine Exit完成。未输入/arm/Maps切换/freeze/目标内存read，未开展新的Maps配对取证；不能证明任意时长或下轮全流程都稳定，也不能补成原M2R1缺失的cleanup回执。人工只观察Exit已确认。

## 身份、连续性与清理

原UDID405D994F-28CB-4F89-BB22-B64AD81C05A2、固定候选43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50，41635精确path/SHA、安装78文件和源1279核验。native xcrun lldb禁lldbinit，PTY63415/LLDB45732/debugserver45734；实际原UDID loaded UUID与固定appex/debug dylib匹配。仅一个出口断点1单resolved location，命中0；continue恢复运行后才请求Human等待回复。

Human“未操作”后，三个PID及启动时间匹配；同PTY process status明确running，断点1仍resolved单位置/0hit。随后仅delete自身断点1，list无断点，process detach返回41635 detached，quit退出code0。已running故不多发continue。最终原目标Ss、flags0x4004/P_TRACED clear，LLDB及debugserver退出，payload/source及两诊断ABSENT/off无漂移。

## 证据与限制

PTY原文 (`keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-stable-channel-artifacts/pty-transcript.txt`)、[Exit](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-stable-channel-artifacts/exit-result.json)、[保全清单](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-stable-channel-artifacts/preservation.json)。request时间和进程metadata另存；PTY原文逐行时间未嵌入，实际目标pause起点UNKNOWN，不能补造。该原生预检不套用MCP calls计数，也不是独立Quality/Architecture/Gate。

原M2R1因工具session失效仍Incomplete，旧断点delete/detach缺失原回执保留；本轮新native session不冒充其延续。后续新的Maps完整配对窗口应重新核独占、未重装/部署、静止保护和新实例，再分别冻操作/读取预算；不得沿现已消费/过期probe直接续采。此预检授权不含新复现、进程退出、安装或恢复。


## 人工视觉Exit增量

Human确认界面正常、既有候选及输入框状态保留、按钮取证；未追加试打或读取内容。仅稳定通道一次回复边界与cleanup的预检交付完成，不等于新Maps故障取证、输入健康复测或原M2R1补成功。
