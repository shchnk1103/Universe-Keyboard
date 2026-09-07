# 多方案资源归属与部署恢复计划

状态：**规划切片完成 / 仅规划**，`2026-09-07 Asia/Shanghai`。
本文件结束「开始做计划」授权，不代表架构方案、恢复策略、实现、merge 或发布已获批准。

所属 [Assignment](../assignments/scheme-delivery-source-state-001.md)。架构候选见 [ADR 0034（Proposed）](../architecture/decisions/0034-multi-scheme-resource-ownership.md)。本文件是实施/交接计划，不替代 ADR 0006、0032、0033，也不替代人工 Product Gate。

## 0. 本切片是否写完

Codex 在额度耗尽前留下未跟踪草稿。本修订补齐治理缺口后，**规划切片视为完成**。完成指：接手者不必再猜「计划还缺哪一节」；不指 P0 已做，也不指 ADR 已 Accepted。

| 规划出口 | 状态 |
|---|---|
| 事实、建议、待批准决策分开书写 | 本文件 §2 / §5 / §5.1 |
| 对应原六点大纲，无静默删节 | §0.1 |
| 长期配置归属另写 Proposed ADR，含治理必填节 | ADR 0034 |
| 由现有 Assignment 链接，并进入 Active Work | Assignment follow-up · `ACTIVE_WORK` 第 6 行 |
| 明确下一技术包与停止条件 | §6 P0、§8、§9 |
| 本提交不含 Swift / 资源文件 / 真机恢复 | 是 |

未纳入本切片、不得当成已交付：

- 2026-09-07 未提交的部署分阶段 journal 诊断（`rime_deployment.phase_changed`）。那是另一次授权，HEAD `5cec512` 不含该增量；Architecture 评审因额度未完成。
- P0 生产路径复现、依赖审计产物、实现、历史状态修复、PR #100 merge、TestFlight。

### 0.1 原六点大纲落点

| 大纲 | 落点 | 本修订补了什么 |
|---|---|---|
| 1. 现状与证据 | §2 | 安装计划 `allowedFiles` / `removableFiles` 不对称；诊断增量不在 HEAD |
| 2. 配置依赖审计 | §4 | 审计字段与「不得猜测动态引用」写死为 P1 产物，不是本切片已完成的清单 |
| 3. 架构选择与决策点 | §5、§5.1 | 抽出必须 Human/Architecture 批准的编号决策 |
| 4. 分阶段实施 | §6 | 计划出口与 P0 入口分开；每步完成条件 |
| 5. 验证与恢复矩阵 | §7 | 保留；标明自动化 vs 真机 |
| 6. 接手说明 | §8、§9 | 工作区、阅读顺序、命令、停止条件；本 commit 之后 HEAD 含计划 |

## 1. 目标与完成定义

让内置 Luna、雾凇、万象在同一 App 中安全安装、升级、切换和卸载。文件归属和依赖明确，安装顺序不改变无关方案的有效配置；失败后保留可恢复检查点，不能以放宽完整性校验换取「部署成功」。

产品完成必须同时具备：受控复现、依赖清单、批准后的配置归属决策、实现与迁移验证、独立评审、指定候选真机证据。下载成功、资源准备成功、引擎编译成功、运行验证成功分别报告，不互相替代。

非目标：更换 RIME 二进制、改键盘热路径/候选排序、改变 Lua/模型产品门、支持任意未知方案包、自动发布 TestFlight。本规划切片不改 Swift/ObjC/资源文件，不执行恢复操作。

## 2. 已知事实与未确认项

把下面三列分开读。不得把「静态冲突」写成「真机唯一根因」，也不得把候选 A 写成已定设计。

### 2.1 已确认事实

