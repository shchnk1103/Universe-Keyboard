# Product Decision: DIAGNOSTICS-READ-RECOVERY-001 — 诊断超预算读取恢复

**Decision ID:** `PD-DIAGNOSTICS-READ-RECOVERY-001`
**Lifecycle status:** `Accepted` — 授权实现与本地验证
**Date / timezone:** `2026-08-12 Asia/Shanghai`
**Parent capability:** [`TD-013-DIAGNOSTICS-V1-P1`](../assignments/td-013-diagnostics-v1-p1.md)
**Assignment:** [`DIAGNOSTICS-READ-RECOVERY-001`](../assignments/diagnostics-read-recovery-001.md)

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Accepted` — Human Product Lead 已授权最小修复 |
| **Phase** | Executor 实现与本地 Simulator 验证已完成 |
| **Non-claims** | 不处理候选栏触摸、万象模型 G2、真机安装或 Release；不改变 ADR 0027 保留与严格排序合同 |
| **Next** | 独立 Quality reverify；本 Decision 不授予 Release 或真机结论 |
| **Residuals** | None |

---

## Decision

Human Product Lead 授权修复诊断 v1 快照超过安全读取预算后的恢复死路：页面必须保留可执行的清空入口，清空成功与失败必须可区分，提示文案不得建议当前保留策略并不能保证完成的恢复动作。

实现必须从最新 `origin/main` 建立独立 worktree，不读取、修改、暂存或提交另一个线程在万象模型 G2 分支上的未提交文件。验证限于静态检查、自动化测试与 Simulator；不连接或安装到真机。

## Non-goals

- 不修改候选栏、键盘 Extension 输入路径、RIME bridge、万象模型或设备证据。
- 不放宽 5 MiB / 10,000 事件安全读取预算，不牺牲 generation-wide 严格排序。
- 不改变 7 天 / 100 MiB retention、generation clear、App Group ownership 或隐私 allowlist 合同。
- 不把自动 retention 描述为读取超预算状态的确定恢复方式。

## Authorization source

Human Product Lead, in-session `2026-08-12 Asia/Shanghai`：明确确认可以在不影响万象模型 G2 工作的前提下修复，并指示“按照 KOS 2.1 设定继续”。该授权绑定到上述最小范围。

## Revalidation triggers

如需要改动 ADR 0027、自动删除尚未到期的用户日志、进入 Keyboard Extension 热路径、触碰 G2 文件、连接真机或扩大为候选栏修复，必须停止并重新取得 Product 授权。
