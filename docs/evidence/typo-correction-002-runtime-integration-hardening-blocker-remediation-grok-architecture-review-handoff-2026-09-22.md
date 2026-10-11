# Handoff：TYPO-CORRECTION-002 runtime-integration blocker remediation

## 交接目标

请 Grok bot 执行一次**独立、只读的 Architecture review**，判断本次三个
Architecture blocker 是否已真正关闭。审查对象是下面列出的精确、未提交
worktree 快照，不是 parent `main`，也不是旧的 implementation / pure-Core
checkpoint。

本 Handoff 不授权修改 Swift、测试、RIME、schema、vendor 或文档；不授权
capture、部署、Run ID、QA-001、INT-003、性能测试、commit、push、PR、merge、
publication、Product/Quality/Release Gate 或 Assignment Close。

## 精确审查对象

| 项目 | 值 |
|---|---|
| Review worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-hardening-blockers/Universe Keyboard` |
| Branch | `codex/typo-correction-002-runtime-hardening-blockers` |
| HEAD | `4d1050f4b677494e06448cb40a83ef2da46d7b27` |
| HEAD tree | `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Final tracked diff SHA-256 | `3f3de3aba53820340c25cafc6adaa87977c9ffe58b6a7e61e165c3c64e26db5e` |
| Final remediation delta SHA-256 | `15b6c539b85265b7be09eabf2deae625e869b5386676e650ed846ae2bf7cb0e4` |
| Predecessor hardening delta | `003c2e004764f96a83fa437262ac49e1b34952a13e523aa2ee9d7fe6d595a319` |

注意：HEAD/tree 是 Git base snapshot；实现改动仍是 worktree 中的未提交
内容。请先执行 `git status --short`，确认没有把本次未提交内容误判成
HEAD 内的 commit。不要 reset、restore、clean、checkout 或吸收 parent 的
脏改动。

## 必须先做的 provenance 检查

1. 在上述 worktree 中读取 `AGENTS.md`、`docs/KNOWLEDGE_INDEX.md`、
   `docs/ACTIVE_WORK.md`，再读取本 Assignment、Architecture blocker review、
   Product decision 和 execution evidence。
2. 核对 `HEAD`、`HEAD^{tree}`、`git status --short`。
3. 用与执行证据一致的七路径 diff recipe，独立重算 remediation delta
   `15b6c539…`；不得只按文件名或“测试通过”认定身份。
4. 核对 preserved implementation worktree 的 tracked-diff SHA-256
   `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b`，以及
   pure-Core checkpoint 的 tracked-diff SHA-256
   `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab`；两者
   不应被修改。
5. Vendor 只作为本地测试依赖：执行记录中的临时 symlink 已经删除。不要
   fetch、copy、更新或重新部署 vendor；不要把 vendor verify 当成 runtime
   或真实 RIME 证据。

## 本次实际修复范围

只允许把以下七个 remediation 路径作为本次 delta 解释；其余 inherited
路径属于 predecessor snapshot，不应被误归因于本次修复：

- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`
- `Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift`
- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRuntimeIntegrationTests.swift`
- `Packages/RimeBridge/Sources/RimeBridge/TypoCorrectionSidecarOwnerAdapters.swift`
- `Packages/RimeBridge/Tests/RimeBridgeTests/TypoCorrectionSidecarOwnerAdapterTests.swift`

### Blocker 1：invalidate-first

检查 Canary 与 P3D1 bootstrap：controller-owned recall 是否在任何
responsive/thread-affine flag 改变之前完成 invalidate。检查 invalidate 是否
覆盖 debounce work item、driver、recall epoch/composition revision、sidecar
owner lifetime，并确认没有遗漏的 flag mutation call site。

### Blocker 2：yielded callback stale ownership

检查 `TypoCorrectionRecallCoordinator` 的 RunLoop → `Task { @MainActor }`
路径：

- callback 是否绑定 recall epoch、composition revision、operation ordinal；
- invalidate 后的旧 callback 是否只能 no-op，不能推进新的 driver；
- 是否仍只有原有 query loop 和 budget，没有 `Task.detached`、第二查询循环
  或扩大生产预算；
- `YieldedTurnToken` 的 `Sendable` 契约是否真实通过 Swift 6 strict 编译，
  而不是用 `@unchecked Sendable` 绕过。

### Blocker 3：fallback/default unique writer 与三 route no-bypass

检查：

- recall 是否只能在 sidecar owner 已安装后启动；
- default、`mainActorResponsive`、`threadAffine` 三个 route 是否都经由同一
  `TypoCorrectionSidecarOwner` façade；
- route 是否由实际 controller 状态推导，而不是由调用点传入与实际状态不符
  的标签；
- 是否没有第二个 live RIME session、raw query writer、绕过 owner 的 fallback
  或另一条 candidate query loop；
- `state.typoCorrection` 是否仍只有既有 controller-owned publish 路径。

## 已有本地验证（仅供独立核对，不可直接当作 Architecture 结论）

- strict Swift format/lint：15 个授权 source/test 路径通过；
- KeyboardCore：`1153 passed / 0 failed`；
- RimeBridgeTests：`82 passed / 0 failed / 20 skipped`；
- Universe Keyboard Debug：`379 passed / 0 failed / 9 skipped`；
- vendor structural verify：12 个 framework artifacts 通过；
- 第一次 App 编译因完整 fence 捕获跨 `@Sendable` 边界而出现 2 个 Swift 6
  data-race errors + 1 个 Sendable warning，之后改用明确 `Sendable`
  的 scalar `YieldedTurnToken`，重新测试通过；
- `git diff --check`、KOS trigger paths、final gate matrix、release evidence
  adapter 的 26 个测试均通过。

测试结果只证明本地源码/编译合同；不证明真实 RIME、部署、Simulator/device
行为、QA-001、INT-003、配对性能或 180 ms。

## 审查输出要求

请输出一份独立 Architecture review，至少包含：

1. 你实际读取/核对的 worktree、HEAD/tree、delta SHA 和文件清单；
2. 对 F-01/F-02/F-03 各自给出 `Closed`、`Open` 或 `Pass with conditions`；
3. 对 invalidate ordering、stale callback、unique writer、三 route/no-bypass
   分别给出源码证据；
4. 区分“源码证明”“编译/单元测试证明”“Executor 记录”“UNKNOWN”；
5. 明确列出 residual 和 non-claims；
6. 不要把本次 review 升格为 Quality、Product、Release 或 merge 结论。

若发现 blocker 仍未关闭，请只记录 blocker 和最小 remediation 建议；不要
修改 worktree。若发现 provenance 不一致，立即停止并报告精确不一致位置。

## 参考记录

- [remediation Assignment](../assignments/typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md)
- [remediation execution evidence](typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md)
- [preceding Architecture blocker review](../reviews/typo-correction-002-runtime-integration-hardening-architecture-review-2026-09-22.md)
- [Product decision](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001.md)
