# QUALITY-C5-R-ACCEPT 独立只读验收（round 1）

**本轮审查覆盖：Complete（R1–R4均已核查）；运行证据验收：Hold。** 这是限于候选、安装配对、一次窗口和同一 Main App 的判断，不是整体 Quality/Gate/Release、根因或 Maps 结论。

| 项 | 覆盖与证据判断 |
|---|---|
| R1 身份/来源 | Covered。packet、manifest、Entry 摘要匹配；HEAD `84b9c192…`、分支与candidate/run相符。30/30 repo inputs、3/3脚本文本、568/568 source-build、111/111 Debug bundle 哈希一致。存档显示安装前后111文件匹配、11 Mach-O核验。脚本只读，未执行；未访问当前设备/安装路径。 |
| R2 typed markers | Covered。独立重算17个窗口事件：单一keyboard_extension/process/appearance；localSequence与monotonic严格递增；will/didAppear各1、resume `started` 1；6组 `set_marked_text` 和1组 `unmark_text` entered/returned成对有序。有限payload由枚举/validator约束。`actionSequence`均为空，不能构造transaction；`started`不代表RIME ready，`returned`不代表宿主接受。没有 `insert_text` 或 tail 消失证据，均未观察，不计通过。 |
| R3 Main App reader | 已完成判据评估；不足以满足“本窗口v6事件均由同配对reader正确消费”的完整条件。Human存档确认同一已安装Main App在该时段三类可见、无incomplete/unsupported提示；源码把reader completeness/paging notice呈现在页面，构成正向的类别级读取与无警告观察。但记录没有Main App窗口内事件总数/筛选数或可绑定17条projection的消费证据，亦无机器完整性/拒绝/fallback计数。故不能把三类可见提升为17/17消费或完整reader证明；此为新reader缺口，未被原值残项接受覆盖。 |
| R4 恢复/边界 | Covered。Human仅对本C5-R接受logging/expiry原值及存在性未知为非阻塞未验证残项；收尾logging=false、expiry不存在，DISP/ENGINE原缺省保持。不得称exact restore。当前C5的30 skips为Human接受的未验证残项，仍非passed；duplicate-member parser限制保留。1次输入、0自动重试；无Maps、Gate、Release或父Assignment关闭。 |

**Hold项与最小补证：** HOST-Q-R-01（reader逐窗完整性）。无需本轮重开设备或采集；只需已有、同App同窗口的内容无关reader记录明确绑定该17条窗口投影并记录显示计数及无完整性/unsupported notice。若当前归档不存在，不得用后续未授权查看补造；任何新运行需新Human授权和独占窗口。原logging/expiry接受仍限定原残项。

依据定位：`c5-r-entry-2026-10-01.md`、`c5-r-typed-window.json`、`c5-r-final-check.json`、`c5-r-capture-restoration-disposition.json`、`c5-r-validation-2026-10-01.md`；主App reader在 `DiagnosticsLogSource.swift:99–110,328–353`、`DiagnosticsStore.swift:150–152`、`DiagnosticsLogContentView.swift:45–59`。三份采集脚本只检查了文本及窗口/投影规则，没有运行。Round1结论只属本次归档验收，不改写此前Partial或另阶段决定。
