# F3 Quality 独立审查

结论：**Pass with conditions**，仅表示当前 F3 候选的 Quality 证据足以进入另行授权的 F4。此结论不证明宿主通知真实送达、控制器运行时恢复、Maps 输入恢复，也不是整个修复或 Release 的通过结论。

审查身份为 /root/m2r2_quality_r1，lane 为 F3-quality-implementation round 1。冻结包 SHA-256 为 34a37a0b8f3dbeba81b015c78985adc295c69440f0f913bc5a18d2ad108cb281，已核对匹配。worktree 为 /Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard，branch 为 codex/keyboard-wake-v3-compatibility-gate，HEAD 为 84b9c19227330b0fe6ff391be001ee398010fd6a，staged paths 为 0。冻结包列出的 122 个允许文件大小和 SHA-256 全部匹配；未读取包外源文件。1156 条构建输入按允许方式只读文件并复算 SHA-256，1156/1156 匹配。

## Q1 — 候选身份、格式与 focused 测试：Covered

F0 entry manifest 冻结了原有 KeyboardViewController.swift、KeyboardViewController+Bootstrap.swift 和 project.pbxproj 字节；RecoveryGate.swift 与其测试文件当时不存在。F1 final-five-hashes 将五文件候选绑定到当前 worktree。F1 root receipt 记录三个既有文件的 patch 重建与当前字节相符、两个新文件副本精确。当前五文件逐字节 SHA 与冻结包相符。

F2 actor retest 将唯一后续源码差量限定在 KeyboardHostLifecycleRecoveryGateTests.swift：F1 SHA 为 e9ef614702dff163ea1f1723e577f2f5af97394c919fb7d03544e15356d3c1a3；F2 当前 SHA 为 b4e8c6c1fdb79dc9f27ff3355e705a0dae0f45a07f9fb4610a51e43a7256b8bf。F2 交付记录为两行、增加 23 bytes，并记录反向替换可恢复 F1 SHA。变化限于测试 fixture；生产控制器、gate、工程文件与 1156 输入均未因该修正变化。F2 full matrix 的原测试文件和修后候选不是同一字节身份，所以以下覆盖明确分开报告。

F2-0 strict Swift lint 对四个 Swift 候选文件 exit 0；修后 GateTests 再次 strict lint exit 0。tracked whitespace check exit 0；untracked whitespace 检查的 no-index 子命令对预期差异返回 1、无诊断，外层收据 exit 0。未重跑这些命令。

我直接用 xcresulttool 读取修后 focused.xcresult：KeyboardHostLifecycleRecoveryGateTests 的 17 个方法全部 Passed，0 Skipped、0 Failed；结果设备为 iPhone 18 Pro、iOS 27.0、UDID 405D994F-28CB-4F89-BB22-B64AD81C05A2。Focused log 显示修后测试文件确实经过 SwiftCompile。原七项 actor-isolation 诊断在修后证据中均为 0；四条仍在的 AppIntents metadata extraction skipped 警告属于工具警告，不能宣称整个日志无警告。原 App full xcresult 中同一组 17 个方法也各自 Passed；方法集合与修后 focused 结果一致。

对应证据：docs/evidence/keyboard-wake-host-activation-fix-001-f0-artifacts/entry-manifest.json、docs/evidence/keyboard-wake-host-activation-fix-001-f1-artifacts/final-five-hashes.json、root-receipt.json、docs/evidence/keyboard-wake-host-activation-fix-001-f2-actor-retest-validation-2026-10-04.md、docs/evidence/keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/diagnostic-and-gate-verification.json、gate-summary.json、gate-actual-results.json、lint-whitespace-receipt.json，以及私有 focused.xcresult 与 focused.log。

## Q2 — F2 矩阵、skip 身份与证据复用：Covered with residual

只读 xcresulttool 对原 F2 矩阵得到：

