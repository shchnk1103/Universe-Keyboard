# F2 模拟器独占、备份、恢复与环境收尾（Prepared，未执行）

本页只列 F2 执行前必须满足的环境合同。准备轮次未运行 `simctl`、未备份、未恢复、未安装、未 mkdir 运行目录。

路径存在性快照：[backup-path-status.json](backup-path-status.json)（UTC `2026-10-04T08:40:00Z`）。

## 设备身份：原精确 UDID

F2 全部 iOS 作业绑定：

`platform=iOS Simulator,id=405D994F-28CB-4F89-BB22-B64AD81C05A2`

该 UDID 是 Assignment 指定的原精确模拟器（iPhone 18 Pro / iOS 27.0，M0 / 43d85d 占用谱系）。CI 工作流默认名称 `iPhone 17 Pro` **不能**自动授权换成另一台设备。命令必须按 `id=` 绑定；不得改回 `name=iPhone 17 Pro`，也不得在缺席时静默换机。

现场 Booted / busy / 是否仍存在该 UDID：**UNKNOWN**（禁止本轮 `simctl list` / boot / shutdown）。F2 授权后由 Environment Executor（root）在执行前现场核验。若该 UDID 不存在：停止并向 Product 报告，不得改用 CI 默认机。

## 独占

F2 执行前 Human 必须确认：

1. `405D994F-28CB-4F89-BB22-B64AD81C05A2` 本轮由本任务独占，无其他 agent / Xcode / UI 测试占用。
2. paired-rollout 子任务仍 Active：这是 **停止或确认条件**，不是换机理由。未获 Human 新鲜独占确认前，不得为跑测试去 boot、关机、重装或清理该 UDID。
3. 测试 runner 安装 / 启动是环境副作用，不能从 F1 或本 Prepared Entry 推断为已授权。
4. 关闭无关 Xcode 测试窗口；不并行第二套 `xcodebuild test`。所有 iOS `test` 命令带 `-parallel-testing-enabled NO`，禁止 xcodebuild 另开 worker 模拟器。
5. 构建产物写入唯一运行目录与独立 DerivedData / KeyboardCore `--build-path`，不污染共享默认缓存。

## 备份路径：存在 / 不存在

| 路径 | 本轮 stat | 用途 |
|---|---|---|
| `/private/tmp/ukey-wake-m0-20261003/backup` | **存在**，目录，mode `0700` | 历史 M0 / 43d85d / 405D994F 保护。禁止覆盖或删除。 |
| `/private/tmp/ukey-wake-m2r1-20261004/backup` | **存在**，目录，mode `0700` | 历史 M2R1。禁止覆盖或删除。 |
| `/private/tmp/ukey-wake-m2r2-20261004/backup` | **存在**，目录，mode `0700` | 历史 M2R2。禁止覆盖或删除。 |
| `/private/tmp/ukey-wake-ui-i0-20261003/backup` | **存在**，目录，mode `0700` | 历史 I0。禁止覆盖或删除。 |
| `/private/tmp/ukey-wake-ui-t0-20261003/backup` | **不存在** | 历史 T0 已清理谱系。不得重建冒充。 |
| `/private/tmp/ukey-wake-ui-keychain-continuation-20261003/backup` | **不存在** | 不得冒充已有 Keychain 备份。 |
| `/private/tmp/ukey-host-activation-fix-entry-20261004` | **存在**，目录，mode `0755` | F0 源码字节副本。禁止覆盖或删除。 |
| `/private/tmp/ukey-host-activation-fix-grok-f1-20261004` | **存在**，目录，mode `0755` | F1 Grok 交付。禁止覆盖或删除。 |
| `/private/tmp/ukey-host-activation-fix-f2-run-20261004` | **不存在** | 计划中的唯一运行目录。AUTH 后新建。 |
| `/private/tmp/ukey-host-activation-fix-f2-backup-20261004` | **不存在** | 计划中的 F2 before 备份。AUTH 后新建，mode `0700`。 |

历史 M0 保护的是同一 UDID 上的 43d85d 诊断现场，**不能**代替 F2 执行前的新鲜 before 快照。F2 必须新建独立备份，不得覆盖上表任一已存在路径。

## 备份范围（执行前新建）

对 `405D994F-28CB-4F89-BB22-B64AD81C05A2` 做完整 before 保护，至少：

- 主 App data container
- App Group `group.com.DoubleShy0N.Universe-Keyboard`
- 已安装 `Universe Keyboard.app` / Keyboard.appex 库存（若存在）

写入 `/private/tmp/ukey-host-activation-fix-f2-backup-20261004/`，mode `0700`。记录 bytes / 结构 / mode，不把用户词条或宿主文字写入仓库。

