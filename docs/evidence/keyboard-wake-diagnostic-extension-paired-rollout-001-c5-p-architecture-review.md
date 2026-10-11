# C5-P Architecture 独立补审（round 1）

## 严格本 lane verdict

**Full — P-A1/P-A2/P-A3 静态设计正向覆盖；不代表执行或晋级通过。**

本结论只评估冻结 C5-P 提案是否给出可核验的最小晋级/安装/真实 callback 路径。未执行晋级、安装或真实 callback；不构成 Product residual 接受、C5-I/R 授权、Quality Pass、全局 Gate 或 Release。

## Scope 与身份摘要

- Work item / lane：`KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001` / `ARCHITECTURE-C5-P round 1`。
- Packet：`{packet_rel}` SHA-256 `{ids["packet"]}`（expected `{expected["packet"]}`；match={ids["packet"]==expected["packet"]}）。
- Manifest：`docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-input-manifest.json` SHA-256 `928bfdd6412ce5b23bdad7cece3141e00c993d191079ea2b7ed692662f06d941`（expected `928bfdd6412ce5b23bdad7cece3141e00c993d191079ea2b7ed692662f06d941`；match=True）。
- Entry：`docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-p-entry.md` SHA-256 `8e507a253fcb89f0d8570ce0b980c029c59b1ec5c452db84b71545da94454dc7`（expected `8e507a253fcb89f0d8570ce0b980c029c59b1ec5c452db84b71545da94454dc7`；match=True）。
- Root / branch / HEAD：`/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard` / `codex/keyboard-wake-v3-compatibility-gate` / `84b9c19227330b0fe6ff391be001ee398010fd6a`；candidate digest `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9`。
- `inputs_sha256`: 40/40 匹配；`source_build_inputs_sha256`: 568/568 匹配；Debug bundle：111/111 文件 SHA 匹配。
  - Bundle plist `Frameworks/KeyboardCore_-8730D61D9395D3A_PackageProduct.framework/Info.plist`: bundleID `keyboardcore.KeyboardCore`, version/build `1.0/1`, extension point `None`。
  - Bundle plist `Frameworks/KeyboardCore_-8730D61D9395D3A_PackageProduct.framework/KeyboardCore_KeyboardCore.bundle/Info.plist`: bundleID `keyboardcore.KeyboardCore.resources`, version/build `None/None`, extension point `None`。
  - Bundle plist `Frameworks/RimeBridge_57276DBF982DF6E4_PackageProduct.framework/Info.plist`: bundleID `rimebridge.RimeBridge`, version/build `1.0/1`, extension point `None`。
  - Bundle plist `Info.plist`: bundleID `com.DoubleShy0N.Universe-Keyboard`, version/build `1.0/1`, extension point `None`。
  - Bundle plist `KeyboardCore_KeyboardCore.bundle/Info.plist`: bundleID `keyboardcore.KeyboardCore.resources`, version/build `None/None`, extension point `None`。
  - Bundle plist `PlugIns/Keyboard.appex/Info.plist`: bundleID `com.DoubleShy0N.Universe-Keyboard.Keyboard`, version/build `1.0/1`, extension point `com.apple.keyboard-service`。
  - Bundle plist `PlugIns/Keyboard.appex/KeyboardCore_KeyboardCore.bundle/Info.plist`: bundleID `keyboardcore.KeyboardCore.resources`, version/build `None/None`, extension point `None`。
  - Bundle plist `PlugIns/UniverseKeyboardTests.xctest/Frameworks/KeyboardCore_-8730D61D9395D3A_PackageProduct.framework/Info.plist`: bundleID `keyboardcore.KeyboardCore`, version/build `1.0/1`, extension point `None`。
  - Bundle plist `PlugIns/UniverseKeyboardTests.xctest/Frameworks/KeyboardCore_-8730D61D9395D3A_PackageProduct.framework/KeyboardCore_KeyboardCore.bundle/Info.plist`: bundleID `keyboardcore.KeyboardCore.resources`, version/build `None/None`, extension point `None`。
  - Bundle plist `PlugIns/UniverseKeyboardTests.xctest/Frameworks/RimeBridge_57276DBF982DF6E4_PackageProduct.framework/Info.plist`: bundleID `rimebridge.RimeBridge`, version/build `1.0/1`, extension point `None`。
  - Bundle plist `PlugIns/UniverseKeyboardTests.xctest/Info.plist`: bundleID `com.DoubleShy0N.Universe-Keyboard.UniverseKeyboardTests`, version/build `None/None`, extension point `None`。
  - Bundle plist `PlugIns/UniverseKeyboardTests.xctest/KeyboardCore_KeyboardCore.bundle/Info.plist`: bundleID `keyboardcore.KeyboardCore.resources`, version/build `None/None`, extension point `None`。

