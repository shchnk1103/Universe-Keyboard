# Assignment: UI4-SPIKE-001 — UI-4 高度 Technical Spike（补录）

Policy version: 1.0.0
record_id: UI4-SPIKE-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed — effective on merge of the PR that carries this record |
| Current phase | 报告组已被Human接受（2026-10-23）；本记录合并前Close尚未生效 |
| Material non-claims | 不实现UI-4/UI-3；不合并实验代码；未测项仍UNKNOWN；非产品、设备运行时、Release或TestFlight许可 |
| Next handoff / decision | 本次Closeout独立评审后由Human决定发布；之后另起UI-4 Product Decision与Assignment |
| Residuals | 见下“评审条件处置”；全部实验缺口保留于结果摘要 |

---

## Authority

- **Assignment Authority:** Product Lead。
- **Decision Source / Date:** Human Product Owner，2026-10-22 Asia/Shanghai，Coordinator会话中的A–E Spike批准；2026-10-23接受报告声明范围内结论，接受记录及摘要见[结果摘要](../evidence/ui4-spike-001-summary.md)。外置原Assignment含增补1、2，完整路径与SHA-256均见摘要清单。
- **Product Approver:** Human Product Owner（Product Lead）。
- **记录责任:** 本文由UI4-SPIKE-001-CLOSEOUT-001 Executor补录；不回写外置原Assignment的历史状态，不替换其原始合同。

## 原授权范围与输入

- **Scope:** A高度实测（原计划iPhone 13 Pro及更小/更大模拟器、横竖屏、至少两宿主、多页面与行高）；B真机完全访问开/关共享及自有存储观察；C调节中禁止输入与三种触发方式评估；D键盘内/主App预览/混合方式及请求时机比较；E测量、风险、UNKNOWN和产品决定输入报告。实验只留一次性分支。
- **Non-goals:** UI-4/UI-3正式实现、正式设置页、持久化格式/迁移设计、修改入库冻结文档/测试、合并实验代码或开代码PR、起草Product Decision、Release/TestFlight。
- **Required Inputs:** 原Assignment；[数值索引](../KEYBOARD_VALUES.md)、[UI-4详情](../portfolio/ui-4-keyboard-height.md)、[UI冻结](../UI_STYLE_GUIDE.md)、[布局](../KEYBOARD_LAYOUT.md)、[项目上下文](../PROJECT_CONTEXT.md)、[技术债](../TECH_DEBT.md) TD-004/TD-020；Human参考截图；模拟器运行时、Human的iPhone 13 Pro/iOS27.0.1与Xcode。这些是原授权输入；本次补录不声称所有原计划实验已执行。
- **基线与载体:** 原起草基线477c042，原要求派发时核验origin/main；实验在外置`UI4-SPIKE-001/worktree`、分支`spike/ui4-height-001`。阶段提交/安装身份按摘要分层，不把最终磁盘HEAD当作设备安装证明。
- **产出偏差:** 原要求报告入库草稿`docs/evidence/ui4-spike-001-report.md`；实际报告留在外置reports。Human本次明确采用“入库摘要加外置清单”，仓库载体改为[结果摘要](../evidence/ui4-spike-001-summary.md)，原件不拷入。

## Assignment 责任与Human确认

| 必填字段 | 原指派及实际执行记录 |
|---|---|
| Domain Owner | Keyboard UI（Architecture and Knowledge Steward协同） |
| Executor | Executor角色（AI不限）；原建议claude-sonnet-5-5/medium不是实际身份。实际含Codex与Grok Build多个会话/厂商，见下；精确模型与effort未确认是身份残项，不代填 |
| Environment Executor | 模拟器：Executor可脚本化部分、Human Product Owner手工点按（增补2）；真机：Human Product Owner，已于2026-10-22确认 |
| Human Dependency | Human Product Owner：签名安装、清单操作/记录、接受结论、决定后续Product Decision |
| Architecture Reviewer | 独立会话，lane U4S-ARCH；实际Codex新会话，R1/R2沿用同一lane会话；非实现者且非Quality会话 |
| Quality Reviewer | 独立会话，lane U4S-QUAL；实际另一个Codex新会话，R1–R3；非实现者且非Architecture会话 |
| Product Approver | Human Product Owner（Product Lead） |

Human于2026-10-22确认A–E范围、自己用Xcode装真机、实验替换现有安装且保留App Group数据、清单预计30–45分钟、自己处理签名及Environment Executor分工。增补2再确认模拟器点按交Human。时间是原计划，不是实测耗时。
本次派发于2026-10-23确认：Closeout的Environment Executor为`Not Applicable — repository documentation only`，且证据只入库摘要加外置清单；这不改写原Spike的环境责任。

## 执行经过与原文差异

