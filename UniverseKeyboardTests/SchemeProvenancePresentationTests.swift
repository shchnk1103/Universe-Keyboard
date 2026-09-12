import XCTest

@testable import Universe_Keyboard

final class SchemeProvenancePresentationTests: XCTestCase {
    func testBuiltinAndDistributionShareTheSameRowTitles() {
        let builtin = SchemeProvenancePresentation.make(
            isDistributionBacked: false,
            installedVersion: nil,
            manifestVersion: "should-not-appear",
            source: Self.sampleSource,
            hasVerifiedReceipt: true
        )
        let distribution = SchemeProvenancePresentation.make(
            isDistributionBacked: true,
            installedVersion: "should-not-appear",
            manifestVersion: nil,
            source: nil,
            hasVerifiedReceipt: false
        )

        XCTAssertEqual(Self.expectedTitles, builtin.rows.map(\.title))
        XCTAssertEqual(Self.expectedTitles, distribution.rows.map(\.title))
        XCTAssertEqual(builtin.footer, SchemeProvenancePresentation.builtinFooter)
        XCTAssertEqual(distribution.footer, SchemeProvenancePresentation.distributionFooter)
    }

    func testBuiltinFillsHonestPlaceholdersAndIgnoresDistributionInputs() {
        let presentation = SchemeProvenancePresentation.make(
            isDistributionBacked: false,
            installedVersion: nil,
            manifestVersion: "2.0",
            source: Self.sampleSource,
            hasVerifiedReceipt: true
        )
        let values = Self.valueMap(presentation)

        XCTAssertEqual(values["版本"], "随 App 内置")
        XCTAssertEqual(values["下载来源"], "随 App 内置")
        XCTAssertEqual(values["下载地址"], "不适用")
        XCTAssertEqual(values["上游版本"], "不适用")
        XCTAssertEqual(values["归档大小"], "不适用")
        XCTAssertEqual(values["归档 SHA-256"], "不适用")
        XCTAssertEqual(values["完整性"], "不适用")
        XCTAssertTrue(presentation.rows.allSatisfy { $0.style == .plain })
    }

    func testBuiltinUsesInstalledVersionWhenPresent() {
        let presentation = SchemeProvenancePresentation.make(
            isDistributionBacked: false,
            installedVersion: "0.99",
            manifestVersion: nil,
            source: nil,
            hasVerifiedReceipt: false
        )
        XCTAssertEqual(Self.valueMap(presentation)["版本"], "0.99")
    }

    func testDistributionUnresolvedPlaceholdersDoNotDependOnSchemaID() {
        let presentation = SchemeProvenancePresentation.make(
            isDistributionBacked: true,
            installedVersion: "ignored",
            manifestVersion: nil,
            source: nil,
            hasVerifiedReceipt: false
        )
        let values = Self.valueMap(presentation)

        XCTAssertEqual(values["版本"], "未知")
        XCTAssertEqual(values["下载来源"], "下载时自动选择")
        XCTAssertEqual(values["下载地址"], "下载完成后显示")
        XCTAssertEqual(values["上游版本"], "下载完成后显示")
        XCTAssertEqual(values["归档大小"], "下载完成后显示")
        XCTAssertEqual(values["归档 SHA-256"], "下载完成后显示")
        XCTAssertEqual(values["完整性"], "下载后验证")
    }

    func testDistributionVerifiedReceiptUsesSourceFields() {
        let source = Self.sampleSource
        let presentation = SchemeProvenancePresentation.make(
            isDistributionBacked: true,
            installedVersion: "ignored",
            manifestVersion: "2024.12",
            source: source,
            hasVerifiedReceipt: true
        )
        let values = Self.valueMap(presentation)
        let expectedSize = ByteCountFormatter.string(
            fromByteCount: source.expectedByteCount,
            countStyle: .file
        )

        XCTAssertEqual(values["版本"], "2024.12")
        XCTAssertEqual(values["下载来源"], "GitHub")
        XCTAssertEqual(values["下载地址"], source.downloadURL.absoluteString)
        XCTAssertEqual(values["上游版本"], "abc123def")
        XCTAssertEqual(values["归档大小"], expectedSize)
        XCTAssertEqual(values["归档 SHA-256"], source.archiveSHA256)
        XCTAssertEqual(values["完整性"], "SHA-256 已验证")
        XCTAssertEqual(presentation.row("下载地址")?.style, .monospacedSelectable)
        XCTAssertEqual(presentation.row("上游版本")?.style, .monospacedSelectable)
        XCTAssertEqual(presentation.row("归档 SHA-256")?.style, .monospacedSelectable)
    }

    func testFutureCatalogSchemeInheritsDistributionFillWithoutSchemaIDBranch() {
        let presentation = SchemeProvenancePresentation.make(
            isDistributionBacked: true,
            installedVersion: nil,
            manifestVersion: "1.0.0",
            source: nil,
            hasVerifiedReceipt: false
        )
        XCTAssertEqual(presentation.rows.count, 7)
        XCTAssertEqual(presentation.row("版本")?.value, "1.0.0")
        XCTAssertEqual(presentation.row("完整性")?.value, "下载后验证")
    }

    private static let expectedTitles = [
        "版本",
        "下载来源",
        "下载地址",
        "上游版本",
        "归档大小",
        "归档 SHA-256",
        "完整性",
    ]

    private static let sampleSource = RimeSchemeSourceVariant(
        id: "github",
        displayName: "GitHub",
        downloadURL: URL(string: "https://example.invalid/scheme.zip")!,
        upstreamRevision: "abc123def",
        expectedByteCount: 2_048_000,
        archiveSHA256: String(repeating: "ab", count: 32),
        allowedRedirectHosts: ["example.invalid"],
        stagedIdentityID: "staged"
    )

    private static func valueMap(_ presentation: SchemeProvenancePresentation) -> [String: String] {
        Dictionary(uniqueKeysWithValues: presentation.rows.map { ($0.title, $0.value) })
    }
}

extension SchemeProvenancePresentation {
    fileprivate func row(_ title: String) -> Row? {
        rows.first { $0.title == title }
    }
}
