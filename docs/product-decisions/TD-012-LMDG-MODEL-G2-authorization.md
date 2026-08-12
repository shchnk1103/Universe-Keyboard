# Product Decision: TD-012-LMDG-MODEL-G2 — 万象 LMDG 模型资产固定与真机可行性门

**Decision ID:** `PD-TD-012-LMDG-MODEL-G2`
**Lifecycle status:** `Recorded` — 授权 G2-A 资产固定；G2-B 仅在资产验证通过后进入人工真机门
**Date / timezone:** `2026-08-11 Asia/Shanghai`
**Parent debt:** [`TD-012`](../TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration)
**Assignment:** [`TD-012-LMDG-MODEL-G2`](../assignments/td-012-lmdg-model-g2.md)

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Recorded` — G2 Assignment `Active` |
| **Phase** | G2-A **Pass**；G2-B Executor evidence complete，Stop/Hold pending review |
| **Non-claims** | 不授权产品安装器、App Group 持久化、schema/UI、默认开启、雾凇/九键或发布能力 |
| **Next** | 独立 Architecture/Quality 复核退出信号；Product Lead 决定 Go/Hold/No-Go |
| **Residuals** | `0xdead10cc` 切换退出信号、跨设备/长时预算、资源解析与部署/卸载合同仍开放 |

---

## Decision

Product 授权一个不进入产品路径的 G2 可行性工作项，目的是回答两个顺序问题：

1. **G2-A：资产是否可被可复现地固定？**
   - 候选仅限上游 `amzxyz/RIME-LMDG` 的简体
     `wanxiang-lts-zh-hans.gram`。
   - 记录 Release/asset 身份、准确字节数、来源摘要、许可证与 attribution；
     将模型下载到仓库外的隔离临时目录，并重新计算 SHA-256。
   - `LTS` 名称不构成 pin；只有本地字节摘要与记录的候选摘要一致才可继续。
2. **G2-B：固定资产在 iOS Keyboard Extension 上是否值得继续？**
   - 先采集无模型基线，再由 Human Device Operator 按书面步骤完成受控真机准备与输入。
   - 采集 Extension 冷启动、长 composition、resident memory 与 Jetsam 分类证据。
   - G2-B 只交付测量和 Go/No-Go 建议；不建立用户可见能力。

## Boundary

### Authorized

- 仓库治理文档、非 shipping 的资产 pin/receipt 和验证命令。
- 仓库外临时目录中的一次候选资产下载与摘要计算。
- G2-A 通过后，制定并停在需要 Human Device Operator 的真机步骤。
- 不含用户文本的模块、文件存在性、内存与生命周期观测。

### Not authorized

- 把 `.gram` 提交到 Git、打进 App、上传为项目 Release，或长期留在 App Group。
- 实现 catalog/设置 UI、自动下载、自动启用、卸载或失败恢复产品流程。
- 修改 `wanxiang`、`rime_ice`、`t9` schema，或宣称长句质量已经改善。
- 改变“主 App 部署、Keyboard Extension session-only”的既有边界。
- 将 Executor 证据当作 Architecture、Quality、Product 或 App Store 结论。

## Product Freezes

- **方案范围：** G2 只评估万象全拼 `wanxiang` + 简体模型；雾凇、朙月、九键和繁体均不在范围。
- **分发范围：** G2 不发布、不镜像、不 bundling；未来分发需要新的 Product/Architecture 决定。
- **失败语义：** 模型缺失、摘要不符或测量失败不得影响万象基础方案，直接保持“语法模型不可用”。
- **预算语义：** 本阶段不发明内存阈值。先记录同设备 A/B 与 Jetsam 事实，再由 Product 决定是否值得进入 G3+。

## Authorization Source

Human Product Lead，当前会话 `2026-08-11 Asia/Shanghai`：

- 确认上一文档修复 PR 已合并；
- 授权继续此前提出的 G2 最小范围；
- 要求需要人工操作时停止并提供步骤；
- 要求保持范围收敛，不扩展到无关产品化工作。

## Revalidation Triggers

- 上游 asset ID、字节数、摘要、许可证或 attribution 来源改变；
- 需要把模型写入 App Group、Git、项目 Release 或 shipping bundle；
- 需要修改 schema、部署边界、设置 UI、其他输入方案或布局；
- G2-A 摘要不匹配，或 G2-B 出现 crash/Jetsam/基础输入回归；
- Human Device Operator、Architecture Reviewer 或 Quality Reviewer 不可用。
