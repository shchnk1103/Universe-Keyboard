import KeyboardCore
import RimeBridge
import SwiftUI
import XCTest

@testable import Universe_Keyboard

/// PB-015-PR4 structural consolidation acceptance tests (`PB-015-PR4-IMPL-001`, M8).
///
/// Pins the post-consolidation main-App Settings IA:
/// - all 20 Search destinations resolve (19 real pages + `activationHelp` via the
///   guide callback, never navigation);
/// - the root Settings page renders exactly 4 groups (12 Nav rows + 5 toggle cards)
///   with the relocated entries removed from the root manifest;
/// - the candidate-count / default-simplified trigger chain stays frozen on
///   `savePreferences()` + `triggerDeployment()` with keys `rime_page_size` /
///   `rime_simplification` (design r2 §4);
/// - 「显示与外观」 hosts the relocated keyboard-height / candidate-font entries;
/// - the diagnostics entry lives inside the About page.
@MainActor
final class AppPR4StructuralConsolidationTests: XCTestCase {
    // MARK: - 20 Search destination traversal

    func testAllNineteenNavigableSearchDestinationsResolveToTheirRealPages() {
        let tab = makeSearchTab()
        let expectations: [(SettingsSearchItem.Destination, String)] = [
            (.keyboardLayout, "KeyboardLayoutSettingsView"),
            (.candidateFont, "CandidateFontSettingsView"),
            (.keyboardHeight, "KeyboardHeightSettingsView"),
            (.feedback, "FeedbackSettingsView"),
            (.deleteKey, "DeleteKeySettingsView"),
            (.typoCorrection, "TypoCorrectionBenchmarkView"),
            (.typingIntelligence, "TypingIntelligenceView"),
            (.rimeSchemes, "RimeSettingsView"),
            (.advancedInput, "RimeAdvancedInputSettingsView"),
            (.fuzzyPinyin, "RimeFuzzyPinyinSettingsView"),
            (.rimeSync, "RimeSyncSettingsView"),
            (.userDictionary, "RimeUserDictionarySettingsView"),
            (.appearance, "AppearanceSettingsView"),
            (.notifications, "NotificationSettingsView"),
            (.about, "AboutSettingsView"),
            (.privacy, "PrivacyDataView"),
            (.openSource, "OpenSourceLicensesView"),
            (.localDictionary, "DictionaryBrowserView"),
            (.diagnostics, "DiagnosticsSettingsView"),
        ]
        XCTAssertEqual(expectations.count, 19, "非 activationHelp 的 destination 应恰好 19 个")
        XCTAssertEqual(SettingsSearchCatalog.all.count, 20)

        for (destination, expectedTypeName) in expectations {
            let leafName = concreteTypeName(tab.destinationView(for: destination))
            XCTAssertEqual(
                leafName,
                expectedTypeName,
                "destination \(destination.rawValue) 的深链目的地应为 \(expectedTypeName)"
            )
        }
    }

    func testActivationHelpDestinationStaysACallbackPathNotANavigationTarget() {
        let tab = makeSearchTab()
        // `.activationHelp` keeps the design r2 §1.2 contract: the search row renders a
        // Button that calls `onOpenActivationGuide`; `destinationView` only keeps an
        // EmptyView placeholder for switch completeness.
        XCTAssertEqual(concreteTypeName(tab.destinationView(for: .activationHelp)), "EmptyView")

        var firedCount = 0
        let observingTab = makeSearchTab { firedCount += 1 }
        let items = SettingsSearchCatalog.all
        XCTAssertEqual(items.count, 20)
        for item in items {
            observingTab.activate(item)
        }
        XCTAssertEqual(firedCount, 1, "20 条搜索结果中只有 activationHelp 允许触发指南回调")
    }

    func testAppearanceCatalogEntryMatchesRenamedDisplayAppearancePage() throws {
        let item = try catalogItem(id: "appearance")
        XCTAssertEqual(item.destination, .appearance)
        XCTAssertEqual(item.title, "显示与外观")
    }

    // MARK: - Root page: 4-group layout (M1)

    func testRootLayoutHasExactlyFourGroupsInFrozenOrder() {
        XCTAssertEqual(
            SettingsRootLayout.groupTitles,
            ["打字习惯", "输入方案", "数据与工具", "通用"],
            "根页信息架构定为 4 组（设计 r1 §1.1）"
        )
    }

