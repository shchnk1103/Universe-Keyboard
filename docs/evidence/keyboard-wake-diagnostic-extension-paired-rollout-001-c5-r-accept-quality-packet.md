# QUALITY-C5-R-ACCEPT frozen packet — round1

WorkItem `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`，lane QUALITY-C5-R-ACCEPT round1；原独立GPT6LunaQuality reviewer复用，不曾实现source/执行C5-R设备或采集。Human仅授权一次已归档运行证据只读独立验收。HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a` branch `codex/keyboard-wake-v3-compatibility-gate` candidate `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9` run `C5-R-20261001-01` worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`。

Manifest `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-accept-input-manifest.json` SHA `91c0f006b6376cb6944590a51486a90145d91453806da96bcebf58d38f2ab8ca`；Entry `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard/docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-accept-entry.md` SHA `44ab7e3a025bba8ca5fe4c21969ea59667a11a79bec002f7f9fc4e29a07647be`；packet摘要root派发。允许30repoinputs+3scratchscript、568source-build及111builtfiles读取，仅必要callpath，不新遍历旁支。旧receipt是历史快照，其owner/statussha不与新freeze当前owner/status比较；当前manifest directhash才基线。

## Required complete positive coverage R1–R4

R1身份/来源：独立核三摘要、HEAD/branch/candidate/run、30inputs+3script/568source/111builtSHA。核C5-R Entry/source→retainedDebug→actualinstalled前后历史111/11凭据；projection脚本只筛授权窗口三种code，非完整raw replay，评价来源充分性/局限。不得读脚本内指向的device文件或执行采集/preflight/final-check脚本，只把脚本文本作为来源方法证据。
R2标记：独立从typed-window解析重算17、同origin/process/appearance、localSeq/monotonic严格关联与window范围，检查finiteenvelope/payload、lifecyclewill/did及resume started、6set_marked_text和1unmark_text配对正序，actionSequence缺失不伪造transaction。不把人说“提交有反应”补成insert_text；无insert/tail分别按实际notobserved/supplemental。结合真实源码boundary，判断只对本轮宿主可作何肯定结论；started非ready/returned非accepted。
R3MainApp reader：独立读原C5plan reader完成条件、MainApp DiagnosticsLogSource/Store/View callpath及Human三类可见/无warning记录，区分Python投影与实际Human当前同配对App渲染。**决定Human可见证据是否满足当前限定reader判据，是否仍有必须关闭的runtime验收缺口**；不能预先按root结论Pass或把未采到的内部计数/逐条消费发明为通过。若完整reader条件仍未被证明，明确必要blocker/partialruntimeaccept与最小补证建议，不自动接受为残项、重跑或操作设备。coverage可Covered（已全面评估），但验收结论可Hold；必须分开。
R4恢复/残项/权限：核Human先arming使original值/存在性UNKNOWN→EntryHold→Human本C5-R明确acceptnonblocking-unverified→off/off恢复machine状态（loggingfalse/expiryabsent/DISPENGINE仍absent）。不称originalabsenceexactrestore、不扩大accepted范围。30C5skip仍notpassed及duplicate-member残项保留；1Human轮/0retry、source/built/installed不变/保全、parentActive无Maps/Release/rootcause/Gate。判断新的必要findings/owners，无则明确限域结论。

## Tools / data / writes

仅本地exec_command读取allowlist、Python hash/JSON/内容无关分析，git只读HEAD/branch/status/diff。无当前Simulator/device/installedcontainer/AppGroup/prefs/journal/UI，不执行3采集脚本，不网络、build/test/install/input/arming/source/Gitmutation/Maps/Release，不读取未列其他lane报告。可读取manifest中的built_bundle_root（本地留存build），它不是installeddevicepath。只写 `/private/tmp/ukey-wake-c5-r-accept-20261001/quality-review.md`、`quality-usage.json`、`timer.json`。root是唯一repo writer。

## Budget/checkpoint/stop

最多6底层工具/480秒，包括初读与所有outputs落盘。第1exec_command开头Python UTC+monotonic记timer，再核packet/manifest/Entry三SHA并exactACK；可batch所有hash与runinputs。第2后立即checkpoint再第3；若到第4后仍未完成，必须第4后checkpoint再第5。可提前4调用完成（建议：1identity/hash/runJSON，2必要source/原plan评估，3剩余核查，4输出）；不用额外clock/ls。每次exec_command/clock分别算底层，wrapper/协作消息不算工具但墙钟计时。

第360秒优先写已有短报告，不留交付到最后。output JSON只用基础types，先json.dumps验证，禁止set/Path/datetime直接serialize；完整计时到输出全部落盘（可写timer一次后采末端时间再原地补写，使有明确terminal-write备注；不能无限自引用时间），toolledger包括实际起止/用途、checkpoint、elapsed；耗时或工具耗尽停止Partial，不追加调用。Scope漂移/UNKNOWN需必要新输入则报locator和剩余覆盖停止；只有HumanProductLead/AssignmentAuthority可授权新范围/预算，root/reviewer不能自行renew。

## Deliverables / verdict

中文简短report约800–1200中文字+R矩阵、source/evidence定位、coverage与boundedruntimeacceptance分离、必要findingID/owner/最小补证、完整非claims。usage三摘要/hashcounts/actualtoolledger/start-endelapsed/checkpoint，timer完整。R1–R4必须全Covered且预算内才“独立只读验收工作完成”；接受结论仍按证据可能BoundedAccepted或Hold，不代Product接受newgap。原证据/Partial绝不改写。
