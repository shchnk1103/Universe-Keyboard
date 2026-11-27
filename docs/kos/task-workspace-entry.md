# Task Workspace 入口（UK-007，opt-in）

本文件从 `AGENTS.md`「工作入口」下沉。绑定红线仍以 `AGENTS.md` 为准：只对明确 opt-in 的新任务生效；无法判断阶段调整是否属于已授权的非实质性细节时，停止并请求 Human。

**Task Workspace（opt-in，UK-007）**：只对 Assignment 明确写明采用 `ops/task-workspace.md`（Kit commit `9ca6dc015bf01084150538aac65cedc25b2a33a5`，见 [UPGRADE_STATUS.md](UPGRADE_STATUS.md)）的新任务生效；现有 Active 任务、Codex 任务与 Worktree 不迁移、不修改。拿到 Task ID 时：

1. 在 `docs/assignments/` 按 `record_id` 定位 Assignment（找不到再按 Task ID 搜 PR 与远端分支）。
2. 定位 carrier 分支。
3. fetch 后读该分支 head 上的 `docs/tasks/<TASK-ID>/BRIEF.md`、`log.md`，以及 AUTH、Plan 和 `read_on_demand` 指向的必要证据。
4. 确认当前阶段、Checkpoint 与剩余工作。
5. 先按合同第四、八节核对 Writer，再动手：若无待接收 `P`，且从 `log.md` 推出的 `W` 是本 Agent、授权有效，可以继续写任务；若待接收 `P` 指向本 Agent，且第八节核对满足接收条件（共同前置条件成立并命中第 3 行，含 `H == S`），只可提交并推送 `ACCEPT`，`ACCEPT` 推送成功后才取得任务代码和其他授权路径的写权；镜像与 log 冲突、状态未知或不满足接收条件，必须停止，不得推测权限；Human 署名的异常接管仍按合同第四节执行，本条不扩大其权限。
6. 在有效授权内继续。
7. 重要进度变化时写 Checkpoint。

无法访问仓库或 GitHub 的 Agent 须明确请求所需资料，或由 Human 中转。无法判断阶段调整是否属于已授权的非实质性细节时，停止并请求 Human。本入口不绑定模型、客户端或厂商，也不是完全自动化的跨平台接管或排他锁。
