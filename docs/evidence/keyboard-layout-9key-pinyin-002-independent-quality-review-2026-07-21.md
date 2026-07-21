# KEYBOARD-LAYOUT-9KEY-PINYIN-002 — 独立质量审查记录

> **审查日期：** `2026-07-21 Asia/Shanghai`
>
> **审查角色：** 独立 Quality Reviewer（🧪 Quality, Performance & Release Maintainer）
>
> **审查范围：** 当前 `main` 的九键精准拼音实现（`6a3e082` Amendment B、`7f754f7` Partial Commit remainder 修正）及其现行 Assignment、Spike、架构审查、Product Gate handoff 与 Release Checklist。
> **非范围：** 本记录不重复 Architecture Review，不作 Product Gate、性能放行、风险接受、合并、推送或发布决定。

## 结论

**Blocked — 自动化与静态边界可复核，但 Assignment 的质量退出条件和人工 Product Gate 未完成。**

本轮没有发现自动化证据表明 `m/n/o`、循环、分段焦点、Delete/rollback 或 raw-host-commit 防护在当前 Core 测试集合中回归。它们不足以替代真实设备上的 VoiceOver、交互布局、延迟、恢复、Full Access 状态或 iPhone/iPad 产品验证；历史截图和 Executor 自报结果均未被提升为最终发布证据。

## 证据矩阵

| 范围 | 独立核对 | 结果 | 限制 |
|---|---|---|---|
| Vendor | `bash scripts/ensure_rime_vendor.sh verify` | **Pass**；11 个 RIME framework 结构完整 | 仅验证产物结构，不证明运行时行为。 |
| 精准路径 Core | `swift test --package-path Packages/KeyboardCore --filter T9PinyinPathTests` | **Pass**；39 tests, 0 failures | 运行于本机 Xcode beta 的 macOS SwiftPM；不是 iOS 真机。 |
| KeyboardCore 全量 | `swift test --package-path Packages/KeyboardCore` | **Pass**；637 tests, 0 failures | 同上；输出中有既存 optional 插值编译 warning，未以 warning-as-errors 运行此 SwiftPM 命令。 |
| RimeBridge | `xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme RimeBridgeTests -destination 'platform=iOS Simulator,id=900FB396-39BF-4A84-9E75-FF813C155FA7' CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test` | **Pass**（exit 0） | iPhone 17 Pro Simulator / iOS 26.5 / Xcode 27 beta；默认 suite 的 fixture-gated real-RIME cases 不应被解释为 isolated T9 Spike。 |
| 真实 RIME 精准路径 | 隔离 `scripts/run_t9_pinyin_selection_spike.sh`，目标同上、临时证据目录 `/private/tmp/uk-9key-quality-spike-20260721` | **未完成** | 当前根工作树含无关的 `-04` 文档修改，只能以 `UK_T9_SPIKE_ALLOW_DIRTY=1` 启动；Xcode beta 测试启动阶段停滞，审查人为避免占用共享 Simulator 已停止进程，未生成 `spike-result.md`。这不是 Pass/Fail，也不替代 Assignment 要求的 clean-commit Spike。 |
| 静态 UI/可访问性 | 路径按钮与“选拼音”只消费 Core path；按钮有 label、selected trait/value 和 hint | **Pass with runtime follow-up** | 静态 metadata 不证明 VoiceOver 实际焦点、朗读顺序或触发手势。 |
| 人工设备/体验 | Assignment Product Gate handoff 与 Release Checklist 对照 | **Blocked** | 本审查未取得当前候选的 iPhone+iPad 真机、深浅色、Dynamic Type、VoiceOver、Full Access、延迟或恢复证据。 |

## 已覆盖的关键合同

`T9PinyinPathTests` 可复核地覆盖了以下状态合同：

- 单键 canonical key identity：`MNO` 即使 live RIME comment 仅暴露 `o`，仍发出有序 `m / n / o`；
- **选拼音**按 `m → n → o → m` 循环，使用相同 refinement transaction，且不推进 segment；
- 直接点按未选 sibling 只改变 tentative choice；点按已选 segment 才确认并推进，后续 choices 仅接受 live RIME 授权的 `g / h`，拒绝 fallback-only `i`；
- 新 digit、Delete、candidate commit、page round-trip、same-raw new output、visibility/fallback/recovery 对 stale provenance 的清除或重建；
- 失败 refinement 的 marked text、choice、selected state 和 RIME output rollback/fail-closed；
- mixed T9 raw 的无 raw 泄漏策略，以及 explicit `m/n/o` 显示不被较长 candidate comment 覆盖。

RimeBridge suite 的严格 Simulator 命令退出为 0，且 Vendor 校验通过；这支持 bridge 目标可构建/执行，但不将 fixture-gated case 或 Simulator 结果说成真实设备、发布最低系统或最终 RIME Spike 证明。

## 阻塞项与 Owner 交接

