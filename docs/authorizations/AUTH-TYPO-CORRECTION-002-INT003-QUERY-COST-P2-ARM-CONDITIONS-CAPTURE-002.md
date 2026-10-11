# AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ARM-CONDITIONS-CAPTURE-002

Policy version 1.0.0

Status: Partial / Blocked — AUTH consumed / exhausted

```kos-record
{
  "schema_version": {
    "major": 1,
    "minor": 0
  },
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ARM-CONDITIONS-CAPTURE-002",
  "record_type": "authorization",
  "status": "live",
  "updated_at": "2026-10-10T14:05:51.450613+00:00",
  "decision_source": "Human“继续”承接offline全部通过后的下一建议：一次actual arm条件snapshot诊断，复用兼容性预检，不授权新的输入或正式Capture。",
  "authorization": {
    "action": "one_same_pid_arm_conditions_snapshot_after_offline_pass",
    "target": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ARM-CONDITIONS-CAPTURE-002",
    "scope": "固定25源/installed78，唯一exact405D当前Keyboard PID，oneattach验证two loadedUUID/path和exacthelper resolved1，恢复后Human只点观测成本一次，helper停点只读取address/count和128bytes数字快照，finally detach及samePID ps；只在本次清理后同PID/path仍T才一次CONT。无input",
    "issuer_role": "Human Product Lead",
    "decision_source": "Human“继续”承接offline全部通过后的下一建议：一次actual arm条件snapshot诊断，复用兼容性预检，不授权新的输入或正式Capture。",
    "consumption_state": "consumed",
    "execution_state": "exhausted",
    "live_at": "2026-10-10T14:00:41.221326+00:00",
    "consumed_at": "2026-10-10T14:00:41.221326+00:00",
    "budget": "preflight<=30s; oneLLDB attach/session<=420s incl300s human window; cleanup samePID detach<=10s then ps; conditionalsamePID CONT once only ifT and exactpath remains; no reattach/reset/rearm/build/install",
    "privacy": "exact128numeric diagnostic; args address/count only; no host/candidate text/other memory/state changes",
    "publication": "None",
    "automatic_effects": "private metadata/debugger transcript/exact128; oneattach+resume+detach; conditionalsamePIDCONT cleanup; no input/store/prefs changes"
  }
}
```
