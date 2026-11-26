import SwiftUI
import UIKit
import XCTest

@testable import Universe_Keyboard

/// PB-015-PR2-STYLE-COMPONENTS-001：组件银层与降级契约单测。
///
/// 覆盖 4 种系统辅助模式（浅/深 × Reduce Transparency × Increase Contrast）
/// 的解析结果与纯函数行为；`accentText` 与 `Keyboard/` 零引用由本地门禁
/// `git grep` 把关（全仓检索，单测无法可靠表达）。
final class AppSilverComponentTests: XCTestCase {
    private let lightTrait = UITraitCollection(userInterfaceStyle: .light)
    private let darkTrait = UITraitCollection(userInterfaceStyle: .dark)

    /// AppSlider 三层 chrome 在 4 态下的降级矩阵：
    /// 正常态 track/outline 为渐变、拇指描边为 label@25%；RT 全部退化为纯 base；
    /// IC 全部切换为 opaqueSeparator；RT+IC 同 IC。
    func testAppSliderChromeDegradesAcrossFourAccessibilityModes() {
        for isDark in [false, true] {
            let trait = isDark ? darkTrait : lightTrait
            // 正常态
            if case let .gradient(base, topLight) = AppSliderChrome.trackFill(
                reduceTransparency: false, increaseContrast: false)
            {
                XCTAssertEqual(
                    base.resolvedColor(with: trait),
                    UIColor.separator.resolvedColor(with: trait))
                XCTAssertGreaterThan(topLight.resolvedColor(with: trait).silverTestAlpha, 0)
            } else {
                XCTFail("正常态轨道应为渐变")
            }
            if case let .solid(stroke) = AppSliderChrome.activeThumbStroke(
                reduceTransparency: false, increaseContrast: false)
            {
                XCTAssertEqual(
                    stroke.resolvedColor(with: trait),
                    UIColor.label.withAlphaComponent(0.25).resolvedColor(with: trait))
            } else {
                XCTFail("activePill 拇指描边应为纯色")
            }
            // RT：关渐变退化纯 base
            for resolved in [
                AppSliderChrome.trackFill(reduceTransparency: true, increaseContrast: false),
                AppSliderChrome.trackOutline(reduceTransparency: true, increaseContrast: false),
            ] {
                guard case let .solid(color) = resolved else {
                    return XCTFail("RT 下必须为纯色")
                }
                XCTAssertEqual(
                    color.resolvedColor(with: trait),
                    UIColor.separator.resolvedColor(with: trait))
            }
            // IC：全部切换 opaqueSeparator（含 RT+IC 组合）
            for resolved in [
                AppSliderChrome.trackFill(reduceTransparency: false, increaseContrast: true),
                AppSliderChrome.trackOutline(reduceTransparency: false, increaseContrast: true),
                AppSliderChrome.activeThumbStroke(reduceTransparency: false, increaseContrast: true),
                AppSliderChrome.trackFill(reduceTransparency: true, increaseContrast: true),
            ] {
                XCTAssertEqual(resolved, .solid(.opaqueSeparator))
            }
        }
    }

    /// AppSlider 拇指沿用黑白拇指对（浅色黑、深色白）。
    func testAppSliderThumbUsesSwitchChromePair() {
        XCTAssertFalse(AppSliderChrome.thumbColor(isDark: false) == AppSliderChrome.thumbColor(isDark: true))
        XCTAssertEqual(
            AppSliderChrome.thumbColor(isDark: true).resolvedColor(with: darkTrait),
            UIColor.white.resolvedColor(with: darkTrait))
        XCTAssertEqual(
            AppSliderChrome.thumbColor(isDark: false).resolvedColor(with: lightTrait),
            UIColor.black.resolvedColor(with: lightTrait))
    }

    /// 进度映射纯函数：线性映射、越界钳制、step 取整。
    func testAppSliderValueMappingMath() {
        let range: ClosedRange<Double> = 5...20
        func sliderValue(_ progress: Double) -> Double {
            AppSlider.mappedValue(fromNormalized: progress, in: range, step: 1)
        }
        // 中点 → 12.5，step=1 四舍五入到 13
        XCTAssertEqual(sliderValue(0.5), 13)
        // 越界钳制
        XCTAssertEqual(sliderValue(-0.5), 5)
        XCTAssertEqual(sliderValue(1.5), 20)
        // 连续区间（反馈强度 0...1，无 step）不做取整
        XCTAssertEqual(
            AppSlider.mappedValue(fromNormalized: 0.5, in: 0...1, step: 0), 0.5,
            accuracy: 0.001)
        XCTAssertEqual(
            AppSlider.mappedValue(fromNormalized: 0.123, in: 0...1, step: 0), 0.123,
            accuracy: 0.0001)
    }

    /// 组件接银同值核对：AppActionButton secondary 描边归入 hairline 层（base 同为
    /// 系统 separator，零视觉变更）。
    func testAppActionButtonSecondaryBorderUsesHairlineToken() {
        XCTAssertEqual(
            AppActionButtonChrome.solidBorderColor(prominence: .secondary),
            AppSilverToken.baseColor(.hairline))
        XCTAssertEqual(
            AppActionButtonChrome.solidBorderColor(prominence: .secondary),
            .separator)
    }

    /// AppIconTile tileFill 正常态解析：base 为 tertiarySystemFill 的渐变（浅/深成对）。
    func testAppIconTileFillIsPairedDynamicColor() {
        if case let .gradient(base, _) = AppSilverToken.resolved(
            .tileFill, reduceTransparency: false, increaseContrast: false)
        {
            XCTAssertNotEqual(
                base.resolvedColor(with: lightTrait),
                base.resolvedColor(with: darkTrait))
        } else {
            XCTFail("tileFill 正常态应为渐变")
        }
    }
}

private extension UIColor {
    /// RGBA alpha 分量（UIColor 无公开 alpha 属性；仅测试用）。
    var silverTestAlpha: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return alpha
    }
}
