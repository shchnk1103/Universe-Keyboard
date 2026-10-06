# F3→F4 最小晋级准备 — 2026-10-05

状态：**Prepared，非Ready**。Human“可以按照你的建议继续做这份支付准备”按当前建议的晋级准备执行；root仅Coordinator读取既有证据、准备治理交付。未新增独立审查、测试、构建、设备查询、备份、安装、LLDB、Maps或清理；Grok仍唯一源码writer。

## 当前事实与证据适用性

工作树、branch、HEAD保持既定身份，staged0。[输入读回](keyboard-wake-host-activation-fix-001-f3-f4-prepared-artifacts/input-check.json)确认1156构建清单行、13pinned输入和四原日志hash相符；完整dirty只读快照保留。当前五文件与A2矩阵/复审候选一致。

| 依赖 | 已完成 | 尚需核清 / 决定 |
|---|---|---|
| Architecture | 原A1与A3静态覆盖；A2-1/2/3及旧A2-F1 Covered；A2-4编译证据独立Pass，有界收件已获Human接受 | root仅提出原A1/A3未受四文件修正影响的适用性，不替作者签发整体新候选Gate |
| Quality Q1/Q2 | [当前候选完整矩阵](keyboard-wake-host-activation-fix-001-a2-validation-2026-10-05.md)：Core1194、Bridge85pass/20skip、App444pass/10skip、gate23/23、signedKeychain1/1、Release配置build；四Swift实际编译，Swift诊断0 | 旧F3 Quality针对前候选17项及旧矩阵，不能换hash直接沿用；新A2-4审查只判编译，未独立覆盖当前完整计数/skip/环境交付 |
| Quality Q3 | [本次before机器恢复](keyboard-wake-host-activation-fix-001-a2-before-restore-2026-10-05.md)两读通过 | 新恢复与metadata例外不是旧Q3报告的那轮；最小Quality增量核验仅已有原件，不操作设备 |
| 审计 | 原F3 Quality作者内容Pass with conditions，超预算58.326秒且stop_reason矛盾原件保留 | F3-Q-AUDIT-001由Human决定是否接受为历史流程残项；不回填假预算，不复用过期技术结论作新Gate |
| skip | 当前A2矩阵30项仅本阶段接受、保留skipped | F3/F4前Q2-R1需Human明确阶段处置，不计通过、不用于Release |
| Runtime | 原模拟器before旧C7恢复，未启动/试打 | 精确新候选尚未F4安装/运行；真实通知context、controller恢复、owner/receipt和Maps结果待证 |

上述适用性是Coordinator影响分析，不冒称独立Quality/Architecture新结论。源码/依赖变化或独立指出覆盖缺口时，依赖部分停止，不能靠Product残项接受替代必需技术覆盖。

## 运行时日志定点分类

[完整定点行清单](keyboard-wake-host-activation-fix-001-f3-f4-prepared-artifacts/runtime-log-inventory.json)绑定四原日志SHA与行号。原Quality回复“10条＝Rime2＋IOHID8”是大小写Error文本的计数，遗漏紧邻的`invalid schema definition`错误级行。当前补正为**RIME错误级3条＋IOHID加载Error8条＝11条；另有IOHID factory伴随信息8条**。不把这19行冒称全部系统错误枚举，亦不把伴随信息重复算成8次独立加载故障；原reviewer回复不可改写。

| 类别 | 原日志位置 | Coordinator事实 / 推断边界 |
|---|---|---|
| RIME malformed YAML及invalid schema（2条） | Bridge1910/1911；testRealDeployerFailsClosedForMalformedSchema | 源测试主动写入`schema: [`并断言deploy=false；原日志同用例Passed。可确认负向fixture相符，不证明运行中所有schema正常 |
| RIME essay read-only db（1条） | Bridge1697；testDeploymentServiceObservesRealTerminalSuccessAndFunctionalSchema | 用例断言deployment succeeded/runtime smoke=true，原日志Passed；essay错误原因/功能影响仍未独立定性，不称无害，不追查新范围 |
| IOHID loading（8条）与factory companion（8条） | App2950/2951、2954/2955、2960/2961、2964/2965；Keychain1723/1724、1727/1728、1740/1741、1744/1745 | 系统IOHIDLib插件路径加载失败与配对factory缺失，发生在测试宿主，非Swift编译诊断。测试结果通过不证明这些消息无运行影响；其与Maps/Keyboard恢复无因果证据 |

本轮仅分类已出现行和测试上下文；不因此请求新部署、Vendor修复或全环境调查。独立Quality下一步只判它们是否阻塞本次诊断安装/Maps验证，不需宣称根因或无害。

## 下一最小授权提案：F3当前候选Quality增量收口

建议复用Assignment已绑定 `/root/m2r2_quality_r1`，只读当前A2矩阵实际结果/23方法/skip身份、精确输入、恢复原件及上述日志分类，并记录对旧Q1/Q2/Q3的增量适用性。排除源码泛审、A2重新审查、旧预算重新审计、原始日志无限扫描、测试/模拟器。由root提前冻结exact-path/hash packet，派发前写出流程预检；reviewer先写ACK及报告/usage骨架，结束前更新并读回，避免内容完成而文件缺失。

预算提案：16实际调用/15分钟先到停止，8/12检查点，最后4调用仅交付；达到12调用尚有技术覆盖缺口即写Partial/未覆盖并停，不自动补回合。Product未批准不派发，不以本准备替代ACK。Quality只可判当前候选证据适用性/阶段风险，不处置Human审计/skip权限。

Human可另作两项狭义决定：①将F3-Q-AUDIT-001接受为历史流程残项，保留超时与文字矛盾、不修史；②仅本次F3及后续单轮F4，将同一30skip保持非阻塞未验证，新增skip/fail仍停止。这两项均尚未接受；不包含安装授权。

## F4后续准备顺序（未授权执行）

1. 当前候选F3技术覆盖与Product两项处置完成后，冻结唯一Debug主App+Keyboard配对产物字节、签名、UUID及构建来源；若缺可安装产物，只准备最小构建方案另授权，不能把Release配置build当已授权安装包。
2. 新鲜原UDID独占、静默进程与完整main-data/Group/installed-app before备份、精确恢复方案、diagnostic原值/存在性；任何进程终止/部署需相应授权。现有备份不覆盖，不默认适用新的现场。
3. 先新候选正常输入健康，再仅一次Maps空搜索框正常输入→AppSwitcher打开后直接回Maps（不切设置）→返回后按键/候选/宿主/提交，并收内容无关通知context、恢复action、owner/receipt配对证据。观测工具/LLDB若必需，先冻结精确方法与非干扰边界另授权；只UI正常不证明真实回调。
4. 结束清理调试器/恢复诊断原值及存在性，保全after；故障/不可证记failed或inconclusive，不循环试打。恢复数据或安装必须与预审差量及授权绑定。

此文不是可直接执行的F4命令包，device现场/产物身份/取证方法仍待F4准备核实；F4未Ready。

## 进度与完成边界

按工程工作量粗估约80%，不是测试通过率或日期承诺：诊断有界父任务已Completed；新修复源码、完整矩阵与A2定点复审完成，整体Quality收口和F4真实通知/Maps回归未完成。后者是修复有效性的关键，不能以23项单测外推。Release/真机/提交推送未纳入本进度。备份当前仍保护恢复及取证，暂无本轮删除决定；满足新候选验收与恢复保留条件后再列可清理清单交Human。
