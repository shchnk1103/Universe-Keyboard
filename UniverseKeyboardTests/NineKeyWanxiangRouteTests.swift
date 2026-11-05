import KeyboardCore
import RimeBridge
import XCTest

@testable import Universe_Keyboard

@MainActor
final class NineKeyWanxiangRouteTests: XCTestCase {
    private let schemaID = "wanxiang_t9i"

    func testMatchedWanxiangMarkerRoutesToNineKeyAndRestoreSelectsThatSchema() throws {
        let fixture = try makeFixture(markerFingerprintMatches: true)
        defer { fixture.cleanup() }
        let snapshot = fixture.manager.currentRuntimeRouteSnapshot()
        XCTAssertEqual(snapshot.effectiveRoute.schemaID, schemaID)
        XCTAssertEqual(snapshot.effectiveRoute.layoutStyle, .nineKey)

        var selected: String?
        var userDir: String?
        RimeT9SmokeProbe.selectAndConfirmHook = { _, user, id in
            selected = id
            userDir = user
            return true
        }
        defer { RimeT9SmokeProbe.selectAndConfirmHook = nil }
        XCTAssertTrue(
            fixture.manager.restoreNineKeyEngineRoute(
                sharedDataURL: fixture.shared,
                userDataURL: fixture.user
            )
        )
        XCTAssertEqual(selected, snapshot.effectiveRoute.schemaID)
        XCTAssertEqual(userDir, fixture.user.path)
    }

    func testPublishedSwitchesSelectTheTargetScheme() async throws {
        let wan = try XCTUnwrap(NineKeySchemeRegistry.scheme(schemaID))
        let fog = try XCTUnwrap(NineKeySchemeRegistry.scheme("t9"))
        try await assertPublishedSwitch(
            target: wan,
            initialLayout: .twentySixKey,
            initialBinding: nil
        )
        try await assertPublishedSwitch(
            target: wan,
            initialLayout: .nineKey,
            initialBinding: fog.schemaID
        )
        try await assertPublishedSwitch(
            target: fog,
            initialLayout: .nineKey,
            initialBinding: wan.schemaID
        )
    }

    func testFinalSelectionFailureRevokesBindingAndReturnsTwentySix() async throws {
        let wan = try XCTUnwrap(NineKeySchemeRegistry.scheme(schemaID))
        let outcome = try await runSwitch(target: wan, selectSucceeds: false, smokePasses: true)
        XCTAssertEqual(outcome.failure, .restoreFailed)
        XCTAssertEqual(outcome.layout, .twentySixKey)
        XCTAssertNil(outcome.binding9)
        XCTAssertEqual(outcome.selected.last, wan.schemaID)
    }

    func testTargetSmokeFailureRestoresTwentySixAndKeepsTheOriginalFailure() async throws {
        let wan = try XCTUnwrap(NineKeySchemeRegistry.scheme(schemaID))
        let outcome = try await runSwitch(target: wan, selectSucceeds: true, smokePasses: false)
        XCTAssertEqual(outcome.failure, .smokeFailed(wan.schemaID))
        XCTAssertEqual(outcome.layout, .twentySixKey)
        XCTAssertNotEqual(outcome.selected.last, wan.schemaID)
    }

    func testMismatchedWanxiangMarkerFailClosesToTwentySix() throws {
        let fixture = try makeFixture(markerFingerprintMatches: false)
        defer { fixture.cleanup() }
        let snapshot = fixture.manager.currentRuntimeRouteSnapshot()
        XCTAssertEqual(snapshot.effectiveRoute.layoutStyle, .twentySixKey)
        XCTAssertNotEqual(snapshot.effectiveRoute.schemaID, schemaID)
    }

    private struct SwitchOutcome {
        let failure: NineKeyEnableOrchestrator.ActiveFailure?
        let layout: KeyboardLayoutStyle
        let binding9: String?
        let selected: [String]
    }

    private func assertPublishedSwitch(
        target: NineKeyScheme,
        initialLayout: KeyboardLayoutStyle,
        initialBinding: String?
    ) async throws {
        let outcome = try await runSwitch(
            target: target,
            selectSucceeds: true,
            smokePasses: true,
            initialLayout: initialLayout,
            initialBinding: initialBinding
        )
        XCTAssertNil(outcome.failure)
        XCTAssertEqual(outcome.selected.last, target.schemaID)
        XCTAssertEqual(outcome.layout, .nineKey)
        XCTAssertEqual(outcome.binding9, target.schemaID)
    }

