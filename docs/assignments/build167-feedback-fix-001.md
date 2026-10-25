# Assignment: BUILD167-FEEDBACK-FIX-001 — Build 167 反馈缺陷：D1 九宫格 Path 消费规则修改与实现；D2/D3 自定义行高真机诊断与修复

Policy version: 1.0.0
record_id: BUILD167-FEEDBACK-FIX-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Assigned |
| Current phase | 登记；S1–S3 尚未开工，每阶段另需 Human 任务包授权 |
| Material non-claims | 本记录不是任何阶段的开工授权，也不是 Product Gate；未取得本任务实现、真机诊断或独立评审结论 |
| Next handoff / decision | 本记录合并进 main 后，由 Human 授权阶段任务包；S1 先交 Architecture 设计与评审 |

## Authority

- **Task ID / Title:** BUILD167-FEEDBACK-FIX-001 — Build 167 反馈缺陷：D1 九宫格 Path 消费规则修改与实现；D2/D3 自定义行高真机诊断与修复。
- **Assignment Authority:** Product Lead。
- **Decision Source / Date:** Human Product Owner 2026-10-25（Asia/Shanghai，对话）；D1-1 = A、D1-2 = A，决定与观察如下；由 [BUILD167-FEEDBACK-FIX-LANDING-001](build167-feedback-fix-landing-001.md) 登记，冻结任务包及授权原文仅外置。
- **Product Approver:** Human Product Owner。

## Human 的决定与观察

以下决定与观察来自 Human 2026-10-25 对话；观察不是测量，不扩写为原因或能力结论。

- **D1-1：** Human 选 A，原话“改成 A 吧，我认为这样更直观”。A 的含义（PM 提问原文）：改规则，**候选覆盖了几个音节就消费几个**（即 Human 预期的“只剩 o”）；需要另外安排修改代码和回归。
- **D1-2：** Human 选 A。PM 提问：`toutoumaiqiule` → 选「偷偷买」→ 在拼音栏点 `qiu` 时，输入框应显示什么。A 的含义是显示「偷偷买qiule」（当前实际表现，对应检查表第 484 行）。
- **D2 真机观察（Human 本人，iPhone 13 Pro，构建未说明）：** “默认高度拼音栏是让整个键盘变高”。
- **D3 新缺陷（Human 本人观察，同一台手机；不是测量）：** “我只能调低，调高的话在我通过滑杆调到一个比较大的数值之后键盘没有变化，我点确定也没变化。”
- **相关历史（只引用，不改）：** [UI-4 portfolio](../portfolio/ui-4-keyboard-height.md) 第 16 行与第 88 行记有 Human 早先接受“在宿主限制高度的场景里调高可能没有效果”。UI-4 的 P4 真机清单没有专门检查“调高后键盘变高”这一项，外置 `~/.kos-work/Universe-Keyboard/UI4-HEIGHT-001/reports/p4-human-device-result.md`；只记录事实，不判断。

## Boundary

- **Scope:** 分为以下三阶段，每阶段另需 Human 任务包授权。
  - **S1 = D1：** 修订 [residual-B 产品合同](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md) 规则 1，以及 [KEYBOARD_LAYOUT](../KEYBOARD_LAYOUT.md) 与 [partial-commit](../architecture/partial-commit.md) 的对应描述。新规则：候选覆盖的音节数多于剩余用户 Path 栈时，按候选实际覆盖的音节消费；用户栈内的部分仍跟用户选择。具体语义与边界由 Architecture 先设计并评审。把 [RELEASE_CHECKLIST](../RELEASE_CHECKLIST.md) 第 478 行改为与第 484 行一致（D1-2 = A）。实现与回归覆盖 D1 序列、无 Path 对照、`toutoumaiqiule` 序列及既有 residual-B 用例。不放宽任何既有断言或超时；凡因规则改变必须修改的既有断言，逐条列出并由 Architecture 批准。
  - **S2 = D2/D3 真机诊断：** 在 Human 的 iPhone 13 Pro 上用内容无关的诊断，确认两件事：(i) 调节页调高时，请求高度、宿主实际高度、accepted 高度与有效行高；(ii) 保存较大行高后，九宫格 Path 出现时同样的四个量。设备操作由 Human 执行。必要时可加只在 Debug 或诊断构建生效的高度诊断记录，不进入 Release。不读取输入内容，不复述设备名中的人名。
  - **S3 = D2/D3 修复：** 依据 S2 结论另行设计；若需修改 UI-4 合同，先请 Human 决定。
