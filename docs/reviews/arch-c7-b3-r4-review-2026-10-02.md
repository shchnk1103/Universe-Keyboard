# Architecture R4 独立静态补核：embedded entitlements

状态：**Covered**。唯一 criterion 为两个最终 thin arm64 Mach-O 的 `__TEXT,__entitlements` section 原始 bytes，与 packet 明确配对的两份冻结 repo xcent 一致，并核对有限的 App Group 与 application identifier 值。

批准 packet `/private/tmp/ukey-wake-arch-r4-20261002/approved-packet.json` 的 SHA-256 为 `23853166ccc8a27cc19e74fddcba8458a4085ce12dc0b1e75b37ab5909f38155`；按排除 `packet_digest_sha256`、sorted compact JSON、`ensure_ascii=false`、UTF-8 独立计算后匹配。packet 指定的两个 xcent 文件也分别与其 allowlist SHA 匹配。

我用独立 Python parser 直接遍历 thin Mach-O 64-bit header 与 `LC_SEGMENT_64` section records，验证 arm64 cputype、唯一 `__TEXT,__entitlements` section、文件 offset/size 与文件边界，再提取原始 section bytes。没有使用 `otool` 的文本 size，也没有查看源码/Vendor。

| Pair | Mach-O | `__TEXT,__entitlements` | embedded SHA-256 = xcent SHA-256 | 原始 bytes / plist | 有限字段 |
|---|---|---:|---|---|---|
| App | `Universe Keyboard.app/Universe Keyboard` | offset 13416，414 bytes | `6610a8c02dfe5b877f5be595941b807a687c7838e2f4b54a80b4c6726b821a6c` | 完全相等 | App Group `group.com.DoubleShy0N.Universe-Keyboard`；application identifier `C33N6HTS9N.com.DoubleShy0N.Universe-Keyboard` |
| Keyboard | `Keyboard.appex/Keyboard` | offset 10266，423 bytes | `1b5eca79f033b12423739696ae50c8dfcd679ed6484803e2e340787aee149b7b` | 完全相等 | App Group `group.com.DoubleShy0N.Universe-Keyboard`；application identifier `C33N6HTS9N.com.DoubleShy0N.Universe-Keyboard.Keyboard` |

两组解码 plist 均与对应 xcent 相等，唯一 criterion 已覆盖；本轮没有发现这项静态 entitlement 字节绑定的差异。

本意见仅确认上述静态 Mach-O/xcent 绑定，不证明签名、安装、App Group 容器可用性、Keychain、实际 iOS 测试、运行时行为、candidate installation、Product Gate 或 Release。没有设备、Simulator、构建、测试、LLDB、网络或 repo 写入；未复审 H1/H3，也未修改 R2/R3 产物。


## 补充核验：packet executable identity（同一 R4 轮）

按 packet `allowed_binary_inputs` 对两个最终 executable 的原始文件再次计算 SHA-256，期望值与当前文件值均相同；R4 call 2 的 parser 也在提取 entitlement section 前执行了同一 allowlist hash 比较。

- App `Universe Keyboard.app/Universe Keyboard`：`0af5b7f021a2eb82142521f8ba1db3f87fc6712f4f19c49d5cd229d2fb133fe8`（packet = observed）。
- Keyboard `Keyboard.appex/Keyboard`：`e059dfbfef672553b51d9ce2a3097348f3c40129c8afaa27b58fd90918cbd692`（packet = observed）。

这项补充只记录既有 criterion 的 exact executable identity，不扩展到 H1/H3 或 runtime。
