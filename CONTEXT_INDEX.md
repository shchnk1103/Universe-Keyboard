# CONTEXT_INDEX.md

> **Legacy detailed registry:** 新线程的唯一默认入口是 `AGENTS.md` →
> `docs/KNOWLEDGE_INDEX.md` → `docs/READING_MAPS.md`。本文件仅用于深度查找和旧文档注册，
> 不再作为新线程入口，也不要求默认加载 `docs/PROJECT_CONTEXT.md`。

> **详细文档注册表（legacy registry）。**
> 新会话先读 `AGENTS.md` 和 `docs/KNOWLEDGE_INDEX.md`；按任务导航使用 `docs/READING_MAPS.md`。本文件保留详细文档清单，不再是默认入口。

> **新会话入口：** `AGENTS.md` → `docs/KNOWLEDGE_INDEX.md` → `docs/READING_MAPS.md`；复杂任务或多 agent 协作时再读 `docs/AI_WORKFLOW.md`。
> **文档治理：** Source of Truth、ADR、plan 归档和 review 规则统一见 `docs/DOCUMENTATION_GOVERNANCE.md`。

---

## 快速导读

| 任务类型 | 必须加载 | 可选加载 |
|----------|----------|----------|
| 新会话入口 | `AGENTS.md` + `docs/KNOWLEDGE_INDEX.md` + `docs/READING_MAPS.md` | `docs/AI_WORKFLOW.md`（复杂任务 / subagent 分工） |
| 文档新增/更新/归档 | `docs/DOCUMENTATION_GOVERNANCE.md` | 相关 Source of Truth |
| 任何代码改动 | `docs/PROJECT_CONTEXT.md` | — |
| UI 改动（SwiftUI / UIKit） | `docs/PROJECT_CONTEXT.md` + `docs/UI_STYLE_GUIDE.md` | — |
| Swift 并发 / 架构决策 | `docs/PROJECT_CONTEXT.md` + `docs/architecture/swift6-migration.md` | — |
| RIME 桥接 / xcframework 管理 | `docs/PROJECT_CONTEXT.md` + `docs/architecture/rime-artifacts.md` | — |
| RIME 多方案管理 | `docs/PROJECT_CONTEXT.md` + `docs/RIME_SCHEME_MANAGEMENT.md` | `docs/UI_STYLE_GUIDE.md`（改主 App UI 时） |
| Partial Commit / composition restore | `docs/PROJECT_CONTEXT.md` + `docs/architecture/partial-commit.md` | `docs/TYPO_BENCHMARK.md`（涉及 typo correction 时） |
| 写测试 | `docs/PROJECT_CONTEXT.md` + `.claude/skills/keyboard-test-writer/SKILL.md` + `REFERENCE.md` | `EXAMPLES.md` |
| RIME 传统模糊音 | `docs/PROJECT_CONTEXT.md` + `docs/RIME_FUZZY_PINYIN.md` | `.claude/skills/keyboard-test-writer/SKILL.md` + `REFERENCE.md`（写测试时） |
| RIME 候选学习 / 用户词典备份 | `docs/PROJECT_CONTEXT.md` + `docs/RIME_USER_DICTIONARY.md` | `docs/UI_STYLE_GUIDE.md`（改主 App UI 时） |
| RIME 跨设备同步 | `docs/PROJECT_CONTEXT.md` + `docs/RIME_SYNC.md` | `docs/APP_NOTIFICATIONS.md`（涉及同步通知时） |
| App 通知 / 全局操作提示 | `docs/APP_NOTIFICATIONS.md` + ADR 0017 | `docs/RIME_SYNC.md`（涉及同步阶段时） |
| App Group / RIME 生命周期 | `docs/architecture/shared-container-and-rime-lifecycle.md` | `docs/DEBUGGING.md` |
| 输入管线 / marked text / Return / Space / Delete | `docs/architecture/input-pipeline-and-marked-text.md` | `docs/architecture/partial-commit.md` |
| 调试复杂故障 | `docs/DEBUGGING.md` | 对应领域文档 |
| 发布验收 | `docs/RELEASE_CHECKLIST.md` | `docs/architecture/swift6-manual-acceptance.md` |
| 性能 / 内存 / jetsam 基线 | `docs/PERFORMANCE_BASELINE.md` | `docs/DEBUGGING.md` |
| 架构决策 / ADR | `docs/architecture/decisions/` | `docs/PROJECT_CONTEXT.md` |
| 已知技术债 | `docs/TECH_DEBT.md` | 相关 ADR |
| 小屏误触 typo correction | `docs/PROJECT_CONTEXT.md` + `docs/TYPO_BENCHMARK.md` | `.claude/skills/keyboard-test-writer/SKILL.md` + `REFERENCE.md`（写测试时） |
| commit / push | `.claude/skills/pre-push-review/SKILL.md` | — |
| 了解长期路线图（历史参考） | `docs/plans/ios-rime-keyboard-development-plan.md` | 已 Superseded，仅供追溯 |
| Swift 6 迁移合规审计 | `docs/architecture/swift6-manual-acceptance.md` | — |
| **调查历史决策 / Bug 上下文** | **`CHANGELOG.md`** | — |

