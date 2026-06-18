import Foundation
import RimeBridgeObjC

public enum RimeBridgeCapabilities {
    public static var luaModuleCompiledIn: Bool {
        RimeDeployer.luaModuleCompiledIn()
    }

    public static var deploymentModules: [String] {
        RimeDeployer.configuredModules().map { String(describing: $0) }
    }
}
