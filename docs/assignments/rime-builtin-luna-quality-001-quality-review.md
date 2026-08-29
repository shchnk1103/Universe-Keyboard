# RIME-BUILTIN-LUNA-QUALITY-001 — 独立 Quality / Performance / Release 审查

| 字段 | 内容 |
|---|---|
| 审查日期 | 2026-08-29（Asia/Shanghai） |
| 审查角色 | Quality, Performance & Release Maintainer（独立审查） |
| 审查工作树 | `/tmp/universe-keyboard-f02-assignment` |
| 审查基线 | `origin/main` / `7f20f3a`；当前只读审查分支 tip `562c85e` |
| 审查范围 | 验证计划、证据门槛、当前实现的可验证性和发布风险；没有实现代码或资源变更，没有提交。 |
**明确排除：** PR [#91](https://github.com/shchnk1103/Universe-Keyboard/pull/91)（包括 `e3e5d77`）不在本 Assignment 范围内；本审查不判断其合并与否。

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
