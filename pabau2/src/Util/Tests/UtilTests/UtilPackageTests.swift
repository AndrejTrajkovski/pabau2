import XCTest
@testable import Util

final class UtilTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Util().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}
