import CryptoKit
import XCTest

@testable import KeyboardCore

final class EnglishCandidateProviderTests: XCTestCase {
    private func makeProvider(
        _ words: [String],
        sourceVersion: String = "test-1"
    ) -> BundledEnglishCandidateProvider {
        BundledEnglishCandidateProvider(words: words, sourceVersion: sourceVersion)
    }

    // MARK: - Prefix generation

    func testPrefixCandidatesMatchPrefixAndHonorLimit() {
        let provider = makeProvider(["apple", "application", "apply", "banana", "app"])

        XCTAssertEqual(
            provider.candidates(for: "app", limit: 8),
            ["app", "apple", "application", "apply"]
        )
        XCTAssertEqual(provider.candidates(for: "app", limit: 2), ["app", "apple"])
        XCTAssertEqual(provider.candidates(for: "b", limit: 8), ["banana"])
        XCTAssertEqual(provider.candidates(for: "z", limit: 8), [])
    }

    func testPrefixLookupIsCaseInsensitiveAndRejectsEmptyPrefix() {
        let provider = makeProvider(["apple", "banana"])

        XCTAssertEqual(provider.candidates(for: "AP", limit: 8), ["apple"])
        XCTAssertEqual(provider.candidates(for: "", limit: 8), [])
        XCTAssertEqual(provider.candidates(for: "  ", limit: 8), [])
    }

    func testDeduplicatesWords() {
        let provider = makeProvider(["apple", "apple", "apply"])

        XCTAssertEqual(provider.candidates(for: "ap", limit: 8), ["apple", "apply"])
    }

    func testRepeatedQueriesAreStablePureMemoryLookups() {
        let provider = makeProvider(["hello", "help", "helm", "world"])

        let first = provider.candidates(for: "he", limit: 8)
        for _ in 0..<1_000 {
            XCTAssertEqual(provider.candidates(for: "he", limit: 8), first)
        }
        XCTAssertEqual(first, ["hello", "helm", "help"])
    }

    // MARK: - Case alignment

    func testCaseAlignmentFollowsTypedPrefix() {
        XCTAssertEqual(EnglishCandidateCase.aligned(prefix: "ap", word: "apple"), "apple")
        XCTAssertEqual(EnglishCandidateCase.aligned(prefix: "Ap", word: "apple"), "Apple")
        XCTAssertEqual(EnglishCandidateCase.aligned(prefix: "AP", word: "apple"), "APPLE")
        XCTAssertEqual(EnglishCandidateCase.aligned(prefix: "APP", word: "apple"), "APPLE")
        XCTAssertEqual(EnglishCandidateCase.aligned(prefix: "", word: "apple"), "apple")
        // Non-letter prefixes never rewrite the stored word.
        XCTAssertEqual(EnglishCandidateCase.aligned(prefix: "1a", word: "apple"), "apple")
    }

    // MARK: - Validation

    func testStrictValidationRejectsOversizeInvalidAndDuplicateWords() {
        XCTAssertThrowsError(
            try BundledEnglishCandidateProvider(
                validating: Array(
                    repeating: "word",
                    count: EnglishWordlistValidator.maximumEntryCount + 1
                )))

        XCTAssertThrowsError(try BundledEnglishCandidateProvider(validating: ["ok", "has space"]))
        XCTAssertThrowsError(try BundledEnglishCandidateProvider(validating: ["ok", "UPPER"]))
        XCTAssertThrowsError(try BundledEnglishCandidateProvider(validating: ["ok", "café"]))
        XCTAssertThrowsError(try BundledEnglishCandidateProvider(validating: ["ok", "a"]))
        XCTAssertThrowsError(
            try BundledEnglishCandidateProvider(validating: [
                "ok",
                String(repeating: "x", count: EnglishWordlistValidator.maximumWordLength + 1),
            ]))
        XCTAssertThrowsError(try BundledEnglishCandidateProvider(validating: ["ok", "ok"]))
    }

    func testStrictValidationAcceptsBoundedWordlist() throws {
        let provider = try BundledEnglishCandidateProvider(validating: ["apple", "apply"])

        XCTAssertEqual(provider.candidates(for: "ap", limit: 8), ["apple", "apply"])
        XCTAssertFalse(provider.sourceVersion.isEmpty)
    }

    // MARK: - Resource loader contract

    func testResourceLoaderRejectsWrongVersionOversizeAndInvalidEntries() {
        let wrongVersion = Data(
            #"{"version":2,"contentVersion":"1.0.0","words":["apple"]}"#.utf8
        )
        XCTAssertNil(BundledEnglishCandidateProvider.provider(fromResourceData: wrongVersion))

        let wrongContentVersion = Data(
            #"{"version":1,"contentVersion":"0.9.0","words":["apple"]}"#.utf8
        )
        XCTAssertNil(BundledEnglishCandidateProvider.provider(fromResourceData: wrongContentVersion))

        let oversized = Data(
            repeating: 0,
            count: BundledEnglishCandidateProvider.maximumBundledResourceBytes + 1
        )
        XCTAssertNil(BundledEnglishCandidateProvider.provider(fromResourceData: oversized))

        let invalidWord = Data(
            #"{"version":1,"contentVersion":"1.0.0","words":["apple","apple"]}"#.utf8
        )
        XCTAssertNil(BundledEnglishCandidateProvider.provider(fromResourceData: invalidWord))
    }

    // MARK: - State model

    func testCandidateStateCarriesPrefixSuggestionsAndVersion() {
        var state = EnglishCandidateState()
        XCTAssertTrue(state.isEmpty)

        state = EnglishCandidateState(prefix: "ap", suggestions: ["apple"], sourceVersion: "v1")
        XCTAssertFalse(state.isEmpty)
        XCTAssertEqual(state.prefix, "ap")
        XCTAssertEqual(state.suggestions, ["apple"])
        XCTAssertEqual(state.sourceVersion, "v1")
    }

    // MARK: - Pinned artifact hash chain

    func testBundledWordlistResourceIsPinnedAndBounded() throws {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "english_wordlist_v1", withExtension: "json")
        )
        let data = try Data(contentsOf: url)

        XCTAssertGreaterThanOrEqual(data.count, 150 * 1_024)
        XCTAssertLessThanOrEqual(data.count, 250 * 1_024)

        let digest = SHA256.hash(data: data)
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        XCTAssertEqual(
            hex,
            "593309209616b50325505019a02fa16bb24105214f2e44a322203b4b8608b7c0",
            "english_wordlist_v1.json drifted; regenerate and re-pin intentionally"
        )

        let provider = try XCTUnwrap(BundledEnglishCandidateProvider.provider(fromResourceData: data))
        XCTAssertGreaterThan(provider.wordCount, 10_000)
        XCTAssertLessThanOrEqual(
            provider.wordCount,
            EnglishWordlistValidator.maximumEntryCount
        )
        XCTAssertEqual(provider.sourceVersion, BundledEnglishCandidateProvider.contentVersion)
        XCTAssertFalse(provider.candidates(for: "ap", limit: 8).isEmpty)
        XCTAssertFalse(provider.candidates(for: "wor", limit: 8).isEmpty)
    }

    func testSharedProviderLoadsBundledResource() {
        XCTAssertGreaterThan(BundledEnglishCandidateProvider.shared.wordCount, 10_000)
    }
}
