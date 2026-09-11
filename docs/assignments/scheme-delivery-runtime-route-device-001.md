# Assignment: SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001 — CS09-10-02 真机路由与耗时验证

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed |
| Current Phase | Human closed this Assignment. CS09-10-02 functional Pass with conditions; `RTRD-01` fix glanced; `RTRD-02` accept |
| Material non-claims | Not Product Gate Passed, TestFlight, Release, or ADR Accept; not a performance comparison of Luna vs fallback |
| Next handoff / decision | None for this Assignment. Product Gate / TestFlight / Release remain separate |
| Residuals | `RTRD-01` `fix` (implemented + glanced); `RTRD-02` `accept` |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in-session approval “批准真机验证”，`2026-09-09 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead
- **Close Authorization:** [AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001-CLOSE](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001-CLOSE.md)

## Boundary

- **Scope:** 在单一、已连接的 iPhone 13 Pro 上安装当前冻结 Debug candidate；验证 Ice → Luna 与 Wanxiang → Luna 的 active-uninstall 后，Keyboard Extension 对 `ni` 是否出现中文候选；收集 Main App 中同 operation UUID 的 content-free route trace，并比较每次 fallback deploy 的 `elapsed_ms` 与一次普通 Luna deploy 的同字段。
- **Non-goals:** 不记录或导出用户输入、拼音、候选文字、宿主内容、文件路径或 App Group 内容；不改方案、持久化策略、RimeBridge/Extension、archive 所有权或 fallback policy；不发布或接受产品结论。
- **Required Inputs:** [集成 Assignment](scheme-delivery-runtime-route-integration-001.md)、[P1 final review](../reviews/scheme-delivery-runtime-route-integration-001-p1-final-independent-review.md)、[历史失败证据](../evidence/scheme-delivery-cross-scheme-cs09-cs10-device-2026-09-08.md)、当前冻结工作树与 iPhone 13 Pro `00008110-000A08440198801E`。

## Assignment

- **Domain Owner:** 📱 Main App UI — active-uninstall route transaction and Main-App diagnostics.
- **Executor:** Current Codex executor — construct/install candidate, capture content-free evidence and write factual record.
- **Environment Executor:** Current Codex executor — signed Debug build, physical-device install/launch and device-log collection only.
- **Human Dependency:** Human Device Operator — on-device setup, two ordered uninstall actions and the binary candidate-present/absent observation for `ni`; no text, candidate or screenshot is required.
- **Architecture Reviewer:** Not Applicable — this task validates an already independently reviewed transaction and introduces no design change.
- **Quality Reviewer:** Independent 🧪 Quality, Performance & Release Maintainer — read-only review of the completed evidence.

## Gates

- **Entry Criteria:** This Assignment has no `UNKNOWN` responsibility; Product authorization is recorded; the device is connected/paired; the candidate source is frozen before build; the operator keeps the device unlocked and can select the keyboard.
- **Exit Criteria:** Both active-uninstall directions have an operation-correlated structured trace and an explicit candidate-present/absent observation; a normal Luna deploy comparison trace is recorded if the existing UI exposes it; elapsed values are reported as observations only, with no invented regression threshold; evidence states exact source/build/device identity and privacy boundary.
- **Stop Conditions:** Device disconnects; signing/install changes an unexpected app identity; the operator cannot keep input content-free; diagnostics omit operation identity; a failure would require source changes, App Group/file inspection, resource deletion, or a policy change.

## Observability Follow-up

`RTRD-01` — **Owner:** Main App UI / Diagnostics; **Disposition:** `fix`（实现已合入；2026-09-11 glance 确认键可见）。

独立诊断 UI Assignment [`SCHEME-DELIVERY-RUNTIME-ROUTE-DIAGNOSTICS-UI-001`](scheme-delivery-runtime-route-diagnostics-ui-001.md) 已 **Closed**（#110）。[`KOS-SUG-OBS-GLANCE-001`](kos-sug-obs-glance-001.md) Human 报告七键与底部详情均为 `是`（Debug `36b63c7`）。2026-09-09 真机记录仍不包含 UUID/phase/elapsed **数值**；本残差不改写成 `accept`。SUG-08 仍未授权。Human 2026-09-11 closed this Assignment.

`RTRD-02` — **Owner:** Main App UI / Diagnostics; **Disposition:** `accept`。

[`SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001`](scheme-delivery-runtime-route-elapsed-001.md) **Closed**. Human 2026-09-11 accepted that ordinary Luna deploy does not emit `runtime_route.phase_changed`, so same-field `elapsed_ms` comparison is unavailable. No performance conclusion. No Swift in this slice.

## Handoff

- **Handoff Target:** Independent Quality reviewer, then Human Product Owner.
- **Required Handoff Content:** frozen source identity; build/install result; device/OS identity; each direction's operation UUID, phase/result and elapsed fields; binary candidate observation; normal-Luna comparison availability; explicit non-claims.
- **Revalidation Trigger:** any source/build/device/OS change, application reinstall after the frozen run, diagnostic schema change, or an additional manual input round.

## Evidence

- [2026-09-09 device record](../evidence/scheme-delivery-runtime-route-device-001-2026-09-09.md)
- [Quality review](../reviews/scheme-delivery-runtime-route-device-001-quality-review.md)

## History

- `2026-09-09 Asia/Shanghai`: Human Device Operator reported both active-uninstall directions switch to Luna and produce a normal Chinese candidate for the controlled `ni` input. Product Lead directed that elapsed evidence be recorded as unavailable rather than widening diagnostic-file access.
- `2026-09-09 Asia/Shanghai`: Independent Quality review returned Pass with conditions: functional CS09-10-02 Pass, no new P0/P1, and candidate push allowed. `RTRD-01` and `RTRD-02` remain `fix`; merge, Product Gate, TestFlight and Release remain unauthorized.
- `2026-09-09 Asia/Shanghai`: Human Product Owner directed docs-only Assignment sync; tip `33b35d3` hosted CI all green; no undraft/merge; `RTRD-01`/`RTRD-02` stay out of this PR.
- `2026-09-10 Asia/Shanghai`: RTRD-01 UI merged as PR #110 (`4e4164f`). This Assignment stays Active because `RTRD-02` remains `fix` and Product Gate is unauthorized. The 2026-09-09 device evidence is not restated as containing UUID/phase/elapsed.
- `2026-09-10 Asia/Shanghai`: Human authorized one diagnostics glance ([`KOS-SUG-OBS-GLANCE-001`](kos-sug-obs-glance-001.md)). No uninstall. This Assignment stays Active.
- `2026-09-11 Asia/Shanghai`: After Debug install, Human uninstalled one scheme and reported all seven allowlisted keys plus tap sheet. `RTRD-02` still `fix`. This Assignment stays Active.
- `2026-09-11 Asia/Shanghai`: Human accepted the RTRD-02 same-field gap (`accept`). Elapsed Assignment Closed. This Assignment stays Active; Product Gate unauthorized.
- `2026-09-11 Asia/Shanghai`: Human: “批准关闭 DEVICE-001”. Engineering Close. Not Product Gate.
- `2026-09-09 Asia/Shanghai`: Human Product Owner authorized undraft+merge of PR #100 after docs sync (tip includes `a007681`) + hosted CI green. `RTRD-01`/`RTRD-02` remain out of this PR and are not closed by merge; Product Gate / TestFlight / Release / ADR Accept remain unauthorized.
