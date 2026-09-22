# TYPO-CORRECTION-002 Simulator Run Receipt — RIME Ice Paired Diagnostic

> **Run ID:** `TC2-PERF-20260918-184840-RIMEICE-01`
>
> **状态：** 已记录 paired diagnostic evidence；未关闭 INT-003、QA-001、配对性能或任何 Product / Quality / TestFlight / Release / merge Gate。
>
> **证据等级：** Executor-recorded；Debug、人工 cadence、非固定节奏。

本收据记录同一安装载荷下的 sidecar 关闭/开启配对。它证明开启臂的直接
`real_rime_sidecar` 可观测性和 live session 不变性，但不把人工输入节奏写成
固定 cadence，也不替代 Release-like、冷/暖、多样本或 Instruments 证据。

## Authority and disposition

- Assignment：[`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md)
- Registry：[`TYPO_BENCHMARK_REGISTRY_V2`](../TYPO_BENCHMARK_REGISTRY_V2.md)
- Device record：[`Device Hub Validation`](typo-correction-002-device-hub-validation.md)
- Scope：`TC2-PERF::TC2-CASE-QA-001::CANDIDATE_REFRESH` 的诊断性 paired arm；仅使用声明的 synthetic sequence。
- Preceding `TC2-PERF-20260918-183500-DEBUGSWITCH-01` 是 schema 不匹配的准备轮，未输入，排除在本收据之外。
- 本轮在雾凇部署后新建 Run ID；没有在本轮重新 build、reinstall 或再次部署 schema。

## Source, build and device identity

| 字段 | 观察值 |
|---|---|
| Source baseline | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` |
| Baseline tree | `68dfd44cfe7b23a4aeb48df1ebc9f942e8949774` |
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar` |
| Branch | `codex/typo-correction-002-provenance-sidecar` |
| Source tree state | dirty；既有 provenance/sidecar、诊断和历史 evidence 改动均保留；本轮未 commit/push |
| Build configuration | `Debug` signed Simulator package；仅诊断用途 |
| Xcode / SDK | Xcode `27.0` / `iphonesimulator27.0` |
| Simulator | iPhone 17 Pro Max / iOS `27.0` |
| Simulator UDID | `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Host | Messages / `com.apple.MobileSMS` |
| Conversation | `+1 (888) 555-1212`；draft 未发送 |
| Keyboard / Full Access | 人工确认 Universe Keyboard 活动且 Full Access 已打开；AX 中的“简体拼音”标签不作为反证 |

本轮实际使用的 Debug payload 位于：
`/tmp/universe-keyboard-typo-correction-002-TC2-PERF-20260918-183500-DEBUGSWITCH-01-derived/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`
。

| Payload 文件 | SHA-256 |
|---|---|
| `Universe Keyboard` | `ee5c9bf880d3f11fa1e79cbc95d19e9e3abdef5855d8988e19f30ac398a7d7fc` |
| `Universe Keyboard.debug.dylib` | `324b6d26f2ffead07ed6ea5a6bf1797f5569d2b5f22b78b6e66e15412cae4256` |
| `Keyboard.appex/Keyboard` | `b42e712f065f5a8d1478442349990b8a910d03b6113ac46f2229ac54bba00321` |
| `Keyboard.appex/Keyboard.debug.dylib` | `cdf633c5e0ce62c50e4eef11ec98634341db54335fdcf79c28fdf42c4c092b04` |

## RIME deployment provenance

Receipt 在第一次输入前从指定 Simulator App Group 读取，并复制到本轮 raw
artifact 目录；没有使用 FakeCandidateProvider 或旧 Ice 目录。

| 字段 | 观察值 |
|---|---|
| `schemeID` / active schema | `rime_ice` |
| Artifact identity | `rime-ice-20260630-675d23b0` |
| Artifact version | `2026.06.30` |
| Source variant | `nju` |
| Upstream revision | `6810e8916d160498620a16fef2135956fecbd485` |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Staged identity / content | `rime-ice-20260630-plan2-post2` / `781f61ce95526bf117cc3316dde014b1ab8cd941be9ecbf0c975b2e7a9a57701` |
| Installed content SHA-256 | `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26` |
| Installed files / bytes | `70` / `51,311,403` |
| librime | `1.16.1` |
| Runtime / Lua smoke | `true` / `true` |
| Receipt ID | `44AF29BD-9E35-4968-87DF-B416BEB092E2` |
| Receipt generatedAt | `2026-09-18T10:48:19Z` |
| Receipt raw SHA-256 | `ba04b36a55d4d76426ef3c5674b4c3e2824a0c6cdc35f8c30912e89942b263ba` |

## Paired procedure

- Synthetic sequence：`wimenjintianquhongyuan`；最终两臂均由 Messages 快照确认精确匹配。
- 不选择候选、不执行 Space、Return、Delete 或 Send。
- Baseline：`typo_experimental_contextual_correction_enabled = false`，重新打开键盘后输入。
- Treatment：`typo_experimental_contextual_correction_enabled = true`，重新打开键盘后输入。
- 两臂都由人工点击可见 Universe Keyboard；第三方键盘按键不向 AX 暴露，未使用宿主 `type_text` 注入。
- 首次 baseline 尝试实际产生了 `wimenjintianquanhongyuan`，多出 `an`，明确排除；清空后重新执行的 22-key 序列才计入 baseline。

## Bounded observations

### Baseline（sidecar off）

| 指标 | 观察值 |
|---|---:|
| Counted key-highlight events | `22` |
| Window | `2026-09-18T11:06:08Z .. 11:06:23Z` |
| Total touch window | `15,086.2 ms` |
| Adjacent intervals | min `305.663 ms` / median `598.860 ms` / mean `718.388 ms` / max `2,013.540 ms` |
| Direct sidecar query | `0`（仅有启动时 `route=unavailable` 记录，不计入输入窗口） |
| Final composition | `wimenjintianquhongyuan` |

### Treatment（sidecar on）

| 指标 | 观察值 |
|---|---:|
| Counted key-highlight events | `22` |
| Window | `2026-09-18T11:09:54Z .. 11:10:06Z` |
| Total touch window | `11,847.8 ms` |
| Adjacent intervals | min `349.941 ms` / median `493.396 ms` / mean `564.180 ms` / max `938.241 ms` |
| Sidecar query events | `70`，sequence `59..352` |
| Query input-length markers | `8..22` |
| Route / schema | `real_rime_sidecar` / `rime_ice` |
| Outcome / result count | `returned` / `3`（每条） |
| Query elapsed | min `1 ms` / median `1 ms` / mean `1.686 ms` / max `7 ms` |
| Receipt binding | 所有 70 条均绑定 `44AF29BD-9E35-4968-87DF-B416BEB092E2` |
| Live session validity | 所有 70 条 `before=true`、`after=true`；live session ID 前后不变 |
| Final composition | `wimenjintianquhongyuan` |

Treatment 的 sidecar 事件窗口为 `2026-09-18T11:09:58Z .. 11:10:06Z`。
它证明旁路查询走真实 RIME 且返回了 content-free 诊断结果；它不证明候选
文字已进入可见前排，也不证明用户已选择目标候选。

## Claim disposition

| Claim | 本轮结论 |
|---|---|
| Exact `rime_ice` deployment provenance | `pass`，限于本轮冻结 receipt 和 installed-content digest |
| Sidecar route is directly observable | `pass`，70 条 `real_rime_sidecar` 事件可见 |
| Sidecar is bound to exact receipt | `pass`，70/70 receipt ID 一致 |
| Sidecar leaves live composition/session unchanged | `pass`，live session 前后有效且 ID 不变；最终 raw composition 保持 |
| INT-003 rapid stale-work cancellation | `inconclusive`；本轮没有任何 `<180 ms` adjacent interval |
| QA-001 target candidate visible/selected | `not-run`；没有选择候选 |
| Paired performance Gate | `inconclusive`；人工 cadence，非 fixed-cadence，多样本/Release-like 条件不足 |

## Missing performance dimensions and non-claims

本轮没有收集或不能从当前 content-free journal 推导：

- maximum main-thread block / Time Profiler stack；
- resident/peak memory、growth trend、cold/warm repeated samples；
- fixed cadence、Sub-180 ms cancellation、candidate visibility range 或 explicit selection；
- Release-like product performance或任何数值预算。

因此本收据不关闭 `TC2-CASE-INT-003`、`TC2-CASE-QA-001` 或配对性能 Gate，
也不形成 Product、Quality、TestFlight、Release、merge 或 publication 结论。

## Preserved raw artifacts

Artifacts retained outside Git：
`/private/tmp/typo-correction-002-perf-runs/TC2-PERF-20260918-184840-RIMEICE-01/raw/`

| 文件 | SHA-256 |
|---|---|
| `rime-runtime-provenance.json` | `ba04b36a55d4d76426ef3c5674b4c3e2824a0c6cdc35f8c30912e89942b263ba` |
| `diagnostics-baseline-raw.jsonl` | `71427582e7378bcd074a4ad6e5a2c7efbb739651630824db31bdeef4d7f3b846` |
| `diagnostics-baseline-attempt.jsonl`（排除的错误序列尝试） | `58df0c81ad98025ddbfdba8b6b8833e4f20dcb1b729f3c9abc88aba00585e680` |
| `diagnostics-treatment.jsonl` | `9a27e1a1bc247510748f264ec1c4d2e28b5b972c4623d725742583769a3228cd` |
| `treatment-final.jpg` | `9efe6d561a79002415afd5faa229a43c982d0aafc6a7e66f375a97c86750dc74` |

Raw journal 的读取和摘要只使用 content-free 字段；不发布宿主正文、候选文字
或用户输入历史。
