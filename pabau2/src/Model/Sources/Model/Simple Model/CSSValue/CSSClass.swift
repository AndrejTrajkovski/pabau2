import Foundation
import CasePaths
import Overture

public enum CSSClass: Equatable {
	
	public var isFulfilled: Bool {
		switch self {
		case .staticText(_):
			return true
		case .input_text(let inputText):
			return inputText.isFulfilled
		case .textarea(let textAreaText):
			return !textAreaText.text.isEmpty
		case .radio(let radio):
			return radio.selectedChoice != nil
		case .signature(let signature):
			return !signature.currentDrawings.isEmpty//TODO: add image url in check
		case .checkboxes(let checkboxes):
			return !checkboxes.selected.isEmpty
		case .select(let select):
			return select.selectedChoice != nil
		case .heading(_):
			return true
		case .image(_):
			return true
		case .cl_drugs(_):
			return true
		case .diagram_mini(_):
			return true
		case .unknown:
			return true
		}
	}
	
	case staticText(StaticText)
	case input_text(InputText)
	case textarea(TextArea)
	case radio(RadioState)
	case signature(SignatureState)
	case checkboxes(CheckBoxState)
	case select(SelectState)
	case heading(Heading)
	case image(String)
	case cl_drugs(ClDrugs)
	case diagram_mini(DiagramMini)
	case unknown
	
	init(_formStructure: _FormStructure, fieldId: CSSFieldID) throws {
		let stringValue = extract(case: Values.string, from:_formStructure.values)
		switch _formStructure.cssClass {
		case .staticText:
			self = .staticText(StaticText(AttributedOrText.init(value: stringValue ?? "")))
		case .input_text:
			self = .input_text(InputText(fldType: _formStructure.fldtype))
		case .textarea:
			self = .textarea(TextArea(text: stringValue ?? ""))
		case .radio:
			let choices = try extractAndSortValues(_formStructure.values)
				.map(\.value).map(RadioChoice.init)
			self = .radio(RadioState(choices))
		case .signature:
			self = .signature(SignatureState(signatureUrl: stringValue))
		case .checkbox:
			let choices = try extractAndSortValues(_formStructure.values)
				.map(\.value)
			self = .checkboxes(CheckBoxState(choices))
		case .select:
			let choices = try extractAndSortValues(_formStructure.values)
				.map(\.value)
			self = .select(SelectState.init(choices, fieldId))
		case .heading:
			self = .heading(Heading.init(value: AttributedOrText.init(value: stringValue ?? "")))
		case .image:
			self = .image(stringValue ?? "")
		case .cl_drugs:
			self = .cl_drugs(ClDrugs.init())
		case .diagram_mini:
			self = .diagram_mini(DiagramMini())
		}
	}
	
	mutating func updateWith(medicalResult: MedicalResult) {
		switch self {
		case .staticText:
			break
		case .input_text(var inputText):
			inputText.updateWith(medicalResult: medicalResult)
			self = .input_text(inputText)
		case .textarea(var textArea):
			textArea.text = medicalResult.value
			self = .textarea(textArea)
		case .radio(var radioState):
			radioState.selectedChoice = RadioChoice.init(medicalResult.value)
			self = .radio(radioState)
		case .signature(var signature):
			signature.signatureUrl = medicalResult.value
//			print("https://crm.pabau.com" + (medicalResult.value))
			self = .signature(signature)
		case .checkboxes(var checkboxes):
			checkboxes.selected = Set.init(
				medicalResult.value.components(separatedBy: ",")
				.compactMap { Data.init(base64Encoded: $0) }
				.compactMap { String.init(data: $0, encoding: .utf8) }
			)
			self = .checkboxes(checkboxes)
		case .select(var selectState):
			selectState.select(choice: medicalResult.value)
			self = .select(selectState)
		case .heading:
			return
		case .image:
			return
		case .cl_drugs:
			return
		case .diagram_mini:
			return
		case .unknown:
			return
		}
	}
	
	func getJSONPOSTValue() -> String? {
		switch self {
		case .input_text(let inputText):
		return inputText.getValue()
		case .textarea(let textArea):
			return textArea.text
		case .radio(let radio):
			return radio.selectedChoice?.title
		case .checkboxes(let checkbox):
			return checkbox.selected
				.flatMap { $0.data(using: .utf8) }
				.map { (data: Data) in data.base64EncodedString() }
				.joined(separator: ",")
		case .select(let select):
			return select.selectedChoice?.title
		case .signature:
			return ""
		case .diagram_mini:
			return ""
		case .staticText:
			return nil
		case .heading:
			return nil
		case .cl_drugs:
			return "" // TODO
		case .image:
			return ""
		case .unknown:
			return nil
		}
	}

}

enum CSSClassTypeMismatch: Error {
	case expectedValueMap
	case expectedString
}

fileprivate let extractAndSortValues: (Values?) throws -> [Value] =
	pipe(extractValueMap(values:), sort(valueMap:))

fileprivate func extractValueMap(values: Values?) throws -> [Int: Value] {
	if let valueMap = extract(case: Values.valueMap, from:values) {
		return valueMap
	} else {
		throw CSSClassTypeMismatch.expectedValueMap
	}
}

fileprivate func sort(valueMap: [Int: Value]) -> [Value] {
	valueMap.sorted(by: \.key).map(\.value)
}
