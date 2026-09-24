# Assignment: SCHEME-LICENSE-DOWNLOAD-CTA-REGRESSION-001 — 许可下载流程回归覆盖

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` |
| **Phase** | 三入口许可 sheet 流程回归已完成；strict format 与 App + Keyboard Debug tests 通过 |
| **Non-claims** | 不等于独立 Quality、Product Gate、真机 UI/真实下载验收、commit / push / merge 或 Release |
| **Next** | Final-tree Quality 状态由独立 revalidation child/receipt 记录；不授予 Gate 或发布权限 |
| **Residuals** | 真机 UI、网络下载与 RIME 部署行为未由本测试覆盖 |

---

## Authority

- Assignment Authority: Human Product Owner
- Decision Source / Date: 用户于 `2026-09-23 Asia/Shanghai` 明确授权：“继续为 P2 缺口建立一个小范围 Assignment/AUTH，补上许可 sheet 的流程回归覆盖。”
- Product Approver: Human Product Owner
- Authorization: [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-REGRESSION-001`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-REGRESSION-001.md)
- Domain Owner: App & Data Operations Maintainer（沿用父 Assignment）
- Executor: `/root` Codex session
- Environment Executor: `/root` Codex session；仅在当前 isolated worktree 运行 swift-format 与本地 iOS Simulator App + Keyboard tests
- Human Dependency: Not Applicable — 无需人工设备操作
- Architecture Reviewer: Not Applicable — 仅提取/复用最小、纯逻辑流程路由，不改变产品或下载引擎合同；若必须改变这些边界则停止
- Quality Reviewer: Not authorized by this implementation AUTH；独立 exact-tree Quality revalidation 需后续 Human 新 AUTH

## Parent and predecessor

- Parent implementation: [`SCHEME-LICENSE-DOWNLOAD-CTA-001`](scheme-license-download-cta-001.md)
- Finding: [`SLD-CTA-Q-01`](../reviews/scheme-license-download-cta-quality-review-001.md) — P2，UI 流程回归覆盖不足
- Product contract: [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md)
- Prior Quality snapshot: [`receipt`](../reviews/scheme-license-download-cta-quality-review-001.md)，只绑定 P3 状态同步前快照；本 Assignment 不继承或声称其为当前树复核

## Scope

1. 新增最小的、确定性、无网络副作用的 first-download license flow coordinator/route helper；三个生产入口（设置详情、启用引导、九键首次安装）实际调用它。
2. 扩展 `UniverseKeyboardTests`，通过生产实际使用的 coordinator/route helper 锁定：
   - 每个入口点击首次下载 CTA 只产生许可 sheet 展示效果，不接受许可或启动下载；
   - 对所选 schema 确认后效果严格为先 `acceptLicense`，再 `startDownload`；
   - 关闭 sheet 只产生 dismiss，不接受许可、不下载；
   - 九键资源缺失时，即使持久许可状态此前为已接受，首次安装仍走许可 sheet 路由。
3. 测试不得联网、部署 RIME、依赖共享 App Group 状态或真的下载资源。测试结论只覆盖共享生产路由/副作用序列；不称为 XCUITest、手工交互或端到端网络验收。
4. 修改后格式化并 strict lint 所有变更 Swift 文件；运行 `Universe Keyboard` Debug App + Keyboard test scheme，确认新测试实际执行。
5. 更新本 Assignment、父 Assignment、Active Work 与 Dashboard 的当前状态，写明测试证据和独立 Quality revalidation 边界。不要改写既有 Quality receipt。

## Non-goals

- 产品文案/行为变化、许可接受存储语义、下载或部署引擎变化
- 完整 XCUITest/UI 自动化、Simulator 人工验收、真实 RIME 下载/部署
- `Keyboard/` Extension、RimeBridge、KeyboardCore
- Independent Quality / Quality Gate、Product Gate、Release Gate、commit、push、PR、merge、TestFlight、Release、worktree/branch cleanup

## Exact starting point

- Worktree: `/private/tmp/universe-keyboard-scheme-license-download-cta-001`
- Branch: `grok/scheme-license-download-cta-001`
- HEAD: `80091f35cc5411b292eca78662f39e2b91694045` (`origin/main`)
- Worktree is intentionally uncommitted. Initial identity must be rechecked before editing. The following digests bind the authorized pre-edit snapshot; only the listed test seam, associated unit tests and named status/Assignment documents may be changed.

