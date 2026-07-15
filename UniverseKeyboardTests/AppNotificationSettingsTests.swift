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

    func testNotificationServiceGatesDeliveryAndUsesToastPreferenceAsMetadata() async {
        await withDefaults { defaults in
            let client = NotificationClientStub(status: .authorized)
            let service = AppNotificationService(defaults: defaults, client: client)

            await service.notify(.manualStarted)
            XCTAssertTrue(client.requests.isEmpty)

            defaults.set(true, forKey: AppNotificationSettingsStore.StorageKey.notificationsEnabled)
            defaults.set(true, forKey: AppNotificationSettingsStore.StorageKey.rimeSyncEnabled)
            await service.notify(.manualStarted)
            XCTAssertEqual(client.requests.count, 1)
            XCTAssertTrue(client.requests[0].prefersToastWhenForeground)

            defaults.set(false, forKey: AppNotificationSettingsStore.StorageKey.operationToastsEnabled)
            await service.notify(.manualCompleted)
            XCTAssertEqual(client.requests.count, 2)
            XCTAssertFalse(client.requests[1].prefersToastWhenForeground)
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
