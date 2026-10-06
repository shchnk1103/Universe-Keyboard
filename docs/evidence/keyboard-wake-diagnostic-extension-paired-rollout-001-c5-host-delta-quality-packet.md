# QUALITY-C5-HOST-DELTA frozen packet — round1

WorkItem `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`；stablelaneQUALITY-C5-HOST-DELTA，positive round1；原独立GPT6LunaQuality runtime复用，未参与源码实现。Baseline HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`，branch `codex/keyboard-wake-v3-compatibility-gate`，candidate `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9`；worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`。Human仅授权本lane只读hostdelta确认，4底层tool/300秒，checkpointafter2。

Manifest `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-input-manifest.json` SHA256 `69b8179e3549d0f487253b23a98f03c8ea4f6fcb2c4c0010301b01db2434c48b`；Entry `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-entry.md` SHA256 `5c2432915d2dfa75d964c1dcd5eb7dd22824b73466e06847943e46d5617a8012`；packet SHA由root派发，不自引用。原C5-P超时Partial和Architecture呈现/计数限制保留；旧C5-I安装111/11证明、FullAccessHuman观察仅historicalartifact，不是当前设备证据。

## Decision / Complete positive coverage

H1：直接源证据说明SearchTab真实TextField、@State query、本地设置catalog匹配、query无直接网络/persistentwrite；区分onAppear的RimeSettingsStore.load可写firstlaunchdeploymentintent（当前旧rime_deployedtrue观察不保证未来），不得称任意环境零副作用。比较与DictionaryBrowserView路径改变，明确无源码/二进制改变。
H2：判断现有一次Human操作/三类typedmarker/同origin/process/appearance/localSeq+monotonic关联、started/returned有限语义、窄导出/reader completeness/键恢复/noautomaticretry，能否适用SearchTab。引用旧P-Q覆盖与不变source/artifact身份；不点击搜索出的设置项、不导航结果、不记录echoedquery或截图。30C5skip保持已接受未验证，不扩大阶段；duplicate-member及其他runtime缺口保留。若source显示必须新采集合同/实现则Blocker，不猜修。
H3：给出本lane必要blocker/无新增blocker、host重绑结论及C5-R futureEntry（精确当前installedrebind、新独占窗口、明确诊断/一次合成输入/capture/restore授权和操作分工）。只有上述H全部正向Covered且预算内才能说此scope确认完成；无currentdevice/appexloaded/runtimecallback/overallGate断言。不代Product接受host替换或授予C5-R执行权限。

## Allowed reads / writes / tools / data

只读manifest列明22input文件、568source/build文件（仅必要旧callpath核验，别新遍历）、111builtbundlefile及manifest/Entry/本packet。不得读当前Simulator/installeddirectory/AppGroup/prefs/journal、他lane未列report、日志/输入/截图；无网络、UI、build/test/install/arm/input/Maps/source/Gitmutation。仅写 `/private/tmp/ukey-wake-c5-host-delta-20261001/quality-review.md`、`quality-usage.json`、`timer.json`。遵守test-releaseplaybook的证据/非claims边界。

## Budget / exact timing / checkpoint / stop

最多4底层工具/300秒，包括初次packet读取和最后写输出。第一次exec_command开头用Python datetime/monotonic立即写timer.json，然后一次读packet/manifest/Entry核对SHA，向rootexactACK。第2调用可batch本地input/source/builtbundle hashes与四hostsource及旧review/plan读取；之后立即checkpoint，最后1–2调用只完成必要核查/写output。**优先3调用内、简短报告（约500–900中文字+H矩阵）完成**，避免不必要全文注册表。wrapper/协作消息不计底层数但耗时计墙钟；不用单独clock工具；输出后不得额外ls/clock第5次。接近240秒优先写已有结果，未覆盖Partial；300秒届满禁止继续审查或补写Pass。

每个嵌套exec_command/clock分别算底层；本地文件I/O/hash不算外部tool。checkpoint严格after2 before3，账本记录实际调用/起止UTC/elapsed/checkpoint。历史beforestatus不同不单独视为漂移；新manifest允许授权bookkeeping，直接hash若不同立即Hold/Partial。required evidence missing/unknownscope或预算耗尽即停止，唯一扩scope/budget authority为HumanProductLead，root/reviewer不能自行放宽。

## Outputs

中文report含精确身份、H1/H2/H3矩阵（source行号/证据路径）、新宿主风险与最小建议/owner、有限scope verdict和明确C5-R待授权。不重复整个历史。UsageJSON含lane/round/三摘要、input/source/bundle匹配、真实计时/toolledger/checkpoint、未执行动作。原source/旧review不可改写。
