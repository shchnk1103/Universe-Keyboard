# TD-012：iOS octagram Vendor 准备计划

> **Status:** Active — 当前只允许 G1 准备与证据收集；尚未授权 artifact 构建、模型下载、运行时接入或用户可见功能。
>
> **Current source of truth:** [`TD-012`](../TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration) 记录风险与触发条件；[`RIME-SCHEME-WANXIANG-001`](../assignments/rime-scheme-wanxiang-001.md) 仍是唯一 Active Assignment；本计划不改变其 `G0 No-Go` 状态。
>
> **Closure rule:** 若 G1 的许可证/来源或可复现 artifact 门槛未通过，本计划标记为 `Abandoned`，并保留 TD-012；只有新 Assignment 与 Architecture/Product Gate 才能让 G2 及以后阶段开始。

## 1. 目的与边界

TD-012 的 G0 已证明当前 `rime-vendor-ios-1.16.1-lua.1` 不含 octagram，因而不能把
`*.gram` 作为可用能力。本计划把下一步拆成可验证的依赖链，而不是把“有一个 grammar
接口”误当成“iOS 能加载模型”。

本计划的产出是一个是否值得开启 G1 的可审计决定包；不是新的 RIME 功能。

### 允许的准备工作

- 固定并审查候选 octagram 源码、librime ABI 对应关系、许可证与来源证据。
- 设计可复现的 iOS vendor 构建清单、slice、链接、模块注册和自动化验证要求。
- 制定 G1/G2 分界、失败语义、质量和设备门槛。

### 明确禁止

- 下载、打包、部署或宣传任何 `.gram` 模型。
- 修改 `Packages/RimeBridge`、Xcode 链接设置、RIME traits 或 schema。
- 将现有未固定版本的旧构建脚本当作 artifact 供应链。
- 将上游仓库的许可证元数据当成法律结论，或把技术测试当成产品/法律批准。

## 2. 已验证的起点

