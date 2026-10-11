# F01 fixed-a44 once CI

Exact frozen base `a44f850d638204aa5c992ac13fb71f5f5424734c`; source5 manifest SHA256 `44fbd8924502c48f36f1f58bcf8446f83801119b78dbf666d124ae45b2b47be1`. Command binding SHA256 `9d1c6e5260cd6e274950ff6da9bf60628c74d073dd3b95fa669935eb2d36a0d6`. Independent consumed AUTH: AUTH-TYPO-CORRECTION-002-F01-FIXED-INTEGRATION-001. Human confirms 405D exclusive.

Same-account isolated outputs, formal Xcode.app, inherited pinned package cache; no outer sandbox-exec wrapper. Necessary Xcode/SwiftPM cache and temp operations, pinned Vendor fetch/verify, private test fixtures and the one unique Keychain test item are in scope. Full default CI in order: strict lint5, Core, RimeBridgeTests, App/Keyboard, signed Keychain, Release. Every stage once, first failure stops; no automatic fixes/retry/rebase after main updates. No probe52 rerun: those untouched opt-in paths are outside F01 delta; prior evidence retains its exact baseline. No source publication or merge.

[Candidate](../evidence/typo-correction-002-f01-fixed-integration-001-candidate.json), [exact commands](../evidence/typo-correction-002-f01-fixed-integration-001-binding-original.json), [runner](../evidence/typo-correction-002-f01-fixed-integration-001-run.py). Run outputs retained under `/private/tmp/uk-f01ci-a44-001`; full logs are not copied to Git.
