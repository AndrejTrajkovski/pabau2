import XCTest
@testable import Clients

final class ClientsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Clients().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
