# ADR 0033: Main-App-Owned Offline RIME Resource Closure

## Status

Accepted; implementation pending

**Accepted:** `2026-08-29 Asia/Shanghai` after the independent Architecture
follow-up accepted the main-App ownership, official-byte overlay, prebuilt
generation, fail-closed manifest and Octagram G1 boundaries. See the
[Architecture review](../../assignments/rime-builtin-luna-quality-001-architecture-review.md#architecture-follow-up-addendum--adr-0033-and-lifecycle-correction).

Acceptance makes this ADR binding architecture; it does not claim that code,
resources, generated receipts, bundle inspection, runtime behavior, physical-
device evidence, CI, legal review, merge, TestFlight or Release is complete.
Those implementation and acceptance results remain subject to the Assignment's
independent Quality and Human Product gates.

## Context

The built-in `luna_pinyin` scheme currently ships a small historical resource
set under `Keyboard/Resources`. The main App locates those inputs through the
embedded `Keyboard.appex`, writes app-owned templates over some upstream
configuration and may compile a table without the official `essay.txt` preset
vocabulary. On a fresh physical-device test this produced rare characters ahead
of normal `ni` and `nihao` results.

Product selected a fully offline official Luna runtime closure: Luna Pinyin,
Essay, Prelude, Stroke and the OpenCC data reachable from supported conversion
profiles, plus only a thin Universe iOS overlay. Every required built-in asset
must ship with the App; users must not download a resource to make the built-in
scheme usable.

This introduces durable choices about cross-target ownership, immutable source
bytes, generated artifacts, OpenCC compatibility and failure recovery. ADR 0001
and ADR 0003 already make the main App the deployment writer and the Extension
a consumer of prepared App Group state, but they do not define the bundle-level
Source of Truth or the reproducible built-in resource closure.

## Decision

### 1. One main-App-owned immutable source

The main App target owns the single bundled deployable copy of the built-in
RIME resource closure. A dedicated resource bundle is allowed if it is linked
only to the main App target.

The Keyboard Extension does not bundle a second copy of Luna, Essay, Prelude,
Stroke, OpenCC configs/data or generated RIME artifacts. It consumes only a
coherent deployment prepared in the App Group and owns only its process-local
RIME session, as required by ADR 0001, ADR 0003 and ADR 0004.

### 2. Pinned official closure, not the complete preset catalog

The accepted source revisions are the immutable pins and exact file manifest
recorded by the
[F-02 upstream pin audit](../../evidence/rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md):

- Luna Pinyin `56b934b099dfbeab842320f13aa8b461a6ab3e42`;
- Essay `e9b1a374a6ea015fca5bdd04318924b4483ac35a`;
- Prelude `082425ea0684bca36474415d4a0e8db9b016487e`;
- Stroke `1e8fff9b9494ddec23b0cbc526bcfd8171a6fd48`;
- OpenCC `25350017e81b40aa9e3e66c18446b57f83b0607d`.

The dependency graph follows the selected `luna_pinyin` entry schema through
its dictionary, presets, reverse lookup and supported OpenCC profiles. S2T is a
retained shared-runtime capability; T2S, T2HK and T2TW are enabled conversion
profiles. The manifest labels direct schema dependencies separately from
retained capability.

Unselected Luna variants, unrelated Prelude schemes, Plum recipes and the full
official preset catalog are not bundled merely because they exist upstream.
Changing a pin, schema ID, profile or retained capability revalidates this ADR
and the Assignment.

### 3. Official bytes remain immutable; product behavior uses thin overlays

Pinned upstream YAML, JSON, dictionary text and preset vocabulary remain
byte-identical in the bundle and deployed source set. Universe-owned behavior
is expressed beside those files through small, reviewable custom overlays:

- `default.custom.yaml` owns the shipped schema list, supported iOS bindings
  and product defaults;
- `luna_pinyin.custom.yaml` owns managed fuzzy rules, the default conversion
  choice and other explicitly approved Luna behavior; and
- another schema-specific custom file is added only when an enabled schema
  requires it and its ownership is recorded.

The implementation must compile-test the effective official configuration. It
must not retain the historical `switches/@1` assumption: the selected official
Luna schema places `zh_hans` at `switches/@2`. A named or otherwise
schema-verified patch is preferred over an unguarded positional mutation.

### 4. Ship one reproducible prebuilt generation

The built-in release path ships prebuilt RIME dictionary artifacts and the six
selected OpenCC `.ocd2` outputs. This avoids making first keyboard use depend on
an expensive source-only compilation and gives the App a deterministic closure
to validate before deployment.

Every generated output is one generation with its pinned source inputs. The
repository must provide a deterministic generation procedure and an immutable
receipt containing:

- source repository, commit and input SHA-256 values;
- generator binary/source revision, host/toolchain identity and exact command;
- output relative path, byte length, SHA-256 and relevant entry count; and
- two clean-output-directory runs whose packaged outputs are byte-identical.

The generated outputs must be accepted by the shipped iOS RIME/OpenCC runtime.
A macOS or Homebrew-generated file is not treated as compatible solely because
the file format appears readable. Stale generated files cannot remain active
after an input, overlay, generator or vendor change.

Source files may also ship for notice, diagnosis or deterministic repair, but
they are not a second runtime authority. The manifest identifies the prebuilt
generation as the built-in deployment Source of Truth. A future source-only
strategy requires a superseding Architecture decision with measured
fresh-device latency, memory and interruption recovery.

### 5. Manifest validation and fail-closed deployment

Before reporting deployment success, the main App validates the complete
required bundle manifest, stages the selected generation and verifies the
deployed identity. A missing, unexpected or corrupt source/generated asset is
an actionable deployment failure.

The implementation must not write text fallback content under `.bin` or
`.ocd2` names and must not use byte length alone as an integrity decision. A
failed attempt preserves the last known good deployment and its receipt. This
ADR requires a guarded staging/commit boundary for F-02 but does not claim to
resolve the broader file-by-file transaction debt governed by ADR 0006 and
TD-001.

### 6. Notices and optional modules

The App's offline third-party notice surface and packaged attribution include
Luna, Essay, Prelude, Stroke, OpenCC and incorporated data, tied to the actual
bundle manifest. Engineering review verifies completeness; legal sufficiency
remains a Human Product Owner/legal decision.

The already linked Octagram module remains capability-only G1. F-02 bundles no
`.gram`, activates no `grammar.language` path and makes no user-facing grammar
claim. Any such change requires a separate Product Decision and Architecture
review; TD-012 is not reopened here.

## Alternatives Considered

- **Keep resources in `Keyboard.appex` and let the main App reach into it:**
  rejected because it reverses the accepted deployment ownership boundary and
  encourages duplicate or Extension-coupled sources.
- **Bundle the complete official preset catalog:** rejected because file
  presence is not a product requirement; it increases size, notice and test
  scope without a selected schema closure.
- **Continue the minimal app-authored Luna schema/dictionary:** rejected because
  it forks the upstream Source of Truth and omits the preset vocabulary that
  provides normal candidate weighting.
- **Modify official YAML in place:** rejected because deployed bytes can no
  longer be verified against upstream pins and index assumptions drift when the
  official schema changes.
- **Compile only from source on first use:** rejected for this release path
  because fresh-device latency and interruption recovery are not yet proven.
- **Trust unreceipted prebuilt binaries:** rejected because source, generator
  and packaged output could silently describe different generations.
- **Download missing built-in resources:** rejected by the binding Product
  constraint and by offline first-run requirements.
- **Upgrade to current OpenCC data while retaining the old binary:** rejected
  because OpenCC binary, generator, configs and dictionaries form one reviewed
  compatibility set.

## Consequences

- Built-in resources move out of the Extension target and increase the main App
  bundle by the exact accepted closure size.
- Deployment preparation becomes manifest-driven and can produce an explicit
  integrity error instead of silently substituting fallback text.
- Official upstream updates require pin, manifest, generated receipt, notice
  and candidate/conversion regression updates as one change.
- Candidate-quality tests can assert exact Top-1 and first-page order against a
  known generation rather than only checking for any Han candidate.
- The Extension startup path remains free of deployment, download, hashing,
  repair and other persistent heavy work.

## Risks

- Prebuilt outputs may be nondeterministic or incompatible if the generator is
  not tied to the shipped runtime; clean double-generation and runtime tests are
  mandatory.
- A partial staging implementation could damage last-known-good state; fault
  injection must cover missing/corrupt assets and interrupted replacement.
- Bundle-size and first-deploy costs may be material; they require measured
  release-like evidence and Human Product acceptance, not an invented budget.
- Positional overlay patches can silently target the wrong switch after an
  upstream update; effective-config tests and revalidation triggers are needed.
- Notices can drift from actual bundled data; the same manifest must drive
  engineering inventory and attribution review.

## Follow-up Work

1. Materialize the dependency graph and intended bundle/deployed manifest from
   the accepted source audit, including direct versus retained OpenCC edges.
2. Add the deterministic RIME/OpenCC generation procedure and two-run receipts.
3. Move target membership to one main-App-owned source and remove the Extension
   copy.
4. Replace generated upstream templates/in-place mutation with thin custom
   overlays and effective-config tests.
5. Implement manifest validation, fail-closed staging and last-known-good fault
   tests without claiming ADR 0006/TD-001 closure.
6. Complete exact candidate-order, four-profile OpenCC, Stroke reverse lookup,
   offline fresh-container, Full Access, performance/size, notice and full CI
   evidence required by the Assignment.
7. Obtain independent Architecture and Quality re-review, then the Human
   Product Gate. None of those gates is implied by this Proposed ADR.

## Related Documents

- [`RIME-BUILTIN-LUNA-QUALITY-001`](../../assignments/rime-builtin-luna-quality-001.md)
- [`Architecture review`](../../assignments/rime-builtin-luna-quality-001-architecture-review.md)
- [`Quality review`](../../assignments/rime-builtin-luna-quality-001-quality-review.md)
- [`Official runtime-closure Product Decision`](../../product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-official-runtime-closure.md)
- [`F-02 upstream pin audit`](../../evidence/rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md)
- [`ADR 0001`](0001-main-app-owns-rime-deployment.md)
- [`ADR 0003`](0003-shared-container-ownership.md)
- [`ADR 0004`](0004-rime-runtime-session-model.md)
- [`ADR 0006`](0006-schema-install-transaction-model.md)
- [`ADR 0008`](0008-fallback-engine-product-semantics.md)
- [`RIME artifacts`](../rime-artifacts.md)
- [`OpenCC integration`](../opencc-integration.md)
- [`TD-001`](../../TECH_DEBT.md#td-001-atomic-schema-installation)