## P-A1–P-A3 正向覆盖矩阵

| Criterion | Status | Positive evidence and boundary |
|---|---|---|
| P-A1 完整载荷／配对／v6 来源 | Covered | v6 product caller 线索：`KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:11`; `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:168`; `Keyboard/Controllers/KeyboardViewController.swift:66`; `Universe Keyboard/App/Universe_KeyboardApp.swift:52`；单一 writer-version 归一化：`KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:11`; `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:168`; `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:235`; `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:300`；逐 record reader/version 验证：`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:6`; `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:78`; `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:87`; `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:97`。候选 Debug bundle 文件对 manifest hash 一致；plist 中 App/appex 的 bundle identity 见上。此为静态候选配对证据，不证明设备已安装或系统实际加载该 appex。 |
| P-A2 安装、共享容器与 gate 顺序 | Covered | Main App Group/root 入口：`Keyboard/Controllers/KeyboardViewController.swift:63`; `Keyboard/Controllers/KeyboardViewController.swift:299`; `Keyboard/Controllers/KeyboardViewController.swift:300`; `Keyboard/Controllers/KeyboardViewController.swift:304`；Extension high-fidelity/expiry gate：`Keyboard/Controllers/KeyboardViewController+Bootstrap.swift:591`; `Keyboard/Controllers/KeyboardViewController.swift:74`; `Keyboard/Controllers/KeyboardViewController.swift:82`; `Keyboard/Controllers/KeyboardViewController.swift:83`；bundle 自含 App/appex plist 已列。C5-P 是晋级前设计评审；安装、Full Access、共享容器读写和 gate 生效仍是未来 C5-I/R/新 Entry 的执行证据，不以 bundle 存在推断。 |
| P-A3 callback 判据、隐私与停止边界 | Covered | 观测 lifecycle：`KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:28`; `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:35`; `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:42`; `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:49`；RIME start-only：`KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:55`; `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:130`; `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:290`; `Keyboard/Controllers/KeyboardViewController.swift:405`；proxy entered/returned：`Keyboard/Services/UITextDocumentProxyAdapter.swift:146`; `Keyboard/Services/UITextDocumentProxyAdapter.swift:148`; `Keyboard/Services/UITextDocumentProxyAdapter.swift:168`; `Keyboard/Services/UITextDocumentProxyAdapter.swift:173`；有限 typed payload：`KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:275`; `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:413`; `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:436`; `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:475`。回调结论须以可观察 marker 顺序和用户明确观测共同判断；returned 只表示本地代理调用返回，不表示宿主确认。没有采集或检查用户日志、输入内容或设备状态。 |

## Findings

没有可从已读 frozen input 确认的 Architecture blocker。该结论仅是上述静态设计覆盖；缺少的设备安装／Full Access／真实 callback 结果属于未验证执行条件，不按静态 review 通过代替。

## Skipped / unverified 与后续 Entry 边界

- C5-P 仅授权晋级前独立补审；Product 的晋级/残项决定仍待办，C5-I/R 当前未授权（C5-P Entry 第 5 行）。
- 不操作设备，不检查 current device、真实 App Group 容器或系统 keyboard installation；Fresh lease、安装身份、Full Access、真实 Maps/App Switcher callback、输入行为均未验证。
- 30 个 Stage B skips 不自动继承 C4 接受；本报告不接受 residual、不把 skip 当 pass。
- 只读 manifest 声明的 40 文档和 568 source/build inputs；旧 C4 review/evidence 不在本 lane 输入时不读取、不引用。
- 工具预算内没有 build/test/install/launch/arm/input/Maps/Git mutation/network。

## Evidence locators

