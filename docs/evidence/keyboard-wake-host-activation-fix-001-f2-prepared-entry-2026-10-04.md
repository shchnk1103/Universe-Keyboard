# 宿主激活修复 F2 Prepared Entry — 2026-10-04（修订）

Human 先要求只准备 F2 Entry；随后要求 **只修订 Entry**，不执行 F2、不改五文件源码。

**状态：Prepared（已按五条修订），未 Ready，未授权执行。** Environment Executor 仍为 root。本轮未运行测试、构建、安装、备份，未操作模拟器，未 mkdir 运行目录，未修改五文件源码。

权威：[Assignment](../assignments/keyboard-wake-host-activation-fix-001.md) F2 行、[AGENTS 本地 CI 门禁](../../AGENTS.md)、[CI 分级](../CI_CHANGE_CLASSIFICATION.md)、[F1 接收](keyboard-wake-host-activation-fix-001-f1-received-2026-10-04.md)。

本修订作废首版 Entry 中的三项说法：destination `name=iPhone 17 Pro`、无条件 F2-3b、以及「完整 CI 等价」。随后按 Human 三项补丁再修订：可复算 358 清单、untracked 白空格、关闭并行测试。

## 修订要点

1. 设备改回原精确 UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`。CI 默认名称不得自动换机。
2. 取消无条件重复 gate focused。完整套件 xcresult 已证明 17 项实际执行时跳过 F2-3b。
3. 唯一运行目录与独立构建缓存；五文件之外冻结 scheme、工具链、Vendor 与实际构建依赖。
4. 补齐备份存在 / 不存在、恢复步骤、成功或失败环境 Exit、预算、停止条件、产物保留。
5. 只称 **完整测试与构建矩阵，外加适用本地分类与轻量检查**。Keychain 专项签名参数保留。
6. 358 文件摘要改为可复算清单（路径 / 字节 / SHA-256 + 聚合算法）；Vendor 实际解压字节另清单绑定。
7. 白空格：`git diff HEAD --check` 只覆盖已跟踪路径；untracked 新 gate 与测试用 `git diff --check --no-index`。
8. 全部 iOS `test` 命令加 `-parallel-testing-enabled NO`。

## 候选冻结（只读重核）

工作树 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；branch `codex/keyboard-wake-v3-compatibility-gate`；HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`；staged 0。

5/5 当前字节与 [F1 delivery-manifest](keyboard-wake-host-activation-fix-001-f1-artifacts/delivery-manifest.json) 一致，见 [candidate-recheck.json](keyboard-wake-host-activation-fix-001-f2-artifacts/candidate-recheck.json)：

| 路径 | SHA-256 |
|---|---|
| `Keyboard/Controllers/KeyboardViewController.swift` | `9aeec10f633454b7b9a032d8140ac0d9912de98ea7049c83a2a886c5ca04ec66` |
| `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` | `e992a9ddf431112d1a40bed80431392eb68c8ef7221b07ece47b87eefb945299` |
| `Keyboard/Services/KeyboardHostLifecycleRecoveryGate.swift` | `2e7dcf3e88022a677e6ca5bfc5efd6aeacb1814c6fb7de6ec0cdc7c52ec7c9fb` |
| `KeyboardTests/KeyboardHostLifecycleRecoveryGateTests.swift` | `e9ef614702dff163ea1f1723e577f2f5af97394c919fb7d03544e15356d3c1a3` |
| `Universe Keyboard.xcodeproj/project.pbxproj` | `49f0ebe89db1f30323d9bf6ceb297179ffed5fc9ef983fd3b947d11d5820586c` |

dirty 默认 819 / `--untracked-files=all` 1430，相对 F1 接收 817/1418 可变（治理文档）；不以总数代替源码 hash。F2 执行前若五文件 hash 漂移则停止。

## 构建输入绑定（五文件之外）

