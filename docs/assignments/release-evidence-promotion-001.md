# Assignment: RELEASE-EVIDENCE-PROMOTION-001 — 发布证据增量与候选晋级

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Phase | P1/P2 修复已完成；本地质量门已重验，Architecture re-review 已 Accept，Quality re-review 为 Conditional Accept；等待 final-SHA/实际 base-head provenance 与 Human Product Owner 决策 |
| Non-claims | 不宣称 Product Gate、Quality Pass、Release Pass、App Store Connect、TestFlight 或真机验收已完成 |
| Next | 如需形成可合并提交，先取得单独 commit 授权并以实际 base/head 保存 CI/lightweight provenance；随后由 Human Product Owner 决定是否采纳为日常发布流程 |
| Residuals | `REP-Q-01`：当前工作树没有 final SHA，尚未形成实际 final base/head 的 hosted provenance；真实 archive/export、外部专属检查、设备操作和正式发布仍在本 Assignment 之外 |

### Review Residual Ledger

| ID | Residual / exit condition | Owner | Disposition | Evidence pointer |
|---|---|---|---|---|
| `REP-P1-01` | pending artifact match 不能形成 UI 或 receipt 的通过结论（已由两次独立复审闭合） | App & Data Operations | `fix` | `ReleaseEvidenceRun.outcome`、pending promotion tests、[Architecture re-review](../reviews/release-evidence-promotion-001-architecture-rereview.md)、[Quality re-review](../reviews/release-evidence-promotion-001-quality-rereview.md) |
| `REP-P1-02` | current-proof 必须绑定最小 artifact identity、行为契约、验证档位、候选/版本/构建、设备/系统、证据契约和 freshness（已由 Architecture Accept、Quality Conditional Accept 闭合） | App & Data Operations + Test/Release | `fix` | `release_evidence.py` context validator/current-proof tests、两份 re-review 记录 |
| `REP-P1-03` | 首次 external 必须有 verified baseline plan；后续 external 必须有 previous receipt 及 digest（已闭合） | Test/Release tooling | `fix` | `receipt_payload` fail-closed tests、Quality re-review |
| `REP-P1-04` | ADR 0027 必须声明 release-evidence 子空间 owner、生命周期、clear 隔离与恢复合同（已闭合） | Architecture + App/Data | `fix` | ADR 0027 ownership row、clear isolation test、两份 re-review 记录 |
| `REP-P2-01` | 损坏 archive 必须可恢复保存且保留原始副本（已闭合） | App & Data Operations | `fix` | quarantine/recovery test、Quality re-review |
| `REP-P2-02` | evidence note 必须有持久化长度上限，并覆盖旧数据解码（已闭合） | App & Data Operations | `fix` | bounded note 与 legacy archive fixture、Architecture re-review |
| `REP-Q-01` | 形成明确 final SHA 后，使用实际 base/head 保存 hosted CI/lightweight provenance | Executor / App & Data Operations | `fix` | Quality re-review handoff；等待单独 commit/hosted CI 授权 |

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner 当前会话授权“开始实施改进工作”，2026-09-14 Asia/Shanghai
- Product Approver: Human Product Owner / Product Lead
- Authorization: AUTH-RELEASE-EVIDENCE-PROMOTION-001

## Boundary

### Scope

1. 增加 repository-local release evidence planner，按变更路径生成 baseline、triggered 或 delta 验证计划。
2. 保留现有 CI 质量门禁的独立职责：源代码或工程改动仍由现有 CI 分类判为 full；release profile 不得跳过 CI。
3. 增加 candidate fact receipt 和 daily Beta → external candidate promotion 逻辑：
   - 五个最小 identity 字段（source commit、version、build、archive SHA-256、package SHA-256）完整一致，且证据上下文 fresh 且相容时才可复用为 current-proof；
   - rc tag、UUID、dSYM、toolchain 等 provenance 字段单独记录，不替代最小 identity；
   - 新构建只能把同版本 Beta 证据作为 comparator；
   - 不一致或未知身份不得冒充可复用证明。
4. 在 Main App 诊断设置中增加发布证据页面，记录候选标识、版本/构建、设备/系统、验证档位和内容无关的有限结果。
5. 将记录保存在 Main App 所有的 App Group release-evidence 文件中，使用有界数量和原子写入；清空诊断日志不删除发布证据。
6. 为存储、结果降级、候选标识和 promotion boundary 增加自动化覆盖，并更新发布/KOS 路由文档。

### Non-goals

- 不上传 archive、package、诊断日志或任何键盘内容。
- 不自动执行 App Store Connect、TestFlight 分组、Beta Review、commit、push、merge 或 Release。
- 不把证据记录或 promotion 结果升级为 Quality、Product 或 Release 通过。
- 不改现有 scripts/ci/classify_changes.py 的 CI 分级合同，不以 release delta 替代 CI full。
- 不把设备上的物理操作、真实 archive/export UUID、dSYM 核对或外部测试资格伪造成 App 内自动结果。
- 不向 Keyboard Extension 热路径增加文件 I/O、App Group 读取或等待 actor。
- 不批量迁移历史 Build 7 / Build 55 证据；历史记录仍按原候选事实元组解释。

## Assignment

