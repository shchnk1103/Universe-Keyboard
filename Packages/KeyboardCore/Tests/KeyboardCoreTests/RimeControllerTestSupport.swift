import XCTest

@testable import KeyboardCore

/// 验证 KeyboardController 在 rimeEngine 设置后走 RIME 路径，所有行为与原有路径一致。
@MainActor
class RimeControllerTestSupport: XCTestCase {
    let client = FakeTextInputClient()
    let engine = FakeRimeEngine()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        return controller
    }()
}
