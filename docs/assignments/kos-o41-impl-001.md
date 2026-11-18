# Assignment: KOS-O41-IMPL-001 — O41 最小接力闭环候选实施

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` — 独立 worktree 候选实施中（非 Ready 合并、非已启用规则） |
| **Phase** | Implementation & Isolated Verification（`task/kos-o41-impl-001`） |
| **Non-claims** | 仅独立 worktree 与任务 `scratch/` 候选产出；未提交、未推送、未合并、未启用共享规则，不代表 Quality / Product 验收通过 |
| **Next** | 完成自检后待 Human 手动派发适用独立验证（先 `Preflight`（`Pete`），再 `Quality Reviewer`（`Quinn`），忙则排队） |
| **Residuals** | None |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:**
  - `KOS-O41-IMPL-001/instructions/authorization-source-r1.md`（SHA-256 `52da13254e52d3701c7a2595e7ff6cd5f744ffc8e5ebfd9f41842534072aad62`，2026-11-16 Asia/Shanghai；其中 16:11:34 原话为 Human 转述，原始逐字记录未证）
  - `KOS-O41-IMPL-001/reports/human-authorization-impl-r1-issued.md`（2026-11-16T16:25:19+08:00 Human 明确派发授权全文）
  - `KOS-O41-IMPL-001/instructions/task-package-impl-r2.md`（SHA-256 `29b9db4fb91f937a170badffbc20453fe539296a41d4d27e0a069eca0c850604`）
  - `KOS-O41-IMPL-001/reports/preflight-impl.md`（SHA-256 `ed09a39ed90fe98528e4c3600066143c7a240af9adc212097130d4c6a51653a5`，`PASS`）
- **Product Approver:** Product Lead

## Boundary

- **Scope:** 在干净固定基线 `1bf02b55764b4333a95a851250e12e5d0afea5e2` 创建的独立 worktree（`/Users/doubleshy0n/.kos-work/Universe-Keyboard/KOS-O41-IMPL-001/worktree`，分支 `task/kos-o41-impl-001`）内，按已通过的 `design-o41.md` + `design-o41-r2.md`（`architecture-review-design-r3.md` `PASS`）实施 O41 最小接力闭环候选：`scripts/kos/` 脚本/规格/测试、`docs/kos/` 对应公共条款与手册候选、`docs/assignments/kos-o41-impl-001.md` 与必要索引链接；将本机 forwarder、角色卡、PM 检查清单迁移内容写入任务 `scratch/candidates/`；在任务 `scratch/` 隔离根运行完整套件与四情形脱敏回放。
- **Non-goals:** 不提交、不推送、不开 PR、不合并；不运行 `xcodebuild`/`swift test`、不启动模拟器或操作真机；不修改现有 `KEY-ROLLOVER` 工作树、共享脚本、角色卡、`QUEUE`、`PRIORITY`、`PM-STATE` 或真实 `CURRENT`；不启用新规则；不抢占 `Pete`/`Quinn`；不扩大为 `KOS-TOOLS-008` 全量；不自动发送消息。
- **Required Inputs:**
  - `KOS-O41-DESIGN-001/reports/design-o41.md`（`682f017506ec6ece1b187b05aed08c409c3821941a547c4c13cf45a5f6900001`）
  - `KOS-O41-DESIGN-001/reports/design-o41-r2.md`（`a1b4546cbcc7f590193693a03a8ee5533559db319d8939921c614345622b7c57`）
  - `KOS-O41-DESIGN-001/reports/architecture-review-design-r3.md`（`d8f4f9179750cdd7b6ccaeda334d07c927536edb733719aa40de3f9f583be491`）
  - `AGENTS.md`（`ab9902c0cd7e04346f24db2c743e0296655373a089b67e8cbcd1edb2dbebbf4e`）
  - `docs/ASSIGNMENT_POLICY.md`（`8b0bcb4fd9e5b8c960ccdaaabe17948fc7a917684f16791d1385a22899ec4234`）
  - `KOS-O41-IMPL-001/instructions/authorization-source-r1.md`（`52da13254e52d3701c7a2595e7ff6cd5f744ffc8e5ebfd9f41842534072aad62`）
  - `KOS-PROCESS-TIERS-001/inputs/human-decision-20261106.md`（`a7b1fa9ba59bba7f1f6146fe2bf43e3cbdfe0a84584b72cabb9c74bccb097db7`）

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward（Knowledge OS 与 `docs/kos/` 单一长期所有者，见 `docs/VIRTUAL_ENGINEERING_TEAM.md`）
- **Executor:** Executor（`Lucy`）
- **Environment Executor:** Not Applicable — 本任务仅在独立 worktree 与任务 `scratch/` 隔离根执行 Python/Shell 候选与非设备测试，不涉及真机、iOS 模拟器、签名构建或外部发布环境。
- **Human Dependency:** Product Lead（Human）— 负责手动派发下一站验证及后续决定是否提交、合并或启用新规则。
- **Architecture Reviewer:** Architecture Reviewer（`Alex`；已完成设计阶段复核 `architecture-review-design-r3.md` `PASS`，若发生架构边界变更则需重新复核）
- **Quality Reviewer:** Quality Reviewer（`Quinn`；与 `Preflight`（`Pete`）按“先 Pete 核对候选范围/证据/可执行性，再 Quinn 复核行为与测试证据”顺序独立验证，忙则排队）

## Gates

- **Entry Criteria:** 角色已领取；全部冻结输入 SHA-256 实测一致；主检出 `main` 干净且 `HEAD = 1bf02b55764b4333a95a851250e12e5d0afea5e2`；独立 worktree 与分支 `task/kos-o41-impl-001` 初始不存在；独立预检 `preflight-impl.md` 为 `PASS`；Human 派发授权已落盘；Assignment 必需字段无 `UNKNOWN`。
- **Exit Criteria:** 独立 worktree 内 O41 最小闭环候选脚本、规格、文档与测试完成；`scratch/candidates/` 本机迁移候选清单与 SHA 完整；隔离夹具完整套件与四情形脱敏回放全部实跑通过；差异空白与语法/静态检查通过；滚动报告定稿并通过 `kos-report-lint.py`；候选清单与完整 SHA 固定。
- **Stop Conditions:** 冻结输入或固定基线不符；写入被拒或路径越界；Assignment 必需字段为 `UNKNOWN` 或权责冲突；必需测试或静态检查失败；需要扩大范围至 `KOS-TOOLS-008` 全量或修改共享脚本/真实 `CURRENT`。

## Handoff

- **Handoff Target:** 正常 `DONE` 交适用独立只读验证（先 `Preflight`（`Pete`），再 `Quality Reviewer`（`Quinn`），忙则排队，待 Human 手动派发）；任何失败、产品/权限/Assignment/基线缺口交 `Jack（PM）`。
- **Required Handoff Content:** 滚动报告路径与实测 SHA-256、独立 worktree 路径与候选文件清单（含完整 SHA-256）、`scratch/candidates/` 迁移清单及启用前提、隔离测试与夹具回放日志路径及退出码、未运行项与未启用声明。
- **Revalidation Trigger:** 范围扩大至 `KOS-TOOLS-008` 全量；基线 `BASE` 变更；设计 `design-o41.md` / `design-o41-r2.md` 修订；需要修改共享脚本或启用新规则；任一责任角色或授权边界变更。

## History

- 2026-11-16T16:25+08:00：按 `task-package-impl-r2.md` 核对 Assignment 前置字段完整无 `UNKNOWN`，在独立 worktree 建立本记录（未提交候选）。
