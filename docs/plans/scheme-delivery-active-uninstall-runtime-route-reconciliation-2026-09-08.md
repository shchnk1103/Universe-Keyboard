# Proposed: Active-uninstall runtime-route reconciliation

Date: 2026-09-08 Asia/Shanghai
Status: **Proposed — documented for a separately authorized future executor**
Assignment: `SCHEME-DELIVERY-SOURCE-STATE-001`
Trigger: [CS09-10-02 failing device observation](../evidence/scheme-delivery-cross-scheme-cs09-cs10-device-2026-09-08.md)

## Problem statement

The active-uninstall path currently writes `rime_active_schema=luna_pinyin`
and completes a Luna deployment before it removes target files. The Keyboard
Extension resolves its effective schema through layout-bound preferences. A
persisted layout slot can still point to the just-removed downloaded scheme,
which wins over `rime_active_schema`; startup then requests the missing scheme.

The device reproduces this in both Ice → Wanxiang and Wanxiang → Ice orders:
Luna deployment reports success in the main App but `ni` has no Chinese
candidate, while explicitly selecting the retained scheme restores candidates.

## First-principles contract

Input state consists of the removed scheme identity, all registered layout
slots and bindings, the selected layout, logical schema dependencies (for
example, the T9 route depends on Ice), installed/readiness facts, and the
approved fallback schema (`luna_pinyin`).

Before fallback deployment, reconciliation must ensure:

1. The selected runtime route resolves to Luna or another explicitly approved,
   installed fallback.
2. No binding reachable from that route names the removed scheme or a logical
   dependent of it.
3. If the selected layout cannot express the fallback, select the fallback's
   registered compatible layout and clear the invalid layout route.
4. Unaffected layout preferences remain intact when they do not reference the
   removed scheme or one of its dependencies.

This preserves the Human-approved policy: active downloaded-scheme uninstall
falls back to Luna, not a peer downloaded scheme.

## Proposed design

Introduce one pure, capability-driven reconciliation seam owned by runtime
selection, conceptually:

`reconcileAfterSchemaRemoval(snapshot, removedSchema, fallbackSchema) -> RuntimeRouteMutation`

`snapshot` contains an ordered registry of layout-slot descriptors rather than
uninstall code referring to `schemeBinding26` or `schemeBinding9`. Each
descriptor declares its preference key, supported schema capabilities, logical
dependencies, and compatible fallback route. The mutation contains only the
affected binding clears/replacements, selected-layout transition, and
active-schema value. The Main App applies it atomically before its existing
Luna deployment request.

| Slot | Current route | Luna-compatible fallback |
|---|---|---|
| 26-key | Direct 26-key schema binding | Bind `luna_pinyin` |
| 9-key | Logical `t9` route dependent on Ice/readiness | Clear invalid route; select the registered 26-key Luna route |

Future layouts add one descriptor and capability/dependency declaration. They
do not add a new conditional branch to active-uninstall code.

## Why not update only the 26-key binding

That would fix the observed 26-key symptom but would leave the same invariant
unexpressed for 9-key and every later layout. It also obscures the case where
Luna cannot serve the active layout. The route reconciler makes the capability
transition explicit and testable.

## Proposed implementation slice

This work is **not authorized for implementation** by this record.

1. Add the pure runtime-route snapshot, layout-slot registry, dependency-aware
   reconciliation result, and deterministic tests in `KeyboardCore`.
2. Make the active-uninstall transaction apply the reconciliation result before
   its existing fallback deployment, retaining the commit lease and
   stage/rollback ordering.
3. Make `RimeRuntimeSelection` and extension startup consume the same resolved
   route; do not duplicate availability checks in keyboard UI code.
4. Add content-free structured diagnostics under the active-uninstall operation
   UUID: route-before, route-after, fallback deployment start/result, staging
   start/result, and commit result. Include route identities and timing only.

## Required verification

- Pure route tests for current 26-key and 9-key slots, removed Ice and
  Wanxiang, T9 dependency invalidation, untouched peer preferences, and an
  unknown/future-slot descriptor.
- `SchemaManager` transaction tests for both uninstall orders, proving the
  resolved fallback route is Luna before deploy and target bytes remain guarded
  by existing stage/commit rules.
- RimeBridge/Extension-target test proving persisted post-reconcile state
  resolves and selects Luna, rather than an absent target schema.
- Strict Swift format/lint and required App + Keyboard/RimeBridge gates.
- Fresh CS09-10-02 physical-device matrix with the structured operation trace.

## Stop conditions and non-goals

Stop and return to Product/Architecture if a new layout has no Luna-compatible
route, if a registry change changes fallback policy, or if reconciliation would
delete a user preference unrelated to the removed scheme.

This slice does not authorize a new fallback scheme, a peer-prefer policy,
Recovery persistence, archive/ownership changes, broad settings redesign,
PR undraft/merge, TestFlight, App Release, Product Gate, or ADR 0034
acceptance. Architecture review against ADR 0026 and quality review are
required before a future candidate is treated as complete.

## Handoff

A future executor should start with this proposal, the failing device evidence,
ADR 0026, `RimeRuntimeSelection`, the active-uninstall transaction, and the
RimeBridge playbook. The first deliverable is a reviewed contract/test plan;
implementation requires a separate explicit Human authorization.
