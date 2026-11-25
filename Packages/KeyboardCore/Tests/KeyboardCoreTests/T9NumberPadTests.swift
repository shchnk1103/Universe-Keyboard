import XCTest

@testable import KeyboardCore

/// PB-009 machine checks that live in KeyboardCore: layout table, direct insert, return, 26-key regression, shortcut set.
@MainActor
final class T9NumberPadTests: XCTestCase {
    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

    func testLayoutTableMatchesDesignGrid() {
        let columns = T9NumberPadLayout.columns
        XCTAssertEqual(columns.map(\.count), [4, 4, 3])
        XCTAssertEqual(columns[1].map(\.count), [3, 3, 3, 3])
        XCTAssertEqual(columns[0].map { $0.map(\.title) }, [["@"], ["+"], ["-"], ["#+="]])
        XCTAssertEqual(
            columns[1].map { $0.map(\.title) },
            [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["返回", "0", "."]])
        XCTAssertEqual(columns[2].map { $0.map(\.title) }, [["⌫"], ["空格"], ["return"]])
        XCTAssertEqual(columns[2][1][0].tap, .literal(" "))
        XCTAssertTrue(columns[2][1][0].installsSpaceCursorLongPress)
        XCTAssertEqual(
            columns.flatMap { $0 }.flatMap { $0 }.filter { $0.tap == .insertReturn }.map(\.title),
            ["return"])
        let returnLocations = columns.enumerated().flatMap { columnIndex, rows in
            rows.enumerated().flatMap { rowIndex, keys in
                keys.enumerated().compactMap { keyIndex, key in
                    key.tap == .insertReturn ? (columnIndex, rowIndex, keyIndex) : nil
                }
            }
        }
        XCTAssertEqual(returnLocations.count, 1)
        XCTAssertEqual(returnLocations[0].0, 2)
        XCTAssertEqual(returnLocations[0].1, 2)
    }

    func testInsertLiteralStaysOnNumbersPageWithoutComposition() {
        controller.state.currentPage = .numbers
        controller.state.inputMode = .chinese
        for literal in ["1", ".", "@", "+", "-", " ", "/", "÷"] {
            client.text = ""
            controller.state.currentComposition = ""
            controller.state.lastRimeOutput = nil
            _ = controller.handle(.insertT9NumberPadText(literal))
            XCTAssertEqual(client.text, literal, literal)
            XCTAssertEqual(controller.state.currentPage, .numbers, literal)
            XCTAssertEqual(controller.state.currentComposition, "", literal)
            XCTAssertNil(controller.state.lastRimeOutput?.rawInput, literal)
        }
    }

    func testInsertCommitsDisplayTextThenAppendsLiteral() {
        controller.state.currentPage = .numbers
        controller.state.inputMode = .chinese
        controller.state.currentComposition = "ni"
        _ = controller.handle(.insertT9NumberPadText("1"))
        XCTAssertEqual(client.text, "ni1")
        XCTAssertEqual(controller.state.currentPage, .numbers)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.lastRimeOutput)
    }

    func testReturnToLettersKeepsCompositionBytes() {
        controller.state.currentPage = .numbers
        controller.state.currentComposition = "ni"
        var steps = 0
        while controller.state.currentPage != .letters && steps < 4 {
            _ = controller.handle(.togglePage)
            steps += 1
        }
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertEqual(controller.state.currentComposition, "ni")
    }

    func testChineseTwentySixNumbersAtStillReturnsToLetters() {
        controller.state.currentPage = .numbers
        controller.state.inputMode = .chinese
        _ = controller.handle(.insertKey("@"))
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    func testShortcutSetIsExactAndGated() {
        XCTAssertEqual(
            T9NumberPadLayout.shortcutSymbols,
            ["/", "%", ":", "×", "÷", "=", "#", "¥", "$", "~", "—", "(", ")", "℃", "±", "‰", "°", "、"])
        XCTAssertEqual(Set(T9NumberPadLayout.shortcutSymbols).count, 18)
        // 不与数字主面板已有按键（@ + - .）重复
        let mainPanelTitles = Set(T9NumberPadLayout.columns.flatMap { $0 }.flatMap { $0 }.map(\.title))
        XCTAssertTrue(Set(T9NumberPadLayout.shortcutSymbols).isDisjoint(with: mainPanelTitles))
        let show = T9NumberPadLayout.showsShortcutBar(
            page: .numbers, inputMode: .chinese, layout: .nineKey, readinessMatched: true,
            composition: "", hasPendingPunctuation: false, hasPendingKaomoji: false)
        XCTAssertTrue(show)
        XCTAssertFalse(
            T9NumberPadLayout.showsShortcutBar(
                page: .numbers, inputMode: .chinese, layout: .nineKey, readinessMatched: true,
                composition: "ni", hasPendingPunctuation: false, hasPendingKaomoji: false))
        XCTAssertFalse(
            T9NumberPadLayout.showsShortcutBar(
                page: .numbers, inputMode: .chinese, layout: .twentySixKey, readinessMatched: true,
                composition: "", hasPendingPunctuation: false, hasPendingKaomoji: false))
        XCTAssertFalse(
            T9NumberPadLayout.showsShortcutBar(
                page: .letters, inputMode: .chinese, layout: .nineKey, readinessMatched: true,
                composition: "", hasPendingPunctuation: false, hasPendingKaomoji: false))
        XCTAssertFalse(
            T9NumberPadLayout.showsShortcutBar(
                page: .numbers, inputMode: .chinese, layout: .nineKey, readinessMatched: true,
                composition: "", hasPendingPunctuation: true, hasPendingKaomoji: false))
    }
}
