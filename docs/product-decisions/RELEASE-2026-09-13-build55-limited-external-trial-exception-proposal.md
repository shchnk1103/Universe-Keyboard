# Product Decision Proposal: RELEASE-2026-0801 — Build 55 公开外部测试例外

**Decision ID:** `PD-RELEASE-2026-0801-B55-PUBLIC-EXTERNAL-TESTING-EXCEPTION`
**Lifecycle status:** `Accepted by Human Product Owner — public external testing execution authorized; not a formal Release Gate Pass`
**Date / timezone:** `2026-09-13 Asia/Shanghai`
**Assignment:** [`RELEASE-2026-0801`](../assignments/release-2026-08-01.md)
**Release evidence:** [`Build 55 public-beta readiness handoff`](../evidence/release-2026-09-13-build55-public-beta-readiness-handoff.md)

## Current Status

| Field | Value |
|---|---|
| **Status** | `Accepted — public external testing execution in progress` |
| **Decision** | 允许 Build `1.0 (55)` 以明确披露限制、公开链接的外部 TestFlight 试用形式先行收集反馈，并把未完成质量证据留到正式版前补齐 |
| **Candidate** | Store export `1.0 (55)`；来源 `main @ b8175129f26f787a6c7fee0be5977ebec46edf60`；RC tag `testflight-v1.0-rc2-build55` |
| **Current Quality/Release** | **Blocked**；本提案不改变独立 Quality/Release 复核结论 |
| **Non-claims** | 不声称性能基线、无崩溃、无 Jetsam、干净 App Group、Full Access 降级自诊断、完整恢复、iPad/低版本兼容或正式 Release 已通过 |
| **Next** | 按本决策进入 App Store Connect 外部测试配置、Beta Review（如平台要求）和公开链接分发；不进入 App Store 正式发布 |
| **Expiry** | 取最早者：Build 55 的 App Store Connect 过期时间、Product Owner 撤回、任一停止条件触发；执行时记录平台显示的具体日期 |

## Authority and boundary

本文件已根据 Human Product Owner 在当前任务中的明确授权改写并执行：“授权你将现有提案改写为‘Build 55 公开外部测试例外提案’，开始执行分发。”

该授权接受本文件列明的公开外部测试风险，并覆盖 App Store Connect 外部测试配置、Beta Review（如平台要求）和公开链接分发的执行；它不关闭 TD-003/004/005，不改变 `RELEASE_CHECKLIST.md`，不改变 Product Gate，也不等于 App Store 正式发布批准。
现有 [`RELEASE-2026-0801-EXTERNAL-TESTFLIGHT-CANDIDATE`](RELEASE-2026-0801-external-testflight-candidate.md) 仍然有效；它明确把 TD-003/004/005 作为外部候选 Gate。本文件是经 Product Owner 明确接受的渠道范围例外，不是对既有质量结论的静默修改。

若要改变 KOS 或 Release Checklist 的规则，仍必须另建对应的治理变更 Assignment；本文件只记录本次 Build 55 的渠道范围例外。

## Accepted decision and execution scope

接受一个**公开外部 TestFlight 试用例外**，而不是正式 Release：

1. 以已记录的 Store export `1.0 (55)` 作为候选，进入 App Store Connect 外部测试流程，并使用**公开链接**让符合 Apple TestFlight 条件的外部测试者加入；不扩大到 App Store 正式发布或其他渠道。
2. 将 TD-003 性能基线、TD-005 当前 Jetsam 分类/精确 Archive 身份边界、TD-004 完整共享能力/恢复矩阵和 clean App Group 证据标为“延期至正式版前补齐”，不把它们写成已关闭。
3. 仅保留当前已经有界验证的产品声明：Luna 26 键基本输入、雾凇下载/部署及九宫格候选提交路径；不把局部真机观察升级为整体质量承诺。
4. 要求试用说明明确 Full Access 必须开启；不宣称 Full Access 关闭时的降级、自诊断、共享诊断或恢复行为已验证。
5. 将试用反馈作为风险监测输入；任何崩溃、键盘退出/回退、数据损坏、隐私疑虑或部署异常都触发停止条件，而不是等待正式版再处理。
6. 公开测试不设置人工邀请上限；设备、系统和地区以 Apple TestFlight 的平台资格为准，但不因此扩展本文件的兼容性声明。

这是一项已接受的渠道范围例外。按当前 Release Checklist，TD-003 和 TD-005 对广泛外部 TestFlight 仍是默认阻断项；因此本决策标记为“公开外部测试例外”，不能标记为 `Release Gate Pass`。

