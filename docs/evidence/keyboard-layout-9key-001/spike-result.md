# T9 Compatibility Spike Result

- Status: **PASSED**
- Timestamp: 2026-07-16 19:56:21 CST
- xcodebuild exit: 0
- Harness commit: `337dd30ab443ad2d2af497648910946d6beb1a35`
- Evidence dir: `/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-195542`
- Provenance: `/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-195542/provenance.md`
- Full log: `/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-195542/logs/xcodebuild-t9-spike.log`
- Full log SHA-256: `784ac88f775d414cc7f181f55e9c7cdb0127b00c8d9d68a79eb59097c7ebe651`
- Vendor verify log SHA-256: `03fd59b207427813f241bb2217f226ac161e682885d370421269bff6e51b17e4`
- Upstream schema SHA-256: `56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6`
- Patched schema SHA-256: `176a01aefcfeba856906ba6e83a9cf147fbd57d39f9923c70b36879c8bb5d57b`

## Required checks

| Check | Result |
|---|---|
| Isolated temp deploy directory | yes (`/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-195542/runtime`) |
| Upstream t9.schema.yaml captured | yes (SHA-256 `56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6`) |
| Unsupported t9_processor removed | yes (patched SHA-256 `176a01aefcfeba856906ba6e83a9cf147fbd57d39f9923c70b36879c8bb5d57b`) |
| Vendor verify succeeded | yes (SHA-256 `03fd59b207427813f241bb2217f226ac161e682885d370421269bff6e51b17e4`) |
| Harness commit contains Spike test | yes (`337dd30ab443ad2d2af497648910946d6beb1a35`) |
| Pinned librime used via RimeBridgeTests | yes (scheme RimeBridgeTests) |
| Schema selected + non-empty candidates + preedit + delete | see summary below |

## Machine summary line

```
1295:T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 firstCandidateComment=ni rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
1296:T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 firstCandidateComment=ni rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
1297:2026-07-16 19:56:20.467300+0800 xctest[14828:3168065] T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 firstCandidateComment=ni rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
```

## XCTest verdict excerpt

```
2:    /Applications/Xcode-beta.app/Contents/Developer/usr/bin/xcodebuild test -project "Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination "platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474" -derivedDataPath "/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-195542/DerivedData" "-only-testing:RimeBridgeTests/RimeT9CompatibilitySpikeTests/testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor"
1189:SwiftCompile normal arm64 Compiling\ RimeT9CompatibilitySpikeTests.swift /Users/doubleshy0n/Dev/Universe\ Keyboard/Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9CompatibilitySpikeTests.swift (in target 'RimeBridgeTests' from project 'Universe Keyboard')
1191:SwiftCompile normal arm64 /Users/doubleshy0n/Dev/Universe\ Keyboard/Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9CompatibilitySpikeTests.swift (in target 'RimeBridgeTests' from project 'Universe Keyboard')
1193:    builtin-SwiftPerFileCompile RimeT9CompatibilitySpikeTests.swift
1231:SwiftDriverJobDiscovery normal arm64 Compiling RimeT9CompatibilitySpikeTests.swift (in target 'RimeBridgeTests' from project 'Universe Keyboard')
1283:Test Suite 'RimeT9CompatibilitySpikeTests' started at 2026-07-16 19:56:07.001.
1284:Test Case '-[RimeBridgeTests.RimeT9CompatibilitySpikeTests testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor]' started.
1295:T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 firstCandidateComment=ni rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
1296:T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 firstCandidateComment=ni rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
1297:2026-07-16 19:56:20.467300+0800 xctest[14828:3168065] T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 firstCandidateComment=ni rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
1298:Test Case '-[RimeBridgeTests.RimeT9CompatibilitySpikeTests testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor]' passed (13.484 seconds).
1299:Test Suite 'RimeT9CompatibilitySpikeTests' passed at 2026-07-16 19:56:20.497.
1301:Test Suite 'RimeBridgeTests.xctest' passed at 2026-07-16 19:56:20.500.
1303:Test Suite 'Selected tests' passed at 2026-07-16 19:56:20.501.
```
