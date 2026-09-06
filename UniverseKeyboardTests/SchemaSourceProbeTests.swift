import Foundation
import KeyboardCore
import Synchronization
import XCTest

@testable import Universe_Keyboard

@MainActor
final class SchemaSourceProbeTests: XCTestCase {
    func testProbeDistinguishesChangedArtifactFromUnavailableSource() async throws {
        let source = try XCTUnwrap(
            RimeSchemeCatalog.entry(for: "rime_ice")?.distribution?.manifest.sourceVariants.first)
        let cases: [(Int, String, String?, SchemaSourceProbeResult)] = [
            (200, "mirror.nju.edu.cn", String(source.expectedByteCount), .available),
            (200, "mirror.nju.edu.cn", String(source.expectedByteCount - 1), .rejected(.archiveSize)),
            (503, "mirror.nju.edu.cn", nil, .rejected(.httpStatus)),
            (200, "untrusted.example", nil, .rejected(.redirectHost)),
            (200, "mirror.nju.edu.cn", nil, .available),
        ]
        for (status, host, length, expected) in cases {
            let response = try XCTUnwrap(
                HTTPURLResponse(
                    url: URL(string: "https://\(host)/full.zip")!, statusCode: status,
                    httpVersion: "HTTP/1.1", headerFields: length.map { ["Content-Length": $0] }
                ))
            let probe = URLSessionHEADSchemaSourceProbe { request in
                XCTAssertEqual(request.httpMethod, "HEAD")
                XCTAssertEqual(request.timeoutInterval, 5)
                return response
            }
            let result = try await probe.probeSource(source)
            XCTAssertEqual(result, expected)
        }
    }

    func testTransportAndCancellationRemainDistinct() async throws {
        let source = try XCTUnwrap(
            RimeSchemeCatalog.entry(for: "rime_ice")?.distribution?.manifest.sourceVariants.first)
        let failing = URLSessionHEADSchemaSourceProbe { _ in throw URLError(.timedOut) }
        let result = try await failing.probeSource(source)
        XCTAssertEqual(result, .rejected(.transport))
        let cancelled = URLSessionHEADSchemaSourceProbe { _ in throw CancellationError() }
        do {
            _ = try await cancelled.probeSource(source)
            XCTFail("Cancellation must not be mislabeled as an unavailable source")
        } catch is CancellationError {} catch { XCTFail("Unexpected error: \(error)") }
    }

    func testSizeRejectionDoesNotHideValidAlternativeAndRecordsSource() async throws {
        let variants = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.distribution?.manifest.sourceVariants)
        let sink = Mutex<[String]>([])
        let probe = FixedResultProbe(results: ["nju": .rejected(.archiveSize), "github": .available])
        let selector = URLSessionSchemaSourceSelector(probe: probe, hedgeDelayNanoseconds: 1_000_000)
        let selected = try await selector.selectSource(from: variants, preferredSourceID: "nju") { source, result in
            if case .rejected(let reason) = result { sink.withLock { $0.append("\(source.id):\(reason.rawValue)") } }
        }
        XCTAssertEqual(selected.id, "github")
        XCTAssertEqual(sink.withLock { $0 }, ["nju:archive_size"])
    }

    func testChangedAndUnreachableSourcesDoNotBecomeNetworkOnlyError() async throws {
        let variants = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.distribution?.manifest.sourceVariants)
        for results: [String: SchemaSourceProbeResult] in [
            ["nju": .rejected(.archiveSize), "github": .rejected(.transport)],
            ["nju": .rejected(.archiveSize), "github": .rejected(.archiveSize)],
        ] {
            let selector = URLSessionSchemaSourceSelector(
                probe: FixedResultProbe(results: results), hedgeDelayNanoseconds: 0)
            do {
                _ = try await selector.selectSource(from: variants, preferredSourceID: nil)
                XCTFail("Changed pinned bytes must fail closed")
            } catch { XCTAssertEqual(error as? DownloadError, .sourceArtifactChanged) }
        }
        let selector = URLSessionSchemaSourceSelector(
            probe: FixedResultProbe(results: ["nju": .rejected(.transport), "github": .rejected(.httpStatus)]),
            hedgeDelayNanoseconds: 0
        )
        do {
            _ = try await selector.selectSource(from: variants, preferredSourceID: nil)
            XCTFail("No source is available")
        } catch { XCTAssertEqual(error as? DownloadError, .allSourcesUnavailable) }
    }
}

private struct FixedResultProbe: SchemaSourceProbing {
    let results: [String: SchemaSourceProbeResult]
    func isReachable(_ variant: RimeSchemeSourceVariant) async throws -> Bool {
        try await probeSource(variant) == .available
    }
    func probeSource(_ variant: RimeSchemeSourceVariant) async throws -> SchemaSourceProbeResult {
        results[variant.id] ?? .rejected(.transport)
    }
}