不备份：系统键盘设置、Keychain、Maps 用户内容（与 M0 合同一致）。

## 恢复步骤（Prepared，不执行）

成功或失败均 **不自动恢复**。恢复另需精确授权。

1. 先重新核 UDID、独占、进程与当前容器；保全 **after** 三组快照及库存，不得覆盖 F2 before 或任何历史备份。
2. 将 after 与 F2 before 逐路径对比内容 / 存在性 / metadata；区分系统容器 metadata、合法新 UUID 与应用内容；写明恢复会丢掉哪些之后的数据。
3. 未经具体批准：不停止新进程、不重装、不覆盖文件、不 erase 模拟器。
4. 若授权回到 **F2 执行前** 现场：只使用 `/private/tmp/ukey-host-activation-fix-f2-backup-20261004` 中的 main-data / app-group / installed-app。
5. 若授权回到 **43d85d 诊断现场**：只申请既有 M0 配对包与 [M0 恢复方案](../../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m0-recovery-plan-2026-10-03.md)；不得把 F2 测试安装混进该身份。
6. 读回签名 / payload / 库存后，机器字节相等不代替运行健康。恢复失败交付 Hold，不自动重试或重新部署。
7. 恢复读回不是 F2 质量通过，也不是 F4 Maps 证据。

## 环境 Exit

### 成功后

1. 停止后续 `xcodebuild` / `swift test` / `simctl` 副作用。
2. 不卸载、不 erase、不覆盖 before 备份。
3. 记录 after 库存（已装身份 hash）与完整 skip / actual counts；不把该记录称为 F4。
4. 模拟器保持授权开始时约定的占用；未经 Human 确认不关机、不释放独占。
5. 交付隔离运行目录中的 xcresult、日志、工具链 / Vendor / 五文件 / 构建输入 hash。
6. F2 证据交付不是 F3、不是 Gate、不是 Release。

### 失败或中止后

1. 立即停止剩余命令，不凑数重跑。
2. 保全 after 库存与失败 xcresult / 日志 / DerivedData。
3. 不自动恢复、不覆盖 before、不删除历史备份。
4. 报告失败步骤 id、exit code、destination UDID、候选 hash 是否仍匹配。
5. 环境保持可恢复检查点，等待 Human 决定恢复 / Hold / 扩预算。

## 执行预算（Prepared 提案，须在 F2 AUTH 钉死）

F1 的 60 tool-call / 60 分钟预算 **不继承** 到 F2。

提案（AUTH 可改，未钉死不得开跑）：

- 墙钟 **180 分钟**，与第一失败先到停止。
- 作业串行：分类 / 轻量 → format → KeyboardCore → RimeBridgeTests → App+Keyboard →（条件 F2-3b）→ Release build → Keychain。
- 不自动续预算。超时或失败保存产物后停止，由 Product 决定是否扩预算或换 Entry。

## 停止条件

出现任一项即停止相应依赖阶段并保存交付：

- 五文件 hash 相对 F1 freeze 漂移
- 构建输入 inventory（scheme / Package.swift / Vendor receipt / Core-Presentation 依赖 / source-tree digest）漂移
- Vendor `verify` 失败
- destination 不是 `405D994F-28CB-4F89-BB22-B64AD81C05A2`，或该 UDID 缺席
- Human 未确认独占，或 paired-rollout Active 冲突未解决
- 计划备份路径已存在且会覆盖，或历史保护路径将要被写入
- 任一 **required** 作业非零退出
- 新 skip 无 Product 决定
- 需要五文件外源码、发现并发 writer
- format lint 失败
- 试图用 SHA-to-SHA 空 diff 或 `docs_only` 跳过 heavy 矩阵
- 预算耗尽

不 reset / revert 全文件，不替换 worktree，不顺手追加 Core scope。

## 产物保留范围

**保留（默认至 F3 消耗身份或 Human 删除授权）：**

- `/private/tmp/ukey-host-activation-fix-f2-run-20261004`（xcresult、logs、DerivedData、KeyboardCore build-path）
- `/private/tmp/ukey-host-activation-fix-f2-backup-20261004`
- 上表全部 **存在** 的历史备份与 F0 / F1 副本
- 写入 `docs/evidence/` 的命令、skip 身份、actual counts、hash 回执

**不保留进 git：** xcresult、DerivedData、Vendor 二进制 payload、模拟器容器内容、用户词条。

**不得删除：** M0 / M2R1 / M2R2 / I0 / F0 / F1。`/private/tmp` 非长期存储；hash 与命令回执应在执行后写入仓库证据，原始容器副本仍留 private tmp。

## 本轮未做

未创建 F2 run / backup 目录，未 ditto，未 erase，未安装测试 runner，未 boot 模拟器。因此 **F2 Entry 未 Ready**。