---

## 文档清单

### 1. `docs/PROJECT_CONTEXT.md` ★ 核心上下文（代码改动必读）

| 属性 | 值 |
|------|---|
| 路径 | `/docs/PROJECT_CONTEXT.md` |
| 大小 | 动态；不作为新鲜度依据 |
| 目的 | 项目长期上下文：项目概述、架构速览、构建命令、关键设计决策、实现约束 |
| 加载时机 | 涉及代码、架构、构建、测试或实现判断时加载 |
| 强制性 | ✅ 必须 |
| 是否过时 | 🟢 低风险。历史变更日志已迁移至 `CHANGELOG.md`，核心内容为永久知识 |

**核心内容摘要：**
- Project Overview：两个 Xcode target（主 App + Keyboard Extension）
- Status And History：说明最新状态统一查 `CHANGELOG.md`，本文件只保留稳定实现约束
- Architecture：`Keyboard/`、`Universe Keyboard/`、`Packages/` 文件布局
- RIME Architecture：双路径设计（rimeEngine / fallback）
- Key Design Decisions：永久性决策（含紧凑高度警告 + visibility change 丢弃未完成 composition 规则）
- Build & Run：构建命令

**维护规则：** 禁止在 `docs/PROJECT_CONTEXT.md` 中添加 "Recent changes"、流水账或带日期的当前状态快照。所有变更与状态更新写入 `CHANGELOG.md`。`CLAUDE.md` 仅保留为兼容入口。

---

### 2. `CHANGELOG.md` — 变更历史（调查历史决策时加载）

| 属性 | 值 |
|------|---|
| 路径 | `/CHANGELOG.md` |
| 大小 | 动态；以当前文件为准 |
| 目的 | 2026-05-21 至今的所有 "Recent changes" + Key Lessons（从原 `CLAUDE.md` 迁移而来），按日期倒序 |
| 加载时机 | 调查历史决策、追溯 bug 上下文、理解某个实现为何如此选择时 |
| 强制性 | 🔷 可选 |
| 是否过时 | ⚠️ 中风险。每次迭代后须手动追加新条目，否则历史将断档 |

**维护规则：** 每次重大改动后，在 CHANGELOG.md 顶部添加 `## YYYY-MM-DD — 简要标题` 条目。不要在 `docs/PROJECT_CONTEXT.md` 维护带日期的当前状态。

---

### 3. `docs/UI_STYLE_GUIDE.md` ★ UI 约束（UI 改动必读）

| 属性 | 值 |
|------|----|
| 路径 | `docs/UI_STYLE_GUIDE.md` |
| 大小 | 动态；以当前文件为准 |
| 目的 | 键盘扩展（UIKit）与主 App（SwiftUI）的视觉规范，包括颜色、按键样式、候选栏、布局约束、无障碍检查清单 |
| 加载时机 | 涉及 `Keyboard/Views/`、`Keyboard/Controllers/`、`Universe Keyboard/Views/` 任何 UI 改动时 |
| 强制性 | ✅ 必须（UI 工作） |
| 是否过时 | 🟢 低风险。几何常量由本文档和当前源码共同校验，不在索引中复制数值 |

**核心内容摘要：**
- 键盘：`KeyVisualStyle` 枚举、语义色、makeKeyButton/applyKeyStyle、候选栏规则
- 主 App：NavigationStack/Form 结构、共享组件清单
- Review Checklist：UI 改动完成前的验证步骤

---

### 4. `docs/TYPO_BENCHMARK.md` — 模糊拼音纠错基准

