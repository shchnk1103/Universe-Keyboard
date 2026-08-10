# TD-012-OCTAGRAM-VENDOR-G1 — Architecture Review Conclusion

**Reviewer role:** 🏛️ Architecture & Knowledge Steward（独立于 Executor）  
**Date / timezone:** `2026-08-10 Asia/Shanghai`  
**Publication under review:** PR [#63](https://github.com/shchnk1103/Universe-Keyboard/pull/63) squash-merged to `main` as `84250c5`  
**Evidence grade:** **Architecture conclusion** — 边界 / 合同 / 范围 / 残余处置判断。**不是** Quality re-run；不替代 `ensure_rime_vendor`、模拟器测试、Debug/Release build 或 release 字节 SHA 的独立复核。

**Authority inputs:**  
[`td-012-octagram-vendor-g1-review-handoff.md`](td-012-octagram-vendor-g1-review-handoff.md) ·  
[`PD-TD-012-OCTAGRAM-VENDOR-G1`](../product-decisions/TD-012-OCTAGRAM-VENDOR-G1-authorization.md) ·  
[`td-012-octagram-vendor-g1.md`](td-012-octagram-vendor-g1.md) ·  
[`rime-artifacts.md`](../architecture/rime-artifacts.md) ·  
[`shared-container-and-rime-lifecycle.md`](../architecture/shared-container-and-rime-lifecycle.md) ·  
G0 / provenance / G1 evidence（Executor-recorded）

---

## Decision

**Conditional Accept**

G1 在架构上可与 Quality 结论一并进入 `Reviewed` / close 路径。  
**不得** 仅凭本结论关闭 Assignment；**不得** 将本结论解读为 `.gram` / 模型 / 产品功能 / App Store 授权。

---

## Scope restatement

| In scope for this review | Out of scope |
|---|---|
| Vendor pin 合同、ABI 插件策略、链接保留、traits 模块表 | Quality 测试重跑与 CI 字节级 SHA 再下载证明 |
| Main App deploy / Extension session 所有权边界 | Jetsam / 真机内存预算测量 |
| 失败与回滚语义是否可操作 | 法律意见或 relicense 法律结论 |
| G1 是否引入 `.gram` / schema / UX 范围泄漏 | G2–G6 模型下载、部署、产品化 |

---

## Architecture questions（6 / 6）

### 1. Boundary — Main App deploys / Extension session-only

**Verdict: Pass**

`RimeDeployer.m` 与 `RimeSessionManager.m` 在既有 setup 路径上对称地把 `octagram` 加入 traits（`core + dict + gears + lua + octagram`），并调用同一套 `RimeOctagramModuleShim`；未新增第二套 RIME bridge、未改变 App Group 写入所有权，也未把 deploy 迁入 Extension。  
`RimeSessionManager` 仍通过 `claimRuntimeOwnership` 维护进程内单一 runtime 所有者；`initializeEngine` 仍声明部署由主 App 完成。octagram 是静态模块注册，不是部署职责转移。

### 2. ABI / recipe — 独立 static plugin + baseline 字节复用

**Verdict: Pass**

策略与 readiness plan 方案 B 及 artifact 合同一致：assemble 脚本将 baseline 11 个 framework 原样拷贝，再叠加 `librime-octagram.xcframework`；build env 固定 octagram `bfb168ca…`、librime peer `1300e568…`。  
对 G1 而言，不必整包重编 11-framework；独立 plugin + 不可变新 pin + 保留 rollback baseline 可接受且可审计。未来 librime 主库 pin 漂移须触发 recipe/manifest 再验证。

### 3. Link retention — shim + Keyboard `-force_load`（octagram + glog）

**Verdict: Pass**

链接保留完整镜像 Lua：SwiftPM binary + `RIME_HAS_OCTAGRAM`；shim 引用 `rime_require_module_octagram`；Keyboard 对 octagram 与 glog 使用 `-force_load`。主 App 未额外 force-load octagram，与既有 Lua 分工一致。  
`Packages/RimeBridge` 内未发现为本任务引入的 `@unchecked Sendable` 或并发捷径。glog 双 force-load 是扩展链接图必要副作用，体积/Jetsam 属后续测量门禁。

### 4. Failure semantics — 基础路径与 rollback

**Verdict: Conditional**

模块表始终保留 `core/dict/gears/lua`，octagram 为增量；能力测试要求 octagram 存在时 Lua 仍可注册。  
构建期缺少 pin 时 `ensure_rime_vendor` / binary target fail-closed 正确。  
运行期无“可选关闭 octagram 且仍用新 pin”的热拔插；回滚 baseline 需协调 manifest + Bridge 接线 + force-load 回退。运维语义可接受，但不得误读为运行时可选模块。

### 5. Scope leak — `.gram` / schema / 模型合同 / 产品文案

**Verdict: Pass**

G1 未新增 schema patch、下载服务、App Group 模型路径、设置项或“整句增强” UX。能力测试以空 shared/user 目录、无模型文件验证 `grammar` 组件注册。assemble 明确不打包 `*.gram`。

### 6. Provenance residual — BSD notice + 过期 GPLv3 文件头

**Verdict: Conditional（工程 pin 可接受；非法律意见）**

pin 满足 PD：octagram @ relicense merge；notice 记录 BSD-3-Clause、PR #8 与陈旧文件头。Product 已接受为 G1 工程来源基础。  
Architecture 不阻塞 G1；不构成法律意见或 App Store 合规结论。来源再变须 revalidation。

---

## Residuals（KOS 2.1 M-03）

| Residual ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `TD012-G1-A-01` | Product / 许可（PD 已接受工程基础） | `accept` | 陈旧 GPLv3 文件头；notice 保留。provenance audit；Vendor notice |
| `TD012-G1-A-02` | 🔧 RIME Platform / Artifact | `accept` | 插件 DT `15.0` vs App `26.4`；须在合同中保持显式 |
| `TD012-G1-A-03` | 🔧 RIME Platform / Keyboard link | `accept` | Keyboard 双 force-load octagram+glog |
| `TD012-G1-A-04` | 🧪 Quality → 后续 G4 | `tech_debt:TD-012` | 链接体积/Jetsam 未测；禁止用 G1 声称内存预算 |
| `TD012-G1-A-05` | 🔧 RIME Platform / Release ops | `accept` | 回滚需协调代码+pin，非热拔插 |
| `TD012-G1-A-06` | Product Lead | `tech_debt:TD-012` | 模型 G2–G6 未授权 |

无 `fix` 类阻塞残余。

---

## Explicit non-claims

Architecture **不** 声称或批准：任意 `*.gram` 可用；schema/下载/UX；Jetsam 预算；法律意见；Quality 已绿（本文件未重跑）；G1 合并即 Assignment 关闭。

Architecture **确实** 声称（在残余前提下）：G1 将 concrete `octagram`/`grammar` 模块能力以可 pin、可回滚 baseline 的 vendor 形态接入既有 RimeBridge，且未破坏 Main App deploy / Extension session 所有权模型。

---

## Summary

| Item | Value |
|---|---|
| Decision | **Conditional Accept** |
| Blocking architecture defects | **None** |
| May pair with Quality for Reviewed/Closed | **Yes** |
| May start model G2+ | **No** |

`SUMMARY_DECISION=Conditional Accept`
