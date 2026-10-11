# 宿主激活修复 F0交付 / F1 Prepared Entry — 2026-10-04

[Assignment草案](../assignments/keyboard-wake-host-activation-fix-001.md)为Assignment Pending，只准备，不批准源码。

- 原工作树 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；branch `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a` 精确一致；staged0。
- docs写入前完整dirty 1408项，使用 `git status --porcelain=v1 --untracked-files=all`；[完整清单](keyboard-wake-host-activation-fix-001-f0-artifacts/dirty-status-before.txt)。这不是只列本任务路径，也不与旧不同粒度计数相减。
- R2原15冻结输入无漂移；五路径3existing/2absent。三existing已带历史diff，保留其全部字节，新差量单独归本任务。来源身份不凭git推定；root只确认当前本agent树没有运行writer，其他任务跨线程不可据此证明；实施前必须重核五路径及writer冲突。
- [manifest](keyboard-wake-host-activation-fix-001-f0-artifacts/entry-manifest.json)冻结输入/状态清单/三文件sha及历史diffsha；三原字节小型副本只在 `/private/tmp/ukey-host-activation-fix-entry-20261004`，不是模拟器备份或安装/恢复产物。
- R2仅设计Pass with conditions；packet哈希抄录差异另root receipt，原件保持。正式责任绑定与F1授权Pending；root exact ACK/即时身份/absence及writer核验Pending。不能称Ready。

F1待批内容：只有五文件实施、测试编写、范围内format/lint及diff/候选冻结。F2测试/build需要新环境Entry与单独授权；F3新精确review预算；F4安装/Maps另授权。本次不执行任何测试/compiler/build、simctl/LLDB或备份清理。

文档准备检查：原15输入hash一致、branch/HEAD/staged0、两新路径仍不存在；交付写入后再核链接及源/工程hash，结果见check-receipt。父Completed、旧rolloutActive不变。只是普通本地docs检查，非KOS2.2 D-01、Quality Gate或发布依据。
