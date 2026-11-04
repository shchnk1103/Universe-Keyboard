# Assignment: SWITCH-RESOLVER-001 — 方案开关按名称与含义识别

Policy version: 1.0.0
record_id: SWITCH-RESOLVER-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active（代码与测试已在本地分支完成，待发布） |
| Current phase | 第 4 步 R5：标准同步下朙月保持简繁键、删除旧重载、补本 Assignment 与 CHANGELOG；本地提交，待独立窄复核 |
| Material non-claims | 不含 push、PR 或 merge；不代表 Human 真机验收、托管 CI 或 Release 通过；万象九宫格（`wanxiang_t9i`）未接入；雾凇九宫格 `t9` 不写开关键；真实引擎证据只限隔离资源 |
| Next handoff / decision | 独立窄复核 R5；Human 决定发布与合并；合并后 Human 真机验收 |
| Residuals | 最终复核 FR-04（设计 F4 的入口场景测试未齐）、FR-05（真机未做）记为后续项，见外置任务目录 `~/.kos-work/Universe-Keyboard/SWITCH-RESOLVER-001/reports/final-review.md` |

---

## Authority

- **Task ID / Title:** SWITCH-RESOLVER-001 — 方案开关按名称与含义识别（取代固定序号写法）
- **Assignment Authority:** Product Lead
- **Decision Source / Date:**
  - Human 2026-10-29（Asia/Shanghai）选“A”：按名字与含义识别开关，找不到或不唯一则不写并记日志；可复用于第三方方案与后续功能。同日第 2 轮设计复核后 Human 选“A”定稿；同日决定万象家族表情候选开启。出处：外置任务目录 `~/.kos-work/Universe-Keyboard/SWITCH-RESOLVER-001/design/design-final.md`。
  - PM 2026-11-01 在 Human 批准的“阶段内由 PM 调整做法”下作出实施说明三项决定：同一目录 `design/spec-decisions.md`。
  - 责任表：同一目录 `inputs/assignment-decision.md`（SHA-256 `bc933b6060c32e25f31e9cc23f017ed159c1319d79b959a3d4c652757611cee7`）第 2 节。Human 在派发第 4 步 R5 任务包的授权消息中逐字确认“按 assignment-decision.md 第 2 节确认 SWITCH-RESOLVER-001 责任分配”，并点名任务包 SHA-256；授权回执为同一目录 `reports/human-authorization-r5-issued.md`（SHA-256 `ee9bfed498e189a9cbe02c82b01d538499c73b1ca4391b8e0dca43d7dc4abf81`）。
- **Product Approver:** Human Product Owner（Product Lead）

## Boundary

- **Scope:** KeyboardCore 封闭开关识别器；朙月、雾凇、万象 overlay 生成接入；测试；标准同步下朙月保持原行为；删除静默忽略简繁参数的旧重载。
- **Non-goals:** `wanxiang_t9i` 接入（万象九宫格阶段 4）；雾凇九宫格 `t9` 开关键（包含展开，后续任务）；custom YAML 回执、第三方方案导入界面、运行时切换开关的新 UI；`docs/PORTFOLIO.md` 修改。
- **Required Inputs:** 外置任务目录 `design/`、`instructions/`、`inputs/` 中的设计定稿、PM 决定与各轮冻结任务包；基线提交 `1ecd9933f83b967fafb27bec8b3a24a498d62bb2`。

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor:** 各轮任务包指定的 Executor 会话（第 4 步 R1–R5、第 5 步）；不得同时担任同一轮的预检或复核。
- **Environment Executor:** Executor，本机构建与 `B34-iPhone17Pro-26.5` 模拟器测试。
- **Human Dependency:** Human：授权派发、合并 PR、真机验收（繁体在雾凇 / 万象生效、标点正常、表情候选出现）。
- **Architecture Reviewer:** Architecture & Knowledge Steward，独立会话（设计复核两轮、最终复核）。
- **Quality Reviewer:** Quality, Performance & Release Maintainer，独立会话（与最终复核合并；R5 窄复核）。

## Gates

- **Entry Criteria:** 设计定稿；冻结任务包与授权回执哈希核对；隔离 worktree 位于基线。
- **Exit Criteria:** 代码与测试本地提交；RimeBridgeTests、App + Keyboard 全量与 Release 构建在最终提交上通过；独立复核通过；Human 合并。
- **Stop Conditions:** 各轮任务包的停止条件，包括写入被拒、测试被削弱、改动超出白名单、身份不符。
- **Handoff Target:** 发布 Executor：分支 `feature/switch-resolver-001` 最终 HEAD 与树、外置报告、测试日志与未决项。
- **Revalidation Trigger:** 设计、范围、基线、授权或必需证据发生变化；万象九宫格阶段 4 接入本识别器时。

---

## History

| Date | Event |
|---|---|
| 2026-10-29 | 设计定稿（两轮独立 Architecture 复核，Human 选“A”） |
| 2026-11-01 | PM 实施说明决定；第 3 步识别器提交 `e4e91d8` |
| 2026-11-02 | 第 4 步 R1 生成器接入提交 `1dbe2fe` |
| 2026-11-04 | 第 4 步 R2 补跑；第 5 步真实引擎矩阵；R3 修正主 App 编译（`92929e4`）；R4 改写朙月闭包测试（`717b0f7`）；最终独立复核 Pass with conditions |
| 2026-11-04 | 第 4 步 R5：本 Assignment 与 CHANGELOG |