| Target | 实际结果 | 设备 / 命令边界 |
|---|---:|---|
| KeyboardCore | 1194 tests，0 failures | F2-1 request/receipt 与允许读取的原日志 |
| RimeBridgeTests | 105 total：85 Passed、20 Skipped、0 Failed | iPhone 18 Pro / iOS 27.0；parallel testing disabled，Swift 6 strict concurrency、warnings-as-errors |
| Universe Keyboard Debug | 448 total：438 Passed、10 Skipped、0 Failed | 同一 UDID/runtime 与 strict settings |
| Release build | request/receipt exit 0 | F2-4 为构建，不是 Release 发布或运行 |
| 单独签名 Keychain lane | RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem Passed 1/1 | CODE_SIGNING_ALLOWED=YES，单项测试 |

RimeBridge 的 20 个实际 skipped identities 与 rimebridge-skip-list.json 相符；App 的 10 个实际 skipped identities 与 app-keyboard-skip-list.json 相符。App 其中一项是 unsigned host 上跳过的 Keychain 测试。另行签名 lane 的同名测试 Passed 1/1；它补充了该项的 signed coverage，但不删除 unsigned full-suite xcresult 中的 Skip，也不把总矩阵改写成无 skip。Human 的 20+10 skip disposition 明确限定 F2。

F2 全矩阵运行早于两行 actor fixture 修正；因此不能把原 App 448 说成修后单次全套。修后 focused run 同 target、配置、UDID/runtime 和 Swift strict 设置下独立通过受改动影响的 17 个方法。Core、RimeBridge 与生产源码未变；F2 全矩阵的 App 其余结果可作为未改测试的先前证据，但汇总时必须保留“组合证据、非同一次修后 448 全套”。F2 actor retest 的 1156 输入清单与当前逐项 hash 匹配。F2 release build 只按允许的 request/receipt 核到 exit 0；其 xcresult 不在可读取的精确私有 allowlist 中，本审查没有读取。

残项 Q2-R1：F2 的 skip 接受不自动延伸到 F3。责任方为 Product Lead / Human Product Owner；F4 前须明确保留这些项目为未验证残项，或另作范围明确的处置。此审查不将它们称为通过。

对应证据：docs/evidence/keyboard-wake-host-activation-fix-001-f2-execution-artifacts 下的 F2-1、F2-2、F2-3、F2-4、F2-5 request/receipt、app-keyboard-skip-list.json、rimebridge-skip-list.json、两份 skip product decision，以及只读读取的 app-keyboard.xcresult、rimebridge.xcresult、keychain.xcresult；修后 focused evidence 位于 docs/evidence/keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/。

## Q3 — 备份来源、停止记录与环境差量：Covered

原 STOP.json 保留：首次 before-backup verification 因 provenance 差异停止，未启动测试、未改源码、未自动重试。随后 Human 仅接受本轮 com.apple.provenance 903 项新增、122 项改写、0 缺失；记录明确 all_metadata_exact=false、scope_expanded=false，不能扩写为所有 metadata 完全一致。备份接受回执记录对同一备份与 live 状态复核通过后继续。

修后 focused request/receipt 记录只运行一次，38.175844 秒、exit 0、无 timeout。前后 main-data、App Group、installed-app 的完整库存均相等，没有新增、删除或改动；环境回执记录两次 after reads 一致、目标进程已退出、restored=false。因此无需恢复，且不得据此声称做过恢复、安装后运行或输入健康验证。

对应证据：docs/evidence/keyboard-wake-host-activation-fix-001-f2-actor-retest-artifacts/STOP.json、backup-difference-classification.json、backup-accepted-receipt.json、provenance-product-disposition.json、execution-entry.json、focused-request.json、focused-receipt.json、before-after-delta.json、environment-after-receipt.json。

## F4 条件与审查边界

可以将 F3 的静态实现与 Quality 证据交给 Product 进入单独授权的 F4。F4 必须验证真实 NSExtensionHost active/resign 通知的送达及对象/context 匹配，观察 controller 的实际恢复动作，并在新鲜独占授权下完成 Maps 运行证据。以上仍未由 gate 单元测试证明。Q2-R1 的 F2 skip disposition 也须在 F4 前被明确保留为未验证残项或另行处置。

本次仅做允许文件的只读审查与 xcresulttool 读取，没有运行 build/test/lint，没有操作 Simulator/LLDB，没有仓库写入。结论不扩展到 Maps 根因、整体修复通过或 Release。
