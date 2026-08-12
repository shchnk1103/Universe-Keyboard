# Assignment: TD-012-LMDG-MODEL-G2 — 万象 LMDG 模型资产固定与真机可行性门

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | G2-A **Pass**；G2-B evidence invalidated；Product Hold，停止测试且不进入 G3 |
| **Non-claims** | 无产品安装器、持久 App Group 模型、schema/UI、质量收益、跨设备内存预算或发布结论 |
| **Next** | 无当前执行；未来仅在新的 Product Decision 下重新开启严格同二进制测量 |
| **Residuals** | [`TD-012`](../TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** 当前 Human Product Lead 会话，`2026-08-11 Asia/Shanghai`
- **Product Approver:** Human Product Lead（当前权威 Product 会话）
- **Product Decision:** [`PD-TD-012-LMDG-MODEL-G2`](../product-decisions/TD-012-LMDG-MODEL-G2-authorization.md)

## Boundary

### Scope

1. G2-A：固定简体 `.gram` 候选的来源身份、字节数、SHA-256、许可证与 attribution；
   只在仓库外临时目录下载并验证。
2. 记录可复现 receipt 与失败关闭规则；模型不得进入 Git、App bundle 或产品安装路径。
3. G2-A 通过后，为 G2-B 准备无模型/有模型同设备测量合同，并在人工真机步骤前停止。
4. G2-B 获得当次人工配合后，采集 Extension 冷启动、长 composition、resident memory
   与 Jetsam 分类证据；只提出是否值得进入 G3+ 的建议。

### Non-goals

- G3–G6 catalog、下载 UX、schema patch、部署/卸载产品语义或默认开启。
- 雾凇、朙月、繁体、九键或其他布局/方案。
- 提交、bundling、镜像或发布 `.gram`；记录任何用户输入文本。
- 变更 Main App deploy / Extension session-only 边界、RIME vendor pin 或第二套 bridge。
- Product、Architecture、Quality、法律或 App Store 结论。

### Required Inputs

- [`TD-012`](../TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration)。
- 已关闭 [`TD-012-OCTAGRAM-VENDOR-G1`](td-012-octagram-vendor-g1.md) 及其 Architecture/Quality 结论。
- [`RIME artifacts`](../architecture/rime-artifacts.md)、
  [`shared-container lifecycle`](../architecture/shared-container-and-rime-lifecycle.md)、
  [`PERFORMANCE_BASELINE`](../PERFORMANCE_BASELINE.md)。
- 上游 [RIME-LMDG](https://github.com/amzxyz/RIME-LMDG)、
  [LTS Release](https://github.com/amzxyz/RIME-LMDG/releases/tag/LTS) 与 CC BY 4.0 LICENSE。
- G2 执行计划：[`td-012-lmdg-model-g2-plan.md`](../plans/td-012-lmdg-model-g2-plan.md)。

## Assignment

- **Domain Owner:** RIME Platform Maintainer
- **Executor:** Current agent
- **Environment Executor:** Current agent — G2-A 本机临时下载/摘要；G2-B 工具、构建与证据采集
- **Human Dependency:** Human Product Lead / Device Operator（当前用户）— G2-B 指定真机上的安装、键盘切换与输入操作
- **Architecture Reviewer:** Architecture & Knowledge Steward（独立于 Executor）
- **Quality Reviewer:** Quality, Performance & Release Maintainer（独立于 Executor）

## Gates

### Entry Criteria

- [x] Product Decision 明确 G2 最小范围和非目标。
- [x] G1 已 Closed，当前 vendor 能发现 concrete `grammar` component。
- [x] G2 从已包含文档修复 PR #67 的 `main` 独立开分支。
- [x] Active Work 加入本任务后不超过 10。
- [x] G2-A 不需要将模型写入仓库、App Group 或 shipping 路径。
- [x] G2-B 仅在 G2-A receipt 通过且 Human Device Operator 当次可用后进入。

### Exit Criteria

#### G2-A

- [x] 上游 Release ID、asset ID、文件名、字节数、创建/更新时间与候选摘要已记录。
- [x] 仓库外下载完成；本地 SHA-256 与候选摘要一致；模型未进入 Git/App Group。
- [x] CC BY 4.0 来源、attribution 要求和非法律结论边界已记录。
- [x] 可复现性明确依赖摘要而非可变 `LTS` URL；变更时 fail closed。

Evidence: [`G2-A asset pin`](../evidence/td-012-lmdg-model-g2-asset-pin-2026-08-11.md) (`Executor-recorded`).

G2-B preflight: [`device preflight`](../evidence/td-012-lmdg-model-g2-device-preflight-2026-08-11.md).

G2-B Executor evidence: [`same-build device A/B`](../evidence/td-012-lmdg-model-g2-device-ab-2026-08-11.md)
(`Executor-recorded` + `Device-attested`).

Latest revalidation attempt: [`invalidated device A/B`](../evidence/td-012-lmdg-model-g2-device-ab-2026-08-12.md)
(`Executor-recorded` + `Device-attested`).

Execution retrospective: [`G2 execution retrospective`](../evidence/td-012-lmdg-model-g2-execution-retrospective-2026-08-12.md).

#### G2-B

- [ ] 同一 Extension binary/device/OS/schema 下记录无模型基线与有模型结果；2026-08-12 attempt
  因 Debug dylib UUID/SHA 不同而作废。
- [x] 覆盖 cold start、长 composition、resident memory/growth 与 Jetsam 分类。
- [x] 输入 evidence 不记录实际用户文本；两组均完成相同的基础万象输入序列。
- [x] Architecture 与 Quality 分别确认 G2-B 因 Debug binary mismatch Blocked。
- [x] Product Lead 于 `2026-08-12` 决定 `Hold`；停止测试，不进入 G3。

### Stop Conditions

- 下载字节数或 SHA-256 与固定候选不符，或上游身份在执行中改变。
- 许可证/attribution 无法明确记录，或有人要求 Executor 给出法律意见。
- 需要把 `.gram` 写入 Git、shipping bundle、项目 Release 或未经授权的持久化位置。
- 需要修改其他 schema/layout、部署所有权或扩大到产品 UI。
- 真机出现 crash、Jetsam、基础输入回归，或证据无法区分普通退出与 Jetsam。
- 独立 Architecture/Quality review 不可用时，不得从 `Completed` 进入 `Reviewed/Closed`。

## Handoff

- **Handoff Target:** G2-A → Human Product Lead / Device Operator；G2-B → Architecture Reviewer + Quality Reviewer；最终 → Product Lead
- **Required Handoff Content:** asset receipt、摘要与来源、仓库/App Group absence、设备/build/OS、A/B 内存与 Jetsam 证据、失败与非声明。
- **Revalidation Trigger:** Product Decision 中任一 trigger，或候选资产/设备/build/environment 改变。

## History

- `2026-08-11`: Product 授权最小 G2；Assignment `Active`，先执行 G2-A。
- `2026-08-11`: G2-A actual-byte SHA-256/size/attribution receipt **Pass**；进入 G2-B 准备，人工操作前停止。
- `2026-08-11`: G2-B 同设备/同 Extension UUID A/B 完成；模型组未增加 physical-footprint 峰值，
  未发生 Keyboard Jetsam。baseline/model 在切回系统键盘后均生成 `RUNNINGBOARD / 0xdead10cc`；
  依 Stop Condition 暂停并交回 Product disposition，不得自动进入 G3+。
- `2026-08-12`: 修复 Extension 文件日志锁与万象基础输入回归后，以 commit `e12d32c` 重跑
  baseline/model。两臂均未出现 Keyboard crash/Jetsam 或基础输入回归，但 post-run 校验发现 stage
  test 重新链接并安装了不同 Debug dylib；同构建 exit criterion 未满足，记录作废并停在 G2-B
  Blocked。尊重 Device Operator 不再重复测试的意愿，等待 Product disposition。
- `2026-08-12`: Human Product Lead 明确决定 `Hold`。Assignment 以 `Closed` 收敛；G2-A
  保留 Pass，G2-B 不通过，不再要求设备测试，不授权 G3。未来重启必须有新的 Product Decision。
