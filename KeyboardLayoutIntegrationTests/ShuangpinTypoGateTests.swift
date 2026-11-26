import Foundation
import KeyboardCore
import XCTest

/// PB-017 PR-3：双拼 schema 激活时键盘端纠错实验编辑 fail-closed 门卫。
///
/// 门卫在 `refreshCachedSettings` 快照解析后生效：双拼 binding26 → 清空实验编辑；
/// 全拼 binding26 / 九宫格 T9（切回全拼语义）→ 保持原有值。
nonisolated final class ShuangpinTypoGateTests: XCTestCase {
    @MainActor
    private final class GateOwner: KeyboardViewController {
        override var hasFullAccess: Bool { true }
        override func viewDidLoad() {}
        override func dismissKeyboard() {}
    }

    @MainActor
    private func makeEditsEnabledDefaults() -> PasteMemoryDefaults {
        let defaults = PasteMemoryDefaults()
        defaults.set(true, forKey: TypoCorrectionExperimentalSettings.insertionEnabledKey)
        defaults.set(true, forKey: TypoCorrectionExperimentalSettings.transpositionEnabledKey)
        return defaults
    }

    @MainActor
    private func makeOwner(defaults: PasteMemoryDefaults) -> GateOwner {
        let owner = GateOwner()
        owner.controller = KeyboardController()
        owner.sharedDefaults = defaults
        return owner
    }

    private let allEdits: TypoCorrectionExperimentalEdits = [.insertion, .transposition]

    @MainActor
    func testDoublePinyinBindingDisablesExperimentalEdits() {
        for binding in ["double_pinyin_flypy", "double_pinyin"] {
            let defaults = makeEditsEnabledDefaults()
            defaults.set(KeyboardLayoutStyle.twentySixKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
            defaults.set(binding, forKey: KeyboardLayoutSettingsKey.schemeBinding26)
            let owner = makeOwner(defaults: defaults)

            owner.refreshCachedSettings()

            XCTAssertEqual(
                owner.controller.typoCorrectionExperimentalEdits,
                [],
                "双拼 binding26=\(binding) 下实验编辑必须 fail-closed 清空")
        }
    }

    @MainActor
    func testFullPinyinBindingKeepsExperimentalEdits() {
        let defaults = makeEditsEnabledDefaults()
        defaults.set(KeyboardLayoutStyle.twentySixKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        defaults.set("rime_ice", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        let owner = makeOwner(defaults: defaults)

        owner.refreshCachedSettings()

        XCTAssertEqual(owner.controller.typoCorrectionExperimentalEdits, allEdits)
    }

    @MainActor
    func testNineKeySwitchRestoresExperimentalEdits() {
        let defaults = makeEditsEnabledDefaults()
        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        defaults.set("double_pinyin_flypy", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        defaults.set("t9", forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        let owner = makeOwner(defaults: defaults)

        owner.refreshCachedSettings()

        XCTAssertEqual(
            owner.controller.typoCorrectionExperimentalEdits,
            allEdits,
            "切回九宫格全拼 T9 后实验编辑应恢复（退出双拼门卫）")
    }

    @MainActor
    func testMissingBindingKeepsExperimentalEdits() {
        let defaults = makeEditsEnabledDefaults()
        defaults.removeObject(forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        let owner = makeOwner(defaults: defaults)

        owner.refreshCachedSettings()

        XCTAssertEqual(owner.controller.typoCorrectionExperimentalEdits, allEdits)
    }
}