## Approved public trial scope

以下范围是本次执行边界；平台执行结果和具体过期日期在分发记录完成后回填：

| Dimension | Approved boundary | Execution record |
|---|---|---|
| Channel | TestFlight external, public link；不进入 App Store 正式发布 | 记录外部组、公开链接状态和 Beta Review 结果 |
| Audience | 符合 Apple TestFlight 条件的公开外部 tester；不设置人工邀请上限 | 记录 Apple 平台限制；不把实际安装数解释为质量样本充分 |
| Build | Store export `1.0 (55)`；`testFlightInternalTestingOnly=false` | Release/Artifact owner 复核上传对象仍为该 SHA-256 包 |
| Device/OS | 允许 Apple TestFlight 公开测试者使用其平台支持的设备/系统 | 仅 iPhone 13 Pro / iOS 27 作为当前有界真机参考；不宣称 iPad、iOS 18 或其他组合已验证 |
| Schema | Luna 26 键与已验证的雾凇九宫格；不宣称万象 parity | 若加入其他方案，需重新定义证据范围 |
| Access | Full Access 必须开启 | What to Test / tester instructions 必须明确该前提 |
| User data | 不要求提交真实输入内容；反馈不得包含 host text、候选文本或隐私内容 | 指定反馈模板和隐私提醒 |
| Trial expiry | 取最早者：Build 55 App Store Connect 过期、Product Owner 撤回或停止条件触发 | 分发完成后记录平台显示的具体日期和复审人 |

## App Store Connect execution record — 2026-09-13

- External group `Build 55 Public Beta` was created under the Universe Keyboard App Store Connect record.
- Store export `1.0 (55)` was added to the group. App Store Connect currently reports `Waiting for Review` and `Expires in 90 days`; no tester has joined, and no install, session or feedback is recorded.
- The Beta Review form was submitted with `Sign-in required` disabled. The `What to Test` text records the Full Access prerequisite, the tested Luna/雾凇 paths, known evidence gaps and privacy-safe feedback boundaries.
- A public link was created with `Open to Anyone` and no tester limit: <https://testflight.apple.com/join/t48JR3Q3>.
- App Store Connect explicitly reports that testers cannot join the public link until the group has an approved build. The public entry point exists, but Build 55 is not yet publicly installable; this record does not claim Beta Review approval or a Release Gate Pass.

## Deferred evidence and explicit non-claims

### TD-003 — Extension performance

现有 Build 55 Time Profiler 记录是诊断采集，不是可比较的 Release-like 基线。延期不代表“性能正常”。正式版前仍需按 [`PERFORMANCE_BASELINE.md`](../PERFORMANCE_BASELINE.md) 采集同一设备/系统/宿主/方案/权限条件下的冷暖启动、首键、连续输入、候选刷新和内存趋势，并报告多次运行的中位数、最差观察值和样本数。

### TD-004 — Full Access and shared capability

现有 off/on 结果只能保留局部行为观察：基本输入、候选提交、声音和震动差异；它没有关闭共享诊断、降级提示、重启持久化、恢复、resource-not-ready 或干净状态边界。若采用本提案，试用范围必须要求 Full Access on，并删除“关闭权限后仍完整可用”或“自动发现并修复降级”的宣传性声明；这不是 TD-004 Close。

### TD-005 — Crash, Jetsam and symbolication

三条含 Build 55 UUID 的 Jetsam 记录没有 victim/reason 标记，继续保持 `unclassified`；不得把进程存在、状态或内存页数解释为 Keyboard 被终止，也不得在没有因果 victim 证据时强行 symbolication。现有 Archive/export 回执只支持条件性候选关系：导出包是 `1.0 (55)`，保留 Archive/dSYM 元数据是 `1.0 (1)`。若当前 Release policy 要求精确 Archive 身份，仍需真正内嵌 `CFBundleVersion=55` 的 Archive/dSYM。

### Fresh-install and App Group

已有卸载/重装、首次引导、键盘添加、Full Access 和方案部署观察不等于干净共享容器证明。App Group、RIME 和用户词典没有被读取或清理，因此本试用不宣称 clean install 或 clean App Group 行为；正式版前需由 Human 单独授权相应边界。

## Risk register and mitigations

