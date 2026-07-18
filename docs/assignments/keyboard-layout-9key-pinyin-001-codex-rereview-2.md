# KEYBOARD-LAYOUT-9KEY-PINYIN-001 Codex 第二次独立复审

- 复审日期：`2026-07-18 Asia/Shanghai`
- 复审角色：Architecture & Knowledge Steward；Quality, Performance & Release
- 分支：`feature/keyboard-layout-9key-pinyin-001`
- HEAD：`44d42130bd8e2012bce7b4c034c4bc51a149dec3`
- 对象：上述 HEAD 上的当前未提交工作区
- 输入 handoff：`docs/assignments/keyboard-layout-9key-pinyin-001-grok-fix-handoff-2.md`
- Architecture：**Fail / Changes Required**
- Quality：**Fail / Changes Required**
- Publication：**Not Ready**
- Product Gate：**Open；Human Dependency 未满足**

## 1. 独立性与权威

本复审重新读取 Assignment、Product Decision、ADR 0020、前次 Codex rereview、Grok fix handoff 2、相关实现和测试。handoff 只作为待核 claims 与定位入口；聊天、handoff 中的 PASS 声明和历史测试结果均不作为结论依据。本记录基于当前工作区静态审查及本次独立命令结果。

## 2. Executive conclusion

Grok 对前次四个 P1 的直接修复基本成立：普通选择路径已经要求当前 generation 的 issued key；稀疏 comment discovery 不再被 16-candidate peek 永久锁死；refinement/rollback 已要求 usable composition 与 candidates；letters 页面往返能够主动重建路径状态。对应负例和 lifecycle 测试存在。

但 Architecture 与 Quality 仍不能通过。rollback 的 usable-live 分支先应用恢复后的 RIME output，随后又用恢复前的整份 `T9PinyinPathState` 覆盖刷新结果。只要恢复后的候选 comments 与恢复前快照不同，旧 compact path、旧 selected path 和旧 issued key 会重新进入当前状态，并能通过 Core provenance guard。该分支正是选择事务失败后的生产恢复路径，因此不是仅有理论影响。

## 3. Blocking finding

### [P1] rollback 用旧路径快照覆盖 live RIME provenance

证据：

- `rollbackT9PinyinRefinement` 在恢复结果 raw 相同且 usable 时先调用 `applyRimeOutput(...)`（`KeyboardController+T9PinyinPath.swift:334-336`）。这一步会依据 live candidates/comments 刷新当前路径状态。
- 随后代码只比较 raw identity，就把 `previousPathState` 整体赋回当前状态（`:337-345`）。被恢复的字段包含 `compactPaths`、`selectedPath` 和 `issuedReplacementKeys`，并未与恢复后的 live comments 重新求交或重新签发。
- 选择入口仅检查 replacement 是否位于当前 `issuedReplacementKeys`、generation 非零且与 raw 位置兼容（`:105-113`）。因此被旧快照重新注入的 replacement 会再次获得选择权限。
- 现有 rollback live-equivalent 测试让恢复前后 candidates/comments 完全相同（`T9PinyinPathTests.swift:151-168`），没有覆盖恢复后 comments 改变或路径消失的情况。

影响：

- 破坏 Product Decision 与 ADR 0020 的 comment-only provenance：用户可选择一个不属于恢复后 live RIME output 的旧路径。
- 路径栏与候选栏可能分别展示恢复前 path snapshot 和恢复后 candidate snapshot，造成同一 Core state 内部不一致。
- 该问题发生在 refinement 失败后的 rollback 成功分支；普通 refresh 的 issued guard 无法补救，因为旧 issued set 在 refresh 后被整份覆盖回来。

Required change：

