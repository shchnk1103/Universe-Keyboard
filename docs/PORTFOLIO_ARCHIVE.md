# PORTFOLIO 归档（已完成与已关闭项）

本文件是 `docs/PORTFOLIO.md` 的归档表，按 O84 活死分离（PORTFOLIO-ARCHIVE-001，2026-11-23）从主表迁出。
规则：只迁入不删除——本文件行与主表迁出前逐字一致（含证据指针）；不回收 `PF-*`/`PB-*` 编号；新的完成项由后续同步包追加到本文件文末。
主表只保留未完成活动项，见 [PORTFOLIO.md](PORTFOLIO.md)。

## 已完成

| ID | 任务 | 完成依据 |
|---|---|---|
| PF-010 | Next TestFlight Release Gate（Done：职能承接） | 职能由 PF-031 承接（范围已定，TD 分类见发布准备 Assignment S2–S4，独有门禁并入 S7）；**不表示门禁通过**；原详情页仍为 [portfolio/testflight-gates.md](portfolio/testflight-gates.md)；[发布准备 Assignment](assignments/release-2026-10-external-testflight-001.md)；Human 2026-10-25 决定，核对 2026-10-25 |
| PF-020 | 任务组合目录（种子） | PR #226（`b62bde1`），`docs/assignments/portfolio-directory-001.md` |
| PF-021 | 键盘数值文档 | PR #227（`477c042`），`docs/assignments/keyboard-values-doc-001.md` |
| PF-002 | UI-1 合并后状态同步 | PR #221（`9f7a88a`）；UI-2 的合并后同步与 PR #222（`7953e8b`，过期事实同步）各自的范围未在本目录核实，UNKNOWN |
| UK-007 | KOS Task Workspace 采纳（UK-007） | `docs/assignments/kos-upgrade-uk-007-task-workspace.md` Closed；PR #211 `834c6af3`；产品决定 2026-10-18 Accepted，opt-in，不含自动跨平台接管。KTW 试点仍是未完成表的 PF-015（UNKNOWN） |
| UI4-SPIKE-001 | UI-4 Technical Spike（限定结论已被Human接受，Close合并时生效） | [Spike Assignment](assignments/ui4-spike-001.md)；核对 2026-10-23；不代表UI-4产品开发完成 |
| PF-012 | UI-3：候选字体大小（Done） | [PR #236](https://github.com/shchnk1103/Universe-Keyboard/pull/236)，合并提交 `b8f6b6516064c4721c884a53e1437e01d83449e7`；[Assignment](assignments/ui3-font-001.md)；Human 2026-10-25 决定 Close，Close 在本 PR 合并时生效；Human 真机观察（不是测量）仅覆盖 `b0e0361`（iPhone 13 Pro、iOS 27.0.1）；完全访问关/开表现无区别；Debug/Release UNKNOWN；之后的预览提交 `eae739e`、`0db9b27` 与测试/文档提交 `16bab5c`、`f489968` 未经真机验收；不是 TestFlight / Release 许可；核对 2026-10-25 |
| PF-013 | UI-4：自定义键盘高度（Done） | [PR #234](https://github.com/shchnk1103/Universe-Keyboard/pull/234)，合并提交 `ebf7e4fa51967b58be80c2cef00f7c3e9fdd8e17`；[Assignment](assignments/ui4-height-001.md)；Human 2026-10-25 决定 Close，Close 在本 PR 合并时生效；Human 观察不是测量；已知限制见 Assignment Exit evidence；已知限制与后续 PF-032、PF-033、PF-031 不随 Done 消失；不是 TestFlight / Release 许可；核对 2026-10-25 |
| PF-009 | Real RIME T9 Batch A（Done：职能由 PF-006 承接，S7 遗留） | Human 2026-10-25 第 4 题答 A；**不表示 real RIME T9 残项已解决**；见 PF-006 |
| PF-014 | KW002：Workspace Cleanup（Done：并入 PF-023） | Human 2026-10-25 第 1 题答 A；职能由 PF-023 承接，不表示清理已执行 |
| PF-017 | Branch Retention & Handoff Lifecycle（Done：并入 PF-023） | Human 2026-10-25 第 1 题答 A；职能由 PF-023 承接 |
| PF-031 | 外部 TestFlight 发布准备（Done：Human 2026-10-25 决定把 Build 167 发给外部测试组；Human 口述已在 App Store Connect 提交，后台状态未核对） | 发布决定（外置 PF031-EVIDENCE-REVIEW-001/reports/human-release-decision-2026-10-25.md）；Human 2026-10-25 第 7 题答 A；发布准备 [Assignment](assignments/release-2026-10-external-testflight-001.md) 的 Lifecycle 仍以该 Assignment 为准，Close 另行决定；遗留证据见 PF-041 |
| DIAG-TYPED-LIFECYCLE-GATE-001 | 新日志写入按进程生命周期加闸门 | [PR #254](https://github.com/shchnk1103/Universe-Keyboard/pull/254)，合并提交 `abd3c85a1ca731e35300c222d8a6a813f31a78b4`；[Assignment](assignments/diag-typed-lifecycle-gate-001.md) |
| PF-044 | 万象方案的九宫格与 emoji | 随 [PR #270](https://github.com/shchnk1103/Universe-Keyboard/pull/270)（合并提交 `9c988dcd398b59894655531fc3446178c41950d5`）合并，Human 2026-11-06 决定关闭，验收边界与后续项见 [Assignment](assignments/wanxiang-t9-001.md) 与 PF-065 至 PF-067；核对 2026-11-06 |
| PF-057 | 主 App 被系统以 0xDEAD10CC 终止（上线前缓解） | 随 PR #270 合并的上线前缓解，Human 2026-11-06 决定关闭，残余见 PF-064 与 [Assignment](assignments/launch-stability-001.md)；核对 2026-11-06 |
| PF-060 | 26 键双手快速交替时第二个键不触发（上线前只修缝隙） | 随 PR #270 合并的缝隙修复，Human 2026-11-06 决定关闭，后续见 PF-061 至 PF-063 与 [Assignment](assignments/launch-stability-001.md)；核对 2026-11-06 |
| PF-036 | 发布自动化：Xcode Cloud 构建并上传到 TestFlight | Human 2026-11-06 陈述 tag `testflight/1.0-20261106` 触发的 Xcode Cloud 构建 201 已自动进入 TestFlight 内部组并决定关闭，PM 对下载件的核对见外置 RELEASE-20261105/build201/pm-check-build201.md；核对 2026-11-06；2026-11-14：Human 口述已把 Xcode Cloud 拆成 testflight/* 与 appstore/* 两个流程，细则见 [Release Checklist](RELEASE_CHECKLIST.md)；build 203（1.0）经 appstore 流程构建并由 Human 于 2026-11-14 13:06 提交 App Store 审核（Human 截图，审核状态 Waiting for Review）。 |
| SWITCH-RESOLVER-001 | 方案开关按名称与含义识别 | 随 [PR #264](https://github.com/shchnk1103/Universe-Keyboard/pull/264) 合并，Human 2026-11-06 在 Build 201 真机三项验收通过后决定关闭，边界见 [Assignment](assignments/switch-resolver-001.md)；核对 2026-11-06 |
| PF-035 | KOS 优化：ACTIVE_WORK 去留（Done：冻结为历史快照，入口改指本目录） | Human 2026-11-07“按推荐改”；本文件决定记录 2026-11-07 |
| PR #276 | 键盘：候选栏空闲时的粘贴按钮 | [PR #276](https://github.com/shchnk1103/Universe-Keyboard/pull/276)（合并提交 `6f417986820594ef804aaec14e709c31b0ad624a`）合并；核对 2026-11-09 |
| PR #277 | 冻结 ACTIVE_WORK，入口文档改指任务组合 | [PR #277](https://github.com/shchnk1103/Universe-Keyboard/pull/277)（合并提交 `81e181502f580300fa6152411641be636ef13146`）合并；核对 2026-11-09 |
| PR #278 | 把 PM 试行规则与角色名册写入 KOS 文档 | [PR #278](https://github.com/shchnk1103/Universe-Keyboard/pull/278)（合并提交 `6860a43a2eaf255e9621776e2595de2d4bfd08b6`）合并；核对 2026-11-09 |
| PR #279 | 九键朙月方案补丁链接入 luna_pinyin_t9.custom | [PR #279](https://github.com/shchnk1103/Universe-Keyboard/pull/279)（合并提交 `38c3930d8ac54a09ca038f07faca4e681fd6c6c1`）合并；核对 2026-11-09 |
| PR #280 | PM 手册补入 LUNA 教训 | [PR #280](https://github.com/shchnk1103/Universe-Keyboard/pull/280)（合并提交 `b9ef8d413c71849b7b734ddd70bc034eb0dde589`）合并；核对 2026-11-09 |
| PR #281 | 新增朙月九宫格知识卡 | [PR #281](https://github.com/shchnk1103/Universe-Keyboard/pull/281)（合并提交 `29f77658f0a6faa05ad3877244899d44014aa0e9`）合并；核对 2026-11-09 |
| PF-022 | 键盘数值核对脚本（Done） | [PR #346](https://github.com/shchnk1103/Universe-Keyboard/pull/346)（合并提交 `fcff70744820f379f72fc00902f4839ea855f1b6`）已合入 `main`；`check_keyboard_values.py` 接入 `scripts/ci/run_lightweight_checks.sh`，`docs/KEYBOARD_VALUES.md` 与代码常量的漂移在轻量 CI 里暴露；核对 2026-11-20；`docs/assignments/keyboard-values-doc-001.md` 为当初登记 Assignment |
| PF-054 | 九宫格上屏后文字重复一遍（Done：1.0.2 真机验证通过） | 历史全程保留：2026-10-27 Human 观察复现；2026-10-28 B34-COMMIT-TRACE-001（PR #256 `e5303933…`）打点 `candidate.commit_trace`；2026-11-20 PF054-DIAG-001（PR #341，合并提交 `86a40a14`）真机日志确认 `partial_commit.overlap`，重叠去重修复 PF054-FIX-001（PR #343，合并提交 `17be7e2f`）并入 `main`；2026-11-22/23 真机复测选候选上屏无重复，「画面」「通用」日志证实 `partial_commit_overlap_len=2` 去重生效，随 1.0.2 收口（Build 206 送审）关闭 | [PR #341](https://github.com/shchnk1103/Universe-Keyboard/pull/341)、[PR #343](https://github.com/shchnk1103/Universe-Keyboard/pull/343)；[v1.0.2.md](releases/v1.0.2.md)；核对 2026-11-23 |
| PF-070 | 九宫格拼音循环与删除诊断日志（T9-PINYIN-CYCLE-009，Done：1.0.2 引擎日志真机通过） | 历史保留：S1 本地实现 v7 与 `t9.cycle_result`/`t9.delete_path` 两类事件；事件随 PR #323 并入 `main`；2026-11-22/23 真机复现 m/n 操作路径，「引擎」日志证实 `t9.cycle_result` 落盘且循环选中目标候选，随 1.0.2 收口（Build 206 送审）关闭；隐私口径与 1.0.1 诊断日志一致（仅事件类别与计数） | [Assignment](assignments/t9-pinyin-cycle-009.md)；[v1.0.2.md](releases/v1.0.2.md)；核对 2026-11-23 |
| PF-056 | KOS：授权消息保持极短，批准项写进任务包「Human 预批准项」（B35，Done：约定已落地） | 历史保留：Human 2026-10-27 指出授权消息过长；其后 KOS 任务包模板落地「Human 预批准项（随本包 SHA 冻结）」固定节（PR #316 一带的任务包规范沿用至今，2026-11-22/23 的 KOS-BOARD-RESERVE-001、REL-102 系列包均为该格式） | PM 记录 B35（外置，不入库）；核对 2026-11-23 |
| PB-002 | 中文 26 键 Caps Lock 直出大写（Done：1.0.2 真机通过） | PR #367 `5a84cbc2`（直出大写）与 PR #370 `8eab437c`（直出上屏时重置 RIME session）已并入 `main`；2026-11-22/23 真机四步验证通过，随 1.0.2 收口（Build 206 送审）关闭 | 外置 `PRODUCT-BUGS-INBOX.md` PB-002（外置不入库）；[v1.0.2.md](releases/v1.0.2.md)；核对 2026-11-23 |
| PB-005 | 九宫格回车上屏可见拼音（Done：1.0.2 真机通过） | PR #369 `df95dc9a` 已并入 `main`，九宫格与 26 键回车语义统一（有未提交拼音时回车上屏拼音）；2026-11-22/23 真机三步验证通过，随 1.0.2 收口（Build 206 送审）关闭 | 外置 `PRODUCT-BUGS-INBOX.md` PB-005（外置不入库）；[v1.0.2.md](releases/v1.0.2.md)；核对 2026-11-23 |

## 明确已关闭 / 被替代（本次归档时主表「未完成」表内无此类独立行）

本次归档盘点：主表「未完成」表各行均为活动项（Backlog/In progress/Waiting Human/UNKNOWN），没有状态列已写明「已关闭」或「被替代」的独立行需要迁出。历史上「Done：职能由 XX 承接」类行（如 PF-009/PF-014/PF-017）已在此前各轮同步时移入上方「已完成」表，本次原样保留。
