# RIME-SYNC-001 bounded iOS V1 最终 Architecture 复审 — 2026-09-24

## Verdict

**Blocked。** 本次复审在本地文件夹私密包删除路径发现新的 P1：目标存在性无法判定时，`fileExists` 可将“缺失”与“无法访问/解析”合并为 `false`，调用随后正常返回；ViewModel 因而可能向用户显示断开/删除成功，而私密包仍留在目的地。删除是隐私与数据生命周期合同的一部分，当前实现和证据未证明该情形会 fail closed。

解除条件：让本地删除仅在确认包不存在或确认删除完成时报告成功；无法确认时抛出错误并保持失败反馈。增加针对“存在性无法判定/访问失败”与“确实不存在”两种情况的回归覆盖，并由独立 Architecture reviewer 对修复后的精确快照重新复审。不得以既有 fake transport 成功用例代替 provider 删除语义证据。

## 精确快照绑定

| 项目 | 值 |
|---|---|
| Repository | `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard` |
| HEAD | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| `git diff --binary` SHA-256 | `627e18f2a60886cb8d971c18b9d6b5bd7f94c406bc4be7eb464a95036bbc6215` — 独立复算匹配 |
| 候选 manifest | 38 个路径；按用户给定算法独立复算 SHA-256：`87ab2543ed4c79b213eaaabb515933d984f5402d3fd10169437c00b0985fa29a` — 数量与摘要均匹配 |
| 排除路径 | 本 receipt `docs/reviews/rime-sync-v1-final-architecture-review-2026-09-24.md` 与指定 Quality receipt `docs/reviews/rime-sync-v1-final-quality-review-2026-09-24.md` |

Manifest 算法：合并 `git diff --name-only --no-renames` 与 `git ls-files --others --exclude-standard -z` 路径，排序并排除上述两条路径；逐文件计算 SHA-256，按 `<digest> 两空格 <path>\n` 拼接后再计算 SHA-256。候选 38 项的路径与内容绑定在本次复算时匹配用户提供值。没有发现快照漂移。

## 评审方法与独立性

- 本人作为 Architecture & Knowledge Steward，在本复审 runtime 中独立完成源文件、测试、合同、ADR、隐私约束、技术债及既有证据的只读核对；未参与该候选实现或证据制作，也未采用历史 Architecture/Quality verdict 作为本轮结论。
- 按仓库入口阅读 `AGENTS.md`、Knowledge Index、Active Work、Reading Maps、AI Workflow、Assignment Policy；加载 Portable RIME Sync 所需 Main App UI、RimeBridge 与 Test/Release playbook，以及 `RIME-SYNC-001` Assignment、RIME 合同、ADR 0012/0013/0014、共享容器/用户词典/隐私 ADR 与相关隐私政策。
- 对 38 项候选做精确摘要验证；阅读本次实现差异、删除/条件写入/诊断/Keychain/自动同步路径、相关测试和 UI fixture。历史 receipts 仅用于识别既有 finding 和证据边界。
- 未运行 build/test，未访问设备或网络，未改变源代码、测试、状态镜像或外部状态。本文件是唯一新增文件，且是用户指定的 review receipt。

## Findings

### 新 finding

#### `ARCH-RIME-SYNC-001-FINAL-P1-01` — 本地私密包删除可能把未知状态报告为成功

**等级：P1 · Open · 阻止 Architecture Accept。**

- `Universe Keyboard/Services/RimeSyncTransport.swift:266-270` 在协调写访问闭包内，以 `fileManager.fileExists(atPath:)` 判断 `universe-rime-sync` 是否存在；返回 `false` 即直接正常返回。Foundation 的该接口无法将“不存在”与“无法解析/访问”可靠地区分。此处没有再读取或验证目录状态，也没有要求 `removeItem` 成功。
- `Universe Keyboard/Models/RimeSyncViewModel.swift:812-853` 在 transport 删除正常返回后才清除本机密钥/配置，并将状态设为 `.notConfigured`；所以 transport 的假成功会被上层表现为删除/断开完成。
- `UniverseKeyboardTests/RimeSyncTests.swift:650-673` 覆盖可访问的临时目录中删除成功并保留标准 RIME 文件；它没有覆盖目标存在性不可判定或访问受限时必须失败的语义。Quality receipt 中的 UI 删除成功/失败用例使用 fake transport，receipt 自己也限定其只验证 App 状态迁移，不证明 provider 端删除。
- **必要处置：** 使用能区分确认缺失、确认存在、访问错误的文件协调/文件系统结果；只有前两种中的“确认缺失”或成功删除可作为成功结果，其余均向上传播为失败。加入未知/拒绝访问路径测试，断言私密包未被删除时不会清除本地密钥或报告成功；之后对同一最终 package fresh re-review。Product 如需接受剩余 provider 限制，应另行作出明确、窄范围决定；本 review 不代行该接受。

