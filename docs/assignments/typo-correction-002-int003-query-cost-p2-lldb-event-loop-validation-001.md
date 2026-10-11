# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LLDB-EVENT-LOOP-VALIDATION-001

Policy version 1.0.0

Status: Completed — AUTH consumed / exhausted; tool Pass, arm rejected

```kos-record
{
  "schema_version": {
    "major": 1,
    "minor": 0
  },
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LLDB-EVENT-LOOP-VALIDATION-001",
  "record_type": "assignment",
  "title": "LLDB本地事件处理修正及一次条件快照验证",
  "lifecycle": "completed",
  "current_phase": "Completed：事件工具运行准入及exact128传输通过；actual rejected/session0-schemaunknown，非正式P2 Capture",
  "updated_at": "2026-10-10T14:15:32.995733+00:00",
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LLDB-EVENT-LOOP-VALIDATION-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002"
  ],
  "responsibilities": {
    "assignment_authority": "Human Product Lead",
    "domain_owner": "Test / Release Maintainer",
    "executor": "root：绑定/metadata及128byte解码",
    "environment_executor": "root：oneLLDB/只读identity+128bytes/显式detach、同PID状态及条件CONT一次",
    "human_dependency": "Human：等待ready后不触3秒，仅点击观测成本一次，回复实际标题，无输入",
    "architecture_reviewer": "复用四路径R2 Pass，非实际guard runtime verdict",
    "quality_reviewer": "Executor-recorded本单轮数字取证，非独立Product或performanceGate",
    "product_approver": "Human Product Lead"
  },
  "decision_source": "Human“继续吧”批准上一最小事件处理方案：本地driver修正及一次绑定验证；先建立并消费独立AUTH。",
  "scope": "只修private driver/launcher，新增event API一次offline检查；fixedsource25/installed78/unique405DPID一次preflight；oneattach loadedUUID/path+helper1，消费同listener事件确认running并精确ps后Humanonearm/exact128，finallydetach/samePIDps条件CONT。无input/build/install/main追逐",
  "non_goals": "No source changes/tests/launch/deploy/record/debugger/publication/Gate; no main chasing or rebuild retry",
  "fixed_identity": {
    "candidate_sha256": "6d1e5c285b49717f53546b94e673cebf053903b351383bb9f3206e88ad7c31a9",
    "manifest_sha256": "c5d921c821f38ec5532aaa813870ce69a39254b423b4c2213a80d32a1a2b5c34",
    "device": "405D994F-28CB-4F89-BB22-B64AD81C05A2",
    "output_root": "/private/tmp/uk-armevent1",
    "driver_sha256": "77b1bf3fd3c8af4adcc098cdba8b66402c426b0a2d55f41984f26f2546414f27",
    "launch_sha256": "ce3418e92c3a5e7ed8c2b1a01a150f9ff0c1d4665fefad85d9f6108c333adaa3",
    "api_sha256": "a86a830dbe94b64ab4667895b517971c2ca0a89d90681b4241b452996820756f"
  },
  "required_inputs": [
    "批准的event-loop-validation方案",
    "fixedsource25/installed78及旧offline通过回执",
    "405D独占授权未撤销及current uniquePID"
  ],
  "entry_criteria": [
    "先消费新AUTH",
    "新增API检查及source/installed/PID一次preflight通过",
    "loaded两UUID/path、livehelper1、Continue之后同PIDrunning事件+GetState+精确ps后才Human点击"
  ],
  "exit_criteria": [
    "exact128严格decode与actualtitle或首失败完整numeric回执",
    "detach成功/samePID不T，AUTH耗尽",
    "只报告当前attempt，不推定旧拒绝根因/P2完成"
  ],
  "stop_conditions": [
    "新增API30s/preflight30s; oneLLDB420s incl attach30s resume5s Human300s cleanup10s;64events/cycle4096total;firstfailurestop",
    "firstfailurestop，无重attach/rearm/reset/build/install/kill",
    "仅128bytes helper借用，禁expr/任意heap/文本",
    "detach后同PID/path仍T才一次CONT清理"
  ],
  "handoff_target": "Human：已有纠错查询链路的最小准备方案；旧rejected实例不重arm，进一步runtime需新AUTH",
  "revalidation_triggers": [
    "相关输入/产物/环境变化才评估，main推进不重试"
  ],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-cost-p2-lldb-event-loop-validation-001.md"
  ],
  "stage_dependencies": {
    "preflight": "source/installed/currentprocess numeric metadata",
    "arm": "sameLLDB loadedUUID and exacthelper BP resolved; process running and Human instruction",
    "readout": "samehelper stop arguments address/count;128bytes only",
    "cleanup": "finally detach+ps; conditional exactPID CONT once"
  },
  "closeout_trigger_identity": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LLDB-EVENT-LOOP-VALIDATION-001:one-validation:AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LLDB-EVENT-LOOP-VALIDATION-001"
}
```
