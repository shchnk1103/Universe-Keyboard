# RIME-SYNC-001 UI-02 — 真机辅助功能补充观察（2026-09-24）

> **Status:** Supplemental human observation recorded; formal UI-02 disposition and independent Quality review remain open.
> **Evidence grade:** Executor-recorded build/install metadata; Human-attested accessibility outcome.
> **Assignment:** [`RIME-SYNC-001`](../assignments/rime-sync-001.md)

## Scope and result

本记录仅绑定一次 iPhone 13 Pro / iOS 27.0 上的 RIME 云同步设置页面辅助功能观察。Human Product Owner 报告：
“朗读和布局都正常，无异常。”观察对象为 VoiceOver 朗读与较大辅助功能文字下的页面布局。

这是一条补充人工观察，不是独立 Quality 结论，不关闭 `UI-02` 或 RIME-SYNC-001，也不证明自动同步、真机 Keychain、后台派发、provider 删除语义或 Release 状态。未提供截图或音频；本记录不推断 VoiceOver 对每个控件的逐项朗读结果。

## Built and installed artifact

| Boundary | Observed value |
|---|---|
| Source base | Isolated worktree `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`, HEAD `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Source state | Dirty worktree at build time (33 changed/untracked paths); no source files were edited for this observation. This is not a clean or committed source snapshot. |
| Tracked Swift diff digest | SHA-256 `8e21bc5e9317ee88c2ec98fcd0c2ad76cdf19bf8f48ed976543c4e510c76a71e` for `git diff --binary HEAD -- '*.swift'` |
| Additional untracked Swift inputs | `RimeSyncUITestFixture.swift`: `41550bf022f2d5b039b3b67a8afbf92cf62b1b9fc7b5c74b54d91834de251e99`; `RimeSyncSettingsUITests.swift`: `00678a1de9180c082d300649d478ee3cb21848941d9c9555dbc25f3831ffeeeb` |
| Build | Xcode `27.0 (27A266a)`; Debug; iOS SDK `27.0`; deployment target `18.0`; `MARKETING_VERSION=1.0`; command-line `CURRENT_PROJECT_VERSION=924` (local identifier only; project files unchanged) |
| App identity | `com.DoubleShy0N.Universe-Keyboard`, version `1.0 (924)`; host-built executable SHA-256 `15e3c2cd9934b8563dc8a36b8cf5f3356bb01823f9a20380a273fa0c68aec0a6` |
| Keyboard identity | `com.DoubleShy0N.Universe-Keyboard.Keyboard`, version `1.0 (924)`; host-built executable SHA-256 `c8b813958d5a9b17d4ae73ad188e4b80a01d57a7f6c05fcc975be04ea3ccc2c7` |
| Signing | Apple Development; Team `C33N6HTS9N`; App and extension code-signature verification passed; embedded development profile included the connected iPhone |
| Install | `devicectl device install app` succeeded without a preceding uninstall. Post-install device listing reported the target App as developer-built, version `1.0`, Bundle Version `924`. The installed executable bytes were not read back from the device. |
| Device | Physical iPhone 13 Pro (`iPhone14,2`), iOS `27.0`; device identifier intentionally omitted. |

## Evidence limits and side effects

- The source was a dirty worktree. HEAD plus the listed Swift digests and installed version identify this local test candidate, but do not constitute a frozen, reproducible full-source manifest.
- Build output hashes are host-side artifact digests, not an on-device executable readback.
- The Executor did not launch the App, trigger synchronization, change settings, uninstall, clear data, or inspect App Group contents. The human opened the App to perform the requested observation; this record does not establish whether opening it caused a foreground automatic-sync attempt.
- No control-action trace was collected. No synchronization outcome is claimed.
- No screenshot/audio was retained. This observation is not Quality-reverified and does not supersede the `2026-09-23` unbound observation or any formal natural-sync run.

## Handoff

The latest accessibility outcome is associated with the local `1.0 (924)` installation at the app-metadata level. `UI-02` remains open for the Assignment's independent Quality conclusion and any required disposition; Product lifecycle authority remains separate.
