# TD-012-LMDG-MODEL-G2 — 作废的真机 A/B 尝试

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-12 Asia/Shanghai` |
| **Assignment** | [`TD-012-LMDG-MODEL-G2`](../assignments/td-012-lmdg-model-g2.md) |
| **Evidence grade** | 工具数据 `Executor-recorded`；人工输入步骤 `Device-attested` |
| **Status** | **Invalidated / Product Hold — baseline and model used different Debug binaries** |

> **Stop:** post-run artifact verification found that the physical-device stage test rebuilt and reinstalled the
> Debug App. The model arm therefore did not use the same executable/dylib bytes as the baseline. Metrics below
> are retained as diagnostic observations only and cannot satisfy the Assignment's same-build G2-B exit criterion.

## Run Header

| Field | Baseline（无模型） | Model（固定模型） |
|---|---|---|
| Device / OS | iPhone 13 Pro (`iPhone14,2`) / iOS `27.0 (24A5408d)` | 同左 |
| Connection | wired；Developer Mode enabled；Device Operator 保持设备解锁 | 同左 |
| Source commit / tree | `e12d32c407a939e734a8bec1863d4cb7ce9dda44` / `5e9ca809ab8bbbeead9beef948f311a7826f0ef3` | 同左 |
| Build | Debug；SDK `iphoneos27.0`；deployment target `26.4`；Swift `-Onone`；GCC `O0`；Apple Development / team `C33N6HTS9N` | 同左 |
| Extension executable | UUID `52FA8B32-7BE5-3982-B715-1690E9268AC1`；SHA-256 `d6f9074f84d1821974404745759fb481130242a993404a5ac1ee37ef4d266e9e` | UUID `52FA8B32-7BE5-3982-B715-1690E9268AC1`；SHA-256 `761074b092f726ff7625b5141d79ec9f08b52ea922d0c9d65f2c3b7a15f721c8` |
| Extension Debug dylib | UUID `1DB6B297-B6D1-3471-857E-B821ED7906AB`；SHA-256 `8305c290c6ca603e89822e93122b7e871608bba7c4a0b9e7b63428831fe6e7a4` | UUID `E40D868D-D8D8-3060-90EA-5D27D424DB7E`；SHA-256 `67144df1514f0e6b57ec79e2acae11331486f059b1d68027adbfbdf21e6ec9a3` |
| Extension PID | `20481` | `20782` |
| Scheme/layout | 万象拼音 `wanxiang` / 26-key Chinese | 同左 |
| Model | absent；采集前递归搜索 `0 files` | `wanxiang-lts-zh-hans.gram`，`420251692` bytes，SHA-256 `90d2385f65337f8b8c7b1ba5cbe874df3f2d91b462d68fa2f9fe90c57aa3bc66` |
| Operation | 从系统键盘切入；同一非敏感长拼音序列输入并选择第一候选，共 3 轮；切回系统键盘 | 同左 |

实际输入内容不进入 evidence、trace 名称或日志。模型组在最后一次 stage 完成后未再安装 App、
运行测试或部署 RIME，直接进入采集；但 stage test 本身在 baseline 之后重新链接并安装了不同的
Debug executable/dylib，因此两臂不是同一二进制。

## Asset Presence And Load Receipts

1. 从固定 GitHub asset ID `508872749` 重新下载到仓库外临时目录。
2. Mac 侧实际字节再次匹配 `420251692` 与固定 SHA-256。
3. 物理设备 stage helper 对源文件再次执行 regular-file、byte-count、SHA-256 校验，经不可解析
   partial 名原子 rename 到 `Rime/shared`；stage test `1 / 0 failures`。
4. 同一源码和同一固定资产的 Grammar probe 取得 Executor-recorded content-free receipt：
   `loadStarted=true`、`validDoubleArrayObserved=true`、`doubleArraySize=105062912`。
5. 最终模型臂在最后一次 stage test 后未再运行 probe 或安装动作，以避免测试 runner/App 安装刷新
   模型状态；Activity Monitor 随即开始。

CoreDevice 禁止从 App Group 根级 `Rime/shared` 直接 copy-from，因此不能在不运行第二个 test bundle
的情况下把 staged 文件回读到 Mac。此限制被明确保留；stage 的双重 pin、同资产 Grammar receipt
以及“stage 后零写操作直接采集”共同构成本轮模型在场证据。

## Activity Monitor Results

`physical footprint` 是本门的主要进程内存指标；`resident size` 包含较多可回收 file-backed 页，
因此单独报告。单位均为 MiB。

| Metric | Baseline | Model | Model − Baseline |
|---|---:|---:|---:|
| Samples / observed span | `24 / 23.892 s` | `32 / 32.258 s` | — |
| Physical footprint min | `11.627` | `11.846` | `+0.219` |
| Physical footprint median | `19.885` | `17.619` | `-2.266` |
| Physical footprint max | `22.705` | `23.018` | `+0.313` |
| Cold ≤5 s footprint median | `18.814` | `14.893` | `-3.921` |
| Post-5 s footprint median | `20.330` | `18.190` | `-2.140` |
| Start → end footprint | `17.486 → 11.627` | `12.471 → 11.846` | — |
| Resident size min | `99.719` | `80.297` | `-19.422` |
| Resident size median | `111.180` | `123.312` | `+12.132` |
| Resident size max | `115.062` | `131.141` | `+16.079` |

两臂所有 Keyboard 样本均为 `Runnable`，`Process Recently Died=No`。表面上模型组
physical-footprint 峰值高 `0.313 MiB`，但由于二进制不一致，该差值不能归因于模型，也不能作为
G2 Pass 证据。resident 差异同样仅作诊断保留。人工操作节奏和样本跨度也不同，因此这不是固定
cadence benchmark。

## Crash And Jetsam Classification

- 基线窗口后没有新的 Keyboard crash 或 JetsamEvent。
- 最终模型窗口后没有新的 Keyboard crash 或 JetsamEvent。
- `JetsamEvent-2026-08-12-220939.ips` 发生在被作废的早期模型臂/cleanup 重试期间，早于最终模型
  trace 约 9 分钟。报告中没有 Keyboard 进程；`largestProcess` 是另一个 suspended `ProductName`
  进程。因此它不能归因为 Keyboard 或固定 `.gram`，但作为执行期间环境事件保留原始记录。
- 2026-08-11 A/B 的 `RUNNINGBOARD / 0xdead10cc` 在本轮 baseline/model 两臂均未复现。

## Invalidated Arm

`22:04` 的首次模型 trace **作废**：Grammar probe 后又覆盖安装了 App，随后 cleanup test 观察到
模型文件已不存在，无法证明采样期间模型仍在。该 trace 仅保存在本地
`raw/discarded/model-presence-unproven.trace`，不参与任何指标或结论。表中纳入诊断比较的是
`22:18:39` 开始的 `final-model.trace`；它仍因二进制不一致而不能成为有效 A/B 证据。

## Cleanup

- 最终 cleanup test 为模型存在/已不存在两种测试 runner 状态提供 fail-closed 清理：存在时先按固定
  摘要验证再删除；已不存在时只删除精确 `cleanup.request`。该临时 test-only 分支运行后立即恢复，
  未进入提交或生产 target。
- 最终 App Group 递归检查：模型 `0 files`、`.td012-staging` `0 files`、cleanup request `0 files`。
- Mac 的 420 MB 临时模型已删除；`git ls-files '*.gram'` 为空；工作树恢复到冻结提交。
- Device Operator 已在一次等价的清理后确认无模型万象基础输入正常；最终清理没有改变生产代码、
  schema 或部署状态，且不再要求重复人工输入。

## Raw Evidence Integrity

原始文件位于被 Git 忽略的本地目录
`evidence/td-012-lmdg-model-g2/2026-08-12/raw/`：

| Artifact | SHA-256 / bundle aggregate |
|---|---|
| `final-baseline.trace` | `517d194174eda19545cbce4683649bfe3f6d618ea7810a99001308cf270086c5` |
| `final-model.trace` | `b5bdf7356fa04ba1c1c753f72cbbdc6a8ce8eb55283f85bde47f0ac67a79eb1e` |
| `final-baseline-sysmon.xml` | `64acb204ec30932d1aabb87e420056a1ba48f52bf09711e66811ec399b3e61e3` |
| `final-model-sysmon.xml` | `ddc919487ffc8fe1d19462420c19aeebdb8cee18443bb4922a5187aa3c689651` |
| `JetsamEvent-2026-08-12-220939.ips` | `5149bff690c9feab54f8e68c3ef5fde1c333bd62a2cdc4bad202861e52060f3c` |

Trace bundle aggregate 使用以下固定命令计算（逐文件 SHA-256 按路径排序后再摘要）；Quality 本轮未独立
复现 bundle aggregate，因此它保持 `Executor-recorded`：

```bash
find <trace-bundle> -type f -print0 | sort -z | xargs -0 shasum -a 256 | shasum -a 256
```

Grammar receipt 与最终设备零残留 inventory 同样保持 `Executor-recorded`，不标记为
`Quality-reverified`。

## Executor Decision Boundary

1. G2-A pin remains Pass。
2. 本轮没有观察到 crash、Keyboard Jetsam 或基础输入回归，但 binary mismatch 使 A/B **无效**。
3. G2-B exit criterion 未满足；不得把本记录提升为 `Quality-reverified` 或 G2 Pass。
4. Human Product Lead 于 `2026-08-12` 决定 `Hold`：停止测试，不进入 G3。未来如重启，必须建立
   新 Product Decision，并先验证预构建 `test-without-building` 流程不会改变二进制。
5. 不授权 G3、持久模型安装、schema/UI、默认开启、其他方案或 Release/Product Gate。
