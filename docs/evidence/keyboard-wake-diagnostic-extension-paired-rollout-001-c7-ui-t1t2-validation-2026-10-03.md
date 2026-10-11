# T1 实际测试 / T2 只读核验交付：数据保护 Hold

Human授权执行T1＋T2只读核验，沿[执行Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1-execution-entry-2026-10-03.md)与[冻结包](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t12-frozen-packet-2026-10-03.json)。实际两套无失败，但 **T1整体Partial/Hold，Keychain未执行**；T2发现容器/数据变化后按规则停止，未恢复或继续下一套。父子Assignment Active，不是Product/整体Quality Gate或新候选runtime通过。

| 实际套件 | xcresult实际总数 | passed | failed | skipped | T2 |
|---|---:|---:|---:|---:|---|
| RimeBridgeTests | 105 | 85 | 0 | 20 | 三容器与T0完整清单相同，两次稳定读回，无目标进程 |
| UniverseKeyboardTests＋KeyboardTests | 431 | 421 | 0 | 10 | App/data路径迁移、AppGroup当前查询为空且原路径不存在，Hold |
| 签名Keychain专项 | 未执行 | — | — | — | 不把旧1/0/0或本轮unsigned skip充当通过 |

Core204包输入收尾仍匹配，复用原strict完整host1194/0/0，不覆盖UIKit/appex。source571/Vendor630前后匹配；实际argv按冻结数组执行（Rime27.936s、AppKeyboard68.760s，各exit0）。9/18条实际Swift invocation确认Swift语言6、DEBUG/probe及warnings-as-errors；complete build setting按冻包请求，实际Swift6 driver未显式输出冗余strict-concurrency flag，不能虚报其字面出现。MCP defaults指向其它任务，未修改其配置；采用结构化subprocess xcodebuild保证原UDID/argv，原raw日志及xcresult留private执行根。xcresulttool因沙箱TestReport内部缓存权限问题采用主机提取，不重跑。

[summary/argv/skip/flags及收尾receipt](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1t2-artifacts/)归档。Rime测试树最初把两个Skipped suite节点计入，最终按Test Case核为20，App10；不通过改计数凑数。历史发现差额原样保留，本轮按实际431记账。当前30skip未验证、当前阶段尚未Product处置，旧accept不继承。

## T2 确认的差异与保护

Rime后main827/group52普通文件＋2链接/app78完全无差异。AppKeyboard后current App是unsigned test-host payload84，main872文件；当前simctl groups返回空，原Group0296…路径不存在。仅证明当前注册Group及原路径不可用，不断言其它系统位置不存在副本。无目标App/appex进程，现有main/app两次读回稳定。

main应用数据改变4项（TipKit db/shm/wal与group preferences），新增46应用路径；四个SplashBoard旧路径换为四新路径但内容SHA多重集相同，系统身份/更名须保留单独分类。App payload被测试替换，不能当作H1 standalone新UI候选安装成功。见[只读receipt](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1t2-artifacts/AppKeyboard-T2-receipt.json)及[Group缺口](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1t2-artifacts/AppKeyboard-T2-container-gap.json)。

T0原完整backup仍在 `/private/tmp/ukey-wake-ui-t0-20261003/backup`；当前测试后main872/app84亦完整复制到 `/private/tmp/ukey-wake-ui-t1-execution-20261003/test-after-preservation`，内容/结构核验与只读清单相同，raw内容不进repo。metadata全相同未宣称，T0副本provenance限制继续披露。本轮未覆盖或删除模拟器数据、未恢复、未重装、未部署、未启动UI/输入/Maps/LLDB/Git；测试自身启动/安装是授权test动作副作用，不能称全轮从未install/launch。

## 下一最小恢复提案（未授权、未执行）

[定点恢复清单](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1t2-artifacts/T2-proposed-restoration.json)和[T0恢复方案](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t0-recovery-plan-2026-10-03.md)具体化：重安装**旧C7完整备份**使AppGroup重新登记；重新发现新容器后恢复原Group应用自有文件/目录/两个链接，保留新系统metadata及root身份；main仅恢复4项变化数据、处理清单内46新增应用路径（测试后状态已保全），保留内容等价的系统快照路径迁移。安装引入的新差异先对比并交回，不作未列删除；诊断须恢复原缺键，保留部署原状态。

恢复要另获Human授权；未知新差异、不可恢复metadata、目标process重新出现、backup漂移立即停止。恢复后的文件readback与另授权Human健康验证完成前，不继续Keychain、不安装新UI候选、不宣布环境恢复。无需重跑已成功两套或历史计数。原历史数据损失、skip、Partial保持；当前backup使本轮可受控恢复，不等于恢复已成功。
