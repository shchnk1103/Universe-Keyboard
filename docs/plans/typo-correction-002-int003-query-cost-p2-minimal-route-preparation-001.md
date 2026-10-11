# INT003 P2 最小验证准备

Status: Proposed

合同及路线已获 Human 批准；本文是具体执行准备，未释放运行 AUTH，不授权操作模拟器。

## Proposed work-package handoff

- Triggering evidence: 大型 ATRC 两次读取未成功；Human 批准收窄 P2 合同，将持久化/UI 等增强延期。
- Frozen facts and unknowns: source HEAD `72dd21710f2a86c9f951d489f645bae89b053b58`；23 路径 candidate SHA `fea38d21ff8712c38e56fc0835eab5c6415bfa04b18e36597e6472f8280083fa`。已安装 B5 的 78 文件绑定是历史事实，当前设备/进程身份和实际内存导出尚未重验。
- Decision to preserve: [批准合同](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md)的精确计数、数值和隐私边界；父 Active。
- Proposed seam and alternatives rejected: 现有 probe → freeze → LLDB 两份有限字节副本 → strict decode。无新增存储或 UI，无大型 trace；避免强制单独空快照 Run 消耗唯一 arm。
- Verification matrix: 见下表；fixture、实际命令/decoder 和运行预算须在执行 AUTH 中完整冻结。
- Stop conditions and non-goals: 首工具/身份/完整性异常即停止并记 Partial，不自动重试；无 build/install/source edit/Gate/发布。
- Required authorization and reviewers: Human 已批准合同/路线和本次 docs 同步；下一运行 AUTH 绑定 root Environment Executor、Human 手动输入及当前独占、独立 Test / Release 证据 reviewer。合同收窄不重开完整 P1 审查；证据审查覆盖新增 Run/transport 的实际缺口。

## 最小流程与覆盖

| 阶段 | 工作及准入 | 证据限制 |
|---|---|---|
| 静态准备 | 复用相关文件未变的 synthetic R4/R5；固定 source 与 B5 manifest；整理旧六类输入 fixture、实际命令和 strict decoder | 不因 main 更新自动重编译；旧审查不证明当前 runtime |
| Run 前置 | Human 当前确认 405D994F-28CB-4F89-BB22-B64AD81C05A2 / iPhone 18 Pro / iOS 27.0 独占；绑定实际安装/loaded UUID/PID、Full Access、Luna、宿主和有限 prefs presence/type/value | 历史 PID/开关回执不能当作当前事实；新进程 session=0 时 arm 会拒绝，正常预热输入须明确授权，不能用调试器创建 session |
| 一次输入测量 | 一次 arm；建议六类 fixture 各作 first-observed 与 warm，共 12 个闭合 observed 序列，精确输入及序列语义冻结后执行；自然输入，不设 180ms 通过条件 | 不声称真正冷启动；未armed控制段不提供查询计数，无外部 A0/A1/A2 性能归因 |
| 同 Run 传输验证 | 测量结束、所有序列闭合且空闲后附加一次 LLDB，设置 exportReady 断点、恢复，然后 Human 点击“成本取证”；用 frame variable 取得实际地址/长度，在同一次有效借用内读两份 | 不执行任意 engine 表达式，不跨借用复用地址；无成功传输回执之前不得宣称可用 |
| 本地核验 | 每份 256..655616 字节，并满足 256+160×recordCount；两份一致/hash，严格 header/record/计数/完整性核对；继续执行并 detach -s false，核对同 PID 非 T/Z 和 prefs 不变 | 161216 只是旧合成 fixture 大小，不作生产上限；暂停时间排除出输入窗口 |
| 独立结论 | Test / Release 对 Run、身份、精确统计和 transport receipt 作限定审查；Product 再决预算/残项 | 缺失不是零；不完整不能称 exact total，不自动 Gate/父关闭 |

一次正式 Run 与导出合并验证，不新增“先做空快照，再做正式采集”的必需步骤。生产 probe 每进程只有一次 arm，不能 reset/rearm；失败后只保存 receipt，后续是否再试由新的具体决定处理。

当前尚未释放执行 AUTH：输入 fixture、命令/decoder、运行时长及产物归档预算须先完整绑定，不能把本准备文档当作执行命令。无需当前让 Human 输入，也不操作其他模拟器。

## 复用来源与延期项

- [现有 transport 准备](typo-correction-002-int003-query-cost-p2-memory-payload-transport-preparation-001.md)：复用同次字节借用、有限读取及 detach 安全边界；其独立空快照 B1 与外部 profiler C 不再是本轮强制阶段。
- [R4 独立核对](../reviews/typo-correction-002-int003-query-cost-p2-memory-review-delivery-completion-001-quality-r4.md)与[R5 callsite 核对](../reviews/typo-correction-002-int003-query-cost-p2-memory-callsite-review-completion-001-quality-r5.md)：只复用身份/覆盖仍适用的既有事实。
- [延期增强设计](typo-correction-002-int003-query-cost-p2-local-evidence-design-001.md)：存储协议、目录所有权、配额、保留策略和 UI 不进入当前 Exit Criteria。
- CPU、主线程停顿、内存归因及真实总体 observer 影响未验证，保留在父任务 Gate 前的证据/范围决策边界，不伪装成通过。
