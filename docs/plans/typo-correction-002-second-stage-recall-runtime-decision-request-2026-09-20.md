# Proposed Product decision request: TYPO-CORRECTION-002 bounded second-stage recall runtime lane

**Lifecycle:** `Superseded`

**Status:** Human Product Owner 于 `2026-09-20 Asia/Shanghai` 选择 B；由
[`PD-TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001`](../product-decisions/TYPO-CORRECTION-002-SECOND-STAGE-RECALL-RUNTIME-DESIGN-001.md)
及其 Ready Assignment 取代。本请求不授权实现、capture、提交或发布。

## Proposed work-package handoff

- **Triggering evidence:** [`QA-001 revalidation 07 receipt`](../evidence/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-inconclusive.md) 使用精确的 22 字母输入、真实 `rime_ice` sidecar 和可见候选栏，但 Human 未见目标候选；该 case 保持 `inconclusive`，并已由 [`QA-001 07 residual Product decision`](../product-decisions/TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL.md) 明确禁止同包同短语重跑。
- **Frozen facts and unknowns:** 生产 `productionV2` 仍为 `12/8`；canonical pinyin `womenjintianqugongyuan` 在 substitution-only expanded search 的观测 rank 为 `55`，生产集合不包含它（[`ADR 0016`](../architecture/decisions/0016-progressive-contextual-recall-preflight.md)）。纯 Core contract remediation 已有有界 Product Accept，但 runtime scheduler 的 corrected-input → canonical group identity、接受语义和真实 sidecar provenance 仍为 P1 open residual（[`core contract Product decision`](../product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-BOUNDED-DECISION-2026-09-20.md)）。未知的是：真实 RIME 若收到该 corrected pinyin 是否返回目标中文候选、其排序/可见位置，以及第二阶段的最小有效 cap。
- **Decision to preserve:** 现有 `12/8` 快路径、`60/64/8` default-off preflight、substitution-only 和双编辑 display-only 合同不因本请求改变。当前 QA-001 不是失败结论，也不是已证明的句子恢复。不得从 content-free journal 读取候选或拼音内容。
- **Proposed seam and alternatives rejected:** 候选方向是一个覆盖缺口触发的、可取消的第二阶段 runtime scheduler；它保留首阶段，并在独立 sidecar session 上按显式尝试上限查询。拒绝的替代方案是：直接将 `60/64/8` 接入所有输入、依赖 FakeCandidateProvider/旧 Ice/host text、自动改写、或以本地/云端模型替代可验证的覆盖边界。
- **Verification matrix:** 任何后续 runtime slice 必须绑定新的 source/package identity，并分别证明：（1）canonical group mapping 和去重/接受语义；（2）第二阶段触发、`maxQueryAttempts`、batch/resolved-group/candidate limits；（3）取消、revision/epoch 与 stale-publish fence；（4）真实 RIME provenance 与 privacy-safe route evidence；（5）新的 QA-001 package/run 上的候选可见性；（6）与 QA-001 分离的同进程 paired-performance 证据。每个 runtime 变更后均需独立 Architecture 与 Quality review。
- **Stop conditions and non-goals:** 若必须改变隐私边界、读取 host text/clipboard、自动提交/改写、放宽为无界搜索、引入本地或云端模型、复用旧 Authorization/Run ID、或把纯 Core 结果写成 RIME/性能/Product Gate 结论，立即停止。此请求不涉及 INT-003、paired performance、parent Close、commit、push、PR、merge、TestFlight 或 Release。
- **Required authorization and reviewers:** 只有 Human Product Owner 接受下列一个选项后，才可建立新的 Assignment 与匹配 Authorization。runtime 行动的 Domain Owner 应为 Input Intelligence Maintainer；Architecture 与 Quality reviewer 必须独立于实现者。任何真实 RIME 或设备证据还需单独命名 Environment Executor、Run ID 与 Human dependency。

## Product choice requested

| Option | Product disposition | Immediate effect | What remains prohibited |
|---|---|---|---|
| **A. 保持现状** | 保留生产 `12/8`，不追求该 canonical case 的第二阶段召回 | 不创建 runtime Assignment；QA-001 residual 保持已接受的 `inconclusive` | 不得声称句子恢复已实现或失败 |
| **B. 有界 runtime 设计 / preflight（建议）** | 先授权一个新的设计与 contract-preflight Assignment，选择 deterministic trigger、canonical group mapping、`maxQueryAttempts` 和取消/publish 边界 | 只产生设计、纯 Core contract 与 Architecture/Quality 输入；不接 production controller、不跑 RIME/设备 | 不得把 `60/64/8` 直接接线，不得创建新 QA-001 结论 |
| **C. 有界 runtime 实现** | 在新的 Assignment/Authorization 中实现第二阶段 scheduler，并为修改后的 package 重新做 review 与 QA-001 | 可以请求受限 production-path 代码与后续真实 RIME evidence | 仍不得无界扩展、自动改写、读取 host text，或跳过性能/QA 独立证据 |

## Recommendation

建议选择 **B**。它先补齐 runtime 特有的身份映射、调度和上限选择，避免把纯 Core 的 rank-55 事实误当作“应直接把 60/64 接到每次输入”。当 B 能提出可审查的硬上限和取消语义后，Product 才能以可逆、可测量的方式决定是否进入 C。

## Handoff target

Human Product Owner 已选择 B。后续由 [`runtime design Assignment`](../assignments/typo-correction-002-second-stage-recall-runtime-design-001.md) 承接；无论选择何项，本文件都不是 Accepted Product Decision、Authorization 或当前开发指导。
