import Foundation

/// Per-scheme **native** advanced-input usage tips (TD-011 product freeze A).
///
/// Product decision (2026-08-08): keep upstream triggers different (e.g. fog `rq`
/// vs 万象 `/rq`); do **not** unify or silently remap triggers. Settings copy must
/// follow the layout-bound scheme so ordinary users know how to invoke features.
public struct RimeSchemeUsageTip: Equatable, Sendable, Identifiable {
    public var id: String { title }
    public let title: String
    public let examples: String

    public init(title: String, examples: String) {
        self.title = title
        self.examples = examples
    }
}

public enum RimeSchemeNativeUsageGuide {
    /// How-to rows for the advanced-input settings page (and similar surfaces).
    public static func advancedInputTips(for schemaID: String) -> [RimeSchemeUsageTip] {
        switch RimeSchemeCapabilityMatrix.normalizeSchemaID(schemaID) {
        case "rime_ice":
            return [
                RimeSchemeUsageTip(
                    title: "输入日期和时间",
                    examples: "试试 rq、sj、xq、dt，可显示日期、时间、星期或完整日期时间。"
                ),
                RimeSchemeUsageTip(
                    title: "输入计算结果",
                    examples: "输入简单算式时，候选里会出现计算结果。"
                ),
                RimeSchemeUsageTip(
                    title: "输入数字格式",
                    examples: "输入数字时，可出现中文大写、金额等格式候选。"
                ),
                RimeSchemeUsageTip(
                    title: "输入特殊内容",
                    examples: "可快速输入随机编号、特殊字符或更多符号内容。"
                ),
            ]
        case "wanxiang":
            return [
                RimeSchemeUsageTip(
                    title: "输入日期和时间",
                    examples: "万象使用 / 或 o 作引导：试试 /rq、orq（日期），/sj、osj（时间），/xq、/nl、/jq 等。"
                ),
                RimeSchemeUsageTip(
                    title: "输入计算结果",
                    examples: "大写 V 引导：例如 V3+5，候选中可出现计算结果。"
                ),
                RimeSchemeUsageTip(
                    title: "输入数字与金额",
                    examples: "大写 R 引导数字：例如 R1234，可出现中文大写、金额等候选。"
                ),
                RimeSchemeUsageTip(
                    title: "Unicode 与其它",
                    examples: "大写 U 引导 Unicode；/wx 可查看万象版本信息。与雾凇的 rq 等触发不同，属方案原生习惯。"
                ),
            ]
        case "luna_pinyin":
            return [
                RimeSchemeUsageTip(
                    title: "基础拼音",
                    examples: "朙月拼音为内置基础方案，不含雾凇/万象那类动态日期与计算器增强。"
                ),
            ]
        default:
            return [
                RimeSchemeUsageTip(
                    title: "当前方案",
                    examples: "请以该方案自带说明为准；不同 RIME 方案的增强触发词可能不同。"
                ),
            ]
        }
    }

    /// Footer under the how-to section.
    public static func advancedInputHelpFooter(for schemaID: String) -> String {
        switch RimeSchemeCapabilityMatrix.normalizeSchemaID(schemaID) {
        case "rime_ice":
            return "增强功能会出现在候选栏；不需要切换键盘页面。下方开关仅控制雾凇产品化高级输入，关闭后需重新部署才在键盘中生效。"
        case "wanxiang":
            return "万象拼音自带上游 Lua 增强（与雾凇触发不同）。上方说明按万象原生习惯；下方开关不能控制万象模块，仅用于雾凇产品化高级输入。"
        case "luna_pinyin":
            return "内置朙月以基础拼音为主；若需日期/计算器等增强，请安装并选用雾凇或万象等方案。"
        default:
            return "不同方案的增强输入触发方式可能不同；请以当前方案的说明为准。"
        }
    }

    /// Extra status line when product toggles do not apply but native tips exist.
    public static func advancedInputStatusNote(for schemaID: String) -> String? {
        switch RimeSchemeCapabilityMatrix.normalizeSchemaID(schemaID) {
        case "wanxiang":
            return "万象使用自带增强输入：日期/时间用 /rq、orq、/sj 等（不是雾凇的 rq）。下方开关不能开关万象模块。"
        case "luna_pinyin":
            return "朙月拼音不提供雾凇式高级输入开关；基础拼音仍可正常使用。"
        default:
            return nil
        }
    }
}