| Risk | Current state | Proposed mitigation | Owner |
|---|---|---|---|
| 性能回归无法比较 | TD-003 Blocked | 限定为试用反馈监测；不做性能承诺；出现明显卡顿、键盘退出或持续输入异常立即停用 | Quality / Performance |
| 崩溃/Jetsam 因果不明 | TD-005 Blocked；Jetsam `unclassified` | 反馈模板只收集版本、设备、系统、权限和复现步骤；不收集输入内容；异常触发停止与新证据切片 | Crash/Jetsam owner |
| Full Access 关闭后的共享能力未知 | TD-004 部分观察 | 试用前置要求 Full Access on；不宣传 off 状态的完整能力或自诊断 | App / Onboarding / Diagnostics |
| 旧容器污染或方案状态差异 | clean App Group `UNKNOWN` | 不宣称干净首次安装；反馈中记录方案和权限状态；正式版前另做清洁边界 | App/Data + RIME owner |
| Archive/dSYM 与导出构建号分层 | 关系条件性接受 | 保留 `Archive=1`、导出 `buildNumber=55` 的差异；不把目录名当作精确 Archive 证明 | Release/Artifact owner |
| 外部渠道误读为正式发布 | 当前 Quality/Release Blocked | 所有文案标注“公开外部测试例外”；不声称 Release Gate Pass 或 App Store 正式发布 | Product Lead / Release owner |

## Stop conditions

在执行本决策后，以下任一情况都应停止继续公开分发 Build 55，并由 Product/Release owner 重新裁决：

- 可复现的崩溃、键盘 Extension 退出、系统键盘回退或明显输入卡死；
- 候选提交错误、输入内容丢失/重复、RIME 方案损坏或部署后无法恢复；
- 发现隐私数据进入诊断、反馈、同步包或外部渠道；
- 反馈显示 Full Access 前置条件未被理解，或实际行为与试用说明矛盾；
- App Store Connect / Beta Review 对该例外范围提出阻断；
- Build 55 被替换、签名/包哈希变化、Archive/export 关系变化或任何新构建被误当成同一候选；
- 试用有效期到期，或 Product Lead 撤销例外。

## Rollback / withdrawal

若触发停止条件，Release owner 应关闭公开链接并撤回 Build 55 的外部试用资格；不自动把 Build 7 或其他构建当作替代品，也不在本决策中授权删除证据、清理设备或发布新包。后续候选必须重新核对来源、包哈希、质量门禁和 Product/Quality/Release 结论。

## Execution record and remaining gates

以下事项不再是公开测试开始前的前置批准，但必须在执行记录或后续正式版决策中保留：

1. App Store Connect 外部组、公开链接、Beta Review（如平台要求）及平台显示的过期日期；
2. What to Test、Beta Review notes 和 tester feedback 模板中的限制性声明；
3. Release/Artifact owner 对 Build 55 Store 包、SHA-256、上传对象和当前条件性 Archive/export 关系的执行核对；
4. TD-003、TD-004、TD-005、clean App Group 的延期处置、负责人和正式版前的补证计划；
5. 公开测试结束或停止时的链接关闭、Build 撤回和后续候选重新核对记录。

## Formal-release follow-up

正式版候选前必须重新裁决以下事项：

- 获得可比的 TD-003 真机 Release-like 性能、候选和内存证据；
- 保留并核对精确 Build 55 Archive/dSYM，或由 Release policy owner 明确记录等价的身份处置；
- 对当前 Jetsam 重新获取足够的 victim/reason 证据；没有该证据就继续 `unclassified`；
- 完成 TD-004 共享能力/恢复矩阵及 clean App Group 边界，或由新的 Product Decision 明确收窄正式版声明；
- 重新进行独立 Quality/Release review，并单独作正式 Release Gate 决定。

## Related Documents

- [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md)
- [`RELEASE-2026-0801 external TestFlight candidate`](RELEASE-2026-0801-external-testflight-candidate.md)
- [`Build 55 public-beta readiness handoff`](../evidence/release-2026-09-13-build55-public-beta-readiness-handoff.md)
- [`Build 55 Archive ↔ export reconciliation`](../evidence/release-2026-09-13-build55-archive-export-reconciliation.md)
- [`Build 55 Quality/Release re-review`](../reviews/release-2026-09-13-build55-quality-release-re-review.md)
- [`Build 55 TD-003 follow-up`](../evidence/release-2026-09-13-build55-td003-cold-warm-diagnostic.md)
- [`Build 55 TD-004 matrix`](../evidence/release-2026-09-13-build55-td004-full-access-matrix.md)
- [`Build 55 TD-005 classification follow-up`](../evidence/release-2026-09-13-build55-td005-classification-follow-up.md)
- [`Human-operated evidence profile`](../kos/universe-keyboard-human-operated-evidence-profile.md)
