# 独立 Quality / Performance 复审：T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02 Evidence Enforcement

| 字段 | 结论 |
|---|---|
| 复审角色 | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| 复审日期 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | [`P2-PERF-02 Evidence Enforcement`](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement.md) |
| 复审基线 | 当前 worktree tip `3585a54`；工作树存在其他任务的 ambient 改动，本复审不归因、不覆盖、不提交 |
| 关联合同 | [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)；[`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)（仍为 `Proposed`） |
| 复审范围 | validator/allow-list、ThreadAffine owner 与 session snapshot、geometry retry、诊断接线、测试与当前 tip 的静态构建；不包含真机/真实 librime 运行 |
| Quality 结论 | **Pass with conditions（bounded implementation/evidence review）**；P2-PERF-02 仍不能标为 `Complete` |
| P0 / P1 / P2 / P3 | **0 / 0 / 6 / 1** |
| 治理结论 | 不形成 Product Gate、Release、ADR Accept、默认开启或真实 off-main 生产收益结论 |

## 1. 复审方法与证据层级

本次只读检查了最新子 Assignment、证据合同、Architecture 复审、validator/line filter、
ThreadAffine owner/session 实现、KeyboardCore 回归以及当前 tip 的 App/Extension 构建。
工作树中的其他改动没有被当作本 Assignment 的变更，也没有被暂存或覆盖。

证据分为三层：

1. **代码/测试证据**：可以证明纯函数判定、隔离形状和默认 gate 约束；
2. **artifact 证据**：可以证明当前源码在显式诊断 flags 下生成了 app/extension；
3. **设备运行证据**：需要安装、真实 librime、日志导出和物理设备，本次没有执行。

因此，本 review 只给 bounded Quality 结论，不把测试通过或字符串扫描升级为设备证据。

## 2. 已验证的结果

### 2.1 测试与构建矩阵

| 项目 | 结果 | 证据边界 |
|---|---:|---|
| `T9ResponsiveEvidenceValidatorTests` | **9 / 0** | 39 行正样本、旧 `T9ARM actions=38` checkpoint、缺失/重复/乱序、PATH/READY、session、geometry、隐私和分类 |
| `ThreadAffineRimeWireTests` | **8 / 0** | owner-thread native session snapshot 的值传输与顺序边界 |
| `ThreadAffineRimeSpikeTests` | **10 / 0** | 150ms+ owner 阻塞时 MainActor 仍可 enqueue、FIFO、epoch 丢弃、生命周期和 gate-off |
| KeyboardCore 全量 | **871 / 0** | 当前 tip 的 SwiftPM 全量通过；已有 optional interpolation 警告不影响通过 |
| RIME vendor structural verify | **通过** | `bash scripts/ensure_rime_vendor.sh verify`；仅结构清单，不是运行证明 |
| `git diff --check` | **通过** | 工作树格式检查；没有改变 ambient diff |
| Release generic iOS app + extension | **BUILD SUCCEEDED** | `CODE_SIGNING_ALLOWED=NO`，仅命令行注入 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`；产物为 iPhoneOS 27.0 generic build，不是签名安装包 |

当前构建的 app/extension 字符串包含 `T9ResponsiveEvidenceValidator`、
`T9RESP marker=PATH/READY`、`T9DEVICE_DISABLED` 和 `T9GEOM phase=execution`。这修正了
子 Assignment 中“最后 validator hardening 后未再生成 app/extension”的过时验证快照，
但只补足了静态 artifact 层，仍没有补足设备运行层。

### 2.2 bounded 通过项

- Validator 对声明的 39-action content-free fixture、旧 `T9ARM actions=38` checkpoint、
  token/顺序/session/geometry/privacy 的主要正负样本已有纯测试入口。
- ThreadAffine 形状保持单一 owner 线程：非 Sendable engine 在 owner 线程创建、调用和释放；
  MainActor 接收的是值型 session snapshot/result。复审对象中没有发现 `@unchecked Sendable`
  或将 live engine 假装跨隔离传递的实现。
- allow-list 与诊断 view 使用同一过滤函数，`T9RESP PATH/READY`、`T9SEG`、`T9ARM`、
  `T9GEOM` 和 `SLOW RIME` 不会因为旧的 App-local 白名单被主动排除；内容过滤保持无原始
  拼音、候选、marked text、host text 或 user dictionary 的设计目标。
- 默认 responsive/thread-affine gate 仍为关闭；项目默认编译设置没有把本次诊断 flags 写入
  Release 默认路径。真实接线仍被 explicit preflight gate 包住。
- geometry 采集失败会写出 `unavailable` 并保留 retry 意图，优于把首个过早 layout 当作
  有效 geometry；这证明了 fail-closed 方向，但不等于最终合同已闭合（见下文）。

## 3. Quality findings

以下是证据强度和可交付性问题，不是对默认生产输入路径的 P1 结论。

### P2-EE-01 — `PATH/READY` 没有 mandatory persistence 保障

`T9RESP PATH` 与 `READY` 仍通过普通 engine-category logger 写入，而不是与
`T9DEVICE` 相同的 preflight mandatory channel。若 logging 或 engine category 被关闭，
记录会在 writer 层被丢弃；导出 allow-list 只能保留已经持久化的行，不能恢复丢失的 marker。

因此当前测试证明“过滤器不会主动删除 PATH/READY”，尚未证明“每次内部 preflight 导出必有
PATH/READY”。需要选择并冻结一项合同：mandatory channel，或 Run Header 明确要求并验证
logging/category 已开启。

### P2-EE-02 — `T9RESP` schema 与 run identity 不足

Validator 对 PATH 主要检查 `path` 值，对 READY 主要检查是否出现 marker；当前 marker 没有
run token，也没有由 validator 强制检查 fixture、dual-gate 请求/激活状态、bootstrap 和
owner readiness 字段。旧日志与当前 39 条 `T9SEG` 混合时，布尔 PATH/READY 条件仍可能被
满足，削弱了“本轮 B arm 已就绪”的证据绑定。

### P2-EE-03 — validator 的 fail-closed schema/order 仍有缺口

当前实现没有覆盖所有下列错误：

- `T9SEG` action 与 event 可交叉错配时，独立的 `[1...39]` 数组检查未必拒绝；
- `ACCEPT → VISIBLE → PUBLISH` 只按 revision/单调顺序核对，尚未把 epoch 关系纳入完整合同；
- `committed` 缺失或 malformed 会落到 `false`，而不是必然报告 schema 缺失；
- 只有隐私违规、没有任何已识别 marker 的输入会落到 `NotRun`，不是严格的 `Blocked`。

这些缺口目前没有产生 P0/P1 生产回归，但会降低自动判定对坏证据的拒绝能力。

### P2-EE-04 — geometry digest 允许多值/空值，retry 终态不清晰

Validator 以 prepared/execution digest 的 Set 相等判定匹配，允许一次 run 中存在多个 digest；
空 digest 或未经形状校验的字符串也可能在两侧相同时被视为匹配。另一方面，先出现
`execution status=unavailable` 后即使 retry 成功，`execution-geometry-unavailable` 仍会留在
reasons，终态没有表达 transient retry 已恢复。

需要冻结唯一 digest、digest 形状和 `unavailable → success` 的终态语义，并补多 digest、空/非法
digest、reload 后 token 变化的负样本。

### P2-EE-05 — owner readiness timeout 被忽略

`startOwner()` 调用 `waitUntilReady(timeout:)` 后忽略返回值；bootstrap 随后可能记录 READY，
但 owner 尚未 ready、初始化超时或已构造失败。线程隔离本身没有因此失效，但 READY 的语义
不再等价于“session snapshot 可读取且 owner 正常运行”。应让 ready 结果进入 marker/validator，
超时或失败时 fail closed。

### P2-EE-06 — 真实 runtime/device/librime 闭环未执行

本次有当前 tip 的 unsigned generic app/extension 构建，但没有 iPhone 13 Pro 安装、启动、
输入长序列、导出诊断日志、验证真实 native session/geometry 或 A/B 对照。也没有真实 librime
长时间 owner 运行、Extension memory/queue/jetsam 或重载稳定性证据。因此历史 B 证据仍为
`Partial`，本子 Assignment 不能标 `Complete`。

### P3-EE-07 — allow-list 的 substring 边界依赖后置 validator

`T9DevicePreflightEvidenceLineFilter` 使用 `contains("T9SEG ")` 等 substring，而不是
版本化 marker 起始和字段 schema。它适合作为轻量导出筛选，但不能独立保证输出的每一行都是
合法 marker；当前安全性依赖后置 validator。建议补 marker shape、伪造前缀和 malformed
ASCII 的回归，避免未来消费者把过滤结果误当成已验证证据。

## 4. 隐私、默认 gate 与发布边界

- 运行时 evidence 仍是 content-free 设计；现有 validator 会拒绝已识别的 raw input、
  candidate/marked text/host text/pinyin/user dictionary 字段和非 ASCII 内容。上述
  P2-EE-03 的 markerless privacy 分类缺口需要后续补强，但本次没有发现把用户文本写入
  诊断 marker 的新路径。
- 本次没有修改默认 gate、输入语义、候选排序、RIME/Lua 或事件保序合同；显式诊断 flags
  仅用于当前 generic build。
- `ADR 0025` 仍是 `Proposed`。本 review 不接受 ADR，不宣布 off-main 生产迁移完成，不
  授权 R4 真实 librime 接线、R5 真机 A/B、R6、Product Gate、Release default-on 或发版。

## 5. 未执行验证

以下项目明确保留为未验证，不以测试绿灯或静态构建替代：

- iPhone 13 Pro 真机安装、解锁后的预检运行、content-free 日志导出和长句 A/B；
- 真实 librime session identity、owner readiness、geometry reload/retry 的运行时闭环；
- Extension jetsam、内存峰值、队列深度、长时间输入和多次键盘重载；
- iOS 26.0 Release RC、签名/archive/dSYM、TestFlight/App Store；
- Product Gate、ADR 0025 Accept、Release default-on 与任何用户体验 SLO 声明。

## 6. 交付与后续建议

**可以把本 review 交给 Architecture 做 bounded reconciliation；不能把它写成
Architecture accepted 或 P2-PERF-02 Complete。** 当前结论是：实现的隔离形状、测试入口、
隐私目标和默认 gate 边界足以通过条件式 Quality 复审，但 P2-EE-01 至 P2-EE-06 仍是关闭
证据合同前的条件。

建议下一授权工作按以下顺序进行：

1. 先冻结 PATH/READY mandatory channel、run-bound schema、geometry 唯一 digest/retry
   终态和 owner readiness 语义，并补对应纯 validator 回归；
2. 重新生成与源码 tip 绑定的 app/extension artifact，并在获得单独真机授权后执行一次
   content-free runtime 导出；
3. 由独立 Architecture/Quality 再审实现与证据，保持历史 B 为 `Partial`；
4. 将真实 librime、jetsam、iOS 26.0 RC、Product Gate 和 Release 决策继续留在各自授权
   边界内。

本角色在此停止；本文件是只读复审记录，不修改生产逻辑、测试、Assignment、ADR 或历史
证据。
