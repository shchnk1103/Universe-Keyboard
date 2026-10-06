# T1 命令与 T2 必要恢复范围冻结

Human于2026-10-03 Asia/Shanghai授权“冻结T1测试命令及T2必要恢复范围”。本轮仅准备，不执行测试、设备访问或恢复；原模拟器独占Human确认沿本轮T0窗口，执行前仍需确认持续有效。root唯一repo writer。完整[结构化执行包](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t12-frozen-packet-2026-10-03.json) digest `090f2f150b018d5d289cfedbb51315c153f700fce9df8ff094631a8ee6743abf`；argv保持数组，含literal `$(inherited)`，不得未经转义拼接shell。包中全部executed=false。

## T1 精确覆盖

| 顺序 | scheme /实际target | 签名及范围 |
|---|---|---|
| 1 | RimeBridgeTests | 无签名完整test，不筛选fixture或skip |
| 2 | Universe Keyboard / UniverseKeyboardTests、KeyboardTests | 无签名完整test；这是两个单元测试target，不含UniverseKeyboardUITests/UI自动化 |
| 3 | Universe Keyboard / RimeSyncModelTests唯一Keychain integration用例 | ad-hoc签名，only-testing限定一个UUID自有账号的新增/更新/删除及异常清理；不读取或清理既有Keychain |

固定Debug、iOS Simulator原UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，Swift6/complete/warnings-as-errors、arm64、DEBUG+KEYBOARD_WAKE_OWNER_PROBE；禁parallel testing/clone，最多一个destination，不更新package或Vendor。新独立执行根`/private/tmp/ukey-wake-ui-t1-execution-20261003`，每套独立DD/xcresult/log，H1冻结SourcePackages先复制到新cache并核pins，缺依赖即停，不下载补齐。执行前核实际flags与target归属；test-host产物不是H1可安装standalone候选，不把测试自动安装的App当作新UI候选已晋级。

## Core 证据复用

本轮204个package文件逐字节与[C7-B2完整输入manifest](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-artifacts/package-input-manifest.json)一致，git非忽略文件集合亦一致；571源码/build输入及630Vendor匹配H1。只读版本查询为Xcode27.0/27A266a、Swift6.4.0.34.1、arm64macOS27.0，符合原完整strict host环境；唯一新UI差异不在Core包。按AI_WORKFLOW最终内容/基线/环境/覆盖条件复用[1194/0/0完整host结果](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-validation-2026-10-02.md)，不重复Core。该结果不覆盖UIKit/真实appex/专用probe运行，T1实际三套仍执行。执行前任一复用条件漂移则停止并解释，不自动换成重跑或修源码。

## T2 限定的数据保护范围

以[T0完整备份](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t0-validation-2026-10-03.md)及[恢复方案](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t0-recovery-plan-2026-10-03.md)为唯一当前基线。每套test之后重新发现app/data/group，保存test-after完整状态并比较；出现failure或数据差异先停下一套，不自动重跑。任何实际恢复均需另获执行授权。

条件恢复只限：测试替换安装包时重安装精确旧C7备份；按manifest恢复当前基线的main-data/AppGroup应用自有内容，并在动作前生成明确逐路径新增/覆盖/移除表，保全测试后内容。保留新容器系统UUID/登记/rootxattrs与metadata，不整目录覆盖旧身份。未知system/SplashBoard变化、文件归属不明或清单外删除即Hold。诊断恢复为原缺键，部署booleans/链接/文件hash读回。副本新增provenance已披露，只允许原属性保全与分类，不声明全部xattrs完全相同。若残留App/appex影响一致快照，暂停申请精确正常终止权限，不自动kill/restart。

不包括新UI候选安装、RIME重新部署、历史丢失数据恢复、全模拟器/Keychain恢复或全局清理、用户输入/UI自动化/Maps/arm/LLDB/Git/Release。恢复未实测；成功readback后如需运行健康证明，另授权启动及Human候选/提交核验。

## 执行门与交付

**当前T1/T2仅冻结、未执行。** 下一最小授权为“执行本冻结T1三套及T2每套后的只读数据核验；需要恢复时先呈现逐路径清单再决定，或明确授权本包限定的条件恢复”。不能从本次“冻结”推断执行权限。执行前再次核source/vendor/toolchain/完整backup/source身份、持续独占及App/appex退出。当前备份metadata例外不得隐瞒，未满足必要证据就停。

actual结果以xcresult实际用例数/pass/skip/failure逐项记账；历史20+10skip继续未验证，当前新skip需Product单独处置，旧accept不继承，不为历史发现计数差额重跑。最终交付包括原argv/log/xcresult、flags/targets/输入与测试后数据保护读回，独立Quality验收需新冻结packet和明确预算，不预填通过。父子仍Active，无Product/整体Quality Gate、安装晋级或Release。无源码/CHANGELOG/架构合同或M-02 Gate/Close变化。
