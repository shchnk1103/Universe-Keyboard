# QUALITY-C7-B1 round 1 — 独立静态质量审查

## 身份与结论

冻结 packet 的 SHA256 已按移除 packet_digest_sha256 后的 sorted compact JSON、UTF-8/ensure_ascii=true 复算匹配：1d7315aba9e5091f1035b10d25993f4141f69afe4c77fa14ad902c4d9cc332b7。52/52 个 allowlisted 文件摘要匹配；source-manifest记录的 identity、branch、HEAD 与 packet 字段一致。未运行 Git，未改仓库。

**静态审查覆盖：Q1 Covered，Q2 Covered，Q3 Covered。独立推进意见：Hold。** 所需静态问题均有证据可判；完整 KeyboardCore 编译仍被 test-source diagnostic 阻断，UIKit target/运行时证据未提供且本轮禁止采集。此结论不是 Gate、安装或 Release 验收。

| Criterion | Coverage | 独立判断 |
|---|---|---|
| Q1 | Covered | final focused host Core log 明确为 36/36、0 failure、0 skip，分为 KeyboardWakeOwnerProbe 10、ThreadAffineRimeSpike 10、ThreadAffineRimeWire 16。第一次 focused copy 因缺 FakeRimeEngine 编译失败；加入同一 helper 的 scratch retry 为 35/35；final 再加 unfinished-attempt 测试后为 36/36。完整 Core suite 在编译阶段因 T9PinyinPathTests.swift:1429 optional 插值诊断退出，未执行断言；未重跑基线，不能断定它是新引入或既有错误。历史 30 skips 在验证记录中仍标为 unverified，没有带入通过数。 |
| Q2 | Covered | 探针接在实际 insertKey/ThreadAffine coordinator 的静态路径，且 UI idle/touch、冻结与有限缓冲逻辑可逐项核读；关键限制和未覆盖动态依赖列于下方。Swift frontend parse 不是 UIKit SDK 类型检查或 target build。 |
| Q3 | Covered | Entry、授权和交付记录一致把 C7-A 限定为 Debug 探针接线、隔离 Core host 验证与 UI syntax parse；记录没有声称 App/Keyboard、RimeBridge、paired、Simulator、安装或 runtime 通过。完整 Core blocker仍开放，下一阶段边界也有书面列明。 |

## 有限 findings

**C7-B1-F1 — Hold：完整 Core 套件没有编译完成。** core-test.log 和 full-core-compilation-failure.json 指向 T9PinyinPathTests.swift:1429:37 的 optional string interpolation 诊断，构建以 exit 1 结束且没有测试断言结果。focused 36/36 是有限 host 子集，不能覆盖完整 suite。最小后续证据是有权处置该编译阻断后再交付全套 Core 结果，或按正式门禁规则给出可复核的边界判定；不要把此报告解读为要求本轮改动范围外文件。

**C7-B1-F2 — 观测边界：receipt 不是 engine completion 或 UI/host 成功。** insertKey 在同步 handler 周围创建/结束 attempt；ThreadAffine 的 schedule marker 在 owner.accept 返回后记录 ownerPresent、receiptPresent、epoch、revision。record schema 没有 engine-start/engine-return、候选应用或 text-proxy 接受阶段，所以有 receipt 只能证明接受回执存在，不能判定队列中的工作是否执行或结果是否呈现。resumeBegin/resumeEnd 还分别由 KeyboardViewController 外层与 ThreadAffine coordinator 内层记录；记录没有 producer/layer 字段，同阶段可出现嵌套重复，解码时须结合 sequence、owner、epoch，不能当成两次独立恢复。探针不会记录键、候选或宿主文本；synthetic armed 记录的 ordinal/owner 为零，不能当作 owner absent 证据。

**C7-B1-F3 — 目标集成仍未验证。** UI 探针位于 DEBUG && KEYBOARD_WAKE_OWNER_PROBE 条件块；allowlisted project.pbxproj 中 Debug compilation condition 为 DEBUG，未见该专用 flag，shared scheme 也没有记录启用它的设置。交付记录的两种 UI syntax parse 只覆盖语法，不证明 UIKit 符号/约束/gesture delegate 在 Keyboard target 中类型检查或运行。C7-B 至少要冻结 exact paired candidate，分别提供专用 flag 开启的真实 Keyboard/UIKit target build 与普通 Debug/Release 不含探针的 build，说明完整 Core blocker 的处置并运行批准的 paired/test 验证。C7-C 必须另有 fresh exact-device/exclusive Entry 和独立授权；其最小运行证据是一次受控唤醒复现、首个异常即 freeze、有限读取并验证 snapshot complete/attempt 配对/owner 与 receipt 状态。当前没有执行这类 runtime 验证，也没有根因或修复结论。

## 关键源码与证据定位

- 按键事件路径与反馈先后：Keyboard/Controllers/KeyboardViewController+InputActions.swift:5–27,71–75,126–128；Keyboard/Controllers/KeyboardViewController+KeyPressFeedback.swift:102–117。
- Probe UI、2s idle 与 freeze 导出：Keyboard/Controllers/KeyboardViewController+WakeOwnerProbe.swift:26–48,51–90,94–99；Keyboard/Views/CandidateBar/CandidateBarView.swift:417–462,704–726。
- stage、单轮/容量/TTL、attempt 归属与不完整冻结：Packages/KeyboardCore/Sources/KeyboardCore/KeyboardWakeOwnerProbe.swift:8–19,60–71,110–120,149–182,186–251,270–319。
- 真实 coordinator schedule / visibility / replacement：Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift:405–421,528–580,590–613；外层 suspend/resume：Keyboard/Controllers/KeyboardViewController.swift:415–425,520–595。
- host 计数与 full-suite 阻断：docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-local-artifacts/focused-test-final.log:93–102, core-test.log:34–42, full-core-compilation-failure.json:1。
- 授权与 C7-A 边界：docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-owner-probe-local-validation-2026-10-02.md:22–31,43–45；Entry:26–28；plan:7–13；授权记录:5–8。

## 未执行与限制

本 reviewer 没有运行 build/test、Simulator/device/LLDB、网络或 Git，也没有编辑仓库。52 个 allowlisted 输入哈希已直接校验；packet 声明的当前 branch/HEAD 仅与 source-manifest 字段交叉核对，没有通过 Git 独立确认。旧 C6、30 skips、整体 Gate/Release 不在本轮验收范围。