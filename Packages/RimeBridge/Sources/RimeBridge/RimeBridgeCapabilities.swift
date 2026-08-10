import Foundation
import RimeBridgeObjC

public enum RimeBridgeCapabilities {
    public static var luaModuleCompiledIn: Bool {
        RimeDeployer.luaModuleCompiledIn()
    }

    public static var luaModuleRegistered: Bool {
        RimeDeployer.luaModuleRegistered()
    }

    public static var luaComponentsRegistered: Bool {
        RimeDeployer.luaComponentsRegistered()
    }

    public static var luaComponentRegistrySummary: [String] {
        RimeDeployer.luaComponentRegistrySummary().map { String(describing: $0) }
    }

    /// Compile-time presence of the octagram static plugin (G1 grammar capability).
    public static var octagramModuleCompiledIn: Bool {
        RimeDeployer.octagramModuleCompiledIn()
    }

    /// Runtime module table contains `octagram` after setup/load.
    public static var octagramModuleRegistered: Bool {
        RimeDeployer.octagramModuleRegistered()
    }

    /// Registry has the concrete `grammar` component. Does not prove a `.gram` model is present.
    public static var grammarComponentRegistered: Bool {
        RimeDeployer.grammarComponentRegistered()
    }

    public static var deploymentModules: [String] {
        RimeDeployer.configuredModules().map { String(describing: $0) }
    }
}
