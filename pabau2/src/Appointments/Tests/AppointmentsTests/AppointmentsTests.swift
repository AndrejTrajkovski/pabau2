import XCTest
@testable import Appointments

final class AppointmentsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CalAppointments().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}
