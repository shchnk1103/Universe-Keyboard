# RELEASE-2026-0801-04 — Build 7 真机性能、Full Access 与终止证据

> **Run ID:** `RELEASE-2026-0801-04-B7-P3-20260824`
> **Status:** `Invalidated — current-keyboard precondition omitted; Extension auto-presented before Time Profiler started`
> **Evidence grade:** post-reboot manifest / machine preflight 为 `Executor-recorded`；pre-reboot schema 可见状态为 predecessor `Device-attested`
> **Collected:** `2026-08-24 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Release ledger:** [`RELEASE-2026-0801`](release-2026-08-01-acceptance.md)
> **Bounded exception:** [`PD-RELEASE-2026-0801-04-BUILD7-BOUNDED-EVIDENCE-EXCEPTION`](../product-decisions/RELEASE-2026-0801-04-build7-bounded-evidence-exception.md)
> **Predecessors:** [`P1 invalidated schema mismatch`](release-2026-08-01-04-build7-device-run-2026-08-24.md)；[`P2 invalidated resident Extension`](release-2026-08-01-04-build7-device-run-p2-2026-08-24.md)

## Scope、authority 与 non-claims

Human Product Owner 已授权继续完成冻结 RC 的真机工作，并担任本轮 iPhone Device Operator；随后于
`2026-08-24 Asia/Shanghai` 明确授权有界证据例外、额外只读 schema 预检、切换至 `rime_ice`，以及在 P2 的
Keyboard Extension 未自然退出后重启 iPhone 以建立冷进程基线。本轮只观察已安装的 Build 7 ad hoc Release 包；
不构建、不重新安装、不改源码、不上传 TestFlight，也不接受失败或跳过的发布风险。

重启后，CoreDevice 重新确认同一 Build 7、同一设备/OS 和零 Keyboard 进程。未启动 Main App 或 Keyboard；从
App Group `Library/Preferences` 只读回读的偏好明确为 `rime_active_schema=rime_ice`、
`keyboard_layout_style=nine_key`、`keyboard_layout_scheme_9=t9`、`rime_deployed=true`、
`rime_needs_deploy=false`、`rime_t9_ready=true`。这些键证明选择与 readiness 偏好在重启后保留，但不证明
`Rime/shared` 编译产物 digest 或已安装 bundle 字节 equality。P1/P2 的正式 Human round 均未开始，本 P3 从 `0` 开始。

本轮目标：

1. 在 iPhone 13 Pro / iOS 27 上记录冷 Extension、代表性输入、候选、宿主切换与恢复的 Time Profiler 证据；
2. 在 Full Access off / on 下验证基础输入与可观察的共享能力差异；
3. 记录冷启动、持续输入后与宿主切换后的阶段性物理内存快照；
4. 练习当前设备 crash/Jetsam 有界查询、分类与 Build 7 UUID/dSYM 绑定路径；
5. 对普通生命周期退出与人为终止后的恢复作出窄结论。

本轮不建立永久性能预算，不证明其他设备/OS/宿主兼容性，不记录真实输入、候选文本或宿主上下文，也不把
“无匹配报告”扩大为“生产者从未生成报告”。

## Immutable Run Manifest

| Boundary | Frozen identity |
|---|---|
| Source | annotated tag `testflight-v1.0-rc1-build7` → `244b32df38cff7ce3d8e56d78a80d4504cc6f073`; tree `d2f0942c3d7e7ceace571fe32ce91437bc108e58` |
| Working tree disposition | 当前 checkout 仅含本 PR 的发布证据/手册文档变化；已安装 payload 来自冻结 ad hoc IPA，不从当前 checkout 构建；冻结后禁止 build/install |
| Main App executable | UUID `3AC2D57A-F20A-3B1F-A4C3-37DFA2F619D2`; SHA-256 `bcaccf7f0bbba266e45ab06ac98ba99631ab461f82b56db4988f7174f1234850`; `7,035,712` bytes |
| Keyboard executable | UUID `08834E19-48AC-3A9C-AE0C-F53EBE94D720`; SHA-256 `c92caa18545e8d08cd39ca6fb4105b5784113936f710622d4f02d75f19216ec7`; `5,211,792` bytes |
| Debug payload | `Not Applicable — Release export contains no *debug*.dylib`; no debugger attach; `get-task-allow = false` |
| Embedded executable runtime | recursive `file` inventory of the extracted IPA finds exactly two non-system Mach-O files: the App and Keyboard executables above; neither bundle contains a `Frameworks` directory or custom dylib. `otool -L` lists only Apple OS libraries/frameworks. RIMEBridge/vendor code is statically carried by these hashed executables, not a third unrecorded payload |
| Installed receipt / byte-binding limit | CoreDevice reports `Universe Keyboard` / `com.DoubleShy0N.Universe-Keyboard` / version `1.0` / build `7`; installation succeeded once from the hashed ad hoc export. CoreDevice exposes the installed bundle path/receipt but does not permit copying installed bundle bytes back. Therefore direct installed SHA equality is unavailable: every formal Time Profiler arm must instead show the loaded Keyboard UUID `08834E19-...` and the receipt must remain build `7`; a missing/mismatched UUID invalidates the run rather than being inferred from the source IPA |
| App dSYM | UUID matches App; DWARF SHA-256 `d093e1e999c0c4540e28243cb1e5ff7208de16b5515117e00b8cee9b588cf464` |
| Keyboard dSYM | UUID matches Extension; DWARF SHA-256 `63ed475f2b5b65433513074192b17a400cd34bdb2a29bcfa92e334b4c2fcc3c8` |
| Archive/export | Xcode Cloud Build 7, Release Archive/export; Xcode `26.6 (17F113)`, iPhoneOS SDK `26.5`, minimum iOS `18.0`; ad hoc IPA SHA-256 `c63d3efe649292d36535e74fd20a8fbe7c99bc8757d37bfb9ef9afbcaa4d00f2` |
| Runtime vendor | frozen source `config/rime-vendor-manifest.env` SHA-256 `a67cf99046a180c9e648755c793182529f2937f3d0469e3b59d6f63638802804`; no deployment/install allowed during run |
| Device | physical iPhone 13 Pro (`iPhone14,2`); UDID SHA-256 `713f2a42a07a609959252ee4ce3d3e5664f2ca0a6b6384a67f17ec7ace243e88`; wired, paired, booted, Developer Mode enabled |
| OS / measurement host | iOS `27.0 (24A5418b)`; macOS `27.0 (26A5416b)`; local Instruments/Xcode `27.0 (27A5237l)` |
| Host fields | Reminders 中一个新建且原本为空的本地提醒字段为 canonical third-party host；Universe Keyboard 主 App 只确认资源状态，不承载性能输入；iOS Settings 搜索字段只用于宿主切换。不完成/保存提醒，不发送消息，不粘贴真实内容 |
| Schema/layout | 重启前 P2 `Device-attested`：雾凇拼音 `nightly` 显示“当前使用”和“基础检查通过”，九宫格拼音及雾凇九键（T9）均选中。重启后未启动 App/Extension；P3 机器只读偏好仍为 `rime_ice` / `nine_key` / `t9`，deployed true、needs-deploy false、T9 ready true。26-key English 仍按产品设计在九键偏好下使用 26 键；正式中文输入以 9-key `64` path/候选/删除 smoke 为主。高级输入功能页面只承载 Lua 增强偏好，不作为九宫格证据，本轮未改其开关。CoreDevice 仍无法读取 App Group 根级 `Rime/shared`，所以重启后的首次真实键盘行为必须 fail closed，且不得宣称已取得 compiled schema digest |
| Access treatment | baseline 为 Full Access off；同一已安装 payload 下切换为 on。权限切换是列明的 runtime treatment，不改变安装 payload |
| Privacy | allowlist 合成输入：英文 `abc`、九宫格数字路径 `64`；receipt 不记录提交结果、候选文本、宿主文本或周边上下文 |
| Human budget | `1` 个连续人工轮次；增加轮次只能由 Human Product Owner 重新授权 |

Canonical Archive/dSYM/export 细节见
[`Build 7 artifact ledger`](release-2026-08-01-01-frozen-rc-build7-artifact-ledger-2026-08-24.md)。

## Machine preflight

| Check | Result | Interpretation |
|---|---|---|
| Device Hub / CoreDevice | 真机为 wired / paired / connected / booted，Developer Mode enabled | 当前物理链路可用 |
| `xctrace list devices` | 同一 iPhone 13 Pro / iOS 27 在线 | Instruments 独立识别设备 |
| Time Profiler / all processes / 5 s | `6.093 s`, `Time limit reached` | 可用于正式 CPU、采样、hang、生命周期与 dyld UUID 证据 |
| System Trace / all processes / 5 s | `6.034 s`, `Time limit reached` | 备用终止/线程/lifecycle 证据；保存耗时长，不作为默认模板 |
| Activity Monitor standalone / combined | 两次均约 `1.205 s` 后 `Device disconnected` | 不可作为连续 trace；不能据此称物理设备断开 |
| Activity Monitor `sysmon-process` | 断连前仍产生带 Physical Footprint、Resident Size、CPU 与状态的完整阶段行 | 允许做明确标注工具限制的阶段性快照；不冒充连续内存曲线 |
| Game Memory / all processes | fail closed：Allocations 与 VM Tracker 不支持 all-processes | 不进入正式 allowlist |
| PID/name attach dry run | 当前 Beta CLI 无法解析真机 SpringBoard 的 attach target | 不对 frozen Release Extension 尝试未验证 attach |
| Device Hub process query | 可按名称查询 PID/路径；当前键盘未显示时无 Universe/Keyboard 行 | 正式运行中只读确认 Extension PID/存活/终止 |
| Installed-bundle byte readback | CoreDevice 只允许 container 的 `Library` / `Documents` / `tmp`，拒绝读取 App Group 根级 `Rime/shared`；也不提供 installed bundle copy-back | 保留为当前工具边界；不得把 receipt 写成设备字节 SHA 证明 |
| Pre-run crash baseline | `11` 个 Keyboard 相关历史条目；最新为 `2026-08-23 22:54`，早于 Build 7 安装/正式窗口 | JSON SHA-256 `71a2f2085f664376a59c9bef74e05977f3965193794239186990fe1ff6cb7aa4` |
| Pre-run Jetsam baseline | `62` 个历史 JetsamEvent；最新为 `2026-08-24 20:19`，早于正式窗口 | JSON SHA-256 `a953b0157fa02faf587fe972cd0bfa720dd5a79a7a91fb0f55548c2cc876c870` |
| Pre-run process baseline | `Keyboard` 搜索结果为 `0` | JSON SHA-256 `e10b39ce7f720d0331a064abda3fded2a3c8fb04bab67abfda87da1218ba8c72` |
| P3 installed receipt | Universe Keyboard `1.0 (7)` | `raw/p3-post-reboot-installed-app.json`, SHA-256 `a17ddc81ab042411cb0663f9dbd7ea7c17f4424d8d1a889d28c8dff844cfac33` |
| P3 device/OS | 同一 physical iPhone 13 Pro / iOS `27.0 (24A5418b)`；wired / paired / connected / booted；Developer Mode enabled | `raw/p3-post-reboot-device-details.json`, SHA-256 `781f8ab12d9742e785f08ec9396d20040a99bfeefed456da4a78aebfedd3eece` |
| P3 cold process baseline | `Keyboard` 搜索结果为 `0`；Main App 与 Keyboard Extension 均未启动 | `raw/p3-post-reboot-keyboard-processes.json`, SHA-256 `1822f722d2c4ec20f8a9da091b0851be438a8d15e7fe114f95f81147429442ec` |
| P3 crash/Jetsam baseline | Keyboard `11`、JetsamEvent `62`，与 P2 pre-action 基线数量相同 | crash JSON SHA-256 `9f0c06cf76083f0b8fe493b5a558079af5cbf9e11cee4454b0efc5e9620297a9`；Jetsam JSON SHA-256 `a65195b2bbc6e834cd38ef90d5602cccc85ec3463ab5895bd7b378d4f3cbd2ea` |
| P3 App Group preference readback | `rime_ice` / `nine_key` / nine-key binding `t9`; deployed true; needs-deploy false; T9 ready true | preference listing JSON SHA-256 `fd9c5f87873873a2effd9fa99f87026ac684eb96baa4ec2761275956189186b5`；plist SHA-256 `5edd8c9343641f69fffd54f31f8e82e5d4263db7912ec2b0f4d6f8abef3c716f`；raw plist 仅留在 git-ignored evidence，不公开其中无关偏好 |
| Final pre-action refresh / run start | receipt `1.0 (7)`；同一 physical iPhone 13 Pro / iOS `27.0 (24A5418b)`；Keyboard process `0`；crash `11`；JetsamEvent `62`；run start `2026-08-24T21:58:05+0800` | installed JSON `7579a8a531298198c4de4b27f5fb9e09e841b2ad7b12a74fe262eaeccbd38a35`；device JSON `eeee3a8a325e92001d794d725a2e00653794104d0767d3139efd501f3487871f`；process JSON `3f3740a63e20790d522b1cccb3790db4dc03fbb63a32a23d2502ac6406188741`；crash JSON `76cbcb81a16784837760d254ea633859e5893acf870c6f0c1f0bf16a2fd16c9d`；Jetsam JSON `7dbb3e1bb66e31dce3b97d25ee2c2d486b7cda293c3c76fa3ecd970781fdec34` |
| P3 sequence deviation / abort | Full Access 已按计划关闭；随后打开空 Reminders 字段时，因为 Universe Keyboard 本来就是系统当前键盘，Extension 在 Time Profiler 启动前自动显示。Device Operator 明确报告未输入；Executor 未采集/伪造 cold-start trace，窗口于 `2026-08-24T22:00:46+0800` 失败关闭 | process query 精确一行 Keyboard Extension PID；JSON SHA-256 `1343868f372d6432cd5f205271f250756aeeadde7b607fcbde46d244227eeeff`。这是 runbook 前置条件遗漏，不是产品行为失败；未发送 signal、未切换权限第二次、未开始输入 |

预检 artifact 位于 `/private/tmp/universe-build7-*-preflight.trace`，均不参与正式指标。组合/Activity 预检即使
命令退出为 `0`，其 TOC `end-reason` 仍是 `Device disconnected`；正式解析必须检查 TOC，不能只看 exit code。

## Formal sequence — one Human round

Human 输入前，Executor 必须完成 readiness re-review、重新读取安装 receipt、记录 crash/Jetsam 基线清单并确认
不存在 Keyboard 进程。Run window 在第一条 Full Access 操作前用带时区的本地时间写入
`raw/run-window-start.txt`；结束恢复 smoke 后立即写入 `raw/run-window-end.txt`。之后每条给 Device Operator 的消息
只包含一个动作。

### A. Full Access off / cold Extension

1. Device Operator 只在 Settings 关闭 Universe Keyboard 的 Full Access；不改其他设置、不输入。
2. Device Operator 打开一个新建且原本为空的 Reminders 提醒字段；此时不输入、不完成或保存提醒。
3. Executor 只读确认安装 receipt、进程 no-match、设备/OS，并启动 all-processes Time Profiler。
4. Device Operator 在空 Reminders 字段首次切换到 Universe Keyboard；完成英文 `abc`，再以九宫格 `64` 完成一次 path/候选提交、Delete/Return/候选展开收起 smoke，报告可见行为与触感，不提供候选文本，不完成/保存提醒。
5. Executor 停止/保存 Time Profiler，确认 Keyboard PID 和 loaded-image UUID；在键盘保持显示时采集一个 Activity Monitor 短快照。

### B. Full Access on / sustained candidate work

1. Device Operator 在 Settings 打开 Full Access 后返回同一空 Reminders 字段；确认仍为 Build 7 键盘。
2. Executor 启动第二个 all-processes Time Profiler。
3. Device Operator 以自然、尽量均匀但不计入产品预算的人工节奏重复九宫格 `64`/候选/清空，并覆盖候选分页和展开/收起；随后切到英文状态完成 `abc`/清空，再回到九宫格中文状态。人工 cadence 与输入模式切换作为 confound 记录。
4. Executor 保存 trace，并采集持续输入后的 Activity Monitor 短快照。

### C. Host switch、termination 与恢复

1. Device Operator 保留一个由九宫格 `64` 产生且未提交的合成 composition，切到 iOS Settings 搜索字段，切回 Universe Keyboard，再返回 Reminders 空字段；确认未完成 composition 被丢弃且新输入可用。
2. Executor 用下列 fail-closed 流程处理一次普通 `SIGTERM`：
   - 运行 `xcrun devicectl device info processes --device <UDID> --search Keyboard --timeout 10 --json-output raw/pre-terminate-processes.json`；
   - 只接受 `runningProcesses` **恰好一行**，且 executable path 后缀为 `/PlugIns/Keyboard.appex/Keyboard`；记录该唯一 PID 与查询文件 SHA-256；
   - 运行 `xcrun devicectl device process terminate --device <UDID> --pid <verifiedPID> --timeout 10 --json-output raw/terminate-result.json`，不加 `--kill`；
   - 立即用相同 search 生成 `raw/post-terminate-processes.json`，要求旧 PID 不再存在。零行是期望；多行、路径/PID 漂移、命令失败或旧 PID 仍在均立即 Hold，不尝试第二次或升级为 SIGKILL。
3. Device Operator 再次显示 Universe Keyboard，完成一次英文 `abc` 和一次九宫格 `64` smoke，确认新 session 可用且没有回退/重复提交。
4. Executor 采集恢复后的 Time Profiler/阶段内存快照、读取新 PID，随后记录 run window end。

### D. Bounded crash/Jetsam query

1. 使用与 pre-run 相同的只读命令生成 post-run 清单：
   - `xcrun devicectl device info files --device <UDID> --domain-type systemCrashLogs --search Keyboard --timeout 10 --json-output raw/post-run-keyboard-crash-list.json`；
   - `xcrun devicectl device info files --device <UDID> --domain-type systemCrashLogs --search JetsamEvent --timeout 10 --json-output raw/post-run-jetsam-list.json`。
2. 先以 JSON 中的完整 URL/name 与 modification date 对 pre/post 清单做集合差，再按
   `windowStart...windowEnd`、process/victim、version/UUID 分类；没有新增项时只记录来源、窗口和有界 no-match。
3. 对每个新增候选，使用
   `xcrun devicectl device copy from --device <UDID> --domain-type systemCrashLogs --source <exact-relative-name> --destination raw/reports/<basename> --timeout 10`
   保存原始字节；不删除设备报告。先计算 SHA-256，再打开副本定向解析。
4. 如果存在匹配 crash，以 report binary-image UUID 对比 Build 7 Keyboard/App dSYM UUID；Jetsam 要求 Keyboard
   process row 与明确 victim/reason 才能分类，只量化 `rpages × pageSize`，不伪造线程符号化。其他 build/UUID
   或窗口外报告标记为 unrelated 并排除。

## Command side-effect ledger and frozen allowlist

| Operation | Side effect | Allowed after freeze |
|---|---|---|
| `devicectl list/info details/apps/processes/files` | device payload read-only | yes |
| `xctrace record` | device payload read-only；本地生成 trace | yes，仅本文件列出的 Time Profiler/Activity 快照 |
| `xctrace export`, `dwarfdump`, `shasum`, plist/codesign inspection | local/device artifact read-only；本地可生成派生摘要 | yes |
| Full Access off → on | runtime treatment；可能影响 Extension 能力/进程生命周期 | yes，按 A→B 单向顺序 |
| 精确 PID `devicectl device process terminate ... --pid <verifiedPID>` | 向唯一匹配的当前 Extension PID 发送普通终止 | yes，仅 C 阶段一次；按 C 节 pre/post 查询失败关闭；禁止 `--kill` |
| `xcodebuild`, Xcode Run/Test/Profile/Archive | build/install/execute，可能覆盖 frozen payload | **forbidden** |
| `devicectl device install/uninstall/launch` | install/uninstall/execute | **forbidden** |
| App Group/RIME 文件 copy/move/delete/deploy/download | runtime mutation | **forbidden** |
| `sendMemoryWarning`, 任意未列明 signal/kill | process/memory treatment | **forbidden** |

任何 forbidden 操作、Build 7 receipt 不匹配、真实文本将被记录、设备/OS/UUID 改变、Activity/Time Profiler 未产出
目标进程行、无法解释的终止，都会立即使当前 run `Hold/Invalidated`。不得自动请求第二个人工轮次。

## Result ledger

| Area | Result | Evidence / note |
|---|---|---|
| Readiness review | Go | Independent Quality review：P0/P1 均为无；允许进入当前 bounded-evidence exception 下的一轮 Human round，不授权 TD closure、release-ready 或上传 |
| Full Access off | Applied, run invalidated before behavior check | 权限处理已完成；未输入，不能形成 off-state 功能结论 |
| Full Access on | Pending | — |
| Cold/first input | Not captured / invalidated | Extension 在 Time Profiler 启动前由当前键盘状态自动显示；不得补写 cold evidence |
| Sustained input/candidates | Pending | — |
| 9-key representative path | Pending | — |
| Host switch/session recovery | Pending | — |
| Stage memory snapshots | Pending | 仅阶段点观察；Activity Monitor Beta limitation retained；不作连续趋势/泄漏/预算/无回归结论 |
| Crash/Jetsam bounded query | Pending | — |
| Exact dSYM binding path | Pending | Build 7 UUIDs frozen above |
| Quality conclusion | Pending | no Product/release conclusion |

## Content-free receipt

```json
{
  "runId": "RELEASE-2026-0801-04-B7-P3-20260824",
  "templateState": "invalidated-current-keyboard-precondition-omitted",
  "installedPayloadMatch": null,
  "installedReceiptMatch": true,
  "installedByteEqualityAvailable": false,
  "deviceAndOSMatch": true,
  "schemaAndConfigMatch": null,
  "schemaConfigDeviceAttestedBeforeReboot": true,
  "schemaSelectionPreferenceReadbackAfterReboot": true,
  "t9PreferenceReadbackAfterReboot": true,
  "machineConfigDigestAvailable": false,
  "extraHumanVisibleSchemaPreflightUsed": 0,
  "humanVisibleSchemaPreflightSessionCount": 0,
  "humanVisibleSchemaPreflightObservationArtifactCount": 0,
  "humanVisibleSchemaPreflightCountScope": "P3 only; excludes executor-recorded machine preflight",
  "humanRoundsUsed": 1,
  "runWindowStart": "2026-08-24T21:58:05+0800",
  "runWindowEnd": "2026-08-24T22:00:46+0800",
  "textInputPerformed": false,
  "newKeyboardCrash": null,
  "keyboardJetsamVictim": null,
  "activityMonitorContinuous": false,
  "stageMemorySnapshotsAvailable": null,
  "rawArtifactPointers": []
}
```

## Handoff and expiry

正式 artifact 保存在 git-ignored 的 `evidence/release-2026-0801-04-build7/2026-08-24/raw/`；仓库只提交
content-free receipt、摘要、哈希、命令与局限。任何 source/tag/build、App/Keyboard UUID、设备/OS、schema/config、
Full Access 顺序、host/input field、Xcode/Instruments 或采集方法变化都使本记录过期。