- usable rollback 以恢复后的 live RIME output 为唯一事实来源，重新构造路径与 issued provenance；不得整体恢复 `previousPathState`。
- 如果产品确需保留选择态，只能在 live 重建后保留仍由当前 comments 重新签发、且与当前 raw 兼容的 selected path；旧 issued set 不得跨 live-output 变化继承。
- 增加负例：恢复前 comments 为 `ni/mi`，rollback 后同 raw 的 usable output 只包含 `mi`（或另一组路径）；断言 `ni` 从 compact/issued/selected 中消失、裸 `ni` 选择被拒绝、当前 live `mi` 仍可选择。

## 4. 前次四个 P1 复核矩阵

| 前次 P1 | 本次判定 |
|---|---|
| Core provenance guard 等价于 compatibility | **主路径已修复**：选择要求 current generation issued key；但 rollback 会重新注入 stale issued keys，见本次 P1 |
| 16-candidate peek 锁死后置路径 | **已修复**：三态 availability、panel 有界 auto-advance 和 index 17+ 测试存在 |
| refinement/rollback 不要求 usable output | **usable 判定已修复**：exact raw、非空 preedit/raw/candidates；但 usable rollback 的 provenance 恢复仍错误 |
| 页面往返不重建 | **已修复**：返回 letters 时重建，并有无新按键 round-trip 测试 |

## 5. 独立验证

| 验证 | 本次结果 | 说明 |
|---|---|---|
| `swift test --package-path Packages/KeyboardCore` | **PASS — 612 tests, 0 failures** | 独立运行；当前集合没有覆盖 live rollback comments 变化 |
| `T9PinyinPathTests` | **PASS — 18 tests, 0 failures** | 定向测试通过，但上述 provenance 负例缺失 |
| KeyboardTests / iPhone 17 Pro Max Simulator 27.0 | **PASS — 6 tests, 0 failures** | xcresult summary；无 hosted path-panel UI tests |
| Debug strict generic Simulator build | **PASS / exit 0** | `SWIFT_STRICT_CONCURRENCY=complete`、Swift warnings-as-errors；有既知 Boost x86_64 linker warnings |
| Release strict generic Simulator build | **PASS / exit 0** | 同上；不能声明全构建零 warning |
| RimeBridgeTests `build-for-testing` | **PASS / exit 0** | 验证 iOS Simulator 测试目标可编译；未运行 real fixture Spike |
| `git diff --check` | **PASS** | 无输出 |
| clean-commit Spike archive | **未执行** | 当前无 commit，现有 Spike 仍只可作为 feasibility evidence |
| physical-device interaction / latency / VoiceOver | **未执行** | Human Dependency；Product Gate 保持 Open |

## 6. Architecture boundary judgement

| Boundary | Result |
|---|---|
| RIME/librime comment 为路径来源 | **Fail**：rollback 可恢复旧 comment provenance |
| Current-generation Core issuance guard | Partial：普通选择 Pass；rollback stale snapshot Fail |
| Exact usable refinement / fail-closed unusable rollback | Pass |
| Usable rollback 与 live candidate/path state 一致 | **Fail** |
| Sparse discovery / lazy paging entry | Pass（静态与 Core contract） |
| Page lifecycle clear/rebuild | Pass（静态与 Core test） |
| RIME deploy/vendor boundary | Pass；未见新增 extension deploy 或 vendor mutation |
| UI geometry / scroll / VoiceOver / latency | Static direction acceptable；interactive evidence open |

## 7. Gate decision and handoff

- Architecture：**Fail / Changes Required**。
- Quality：**Fail / Changes Required**。
- Assignment 保持 `Active`；不得标记 `Reviewed`、`Completed` 或 `Closed`。
- Publication：**Not Ready**；本次复审不授权 commit、push 或 PR。
- Product Gate：保持 **Open**。即使上述 P1 修复并通过代码复审，仍需 clean evidence、hosted UI/VoiceOver 以及真机 interaction/lifecycle/latency matrix。

下一 handoff 回到 Grok Executor。修复范围应只处理 usable rollback 的 live provenance 重建及对应负例，不借机扩展功能或重构 RIME 部署边界。Codex 本次未修改实现代码。
