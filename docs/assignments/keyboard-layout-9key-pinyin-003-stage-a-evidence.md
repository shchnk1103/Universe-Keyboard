# KEYBOARD-LAYOUT-9KEY-PINYIN-003 — Stage A 与定向实现证据

## Evidence Boundary

- 日期：2026-07-22 Asia/Shanghai
- 基线：`101b889`
- 工作分支：`codex/t9-atomic-path-snapshot`
- 架构决策：ADR 0022 Option A
- 本文仅证明 pinned fixture、结构调用预算和 KeyboardCore 状态合同；不证明 iPhone 13 Pro 延迟或 Product Gate。

## Stage A RimeBridge Spike

环境：

- iOS 27 Simulator `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- pinned fixture：`evidence/keyboard-layout-9key-spike/20260716-195542/runtime`
- 单次只读 `candidateWindow`，比较 limit `16/24/32/48`
- 通过只读 `currentOutput` 在窗口读取前后比较 raw、preedit、候选和高亮；验证过程不调用 `replaceInput` 修复 session
- 冻结形状：长输入 `dei` 后续、`qing/wei/fan/dao` 后续、`qiu -> le`

结果：

```text
T9_ATOMIC_PATH_STAGE_A caseCount=3 limit16=3 limit24=3 limit32=3 limit48=3
Executed 1 test, with 0 failures
```

定向命令：

```bash
env \
  TEST_RUNNER_UK_RIME_T9_SPIKE_SHARED_DIR='.../runtime/shared' \
  TEST_RUNNER_UK_RIME_T9_SPIKE_USER_DIR='.../runtime/user' \
  xcodebuild test \
  -project 'Universe Keyboard.xcodeproj' \
  -scheme RimeBridgeTests \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474' \
  -derivedDataPath /private/tmp/universe-keyboard-t9-003-final-readonly \
  -only-testing:RimeBridgeTests/RimeT9PinyinSelectionSpikeTests/testAtomicPathDiscoveryStageAOnPinnedLibrime \
  CODE_SIGNING_ALLOWED=NO
```

最终代码状态结果包：`~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-22T11-09-47-272Z_pid78811_44d9df99.xcresult`

生产采用固定 limit `48`：真实冻结形状在 `16` 已覆盖，但既有确定性单测将一个必要低排名分支放在 global index 16；固定 `48` 保留该合同，同时删除所有按拼写循环的 session mutation。

## KeyboardCore Targeted Evidence

已验证的合同：

- 直接 Path advance：增量 `replaceInput <= 1`、`candidateWindow <= 1`。
- `qing -> wei -> fan -> dao -> 请喂饭到`：候选选择后 composition revision 前进，Path revision 与之相同，旧 focus 消失，新 Path 含 `wo`。
- `qiu -> 球 -> Delete -> Delete`：既有恢复和 `qiule -> qiul` 语义保持；`markedTextHistory` 每次写入均无内部数字。
- host writer：拒绝 `64`、`748 53`、`qiu5` 等内部投影；允许候选确认前缀中的合法数字及显式 number suffix。
- runtime fail-close：Return/符号不提交遗留 T9 raw。
- candidate page、rollback success/fail-close 均推进 composition revision；展开 Path 同时校验 composition 与 provenance revision。

最终定向矩阵执行 `17` 条 KeyboardCore 测试，`0` failure；未运行全量测试，符合 Product Decision 的 bounded-test 授权。

定向命令：

```bash
swift test --package-path Packages/KeyboardCore \
  --filter '(T9HostPreeditSafetyTests|T9PinyinPathTests/(testLongInputAdvance|testDirectPathAdvance|testFinalSyllablePathTap|testCandidatePageChangeAdvancesCompositionRevision|testUnexpectedCommitAndRollbackFailureFailClosed)|PartialCommitControllerTests/(testQingWeiFanDaoCandidateSelectionPublishesWoPathsFromNewRemainder|testQingCandidateWithRetainedFullAnchoredRawStillPublishesWoPaths|testT9PartialCommitSelectingQiuPreservesConfirmedPrefixWhenRimeReranks|testWholeUnresolvedTailDoesNotRestoreStaleConfirmedPathSnapshot)|RimeControllerInputTests/testNumbersPageDigitsContinueChineseComposition)'
```

主 App 与键盘扩展已在 iOS 27 Simulator 定向编译成功；该结果只证明工程集成和 Swift/ObjC 边界可编译，不替代真机体验验收。

## Independent Quality

独立 Quality 最终判定为 **Automated Pass**：复核了只读 session snapshot、Path 固定调用预算、composition/provenance 双版本保护、数字安全边界和上述定向测试结果。该结论只关闭自动化 Quality Gate，不关闭 Human Product Gate。

## Remaining Human Gate

需要 Human Product Owner 在 iPhone 13 Pro、备忘录、当前签名构建上验证：

1. `deizhaoyishengwenyixia -> dei` 的可感知延迟；
2. 完整 `qing/wei/fan/dao -> 请喂饭到` 后 Path 立即显示 `wo` 分支；
3. `toutoumaiqiule -> 偷偷买 -> qiu -> 球 -> Delete`；
4. 快速输入、Delete、收起/重开及 recovery 期间无瞬时内部数字；
5. 数字页显式输入仍正常。

Simulator 和单元测试不能关闭该 Product Gate。

## 2026-07-22 Physical Product Gate Result

- **Pass:** `deizhaoyishengwenyixia` 的 Path 点击不再有此前的可感知卡顿。
- **Fail — choice completeness:** 逐段到第三焦点时 Path 只显示 `yi`，用户无法进入同数字槽位的 `zi` 分支。
- **Fail — Delete recovery:** `toutoumaiqiule → 偷偷买 → qiu → 球 → Delete → Delete` 后 Path Bar 偶发消失，而候选仍保持活跃。

后续只读真实 RIME 诊断将 `dei'zhao'<remaining digits>` 的单窗口从 `48` 扩到 `768`，结果始终为：

```text
limit48=yi:true,zi:false
limit96=yi:true,zi:false
limit192=yi:true,zi:false
limit384=yi:true,zi:false
limit768=yi:true,zi:false
```

因此扩大窗口不能形成完整性保证。Architecture 推荐“live 完整音节 + 未覆盖物理键 focused-prefix escape branch”；该方案改变多键 choice source，必须先由 Product Lead 形成 dated amendment，不能由执行角色自行采用。
