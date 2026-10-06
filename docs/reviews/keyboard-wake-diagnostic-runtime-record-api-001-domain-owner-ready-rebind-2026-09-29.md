# Domain Owner Ready Rebind: KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001

## Disposition

**ACKNOWLEDGED — Pass with conditions.** 本收据确认 Ready 是已 ACK 范围候选的
lifecycle/status 写回，不是新的范围批准、实现结果、Quality/Product Gate、Release
决定或父任务关闭。

## Exact identities

| Object | SHA-256 |
|---|---|
| Runtime Record API Assignment | `d9789daab24d64cdb2daf0e6ac86bbe547a3b9231dfeadca83875541970984e6` |
| ADR 0036 | `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c` |
| Product implementation authorization | `7f2e472552efd7c7016770f6182aafcf4c54b834222a441d62245503952643e7` |
| Fresh worktree baseline | `58fc930762e8adac11bdc78afab1c2ff63bc5038f9f013114b44732eb7cc12b0` |
| Nine-file source/test manifest | `3e7338898e88d5732d98da210d31df915bfe4b8880a9704273c96d38b6240f2c` |
| Writer-isolation recheck | `4981748919c417752daa43c71ada9dacaec71b4913f757a07f5962c33486d759` |
| Parent Assignment mirror | `862ff1a5a849c0514abccde81074f64a66d33629eba5ab8fa2fe88ca1c6a5198` |
| `ACTIVE_WORK.md` mirror | `a0c19f7453795344772ac6357f2ffb7ff214ead7f43eb8ebc0b6162f90cffb9c` |

## Domain rebind

- `Input Intelligence Maintainer` 仍是 `KeyboardCore` Runtime Record API 的唯一
  Domain Owner。
- 当前 Assignment 的 typed v4 methods、v4 construction/encoding/append、版本
  不变量、隐私边界和 bounded asynchronous ingress 与此前已 ACK 的范围一致。
- Extension callsite、v4 production enablement、Main App reader/fallback、
  RimeBridge、UI、Simulator/device、paired-build rollout 和发布操作仍是明确
  排除项。
- `Ready` 记录仅反映先前 ACK、实现授权、九文件 baseline 和 writer-isolation
  recheck 已完成；它没有把实现授权扩展为提交、发布或运行时发射授权。

## Read-only checks and conditions

- 最新 Assignment、父任务和 `ACTIVE_WORK.md` 的实际 SHA 与委派身份匹配；Assignment
  明确写明“status writeback does not change the scope”，且当前实现尚未开始。
- writer recheck 的 `lsof`、managed-worktree 和 manifest 证据与其精确 SHA 匹配。
- 当前符号核对仍显示 `schemaVersion = 3`、`isWritableV3` append guard，且只存在旧的
  `recordRimeSync`；三个 typed v4 submission methods 尚未出现。
- 实现开始前仍应重复 writer ownership 检查；两个既有 modified 测试文件继续受保护，
  新 writer coverage 必须使用隔离测试文件或明确 handoff。

本次没有修改任何源码或测试，没有运行测试、构建、Simulator、安装或运行时事件生产。
Ready rebind 不推进实现本身；后续由 Executor 在首次源码/测试编辑时将 Assignment 转为
`Active`，并继续遵守现有 stop conditions。