### 历史 Architecture findings 的本轮状态

| 稳定 ID | 原等级 / 本轮状态 | 本轮独立核对 |
|---|---|---|
| `ARCH-RIME-SYNC-001-P1-01` | 历史 P1；当前实现已修复 | `RimeSyncTransport.swift:248-263,285-297` 只把 Cocoa 明确 `fileReadNoSuchFile` 视作缺失；其它读取错误向上传播，并在任何包写入前比较 ETag。`RimeSyncTests.swift:615-648` 覆盖不可读既有目标及不得部分写入。仅确认该旧 finding 在绑定候选中的修复，不替代本轮整体 verdict。 |
| `ARCH-RIME-SYNC-001-P1-02` | 历史 P1；继续 `tech_debt:TD-002` | `docs/TECH_DEBT.md:18-26` 明确跨进程 Main App / Keyboard Extension 的 `Rime/user` 并发风险仍开放；进程 gate 与活动心跳只是缓解，不是跨进程互斥证明。Product 对债务留存的授权不构成技术解决或无风险接受。 |
| `ARCH-RIME-SYNC-001-P2-01` | 历史 P2；当前映射已修复 | `RimeSyncTransport.swift:25-50,107-155` 对已知错误使用有限固定码，忽略底层 NSError 细节，未知错误归为 `unknown`；测试 `RimeSyncTests.swift:529-564` 覆盖稳定值与私有底层信息不外泄。本轮直接审查当前代码，不继承旧 P2 receipt 的 verdict。 |

## 合同与边界核对

- **所有权：** ViewModel、transport、Keychain 与调度器均由主 App 的 `Universe Keyboard/` 路径承载。Keyboard Extension 的 RIME 同步相关入口仅更新短期活动心跳；未发现网络、文件扫描、加解密或同步协调进入键盘热路径。同步继续使用 librime 标准 `sync_user_data` 请求；未发现复制/替换活动 `*.userdb*` 的路径。
- **私密数据与密钥：** 私密设置用 ChaCha20-Poly1305 与版本绑定 AAD 加密；WebDAV Basic authorization 仅由要求 HTTPS 的配置入口提供；内容密钥与 WebDAV 密码分开存于 Keychain，访问属性为 `AfterFirstUnlockThisDeviceOnly`。格式/域分层和隐私合同仍排除输入、词典、诊断、学习数据和 YAML/TXT 导入。
- **条件写入/冲突：** WebDAV 使用 `If-Match` / `If-None-Match`；本地 transport 使用当前内容 SHA-256 与调用方 ETag 比较，读取失败不会被误作不存在。冲突由协调器重新 fetch、合并并重试。新 finding 仅针对删除目标的存在性判定，不改变上述写入结论。
- **删除语义：** WebDAV 只对目标私密包根发 DELETE；本地实现也限定删除 `universe-rime-sync`，测试确认标准 RIME 文件保留。然本地缺失/无法判定语义仍不满足严格成功反馈，见 P1 finding。Provider 服务端传播结果也未由 fake transport 测试证明。
- **后台安全门：** `RimeSyncViewModel.synchronizeAutomatically` 先检查自动开关、标准同步子项、有效配置、首次手动成功、冷却、键盘活动心跳，再取得进程内 gate；调度器由 Main App 注册 `BGProcessingTask`。`earliestBeginDate` 仍被描述为最早机会，不承诺准时或保证派发。进程 gate 不跨 Extension 进程，保持 TD-002 边界。
- **Product residual / debt：** QR-CURRENT-01 仅接受 2026-09-23 Quality-reviewed run 与 2026-09-24 exact-run confirmation 的 MCP discovery-count reporting residual；不声称工具根因修复、不改变 10 个 skipped，也不外推未来计数。UI-02 的窄设备未测和设备来源绑定不足只按指定 Product Decision 接受，不算通过。`TD-002`、`TD-008`、`TD-013`、`TD-017` 仍 Open/Deferred；Run 02 仍为 INVALID 历史记录。未发现本快照把这些债务或非声明弱化为已解决。

## Verdict 的适用范围与非声明

本 `Blocked` 只表示上述最终 bounded iOS V1 候选未获得 Architecture Accept。它不撤销或扩大 Product 对 QR-CURRENT-01、UI-02 或指定技术债的既有窄决定。

本 receipt 不构成 Quality verdict、Product Gate/接受、Assignment 生命周期关闭、merge、commit、push、TestFlight 或 Release 授权；不声明 provider 删除的远端传播结果、真机 Keychain、后台系统派发可靠性、跨进程互斥、CloudKit、全平台兼容或未来 MCP 计数正确。父项 `RIME-SYNC-001` 仍为 `Active`。本复审未运行测试；既有 Quality / simulator / device 证据仍各自绑定其 receipt、运行和限制。