| 属性 | 值 |
|------|----|
| 路径 | `docs/TYPO_BENCHMARK.md` |
| 目的 | 记录小屏键盘误触 typo correction 的代表性样例、当前覆盖、已知限制、评分原则和下一步优先级 |
| 加载时机 | 设计或修改 typo correction 规则、候选排序、纠错 UI、或相关 benchmark 测试时 |
| 强制性 | 🔶 条件必须（小屏误触 typo correction 工作） |
| 是否过时 | ⚠️ 中风险。真实误触样例出现后应持续补充 |

**核心内容摘要：**
- 当前支持：有效输入不干扰、全位置安全邻键替换、末尾重复字符删除、保守候选提升
- 当前不支持：漏字、转置、多字符纠错、非末尾辅音/元音跨类替换、部分末尾错误
- 评分原则：precision 优先，false positive 比 missed correction 更严重
- V0.4 评分与展示计划：`docs/plans/typo-correction-v0.4-scoring-and-ui-plan.md`
- V0.6-V0.9 质量闸门计划：`docs/plans/typo-correction-v0.6-v0.9-quality-gates-plan.md`

### 4b. `docs/RIME_FUZZY_PINYIN.md` — RIME 传统模糊音

| 属性 | 值 |
|------|----|
| 路径 | `docs/RIME_FUZZY_PINYIN.md` |
| 目的 | 记录传统拼音模糊音设置、RIME `speller/algebra` derive 规则、部署方式和边界 |
| 加载时机 | 设计或修改 RIME 模糊音设置、schema 后处理、部署前 YAML 生成时 |
| 强制性 | 🔶 条件必须（RIME 传统模糊音工作） |
| 是否过时 | ⚠️ 中风险。新增模糊音规则或部署策略变化后应更新 |

**核心内容摘要：**
- 当前支持：总开关 + `zh/z`、`ch/c`、`sh/s`、`n/l` 四组双向声母模糊音，默认开启
- 部署边界：主 App 保存设置并重新部署当前 active schema；Keyboard Extension 只读取编译结果
- 托管 block：只管理 `# universe:fuzzy-pinyin begin/end` 之间的规则，保留 schema 原有 algebra

### 4c. `docs/RIME_SCHEME_MANAGEMENT.md` — RIME 多方案管理

| 属性 | 值 |
|------|----|
| 路径 | `docs/RIME_SCHEME_MANAGEMENT.md` |
| 目的 | 记录 RIME 多方案设置、方案列表/详情 UI、主 App 与 Keyboard Extension 边界、未来新增开源方案规则 |
| 加载时机 | 修改 RIME 方案列表、方案详情、下载/更新/卸载、方案切换或新增开源方案时 |
| 强制性 | 🔶 条件必须（RIME 多方案管理工作） |
| 是否过时 | ⚠️ 中风险。新增方案、下载策略或设置结构变化后应更新 |

**核心内容摘要：**
- RIME 设置顶层按方案列表组织，点击进入方案详情
- 方案详情承载下载、更新、重新下载、卸载、许可证和设为当前方案等方案专属动作
- 候选数、简繁转换、部署状态等全局设置保留在 RIME 顶层页面
- Keyboard Extension 只使用已准备好的运行时数据，不在输入时下载、更新、卸载或部署方案

### 4d. `docs/RIME_USER_DICTIONARY.md` — RIME 候选学习与用户词典备份

| 属性 | 值 |
|------|----|
| 路径 | `docs/RIME_USER_DICTIONARY.md` |
| 目的 | 记录候选学习设置、用户词典备份/恢复、自动备份、主 App UI 结构和 Keyboard Extension 边界 |
| 加载时机 | 修改候选学习、用户词典、备份/恢复、自动备份、多方案候选学习 UI 时 |
| 强制性 | 🔶 条件必须（RIME 候选学习 / 用户词典工作） |
| 是否过时 | ⚠️ 中风险。新增方案、备份策略或 UI 结构变化后应更新 |

**核心内容摘要：**
- 当前只管理 `luna_pinyin` 和 `rime_ice` 的 RIME 用户词典学习记录
- 主 App 负责设置、备份、恢复、manifest 比较和自动备份；Keyboard Extension 不在输入热路径做文件扫描、hash、复制或部署
- 候选学习 UI 按方案聚合：顶层是方案列表，详情页管理该方案的学习开关、备份/恢复和重置
- 操作结果使用全局底部 toast，方案行只显示短状态和紧凑状态图标