| 项 | 证据 |
|---|---|
| 真机：dated 雾凇包下载、归档大小/SHA、处理后内容校验及文件安装成功；之后部署失败 | 用户日志；Assignment residuals |
| 最新真机失败点 | operation `4169e168-de24-4e81-916a-e8d1f4d4a572`，用户时间 `18:27:46`，`resource_preparation started → failed → terminal failed`；尚未进入 `input_validation`。记录日期为会话日 `2026-09-07`，不是用户日志日历日的独立证明 |
| 调用链 | `SchemaArchiveInstaller.deploymentDirectories` → `RimeConfigManager.prepareDirectories` → bundle 重建/验证、用户目录/`installation.yaml`、内置安装事务及 custom YAML。任何抛错都被上层归并为 `resource_preparation` failed |
| 雾凇安装计划允许覆盖 `default.yaml` | `rime-ice-plan-1` `allowedFiles` 含 `default.yaml` |
| 万象安装计划跳过 `default.yaml` | `wanxiang-plan-1` `skippedFiles` 含 `default.yaml` |
| 雾凇卸载列表不含 `default.yaml` | 同计划 `removableFiles` 无该文件。即使安装曾覆盖，卸载也不会自动恢复官方 Prelude 字节 |
| 内置更新会校验已有 receipt 对应文件 | `RimeBuiltinResourceInstaller` 对 `default.yaml` 等 required paths 做 SHA/size/set 校验 |
| 字节差异 | 内置 Prelude `default.yaml`：1593 bytes，SHA `0628ada16651d56c4cdfcb8e45ddba23d4d585cc8be0580a62c4e077c0bcc141`（F-02 pin audit）；雾凇 2026.06.30 包：14842 bytes，SHA `0dacfbaca4774c07a0adb2ca2380dc290ada5dfb97e027d54063790ebaca37cd` |
| 雾凇仍引用 `default` 预设 | schema 显式 `__include: default:/punctuator`，并 `import_preset: default`；T9 也引用 default。不能仅排除文件就宣称行为保持 |
| 两个下载方案都允许 `lua/` 前缀 | 目录前缀 allowlist 不是文件所有权；TD-011 已记录 `lua/data/` 与根脚本共存风险 |
| 官方 RIME 允许 custom patch / 替换配置 | 见 §3。这不等于本 App 多个安装器可以争用同一 SHA-gated 文件 |
| 原 source-state 工程片 | PR [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) draft，HEAD `5cec512`；下载来源 pin 与失败隔离已实现。Human 真机复测与 merge 仍未授权 |

### 2.2 建议（未批准）

见 §5。候选 A 为规划建议，不是 Decision。

### 2.3 尚未确认

- 真机异常的具体 `InstallationError`（checksum / byteCount / resourceSet / manifest / fileOperation 等）。
- 覆盖冲突在真实生产安装链上的完整复现。
- 此前设备是否已有有效 builtin generation/receipt。
- 其他同名资源、OpenCC、编译产物冲突。
- 所有升级/卸载/回滚后果。
- 未提交诊断增量若再落地，能否在不泄露路径/YAML 的前提下缩小失败分支。

即使复现 `default.yaml` 冲突，也须排除 bundle 校验、文件系统和 overlay 写入失败等其他分支。

## 3. 权威输入与阅读顺序

1. `AGENTS.md` → `docs/KNOWLEDGE_INDEX.md` → `docs/ACTIVE_WORK.md` → `docs/READING_MAPS.md`（方案下载/安装路径）。
2. 所属 Assignment、`docs/ASSIGNMENT_POLICY.md`、`docs/PROJECT_CONTEXT.md`。
3. ADR 0001/0003 的主 App 写入边界；[ADR 0006](../architecture/decisions/0006-schema-install-transaction-model.md)（事务模型仍 pending，本计划不自动还清 TD-001）；[ADR 0032](../architecture/decisions/0032-verified-scheme-source-recovery-and-integrity-classification.md)；[ADR 0033](../architecture/decisions/0033-main-app-owned-offline-rime-resource-closure.md)（官方字节不可变 + 薄 overlay）。
4. [方案管理](../RIME_SCHEME_MANAGEMENT.md)、[证据](../evidence/scheme-delivery-source-state-001.md)、[评审](../reviews/scheme-delivery-source-state-001.md)。
5. 本计划与 Proposed ADR 0034。领域评审按 `docs/playbooks/`：Main App UI 为主，RimeBridge / Test-Release 为辅，跨所有权升级 Coordinator。

官方依据（2026-09-07 会话已查询；执行时核对 pinned librime，不能把 upstream master 当成本项目二进制）：

