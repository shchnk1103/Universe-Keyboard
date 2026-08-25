# Product Decision: RIME-SCHEME-DELIVERY-001 — Upstream Source Variants Without A Universe Server

**Decision ID:** `PD-RIME-SCHEME-DELIVERY-001-SOURCE-VARIANTS`
**Lifecycle status:** `Recorded — implementation pending`
**Date / timezone:** `2026-08-25 Asia/Shanghai`
**Assignment:** [`RIME-SCHEME-DELIVERY-001`](../assignments/rime-scheme-delivery-001.md)
**Evidence:** [`2026-08-25 bounded endpoint pilot`](../evidence/rime-scheme-delivery-endpoint-pilot-2026-08-25.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Recorded — implementation pending` |
| **Phase** | Product source contract is frozen; implementation Assignment remains Pending |
| **Non-claims** | No production implementation, Mainland cellular/Wi-Fi pass, endpoint permission conclusion or Release acceptance |
| **Next** | Product Lead completes the implementation responsibility configuration; Architecture reviews manifest and installed-content identity before code execution |
| **Residuals** | Assignment Entry/Exit Criteria and endpoint pilot gates remain authoritative |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead
- **Decision Source:** Active Codex task, `2026-08-25 Asia/Shanghai`: declined
  purchasing another server, accepted the source/version disclosure approach
  after the exact GitHub/CNB content comparison, and instructed the task to
  continue under KOS.
- **Assignment Authority:** Product Lead under
  [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)

## Bound Product Decisions

1. Universe will not purchase or operate an additional server, object-storage
   origin or CDN for this Assignment.
2. Upstream-maintained GitHub, NJU and CNB endpoints may be evaluated. A source
   is never presented as a Universe-operated mirror.
3. Byte-identical copies are equivalent endpoints of one archive identity.
   Non-identical archives may be accepted only as explicitly identified source
   variants after they are proven to stage the same selected runtime content.
4. The user-visible product must show the scheme version and selected download
   source. A details surface must retain the exact source URL/host, upstream
   revision where available, archive size and integrity status.
5. Every source variant has its own expected archive size and SHA-256. A shared
   visible tag is not sufficient integrity identity.
6. Lightweight source selection starts only after explicit user download intent.
   It must not require a VPN, run from the Keyboard Extension, fingerprint the
   user, or add a separate large synthetic speed test.
7. A fallback may switch source automatically only while both source variants
   remain bound to one validated installed-content identity. If their selected
   schema, dictionaries, Lua or other staged runtime content diverges, the App
   must stop transparent substitution and require a new manifest/Product review.
8. Transport failures use stable Simplified Chinese categories and recovery
   guidance. Raw `localizedDescription` text is diagnostic detail, not primary
   UI copy.

## Wanxiang `v17.5.9` Disposition

- GitHub and CNB archives are not byte-identical and use different source
  commits and archive SHA-256 receipts.
- All ordinary Wanxiang runtime files common to the archives are byte-identical
  in the recorded snapshot. CNB additionally contains three files under
  `custom/` for a separate `wanxiang_pure` schema; only `README.md` otherwise
  differs.
- Universe productizes only the ordinary `wanxiang` scheme in this slice. The
  Pure schema is not added to the catalog, copied to the shared RIME runtime or
  advertised as a feature.
- The current Wanxiang installation plan already skips `custom/`; implementation
  review must preserve this exclusion and add evidence that the guarded staged
  content is source-invariant.

## Explicit Non-authorization

- Purchase, creation or publication of a Universe server/mirror/CDN
- Adding `wanxiang_pure` as a selectable scheme
- Trusting an archive because it merely extracts or contains the expected schema
- Release distribution, Beta Review submission or RC acceptance
- Skipping Architecture, Quality or Mainland/non-Mainland evidence gates

## Revalidation Triggers

- Scheme version/tag, asset path, source commit, archive digest or endpoint changes
- Any selected staged runtime file differs between accepted source variants
- Installation plan begins copying `custom/` or other previously excluded paths
- Endpoint ownership/terms, redirect behavior or iOS networking behavior changes
