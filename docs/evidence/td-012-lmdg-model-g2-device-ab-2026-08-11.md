# TD-012-LMDG-MODEL-G2 — G2-B 同构建真机 A/B

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-11 Asia/Shanghai` |
| **Assignment** | [`TD-012-LMDG-MODEL-G2`](../assignments/td-012-lmdg-model-g2.md) |
| **Evidence grade** | 工具数据 `Executor-recorded`；人工输入步骤 `Device-attested` |
| **Status** | **Executor evidence complete — Stop/Hold；等待独立 Architecture、Quality 与 Product disposition** |

## Run Header

| Field | Baseline（无模型） | Model（固定模型） |
|---|---|---|
| Device / OS | iPhone 13 Pro (`iPhone14,2`) / iOS `27.0 (24A5408d)` Beta | 同左 |
| Connection | wired；Developer Mode enabled；Full Access 由 Device Operator 当次确认 | 同左 |
| Production source | `9a177ab`；本分支仅新增非 shipping 测试 helper 与治理/证据文档 | 同左 |
| Extension UUID | `ACAEE389-29CD-3695-99CF-54CDC5644676` | `ACAEE389-29CD-3695-99CF-54CDC5644676` |
| Extension PID | `7474` | `7407` |
| Scheme/layout | 万象拼音 `wanxiang` / 26-key Chinese | 同左 |
| Model | absent；受控清理测试已确认删除 | `wanxiang-lts-zh-hans.gram`，`420251692` bytes，SHA-256 `90d2385f65337f8b8c7b1ba5cbe874df3f2d91b462d68fa2f9fe90c57aa3bc66` |
| Operation | 从系统键盘切入；同一 disposable、非敏感长拼音序列输入并选择第一候选，共 3 轮；切回系统键盘 | 同左 |

实际输入内容不写入 evidence、trace 名称或日志。首轮旧构建 baseline 的 Extension UUID 为
`CCE6BB8B-3F17-3E25-BE37-4EF4D784BE8C`，因与模型组不一致而从正式 A/B 排除；清理模型后重采
上表 baseline，避免把构建差异误当模型差异。

## Staging And Cleanup Contract

非 shipping 的 `TD012LMDGDeviceStagingTests` 只接受 App Group
`tmp/td012-g2/wanxiang-lts-zh-hans.gram` 中准确匹配 size/SHA-256 的 fixture。物理设备 stage test
先移动到不可解析的 partial 名，再暴露为 `Rime/shared/wanxiang-lts-zh-hans.gram`；执行结果：
`1 test / 0 failures`。模型组完成后，独立 `cleanup.request` 触发 cleanup test；它重新校验目标
摘要后才删除，并断言模型和 request 均不存在；执行结果：`1 test / 0 failures`。

Mac 侧第二次下载的临时模型与 cleanup request 也已删除，`LOCAL_TEMP_REMOVED=YES`。没有模型
进入 Git、App bundle、Release 或产品安装路径。

## Activity Monitor Results

`physical footprint` 是本门的主要进程内存指标；`resident size` 同时包含可回收 file-backed 页，
因此单独列出但不把它等同于 Jetsam footprint。所有数值单位为 MiB。

| Metric | Baseline | Model | Model − Baseline |
|---|---:|---:|---:|
| Samples / observed span | `44 / 51.980 s` | `49 / 50.697 s` | — |
| Physical footprint min | `10.158` | `12.314` | `+2.156` |
| Physical footprint median | `21.549` | `21.471` | `-0.078` |
| Physical footprint max | `22.939` | `22.533` | `-0.406` |
| Cold ≤5 s footprint median | `13.486` | `15.768` | `+2.282` |
| Post-5 s footprint median | `21.549` | `21.674` | `+0.125` |
| Start → end footprint | `10.158 → 21.486` (`+11.328`) | `12.314 → 21.674` (`+9.360`) | — |
| Resident size min | `70.156` | `80.859` | `+10.703` |
| Resident size median | `117.875` | `138.859` | `+20.984` |
| Resident size max | `118.297` | `140.953` | `+22.656` |

两次 trace 中 Keyboard 的 `Process Recently Died` 均始终为 `No`，状态均为 `Runnable`。模型组
没有出现 physical-footprint 峰值增加；这支持“固定模型在本次输入窗口内没有造成明显进程内存
压力”的窄结论，不建立跨设备预算、SLO、长时稳定性或 Release 结论。

## Jetsam And Exit Classification

- `JetsamEvent-2026-08-11-224005.ips` 的终止原因属于 `coreduetd / per-process-limit`；
  `Universe Keyboard` 只作为 suspended 进程出现在系统快照中，Keyboard Extension 不是 victim。
- 模型 PID `7407` 在 Device Operator **切回系统键盘后**产生
  `RUNNINGBOARD / SIGKILL / 0xdead10cc`；最终 baseline PID `7474` 在相同退出动作后产生完全相同
  记录。两者 Extension UUID 相同，且 baseline 更早的旧构建也有同类记录。
- 因而没有证据把 `0xdead10cc` 归因为 `.gram`，也不能把它分类为模型内存 Jetsam；但它仍是
  crash report，并命中 Assignment 的显式 Stop Condition。Executor 不得据此自动进入 G3+。

## Raw Evidence And Integrity

以下路径位于被 Git 忽略的本地 `evidence/`，不会随 PR 发布：

| Artifact | SHA-256 / bundle aggregate |
|---|---|
| `raw/final-baseline-current-build.trace` | `6ba377075c1b1e046876599871230af90ac43d9bf065e6524f72898538b4ba34` |
| `raw/model-activity.trace` | `d18308a4d760ae45eb88a77385cee16764fd34f0358aa2ce4423753e2de7f902` |
| `raw/final-baseline-current-build-sysmon.xml` | `eee8cf4248b620b4131cbd8683eace15665a07e9b6ec739816584fb5c994757b` |
| `raw/model-sysmon.xml` | `316da1f0bc87766311f3783f3734b1078dbd69339b053dae42a95c01bcef68c9` |
| `raw/crashlogs/Keyboard-2026-08-11-225858.ips` | `5898ee3ec7c55b78f68c64ca8c4d611bb8b15a9ae9f63c7b4248693acda9eae2` |
| `raw/crashlogs/Keyboard-2026-08-11-225122.ips` | `ee231510aefcb5c7007f3dab08c52dc6cf3c5612a94190a541f91195f4f526be` |
| `raw/crashlogs/JetsamEvent-2026-08-11-224005.ips` | `9fe5f5e5cb9117e7ae982c67a4e0fe7eb2094efcf59937f5d20505310934ce22` |

Trace bundle aggregate 由 bundle 内所有普通文件按相对路径排序、逐文件 SHA-256 后再次 SHA-256
得到。原始采样包含一次 Instruments dylib-overlap warning，但 TOC 与 `sysmon-process` 均可导出，
对应 PID、时序和生命周期日志能够交叉核对；本 evidence 不把 warning 静默视为无影响。

## Executor Disposition

1. **G2-A remains Pass**：资产可按实际字节摘要固定。
2. **G2-B memory/Jetsam narrow result**：本次同设备、同 OS、同 Extension UUID 的短窗 A/B 未见
   模型引入 physical-footprint 峰值增长或 Keyboard Jetsam。
3. **Overall G2 = Hold at Stop Condition**：相同的 `0xdead10cc` 在 baseline/model 切换退出后均存在。
   独立 Architecture/Quality 必须判断该既有生命周期信号是否允许 G2 继续；Product Lead 再决定
   `Go G3+`、`Hold` 或 `No-Go`。
4. **Non-claims**：不宣称模型质量提升、长期稳定、iOS 26/Release 适用、产品部署可用或可发布。

## Repository Verification

- 发布前本地 CI 复核日期：`2026-08-12 Asia/Shanghai`。
- `swift-format lint --strict`：新增 test helper **Pass**。
- 物理设备 stage test：`1 test / 0 failures`；cleanup test：`1 test / 0 failures`。
- `KeyboardCore`：`973 tests / 0 failures`；存在一条仓库既有 optional interpolation warning，
  不涉及本分支文件。
- `RimeBridgeTests`：`57 tests / 0 failures / 20 fixture-dependent skips`。
- iPhone 17 Pro / iOS 26.5 Simulator 完整 `Universe Keyboard` scheme test：
  `UniverseKeyboardTests 153 tests / 0 failures / 2 physical-only skips`；
  `KeyboardTests 6 tests / 0 failures`；`** TEST SUCCEEDED **`。
- 同 destination 的 Debug build 与 Release build 均 `** BUILD SUCCEEDED **`。
- 使用 iOS 26.5 是因为当前工程 deployment target 为 iOS 26.4，本机 iOS 26.0 destination 不兼容；
  设备型号保持 CI 的 `iPhone 17 Pro`。这不构成 iOS 26.0 Release 证据。
- 变更文档本地链接：10 files checked，0 broken；`git diff --check` **Pass**。
- `CHANGELOG.md` 与 ADR 未更新：G2 没有形成产品能力或生产架构变更。
