# T2 恢复后正常基线健康交付

沿[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-health-entry-2026-10-03.md)，Human明确反馈“完全访问开，候选和提交正常”。本轮仅确认恢复的旧C7正常输入健康，不是新UI候选验证，也不证明Maps返回异常已修复。

[内容无关机器读回](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-health-artifacts/post-readback.json)确认安装包78文件仍匹配T0旧C7，App及appex双签名有效，三容器路径相同，两项诊断原缺键/默认关闭，部署deployed=true/needs=false/deploying=false。未读取用户输入；输入后的词典/缓存变化属正常运行，不声明全部数据仍与输入前字节相等。

人工结果仅按Human证据记录，不冒充机器测量。未重新安装、构建或部署，没有观测/Maps/LLDB。本轮旧C7恢复机器及正常健康缺口已补齐；原T1仍Partial：30skip未验证、签名Keychain未执行，独立T结果验收尚未完成，原历史数据损失和停止记录保留。无Product/Release或新候选晋级结论。

下一步沿已授权T1剩余单个Keychain目标，先收起键盘/关闭主App并只读核进程，准备人工输入后新鲜三容器完整备份与恢复范围。不得复用T0作为这次输入后基线，不自动终止残留进程；任何测试引起的数据变化先保全并呈现清单，恢复权限不超出明确范围。

## 后续 Keychain Entry 精确进程退出补证

Human关闭主App后，PID16380旧C7 Keyboard.appex仍驻留；Human另行授权仅该已核实进程一次正常SIGTERM。动作前精确执行路径仍匹配，发送一次SIGTERM后已退出，主App与appex均不再驻留。见[回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-health-artifacts/keychain-entry-sigterm-16380.json)。未强制终止、重启、安装或测试。下一依赖为人工输入后新鲜三容器完整备份及限定恢复方案，尚未完成，不预填Keychain Ready。
