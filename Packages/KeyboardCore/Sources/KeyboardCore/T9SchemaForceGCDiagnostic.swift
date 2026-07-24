import Foundation

/// Snapshot of whether on-disk T9 schema source **and** compiled build still register force_gc.
///
/// Used by the main App diagnostics UI and log pipeline. Never includes schema body
/// text in summaries — only presence flags and path basenames.
public struct T9SchemaForceGCDiagnostic: Equatable, Sendable {
    public var appGroupAvailable: Bool
    /// Absolute path when known (for developer logs only).
    public var schemaPath: String?
    public var schemaExists: Bool
    public var schemaReadable: Bool
    public var hasSchemaIDT9: Bool
    /// True when **source** `t9.schema.yaml` list entry (`- …force_gc…`) is still registered.
    public var forceGCTranslatorPresent: Bool
    /// True when a **compiled** `build/t9.schema.yaml` (shared or user) still lists force_gc.
    public var compiledForceGCTranslatorPresent: Bool
    /// Which compiled paths were found (basenames only in summary).
    public var compiledSchemaFound: Bool
    public var forceGCLuaExists: Bool
    /// `nil` when the lua file is missing or unreadable.
    public var forceGCLuaCallsCollectgarbage: Bool?
    public var layoutStyleRaw: String?
    public var t9Ready: Bool?
    public var readinessCompatibilityVersion: String?
    public var readinessFingerprintPrefix: String?

    public init(
        appGroupAvailable: Bool,
        schemaPath: String? = nil,
        schemaExists: Bool = false,
        schemaReadable: Bool = false,
        hasSchemaIDT9: Bool = false,
        forceGCTranslatorPresent: Bool = false,
        compiledForceGCTranslatorPresent: Bool = false,
        compiledSchemaFound: Bool = false,
        forceGCLuaExists: Bool = false,
        forceGCLuaCallsCollectgarbage: Bool? = nil,
        layoutStyleRaw: String? = nil,
        t9Ready: Bool? = nil,
        readinessCompatibilityVersion: String? = nil,
        readinessFingerprintPrefix: String? = nil
    ) {
        self.appGroupAvailable = appGroupAvailable
        self.schemaPath = schemaPath
        self.schemaExists = schemaExists
        self.schemaReadable = schemaReadable
        self.hasSchemaIDT9 = hasSchemaIDT9
        self.forceGCTranslatorPresent = forceGCTranslatorPresent
        self.compiledForceGCTranslatorPresent = compiledForceGCTranslatorPresent
        self.compiledSchemaFound = compiledSchemaFound
        self.forceGCLuaExists = forceGCLuaExists
        self.forceGCLuaCallsCollectgarbage = forceGCLuaCallsCollectgarbage
        self.layoutStyleRaw = layoutStyleRaw
        self.t9Ready = t9Ready
        self.readinessCompatibilityVersion = readinessCompatibilityVersion
        self.readinessFingerprintPrefix = readinessFingerprintPrefix
    }

    /// Runtime is clean only when source is clean and no compiled force_gc remains.
    public var runtimeLikelyClean: Bool {
        schemaReadable && !forceGCTranslatorPresent
            && (!compiledSchemaFound || !compiledForceGCTranslatorPresent)
    }

    /// One-line summary for `Logger` / `rime_diag_log` (no file bodies).
    public var developerSummary: String {
        let pathLabel = schemaPath.map { URL(fileURLWithPath: $0).lastPathComponent } ?? "missing"
        let luaGC: String = {
            guard forceGCLuaExists else { return "lua=absent" }
            switch forceGCLuaCallsCollectgarbage {
            case true?: return "lua=calls_gc"
            case false?: return "lua=no_gc_call"
            case nil: return "lua=unreadable"
            }
        }()
        return
            "t9Schema force_gc check appGroup=\(appGroupAvailable) "
            + "schema=\(pathLabel) exists=\(schemaExists) readable=\(schemaReadable) "
            + "schemaID_t9=\(hasSchemaIDT9) source_force_gc=\(forceGCTranslatorPresent) "
            + "compiled_found=\(compiledSchemaFound) compiled_force_gc=\(compiledForceGCTranslatorPresent) "
            + "runtime_clean=\(runtimeLikelyClean) \(luaGC) "
            + "layout=\(layoutStyleRaw ?? "nil") t9Ready=\(t9Ready.map(String.init) ?? "nil") "
            + "compat=\(readinessCompatibilityVersion ?? "nil") "
            + "fp=\(readinessFingerprintPrefix ?? "nil")"
    }