---

### 5. `docs/architecture/swift6-migration.md` ★ 并发架构约束

| 属性 | 值 |
|------|----|
| 路径 | `docs/architecture/swift6-migration.md` |
| 大小 | 动态；以当前文件为准 |
| 目的 | Swift 6 严格并发的所有权边界定义、回归不变式、验证命令 |
| 加载时机 | 涉及 actor 隔离、并发、新 Swift Package 依赖、`Sendable` 相关改动时 |
| 强制性 | ✅ 必须（并发/架构改动） |
| 是否过时 | 🟢 低风险。迁移已完成，这是固化的架构约束文档 |

**核心内容摘要：**
- Build Contract：Swift 6 + strict concurrency，warnings-as-errors
- Ownership Boundaries：5 条边界规则表格（UI / KeyClickPlayer / RIME session / 部署 / 主 App 状态）
- RIME Consolidation：RimeBridge 是唯一生产桥接包，不允许 target 内自建
- Regression Invariants：6 条不得触犯的约束（含关键 processKey 纯净性要求）

---

### 6. `docs/architecture/partial-commit.md` — Partial Commit 架构与合并边界

| 属性 | 值 |
|------|----|
| 路径 | `docs/architecture/partial-commit.md` |
| 目的 | 记录 Partial Commit Phase 1/2/3 V1/V2 的功能矩阵、产品决策、feature flag 状态、已知边界和合并建议 |
| 加载时机 | 涉及 Partial Commit、composition restore、Delete restore、候选选择引用、或 typo correction partial commit 时 |
| 强制性 | ✅ 必须（Partial Commit 工作） |
| 是否过时 | ⚠️ 中风险。feature flag 默认值或合并策略变化后需要更新 |

**核心内容摘要：**
- Normal RIME Partial Commit、Delete Restore、Typo Partial Commit V1、Phase 3 V2 Stabilization 的当前状态
- 当前产品决策：Typo correction partial commit 的 Delete restore 暂时保留，不在本里程碑继续优化
- Feature flag 默认关闭，flag-on 路径已通过测试与真机验证但仍需单独批准才能生产开启
- 推荐合并方式：Squash Merge，建议标签 `partial-commit-v1`

---

### 7. `docs/architecture/rime-artifacts.md` — RIME 制品管理

| 属性 | 值 |
|------|----|
| 路径 | `docs/architecture/rime-artifacts.md` |
| 大小 | 动态；以当前文件为准 |
| 目的 | 11 个 xcframework 清单、版本固定方案、manifest 校验流程、发布 Checklist |
| 加载时机 | 需要更新/验证 RIME xcframework、处理 `Packages/RimeBridge/Vendor/`、或 CI 脚本改动时 |
| 强制性 | 🔶 条件必须（RIME 制品相关工作） |
| 是否过时 | ⚠️ 中风险。版本固定到 `rime-vendor-ios-1.16.1-lua.1`，升级版本时须更新 |

**核心内容摘要：**
- Required Inventory：11 个 framework 名称
- 当前 SHA-256、Release URL
- `ensure_rime_vendor.sh verify/fetch` 命令
- Publishing Checklist

---

### 7. `docs/architecture/swift6-manual-acceptance.md` — 迁移验收记录

| 属性 | 值 |
|------|----|
| 路径 | `docs/architecture/swift6-manual-acceptance.md` |
| 大小 | 动态；以当前文件为准 |
| 目的 | Swift 6 迁移的自动化证据 + 真机验收矩阵，包含历史测试记录和模板 |
| 加载时机 | 发布审查、验收门控检查、补充真机测试记录时 |
| 强制性 | 🔶 条件必须（发布准备 / 验收门控） |
| 是否过时 | ⚠️ 中风险。包含历史测试记录（2026-05-28），4 个场景仍 BLOCKED（Lua smoke test、VoiceOver、Dynamic Type、Light/Dark 截图）。未来发布前须补充 |

**注意：** 此文档是历史记录+模板，不是日常工作指南。除非执行发布验收，否则跳过。

---

### 8. `.claude/skills/keyboard-test-writer/SKILL.md` — 测试编写技能

