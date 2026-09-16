# SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001 — Assignment Close

日期：2026-09-16 Asia/Shanghai

**性质：** Human Product Owner 在当前任务中授权的工程 **Assignment Close**。
它关闭主 App runtime-route integration scope，不把已知证据边界升级为产品或发布结论。

**Assignment：** [`SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001`](../assignments/scheme-delivery-runtime-route-integration-001.md)

**观察基线：** Close 文档编辑前，`main` 为 `89a78a5c4644e0d60dbf2ba149bf11dac0d4688b`，
tree 为 `ccc25cc801442be3e0a9c879b56bde4cd4d47de0`。本 Close 文档尚未 commit 或 push。

## Close basis

| 条件 | Close 时结论 |
|---|---|
| Route transaction 与 recovery-incomplete 契约 | **Met** — P1 最终独立复审确认七条冻结序列、结构化 payload、同一 operation UUID 与 live lease identity 证据 |
| 自动化验证 | **Met for P1 contract scope** — 最终复审记录 strict format、KeyboardCore、受影响 route 场景及实现 tip 的验证；完整 CI 等价门不由该复审替代，按下表保留证据边界 |
| 设备 / diagnostics follow-up | **Met as separate bounded slices** — DEVICE-001、RTRD-01、RTRD-02 已分别有 Close 与 residual disposition |
| 关闭权限 | **Met** — 当前 Human Product Owner 授权本 Assignment Close；未授权 Product Gate 或 Release |

## Residual disposition at Close

| Residual | Owner | Disposition | Pointer |
|---|---|---|---|
| `RTRI-01` App Group 多 key route 写入的跨进程/崩溃原子性 | Main App / Architecture | `accept` | [`P1 final independent review`](../reviews/scheme-delivery-runtime-route-integration-001-p1-final-independent-review.md)；本 Close 不声明一般原子性 |
| `RTRI-02` matched T9 persisted resolver 与 inactive binding 后续切换策略 | KeyboardCore / Main App | `accept` | [`P1 final independent review`](../reviews/scheme-delivery-runtime-route-integration-001-p1-final-independent-review.md)；后续改变需新 Assignment |
| `RTRI-03` commit cleanup 实际结果与诊断语义 | Main App / Quality | `accept` | 同上；不把 `commit:succeeded` 升级为 crash/restart cleanup 证明 |
| `RTRI-04` RimeBridge/Extension runtime、真实 App Group、candidate input、完整设备矩阵 | Human Device Operator / Quality | `accept` | [`DEVICE-001 evidence`](scheme-delivery-runtime-route-device-001-2026-09-09.md)；保留其 Device-attested functional Pass with conditions 边界 |
| 完整 CI 等价门（最新独立复审未替代的范围） | Environment Executor | `accept` | [`P1 final independent review`](../reviews/scheme-delivery-runtime-route-integration-001-p1-final-independent-review.md) 明确保留该边界；不扩展为当前 Release proof |
| elapsed 字段注释的 wall-clock 用词 | Main App / Documentation | `accept` | P1 final review residual note；实现使用 monotonic `DispatchTime`，后续文档卫生可单独处理 |
| `RTRI-05` recovery-incomplete 语义、完整序列与 lease evidence | Main App / Quality | `fix` | P1 final independent review：该项已满足并在 Close 时记为 closed |

## Disposition

- Assignment Lifecycle：**Closed**。
- Next for this Assignment：**none**。若要解决 `RTRI-01…04`、增加普通 Luna 耗时对照、
  扩大 Extension/真实 App Group 矩阵或调整 route contract，必须建立新的 Assignment / Authorization。
- `SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001`、`RTRD-01`、`RTRD-02` 的生命周期不由本
  文档重新决定；它们的现有 Close 记录继续有效。

## Explicit non-claims

- **Closed ≠** Product Gate / TestFlight / App Store Connect / Release。
- 不声明 fallback deployment 已恢复至普通 Luna 的性能、真实 App Group crash atomicity、
  完整 Extension runtime 或所有用户布局切换安全性。
- 本 Close slice 只有文档变更；未执行 Swift 格式、xcodebuild、设备操作、commit、push 或发布动作。
