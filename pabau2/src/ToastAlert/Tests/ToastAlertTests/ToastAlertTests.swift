import XCTest
@testable import ToastAlert

final class ToastAlertTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ToastAlert().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}
