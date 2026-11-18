# Release SOP

本文件是 Universe Keyboard 的端到端发版流程入口；逐项验收字典以 [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) 为准，历史变更以 [CHANGELOG.md](../CHANGELOG.md) 为准。发版动作必须分别取得 Human 授权，流程文档本身不授予 push、Tag、TestFlight、Release 或 App Store 提交权限。

- 权威边界：项目协作与发布授权见 [AGENTS.md](../AGENTS.md)；门禁分类见 [CI_CHANGE_CLASSIFICATION.md](CI_CHANGE_CLASSIFICATION.md)；证据复用见 [AI_WORKFLOW.md](AI_WORKFLOW.md)。
- 文档影响：本 SOP 只定义顺序和交付物；不复制逐项清单，不创建 ADR，也不改 `CHANGELOG.md` 的日期式格式。文档责任、依赖和归档条件见 [DOCUMENTATION_GOVERNANCE.md](DOCUMENTATION_GOVERNANCE.md)、[KNOWLEDGE_DEPENDENCIES.md](KNOWLEDGE_DEPENDENCIES.md)、[DECISION_TREES.md](DECISION_TREES.md) 与 [DOCUMENTATION_HEALTH.md](DOCUMENTATION_HEALTH.md)。
- 角色与导航：主要按 [Documentation Maintainer](playbooks/documentation-maintainer.md) 维护文档；逐项验收仍由 [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) 持有。首份版本档案见 [v1.0.1.md](releases/v1.0.1.md)。

## 每次发版的固定 5 步

1. **开版盘点**：明确目标版本与基线 commit；核对未关闭债务、合规项与未完成真机门禁；创建 `docs/releases/vX.Y.Z.md` 版本档案，写入目标、基线、状态、Owner、归档条件和当期变更清单。
2. **收口与文档**：完成当版合规说明或必要修复；核对 `CHANGELOG.md` 中现行日期式条目是否齐备（仓库没有 `[Unreleased]` 区块，不引入 Keep-a-Changelog 结构）；在版本档案中起草商店更新文案（What's New）与 Review Notes。
3. **封版与门禁**：按发布决定更新 `MARKETING_VERSION`；`CURRENT_PROJECT_VERSION` 按 `RELEASE_CHECKLIST.md` 由 Xcode Cloud 或上传包递增写入；在本地跑通对应分类的 CI 门禁，并由 Human 完成真机必测矩阵。CI 绿不替代真机、性能、签名、隐私或 Product/Release 门禁。
4. **打包与提审**：确认 `main` 上封版 commit 的 `push` CI run 为 `success`；按 `RELEASE_CHECKLIST.md` 规则打 Tag：App Store 正式包用 `appstore/<version>-<yyyymmdd>`，TestFlight 用 `testflight/<version>-<yyyymmdd>`；用 Tag 触发 Xcode Cloud 打包上传，核对 App Store Connect 元数据、隐私问卷与 Build 号后提交审核。Tag、上传、分发和审核提交分别授权、分别记录。
5. **发版收尾**：上线/审核通过后把版本档案状态更新为 `Released`，补全 Build 号与上线日期；按 `CHANGELOG.md` 现行日期式格式补充一条版本发布标记条目；归档发版任务，并在必要镜像中同步完成状态。

## `docs/releases/vX.Y.Z.md` 标准档案模板

```markdown
# vX.Y.Z Release Record

- Status: In Preparation | Release Candidate | Released
- Target: <App Store / TestFlight / internal>
- Baseline commit: <sha>
- Release commit / tag: <pending or sha/tag>
- Build: <pending or App Store Connect build number>
- Owner: Test / Release
- Archive condition: Released + Build + 上线日期 + 发版任务归档后

## Scope

- <user-visible change 1>
- <user-visible change 2>
- 来源：`CHANGELOG.md` 与 <audit / review report path>

## Compliance

- 剪贴板、隐私问卷、Review Notes：<current wording / pending Human decision>
- 内置方案与第三方许可：<manifest / license inventory / residual>
- 安全与实验代码隔离：<wired / not wired / compile-condition evidence>

## Gates

- 版本号与构建号：<pending / done>
- 本地与托管 CI：<pending / run + conclusion>
- Human 真机必测：<pending with exact checklist>
- Product / Release 授权：<pending / authority record>

## Store Copy Draft

- What's New（中文）：<draft>
- Review Notes 建议稿：<draft>

## Release Closeout

- Released date: <pending>
- Build number: <pending>
- CHANGELOG 日期式发布标记：<pending or entry>
- Archive / state sync receipt: <pending or path>
```
