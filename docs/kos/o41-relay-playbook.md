# O41 最小接力闭环候选操作手册

> 状态：独立 worktree 候选文档（`KOS-O41-IMPL-001`），**未启用**。共享环境启用需 Human 另行授权同步本机 `tools/`、角色卡与 `PM-DISPATCH-CHECKLIST.md`。

## 1. 唯一当前入口（`<任务目录>/CURRENT.json`）

每个活跃任务目录维护唯一的 `<任务目录>/CURRENT.json`（`schema: 2`），由 `scripts/kos/kos_current.py` 通过同目录排他锁文件 `.CURRENT.lock`（`fcntl.flock(LOCK_EX)`）原子更新，禁止锁外读取 `revision` 后直接 `os.replace`。

### 员工 5 步启动协议
1. 读取 `<任务目录>/CURRENT.json`（禁止遍历 `instructions/` 猜最新文件名）；
2. 核对 `role` 与本轮受领角色一致，且 `state == "READY_TO_DISPATCH"`（若为 `CLAIMED`、`UPGRADED_TO_PM` 或 `COMPLETED`，立即 `STOPPED` 报 `Jack`）；
3. 实测复算 `package_sha256`、`params_sha256`、`authorization_sha256`（任一不符立即 `STOPPED`）；
4. 调用 `kos_current.py claim`（或集成了该逻辑的 `kos-role-claim.sh`）原子推进 `READY_TO_DISPATCH → CLAIMED`，获取新 `claim_id` 与 `revision`；
5. 读取 `package_path`、`params_path`（以及非空的 `resume_from_report`）开始执行。

可用 `python3 -I -B scripts/kos/kos_current.py verify --task-dir <dir> --role <Role> [--package-path <pkg>]` 一次完成第 1–3 步核验（含过期入口检测）。

## 2. `CLAIMED` 所有权与 `--recover` 恢复边界

- **防误接管活跃员工**：只要 `state == "CLAIMED"`，任何新会话直接 `claim` 或接管均被拒绝（`STOPPED`），禁止仅凭 `IN-PROGRESS` 滚动报告接管活跃员工。
- **唯一合法恢复入口**：仅当 Human 或 PM（`Jack`）确认原会话确已停止后，由 PM 显式执行：
  `kos_current.py recover --task-dir <dir> --expect-rev <N> --updated-by Jack --resume-from-report <report_path> --recover`
  该操作在锁内将 `revision` 加 1、作废旧 `claim_id`、记录 `prev_claim` 审计信息，并将 `state` 置回 `READY_TO_DISPATCH`。
- **防旧会话复活双写**：失联旧会话复活后若尝试用旧 `claim_id` / 旧 `revision` 调用 `complete`、`upgrade` 或 `dispatch`，锁内校验必然拒绝。

## 3. 条件接力与报告校验

- 报告末尾固定节：`## 下一站接力（O41）`。
- **分支 1（正常接力）**：`DONE` / `PASS` 且无待决、包内已预置下一站授权与条件模板时，写明 `next_role`、`next_step`、下一站 `params_path` / `block_path` 及 SHA-256，并明确标注 `块已生成未派发（待 Human 通知）`。
- **分支 2（阻塞升级）**：`PARTIAL` / `BLOCKED` / `STOPPED` / `FAIL` 或存在待决/无下一站授权时，`next_role` 固定为 `Jack（PM）`，不得越过 PM 生成下一站入口。
- 使用 `python3 -I -B scripts/kos/kos-report-lint.py --require-o41 <report.md>` 校验报告结构。
