# Architecture R3 独立补核：R2 H2 embedded entitlements

状态：**Partial / incomplete**。本轮仅处理 R2 H2 中“最终 App 与 appex 的 `__TEXT,__entitlements` 原始 bytes 是否逐字节等于对应 xcent”的缺口；没有复审 H1/H3，也没有作安装、runtime、Gate 或 Release 判断。

## 冻结范围与停止点

批准 packet `/private/tmp/ukey-wake-c7b3-20261002/current-round/arch-r3-approved-packet.json` 的摘要已按 `packet_digest_sha256` 外的 sorted compact JSON、`ensure_ascii=false`、UTF-8 核对，匹配 `4e9b7ea1d3ca82bce65438c52756562da1094687d2219c86324c4819f0b06058`。本人为独立 Architecture reviewer，未参与实现；scope ACK 与第 2 call checkpoint 已发给 root。

packet 固定了两个最终 Mach-O（二者均在 `allowed_binary_inputs` 中），以及两份 frozen xcent 内容输入。读取并核对 allowlist digest 后，我仅打开了 packet 列明的 `paired-products.json` 与 `simulator-entitlements.json`；二者 SHA-256 均与 `allowed_content_inputs` 一致。解析停止在 `simulator-entitlements.json#/bundles[*]/simulated_xcent`：其中指向 `/private/tmp/ukey-wake-c7b3-20261002/CandidateDerivedData/...`，而 packet 列明的 xcent 输入位于 worktree 的 `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-artifacts/app-Simulated.xcent` 与 `keyboard-Simulated.xcent`。尚未完成这两组 locator 的只读映射校验，因此没有读取任何 Mach-O 或 xcent 原始 bytes，也没有宣称二者相等或不等。没有调用 `otool`，没有解析源码或 Vendor。

具体未覆盖项只有一个：H2 的最终 Mach-O embedded entitlement bytes 与 packet-listed xcent 的独立 byte-for-byte 比较。冻结 JSON 中记录的 section/xcent digest 不能替代本轮指定的原始 bytes 比较。由于未观察到产物矛盾，这是 **incomplete**，不是新发现的 binary mismatch。后续若有新的明确授权，应先用 packet allowlist 中两个 repo xcent 输入建立映射，再用 Python 解析 arm64 Mach-O load commands 的 `__TEXT,__entitlements` section，并分别比较长度、SHA-256、原始 bytes 与 App Group plist 值。

本轮没有设备、模拟器、安装、构建、测试、LLDB、网络或 repo 写入；没有产生 runtime / Gate / 候选安装结论。旧 R2 H2 finding 保持未解决。
