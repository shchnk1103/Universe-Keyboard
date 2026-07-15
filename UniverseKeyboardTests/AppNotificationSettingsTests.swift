import Foundation
import UserNotifications
import XCTest

@testable import Universe_Keyboard

@MainActor
final class AppNotificationSettingsTests: XCTestCase {
    func testNewUserDefaultsToNotificationsOffAndOperationToastsOn() {
        withDefaults { defaults in
            let client = NotificationClientStub(status: .notDetermined)
            let model = AppNotificationSettingsModel(defaults: defaults, client: client)

            XCTAssertFalse(model.notificationsEnabled)
            XCTAssertFalse(model.isCategorySelected(.rimeSync))
            XCTAssertFalse(model.isRimeSyncScopeSelected(.standardRimeData))
            XCTAssertFalse(model.isRimeSyncScopeSelected(.privateSettings))
            XCTAssertTrue(model.operationToastsEnabled)
        }
    }

    func testLegacyRimeSelectionMigratesMasterOnlyWhenSystemCanDeliver() async {
        await withDefaults { defaults in
            defaults.set(true, forKey: AppNotificationSettingsStore.StorageKey.rimeSyncEnabled)
            let model = AppNotificationSettingsModel(
                defaults: defaults,
                client: NotificationClientStub(status: .authorized)
            )

            await model.refreshAuthorizationStatus()

            XCTAssertTrue(model.notificationsEnabled)
            XCTAssertTrue(model.isCategoryEnabled(.rimeSync))
            XCTAssertTrue(model.isRimeSyncScopeSelected(.standardRimeData))
            XCTAssertTrue(model.isRimeSyncScopeSelected(.privateSettings))
        }

        await withDefaults { defaults in
            defaults.set(true, forKey: AppNotificationSettingsStore.StorageKey.rimeSyncEnabled)
            let model = AppNotificationSettingsModel(
                defaults: defaults,
                client: NotificationClientStub(status: .denied)
            )

            await model.refreshAuthorizationStatus()

            XCTAssertFalse(model.notificationsEnabled)
            XCTAssertTrue(model.isCategorySelected(.rimeSync))
        }
    }

    func testEnablingMasterRequestsPermissionAndSelectsDefaultCategory() async {
        await withDefaults { defaults in
            let client = NotificationClientStub(
                status: .notDetermined,
                statusAfterRequest: .authorized,
                requestResult: true
            )
            let model = AppNotificationSettingsModel(defaults: defaults, client: client)

            await model.setNotificationsEnabled(true)

            XCTAssertEqual(client.requestCount, 1)
            XCTAssertTrue(model.notificationsEnabled)
            XCTAssertTrue(model.isCategorySelected(.rimeSync))
            XCTAssertTrue(model.isRimeSyncScopeSelected(.standardRimeData))
            XCTAssertTrue(model.isRimeSyncScopeSelected(.privateSettings))
        }
    }

    func testDeniedPermissionTurnsMasterOffButPreservesCategorySelection() async {
        await withDefaults { defaults in
            let client = NotificationClientStub(
                status: .notDetermined,
                statusAfterRequest: .denied,
                requestResult: false
            )
            let model = AppNotificationSettingsModel(defaults: defaults, client: client)

            await model.setCategorySelected(true, category: .rimeSync)

            XCTAssertFalse(model.notificationsEnabled)
            XCTAssertTrue(model.isCategorySelected(.rimeSync))
            XCTAssertEqual(model.authorizationStatus, .denied)
        }
    }

    func testProvisionalAndEphemeralAuthorizationCanDeliver() async {
        for status in [
            AppNotificationAuthorizationStatus.provisional,
            AppNotificationAuthorizationStatus.ephemeral,
        ] {
            await withDefaults { defaults in
                defaults.set(true, forKey: AppNotificationSettingsStore.StorageKey.rimeSyncEnabled)
                let model = AppNotificationSettingsModel(
                    defaults: defaults,
                    client: NotificationClientStub(status: status)
                )

                await model.refreshAuthorizationStatus()

                XCTAssertTrue(model.notificationsEnabled)
                XCTAssertTrue(model.isCategoryEnabled(.rimeSync))
            }
        }
    }

