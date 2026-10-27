# Assignment: BUILD167-FEEDBACK-DEFECTS-001 — Build 167 反馈缺陷诊断

Policy version: 1.0.0
record_id: BUILD167-FEEDBACK-DEFECTS-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Completed |
| Current phase | D1 / D2 诊断产出已交付 |
| Material non-claims | 本记录不是修复授权或 Product Gate；独立 Quality 和真机未由诊断报告证明 |
| Next handoff / decision | Close 由 Human 决定 |

## Authority

- **Task ID / Title:** BUILD167-FEEDBACK-DEFECTS-001 — Build 167 反馈缺陷诊断（D1 九宫格 Path 部分选择后候选消费范围；D2 自定义行高下路径栏出现时按键被压缩）。
- **Assignment Authority:** Product Lead。
- **Decision Source / Date:** Human Product Owner 2026-10-25（Asia/Shanghai，对话）报告 D1、转述 D2；由 [BUILD167-FEEDBACK-ASSIGNMENT-LANDING-001](build167-feedback-assignment-landing-001.md) 入库。
- **Product Approver:** Human Product Owner。

## Human 报告

以下均为 Human 观察或转述，不是测量。

- **D1（Human 本人观察）：** 九宫格输入 `xiwanjiushuio`；先在候选栏选「洗完」；再在拼音栏（Path Bar）选 `jiu`；再在候选栏选「就睡」。Human 预期只剩 `o` 未被消费；实际拼音栏仍剩 `shuio`。构建、宿主 App、方案：UNKNOWN。
- **D2（外部测试者反馈，经 Human 转述）：** 调节了键盘高度之后，九宫格拼音栏出现时，不是在调节后的高度上方再出现，而是把九宫格键盘往下挤压，整体高度仍是调节后的高度。测试者的设备、系统、所设行高、宿主 App：UNKNOWN。

## Boundary

