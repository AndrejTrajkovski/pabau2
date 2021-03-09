import XCTest
@testable import Avatar

final class AvatarTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Avatar().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}
