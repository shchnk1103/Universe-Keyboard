import KeyboardCore
import SwiftUI
import UIKit
import XCTest

@testable import Universe_Keyboard

@MainActor
final class AppLeafRelocationTests: XCTestCase {
    // MARK: - 双词典文案同步（枚举 case 名不变）

    func testUserDictionarySearchEntryUsesNewDisplayName() throws {
        let item = try catalogItem(id: "userDictionary")
        XCTAssertEqual(item.destination, .userDictionary)
        XCTAssertEqual(item.title, "用户词典")
        XCTAssertEqual(item.subtitle, "备份 / 恢复 / 清空学习记录")
        XCTAssertEqual(item.systemImage, "text.book.closed")
        XCTAssertTrue(SettingsSearchCatalog.matches(query: "用户词典").contains(item))
        XCTAssertTrue(SettingsSearchCatalog.matches(query: "备份").contains(item))
    }

    func testLocalDictionarySearchEntryUsesNewDisplayName() throws {
        let item = try catalogItem(id: "localDictionary")
        XCTAssertEqual(item.destination, .localDictionary)
        XCTAssertEqual(item.title, "词典文件")
        XCTAssertEqual(item.subtitle, "浏览与搜索词典文件")
        XCTAssertEqual(item.systemImage, "doc.text.magnifyingglass")
        XCTAssertTrue(SettingsSearchCatalog.matches(query: "词典文件").contains(item))
    }

    func testDualDictionaryIconsStayDistinguishableAndAllTwentyCasesUnchanged() throws {
        let userDictionary = try catalogItem(id: "userDictionary")
        let localDictionary = try catalogItem(id: "localDictionary")
        XCTAssertNotEqual(userDictionary.systemImage, localDictionary.systemImage)

        let expectedRawValues: Set<String> = [
            "keyboardLayout", "candidateFont", "keyboardHeight", "feedback", "deleteKey",
            "typoCorrection", "typingIntelligence", "rimeSchemes", "advancedInput", "fuzzyPinyin",
            "rimeSync", "userDictionary", "appearance", "notifications", "about", "privacy",
            "openSource", "localDictionary", "diagnostics", "activationHelp",
        ]
        XCTAssertEqual(SettingsSearchCatalog.all.count, 20)
        XCTAssertEqual(
            Set(SettingsSearchCatalog.all.map { $0.destination.rawValue }),
            expectedRawValues
        )
    }

    // MARK: - destination 不变

    func testSearchDestinationMappingsRemainUnchanged() throws {
        XCTAssertEqual(try catalogItem(id: "typoCorrection").destination, .typoCorrection)
        XCTAssertEqual(try catalogItem(id: "diagnostics").destination, .diagnostics)
        XCTAssertEqual(try catalogItem(id: "activationHelp").destination, .activationHelp)
    }

    // MARK: - 设置主页两处词典入口（标题 / 副标题 / 图标）

    func testSettingsHomeDualDictionaryEntriesUseNewDisplayNames() throws {
        XCTAssertEqual(SettingsTabCopy.userDictionaryTitle, "用户词典")
        XCTAssertEqual(SettingsTabCopy.userDictionarySubtitle, "备份 / 恢复 / 清空学习记录")
        XCTAssertEqual(SettingsTabCopy.userDictionarySystemImage, "text.book.closed")

        XCTAssertEqual(SettingsTabCopy.localDictionaryTitle, "词典文件")
        XCTAssertEqual(SettingsTabCopy.localDictionarySubtitle, "浏览与搜索词典文件")
        XCTAssertEqual(SettingsTabCopy.localDictionarySystemImage, "doc.text.magnifyingglass")
    }

    func testSettingsHomeDualDictionaryEntriesMatchSearchCatalog() throws {
        let userDictionary = try catalogItem(id: "userDictionary")
        let localDictionary = try catalogItem(id: "localDictionary")

        // 设置主页与搜索结果必须说同一套名字、同一套图标。
        XCTAssertEqual(SettingsTabCopy.userDictionaryTitle, userDictionary.title)
        XCTAssertEqual(SettingsTabCopy.userDictionarySubtitle, userDictionary.subtitle)
        XCTAssertEqual(SettingsTabCopy.userDictionarySystemImage, userDictionary.systemImage)

        XCTAssertEqual(SettingsTabCopy.localDictionaryTitle, localDictionary.title)
        XCTAssertEqual(SettingsTabCopy.localDictionarySubtitle, localDictionary.subtitle)
        XCTAssertEqual(SettingsTabCopy.localDictionarySystemImage, localDictionary.systemImage)

        XCTAssertNotEqual(
            SettingsTabCopy.userDictionarySystemImage,
            SettingsTabCopy.localDictionarySystemImage
        )
    }

    // MARK: - activationHelp 活链（Button → onOpenActivationGuide）

    func testActivationHelpRowInvokesGuideCallbackInsteadOfNavigation() throws {
        var fired = false
        let tab = makeSearchTab { fired = true }

        tab.activate(try catalogItem(id: "activationHelp"))
        XCTAssertTrue(fired, "点击 activationHelp 行必须触发 onOpenActivationGuide 回调")
    }

    func testActivationIsNoopForNavigableDestinations() throws {
        var fired = false
        let tab = makeSearchTab { fired = true }

        for id in ["typoCorrection", "diagnostics", "userDictionary", "localDictionary", "rimeSync"] {
            tab.activate(try catalogItem(id: id))
        }
        XCTAssertFalse(
            fired,
            "除 activationHelp 外，其余搜索结果由 NavigationLink 导航，不应触发指南回调"
        )
    }

    // MARK: - 实验区三块拆分（Release 可见审计 / DEBUG 内部开关 / RIME 边界留原页）