| Input | SHA-256 at authorization |
|---|---|
| `Universe Keyboard/Views/Guide/ActivationResourcePreparePanel.swift` | `641facd8fc2fb281be2afecb64ff9a23089c7d6b7a5ed5ae75ac4178f19cf2cb` |
| `Universe Keyboard/Views/Settings/KeyboardLayoutSettingsView.swift` | `11cf1465e07fba7601bdf365a90a352b95e1898ab91435e8647ec0c10421382b` |
| `Universe Keyboard/Views/Settings/RimeSettingsView.swift` | `338ea19674d767e883070f24a42d7ad92d717a2dd3980014b0a54de944a06491` |
| `Universe Keyboard/Views/License/LicenseView.swift` | `67273dd1add0be4d3447fec42a75abf836df44b2f373d1e5b1a46d22039ed7e2` |
| `Universe Keyboard/Models/SchemeLicenseDownloadCopy.swift` | `97d893792c1b707e1e84bda7c50c3b1e177a091d6cb420c81071c14932d25262` |
| `UniverseKeyboardTests/SchemeLicenseDownloadCopyTests.swift` | `1c93fef092efd35721d3b5942733fe80eec6c63eb598220980f9dd61fb1614d3` |
| Existing implementation status stream excluding this new Assignment/AUTH and eventual test review receipt | `8ec199203b1ba4f969a729a6b02806ae54c683128e0ad078578c6c13d2716114` |
| Existing tracked `git diff HEAD` stream (including P3 state-sync docs) | `d3783c63708659480a2e70be7a85387bd8d6d38e48b7a1bd8e7bc65bb79cf339` |

## Entry Criteria

- The Human authorization above is recorded as a live AUTH.
- Exact branch/HEAD and all source hashes match this Assignment before edits.
- Existing dirty files outside this Assignment are preserved; no operation resets, cleans, or switches the worktree.

## Exit Criteria

- Automated tests execute against the same production-used route/effect coordinator that all three entry points call.
- Tests assert the four behaviors in Scope, including selected schema and callback order.
- `swift-format format --in-place` and strict lint pass on all changed Swift files.
- App + Keyboard Debug test target passes with new coverage executed; record command, simulator/OS, target counts and result.
- Parent and active status mirrors distinguish implementation/test evidence from independent Quality, Product Gate and publication.

## Completion Evidence

- `2026-09-23 Asia/Shanghai` — `xcrun swift-format format --in-place --configuration .swift-format` and `xcrun swift-format lint --strict --configuration .swift-format` passed for all six changed Swift files.
- `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,id=8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2' -derivedDataPath /private/tmp/scheme-license-download-cta-regression-derived -resultBundlePath /private/tmp/scheme-license-download-cta-regression-final.xcresult CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test` — **TEST SUCCEEDED**, iPhone 17 Pro / iOS 26.0 Simulator; UniverseKeyboardTests 379 passed / 9 skipped / 0 failed; KeyboardTests 15 passed / 0 failed. The five new flow tests executed in UniverseKeyboardTests.
- `2026-09-23 Asia/Shanghai` — Human Product Owner authorized implementation; this AUTH is consumed by the bounded code/test change and local verification. No Quality, Gate or publication action was performed.

## Stop Conditions

- Any baseline mismatch or unrelated source-tree mutation is discovered.
- A test requires real network, RIME deployment, shared user state or unbounded infrastructure.
- A meaningful test requires changing download-engine/license-storage/product semantics or user-visible behavior.
- App + Keyboard test fails; capture exact error and stop before fixing unrelated failures or altering contract.

## Handoff

- Handoff target: Human Product Owner.
- Expected output: changed file list, test seam rationale, test/format evidence, remaining non-claims, and explicit need for a separate Quality AUTH before exact-tree revalidation.

## Revalidation Trigger

Any source/test input, Product Decision, branch/HEAD identity, or scope change invalidates this Assignment. A future independent Quality review must bind the post-implementation exact tree with its own AUTH.
