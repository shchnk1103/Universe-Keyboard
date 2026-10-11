import XCTest

@testable import Universe_Keyboard

final class SchemeLicenseDownloadCopyTests: XCTestCase {
    func testFirstDownloadCopyIsTheLockedPair() {
        XCTAssertEqual(SchemeLicenseDownloadCopy.viewAndDownload, "查看许可并下载")
        XCTAssertEqual(SchemeLicenseDownloadCopy.agreeAndDownload, "同意并下载")
    }

    func testActivationAliasesUseTheSharedOwner() {
        XCTAssertEqual(
            ActivationCopy.resourcesViewLicenseAndDownload,
            SchemeLicenseDownloadCopy.viewAndDownload
        )
        XCTAssertEqual(
            ActivationCopy.resourcesAcceptLicenseAndDownload,
            SchemeLicenseDownloadCopy.agreeAndDownload
        )
    }

    func testFirstDownloadRequestOnlyPresentsLicenseForEveryEntryPoint() {
        for entryPoint in SchemeLicenseDownloadFlow.EntryPoint.allCases {
            let schemaID = "schema-\(entryPoint.rawValue)"

            XCTAssertEqual(
                SchemeLicenseDownloadFlow.effects(
                    for: .requestFirstDownload(entryPoint: entryPoint, schemaID: schemaID)
                ),
                [.presentLicense(entryPoint: entryPoint, schemaID: schemaID)],
                "Requesting a first download must only present the license sheet."
            )
        }
    }

    func testLicenseAcceptancePrecedesDownloadForEveryEntryPoint() {
        for entryPoint in SchemeLicenseDownloadFlow.EntryPoint.allCases {
            let schemaID = "schema-\(entryPoint.rawValue)"

            XCTAssertEqual(
                SchemeLicenseDownloadFlow.effects(
                    for: .agreeToFirstDownload(entryPoint: entryPoint, schemaID: schemaID)
                ),
                [
                    .acceptLicense(entryPoint: entryPoint, schemaID: schemaID),
                    .startDownload(entryPoint: entryPoint, schemaID: schemaID),
                ],
                "The selected schema must be accepted before its download starts."
            )
        }
    }

    func testDismissOnlyDismissesTheLicenseSheet() {
        XCTAssertEqual(
            SchemeLicenseDownloadFlow.effects(for: .dismissLicense),
            [.dismissLicense]
        )
    }

    func testNineKeyMissingResourcesStillRequiresLicenseAfterPriorAcceptance() {
        XCTAssertEqual(
            SchemeLicenseDownloadFlow.nineKeyRoute(
                readinessMatched: false,
                resourcesExist: false,
                licenseAccepted: true
            ),
            .presentLicense
        )
        XCTAssertEqual(
            SchemeLicenseDownloadFlow.nineKeyRoute(
                readinessMatched: false,
                resourcesExist: false,
                licenseAccepted: false
            ),
            .presentLicense
        )
    }

    func testNineKeyRoutePreservesReadyAndInstalledResourcePaths() {
        XCTAssertEqual(
            SchemeLicenseDownloadFlow.nineKeyRoute(
                readinessMatched: true,
                resourcesExist: true,
                licenseAccepted: false
            ),
            .alreadyReady
        )
        XCTAssertEqual(
            SchemeLicenseDownloadFlow.nineKeyRoute(
                readinessMatched: false,
                resourcesExist: true,
                licenseAccepted: false
            ),
            .prepareInstalledResources
        )
    }
}
