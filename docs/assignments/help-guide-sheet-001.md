# Assignment: HELP-GUIDE-SHEET-001 — 引导 sheet 与设置「？」入口

**Policy version:** `1.0.0`
**Task ID:** `HELP-GUIDE-SHEET-001`
**Decision source / date:** [`PD-HELP-GUIDE-SHEET-001`](../product-decisions/HELP-GUIDE-SHEET-001-authorization.md), Human Product Owner F1–F3 lock, `2026-09-14 Asia/Shanghai`
**Predecessor:** [`HELP-TIPKIT-001`](help-tipkit-001.md) (`Completed` — previous presentation packaging)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | Human Product Gate Passed；展示包装验收关闭 |
| **Non-claims** | 不宣称 commit、push、TestFlight、Release；不宣称 F1/F2 真机已证明 |
| **Next** | 无（本 Assignment）。仓库落地需另授权、切开无关脏树后的 commit |
| **Residuals** | `HGS-01`–`HGS-05` accept；随 Gate 关闭，不阻塞 Close |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-HELP-GUIDE-SHEET-001`](../product-decisions/HELP-GUIDE-SHEET-001-authorization.md), `2026-09-14 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead
- **Authorization (record slice):** [`AUTH-HELP-GUIDE-SHEET-001`](../authorizations/AUTH-HELP-GUIDE-SHEET-001.md) — consumed; Decision/Assignment only
- **Authorization (implementation slice):** [`AUTH-HELP-GUIDE-SHEET-001-IMPLEMENT`](../authorizations/AUTH-HELP-GUIDE-SHEET-001-IMPLEMENT.md) — consumed (implementation delivered)
- **Authorization (Quality):** [`AUTH-HELP-GUIDE-SHEET-001-QUALITY`](../authorizations/AUTH-HELP-GUIDE-SHEET-001-QUALITY.md) — consumed
- **Authorization (Product Gate):** [`AUTH-HELP-GUIDE-SHEET-001-PRODUCT-GATE`](../authorizations/AUTH-HELP-GUIDE-SHEET-001-PRODUCT-GATE.md) — consumed
- **Product Gate:** [`PD-HELP-GUIDE-SHEET-001-PRODUCT-GATE`](../product-decisions/HELP-GUIDE-SHEET-001-product-gate.md) — Accepted

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | 本任务记录展示合同，不新增证据 claim。 |
| A-01 / B-01 authorization chain and briefing | Adopted | 本 Assignment、当前 Authorization receipt、Accepted Product Decision 构成本切片权威链。 |
| P-01 publication facts | Not applicable | 未授权 commit / push / PR / hosted CI。 |
| D-01 final-documentation receipt | Not applicable | 本切片无 final SHA 交接；普通 docs 检查不得称为 D-01 receipt。 |
| H-02 / W-01 | Not applicable | 超出已采用的 v0.8.0 范围。 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current docs-only record | Authorized | `record_help_guide_sheet_product_decision_and_assignment` for `HELP-GUIDE-SHEET-001` | Consumed [AUTH-HELP-GUIDE-SHEET-001](../authorizations/AUTH-HELP-GUIDE-SHEET-001.md) |
| Main-App implementation | Authorized | `implement_help_guide_sheet` delivered; Human accepted completed-manual replay | Consumed [AUTH-HELP-GUIDE-SHEET-001-IMPLEMENT](../authorizations/AUTH-HELP-GUIDE-SHEET-001-IMPLEMENT.md) |
| Independent Quality | Authorized | `independent_quality_review_help_guide_sheet` — Pass with conditions | [AUTH-HELP-GUIDE-SHEET-001-QUALITY](../authorizations/AUTH-HELP-GUIDE-SHEET-001-QUALITY.md) → [review](../reviews/help-guide-sheet-001-quality-review.md) |
| Human Product Gate | Authorized | `product_gate_and_close_help_guide_sheet` — Pass；Assignment Closed | Consumed [AUTH-HELP-GUIDE-SHEET-001-PRODUCT-GATE](../authorizations/AUTH-HELP-GUIDE-SHEET-001-PRODUCT-GATE.md) → [PD](../product-decisions/HELP-GUIDE-SHEET-001-product-gate.md) |
| Scoped commit | Authorized | `scoped_commit_help_guide_sheet` on feature branch; no push | [AUTH-HELP-GUIDE-SHEET-001-COMMIT](../authorizations/AUTH-HELP-GUIDE-SHEET-001-COMMIT.md) |
| Push / PR | Not authorized | | New Authorization required |
| Environment or external slice | Not applicable | 无 H-01 冻结载荷 run | 未完成路径 F1/F2 真机仍为 Human Dependency |

