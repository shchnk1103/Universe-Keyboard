# KEYBOARD-LAYOUT-9KEY-PINYIN-001 Codex 第三次独立复审

- 复审日期：`2026-07-18 Asia/Shanghai`
- 复审角色：Architecture & Knowledge Steward；Quality, Performance & Release
- 分支：`feature/keyboard-layout-9key-pinyin-001`
- HEAD：`44d42130bd8e2012bce7b4c034c4bc51a149dec3`
- 对象：上述 HEAD 上的当前未提交工作区
- 输入 handoff：`docs/assignments/keyboard-layout-9key-pinyin-001-grok-fix-handoff-3.md`
- Architecture：**Fail / Changes Required**
- Quality：**Fail / Changes Required**
- Publication：**Not Ready**
- Product Gate：**Open；Human Dependency 未满足**

## 1. 独立性与权威

本复审重新读取 `AGENTS.md`、Knowledge Index / Reading Maps、Assignment Policy、当前 Assignment、Product Decision、ADR 0020、相关 playbook、前次 review、handoff 3、当前实现及测试。handoff 仅作为待核 claims 和定位入口；聊天与 handoff 中的结论或历史测试结果均不作为权威。本记录只依据当前工作区静态审查和本次独立命令结果。

## 2. Executive conclusion

handoff 3 针对上一轮 P1 的直接修复成立：usable rollback 不再整体写回 `previousPathState`；当前 live comments 会重新生成 compact paths 与 issued keys；只有被 live output 重新签发的 selected path 才会保留。新增测试也真实覆盖了 `ni/mi → mi` 的 rollback provenance 变化。

但 Architecture 与 Quality 仍不能通过。为避免 stale provenance，当前 `refreshT9PinyinPathState()` 在每次 refresh 时清空 issued set，并只从当前 page 与前 16 个 hot-path candidates 重建。完整面板此前通过后续 window 签发的合法路径会因此被撤销；与此同时 raw 未变化时 `rawInputGeneration` 保持不变，UIKit 不会重建或关闭面板，仍展示这些已被 Core 撤权的路径。用户点击后，面板先关闭，Core 再静默拒绝选择。

问题的第一性原因是：实现把“raw-input generation”和“candidate-comment provenance snapshot”当成同一个版本。raw 相同不代表 comments/window provenance 相同；但当前状态没有第二个 revision 来让 Core 与 UIKit 对齐。

## 3. Blocking finding

### [P1] same-raw refresh 撤销已展示的后置路径，但 UI generation 不失效

证据链：

- `t9PinyinPathWindow` 会把任意已读取 window 中的合法路径登记到 `issuedReplacementKeys`（`KeyboardController+T9PinyinPath.swift:22-57`）。这是 expanded panel 后置路径获得 Core 选择授权的来源。
- `refreshT9PinyinPathState` 每次从空 issued set 开始，只重新登记当前 page 和 `hotPathWindowLimit == 16` 的结果（`:187-224`）。先前由第 17 个及以后 window 签发、且仍属于同一 live candidate snapshot 的路径会被撤销。
- raw identity 未变化时 `rawInputGeneration` 明确保留原值（`:174-185`）。因此这次 provenance 变化不会使 panel generation 失效。
- UIKit 仅在 raw generation 改变时重建完整面板数据（`KeyboardViewController+T9PinyinPath.swift:205-218`）；同 generation 只 reload 旧 `accumulatedPinyinPaths`。点击路径时也只校验 generation，然后先关闭面板再交给 Core（`KeyboardViewController+CandidateDataSource.swift:67-80`）。
- Core 选择入口要求 replacement 仍位于 issued set（`KeyboardController+T9PinyinPath.swift:105-113`），所以被 refresh 撤权的可见路径必然返回空 effect。
- 现有 index-17 discovery 测试在 window 签发成功后立即结束（`T9PinyinPathTests.swift:480-484`），没有再执行一次 same-raw refresh 并尝试选择该路径。

可复现状态序列：

1. 前 16 个 comments 无有效 path，第 17 个 comment 产生 `ni`。
2. expanded panel 调用 `t9PinyinPathWindow(0, 48)`，显示并签发 `ni`。
3. 在 raw 仍为 `64` 时触发一次 path refresh；Core 清除 `ni`，raw generation 不变。
4. UI 保留并显示 accumulated `ni`；用户点击后面板关闭，但 Core 因 `ni` 已不在 issued set 而拒绝 refinement。

影响：

- 破坏 Product Decision 的完整路径面板与 ADR 0020 的 lazy-window 可选择性合同；合法、仍可见的 RIME comment path 可能无法选择。
- UI stale guard 给出“generation 仍有效”的判断，而 Core authorization 已经变化，形成跨层状态分叉。
- 用户侧表现是点击无输入、面板消失，属于核心交互失败，而不是单纯缓存或展示瑕疵。

