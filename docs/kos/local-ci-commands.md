# 本地 CI 命令全文（local-fast 与七步）

绑定红线在 `AGENTS.md`：合并前须通过本机定向快验及适用的托管 CI；未知或混合路径走完整门禁；docs-only 必须在报告写明并不得用于 workflow / `scripts/ci/**` / 分类规则自身；改主 App 或测试 target 不能只跑 KeyboardCore；Swift 格式 `lint --strict` 失败不得 commit 或 push，草稿与只推不合并均不豁免。本文是命令与分级矩阵，不放宽上述红线。

托管 CI 的三个 xcodebuild 测试任务对失败用例自动重试一次，并在任务摘要中列出重试用例。重试通过不代表用例稳定；本地门禁命令不变。

远端工作流按 [`docs/CI_CHANGE_CLASSIFICATION.md`](../CI_CHANGE_CLASSIFICATION.md)
分级：分类、轻量检查和 `final-quality-gate` 始终运行；只有严格的 docs/KOS allowlist
可跳过全部 heavy jobs（`format-swift`、`test-keyboardcore`、`test-rimebridge`、
`test-app-keyboard`、`test-rime-sync-keychain`、`build-release`）。未知路径、workflow 或 `scripts/ci/**`
变更按下方受控分类矩阵选择门禁；未知或混合路径走完整门禁。

## 本机定向快验（local-fast）与托管门禁

Code 站默认执行本机定向快验：Swift 改动必须通过 `AGENTS.md` 的 `swift-format lint --strict` 硬门槛；改 `KeyboardCore` 跑 `swift test --package-path Packages/KeyboardCore`；改主 App、Keyboard 或 RimeBridge 时，默认使用 `-only-testing:<本次新增及直接受影响的测试类>` 跑相应 scheme。按改动范围组合执行；纯文档或 KOS 脚本等无 Swift 改动按任务指定的适用检查执行。

本机默认不强跑签名 Keychain 测试与 Release build：涉及 Sync/Keychain 时跑签名 Keychain；涉及泛型或编译配置、或 CI 报 Release 错时跑 Release build。GitHub Actions 托管 CI 在合并前按分类把关六项重型门禁；下方七步保留供托管 CI 对齐及特殊场景使用。

Quality 站禁止默认重跑全量 `xcodebuild`，应审查代码、核对合同与 Code 站门禁日志并检查 Swift 格式；仅发现疑点时定向补跑单个 `-only-testing:` 用例。本机重型 `xcodebuild` 并发上限为 2 槽，多线并行时最多两条线同时占用模拟器执行。默认模拟器为 `iPhone 17 Pro`；使用等价机型时在报告说明。

## 分级与证据复用

合并前按 `docs/CI_CHANGE_CLASSIFICATION.md` 取得适用的托管 CI 结果。Quality 核对 Code 站证据，Publish 在文件字节、比较基线、依赖与环境不变时按 `docs/AI_WORKFLOW.md` 复用有效证据；否则补跑受影响检查。

质量证据可按 `docs/AI_WORKFLOW.md` 的最终内容、基线、环境和覆盖条件复用；不能因此跳过必需门禁。明确要求重跑时重跑；证据仍有效时，仅再次要求 merge 不自动触发重复全套验证。

## Swift 格式命令

相对推送目标分支（通常为默认分支或当前 PR 基线）的变更 `.swift` 文件，在 **commit 前且 push 前** 必须全部通过：

```bash
xcrun swift-format format --in-place --configuration .swift-format <file>
xcrun swift-format lint --strict --configuration .swift-format <file>
```

`lint --strict` 失败即停止；**不得** commit 或 push。推荐先 `format --in-place` 再 `lint`，避免 CI `Check Swift formatting` 反复红灯（历史：PR #100 多次卡在换行/折行）。

## 七步命令（托管 CI 对齐及特殊场景）

1. **（若改了 RIME 二进制依赖）** `bash scripts/ensure_rime_vendor.sh fetch`
2. **（若有 Swift 改动）** 先满足 `AGENTS.md`「Swift 格式硬门槛」（与 CI `Check Swift formatting` 对齐）
3. **KeyboardCore：** `swift test --package-path Packages/KeyboardCore`
4. **RimeBridgeTests：**
   `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test`
5. **App + Keyboard 测试（含 UniverseKeyboardTests / KeyboardTests）：**
   `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test`
6. **签名 Keychain 集成：** `Universe Keyboard` Debug scheme、同上 destination，使用
   `CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO`，并以
   `-only-testing:UniverseKeyboardTests/RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem`
   执行 `test`（与 CI 的 `test-rime-sync-keychain` 对齐）。无签名的步骤 5 不替代此检查。
7. **Release build：** 同上 destination，`-configuration Release` 的 `build`（参数与 CI 一致）。Debug `test` 已覆盖 Debug 编译，不再单独跑 Debug `build`。

**本机范围：** 纯文档且无 Swift / 工程 / 测试文件改动时，可跳过 3–7，但须在完成报告中写明「docs-only，跳过 xcodebuild」。只改 `Packages/KeyboardCore` 时至少跑步骤 3；改主 App / Extension / 测试 target 时应执行相应定向测试，不能只跑 KeyboardCore。

修改 `.github/workflows/**`、`scripts/ci/**` 或分类规则本身时不得使用 docs-only
例外；必须验证完整路径和 docs-only 路径，并在 merge 前取得 hosted run 证据。

**改完测试或部署意图后：** 必须跑到会执行该用例的 target（例如改了 `UniverseKeyboardTests` 就须在步骤 5 的 scheme 中定向执行该测试类，不能只跑 KeyboardCore）。
历史教训：#48 合并后 CI 红在 `RimeSettingsStoreTests`（签名 `schema=all` 与测试种子不一致）——本地若只跑 KeyboardCore 过滤套件会漏掉。