This is a manual advisory opt-in for A-01/B-01 only. This Assignment, its Authorization and its Product Decision are **not** Profile-included; validator coverage does not apply. Changing `.kos/project.json` requires a separate onboarding Assignment.

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** Current Grok session acting as App & Data Operations Maintainer / Main App UI
- **Environment Executor:** Current Grok session for Simulator / unit-test / build evidence **after** implementation is authorized; Human Product Owner for physical-device Full Access round-trip and first-run sheet resume (not required to keep this Assignment in `Ready`)
- **Human Dependency:** Human Product Owner — (1) implementation start instruction; (2) Product Gate on sheet + 「？」 + F1/F2/F3 behavior; (3) optional device evidence
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward — **Not Applicable** for presentation/IA that does not change App Group, FA observation model, privacy claims or activation success; **required** if implementation crosses those boundaries
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer — required before implementation close; **Not Applicable** to this docs-only record slice
- **Supporting Domain:** [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- **Handoff Target:** After implementation: Quality Reviewer, then Product Lead

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-09-14 Asia/Shanghai` — Human locked F1–F3 and instructed to record Decision + Assignment under KOS, no Swift.
- **Executor acknowledgement (record slice):** `2026-09-14 Asia/Shanghai` — Scope, Non-goals, Stop Conditions and F1–F3 accepted; activation semantics remain `ONBOARDING_ACTIVATION` / `PD-RELEASE-2026-0801-03`.
- **Executor acknowledgement (implementation):** `2026-09-14 Asia/Shanghai` — Human instructed 开始实施; AUTH-HELP-GUIDE-SHEET-001-IMPLEMENT recorded; avoid parallel Codex release-evidence docs.
- **Entry Criteria status:** **Met** for `Active` implementation slice.
- **Product lifecycle decision:** `Ready → Active` on Human instruction “请严格按照KOS设定开始实施吧”, `2026-09-14 Asia/Shanghai`.
- **Current phase:** Closed after Human Product Gate Pass.

## Boundary

### Scope

Authorize (and, **after a later implementation Authorization**, implement) main-App **presentation packaging** for the existing activation journey:

1. **Remove** the conditional **帮助** tab. Main `TabView` is fixed: 首页 | 设置 | 搜索 (Search remains far right).
2. **Single entry:** Settings navigation-bar **？** only (F3). Delete the Settings list row that currently opens Guide.
3. **One bottom sheet** for J0–J5. J0 is the first page of that sheet, not a separate Welcome that then switches tabs.
4. **First-run / resume (F1):** If recommended activation is incomplete or recovery holds, auto-present the sheet on **next main-App process launch**. Persist that the session should be offered; **do not** persist a step index as completion truth. Displayed step = `ActivationChecklistState.nextStep`. Optional `focusedStep` is scroll/expand memory only.
5. **Incomplete marker (F1):** **？** shows an incomplete/recovery marker (visual may be red; not color-only) while `nextStep != nil` or recovery holds.
6. **「稍后再说」(F2):** Allowed on the incomplete session. Disables accidental swipe-down; explicit defer dismisses the sheet for this process only. Next process launch auto-presents again; **？** remains tappable immediately.
7. **Re-read:** After healthy full activation, **？** uses the default appearance; sheet is user-initiated and dismissible; default re-read does not clear affirmations or deployment truth.
8. **J4:** Trial input field **inside the sheet**. Search tab is no longer the J4 primary path (`PD-APP-SEARCH-001` amendment).
9. **J3:** Keep the existing slim prepare panel inside the sheet (`PD-HELP-J3-RESOURCES-001` unchanged except carrier wording).
10. **TipKit:** Optional packaging; rebind surfaces from Help tab to the sheet when implementation is authorized. No Extension tips.
11. **Documentation:** Keep `ONBOARDING_ACTIVATION.md` presentation sections aligned with the authorized packaging. Do not invent competing journey semantics.

### Non-goals

- Changing activation success criteria, FA optionality, J2 deferral order, or capability matrix
- General feature Tips Library (fuzzy pinyin, sync, Lua/advanced input, haptics as new first-run steps)
- Keyboard Extension TipKit or any Extension tip UI
- Default 「重置启用进度」
- Hard lock with no 「稍后再说」
- Storing current-step as a second checklist
- Inventing a live Extension Full Access flag
- Closing TD-004
- App Store / TestFlight / commit / push / merge under this record slice
- Profile include / `required` mode

### Required Inputs

- [`PD-HELP-GUIDE-SHEET-001`](../product-decisions/HELP-GUIDE-SHEET-001-authorization.md)
- [`PD-HELP-TIPKIT-001`](../product-decisions/HELP-TIPKIT-001-authorization.md) (2026-09-14 amendment)
- [`PD-APP-SEARCH-001`](../product-decisions/APP-SEARCH-001-authorization.md) (2026-09-14 amendment)
- [`PD-RELEASE-2026-0801-03`](../product-decisions/RELEASE-2026-0801-03-activation-authorization.md)
- [`PD-HELP-J3-RESOURCES-001`](../product-decisions/HELP-J3-RESOURCES-001-authorization.md)
- [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)
- [`UI_STYLE_GUIDE.md`](../UI_STYLE_GUIDE.md)
- [`playbooks/main-app-ui.md`](../playbooks/main-app-ui.md)
- Existing: `GuideTab.swift`, `ActivationWelcomeView.swift`, `ActivationChecklistState.swift`, `ContentView.swift`, `SettingsTab.swift`, `ActivationChecklistStateTests`
- ADR 0001, 0003, 0007, 0008 (boundary only)

## Gates

### Entry Criteria

- [x] Product Decision `PD-HELP-GUIDE-SHEET-001` recorded with F1–F3 locked
- [x] `PD-HELP-TIPKIT-001` and `PD-APP-SEARCH-001` amended for current presentation rules
- [x] Domain Owner, Executor, Environment Executor, Human Dependency, Quality Reviewer named or justified
- [x] No required Assignment field is `UNKNOWN`
- [x] Activation semantics predecessor remains the single source for checklist truth
- [x] Executor acknowledgement on first **Active** (implementation) turn

### Exit Criteria

**Record slice (this turn)**

- Decision, Authorization, Assignment and presentation-source alignment exist and do not rewrite C1–C9 or FA optionality.

**Implementation**

- [x] No 帮助 tab. Tab order 首页 | 设置 | 搜索 (code + Human opened guide from Settings **？**).
- [x] Settings list Help row removed; toolbar **？** is the entry.
- [x] J4 trial field is in-sheet; Search remains settings search.
- [x] Completed re-read does not clear progress; 「从第一步开始」 replays J1–J4 as a manual. Human: 完全满足预期 ([observation](../evidence/help-guide-sheet-001-human-completed-manual-2026-09-14.md)).
- [x] Session-offer projection tests (`shouldMarkHelpEntryIncomplete` / `shouldOfferGuideSession`); Simulator App+Keyboard tests green (iPhone 17 Pro / iOS 26.0).
- [x] C1–C9 and FA optionality not rewritten.
- [ ] Fresh-install / incomplete F1 auto-present and kill-app resume — **not** Human-attested this round.
- [ ] F2 「稍后再说」 same-process vs next-launch — **not** Human-attested this round.
- [x] Independent Quality **Pass with conditions** — [`help-guide-sheet-001-quality-review.md`](../reviews/help-guide-sheet-001-quality-review.md); residuals `HGS-01`–`HGS-05` `accept`.
- [x] Human Product Gate for Assignment `Closed` — [`PD-HELP-GUIDE-SHEET-001-PRODUCT-GATE`](../product-decisions/HELP-GUIDE-SHEET-001-product-gate.md).

### Stop Conditions

Stop and escalate if:

- Implementation claims a live Extension Full Access flag from the main App alone
- Copy states that Full Access is required for basic Chinese typing
- Next-step order or success definition changes without amending `PD-RELEASE-2026-0801-03`
- Guide UI is placed in the Keyboard Extension
- 「重新走一遍」 silently resets progress
- 「稍后再说」 is implemented as activation success or as suppressing next-launch auto-present
- A stored step index overrides `nextStep`
- App Group / deployment ownership is altered
- Required evidence is fabricated

## Handoff

- **Required Handoff Content:**
  - Presentation: Settings toolbar **？**; no Help tab; one activation sheet; J0 first page when welcome unseen; incomplete sessions disable swipe-down and use 「稍后再说」 (process-local); next process launch auto-presents while `shouldOfferGuideSession`; **？** red + VoiceOver 启用未完成 when incomplete/recovery.
  - Re-read: completed manual; 「从第一步开始」 walks J1–J4 without writing new affirmations; 「查看下一步」 / 「回到说明书」.
  - Progress truth remains `ActivationChecklistState.nextStep`; replay cursor is presentation-only.
  - Simulator: `xcodebuild` scheme `Universe Keyboard` Debug test, destination `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0` (latest `name=iPhone 17 Pro` unmatched), `CODE_SIGNING_ALLOWED=NO` `SWIFT_VERSION=6.0` `SWIFT_STRICT_CONCURRENCY=complete` `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` — **TEST SUCCEEDED** (UniverseKeyboardTests 369 / 9 skipped; KeyboardTests 11). Not run: KeyboardCore-only, RimeBridgeTests, Debug/Release `build`.
  - Human observation: [completed-manual](../evidence/help-guide-sheet-001-human-completed-manual-2026-09-14.md).
  - C1–C9 / FA optionality unchanged.
  - Known gaps: F1 incomplete auto-present and F2 defer not device-attested; no frozen payload identity; dirty tree; Quality not started.
- **Primary files:** `ContentView.swift`, `SettingsTab.swift`, `GuideTab.swift`, `ActivationGuideSheet.swift`, `ActivationWelcomeView.swift`, `SearchTab.swift`, `ActivationChecklistState.swift`, `ActivationChecklistStateTests.swift`
- **Handoff Target:** Quality Reviewer (when authorized) → Product Lead (Human Product Gate)
- **Revalidation Trigger:** Activation state model change; FA/privacy matrix change; product request for progress-reset, Extension tips, or hard lock without defer; Help content expansion beyond activation steps; F1–F3 reversal

## History

- `2026-09-14 Asia/Shanghai` — Human locked F1–F3; record slice authorized; Assignment enters `Ready`; implementation not authorized.
- `2026-09-14 Asia/Shanghai` — Human authorized implementation; Assignment `Ready → Active`; AUTH-HELP-GUIDE-SHEET-001-IMPLEMENT.
- `2026-09-14 Asia/Shanghai` — Main-App sheet / Settings **？** landed. `xcodebuild` `Universe Keyboard` Debug test on iPhone 17 Pro / iOS 26.0 **TEST SUCCEEDED** (UniverseKeyboardTests 369, 9 skipped; KeyboardTests 11). Did not run KeyboardCore-only, RimeBridgeTests, or Debug/Release `build`. No commit.
- `2026-09-14 Asia/Shanghai` — Completed-manual 「从第一步开始」 added. Human Product Owner: 完全满足预期. Observation: [`help-guide-sheet-001-human-completed-manual-2026-09-14.md`](../evidence/help-guide-sheet-001-human-completed-manual-2026-09-14.md). Implementation AUTH consumed. Quality / Product Gate / commit not authorized.
- `2026-09-14 Asia/Shanghai` — Independent Quality **Pass with conditions** on dirty-tree presentation slice ([review](../reviews/help-guide-sheet-001-quality-review.md)). Residuals `HGS-01`–`HGS-05` accept. Product Gate / commit still not authorized.
- `2026-09-14 Asia/Shanghai` — Human Product Gate **Pass**（「通过」）；接受 `HGS-01`–`HGS-05`。Assignment **Closed**。Commit / push / TestFlight / Release 仍未授权。
- `2026-09-14 Asia/Shanghai` — Human authorized scoped commit ([`AUTH-HELP-GUIDE-SHEET-001-COMMIT`](../authorizations/AUTH-HELP-GUIDE-SHEET-001-COMMIT.md)); push still not authorized.
