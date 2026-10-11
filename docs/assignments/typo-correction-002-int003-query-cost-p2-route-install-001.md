# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-INSTALL-001

Policy version 1.0.0

## Current Status

Completed：405D installed78身份核对Pass，AUTH consumed/exhausted；未launch，父Active。

```kos-record
{
  "schema_version": {
    "major": 1,
    "minor": 0
  },
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-INSTALL-001",
  "record_type": "assignment",
  "title": "固定route DEBUG包405D一次安装及installed78核对",
  "lifecycle": "completed",
  "current_phase": "Completed：one405D install exit0/installed78 exact match，source25不变；未launch/runtime",
  "updated_at": "2026-10-10T15:47:57.674098+00:00",
  "decision_source": "Human 2026-10-10 +08:00“确认仍独占，继续吧”，承接单次安装新包及安装文件核对建议",
  "parent_refs": [
    "TYPO-CORRECTION-002"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-INSTALL-001"
  ],
  "responsibilities": {
    "assignment_authority": "Human Product Lead",
    "domain_owner": "Test / Release Maintainer（P2 evidence）",
    "executor": "当前Codex /root：manifest/read-only receipts",
    "environment_executor": "当前Codex /root：only405D一次simctl install及bundle location核对",
    "human_dependency": "Human已确认405D当前独占；本轮无手动输入",
    "architecture_reviewer": "Not Applicable：不改源或架构，只安装已核验包",
    "quality_reviewer": "Not Applicable：Executor installed identity证据，不独立Quality/Gate",
    "product_approver": "Human Product Lead"
  },
  "scope": "405D ready只读核对、one simctl install、one get_app_container app及完整78files hash/大小/新增项核对",
  "non_goals": "no launch/typing/button/deploy/reset/preferences/test/build/LLDB/Git/Gate/Close; no other simulator; no retry",
  "fixed_identity": {
    "writer": "/Users/doubleshy0n/.codex/worktrees/int003-query-cost-memory-impl-001/Universe Keyboard",
    "source_head": "72dd21710f2a86c9f951d489f645bae89b053b58",
    "candidate_sha256": "d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2",
    "payload_manifest_sha256": "8bded308bca12cac26d3a1f572287464d1642aea957b338b6d176ebeaa6aa442",
    "app": "/private/tmp/uk-routepkg1/DD/Build/Products/Debug-iphonesimulator/Universe Keyboard.app",
    "device_udid": "405D994F-28CB-4F89-BB22-B64AD81C05A2",
    "device_argv": [
      "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl",
      "list",
      "devices",
      "--json"
    ],
    "install_argv": [
      "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl",
      "install",
      "405D994F-28CB-4F89-BB22-B64AD81C05A2",
      "/private/tmp/uk-routepkg1/DD/Build/Products/Debug-iphonesimulator/Universe Keyboard.app"
    ],
    "container_argv": [
      "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl",
      "get_app_container",
      "405D994F-28CB-4F89-BB22-B64AD81C05A2",
      "com.DoubleShy0N.Universe-Keyboard",
      "app"
    ],
    "timeout_each_seconds": 120,
    "install_attempts_max": 1,
    "environment": {
      "DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer"
    },
    "exclusive_source": "Human current“确认仍独占，继续吧”",
    "non_goals": "no launch/typing/button/deploy/reset/preferences/test/build/LLDB/Git/Gate/Close; no other simulator; no retry"
  },
  "required_inputs": [
    "Human405D exclusive andinstall authorization",
    "newpayload78 manifest and build artifactpass",
    "fixedsource25/candidate"
  ],
  "entry_criteria": [
    "AUTH先释放consume",
    "source25/head/hash及payload78 exact match",
    "405D Booted且available，若非ready停止不自行启动"
  ],
  "exit_criteria": [
    "only once install exit0 then allinstalledfiles exact match；或首failure保存stop不重试",
    "不launch/输入/诊断，父Active和AUTH耗尽"
  ],
  "stop_conditions": [
    "失去exclusive/deviceunavailable/hash漂移/command failure或120s timeout即停，no retry",
    "only405D，不动其他设备，不因main推进重build"
  ],
  "handoff_target": "Human：installed78身份回执；运行前置只读确认和actualarm分别新AUTH",
  "revalidation_triggers": [
    "payload/source/environment/exclusive变化须重绑定；main推进本身不重试"
  ],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-cost-p2-route-install-001.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p2-route-install-001-installed-identity.json"
  ],
  "closeout_trigger_identity": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-INSTALL-001:once-install-installed78:AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-INSTALL-001"
}
```