- [RIME 定制指南](https://github.com/rime/home/wiki/CustomizationGuide)：推荐 custom patch，支持全局与方案级定制、`schema_list`。
- [RIME 配置说明](https://github.com/rime/home/wiki/Configuration)：配置引用与补丁机制。
- [librime 部署源码](https://github.com/rime/librime/blob/master/src/rime/lever/deployment_tasks.cc)：`default.yaml` 更新/编译；不是本项目 SHA receipt 合同。
- [雾凇上游](https://github.com/iDvel/rime-ice)：`default.yaml` 是整套配置中的共享预设；具体改写以本项目 pinned 归档为准。

RIME 允许替换配置，不等于允许本 App 的多个安装器争用同一文件。由 App 统一管理公共配置是 **待批准** 的架构选择。

## 4. 依赖与归属审计产物（P1，尚未执行）

对内置 manifest、两种已固定 source variant 和生产后处理输出生成一份清单，至少包含：

`logical path / source artifact+SHA / installer owner / consumer schemas / reference kind / transformed destination / mutable-or-immutable / uninstall owner / migration rule`。

审计必须递归覆盖 schema dependencies、dictionary/`import_tables`、`__include`、`__patch`、`import_preset`、OpenCC JSON 引用、Lua `require`/`dofile` 与模块名；动态引用标为 unresolved，不猜字符串替换即可完整改名。比较源归档交集与实际安装交集，区分相同字节共享和同名不同字节冲突。

重点：`default.yaml`、`lua/`、OpenCC、`custom_phrase`、T9、编译输出与缓存清理。当前目录前缀 allowlist 不是文件所有权证明；`removeDirectory` 和 substring cache 删除不能推定安全。

输出应落在本 Assignment 的 evidence 子文档，并记录输入 SHA、工具版本、命令、未覆盖项。不读取或导出用户词典/输入内容。本规划切片 **没有** 这份清单。

## 5. 架构选项

| 选项 | 收益 | 成本 / 风险 | 规划建议 |
|---|---|---|---|
| A 公共基线由 App 管理，方案预设独立命名 | 保持现有共享运行目录及 Luna 官方字节合同；便于统一设置和共存 | 必须完整适配引用、Lua 命名与升级规则；不能丢失上游行为 | 首选 **候选**，依赖审计/行为对照通过后才提交批准 |
| B 安装时合并各包 `default.yaml` | 初始改动可能较小 | 同一键语义冲突，列表/补丁优先级难以稳定，易受安装顺序影响 | 不推荐作为通用策略 |
| C 每方案独立运行资源目录 | 隔离文件命名和默认配置 | session 生命周期、用户词典/同步、磁盘、切换/回滚合同均扩大 | A 无法保真时再单独评估，当前不实施 |

选项 A 若获批，不得偷偷改写 ADR 0033 的官方不可变字节合同。需要改官方文件时，先修订 ADR 0033。选项 A 也不自动关闭 ADR 0006 / TD-001。

### 5.1 待批准决策（阻塞 P2 实现）

未得到 Human Product 与独立 Architecture 书面结论前，不得进入 §6 P2/P3。

1. 是否采纳候选 A（或改为 B/C / 停做共存）。
2. 全局设置、方案预设、用户 `*.custom.yaml` 的优先级。
3. 允许的上游行为差异：雾凇依赖的 punctuator/key_bindings 等，是否必须与官方 Prelude 逐键一致。
4. 同名字节相同是否可共享；共享时卸载如何维护引用计数。
5. 历史设备已被第三方 `default.yaml` 覆盖时：可证明场景是否自动恢复、是否需用户确认、未知修改是否只保留现场。
6. 活跃方案卸载失败时的回退方案。
7. 本 follow-up 的 Executor / Environment Executor / Architecture / Quality 是否仍为原 Codex 任务，或改由后续会话担任。不得把「Grok 写完计划」当成 P0+ 角色任命。

## 6. 分阶段工作包

### P0：冻结现场与复现（规划完成后的第一项技术工作）

入口：Human 明确授权 P0。本规划提交 **不是** P0 授权。

- 保存工作树 checkpoint（用户授权后再 commit/push）；记录 HEAD、base、代码 diff hash、归档 hash 与环境。
- 在临时根建立有效 builtin generation/receipt，通过真实雾凇安装逻辑写入同根，再调用生产使用的验证/准备步骤，捕获受控错误类型。
- 对照：仅内置、内置+万象、无 prior receipt、重复部署。若现有 API 绑定 App Group，仅增加可测试的路径注入接缝，生产路径保持不变，不另写一套假安装器证明自己。
- 必要时为 `resource_preparation` 加有限子阶段/`InstallationError` 分类；不输出 `localizedDescription`、路径或 YAML。错误分类失败仍保留 unknown，不猜测。未提交诊断增量可在另授权后复用或重做，不得从记忆补代码。
- 出口：可以稳定复现并解释失败机制；否则停留调查，不修改校验或来源 pin。

### P1：依赖审计与 ADR 决策

- 完成 §4 清单，验证 A 的引用改写是否闭合，并与 B/C 比较。
- 把明确的设置优先级、文件 ownership、升级/卸载合同写入 ADR 0034，再申请 Accepted。
- 出口：独立 Architecture 评审与 Human Product 决策；当前 Proposed 不自动转 Accepted。

### P2：安装与有效配置生成

- 将原始 pinned 资源和生成后的适配内容分开识别，保留来源证据；不改 App bundle 官方字节。
- A 若获批，对方案所需预设采取独立名称及显式引用适配；验证默认继承和显式 import 均保真。
- 安装前检查所有路径冲突、依赖缺失和保留路径；校验通过才进入写入阶段。
- 使用 manifest/receipt 记录精确文件归属；相同内容共享也需显式引用关系。失败不把不完整 generation 标成可用。
- 保留单写者、commit lease、取消、staging 校验、清理与回滚边界。评估现有逐文件覆盖实现是否需要事务扩展，不擅自声称现有下载安装已经原子化。
- 变更 plan/post-processing 时递增版本与 staged identity，重新计算 Lua 开/关及各 source variant 摘要；保留旧标识日志解码。不得为了通过测试直接更新预期 hash。

### P3：已污染状态的有界恢复

- 覆盖当前真机场景：旧 installer 已写入第三方 `default.yaml`，builtin receipt 验证失败。
- 只使用可信 bundle manifest 和已知发行包/适配版本证明归属；不能信任失效 receipt 自报路径后批量删除。
- 已知污染字节：提出可审计、带备份/回滚的限定恢复事务。未知用户修改、异常 receipt、未知版本：保留数据并停止，按获批策略提示用户。
- 明确事务步骤、备份保留、失败注入点、恢复重入和成功后清理。不能「每次部署先覆盖回来」，也不能强制重签现有文件来消除错误。
- 保留 userdb、用户 custom 设置和其他方案文件；验证恢复后重复执行幂等。

### P4：升级、卸载和回归

- 根据精确 ownership 删除，不按宽泛 `lua/` 或 build 文件名子串推断归属。
- 活跃方案卸载/升级失败时的回退行为必须先按 Product 决策冻结。
- 检查用户通过 App 设置的 overlay 是否仍覆盖正确目标；不把 `schema_list` 错改成无条件启用所有已下载方案。
- 变更实现后完成 §7 自动化矩阵及严格门禁，独立 Quality/Architecture 复审。

### P5：真机与交付

- 向用户提供唯一项目路径、候选 commit/工作树指纹和明确日志标识，再由用户 Cmd+R。
- 主 App 日志验证安装→资源准备→输入检查→引擎→runtime smoke→terminal；Lua 单独报告，不冒充基础成功门。
- 用户验证内置/雾凇/万象实际输入及跨页错误隔离。模拟器不能替代真机。
- 回写 Assignment/evidence/review/CHANGELOG；commit、push、PR 更新、merge、TestFlight 分别核对已有授权。不得自动将 PR #100 宣称可合并。

## 7. 验证矩阵

| 场景 | 必须证明 | 谁执行 |
|---|---|---|
| 干净内置→雾凇→万象；反向顺序 | 公共受管源字节不变；各方案有效配置与安装顺序无关 | 自动化 + 真机 |
| 同方案重复安装/部署；已有旧 nightly | 幂等；版本识别、受控迁移正确 | 自动化；真机抽检 |
| 雾凇/万象各自升级 | 不改另一方案、用户配置和词典；摘要/receipt 更新准确 | 自动化 + 真机 |
| 卸载任一方案，另一方案仍在 | 仅删自身所有/不再引用资源；剩余方案可部署可输入 | 自动化 + 真机 |
| 缺依赖、同名不同内容、未知动态引用 | 安装前明确拒绝，不留下半安装状态 | 自动化 |
| 已知 default 覆盖；未知修改；坏 receipt | 仅已批准可证明场景恢复，其他保留现场拒绝 | 自动化故障注入 + 真机已知场景 |
| copy/rename/overlay/receipt 失败、取消、恢复再失败 | 不错误标记可用，可回滚或保留明确恢复状态 | 自动化 |
| Lua 开/关、T9/全键、Luna 转换 | 保留各自既有合同，固定输入 smoke 使用测试夹具，不记录用户输入 | 既有测试 + 真机抽检 |
| 日志关闭、category 关闭、写入不可用 | 业务结果不依赖日志；开启后有限字段可显示/检索 | 自动化 |
| 既有错误 UI | 方案失败不会污染另一详情页；重试绑定原 schema ID | 已有 PR #100 测试；真机复测仍待 Human |

门禁：按 `AGENTS.md` 当前 CI 顺序执行变更 Swift strict-format、KeyboardCore、RimeBridgeTests、App/Keyboard tests、Debug/Release build、轻量与 pinned KOS 检查。使用单独 DerivedData，不与用户真机构建争用。来源/身份改动必须跑真实归档生产后处理测试，不能只测 fake。本规划切片为 docs-only，不跑 xcodebuild。

## 8. 接手说明

- 修复 clone（规划提交后仍用它，或从 `origin/codex/scheme-delivery-fix` 建新 worktree）：`/private/tmp/uk-scheme-delivery-fix`。
- 分支：`codex/scheme-delivery-fix`。规划提交前 HEAD 为 `5cec512f5fdc8c654a3cd3186dc080d947e5b37f`。接手先 `git rev-parse HEAD` 与 `git status`，确认计划文件已在 HEAD，而不是只存在于 `/tmp` 未跟踪文件。
- PR：[#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) draft。本规划是同一分支上的 docs follow-up，不把 PR 改为可合并。
- 原工作区 `/Users/doubleshy0n/Dev/Universe Keyboard` 是另一 checkout（`main`），不能在那里直接继续或覆盖其文件。
- `/private/tmp` 不是长期存储。规划文档必须以 git 对象存在于该分支；未 push 的本地 commit 仍可能随机器清理丢失。
- 雾凇夹具：`/private/tmp/rime-ice-20260630/github.zip`、`nju.zip`，16050491 bytes，SHA `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac`。使用前重验。
- 模拟器：`36BAABED-6846-4F9A-A672-6884B54CF50E`，iOS 26.5，Xcode-beta。旧 DerivedData `/private/tmp/uk-scheme-fix-derived`；并行工作另设目录。
- PR #100 已测范围只覆盖 source-state 工程片，不覆盖本计划的 ownership/恢复。独立评审不继承到 P0+ 实现。

接手只读核对：

```sh
cd /private/tmp/uk-scheme-delivery-fix
git status --short --branch
git rev-parse HEAD
git diff --stat origin/codex/scheme-delivery-fix
test -f docs/plans/scheme-resource-ownership-and-coexistence-plan.md
test -f docs/architecture/decisions/0034-multi-scheme-resource-ownership.md
```

**第一个技术工作包是 P0 的生产路径复现，不是删除 `default.yaml` 或关校验。** 当前只完成规划；不凭计划自行进入 P2/P3。

## 9. 停止条件

规划切片在下列情况停止并交回 Human：

- 需要改 Swift、安装计划、真机文件或放宽完整性校验。
- 要把 ADR 0034 标为 Accepted，或把候选 A 写成现行架构。
- Assignment 必需字段变成 `UNKNOWN`，或与 PR #100 原范围冲突且无法在 follow-up 内隔离。
- 发现编号 0034 已被其他已合并分支占用（本修订核对：`main` `2816009` 与本分支均无既有 0034）。

P0 另授权后的停止条件仍适用 Assignment 原文：未验证来源、staged mismatch、不安全 fallback、扩大来源合同、清理失败。不得为了让测试变绿而放宽这些条件。
