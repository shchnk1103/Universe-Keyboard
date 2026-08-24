# RELEASE-2026-0801-04 — Build 7 真机性能、Full Access 与终止证据

> **Run ID:** `RELEASE-2026-0801-04-B7-P1-20260824`
> **Status:** `Invalidated — Product Lead authorized schema transition after Wanxiang/rime_ice mismatch; no formal round started`
> **Evidence grade:** manifest / machine preflight 为 `Executor-recorded`；schema 可见状态为 `Device-attested`
> **Collected:** `2026-08-24 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Release ledger:** [`RELEASE-2026-0801`](release-2026-08-01-acceptance.md)
> **Bounded exception:** [`PD-RELEASE-2026-0801-04-BUILD7-BOUNDED-EVIDENCE-EXCEPTION`](../product-decisions/RELEASE-2026-0801-04-build7-bounded-evidence-exception.md)

## Scope、authority 与 non-claims

Human Product Owner 已授权继续完成冻结 RC 的真机工作，并担任本轮 iPhone Device Operator；随后于
`2026-08-24 Asia/Shanghai` 明确授权上述有界证据例外及一个额外的只读 schema 预检。本轮只观察已安装的
Build 7 ad hoc Release 包；不构建、不重新安装、不改源码、不上传 TestFlight，也不接受失败或跳过的发布风险。

额外只读预检发现当前方案为万象拼音而不是 manifest 中的 `rime_ice` 后，Human Product Lead 又明确授权切换至
`rime_ice` 并完成部署，再冻结一个新 manifest。该配置变更授权使本 manifest 永久 `Invalidated`；本记录只保留
失配与处置审计，不得恢复或承载后续正式证据。失效前 formal Human input round 未开始，计数保持 `0`。

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
| Schema/layout | frozen plan 为 `rime_ice`；26-key Chinese/English 为主，9-key 做代表性候选/path smoke。CoreDevice 在 iOS 27 上拒绝读取 App Group 根级 `Rime/shared`；Product Owner 已通过 bounded exception 授权一个额外的“只看不输入”预检。预检实际可见状态为：万象拼音 `v17.2.5` 显示“当前使用”，部署卡显示“已部署 / 配置已生效”；雾凇拼音 `16 MB · nightly` 仅显示“已安装”。实际状态与 frozen plan 不符，因此本 manifest 保持 Hold，禁止在本 manifest 下切换方案后继续正式轮次 |
| Access treatment | baseline 为 Full Access off；同一已安装 payload 下切换为 on。权限切换是列明的 runtime treatment，不改变安装 payload |
| Privacy | allowlist 合成输入：`abc`、`nihao`、`chile`、`64`；receipt 不记录提交结果、候选文本、宿主文本或周边上下文 |
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
| Extra read-only schema preflight | `Device-attested`: 万象拼音 `v17.2.5` 为“当前使用”，部署状态为“已部署 / 配置已生效”；雾凇拼音仅为“已安装” | 与 manifest 的 `rime_ice` 计划不符；截图 `raw/read-only-preflight-current-schema.png`, SHA-256 `07205224ddc6f052a63ed0fd39a6f17f72fa6244e9c81633cb7ebc1a20308d39`, `311,071` bytes；未输入、未切换方案、未部署、未改设置 |

预检 artifact 位于 `/private/tmp/universe-build7-*-preflight.trace`，均不参与正式指标。组合/Activity 预检即使
命令退出为 `0`，其 TOC `end-reason` 仍是 `Device disconnected`；正式解析必须检查 TOC，不能只看 exit code。

## Formal sequence — one Human round

Human 输入前，Executor 必须完成 readiness re-review、重新读取安装 receipt、记录 crash/Jetsam 基线清单并确认
不存在 Keyboard 进程。Run window 在第一条 Full Access 操作前用带时区的本地时间写入
`raw/run-window-start.txt`；结束恢复 smoke 后立即写入 `raw/run-window-end.txt`。之后每条给 Device Operator 的消息
只包含一个动作。

### A. Full Access off / cold Extension

1. Device Operator 在 Settings 关闭 Universe Keyboard 的 Full Access，打开一个新建且原本为空的 Reminders 提醒字段；此时不输入。
2. Executor 只读确认安装 receipt、进程 no-match、设备/OS，并启动 all-processes Time Profiler。
3. Device Operator 在空 Reminders 字段首次切换到 Universe Keyboard；依次完成 `abc`、`nihao` 候选提交、Delete/Return/候选展开收起 smoke，报告可见行为与触感，不提供候选文本，不完成/保存提醒。
4. Executor 停止/保存 Time Profiler，确认 Keyboard PID 和 loaded-image UUID；在键盘保持显示时采集一个 Activity Monitor 短快照。

### B. Full Access on / sustained candidate work

1. Device Operator 在 Settings 打开 Full Access 后返回同一空 Reminders 字段；确认仍为 Build 7 键盘。
2. Executor 启动第二个 all-processes Time Profiler。
3. Device Operator 以自然、尽量均匀但不计入产品预算的人工节奏重复合成输入：26-key `nihao`/候选/清空，候选分页和展开/收起；再切到 9-key，以 `64` 完成一次 path/候选/删除 smoke。人工 cadence 作为 confound 记录。
4. Executor 保存 trace，并采集持续输入后的 Activity Monitor 短快照。

### C. Host switch、termination 与恢复

1. Device Operator 保留一个未提交的合成 composition，切到 iOS Settings 搜索字段，切回 Universe Keyboard，再返回 Reminders 空字段；确认未完成 composition 被丢弃且新输入可用。
2. Executor 用下列 fail-closed 流程处理一次普通 `SIGTERM`：
   - 运行 `xcrun devicectl device info processes --device <UDID> --search Keyboard --timeout 10 --json-output raw/pre-terminate-processes.json`；
   - 只接受 `runningProcesses` **恰好一行**，且 executable path 后缀为 `/PlugIns/Keyboard.appex/Keyboard`；记录该唯一 PID 与查询文件 SHA-256；
   - 运行 `xcrun devicectl device process terminate --device <UDID> --pid <verifiedPID> --timeout 10 --json-output raw/terminate-result.json`，不加 `--kill`；
   - 立即用相同 search 生成 `raw/post-terminate-processes.json`，要求旧 PID 不再存在。零行是期望；多行、路径/PID 漂移、命令失败或旧 PID 仍在均立即 Hold，不尝试第二次或升级为 SIGKILL。
3. Device Operator 再次显示 Universe Keyboard，完成一次 `abc` 和一次 `nihao` smoke，确认新 session 可用且没有回退/重复提交。
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
| Readiness review | Hold | 额外只读预检确认 runtime schema/config 与 frozen manifest 不一致；正式 Human 输入轮次不得开始 |
| Full Access off | Pending | — |
| Full Access on | Pending | — |
| Cold/first input | Pending | — |
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
  "runId": "RELEASE-2026-0801-04-B7-P1-20260824",
  "templateState": "invalidated-authorized-config-transition",
  "installedPayloadMatch": null,
  "deviceAndOSMatch": null,
  "schemaAndConfigMatch": false,
  "extraReadOnlyPreflightUsed": 1,
  "humanRoundsUsed": 0,
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
