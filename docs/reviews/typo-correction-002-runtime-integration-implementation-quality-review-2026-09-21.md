# Quality review: TYPO-CORRECTION-002 runtime-integration implementation

## Verdict

**Pass with conditions** — 仅限实现 worktree 当前 uncommitted 快照，且仅限本审查独立重跑的路径门禁。

独立重算的 HEAD / tree / tracked `git diff` 与 Quality AUTH 绑定值一致；原纯 Core checkpoint 仍未被改。`swift-format lint --strict`、完整 KeyboardCore、指定模拟器上的 RimeBridgeTests 与 Universe Keyboard scheme test 均通过。Architecture 的 F-01 / F-02 / F-03 条件与测试合同缺口仍然存在：它们是 **未覆盖但可接受的 bounded residual**，**不把本审查升级成无条件 Quality Pass，也不把 Architecture Conditional Accept 升级成 Quality Gate**。

未测合同不得写成已测。本 verdict 不是 Product / Quality / Release Gate，不是 publication，也不是 Assignment Close。

## Review identity

| Field | Value |
|---|---|
| Reviewer | Independent Quality, Performance & Release Maintainer；不是实现 Executor，也不是 Architecture reviewer |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`](../assignments/typo-correction-002-runtime-integration-implementation-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-QUALITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-QUALITY-001.md)，本审查消费 |
| Architecture review | [`implementation Architecture review`](typo-correction-002-runtime-integration-implementation-architecture-review-2026-09-21.md) — `Conditional Accept`（未重跑测试） |
| Implementation worktree | `/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001` |
| Parent docs worktree | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003` |
| Review time | `2026-09-21T22:44:12+08:00 Asia/Shanghai` |
| Method | 独立重算身份与 per-file / 全量哈希；独立重跑 format + 路径门禁测试；只读源码与测试合同。未改 Swift、未 capture、未 commit/push |

Executor [`evidence`](../evidence/typo-correction-002-runtime-integration-implementation-001.md) 只作路径索引，不作为 Quality 事实。

## Independent identity recomputation

实现 worktree 命令（重跑后再次核对，结果不变）：

```bash
cd /private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001
git rev-parse HEAD
git rev-parse 'HEAD^{tree}'
git status --porcelain -uall
git diff HEAD | shasum -a 256
```

原 checkpoint 命令：

```bash
cd "/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard"
git rev-parse HEAD
git status --porcelain -uall
git diff HEAD | shasum -a 256
shasum -a 256 \
  Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift
```

全量内容配方（Quality 实际采用）：`git status --porcelain -uall` 的 15 个路径按字典序拼接原始文件字节，再 SHA-256。

```bash
python3 -c '
import hashlib, os, subprocess
os.chdir("/private/tmp/universe-keyboard-typo-correction-002-runtime-integration-implementation-001")
paths=[]
for line in subprocess.check_output(["git","status","--porcelain","-uall"], text=True).splitlines():
    paths.append(line.split(" -> ",1)[1] if " -> " in line else line[3:])
blob=b"".join(open(p,"rb").read() for p in sorted(paths))
print(len(paths), len(blob), hashlib.sha256(blob).hexdigest())
for p in sorted(paths):
    print(hashlib.sha256(open(p,"rb").read()).hexdigest(), p)
'
```

