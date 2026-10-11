F4-P 本轮结论应为 **Partial / incomplete**，不能判定 A-P1..3 全部 Covered。我已用满 **16/16 次工具调用**，停止继续取证。

确认冻结包 SHA-256 为 `44a83a73738a6664f54dbf255bc3db8b08dc712bced69326773899538802e6be`。root 提供的允许输入只读镜像位于 architecture-raw-reader.json，SHA-256 为 `c3e2e7646a7813657b2ce3bc3ca3f66c61c68fe61c3cc09ccd0f406542e91817`。该镜像的批量输出被截断，无法独立完成三项判断。

目前可确认的局部证据：

- A-P1：探针条件点在候选栏、输入动作、按键反馈和 Presentation 代码中可见；例如候选栏第 39、170 行，输入动作第 20 行，按键反馈第 12 行，Presentation 第 94、139、155 行。普通/诊断编译 flags、依赖与五源对应关系未能核完，因此该项未覆盖。
- A-P2：没有取得足够完整的 A2/F3 证据片段来界定可复用范围及仍未验证的 UI/probe 行为，该项未覆盖。
- A-P3：可见日志字段包括粗粒度角色、效果枚举、生命周期/owner 状态、composition/raw 长度；片段未显示文本值，但不足以验证完整 export/button/wire 资格与内容过滤合同，该项未覆盖。
- 允许的 build log 镜像显示一条 AppIntents 元数据提取 warning（第 2889 行）和 BUILD SUCCEEDED（第 2949 行）；三个依赖清单的 actual 与 expected aggregate SHA 相符。这些局部证据不能替代 A-P1..3 覆盖。

由于 host 原件在本 runtime 的 exec_command 中报 ENOENT，且调用预算已用尽，ACK、review、usage 和 delivery-readback 四份指定私有产物均未写入或读回。可确认的时间只有首个包读取时间 2026-10-05T03:07:13.569925Z 与 reader 镜像生成时间 2026-10-05T03:11:38.637598Z；没有捕获精确结束时间，不能据此伪造 usage elapsed 或交付摘要。
