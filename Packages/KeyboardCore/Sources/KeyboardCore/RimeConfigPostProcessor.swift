import Foundation

/// 后处理 rime-ice 配置，使其适配不含 librime-lua 的 iOS 编译版本。
public struct RimeConfigPostProcessor {

    /// 仅在 lua 模块不可用时剥离 Lua 依赖。
    /// Reads Lua capability recorded by the main-app deployment path.
    /// 默认 true：librime-lua 已编译链接。
    public static func shouldStripLua() -> Bool {
        let luaAvailable =
            (UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")?
                .object(forKey: "rime_lua_available") as? Bool) ?? true
        return !luaAvailable
    }

    /// 从 rime_ice.schema.yaml 中移除所有 Lua 处理器、分段器、翻译器和过滤器。
    /// 同时跳过 Lua 条目的更深缩进续行（option:, extra: 等），防止产生孤立 YAML 键。
    /// 同时移除 `initials:` 行（speller 配置），因为 rime_ice 的 initials 包含全部字母，
    /// 会导致 speller 无法组成完整音节（依赖 Lua processor 才能正常工作）。
    public static func stripLuaDependencies(from yaml: String) -> String {
        let lines = yaml.components(separatedBy: "\n")
        var result: [String] = []
        var skipUntilIndentation: Int? = nil

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let indent = line.prefix(while: { $0 == " " || $0 == "\t" }).count

            let isLuaLine =
                trimmed.contains("lua_translator@")
                || trimmed.contains("lua_filter@")
                || trimmed.contains("lua_segmentor@")
                || trimmed.hasPrefix("- lua_translator")
                || trimmed.hasPrefix("- lua_filter")
                || trimmed.hasPrefix("- lua_processor")
                || trimmed.hasPrefix("- lua_segmentor")

            // rime_ice speller initials 包含全部字母，无 Lua 时 speller 无法工作
            let isInitialsLine =
                trimmed.hasPrefix("initials:")
                && (trimmed.contains("zyxwvutsrqponmlkjihgfedcba") || trimmed.contains("abcdefghijklmnopqrstuvwxyz"))

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

            if isInitialsLine {
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
    public static func validateStrippedSchema(_ yaml: String) -> Bool {
        yaml.contains("script_translator") || yaml.contains("table_translator")
    }

    /// 运行时修复已损坏的 rime_ice.schema.yaml（旧版剥离代码遗留）。
    /// 如果 schema 包含 Lua 引用说明是正确版本，跳过修复。
    /// 两个破坏分别独立检测：
    /// 1. 破坏性 `initials:`（全字母）→ speller 无法组成音节
    /// 2. `date_locale: zh` 孤行（lua_translator@*date_translator 的续行残留）
    public static func repairSchemaIfNeeded(at path: String) {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return }

        // 如果已有 Lua 引用，说明是完整下载的正确版本，不需要修复
        let hasLuaReferences =
            content.contains("lua_translator@") || content.contains("lua_filter@")
                || content.contains("lua_processor@") || content.contains("lua_segmentor@")
        guard !hasLuaReferences else { return }

        let hasDamagingInitials = content.components(separatedBy: "\n").contains { line in
            let t = line.trimmingCharacters(in: .whitespaces)
            return t.hasPrefix("initials:")
                && (t.contains("zyxwvutsrqponmlkjihgfedcba") || t.contains("abcdefghijklmnopqrstuvwxyz"))
        }
        let hasOrphanDateLocale = content.components(separatedBy: "\n").contains { line in
            line.trimmingCharacters(in: .whitespaces) == "date_locale: zh"
        }

        guard hasDamagingInitials || hasOrphanDateLocale else { return }

        var repaired = content
        if hasDamagingInitials {
            repaired = repaired.components(separatedBy: "\n")
                .filter { line in
                    let t = line.trimmingCharacters(in: .whitespaces)
                    if t.hasPrefix("initials:")
                        && (t.contains("zyxwvutsrqponmlkjihgfedcba") || t.contains("abcdefghijklmnopqrstuvwxyz"))
                    {
                        return false
                    }
                    return true
                }
                .joined(separator: "\n")
        }
        if hasOrphanDateLocale {
            repaired = repaired.components(separatedBy: "\n")
                .filter { line in line.trimmingCharacters(in: .whitespaces) != "date_locale: zh" }
                .joined(separator: "\n")
        }
        guard validateStrippedSchema(repaired) else {
            Logger.shared.warning("Repair would leave schema invalid — skipping", category: .config)
            return
        }
        try? repaired.write(toFile: path, atomically: true, encoding: .utf8)
        let fixes = [hasDamagingInitials ? "initials" : nil, hasOrphanDateLocale ? "orphan date_locale" : nil]
            .compactMap { $0 }.joined(separator: " + ")
        Logger.shared.warning("Repaired rime_ice.schema.yaml: removed \(fixes)", category: .config)

        // 清除 librime 编译缓存，触发重新部署以加载修复后的 schema
        let sharedDir = (path as NSString).deletingLastPathComponent
        let buildDir = sharedDir + "/build"
        try? FileManager.default.removeItem(atPath: buildDir)
        try? FileManager.default.createDirectory(atPath: buildDir, withIntermediateDirectories: true)
        let defs = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
        defs?.set(false, forKey: "rime_deployed")
        defs?.set(true, forKey: "rime_needs_deploy")
        defs?.synchronize()
        Logger.shared.info("Cleared build cache + set needs_deploy after schema repair", category: .config)
    }
}
