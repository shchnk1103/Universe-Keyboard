# Evidence: RIME-SYNC-001 XcodeBuildMCP test-count reconciliation — 2026-09-24

| Field | Value |
|---|---|
| Assignment | [`RIME-SYNC-001`](../assignments/rime-sync-001.md) |
| Evidence grade | `Executor-recorded` |
| Disposition | Product accepted this bounded reporting residual; see [Product Decision](../product-decisions/RIME-SYNC-001-QR-CURRENT-01-PRODUCT-RESIDUAL-2026-09-24.md) |
| Source base | Isolated worktree HEAD `4a51228fc8e435d538e9a5f7342ae325502e1e66`; worktree was dirty and was not changed for this reconciliation |

## Reconciliation

The current Quality-reviewed App + Keyboard run from 2026-09-23 reported
`398 discovered`, while its authoritative `.xcresult` contains `397` cases:
`387` passed, `10` skipped and `0` failed. A confirmatory full run on
2026-09-24 reported the same totals. The ten skipped cases remain skipped and
are not counted as passes.

Xcode's native test enumeration was run in enumeration mode (no test methods
were run) against the **same** `.xctestproducts` bundle for each run. The
primary comparison is the exact package inspected by the 2026-09-23 Quality
review:

```text
xcodebuild -derivedDataPath /private/tmp/rime-sync-qr-current-01-repro-20260924-derived \
  -packageCachePath /Users/doubleshy0n/Library/Caches/org.swift.swiftpm \
  -testProductsPath /Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/test-products/test_sim_2026-09-23T15-32-10-266Z_pid5815_b57d1119.xctestproducts \
  -destination 'platform=iOS Simulator,id=405D994F-28CB-4F89-BB22-B64AD81C05A2' \
  -enumerate-tests -test-enumeration-style flat -test-enumeration-format json \
  -test-enumeration-output-path /private/tmp/rime-sync-qr-current-01-enum.cr8BdK/quality-run-enumeration.json \
  -disableAutomaticPackageResolution -skipPackageUpdates test-without-building
```

Both enumerations returned no errors and `397` enabled, unique test identifiers
each:

| Target | Enumerated identifiers |
|---|---:|
| `UniverseKeyboardTests` | 382 |
| `KeyboardTests` | 15 |
| **Total** | **397** |

| Run | MCP discovered | `.xcresult` total | Xcode enumerated | Identifier set difference |
|---|---:|---:|---:|---:|
| 2026-09-23 Quality-reviewed run | 398 | 397 (`387/10/0`) | 397 | 0 |
| 2026-09-24 confirmation run | 398 | 397 (`387/10/0`) | 397 | 0 |

For each run, the normalized Xcode identifier set was compared with every
test-case identifier in that run's `.xcresult`. Both symmetric differences
were **0**. All four sorted sets have SHA-256
`a4616f29720c3b9c8f5fb3fd728381d3154b293db59007da9041e1898738fa71`.
Both raw Xcode enumeration JSON files have SHA-256
`622366d88fe300149f0a5442973c9e4fd8a1d3efff6ba4e8e43018da02f17b5d`.

## Artifacts and result

- Quality-reviewed XcodeBuildMCP `.xcresult`:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T15-32-10-266Z_pid5815_cb08a974.xcresult`
- Confirmatory XcodeBuildMCP `.xcresult`:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T11-52-54-097Z_pid14565_985b45ad.xcresult`
- Quality-reviewed raw log:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-23T15-32-10-266Z_pid5815_b0dff4c5.log`
- Confirmatory raw log:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-24T11-52-54-096Z_pid14565_c629bf54.log`
- Quality-reviewed `.xctestproducts`:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/test-products/test_sim_2026-09-23T15-32-10-266Z_pid5815_b57d1119.xctestproducts`
- Confirmatory `.xctestproducts`:
  `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/test-products/test_sim_2026-09-24T11-52-54-097Z_pid14565_7156207f.xctestproducts`
- Enumeration JSONs:
  `/private/tmp/rime-sync-qr-current-01-enum.cr8BdK/quality-run-enumeration.json` and
  `/private/tmp/rime-sync-qr-current-01-enum.cr8BdK/enumeration.json`
- Simulator: iPhone 18 Pro, iOS 27.0; Xcode `27.0 (27A266a)`.

**Conclusion:** The 397 real test identifiers in Xcode's enumeration exactly
match the 397 cases in each `.xcresult`, including the exact run reviewed by
Quality. The 398 value is isolated to the XcodeBuildMCP discovery/preflight
count; this evidence does not identify the internal source of its extra count
or claim an additional/missing test. No suite rerun, application-source edit,
or test-result alteration was performed for either comparison.

## Limits

- XcodeBuildMCP exposed the aggregate discovery count and only a sample of its
  selectors, not the complete preflight selector set; the specific source of
  the extra reported count remains unknown.
- This reconciles the current Quality-reviewed run and one same-snapshot
  confirmation run only. It does not establish that future XcodeBuildMCP
  versions or runs will report accurate discovery counts.
- This is not a new independent Quality review, hosted CI run, device test,
  Product Gate, merge, TestFlight or Release conclusion.