| 属性 | 值 |
|------|----|
| 路径 | `.claude/skills/keyboard-test-writer/SKILL.md` |
| 大小 | 动态；以当前文件为准 |
| 目的 | 为 KeyboardCore 编写测试的快速入门：setUp 模式、FakeTextInputClient / FakeRimeEngine 用法、优先级工作流 |
| 加载时机 | 用户说"写测试"、"加测试"、"add tests"，或改动 `Keyboard/Controllers/`、`Packages/KeyboardCore/` 时 |
| 强制性 | 🔶 条件必须（测试工作） |
| 是否过时 | 🟢 低风险。核心模式仍有效，且已移除了会过时的测试数量硬编码 |

**配套文件（按需加载）：**
- `REFERENCE.md`：协议定义、mock 结构、所有测试文件清单 — 写测试时必读
- `EXAMPLES.md`：具体测试代码示例 — 可选，参考用

---

### 9. `.claude/skills/pre-push-review/SKILL.md` — 提交审查技能

| 属性 | 值 |
|------|----|
| 路径 | `.claude/skills/pre-push-review/SKILL.md` |
| 大小 | 动态；以当前文件为准 |
| 目的 | commit + push 前自动检查：扫描 .bak/.DS_Store、运行测试、按规范生成 commit message 并推送 |
| 加载时机 | 用户说 "push"、"ship it"、"commit and push"、"upload to GitHub" 时 |
| 强制性 | 🔶 条件必须（推送工作） |
| 是否过时 | 🟢 低风险，稳定 |

---

### 10. `docs/plans/ios-rime-keyboard-development-plan.md` — 长期路线图（已归档）

| 属性 | 值 |
|------|----|
| 路径 | `/docs/plans/ios-rime-keyboard-development-plan.md` |
| 大小 | 大型历史路线图；行数不作为新鲜度依据 |
| 目的 | 项目初期生成的完整教学级开发方案：背景、限制、技术路线、阶段规划、模块设计、滑动输入设计 |
| 加载时机 | 理解项目长期方向、规划新功能（如滑动输入 SwipeEngine）时 |
| 强制性 | 🔷 可选 |
| 是否过时 | ✅ Superseded。已归档至 `docs/plans/`，添加生命周期头，仅供历史追溯。当前架构以 `docs/PROJECT_CONTEXT.md`、`docs/architecture/`（含 ADR）及 Knowledge OS 体系为准 |

**警告：** 此文档的目录结构、模块划分与当前实际实现**存在差异**（例如文档中的 `KeyboardUI` Package 未建立，实际使用 UIKit 直接实现）。勿以此文档指导代码修改。

---

### 11. `README.md` — 项目对外说明

| 属性 | 值 |
|------|----|
| 路径 | `/README.md` |
| 大小 | 动态；以当前文件为准 |
| 目的 | 面向开发者和用户的项目说明：功能清单、架构概览、构建命令、RIME 集成状态表 |
| 加载时机 | 几乎不需要主动加载 — `docs/PROJECT_CONTEXT.md` 包含更详尽的内部视图 |
| 强制性 | 🔷 可选 |
| 是否过时 | ⚠️ 中风险。功能清单需随开发同步；测试数不得硬编码，以当前命令/CI 输出为准 |

---

## 知识层次结构

```
层级 1：必须上下文（每次必读）
├── AGENTS.md
└── docs/PROJECT_CONTEXT.md
    ├── 项目概述 + 两个 target
    ├── 状态与历史入口（最新状态见 CHANGELOG.md）
    ├── 架构文件布局
    ├── RIME 双路径架构
    ├── Key Design Decisions（20+ 条永久规则）
    └── 构建 & 测试命令

层级 2：领域约束（按任务加载）
├── docs/UI_STYLE_GUIDE.md          → UI 改动
├── docs/TYPO_BENCHMARK.md          → 模糊拼音 / typo correction
├── docs/DEBUGGING.md               → 故障分类与诊断路径
├── docs/RELEASE_CHECKLIST.md       → 发布验收
├── docs/PERFORMANCE_BASELINE.md    → 性能测量方法与待采集指标
├── docs/TECH_DEBT.md               → 未实现风险台账
├── docs/architecture/
│   ├── swift6-migration.md         → 并发/架构改动
│   ├── shared-container-and-rime-lifecycle.md → App Group / RIME 生命周期
│   ├── input-pipeline-and-marked-text.md → 输入与 marked text 契约
│   ├── decisions/                  → 已接受的架构/产品决策
│   └── rime-artifacts.md           → RIME xcframework 管理
└── .claude/skills/
    ├── keyboard-test-writer/        → 测试编写
    │   ├── SKILL.md
    │   ├── REFERENCE.md
    │   └── EXAMPLES.md
    └── pre-push-review/SKILL.md    → commit/push

层级 3：历史记录（发布/审计时加载）
└── docs/architecture/swift6-manual-acceptance.md

层级 4：背景参考（规划新功能时加载）
├── docs/plans/ios-rime-keyboard-development-plan.md
└── README.md
```

