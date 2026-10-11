# C5-P quality frozen review packet

Work Item: KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001
Lane ID: QUALITY-C5-P; round:1（新 lane；旧C4预算/报告不迁移）。
Baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`; branch `codex/keyboard-wake-v3-compatibility-gate`; exact dirty source candidate `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9`.
Input manifest: `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-input-manifest.json`; SHA256 `928bfdd6412ce5b23bdad7cece3141e00c993d191079ea2b7ed692662f06d941`. Entry: `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-entry.md`; SHA256 `8e507a253fcb89f0d8570ce0b980c029c59b1ec5c452db84b71545da94454dc7`. Packet digest由root派发消息提供（不自引用）。

## Decision question / Positive complete coverage

只评估冻结 C5 提案是否提供合理且可核验的最小晋级/安装/真实callback路径，必需证据缺口及当前边界是什么；不作 Product residual accept、晋级/安装授权或全局Gate。必须逐项正向证据覆盖：P-Q1 C4证据复用及30skip对本阶段的影响；P-Q2 安装后身份检验和可执行宿主前置条件；P-Q3 一次采集、reader验证及残项。报告每项已覆盖/未覆盖、证据位置及论证；任何未覆盖或预算耗尽只可Partial/incomplete，不能Pass。独立说明设计review可完成与未来执行Entry仍待满足的区别；30skips不自动承接C4接受。

## Allowed inputs / read-write-tool-access-data boundaries

允许只读 manifest列出的文档和568 source/build输入、指定bundle111文件；允许读取manifest/Entry/本packet及scratch自己输出。源输入只用于既有call-path/语义核验；旧C4 evidence链接若未在manifest列出，须先报告缺口，不盲猜文件。不得读取另一个C5 reviewer的新报告或寻求其结论；root也不向两lane传递对方发现。

允许本地文件读取/hash/plist/Mach-O及git只读身份；无网络、无Simulator/设备发现/UI/容器访问、无build/test/install/launch/arm/input/Maps、无source/doc/Git mutation。仅可写 `/private/tmp/ukey-wake-c5-p-20261001/quality-review.md` 和 `quality-usage.json`。不拷贝用户输入/日志/prefs/截图。

## Budget / checkpoints / stop / expansion authority

新预算：最多12底层tool调用、600秒；从精确ACK并开始审阅计时，写报告/usage也计tool调用和时间。functions.exec中每个嵌套工具分别计数；不得用脚本隐藏多项工具调用。第6次完成后立即向root checkpoint（覆盖/剩余/下一步），不要等第7次。保留至少1次写报告预算。稳定laneID/round、实际开始/结束/耗时、每调用账本、checkpoint时间及超额/迟报必须如实写usage。

先给root精确packet/manifest SHA ACK和timer start；identity不符、输入漂移、必需证据缺失、隐私/权限/未知owner或预算耗尽立即Hold/Partial，保留原始结论。只能Human Product Lead扩scope/budget，reviewer/root不得自己放宽。环境相关结果只能列futureEntry/未验证，不以静态文件确认currentdevice/安装/FullAccess/Rime。

## Required outputs

中文报告：Scope；身份摘要；三项正向coverage矩阵；Findings（ID、严重性、证据位置、影响、责任人、最小建议）；Skipped/unverified；严格本lane verdict及其边界。附usage JSON。若无review blocker，明确仍需Product专属晋级/残项决定与C5-I/R授权及freshlease；不要宣称整体QualityPass/ReleaseGate/真实callback已通过。
