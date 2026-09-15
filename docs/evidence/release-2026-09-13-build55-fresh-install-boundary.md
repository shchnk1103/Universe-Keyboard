# RELEASE-2026-0801-04 — Build 55 全新安装边界回执

> **Run ID:** `RELEASE-2026-0801-04-B55-FRESH-INSTALL-20260913`
> **Status:** `In progress — app uninstall/reinstall, J1/J2/J3, Luna 26-key J4 and scoped 雾凇 nine-key gate observed; clean shared-container boundary pending`
> **Evidence grade:** `Executor-recorded` for install state; `Device-attested` for first-launch, J1, J2, J3, J4 and nine-key gate observations
> **Collected:** `2026-09-13 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Product source:** [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)

## Scope、authority 与 non-claims

Human Product Owner 明确批准进入“全新安装边界”。本轮只针对同一台 iPhone 13 Pro 上的
`com.DoubleShy0N.Universe-Keyboard` 执行卸载、安装和首次打开观察；未操作其他 App，未修改代码、提交、推送、上传或分发。

本轮验证的是 **App 安装生命周期、首次引导入口与首次输入前置状态**，不把系统卸载自动提供的状态扩大为 App Group、RIME 或用户词典的清空证明。
未读取或手工删除 App Group 内容；因此“全新 App Group / 全新 RIME 状态”仍为 `UNKNOWN`，也未形成完整共享状态、全新激活或 Release 结论。

## Frozen candidate and environment

| Boundary | Recorded value |
|---|---|
| Source | `main` @ `b8175129f26f787a6c7fee0be5977ebec46edf60` |
| Xcode Cloud | `Archive Pilot (No Distribution)` Build `55`; Build ID `8ca1634e-9139-405a-aa5c-75c3d6919908` |
| Version/build | `1.0 (55)` |
| App / Keyboard bundle | `com.DoubleShy0N.Universe-Keyboard` / `com.DoubleShy0N.Universe-Keyboard.Keyboard` |
| App executable UUID | `6898B44F-EF4F-3B46-93C8-BCE83668270A` |
| Keyboard executable UUID | `C6C1758B-ECA2-3784-8EFA-22AF59B6CF25` |
| Device | Physical iPhone 13 Pro (`iPhone14,2`), iOS `27.0 (24A435)` |
| Install artifact | Locally retained Ad Hoc extracted `.app`; App executable SHA-256 `2a63c53a656ec5e5ccb8307f45c095b4bb26773cc45c94c1af0df53a9f3b1609`; Keyboard executable SHA-256 `3ae37666bcba90e3cceb92683a673da20ba06ae86a7c16c31f720754f6033bff` |
| Artifact note | Current retained outer IPA SHA-256 `ec02dc4a959549d6ba2b36224a405740b4eeb7ca2cfbcdcbab5b0932ae069ebc`; the earlier replacement receipt recorded `de5b9b355f87af094b669f2548fb2811e8c1cf529dc551276dda8128b0ef8152`. The current install is bound by `1.0 (55)`, bundle IDs and matching executable UUIDs; ZIP-hash continuity is not claimed. |

## Install lifecycle observations

| Phase | Observation | Evidence |
|---|---|---|
| Preflight | Target App was installed as `1.0 (55)`; Keyboard Extension was the only matching product process observed (`PID 10951`) | Read-only device query before uninstall |
| Uninstall | `devicectl device uninstall app` returned success for exactly `com.DoubleShy0N.Universe-Keyboard` | `uninstall-20260913.json` |
| Post-uninstall | Target App listing was empty and the Keyboard process listing was empty | `post-uninstall-apps-20260913.json`, `post-uninstall-processes-20260913.json` |
| Install | `devicectl device install app` returned success for the selected Ad Hoc `.app` | `install-20260913.json` |
| Post-install identity | Device listed only the target App at version `1.0`, Bundle Version `55`; no product process was running before first launch | `post-install-apps-20260913.json`, `post-install-processes-20260913.json` |

The uninstall/reinstall sequence establishes a fresh **installed-App boundary** for this run. It does not establish that the shared App Group container or its contents were removed, because those contents were intentionally not inspected or manually reset.

## First-launch human observation

After reinstall, Human Product Owner opened the main App and reported:

> 首次引导页是引导打开系统设置添加我们的键盘。

This matches the documented fresh-install acceptance scenario: “Fresh install → Guide shows add-keyboard as next step; Settings limitation is visible.” The result is therefore:

| Claim | Result |
|---|---|
| First launch presents the add-keyboard next step | `Observed — Device-attested` |
| J1 — Universe Keyboard has been added in system Settings | `Observed — Device-attested; Human reported 已添加` |
| Full Access / J2 | `Observed — Device-attested; Human reported 完全访问已开启` |
| Main-App deployment / J3 | `Observed — Device-attested; initial Luna preflight showed 已部署 automatically; later 雾凇 deployment is recorded in the scoped gate` |
| First input / J4 | `Observed — Device-attested; Human reported default Luna with 26-key layout can output normally; no 9-key scheme claim` |
| Nine-key / 雾凇 gate | `Pass — Device-attested; download/deploy, selection, candidates and commit normal; sound present; no degradation prompt` |
| Clean App Group / RIME / user dictionary state | `UNKNOWN — not read or reset` |
| Full fresh-install activation boundary | `Not closed` |

## J3 resource preflight

Human Product Owner initially reported that the resource view showed built-in Luna as the default, while 雾凇 and 万象 were
available as downloadable schemes and were not downloaded at that point. Human then clarified that the main App already showed
the RIME resource state as `已部署`; no manual deployment tap was made during that initial preflight. A later separately
authorized nine-key gate downloaded and deployed 雾凇 successfully; its result is recorded below.

The `已部署` display is a Device-attested main-App state and is sufficient to record J3 as completed for this progress run. It is not an independent App Group readback or runtime-input proof. The documented J3 condition remains bounded by an installed active schema, successful main-App deployment, and no failed/in-progress deployment state.

## J4 first input

Human Product Owner reported that the default Luna scheme can output normally with the 26-key keyboard. This is valid
Device-attested evidence for the documented “any content” first-input path. Because 雾凇 and 万象 were not downloaded at that
preflight stage, the numeric nine-key smoke was not applicable to that stage; the later 雾凇 nine-key result is recorded separately.

## 雾凇九宫格真机 gate

The separately authorized Build 55 gate downloaded and deployed 雾凇 successfully. Human reported that Universe Keyboard
remained selected, nine-key candidates appeared and committed normally, sound was present, and no degradation prompt appeared.
Haptics were reported off in this arm because they require Full Access; this supplementary observation does not fail the scoped
nine-key gate. Full receipt: [`Build 55 雾凇九宫格真机 Gate`](release-2026-09-13-build55-rime-ice-nine-key-gate.md).

## Controlled artifacts

Controlled evidence archive root:
`evidence/release-2026-0801-04-build55/2026-09-13/raw/fresh-install/`

| Artifact | SHA-256 |
|---|---|
| `uninstall-20260913.json` | `adb8f2406371d2278a0814384335800f99e13004d75188ba2ac855b87e4efca3` |
| `post-uninstall-apps-20260913.json` | `0caafad64efafd27f874932bcd247fcf6e443951d56725bbb4cbfea074d380b4` |
| `post-uninstall-processes-20260913.json` | `b7065fa55ee79cf30db323bc9593fe612c2215bced09df804962a8e6db7bce0d` |
| `install-20260913.json` | `36e926a854e74aed74ddff10de46e24238574b13bdc085279576b6ad46ef67f4` |
| `post-install-apps-20260913.json` | `8a45201fbd0e1dc252758a89451311daaff4ea8b184197ac0f55cfe73b6c4a8c` |
| `post-install-processes-20260913.json` | `b7065fa55ee79cf30db323bc9593fe612c2215bced09df804962a8e6db7bce0d` |

The archived JSON is filtered to remove command arguments and device identifiers. No typed content, candidate content or App Group file content is retained.

## Handoff and next action

This run has produced a valid partial fresh-install receipt: the target App was removed, Build 55 was reinstalled, the first-launch add-keyboard guide was observed, Human confirmed J1 and J2 completed, the main App reported J3 already deployed during the initial preflight, default Luna produced normal 26-key output for J4, and the separately authorized 雾凇 nine-key gate passed. The clean shared-container state remains open; the overall physical/release gate is not closed.

The next KOS handoff is Product/Quality review of the remaining physical evidence and clean App Group / shared-container boundary.
No additional scheme download is required for the authorized nine-key gate.
