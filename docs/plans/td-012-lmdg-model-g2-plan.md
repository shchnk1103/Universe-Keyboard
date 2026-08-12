# TD-012-LMDG-MODEL-G2 执行计划

> **Status:** Active — Executor G2 evidence complete；Stop/Hold，等待独立复核与 Product disposition
> **Current source of truth:**
> [`PD-TD-012-LMDG-MODEL-G2`](../product-decisions/TD-012-LMDG-MODEL-G2-authorization.md) ·
> [`Assignment`](../assignments/td-012-lmdg-model-g2.md) ·
> [`TD-012`](../TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration)
> **Archive condition:** Product 对 G2 作出 `Go G3+`、`Hold` 或 `No-Go`，且 Assignment 完成交接。
> **ADR:** G2 不改变生产架构，因此当前不需要 ADR；若进入持久部署/G3，必须重新判断并优先提出 ADR。

## 1. 第一性原理边界

| 问题 | G2 输入 | 状态落点 | 副作用边界 | 可验证输出 |
|---|---|---|---|---|
| 资产是否可固定 | 上游 asset metadata + 实际下载字节 | 仓库外临时目录 | 不进 Git/App Group/App bundle | SHA-256、size、receipt |
| Extension 是否可承受 | 同一真机的无模型/有模型环境 | 仅受控 G2-B 环境 | 不形成产品安装路径 | RSS、增长趋势、Jetsam 分类 |
| 是否值得产品化 | G2-A/G2-B 证据 | Product Decision | Executor 不自动推进 | Go/Hold/No-Go |

## 2. G2-A — Asset Pin

1. 查询并记录 LTS Release 与简体 asset metadata。
2. 检查本机隔离目录空间，不复用仓库或 App Group。
3. 通过 GitHub asset API 下载指定 **asset ID**，不使用“latest release”发现路径。
4. 计算实际文件字节数与 SHA-256；任何不一致立即停止。
5. 记录 LICENSE blob/source、attribution 和“非法律意见”边界。
6. 写 G2-A evidence；确认 `git ls-files '*.gram'` 为空且工作树不含模型。

## 3. G2-B — Device Viability Gate

G2-A 通过后才准备。Executor 先完成可自动化部分，然后在需要真机操作时停止并给 Human
Device Operator 一次只包含当前步骤的指引。

测量顺序固定为：

1. 冻结 commit、build、设备、OS、schema `wanxiang` 与 Full Access 状态。
2. 无模型：cold start、会话建立、长 composition、resident memory、退出分类。
3. 受控放置已验证模型并由非 shipping Main App test helper 完成一次性暂存；禁止 Extension 部署。
4. 有模型：重复同一序列，记录 RSS/增长趋势与 Jetsam/普通生命周期事实。
5. 清理受控模型并确认基础万象仍可用。

上述 1–5 已于 `2026-08-11` 完成，结果见
[`G2-B same-build device A/B`](../evidence/td-012-lmdg-model-g2-device-ab-2026-08-11.md)。模型组未见
physical-footprint 峰值增长或 Keyboard Jetsam，但 baseline/model 在切回系统键盘后均产生相同
`RUNNINGBOARD / 0xdead10cc` crash report。按 Assignment Stop Condition，当前停在独立
Architecture/Quality 与 Product handoff，不进入 G3+。

本计划不预设内存预算。明显 crash/Jetsam/基础输入回归触发 Stop；其余数据交给独立 Quality
和 Product 判断。

## 4. 当前实现约束（G3 输入，不在 G2 实现）

- 现有 `GitHubSchemaCatalogClient` 请求 `releases/latest`，无法固定 LMDG `LTS` asset。
- 现有 scheme 流程假定 ZIP + schema；`.gram` 是单一大型二进制文件，不能套用解压流程。
- Catalog 虽有 checksum storage key，当前 scheme 下载路径没有安装前 SHA-256 验证。
- 未来模型安装必须是临时下载 → 摘要验证 → 原子替换；不得继承逐文件半安装语义。
- 模型的 shared/user 搜索顺序必须由 pinned librime 的 `ResourceResolver` 运行证据确认，不能靠猜。

G2-B 使用 `UniverseKeyboardTests/TD012LMDGDeviceStagingTests.swift` 作为非 shipping、默认跳过的
物理设备 helper。`devicectl` 只能把固定字节传入 App Group `tmp/td012-g2/`；helper 仅在文件的
准确 size/SHA-256 匹配时，将其通过不可解析的中间文件名移动到 `Rime/shared`。清理同样要求
独立的 `cleanup.request`，且只删除摘要仍匹配的目标文件。它不是产品安装器，也不进入生产 target。

## 5. 验证与交接

- G2-A：metadata receipt、实际 SHA-256/size、license pointer、仓库/App Group absence。
- G2-B：按 `PERFORMANCE_BASELINE` 记录方法、commit/build、设备/OS、A/B 与退出分类。
- Executor 结果标记 `Executor-recorded`；真机人工步骤标记 `Device-attested`；独立复核后才能使用 `Quality-reverified`。
- G2 不更新 `CHANGELOG.md`，因为尚未形成产品能力；若 G3+ 改变生产行为再更新。
