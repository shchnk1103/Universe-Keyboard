# T9-RESPONSIVE-PIPELINE-001 / CANARY-001 — 会话交接说明

Date: 2026-08-05
Branch: `main`（本地已领先 `origin/main` 5 个提交，待推送/开 PR）
Handoff target: 下一个处理 CANARY-001 或 ADR 0025 评审的 agent / Human Product Lead
Product Gate owner: Human Product Owner（用户）

## Summary

CANARY-001（default-off 生产形态响应式 RIME canary）的**设备证据阶段已完整收尾**：
iPhone 13 Pro 上 A/B/K/O 四臂执行完毕、证据落盘、独立 Architecture 与 Quality 双复审
均为 **Pass with conditions**，Human Product Lead 已选择 **Stop/Retain** 处置归档。
ADR 0025 仍为 **Proposed**，dual-gate 保持 **default-off**，本会话未 claim 任何
Product Gate / Release / default-on。

## Evidence（已完成，全部提交到 main）

### 提交链（本地 `6c126b3`，领先 origin 5 个提交）

| 提交 | 内容 |
|---|---|
| `acb8ec5` | canary 实现 + DEVICE-001 证据 + 此前被 gitignore 挡住的 docs/evidence 文档 |
| `b132b1b` | 忽略 `__pycache__/` |
| `4e83404` | Dashboard / plan 记录四臂完成 |
| `4f658eb` | 独立 Arch/Quality 复审 + 残余修复 |
| `6c126b3` | CANARY-001 Stop/Retain 处置记录 |

### 关键文件

- 设备证据：`docs/evidence/t9-responsive-pipeline-canary-001-device-001-2026-08-04.md` + `…-summary-2026-08-04.json` + `…-run-header-final-2026-08-04.json`
- 独立复审：`docs/assignments/t9-responsive-pipeline-001-canary-001-architecture-review.md`（0/0/1/0）· `…-quality-review.md`（0/0/5/3，含修复收口）
- 处置记录：`docs/product-decisions/T9-RESPONSIVE-PIPELINE-001-CANARY-001-disposition.md`
- 本地隔离收据（gitignored，不提交）：`evidence/CANARY-001-DEVICE-001/raw/`（A/B post-input receipt、K/O install、operator sheet、O-binary-scan）

### 四臂结果

- **A**（sync）：stallScore 2.5，action 24/29/32 RIME 尖峰 208–229ms
- **B**（R5P provisional）：stallScore 0，同位置 RIME 242.5ms 但 UI 保持响应
- **K**（kill-switch）：`decision=kill` 断言写入读回成功；扩展 fail-closed 到 baseline；kill 后无 canary ACCEPT
- **O**（恢复）：普通 Release 装回，hash 匹配、无 canary 标记、Human smoke 正常

## 建议下一步（做什么 / 不做什么）

**做：**
- 若未来推进响应式方向，走**独立 ADR 0025 正式接受评审**（需要 Human Product Owner 新授权），以本 canary 证据 + P2-PERF-03 作为输入。
- 保留 default-off；任何开启默认 gate 的决定必须单独走 Product Gate。

**不做：**
- 不再追加设备证据阶段（Stop/Retain 已确定）。
- 不把本 canary 结果当作 ADR 0025 Accept / Product Gate / benchmark / SLO。
- 不清理 `evidence/CANARY-001-DEVICE-001/raw/`（它是本地隔离证据，供未来评审引用）。

## Risk / 开放残余

- **P2-04**：Full Access 逐臂 re-confirm 缺独立 attestation 行（过程记录缺口）。
- **P3-01**：K `decision=kill` marker 为 Human-mediated（物理设备限制）。
- **P3-02**：powerThermal 为 operator 观测，非传感器记录。
- **K/expiry 混杂**：扩展 fail-closed 到 baseline 是 kill=1 与配置过期共同作用；`phase=kill decision=kill` 断言独立于 expiry（详见 Architecture review P2-01）。
- **单对 A/B（n=1）** + Human cadence confound：方向性证据，非统计结论。

## 需人工/环境配合

- 推送与 PR：本地 5 个提交已就绪，`git push` 后创建 PR（见 `docs/AI_WORKFLOW.md` PR 规范）。
- 设备：iPhone 13 Pro 已恢复普通 Release，无需再连接。
