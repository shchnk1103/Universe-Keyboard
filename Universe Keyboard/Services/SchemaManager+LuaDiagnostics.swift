import Foundation
import KeyboardCore
import RimeBridge

extension SchemaManager {
    func rimeIceLuaCapabilityDiagnostic(logResult: Bool = true) -> RimeLuaCapabilityDiagnostic {
        let sharedDataURL = archiveInstaller.sharedDataDirectoryURL()
        let schemaURL = sharedDataURL?.appendingPathComponent("rime_ice.schema.yaml")
        let schemaContent = schemaURL.flatMap { try? String(contentsOf: $0, encoding: .utf8) }
        let luaDirectoryURL = sharedDataURL?.appendingPathComponent("lua", isDirectory: true)
        let dateTranslatorURL = luaDirectoryURL?.appendingPathComponent("date_translator.lua")
        let requiredLuaComponents = schemaContent.map(Self.requiredLuaComponents) ?? []
        let missingLuaComponents = Self.missingLuaComponents(
            requiredLuaComponents,
            in: luaDirectoryURL
        )

        let diagnostic = RimeLuaCapabilityDiagnostic(
            luaCompiledIn: RimeBridgeCapabilities.luaModuleCompiledIn,
            deploymentModules: RimeBridgeCapabilities.deploymentModules,
            persistedLuaAvailable: settings.object(forKey: "rime_lua_available") as? Bool,
            rimeIceInstalled: schemas.contains { $0.schemaID == "rime_ice" && $0.installed },
            activeSchemaID: activeSchemaID,
            rimeDeployed: settings.bool(forKey: "rime_deployed"),
            rimeNeedsDeploy: settings.bool(forKey: "rime_needs_deploy"),
            schemaExists: schemaURL.map { FileManager.default.fileExists(atPath: $0.path) } ?? false,
            schemaHasLuaComponents: schemaContent.map(Self.schemaHasLuaComponents) ?? false,
            luaDirectoryExists: luaDirectoryURL.map { url in
                var isDirectory = ObjCBool(false)
                return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                    && isDirectory.boolValue
            } ?? false,
            dateTranslatorExists: dateTranslatorURL.map { FileManager.default.fileExists(atPath: $0.path) } ?? false,
            requiredLuaComponentNames: requiredLuaComponents,
            missingLuaComponentNames: missingLuaComponents
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
    }

    private static func requiredLuaComponents(_ yaml: String) -> [String] {
        let componentPattern = #"lua_(?:processor|translator|filter)@\*?([A-Za-z0-9_./-]+)"#
        guard let regex = try? NSRegularExpression(pattern: componentPattern) else { return [] }
        let nsRange = NSRange(yaml.startIndex..<yaml.endIndex, in: yaml)
        let names = regex.matches(in: yaml, range: nsRange).compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: yaml) else { return nil }
            return String(yaml[range])
        }
        return Array(Set(names)).sorted()
    }

    private static func missingLuaComponents(_ names: [String], in luaDirectoryURL: URL?) -> [String] {
        guard let luaDirectoryURL else { return names }
        return names.filter { name in
            !FileManager.default.fileExists(
                atPath: luaDirectoryURL.appendingPathComponent("\(name).lua").path
            )
        }
    }
}
