# RELEASE-2026-0801-06 独立质量审查 — 2026-07-21

**审查角色：** 独立 Quality Reviewer（由 Product Lead 任命）
**审查对象：** `codex/release-2026-08-01-coordination-next`，范围 `130a9b0bf58b0bb67144262ed2e634503739026b..3444826983bb7b4e49ef96f9eb165964880ca8b9`；本记录只审查其中 `RELEASE-2026-0801-06` 的产品打磨差异，明确不评价同一分支的 `RELEASE-2026-0801-07` 探索性 iPad 文档。
**审查方式：** 只读差异与静态代码审查；在隔离 worktree `/private/tmp/uk-q06-release-polish` 和独立 DerivedData 路径执行构建。未修改生产代码、未合并、未推送，且未触碰任务 04 的未提交 Assignment。
**结论状态：** **Blocked — 可以交给 Domain Owner 处理发现项，但尚不满足 -06 的独立质量关闭条件。** 本结论不是 Product Gate、风险接受、合并授权或发布决定。

## 范围与前提

范围冻结将高级 Typing Intelligence（趋势、构成、连续记录/历史与更宽泛的智能/分析定位）和上下文拼写纠错排除在 V1.0 首发范围外。`RELEASE-2026-0801-06` 可以移除或如实禁用不完整的可见入口，但不得改变输入语义、RIME 所有权或借由本次 UI 打磨扩展功能。

本审查不把 Xcode beta 构建、历史 iPad 截图或单个缓存状态当作发布级设备、无障碍或 Archive 证据。

## 证据矩阵

| 审查项 | 证据与结果 | 裁定 |
|---|---|---|
| 首发排除项的可见入口 | `HomeTab` 将“今日输入”改为非 `NavigationLink` 的本地计数卡，移除趋势/构成/数据管理的 VoiceOver 提示和连续记录；`SettingsTab` 移除“输入洞察”和“智能纠错”两个导航入口。目标视图类型仍随代码保留，不构成首发界面曝光。 | **通过（静态差异）** |
| 首页卡片的产品表述 | 卡片保留“今日输入”及中文、字母、Emoji 三类本地计数；不再出现 AI、智能、趋势、历史或连续记录承诺。它继续以既有本地 `TypingIntelligenceViewModel` 提供计数，故该差异不证明基础计数在 Full Access 开/关、错误状态或实际设备上均可用。 | **通过（首发文案边界）**；运行时状态仍待验证。 |
| Release 下的上下文纠错 | `scheduleContextualTypoCorrectionRefresh()` 的延迟刷新体被 `#if DEBUG` 包裹；Release 配置编译通过，因而未发现 Release 路径向候选栏调用 `refreshContextualTypoCorrectionSuggestions` 的静态证据。正常 RIME 候选、九键和上屏后联想不在本差异的改写范围内。 | **通过（静态/Release 编译）**；真实 Release-like 键盘候选回归仍待设备验证。 |
| -03 兼容性 | 差异未改动启用引导、Full Access 探测/文案、RIME 部署边界、App Group、entitlement 或 Keyboard Extension 生命周期。静态上未发现与 `RELEASE-2026-0801-03` 已接受的“Full Access 可选、关闭后基础输入可用”合同相冲突的改动。 | **通过（静态差异）**；不替代 TD-004 的开/关实测。 |
| 构建与依赖产物 | 在隔离 worktree 中，`bash scripts/ensure_rime_vendor.sh verify` 通过，确认 11 个 RIME framework 的结构清单。随后以 Xcode 27.0 beta、`SWIFT_STRICT_CONCURRENCY=complete`、warnings-as-errors 与 `CODE_SIGNING_ALLOWED=NO` 分别完成 Debug 和 Release 的 `generic/platform=iOS Simulator` 构建。 | **通过（预检构建）**；beta 工具链、无签名和 generic destination 均不构成稳定 Archive 或设备运行证明。 |
| 自动化回归 | 本差异没有新增 `HomeTab`、Settings 信息架构或 Release 上下文纠错的自动化测试。审查期间 `xcrun simctl list devices available` 因 CoreSimulatorService 无法连接而失败，故无法发现可用目的地并运行两个 scheme 测试；未将执行者历史“121 passed”外推为本审查当前结果。 | **未通过 / 阻塞** |
| 视觉与无障碍 | 未取得同一候选上的浅/深色、Dynamic Type、VoiceOver 焦点/朗读、横竖屏、Toast/safe-area、iPhone 与 iPad 运行时证据。源码中的 accessibility label 或 SwiftUI 自适应修饰符不等同于设备无障碍通过。 | **未通过 / 阻塞** |

## 实际执行命令

```bash
# worktree: /private/tmp/uk-q06-release-polish @ 3444826
bash scripts/ensure_rime_vendor.sh verify

xcodebuild -project 'Universe Keyboard.xcodeproj' \
  -scheme 'Universe Keyboard' -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/uk-q06-derived-debug \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build

xcodebuild -project 'Universe Keyboard.xcodeproj' \
  -scheme 'Universe Keyboard' -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/uk-q06-derived-release \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
```

以上三项均以退出码 0 完成。`git diff --check 130a9b0..3444826` 通过。未运行的 Simulator 测试原因已在矩阵中记录，不是通过结论。

## 阻塞项与所有者交接

1. **Q-06-01：缺少受控运行时回归。**
   - 所有者：Keyboard Experience Executor / Test & Release。
   - 需要：在可用的同一 Simulator 目的地或合格真机上，对候选分支执行 `Universe Keyboard` 与 `RimeBridgeTests`；记录命令、设备/OS、提交与失败详情。至少覆盖 Release-like 情况下普通 RIME 候选、九键、上屏后联想、以及“停顿后不注入上下文纠错候选”。

2. **Q-06-02：主 App 视觉与无障碍矩阵缺失。**
   - 所有者：`RELEASE-2026-0801-06` Environment Executor；最终视觉 Product Gate 属于 Human Product Owner。
   - 需要：同一候选构建上的 iPhone 和 iPad，浅/深色、Dynamic Type、VoiceOver、横竖屏；核对首页卡片不是可点击的误导性控件，设置不暴露排除入口，并特别检查 Toast/safe-area 不遮挡导航或内容。

3. **Q-06-03：-03 的 Full Access 回归未实测。**
   - 所有者：`RELEASE-2026-0801-04` 最终设备矩阵与 `RELEASE-2026-0801-03` Domain Owner。
   - 需要：Full Access 开/关下的主 App 文案、基础输入与本地计数卡错误/不可用状态；不得以静态无差异替代 TD-004 验证。

4. **Q-06-04：任务 Assignment 的生命周期不应因本审查推进。**
   - 所有者：Product Lead / -06 Executor。
   - 需要：在阻塞项均有独立可追溯证据后，更新 Assignment 并由独立 Quality Reviewer重新判定；本审查不授权合并 `3444826` 或关闭任务。

## 独立质量结论

`-06` 的静态收敛方向符合已冻结的首发范围：不再以首页或设置入口承诺被排除的高级 Typing Intelligence/上下文纠错，且 Release 编译未显示上下文纠错刷新仍会执行。未发现其改动侵犯 RIME 部署边界或直接回退 `-03` 的 Full Access 合同。

不过，当前没有本审查采集的可运行测试结果，也没有可与候选提交绑定的 iPhone/iPad 视觉、VoiceOver、Dynamic Type、深色、方向、Toast/safe-area 或 Full Access 开关证据。因此 **RELEASE-2026-0801-06 维持 Blocked**。该分支不得仅依据本记录合并或作为发布候选宣称已通过 Quality。