---

## 重复与冲突分析

| 信息 | 出现位置 | 结论 |
|------|----------|------|
| 架构文件布局 | `docs/PROJECT_CONTEXT.md` §Architecture + `README.md` §架构 | 内容一致，`docs/PROJECT_CONTEXT.md` 更详尽 |
| 构建命令 | `docs/PROJECT_CONTEXT.md` §Build & Run + `README.md` §构建与运行 + `swift6-migration.md` §Verification | 命令相同，三处维护成本高。主权在 `docs/PROJECT_CONTEXT.md`，其余为补充 |
| 动态测试计数 | 各地散落的旧引用已被清理 | ✅ **已解决**。文档中不再硬编码测试计数，开发时依赖 `swift test` 输出，仅在验收快照和 CHANGELOG 中保留历史基线。 |
| 几何常量 | `docs/PROJECT_CONTEXT.md` §Key Design Decisions + `UI_STYLE_GUIDE.md` §Keys + 源码 | 索引不复制数值；改动时必须三者校验 |
| RIME 部署边界规则 | `docs/PROJECT_CONTEXT.md` + `swift6-migration.md` + `swift6-manual-acceptance.md` | 一致，分别从不同角度（实现/约束/验证）描述同一规则 |
| 目录结构规划 | `docs/plans/ios-rime-keyboard-development-plan.md` + `docs/PROJECT_CONTEXT.md` | ✅ 开发计划已归档为历史参考。以 `docs/PROJECT_CONTEXT.md` 为准 |

---

## 缺失上下文评估

下表仅说明定位入口，不代表文档已经完整：

| 信息类型 | 覆盖文档 | 结论 |
|----------|----------|------|
| 项目背景与目标 | `docs/PROJECT_CONTEXT.md` §Project Overview | ✅ 已覆盖 |
| 架构设计 | `docs/PROJECT_CONTEXT.md` §Architecture | ✅ 已覆盖 |
| UI 规范 | `docs/UI_STYLE_GUIDE.md` | ✅ 已覆盖 |
| 并发规则 | `docs/architecture/swift6-migration.md` | ✅ 已覆盖 |
| AI 工作规则 | `AGENTS.md` + `docs/AI_WORKFLOW.md` + 各 skill | ✅ 已覆盖 |
| 调试入口 | `docs/DEBUGGING.md` + `CHANGELOG.md` | ⚠️ 有最小路径；数值化性能/内存基线仍待补充 |

注：历史变更记录存放于 `CHANGELOG.md`。已完成的 plan 只用于追溯，不得覆盖当前架构文档和源码事实。

---

## 使用规则（for AI Agents）

1. **不要扫描整个 codebase** 来理解项目。从 `AGENTS.md`、`docs/KNOWLEDGE_INDEX.md` 和 `docs/READING_MAPS.md` 开始；仅在任务路由需要时查阅本注册表或 `docs/PROJECT_CONTEXT.md`。
2. **不要同时加载所有文档**。按任务类型参考快速导读表，按需加载。
3. **`docs/plans/ios-rime-keyboard-development-plan.md` 是历史参考**。已归档并标记 Superseded，以 `docs/PROJECT_CONTEXT.md`、`docs/architecture/`（含 ADR）及 Knowledge OS 体系为准。
4. **测试计数会变化**。不要假设文档中的任何数字都是最新的。当需要准确数字时，应从 CI 或当前测试套件中获取。
5. **修改 UI 前必须读 `UI_STYLE_GUIDE.md`**。不得绕过，不得自行发明样式。
6. **修改并发隔离前必须读 `swift6-migration.md`**。`@unchecked Sendable` 和 unsafe isolation 是被明确禁止的。
7. **push 前必须走 `pre-push-review` skill**。测试必须 0 failures，`.bak`/`.DS_Store` 必须清理。
8. **RIME 部署边界是红线**：`processKey()` 和 keyboard extension 不得执行 full deployment，这是架构约束，不是建议。
