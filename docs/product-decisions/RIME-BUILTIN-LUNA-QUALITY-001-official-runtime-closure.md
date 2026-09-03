# Product Decision: RIME-BUILTIN-LUNA-QUALITY-001 — Official Luna Runtime Closure

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-RIME-BUILTIN-LUNA-QUALITY-001-CLOSURE",
  "record_type": "decision",
  "title": "Adopt the pinned official Luna runtime closure with a thin Universe iOS overlay",
  "status": "accepted",
  "updated_at": "2026-08-29T20:15:53+08:00",
  "revalidation_triggers": [
    "upstream_package_revision_changed",
    "schema_dependency_graph_changed",
    "supported_conversion_profile_changed",
    "grammar_or_model_capability_proposed"
  ],
  "parent_refs": ["RIME-BUILTIN-LUNA-QUALITY-001"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-29 Asia/Shanghai confirmation",
    "scope": "Select the built-in Luna source-of-truth and offline resource strategy",
    "outcome": "Use a pinned official Luna runtime dependency closure plus a thin, reviewed Universe iOS overlay; bundle every required runtime asset in the App with no user download; do not authorize implementation, Octagram, PR #91, merge or release",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-RIME-BUILTIN-LUNA-QUALITY-001-CLOSURE`
- **Lifecycle status:** `Accepted`
- **Date / timezone:** `2026-08-29 Asia/Shanghai`
- **Authority:** Human Product Owner acting as Product Lead

## Decision

The built-in scheme will use the **pinned official Luna runtime dependency
closure** as its upstream Source of Truth. Universe Keyboard will maintain only
a thin iOS product overlay needed to:

- register only schemes actually shipped by the App;
- select reviewed simplified/traditional defaults and supported conversion
  profiles;
- adapt desktop-oriented bindings and presentation to the keyboard extension;
- define managed fuzzy-pinyin defaults without copying the upstream schema;
- explicitly keep grammar/model activation outside this closure.

The runtime closure starts from pinned revisions of official Luna Pinyin,
Essay, Prelude and Stroke, then follows every active schema reference into the
required OpenCC configuration/data and generated RIME artifacts. Every asset
required for first-run activation, normal candidate quality, conversion,
punctuation or reverse lookup ships inside the App. A user must not download a
built-in dependency.

“Official runtime closure” does **not** mean bundling the entire RIME preset
catalog. Prelude entries for unshipped schemes, unrelated recipes, user data,
downloadable third-party schemes and unsupported optional capabilities are not
part of this decision.

## Supply-Chain Boundary

- Pin each upstream repository to an immutable commit; no production input may
  resolve from a mutable branch or an unverified release alias.
- Record repository, commit, path, byte length, SHA-256, license and attribution
  for every source asset.
- Generate any shipped table, prism and reverse artifacts from the exact pinned
  closure, and record their SHA-256 plus the generator/librime provenance.
- Verify both App-bundle membership and deployed App Group identity. The main
  App remains the deployment owner; the Keyboard Extension consumes only the
  last known good deployed state.
- Treat an upstream revision or dependency-graph change as a reviewed upgrade,
  not an automatic resource refresh.

## Explicit Non-Authorization

This decision selects product direction only. It does not:

- authorize implementation while Assignment responsibilities and immutable
  revisions remain incomplete;
- enable or bundle Octagram or another `.gram` model;
- modify, review, merge or otherwise manage PR
  [#91](https://github.com/shchnk1103/Universe-Keyboard/pull/91);
- authorize a TestFlight build, App Store submission, merge or Release claim.
