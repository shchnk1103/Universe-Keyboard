# Assignment: SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001 — CS09-10-02 真机路由与耗时验证

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current Phase | CS09-10-02 功能性观察已通过独立 Quality 复审；candidate 含 docs tip `a007681`（工程 tip `33b35d3`）；Human 已授权 **docs sync + hosted CI 全绿后** undraft+merge PR #100；Release / Product Gate 仍未授权 |
| Material non-claims | 不把 `RTRD-01`/`RTRD-02` 塞进本 PR；不因 merge 关闭 `RTRD-01`/`RTRD-02`；不声称 TestFlight、Release、Product Gate Passed 或 ADR Accept；本 Assignment 不因 CI 绿或 merge 自动 Closed |
| Next handoff / decision | Human 已授权：docs tip + hosted CI 全绿后 undraft+merge #100。`RTRD-01`（诊断 UI）与 `RTRD-02`（耗时对照）仍需另开 Assignment；Product Gate / TestFlight / Release 另案 |
| Residuals | `RTRD-01` 当前诊断列表只展示 code/时间，未渲染 runtime-route 的结构化字段；`RTRD-02` 普通 Luna 与 fallback 的耗时暂无获得 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in-session approval “批准真机验证”，`2026-09-09 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

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

`RTRD-01` — **Owner:** Main App UI / Diagnostics; **Disposition:** `fix`。

当前 `DiagnosticsEventDisplayFormatter` 会显示 `schemeDeliveryPayload` 与
`rimeSyncPayload`，但未显示 `runtimeRoutePayload`。诊断列表因而只能证明
`runtime_route.phase_changed` 已写入，不能让 Device Operator 核验 operation UUID、
phase/result、schema/layout/state 或 monotonic `elapsed_ms`。

后续独立的诊断 UI Assignment 应在点击某条日志时，于页面底部弹出详情窗口，且仅展示
现有 finite runtime-route 字段；不展示用户输入、候选文字、宿主内容、文件路径、URL 或
异常原文。该改进不属于本次真机验证，也不改变 journal 存储、RIME 路由或部署行为。
Implementation: [`SCHEME-DELIVERY-RUNTIME-ROUTE-DIAGNOSTICS-UI-001`](scheme-delivery-runtime-route-diagnostics-ui-001.md) (`Active`).

`RTRD-02` — **Owner:** Main App UI / Diagnostics; **Disposition:** `fix`。

本轮诊断页确认写入十条 `runtime_route.phase_changed` code，但其列表/复制输出没有
展开 payload。CoreDevice 无法列出单个 App Group JSONL 文件；读取整个诊断目录的操作
会超出本轮最小数据边界，因此没有执行。普通 Luna deployment 的可比较 `elapsed_ms`
也没有可见来源。本轮将部署耗时标记为“暂无获得”，不推断性能回归是否已修复。

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
- `2026-09-09 Asia/Shanghai`: Human Product Owner authorized undraft+merge of PR #100 after docs sync (tip includes `a007681`) + hosted CI green. `RTRD-01`/`RTRD-02` remain out of this PR and are not closed by merge; Product Gate / TestFlight / Release / ADR Accept remain unauthorized.
