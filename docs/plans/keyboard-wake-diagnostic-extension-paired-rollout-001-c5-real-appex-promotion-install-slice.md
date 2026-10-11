# C5：真实 appex 回调的最小晋级／安装切片（提案）

日期：2026-10-01。状态：**准备完成；执行 Not Ready**。权威：[配对 rollout Assignment](../assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md)。Human 本轮仅授权“准备真实 appex 回调验证的最小晋级／安装切片”；本文不授予晋级、安装、诊断启用、设备操作或人工输入权限。

## Scope / Ownership / Decision

建议复用 C4 留存的同源 Debug App + 内嵌 Keyboard.appex，先完成独立晋级前核验，再一次配对安装，最后一次受控真实回调采集。无需新增源码、测试或构建。Product Lead / Human 决定晋级及环境授权；Keyboard Experience 保持领域所有权；root 承担 Executor / Environment Executor；原 Architecture、Quality 独立 reviewer 可复用，但需各自新轮次、精确输入 ACK 与新预算，不能沿用耗尽预算。Human 操作依赖另行确认；Maps 不在本切片。

## Confirmed Facts / Evidence

- 唯一工作树 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；分支 `codex/keyboard-wake-v3-compatibility-gate`；HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`。
- [C4 冻结源清单](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-candidate-manifest.json)：568 项源／构建输入，摘要 `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9`。当前显式 v6 调用绑定；Core 公共默认仍 v5；Release marker context disabled，故选择 Debug。
- [C4 验证](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-integrated-validation-2026-10-01.md)：Core 1184 pass；Rime 85 pass + 20 skip；App/Keyboard 421 pass + 10 skip；signed Keychain 1 pass；Release build 成功。构建、静态 review 和 test-runner 运行不等于本次实际安装身份或真实 appex marker 证据。
- [C4 补审](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c4-supplement-quality-review-r2.md)只确认 C4-Q-01 当轮非阻塞、未验证 disposition。30 项仍 skipped，未取得整体 Quality / Product / Release Gate；**不自动继承到 C5**。C5 晋级前须 Quality 说明其对本受控暴露的影响，由 Product 作 C5 专属决定；不为数量差异重跑，也不声称补齐 skipped fixture。
- [C5 完整安装载荷清单](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-preparation-debug-install-payload-manifest.json)新增 111 文件哈希和 11 Mach-O 载荷的 SHA-256、大小、UUID，覆盖两个外层 executable、实际业务 `.debug.dylib`、preview 与嵌入 framework。旧 executable receipt 不足以独自证明 Debug 业务载荷身份。
- [签名只读结果](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-preparation-signing-readonly.json)：两 executable 的 codesign verify 成功；codesign entitlement 查询为空。[Simulator entitlement receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-preparation-simulator-entitlements.json)从 Mach-O `__TEXT,__entitlements` 读出两端相同 `group.com.DoubleShy0N.Universe-Keyboard`；这仅证明构建载荷，不能替代实际 App Group 访问、Full Access 或已安装状态。[原始载荷检查](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c5-preparation-payload-entitlements-readonly.json)。

选择的唯一安装源：

```text
/private/tmp/ukey-wake-c4-20261001/DerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app
  PlugIns/Keyboard.appex
