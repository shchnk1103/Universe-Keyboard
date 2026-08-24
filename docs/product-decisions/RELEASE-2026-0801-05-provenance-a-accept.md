# Product Decision: RELEASE-2026-0801-05-PROVENANCE-A — 接受派生收据

**Decision ID:** `PD-RELEASE-2026-0801-05-PROVENANCE-A-ACCEPT`
**Lifecycle status:** `Recorded`
**Date / timezone:** `2026-08-23 Asia/Shanghai`
**Assignment:** [`RELEASE-2026-0801-05-PROVENANCE-A`](../assignments/release-2026-08-01-05-provenance-recovery-phase-a.md)
**Parent:** [`RELEASE-2026-0801-05`](../assignments/release-2026-08-01-05-app-store-materials.md)
**Evidence:** [`Phase A evidence and handoff`](../evidence/release-2026-08-01-05-provenance-recovery-phase-a-2026-08-23.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Recorded` |
| **Phase** | Phase A 派生收据已接受为外部 TestFlight 候选残留；未开 Phase B |
| **Non-claims** | 不是精确来源声明；不是法律意见；不关闭 App Store Connect 内容版权/类别保存；不授权 Vendor 重建、资源替换、RC 冻结或上传 |
| **Next** | 无；Human 已报告内容版权「是」、主要类别 `工具`、次要类别 `效率` 已在线保存 |
| **Residuals** | Lua `types.o` Boost.Regex 头文件有界无匹配；Luna 官方 blob + 单行 URL 补丁 |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead
- **Decision Source:** Human Product Owner 在 Grok 会话中于 `2026-08-23 Asia/Shanghai` 明示：接受当前 Phase A 派生收据，不开 Phase B
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

本 Decision 只处置 Phase A 工程来源收据。它不改变 RIME 运行时合同、Vendor 字节、Luna 资源字节或 App Store 在线字段。

## Bound Product Decisions

1. 接受下列收据为 **外部 TestFlight 候选的已知发布残留**，不再要求 Phase A 找出精确 Boost.Regex tag 或全字节 Luna 上游 blob：
   - `librime-lua`：官方 `hchunhui/librime-lua@ec52e48ea18f11af37717a01c337f853215cf70b` 加本地空 `opencc_init` stub；设备 arm64 与 Simulator arm64/x86_64 上 9/10 对象字节匹配。
   - `types.o`：使用 `re_detail_500`；在官方 Boost.Regex 1.88.0（500）/ 1.89.0（600）头文件版本边界记录为有界无匹配。
   - 捆绑 `luna_pinyin.dict.yaml`：官方 `rime/brise@4966835…` blob `728f883…` 加一行 Chewing 归属 URL 从 `chewing.csie.net` 改为 `chewing.im`。
2. **不开 Phase B。** 不重建、不替换、不重新打包 Vendor 或 Luna 资源。
3. **不再混合猜测 Boost 头文件** 去编译 shipped `types.o`。
4. 对外和 App Store Connect 材料不得把上述残留写成精确上游 tag 或未修改上游 blob。
5. 仓库支持的内容版权答案是：“Yes, the app contains or accesses third-party content and has the necessary rights.” Human Product Owner subsequently reported saving that answer in App Store Connect. The executor did not independently reopen the account to verify the field.
6. 若日后因其他原因重建 Vendor，可在新 Assignment 中用当前已绑定的 Boost 1.91 头文件重编 `librime-lua`；那是新的产物变更，不是对本 Decision 的默示授权。

## Explicit non-authorization

- Vendor / Luna / 清单变更
- RC 冻结、Archive 上传、TestFlight 分发或审核提交
- 把本 Decision 写成法律结论或 App Review 保证
- 自动保存 App Store Connect 内容版权或主要类别
- 关闭 `RELEASE-2026-0801-05` 的其余材料 Gate

## Related Documents

- [`assignments/release-2026-08-01-05-provenance-recovery-phase-a.md`](../assignments/release-2026-08-01-05-provenance-recovery-phase-a.md)
- [`evidence/release-2026-08-01-05-provenance-recovery-phase-a-2026-08-23.md`](../evidence/release-2026-08-01-05-provenance-recovery-phase-a-2026-08-23.md)
- [`evidence/release-2026-08-01-05-third-party-notice-provenance-2026-08-23.md`](../evidence/release-2026-08-01-05-third-party-notice-provenance-2026-08-23.md)
- [`product-decisions/RELEASE-2026-0801-external-testflight-candidate.md`](RELEASE-2026-0801-external-testflight-candidate.md)
