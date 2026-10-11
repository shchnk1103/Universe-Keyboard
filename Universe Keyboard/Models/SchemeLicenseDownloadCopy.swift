import Foundation

/// Shared copy for the first-download license flow (`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`).
nonisolated enum SchemeLicenseDownloadCopy: Sendable {
    nonisolated static let viewAndDownload = "查看许可并下载"
    nonisolated static let agreeAndDownload = "同意并下载"
}

/// Effects for the first-download license flow, kept pure so each production
/// entry point can share the same behavior and regression contract.
nonisolated enum SchemeLicenseDownloadFlow: Sendable {
    nonisolated enum EntryPoint: String, CaseIterable, Sendable {
        case settingsDetail
        case activationGuide
        case nineKeyInstall
    }

    nonisolated enum Intent: Equatable, Sendable {
        case requestFirstDownload(entryPoint: EntryPoint, schemaID: String)
        case agreeToFirstDownload(entryPoint: EntryPoint, schemaID: String)
        case dismissLicense
    }

    nonisolated enum Effect: Equatable, Sendable {
        case presentLicense(entryPoint: EntryPoint, schemaID: String)
        case acceptLicense(entryPoint: EntryPoint, schemaID: String)
        case startDownload(entryPoint: EntryPoint, schemaID: String)
        case dismissLicense
    }

    nonisolated enum NineKeyRoute: Equatable, Sendable {
        case alreadyReady
        case presentLicense
        case prepareInstalledResources
    }

    nonisolated static func effects(for intent: Intent) -> [Effect] {
        switch intent {
        case .requestFirstDownload(let entryPoint, let schemaID):
            [.presentLicense(entryPoint: entryPoint, schemaID: schemaID)]
        case .agreeToFirstDownload(let entryPoint, let schemaID):
            [
                .acceptLicense(entryPoint: entryPoint, schemaID: schemaID),
                .startDownload(entryPoint: entryPoint, schemaID: schemaID),
            ]
        case .dismissLicense:
            [.dismissLicense]
        }
    }

    /// Prior acceptance does not suppress the first-install license sheet.
    nonisolated static func nineKeyRoute(
        readinessMatched: Bool,
        resourcesExist: Bool,
        licenseAccepted _: Bool
    ) -> NineKeyRoute {
        if readinessMatched, resourcesExist {
            return .alreadyReady
        }
        guard resourcesExist else {
            return .presentLicense
        }
        return .prepareInstalledResources
    }
}
