import Foundation

/// 后处理 rime-ice 配置，使其适配不含 librime-lua 的 iOS 编译版本。
struct RimeConfigPostProcessor {

    /// 仅在 lua 模块不可用时剥离 Lua 依赖。
    /// 读取 rime_lua_available（由 RimeSessionManager 设置）。
    static func shouldStripLua() -> Bool {
        let luaAvailable = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")?
            .bool(forKey: "rime_lua_available") ?? false
        return !luaAvailable
    }

    /// 从 rime_ice.schema.yaml 中移除所有 Lua 处理器、翻译器和过滤器。
    /// 同时跳过 Lua 条目的更深缩进续行（option:, extra: 等），防止产生孤立 YAML 键。
    static func stripLuaDependencies(from yaml: String) -> String {
        let lines = yaml.components(separatedBy: "\n")
        var result: [String] = []
        var skipUntilIndentation: Int? = nil

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let indent = line.prefix(while: { $0 == " " || $0 == "\t" }).count

            let isLuaLine = trimmed.contains("lua_translator@")
                         || trimmed.contains("lua_filter@")
                         || trimmed.hasPrefix("- lua_translator")
                         || trimmed.hasPrefix("- lua_filter")
                         || trimmed.hasPrefix("- lua_processor")

            // 检查是否应该跳过当前行（续行检测）
            if !isLuaLine, let skipIndent = skipUntilIndentation, indent > skipIndent, !trimmed.isEmpty {
                continue
            }

            // 新行缩进不超过 Lua 条目时，退出 skip 模式
            if !isLuaLine && indent <= (skipUntilIndentation ?? -1) {
                skipUntilIndentation = nil
            }

            if isLuaLine {
                skipUntilIndentation = indent
                continue
            }

            // 空行或非缩进行退出 skip 模式
            if trimmed.isEmpty {
                skipUntilIndentation = nil
            }

            result.append(line)
        }

        return result.joined(separator: "\n")
    }

    /// 验证剥离后的 schema 至少保留了一个基础翻译器（script_translator 或 table_translator）。
    static func validateStrippedSchema(_ yaml: String) -> Bool {
        yaml.contains("script_translator") || yaml.contains("table_translator")
    }
}
