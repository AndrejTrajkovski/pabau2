import XCTest
@testable import Journey

final class JourneyTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Journey().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
