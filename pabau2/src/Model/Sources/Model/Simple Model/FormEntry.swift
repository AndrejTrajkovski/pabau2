import Foundation
import Tagged

public struct FormEntry: Codable {
	public typealias ID = Tagged<FormEntry, Int>
	let id: ID
	let medicalResults: [MedicalResult]
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
	let id, attrID, labelName, contactID: String
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
	let cssClass, formStructureRequired: String
	let values: Values?
	let defaults: String
	let linked, fldtype, fldwidth, trigger: String?
	let title, multiple, dispScoreTotal: String?

	enum CodingKeys: String, CodingKey {
		case cssClass
		case formStructureRequired = "required"
		case values, defaults, linked, fldtype, fldwidth, trigger, title, multiple
		case dispScoreTotal = "disp_score_total"
	}
}

enum Values: Codable {
	case string(String)
	case valueMap([String: Value])

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let x = try? container.decode([String: Value].self) {
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
