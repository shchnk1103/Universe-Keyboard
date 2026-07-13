# ADR 0012: RIME Portable Sync And Transport Boundary

## Status

Partially superseded by [ADR 0013](0013-rime-standard-sync-interoperability.md).
The encrypted Universe settings package remains accepted as an auxiliary layer.

## Context

Universe Keyboard 需要在 iPhone、macOS、Windows、Linux 和 Android 之间同步 RIME 设置。RIME 本身提供 `sync_dir`、`installation_id` 和用户资料同步能力，但它不提供云传输服务；配置文件主要是单向备份，用户词典快照才执行合并。

当前仓库只具备 App Group entitlement，没有 iCloud entitlement。Apple 的 CloudKit 配置要求有效的 Apple Developer Program membership、开发团队和 iCloud container，因此当前不能把 CloudKit 作为可验证实现基础。

同步还会改变 ADR 0007 的“数据不得离开设备”边界。必须区分用户主动启用、端到端加密的同步与无同意的遥测或上传。

## Decision

建立传输无关的开放同步包和主 App 同步编排器：

- 领域层只依赖 `SyncTransport` 能力，不依赖 CloudKit、WebDAV 或文件提供器类型；
- WebDAV 是 Universe 私密设置的跨平台传输适配器；RIME 标准文件夹由 ADR 0013 定义为跨 App 主路径；CloudKit 是会员和 entitlement 可用后的可选适配器；
- Universe 私密设置包 V1 只同步管理型设置；可移植配置文件、输入历史和学习数据不在该加密包。RIME 用户词典文本快照由 ADR 0013 的标准同步路径处理；
- 云端对象必须先在设备端加密；服务器不持有明文内容密钥；
- 所有扫描、网络、加密、导入、恢复和部署都由主 App 执行；Keyboard Extension 保持 session-only、offline 和 hot-path-free；
- 管理型设置只通过现有偏好和主 App 部署入口应用；配置文件后续必须采用 staging、校验、恢复快照、提交和部署的事务式顺序；失败不破坏当前可用部署；
- 未来用户词典同步必须调用 librime 官方 `sync_user_data` / 文本快照合并路径，不复制或覆盖运行中的 `*.userdb*`。

本 ADR 对 ADR 0007 作有限 supersession：允许用户在主 App 中明确开启、可撤销、端到端加密的 RIME 同步。ADR 0007 对键盘输入、诊断、Typing Intelligence、默认本地处理、无同意上传和 Full Access 的其余限制继续有效。

## Alternatives Considered

### CloudKit Only

拒绝作为核心方案。当前缺少可用 membership/container/entitlement；它也会把跨平台协议耦合到 Apple 服务和身份体系。保留为 Apple 设备体验适配器。

### RIME `sync_dir` Directly Bound To A Cloud Folder

拒绝作为完整产品架构。它适合用户词典快照和根目录配置备份，但不提供云传输、端到端加密、设置字段合并、完整配置恢复、冲突 UX 或跨平台兼容声明。

### Universe Keyboard Hosted Account Service

暂不采用。它能提供更易用的账号体验，但引入账号、服务端运营、合规、成本、删除承诺和事故响应，超出当前产品基础。

### Copy Live `*.userdb*` Files

拒绝。当前已有 TD-002 并发风险和 ADR 0005 恢复安全缺口；跨进程复制或覆盖运行数据库可能损坏或丢失学习数据。

## Consequences

- 需要定义版本化同步包、加密密钥恢复、冲突记录和适配器 contract。
- 主 App 将拥有新的网络和持久数据操作；隐私政策、错误模型和删除流程必须更新。
- 桌面和 Android 需要兼容客户端或 CLI 才能直接消费 Universe 设置语义；仅配置共享文件夹不会自动完成应用与部署。
- CloudKit 不再阻塞跨平台 V1，但其后续实现仍需要付费会员、container、签名和真实设备验证。
- RIME 用户词典标准同步由 ADR 0013 定义并复用 librime 的快照合并语义；运行中数据库复制、自动恢复和跨进程并发风险仍受 ADR 0005 与 TD-002 约束。

## Risks

- 用户丢失恢复码会无法解密远端数据。
- 自定义 YAML 可包含平台差异或危险路径引用，需要严格 allowlist 和 staging 验证。
- iOS 后台执行不可保证，UI 不得承诺实时同步。
- WebDAV 服务实现差异可能影响 ETag、原子移动和锁语义。
- 多端逻辑版本与文件冲突实现不正确会造成设置回退或数据分叉。

## Follow-up Work

- 发布并执行 `RIME-SYNC-001` 分阶段计划。
- 在实现前更新隐私政策、共享容器数据表、调试流程、Release Gate 和 TECH_DEBT。
- 定义同步包 JSON Schema、加密测试向量和跨平台兼容夹具。
- 完成标准同步的真机、跨进程与跨前端验证；ADR 0005 与 TD-002 仍约束本机恢复、清空和运行中数据库操作。
- Apple Developer Program 开通后创建 CloudKit 专项 revalidation，不直接复用未经验证的 entitlement 假设。

## Related Documents

- [`RIME_SYNC.md`](../../RIME_SYNC.md)
- [`RIME_USER_DICTIONARY.md`](../../RIME_USER_DICTIONARY.md)
- [`shared-container-and-rime-lifecycle.md`](../shared-container-and-rime-lifecycle.md)
- [`ADR 0003`](0003-shared-container-ownership.md)
- [`ADR 0005`](0005-user-dictionary-restore-safety.md)
- [`ADR 0007`](0007-full-access-and-privacy-boundary.md)
- [`TECH_DEBT.md`](../../TECH_DEBT.md)