- Domain Owner: App & Data Operations Maintainer
- Executor: Current Codex task
- Environment Executor: Current Codex task（本地脚本、单元测试、Simulator/build 验证）
- Human Dependency: 本实现切片不需要设备、账户或外部服务；后续真实 archive/export 录入与设备/外部候选验证另行授权
- Architecture Reviewer: 独立 Architecture & Knowledge Steward
- Quality Reviewer: 独立 Quality, Performance & Release Maintainer
- Handoff Target: Architecture review → Quality review → Human Product Owner / Product Lead

## Gates

### Entry Criteria

- [x] 需求已明确为“按变更增量验证”，并保留首次/高风险变更的 baseline 路径。
- [x] 需求已明确正式外部候选可沿用日常 Beta 证据，但必须经过产物身份和合同边界核对。
- [x] 现有诊断日志的 Main App owner、隐私边界和输入热路径约束已核查。
- [x] 本切片拥有独立 bounded Assignment，不复活已 Completed/Closed 的历史 Assignment。
- [x] 变更不包含上传、分发、审核、commit 或 push 授权。

### Exit Criteria

- [x] release planner 对普通、触发、基线和 docs-only 路径有确定性输出，并明确 CI 独立 full 门禁。
- [x] candidate receipt 能保留未知字段，不能把未知字段判为 exact artifact；identity 与 provenance 字段边界明确。
- [x] promotion 在 exact artifact 之外保持 pending/comparator/none；current-proof 还需通过证据上下文、候选绑定和 freshness 校验。
- [x] external receipt 对首次 verified baseline 与后续 previous receipt fail closed；缺少二者不能生成正式 external receipt。
- [x] Main App 证据会话能有界、原子、可读地保存和导出，不包含用户内容。
- [x] pending external 会话不会因手工标记步骤而显示总体通过；损坏 archive 可隔离恢复，备注长度有界，诊断清除不删除 release-evidence。
- [x] 发布清单、建议稿、架构 ADR、Product Decision、Authorization、Active Work 和 Knowledge Index 已互相链接。
- [x] Swift 格式、相关单元测试、KeyboardCore、RimeBridgeTests、App + Keyboard tests、Debug/Release build 已按本轮修复后的仓库门禁重验；条件性设备/Spike 用例的跳过原因保留在测试输出中。
- [x] 独立 Architecture re-review 与 Quality re-review 完成；两者均未授予 Product/Release 权限。
- [ ] 形成明确 final SHA 后保存实际 base/head 的 CI/lightweight provenance；该项需要另行 commit/hosted CI 授权。
- [ ] Human Product Owner 决定是否将 Proposed 设计纳入日常发布合同。

### Stop Conditions

- 需要以 release profile 为理由跳过现有 CI、设备、签名或正式门禁。
- 候选事实元组、证据记录或导出可能含输入内容、宿主文字、候选文字、词典或完整日志。
- 需要在 Extension 或按键热路径写盘、读 App Group、等待 actor 或引入不安全并发隔离。
- promotion 将新 build 的旧证据标为当前证明，或把 pending/partial 结果升级为通过。
- 需要新增账户、凭证、网络连接或外部服务权限才能完成本地切片。

## Handoff

- Required Handoff Content: 变更分类规则、CI 独立边界、五字段 identity 与 provenance 区分、candidate context/current-proof/freshness 语义、首次/后续 external baseline 证明、Main App 存储位置与上限、损坏恢复与 clear 隔离、隐私 allowlist、自动化结果、未执行的设备/外部检查。
- Initial Review Records: [Architecture review](../reviews/release-evidence-promotion-001-architecture-review.md)（Conditional Accept） · [Quality review](../reviews/release-evidence-promotion-001-quality-review.md)（Blocked）。
- Final Review Records: [Architecture re-review](../reviews/release-evidence-promotion-001-architecture-rereview.md)（Accept，仅限修复范围） · [Quality re-review](../reviews/release-evidence-promotion-001-quality-rereview.md)（Conditional Accept，开放 `REP-Q-01`）。两份记录均为独立 Reviewer 的只读结论。
- Revalidation Trigger: release profile 规则变化、artifact identity 字段变化、证据有效性合同变化、App Group 文件 owner 变化、日志隐私边界变化、外部动作授权变化或正式采纳 ADR。

## History

- 2026-09-14: Human Product Owner 授权开始实施本有界切片。当前实现仍处于本地验证与独立复核前，不能被视为发布授权。
- 2026-09-14: 本地实现、脚本/Swift 自动化、完整 Simulator CI 等价门禁完成；转交独立 Architecture / Quality Reviewer，未执行真机或外部发布动作。
- 2026-09-14: 独立 Architecture 结论为 Conditional Accept，独立 Quality 结论为 Beta → external current-proof Blocked；登记 `REP-P1-01`–`REP-P2-02`，进入本 Assignment 内 P1/P2 remediation，ADR 0035 仍 Proposed。
- 2026-09-14: 完成 pending fail-closed、current-proof context/freshness、external baseline/history fail-closed、archive quarantine、note bound 与 Diagnostics clear isolation 修复；本地质量门和独立 re-review 待完成。
- 2026-09-14: 修复 target candidate ID binding 与 legacy archive fixture；Architecture re-review Accept，Quality re-review Conditional Accept；`REP-P1-01`–`REP-P2-02` 闭合，新增 `REP-Q-01` 作为 final-SHA/实际 base-head provenance residual。ADR 0035 仍 Proposed，未执行 commit、push、merge 或外部发布。