- **Scope:** S1 = D1 诊断：只读代码路径 + 在 iOS 模拟器用生产 `RimeEngineImpl` / `KeyboardController` 接真实 librime 复现（离线 rime_ice t9 夹具），最多新增 1 个实验测试文件，本地提交不推送；核对 [KEYBOARD_LAYOUT 的 Partial × Path residual-B](../KEYBOARD_LAYOUT.md#partial--path-residual-b004-gate-5--human-pass)（规则 1：推进步数 K = min(候选汉字个数, 剩余用户 Path 栈长度)）及其产品 SoT [004 Gate 5](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md)，以及 [RELEASE_CHECKLIST](../RELEASE_CHECKLIST.md) 第 477–486 行 Amendments E/F/G/H；结论分类：代码与合同一致但合同与 Human 预期不同 / 代码与合同不一致 / 合同自相矛盾 / 无法复现。S2 = D2 诊断：只读代码路径（[KeyboardViewController+HeightSettings.swift](../../Keyboard/Controllers/KeyboardViewController+HeightSettings.swift) 的行高解析与宿主接受高度，[KeyboardHeightSettings.swift](../../Packages/KeyboardCore/Sources/KeyboardCore/KeyboardHeightSettings.swift) 的竖屏 50% 封顶）+ 模拟器复现（不同保存行高下路径栏 0→34pt 时的请求高度、宿主实际高度与有效行高），对照 [UI4 产品合同](../product-decisions/UI4-KEYBOARD-HEIGHT-001-product-contract.md) 与 [KEYBOARD_LAYOUT](../KEYBOARD_LAYOUT.md) 中 Sticky 路径栏的高度要求；同样四类结论。每个阶段一份外置报告。
- **Non-goals:** 任何产品代码或既有测试修改、修复实现（另立）、放宽断言或超时（TD-020）、打开 R174、修改产品合同或 ADR、真机操作（如需真机证据，只在报告中列出需要什么）、联系测试者、TestFlight / App Store Connect 动作、push / PR / merge；本记录不是修复授权，也不是 Product Gate。
- **Required Inputs:** 上列合同与代码文件；[KEYBOARD_VALUES](../KEYBOARD_VALUES.md)；外置先例报告 `~/.kos-work/Universe-Keyboard/PF031-S7-SIM-001/reports/executor-report.md`（模拟器真实引擎实验做法）；离线方案夹具 `docs/evidence/r4b-runtime/manual-run2/runtime/shared` 与被忽略的 `Packages/RimeBridge/Vendor`（可从 Human 主检出只读复制，逐文件 SHA-256 比对）。

## Assignment

- **Domain Owner:** Keyboard Experience Maintainer；采用仓库现有角色名，出处 [VIRTUAL_ENGINEERING_TEAM](../VIRTUAL_ENGINEERING_TEAM.md) 第 216 行起（Keyboard Extension UI、布局及 Core 合同接线）。
- **Executor:** Codex（当前 Executor 会话；精确后端版本未确认）。
- **Environment Executor:** Codex（Xcode、`xcodebuild`、iOS 模拟器本机命令）。
- **Human Dependency:** Human Product Owner——各阶段任务包授权；D1 的产品预期是否改写现有规则（产品决定）；D2 若需测试者补充信息（设备、行高、宿主），由 Human 转达。
- **Architecture Reviewer:** Not Applicable — 诊断阶段无代码或架构改动；进入修复时另行指定。
- **Quality Reviewer:** 独立 Quality Reviewer（非 Executor 会话），在各阶段报告完成后派发。

## Human 确认状态

D1、D2 已由 Human 报告（2026-10-25）；各阶段开工授权、D1 产品预期是否改规则、修复立项：**待 Human**。

## Reviewer claim register

| ID | 声称 |
|---|---|
| R1 | 复现步骤与 Human 报告一致 |
| R2 | 代码路径引用准确 |
| R3 | 结论分类有合同出处 |
| R4 | 模拟器证据不被写成真机证据 |
| R5 | Human 观察与转述不升级为测量 |
| R6 | 无产品代码改动、无 push |

## Gates

- **Entry Criteria:** 本记录合并进 main；每阶段另需 Human 的任务包授权。
- **Exit Criteria:** S1、S2 各有外置报告与独立 Quality 结论；每条缺陷有结论分类与需要 Human 决定的问题清单；修复是否立项由 Human 另行决定。
- **Stop Conditions:** 需要改产品代码或既有测试；需要真机或联网；需要打开 R174；`origin/main` 有产品代码新提交且影响相关文件；合同出处找不到。

## Handoff

- **Handoff Target:** Coordinator → Codex（S1、S2）→ Quality Reviewer → Human Product Owner。
- **Required Handoff Content:** 代码路径表（文件:行号）、合同原文与冲突点、模拟器环境（Xcode、模拟器、librime 版本、夹具 SHA）、逐步事实表与两轮一致性、结论分类、UNKNOWN。
- **Revalidation Trigger:** main 上相关产品代码变化；Human 补充或更正报告；修复立项；测试者提供新信息。

## Reports

| 项 | Result |
|---|---|
| S1 外置报告 | （执行时填） |
| S2 外置报告 | （执行时填） |

## Exit evidence

- D1：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-FEEDBACK-DIAG-001/reports/s1-d1-report.md`，SHA-256 `1cb7a0b0c7ea6f2c44c860851a8905b54b7fbd1b25435eb87e7dd2dffd039f87`（外置，不入库）；当前夹具与生产路径下，消费结果符合残余账本合同但不同于 Human 预期；真实设备同因未证明。
- D2：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/BUILD167-FEEDBACK-DIAG-001/reports/s2-d2-report.md`，SHA-256 `68c105ca0e9dd656963a5c8b5cfd4c4308b1df6cbe557c463c59ca546ea4afc5`（外置，不入库）；固定宿主预算时行高随预算压缩，增长允许时维持保存行高，符合报告所述合同边界。
- 两项报告均记录未执行独立 Quality；Completed 是诊断产出已交付，不表示 Reviewed / Closed。Human 批准依据 `/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-CLOSEOUT-177-001/reports/human-authorization-r2-issued.md`，SHA-256 `eae66df89903e0a5076ca35f016f94657906e2eff2e10a3075063c4f4f2c5aa2`（外置，不入库）。

## Closeout Decision

由 Human 决定；Close 不是修复授权。

## Lifecycle Status

Completed

Ready/Active 阶段未在本记录逐级标注；工作依各阶段外置任务包与 Human 授权消息进行（见 Exit evidence）。