    private func runSwitch(
        target: NineKeyScheme,
        selectSucceeds: Bool,
        smokePasses: Bool,
        initialLayout: KeyboardLayoutStyle = .twentySixKey,
        initialBinding: String? = nil
    ) async throws -> SwitchOutcome {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-wx-switch-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        for scheme in NineKeySchemeRegistry.entries {
            try "schema_id: \(scheme.schemaID)\n".write(
                to: shared.appendingPathComponent(scheme.schemaFileName),
                atomically: true,
                encoding: .utf8
            )
        }
        let settings = RecordingSettingsStore()
        settings.set(true, forKey: "wanxiang_installed")
        settings.set("luna_pinyin", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        settings.set("luna_pinyin", forKey: "rime_active_schema")
        T9DeploymentSupport.persistLayout(initialLayout, settings: settings)
        if let initialBinding {
            settings.set(initialBinding, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
            let fingerprint = T9DeploymentSupport.resourceFingerprint(
                schemaID: initialBinding, sharedDataURL: shared)
            T9DeploymentSupport.writeMatchedReadiness(
                schemaID: initialBinding,
                fingerprint: fingerprint ?? "missing",
                upstreamVersion: "v",
                settings: settings
            )
        }
        let directories = SchemaDeploymentDirectories(sharedDataURL: shared, userDataURL: user)
        let manager = SchemaManager(
            settings: settings,
            archiveInstaller: WanxiangRouteInstaller(directories: directories)
        )
        var selected: [String] = []
        RimeT9SmokeProbe.selectAndConfirmHook = { _, _, id in
            selected.append(id)
            return selectSucceeds
        }
        defer { RimeT9SmokeProbe.selectAndConfirmHook = nil }
        let listed = NineKeySchemeRegistry.entries
        let failure = await NineKeyEnableOrchestrator.enable(
            using: NineKeyEnableOrchestrator.ActiveDependencies(
                target: target,
                familyInstalled: { true },
                resolveDirectories: {
                    NineKeyEnableOrchestrator.Directories(sharedDataURL: shared, userDataURL: user)
                },
                beginTargetTransaction: {
                    T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
                    T9DeploymentSupport.invalidateReadiness(schemaID: target.schemaID, settings: settings)
                },
                prepare: { _ in },
                invalidateAllMarkers: {
                    T9DeploymentSupport.invalidateAllReadiness(settings: settings)
                },
                deploy: { true },
                schemesToVerify: { listed },
                rewriteCheck: { _, _ in true },
                smoke: { scheme, _, _ in
                    smokePasses || scheme.schemaID != target.schemaID
                },
                fingerprint: { scheme, url in
                    T9DeploymentSupport.resourceFingerprint(schemaID: scheme.schemaID, sharedDataURL: url)
                },
                restoreRoute: {
                    manager.restoreNineKeyEngineRoute(sharedDataURL: shared, userDataURL: user)
                },
                finalRouteMatchesTarget: {
                    let selection = manager.registeredRuntimeSelection(sharedDataURL: shared)
                    return selection.effectiveSchemaID == target.schemaID
                        && selection.effectiveLayoutStyle == .nineKey
                },
                forceTwentySix: {
                    T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
                },
                writeMarker: { scheme, fingerprint in
                    T9DeploymentSupport.writeMatchedReadiness(
                        schemaID: scheme.schemaID,
                        fingerprint: fingerprint,
                        upstreamVersion: "v",
                        settings: settings
                    )
                },
                publishBinding: { id in
                    settings.set(id, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
                },
                publishLayout: {
                    T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
                },
                revokeNineKeyBinding: {
                    settings.removeObject(forKey: KeyboardLayoutSettingsKey.schemeBinding9)
                }
            )
        )
        return SwitchOutcome(
            failure: failure,
            layout: KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)),
            binding9: settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9),
            selected: selected
        )
    }

    private func makeFixture(markerFingerprintMatches: Bool) throws -> RouteFixture {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-wx-route-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("custom-user", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        let source = shared.appendingPathComponent("\(schemaID).schema.yaml")
        try "engine:\n  processors:\n    - speller\n".write(to: source, atomically: true, encoding: .utf8)
        let fingerprint = T9DeploymentSupport.resourceFingerprint(schemaID: schemaID, sharedDataURL: shared)
        let settings = RecordingSettingsStore()
        settings.set(true, forKey: "wanxiang_installed")
        settings.set("wanxiang", forKey: "rime_active_schema")
        settings.set("wanxiang", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        settings.set(schemaID, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        settings.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: schemaID,
            fingerprint: markerFingerprintMatches ? (fingerprint ?? "missing") : "mismatch",
            upstreamVersion: "test",
            settings: settings
        )
        let directories = SchemaDeploymentDirectories(sharedDataURL: shared, userDataURL: user)
        let manager = SchemaManager(
            settings: settings,
            archiveInstaller: WanxiangRouteInstaller(directories: directories)
        )
        return RouteFixture(root: root, shared: shared, user: user, manager: manager)
    }
}

@MainActor
private struct RouteFixture {
    let root: URL
    let shared: URL
    let user: URL
    let manager: SchemaManager
    func cleanup() { try? FileManager.default.removeItem(at: root) }
}

@MainActor
private final class WanxiangRouteInstaller: SchemaArchiveInstalling {
    let directories: SchemaDeploymentDirectories
    init(directories: SchemaDeploymentDirectories) { self.directories = directories }
    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(distribution.cachedArchiveFileName)
    }
    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(distribution.extractionDirectoryName)
    }
    func removeTemporaryItem(at url: URL) {}
    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool { false }
    func checkDiskSpace(needed: Int64) throws {}
    func installSchemaFiles(from extractDir: URL, plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws {}
    func createUpgradeCheckpoint(plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws
        -> SchemaUpgradeCheckpoint?
    { nil }
    func restoreUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) throws {}
    func commitUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) {}
    func stageSchemaUninstall(plan: RimeSchemeInstallationPlan) throws -> SchemaUninstallStaging {
        SchemaUninstallStaging(rootURL: URL(fileURLWithPath: "/tmp/staging"), movedRelativePaths: [])
    }
    func commitSchemaUninstall(_ staging: SchemaUninstallStaging, plan: RimeSchemeInstallationPlan) {}
    func rollbackSchemaUninstall(_ staging: SchemaUninstallStaging) {}
    func clearBuildCache(plan: RimeSchemeInstallationPlan) {}
    func sharedDataDirectoryURL() -> URL? { directories.sharedDataURL }
    func runtimeDirectories() throws -> SchemaDeploymentDirectories { directories }
    func deploymentDirectories(pendingSchemaID: String?) throws -> SchemaDeploymentDirectories { directories }
}
