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

    public static var deploymentModules: [String] {
        RimeDeployer.configuredModules().map { String(describing: $0) }
    }
}