    /// Short Chinese lines for Settings UI.
    public var userFacingLines: [String] {
        var lines: [String] = []
        if !appGroupAvailable {
            lines.append("App Group 不可用，无法读取共享目录。")
            return lines
        }
        if !schemaExists {
            lines.append("未找到 Rime/shared/t9.schema.yaml（雾凇/九键资源可能未安装）。")
            return lines
        }
        if !schemaReadable {
            lines.append("t9.schema.yaml 存在但无法读取。")
            return lines
        }
        if forceGCTranslatorPresent {
            lines.append("源文件 t9.schema.yaml 仍注册 force_gc translator。")
        } else {
            lines.append("源文件 t9.schema.yaml 未注册 force_gc translator。")
        }
        if compiledSchemaFound {
            if compiledForceGCTranslatorPresent {
                lines.append(
                    "编译产物 build/t9.schema.yaml 仍含 force_gc — 运行时可能仍在用旧编译结果；请完整部署以重编译。"
                )
            } else {
                lines.append("编译产物 build/t9.schema.yaml 已不含 force_gc。")
            }
        } else {
            lines.append("未找到编译产物 build/t9.schema.yaml（将在下次部署时生成）。")
        }
        if !hasSchemaIDT9 {
            lines.append("警告：源文件中未检测到 schema_id: t9。")
        }
        if forceGCLuaExists {
            if forceGCLuaCallsCollectgarbage == true {
                lines.append("共享 lua/force_gc.lua 仍调用 collectgarbage（26 键等方案可能仍使用，属预期）。")
            } else if forceGCLuaCallsCollectgarbage == false {
                lines.append("共享 lua/force_gc.lua 存在但不含 collectgarbage 调用。")
            } else {
                lines.append("共享 lua/force_gc.lua 存在但无法判断内容。")
            }
        } else {
            lines.append("共享 lua/force_gc.lua 不存在。")
        }
        if let layoutStyleRaw {
            lines.append("当前布局设置：\(layoutStyleRaw)")
        }
        if let t9Ready {
            lines.append("九键就绪标记：\(t9Ready ? "ready" : "not ready")")
        }
        if runtimeLikelyClean {
            lines.append("结论：源与编译产物均干净；若仍 SLOW KEY，主因更可能是长串 script_translator。")
        } else if !forceGCTranslatorPresent && compiledForceGCTranslatorPresent {
            lines.append("结论：源已剥离但编译缓存仍脏 — 必须完整部署后再测。")
        }
        return lines
    }
}

/// Pure inspector for on-disk T9 force_gc registration (no I/O logging).
public enum T9SchemaForceGCInspector {
    /// Analyze YAML text for translator list entries that register force_gc.
    public static func forceGCTranslatorPresent(inYAML yaml: String) -> Bool {
        yaml.split(separator: "\n", omittingEmptySubsequences: false).contains { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Source: `- lua_translator@*force_gc`
            // Compiled: `- "lua_translator@*force_gc"`
            return trimmed.hasPrefix("-") && trimmed.contains(T9SchemaCompatibility.forceGCTranslatorMarker)
        }
    }

    public static func hasSchemaIDT9(inYAML yaml: String) -> Bool {
        yaml.contains("schema_id: t9") || yaml.contains("schema_id:t9")
            || yaml.contains("schema_id: \"t9\"")
    }

    public static func luaCallsCollectgarbage(_ source: String) -> Bool {
        source.contains("collectgarbage(")
    }

    public static func inspect(
        sharedDataURL: URL?,
        userDataURL: URL? = nil,
        layoutStyleRaw: String?,
        t9Ready: Bool?,
        readinessMarker: RimeT9ReadinessMarker?,
        fileManager: FileManager = .default
    ) -> T9SchemaForceGCDiagnostic {
        guard let sharedDataURL else {
            return T9SchemaForceGCDiagnostic(
                appGroupAvailable: false,
                layoutStyleRaw: layoutStyleRaw,
                t9Ready: t9Ready,
                readinessCompatibilityVersion: readinessMarker?.compatibilityVersion,
                readinessFingerprintPrefix: fingerprintPrefix(readinessMarker?.resourceFingerprint)
            )
        }

        let schemaURL = sharedDataURL.appendingPathComponent("t9.schema.yaml")
        let luaURL = sharedDataURL
            .appendingPathComponent("lua", isDirectory: true)
            .appendingPathComponent("force_gc.lua")
        let schemaExists = fileManager.fileExists(atPath: schemaURL.path)
        let luaExists = fileManager.fileExists(atPath: luaURL.path)

        var schemaReadable = false
        var hasT9 = false
        var translatorForceGC = false
        if schemaExists, let yaml = try? String(contentsOf: schemaURL, encoding: .utf8) {
            schemaReadable = true
            hasT9 = hasSchemaIDT9(inYAML: yaml)
            translatorForceGC = forceGCTranslatorPresent(inYAML: yaml)
        }

        var luaCallsGC: Bool?
        if luaExists {
            if let source = try? String(contentsOf: luaURL, encoding: .utf8) {
                luaCallsGC = luaCallsCollectgarbage(source)
            } else {
                luaCallsGC = nil
            }
        }

        let compiledURLs = [
            sharedDataURL.appendingPathComponent("build/t9.schema.yaml"),
            userDataURL?.appendingPathComponent("build/t9.schema.yaml"),
        ].compactMap { $0 }

        var compiledFound = false
        var compiledForceGC = false
        for url in compiledURLs where fileManager.fileExists(atPath: url.path) {
            compiledFound = true
            if let yaml = try? String(contentsOf: url, encoding: .utf8),
               forceGCTranslatorPresent(inYAML: yaml)
            {
                compiledForceGC = true
            }
        }

        return T9SchemaForceGCDiagnostic(
            appGroupAvailable: true,
            schemaPath: schemaURL.path,
            schemaExists: schemaExists,
            schemaReadable: schemaReadable,
            hasSchemaIDT9: hasT9,
            forceGCTranslatorPresent: translatorForceGC,
            compiledForceGCTranslatorPresent: compiledForceGC,
            compiledSchemaFound: compiledFound,
            forceGCLuaExists: luaExists,
            forceGCLuaCallsCollectgarbage: luaCallsGC,
            layoutStyleRaw: layoutStyleRaw,
            t9Ready: t9Ready,
            readinessCompatibilityVersion: readinessMarker?.compatibilityVersion,
            readinessFingerprintPrefix: fingerprintPrefix(readinessMarker?.resourceFingerprint)
        )
    }

    private static func fingerprintPrefix(_ fingerprint: String?) -> String? {
        guard let fingerprint, !fingerprint.isEmpty else { return nil }
        return String(fingerprint.prefix(12))
    }
}