```

两端 version 1.0 / build 1；bundle ID 分别为 `com.DoubleShy0N.Universe-Keyboard`、`com.DoubleShy0N.Universe-Keyboard.Keyboard`。不得混用独立 Products/Keyboard.appex 或后来构建。

## Applicable Contracts / Documentation Impact

遵守 Assignment、ADR [0036 v6 addendum](../architecture/decisions/0036-keyboard-wake-wire-v6-addendum.md)及现有 DEBUG 高保真／logging／category gates；Main App 保持完整部署所有权。借鉴 Human-operated evidence profile 的先机器后人工、载荷冻结和副作用账本原则；该 physical-device profile 不因此被宣告为 Simulator required policy。本文不修改 wire、输入行为、捕获合同或 CHANGELOG；不新增 flag、热路径 I/O 或同步 flush。

## Required Verification：分阶段 Entry / Exit

### C5-P：晋级前只读独立核验

Entry：Human 授权本阶段；源清单、完整 Debug 载荷、Assignment 和本文重新冻结；明确 sole writer。建议复用原 GPT6 Luna Architecture / Quality 各一轮，**各最多 12 底层工具 / 10 分钟，6 次时 checkpoint**；预算耗尽交回 Partial，不自动加轮。

Architecture 正向覆盖：P-A1 完整载荷／配对／v6 来源；P-A2 安装、共享容器及 gate 顺序；P-A3 回调判据、隐私与停止边界。Quality 正向覆盖：P-Q1 C4 证据复用及 30 skip 对本阶段的影响；P-Q2 安装后身份检验／可执行宿主前置条件；P-Q3 一次采集、reader 验证及残项。未覆盖项不能被“无 blocker”代替。

Exit：独立报告绑定最终 packet；无本切片必需 blocker，Product 单独记录 C5 的晋级及残项决定。任一 required 字段 UNKNOWN，停止在 Not Ready。

### C5-I：一次配对安装与机器 readiness

Entry：C5-P 满足；Human 精确授权安装／启动／必要系统设置核验，并确认**新鲜独占窗口**。唯一候选目标仍为 iPhone 18 Pro / iOS 27.0、UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，本轮尚未核查或预约，旧窗口已结束。先核对目标和现状；设备不符、他人占用或载荷变化即 Hold。

只安装上述 Main App bundle 一次，由其携带 appex；不单独安装 extension，不重建、不重新签名、不卸载、不 reset／erase／清理历史。安装是有状态动作，不保证可恢复旧 App；不得把保存 manifest 称为旧 App 回滚。启动也可能运行现有 App 生命周期与后台初始化，应在副作用账本记录。

安装后核查实际 App / 内嵌 appex bundle ID、版本、build，以及**全部 11 Mach-O（含两个 debug dylib）SHA-256 / 大小 / UUID**；记录完整安装目录清单，逐项解释系统导致的非载荷差异，不能以解释豁免 Mach-O 不一致。记录安装命令、源摘要、实际路径、时间和目标。未核实不得启用诊断或交给 Human。

再核验现有 keyboard 配置／Full Access／App Group 访问、RIME 已有资源 readiness 和宿主可用性。若需新增 keyboard／启用 Full Access，只有授权明确包含这些系统设置动作才能进行；不自动部署、下载、改 schema 或更换宿主。缺前置条件 Hold，不猜修。

Exit：同一已安装配对载荷身份和 runtime readiness 记录成立，reader 与 producer 版本关系被绑定。构建 entitlement 不替代运行可访问性。

### C5-R：一次真实回调采集（另含明确采集／输入授权）

Entry：C5-I 完成，独占窗口有效，Human/Environment 分工明确，输入与 gate 副作用已授权。建议宿主是同一 Main App → 设置 → 本地词典 → 现有“搜索词语或编码”字段；源码已存在 searchable，但实际可激活键盘和 RIME 条件尚未验证。若不可用 Hold，不自动换 Notes 或 Maps。

先读取并保存**仅相关键的原值及是否存在**：`logging_enabled`、`log_category_disp`、`log_category_engine`、`diagnostics_high_fidelity_expiration`。通过现有诊断 UI 开启 logging、高保真默认 30 分钟及 DISP/ENGINE；不延长 expiry，不开启通知／hitbox，不改其他类别。现有其他 producer 仍可能写入，故只能声称导出内容经过限制，不能声称全局日志只含三个 marker 家族。

生成外部 run receipt ID（不新增事件字段），记录 UTC 窗口；激活一次 appex，完成一次非敏感合成拼写／候选提交，在键盘可见时留约 2 秒供异步 ingress（不是持久化保证），再隐藏一次。不保存输入文字、键值、候选内容、宿主文本、原始 prefs 或屏幕截图。搜索本身可能触发本地查询／UI 更新，不能宣称零副作用。仅清除本轮合成搜索字段；不修改字典条目。

只定位动态 `keyboard_extension-*.jsonl` 并流式筛选本窗口内容无关的 typed v6 事件；不拷贝完整历史／legacy 日志。以 origin、processInstanceID、appearanceID、localSequence、monotonic 时间关联；当前 marker 没有可用 actionSequence，不能造 transaction ID。由同一 Main App reader 查询消费，并记录完整性／拒绝／fallback 状态。

| 验证对象 | 最小正向证据 | 不得扩大结论 |
|---|---|---|
| 实际 appex 生命周期 | 新 process/appearance 的 willAppear、didAppear | 不代表所有宿主、所有唤醒场景 |
| RIME 边界 | 真实 resume 调用边界的 started | 不是 ready、success 或 RIME 根因结论 |
| text proxy | 本次确实调用的操作至少一个 entered / returned 顺序对 | returned 仅表示 UIKit 调用返回，不证明宿主接受；未调用的 setMarkedText/unmarkText 不伪报通过 |
| 同配对 reader | 本窗口 v6 事件被 Main App 正确消费，完整性状态真实呈现 | 不用 legacy 文本补齐缺失 marker 或隐去 unsupported |
| 普通输入观察 | 合成操作反馈的无内容状态记录 | 不证明卡死已修复或 Maps 复现 |

willDisappear / hostResign 为可观察补充，尾部异步丢失可能存在，不作为必达硬条件。缺失必要 marker、expiry、路径未执行、reader 不完整或身份不符均 Hold / inconclusive；不能凭“没日志”判 producer 缺陷。最多一次人工轮次、零自动重试；冻结后重建／重新安装使该轮无效，需要新决定。

退出时恢复本轮确实改动的相关诊断键及原存在性；若原先就启用，恢复原值而非擅自关闭他人捕获。到期旧 expiry 不续期。保留历史 journal，不 bulk defaults restore、不日志清空、不卸载；记录残留捕获状态及窗口结束。若运行失败，仍做授权内 gate 恢复并保存内容无关失败证据。

## 副作用账本与授权边界

| 动作 | 本轮准备 | 后续最小授权 |
|---|---|---|
| 源／产物 hash、Mach-O entitlement、文档 | 已完成只读核验／文档准备 | 可重复只读 rebind |
| 独立 readiness review | 未派发 | C5-P 精确 packet / budget |
| Simulator 核验／启动、安装 App、启动 App | 未执行 | C5-I 明确动作 + 新独占窗口 |
| keyboard／Full Access 设置（必要时） | 未执行、状态未知 | 需明确包含条件动作 |
| capture keys、合成输入、窄日志读取／reader 操作／恢复 | 未执行 | C5-R 精确动作及一次轮次 |
| build/test/source/Git/Maps/Release | 不在切片 | 分别另行授权 |

## Risks / Handoff

当前阻碍执行的是晋级 readiness review／Product 决定、新设备独占窗口、安装及采集权限、运行前置条件；不是源码实现缺口。duplicate-member parser limitation 和 30 skipped fixtures 均仍未验证。仅完成本切片也不能关闭父 Assignment，不能替代 Maps、跨宿主、性能、Release 或根因诊断。

建议 Human 先授权 C5-P；待 reviewer 正向覆盖与 Product disposition 成立，再激活 C5-I/C5-R。也可一次给出分阶段条件授权，但每阶段必须逐项满足 Entry，不能越过 Hold。
