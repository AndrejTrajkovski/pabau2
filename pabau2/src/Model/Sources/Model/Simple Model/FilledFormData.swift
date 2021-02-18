import Foundation
import Tagged
import CasePaths

struct _FilledForm: Codable {
	let id: FilledFormData.ID?
	let medicalResults: [MedicalResult]?
	let success: Bool
	let formTemplate: [_FormTemplate]
//	let companyDateFormat: String

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case medicalResults = "medical_results"
		case success
		case formTemplate = "form_template"
//		case companyDateFormat = "company_date_format"
	}
}

// MARK: - FormTemplate
struct _FormTemplate: Codable {
	let id, name, formType, serviceID: String
	//base64 representation of _FormStructure
	let formData: String

	enum CodingKeys: String, CodingKey {
		case id, name
		case formType = "form_type"
		case serviceID = "service_id"
		case formData = "form_data"
	}
}

// MARK: - MedicalResult
struct MedicalResult: Codable {
	let labelName: CSSFieldID.FakeID
	let id, attrID, contactID: String
	let value: String
	let epaperImages: [JSONAny]

	enum CodingKeys: String, CodingKey {
		case id
		case attrID = "attr_id"
		case labelName = "label_name"
		case contactID = "contact_id"
		case value
		case epaperImages = "epaper_images"
	}
}

// MARK: - Form
struct _FormData: Codable {
	let formStructure: [_FormStructure]

	enum CodingKeys: String, CodingKey {
		case formStructure = "form_structure"
	}
}

// MARK: - FormStructure
struct _FormStructure: Codable {
	let cssClass: CSSClassType
	let formStructureRequired: String
	let values: Values?
	let defaults: String?
	let linked, fldtype, fldwidth, trigger: String?
	let title, multiple, dispScoreTotal: String?
	
	func keyString() -> String {
		switch self.cssClass {
		case .input_text, .textarea:
			return extract(case: Values.string, from: self.values)!
		case .radio, .checkbox, .select, .signature, .diagram_mini:
			return self.title!
		case .staticText:
			return "staticText"
		case .heading:
			return "heading"
		case .cl_drugs:
			return "" // TODO
		case .image:
			return ""
		}
	}
	
	enum CodingKeys: String, CodingKey {
		case cssClass
		case formStructureRequired = "required"
		case values, defaults, linked, fldtype, fldwidth, trigger, title, multiple
		case dispScoreTotal = "disp_score_total"
	}
}

public enum CSSClassType: String, Equatable, Codable {
	case staticText
	case input_text
	case textarea
	case radio
	case signature
	case checkbox
	case select
	case heading
	case image
	case cl_drugs
	case diagram_mini
}

enum Values: Codable {
	case string(String)
	case valueMap([Int: Value])

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let x = try? container.decode([Int: Value].self) {
			self = .valueMap(x)
			return
		}
		if let x = try? container.decode(String.self) {
			self = .string(x)
			return
		}
		throw DecodingError.typeMismatch(Values.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Values"))
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .string(let x):
			try container.encode(x)
		case .valueMap(let x):
			try container.encode(x)
		}
	}
}

// MARK: - Value
struct Value: Codable {
	let value, baseline, critical, trigger: String
	let desc, score: String?
}

func makeIdxsById(_ idsByIdx: [Int: CSSField.ID]) -> [CSSField.ID: Int] {
	return Dictionary(grouping: idsByIdx.keys, by: { idsByIdx[$0]! })
		.mapValues { Int($0.first!) }
}
