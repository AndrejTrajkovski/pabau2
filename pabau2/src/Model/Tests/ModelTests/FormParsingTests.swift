import XCTest
import CasePaths
@testable import Model

final class FormParsingTests: XCTestCase {
	
	func testHTMLFormFilledFormParsing() {
		do {
			let formEntry = try decodeJSONFile(path: "Advanced Electrolysis Treatment Notes (V)", type: FilledForm.self)
			let builder = try HTMLFormBuilder(formEntry: formEntry)
			let form = HTMLForm.init(builder: builder)
			XCTAssertNotNil(form)
			
			let radio = extract(case: CSSClass.radio, from: form!.formStructure.first!.cssClass)
			let radioExpected = RadioState(["No", "Yes"].map(RadioChoice.init))
			XCTAssertEqual(radio, radioExpected)
			
			let staticText = extract(case: CSSClass.staticText, from: form!.formStructure[1].cssClass)
			XCTAssertNotNil(staticText)
			
			let inputText = extract(case: CSSClass.input_text, from: form!.formStructure[2].cssClass)
			let inputTextExpected = InputText(text: "Work Phone (opt)")
			XCTAssertEqual(inputText, inputTextExpected)
			
			let checkbox = extract(case: CSSClass.checkboxes, from: form!.formStructure[12].cssClass)
			XCTAssertNotNil(checkbox)
			XCTAssertEqual(checkbox!.checkboxes.count, 20)
			XCTAssertEqual(checkbox!.checkboxes[2], "Collagen Therapy")
			XCTAssertEqual(checkbox!.checkboxes.last!, "Removing Facial Veins")
			
			let textArea = extract(case: CSSClass.textarea, from: form!.formStructure[32].cssClass)
			XCTAssertNotNil(textArea)
			XCTAssertEqual(textArea!.text, "Do you have any other health problems or medical conditions (not listed) that may help us in your treatment plan? PLEASE LIST:")
			
			
		} catch {
			print(error)
			XCTAssert(false)
		}
	}
	
	func testHTMLFormTemplateParsing() {
		do {
			let formEntry = try decodeJSONFile(path: "MedicalHistoryForm", type: FilledForm.self)
			let builder = try HTMLFormBuilder(formEntry: formEntry)
			let form = HTMLForm.init(builder: builder)
			XCTAssertNotNil(form)
			
			let radio = extract(case: CSSClass.radio, from: form!.formStructure.first!.cssClass)
			let radioExpected = RadioState(["No", "Yes"].map(RadioChoice.init))
			XCTAssertEqual(radio, radioExpected)
			
			let staticText = extract(case: CSSClass.staticText, from: form!.formStructure[1].cssClass)
			XCTAssertNotNil(staticText)
			
			let inputText = extract(case: CSSClass.input_text, from: form!.formStructure[2].cssClass)
			let inputTextExpected = InputText(text: "Work Phone (opt)")
			XCTAssertEqual(inputText, inputTextExpected)
			
			let checkbox = extract(case: CSSClass.checkboxes, from: form!.formStructure[12].cssClass)
			XCTAssertNotNil(checkbox)
			XCTAssertEqual(checkbox!.checkboxes.count, 20)
			XCTAssertEqual(checkbox!.checkboxes[2], "Collagen Therapy")
			XCTAssertEqual(checkbox!.checkboxes.last!, "Removing Facial Veins")
			
			let textArea = extract(case: CSSClass.textarea, from: form!.formStructure[32].cssClass)
			XCTAssertNotNil(textArea)
			XCTAssertEqual(textArea!.text, "Do you have any other health problems or medical conditions (not listed) that may help us in your treatment plan? PLEASE LIST:")
			
			
		} catch {
			print(error)
			XCTAssert(false)
		}
	}
	
	func decodeJSONFile<T: Decodable>(path: String, type: T.Type) throws -> T {
		let thisSourceFile = URL(fileURLWithPath: #file)
		let thisDirectory = thisSourceFile.deletingLastPathComponent()
		let resourceURL = thisDirectory.appendingPathComponent("\(path).json")
		guard let jsonString = try? String(contentsOf: resourceURL) else {
			fatalError("Unable to convert UnitTestData.json to String")
		}

		print("The JSON string is: \(jsonString)")

		guard let jsonData = try? Data(contentsOf: resourceURL) else {
			fatalError("Unable to convert UnitTestData.json to Data")
		}

		return try JSONDecoder().decode(type, from: jsonData)
	}
}