    func testRootLayoutKeepsTwelveNavigationRowsAndFiveToggleCards() {
        XCTAssertEqual(SettingsRootLayout.groups.count, 4)
        XCTAssertEqual(
            SettingsRootLayout.groups.flatMap(\.navigationTitles),
            [
                // 打字习惯
                "键盘布局", "键盘反馈", "删除键",
                // 输入方案
                "RIME 方案设置", "用户词典",
                // 数据与工具
                "RIME 云同步", "词典文件",
                // 通用
                "显示与外观", "通知与提醒", "智能纠错", "输入洞察", "关于",
            ],
            "根页 12 条 Nav 行按 4 组固定顺序排列（A-08 口径）"
        )
        XCTAssertEqual(
            SettingsRootLayout.groups.flatMap(\.toggleCardTitles),
            [
                "显示剪贴板预览", "上屏后联想", "中英混排自动加空格",
                "英文候选自动补空格", "成对符号自动匹配",
            ],
            "根页保留 5 张内联开关卡，全部属于打字习惯组"
        )
        XCTAssertEqual(SettingsRootLayout.groups[0].toggleCardTitles.count, 5)
        XCTAssertEqual(SettingsRootLayout.groups[0].navigationTitles.count, 3)
    }

    func testRelocatedEntriesNoLongerAppearOnRootPage() {
        let navTitles = Set(SettingsRootLayout.groups.flatMap(\.navigationTitles))
        let cardTitles = Set(SettingsRootLayout.groups.flatMap(\.toggleCardTitles))

        XCTAssertFalse(navTitles.contains("诊断"), "诊断入口迁入关于页（M6）")
        XCTAssertFalse(navTitles.contains("高级输入功能"), "高级输入功能并入 RIME 方案设置页（M4）")
        XCTAssertFalse(navTitles.contains("模糊音设置"), "模糊音并入 RIME 方案设置页（M5）")
        XCTAssertFalse(navTitles.contains("外观"), "外观并入「显示与外观」页（M2）")
        XCTAssertFalse(cardTitles.contains("候选数量"), "候选数量滑杆迁入 RIME 方案设置页（M3）")
        XCTAssertFalse(cardTitles.contains("默认简体"), "默认简体开关迁入 RIME 方案设置页（M3）")
    }

    func testRelocatedSettingsAreSignpostedInGroupFooters() {
        XCTAssertTrue(
            SettingsRootLayout.groups[1].footer.contains("高级输入功能"),
            "输入方案组页脚应指引高级输入功能并入方案设置页"
        )
        XCTAssertTrue(SettingsRootLayout.groups[1].footer.contains("模糊音"))
        XCTAssertTrue(
            SettingsRootLayout.groups[3].footer.contains("诊断"),
            "通用组页脚应指引诊断入口在关于页"
        )
    }

    // MARK: - 「显示与外观」page (M2)

    func testDisplayAppearancePageDeclaresRelocatedEntries() {
        XCTAssertEqual(DisplayAppearanceCopy.navigationTitle, "显示与外观")
        XCTAssertEqual(
            DisplayAppearanceCopy.relocatedEntryTitles,
            ["键盘高度", "候选字大小"],
            "键盘高度与候选字大小 Entry 迁入「显示与外观」页"
        )
    }

    // MARK: - Diagnostics entry inside About (M6)

    func testAboutPageDeclaresDiagnosticsEntry() {
        XCTAssertEqual(AboutSettingsCopy.diagnosticsEntryTitle, "诊断")
        XCTAssertEqual(AboutSettingsCopy.diagnosticsSectionHeader, "诊断")
    }

    // MARK: - Trigger-chain invariants (M3, design r2 §4 frozen)

    func testCandidatePreferenceCommitWritesBothFrozenKeys() {
        let persistence = PR4SpySettingsPersistence()
        let store = makePR4Store(persistence: persistence)

        store.pageSize = 13
        store.simplified = false

        commitRimeCandidatePreference(store)

        XCTAssertEqual(
            persistence.values["rime_page_size"] as? Int, 13,
            "键 rime_page_size 不得改名（冻结）"
        )
        XCTAssertEqual(
            persistence.values["rime_simplification"] as? Bool, false,
            "键 rime_simplification 不得改名（冻结）"
        )
    }

