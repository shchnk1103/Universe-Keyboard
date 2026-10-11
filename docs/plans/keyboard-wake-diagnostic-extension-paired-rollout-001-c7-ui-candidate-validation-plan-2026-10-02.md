# C7 UI绑定修复：新候选验证准备

## Scope / Authority / Baseline

Human授权“可以只补正其一致性，再准备新候选验证”。当前只有旧静态报告/usage一致性补正与新候选验证**准备**，不执行build/test/install/device/LLDB/Maps，不新增源码。root Coordinator/Environment Executor唯一repo writer；独立Quality新round2仅一致性，不覆盖此候选runtime。

沿[本地修复](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-probe-ui-binding-validation-2026-10-02.md)：原worktree/branch/HEAD不变，571 source/build输入冻结SHA `5f16aa1031b1ee4a90d72e4d15693e3656b0c746bcd71a10874e90655a0269c9`，仅Presentation单文件改变。该571字典规范化sorted compact JSON、UTF-8、ensure_ascii=False。原candidate digest ddd557…/installed78/正常路径528字节/5行仅绑定旧源码；当前已消费frozen实例不自动rearm。

## 分阶段候选验证

| 阶段 | 执行前Entry / 工作 | Exit与停止条件 |
|---|---|---|
| H1 host standalone | 另授权host generic SDK-only构建；源码571、Vendor630/锁文件/SDK/Xcode实际版本/专用编译flag核清。新独立scratch DD/results；不下载新依赖、不更新package，不把SDK或解析当作模拟器实例验证。 | 单独可安装App/appex，不含test-host；保存构建命令/日志/xcresult、全部payload hashes、每个MachO SHA/UUID、Info/version/build、签名校验及嵌入entitlement section原字节对应xcent；形成新candidate digest。UNKNOWN/mismatch=>停。 |
| H2普通模式隔离 | host普通Debug和Release对照；条件移除KEYBOARD_WAKE_OWNER_PROBE。重用旧普通模式证据必须逐项满足AI_WORKFLOW的最终内容/覆盖/环境条件，否则重新构建。 | 专用Debug探针存在；普通Debug/Release符号/产物未带入探针入口。Release SDK编译证据不是Release授权。 |
| Q新candidate独立绑定 | 新冻结packet/预算，Quality确认source→command→最终payload；Architecture只做新产物entitlement字节绑定和局部影响分析，旧static结论可依显式影响分析作为输入，但不复用旧candidate UUID。 | 每项新身份与有限scope结论明确；Partial/Hold不安装；一致性R2不自动充当新candidate评审。 |
| T实际套件 | **测试前**先获指定原模拟器fresh独占、完整当前main data/App Group/installed App备份及可执行恢复方案，再授权实际测试。不得等到候选安装前才备份。 | Core、RimeBridge、App+Keyboard所需覆盖按当前内容/命令/环境条件核对；App+Keyboard UI target必须实际执行，syntax不能替代。原30skip仍skip，当前用例数记实际，不为发现数差额凑数重跑。 |
| I候选安装 / 新环境读回 | 测试后的环境可能换bundle/data/group容器；先逐字节核验健康部署和数据，必要恢复按已授权恢复方案。另一次完整fresh backup/readback保护新安装前当前数据；FullAccess/diagnostics原键值及存在性重新核。 | 精确新payload/UUID/install identity，主App/appex配对，当前部署健康、data保护证明；缺失/不可恢复=>停。旧数据未恢复事实不被新baseline掩盖。 |
| U探针UI单轮 | 在新候选主App搜索页、另授权正常路径单轮：以可测时刻记录停手到显示，arm前空候选观测可见；arm后停手取证文字；候选时隐藏policy按未arm/armed分别验。 | 真实显示文字、时长、候选正常，出口有限导出/cleanup，不通过截图时间差或主观“约一分钟”算计时。未响应/异常=>停，不重启补成成功。 |
| M Maps后续 | UI入口可靠且新取证链有效后，才另授权直接AppSwitcher回Maps的目标variant。新fresh独占/真实appex PID/唯一export断点及完整当前数据恢复条件。 | 两次受控insert配对、owner/receipt有限结论，故障表征逐项记录；不因owner0推根因，不自动重采/猜修。 |

各阶段Ready只能写已取得证据，以下UNKNOWN是准备占位而非放行：H1构建授权/实际SDK工具链及新candidate=UNKNOWN；T/I/U/M fresh独占、当前完整备份、数据恢复实效、新FullAccess、当前诊断键存在性=UNKNOWN。当前不访问设备来填占位。

## 命令与产物模板

[host build argv准备件](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-candidate-prep-artifacts/host-build-command.json)沿原可安装standalone generic Debug规则，改用 `/private/tmp/ukey-wake-probe-ui-candidate-20261002` 下全新DD/SourcePackages/xcresult。不执行模板。`$(inherited)`保持literal argv，未来使用结构化extraArgs或Python subprocess(argv)，不能未经shell转义拼接。

依赖定位/专用flag/签名需执行前核：Swift6 complete warnings-as-errors，arm64，DEBUG与KEYBOARD_WAKE_OWNER_PROBE；ad-hoc Simulator签名，CODE_SIGNING_REQUIRED=NO。不降低warning/concurrency；缓存manifest/权限故障只做获授权SDK工具fallback，不触碰当前模拟器实例。完整raw备份留private scratch，不将用户数据或内容复制到repo证据；只归档hash/计数/有限状态证明。

T环境固定目标仅iPhone18Pro/iOS27.0、UDID405D994F-28CB-4F89-BB22-B64AD81C05A2。新fresh独占必须覆盖测试、恢复、安装及人工窗口，旧授权不代新窗口。parallel testing禁用且最大destination=1，不创建clone或替代工作树，不使用其他任务设备。测试动作可能替换App和AppGroup，不能把测试无失败当作数据未改变。

skip处置当前仅准备：旧Rime20/App10逐项与本次套件结果和fixture根因核对；签名Keychain单独通过不改写原unsigned skip。旧C7安装/取证残项接受不能自动计入新候选已验证或Release；若仍需阶段nonblocking接受，由Product另对当前实际残项决定。429/428、432/431等历史差额原样保留，无count-only重跑。

## 本轮完成边界

只提供新candidate验证可审查步骤和argv；无新candidate产物或新测试结果，源文件未再变。旧round1/正常路径原正式Partial/超时记账保留；一致性补正不接受旧budget缺陷。当前无commit/push/Release/Gate/Close。无需CHANGELOG或架构合同改动，无M-02生命周期触发。
