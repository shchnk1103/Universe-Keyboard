# RELEASE-2026-0801-01 — Xcode Cloud artifact/dSYM retention pilot

> **Evidence grade:** `Executor-recorded`
> **Collected:** `2026-08-24 Asia/Shanghai`
> **Source build:** Xcode Cloud `Archive Pilot (No Distribution)` Build 3
> **Commit:** `4fd3ce70d9acfc54472923fb7d66ff0589e11f6d`
> **Assignment:** [`RELEASE-2026-0801-01`](../assignments/release-2026-08-01-01-stable-archive.md)

## Scope

Verify that the earlier no-distribution pilot still exposes downloadable Archive,
logs, XCResult and App Store export artifacts, and that those artifacts retain
actionable App/Keyboard symbols and distribution metadata. This is a capability
pilot only. The source commit is not the frozen RC and no upload or distribution
was performed.

## Cloud observation

- Build 3 remained available in App Store Connect on `2026-08-24`.
- The Archive action exposed downloadable artifacts for the `.xcarchive`, archive
  logs, ad-hoc/App Store/development exports and XCResult.
- The App Store export option records `testFlightInternalTestingOnly = false`.
- XCResult reports `succeeded`, with 0 errors, 0 warnings and 0 analyzer warnings.

## Archive and symbol mapping

| Item | Result |
|---|---|
| App Mach-O UUID | `C9F8B0C2-038D-3B12-A3E8-0F4C4400A1A4` |
| App dSYM UUID | `C9F8B0C2-038D-3B12-A3E8-0F4C4400A1A4` — exact match |
| Keyboard Mach-O UUID | `ED4F9043-CC75-362E-B652-32104549E06D` |
| Keyboard dSYM UUID | `ED4F9043-CC75-362E-B652-32104549E06D` — exact match |
| App dSYM DWARF SHA-256 | `66ee067c4d13f41ba24d14d59a459361321e2dde8f26b50c2296a90608163ba6` |
| Keyboard dSYM DWARF SHA-256 | `26f040d2343f264de4f5f7c9df5ef1c8344cae674faef264df97b1364ce5f3f3` |

## App Store export

- The Human Product Owner manually downloaded the complete `Universe Keyboard 1.0 app-store`
  export directory. Its retained manifest is:

| File | Bytes | SHA-256 |
|---|---:|---|
| `Universe Keyboard.ipa` | `18,557,499` | `aca8d33502ae192510b0fa25911e6067dcb59eaadc262735697aa721f539326f` |
| `Packaging.log` | `110,436` | `a53ae60007c3c723cd0c18f90cecfe41a9e0abc7a3920d708d1ea645c971c300` |
| `ExportOptions.plist` | `666` | `f8a3deab39a72c3396967744872f440532ab32fa8c4e4822d2c0a7b34b1c291e` |
| `DistributionSummary.plist` | `3,286` | `521066485b56c75293b1a8a7b6da968ef5c28c668e794c64723f66afa38925df` |

- Exported App and Keyboard are both version `1.0`, build `3`, arm64, minimum
  iOS `18.0`, produced by Xcode `26.6 (17F113)` / iPhoneOS SDK `26.5`.
- The binaries extracted from the downloaded IPA retain the same App and Keyboard
  Mach-O UUIDs shown above, so the downloaded App Store package maps back to both
  retained dSYMs rather than only to the pre-export archive metadata.
- `DistributionSummary.plist` records Cloud Managed Apple Distribution for both
  bundles, Team ID `C33N6HTS9N`, Store provisioning profiles, symbols present and
  `get-task-allow = false`.
- App and Keyboard share the expected App Group
  `group.com.DoubleShy0N.Universe-Keyboard`; both have
  `beta-reports-active = true`.
- Export logs end with `EXPORT SUCCEEDED` and show the App Store export/signing
  pipeline. No TestFlight upload occurred.

## Local verification boundary

The downloaded `.xcarchive` is intentionally ad-hoc before export; the retained
App Store export contains the distribution signature and profiles. Local
`codesign --verify --deep --strict` reached `CSSMERR_TP_NOT_TRUSTED` because the
current beta-host keychain does not trust the Cloud-managed certificate chain.
This is not recorded as an artifact-integrity pass from local trust validation.
The distribution identity is instead corroborated by the embedded signature
Team ID, entitlements, Store profiles, `DistributionSummary.plist` and the Cloud
export log. Final RC evidence must repeat the same checks and retain its own
exact artifacts.

## Conclusion

**Pilot capability Pass:** Xcode Cloud can retain and later download the Archive,
both dSYMs, logs, XCResult and a non-Internal-Only App Store export whose App and
Keyboard symbols map to the archived binaries.

**Non-claims:** this does not freeze RC, validate the final candidate, authorize
upload, close `RELEASE-2026-0801-01`, close TD-005, or replace independent review.
The final frozen RC must produce a new artifact ledger and durable storage record.
