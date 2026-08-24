# RELEASE-2026-0801-04 — Build 7 真机性能、Full Access 与终止证据

> **Run ID:** `RELEASE-2026-0801-04-B7-P4-20260824`
> **Status:** `Invalidated — sole bounded re-arm also ended Device disconnected before any Human instruction`
> **Evidence grade:** post-reboot manifest / machine preflight 为 `Executor-recorded`；pre-reboot schema 可见状态为 predecessor `Device-attested`
> **Collected:** `2026-08-24 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Release ledger:** [`RELEASE-2026-0801`](release-2026-08-01-acceptance.md)
> **Bounded exception:** [`PD-RELEASE-2026-0801-04-BUILD7-BOUNDED-EVIDENCE-EXCEPTION`](../product-decisions/RELEASE-2026-0801-04-build7-bounded-evidence-exception.md)
> **Predecessors:** [`P1 invalidated schema mismatch`](release-2026-08-01-04-build7-device-run-2026-08-24.md)；[`P2 invalidated resident Extension`](release-2026-08-01-04-build7-device-run-p2-2026-08-24.md)；[`P3 invalidated current-keyboard omission`](release-2026-08-01-04-build7-device-run-p3-2026-08-24.md)

## Scope、authority 与 non-claims

Human Product Owner 已授权继续完成冻结 RC 的真机工作，并担任本轮 iPhone Device Operator；随后于
`2026-08-24 Asia/Shanghai` 明确授权有界证据例外，以及在 P3 因 current-keyboard 前置条件遗漏失败关闭后进行
P4 准备并额外增加一轮 Human round。Device Operator 已切换到 Apple 系统键盘并重启 iPhone；本轮只观察
已安装的 Build 7 ad hoc Release 包，不构建、不重新安装、不改源码、不上传 TestFlight，也不接受失败或跳过的发布风险。

P4 重启后，CoreDevice 重新确认同一 Build 7、同一设备/OS、零 Universe Keyboard 进程及未变化的 crash/Jetsam
基线；App Group 偏好仍为 `rime_ice` / `nine_key` / `t9`，deployed true、needs-deploy false、T9 ready true。
Device Operator 随后在空 Reminders 字段只读确认 Apple 系统键盘自动显示，未输入、未切换；再次机器查询仍为
零 Universe Keyboard 进程。本 manifest 冻结该精确起点：Full Access off、Apple 键盘可见、空宿主字段已聚焦。

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
| Schema/layout | P2 重启前截图仅作为历史 provenance：当时雾凇拼音 `nightly` 显示“当前使用”和“基础检查通过”，九宫格拼音及雾凇九键（T9）均选中；P2/P3 manifest 均已失效，P4 不复用其 readiness 结论。P4 的当前有效证据是重启后的机器只读偏好：`rime_ice` / `nine_key` / `t9`，deployed true、needs-deploy false、T9 ready true。26-key English 仍按产品设计在九键偏好下使用 26 键；正式中文输入以 9-key `64` path/候选/删除 smoke 为主。高级输入功能页面只承载 Lua 增强偏好，不作为九宫格证据。CoreDevice 仍无法读取 App Group 根级 `Rime/shared`，所以 P4 的首次真实键盘行为必须 fail closed，且不得宣称已取得 compiled schema digest |
| Access treatment | baseline 为 Full Access off；同一已安装 payload 下切换为 on。权限切换是列明的 runtime treatment，不改变安装 payload |
| Privacy | allowlist 合成输入：英文 `abc`、九宫格数字路径 `64`；receipt 不记录提交结果、候选文本、宿主文本或周边上下文 |
| Human budget | Assignment 共授权 `2` 个 Human round：P3 已使用 `1` 个并在输入前失败关闭；P4 额外授权的 `1` 个槽位已由本次 P4 run 消耗并失败关闭。P4 没有发出 Human 指令、也没有发生输入，但该区别不产生可重试额度；不得再自动增加 |

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
| P4 installed receipt | Universe Keyboard `1.0 (7)` | `raw/p4-prep-installed-app.json`, SHA-256 `d96db8a1e320626a88c128b4041041ee6681f25cfc4b994bb8ddce8501b9d69d` |
| P4 device/OS | 同一 physical iPhone 13 Pro / iOS `27.0 (24A5418b)`；wired / paired / connected / booted；Developer Mode enabled | `raw/p4-prep-device-details.json`, SHA-256 `b552bf4cb8ed609a55ac03d146953d266bedcf911a09325077db1bc0741c3e0f` |
| P4 cold process baseline | `Keyboard` 搜索结果为 `0` | `raw/p4-prep-keyboard-processes.json`, SHA-256 `fd7128e30a09e0df0971c77af3b63751fef98afbae65acd43e0f5f674af2f8d1` |
| P4 crash/Jetsam baseline | Keyboard `11`、JetsamEvent `62`，与 P3 前基线相同 | crash JSON SHA-256 `47a000579e608cb2def273cc4c5d7d84f39d671b71427674a3f4350f504dd462`；Jetsam JSON SHA-256 `3c7071acbae13b51ad9635854fa46625b8338e13dd20264e9859c8f94de923ba` |
| P4 App Group preference readback | `rime_ice` / `nine_key` / nine-key binding `t9`; deployed true; needs-deploy false; T9 ready true | plist SHA-256 `5edd8c9343641f69fffd54f31f8e82e5d4263db7912ec2b0f4d6f8abef3c716f`；raw plist 仅留在 git-ignored evidence，不公开无关偏好；不冒充 compiled schema digest |
| Apple-current host preflight | `Device-attested`: 空 Reminders 字段自动显示 Apple 系统键盘；未输入、未切换、未保存。其后 Universe Keyboard process 仍为 `0` | `raw/p4-apple-keyboard-visible-universe-processes.json`, SHA-256 `7d62a4b32f3e28bd94d61cce6ab8ad522461bf0a694f9c67fdce706373d9a850` |
| P4 final refresh / run start | Human 再次确认 Full Access off、Apple 键盘可见、空字段聚焦且未输入；receipt `1.0 (7)`、同一设备/OS、Universe process `0`、crash `11`、JetsamEvent `62`；start `2026-08-24T22:12:43+0800` | installed JSON `b2250a8e3fe14d7b95e528b0cc1d40b7378466296fa2c7a7e4659d1e57089cdc`；device JSON `b447128c16088ff9a3178ea83e81dc359857ff5cbd058cd5ce7b7521adb44e0f`；process JSON `95768513547563c624d6d4ebb6061c418b79f1b289043af13102ccbeb6fb85cf`；crash JSON `097a957cdff072e6127ca38b9dd30473637493f7af5d3067247a10e4341f2e5f`；Jetsam JSON `b449d21070b59a21212fcfbe770a92f53408926ac0053d05048a55a5d14f3961` |
| Excluded machine arm A-0 | Time Profiler 在任何 Human 指令前自行结束：start `2026-08-24T22:13:34.744+0800`、end `22:13:36.051+0800`、duration `1.306943 s`、end reason `Device disconnected`。Universe 未启动、Human 未操作/输入；此 trace 永久排除，不参与性能结论 | raw trace `raw/p4-arm-a-full-access-off-cold.trace`；excluded ZIP SHA-256 `429a93bed941f3901588efac9ddbcded9ef507b81209bff92d2593823007a83a`；TOC XML SHA-256 `75d9bf108aea3fb9b543ae88d0bc5076cdede56414c2d582fb473102f2c9209c`；cleanup：保留原始字节，不删除/覆盖；next authority：Independent Quality 允许一次且仅一次 machine-only re-arm |
| Re-arm readiness | 首次失败后 CoreDevice 仍在线；同一 device/OS；Universe process `0`；receipt `1.0 (7)`；App Group 偏好字节未变化；Human 保持 Full Access off / Apple keyboard / empty focused host 且未操作 | device JSON `47e7dd3751f3ecbc2a37a602c0dec809693eacc6f4081f97f1029dd67b0a4d6e`；process JSON `cc5a52fabab6957b9f1b47bd085c0436736064f56f40fdf285fe555de5ede9c1`；receipt JSON `5a62d05da248604ef2c6723d546323e082ff89ffe628c411cf9ce2ecbc153dad`；preferences plist `5edd8c9343641f69fffd54f31f8e82e5d4263db7912ec2b0f4d6f8abef3c716f`；re-arm ready `2026-08-24T22:17:07+0800` |
| Excluded sole re-arm A-1 / P4 abort | 相同 Time Profiler 方法在任何 Human 指令前再次结束：start `2026-08-24T22:17:52.087+0800`、end `22:17:53.319+0800`、duration `1.232244 s`、end reason `Device disconnected`。保存阶段还报告 iOS 27 DeviceSupport 与系统 dylib address overlap。Universe 未启动、Human 未操作/输入；P4 于 `2026-08-24T22:18:33+0800` 失败关闭，禁止第三次 arm | raw trace `raw/p4-arm-a-full-access-off-cold-rearm.trace`；excluded ZIP SHA-256 `784fad6c87e65f23ba10b566ba8ddbd924b30bf44791a9f8fd4e8d0f0f1d2bc3`；TOC XML SHA-256 `1f4bc6dde0a35b58f6ec49a2c921ceaa31813efee80b53bb791fca2268682d5d`；cleanup：保留原始字节；next authority：需要 Product Lead 新裁决和不同/稳定采集环境，不得在当前 P4 重试 |

预检 artifact 位于 `/private/tmp/universe-build7-*-preflight.trace`，均不参与正式指标。组合/Activity 预检即使
命令退出为 `0`，其 TOC `end-reason` 仍是 `Device disconnected`；正式解析必须检查 TOC，不能只看 exit code。

## Formal sequence — authorized additional Human round

Human 输入前，Executor 必须完成 readiness re-review、重新读取安装 receipt、记录 crash/Jetsam 基线清单并确认
不存在 Universe Keyboard 进程。Run window 在启动第一段 Time Profiler 前用带时区的本地时间写入
`raw/p4-run-window-start.txt`；结束恢复 smoke 后立即写入 `raw/p4-run-window-end.txt`。之后每条给 Device Operator
的消息只包含一个动作。冻结起点必须保持为 Full Access off、Apple 系统键盘可见、空 Reminders 字段已聚焦。

### A. Full Access off / cold Extension

1. Executor 只读确认安装 receipt、Universe Keyboard 进程 no-match、设备/OS，写入 P4 run start 并启动 all-processes Time Profiler。
2. Device Operator 只切换到 Universe Keyboard；不输入、不关闭字段，报告九宫格是否显示。
3. Executor 只读确认唯一 Keyboard Extension PID；trace 必须覆盖其首次出现。
4. Device Operator 按逐条单动作指令完成九宫格 `64` path/候选提交/删除 smoke，再完成英文 `abc`/清空；报告可见行为与触感，不提供候选文本，不完成/保存提醒。
5. Executor 停止/保存 Time Profiler，确认 loaded-image UUID；在键盘保持显示时采集一个 Activity Monitor 短快照。

### B. Full Access on / sustained candidate work

1. Device Operator 按单独指令进入 Universe Keyboard 的 Full Access 设置页；不改设置。
2. Device Operator 只打开 Full Access；不改其他设置。
3. Device Operator 按单独指令返回同一空 Reminders 字段；不输入。
4. Executor 启动第二个 all-processes Time Profiler。
5. Device Operator 按逐条单动作指令，以自然、尽量均匀但不计入产品预算的人工节奏重复九宫格 `64`/候选/清空，并覆盖候选分页和展开/收起；随后完成英文 `abc`/清空并回到九宫格中文状态。人工 cadence 与输入模式切换作为 confound 记录。
6. Executor 保存 trace，并采集持续输入后的 Activity Monitor 短快照。

### C. Host switch、termination 与恢复

1. Device Operator 按逐条单动作指令建立一个由九宫格 `64` 产生且未提交的 composition、切到 iOS Settings 搜索字段、切回 Universe Keyboard、再返回 Reminders 空字段；只在各动作间报告状态。最终确认未完成 composition 被丢弃且新输入可用。
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
| Readiness review | Historical pre-arm Go; final P4 invalidated | Independent Quality 在启动 machine arm 前复核为 Go；两次 machine arm 随后均在 Human 指令前失败并永久排除。该历史 readiness 不产生第三次 arm 或 Human round |
| Full Access off | Frozen precondition; behavior pending | Device Operator 已在 P3 关闭且未再次修改；P4 Apple-current preflight 未输入 |
| Full Access on | Pending | — |
| Cold/first input | Not captured / toolchain Hold | 两次 machine arm 均在 Human 指令前以 `Device disconnected` 结束；无产品行为证据 |
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
  "runId": "RELEASE-2026-0801-04-B7-P4-20260824",
  "templateState": "invalidated-machine-rearm-device-disconnected",
  "installedPayloadMatch": null,
  "installedReceiptMatch": true,
  "installedByteEqualityAvailable": false,
  "deviceAndOSMatch": true,
  "schemaAndConfigMatch": null,
  "historicalSchemaDeviceAttestationFromInvalidatedP2": true,
  "historicalSchemaAttestationIsCurrentP4Proof": false,
  "schemaSelectionPreferenceReadbackAfterReboot": true,
  "t9PreferenceReadbackAfterReboot": true,
  "machineConfigDigestAvailable": false,
  "appleCurrentPreflightDeviceAttested": true,
  "universeProcessCountAtFrozenStart": 0,
  "humanRoundsAuthorizedTotal": 2,
  "humanRoundsUsedBeforeP4": 1,
  "p4HumanRoundsUsed": 1,
  "p4RunWindowStart": "2026-08-24T22:12:43+0800",
  "p4HumanInstructionIssued": false,
  "p4MachineArmAttempts": 2,
  "p4MachineArmExcluded": 2,
  "p4MachineRearmAuthorizedMaximum": 1,
  "p4MachineRearmUsed": 1,
  "p4RunWindowEnd": "2026-08-24T22:18:33+0800",
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
