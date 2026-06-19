import Foundation
import KeyboardCore
import RimeBridge

extension SchemaManager {
    func rimeIceLuaCapabilityDiagnostic(logResult: Bool = true) -> RimeLuaCapabilityDiagnostic {
        let sharedDataURL = archiveInstaller.sharedDataDirectoryURL()
        let schemaURL = sharedDataURL?.appendingPathComponent("rime_ice.schema.yaml")
        let schemaContent = schemaURL.flatMap { try? String(contentsOf: $0, encoding: .utf8) }
        let luaDirectoryURL = sharedDataURL?.appendingPathComponent("lua", isDirectory: true)
        let luaEntryScriptURL = sharedDataURL?.appendingPathComponent("rime.lua")
        let dateTranslatorURL = luaDirectoryURL?.appendingPathComponent("date_translator.lua")
        let requiredLuaComponents = schemaContent.map(Self.requiredLuaComponents) ?? []
        let missingLuaComponents = Self.missingLuaComponents(
            requiredLuaComponents,
            in: luaDirectoryURL
        )
        let missingLuaDependencies = Self.missingLuaDependencies(requiredLuaComponents, in: luaDirectoryURL)

        let diagnostic = RimeLuaCapabilityDiagnostic(
            luaCompiledIn: RimeBridgeCapabilities.luaModuleCompiledIn,
            luaModuleRegistered: RimeBridgeCapabilities.luaModuleRegistered,
            luaComponentsRegistered: RimeBridgeCapabilities.luaComponentsRegistered,
            deploymentModules: RimeBridgeCapabilities.deploymentModules,
            persistedLuaAvailable: settings.object(forKey: "rime_lua_available") as? Bool,
            rimeIceInstalled: schemas.contains { $0.schemaID == "rime_ice" && $0.installed },
            activeSchemaID: activeSchemaID,
            rimeDeployed: settings.bool(forKey: "rime_deployed"),
            rimeNeedsDeploy: settings.bool(forKey: "rime_needs_deploy"),
            runtimeSmokePassed: settings.bool(forKey: "rime_ice_lua_smoke_passed"),
            schemaExists: schemaURL.map { FileManager.default.fileExists(atPath: $0.path) } ?? false,
            schemaHasLuaComponents: schemaContent.map(Self.schemaHasLuaComponents) ?? false,
            luaDirectoryExists: luaDirectoryURL.map { url in
                var isDirectory = ObjCBool(false)
                return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                    && isDirectory.boolValue
            } ?? false,
            luaEntryScriptRequired: schemaContent.map(Self.luaEntryScriptRequired) ?? false,
            luaEntryScriptExists: luaEntryScriptURL.map { FileManager.default.fileExists(atPath: $0.path) } ?? false,
            dateTranslatorExists: dateTranslatorURL.map { FileManager.default.fileExists(atPath: $0.path) } ?? false,
            requiredLuaComponentNames: requiredLuaComponents,
            missingLuaComponentNames: missingLuaComponents,
            missingLuaDependencyNames: missingLuaDependencies
        )

        if logResult {
            Logger.shared.info("rime_ice lua diagnostic: \(diagnostic.developerSummary)", category: .deployment)
        }
        return diagnostic
    }

    private static func schemaHasLuaComponents(_ yaml: String) -> Bool {
        yaml.contains("lua_processor@")
            || yaml.contains("lua_translator@")
            || yaml.contains("lua_filter@")
            || yaml.contains("lua_segmentor@")
    }

    private static func requiredLuaComponents(_ yaml: String) -> [String] {
        let componentPattern = #"lua_(?:processor|translator|filter|segmentor)@\*?([A-Za-z0-9_./-]+)"#
        guard let regex = try? NSRegularExpression(pattern: componentPattern) else { return [] }
        let nsRange = NSRange(yaml.startIndex..<yaml.endIndex, in: yaml)
        let names = regex.matches(in: yaml, range: nsRange).compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: yaml) else { return nil }
            return String(yaml[range])
        }
        return Array(Set(names)).sorted()
    }

    private static func luaEntryScriptRequired(_ yaml: String) -> Bool {
        yaml.range(
            of: #"lua_(?:processor|translator|filter|segmentor)@(?!\*)[A-Za-z0-9_./-]+"#,
            options: .regularExpression
        ) != nil
    }

    private static func missingLuaComponents(_ names: [String], in luaDirectoryURL: URL?) -> [String] {
        guard let luaDirectoryURL else { return names }
        return names.filter { name in
            !FileManager.default.fileExists(
                atPath: luaDirectoryURL.appendingPathComponent("\(name).lua").path
            )
        }
    }

    private static func missingLuaDependencies(_ roots: [String], in luaDirectoryURL: URL?) -> [String] {
        guard let luaDirectoryURL else { return roots }

        var visited = Set<String>()
        var missing = Set<String>()
        var pending = roots

        while let name = pending.popLast() {
            guard visited.insert(name).inserted else { continue }

            let scriptURL = luaScriptURL(for: name, in: luaDirectoryURL)
            guard FileManager.default.fileExists(atPath: scriptURL.path) else {
                missing.insert(name)
                continue
            }
            guard let content = try? String(contentsOf: scriptURL, encoding: .utf8) else { continue }

            for dependency in luaRequireNames(in: content) where !visited.contains(dependency) {
                if FileManager.default.fileExists(atPath: luaScriptURL(for: dependency, in: luaDirectoryURL).path) {
                    pending.append(dependency)
                } else {
                    missing.insert(dependency)
                }
            }
        }

        return Array(missing.subtracting(roots)).sorted()
    }

    private static func luaRequireNames(in content: String) -> [String] {
        let pattern = #"require\s*\(?\s*["']([A-Za-z0-9_.-]+)["']\s*\)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
        let names = regex.matches(in: content, range: nsRange).compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return String(content[range])
        }
        return Array(Set(names)).sorted()
    }

    private static func luaScriptURL(for moduleName: String, in luaDirectoryURL: URL) -> URL {
        let relativePath = moduleName.replacingOccurrences(of: ".", with: "/")
        return luaDirectoryURL.appendingPathComponent("\(relativePath).lua")
    }
}