| 事实 | 证据 | 影响 |
|---|---|---|
| 当前 pin 没有 octagram | [G0 artifact audit](../evidence/td-012-g0-octagram-artifact-audit-2026-08-09.md) | G1 不能复用当前 11-framework vendor。 |
| Lua 插件需同时保留静态对象并运行时载入模块 | `RimeLuaModuleShim.mm`、Xcode `-force_load`、`RimeSessionManager.m` | octagram 也必须有对应的链接与注册证据。 |
| 仓库旧构建脚本含手动/待实现步骤，且下载未固定上游 HEAD | `Packages/RimeBridge/scripts/` | 不能满足可复现和审计要求。 |
| upstream 将 octagram 作为单独 librime 插件 | [librime-octagram](https://github.com/lotem/librime-octagram) | 需与 pinned librime 版本/ABI 一起构建和验证。 |
| 上游 relicense 有公开同意记录，但文件头未同步 | [许可证与来源审计](../evidence/td-012-octagram-license-provenance-audit-2026-08-09.md) | G1 source 必须 pin 在 relicense merge 之后；项目仍须明确其分发阈值与 notice。 |

## 3. 第一性原理：能力链

用户看到“整句增强可用”之前，以下每一环都必须成立：

```text
固定来源与许可
  -> 同 ABI 的 iOS 静态 artifact（device + simulator）
  -> 链接器保留 octagram 注册对象
  -> traits 加载 octagram 模块
  -> registry 发现 grammar component
  -> 经主 App 部署的、已校验的 .gram
  -> Extension session 读取并在预算内完成候选
```

任一环失败时，产品语义必须是“整句增强不可用”，而不是下载成功、更不是基础方案损坏。
G1 只覆盖前四环；模型文件和用户可见设置属于后续的 G2–G6。

## 4. G1 候选方案与当前建议

| 方案 | 描述 | 当前判断 |
|---|---|---|
| A. 保持 No-Go | 不引入 octagram，TD-012 保留为债务 | 合法/供应链门槛不能清晰通过时的唯一正确路径。 |
| B. 新建可复现 vendor | 以与当前 librime 相同的确定版本构建 octagram 静态 plugin，作为新版本、哈希固定的 iOS artifact 发布 | **唯一可继续评估的技术路径**；未获准实施。 |
| C. 仅落盘 `.gram` | 保持现有 vendor，下载模型并改 schema | 不可行；缺少 concrete module，禁止采用。 |

方案 B 不是“升级一个 framework 名称”：它会改变二进制供应链、静态链接边界与 RIME 模块表，
因此在实现前需要新的 Architecture/Product Gate；若选择它，新的 artifact 必须有独立版本与
不可变 SHA-256，不能覆盖当前发布物。

## 5. 进入 G1 前的必备决定与输入

新的 Assignment 需要显式列出下列条目；任一项为 `UNKNOWN` 即不得进入 `Ready`：

1. **Product scope：** G1 仅创建和验证 vendor 能力，还是同时允许 G2 的模型下载；默认必须是前者。
2. **许可证与来源负责人：** 审核 [公开 relicense 记录](../evidence/td-012-octagram-license-provenance-audit-2026-08-09.md)，并对仍未同步的文件头作出本项目的书面分发/notice 结论；不能由 Executor 代替。
3. **构建来源：** `librime`、octagram、每个依赖的精确 commit/tag、获取校验和、补丁（若有）。
4. **构建环境：** 固定 Xcode/SDK、CMake/toolchain 版本与 device/simulator slice 规则；不接受“当前 GitHub HEAD”。
5. **架构合同：** 保持“主 App 部署、Extension 只创建 session”的既有边界；确认静态模块注册不会引入第二套 bridge 或跨线程调用。
6. **质量合同：** 指定独立 Architecture Reviewer、Quality Reviewer，以及在无 `.gram` 的 G1 中能证明什么、不能证明什么。

## 6. G1 技术验收合同（获得授权后）

| 类别 | 必须通过的证据 |
|---|---|
| Artifact provenance | 新 release asset、清单 URL、SHA-256、receipt、完整 device `arm64` 与 simulator slices；旧 pin 保持可恢复。 |
| ABI / 链接 | octagram 与同一 librime revision 构建；静态 archive 含 `rime_require_module_octagram`；最终 App/Extension 链接有明确 force-load 保留路径。 |
| 模块注册 | 受控 shim/测试在不读取用户文本的条件下证明 module group 加载后 registry 可发现 `grammar` component。 |
| 回归 | `ensure_rime_vendor`、RimeBridgeTests、App/Keyboard strict Swift 6 测试、Debug/Release build 全部通过。 |
| 失败语义 | artifact 或模块不可用时，基础输入与既有 Lua 路径保持可用；不创建、下载或引用模型文件。 |
| 独立结论 | Architecture 与 Quality 分别审查；Executor-recorded 结果不得替代两者。 |

G1 即便全部通过，也只证明引擎 **具备**读取 grammar 的能力；它不证明 LMDG 模型质量、磁盘
策略、内存/Jetsam、长句收益或用户体验。那些必须在单独获准的 G2–G6 中测量。

## 7. 后续阶段的硬门槛

| 阶段 | 额外授权与证据 |
|---|---|
| G2 资产 pin / 下载 | 单独 Product 授权模型来源、许可证、不可变 hash、准确 size、磁盘空间和取消/失败体验。 |
| G3 schema | 仅主 App 写入/部署；精确 `grammar.language` 与 pinned 文件 stem 对应；不自动改动其他 scheme。 |
| G4 性能与安全 | 真机 cold start、长 composition、内存和 Jetsam 证据；没有预算和设备结论不得默认开启。 |
| G5/G6 产品化 | 安装、卸载、共享资源引用、设置状态和 copy；缺失模型不能伪装为方案安装失败。 |

## 8. 停止条件与交接

立即停止并把计划标记为 `Abandoned`，如果：

- 许可证/来源结论不能以项目可接受的方式书面固定；
- 无法建立不依赖浮动 upstream 的构建输入；
- 无法在不破坏现有 App/Extension 和 Lua 链路的前提下完成 module/ABI 证明；
- 评审认为 binary、内存或维护成本不值得 G2 继续投入。

若以上条件均满足，交接给 Product Lead 创建 **一个替换或续接现有 TD-012 阶段的完整
Assignment**；Active Work 达到上限时，应先由 Product 选择关闭/替换哪一项，而不是绕过
M-05 新增第 11 项。

## 9. 文档影响

本计划不改变当前 runtime、用户数据、Extension 生命周期、release artifact 或产品能力。
因此不需要 `CHANGELOG.md`、ADR 或 `DEBUGGING.md` 更新；真正改变 artifact 或 runtime 时，
必须复核 `rime-artifacts.md`、RIME 生命周期、Release Checklist、TECH_DEBT 和相应 ADR。
