import XCTest

@testable import Universe_Keyboard

@MainActor
final class LocalDictionaryModelTests: XCTestCase {
    func testEntriesFooterUsesSearchCopyForTruncatedResults() {
        let model = LocalDictionaryModel()
        model.entries = Array(
            repeating: LocalDictionaryEntry(id: "entry", text: "你好", code: "ni hao", weight: nil),
            count: 120
        )

        XCTAssertEqual(model.entriesFooter(searching: true), "最多显示前 120 个搜索结果。")
    }

    func testEntriesFooterUsesDefaultCopyWhenNotSearching() {
        let model = LocalDictionaryModel()
        model.entries = [
            LocalDictionaryEntry(id: "entry", text: "你好", code: "ni hao", weight: nil)
        ]

        XCTAssertEqual(
            model.entriesFooter(searching: false),
            "显示前 1 个词条，可使用搜索快速查找本地条目。"
        )
    }

    func testRefreshUsesInjectedIndexServiceSnapshot() async {
        let expected = DictionarySnapshot(
            files: [
                LocalDictionaryFile(
                    id: "rime_ice.dict.yaml",
                    displayName: "rime_ice",
                    relativePath: "rime_ice.dict.yaml",
                    byteCount: 32,
                    entryCount: 1
                )
            ],
            entries: [
                LocalDictionaryEntry(id: "rime_ice.dict.yaml-1", text: "你好", code: "ni hao", weight: "100")
            ],
            totalEntries: 1,
            totalBytes: 32
        )
        let service = StubDictionaryIndexService(snapshot: expected)
        let model = LocalDictionaryModel(indexService: service)

        await model.refreshImmediately(query: "ni")
        let receivedQueries = await service.receivedScanQueries()

        XCTAssertEqual(model.files.map(\.id), ["rime_ice.dict.yaml"])
        XCTAssertEqual(model.entries.map(\.text), ["你好"])
        XCTAssertEqual(model.totalEntries, 1)
        XCTAssertEqual(model.totalBytes, 32)
        XCTAssertFalse(model.isLoading)
        XCTAssertEqual(receivedQueries, ["ni"])
    }

    func testPreviewModelUsesInjectedServiceAndPreservesResultLimitCopy() async {
        let file = LocalDictionaryFile(
            id: "rime_ice.dict.yaml",
            displayName: "rime_ice",
            relativePath: "rime_ice.dict.yaml",
            byteCount: 0,
            entryCount: 120
        )
        let entries = (0..<DictionaryScanner.resultLimit).map {
            LocalDictionaryEntry(id: "\($0)", text: "词条\($0)", code: "code", weight: nil)
        }
        let service = StubDictionaryIndexService(previewEntries: entries)
        let model = LocalDictionaryPreviewModel(file: file, indexService: service)

        await model.refreshImmediately(query: "code")
        let receivedQueries = await service.receivedPreviewQueries()

        XCTAssertEqual(model.entries.count, 120)
        XCTAssertEqual(model.entriesFooter(), "最多显示前 120 个词条。")
        XCTAssertEqual(receivedQueries, ["code"])
    }
}

final class DictionaryIndexServiceTests: XCTestCase {
    func testScanReadsDictionaryFilesAndFiltersByCode() async throws {
        let rootURL = try makeTemporaryDictionaryRoot()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        try dictionaryPayload.write(
            to: rootURL.appendingPathComponent("rime_ice.dict.yaml"),
            atomically: true,
            encoding: .utf8
        )

        let snapshot = await DictionaryIndexService(rootURL: rootURL).scan(query: "shi jie")

        XCTAssertEqual(snapshot.files.map(\.displayName), ["rime_ice"])
        XCTAssertEqual(snapshot.totalEntries, 2)
        XCTAssertEqual(snapshot.entries.map(\.text), ["世界"])
        XCTAssertEqual(snapshot.entries.first?.weight, nil)
    }

    func testPreviewRejectsPathTraversalOutsideDictionaryRoot() async throws {
        let rootURL = try makeTemporaryDictionaryRoot()
        defer { try? FileManager.default.removeItem(at: rootURL.deletingLastPathComponent()) }
        let outsideURL = rootURL.deletingLastPathComponent().appendingPathComponent("outside.dict.yaml")
        try dictionaryPayload.write(to: outsideURL, atomically: true, encoding: .utf8)

        let entries = await DictionaryIndexService(rootURL: rootURL).preview(
            fileID: "../outside.dict.yaml",
            query: ""
        )

        XCTAssertTrue(entries.isEmpty)
    }

    private var dictionaryPayload: String {
        """
        # Rime dictionary
        ---
        name: test
        ...
        你好\tni hao\t100
        世界\tshi jie
        """
    }

    private func makeTemporaryDictionaryRoot() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("shared", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}

@MainActor
private final class StubDictionaryIndexService: DictionaryIndexServicing {
    private let snapshot: DictionarySnapshot
    private let previewEntries: [LocalDictionaryEntry]
    private var scanQueries: [String] = []
    private var previewQueries: [String] = []

    init(
        snapshot: DictionarySnapshot = DictionarySnapshot(
            files: [],
            entries: [],
            totalEntries: 0,
            totalBytes: 0
        ),
        previewEntries: [LocalDictionaryEntry] = []
    ) {
        self.snapshot = snapshot
        self.previewEntries = previewEntries
    }

    func scan(query: String) async -> DictionarySnapshot {
        scanQueries.append(query)
        return snapshot
    }

    func preview(fileID: String, query: String) async -> [LocalDictionaryEntry] {
        previewQueries.append(query)
        return previewEntries
    }

    func receivedScanQueries() async -> [String] {
        scanQueries
    }

    func receivedPreviewQueries() async -> [String] {
        previewQueries
    }
}