1. 初轮Codex预检因缺12个Vendor框架停止。增补1由Human仅授权该worktree一次`ensure_rime_vendor.sh fetch`，固定制品版本`rime-vendor-ios-1.16.1-lua.1-octagram.1`、SHA-256 `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`，不借用main产物。环境恢复不等于实验通过。
2. 接手Grok Build会话的模拟器GUI自动化反复误操作；增补2停止其GUI自动操作，改为Human手点，Executor继续构建/安装/启动/日志/文件、simctl截图及整理。不能仍记“模拟器全部由Executor”。
3. r11/r13/最终报告由Grok Build会话`01a163d4-f039-7c13-9186-0a2a237192dc`记录；r15/r16及补充由参与实现的Codex会话`01a16739-c30d-7002-ad62-44cdb99814d6`记录。早期Codex阶段存在，不能将全程归于单一Executor会话。报告身份仅按各原件自述，不猜具体部署模型/effort。
4. 实际只有一种模拟器屏幕与一台真机，模拟器九键未测；真机共享仅照片，F三组覆盖不齐；原计划全部A–E与测量矩阵未完整实现。原Exit文字保留为计划，不声称全部达到；Human接受的是报告范围与缺口，不是把未测补为Pass。
5. 旧入口推荐、共享存储未决及早期安装说明按最终报告+补充1/2/3的时间顺序读取；Human的后续产品方向单列于摘要，不属于Spike发现。实验代码不由本次带入仓库。

## Gates 与移交

| 必填字段 | 合同与状态 |
|---|---|
| Entry Criteria | Human上述确认与派发；原指定隔离worktree/一次性分支。外置原件保留当时状态 |
| Exit Criteria | 原要求A–E、测量/真机表、报告/证据保存、实验分支保留未合并、Reviewer评审及Human接受。实际覆盖与差异见上；按2026-10-23有界接受及D7收尾，不宣称原实验目标全部完成 |
| Stop Conditions | 需要合并产品实验代码、改测试、真机签名/安装失败、数值与索引不符、push main或开代码PR即停；本次Closeout另受自身Assignment停止条件约束 |
| Handoff Target | Human Product Owner；后续UI-4 Product Decision另行起草，不自动授权实施 |
| Revalidation Trigger | 基线明显漂移、设备/系统/范围变化；外置来源字节或责任变化须重新核对 |

## 评审条件处置与接受

| 残项 | Owner | Disposition | 依据与限制 |
|---|---|---|---|
| U4S-ARCH-F01/F02/F03 | 报告Executor；Architecture Reviewer复核 | fix | 补充2补齐输入、更正点击范围/静态预览/成本措辞，Architecture R2复核关闭 |
| U4S-Q-F01 | Executor/Coordinator | fix | 补充2更正旧索引，Quality R3核验为已解释的历史问题；R1 Partial保留 |
| U4S-Q3-F01/U4S-Q3-N01 | Executor/Coordinator；Human Product Owner接受范围 | fix | 补充3拆分81/117及限制旧竖屏图用途；未经独立复核。Human接受记录披露Coordinator机械核对与亲看两图，不升格Quality结论 |
| 身份精度、过程计时/allowlist与实验未测边界 | Human Product Owner | accept | 2026-10-23在报告声明范围内接受；保留各原报告过程披露及摘要UNKNOWN，不消除未测项 |

Architecture R1 Pass with conditions → R2 Pass；Quality R1/R2 Partial（Coordinator包设计导致停止）→ R3 Pass with conditions。路径、各轮SHA-256、条件与独立性边界见[结果摘要](../evidence/ui4-spike-001-summary.md)；这里不授予本Closeout的独立评审结论。

## Closeout Decision — 结果

依据Human Product Owner于2026-10-23接受UI4-SPIKE-001报告声明范围内的结论、原Assignment的D7收尾规则及[Closeout Assignment](ui4-spike-001-closeout-001.md)，本记录写`Closed — effective on merge of the PR that carries this record`。合并前不声称Close已生效；本Closeout仍待独立评审与Human发布决定。
稳定触发身份：`UI4-SPIKE-001 / Human acceptance 2026-10-23 / reports/human-acceptance-2026-10-23.md`（摘要见清单）。本次是该触发的结果入库/同步事务，其行政完成不递归触发另一轮M-02；未来独立Product Gate/实现或新生命周期决定另计。

## Exit evidence

- [结果摘要与外置清单](../evidence/ui4-spike-001-summary.md)：原Assignment、最终报告及三补充、五轮评审、Human接受、日志/表/清单的路径与SHA-256。
- [UI-4详情](../portfolio/ui-4-keyboard-height.md)保留既有Human决定并记录新方向；[Portfolio](../PORTFOLIO.md)仅同步PF-013及指定追加区域。
- 本次文档核对、验证和本地提交由[Closeout Assignment](ui4-spike-001-closeout-001.md)承载。push/PR/merge均未执行，UI-4 Product Decision与开发Assignment尚未起草。
