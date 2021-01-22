import XCTest
@testable import Model

final class FormParsingTests: XCTestCase {
	
	func testHTMLFormBuilderInit() {
		do {
			let builder = try HTMLFormBuilder(formEntry: getMedHistoryForm())
			let form = HTMLForm.init(builder: builder)
			XCTAssertNotNil(form)
		} catch {
			print(error)
			XCTAssert(false)
		}
	}
	
	func testFormEntryParsing() {
		_ = getMedHistoryForm()
	}
	
	func getMedHistoryForm() -> FormEntry {
		let thisSourceFile = URL(fileURLWithPath: #file)
		let thisDirectory = thisSourceFile.deletingLastPathComponent()
		let resourceURL = thisDirectory.appendingPathComponent("MedicalHistoryForm.json")

		guard let jsonString = try? String(contentsOf: resourceURL) else {
			fatalError("Unable to convert UnitTestData.json to String")
		}

		print("The JSON string is: \(jsonString)")

		guard let jsonData = try? Data(contentsOf: resourceURL) else {
			fatalError("Unable to convert UnitTestData.json to Data")
		}

		do {
			let result = try JSONDecoder().decode(FormEntry.self, from: jsonData)
			return result
		} catch {
			print(error)
			fatalError()
		}
	}
//
//	static var allTests = [
//		("testExample", testExample),
//	]
}
