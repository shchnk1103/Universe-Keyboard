# C2 Extension producer 本地实施与模拟器验证授权

2026-10-01 Asia/Shanghai。Human 首先表示“C2 是你最建议的下一步工作吗？是的话我就授权你继续。”Coordinator 推荐并承接 C2，准备五文件执行包后，Human 确认“授权确认本轮模拟器仍为之前授权与独占的那台模拟器”。两条共同授权本轮 C2 本地实施、strict format/lint、Simulator Debug producer focused 与 App + Keyboard 验证及 owning 阶段文档。

精确五路径见 Entry/pre-edit manifest：三个 Extension 文件、新 producer 测试、工程文件仅 adapter test membership。Main App、Core、WireValidator、既有测试及其他工程路径只读。生产 Runtime 默认 v5、marker off 不变；测试的显式 v6 只写临时目录。真实 Extension 调用点只记录实际生命周期、RIME resume 调用 started 和三个 proxy 操作 entered/returned；不推测 session/schema/owner 成功、宿主显示或根因。不新增 observer、状态合同、内容字段、开关或 actionID，不改 RIME 部署边界。

本 C2 split 承接 C1 分阶段顺序：当前 Keyboard UI scope ACK、fresh inputs/sole writer、设备身份与 Human fresh exclusive window 在实施前满足；生产配对版本绑定、独立 exact-candidate Architecture/Quality、完整 paired CI、promotion、手动安装/Maps/Gates 留为未来依赖。C2 helper/adapter test bundle 运行不等于 appex 中实际实例/VC callback 被执行。不自动沿用 Stage B skip 接受，不改变永久责任分配或 global Exit。

root 为唯一 repo source/docs writer 与 Environment Executor；复用原 GPT6 Luna 作者在 private/tmp 草拟，是领域贡献者，不是独立 reviewer。精确独占目标为 iPhone 18 Pro / iOS 27.0，UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，本轮至验证结束。测试 runner 必需的自动安装/launch 在 scope 内；禁止手动安装、Maps、其他设备、下载网络、Release build、Git stage/commit/push/PR/merge、Gate/parent closure。
