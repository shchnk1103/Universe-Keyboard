import XCTest

@MainActor
final class RimeSyncSettingsUITests: XCTestCase {
    func testUnconfiguredSyncSettingsExposeCoreSections() {
        let app = launchSyncSettings()

        XCTAssertTrue(app.staticTexts["RIME 云同步"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["同步状态"].exists)
        XCTAssertTrue(app.staticTexts["同步方式"].exists)
        XCTAssertTrue(app.staticTexts["同步内容"].exists)
        XCTAssertTrue(app.staticTexts["Universe 私密设置"].exists)
        XCTAssertFalse(app.staticTexts["自动同步"].exists)
    }

    func testLocalFolderConfigurationShowsAutomaticSyncControls() {
        let app = XCUIApplication()
        prepareSyncSettingsLaunch(app, argument: "--rime-sync-ui-local-folder")
        app.launch()

        dismissWelcomeIfNeeded(in: app)
        app.tabBars.buttons["设置"].tap()
        app.swipeUp()
        app.buttons.containing(.staticText, identifier: "RIME 云同步").firstMatch.tap()

        XCTAssertTrue(app.staticTexts["自动同步"].waitForExistence(timeout: 10))
        for control in ["自动同步", "RIME 标准同步", "Universe 设置同步", "同步间隔"] {
            XCTAssertTrue(scrollToStaticText(control, in: app))
        }
    }

    func testUnconfiguredLocalFolderCanOpenAndCancelSystemPicker() {
        let app = launchSyncSettings(argument: "--rime-sync-ui-local-folder-picker")

        let chooseFolderButton = app.buttons["选择"]
        XCTAssertTrue(scrollToElement(chooseFolderButton, in: app))
        chooseFolderButton.tap()

        // iOS 27 exposes the document picker's Cancel control as a generic
        // accessibility element rather than a Button.
        let cancelControl = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", "Cancel"))
            .firstMatch
        XCTAssertTrue(cancelControl.waitForExistence(timeout: 10), app.debugDescription)
        cancelControl.tap()

        XCTAssertTrue(app.staticTexts["同步方式"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["立即同步"].exists)
    }

    func testLocalFolderPickerCreatesIsolatedFolderAndCompletesFirstSync() {
        let app = launchSyncSettings(argument: "--rime-sync-ui-local-folder-integration")
        let folderSuffix = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            .prefix(8)
            .map { character in
                guard let digit = character.hexDigitValue else {
                    return String(character).lowercased()
                }
                return String(UnicodeScalar(97 + digit)!)
            }
            .joined()
        let folderName = "UniverseRimeSync\(folderSuffix)"

        let filesApp = XCUIApplication(bundleIdentifier: "com.apple.DocumentsApp")
        filesApp.launch()
        let filesBrowseTab = filesApp.tabBars.buttons["浏览"]
        if filesBrowseTab.waitForExistence(timeout: 5) {
            filesBrowseTab.tap()
        }

        let refreshedFilesLocation = filesApp.cells.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "iPhone")
        ).firstMatch
        XCTAssertTrue(refreshedFilesLocation.waitForExistence(timeout: 10), filesApp.debugDescription)
        refreshedFilesLocation.tap()

        let filesMoreButton = filesApp.buttons.matching(
            NSPredicate(format: "label IN %@", ["更多", "More"])
        ).firstMatch
        XCTAssertTrue(filesMoreButton.waitForExistence(timeout: 10), filesApp.debugDescription)
        filesMoreButton.tap()

        let filesCreateFolderButton = filesApp.buttons.matching(
            NSPredicate(format: "label IN %@", ["新建文件夹", "New Folder"])
        ).firstMatch
        XCTAssertTrue(filesCreateFolderButton.waitForExistence(timeout: 5), filesApp.debugDescription)
        filesCreateFolderButton.tap()

        let filesFolderNameField = filesApp.textViews["DOC.inlineRenameField"]
        XCTAssertTrue(filesFolderNameField.waitForExistence(timeout: 5), filesApp.debugDescription)
        filesFolderNameField.tap()
        filesFolderNameField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 6))
        for character in folderName {
            filesFolderNameField.typeText(String(character))
        }
        XCTAssertEqual((filesFolderNameField.value as? String)?.lowercased(), folderName.lowercased())
        filesApp.keyboards.descendants(matching: .any)["Done"].tap()
        XCTAssertTrue(
            filesApp.descendants(matching: .any).matching(
                NSPredicate(format: "label CONTAINS %@", folderName)
            ).firstMatch.waitForExistence(timeout: 5),
            filesApp.debugDescription
        )

        app.activate()
        let providerPicker = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "同步方式")
        ).firstMatch
        XCTAssertTrue(scrollToElement(providerPicker, in: app), app.debugDescription)
        providerPicker.tap()

        let localFolderOption = app.buttons["RIME 标准文件夹"]
        XCTAssertTrue(localFolderOption.waitForExistence(timeout: 5), app.debugDescription)
        localFolderOption.tap()

        let browseButton = app.tabBars.buttons["浏览"]
        XCTAssertTrue(browseButton.waitForExistence(timeout: 10), app.debugDescription)
        browseButton.tap()

        let onDeviceLocation = app.cells.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "iPhone")
        ).firstMatch
        XCTAssertTrue(onDeviceLocation.waitForExistence(timeout: 10), app.debugDescription)
        onDeviceLocation.tap()
        XCTAssertTrue(
            app.descendants(matching: .any).matching(
                NSPredicate(format: "label CONTAINS %@", folderName)
            ).firstMatch.waitForExistence(timeout: 10),
            app.debugDescription
        )

        let createdFolder = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", folderName)
        ).firstMatch
        XCTAssertTrue(createdFolder.waitForExistence(timeout: 10), app.debugDescription)
        createdFolder.tap()

        let openFolderButton = app.buttons.matching(
            NSPredicate(format: "label IN %@", ["打开", "Open"])
        ).firstMatch
        XCTAssertTrue(openFolderButton.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(openFolderButton.isEnabled)
        openFolderButton.tap()

        let syncButton = app.buttons["立即同步"]
        for _ in 0..<8 {
            if syncButton.isHittable { break }
            app.swipeDown()
        }
        XCTAssertTrue(syncButton.isHittable, app.debugDescription)
        syncButton.tap()

        let confirmation = app.alerts["同步 RIME 数据？"]
        XCTAssertTrue(confirmation.waitForExistence(timeout: 5), app.debugDescription)
        confirmation.buttons["开始同步"].tap()

        let successStatus = app.staticTexts["同步正常"]
        XCTAssertTrue(successStatus.waitForExistence(timeout: 90), app.debugDescription)
        XCTAssertTrue(
            app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", folderName)
            ).firstMatch.exists
        )

    }

    func testUnconfiguredSyncSettingsStayReachableInDarkLargeText() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-uiuserInterfaceStyle", "dark",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL",
        ]
        prepareSyncSettingsLaunch(app, argument: "--rime-sync-ui-unconfigured")
        app.launch()

        dismissWelcomeIfNeeded(in: app)
        app.tabBars.buttons["设置"].tap()
        app.swipeUp()
        app.buttons.containing(.staticText, identifier: "RIME 云同步").firstMatch.tap()

        XCTAssertTrue(app.staticTexts["RIME 云同步"].waitForExistence(timeout: 10))
        for section in ["同步方式", "同步内容", "Universe 私密设置"] {
            XCTAssertTrue(scrollToStaticText(section, in: app))
        }
    }

    func testWebDAVSettingsExplainPrivateScopeAndConfirmDeletionBeforeActing() {
        let app = launchSyncSettings(argument: "--rime-sync-ui-webdav")

        let firstTextField = app.textFields.firstMatch
        XCTAssertTrue(scrollToElement(firstTextField, in: app))
        XCTAssertGreaterThanOrEqual(app.textFields.count, 2)
        XCTAssertGreaterThanOrEqual(app.secureTextFields.count, 1)

        let privateSettingsRow = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS %@", "Universe RIME 设置")
        ).firstMatch
        XCTAssertTrue(scrollToElement(privateSettingsRow, in: app))
        let privacyFooter = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS %@", "当前不会上传你的输入习惯")
        ).firstMatch
        XCTAssertTrue(scrollToElement(privacyFooter, in: app))

        let remoteDeleteButton = app.buttons["删除云端数据并断开"]
        XCTAssertTrue(scrollToElement(remoteDeleteButton, in: app))
        remoteDeleteButton.tap()

        let deletionAlert = app.alerts["删除云端同步数据？"]
        XCTAssertTrue(deletionAlert.waitForExistence(timeout: 5))
        XCTAssertTrue(
            deletionAlert.staticTexts[
                "这只会删除当前同步位置中的 universe-rime-sync 加密设置包，并清除本机同步密钥。RIME 标准同步目录和其他设备数据不会被删除。"
            ].exists
        )
        deletionAlert.buttons["取消"].tap()

        let disconnectButton = app.buttons["断开本机同步"]
        XCTAssertTrue(scrollToElement(disconnectButton, in: app))
        disconnectButton.tap()

        let disconnectAlert = app.alerts["断开同步？"]
        XCTAssertTrue(disconnectAlert.waitForExistence(timeout: 5))
        XCTAssertTrue(
            disconnectAlert.staticTexts[
                "本机将停止 Universe 私密设置同步。已生成的 RIME 标准同步目录和其他设备数据会保留。"
            ].exists
        )
        disconnectAlert.buttons["取消"].tap()
    }

    func testFolderBookmarkRepairExplainsSyncIsPaused() {
        let app = launchSyncSettings(argument: "--rime-sync-ui-folder-repair")

        let pausedWarning = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS %@", "同步已暂停")
        )
        XCTAssertTrue(scrollToElement(pausedWarning.firstMatch, in: app))
        XCTAssertTrue(app.buttons["重新选择同步文件夹"].exists)

        let automaticSyncToggle = app.switches["自动同步"]
        XCTAssertTrue(scrollToElement(automaticSyncToggle, in: app))
        XCTAssertFalse(automaticSyncToggle.isEnabled)
    }

    func testSucceededAndConflictStatusesAreDistinct() {
        let succeededApp = launchSyncSettings(argument: "--rime-sync-ui-status-succeeded")
        XCTAssertTrue(scrollToStaticText("同步正常", in: succeededApp))
        XCTAssertTrue(
            succeededApp.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "RIME 用户资料与私密设置已同步")
            ).firstMatch.exists
        )

        succeededApp.terminate()
        let conflictApp = launchSyncSettings(argument: "--rime-sync-ui-status-conflict")
        XCTAssertTrue(scrollToStaticText("需要处理", in: conflictApp))
        XCTAssertTrue(
            conflictApp.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "其他设备正在更新，请稍后重试。")
            ).firstMatch.exists
        )
    }

    func testCorruptedPackageStatusOffersRecoveryCodeImport() {
        let app = launchSyncSettings(argument: "--rime-sync-ui-status-corrupted")
        XCTAssertTrue(scrollToStaticText("需要处理", in: app))
        XCTAssertTrue(
            app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "云端数据损坏或密钥不匹配。")
            ).firstMatch.exists
        )

        let recoveryCodeField = app.secureTextFields["输入另一台设备的恢复码"]
        XCTAssertTrue(scrollToElement(recoveryCodeField, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["导入恢复码"], in: app))
    }

    func testMalformedRecoveryCodeShowsValidationError() {
        let app = launchSyncSettings()
        let recoveryCodeField = app.secureTextFields.firstMatch
        XCTAssertTrue(scrollToElement(recoveryCodeField, in: app))
        recoveryCodeField.tap()
        recoveryCodeField.typeText("not-a-recovery-code")

        let importButton = app.buttons["导入恢复码"]
        XCTAssertTrue(importButton.isEnabled)
        importButton.tap()

        let statusTitle = app.staticTexts["需要处理"]
        for _ in 0..<8 {
            if statusTitle.isHittable { break }
            // The status section precedes the recovery-code field in the Form.
            app.swipeDown()
        }
        XCTAssertTrue(statusTitle.isHittable)
        let validationError = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS %@", "恢复码无效，请检查后重试")
        ).firstMatch
        XCTAssertTrue(validationError.waitForExistence(timeout: 5))
    }

    func testWebDAVAuthenticationFailureAppearsAfterSyncAttempt() {
        let app = launchSyncSettings(argument: "--rime-sync-ui-authentication-failure")

        let syncButton = app.buttons["立即同步"]
        XCTAssertTrue(scrollToElement(syncButton, in: app))
        syncButton.tap()

        let authenticationError = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS %@", "WebDAV 认证失败，请检查账号和权限。")
        ).firstMatch
        XCTAssertTrue(authenticationError.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["需要处理"].exists)
    }

    func testValidButMismatchedRecoveryCodeCanBeReplacedAndReportsWrongKey() {
        let app = launchSyncSettings(argument: "--rime-sync-ui-wrong-key")

        let importExistingCode = app.buttons["使用已有恢复码"]
        if importExistingCode.exists {
            XCTAssertTrue(scrollToElement(importExistingCode, in: app))
            importExistingCode.tap()
        }

        let recoveryCodeField = app.secureTextFields["输入另一台设备的恢复码"]
        XCTAssertTrue(scrollToElement(recoveryCodeField, in: app))
        recoveryCodeField.tap()
        recoveryCodeField.typeText("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
        app.buttons["导入恢复码"].tap()

        XCTAssertTrue(app.buttons["保存恢复码"].waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToStaticTextFromBottom("同步已配置", in: app))

        let syncButton = app.buttons["立即同步"]
        XCTAssertTrue(scrollToElement(syncButton, in: app))
        syncButton.tap()

        let wrongKeyError = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS %@", "云端数据损坏或密钥不匹配。")
        ).firstMatch
        XCTAssertTrue(wrongKeyError.waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToStaticTextFromBottom("需要处理", in: app))
    }

    func testDisconnectConfirmationCompletesLocalDisconnect() {
        let app = launchSyncSettings(argument: "--rime-sync-ui-webdav")

        let disconnectButton = app.buttons["断开本机同步"]
        XCTAssertTrue(scrollToElement(disconnectButton, in: app))
        disconnectButton.tap()
        app.alerts["断开同步？"].buttons["断开"].tap()

        XCTAssertTrue(scrollToStaticTextFromBottom("尚未配置", in: app))
        XCTAssertFalse(app.buttons["断开本机同步"].exists)
    }

    func testRemoteDeletionConfirmationCompletesWithFakeTransport() {
        let app = launchSyncSettings(argument: "--rime-sync-ui-webdav")

        let deleteButton = app.buttons["删除云端数据并断开"]
        XCTAssertTrue(scrollToElement(deleteButton, in: app))
        deleteButton.tap()
        app.alerts["删除云端同步数据？"].buttons["删除并断开"].tap()

        XCTAssertTrue(scrollToStaticTextFromBottom("尚未配置", in: app))
        XCTAssertFalse(app.buttons["删除云端数据并断开"].exists)
    }

    func testRemoteDeletionFailureKeepsConfigurationAndShowsError() {
        let app = launchSyncSettings(argument: "--rime-sync-ui-deletion-failure")

        let deleteButton = app.buttons["删除云端数据并断开"]
        XCTAssertTrue(scrollToElement(deleteButton, in: app))
        deleteButton.tap()
        app.alerts["删除云端同步数据？"].buttons["删除并断开"].tap()

        XCTAssertTrue(
            app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "WebDAV 认证失败，请检查账号和权限。")
            ).firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToElement(app.buttons["删除云端数据并断开"], in: app))
        XCTAssertTrue(scrollToStaticTextFromBottom("需要处理", in: app))
    }

    private func launchSyncSettings(argument: String = "--rime-sync-ui-unconfigured") -> XCUIApplication {
        let app = XCUIApplication()
        prepareSyncSettingsLaunch(app, argument: argument)
        app.launch()
        dismissWelcomeIfNeeded(in: app)
        app.tabBars.buttons["设置"].tap()
        app.swipeUp()
        app.buttons.containing(.staticText, identifier: "RIME 云同步").firstMatch.tap()
        return app
    }

    private func prepareSyncSettingsLaunch(_ app: XCUIApplication, argument: String) {
        app.launchArguments += [
            argument,
            "--rime-sync-ui-defaults-suite",
            "rime-sync-ui-\(UUID().uuidString)",
        ]
    }

    private func dismissWelcomeIfNeeded(in app: XCUIApplication) {
        let deferButton = app.buttons["稍后再说"]
        if deferButton.waitForExistence(timeout: 2) {
            deferButton.tap()
        }
    }

    private func scrollToStaticText(_ value: String, in app: XCUIApplication) -> Bool {
        let text = app.staticTexts[value]
        for _ in 0..<8 {
            if text.exists { return true }
            app.swipeUp()
        }
        return text.exists
    }

    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication) -> Bool {
        for _ in 0..<8 {
            if element.exists, element.isHittable { return true }
            app.swipeUp()
        }
        return element.exists && element.isHittable
    }

    private func scrollToStaticTextFromBottom(_ value: String, in app: XCUIApplication) -> Bool {
        let text = app.staticTexts[value]
        for _ in 0..<8 {
            if text.exists, text.isHittable { return true }
            app.swipeDown()
        }
        return text.exists && text.isHittable
    }
}
