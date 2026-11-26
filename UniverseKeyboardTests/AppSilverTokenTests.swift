import SwiftUI
import UIKit
import XCTest

@testable import Universe_Keyboard

/// PB-015-PR1-STYLE-TOKENS-001：四层银色纯令牌契约单测。
///
/// 覆盖三类断言（设计 r1 §2.5 / r2 §6 PR-1 验收）：
/// 浅/深成对解析、Reduce Transparency 关渐变退化、Increase Contrast 改 `opaqueSeparator`。
final class AppSilverTokenTests: XCTestCase {
    private let allLayers: [AppSilverToken.Layer] = [
        .hairline, .tileFill, .activePill, .sliderTrack,
    ]

    private let lightTrait = UITraitCollection(userInterfaceStyle: .light)
    private let darkTrait = UITraitCollection(userInterfaceStyle: .dark)

    /// 令牌表冻结为恰好四层，无 `accentText` 之类的文字色扩展。
    func testTokenTableIsExactlyTheFourSilverLayers() {
        XCTAssertEqual(AppSilverToken.Layer.allCases, allLayers)
        XCTAssertEqual(AppSilverToken.Layer.allCases.count, 4)
        for layer in allLayers {
            XCTAssertNotEqual(layer.rawValue, "accentText")
        }
    }

    /// 浅/深成对：每层的 base 动态色在浅/深 trait 下各有解析值且不相等
    /// （银层随系统外观自动成对，调用点无需手写色值）。
    func testLightAndDarkResolutionsArePairedAndDistinct() {
        for layer in allLayers {
            let base = AppSilverToken.baseColor(layer)
            let light = base.resolvedColor(with: lightTrait)
            let dark = base.resolvedColor(with: darkTrait)
            XCTAssertNotEqual(
                light, dark,
                "\(layer.rawValue) 的 base 必须是浅/深成对的动态色")
        }
    }

    /// 正常态：hairline / tileFill / sliderTrack 是渐变银层；activePill 是纯描边。
    func testNormalResolutionUsesGradientOnlyOnDecorativeLayers() {
        for layer in allLayers {
            let resolved = AppSilverToken.resolved(
                layer, reduceTransparency: false, increaseContrast: false)
            if layer == .activePill {
                guard case let .solid(color) = resolved else {
                    return XCTFail("activePill 应为纯描边色，而非渐变")
                }
                XCTAssertEqual(color, AppSilverToken.baseColor(layer).withAlphaComponent(0.25))
            } else {
                guard case let .gradient(base, topLight) = resolved else {
                    return XCTFail("\(layer.rawValue) 正常态应为渐变银层")
                }
                XCTAssertEqual(base, AppSilverToken.baseColor(layer))
                XCTAssertGreaterThan(
                    topLight.resolvedColor(with: lightTrait).alphaComponent(),
                    0, "渐变顶部亮银应有非零透明度")
            }
            XCTAssertTrue(
                AppSilverToken.usesGradient(
                    layer, reduceTransparency: false, increaseContrast: false)
                    == (layer != .activePill))
        }
    }

    /// Reduce Transparency 开启：所有层关闭渐变，退化为纯 base 灰阶。
    func testReduceTransparencyDisablesGradientToSolidBase() {
        for layer in allLayers {
            XCTAssertFalse(
                AppSilverToken.usesGradient(
                    layer, reduceTransparency: true, increaseContrast: false))
            let resolved = AppSilverToken.resolved(
                layer, reduceTransparency: true, increaseContrast: false)
            guard case let .solid(color) = resolved else {
                return XCTFail("\(layer.rawValue) 在 Reduce Transparency 下必须是纯色")
            }
            let light = color.resolvedColor(with: lightTrait)
            let baseLight = AppSilverToken.baseColor(layer).resolvedColor(with: lightTrait)
            XCTAssertEqual(light, baseLight, "\(layer.rawValue) 降级色必须等于 base 灰阶")
        }
    }

    /// Increase Contrast 开启：所有层切换为 `opaqueSeparator` 纯色。
    func testIncreaseContrastSwitchesToOpaqueSeparator() {
        for layer in allLayers {
            XCTAssertFalse(
                AppSilverToken.usesGradient(
                    layer, reduceTransparency: false, increaseContrast: true))
            let resolved = AppSilverToken.resolved(
                layer, reduceTransparency: false, increaseContrast: true)
            XCTAssertEqual(resolved, .solid(.opaqueSeparator))
            let alsoRT = AppSilverToken.resolved(
                layer, reduceTransparency: true, increaseContrast: true)
            XCTAssertEqual(alsoRT, .solid(.opaqueSeparator))
        }
    }
}

extension UIColor {
    /// 提取 RGBA 中的 alpha 分量（供渐变顶部亮银的非零断言）。
    fileprivate func alphaComponent() -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return alpha
    }
}
