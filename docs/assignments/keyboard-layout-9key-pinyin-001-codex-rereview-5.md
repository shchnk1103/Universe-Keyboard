# KEYBOARD-LAYOUT-9KEY-PINYIN-001 Codex 第五次独立复审

- 复审日期：`2026-07-18 Asia/Shanghai`
- 复审角色：Architecture & Knowledge Steward；Quality, Performance & Release
- 分支：`feature/keyboard-layout-9key-pinyin-001`
- HEAD：`44d42130bd8e2012bce7b4c034c4bc51a149dec3`
- 对象：上述 HEAD 上的当前未提交工作区
- 输入 handoff：`docs/assignments/keyboard-layout-9key-pinyin-001-grok-fix-handoff-5.md`
- Architecture：**Pass**
- Quality（自动化实现门）：**Pass**
- Publication：**Not Ready**
- Product Gate：**Open；Human Dependency 未满足**

## 1. 独立性与权威

本复审重新读取仓库协作规则、Knowledge Index、Assignment、Product Decision、ADR 0020、前次独立 review、handoff 5、当前实现、测试及领域文档。handoff 仅作为待核 claims 和定位入口；聊天、handoff 结论及历史命令结果均不作为权威。本记录依据当前工作区静态审查和本次独立验证。

## 2. Executive conclusion

上一轮 Architecture/Quality 阻断项已经关闭：新 RIME output apply 与同 snapshot re-scan 现在是两个显式 Core API；生产 output apply、partial composition 和 partial candidate selection 均走 hard provenance，same-raw comments 变化会推进 `provenanceRevision`、撤销旧 issued keys，并使 UIKit panel/window token 失效；soft refresh 只用于同 stored snapshot，并保留该 snapshot 下 expanded-window issuance。

新增生产调用链测试没有直接调用 hard helper 来伪造结论，而是通过 `applyRimeOutput` 注入 same-raw、changed-comments 的新 output，验证 raw generation 稳定、provenance revision 推进、旧 `ni` 撤权、旧 window token stale、当前 `mi` 仍可选择。ADR 0020 与 `KEYBOARD_LAYOUT.md` 也已记录双 revision 和 apply/soft 边界。

本次未发现新的 P0/P1/P2 实现阻断项。Architecture 可通过；自动化实现 Quality 可通过。该结论不关闭 Product Gate，也不构成发布授权：真机交互、VoiceOver、布局/滚动、按键延迟、clean-commit Spike evidence 及 hosted panel UI 自动化仍未完成。

## 3. 上一轮 findings 复核

| 上一轮 finding | 本次判定 |
|---|---|
| same-raw 新 RIME output 仍走 soft refresh | **已修复**：生产 apply 使用 `applyT9PinyinPathStateFromNewRimeOutput()` |
| partial candidate / remaining composition 未 hard-open provenance | **已修复**：相关生产路径显式 hard apply |
| stale issued key 可跨 changed comments 留存 | **已修复**：生产负例验证 `ni/mi → mi` 后 `ni` 撤权 |
| UIKit panel token 未绑定 comment authority | **已修复**：panel/window/click 均绑定 `provenanceRevision` |
| ADR / KEYBOARD_LAYOUT 未记录双 revision | **已修复**：current-comment-only、双 revision、apply/soft 合同已入权威文档 |

## 4. Architecture judgement

| Boundary | Result |
|---|---|
| RIME comments 为唯一 path 来源 | Pass |
| Current-comment-only Core authorization | Pass |
| Raw lifecycle 与 comment provenance 分离 | Pass |
| 新 RIME output 自动推进 provenance | Pass |
| 同 snapshot expanded issuance 持续有效 | Pass |
| UIKit panel/window/click stale guard | Pass（静态 + Core contract） |
| Exact usable refinement / transactional rollback | Pass |
| Mixed raw Space/Return/language safety | Pass（Core tests） |
| Page/lifecycle clear and rebuild | Pass（Core tests） |
| RIME deploy/vendor boundary | Pass；未见 Extension deploy、schema mutation 或 vendor change |
| ADR / domain Source of Truth | Pass；双 revision 合同已同步 |

## 5. 独立 Quality 验证

| 验证 | 本次结果 | 说明 |
|---|---|---|
| `swift test --package-path Packages/KeyboardCore --filter T9PinyinPathTests` | **PASS — 21 tests, 0 failures** | 包含 same-raw new-output 生产调用链负例 |
| `swift test --package-path Packages/KeyboardCore` | **PASS — 615 tests, 0 failures** | 独立运行，约 3.5 秒 |
| KeyboardTests / iPhone 17 Pro Max Simulator 27.0 | **PASS — 6 tests, 0 failures** | xcresult summary；不是 hosted path-panel UI automation |
| Debug strict generic Simulator build | **PASS / exit 0** | complete concurrency + Swift/C warnings-as-errors；仍有既知 Boost x86_64 linker warnings |
| Release strict generic Simulator build | **PASS / exit 0** | 同上；不能声明全构建零 warning |
| RimeBridgeTests `build-for-testing` | **PASS / exit 0** | Simulator target 可编译；本轮未运行 real fixture Spike |
| `git diff --check` | **PASS for tracked diff** | 新功能多数文件仍 untracked；相关实现/测试/ADR 的 trailing-whitespace 扫描亦无结果 |
| `@unchecked Sendable` / Extension deploy boundary scan | **PASS** | 本次 feature 路径未发现绕过并发或部署边界的改动 |

## 6. Non-blocking follow-up

### [P2 Documentation] Assignment 的 Current Evidence 区块仍陈旧

`docs/assignments/keyboard-layout-9key-pinyin-001.md` 的 Current Evidence 仍写 `T9PinyinPathTests (13)`、KeyboardCore `607` tests，并把 UI 描述为 raw `generation-guarded`；handoff/review 链也只更新到 fix handoff 4。该区块是状态镜像，不改变 Product/ADR 合同，因此不阻断本次 Architecture/automated Quality Pass，但发布前应同步为当前 21/615、dual-revision 语义及 handoff 5 / rereview 5 链接。

## 7. Skipped / open gates

- clean-commit Spike re-archive：未执行；当前仍为 dirty uncommitted worktree。
- real librime Spike re-run：本轮未执行；沿用仓库已有 feasibility evidence，不将其表述为当前 clean publication snapshot。
- hosted UIViewController path-panel interaction automation：未执行。
- physical-device matrix、与原生九宫格对比、VoiceOver、滚动及 key latency：未执行；Human Dependency 未满足。
- commit、push、PR：未授权且未执行。

## 8. Gate decision and next handoff

- Architecture：**Pass**。
- Quality（自动化实现门）：**Pass**。
- Assignment 仍保持 `Active`，不由本次复审擅自改为 `Completed`、`Reviewed` 或 `Closed`。
- Publication：**Not Ready**；需先形成 clean commit/evidence，并完成发布前范围检查。
- Product Gate：**Open**；下一 handoff 应进入 Human Dependency 的真机/VoiceOver/交互/延迟矩阵，再由 Quality 与 Product Lead 审阅。

Codex 本次只新增独立复审记录，未修改实现代码、Assignment 状态或发布状态。
