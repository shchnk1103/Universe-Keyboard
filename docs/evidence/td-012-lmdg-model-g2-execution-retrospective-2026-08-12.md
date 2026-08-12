# TD-012 G2 执行复盘：减少重复测试与证据成本

> **性质：** Executor retrospective / KOS 优化建议，不是新的 Product Decision 或 KOS 规范修订。
> **范围：** 2026-08-12 万象基础输入恢复、G2-B 设备测量及其 Hold 收敛。

## 1. 结果摘要

- 万象基础输入与自动部署回归已修复，并通过完整 CI 等价门、独立 Architecture/Quality 复核和
  最终真机 smoke。
- G2-A 模型资产 pin 保持 Pass；模型可以按固定 size/SHA 安全 stage、加载并清理。
- G2-B 最新 A/B 因 baseline/model 实际 Debug dylib 不同而作废。Product 决定 `Hold`：停止测试，
  不进入 G3。
- 设备、App Group、Mac 临时模型和 Git 工作树均已清理；没有把无效 A/B 包装成通过。

## 2. 为什么今晚发生多次重复

### 2.1 把“同源码”误当成“同二进制”

`xcodebuild test` 不只是运行测试；它会重新构建、重新链接并可能重新安装 test host 与 App。
本轮冻结了 commit/tree 和外层 Extension UUID，却没有在**每次可能安装 App 的动作之后**重新核对
实际 `Keyboard.debug.dylib` UUID/SHA。这个检查直到全部人工输入结束后才做，导致证据晚期作废。

### 2.2 Stage、probe、install、measurement 没有被建模成单向状态机

正确顺序应是：

`build once → install once → baseline → stage without build/install → model arm → cleanup`

本轮 stage/probe 依赖 XCTest，XCTest 又隐含 build/install 副作用；随后为了“恢复同一 App”再次安装，
反而破坏模型在场。流程虽然每一步局部合理，但全局状态转换没有 fail closed。

### 2.3 CoreDevice 路径语义在执行时才被逐步发现

向 `tmp/td012-g2/` 复制单文件时，CoreDevice 将目标创建成扁平文件 `tmp/td012-g2`；复制 cleanup
request 时又需要目录语义。虽然 helper 有 flat fallback，但 runbook 没把“文件态 → stage 后空路径 →
目录态 cleanup request”的精确转换预先写死，导致 cleanup 重试。

### 2.4 独立复核在代码上足够早，在设备 runbook 上不够早

Architecture/Quality 对源码与 helper 做了严格审计，但最终设备执行命令序列没有在第一次人工输入前
经过一次“dry-run review”。因此 reviewer 很早发现了代码 fail-open，却没在人工测量前阻止
`xcodebuild test` 改变二进制这一执行级问题。

### 2.5 自动化输出过长，关键信号出现得太晚

大量 `xcodebuild`、sysmon XML 和历史 crash 列表被完整读入上下文。质量没有因此提高，因为最终判断
只依赖少量结构化字段；反而增加了 token 消耗和发现关键差异的延迟。

## 3. KOS 2.1 的最小优化建议

以下建议先作为实践模板，不直接修改冻结的 KOS 原则。

### K-01：Human-cost gate

凡是需要真人重复操作的设备门，在首次人工动作前必须记录：

- 最大人工轮数，默认 `1`；
- 哪些自动动作会使该轮证据失效；
- 失效后默认 `Hold`，不得自动请求重测；
- 只有 Human Product Lead 可追加人工轮次。

这把“用户时间”作为显式预算，而不只是依赖项。

### K-02：Immutable run manifest

在 A/B 前生成机器可读 manifest，至少包含：

- commit/tree；
- App、Extension stub、实际 Debug dylib 的 UUID/SHA/size；
- build configuration、优化级别、SDK、签名、schema/config fingerprint；
- device/OS；
- asset size/SHA；
- 允许执行的命令 allowlist。

每一臂开始前重新读取已安装二进制并与 manifest 比较；任何差异在人工输入前停止。

### K-03：Command side-effect ledger

Runbook 的每条命令标注 `build / install / mutate App Group / read-only / cleanup`。A/B 冻结后，
命令只要含 `build` 或 `install` 就默认禁止。名称像 “test” 不能掩盖其 build/install 副作用。

### K-04：Evidence readiness review

独立 reviewer 在设备操作前只审核一页 readiness：状态机、manifest、命令 allowlist、停止条件、清理
路径。代码 review 不替代 runbook review。通过后才向 Device Operator 发第一条指令。

### K-05：Invalidation ledger

一旦发现证据失效，立即写一行：`arm / reason / discovered-at / excluded artifacts / next authority`。
后续工具和 reviewer 默认忽略 invalidated arm，避免重复解释或误用旧数字。

## 4. 不降低质量的 token 节省方案

### 4.1 先结构化，再查看原始输出

- XCTest：先读 `xcresulttool ... summary`，失败时才展开具体 test log。
- xctrace：先输出 TOC 和一个小型指标 JSON；XML 只保存到本地，不整段回传上下文。
- crash：先按时间窗和进程名列文件，再对单个候选用 `jq` 提取 victim/reason。
- Git：默认 `status --short + diff --stat + diff --check`；只有范围异常才展开完整 diff。

### 4.2 单一 receipt 工具

为 G2 类设备门准备一个仓库脚本，一次输出不含用户内容的 JSON：

```json
{
  "binaryMatch": true,
  "modelPinMatch": true,
  "modelPresent": true,
  "trace": { "pid": 0, "samples": 0, "footprintMiB": {} },
  "newKeyboardCrash": false,
  "keyboardJetsamVictim": false,
  "cleanupZeroResidue": true
}
```

对话只需要传这份 receipt 和异常字段；原始 artifacts 保留供复核。节省 token 的同时提高可审计性。

### 4.3 评审按增量触发

- 源码冻结前：Architecture/Quality 审代码。
- 人工输入前：审 run manifest/runbook。
- 采集后：只复核 receipt、raw hashes 与异常。

避免每次小改都让 reviewer 重读整个历史，也避免把关键执行问题留到最后。

### 4.4 用户指令只包含当前动作

每次只告诉 Device Operator：当前状态、一个动作、完成回执。内部细节留在工具记录；只有失败时解释。
这符合既有 KOS 人工门要求，也减少用户认知负担。

### 4.5 长命令输出默认 quiet + 文件化

成功路径只保留 exit code、测试计数、artifact 路径和 SHA。错误路径再按定位需要展开最多几十行，
不把数万行编译日志放进上下文。

## 5. 下次若重新开启 G2-B

必须新建 Product Decision，并在任何人工输入前完成：

1. 预构建一次 test products；记录 App/stub/dylib manifest。
2. 验证 stage 与 cleanup 可通过 `test-without-building` 或独立已签名 helper 执行，且不会安装 App。
3. 用无人工输入的 dry run 证明 stage 前后已安装二进制 SHA 不变。
4. baseline 前核对 manifest；stage 后、model arm 前再次核对，必须 byte-for-byte 相同。
5. 人工轮次上限为一次；任一前置条件失败直接 Hold，不进入人工测量。

## 6. Executor 责任结论

今晚最主要的问题不是测试严格，而是把严格检查放得太晚。正确优化不是减少验证，而是把最便宜、
最决定性的验证（实际二进制 SHA）前移到第一次人工操作之前。这样既能保持甚至提高证据质量，也能
显著减少设备重复、上下文 token 和用户等待。