| Item | AUTH / Architecture 绑定值 | 本审查独立重算 | 结果 |
|---|---|---|---|
| HEAD | `4d1050f4b677494e06448cb40a83ef2da46d7b27` | 同左 | 一致 |
| Tree | `5f864a6f6f139810ed59c7e00ab6c33caad7e500` | 同左 | 一致 |
| Tracked `git diff HEAD` SHA-256 | `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b` | 同左（38182 bytes） | 一致 |
| 15 文件字节拼接 SHA-256 | Architecture AUTH `3cf0d23cda23a5f0a6a87264333cb1b31d91fad3b36c9c8784c9dbaea51e660d`；Architecture 独立拼接 `4b701835f070e2c337fd2d3b76b67813e7e5722bdaa7db1b82faa7e00d2c891e` | 同 Architecture 拼接值 `4b701835…`（172096 bytes） | **未复现 `3cf0d23c…`**；与 Architecture 独立观测一致 |
| 原纯 Core `git diff HEAD` | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` | 同左；仍仅 3 个 tracked 文件 | 一致、未被改 |

Quality AUTH 绑定的是 HEAD / tree / tracked diff。这三项无漂移，审查继续。`3cf0d23c…` 仍是 **identity-recipe residual**，不是第二份已核验快照。

另测配方均不是 `3cf0d23c…`：`git add -A` 后 cached diff `e8572b10…`；untracked-only 拼接 `d10a0507…`；14 个 Swift 拼接 `17923693…`；`sha256  path` manifest `9a4727a2…`。

### Per-file SHA-256（字典序）

| SHA-256 | Path |
|---|---|
| `2118de9db9065aaad25157c2ba2b28dc79ab305180f4f8bfb60b9b989c47f217` | `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` |
| `142a3ebe0f02ad2506016d0a1235233289b914ebd69c21893e17aee30b6e68f7` | `Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift` |
| `c1c3df2697699bf863944da944177fc27d056ae2ea6c7571fc5523f54139e4ec` | `Keyboard/Controllers/KeyboardViewController.swift` |
| `ab363292f55eb2981d40a675dc2ef93ba11c1800418d2629ff25cb966d06c676` | `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift` |
| `da8828fecac0c88c3ac1b4551b5dd1c39bebaa925bf1a7bc5dfc65f5a8748953` | `KeyboardTests/TypoCorrectionRecallRuntimeTests.swift` |
| `08745e149975b5feb844107a570428cd9a51e1a754ede2f0368ae3177667c949` | `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift` |
| `0a8d484dd22d82e109e8d0273d0bc0fbe6ba3d3bb62dfafd631fb6763d2b20ae` | `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TypoCorrection.swift` |
| `6bbb6f86ca119e0974dd6888fb147d8b27142a70619d7a5ebe90dbb51e3cbf58` | `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift` |
| `f7ba8bec024f71e39b073eb0cef767960fd81dc538923a975d8de267b7136a6a` | `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift` |
| `23d608f324a576ee971c64bbe3fcbf805edf5f65b86f83eaa8da9091ec822c8a` | `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift` |
| `edbf636f9b66c336189c213769d84fdb4425d440a4ac7b169a0e5cde47315780` | `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift` |
| `0bb43bc700f0fdd0dc54a20993f59453305a137ecb0a42668d93f773a2179c44` | `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRuntimeIntegrationTests.swift` |
| `80588d36432cc35f0d3c22a0c51e583b8cb78801ff2b39892b99942a692f5f55` | `Packages/RimeBridge/Sources/RimeBridge/TypoCorrectionSidecarOwnerAdapters.swift` |
| `f117600dc2a20de63a5999b43cbcce5ad8e4af93110d89247a708888dbfd20e7` | `Packages/RimeBridge/Tests/RimeBridgeTests/TypoCorrectionSidecarOwnerAdapterTests.swift` |
| `51537e56969bb44b66eb4fb78692c4f29d1ad93dad896eed6e1f5d25dfff4e9f` | `docs/evidence/typo-correction-002-runtime-integration-implementation-001.md` |

原 checkpoint 三文件字节与上表对应哈希相同，证明本 slice 未改写那份纯 Core 快照。

## Independent rerun matrix

环境：macOS 27.0 (26A428)，Xcode 27.0 (27A266a)，Apple Swift 6.4，host `arm64`。模拟器 `iPhone 17 Pro` id `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`，iOS 26.0 (23A343)，审查期间已 Booted。Vendor 已在实现 worktree `Packages/RimeBridge/Vendor`。未跑 Release build（Quality AUTH 未要求）。未改任何 Swift。

| Check | Exact command | Result |
|---|---|---|
| Swift format | 对 14 个变更 `.swift` 各执行 `xcrun swift-format lint --strict --configuration .swift-format <file>` | 全部 exit 0，无 lint 输出 |
| KeyboardCore | `swift test --package-path Packages/KeyboardCore` | **1150 passed / 0 failed / 0 skipped**；`TypoCorrectionRecallPreflightTests` 18/0；`TypoCorrectionRuntimeIntegrationTests` 7/0 |
| RimeBridgeTests | `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination 'platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES -derivedDataPath /tmp/typo-corr-002-qi-derived-rimebridge test` | **TEST SUCCEEDED**。xcresult `totalTestCount=102`：82 passed / 0 failed / 20 skipped。新套件 `TypoCorrectionSidecarOwnerAdapterTests` 1 passed |
| Universe Keyboard | 同上 destination / 标志，`-scheme "Universe Keyboard"`，`-derivedDataPath /tmp/typo-corr-002-qi-derived-app` | **TEST SUCCEEDED**。xcresult `totalTestCount=388`：379 passed / 0 failed / 9 skipped。日志拆分：UniverseKeyboardTests **373 executed / 9 skipped / 0 failed**；KeyboardTests **15 executed / 0 skipped / 0 failed**（含新套件 1 条常量断言） |