    func testMasterOffPreservesCategoryAndReauthorizationDoesNotEnableItAgain() async {
        await withDefaults { defaults in
            let client = NotificationClientStub(status: .authorized)
            let model = AppNotificationSettingsModel(defaults: defaults, client: client)
            await model.setNotificationsEnabled(true)
            await model.setNotificationsEnabled(false)

            XCTAssertFalse(model.notificationsEnabled)
            XCTAssertTrue(model.isCategorySelected(.rimeSync))

            client.status = .denied
            await model.refreshAuthorizationStatus()
            client.status = .authorized
            await model.refreshAuthorizationStatus()

            XCTAssertFalse(model.notificationsEnabled)
            XCTAssertTrue(model.isCategorySelected(.rimeSync))
        }
    }

    func testClosingLastCategoryAlsoClosesMasterAndBothEntrypointsShareState() async {
        await withDefaults { defaults in
            let client = NotificationClientStub(status: .authorized)
            let globalPageModel = AppNotificationSettingsModel(defaults: defaults, client: client)
            let rimePageModel = AppNotificationSettingsModel(defaults: defaults, client: client)

            await globalPageModel.setNotificationsEnabled(true)
            XCTAssertTrue(rimePageModel.isCategorySelected(.rimeSync))

            await rimePageModel.setCategorySelected(false, category: .rimeSync)
            await globalPageModel.refreshAuthorizationStatus()

            XCTAssertFalse(globalPageModel.notificationsEnabled)
            XCTAssertFalse(rimePageModel.isCategorySelected(.rimeSync))
        }
    }

    func testRimeNotificationScopesAreIndependentAndLastScopeClosesParent() async {
        await withDefaults { defaults in
            let client = NotificationClientStub(status: .authorized)
            let model = AppNotificationSettingsModel(defaults: defaults, client: client)
            defaults.set(true, forKey: RimeSyncStorageKey.automaticSyncEnabled)
            defaults.set(false, forKey: RimeSyncStorageKey.automaticStandardRimeDataEnabled)
            defaults.set(true, forKey: RimeSyncStorageKey.automaticPrivateSettingsEnabled)

            await model.setCategorySelected(true, category: .rimeSync)
            await model.setRimeSyncScopeSelected(false, scope: .standardRimeData)

            XCTAssertTrue(model.notificationsEnabled)
            XCTAssertTrue(model.isCategoryEnabled(.rimeSync))
            XCTAssertFalse(model.isRimeSyncScopeSelected(.standardRimeData))
            XCTAssertTrue(model.isRimeSyncScopeSelected(.privateSettings))

            await model.setRimeSyncScopeSelected(false, scope: .privateSettings)

            XCTAssertFalse(model.notificationsEnabled)
            XCTAssertFalse(model.isCategorySelected(.rimeSync))
            XCTAssertFalse(model.isRimeSyncScopeSelected(.standardRimeData))
            XCTAssertFalse(model.isRimeSyncScopeSelected(.privateSettings))
            XCTAssertTrue(defaults.bool(forKey: RimeSyncStorageKey.automaticSyncEnabled))
            XCTAssertFalse(defaults.bool(forKey: RimeSyncStorageKey.automaticStandardRimeDataEnabled))
            XCTAssertTrue(defaults.bool(forKey: RimeSyncStorageKey.automaticPrivateSettingsEnabled))

            await model.setCategorySelected(true, category: .rimeSync)
            XCTAssertTrue(model.isRimeSyncScopeSelected(.standardRimeData))
            XCTAssertTrue(model.isRimeSyncScopeSelected(.privateSettings))
        }
    }

    func testNotificationServiceGatesDeliveryAndUsesToastPreferenceAsMetadata() async {
        await withDefaults { defaults in
            let client = NotificationClientStub(status: .authorized)
            let service = AppNotificationService(defaults: defaults, client: client)

            let startedEvent = RimeSyncNotificationEvent.phaseStarted(
                mode: .manual,
                scope: .standardRimeData,
                completedScopes: [],
                pendingScopes: [.privateSettings]
            )
            await service.notify(startedEvent)
            XCTAssertTrue(client.requests.isEmpty)

            defaults.set(true, forKey: AppNotificationSettingsStore.StorageKey.notificationsEnabled)
            defaults.set(true, forKey: AppNotificationSettingsStore.StorageKey.rimeSyncEnabled)
            await service.notify(startedEvent)
            XCTAssertEqual(client.requests.count, 1)
            XCTAssertTrue(client.requests[0].prefersToastWhenForeground)
            XCTAssertTrue(client.requests[0].body.contains("RIME 常用词、标准资料和 Universe App 设置"))

            defaults.set(false, forKey: AppNotificationSettingsStore.StorageKey.operationToastsEnabled)
            await service.notify(
                .completed(
                    mode: .manual,
                    scopes: [.standardRimeData, .privateSettings]
                )
            )
            XCTAssertEqual(client.requests.count, 2)
            XCTAssertFalse(client.requests[1].prefersToastWhenForeground)
        }
    }

