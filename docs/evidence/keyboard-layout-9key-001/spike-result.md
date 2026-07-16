# T9 Compatibility Spike Result

- Status: **PASSED**
- Timestamp: 2026-07-16 19:45:00 CST
- xcodebuild exit: 0
- Evidence dir: `/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-194424`
- Provenance: `/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-194424/provenance.md`
- Full log: `/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-194424/logs/xcodebuild-t9-spike.log`

## Required checks

| Check | Result |
|---|---|
| Isolated temp deploy directory | yes (`/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-194424/runtime`) |
| Upstream t9.schema.yaml captured | yes (SHA-256 `56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6`) |
| Unsupported t9_processor removed | yes (patched SHA-256 `176a01aefcfeba856906ba6e83a9cf147fbd57d39f9923c70b36879c8bb5d57b`) |
| Pinned librime used via RimeBridgeTests | yes (scheme RimeBridgeTests) |
| Schema selected + digits + delete | see summary below |

## Machine summary line

```
1295:T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
1296:T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
1297:2026-07-16 19:44:59.642490+0800 xctest[94305:3128392] T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
```

## XCTest verdict excerpt

```
2:    /Applications/Xcode-beta.app/Contents/Developer/usr/bin/xcodebuild test -project "Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination "platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474" -derivedDataPath "/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-194424/DerivedData" "-only-testing:RimeBridgeTests/RimeT9CompatibilitySpikeTests/testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor"
1171:SwiftCompile normal arm64 Compiling\ RimeT9CompatibilitySpikeTests.swift /Users/doubleshy0n/Dev/Universe\ Keyboard/Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9CompatibilitySpikeTests.swift (in target 'RimeBridgeTests' from project 'Universe Keyboard')
1173:SwiftCompile normal arm64 /Users/doubleshy0n/Dev/Universe\ Keyboard/Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9CompatibilitySpikeTests.swift (in target 'RimeBridgeTests' from project 'Universe Keyboard')
1175:    builtin-SwiftPerFileCompile RimeT9CompatibilitySpikeTests.swift
1231:SwiftDriverJobDiscovery normal arm64 Compiling RimeT9CompatibilitySpikeTests.swift (in target 'RimeBridgeTests' from project 'Universe Keyboard')
1283:Test Suite 'RimeT9CompatibilitySpikeTests' started at 2026-07-16 19:44:47.974.
1284:Test Case '-[RimeBridgeTests.RimeT9CompatibilitySpikeTests testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor]' started.
1295:T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
1296:T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
1297:2026-07-16 19:44:59.642490+0800 xctest[94305:3128392] T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 rawAfterDelete=6 deploy=librime 1.16.1, luaRuntimeRegistered=true
1298:Test Case '-[RimeBridgeTests.RimeT9CompatibilitySpikeTests testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor]' passed (11.674 seconds).
1299:Test Suite 'RimeT9CompatibilitySpikeTests' passed at 2026-07-16 19:44:59.650.
1301:Test Suite 'RimeBridgeTests.xctest' passed at 2026-07-16 19:44:59.653.
1303:Test Suite 'Selected tests' passed at 2026-07-16 19:44:59.653.
```
