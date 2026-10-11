# Product Decision: APP-ABOUT-001 — 主 App「关于」页

**Decision ID:** `PD-APP-ABOUT-001`
**Lifecycle status:** `Recorded — Product Gate Accepted; Assignment Closed`
**Date / timezone:** `2026-09-28 Asia/Shanghai`
**Assignment:** [`APP-ABOUT-001`](../assignments/app-about-001.md)
**Authorization (this slice):** [`AUTH-APP-ABOUT-001`](../authorizations/AUTH-APP-ABOUT-001.md)
**Authorization (implementation):** [`AUTH-APP-ABOUT-001-IMPLEMENT`](../authorizations/AUTH-APP-ABOUT-001-IMPLEMENT.md)
**Quality review:** [`app-about-001-quality-review.md`](../reviews/app-about-001-quality-review.md) — **Pass with conditions**
**Authorization (Product Gate):** [`AUTH-APP-ABOUT-001-PRODUCT-GATE`](../authorizations/AUTH-APP-ABOUT-001-PRODUCT-GATE.md)
**Product Gate:** [`PD-APP-ABOUT-001-PRODUCT-GATE`](APP-ABOUT-001-product-gate.md) — Accepted

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Recorded — Product Gate Accepted |
| **Phase** | 合同仍有效；Assignment `Closed`（Human Product Gate Passed with accepted evidence conditions） |
| **Non-claims** | 不等于 Device-attested、commit / push / merge、TestFlight 或 Release |
| **Next** | 本 Assignment 无下一步；TestFlight 或 Release 另需授权 |
| **Residuals** | `ABOUT-01`–`ABOUT-05` 已由 Product Gate 接受 |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner, acting as Product Lead in the current Grok session (`2026-09-28 Asia/Shanghai`). Human 锁定入口、通道、邮件主题格式，并决定把「隐私与数据」与「开源软件与内容」挪进关于页。
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 📱 App & Data Operations Maintainer（主 App 设置 / 关于 SwiftUI）
- **Architecture / Quality:** Architecture review **Not Applicable** while the page stays in the main App, opens user-tapped `mailto` / URL, and does not change keyboard network or Full Access claims. Quality, Performance & Release Maintainer is required after the implementation slice lands.

This Decision records the **About-page product contract**. The record slice does **not** mutate Swift.

## Product Problem

主 App 没有一处展示当前安装身份（营销版本 + Build），也没有官方联系通道。设置「App 设置」同时堆了外观/通知（会改行为）和隐私/开源（认识产品），列表偏长。用户要报公测问题或找维护者时，只能离开 App 猜版本。

「键盘反馈」是按键音/震动，启用指南在设置右上角问号。这两处都不是「关于」。

## Bound Product Decisions

Human Product Owner locked:

1. **Entry.** 设置 Tab →「App 设置」分组末行，标题 **「关于」**。不是第四个 Tab，不是首页卡片，不是问号按钮。
2. **Identity.** 关于页展示应用名、以及**当前安装包** Info.plist 中的 `CFBundleShortVersionString`（营销版本）和 `CFBundleVersion`（Build）。版本与 Build 可复制。关于页不编写、不递增这些数字。
   - 本地 Debug / Simulator 安装读工程默认值。当前仓库 `MARKETING_VERSION=1.0`、`CURRENT_PROJECT_VERSION=1`，因此模拟器显示 `1.0` 与 Build `1` 是预期结果。
   - 公测（TestFlight）与正式版显示的是**那一次上传包**写入的营销版本和构建号，例如历史导出包 `1.0 (55)`。用户装的是 55 号包，关于页就显示 55。
   - 构建号如何为每一次上传选取、App 与键盘扩展必须同号、以及换号即新候选，由 [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md) 的 “Installed Version And Build Identity” 拥有。关于页只反映安装结果。
3. **Contact channels (current).** 仅：
   - 邮箱 `doubleshy0n@gmail.com`，用系统邮件；
   - 小红书 `https://xhslink.cn/o/7lEn4EM0BtP`（Human 接受短链）。
   无 Telegram、Discord、GitHub Issues、应用内工单。
4. **Mail subject.** 打开邮件时预填主题 `Universe Keyboard 反馈 · {version} (Build {build})`，例如 `Universe Keyboard 反馈 · 1.0 (Build 55)`。正文留空。不自动附诊断日志、输入内容或截图。
5. **Settings IA.** 「隐私与数据」和「开源软件与内容」从设置「App 设置」移除，改为关于页内的导航行，仍进入现有 [`PrivacyDataView`](../../Universe%20Keyboard/Views/Settings/PrivacyDataView.swift) 与 [`OpenSourceLicensesView`](../../Universe%20Keyboard/Views/License/LicenseView.swift)。不把这两页正文摊进关于页。设置「App 设置」只保留：外观、通知与提醒、关于。
6. **Search.** 设置搜索可命中关于、版本、邮箱、小红书、隐私、开源。隐私与开源可直达原页。
7. **Copy.** 联系区用「联系我们」，避免和「键盘反馈」撞名。
8. **Privacy boundary.** 邮箱与小红书仅在用户点击后由主 App 打开系统处理器。键盘扩展不增加入口。不上传输入。

## Non-goals

- Keyboard Extension UI
- Telegram / Discord / 应用内表单 / App Store 评分 / 更新日志
- 自动附带诊断或输入内容
- 改隐私承诺正文或许可证原文（只改入口）
- 改启用指南问号
- commit / push / merge / TestFlight / Release
- Profile include / `required` mode

## Related Records

- Visual SoT: [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)
- Installed version/build at release: [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md)
- Privacy source: [`PRIVACY_POLICY.md`](../PRIVACY_POLICY.md)
- Help packaging (问号仍独立): [`PD-HELP-TIPKIT-001`](HELP-TIPKIT-001-authorization.md)
- Playbook: [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- Assignment: [`APP-ABOUT-001`](../assignments/app-about-001.md)
