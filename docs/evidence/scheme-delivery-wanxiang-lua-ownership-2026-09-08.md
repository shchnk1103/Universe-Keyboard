# Wanxiang exact-hash Lua ownership staging tests

Date: 2026-09-08 (Asia/Shanghai). Isolation checkout `/private/tmp/uk-scheme-delivery-fix`, branch `codex/scheme-delivery-fix`, base `bf9de51` plus existing uncommitted WIP. Human authorized this slice only: unit tests + evidence for pinned CNB Wanxiang 17.5.9 Lua exact-ownership staging. **Local commit authorized later in split; still no push, undraft/merge of PR #100, ADR 0034 Accept, or TestFlight.**

## What was tested

Production helper `matchingWanxiangLuaPaths` (in `SchemaArchiveInstaller.stageSchemaUninstall`) only runs when `plan.schemaFileName == "wanxiang.schema.yaml"` and `plan.revision == "wanxiang-plan-1"`. It stages a mapped relative path only when the live file exists, is not a symlink out of the standardized path (`resolvingSymlinksInPath` equals standardized path), and SHA-256 equals the pin in `WanxiangLuaOwnership.sha256ByPath`.

Pin context:

- Archive SHA-256: `9bfcf60e62d85dd168cd2748e5b2d126fcb3355939969eb80455ba71cbf67732`
- Positive match fixture: empty `lua/data/chaifen.txt` (map SHA `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`)
- Optional second match: extracted `lua/wanxiang/bit.lua` from `/private/tmp/rime-wanxiang-1759/extract` when present (map SHA `7dedb1ed31a31c2c254fcf26a23e77fc428ebeaa091336f2545cb5d5fc4f03ca`)

## Non-claims

- Not full Wanxiang P4 closure / upgrade-uninstall contract complete
- Not upgrade rollback or mid-install generation restore
- Not digest-cleaning-as-policy or a general ownership receipt for future/user files
- Not Product Gate extension; not ADR 0034 Accept; not PR #100 undraft/merge; not TestFlight
- Comment on `WanxiangLuaOwnership` remains authoritative: unknown/edited files stay untouched

## Test names (file)

`UniverseKeyboardTests/SchemeResourcePreparationCoexistenceTests.swift`:

1. `testWanxiangExactHashLuaMatchIsStagedOnUninstall`
2. `testWanxiangModifiedLuaBytesAreNotStaged`
3. `testWanxiangUnknownLuaPathIsLeftInPlaceOnUninstallCommit`
4. `testWanxiangSymlinkAtMappedLuaPathIsNotStaged`
5. `testIceUninstallDoesNotStageWanxiangExactHashLuaPaths`

## Validation

Command style (same as prior P4): Xcode-beta, Swift 6 strict concurrency, DerivedData `/private/tmp/uk-scheme-takeover-derived`, simulator `36BAABED-6846-4F9A-A672-6884B54CF50E`. Focused filter on the five names above. Log: `/private/tmp/uk-wanxiang-lua-ownership-test.log`.

Changed Swift: `swift-format` (Xcode-beta toolchain) + `git diff --check` on the coexistence test file.

## Result

**Pass.** Focused filter executed **5** tests, **0** failures, **0** unexpected, **0** skipped (symlink creation supported on this simulator FS).

| Test | Result |
|---|---|
| `testWanxiangExactHashLuaMatchIsStagedOnUninstall` | passed |
| `testWanxiangModifiedLuaBytesAreNotStaged` | passed |
| `testWanxiangUnknownLuaPathIsLeftInPlaceOnUninstallCommit` | passed |
| `testWanxiangSymlinkAtMappedLuaPathIsNotStaged` | passed |
| `testIceUninstallDoesNotStageWanxiangExactHashLuaPaths` | passed |

Log: `/private/tmp/uk-wanxiang-lua-ownership-test.log`. xcresult under `/tmp/uk-scheme-takeover-derived/Logs/Test/`. Xcode-beta 27.0 (27A5252f), simulator `36BAABED-6846-4F9A-A672-6884B54CF50E`, DerivedData `/private/tmp/uk-scheme-takeover-derived`, `SWIFT_VERSION=6.0` + `SWIFT_STRICT_CONCURRENCY=complete` + `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`. Changed coexistence Swift: `swift-format` + `git diff --check` clean before the run.

Match coverage used empty `lua/data/chaifen.txt` and extracted `lua/wanxiang/bit.lua` from `/private/tmp/rime-wanxiang-1759/extract`. Unknown path coverage used `lua/user_custom.lua` and Ice-style `lua/date_translator.lua`; commit left both in place while removing the matched chaifen file. Ice scope guard confirmed Wanxiang map paths are not staged under the Ice plan.

Still uncommitted; no push/merge/undraft/ADR Accept/TestFlight.