- **Non-goals:** 打开 R174；修改 S1–S3 以外的输入或布局行为；放宽超时（TD-020）；TestFlight / App Store Connect 动作；push / PR / merge 各自另行授权。本记录不是任何阶段的开工授权，也不是 Product Gate。
- **Required Inputs:** [诊断 Assignment](build167-feedback-defects-001.md)；上述 residual-B、KEYBOARD_LAYOUT、partial-commit、RELEASE_CHECKLIST；[UI4 产品合同](../product-decisions/UI4-KEYBOARD-HEIGHT-001-product-contract.md)；[KEYBOARD_VALUES](../KEYBOARD_VALUES.md)；[PERFORMANCE_BASELINE](../PERFORMANCE_BASELINE.md)（真机打字由 Human 执行的规则）；外置诊断证据如下，摘要须复核：
  - `~/.kos-work/Universe-Keyboard/BUILD167-FEEDBACK-DIAG-001/instructions/task-package.md`，SHA-256 `1b176ccb4fb53bf09765b06597151592c983cbbacd31987f9e9e9b0fe3e0bee0`。
  - `~/.kos-work/Universe-Keyboard/BUILD167-FEEDBACK-DIAG-001/reports/s1-d1-report.md`，SHA-256 `1cb7a0b0c7ea6f2c44c860851a8905b54b7fbd1b25435eb87e7dd2dffd039f87`；结论（a）：代码照 residual-B 合同执行，用户栈 `[jiu]` 时 K=1、只消费三位；检查表 478/484 冲突（c），夹具实际符合 484。这是模拟器证据，不是真机证据。
  - `~/.kos-work/Universe-Keyboard/BUILD167-FEEDBACK-DIAG-001/reports/s2-d2-report.md`，SHA-256 `68c105ca0e9dd656963a5c8b5cfd4c4308b1df6cbe557c463c59ca546ea4afc5`；合成宿主允许增高时，50/60 行高保持；人为固定宿主高度时 50→41、60→51；真实宿主是否拒绝增高未复现（d）。合成观测不是测试者真机证据。
  - 实验本地提交 `01fe451d4bb9510ba4d369ed6054c3f8816b2a6f`，分支 `experiment/build167-feedback-diag-001`，未推送；不并入本记录的改动。

## Assignment

- **Domain Owner:** Keyboard Experience Maintainer（与诊断 Assignment 相同）；D1 合同及输入状态语义涉及 Input Intelligence Maintainer 的 KeyboardCore、候选语义与 Partial Commit 职责，按 [VIRTUAL_ENGINEERING_TEAM](../VIRTUAL_ENGINEERING_TEAM.md) 现有分工协作，不转移永久所有权。
- **Executor:** Codex。
- **Environment Executor:** Codex（Xcode、模拟器、`devicectl`）；设备上的手动操作由 Human 完成。
- **Human Dependency:** Human Product Owner——各阶段授权；S2 设备操作（Human 2026-10-30 至 11-02 外出，S2 宜在此前完成）；S1 合同修订文本批准；S3 方案选择。
- **Architecture Reviewer:** 独立 Architecture Reviewer（S1 必需；S3 视改动而定），非 Executor 会话。
- **Quality Reviewer:** 独立 Quality Reviewer（每阶段），非 Executor 或 Architecture 同一会话。

## Human 确认状态

D1-1 = A、D1-2 = A（2026-10-25 已定）；S1 合同文本、S2 时间与授权、S3 方案：**待 Human**。

## Gates

- **Entry Criteria:** 本记录合并进 main，并且每阶段有 Human 的任务包授权。S3 还需要 S2 报告与 Human 的方案选择。
- **Exit Criteria:** 每阶段有外置报告与独立评审结论。S1 的合同修订、实现与测试经 PR 合并；S2 给出 D2/D3 成因分类；S3 的修复合并或由 Human 决定不修。最后由 Human 决定 Close。
- **Stop Conditions:** 需要放宽断言或超时；需要打开 R174；需要 Apple 账号、签名设置或 provisioning 变更；设备不可用；合同修订未获批准就要实现。

## Handoff

- **Handoff Target:** Coordinator → Codex（S1 设计、实现；S2 诊断构建与读数）→ Architecture / Quality Reviewer → Human Product Owner。
- **Required Handoff Content:** 当前阶段授权、合同修订与 Architecture 结论、D1 实现及回归证据；S2 内容无关的四项高度读数与成因分类；S3 方案、Human 选择与修复证据；独立评审、偏差及未验证范围。
- **Revalidation Trigger:** main 上相关代码变化；Human 改变 D1-1、D1-2 的决定；设备或系统版本变化。

## Reports

| 项 | Result |
|---|---|
| S1 外置报告 | （执行时填） |
| S2 外置报告 | （执行时填） |
| S3 外置报告 | （执行时填） |

## Exit evidence

| 项 | Result |
|---|---|
| S1 合同修订、Architecture 评审、实现与回归合并 | （执行时填） |
| S1 独立 Quality 结论 | （执行时填） |
| S2 D2/D3 成因分类及独立评审结论 | （执行时填） |
| S3 修复合并或 Human 不修决定及独立评审结论 | （执行时填） |

## Closeout Decision

由 Human 决定。

## Lifecycle Status

Assigned
