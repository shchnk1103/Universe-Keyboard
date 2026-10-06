# AP-META-004 Quality round 1 — 独立只读验收

## 范围与结论

审查仅覆盖 packet 冻结的同一轮 AP-META-004 元数据停点身份与其范围/交付记录。Packet SHA-256 为 `fd5da48966c5fbb1e198f83ae6819514fc7109eb06929311e8899e6399353b55`；reader 是 **74,975 bytes**、SHA-256 `a5cb4b5623852ee0bf6825fe707cb12e954bdd15884409b5e7fb678d46d369be`，含 23 个 `{path, bytes, sha256, text}` 原始记录。优先读取原始文件并逐项对照 reader 摘要；reader 仅作为文件清单/必要时的代理文本。

**总体结论：Partial。** 精确的 callback/断点/已加载模块/同停点 CLI 身份链可独立判 Pass。两个人工点击的精确事件时间不能由现有 UTC 字段独立证明；且私有 `run-summary.json` 的33-call中间摘要与最终35-call账本保存在不同路径。默认 LLDB 停点格式还显示了参数，相关范围偏差仍待 Product 处置。本审查不替 Product 接受该偏差，不推断 owner 缓冲、Maps 修复或 Release。

## 证据矩阵

| 标准 | 判断 | 证据与边界 |
|---|---|---|
| Q-META-1 | **Pass（仅元数据身份链）** | `configuration-receipt.json`/`live-binding.json` 将 PID 778、loaded UUID `4B207746-89A7-321F-83C4-91477259BB26`、出口符号 `$s8Keyboard25wakeOwnerProbeExportReadyyySV_SitF`、PC `4331007904`、bp1/location1、attach StopID1 绑定。`callback.json` 为同一 PID、thread 44589446、frame0、StopID2，stop reason 为该断点；frame PC、断点 PC 和 callback 配置一致，UUID及mangled symbol一致，所有 identity checks 为 true。调用者栈含 `handleWakeOwnerProbeButton` 与 `Array.withUnsafeBytes`。`machine-exit.json` 的 callback/CLI 同停点 PID、thread、StopID、frame、PC、UUID比较均为 true，PTY 保留对应 breakpoint stop。结论只覆盖这条元数据身份与按钮/同步借用调用链。 |
| Q-META-2 | **Partial（精确点击时序未独立证实）** | pre-arm 与 pre-freeze 是分开的机器快照：各自 process running、hit count 0、target memory/argument/expression reads 0；两次 evaluation 均为 `PASS_PRECLICK_METADATA`。Human 文件记录一次 arm 与一次 freeze，callback/hit count 均为1。可是 `human-arm.json` 的 `recorded_utc` 是 03:08:54.827854 且 `actual_calls=23`，而 call ledger 将 arm 请求列为 call19、快照/evaluation列为20–23；这更像记录/收件时间，不是动作时间。Human freeze 的 `recorded_utc` 03:09:28.825793 晚于 callback UTC 03:09:06.019304；恢复出的作者 call ledger把 freeze列为24、callback/清理列为25–28。没有独立的点击发生时间字段，故只能说作者账本给出该顺序，不能从 UTC 原件独立重建点击先于 callback 的确切时序。 |
| Q-META-3 | **Covered（有来源限制）** | PTY 显示清理脚本运行、`breakpoint list` 为空、`process detach`、`quit`；`stop-and-cleanup.json` 记录 bp1 删除成功且剩余0。`machine-exit.json` 记录同 PID 回到 `Ss`、无匹配 debugserver、LLDB exit0，三个诊断原键仍 ABSENT。暂停界限为 callback→delete `27.316396s` 下界、callback→machine-exit 记录的上界；按两端 UTC 直接相减为 `70.220018s`，与文件中 `70.220212s` 多 `0.000194s`，两者均小于120秒。没有精确 detach 时间，不把下界当精确暂停时长。Human 视觉退出原话“界面正常，显示取证；App 已关闭”只出现在root保全的最终误归档副本；冻结 `run-summary.json` 仍为 `Pending Human`，所以视觉事实按Human引述而非机器证明处理。 |
| Q-META-4 | **Partial（账本路径与范围接受未闭合）** | `appex_meta_callback.py` 未查参数、读 buffer、`ReadMemory` 或执行 target expression，callback计数均为0；但原PTY的LLDB默认停点formatter显示了 `address`/`byteCount` 参数。执行报告承认这是默认显示，且没有声称整场参数/内存读取为零；此偏差仍待Product决定。冻结私有 `run-summary.json` 报33 calls、291.543386秒、`visual_exit=Pending Human`，截止 `archived_utc=03:11:12.713763Z`，没有 call ledger。作者最终JSON原样被root从误写的 `docs/ACTIVE_WORK.md` 保全，源SHA `99c39f6c8988a9c9116e59f460fe6fbdbd2391c3866ef33f4b2a24773b7b262b`；其35-call ledger连续覆盖1–35，含Human视觉退出，结束于03:11:45.158394Z。该终点相对运行起点为 `323.988017s`，与最终报告的324.0秒四舍五入一致；私有摘要的291.543386秒也正好对应其较早archive时间。root的erratum说明最终summary误写路径且私有run-summary未改。故33→35可解释为中间摘要与最终归档边界差异，但最终账本不在冻结私有summary中，仍属作者账本/协调者保全副本，不能冒称逐调用独立重建或原件路径一致。 |

## 原件、代理文本与补充来源

reader 所列23项逐一核对 bytes/SHA；usage 保留每项原路径的 native 命中状态。callback、PTY、清理/退出、run-summary、脚本与执行报告均直接从本地原始路径读取并匹配冻结摘要。没有查询模拟器、live容器或 LLDB，也没有改源码/Assignment。

`root-erratum.json`（SHA `15da27ca06c642fb79fbf69f466b9715b13e59df4275c01c35406eabefda04cd`）和 `root-misfiled-final-summary-original.json`（SHA `99c39f6c8988a9c9116e59f460fe6fbdbd2391c3866ef33f4b2a24773b7b262b`）是本轮开始后由Coordinator提供的补充，不属于冻结 reader 的23项。我按原样摘要用于解释33/35归档差异；未据此改写冻结原件或接受Product偏差。Coordinator之后报告的 ACTIVE_WORK 恢复证明未在本lane读取，不作为本结论证据。

## 未作结论

未读 owner 缓冲内容；未证明 owner/session 状态、真实通知/Maps行为或整体修复完成；不作Release判断。剩余决定权属于 Human Product。

## Review writer 过程说明

本 reviewer 首次命令的错误路径在 stdout flush 前失败，第二次命令又误读了 packet 字段名；两次均未触及 writer。随后成功校验packet/reader并写回ACK。两个错误尝试已计入usage；准确 lane-start UTC 未能恢复，因此 usage 只给首个成功读取 UTC 和其后的精确 elapsed，不虚构完整起点或完整墙钟合规。