    func testExperimentalAuditSectionLivesOnDiagnosticsPageNotTypoCorrectionPage() {
        XCTAssertEqual(DiagnosticsSettingsCopy.experimentalAuditSectionTitle, "实验开关审计")
        XCTAssertEqual(DiagnosticsSettingsCopy.developerExperimentSectionTitle, "内部实验开关")

        // 智能纠错页只保留用户功能上下文；两个实验区块都已迁出。
        XCTAssertFalse(
            TypoCorrectionBenchmarkCopy.retainedSectionTitles.contains("实验开关审计")
        )
        XCTAssertFalse(
            TypoCorrectionBenchmarkCopy.retainedSectionTitles.contains("内部实验开关")
        )
        XCTAssertEqual(
            TypoCorrectionBenchmarkCopy.relocatedSectionTitles,
            ["实验开关审计", "内部实验开关"]
        )

        // RIME 边界留在智能纠错页。
        XCTAssertTrue(
            TypoCorrectionBenchmarkCopy.retainedSectionTitles.contains("与 RIME 权重的关系")
        )
        XCTAssertEqual(TypoCorrectionBenchmarkCopy.navigationTitle, "智能纠错")
    }

    func testDeveloperExperimentSectionOnlyCompilesInDebug() {
        #if DEBUG
            XCTAssertEqual(
                DiagnosticsSettingsCopy.developerExperimentToggleTitles,
                ["安全漏字纠错实验", "相邻转置纠错实验"]
            )
        #else
            // Release 构建下诊断页不得出现实验开关控件：开关标题只存在于 Debug 区间。
            XCTAssertTrue(DiagnosticsSettingsCopy.developerExperimentToggleTitles.isEmpty)
        #endif
    }

    func testExperimentalKeyNamesStayUnchanged() {
        XCTAssertEqual(
            TypoCorrectionExperimentalSettings.insertionEnabledKey,
            "typo_experimental_insertion_enabled"
        )
        XCTAssertEqual(
            TypoCorrectionExperimentalSettings.transpositionEnabledKey,
            "typo_experimental_transposition_enabled"
        )
    }

    func testExperimentalKeysAreIgnoredOutsideDebug() {
        let suiteName = "AppLeafRelocationTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.set(true, forKey: TypoCorrectionExperimentalSettings.insertionEnabledKey)
        defaults.set(true, forKey: TypoCorrectionExperimentalSettings.transpositionEnabledKey)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let loaded = TypoCorrectionExperimentalSettings.load(from: defaults)
        #if DEBUG
            XCTAssertTrue(loaded.insertionEnabled)
            XCTAssertTrue(loaded.transpositionEnabled)
        #else
            XCTAssertFalse(loaded.insertionEnabled)
            XCTAssertFalse(loaded.transpositionEnabled)
        #endif
    }

    // MARK: - 云同步页：删通知中心 Nav 入口，保留同步提醒 Picker

    func testSyncPageDropsNotificationCenterEntryAndKeepsReminderPicker() {
        XCTAssertEqual(RimeSyncSettingsCopy.reminderTitle, "同步完成时提醒")
        XCTAssertEqual(RimeSyncSettingsCopy.reminderSectionTitle, "通知与提醒")
        XCTAssertTrue(RimeSyncSettingsCopy.notificationCenterHint.contains("通知总开关在"))
        // 通知中心的统一入口只在「通用 → 通知与提醒」，云同步页不再重复导航入口。
        XCTAssertFalse(
            RimeSyncSettingsCopy.reminderTitle
                .contains(RimeSyncSettingsCopy.removedNotificationCenterEntryTitle)
        )
        XCTAssertFalse(
            RimeSyncSettingsCopy.reminderSectionTitle
                .contains(RimeSyncSettingsCopy.removedNotificationCenterEntryTitle)
        )
    }

    // MARK: - 叶子页标题

    func testLeafNavigationTitlesUseRenamedDictionaries() {
        XCTAssertEqual(RimeUserDictionarySettingsCopy.navigationTitle, "用户词典")
        XCTAssertEqual(DictionaryBrowserCopy.navigationTitle, "词典文件")
    }

    // MARK: - Helpers

    private func catalogItem(id: String) throws -> SettingsSearchItem {
        let entries = SettingsSearchCatalog.all.filter { $0.id == id }
        XCTAssertEqual(entries.count, 1, "目录中应恰好存在一个 \(id) 条目")
        return try XCTUnwrap(entries.first)
    }

    private func makeNotificationSettings() -> AppNotificationSettingsModel {
        let defaults =
            UserDefaults(suiteName: "AppLeafRelocationTests.\(UUID().uuidString)") ?? .standard
        return AppNotificationSettingsModel(
            defaults: defaults,
            diagnosticsDefaults: defaults,
            client: NoopNotificationClient()
        )
    }

    private func makeSearchTab(
        initialQuery: String = "",
        onOpenActivationGuide: (() -> Void)? = nil
    ) -> SearchTab {
        let rimeStore = RimeSettingsStore()
        let defaults =
            UserDefaults(suiteName: "AppLeafRelocationTests.\(UUID().uuidString)") ?? .standard
        return SearchTab(
            rimeStore: rimeStore,
            syncModel: RimeSyncViewModel(rimeStore: rimeStore, defaults: defaults),
            notificationSettings: makeNotificationSettings(),
            onOpenActivationGuide: onOpenActivationGuide,
            initialQuery: initialQuery
        )
    }
}

@MainActor
private final class NoopNotificationClient: AppNotificationClient {
    func authorizationStatus() async -> AppNotificationAuthorizationStatus { .authorized }
    func requestAuthorization() async throws -> Bool { true }
    func schedule(_ request: AppLocalNotificationRequest) async throws {}
    func cancelPendingNotification(identifier: String) async {}
}