| ID | 阻塞项 | 明确 Owner | 解除证据 |
|---|---|---|---|
| Q-9-01 | 缺少 clean committed harness 上的 isolated pinned-librime Spike；本轮 dirty 运行未完成。 | 原 Executor / Environment Executor（经 Product Lead 重新授权） | 干净工作树、明确 commit、isolated T9 fixture 的完整 result/provenance/log，断言 `m/n/o`、`n4`、`n'g/n'h/n'i` 授权和 no host commit。 |
| Q-9-02 | 缺少当前候选 iPhone 与 iPad 的人工矩阵：路径栏、直点/循环、分段确认、Delete、candidate commit、page/language/visibility/fallback/recovery。 | Human Product Owner（设备操作） + Keyboard Experience Maintainer（问题分诊） | 按 Product Gate handoff 逐行记录设备、OS、build、schema、Full Access 状态与 PASS/FAIL；不得以旧截图替代。 |
| Q-9-03 | VoiceOver、深浅色、Dynamic Type、紧凑高度和触控命中区未获运行时证据。 | Keyboard Experience Maintainer + Human Product Owner | iPhone+iPad 实测：焦点/朗读、selected state、`选拼音` hint/value、单行无重叠与可用 hit target。 |
| Q-9-04 | confirmation probe 延迟、三段及以上、跨 confirmed segment Delete、Extension 重启恢复未获性能/可靠性证据。 | `RELEASE-2026-0801-04` 独立 Quality Executor（最终 RC） + Input Intelligence Maintainer（如发现缺陷） | 最终 RC/Archive 的 trace/日志/设备证据；若出现功能失败，返还 Input Intelligence Maintainer，不由 Quality 接受风险。 |
| Q-9-05 | 首发最低 iOS 26.0 仍由 `RELEASE-2026-0801-09` No-Go 阻塞，当前测试为 iOS 26.5 Simulator 与 Xcode beta。 | Product Lead / `RELEASE-2026-0801-09` 后续 Executor | 稳定 Xcode/SDK 与 iOS 26.0 runtime 或真机之后的重新实施与独立验证。 |

## 明确未作出的结论

- 不将本记录变更为 Architecture Pass、Product Gate Pass、性能 Pass 或发布 Go。
- 不把现有 iOS 26.5 Simulator 结果外推为 iOS 26.0 支持。
- 不把历史 Device Hub 截图、自报操作或本轮静态 accessibility 核对称为最终真机/VoiceOver 证据。
- 不接受任何跳过项或风险；由 Product Lead 在具备完整证据后作决定。

## 复核卫生

审查开始和结束均仅观察到与本任务无关的未暂存文件：`docs/assignments/release-2026-08-01-04-device-performance.md`。本审查未读取其内容作为本任务结论，也未暂存或修改它。`git diff --check` 在审查结束时通过。

## Amendment C 复核附录 — 2026-07-21 Asia/Shanghai

**结论：自动化范围 Pass；Assignment 质量总门仍为 Blocked。** 本次新增的长输入 choice-discovery 行为在当前本地树上可复核通过，但 clean-commit Spike、真实设备交互/延迟、VoiceOver 与 Product Gate 仍未完成，原阻塞结论不变。

| 复核项 | 当前结果 |
|---|---|
| 先写失败测试 | 新增“合法音节位于候选 16 之后”与“一个精确音节仍补充 live-authorized 分支”；修复前 2 项失败，其余 39 项通过 |
| Focused Core | `T9PinyinPathTests` **41/41 PASS** |
| KeyboardCore 全量 | **639/639 PASS** |
| Vendor | `ensure_rime_vendor.sh verify` PASS；11 个 framework 结构完整 |
| RimeBridgeTests | iPhone 17 Pro Simulator / iOS 26.5：**28 passed，4 fixture-gated skipped，0 failed**；xcresult `/tmp/codex-t9-amendment-c-rime-tests/Logs/Test/Test-RimeBridgeTests-2026.07.21_17-59-39-+0800.xcresult` |
| 主工程 tests | **127/127 PASS**；xcresult `/tmp/codex-t9-amendment-c-main-tests/Logs/Test/Test-Universe Keyboard-2026.07.21_17-59-51-+0800.xcresult` |
| 严格构建 | Debug / Release generic iOS Simulator 均 exit 0；Swift 6 strict concurrency 与 warnings-as-errors 开启。既有 Boost x86_64 slice 提示仍存在 |
| 格式卫生 | `git diff --check` PASS |

静态复核确认扫描最多 48 个候选，额外 probe 最多覆盖一个物理键组并在 compact 5 项时停止；没有日志、宿主文本持久化、网络、部署或无界工作。测试同时断言新焦点未选中、候选 16 之后的音节可发现、单个精确音节不会压制另一条 live-authorized 分支，以及 probe 后 session raw 恢复。

