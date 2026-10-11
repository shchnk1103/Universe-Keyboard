# 键盘唤醒 /private/tmp 备份清理 — 2026-10-06

Human 授权按精确绝对路径处理 KEEP/DELETE，并默认「先前创建的备份都可以删」；只有给得出无法拒绝的保留理由才 KEEP。范围仅 `/private/tmp` 下 `ukey-` / `uk-wake-` / `archive-ukey-` / `prepare-ukey-`。不碰 `universe-keyboard-*`（TYPO 等其他任务 scratch）、不碰 CoreSimulator 容器、不碰 worktree。

三件键盘唤醒 Assignment 均已有界 Completed。容器 before/after 不再承担未完成恢复义务。

## KEEP（1）→ 已入库后删除 tmp

原 KEEP：`/private/tmp/ukey-host-activation-fix-owner-export-20261006`。Human 随后授权拷进 `docs/evidence` 再删 tmp。

归档：[owner-export-e1-originals](keyboard-wake-host-activation-fix-001-owner-export-e1-originals/)；[入库记录](keyboard-wake-host-activation-fix-001-owner-export-e1-originals-ingest-2026-10-06.md)。`owner-buffer.bin` SHA-256 `a8b3bde10c0c489e92b1e7f370e257d33c4156f805697af1597fe5d5fd35414d` 在归档中复核通过。冻结 Quality packet 不改写，历史 tmp 路径改为读本归档。

其余「以后也许要恢复模拟器」「DerivedData 很大所以先留着」「xcresult 方便重审」都拒绝：任务已有界完成，残项已接受，矩阵/审查不再授权重跑，候选可从源码重建。

## DELETE

精确 183 条见 [keep-delete-plan.json](keyboard-wake-backup-cleanup-2026-10-06-artifacts/keep-delete-plan.json)。合计约 11822.55 MiB。类别包括：

- 容器恢复备份：F4-before、F2 backup/restore/after-preservation、actor-retest、A2 backup/restore、M0/M2R1/M2R2、I0/I1、FreshBaselineBackup、T/Keychain 残余父目录
- 候选 DerivedData / xcresult 跑树：F2-run、A2-validation-run、F4-P build、C7b/C7b3、probe-ui-candidate、T1-execution 等
- 主机预检脚本与小 scratch

T0/keychain/T1 的 backup 子目录历史已 ABSENT，不重建。本轮删除的是仍存在的父目录与其余 ukey scratch。

## 执行结果

183/183 删除成功，14.7 秒，失败 0。KEEP 目录仍在，`owner-buffer.bin` SHA-256 仍为 `a8b3bde10c0c489e92b1e7f370e257d33c4156f805697af1597fe5d5fd35414d`（1496 bytes）。清理后 in-scope 仅剩 KEEP 这一条。逐条回执：[delete-result.json](keyboard-wake-backup-cleanup-2026-10-06-artifacts/delete-result.json)。

未删除 `universe-keyboard-*`、CoreSimulator、worktree。HEAD `84b9c192…` staged 0，五源码未改。无 Git/Release。

## KEEP 入库后再删 tmp — 2026-10-06

67 个常规文件已拷入 `docs/evidence/keyboard-wake-host-activation-fix-001-owner-export-e1-originals/`，packet 绑定原件与 `owner-buffer.bin` SHA 复算通过后删除 tmp KEEP 目录。FIFO `e1-lldb.cmd` 未拷。详见[入库记录](keyboard-wake-host-activation-fix-001-owner-export-e1-originals-ingest-2026-10-06.md)。

## 执行边界

无源码、构建、测试、模拟器、LLDB、Git、Release。删除不可回滚。E1 原件以 `docs/evidence` 归档为准。