[build-input-inventory.json](keyboard-wake-host-activation-fix-001-f2-artifacts/build-input-inventory.json)（UTC `2026-10-04T09:45:00Z`）。逐文件清单：[source-tree-manifest.json](keyboard-wake-host-activation-fix-001-f2-artifacts/source-tree-manifest.json)、[app-source-manifest.json](keyboard-wake-host-activation-fix-001-f2-artifacts/app-source-manifest.json)、[vendor-byte-manifest.json](keyboard-wake-host-activation-fix-001-f2-artifacts/vendor-byte-manifest.json)。

摘要算法：每个文件为原始字节的 SHA-256；清单行为 UTF-8 `{posix路径}\\t{十进制字节}\\t{文件sha256}\\n`，按路径升序拼接后再做 SHA-256，得到聚合 digest。执行前按同一算法复算，计数或 digest 漂移则停止。

| 输入 | SHA-256 / 钉 |
|---|---|
| scheme `Universe Keyboard.xcscheme` | `ed7e9b94b88097638cfc4ecaef7c391a8d633ffc0c0751fdf6dbbda2c4f730da` |
| scheme `RimeBridgeTests.xcscheme` | `f5934541b999c57d6d7cdacd9ff66dcf569d97fc6cdf900d80d7ec2d7cfeb0f9` |
| `Packages/KeyboardCore/Package.swift` | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` |
| `Packages/RimeBridge/Package.swift` | `83e91b4c48c15c1c39dc919a5282c39c80da82a55a370b62fdd430c758ea9b0b` |
| `.swift-format` | `47735e1c2cf0ea214e5e384eadcb091a9a499e92e40f29721000d68acf86a807` |
| `config/rime-vendor-manifest.env` | `a67cf99046a180c9e648755c793182529f2937f3d0469e3b59d6f63638802804` |
| Vendor receipt 文件 | `32b81905629e811067cfc8dfcd8b1548cce6e4a92433a885aba3ed8e0beeca83` |
| `KeyboardViewController+Presentation.swift`（仍匹配 F0） | `767c2817054484d4d4c328cb7a8deaf676509b76bbc3cb45868b6e3cf721319a` |
| `KeyboardController.swift`（仍匹配 F0） | `fac2f75a67b2a7dc301a24be4944b1594e556791e13e0c205c24a650e5ee85bd` |
| `KeyboardController+RimeRecovery.swift` | `f3cb33290ddd8fe2ac69b52775067aaa675eecd0049600641ad9d9316c0b6ab5` |
| `ThreadAffineRimeSession.swift` | `b7050645be501a7f41a6732efda40b07fb82c4c930862c0f1d13d167af426a76` |
| `ResponsiveRimeCanaryMode.swift` | `2bcb4684cbb0b3afee5616a3d73045f7f4f4233834f2539c9b9e6b594f22e235` |
| 源树 358 文件聚合 digest | `099aec228a338ed2e42ca0d44d28e30802d78f1f4bbc92c7c4bd17f21d57dfe3` |
| 主 App 源树 168 文件聚合 digest | `b5fdda0ffd8c3f7563fe70a925b166817308267392edf72f4ffa00dda96068ca` |
| Vendor 解压 630 文件聚合 digest | `f9b03dea3e5be3e8d903e1c02f16dc933d5048ca48e45bf652e15ec99bdc0a9a` |

358 切片根：`Keyboard/`、`KeyboardTests/`、`UniverseKeyboardTests/`、`Packages/KeyboardCore/`、`Packages/RimeBridge/`、`Universe Keyboard.xcodeproj/`。排除 `.xcframework`、`Packages/RimeBridge/TestTool/**`、`.DS_Store`、`xcuserdata`。先前不带清单的聚合 `dff969d7…` 无法独立复算，由本清单取代。

Vendor 实际字节分三层绑定：

1. **归档：** `config/rime-vendor-manifest.env` 的 `RIME_VENDOR_ARCHIVE_SHA256=d17aab9a…`（fetch 时 zip 身份）。
2. **receipt：** `.rime-vendor-receipt` 文件 SHA-256 `32b81905…`，内容 `version=` / `sha256=` 与 manifest 一致。`ensure_rime_vendor.sh verify` 只检查结构（12 个 xcframework、Info.plist、至少一个 `.a`、无多余框架）和 receipt 文本。
3. **解压后文件：** `vendor-byte-manifest.json` 对 Vendor 目录 630 个常规文件逐个 SHA-256。F2 必须复算该清单；仅 verify PASS 不能证明 `.a` 未被改写。

执行前上述 hash 任一漂移则停止。无 `KeyboardTests` scheme，必须走 `Universe Keyboard`。

## 工具链 / Vendor（只读）

[toolchain-vendor.json](keyboard-wake-host-activation-fix-001-f2-artifacts/toolchain-vendor.json)（UTC `2026-10-04T08:33:35Z`）：

- Xcode 27.0 (27A266a)，`xcode-select` → `/Applications/Xcode.app/Contents/Developer`
- Apple Swift 6.4；测试 / 构建仍钉 `SWIFT_VERSION=6.0`
- `bash scripts/ensure_rime_vendor.sh verify` **PASS**（12 xcframework）；receipt `rime-vendor-ios-1.16.1-lua.1-octagram.1` / `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` 与 manifest 一致
- **未 fetch**。verify 失败时 F2 停止，fetch 另需执行授权

## 冻结命令与覆盖目标

完整命令原文：[frozen-commands.json](keyboard-wake-host-activation-fix-001-f2-artifacts/frozen-commands.json)。覆盖目标：[coverage-targets.json](keyboard-wake-host-activation-fix-001-f2-artifacts/coverage-targets.json)。

Destination：**`platform=iOS Simulator,id=405D994F-28CB-4F89-BB22-B64AD81C05A2`**。

隔离（AUTH 后才创建，当前均 **不存在**）：

- 运行根 `/private/tmp/ukey-host-activation-fix-f2-run-20261004`
- `-derivedDataPath …/DerivedData`
- KeyboardCore `--build-path …/keyboardcore-build`
- xcresult `…/xcresults/`
- 日志 `…/logs/`

未签名作业公共参数：`CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`。全部 iOS `test` 另加 `-parallel-testing-enabled NO`，把作业钉在 `id=405D994F-…`，禁止 xcodebuild 另开 worker 模拟器。Release `build` 不加该开关。

Keychain 专项 **保留** CI 签名参数：`CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO`，仅把 destination 改到上述 UDID。

本矩阵的诚实名称是 **完整测试与构建矩阵，外加适用本地分类与轻量检查**。它覆盖 hosted 六项 heavy 作业的本地对应物，外加能看见 uncommitted F1 的分类表与轻量子集。它 **不是** hosted SHA-to-SHA `classify-change` + `lightweight-checks` + `final-quality-gate` 的完整 CI 等价，因为那些脚本看不到未提交五文件，且 CI destination 名称未被授权替换 Assignment UDID。

执行顺序（先到停止；任一步失败不宣称矩阵通过）：

1. **F2-C** 按冻结表对 uncommitted 路径分类。五文件 + pbx 为 `full`；不得用 `HEAD..HEAD` 空 diff 跳过 heavy。
2. **F2-L** 适用本地轻量：`git diff HEAD --check`（已跟踪的三文件 F1 差量 + F2 证据）、**F2-L-diff-check-untracked**（`??` 的 gate 源与测试：`git diff --check --no-index -- /dev/null <file>`，因整文件相对 `/dev/null` 恒有 diff，只把 `trailing whitespace` / `space before tab` / `leftover conflict marker` 当失败）、`.kos/project.json`、`scripts/ci` helper 测试、F2 证据工作树相对链接。
3. **F2-0** 四个 Swift 文件 `swift-format lint --strict`（pbx 不走 format）。
4. **F2-1** `swift test --package-path Packages/KeyboardCore --build-path <隔离目录>`。
5. **F2-2** `RimeBridgeTests` Debug `test`，UDID destination，独立 DerivedData。
6. **F2-3** scheme `Universe Keyboard` Debug `test`（完整套件）。必须实际执行 `KeyboardTests/KeyboardHostLifecycleRecoveryGateTests` 17 个已 authored 方法；skip 另报 Product，不继承历史 29/30。
7. **F2-3b** **条件作业**：仅当 F2-3 xcresult 覆盖证据不足（17 项未列出、被 skip、或计数缺口）时补跑 `-only-testing:KeyboardTests/KeyboardHostLifecycleRecoveryGateTests`。完整套件已证明 17 项实际执行则 **跳过**。F2-3b 不能代替 F2-3。
8. **F2-4** 同 UDID Release `build`。这不是 Release 发布。
9. **F2-5** Keychain focused，签名参数同上。

gate 单测只证明状态 / action 计数，不证明通知投递、appex 控制器或 Maps / owner。

## 模拟器独占、备份、恢复与环境收尾

全文：[occupancy-backup-requirements.md](keyboard-wake-host-activation-fix-001-f2-artifacts/occupancy-backup-requirements.md)、[backup-path-status.json](keyboard-wake-host-activation-fix-001-f2-artifacts/backup-path-status.json)、[environment-wrapup.json](keyboard-wake-host-activation-fix-001-f2-artifacts/environment-wrapup.json)。

- 独占对象就是 `405D994F-…`。paired-rollout Active 须 Human 新鲜确认；未确认则停止，不改用 iPhone 17 Pro。
- **已存在、禁止覆盖：** M0、M2R1、M2R2、I0、F0、F1。
- **不存在：** T0 备份、keychain-continuation 备份、计划中的 F2 run 与 F2 backup。
- 执行前对该 UDID 新建 F2 before（main-data / App Group / installed-app），写入 `/private/tmp/ukey-host-activation-fix-f2-backup-20261004`，mode `0700`。
- 恢复：先保全 after，不覆盖 before；回到 F2 前用 F2 备份；回到 43d85d 只用 M0。不自动恢复。
- **成功 Exit：** 停后续副作用，保留独占与 before，交付隔离产物与 counts；不称 F3 / Gate / Release。
- **失败 Exit：** 停剩余命令，保留失败产物与 after，等待 Human 恢复 / Hold / 扩预算。
- **预算提案：** 墙钟 180 分钟与第一失败先到停止；不继承 F1 60/60；须在 F2 AUTH 钉死。
- **保留：** F2 run / F2 backup 直至 F3 消耗或 Human 删除授权；永不删历史 M0/I0/F0/F1；xcresult 与 DerivedData 不进 git。

因此独占与新鲜备份未满足，**不能进入 F2 Ready / Active。**

## 非声明

不是测试通过、不是修复验证、不是 F3 实现审查、不是 F4 安装 / Maps、不是 Gate / Release。未改 Assignment 生命周期镜像（交 root）。父诊断 Completed、rollout 子任务 Active、R2 仅设计条件通过保持。

## 下一合法动作

Human 批准 F2 执行授权（并钉死预算与 405D994F 独占）后，由 root 作为 Environment Executor：现场确认该 UDID 独占、新建 F2 before 备份与隔离运行目录、按冻结命令顺序跑矩阵并落盘 xcresult。缺授权、身份漂移或覆盖证据不足时按停止条件处理。

## Root 最终准备核验与单条命令修正 — 2026-10-04

358源树+168主App+630Vendor常规文件，共1156逐文件字节/大小/hash及三个聚合摘要复算匹配，五文件源码不变。四个test命令按原UDID且关闭parallel testing，focused仅条件执行。旧不透明digest由可复算清单替代。

Root仅修正F2-L-diff-check-untracked：删除吞错误的`|| true`/有限消息grep，显式检查两个新文件存在性，保留git诊断/退出状态；只接受正常no-index差异状态0/1且无诊断，其他全部失败。命令仅Prepared，未执行。原命令及前后packet hash保留于[root核验记录](keyboard-wake-host-activation-fix-001-f2-artifacts/root-final-preparation-review.json)。无需Grok继续扩写。

准备核验收口：仍Prepared，不是Ready或独立Quality验收。下一仅Human批准root执行F2（含备份、test-runner安装/启动、180分钟墙钟提案）及原UDID新鲜独占，然后root核现场身份/静默备份/完整输入等即时Entry。没有新源码、测试、构建或模拟器操作授权从本准备记录自动产生。
