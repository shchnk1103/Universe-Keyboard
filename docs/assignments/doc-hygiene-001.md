# Assignment: DOC-HYGIENE-001 — Knowledge OS Documentation Hygiene Pass

**Policy version:** `1.0.0`

**Decision source:** Human Product Owner authorization to organize repository documentation under Knowledge OS 2.0 / `2026-07-17 Asia/Shanghai`

**Decision date:** `2026-07-17 Asia/Shanghai`

**Lifecycle status:** `Accepted / Closed`

**Assignment Authority:** 🧭 Product Lead

---

## Objective

Apply a bounded Knowledge OS documentation hygiene pass so current guidance is single-track, lifecycle-correct and cheaper for new sessions to navigate—without redesigning Knowledge OS, moving domain trees or changing product runtime.

---

## Authority

- **Assignment Authority:** 🧭 Product Lead
- **Product Approver:** 🧭 Product Lead (Human Product Owner)
- **Permanent Domain Ownership:** 🏛️ Architecture & Knowledge Steward
- **Domain Owner / Executor:** 🏛️ Architecture & Knowledge Steward
- **Environment Executor:** `Not Applicable — documentation hygiene only`
- **Human Dependency:** `Not Applicable — Product authorization already recorded in Decision Source`
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** `Not Required — no runtime/release/performance evidence gate`
- **Handoff Target:** 🧭 Product Lead; 📋 Program Manager for Dashboard sync if needed

---

## Scope

Repository Change Types: `Documentation` and `State` (lifecycle synchronization only).

Allowed work:

1. Publish this Assignment and a hygiene audit record.
2. Normalize `docs/plans/*` lifecycle headers to `Active` / `Archived` / `Superseded` / `Abandoned`.
3. Synchronize Assignment Records whose Dashboard/Product-confirmed state is already Closed but the record header still shows an earlier state (`KOS-GOV-001`, `ENV-TOOLING-001`).
4. Resolve the dual ADR `0017` identity collision by renumbering the App Notification ADR to `0019` and rewriting references.
5. Reduce `README.md` to entry / quick-start / navigation responsibility; link out for architecture and capability detail.
6. Refresh `DOCUMENTATION_HEALTH.md` audit snapshot and debt queue after this pass.
7. Update navigation/graph references required by the ADR renumber and hygiene discovery.
8. Report validation and residual risks.

## Non-goals

- Knowledge OS 2.1 / 3.0 redesign
- Domain architecture tree migration or mass file moves
- Production code, tests, build settings, Runtime/RIME behavior
- Changing Product Contract substance, Registry IDs or Benchmark outcomes
- Full playbook dry-runs and permanent-thread dry-runs (recorded as residual debt)
- Inventing missing Product decisions for still-active work items

---

## Entry / Exit / Stop

**Entry:** KOS-MIG-001 single-track authority available; Product authorized hygiene.

**Exit:** deliverables present; plan headers use allowed lifecycle enum; dual ADR 0017 collision resolved; README no longer owns full feature/architecture inventory; health snapshot updated; validation reported.

**Stop:** any work that requires Product reinterpretation of active feature contracts, domain tree moves, or frozen Knowledge OS redesign.

---

## Lifecycle

Executed path: `Assigned → Acknowledged → Ready → Active → Completed → Reviewed → Accepted / Closed`

Product Review: **Accepted** via Human Product Owner authorization `2026-07-17 Asia/Shanghai`.

---

## Related Documents

- [`Hygiene audit record`](../evidence/doc-hygiene-001-audit.md)
- [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md)
- [`DOCUMENTATION_HEALTH.md`](../DOCUMENTATION_HEALTH.md)
- [`KOS-MIG-001`](kos-mig-001.md)