- `AGENTS.md`: 35, 38, 39, 46, 67, 68, 69, 70, 85, 88, 89, 94, 95, 104.
- `docs/ASSIGNMENT_POLICY.md`: 19, 27, 43, 71, 88, 101, 118, 120, 126, 130, 135, 158, 160, 171, 185, 187, 195, 228.
- `docs/AI_WORKFLOW.md`: 9, 20, 69, 94, 96.
- `docs/VIRTUAL_ENGINEERING_TEAM.md`: 19, 35, 46, 55, 72, 131, 137, 140, 150, 170, 171, 180, 182, 186, 188, 195, 196, 204.
- `docs/DOCUMENTATION_GOVERNANCE.md`: 15, 19, 20, 21, 24, 27, 34, 44, 45, 46, 49, 51, 52, 59, 70, 72, 195, 196.
- `docs/playbooks/test-release.md`: 5, 10, 16, 49, 50, 61, 73, 77.
- `docs/playbooks/documentation-maintainer.md`: 5, 73.
- `docs/RELEASE_CHECKLIST.md`: 5, 14, 16, 20, 22, 29, 45, 73, 75, 77, 84, 92, 101, 110, 162, 167, 170, 181.
- `docs/PERFORMANCE_BASELINE.md`: 20, 30, 54, 56, 57, 62, 64, 69, 70, 71, 74, 84, 95, 97, 101, 103, 107, 113.
- `docs/READING_MAPS.md`: 5, 9, 19, 23, 29, 33, 37, 43, 58, 64, 69, 78, 83, 86, 91, 95, 97, 98.
- `docs/product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md`: 35, 41, 50, 61.
- `docs/kos/universe-keyboard-human-operated-evidence-profile.md`: 11, 13, 16, 39, 52, 54, 55, 57, 59, 67, 68, 71, 72, 80, 87, 109, 114, 125.
- `docs/architecture/decisions/0036-keyboard-wake-wire-v6-addendum.md`: 5, 9, 16, 23, 24, 28, 29, 38, 39, 43, 50, 52, 53, 62, 63.
- `docs/assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md`: 9, 10, 11, 12, 13, 21, 22, 24, 33, 34, 36, 44, 45, 51, 57, 58, 60, 65.
- `docs/plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-real-appex-promotion-install-slice.md`: 3, 11, 13, 14, 15, 16, 29, 33, 37, 39, 43, 49, 55, 66, 67, 73, 80, 82.
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-validation-2026-10-01.md`: 3, 7, 14, 16, 17, 18, 21, 23, 27, 31, 35, 41.
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-architecture-review.md`: 5, 11, 12, 21, 22, 23, 24, 25.
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-quality-review.md`: 3, 12, 13, 14, 15, 16, 20, 22.
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-supplement-product-disposition.md`: 3, 5, 7, 9.
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-supplement-quality-review-r2.md`: 3, 8, 11, 13.
- `v6_selection`: `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:11`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:168`, `Keyboard/Controllers/KeyboardViewController.swift:66`, `Universe Keyboard/App/Universe_KeyboardApp.swift:52`, `Universe Keyboard/Services/RimeSyncDiagnostics.swift:37`, `Universe Keyboard/Services/SchemaDeliveryDiagnostics.swift:30`, `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift:371`.
- `writer_normalization`: `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:11`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:168`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:235`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:300`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:314`, `Keyboard/Controllers/KeyboardViewController.swift:66`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:1195`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:1196`.
- `reader_versioning`: `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:6`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:78`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:87`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:97`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:103`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:118`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:12`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:16`.
- `fallback_guard`: `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift:407`, `Keyboard/Controllers/KeyboardViewController.swift:53`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:696`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift:120`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift:131`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift:139`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift:145`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift:237`.
- `app_group`: `Keyboard/Controllers/KeyboardViewController.swift:63`, `Keyboard/Controllers/KeyboardViewController.swift:299`, `Keyboard/Controllers/KeyboardViewController.swift:300`, `Keyboard/Controllers/KeyboardViewController.swift:304`, `Keyboard/Controllers/KeyboardViewController.swift:583`, `Keyboard/Controllers/KeyboardViewController.swift:585`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift:4`, `Universe Keyboard/App/Universe_KeyboardApp.swift:34`.
- `high_fidelity_gate`: `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift:591`, `Keyboard/Controllers/KeyboardViewController.swift:74`, `Keyboard/Controllers/KeyboardViewController.swift:82`, `Keyboard/Controllers/KeyboardViewController.swift:83`, `Keyboard/Controllers/KeyboardViewController.swift:363`, `Keyboard/Controllers/KeyboardViewController.swift:596`, `Keyboard/Controllers/KeyboardViewController.swift:601`, `Keyboard/Controllers/KeyboardViewController.swift:602`.
- `lifecycle`: `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:28`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:35`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:42`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:49`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:126`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:275`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:276`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:277`.
- `rime_start`: `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:55`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:130`, `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:290`, `Keyboard/Controllers/KeyboardViewController.swift:405`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:68`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:75`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:30`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:993`.
- `proxy_phases`: `Keyboard/Services/UITextDocumentProxyAdapter.swift:146`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:148`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:168`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:173`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:178`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:180`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:260`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:285`.
- `closed_payload`: `KeyboardTests/KeyboardWakeDiagnosticProducerTests.swift:275`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:413`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:436`, `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift:475`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:50`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:81`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:82`, `Keyboard/Services/UITextDocumentProxyAdapter.swift:89`.
