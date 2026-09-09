# Evidence: SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001

Date: 2026-09-09 Asia/Shanghai
Evidence grade: **Device-attested functional result; executor-recorded device/build identity**

## Candidate and environment

| Field | Value |
|---|---|
| Source baseline | `f9060fc55264b66c2479592885d40690000b4e14` plus frozen working-tree diff SHA-256 `7234f6f8c777dcb2825c8abe02fe6954fbd9d4be15da3738172c0606b1ed0d6b` |
| Build | signed Debug, `Universe Keyboard` / `com.DoubleShy0N.Universe-Keyboard` |
| Device | wired iPhone 13 Pro (`iPhone14,2`), iOS 27.0 (`24A5430a`), Developer Mode enabled |
| Install/launch | CoreDevice reported successful install and launch |

## Observed matrix

| Active downloaded scheme removed | Main-App route result | Controlled Extension observation |
|---|---|---|
| Rime Ice | switched to Luna | `ni` produced a normal Chinese candidate |
| Wanxiang | switched to Luna | `ni` produced a normal Chinese candidate |

The human operator supplied only the binary candidate-present result. No candidate
text, host content, screenshot of input, App Group file content or user data was
recorded.

## Structured-diagnostic availability

After the two runs, the Main-App Diagnostics UI showed ten
`runtime_route.phase_changed` records in two timestamp clusters under the
deployment category. This confirms that the new producer persisted route
events for the observed operations.

The current list renders only code/time/level/category. It does not render
the underlying `runtimeRoutePayload`; its existing Copy action also exports
only that formatted text. Consequently, this evidence does **not** claim the
individual operation UUID, phase/result, schema/layout/state, or
`elapsed_ms` values.

CoreDevice could not list an individual JSONL segment in the App Group.
Copying the whole Diagnostics directory would exceed the approved minimal
data boundary, so it was not performed. The Product Lead directed the
elapsed comparison to be recorded as **暂无获得**. No conclusion is drawn
about whether fallback deployment is slower than normal Luna deployment.

## Result and non-claims

**CS09-10-02 functional candidate outcome: Pass.** The prior device symptom
of a successful Main-App Luna deployment followed by no Extension candidate
was not reproduced in either active-uninstall direction on this candidate.

This does not prove a general performance result, real App Group crash
atomicity, every route-payload field, Product Gate, PR merge, TestFlight,
Release, or completion of `RTRD-01` / `RTRD-02`.