剩余必测：在提供问题截图的真实设备路径上重放 `xian → zai → you`，确认后续分支、单选项无高亮、直接点按、**选拼音**、Delete、深浅色、VoiceOver，并记录 48 项窗口读取加最多 4 次 probe 的确认延迟。未取得这些证据前不得把本附录解释为 Product Gate、性能 Pass、风险接受或发布 Go。

## Amendment D 复核附录 — 2026-07-21 Asia/Shanghai

**结论：自动化范围 Pass；质量总门继续 Blocked。** 新增测试在修复前稳定复现三类失败，修复后与既有回归共同通过：

| 范围 | 结果 |
|---|---|
| Focused T9 / Partial Commit / display | **90/90 PASS**；含 `偷偷买748 53`、错误 `t/u/v` provenance、digit-bearing comment/session fallback、`tou → tong → ta` 失败形状与 refine/restore 双失败 fail-closed |
| KeyboardCore 全量 | **642/642 PASS** |
| Vendor | 11 个 RIME framework 结构验证 PASS |
| RimeBridgeTests | iPhone 17 Pro Simulator / iOS 26.5：**28 passed，4 fixture-gated skipped，0 failed**；xcresult `/tmp/codex-t9-amendment-d-rime-tests.xcresult` |
| 主工程 tests（最终源码） | **127/127 PASS**；xcresult `/tmp/codex-t9-amendment-d-main-tests-final2.xcresult` |
| 严格构建（最终源码） | Debug / Release generic iOS Simulator 均 exit 0；既有 Boost x86_64 slice 提示不变 |

静态检查确认普通 Delete 仅在无 Partial Commit、无 selected/confirmed segment 时介入；非空目标进行一次 exact `replaceInput`，空目标清 session；候选 comment 不能覆盖缩短后的显示。剩余阻塞是用户截图路径的真机重放、无 comment/session-loss、Delete flicker/延迟、VoiceOver、深浅色和 lifecycle 恢复。未完成前不作 Product Gate、性能 Pass 或发布 Go。

## Amendments E/F/G independent quality addendum

**自动化 Quality PASS；整体发布状态仍因真机 Product Gate 未完成而 Blocked。**

| Evidence | Result |
|---|---|
| Confirmed-prefix rerank regression | RED 时 `qiu53` 仍返回「填了」分支；锚定 `qiu'53` 后候选进入 `qiu` 分支，marked text 仅显示 `qiu` |
| Complete-syllable regression | 移除候选页中的 `le` 后测试先因缺少 `le` 失败；有界 exact live probe 后 `qiu'le` 被授权并恢复 |
| One-slot display regression | RED 时 `8` 显示 `ta`、`86` 显示 `tou`；投影修复后为 `t / to / tou` |
| Focused T9 Path | `46/46 PASS` |
| Layout and runtime | `14/14 PASS` |
| KeyboardCore full suite | `647/647 PASS` |

静态复核确认 probe 上限为 48、长度上限为 6，输出仍须 live-RIME provenance；普通投影不覆盖显式 Path Bar display，数字 comment 继续 fail closed。最终 G 源码需重新构建并安装到 iPhone 13 Pro，再完成 `t → to → tou` 与 `偷偷买 → qiu → le` 矩阵，方可改变 Product Gate 状态。

### Final device-build checkpoint

- 最终 Amendment G 源码面向 iPhone 13 Pro / iOS 27.0 的 Debug 构建成功，并通过 `devicectl` 安装。
- 备忘录空白输入首按 `TUV`：host marked text 实测为 `t`，未出现旧行为 `ta`，该单项 **PASS**。
- Device Hub 随后发生镜像窗口焦点/坐标漂移，继续点击可能落到设备列表；为避免误操作已停止。`to / tou` 与完整 `偷偷买 → qiu → le` 仍无可靠最终截图，因此 Product Gate 继续 **Pending**。

## Amendment H checkpoint — suffix replacement and Delete ordering

Status: **implementation present; final Quality rerun blocked by Codex execution-credit limit**.

Observed RED evidence:

- Path Bar `qiu` produced `偷偷买qiu` instead of preserving `le`.
- nested candidate Delete failed to restore `qiu'53` / `偷偷买qiule` safely.
- the next Delete targeted the raw tail rather than the first slot of the current unresolved focus.

Evidence obtained during implementation:

- After visible-suffix, checkpoint and focused-Delete fixes, the qiu test covering `qiule → 球 → Delete → qiule → Delete → qiue` passed `1/1`.
- A combined qiu/shu run then passed qiu and all shu display assertions, but exposed one remaining provenance defect: `shu` display was correct while state raw remained `74853` rather than `shu'53`.
- The final patch makes all letter-bearing refined raw authoritative in `installPartialCommitPresentation`. `git diff --check` passes after it, but the test command was rejected before execution because the Codex usage limit was reached.

Required next evidence is listed in `docs/assignments/keyboard-layout-9key-pinyin-002-grok-handoff-2026-07-21.md`. Do not upgrade this checkpoint to Quality PASS until focused qiu/shu, T9 Path, layout/runtime and KeyboardCore full suite all pass on the final source.
