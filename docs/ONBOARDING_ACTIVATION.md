# Onboarding Activation And Full Access Journey

> **Status:** Active product source for new-user activation and Full Access degradation presentation
> **Decision source (semantics):** [`PD-RELEASE-2026-0801-03`](product-decisions/RELEASE-2026-0801-03-activation-authorization.md)
> **Decision source (Help / soft first-run / TipKit packaging):** [`PD-HELP-TIPKIT-001`](product-decisions/HELP-TIPKIT-001-authorization.md)
> **Assignment (semantics V1):** [`RELEASE-2026-0801-03`](assignments/release-2026-08-01-03-onboarding-full-access.md) (`Closed`)
> **Assignment (presentation):** [`HELP-TIPKIT-001`](assignments/help-tipkit-001.md)
> **Architecture boundaries:** ADR 0007, ADR 0008, ADR 0001, ADR 0003
> **Related debt:** TD-004

This document owns the user journey, copy boundaries and capability matrix for activation. Implementation may present these semantics in Help, Settings recovery surfaces or TipKit, but must not invent competing product meaning. Presentation packaging (soft Welcome, Help tab visibility, Settings entry, TipKit phase) is authorized by `PD-HELP-TIPKIT-001`.

## Activation Definition

| Outcome | Meaning |
|---|---|
| Full recommended activation | Keyboard added, Full Access allowed, main-App RIME resources ready, first successful Chinese input verified |
| Minimum degraded success | Keyboard added; basic local typing may work without Full Access; complete shared RIME features must not be claimed |

First-input smoke example for V1: type `nihao`, confirm candidates appear, commit with Space or tap.

## Journey

### J0 — Welcome

- One-screen value: local RIME Chinese input; keystrokes are not uploaded.
- Primary CTA enters the checklist (Help surface, focus next step). Skip is allowed.
- **Presentation (`PD-HELP-TIPKIT-001`):** soft, skippable Welcome on first main-App open only; does not block Home; Welcome-seen is not activation success. Re-read after completion uses Help, not forced re-Welcome every launch.

### J1 — Add keyboard

1. Open Settings
2. General → Keyboard → Keyboards
3. Add New Keyboard
4. Choose **Universe Keyboard**
5. Return to the App

App limitation copy is mandatory: the App cannot add the keyboard for the user.

### J2 — Allow Full Access

1. Settings → General → Keyboard → Keyboards
2. Tap **Universe Keyboard**
3. Enable **Allow Full Access**
4. Confirm the system warning
5. Return to the App

Users may defer. Deferral keeps Full Access incomplete, advances the guide through J3 and J4,
then returns J2 as the final outstanding step. Deferred state must describe degraded complete
capabilities, not blocked basic typing.

### J3 — Prepare input resources

Main App owns deployment (ADR 0001). Extension never deploys.

**Presentation (`PD-HELP-J3-RESOURCES-001`):** Help embeds a **slim** prepare panel (not a full RIME settings clone):

1. Recommend **雾凇** (`rime_ice`); user must tap to select (no auto-download).
2. Downloadable open-source schemes require **view + accept license** before download (same gate as Settings).
3. Builtin **朙月** may be selected without a download license gate.
4. User-triggered install/deploy via main-App store APIs.
5. Full scheme management remains under Settings.

**J3 complete when all hold:** active schema is installed, main-App deployment succeeded, and deploy is not failed/in-progress.

### J4 — First successful input

Presentation (`PD-APP-SEARCH-001`): primary path uses the main-App **搜索** tab text field.

1. Open the Search tab field (Help CTA may switch tab and focus it)
2. Globe key → Universe Keyboard
3. Type **any content** the user chooses (settings names or free text are both fine; `nihao` / 「你好」 remain optional examples only)
4. Commit if using candidates as usual
5. Return and affirm success in Help (V1 remains user affirmation)

### J5 — Complete

Short confirmation, links to privacy and scheme settings, advanced diagnostics collapsed by default.

## State Model

