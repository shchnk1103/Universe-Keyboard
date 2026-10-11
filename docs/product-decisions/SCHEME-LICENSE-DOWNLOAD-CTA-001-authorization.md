# Product Decision: SCHEME-LICENSE-DOWNLOAD-CTA-001 — 第三方方案许可下载单按钮

**Decision ID:** `PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`
**Lifecycle status:** `Recorded — implementation authorized`
**Date / timezone:** `2026-09-23 Asia/Shanghai`
**Assignment:** [`SCHEME-LICENSE-DOWNLOAD-CTA-001`](../assignments/scheme-license-download-cta-001.md)
**Authorization:** [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-001`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-001.md)

## Bound Product Decisions

Human Product Owner locked:

1. **Single first-download CTA.** 每个主 App 第三方方案**首次下载**入口只有一个按钮，文案 **「查看许可并下载」**。禁止并排「查看许可证」+「同意并下载」，也禁止未接受许可时把下载按钮做成灰色可点/不可点双态。
2. **Sheet first.** 单击该按钮只打开既有 `SchemeLicenseView` 许可证 sheet，不在卡片上直接 `startDownload`。
3. **Sheet confirm.** sheet 底部主按钮文案 **「同意并下载」**。单击后：记录许可接受，并开始该方案的下载与随后部署。关闭（右上角）不下载。
4. **Shared copy.** 设置方案详情、启用引导准备资源、以及其它会拉起同一下载许可 sheet 的入口，使用同一套文案。
5. **Already-installed management stays.** 已安装方案的管理网格「许可证 / 检查更新 / 重新下载 / 卸载」不是本 CTA。失败重试仍是「重试」。

## Non-goals

- Keyboard Extension
- 改变 `SchemaManager` 下载/部署引擎、许可存储键或 checksum
- 引入品牌强调色或第二套按钮组件
- commit / push / merge / TestFlight / Release
