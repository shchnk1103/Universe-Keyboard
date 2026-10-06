# QUALITY-C7-B1 round 3：host candidate 定点 Quality

本轮独立 reviewer 未参与实现。packet digest `793355b0508578e7f68fba73ae2fca769302420bd34f00465f01231e518c8233` 匹配；26/26 内容输入、1279/1279 hash-only 输入匹配，branch/HEAD 与 packet 一致。仅审 H1–H3 的 host artifact 证据。

| Criterion | 覆盖 | 判定 |
|---|---|---|
| H1 | Covered | source/build、Vendor、payload、standalone/no-testhost 与候选身份绑定成立。 |
| H2 | Covered | bundle 签名、embedded Simulator entitlements/xcent/App Group、Mach-O UUID/symbol 对照成立。 |
| H3 | Covered | 保留 host-only 边界与所有未完成验证/旧 finding。 |

**有限结论：Positive scoped host-artifact opinion。** 不构成安装放行、实际 suite、runtime、Product/Gate、Release 或整体 Quality 通过。

**C7-B1-H1 — Bound。** `build-input-manifest.json` 中 571 项 source/build 和 630 项 Vendor SHA 全匹配当前输入；十文件 source identity 为 `3c45e4d76a858d4d5484496d216cb8b1dc6a1d59d5bc3311eb5a2e451602e0e0`。`preflight-equivalence.json` 只列已被 C7-B1 R2 接受的 `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift` 一个差异，missing 为空。专用 CandidateDerivedData 下的 generic iOS Simulator arm64 standalone `build` 使用 Swift 6 strict concurrency/warnings-as-errors，host retry exit 0，candidate digest `ddd5579ee6dce39deea3c63487cfe6817c419628c4471c0b3e9298d9c47f3ca9` 与命令、结果、manifest、paired product 一致。sandbox 首次 exit 74 是缓存/XPC 限制，未改源码，随后同 candidate host 重试成功。78 个最终 bundle payload 字节 SHA 全匹配，无缺失/差异；两个 bundle 均 1.0/build 1，`contains_test_host=false`、`installed=false`、`runtime_verified=false`。见 C7-B3 Entry、host candidate、`build-input-manifest.json`、`preflight-equivalence.json`、`paired-products.json`。

**C7-B1-H2 — Bound。** 我独立对 app 与 appex 执行只读 `codesign --verify --deep --strict`，均 exit 0，签名为 ad-hoc。常规 codesign entitlement 输出解析为空 `<dict/>`，不能据此推断 App Group 缺失。静态抽取两个 final executable 的 `__TEXT,__entitlements` 区段，与各自 Simulated.xcent 原始字节及 SHA 完全一致；两者均含 `group.com.DoubleShy0N.Universe-Keyboard` 和对应 application-identifier。六个清单 Mach-O 的 SHA/大小/`dwarfdump --uuid` 均匹配；`nm` 的 16 个预期探针符号全部出现在 `Keyboard.debug.dylib`。paired-products 没有独立 dSYM（0 项）；本轮只确认 Mach-O UUID/符号绑定，不声称有 dSYM 或证明未来 LLDB 局部参数可读。entitlement 细节见 `simulator-entitlements.json` 与两份 `.xcent`。

**C7-B1-H3 — Scope preserved。** 本结果只是 host standalone build，不是测试执行。实际 RimeBridge/App+Keyboard suites、fresh exclusive、设备、installed candidate、恢复来源、容器和 runtime 均需后续 Entry/授权。原 C7-B1 整体 Hold、F2/F3、57 条格式诊断及历史 30 skips 保持；没有接受 skip，也未批准安装、Gate 或 Release。来源为 C7-B3 授权/Entry、旧 Quality R2 review 和 C7-B3 host candidate 记录。

本轮未执行 build/test、Simulator/device/container/UI/LLDB/network、签名修改或 repo 写入；仅对冻结 artifact 做只读检查。完整证据和逐调用账本见 `quality-usage.json`。

**预算说明**：本轮实际 elapsed 超过 420 秒 soft delivery，但低于 600 秒 hard ceiling；准确首尾 UTC 与逐次底层调用记录见 `quality-usage.json`。
