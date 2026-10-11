# AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-PARTIAL-EXPORT-001

Policy version 1.0.0

## Current Status

Completed：限定诊断导出成功，AUTH耗尽；stimulus偏离、非formalP2Pass，父Active。

```kos-record
{
  "schema_version": {
    "major": 1,
    "minor": 0
  },
  "record_id": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-PARTIAL-EXPORT-001",
  "record_type": "authorization",
  "status": "live",
  "updated_at": "2026-10-10T18:08:35.107830+00:00",
  "decision_source": "Human明确授权限定导出，确认重复1包含完整开始/结束边界；实际7闭合序列",
  "authorization": {
    "action": "one_existing_deviated_run_bounded_export",
    "target": "TYPO-CORRECTION-002-INT003-QUERY-COST-P2-PARTIAL-EXPORT-001",
    "scope": "existing7closedsequences only diagnostic export once; no furtherinput/rearm; original12fixture notpassed",
    "issuer_role": "Human Product Lead",
    "consumption_state": "consumed",
    "execution_state": "exhausted",
    "live_at": "2026-10-10T18:05:37.684556+00:00",
    "consumed_at": "2026-10-10T18:05:37.684556+00:00",
    "binding": {
      "candidate": "/private/tmp/uk-route-impl1/candidate.json",
      "candidate_sha256": "d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2",
      "manifest": "/Users/doubleshy0n/.codex/worktrees/int003-xcode-env-preflight-001/Universe Keyboard/docs/evidence/typo-correction-002-int003-query-cost-p2-route-payload-001-payload-manifest.json",
      "manifest_sha256": "8bded308bca12cac26d3a1f572287464d1642aea957b338b6d176ebeaa6aa442",
      "installed_app": "/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/405D994F-28CB-4F89-BB22-B64AD81C05A2/data/Containers/Bundle/Application/89DBF2C8-CE4A-4811-9046-79B27B1D2CB1/Universe Keyboard.app",
      "target_path": "/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/405D994F-28CB-4F89-BB22-B64AD81C05A2/data/Containers/Bundle/Application/89DBF2C8-CE4A-4811-9046-79B27B1D2CB1/Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard",
      "device": "405D994F-28CB-4F89-BB22-B64AD81C05A2",
      "expected_modules": {
        "/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/405D994F-28CB-4F89-BB22-B64AD81C05A2/data/Containers/Bundle/Application/89DBF2C8-CE4A-4811-9046-79B27B1D2CB1/Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard": "057416AF-EA68-32D1-A849-56A91DD8548F",
        "/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/405D994F-28CB-4F89-BB22-B64AD81C05A2/data/Containers/Bundle/Application/89DBF2C8-CE4A-4811-9046-79B27B1D2CB1/Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard.debug.dylib": "46F38D70-5630-30BF-AF9E-A13C8E303B20"
      },
      "symbol": "$s8Keyboard25queryCostProbeExportReadyyySV_SitF",
      "raw_scope": "only exact queryCostProbeExportReady address/count and TWO copies each256..655616 in SAME valid borrow; no arbitrary heap/input/expressions",
      "budget": "source25/installed78/samePID oneprecheck; oneoffline60s; oneattach420s/human300s/exacttwo copies<=655616/cleanup10s; total10MiB archive120s; no retries",
      "non_goals": "No rearm/restart/build/install/sourceedit/test/trace/anchor/prefs/Git/Gate/parentClose/main chase",
      "human_UI": "2026-10-11 currentHuman FullAccess true/Luna/deployed/two diag off/hostempty/fourinitial labels; do not click until root READY",
      "pid": 46758,
      "driver_sha256": "0606d1502b72bedb5eea28dc9719f1bc5744ffa960c77e92592993fd232718a5",
      "lldb_argv": [
        "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb",
        "--no-lldbinit",
        "--batch",
        "-o",
        "script exec(open(\"/private/tmp/uk-routecapture1/driver.py\").read())"
      ],
      "run_id": "TC2-SIM-20261011-INT003-ROUTE-QUERY-001",
      "arm_attempts": 0,
      "sequences_max": 7,
      "read_copies": 2,
      "wire_max_bytes_each": 655616,
      "artifact_budget_bytes": 10485760,
      "measurement_budget_seconds": 0,
      "export_stops_max": 1,
      "archive_budget_seconds": 120,
      "arm_origin": "/private/tmp/uk-routearm1/snapshot-result.json",
      "scope": "existing7closedsequences only diagnostic export once; no furtherinput/rearm; original12fixture notpassed",
      "human_current": "keyboard visible/empty/four labels as expected/exclusive confirmed current reply",
      "fixture_sha256": "e2b89ba90c5278de0437b7be44660e43df06c2e184bbea078e75e90aade5c47a",
      "sequence_cleanup": "within each open sequence: natural lowercase keys, idle3s, Space once, delete only this public insertion to empty, idle3s,end once; firstObserved1..6,warm7..12",
      "authorization": "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-PARTIAL-EXPORT-001",
      "decoder_sha256": "6c18c45aa9290455c2a7f98592b1eadacd2dccc0cb3d369e3578ae9f71008bde",
      "launch_sha256": "8ae6f325ff3a22df990c7e79ed4324e02bf081b230a23afebe7a98c86ed205f5",
      "run_uuid_words": [
        5138136499253978828,
        8688690792908872119
      ],
      "expected_sequences": 7,
      "stimulus_contract_complete": false,
      "artifact_root": "/private/tmp/uk-routepartial1",
      "actual_stimulus": [
        "F01",
        "F01 repeated",
        "F02",
        "F03",
        "F04",
        "F05",
        "F06"
      ]
    },
    "privacy": "数字快照双副本限定范围，无任意heap/hostinput读取",
    "automatic_effects": "one LLDB attach/stop/read/detach，oneHumanfreeze，有限owned files及文档",
    "publication": "None",
    "completed_at": "2026-10-10T18:08:35.107830+00:00",
    "result": "oneattach/onefreeze/two12896copies v2 complete61calls7seq; sameRunUUID/scope/cleanupPass;stimulusdeviated noformalP2Pass"
  }
}
```
