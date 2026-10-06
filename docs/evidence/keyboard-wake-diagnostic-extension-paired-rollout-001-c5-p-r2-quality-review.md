# QUALITY-C5-P 独立 Quality Review Round 2

## Scope 与身份

本轮是 QUALITY-C5-P round 2 的只读确认，未参与实现。仅确认 D1–D3；不授权 Product 晋级/残项接受、C5-I/R、设备或运行采集。

冻结 packet SHA-256 92261372cf80f101519d2699dca35f8a49856964f04aeddfde7a48111dcb9535，manifest SHA-256 56d6c3b4875712dee712ef93c7e691fd0bf905cbdfd555b96539bed006e34f15，Entry SHA-256 f4ce5e922d70f15ff0c3de011cbe007b57a528b4379e9e004dc11b8dfffbc282，均与派发值匹配。HEAD 84b9c19227330b0fe6ff391be001ee398010fd6a、branch codex/keyboard-wake-v3-compatibility-gate、candidate af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9 匹配。直接重算 47/47 manifest 文档、568/568 source/build 文件和 111/111 Debug bundle 哈希，均无缺失或不匹配。

manifest 的 before_status_z_sha256 是本轮 packet/manifest/Entry 冻结前的历史状态，不是评审时状态摘要。当前只读 status digest 为 62b1bc8d864b3f13ea35a3989a31d54ae49b147e07fc2ba65dd1e20ead3779f9；root 说明冻结期间新增本轮 packet、manifest、Entry 和 owning Assignment bookkeeping，并确认 2518 项既有文件中只有 owning Assignment 变化、staged 为 0。这与 manifest 字段语义一致，不构成 source 或 bundle 漂移。该说明用于解释状态摘要，不替代 C5 Product 决定。

## D1–D3 确认

| D | 结论 | 依据与边界 |
|---|---|---|
| D1：身份与旧证据复用 | Covered | 三个冻结 SHA、HEAD/branch/candidate 及 47/568/111 输入哈希匹配。原 round 1 report SHA-256 e646bf55a3bbff690fdf4951abd40e84e283e2e70e3916fdcfdc4eec83cded4d，usage SHA-256 842848bc2319704c854556c963ac5ac738e4651c2d3cdc6ec508ed5151acbe27，以及 C5 slice plan 均已读取；本轮只复用其证据，不重跑测试、不扩展源码调查。 |
| D2：P-Q1/Q2/Q3 与残项边界 | Covered | Round 1 已逐项记录三项 positive coverage，且本轮核实对应计划、文档、source/build 和 bundle 均保持冻结哈希。P-Q1：30 个 skip 仍是 20 Rime + 10 App 的未验证残项；C4 scoped acceptance 不带入 C5，须由 Product 作 C5 专属决定。P-Q2：候选配对身份与 11 Mach-O 的静态准备证据可复用；真实安装身份、Full Access、App Group、RIME/宿主 readiness 仍属 future Entry。P-Q3：一次采集、隐私、恢复、reader 完整性与无重试边界及 marker 的 started/returned 语义限制可复用；仍不证明真实 callback 或持久化，duplicate-member 检测限制保留。 |
| D3：本 lane 最终确认 | Covered | 本轮预算内完成身份重绑和既有正向覆盖确认。Round 1 因 610.087 秒超过 600 秒仍保持历史 Partial；本轮不追认或改写旧结果。C5 Product 晋级/skip 决定、C5-I/R 授权与 fresh device lease 未完成。 |

## Findings 与结论

- **C5P-R2-01 — Product 决定待定。** 30 个 skipped cases 仍未验证，C4 接受只适用于 C4。责任人：Human Product Owner / Product Lead。最小后续：在 C5-P Product Exit 前记录 C5 专属决定；本 reviewer 不代为接受。
- **C5P-R2-02 — 运行 Entry 待定。** 配对安装、host 可用、Full Access、App Group/RIME readiness 和实际回调未验证。责任人：Environment Executor 与授权人。最小后续：仅在 C5-I/R 分别获准并取得 fresh lease 后执行对应 Entry。

**Round 2 verdict：D1–D3 覆盖完成；未发现阻止完成本 lane Quality 确认的新增 blocker。** 这不是整体 Quality Pass、Product Gate、安装或 Release Gate。旧 Round 1 Partial 保持原样，30 个 skip 未被接受或改记为通过。本轮没有执行 build/test、Simulator/设备、安装、输入/捕获、Maps、网络或 Git mutation。