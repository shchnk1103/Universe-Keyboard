# Uninstall rollback double-failure correction

## Review follow-up

Final independent result: [delta review](../reviews/scheme-delivery-rollback-double-failure-delta-2026-09-08.md) returned P2 Closed, no new P0/P1/P2 blocking finding. This supersedes pending-review statements in earlier run records below; it does not extend Product acceptance.

Independent reviewer `01a07e40-7514-7843-ba4d-5412205b254f` confirmed the bounded retention/manager-stop behavior, but identified P2 coverage missing for continuing after a middle restore failure and retrying the original checkpoint. It also noted the pre-existing missing-staged-path assumption.

Human authorized both corrections. Three-file coverage now fails the middle restore, verifies later restores continue, and retries the original staging description. A missing staged file is accepted only when this installer instance recorded its successful restore and the destination remains present; an unrelated destination alone cannot authorize checkpoint cleanup. A negative test removes a staged file and places unrelated destination bytes, asserting failure and checkpoint retention. This is in-process evidence, not persisted restart recovery or protection against arbitrary external destination mutation.

Final follow-up validation: strict Swift 6 full App/Keyboard run succeeded; App 304 executed, 4 skipped, zero failures; Keyboard 11, zero failures. Both new tests passed. Log `/private/tmp/uk-p4-multifile-test.log`; same Xcode/simulator/DerivedData as below. Changed-file strict-format and `git diff --check` passed. Earlier counts below refer to their stated earlier run. Independent delta verdict remains pending until returned.

Base: `bf9de51`; isolated checkout `/private/tmp/uk-scheme-delivery-fix`. Human authorized this bounded repair on 2026-09-08. Existing uncommitted Grok governance records were preserved.

Failure: rollback ignored failed moves and then removed staging, potentially deleting the only surviving copy. The installer now attempts remaining restores, retains staging if any restore failed, and throws `rollbackIncomplete`. The manager stops without clearing installation metadata or redeploying an incomplete original resource tree. If Luna already deployed, it keeps that selection.

Production-installer test injects failures on moves 2 and 3 (staging and rollback), verifies original bytes remain in staging/live locations, then retries restoration successfully. This proves in-process checkpoint retention and explicit retry, not automatic restart recovery. Commit cleanup and crash recovery are unchanged residuals.

Validation: strict Swift 6 App/Keyboard test run succeeded on Xcode-beta, iOS Simulator `36BAABED-6846-4F9A-A672-6884B54CF50E`: UniverseKeyboardTests 301 executed, 4 skipped, zero failures; KeyboardTests 11, zero failures. Log: `/private/tmp/uk-p4-double-failure-test.log`. Changed production/coexistence Swift strict-format and diff whitespace checks passed. The separately added manager regression is recorded after its run completes.

Supplementary manager suite: 62 tests passed, zero failures, including `testIncompleteRollbackStopsWithoutRedeployingOriginalSchema`; log `/private/tmp/uk-p4-manager-test.log`. Manager test strict-format passed. No production changes followed the full App/Keyboard run.

No new full Core/Bridge suites or standalone Release build were run for this App-only correction. No device failure injection, independent delta review, commit, push, merge or TestFlight action. Historical limited Product Gate does not accept this changed revision.
