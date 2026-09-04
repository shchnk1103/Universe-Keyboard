# RIME-BUILTIN-LUNA-QUALITY-001 — 独立 Quality / Performance / Release 审查

| 字段 | 内容 |
|---|---|
| 审查日期 | 2026-08-29（Asia/Shanghai） |
| 审查角色 | Quality, Performance & Release Maintainer（独立审查） |
| 审查工作树 | `/tmp/universe-keyboard-f02-assignment` |
| 审查基线 | `origin/main` / `7f20f3a`；当前只读审查分支 tip `562c85e` |
| 审查范围 | 验证计划、证据门槛、当前实现的可验证性和发布风险；没有实现代码或资源变更，没有提交。 |
**明确排除：** PR [#91](https://github.com/shchnk1103/Universe-Keyboard/pull/91)（包括 `e3e5d77`）不在本 Assignment 范围内；本审查不判断其合并与否。

## Current Status

| 字段 | 内容 |
|---|---|
| **Lifecycle** | Assignment `Active`；本文不是 Assignment SoT |
| **Verdict** | PR [#98](https://github.com/shchnk1103/Universe-Keyboard/pull/98) 本片 Quality packet：`Pass with conditions`。Assignment Exit / TestFlight / Release 仍为 `Fail`（未授权）。无 merge AUTH。 |
| **Reviewed HEAD** | PR [#98](https://github.com/shchnk1103/Universe-Keyboard/pull/98) `eedc4a7`（实现 `9309a0d`） |
| **Non-claims** | 无 merge、Exit、TestFlight、Release、法律充分性、Q-03 四输出、Q-06 严格 fault-injection、Q-07 release-like 性能闭合；搜索页网络弹窗未定性 |
| **Next** | Coordinator / Product Lead：Architecture 复审对齐后决定是否申请 merge AUTH。搜索页原文案仍待 Human。 |
| **Residuals** | 见 [`eedc4a7` 复审](#independent-quality-re-review--eedc4a7--2026-09-04) |

> **S-03（2026-09-04）：** 文末 [`ecd3446`](#independent-quality-re-review--ecd3446--2026-09-03) addendum 是 PR [#93](https://github.com/shchnk1103/Universe-Keyboard/pull/93) 的历史结论，**不得**复用为本 PR [#98](https://github.com/shchnk1103/Universe-Keyboard/pull/98) / `eedc4a7` 的 Quality verdict。当前审查结论以 [`eedc4a7` addendum](#independent-quality-re-review--eedc4a7--2026-09-04) 为准。Exit / TestFlight / Release `Fail` 仍有效。

## 结论

**阶段化结论（生命周期 addendum 见文末）：**

- **Pre-implementation / Ready-plan Quality review：`Pass with conditions`。** 验证计划在补齐下文的 Ready 前条件后，可以授权进入实现阶段；这不是实现或运行时证据通过。
- **当前实现 / Assignment Exit / TestFlight / Release gate：`Fail`。** 现有代码和证据仍不能证明修复完成，也不能进入发布门禁。
- **Assignment lifecycle：仍为 `Assignment Pending`。** 本文不替代 Architecture 接受 ADR 0033、Product Lead 的生命周期转换或 Human Product Gate。

原 `Fail` 结论仅针对当前实现、Exit 和 Release 证据包，不应被解释为在验证计划足够后仍禁止开始实现。两个 Product Decision 已明确选择“官方朙月拼音运行时闭包 + 薄的 iOS overlay、全部离线内置、无用户下载”；但实现、生成物、失败回滚、许可证和真机 Release-like 证据仍未闭环。现有设备材料足以确认候选质量问题是真实产品风险，却不能证明修复已经完成。

本次审查的最重要发现是：

1. 当前 smoke 只验证“有汉字候选”，不能阻止 `ni` 返回截图中那类罕见字作为 Top-1；它没有覆盖 `nihao`、`sanjiaoxing`、首屏顺序、模糊音开关、OpenCC 或笔画反查。
2. 当前资源仍主要由 `Keyboard/Resources` 提供给 `Keyboard.appex`，而 Assignment 要求由主 App 一次部署、Extension 只消费；资源清单也没有 Essay、Prelude、Pinyin、Stroke 和完整 OpenCC 配置/源数据闭包。
3. 当前缺失资源路径会把 `fallbackDict` 写入请求的目标文件名，甚至可能是 `.bin` 或 `.ocd2`；复制判断按字节数而非 SHA-256，不能满足“缺失/损坏失败且保留 last-good”的安全门槛。
4. 现有设备证据的精确安装 commit/build 为 `UNKNOWN`；候选上游 pin 仍被证据明确标为 candidate，不是已接受的生产 pin。`ensure_rime_vendor.sh verify` 在本审查环境缺少 12 个框架，完整 Rime 运行时门禁尚未可复核。

## 依据与方法

已按仓库入口和对应 playbook 读取并交叉核对：

- [`AGENTS.md`](../../AGENTS.md)、[`KNOWLEDGE_INDEX.md`](../KNOWLEDGE_INDEX.md)、[`ACTIVE_WORK.md`](../ACTIVE_WORK.md)、[`READING_MAPS.md`](../READING_MAPS.md)；
- [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)、KOS 2.1 operational maturity、[`test-release` playbook](../playbooks/test-release.md)、[`rime-bridge` playbook](../playbooks/rime-bridge.md)；
- [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md)、[`PERFORMANCE_BASELINE.md`](../PERFORMANCE_BASELINE.md)、文档治理规则；
- F-02 Assignment、两个 Product Decision、两份 F-02 evidence；
- Rime 部署/资源复制/自定义 YAML/Extension 资源定位、runtime smoke、RimeBridge contract tests、license catalog 和 SchemaManager deployment 源码。

本次只做了静态交叉核对，以及一次只读的 `bash scripts/ensure_rime_vendor.sh verify`。没有改动主工作区，没有访问或改变 PR #91，没有运行真机操作，也没有把未运行的门禁写成通过。

## 现有证据矩阵

以下是已经存在且本审查可以定位的证据。`M-04` 只使用 KOS 允许的三种证据等级：`Executor-recorded`、`Quality-reverified`、`Device-attested`。它们不是同一层级，不能互相替代。

| ID | 证据等级 | 已观察事实 | 精确来源 / 可复核定位 | 对 F-02 的判断 |
|---|---|---|---|---|
| E-01 | `Device-attested` | iPhone 13 Pro、iOS 27.0（24A5424a）的当前修复后设备上，模糊音开/关两组都能输入 `sanjiaoxing → 三角形`；`ni`、`nihao` 的候选首项仍明显不符合正常用户预期。 | [`rime-builtin-luna-quality-f02-2026-08-29.md`](../evidence/rime-builtin-luna-quality-f02-2026-08-29.md) §Human A/B Results；用户提供的 `IMG_7939`–`IMG_7945` | 通过“问题仍可见”的诊断目的；不是修复通过。 |
| E-02 | `Quality-reverified` | 设备材料没有独立记录精确安装 commit/build，明确为 `UNKNOWN`；PR #91 `e3e5d77` 只作为排除范围信息。 | 同上证据文档 §Build / provenance table | 阻塞 Release-like 归因和回归结论。 |
| E-03 | `Quality-reverified` | `7f20f3a` 的 `Keyboard/Resources` 只有当前 schema、旧版 Luna dict、3 个 Luna bin 和 4 个 OpenCC `.ocd2`；没有 Essay、Prelude、Pinyin、Stroke 及完整 JSON/data 闭包。旧 Luna dict 约 282,450 bytes，证据还记录 decompiled table 仅 225 entries。 | F-02 evidence §Checked-in resource audit；`rg --files Keyboard/Resources` | 不满足批准的官方完整运行时闭包。 |
| E-04 | `Quality-reverified` | `SchemaArchiveInstaller.deploymentDirectories()` 从 `Bundle.main.builtInPlugInsURL/Keyboard.appex` 获取资源，再调用 `prepareDirectories(resourceBundle:)`；当前资源归属与“主 App 部署、Extension 只消费”边界不一致。 | [`SchemaArchiveInstaller.swift`](../../Universe%20Keyboard/Services/SchemaArchiveInstaller.swift) 148–159；[`RimeConfigManager+DeploymentResources.swift`](../../Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+DeploymentResources.swift) 31–64 | 阻塞资源所有权和无重复副本验收。 |
| E-05 | `Quality-reverified` | 部署写入模板 `default.yaml` / `installation.yaml` / Luna schema，并只复制一套 dict/bin；OpenCC 只写 `t2s.json`、`s2t.json` 和 4 个 `.ocd2`。复制缺失时写 `fallbackDict`，现有比较只看 size。 | [`RimeConfigManager+DeploymentResources.swift`](../../Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+DeploymentResources.swift) 42–75、146–173 | 缺失、损坏、来源不匹配不能安全失败；阻塞 rollback gate。 |
| E-06 | `Quality-reverified` | runtime smoke 的 `passed` 条件是 schema 选中、composition/raw input 存在、候选数大于 0、任一候选含汉字且无意外 commit；实际 `run` 只输入 `ni`。 | [`RimeSchemaRuntimeSmokeProbe.swift`](../../Packages/RimeBridge/Sources/RimeBridge/RimeSchemaRuntimeSmokeProbe.swift) 5–18、21–75 | 不能识别错误 Top-1、错误首屏顺序、`nihao`/`sanjiaoxing`、模糊音或 OpenCC 回归。 |
| E-07 | `Executor-recorded` | Luna / Essay / Prelude / Stroke / OpenCC 的上游 commit、文件 byte length、SHA-256 已列为 candidate manifest；证据明确写明尚未成为 accepted production pins，生成物 receipt 尚缺。 | [`rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md`](../evidence/rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md) §Candidate pins、§Source manifest、§Generated artifacts | 可作为输入审计起点；不能作为生产来源证明。 |
| E-08 | `Quality-reverified` | 本审查执行 `bash scripts/ensure_rime_vendor.sh verify` 失败，缺少 12 个框架：boost_atomic、boost_filesystem、boost_regex、libglog、libleveldb、liblua、libmarisa、libopencc、librime-lua、librime-octagram、librime、libyaml-cpp。 | 当前隔离工作树命令输出；对应 [`scripts/ensure_rime_vendor.sh`](../../scripts/ensure_rime_vendor.sh) | 当前环境不能复核真实 Rime runtime / OpenCC / 生成物门禁；不是把环境失败误报为产品通过。 |
| E-09 | `Quality-reverified` | 现有 `RimeEngineContractTests` 使用 `RimeConfigTemplates.fallbackDict` 构造 functional fixture；test 只观察部署服务成功和 generic smoke。 | [`RimeEngineContractTests.swift`](../../Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift) 426–489、593–640 | 这是部署协议回归，不是官方完整闭包或候选质量验收。 |
| E-10 | `Quality-reverified` | license catalog 目前有单一 Luna descriptor，并把 GPL-3.0 文档、Luna 归因等放在同一条；未见 Essay、Prelude、Stroke 的独立来源/许可证条目。 | [`ThirdPartyLicenseDescriptor.swift`](../../Universe%20Keyboard/Models/ThirdPartyLicenseDescriptor.swift) 70–90、92–189；upstream pin audit §License disposition | 许可证与归因 gate 未闭环，不能作法律充分性声明。 |

## 必须补齐的 Quality evidence matrix

下表是下一次 Quality review 必须收到的**可执行证据**，不是对当前状态的通过声明。每行在真正执行后须填入唯一的 M-04 等级、精确 commit/build、环境、命令或设备操作、结果和 receipt 路径；没有这些字段时应保持 `UNKNOWN`，不能用“测试绿”替代。

| Gate ID | 必须验证的接受谓词 | 必须保留的精确 receipt | 当前状态 / 责任 |
|---|---|---|---|
| Q-01 闭包和 target | 空 App Group、首次安装、飞行模式下，仅使用 App 内置资源完成部署；所有必需源文件和 generated files 都能从清单解析，Extension 不含第二份运行时副本。 | release-like commit；archive/IPA/build；App 与 Extension bundle manifest（相对路径、byte length、SHA-256、target membership）；部署后 manifest（同字段）；网络关闭证明。 | `POST-READY EVIDENCE PENDING`。RIME Platform Maintainer 实现；Architecture 复核主 App/Extension 边界。 |
| Q-02 候选 Top-1 / order | 干净、未学习、无额外用户词典的 26-key Luna，在模糊音 on/off 两组均冻结并验证：`ni → 你`、`nihao → 你好`、`sanjiaoxing → 三角形`；还要冻结代表性句子的 Top-1 与首屏顺序。不能只检查“有汉字”。模糊候选必须可发现且不能替换正常 Top-1。 | content-free synthetic vector（输入、开关、完整 candidate window、expected Top-1/order、实际结果）；精确 app/build/device/OS；两次冷启动后的结果。 | `POST-READY EVIDENCE PENDING`。现有 E-01 仅证明问题，E-06 不能承接此 gate。RIME Platform Maintainer 负责；Quality 复核。 |
| Q-03 OpenCC 四输出 | 为同一组包含简繁、港台差异的固定字符串，分别验证简体（t2s）、繁体（s2t/项目保留能力）、香港（t2hk）、台湾（t2tw）配置输出；每个输出必须与 pinned profile 完全一致，不得因 JSON、`.ocd2` 或 schema profile 错配而静默成功。 | 四状态输入/输出 fixture；每个 profile/data 文件 source 与 generated SHA-256、byte length、路径；部署后 hash；运行日志只含合成文本或 opaque case ID，不含用户输入。 | `POST-READY EVIDENCE PENDING`。当前只见 4 个 `.ocd2` 与两个模板 JSON，闭包/配置覆盖不足。RIME Platform Maintainer + Quality。 |
| Q-04 Stroke reverse lookup | 按官方 schema 的反查入口和 pinned Stroke dictionary 选择确定性 fixture，验证输入法 session 能进入反查、候选内容/顺序正确、普通拼音 session 不被污染。fixture 必须由 pinned dictionary 冻结，不能临时猜字符。 | pinned Stroke source/generated manifest；反查 synthetic vector（入口、stroke code、完整候选窗口）；App/Extension session receipt；Full Access 两组结果。 | `POST-READY EVIDENCE PENDING`。Stroke 资源尚未随 App 内置，也没有测试向量。RIME Platform Maintainer。 |
| Q-05 生成物可复现 | 在同一 pinned source/toolchain 下，使用两个干净输出目录重复生成 table/prism/reverse、Stroke 生成物、OpenCC `.ocd2` 及实际随包的编译配置；两次输出逐字节相同。每个生成物能回溯到 source commit、generator 版本和命令。 | generator command；toolchain/Xcode/Swift/Rime vendor 版本；两次 manifest；逐文件 SHA-256/byte length；entry count；差异为零的机器输出。 | `POST-READY EVIDENCE PENDING`。当前证据只有 source candidate hash，未有 generated receipt；E-08 还阻断环境。Domain Owner + Quality。 |
| Q-06 缺失/损坏/回滚 | 以一份 last-good deployment 为基线，逐一删除或篡改每个 required source/generated file，并在 staging 的多个失败点中断；系统必须在成功标记前拒绝部署、保留 last-good 文件及 manifest，Extension 继续消费 last-good，不能把 fallback 文本写成二进制/数据文件。 | 每个 fault case 的故障注入点、旧/新 manifest、成功标志、错误码、共享目录 hash 前后对照；部署后 Extension smoke；恢复成功 receipt。 | `POST-READY EVIDENCE PENDING`。现有 E-05 明确存在不安全 fallback；需先取得 Architecture 对事务/回滚方案的接受。 |
| Q-07 冷热性能、大小和部署 | 以 release-like build，在 iPhone 13 Pro / iOS 27.0（24A5424a）和指定 Simulator 记录首次部署、冷启动、暖启动、首键、候选刷新、Rime session、OpenCC 的样本数、median、worst、环境和 traces；单独记录 App/Extension uncompressed size、IPA 增量和首次部署时间。没有数字预算时必须由 Product 明确接受，不能以“没有明显卡顿”通过。 | exact build/archive/dSYM；设备/OS/网络/Full Access/schema；每个指标的样本数、median、worst、trace/log 路径；size/byte manifest；前后版本对照。 | `POST-READY EVIDENCE PENDING`。[`PERFORMANCE_BASELINE.md`](../PERFORMANCE_BASELINE.md) 没有虚构预算；当前没有本 Assignment 结果。Quality/Performance + Human Product Owner。 |
| Q-08 Full Access 和生命周期 | fresh install/redeploy/relaunch、Extension restart、主 App 再部署，以及 Full Access off/on 都须验证 Q-01–Q-04；结果必须标注精确 build。离线时不得出现下载提示或把“打开 App 后部署”误称为后台/首次安装证据。 | 人工设备操作脚本、截图/屏幕录制或结构化 content-free log；App/Extension process 与安装时间；精确 build/commit；每一格 pass/fail。 | `POST-READY EVIDENCE PENDING`。E-01 只覆盖现有开发版本的一部分，build provenance 仍 `UNKNOWN`。Human Product Owner 提供设备操作，Quality 复核。 |
| Q-09 许可证和归因 | Luna、Essay、Prelude、Stroke、OpenCC 及每个 incorporated upstream work 均有与实际随包文件匹配的离线 notice、source、license、版本/commit；UI、包内文档和 manifest 不得漏项。此 gate 只能报告工程完整性，法律充分性仍归 Human Product Owner / 法务。 | license inventory 与 bundle path/SHA；每个项目的 LICENSE/AUTHORS/attribution；catalog snapshot；reviewer sign-off；不作未授权法律结论。 | `POST-READY EVIDENCE PENDING`。E-10 仅覆盖 Luna descriptor；upstream audit 已指出复合归因需要刷新。Domain Owner + Human Product Owner。 |
| Q-10 CI / release reproducibility | 资源/Swift/工程/测试变更后，按 `AGENTS.md` 本地 CI 门禁顺序执行 format、KeyboardCore、RimeBridgeTests、App+Keyboard tests、Debug build、Release build；同时执行 vendor verify、资源 manifest/negative tests，取得 hosted CI 实际 step log。 | 命令、完整 target/destination、commit、Xcode/Swift、逐步结果和 hosted run URL；失败不能被 aggregate green 掩盖；所有 skipped gate 有理由和 owner。 | `POST-READY EVIDENCE PENDING`。本审查没有实现变更，也没有成功 vendor verify；不能把 docs-only 例外当作 F-02 runtime gate 通过。Executor + Quality。 |

## 阻塞项（按优先级）

| 优先级 | Blocker | 失败原因 | 关闭定义 | 责任 / 复核 |
|---|---|---|---|---|
| P0 | B-Q-01 候选质量验收缺失 | 当前 smoke 对任何汉字候选都可能通过；用户设备已观察到 `ni` / `nihao` 的异常首项。 | Q-02 的固定 Top-1、首屏顺序、模糊音 on/off、冷启动重复证据全部通过。 | RIME Platform Maintainer；Quality 独立复核；Human Product Owner 做 Product Gate。 |
| P0 | B-Q-02 官方离线资源闭包和 target ownership 未实现 | Essay/Prelude/Pinyin/Stroke/完整 OpenCC closure 未随 App 内置，当前运行期从 `Keyboard.appex` 取资源。 | Q-01 的 App-only bundle/deployed manifest、空 App Group + 飞行模式、无下载、无 Extension duplicate 全部通过。 | RIME Platform Maintainer + Architecture Reviewer。 |
| P0 | B-Q-03 缺失/损坏不能安全失败 | missing resource 写 `fallbackDict`；size-only 判断无法鉴别同尺寸篡改，且没有 last-good transaction receipt。 | Q-06 全部 fault case fail-closed，旧 hash 保持不变，错误可诊断且无假成功。 | RIME Platform Maintainer；Architecture 先接受回滚设计，Quality 后验。 |
| P1 | B-Q-04 生成物 provenance / reproducibility 不完整 | candidate source pins 尚未 accepted；没有 generator command/toolchain、generated SHA 和逐字节重复结果。 | Q-05 完成并把 exact manifest 绑定到 release-like commit/build。 | Domain Owner；Quality / Architecture。 |
| P1 | B-Q-05 OpenCC / Stroke 运行时矩阵未定义 | 没有四输出 deterministic vectors，也没有 Stroke reverse lookup fixture；“文件存在”不等于行为正确。 | Q-03/Q-04 每个 profile/session 均有 content-free input/output receipt。 | RIME Platform Maintainer；Quality。 |
| P1 | B-Q-06 设备归因、Full Access 和 offline fresh-container 证据不完整 | 当前设备证明 build/commit 为 `UNKNOWN`，且未覆盖批准闭包；Simulator 或 App 打开后的成功不能替代物理设备。 | Q-08 全矩阵使用 exact build/archive/dSYM 并保留人工证据。 | Human Product Owner + Environment Executor；Quality。 |
| P1 | B-Q-07 vendor/CI 可复核性未恢复 | 当前 `ensure_rime_vendor.sh verify` 缺 12 框架，真实 Rime/OpenCC tests 无法在本环境复核。 | vendor receipt 通过，全部相关 local/hosted CI step log 可定位；失败步骤不能被总绿掩盖。 | Environment Executor；Quality。 |
| P2 | B-Q-08 性能/大小/部署时间和许可证闭环缺失 | 没有样本数/median/worst、size delta 或 Product 接受的预算；Essay/Prelude/Stroke/复合来源未完整进入 catalog。 | Q-07/Q-09 receipts 完成，并由 Product Owner 对预算与许可证风险作明确决定。 | Quality/Performance + Human Product Owner。 |

## 已通过、但不能扩张解释的部分

- Product Decision 对“官方完整朙月拼音闭包、全部离线内置、无下载、Extension 不重复部署”的方向是明确的；这只是产品方向通过，不是实现或 Quality 通过。
- E-01 的物理设备 A/B 结果足以确认当前候选质量是实际产品风险；它不能被解释为“sanjiaoxing 成功，所以 Luna 已通过”。
- 本审查分支和工作区边界符合 Assignment：没有改动 PR #91，也没有把开发版本、TestFlight Build 7 或历史崩溃证据混成当前 Release 证据。

## Skipped / 未执行门禁

以下项目本次均明确标记为未执行，不作通过解释：

| Gate | 状态 | 原因 / 后续要求 |
|---|---|---|
| Fresh empty App Group + airplane mode | `SKIPPED` | 当前没有实现闭包和 release-like binary；待 Q-01 实现后由 Environment Executor / Human Product Owner 按物理设备和 isolated fixture 执行。 |
| `ni` / `nihao` / `sanjiaoxing` exact candidate order | `SKIPPED` | 现有设备材料是诊断证据，不是新闭包的 exact build 证据；待 Q-02 test vector 和设备矩阵完成。 |
| OpenCC four-output runtime | `SKIPPED` | 没有完整 profile/data closure 和 deterministic vector；待 Q-03。 |
| Stroke reverse lookup | `SKIPPED` | Stroke 尚未纳入当前 bundle/deploy；待 Q-04。 |
| Generated artifact reproducibility | `SKIPPED` | 未授权实现/生成；且 vendor verify 当前失败；待 Q-05。 |
| Missing/corrupt/rollback fault injection | `SKIPPED` | 当前代码的 fallback 行为不能作为安全基线；需先有 Architecture 接受的事务设计，待 Q-06。 |
| Physical performance / size / first-deploy | `SKIPPED` | 未执行 Instruments 或 release-like 设备采样；待 Q-07。 |
| Full Access / lifecycle / exact build correlation | `SKIPPED` | 当前材料没有精确安装 provenance；待 Q-08。 |
| License/legal acceptance | `SKIPPED` | 本审查只做工程证据审查，不代替 Human Product Owner / 法务判断；待 Q-09。 |
| Local full CI / hosted CI | `SKIPPED` | 本次只新增审查文档；docs-only 可以不跑 xcodebuild，但不产生 F-02 runtime gate 通过。vendor verify 已实际运行且失败，见 E-08。 |
| PR #91 review/merge | `INTENTIONALLY OUT OF SCOPE` | Assignment 明确排除，不得把其检查状态、合并状态或 commit 当作 F-02 证据。 |

## Ready 建议与交接

当前建议：**Quality = `Pass with conditions for Ready`；Assignment 仍为 `Pending`**，
直到 ADR 0033 被 Architecture 接受、计划条件写入 Assignment 或后续 handoff，并由
Product Lead 执行合法的 `Pending → Ready → Active` 转换。当前实现仍为 `Fail`，不应
请求合并或 Release。

进入 Ready 前只需完成计划级交接，不得把实际生成物、bundle、真机、性能或 CI 结果提前
伪造为入口证据：

1. Architecture & Knowledge Steward 接受 ADR 0033，并把 §4/§5/OpenCC 的实际证明
   改为 `Ready → Active` 后执行的证据门禁；同时统一 upstream pin 的 candidate / accepted
   状态命名。不得放松主 App ownership、无下载、无 Extension duplicate、无 Octagram
   和不触碰 PR #91 的边界。
2. RIME Platform Maintainer / Quality 冻结 Q-01–Q-10 的 acceptance predicates、
   synthetic vectors、manifest/receipt 字段、fault matrix、性能采样方法、license
   inventory 和 CI 命令/owner。这里冻结的是“怎么验”，不是先生成资源或先测真机。
3. 完成 Product/Architecture 的 Ready handoff 后，Executor 才进入 Active，实现
   App-only bundle、官方字节 + overlay、生成物、manifest、fail-closed/last-good
   和对应测试；Q-01–Q-06、Q-08–Q-10 的实际 receipts 在 Active/Assignment Exit 阶段
   产生，Q-07 的性能/大小/部署 receipts 同样在实现后的 release-like build 上产生。
4. 以新的精确 commit/build 重新提交 Quality review，逐项复核实际 Q-01–Q-10 证据；
   任意 skipped gate 必须有明确 owner、范围、期限和 Human Product Owner 的书面风险
   决定。Quality 通过后仍需 Human Product Gate；本文不授权上传、合并或发布。

本次只新增本审查文档，不需要更新 `CHANGELOG.md` 或架构文档。后续一旦实现资源闭包、target ownership、生成器、回滚、许可证或测试意图，必须按各自治理规则同步更新 Assignment/evidence、相关 ADR 或架构文档、`RELEASE_CHECKLIST.md`，并重新取得独立 Architecture/Quality 与 Human Product Gate 结论。

## Lifecycle Follow-up Addendum — 2026-08-29

本 addendum 对上述结论做生命周期澄清。它只修改本 Quality review，不修改
ADR、Assignment、代码或资源，也不授权实现。

### 对三个问题的明确回答

1. **当前矩阵 / Proposed ADR 是否足以给出 Ready 前的 Quality 结论？**

   **可以给出 `Pass with conditions`，不能给出无条件 `Quality Pass`。** Q-01–Q-10
   已经覆盖了候选假绿、资源闭包、生成物、OpenCC、Stroke、回滚、性能、设备、许可证
   和 CI 的必要维度；本次把矩阵中的 `BLOCKED` 改成
   `POST-READY EVIDENCE PENDING`，明确它们是实现后的证据门禁，而不是“没有证据就不许
   开始实现”。不过，在 Ready 之前仍须完成下表的计划级条件。

   ADR 0033 的方向和边界足以支撑这个**有条件**的 Quality 结论：它写明了主 App
   单一资源所有权、官方字节加 overlay、预生成路径、fail-closed、无下载和不重开
   Octagram。它当前仍是 `Proposed`，并且 §4/§5 及 OpenCC 小节的“proof/receipt
   before Ready”措辞容易把实际生成和运行时证明提前成入口条件；这些内容应在
   Architecture 接受 ADR 时明确分成“Ready 前冻结的验证计划/receipt contract”和
   “Ready → Active 后执行的实际证据”。此外，ADR 把上游 revision 称为 accepted，
   而 pin audit 仍称 candidate；这个状态命名必须在 Ready 前统一。

   因此，本审查建议为 **Quality：`Pass with conditions for Ready`**；Assignment
   仍保持 `Pending`，直到 Architecture 接受 ADR 0033、计划条件被记录并由 Product
   Lead 执行生命周期转换。这个建议不等于 Product Gate、实现通过或 Release 通过。

2. **哪些条件必须在 Ready 前定义，哪些只能在实施后验证？**

   Ready 前必须冻结“怎么验、验什么、谁负责、凭什么证据判定”，但不要求先生成资源或
   先拿到真机结果：

   | Ready 前计划条件 | 必须明确的内容 |
   |---|---|
   | ADR / 生命周期 | Architecture 接受 ADR 0033；把实际生成、bundle、部署、设备、性能和 CI 结果归入 `Ready → Active → Assignment Exit / Release`，不把它们写成实现入口；保留 PR #91、Octagram、下载和 Extension 部署边界。 |
   | Q-01 / Q-05 证据合同 | 固定 manifest 字段（source/generator/output path、byte length、SHA-256、target/deployed identity、toolchain、command、entry count）及双目录复现规则；固定 candidate pin 与 accepted production receipt 的命名。 |
   | Q-02 候选向量 | 固定 `ni`、`nihao`、`sanjiaoxing`、代表句、模糊音 on/off、Top-1 和完整首屏顺序的 synthetic fixtures；定义何种差异必须失败，不能只保留“有汉字”。实际候选值在 Active 生成物上测。 |
   | Q-03 / Q-04 行为向量 | 固定 t2s、s2t、t2hk、t2tw 的输入/期望输出，以及从 pinned Stroke dict 导出的反查入口、stroke code、候选窗口；实际运行和数据兼容性在 Active 测。 |
   | Q-06 负向计划 | 列出每个 required source/generated file 的 missing/corrupt fault cases、staging interruption points、last-good hash/flag 不变量和“不写 binary fallback”的判定；实际故障注入在 Active 测。 |
   | Q-07 / Q-08 / Q-09 / Q-10 方法 | 固定设备/OS/Full Access/网络/冷暖启动/样本数/median/worst、大小和首次部署的采样表；固定 license inventory 与 target/build/CI receipt 模板、owner、stop condition 和 Product 风险决策路径。实际测量、打包、设备和 CI 在 Active/Exit/Release 执行。 |

   Ready 后才可执行并计入 Assignment Exit / Release 的是：真实 upstream 取证和生成、
   App bundle/deployed manifest、空 App Group + 飞行模式部署、有效 RIME 候选和
   OpenCC/Stroke 运行、缺失/损坏回滚、真机 Full Access/lifecycle、性能/大小/首次部署、
   随包许可证检查，以及代码/工程变更后的完整 local/hosted CI。它们不应被提前伪造为
   Ready 证据，也不能用当前开发版本截图、Simulator generic smoke 或 aggregate CI
   green 代替。

3. **原来的 `Fail` 是否只保留为当前实现 / Release gate？**

   **是。** 原 `Fail` 保留为当前实现、Assignment Exit、TestFlight 和 Release 的
   阻断结论：当前资源仍不完整，smoke 仍可能假绿，安装 build provenance 仍未知，且
   E-08 的 vendor verify 未通过。它不再被解释为“只要实际证据尚未产生，就禁止在 Ready
   后开始实现”。当且仅当 Ready 前计划条件关闭并完成合法的 `Ready → Active` 转换后，
   Executor 才可以实现；B-Q-01–B-Q-08 和 Q-01–Q-10 的实际证据仍必须在 Active/Exit
   /Release 阶段关闭。若计划合同发生范围变化，须重新 Quality review。

### Revised phase map for Q-01–Q-10

| 阶段 | Quality 允许的判断 | 不允许的替代解释 |
|---|---|---|
| `Pending → Ready` | 只判断 ADR/Assignment 边界、owner、fixtures、manifest、负向矩阵、性能/许可证/CI 方法是否足够明确且可执行；本 review 的结论为 `Pass with conditions`。 | 不把“没有生成物 / 没有真机 / 没有 CI”写成实现失败；也不由 Quality 直接把 Assignment 改为 Ready。 |
| `Ready → Active` | Product/Architecture 完成各自授权后，Executor 开始实现；Quality 保留独立复核权。 | 不在 Ready 前生成或替换生产资源，不把本 review 当实现授权。 |
| `Active → Assignment Exit` | 对 Q-01–Q-06、Q-08–Q-10 的实际闭包、runtime、负向、设备、manifest、license 和测试证据逐项复核；对 Q-07 复核性能/大小/部署 receipt。 | 不用计划表、source candidate SHA、旧设备截图或 generic smoke 关闭实际 gate。 |
| `Exit → TestFlight / Release` | 以精确 release-like commit/build 汇总所有实际 receipts，处理 skipped gates、风险期限和 Human Product Gate。 | 不把 `Pass with conditions`、Architecture review 或本 addendum 当作上传、合并或发布批准。 |

### Follow-up disposition

本 addendum 后，文中 Q-01–Q-10 的 `POST-READY EVIDENCE PENDING` 和 B-Q-01–B-Q-08
仍然有效，但它们的阻断范围是“当前实现不能通过 Exit/Release”，不是“验证计划不足以
进入 Ready”。在 ADR 0033 被 Architecture 接受、上述计划条件写入 Assignment 或其
后续 handoff、并由 Product Lead 完成生命周期转换前，Assignment 仍是 `Pending`；本
Quality review 不执行任何实现、资源生成、真机操作或发布动作。

## Post-sync Note — 2026-08-29

Coordinator 已同步记录 ADR 0033 为 `Accepted`、统一 source pin 状态，并将 Assignment
推进为 `Ready`（implementation authorization 仍待独立授权）。Ready 前 conditions 已
关闭，本 Quality plan 的 `Pass with conditions` 生效；当前实现、Exit、TestFlight、
Release 仍为 `Fail`，Q-01–Q-10 继续保持 `POST-READY EVIDENCE PENDING`。

## Post-implementation Review — `09659a7` — 2026-08-30

**Independent verdict: `Fail` for implementation re-review.** The current
implementation remains in Active remediation and must not advance to
physical-device handoff or Exit.

### Findings

- **P0:** `RimeSchemaRuntimeSmokeProbe.swift:34-36,72-87` permits
  `builtinQualityPassed == nil`. For `luna_pinyin`, a missing receipt skips the
  exact quality cases and can still pass on any Han candidate; the receipt is
  also not bound to the current deployed manifest.
- **P1:** the five Top-1 vectors do not prove full first-page order,
  representative sentences, fuzzy-derived discoverability or repeated cold
  starts; installer faults do not cover same-length hash corruption, every
  required member/staging interruption or Extension last-good consumption;
  OpenCC covers only t2s behavior and Stroke covers only one vector; test
  fixtures allow empty provenance metadata.
- **P2:** no accepted before/after IPA delta, sample count, median/worst, trace
  or Product performance budget exists; physical-device/Full Access/lifecycle,
  hosted CI and exact archive provenance remain absent.

### Q-01–Q-10 disposition

| Gate | Result |
|---|---|
| Q-01 | `PARTIAL` |
| Q-02 | `PARTIAL` — also blocked by the P0 fail-open smoke path |
| Q-03 | `PARTIAL` |
| Q-04 | `PARTIAL` |
| Q-05 | `PARTIAL` |
| Q-06 | `PARTIAL` |
| Q-07 | `PENDING` |
| Q-08 | `PENDING` |
| Q-09 | `PENDING` |
| Q-10 | `PARTIAL` |

The reviewer independently re-read existing xcresult summaries for
RimeBridgeTests (75 total, 55 passed, 20 skipped) and the App suite (255 total,
252 passed, 3 skipped). The focused integration summary could not be reread in
that review environment, so its recorded 1.334-second result remains
Executor-recorded. The reviewer performed no build/network/write action and did
not access or change PR #91.

## Final implementation re-review — `fa5dbaf` / `786f4c7` — 2026-08-31

**Independent verdict: `Pass with conditions`.** P0: none. P1: none. The
reviewed implementation commit is
`fa5dbaf1fded3e25ac39a6c0c675cddc786f01bb`; the reviewed evidence commit is
`786f4c720949784f4f66515228778bf6a012b952`.

The reviewer closed the previous fail-open smoke, base/overlay atomicity,
full-first-page and App-aggregate conditions. The current local evidence covers
four clean deployments, exact fuzzy-off/on first pages for every frozen vector,
four OpenCC behavior vectors, Stroke plus same-session pinyin recovery, the
26-point switch fault matrix, production-sequence rollback and receipt-gated
Extension authorization.

### Q-01–Q-10 final local disposition

| Gate | Result | Remaining boundary |
|---|---|---|
| Q-01 | `PARTIAL` | Physical fresh App Group and airplane-mode first deployment remain pending. |
| Q-02 | `PARTIAL` | Exact complete first pages pass locally; physical repeated process cold starts remain pending. |
| Q-03 | `PASS` | Local actual-bundle s2t/t2s/t2hk/t2tw vectors pass; physical RC binding is still downstream evidence. |
| Q-04 | `PARTIAL` | Stroke and same-session pinyin isolation pass locally; Full Access and Extension lifecycle remain pending. |
| Q-05 | `PASS` | Local reproducibility and identity evidence pass; hosted clean-checkout repetition remains pending. |
| Q-06 | `PARTIAL` | Synchronous rollback and receipt authorization pass; process-death and physical Extension consumption remain pending. |
| Q-07 | `PENDING` | Release-like physical performance, IPA delta, median/worst and Product budget acceptance remain pending. |
| Q-08 | `PENDING` | Exact-build physical install/redeploy/relaunch and Full Access matrix remain pending. |
| Q-09 | `PARTIAL` | Engineering inventory exists; independent inventory and Human/legal sufficiency remain pending. |
| Q-10 | `PARTIAL` | Local gates pass; hosted CI, exact archive and release provenance remain pending. |

The remaining M-03 items are owned rather than silently accepted:
`F02-Q01-PHYSICAL-001`, `F02-Q02-COLDSTART-001`, `F02-Q03-RC-001`,
`F02-Q04-DEVICE-001`, `F02-Q05-HOSTED-001`,
`F02-Q06-EXTENSION-001`, `F02-Q07-PERF-001`,
`F02-Q08-LIFECYCLE-001`, `F02-Q09-LICENSE-001` and
`F02-Q10-HOSTED-001` remain `fix`; process-death atomicity is
`F02-Q06-PROCDEATH-001` / `tech_debt:TD-001`.

Quality permits preparation of an exact installable build and physical-device
handoff packet because Architecture independently gave the same permission.
This does not authorize the device run itself and is not Product, Exit, merge,
TestFlight or Release acceptance.

**Independence statement:** the reviewer completed a read-only review without
file changes or build/test/network/device actions, did not touch the main
checkout and did not inspect or operate PR #91.

## Q-09 inventory closure re-review — `bb43c5f` — 2026-08-31

**Independent verdict: `Pass with conditions`.** P0: none. P1: none.

Engineering Q-09/inventory is `PASS / CLOSED`. OpenCC now exposes both the
Apache license and AUTHORS in the offline catalog; bundled AUTHORS is exactly
277 bytes with pinned SHA-256
`cb34e252fa994679bcbfc8355581e821ceda44bd857875e2cfe15b7ec4eec006`.
Tests cover all offline catalog documents and hard-check the OpenCC document
set, byte count and hash. The latest evidence binds manifest v3 and the affected
full local gates.

`F02-Q09-HUMAN-LEGAL-001` remains P2 / `fix`: Human/legal sufficiency is
pending and cannot be inferred from engineering review. The reviewer could not
independently read back the four `.xcresult` summaries because the local tool
attempted a disallowed `TestReport` write; the test counts therefore remain
Executor-recorded rather than reviewer-rerun evidence.

A clean replacement signed candidate may be prepared and frozen. Installation,
physical execution, hosted CI, archive, Product Gate, merge, TestFlight and
Release remain unauthorized.

**Independence statement:** this was a read-only review of `bb43c5f`; no files,
builds, tests, network, devices, main checkout or PR #91 were touched.

## Independent Quality re-review — `b1d81fd` — 2026-09-02

**Independent verdict：代码层 `Pass with conditions`（无 P0/P1）；KOS/生命周期层 `Fail`（无 P0，1 个 P1、3 个 P2）。** 本 addendum 不授权 device install、merge、Exit、TestFlight、Release 或 legal/Product Gate 通过。

### 复审对象

- 分支 `codex/f02-rime-builtin-quality-assignment`，HEAD `b1d81fd2f61522001bc1d15490563097bd581016`（2026-09-02 20:01，Cowork 3P），父 commit `688a8fe`，工作树 clean。
- 范围 `git diff 688a8fe..b1d81fd`：3 个 Swift 文件（`RimeConfigManager+CustomYaml.swift`、`RimeConfigManager+Preferences.swift`、`RimeBuiltinResourceInstallerTests.swift`），+103/−23。

### 代码层结论

- 语义正确：`rime_simplification` 缺失时按产品默认简体写 `switches/@2/reset:1`；显式 `false` 仍写 `reset:0`。
- 收敛点单一：`simplificationPreference(from:)` 同时供设置页与 sync 使用，消除两处默认逻辑漂移；生产入口无旁路，main-App 部署 / Extension session-only 边界未破坏。
- 写入/验证链完整：plan → overlay（Luna switch 2，true→1 / false→0）→ 事务替换 → receipt 校验；两条 fixture 测试对实际落盘内容断言并通过 `validateInstalledRuntime`。

### `F02-COMMITTED-TEST-RERUN-001` — 关闭（CLOSED）

原条件：尚未对 committed `b1d81fd` 做独立复跑；此前证据为 pre-commit 运行 + mtime 一致性推断。

现证据（commit 级复跑）：
- xcresult：`/private/tmp/uk-f02-tests-dd/Logs/Test/Test-RimeBridgeTests-2026.09.02_20-15-20-+0800.xcresult`
- 读回：`passedTests: 75` + `skippedTests: 20` = 95 total、`failedTests: 0`、`result: "Passed"`。
- 时序：`b1d81fd` commit 于 20:01:48 → 复跑于 20:15:20 → 工作树 clean 且 HEAD=b1d81fd，无后续源码改动。

结论：复跑对象即 committed `b1d81fd`，本条件关闭。

证据等级（诚实标注）：复跑由 Executor 运行（`Executor-recorded`）；replacement reviewer 独立读回 xcresult 并核对 git state（`reviewer-readback`），未亲自重跑，故不标 `Quality-reverified`。

### 剩余未关闭条件

| ID | 级别 | 状态 | 说明 |
|---|---|---|---|
| `KOS-001` | P1 | open | `c5f3004` 冻结已失效（`b1d81fd` 在其后提交）；Assignment / ACTIVE_WORK / handoff packet 仍写 "clean c5f3004 已冻结"，需补 S-03 supersession 横幅并二选一：从 clean `b1d81fd` 重冻结，或显式记录 "c5f3004 冻结仍有效、缺 key 行为推迟"。此为 Product 决定，本 reviewer 不作。 |
| `KOS-002` | P2 | closed | b1d81fd 的独立复审记录见本 addendum；09-02 evidence 见 [`rime-builtin-luna-quality-f02-default-simplification-2026-09-02.md`](../evidence/rime-builtin-luna-quality-f02-default-simplification-2026-09-02.md)。 |
| `KOS-003` | P2 | closed | 09-02 测试结果证据等级已标注；committed 复跑已补（见上）。 |
| `KOS-004` | P2 | open | `F02-APPGROUP-MANUAL-001` 仍 pending；08-31 结论不适用于 b1d81fd，本 addendum 为其 09-02 复审记录。 |
| `F02-APPGROUP-MANUAL-001` | P2 | open | 缺 signed Simulator / physical 真实 App Group 写入与部署的 manual 证据。 |

### 禁止动作

不 merge、不 push、不安装 `c5f3004` 或按旧 packet 执行真机 Run ID；本结论不是 Exit / TestFlight / Release / legal / Product Gate 通过。

### Independence statement

Replacement Quality reviewer（Claude Code）接续 codex quality subagent（`/root/f02_quality_kos_review`）的 finding 历史。只读复审 `b1d81fd`：未改 Swift 源码、未运行 build/test/device，仅读回 xcresult 与 git state；未触碰主 checkout `/Users/doubleshy0n/Dev/Universe Keyboard` 或 PR #91。本 addendum 由 replacement reviewer 自行记录。

## Independent Quality re-review — `ecd3446` — 2026-09-03

**Independent verdict：代码与已记录证据 `Pass with conditions`（无 P0/P1）；KOS/生命周期 `Fail` 关闭。** Assignment Exit / TestFlight / Release 仍为 `Fail`。本 addendum 不授权 merge。

### 复审对象

- 分支 `codex/f02-rime-builtin-quality-assignment`，HEAD `ecd3446a242f6309b5150f0d751fb6d4f155faa6`。
- 证据：[`physical-device handoff`](../evidence/rime-builtin-luna-quality-f02-device-handoff-2026-08-31.md)、hosted Swift 6 Quality run [`33642643269`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33642643269)、GitHub `statusCheckRollup` 全绿。
- 未重新执行真机、未本地重跑 xcodebuild。

### KOS P1/P2 关闭

| ID | 级别 | 状态 | 处置 | 说明 |
|---|---|---|---|---|
| `KOS-001` | P1 | closed | `fix` | Human 授权并从 clean `b1d81fd` 重冻结；handoff 已加 S-03。与 Architecture `F02-A-P1-FREEZE-001` 对齐。 |
| `KOS-002` | P2 | closed | `fix` | 保持 09-02 关闭。 |
| `KOS-003` | P2 | closed | `fix` | 保持 09-02 关闭。 |
| `KOS-004` / `F02-APPGROUP-MANUAL-001` | P2 | closed | `fix` | Q-01 真机：删除 App 后重装、空 App Group、飞行模式离线部署 `PASS`（`Device-attested`）。此前 defer 到 Q-01 的条件已满足。 |

### Q-01–Q-10 当前处置

| Gate | Result | 证据等级 | 剩余边界 |
|---|---|---|---|
| Q-01 | `PASS` | `Device-attested` | 首次自动部署缺失见 `F02-FIRST-LAUNCH-AUTODEPLOY-001`，不否定离线闭包可部署。 |
| Q-02 | `PASS` | `Device-attested` | fuzzy off/on 8/8 exact + `fanti`。转换/反查向量不在本 gate 闭合范围内。 |
| Q-03 | `DEFERRED` | n/a | `F02-CONVERSION-LOOKUP-NOT-WIRED-001`。本地四输出不能扩张为真机 RC 通过。 |
| Q-04 | `PASS`（Full Access/lifecycle） | `Device-attested` | Stroke reverse lookup 随 Q-03 延期。 |
| Q-05 | `PASS`（hosted checkout） | reviewer-readback of hosted CI | run `33642643269`：`classify-change` / `lightweight-checks` / `build-and-test` / `final-quality-gate` 均为 `SUCCESS`。不是 reviewer 本地重跑。 |
| Q-06 | `PARTIAL` | `Device-attested`（C.4 消费） | 严格 missing/corrupt/rollback 真机 fault-injection 仍 `POST-READY EVIDENCE PENDING`。进程死亡原子性 = `tech_debt:TD-001`。 |
| Q-07 | `PARTIAL` | `Device-attested`（D.1/D.2 观察） | 5 次冷启动 median 1.06 s / worst 1.17 s；`.app` 81.20 MB。非 release-like；无 Product 性能预算接受。 |
| Q-08 | `PASS` | `Device-attested` | 精确 build `b1d81fd` 安装/重部署/重开/重启。 |
| Q-09 | `PARTIAL` | `Executor-recorded` 工程清单 | `F02-Q09-HUMAN-LEGAL-001` 仍待 Human/legal。 |
| Q-10 | `PARTIAL` | reviewer-readback of hosted CI | hosted CI 绿；exact archive / release provenance 未做。 |

### 剩余 M-03 残差（merge 前须由 Product 给 disposition）

| ID | Severity | Owner / disposition | Pointer |
|---|---|---|---|
| `F02-Q03-RC-001` | P2 | Human Product Owner / open | Q-03 deferred；[`handoff` Run findings](../evidence/rime-builtin-luna-quality-f02-device-handoff-2026-08-31.md) |
| `F02-Q06-EXTENSION-001` | P2 | Human Product Owner / open | 严格 Extension fault-injection 未跑 |
| `F02-Q06-PROCDEATH-001` | P2 | Main App/Data Ops / `tech_debt:TD-001` | ADR 0006 |
| `F02-Q07-PERF-001` | P2 | Human Product Owner / open | release-like 性能/预算未接受 |
| `F02-Q09-HUMAN-LEGAL-001` | P2 | Human Product Owner / open | 工程 inventory 不能代替法律充分性 |
| `F02-Q10-ARCHIVE-001` | P2 | Human Product Owner / open | 无 exact archive；hosted CI 已绿，不覆盖 Release provenance |
| `F02-FIRST-LAUNCH-AUTODEPLOY-001` | P2 | Human Product Owner / open | 全新安装不自动部署 |
| `F02-CONVERSION-LOOKUP-NOT-WIRED-001` | P2 | Human Product Owner / open | 与 Architecture `F02-A-P2-OPENCC-SCOPE-001` 同一事实 |
| fuzzy-default-ON | note | Human Product Owner / open | handoff 记为有意行为，不是缺陷；仍需 Product 确认 |

允许的 disposition 只有 `fix` / `accept` / `tech_debt:<ID>`。Quality 不代填 Product 决定。

### 禁止动作

不 merge、不发 AUTH、不把本结论写成 Exit / TestFlight / Release / legal 通过。

### Independence statement

Replacement Quality reviewer（Grok 4.6）只读复审 `ecd3446`（worktree `/private/tmp/universe-keyboard-f02-assignment`）：未改 Swift 源码、未跑 build/test/device，只读回已提交的真机 ledger 与 GitHub check rollup。本文档记录属于审查卫生，不是 Product Gate。

## Independent Quality re-review — `eedc4a7` — 2026-09-04

**本片 merge-slice Quality packet：`Pass with conditions`（无 P0；无阻塞本片的 P1）。**  
**Assignment Exit / TestFlight / Release：`Fail`（未授权）。**  
本 addendum **不**发 merge AUTH、**不**声明 Exit / TestFlight / Release，也**不**复用 [#93](https://github.com/shchnk1103/Universe-Keyboard/pull/93) `ecd3446` 的 Quality verdict。

### Scope

| 项 | 值 |
|---|---|
| Object | PR [#98](https://github.com/shchnk1103/Universe-Keyboard/pull/98) `fix/f02-first-launch-autodeploy-fuzzy-off` |
| HEAD | `eedc4a7b9fc10f058b2553764ade46c7d52236fd` |
| Implementation | `9309a0df4745c9688bb911f9c8e36a6257971aff` |
| Diff base | `origin/main...HEAD`（17 files；核心为首次自动部署种子 + fuzzy 主开关默认关 + XCTest 隔离/`nonisolated deinit`） |
| Hosted CI | GitHub Actions run [`33835843752`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33835843752) `SUCCESS`（classify / lightweight / build-and-test / final-quality-gate）+ GitGuardian |
| Out of scope | 实现改代码、merge、AUTH、真机复跑、Exit / TestFlight / Release |

本片只验收：`F02-FIRST-LAUNCH-AUTODEPLOY-001` 修复路径 + Human 授权的 fuzzy master default OFF；不重开 Q-03/Q-06/Q-07/法律/archive。

### Evidence Matrix

M-04 仅用 `Executor-recorded` / `Quality-reverified` / `Device-attested`。Human 会话报告计入 `Device-attested` 输入；本 reviewer **未**独立重跑真机或本地 xcodebuild，故不得把 Human 报告或 Executor 本地命令自动升格为 `Quality-reverified`。

| ID | Claim | Grade | Exact receipt | Judgment |
|---|---|---|---|---|
| EQ-98-01 | Fresh App Group：`load()` 种子 `rime_needs_deploy`；已部署 / 自动重试抑制不种子；种子后 `triggerPendingDeploymentIfNeeded` 发一次本地部署 | `Executor-recorded` | PR body + `RimeSettingsStoreTests`（含 `testLoadSeedsBuiltinDeployIntentOnFreshAppGroup` 等）；声称 iPhone 17 Pro / iOS 26.0 上该类 **45/0**。Quality **未**本地复跑 | 单元路径覆盖足够支撑本片意图；单独不足以关闭真机首次安装 |
| EQ-98-02 | Human 删装：打开主 App 即自动部署；无需手动「应用并重新部署」；无下载 | `Device-attested` | Assignment Current Status / timeline（`eedc4a7`）；Human Product Owner 2026-09-04 会话报告。Quality **未**复跑设备 | **PASS** 本片 autodeploy 谓词；关闭 `F02-FIRST-LAUNCH-AUTODEPLOY-001` 的真机缺口（相对 `bd5ad23` 时的 open re-ver） |
| EQ-98-03 | Human：fuzzy 主开关默认关；候选 `ni` / `nihao` / `sanjiaoxing` / `jintiantianqihenhao` 正常 | `Device-attested` | 同上 Human 报告 + Assignment M-03 行 | **PASS** 本片 fuzzy-off + 候选烟雾；非完整 Q-02 矩阵重跑，也不扩张为 Exit |
| EQ-98-04 | Fuzzy master default OFF；分组默认仍 ON；存储偏好不变 | `Executor-recorded`（代码+测试）+ `Device-attested`（真机关） | `RimeFuzzyPinyinSettings.enabled` 默认 `false`；`RimeSettingsStore` / `SchemaManager+Deployment` / `RimeConfigManager+CustomYaml` 缺省一致；`RimeFuzzyPinyinTests` 产品默认断言；KeyboardCore 声称 **1072/0**；`SchemaManagerTests` 为 ON 路径显式写入 `enabledKey: true` | 生产默认覆盖**足够本片**：四处读默认对齐 + 单测 + Human。不要求本片再扩矩阵 |
| EQ-98-05 | Hosted CI 全绿（含完整 App+Keyboard 契约测试） | `Quality-reverified`（hosted path only） | run `33835843752` @ `eedc4a7`：`build-and-test` 中 KeyboardCore、RimeBridge、**Test app and keyboard contracts**（`UniverseKeyboardTests` **278** executed / 3 skipped / 0 failed；`KeyboardTests` **11/0**；`** TEST SUCCEEDED **`）、Debug/Release **BUILD SUCCEEDED**；`final-quality-gate` SUCCESS。本 reviewer 经 `gh run view` / log 独立核对 | Hosted 路径 **PASS**。CI 绿 ≠ Quality Pass for merge ≠ Release |
| EQ-98-06 | Executor 本地跳过完整 `Universe Keyboard` scheme（XCTest-host malloc abort 后改隔离跑 store tests） | n/a（skip with reason） | PR body：**Not run** full scheme；随后隔离 `RimeSettingsStoreTests` 绿 | **可接受 skip**：本地理由成立，且 EQ-98-05 hosted 已跑通等价完整契约套件。**不是**本片 merge 的 P1 缺口 |
| EQ-98-07 | `nonisolated deinit` + XCTest 跳过首次部署路径 | `Executor-recorded` | `AppGroupSharedSettingsStore` / `SchemaManager` / `RimeSettingsStore` 的 `nonisolated deinit`；`ContentView.task` 在 `XCTestConfigurationFilePath` 下跳过 seed/deploy；`testDefaultAppGroupSettingsStoreDeinitDoesNotAbort` / `testDefaultSchemaManagerDeinitDoesNotAbort` | **回归测试存在**。**禁止**扩张为“已修复生产真机崩溃”；CHANGELOG 已正确限定为模拟器宿主 teardown |
| EQ-98-08 | 搜索页首次输入前系统网络弹窗 | open observation（Human）；代码侧无 SearchTab 下载 | Human 报告（原文案 `UNKNOWN`）；静态：`SearchTab.swift` 无 `URLSession` / download / http | **不失败 autodeploy**。保持开放观察，待 Human 原文案后再定性 |
| EQ-98-09 | PR body vs 实际 | `Quality-reverified`（文档对照） | PR Verification 仍写「No physical-device fresh-install retest」且强调本地未跑全套；HEAD `eedc4a7` 已记录 Human 删装通过；hosted 已跑全套 App+Keyboard | PR body **落后于 HEAD 证据**。以 Assignment/`eedc4a7` + hosted log 为准，不以过期 PR 段落否定后续证据 |

### Passed

- 本片代码意图与边界：主 App `load()` 种子 + `ContentView.task` 一次 pending 本地部署；Extension 仍 session-only；无内置资源下载路径。
- Fuzzy master default OFF 在 KeyboardCore / Store / Deployment / CustomYaml 一致；分组默认 ON；测试与 Human 真机一致。
- Hosted CI `33835843752` 对 `eedc4a7` 完整门禁绿，且包含 Executor 本地跳过的 App+Keyboard 全契约套件。
- `F02-FIRST-LAUNCH-AUTODEPLOY-001`：单元种子路径 + Human 删装确认 → 本片 Quality 接受 Assignment 上的 `fix` disposition（真机谓词）。
- `nonisolated deinit` / XCTest skip 有对应测试与文档边界，未过度宣称生产崩溃修复。

### Failed / Blocked

- **无本片 P0 / 无阻塞本片 merge-slice 的 P1 技术失败。**
- **Exit / TestFlight / Release 门禁：`Fail`（未授权）** — 与 merge-slice packet 分离。
- **无 merge AUTH** — 本审查不签发。

### Skipped With Reason

| Item | Reason | Owner |
|---|---|---|
| Quality 本地重跑 KeyboardCore / RimeBridge / `RimeSettingsStoreTests` / 全 scheme | 独立复审未执行 xcodebuild；依赖 Executor 记录 + hosted `Quality-reverified` | Quality（本片接受） |
| Quality 真机删装复跑 | 未操作设备；Human 报告为 `Device-attested` 输入 | Human / Quality |
| 搜索页网络弹窗分类 | 缺系统原文案；SearchTab 无网络 API，不阻塞 autodeploy | Human Product Owner |
| Q-03 / 严格 Q-06 / Q-07 release-like / 法律充分性 / exact archive | 既有 Product `accept` / 另开范围；本片不重开 | 既有 M-03 |

### Release Decision

| Gate | Decision |
|---|---|
| 本片 Quality packet（PR #98 / `eedc4a7`） | **`Pass with conditions`** |
| Merge AUTH | **未授权**（待 Product / Coordinator；Architecture 对齐） |
| Assignment Exit | **`Fail` / 未授权** |
| TestFlight | **`Fail` / 未授权** |
| Release / App Store | **`Fail` / 未授权** |

CI 绿 ≠ Quality Pass for merge ≠ Release。

### M-03 residuals（本片后仍须 disposition）

| ID | Severity | Owner | Disposition | Notes |
|---|---|---|---|---|
| `F02-FIRST-LAUNCH-AUTODEPLOY-001` | P2→closed for slice | Executor + Quality | `fix` | Human 删装 2026-09-04；本 addendum 接受 |
| fuzzy-default-ON | note | Human Product Owner | superseded — default OFF | 与实现一致 |
| `F02-SEARCH-NETWORK-DIALOG-001`（新观察） | P2 observation | Human Product Owner | `open` | 搜索页首次输入前系统网络弹窗；原文案 `UNKNOWN`；**不**计为 autodeploy 失败 |
| `F02-PR98-BODY-STALE-001` | P2 docs | Executor | `open` / 可在跟进 docs 修 | PR Verification 未反映 Human 删装与 hosted 全套通过 |
| `F02-HANDOFF-AUTODEPLOY-LEDGER-LAG-001` | P2 docs | Executor | `open` | `device-handoff` 仍写「Device re-verification … still open」，与 Assignment `fix` 不同步 |
| `F02-Q03-RC-001` / conversion-lookup | P2 | Human Product Owner | `accept`（既有） | 本片不重开 |
| `F02-Q06-EXTENSION-001` | P2 | Human Product Owner | `accept`（既有） | 本片不重开 |
| `F02-Q06-PROCDEATH-001` | P2 | Main App/Data Ops | `tech_debt:TD-001` | 既有 |
| `F02-Q07-PERF-001` | P2 | Human Product Owner | `accept`（既有） | 本片不重开 |
| `F02-Q09-HUMAN-LEGAL-001` | P2 | Human Product Owner | `accept`（既有） | 工程 ≠ 法律 |
| `F02-Q10-ARCHIVE-001` | P2 | Human Product Owner | `accept`（既有） | merge 不要求 exact archive；仍 ≠ Release provenance |
| Merge AUTH / Exit / TestFlight / Release | — | Product Lead | **unauthorized / Fail** | 本 Quality 不签发 |

无缺失 disposition 的 **本片 P0**。docs lag 与搜索弹窗为 **P2**，不单独把本片 Quality 打成 Fail。

### Owner Handoffs

1. **Coordinator / Product Lead：** 待独立 Architecture 复审对齐后，决定是否申请 **新的** merge AUTH（历史 `AUTH-…-MERGE` 仅覆盖 #93）。
2. **Human Product Owner：** 提供搜索页网络弹窗**原文案**后再定性；维持 Exit / TestFlight / Release 不上传。
3. **Executor（docs）：** 可选更新 PR body Verification 与 `device-handoff` autodeploy 行，消除与 Assignment/`eedc4a7` 的 ledger 漂移。
4. **Architecture：** 独立复审本 diff（首次部署种子、fuzzy 默认、deinit/XCTest 边界）；Quality 不代签架构结论。

### Conditions（Pass with conditions）

1. 搜索页网络弹窗保持开放观察，不得在未定性前写成部署/下载回归。
2. 不得把 `nonisolated deinit` 说成已证明的生产崩溃修复。
3. 不得把本 packet 写成 Assignment Exit / TestFlight / Release / merge AUTH。
4. docs ledger 漂移（PR body / handoff）应在跟进中收敛，但不升格为本片 P1。

### Independence statement

Quality, Performance & Release Maintainer（**grok-4.5**；与 Architecture reviewer / 实现 parent 分离）。只读复审 PR #98 @ `eedc4a7`：核对 `git diff origin/main...HEAD`、PR body、Assignment、既有 `ecd3446` addendum、SearchTab 静态面、以及 hosted run `33835843752` 的 job/log。**无生产 Swift 编辑**；**未**本地重跑测试；**未**真机复跑；**未** push / commit / merge。仅允许编辑本 Quality review 文件（本 addendum + Current Status S-03）。