# Product Decision: CANDIDATE-BAR-IDLE-DISMISS-001 — Human Product Gate

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE",
  "record_type": "decision",
  "title": "Accept CANDIDATE-BAR-IDLE-DISMISS-001 idle candidate-bar dismiss",
  "status": "accepted",
  "updated_at": "2026-09-28T22:10:55+08:00",
  "revalidation_triggers": ["scope_changed", "idle_dismiss_contract_changed"],
  "parent_refs": ["CANDIDATE-BAR-IDLE-DISMISS-001", "PD-CANDIDATE-BAR-IDLE-DISMISS-001"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "In-session 2026-09-28 Asia/Shanghai explicit Product Gate authorization: 接受残差，授权 Product Gate。",
    "scope": "Human Product Gate for dual-mode trailing candidate-bar expand/dismiss. Accept Quality residuals including deferred CBID-CORNER. Close the Assignment.",
    "outcome": "Human Product Gate passed with accepted evidence conditions; Assignment Closed; publication, release, and corner-bleed follow-up remain unauthorized",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE`
- **Lifecycle status:** `Accepted`
- **Date / timezone:** `2026-09-28 Asia/Shanghai`
- **Assignment:** [`CANDIDATE-BAR-IDLE-DISMISS-001`](../assignments/candidate-bar-idle-dismiss-001.md) — **Closed**
- **Authorization:** [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-PRODUCT-GATE.md)
- **Contract source:** [`PD-CANDIDATE-BAR-IDLE-DISMISS-001`](CANDIDATE-BAR-IDLE-DISMISS-001-authorization.md)
- **Quality:** [`candidate-bar-idle-dismiss-001-quality-review.md`](../reviews/candidate-bar-idle-dismiss-001-quality-review.md) — Pass with conditions

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Phase | Human Product Gate **Passed with accepted evidence conditions**；Assignment `Closed` |
| Evidence | PR [#190](https://github.com/shchnk1103/Universe-Keyboard/pull/190) squash `944a76bd049d717dd1048a6b4eb5bc7fd9124347`; `CandidateBarView.swift` SHA-256 `606b5553c14f86f1963116b977bcb5ccb905e9c64515273a581f98a74fab95de`; independent Quality App + Keyboard `UniverseKeyboardTests 410 / 10 skipped`, `KeyboardTests 16`; hosted same-head run [36434767922](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/36434767922) |
| Non-claims | Not Device-attested; not commit / push / PR / merge / TestFlight / App Store Connect / Release; not the rounded-corner follow-up |
| Next | None for this Assignment. Commit remains separately authorized. Rounded-corner host bleed (`CBID-CORNER`) starts only after Close, as a new work item. |

## Decision

Human Product Owner accepted the idle dismiss Product Gate for the locked contract:

- 全布局复用现有右侧键
- 有可展开内容（含联想）时 `chevron.down` 展开
- 空闲 `chevron.down.circle` 调用 `dismissKeyboard()`，template 无 Configuration 白盘
- 下滑只展开、不关闭
- VoiceOver 随模式换词

The accepted evidence is bounded to:

1. Isolated dirty tree (`CandidateBarView.swift` SHA-256 `606b5553…`). There is no implementation commit.
2. Independent Quality Pass with conditions, including independently re-run App + Keyboard Debug **TEST SUCCEEDED** on iPhone 17 (`UniverseKeyboardTests` 410 executed, 10 skipped; `KeyboardTests` 16).
3. Human in-session Simulator glance that dismiss worked and the idle-icon white plate was gone, plus residual acceptance: 「接受残差，授权 Product Gate。」 Human-attested, not Device-attested.

## Accepted residuals and boundaries

| Residual | Gate disposition |
|---|---|
| `CBID-01` — no frozen implementation SHA / dirty-tree identity | `accept` — Product Gate binds the Quality-pinned working-tree SHA-256; commit remains unauthorized |
| `CBID-02` — Quality lane did not re-open Simulator | `accept` — Human-attested Simulator glance plus residual acceptance is sufficient |
| `CBID-03` — source-contract tests | `accept` — existing Quality disposition |
| `CBID-04` — swipe and tap share the trailing selector | `accept` — expand vs dismiss still gated by `allowsSwipeToExpand` / `expandsCandidateBarPanel` |
| `CBID-CORNER` — light-mode top-left/right rounded-corner host bleed | `accept` — pre-existing; keep current; **new work item only after this Assignment is Closed** |

This Gate closes only the **idle trailing-button dismiss product acceptance**. It does
not authorize commit, push, PR, merge, TestFlight, App Store, Release, or the
rounded-corner follow-up.
