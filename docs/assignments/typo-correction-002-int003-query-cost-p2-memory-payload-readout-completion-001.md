# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-MEMORY-PAYLOAD-READOUT-COMPLETION-001

Policy version 1.0.0

## Current Status

- Lifecycle: Completed
- Phase: 工具预检及2/2签名命令通过，metadata收尾完成
- Non-claims: 无设备、Capture、Gate或发布
- Next: Human确认模拟器可用及独立安装绑定AUTH

```kos-record
{
  "schema_version": {
    "major": 1,
    "minor": 0
  },
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-MEMORY-PAYLOAD-READOUT-COMPLETION-001",
  "record_type": "assignment",
  "title": "整体工具预检后的两项签名readout收尾",
  "lifecycle": "completed",
  "current_phase": "2/2签名命令exit0，固定payload metadata完整；仅本轮Completed",
  "updated_at": "2026-10-09T14:26:43.255287+08:00",
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-MEMORY-PAYLOAD-READOUT-COMPLETION-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002"
  ],
  "responsibilities": {
    "assignment_authority": "Human Product Owner acting as Product Lead",
    "domain_owner": "Test / Release Maintainer",
    "executor": "Codex /root，仅私有runner修正/预检/metadata归档",
    "environment_executor": "Codex /root，仅2个codesign只读命令；零build/设备",
    "human_dependency": "Human当前继续批准最小工具修正与两命令收尾；无设备依赖",
    "architecture_reviewer": "Not Applicable：源码/合同/产物不变",
    "quality_reviewer": "Not Applicable：本轮Executor-recorded metadata补齐；独立runtime/readiness另AUTH",
    "product_approver": "Human Product Owner acting as Product Lead"
  },
  "scope": "仅私有runner语法修正及整体ast/mock预检；绑定预检script/helper哈希、同22源码/74产物。预检通过后一次执行embedded Keyboard codesign verify/display，最多2命令、命令轮300秒、首失败停止。零build/产品测试/源改/重签名/设备/LLDB/profiler/输入/发布/merge/Capture/Gate/父Close/ADR Accept/Release，不追main。",
  "decision_source": "Human：继续吧，请你仔细一点吧。批准前轮最小方案；2026-10-09T14:25:23.845088+08:00",
  "fixed_identity": {
    "HEAD": "72dd21710f2a86c9f951d489f645bae89b053b58",
    "candidate_manifest_sha256": "d0e491083df08df27ff8e463ad9f4824c5d083c0804ccc0cdf9c811e23cdf4ad",
    "old_readout_sha256": "b3152b40c979438e5ded6b2afc09af3b3954cdf062c6206cb98171c489252453",
    "build_receipt_sha256": "f460a89cd84fea4bb87fb7fd5b63ae44eec8e3cc3912c51959d0ca4792c547cf",
    "payload_files": 74,
    "macho": 2,
    "output_root": "/private/tmp/universe-keyboard-int003-p2-memory-payload-readout-completion-001",
    "runner_sha256": "514eb5e974a36fb47b14812fe05cc93b07cef55199b50d1bd5b4cbeedc4e27e0",
    "helper_sha256": "cd3ac83f9bd251501664f13f62a58df9a1451101c8da587989dbba885531593b"
  },
  "required_inputs": [
    "旧成功编译和失败readout固定bytes",
    "74file/2binary/旧CLI日志及savedAppXML",
    "固定22源码与HEAD"
  ],
  "entry_criteria": [
    "整体ast与mock成功/首失败停止/报告JSON预检通过",
    "source22/HEAD/index/74filehash匹配",
    "Human批准新独立AUTH；旧AUTH耗尽保留"
  ],
  "exit_criteria": [
    "exact2codesign exit0及新XMLparse成功",
    "全83固定输入前后hash匹配，完整metadata关联旧build",
    "记录本轮usage/UTC及旧失败，不授予runtime或Quality Pass"
  ],
  "stop_conditions": [
    "首解析/CLI/metadata/hash失败停，不重build/重试/自动续预算",
    "2codesign命令/300秒先到停止；未覆盖Partial",
    "不扩inputs/privateusertext/device/profiler/权限"
  ],
  "handoff_target": "Human Product Lead：产物完整readout后，单独确定设备安装/暖机/transport授权",
  "revalidation_triggers": [
    "源/产物/命令/覆盖/权限变化需新AUTH；main更新不自动重试"
  ],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-cost-p2-memory-payload-readout-completion-001.md"
  ]
}
```

[批准方案](../plans/typo-correction-002-int003-query-cost-p2-memory-payload-readout-completion-001.md)。