Required change：

- 分离 raw lifecycle generation 与 provenance snapshot revision。candidate/comments authority 变化时应使 provenance revision 变化；panel/window 必须绑定该 revision。
- 同一个 provenance snapshot 内，后续 window 的 issued keys 应持续有效；若 refresh 表示新 snapshot，则 UIKit 必须按新 revision 重建/关闭面板并重新签发可见路径，不能继续展示旧 accumulated paths。
- 不要通过永久继承旧 issued set 来回退修复，因为那会重新引入 handoff 3 已解决的 rollback stale provenance。
- 增加 Core + UI contract 测试：index-17 path 被 panel window 签发后执行 same-raw refresh；结果必须二选一且跨层一致：若 snapshot 未变，路径仍 issued 且可选；若 snapshot 已变，revision 必须变化，panel 重建后只展示并签发 live paths。

## 4. 上一轮 P1 复核

| 上一轮 finding | 本次判定 |
|---|---|
| usable rollback 用旧路径快照覆盖 live provenance | **直接缺陷已修复**：不再整体恢复旧 path state；`ni/mi → mi` 负例通过 |
| old issued set 不应跨 live comments 变化继承 | **局部修复但产生新 P1**：stale issued 已消除；同 snapshot 的 expanded-window issuance 也被无差别清除 |
| selected path 只在 live 重新签发时保留 | **已修复** |

## 5. 独立验证

| 验证 | 本次结果 | 说明 |
|---|---|---|
| `swift test --package-path Packages/KeyboardCore --filter T9PinyinPathTests` | **PASS — 19 tests, 0 failures** | 独立运行；缺少 expanded issuance → same-raw refresh 回归测试 |
| `swift test --package-path Packages/KeyboardCore` | **PASS — 613 tests, 0 failures** | 独立运行，约 3.5 秒 |
| KeyboardTests / iPhone 17 Pro Max Simulator 27.0 | **PASS — 6 tests, 0 failures** | xcresult summary；没有 hosted expanded-path interaction test |
| Debug strict generic Simulator build | **PASS / exit 0** | complete concurrency + Swift/C warnings-as-errors；仍输出既知 Boost x86_64 linker warnings |
| Release strict generic Simulator build | **PASS / exit 0** | 同上；不能声明完整构建零 warning |
| RimeBridgeTests `build-for-testing` | **PASS / exit 0** | iOS Simulator target 可编译；本轮未运行 real fixture Spike |
| `git diff --check` | **PASS for tracked diff** | 新功能多数文件仍 untracked，因此另对相关 Swift 文件执行 trailing-whitespace 扫描，亦无结果 |
| clean-commit Spike archive | **未执行** | 无 commit / publication 授权 |
| physical-device interaction / latency / VoiceOver | **未执行** | Human Dependency 未满足；Product Gate 保持 Open |

说明：首次 sandbox 内 SwiftPM/Xcode 调用因用户缓存/CoreSimulator 权限失败；获准访问本机缓存与 Simulator 后，以上记录的独立命令均成功。环境权限失败不计为产品测试失败。

## 6. Architecture boundary judgement

| Boundary | Result |
|---|---|
| Usable rollback 以 live RIME comments 重建 provenance | Pass |
| Stale selected/issued path 不跨 changed live snapshot 恢复 | Pass |
| Expanded-window issuance 在有效 snapshot 内保持可选择 | **Fail** |
| Core authorization 与 UIKit panel stale guard 使用同一版本 | **Fail** |
| Sparse discovery / index 17+ 路径可达 | Partial：可显示；same-raw refresh 后可能不可选择 |
| Exact usable refinement / fail-closed rollback | Pass |
| RIME deploy/vendor boundary | Pass；未见新增 Extension deploy、schema mutation 或 vendor change |
| UI geometry / VoiceOver / latency | Static direction acceptable；interactive evidence open |

## 7. Gate decision and handoff

- Architecture：**Fail / Changes Required**。
- Quality：**Fail / Changes Required**。
- Assignment 保持 `Active`；不得标记 `Completed`、`Reviewed` 或 `Closed`。
- Publication：**Not Ready**；本次复审不授权 commit、push 或 PR。
- Product Gate：保持 **Open**。代码复审通过后仍需 clean evidence、hosted UI/VoiceOver 和真机 interaction/lifecycle/latency matrix。

下一 handoff 回到 Grok Executor。修复范围应聚焦 provenance snapshot revision、expanded issuance 生命周期及相应 Core/UI contract 测试；不要恢复无条件继承旧 issued set，也不要扩展 RIME 部署或产品范围。Codex 本次未修改实现代码。
