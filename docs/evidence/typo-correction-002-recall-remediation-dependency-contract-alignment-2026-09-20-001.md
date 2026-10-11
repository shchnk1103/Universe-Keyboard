# TYPO-CORRECTION-002 Recall Dependency Contract Alignment 001

- Authorization：[`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DEPENDENCY-CONTRACT-ALIGNMENT-CODE-FIX-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-DEPENDENCY-CONTRACT-ALIGNMENT-CODE-FIX-001.md)
- Worktree：`/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001`
- Base HEAD：`162b09fd58ba60538a944026b1902efa405c75aa`
- Changed file：`UniverseKeyboardTests/RimeSettingsStoreTests.swift`
- Previous file SHA-256：`788d6fd0fc814a034a61873cda6ba67432e21042f7953c8849212f350e8066f9`
- Final file SHA-256：`737206cf1020c35e339bf3dd2a461ce8a1d77c440a22eebe9b8741e3b444705b`
- Previous manifest SHA-256：`709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207`
- Final manifest：[`source manifest 002`](typo-correction-002-recall-remediation-publication-staging-source-manifest-2026-09-20-002.txt)
- Final manifest SHA-256：`e2b4373c0797a0959b0b0da10c1db01cf4fa81cfe25903c7d9726942edab465c`

## 改动边界

只移除测试 fixture 对 clean base 不存在的 `librimeVersion` 属性、初始化参数和 result initializer 参数；保留 `runtimeSmokePassed` 的成功 fixture 语义。没有修改任何 production Swift、RIME bridge、schema、Package/Xcode 工程或 KeyboardCore recall source。

## 验证

- `swift-format format --in-place` + strict lint：通过，仅作用于该文件。
- 四个 recall 相关 Swift 文件 strict lint：全部通过。
- 五项 final manifest：全部 hash 匹配。
- `git diff --check`：通过。
- 下一 Run：`TC2-RECALL-QUALITY-20260920-002`，见 [`quality run 002`](typo-correction-002-recall-remediation-quality-run-2026-09-20-002.md)。

## Non-claims

- 这是 test fixture contract alignment，不是 parent `RimeDeploymentService` provenance contract 的发布。
- 不构成 runtime、真实 RIME、设备行为、INT-003、QA-001、paired performance、180 ms、Product/Quality/Release Gate 或 publication 结论。
- 未 commit、push、PR、merge、TestFlight、Release，也未关闭 parent/child Assignment。
