import XCTest
@testable import CoreDataModel

final class CoreDataModelTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CoreDataModel().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
