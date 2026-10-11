# QUALITY-C7-B1 round 4：候选晋级前准备协议独立验收

**范围结论：Scoped Positive preparation opinion。** P1、P2、P3 均 Covered；这只确认晋级前准备材料相互一致、风险和停止条件明确。它不是 Product 对残项的接受，不是安装授权、实际 candidate runtime 验收或整体 Gate/Release 结论。候选仍未安装，paired-products 记录 installed=false、runtime_verified=false。

| Criterion | 结论 | 独立核对 |
|---|---|---|
| P1 候选身份与既有审查对齐 | Covered | 冻结 revalidation 的 source/build 571、Vendor 630、payload 78 均为零差异；candidate ddd5579ee6dce39deea3c63487cfe6817c419628c4471c0b3e9298d9c47f3ca9 与 build-input-manifest、paired-products、Quality round 3 一致，payload digest 为 5a935a0e648fd8939b1e56b4e40f5da24828a0f2e6bfe9e6365b98ca3a2a80e4。paired-products 记录 78 文件、无 test host，签名验证成功；Quality round 3 只给 host-artifact 意见，不证明安装/runtime。Architecture round 3 的总体 Partial 保留；Architecture R4 只补足两 executable 与配对 xcent 的 entitlement bytes/identity 核对，不关闭整体 Architecture 状态。 |
| P2 三套结果、skip 和 Keychain 对账 | Covered，保留边界 | RimeBridgeTests 85/0/20（总 105），App+Keyboard unsigned 421/0/10（总 431），signed unique Keychain 1/0/0（总 1）。冻结 skip 清单 30 个 ID 全唯一且均有原因，按 lane 为 app 10、rime 20，与两个 xcresult 的 10+20 skips 对上。独立 Keychain pass 不抹去 unsigned suite 中对应的 skip；其余 29 个 skip 未获本轮 Product 接受。432 项工具发现与 xcresult 实际 431 项的差额仍为 UNKNOWN，现有 preview 不足逐项对应；不为凑数重跑。 |
| P3 安装前保护与停止协议 | Covered（执行仍 Hold） | 计划要求安装前重新核对独占设备、准确 source/bundle、诊断值及存在性，并完整备份当前 Main App data 与 App Group 到私有 scratch、逐字节验证；任一缺失即不安装。重建前的 827/4 备份不能代替当前新基线备份。安装后先比对 paired payload 与容器身份，漂移即停并按完整恢复来源处置，不自动启动或猜测复制 metadata。计划保留旧数据未恢复的限制。 |

**保留的未决项与下一步。** 30 个 skip 均仍是未验证；Product 尚须对其余 29 项给出本阶段非阻塞/未验证处置，signed Keychain pass 只覆盖其独立集成用例。57 条格式诊断及原 F2/F3、旧数据丢失和整体 Hold 不因本意见改变。安装前仍需新的精确 Entry、独占状态确认、对当前新环境重新做完整 data/App Group 备份并验证，以及安装/恢复路径的独立授权；当前候选没有安装或 runtime 证据。本 reviewer 未访问设备，也未执行 build/test/install。

**计时完整性。** Packet SHA-256 a621b310200706e97e5b0470362c7751471ef08051c2d646d9ac4ee35aa6f92d 与 canonical digest 匹配，17/17 明确输入哈希匹配。首次命令在进程内采集了 UTC/unix，但因 digest 字段名识别错误而在打印前退出；按 packet 规则，实际 review start 与累计 elapsed 记为 null，不以第二次观察或文件时间推算。后续已知时间及缺失项见 usage；因此不声称有可审计的精确总墙钟时长。共计 7/12 底层调用，未扩围；时间硬上限的精确合规性因 start 样本未落盘而不能独立证明。
