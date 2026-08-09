# Assignment: KEYBOARD-STARTUP-PERF-001 — 首帧 RIME 启动与配置读取修复

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` — 等待真机复现证据以证明幽灵按键/短暂候选边界 |
| **Phase** | Executor 诊断实现与自动化验证完成 |
| **Non-claims** | 不调换 librime vendor、不改 RIME 方案/候选语义、不作性能 SLO 或物理机通过声明 |
| **Next** | Human Product Owner 捕获一次复现日志；根因证明前不做行为修复 |
| **Residuals** | 幽灵按键/短暂候选的实际边界尚未证明；真实设备 Time Profiler 与热状态对比尚未采集 |

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner 在当前 Codex task 授权“先修复主线程 ownerReady 等待与 16 次资源扫描”，`2026-08-09 Asia/Shanghai`。
- Product Approver: Human Product Owner / Product Lead

## Boundary

- Scope:
  1. 使 thread-affine RIME owner 的首次启动不阻塞 Keyboard MainActor，并保持会话工作 FIFO、受限入队与可见性失效语义。
  2. 将主 App 设置读取所需的运行时目录解析与会写入/枚举资源的部署准备分开，禁止 layout/readiness 计算属性触发后者。
  3. 为以上边界补充最小的 KeyboardCore 与主 App 回归测试。
  4. 在首次可见时让 RIME owner 等待键盘跨过受测的首帧显示节拍，避免与 UIKit 首帧竞争 CPU / I/O；保留不可见时释放 session 的合同。
  5. 为微信等宿主中的短暂按键高亮/候选现象加入 Debug-only、内容无关的触摸、候选结构与生命周期诊断；不改变生产行为。
- Non-goals:
  - 不把部署、修复或资源写入移入 Keyboard Extension。
  - 不丢弃、合并或重排用户输入；不显示伪造 RIME 候选。
  - 不改动 librime 二进制、词库、schema、RIME 配置行为或设置 UI 文案。
  - 不宣称真实设备、温控、Release 或 Product Gate 已通过。
- Required Inputs: `PERFORMANCE_BASELINE.md`、共享容器生命周期、ADR 0004 / 0025、`DEBUGGING.md`、RimeBridge / Main App UI / Keyboard UI playbooks，以及本 task 的内容无关诊断日志。

## Assignment

- Domain Owner: 🔧 RIME Platform Maintainer
- Executor: Current Codex agent
- Environment Executor: Current Codex agent（本地与 Simulator 自动化）；Human Product Owner（可选物理机验证）
- Human Dependency: Human Product Owner 仅在后续物理机首帧与热状态复测时执行
- Architecture Reviewer: 🏛️ Architecture & Knowledge Steward（独立复核）
- Quality Reviewer: 🧪 Quality, Performance & Release Maintainer（独立复核）

## Gates

- Entry Criteria:
  - [x] 已有三次冷启动的内容无关诊断记录。
  - [x] 已确认启动等待与读取路径的静态调用链。
  - [x] 本范围不改变部署所有权或输入语义。
- Exit Criteria:
  - [x] 首帧 owner bootstrap 不在 MainActor 同步等待 RIME session 创建。
  - [x] 启动前接受的 printable key 仍以 FIFO 进入同一 owner，且完成后可发布真实快照。
- [x] layout/readiness 读取不会调用 `prepareDirectories()`。
- [x] RIME owner 仅在两次显示节拍后启动；在门控尚未通过时的可见性退出会取消 display link，因而不会打开 session。
- [x] 诊断能区分 UIKit 触摸终端、Core 候选结构、UIKit 候选缓存与宿主生命周期清理，且不记录输入或候选文本。
- [x] 针对性自动化测试与受影响 target 测试通过。
- Stop Conditions:
  - 需要改变 RIME 方案、候选/Path 产品语义、可见性遗弃合同或部署所有权。
  - 任一路径可能丢失、重排、意外提交用户输入，或需使用不安全并发隔离。
  - 自动化测试显示 owner 未就绪期间的队列不能安全收敛。

## Handoff

- Handoff Target: 独立 Architecture / Quality 复核，随后 Human Product Owner 决定是否进行一次物理机对比。
- Required Handoff Content: 改动范围、测试输出、MainActor 等待移除证据、部署准备调用计数回归、未做的物理机证据。
- Revalidation Trigger: RIME owner 生命周期、布局迁移、部署 API 或 `prepareDirectories()` 再被调用方修改。
