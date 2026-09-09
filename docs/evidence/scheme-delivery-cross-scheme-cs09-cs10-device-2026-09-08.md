# Evidence: Cross-scheme CS09-10-02 device/runtime observation

Date: 2026-09-08 Asia/Shanghai
Evidence grade: **Human-attested; failing device observation**
Checkout built by operator: `/private/tmp/uk-scheme-delivery-fix` on
`codex/scheme-delivery-fix`

## Result

`CS09-10-02` is **not passed**. In both directions, active-scheme uninstall
reported Luna selection and completed deployment in the main App, but entering
`ni` in the Keyboard Extension did not produce a Chinese candidate. Selecting
and deploying the retained downloaded scheme afterwards did produce the
expected Chinese candidate.

| Direction | Main-App result | Extension result | Retained scheme result |
|---|---|---|---|
| Ice → Wanxiang | Ice uninstall selected and deployed Luna | `ni` had no Chinese candidate | Selecting/deploying Wanxiang produced candidates |
| Wanxiang → Ice | Wanxiang uninstall selected and deployed Luna | `ni` had no Chinese candidate | Selecting/deploying Ice produced candidates |

The operator also observed that active-scheme uninstall takes visibly longer
than ordinary scheme operations. This is an observation, not a measured
performance regression: the active path intentionally waits for a full Luna
deployment before staging target removal. No operation-correlated duration
record was available in the current diagnostics.

## Available diagnostics

The supplied log shows a complete `scheme_delivery` download/install/deploy
sequence for an Ice operation (`operation=103dfcec-0d84-4964-ac10-7b9bfc84b58d`)
and later Extension `presentation.appeared` records. It does not contain an
operation-correlated active-uninstall / Luna-fallback sequence. The absence is
not proof that no producer ran: the current UI may show a bounded window, and
active uninstall is not yet emitted through the same structured delivery
payload as the download path.

## Consequence and boundary

This evidence invalidates the prior automated-only claim that successful Luna
deployment makes the active-uninstall fallback usable. It does not identify a
device-only RIME fault: the current static analysis has a concrete stale-route
hypothesis recorded in the accompanying
[route-reconciliation proposal](../plans/scheme-delivery-active-uninstall-runtime-route-reconciliation-2026-09-08.md).

No user input, candidate text, App Group file contents, archive provenance,
Product Gate, PR merge, TestFlight, App Release, or ADR acceptance is claimed.