权威 App+Keyboard 计数是 xcresult **388 = 379 passed + 9 skipped**。套件日志 373+15=388，与 xcresult 闭合。跳过项仍是 skip，不是 pass。

### Q-01 — yield hop 的 `#ActorIsolatedCall` 警告

App scheme 编译 `TypoCorrectionRecallCoordinator.swift:132` 发出：

`warning: call to main actor-isolated instance method 'performYieldedTurn()' in a synchronous nonisolated context [#ActorIsolatedCall]`

命令行与工程均带 `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`，但本机此次仍 **TEST SUCCEEDED**。这不是测试失败，也不能证明 hosted CI 会同样放行。**未覆盖但可接受为 bounded residual**；不阻断本 bounded Quality 结论。禁止把它说成并发合同已闭合。本审查未修代码。

## Coverage vs Architecture residuals

| Residual | Quality 处置 | 依据 |
|---|---|---|
| F-01 yield：driver 返回后不在同栈取下一 query | **测试已覆盖**（driver 级） | `testDriverYieldsAfterEachQueryAndDoesNotStartTheNextOnTheReturnStack` 本机 7/7 中通过。**未**覆盖 `RunLoop.main.perform(inModes: [.default])` 或 UIKit 调度 |
| F-01 `handleTogglePage` 无 invalidate-first | **未覆盖但可接受为 bounded residual** | 源码 `handleTogglePage()` 只改 `state.currentPage`，不 `clear` / 不 bump epoch。无入口测试。fence 的 `page` 字段是 fail-closed，不是 invalidate-first |
| F-01 字母热路径 `refreshTypoCorrectionSuggestions` | **未覆盖但可接受为 bounded residual** | `KeyboardController+PartialCommit.swift` / TextEditing / RimeRecovery 仍同步循环 query 并写 `state.typoCorrection`。无本 slice 新测试覆盖该热路径 |
| F-01 canary / P3D1 安装无先行 invalidate | **未覆盖但可接受为 bounded residual** | Bootstrap ~560、996 行只 `installTypoCorrectionSidecarOwner`。无测试 |
| F-01 correction-disable / 空 composition 切模式 | **未覆盖但可接受为 bounded residual** | `handleToggleInputMode()` 仅 abandon / finish 路径 `clear`；空 composition 切模式不 bump。无测试 |
| F-01 visibility / default engine / dual-gate rebind | **源码挂钩存在；测试未覆盖入口** | `viewWillDisappear`、default `RimeEngineImpl` 安装、dual-gate 安装前有 `invalidateTypoCorrectionRecall()`。无 UIKit 级测试。不阻断本结论 |
| F-02 default wrap + `nil` epoch | **测试已覆盖** | Core `testInstalledSidecarOwnerForwardsToTheFacadeAndNeverInventDefaultEpoch`；RimeBridge `testDefaultAdapterWrapsTheInstalledQueryFacadeWithNoNativeEpoch` 本机通过 |
| F-02 三路线 adapter no-bypass | **未覆盖但可接受为 bounded residual** | 无 MainActor-responsive / thread-affine 测试。`makeTypoCorrectionSidecarOwner()` 未被 Bootstrap 调用。不得写成三路线已证明 |
| F-02 dual-gate 仍 `CandidateProviderTypoCorrectionQuery` | **未覆盖但可接受为 bounded residual** | dual-gate / canary / P3D1 安装的是 CandidateProvider，不是 thread-affine `correctionCandidates` facade。无测试把该缺口证伪或证实 |
| F-03 composition 变化 display no-op | **测试已覆盖** | `testConditionalApplyWritesOnceAndIsDisplayNoOpWhenCompositionChanged` 本机通过 |
| F-03 第二 writer `refreshTypoCorrectionSuggestions` | **未覆盖但可接受为 bounded residual** | apply 路径之外热路径仍写 `state.typoCorrection`。无测试证明唯一 writer |
| F-03 empty / budget-stop display no-op | **未覆盖但可接受为 bounded residual** | `finishApply()` 对空材料仍 `.readyToApply`；coordinator 仍 `applyTypoCorrectionRecallMaterial` 并可 `refreshCandidateBar()`。无对应测试 |
| Coverage-deficit 三结构条件 | **测试已覆盖** | `testCoverageDeficitRequiresEmptyStageOneAndRemainingBudget`：accepted==0 / unaccounted>0 / remaining>0 |
| Stage-two abstain | **测试已覆盖** | `testStageTwoAbstainsWhenStageOneAlreadyHasAcceptedDisplayResults` |
| letter / Chinese / min-length 与 predicate 合取 | **未覆盖但可接受为 bounded residual** | coordinator `isEligible` 有实现；测试未合取 |
| 8/8/3/4 常量 | **测试已覆盖（常量级）** | KeyboardTests 仅四条 `XCTAssertEqual`。**不构成 F-01 入口合同** |
| KeyboardTests 仅常量断言 | **未覆盖 F-01；可接受为 bounded residual** | 新文件被同步 root group 编译并执行（15/15），但只有预算钉死 |
| 生产 12/8；60/64 非 always-on 第一阶段 | **未在本 Quality 重测语义；源码与既有 preflight 测试仍在** | Preflight 18 通过。不声明 runtime 效果 |
| F-04 diagnostics | **保持 `tech_debt`** | 本 slice 未扩 scope；DEBUG trace 仍在 `applyRankedTypoCorrection` |
| AUTH `3cf0d23c…` | **identity-recipe residual** | 见上。不阻断 HEAD/tree/tracked 绑定 |
| Real RIME / QA-001 / INT-003 / 180 ms | **仍 `UNKNOWN`** | AUTH 排除。不阻断本 bounded 结论 |

