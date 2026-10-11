# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-IMPLEMENTATION-001

Policy version 1.0.0

## Current Status

Completed（实施与格式检查）；AUTH consumed / exhausted；测试/编译/运行尚未执行。

```kos-record
{
  "schema_version": {
    "major": 1,
    "minor": 0
  },
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-IMPLEMENTATION-001",
  "record_type": "assignment",
  "title": "Proposed：既有query-cost探针的最小route/facade scope适配",
  "lifecycle": "completed",
  "current_phase": "Completed：10路径最小DEBUG适配/测试源码与private v2 decoder，strict format/lint通过，新candidate冻结；未test/build/runtime",
  "updated_at": "2026-10-10T14:52:21.808539+00:00",
  "decision_source": "Human“批准，请继续吧”明确接受两scope准入含义补充并批准独立最小DEBUG实施；测试/设备/发布另绑定",
  "parent_refs": [
    "TYPO-CORRECTION-002"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-IMPLEMENTATION-001"
  ],
  "responsibilities": {
    "assignment_authority": "Human Product Lead",
    "domain_owner": "Test / Release Maintainer（P2 evidence）",
    "executor": "当前Codex：仅获批准后实施DEBUG适配",
    "environment_executor": "当前Codex：strict format/lint及private工具语法核对；测试/设备另AUTH",
    "human_dependency": "Human：批准native-session/provider-facade两种scope含义及指定实施范围；本阶段无手动输入",
    "architecture_reviewer": "Architecture & Knowledge Steward：后续新candidate增量lane单独冻结授权，当前不派发",
    "quality_reviewer": "Test / Release Maintainer：后续新candidate限定验证与增量lane单独冻结授权，当前不派发",
    "product_approver": "Human Product Lead"
  },
  "scope": "10路径DEBUG/probe scope及v2 codec适配、private LLDB v2 decoder更新、strict format/lint及冻结candidate；不执行tests/build/install/LLDB",
  "non_goals": "No production route/query/fence/Bootstrap/RimeBridge changes; no storage/UI/logs/provenance/main chasing/publication/Gate/Close",
  "fixed_identity": {
    "source_head": "72dd21710f2a86c9f951d489f645bae89b053b58",
    "candidate_sha256": "6d1e5c285b49717f53546b94e673cebf053903b351383bb9f3206e88ad7c31a9",
    "writer": "/Users/doubleshy0n/.codex/worktrees/int003-query-cost-memory-impl-001/Universe Keyboard",
    "preimage_manifest": "/private/tmp/uk-route-design1/source-preimages.json",
    "preimage_sha256": "b4eba4515bcfd22c531cb0bb2bab00262c53e2be7b7c133847be05d4961da601",
    "allowed_paths": [
      "Packages/KeyboardCore/Sources/KeyboardCore/QueryCostMemoryProbe.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift",
      "Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift",
      "Keyboard/Controllers/KeyboardViewController+QueryCostProbe.swift",
      "Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift",
      "Keyboard/Controllers/QueryCostArmDiagnostic.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/QueryCostMemoryProbeTests.swift",
      "KeyboardExtensionTests/QueryCostArmDiagnosticTests.swift",
      "KeyboardExtensionTests/TypoCorrectionRecallCoordinatorIntegrationTests.swift",
      "KeyboardExtensionTests/TypoCorrectionQueryCostProbeIntegrationTests.swift"
    ],
    "final_candidate": "/private/tmp/uk-route-impl1/candidate.json",
    "final_candidate_sha256": "d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2",
    "delta_manifest_sha256": "7a5efae2bf9abe615f9786561edd3d59641e03784d6d067e7b07a12434a30226"
  },
  "required_inputs": [
    "Human明确批准Proposed两scope准入语义及实施AUTH",
    "route设计及完整source-preimages",
    "固定candidate及此前工具验证证据（非新scope验证）"
  ],
  "entry_criteria": [
    "独立AUTH释放并先消费，非复用旧AUTH",
    "source25及10路径preimages匹配，变更前备份",
    "只进入DEBUG/probe范围，不改生产引擎/路由"
  ],
  "exit_criteria": [
    "两scope来源/生命周期分明，unknown fail closed",
    "v2严格codec与现有尺寸不变，历史v1不倒写",
    "修改Swift strict格式lint通过，新candidate固定",
    "新增测试源码与验证映射明确，但不宣称测试已执行"
  ],
  "stop_conditions": [
    "若须扩大10路径、生产路由或原产品计数合同，停止交Human",
    "identity mismatch或ordinal overflow unavailable，不猜测",
    "不因main更新反复重验；最多完成本指定增量，无自动编译/设备重试"
  ],
  "handoff_target": "Human：固定candidate上的一次Core及hostless Extension限定验证独立AUTH，再按增量review和运行各自绑定",
  "revalidation_triggers": [
    "冻结源或相关scope环境变化须影响核查；main更新本身不触发重试"
  ],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-cost-p2-route-scope-implementation-001.md"
  ],
  "closeout_trigger_identity": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-IMPLEMENTATION-001:proposed-scope-implementation:AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-IMPLEMENTATION-001"
}
```