    func testNotificationServiceSkipsUnselectedRimeScope() async {
        await withDefaults { defaults in
            let client = NotificationClientStub(status: .authorized)
            let service = AppNotificationService(defaults: defaults, client: client)
            defaults.set(true, forKey: AppNotificationSettingsStore.StorageKey.notificationsEnabled)
            defaults.set(true, forKey: AppNotificationSettingsStore.StorageKey.rimeSyncEnabled)
            defaults.set(false, forKey: AppNotificationSettingsStore.StorageKey.rimeStandardSyncEnabled)
            defaults.set(true, forKey: AppNotificationSettingsStore.StorageKey.rimePrivateSettingsEnabled)

            await service.notify(
                .phaseStarted(
                    mode: .automatic,
                    scope: .standardRimeData,
                    completedScopes: [],
                    pendingScopes: [.privateSettings]
                )
            )
            XCTAssertTrue(client.requests.isEmpty)

            await service.notify(
                .phaseStarted(
                    mode: .automatic,
                    scope: .privateSettings,
                    completedScopes: [.standardRimeData],
                    pendingScopes: []
                )
            )
            XCTAssertEqual(client.requests.count, 1)
            XCTAssertTrue(client.requests[0].body.contains("Universe App 设置"))
        }
    }

    func testToastTogglePersistsWithoutReplayingAnyPreviousState() {
        withDefaults { defaults in
            let model = AppNotificationSettingsModel(
                defaults: defaults,
                client: NotificationClientStub(status: .authorized)
            )

            model.setOperationToastsEnabled(false)
            XCTAssertFalse(model.operationToastsEnabled)
            XCTAssertFalse(defaults.bool(forKey: AppNotificationSettingsStore.StorageKey.operationToastsEnabled))

            model.setOperationToastsEnabled(true)
            XCTAssertTrue(model.operationToastsEnabled)
            XCTAssertNil(model.notice)
        }
    }

    func testForegroundToastPrioritySuppressesBannerAndSoundOnlyForKnownEvents() {
        let toastOptions = AppNotificationForegroundPresentationPolicy.options(
            hasKnownCategory: true,
            prefersToast: true
        )
        XCTAssertEqual(toastOptions, [.list])

        let bannerOptions = AppNotificationForegroundPresentationPolicy.options(
            hasKnownCategory: true,
            prefersToast: false
        )
        XCTAssertTrue(bannerOptions.contains(.banner))
        XCTAssertTrue(bannerOptions.contains(.list))
        XCTAssertTrue(bannerOptions.contains(.sound))

        let futureCategoryOptions = AppNotificationForegroundPresentationPolicy.options(
            hasKnownCategory: false,
            prefersToast: true
        )
        XCTAssertTrue(futureCategoryOptions.contains(.banner))
        XCTAssertTrue(futureCategoryOptions.contains(.sound))
    }

    private func withDefaults(_ body: (UserDefaults) throws -> Void) rethrows {
        let suiteName = "AppNotificationSettingsTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        try body(defaults)
    }

    private func withDefaults(
        _ body: (UserDefaults) async throws -> Void
    ) async rethrows {
        let suiteName = "AppNotificationSettingsTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        try await body(defaults)
    }
}

@MainActor
private final class NotificationClientStub: AppNotificationClient {
    var status: AppNotificationAuthorizationStatus
    private let statusAfterRequest: AppNotificationAuthorizationStatus
    private let requestResult: Bool

    private(set) var requestCount = 0
    private(set) var requests: [AppLocalNotificationRequest] = []

    init(
        status: AppNotificationAuthorizationStatus,
        statusAfterRequest: AppNotificationAuthorizationStatus? = nil,
        requestResult: Bool = true
    ) {
        self.status = status
        self.statusAfterRequest = statusAfterRequest ?? status
        self.requestResult = requestResult
    }

    func authorizationStatus() async -> AppNotificationAuthorizationStatus {
        status
    }

    func requestAuthorization() async throws -> Bool {
        requestCount += 1
        status = statusAfterRequest
        return requestResult
    }

    func schedule(_ request: AppLocalNotificationRequest) async throws {
        requests.append(request)
    }
}