| Key | Allowed values | Authority |
|---|---|---|
| Keyboard added | `unknown`, `userAffirmed` | User affirmation only unless a future reliable signal exists |
| Full Access | `unknown`, `userAffirmed`, `sharedDataUnavailable`, `sharedCapabilityOK` | Observation overrides affirmation |
| Full Access deferred | bool | Presentation order only; never evidence that Full Access is enabled |
| RIME ready | `notReady`, `preparing`, `ready`, `failed` | Main-App deployment state |
| First input | `no`, `userAffirmedSuccess` | User affirmation for V1 |
| Guide dismissed / Welcome seen | bool | User preference only; does not equal activation success |
| Help tab visible | derived | See [Help information architecture](#help-information-architecture) |

Rules:

1. Default next-step order is J1 → J2 → J3 → J4.
2. If the user defers incomplete J2, the presentation order becomes J1 → J3 → J4 → J2;
   J2 remains incomplete throughout and full activation cannot be claimed.
3. `sharedDataUnavailable` overrides deferral and must reopen J2 recovery immediately, even if
   the user previously affirmed Full Access.
4. `rimeReady=ready` must not be presented as complete success while shared data is unavailable.
5. The main App must not claim a live Extension Full Access flag before observation.

## Canonical Copy

| ID | Text |
|---|---|
| C1 | 本地 RIME 中文输入，在设备上完成。 |
| C2 | 输入内容、候选与上下文不会上传给开发者。 |
| C3 | 「允许完全访问」用于访问主 App 与键盘共享的本地数据（方案、设置、本地学习等）。 |
| C4 | 不用于把按键发送到服务器，也不用于广告跟踪。 |
| C5 | 系统不允许 App 代替你添加键盘或打开完全访问，需要你在「设置」中完成。 |
| C6 | 未开启完全访问时，基本输入通常仍可用；共享反馈（如按键震动）及其他共享功能可能不可用或不可靠，完整体验不保证。 |
| C7 | 输入方案由主 App 准备；键盘扩展不会在输入时自行部署。 |
| C8 | 若候选异常有限，可能处于安全降级模式，不代表所选方案已完全就绪。 |
| C9 | 主 App 无法在键盘运行前始终得知完全访问的实时状态；请以实际能否使用共享功能为准。 |

### Forbidden patterns

- “一键开启输入法”
- “必须开启完全访问才能打字”
- Claiming Full Access is on without observation or explicit weak user affirmation labeled as such
- Implying keystroke upload, ads or tracking
- Treating fallback candidates as proof the selected scheme is healthy
- Making diagnostics the primary new-user path

## Full Access Capability Matrix

### Design intent (ADR 0007 contract)

| Capability | Full Access off | Full Access on, resources not ready | Full Access on, resources ready |
|---|---|---|---|
| Basic local key insertion | Available when Extension can still insert text | Available | Available |
| Real RIME candidates / selected scheme | Treat as **at risk / may degrade** (do not guarantee parity) | Degraded / not ready | Expected available |
| Shared feedback prefs (haptic / click enable sync) | Expect unavailable or defaults | May be incomplete | Expected available |
| Other shared settings | Treat as at risk; do not claim live Extension state from main App alone | Incomplete until verified | Expected available |
| User-dictionary learning | At risk / may be unavailable | Unavailable until runtime healthy | Expected available |
| Diagnostics persistence | At risk | May fail until container healthy | Available when enabled |
| Typing Intelligence aggregates | Unavailable / paused (out of V1.0 launch claims) | Unavailable until enabled + healthy store | Available only if user enables |
| Optional RIME sync | Main-App only | Main-App only | Main-App only; never Extension input path |
| Scheme download/deploy | Main-App may fail if container missing | Preparing / failed / ready | Ready |

### Observed on device (does not rewrite ADR 0007)

Source: [`evidence/release-2026-08-01-03-physical-device-fa-matrix.md`](evidence/release-2026-08-01-03-physical-device-fa-matrix.md) — iPhone 13 Pro / iOS 27.0 beta 3 / 雾凇已部署 / `feature/release-2026-08-01-03-onboarding`.

| Capability | FA off (observed) | FA on (observed) |
|---|---|---|
| Basic input + `nihao` candidates | Available; **same as FA on** in this run | Available |
| Main-App setting reflection (operator) | Reported yes | Yes |
| Key haptic feedback | **Absent** | **Present** |
| Explicit degradation UI | None | n/a |

**Product implication:** Do **not** tell users that Chinese input is impossible without Full Access. Do tell them Full Access is required for reliable shared feedback (and potentially other shared features), and that complete/shared behavior is not guaranteed without it. A matrix-fidelity + Extension-visible recovery follow-up remains open (TD-004).

User-facing recovery:

- Off → explain C3–C6; emphasize feedback/shared reliability, not “cannot type Chinese”.
- On but not ready → explain C7 and offer main-App deploy/retry.
- Fallback-like limited candidates → C8 and reopen readiness checks.

## Help information architecture

Authorized by [`PD-HELP-TIPKIT-001`](product-decisions/HELP-TIPKIT-001-authorization.md).

### Surfaces

| Surface | Role |
|---|---|
| Soft Welcome (J0) | First open only; skippable; not a progress reset |
| Tab **帮助** | Primary activation checklist while incomplete or in recovery |
| Settings → 使用帮助 / 启用指南 | Permanent entry to the same Help / activation content |
| TipKit tips (optional phase) | Contextual one-action packaging of the same steps |

### Help tab visibility

Show the **帮助** tab when any of:

1. Recommended activation incomplete (`nextStep != nil`).
2. `fullAccess == sharedDataUnavailable`.
3. Resources recovery is actionable (deployment failed / not ready for complete experience under existing J3 authority).

When fully activated and healthy: **hide** the Help tab; users re-enter via Settings. If a recovery condition returns, **show the Help tab again**.

### Re-read policy（重新走一遍）

Users may re-open Help and re-read every activation step after completion. Default re-read **must not** clear checklist affirmations, observation flags, or main-App deployment readiness truth. A destructive “reset activation progress” control is **out of scope** unless a new Product Decision authorizes it.

### Content scope (this presentation track)

Activation steps only (J0–J5). Not a general product Tips Library (fuzzy pinyin, sync, dictionary tutorials, etc.).

## TipKit mapping

TipKit presents the same steps as contextual tips (main App; iOS 17+; implemented under `HELP-TIPKIT-001` P3 in `ActivationTips.swift`). Rules:

1. One tip teaches one action.
2. Invalidate when the corresponding checklist state completes (`ActivationTips.sync` → Tip `@Parameter`).
3. Do not put the full legal privacy policy inside a tip.
4. Activation remains main-App-owned; do not depend on Extension TipKit for the first-run path.
5. TipKit is optional packaging, not a second product contract.
6. **No TipKit (or equivalent tip UI) in the Keyboard Extension** under `PD-HELP-TIPKIT-001`.

| Tip | Surface (P3) | Invalidate when |
|---|---|---|
| Add keyboard | Help next-step | `addKeyboard` complete |
| Full Access | Help next-step | Full Access satisfied for progress |
| Prepare resources | Help next-step; Settings → RIME 方案设置 | Resources ready |
| First input | Help next-step; Home keyboard card when next | First input affirmed |

## Acceptance Scenarios

1. Fresh install → Guide shows add-keyboard as next step; Settings limitation is visible.
2. User defers Full Access → Guide advances to resources, then first input, then returns Full Access
   as the final incomplete step; basic typing remains described as possible and complete activation
   is not claimed.
3. User allows Full Access and deploys → readiness becomes actionable/ready.
4. First-input checklist can be affirmed after `nihao` smoke.
5. Shared-data failure copy appears when container/shared operations fail and overrides prior affirmation.
6. Accessibility: checklist steps and status values are readable by VoiceOver.
7. Physical device: Full Access off keeps basic typing usable; Full Access on restores shared capabilities without false active claims.

## Evidence Boundary

- Unit tests may prove checklist next-step logic and copy-state mapping.
- Simulator builds prove Guide compilation and navigation.
- Physical-device Full Access on/off remains required before Product Gate close and before claiming TD-004 resolved.