    func testCandidatePreferenceCommitStillTriggersDeployment() async throws {
        let persistence = PR4SpySettingsPersistence()
        let deploymentService = PR4SpyDeploymentService()
        let store = makePR4Store(persistence: persistence, deploymentService: deploymentService)

        store.pageSize = 11
        commitRimeCandidatePreference(store)

        // The frozen chain fires the deployment on an unstructured task; poll briefly.
        for _ in 0..<200 {
            if await deploymentService.deployCallCount > 0 { break }
            try await Task.sleep(nanoseconds: 10_000_000)
        }

        let deployCallCount = await deploymentService.deployCallCount
        XCTAssertEqual(
            deployCallCount, 1,
            "迁移后候选偏好变更仍必须走 triggerDeployment()（设计 r2 §4 冻结不变量）"
        )
    }

    func testDefaultSimplifiedToggleChangeStillTriggersDeployment() async throws {
        let persistence = PR4SpySettingsPersistence()
        let deploymentService = PR4SpyDeploymentService()
        let store = makePR4Store(persistence: persistence, deploymentService: deploymentService)

        store.simplified.toggle()
        commitRimeCandidatePreference(store)

        for _ in 0..<200 {
            if await deploymentService.deployCallCount > 0 { break }
            try await Task.sleep(nanoseconds: 10_000_000)
        }

        let deployCallCount = await deploymentService.deployCallCount
        XCTAssertEqual(deployCallCount, 1, "简繁偏好变更必须触发部署重建")
        XCTAssertEqual(persistence.values["rime_simplification"] as? Bool, false)
    }

    // MARK: - RIME settings page hosts merged sections (M3/M4/M5)

    func testRimeSettingsPageDeclaresMergedPreferenceSection() {
        XCTAssertEqual(RimeSettingsPageCopy.preferenceSectionHeader, "输入偏好")
    }

    // MARK: - Helpers

    /// Unwraps the `_ConditionalContent` chain produced by the `@ViewBuilder` switch in
    /// `SearchTab.destinationView(for:)` down to the concrete leaf view type name.
    /// Newer SwiftUI wraps each branch payload in an internal `Storage` container,
    /// which is unwrapped the same way as the conditional nodes.
    private func concreteTypeName(_ view: some View) -> String {
        var current: Any = view
        for _ in 0..<64 {
            let typeName = String(describing: type(of: current))
            guard typeName.hasPrefix("_ConditionalContent") || typeName == "Storage" else {
                return typeName
            }
            guard let child = Mirror(reflecting: current).children.first else { return typeName }
            current = child.value
        }
        return String(describing: type(of: current))
    }

    private func catalogItem(id: String) throws -> SettingsSearchItem {
        let entries = SettingsSearchCatalog.all.filter { $0.id == id }
        XCTAssertEqual(entries.count, 1, "目录中应恰好存在一个 \(id) 条目")
        return try XCTUnwrap(entries.first)
    }

    private func makePR4Store(
        persistence: PR4SpySettingsPersistence,
        deploymentService: PR4SpyDeploymentService = PR4SpyDeploymentService()
    ) -> RimeSettingsStore {
        RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: persistence,
                deploymentService: deploymentService
            ),
            persistence: persistence
        )
    }

    private func makeNotificationSettings() -> AppNotificationSettingsModel {
        let defaults =
            UserDefaults(suiteName: "AppPR4StructuralConsolidationTests.\(UUID().uuidString)")
            ?? .standard
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
            UserDefaults(suiteName: "AppPR4StructuralConsolidationTests.\(UUID().uuidString)")
            ?? .standard
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
private final class PR4SpySettingsPersistence: SharedSettingsStoring, RimeSettingsPersisting {
    private(set) var values: [String: Any] = [:]
    private var storage: [String: Any] = [:]

    func string(forKey key: String) -> String? { storage[key] as? String }
    func integer(forKey key: String) -> Int { storage[key] as? Int ?? 0 }
    func bool(forKey key: String) -> Bool { storage[key] as? Bool ?? false }
    func hasValue(forKey key: String) -> Bool { storage[key] != nil }
    func object(forKey key: String) -> Any? { storage[key] }
    func set(_ value: Any?, forKey key: String) {
        storage[key] = value
        if let value { values[key] = value }
    }
    func removeObject(forKey key: String) { storage.removeValue(forKey: key) }
    func synchronize() {}
}

private actor PR4SpyDeploymentService: RimeDeploymentServicing {
    private(set) var deployCallCount = 0

    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        deployCallCount += 1
        return RimeDeploymentResult(
            succeeded: false,
            diagnosticMessage: "PR4 spy deployment"
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
