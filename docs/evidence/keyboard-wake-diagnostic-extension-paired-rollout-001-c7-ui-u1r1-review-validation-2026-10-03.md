# U1R1 独立运行验收交付 — 2026-10-03

独立 GPT6 Luna low /root/t_split_p 对 QUALITY-C7-UI-U1R1-RUNTIME round1 已提交窄范围 Positive scoped runtime-chain acceptance；P1、P2、P3 均 Covered。报告及独立解析原字节保留，**正式交付一致性仍Partial/incomplete**，不得把独立范围意见或root实际hash核对代替缺失/矛盾的必需usage字段。

[独立报告](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-review-artifacts/review.md)、[usage](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-review-artifacts/usage.json)、[独立解析](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-review-artifacts/independent-analysis.json)、[接收核对](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-review-artifacts/root-receipt.json)。固定43d85d…、原UDID/新PID88188/session4895a8c9…，65内容/1279hash-only输入零漂移，独立raw528byte/5行逐字段及唯一attempt配对、真实caller有效borrow/一次read/断点删除列表为空/continue/detach/15debugcall账本均覆盖。

Reviewer使用6/6 leaf calls、259.904644秒（报告writer原wallclock，不与root63.106秒混用），在450soft/600hard内；无新设备采集。报告SHA9e739c6f3ec8f575369a4b5a830ef759d4bdc6e9243b9f1b18fe5c774674b5f8。原始6-call预算已耗尽，不自动续。

## 独立意见与必要限制

仅本候选正常路径的运行证据链接受；owner1/receipt1只调度记录点语义，synthetic arm owner0不代表owner为空。本地buffer complete不是engine/host/全部callback证明，未知实际click/target pause开始/borrow创建UTC及Human仅视觉Exit均保留。无Maps/根因/Release/Product或整体Quality Gate结论，父子Active。

## 正式交付一致性缺口（不是runtime failure）

- U1R1-D-001：report P1写Call1=image list，primary实际Call2=image list、Call1=attach。
- U1R1-D-002：usage external_identity_matches=false，但root按正确字段重算whole/canonical均与external身份及独立报告一致；usage self_sha_matches实际true。作者final消息误指self字段，原文保留，不把它代成已经更正external。
- U1R1-D-003：usage status仍为旧Partial/in-progress，和正式Complete覆盖/report不一致。
- U1R1-D-004：packet要求的逐次reviewer调用request/output时间来源字段未交付，只有aggregate start/end和checkpoint。补正只填已有实际观测；原来没采的individual UTC留null，不补造。

以上未交由Product接受、未root擅改原报告；不从独立P1–P3Covered推正式交付完全一致。[最小作者补正Prepared](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-review-delivery-correction-prepared-2026-10-03.md)仅2calls/180秒，无新实质review，待Human决定；范围/预算不得自动增加。原运行采集不因交付笔误改写为失败。

当前授权独立意见已交付；补正未执行，未再触设备/源码/测试/构建/Git/Maps。docs-only跳过xcodebuild，无需CHANGELOG或架构合同改动。