没有任何一项 Architecture residual 被本审查改写成「已测通过」。也没有任何一项因测试失败而 **阻断本 Quality 结论**。它们共同阻断的是：无条件 Quality Pass、Quality Gate、以及把 Conditional Accept 当成已闭合合同。

## Executor receipt reconciliation

| Executor 叙述 | 独立 Quality |
|---|---|
| format lint Pass | 14 个变更 Swift 独立 `lint --strict` 通过 |
| KeyboardCore filter 7 passed | 全量套件内同一 7 条全部 passed；不以 filter 替代全量 |
| KeyboardCore 1150 passed | 独立重跑 1150/0/0，一致 |
| RimeBridgeTests `TEST SUCCEEDED`（无计数） | 独立计数 102 = 82 passed + 20 skipped。Executor 省略 skip/pass 数，不冲突，也不被当成 102 全 pass |
| UniverseKeyboardTests 373 executed / 9 skipped；KeyboardTests 15 passed | 独立日志一致；xcresult 388/379/9/0 与 373+15 闭合 |
| adapter / fences / apply 已落地 | 只承认已执行测试覆盖的子集；三路线、invalidate-first 枚举、empty/budget-stop no-op **不能**从 receipt 推出 |

Executor 未记录 Q-01 警告。Quality 以独立编译日志为准。

## Non-claims

本审查不声明或批准：

- Quality / Product / Release Gate
- Architecture Conditional Accept 已被 Quality 无条件接受
- 三路线 runtime 已无 bypass
- page / mode / 热路径 / canary / P3D1 已全部 invalidate-first
- empty / budget-stop 已是 display no-op
- `RunLoop.main.perform(inModes: [.default])` 已被测试证明
- KeyboardTests 常量断言等于 F-01 入口合同
- AUTH `3cf0d23c…` 等于当前 15 文件字节拼接
- 真实 RIME query/deploy、Simulator/device capture、新 Run ID
- QA-001、INT-003、paired performance 或 `180 ms`（debounce `0.18` 只是源码常数，不是测量）
- commit、push、PR、merge、TestFlight、Release、parent 或本 Assignment Close

下一步只属于 Product Lead：是否接受上述 bounded residuals，并另开 Authorization。本审查不关闭 Assignment。
