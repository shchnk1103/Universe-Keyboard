# C4 integrated v6 paired validation — delivery

2026-10-01 Asia/Shanghai. Human authorized freeze/independent review/full paired verification and confirmed a fresh exclusive iPhone18Pro/iOS27.0 window, exact UDID405D994F-28CB-4F89-BB22-B64AD81C05A2. Entry/authorization, candidate/input manifests, commands, raw logs, xcresult file inventories, skip reasons and paired products accompany this record.

## Candidate identity

Selected worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`; branch `codex/keyboard-wake-v3-compatibility-gate`; HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`. Frozen candidate digest `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9` binds 568 source/build inputs and 34 focused independent review targets. This identifies the dirty integrated source, not merely the base HEAD. Five product constructors select v6; Core public defaults stay v5 and historical bytes/gates unchanged.

## Current verification

| Step | Actual result |
|---|---|
| Swift format/strict lint | 17 changed Swift files pass; formatting performed on exact scratch copies and verified byte-identical to repository inputs; no source write |
| Pinned RIME vendor | structural+receipt verify pass; 630 local vendor-file hashes and pinned manifest/receipt preserved; no fetch |
| Full KeyboardCore host suite | 1184 passed / 0 failed |
| RimeBridgeTests Debug | 105 total =85 passed +20 skipped +0 failed |
| App + Keyboard Debug | 431 total =421 passed +10 skipped +0 failed |
| Signed Keychain focused | 1 passed /0 skipped /0 failed |
| Release build | exit0; configuration build only, not Release delivery |

Raw host Core logs retain the known optional interpolation warning in `T9PinyinPathTests.swift:1429`. Xcode logs retain AppIntents metadata-extraction skipped tool warnings, although xcresult summary warningCount is zero; do not interpret metrics as no raw warnings. No Swift warnings/errors under the strict iOS target flags. Unsigned App runner logged AppGroup entitlement absence; separately signed Keychain validation passed. Sandbox xcresult summary cache extraction needed narrow host escalation; actual test execution and result counts are unaffected.

All three relevant current App/producer tests succeeded: `testV6HistoriesPropagateCompletenessThroughCompositeQuery`, `testClosedExpiredAndV5GatesDoNotChangeProxyBehavior`, `testV6ProducerAndAdapterWriteFiniteMarkersAroundProxyCalls`. Core suite includes writer-version/all-family validation. This evidence covers isolated reader/writer/producer behavior; injected runtime tests and compiled target membership do not prove actual appex callbacks or default AppGroup persistence.

## Paired build provenance

Debug retained after the signed focused test and Release final products both embed `Keyboard.appex` in `Universe Keyboard.app`. Both members of each pair have version1.0/build1, expected bundle IDs and independent executable/plist SHA256 values recorded in paired-products manifest, tied to same frozen input digest and exact commands. Debug signing differs from unsigned full-suite runner, so it is described precisely rather than reusing unsigned executable identity. Installed identity and production marker emission were not inspected or proven. No manual install, diagnostics arming, actual appex callback, Maps, Release delivery or Git operation.

## Residuals

All 30 current skip IDs/reasons/source lines remain unverified in skip inventory, with no current-stage Product acceptance. The unsigned full suite's Keychain skip remains a skip entry even though its separately signed counterpart passed. Prior v5/StageB-only acceptance is not carried. Duplicate JSON object member detection limitation remains explicit. Promotion/installation/real appex/Maps dependencies are not satisfied by this matrix.

## Independent reviews

Architecture A-C4 round1: **Full static coverage A1–A6; no Architecture blocker found**. Quality Q-C4 round1: **Blocker**, with Q1–Q6 fully covered; sole finding `C4-Q-01` is missing current-stage Human Product disposition for the exact 30 skip records. Original independent reports and usage preserved. This is not a Quality Gate Pass.

Architecture report/usage omitted three packet-digest characters; reviewer acknowledged the actual digest and a separate factual reconciliation fixes the identity reference without rewriting the original verdict. Quality report mentions historical “Architecture R3” as a parallel lane; the current source lane is **A-C4 round1**, not historical StageB R3. This label is not used as C4 Architecture proof; actual A-C4 original report/candidate hashes are separately archived. Raw Release log has 2 AppIntents warnings; other logs also retain metadata warnings, as described above. Operational usage records explicitly disclose late checkpoints (Architecture12/21/31; Quality14/23/30) and Architecture absent guessed paths; no strict protocol-compliance claim is made.

## Preservation and handoff

After the entire matrix, all 2455 pre-existing baseline files remained byte-identical, staged empty, branch/HEAD unchanged and `git diff --check` passed. Only C4 evidence and final owning Assignment bookkeeping are written. Root sole repo writer; reused GPT6 Luna reviewers independent of authorship. Verification window ended after all matrix actions; new Simulator work needs fresh reservation. Parent remains Active; no Product/Quality/Release Gate or root-cause conclusion. No new source/test fixes; CHANGELOG/ADR not changed because this is evidence for the existing accepted contract, not a published behavior change.
