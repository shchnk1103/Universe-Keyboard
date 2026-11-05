# Assignment: WANXIANG-T9-001 — 万象九宫格

- **Policy version:** `1.0.0`
- **Task ID / Title:** WANXIANG-T9-001 — 万象九宫格
- **Assignment Authority:** Product Lead
- **Decision Source / Date:** 设计定稿 SHA-256 `65eca4dbd61fc4173b54ced5b25714071864451e3cc98aec7af3e9d478a0541b`；切片 0 R1 任务包 SHA-256 `b14b4998760654471e092d4454979c7110adbb13fc1bb3ebc47d307b58524492`；Human 授权回执 `~/.kos-work/Universe-Keyboard/WANXIANG-T9-001/reports/human-authorization-s0r1-issued.md`，2026-10-29。切片 2 PM 决定 `/Users/doubleshy0n/.kos-work/Universe-Keyboard/WANXIANG-T9-001/design-s2-decisions.md` SHA-256 `c961ac676b1e136372f6397cba7672f094c01da32330c42b19b32018431a0615`。切片 3 PM 决定 `/Users/doubleshy0n/.kos-work/Universe-Keyboard/WANXIANG-T9-001/design-s3-decisions.md` SHA-256 `19f93f3b6be51786070de9381da3307d3741cfa878d1b4559149410567520930`。切片 3 实施说明 `/Users/doubleshy0n/.kos-work/Universe-Keyboard/WANXIANG-T9-001/reports/s3-implementation-spec.md` SHA-256 `b5812fec5cacbc12bd2340095c4571d30838cc87057f93ab8e8bf66be552f127`。
- **Scope:** 切片 0 为写死点分类与隔离真实引擎观察。切片 1–2 在功能分支上做九键登记表、万象与雾凇同等的兼容改写、编译物检查与就绪标记，并在共享资源准备前作废两方案标记、启用发布后核对最终路由。切片 3a 让拼音栏、测试 marked 与候选栏拼音项只显示同一校验投影，并补隔离资源上的真实引擎断言矩阵。切片 3b 把当时的 main 合进功能分支，并写 ADR 0039、方案管理文档、CHANGELOG 与本 Assignment。切片 3c 与 Human 真机验收还没做。
- **Non-goals:** 不 push、PR、merge 或 Release。不做设计定稿 §F 的技术债。本文件不把托管 CI 或真机写成已通过。
- **Domain Owner:** RimeBridge Maintainer
- **Executor:** Executor
- **Environment Executor:** Executor，隔离模拟器与本地测试
- **Human Dependency:** 真机验收清单仍待 Human：装万象后选万象九键，短句、选路径、部分上屏、退格；拼音栏只显示拼音；看见表情候选；切回雾凇仍正常；卸载万象回到 26 键（设计 v2 第 73 行「Human 真机验收」；定稿第 55 行「同 v2」）。真实宿主 marked text 只在这一门。雾凇基线若再出现可见差异，交 Human，不在文档里自行接受。后续发布须另行授权。
- **Architecture Reviewer:** Architecture Reviewer
- **Quality Reviewer:** Quality Reviewer
- **Product Approver:** Human Product Owner acting as Product Lead
- **Required Inputs:** 冻结设计、切片 2 与切片 3 的 PM 决定、实施说明、任务包与授权回执。文档写作起点的功能分支 HEAD `1e532eca9d676b09bca1bdee04b7f7d7bc6bc32f`，合入的 main `d530f50449d8c115a7949fb9b3c39001039b5602`。固定资源：雾凇 `full.zip` SHA-256 `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac`；万象清单 SHA-256 `6649905a3427f08fd68c5db5421422b983f252d4909b75dd107292841c3362f7`（实施说明第 1 节）。
- **Entry Criteria:** 哈希、授权及基线核验，隔离工作树。
- **Exit Criteria:** 最终独立 Architecture 与 Quality 复核；Human 真机验收清单；托管 CI；功能分支整体完成后一次合并。这些门都还没过。本地矩阵与模拟器证据见切片执行报告，不能代替上述门（实施说明第 3 节）。
- **Stop Conditions:** 任务包所列停止条件，包括基线冲突、越界写入或写入被拒。
- **Handoff Target:** Product Lead，及后续独立 Architecture Reviewer / Quality Reviewer。
- **Lifecycle Status:** Active — 切片 3（文档完成，待最终复核与 Human 真机验收）。

## History

| 日期 | 任务包 | 提交 |
| --- | --- | --- |
| 2026-11-05 | `task-package-s4-engine-fix-r1a.md` | 见执行报告 |
- **Revalidation Trigger:** 冻结输入、产品合同、基线、授权或证据要求变更。
