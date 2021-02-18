import Foundation
import CasePaths
import Overture

public enum CSSClass: Equatable {
	
	public var isFulfilled: Bool {
		switch self {
		case .staticText(_):
			return true
		case .input_text(let inputText):
			return !inputText.text.isEmpty
		case .textarea(let textAreaText):
			return !textAreaText.text.isEmpty
		case .radio(let radio):
			return radio.selectedChoice != nil
		case .signature(let signature):
			return !signature.drawings.isEmpty//TODO: add image url in check
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
	
	init(_formStructure: _FormStructure) throws {
		let stringValue = extract(case: Values.string, from:_formStructure.values)
		switch _formStructure.cssClass {
		case .staticText:
			self = .staticText(StaticText(AttributedOrText.init(value: stringValue ?? "")))
		case .input_text:
			self = .input_text(InputText(text: stringValue ?? ""))
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
				.map(\.value).map(SelectChoice.init)
			self = .select(SelectState.init(choices))
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
			inputText.text = medicalResult.value
			self = .input_text(inputText)
		case .textarea(var textArea):
			textArea.text = medicalResult.value
			self = .textarea(textArea)
		case .radio(var radioState):
			radioState.selectedChoice = RadioChoice.init(medicalResult.value)
			self = .radio(radioState)
		case .signature(var signature):
			signature.signatureUrl = medicalResult.value
			self = .signature(signature)
		case .checkboxes(var checkboxes):
			checkboxes.selected = Set.init(
				medicalResult.value.components(separatedBy: ",")
				.compactMap { Data.init(base64Encoded: $0) }
				.compactMap { String.init(data: $0, encoding: .utf8) }
			)
			self = .checkboxes(checkboxes)
		case .select(var selectState):
			selectState.selectedChoice = SelectChoice.init(medicalResult.value)
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
