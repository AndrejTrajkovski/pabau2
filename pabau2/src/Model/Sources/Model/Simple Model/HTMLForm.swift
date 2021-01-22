import Foundation
import Tagged

public struct HTMLForm: Identifiable, Equatable, CustomDebugStringConvertible {
	
	public var debugDescription: String {
		return name
	}
	
	public typealias ID = Tagged<HTMLForm, Int>
	
	public let entryId: FormEntry.ID?
	
	public let id: HTMLForm.ID
	
	public let name: String
	
	public let formType: FormType
	
	public let ePaper: Bool?

	public var formStructure: [CSSField]
	
	public var canProceed: Bool {
		return formStructure.allSatisfy {
			!$0._required || $0.cssClass.isFulfilled
		}
	}
	
	public init(id: Int,
				name: String,
				formType: FormType,
				ePaper: Bool? = nil,
				formStructure: [CSSField]) {
		self.id = HTMLForm.ID(rawValue: id)
		self.name = name
		self.formType = formType
		self.ePaper = ePaper
		self.formStructure = formStructure
		self.entryId = nil
	}
	
	init?(builder: HTMLFormBuilder?) {
		guard let builder = builder else {
			return nil
		}
		self.entryId = builder.entryId
		self.id = builder.id
		self.name = builder.name
		self.formType = builder.formType
		self.ePaper = builder.ePaper
		self.formStructure = builder.formStructure
	}
}

enum HTMLFormBuilderError: Error {
	case noTemplate
	case idNotInteger
	case unhandledFormType
	case formStructureNotBase64
}

struct HTMLFormBuilder {
	
	public var entryId: FormEntry.ID?
	public var id: HTMLForm.ID
	public var name: String
	public var formType: FormType
	public var ePaper: Bool?
	public var formStructure: [CSSField]
	
	init(formEntry: FormEntry) throws {
		guard let template = formEntry.formTemplate.first else {
			throw HTMLFormBuilderError.noTemplate
		}
		try self = .init(template: template)
		
		self.entryId = formEntry.id
		
		guard let medResults = formEntry.medicalResults else { return }
		
		let medicalResultsById = Dictionary.init(grouping: medResults, by: { $0.labelName })
			.compactMapValues(\.first)
		
		var updated = [CSSField]()
		self.formStructure.forEach {
			if let medResult = medicalResultsById[$0.id] {
				var new = $0
				new.cssClass.updateWith(medicalResult: medResult)
				updated.append(new)
			} else {
				updated.append($0)
			}
		}
		self.formStructure = updated
	}
	
	init(template: _FormTemplate) throws {
		guard let id = Int(template.id) else { throw HTMLFormBuilderError.idNotInteger }
		guard let formType = FormType(rawValue: template.formType) else { throw HTMLFormBuilderError.unhandledFormType }
		
		self.entryId = nil
		self.id = .init(rawValue: id)
		self.name = template.name
		self.formType = formType
		self.ePaper = nil
		self.formStructure = try Self.cssFields(formData: template.formData)
	}
	
	static func cssFields(formData: String) throws -> [CSSField] {
		guard let encodedFormData = Data(base64Encoded: formData) else {
			throw HTMLFormBuilderError.formStructureNotBase64
		}
		let formDataDecoded = try newJSONDecoder().decode(_FormData.self, from: encodedFormData)
		return makeCSSFieldsIdsByIdx(formStructure: formDataDecoded.formStructure)
	}
	
	static func makeCSSFieldsIdsByIdx(formStructure: [_FormStructure]) -> [CSSField] {
		var result: [CSSField] = []
		formStructure.enumerated().forEach { idx, field in
			let id = CSSField.ID.init(idx: idx, cssField: field)
			guard let cssField = CSSField.init(id: id, formStructure: field) else { return }
			result.append(cssField)
		}
		return result
	}
}

extension HTMLForm {
	
	public static let mockConsents  = [
		HTMLForm(id: 1,
				 name: "Consent - Transplant",
				 formType: .consent,
				 ePaper: false,
				 formStructure:
					[
						
					]),
		HTMLForm(id: 3, name: "Test Consent", formType: .consent,
				 ePaper: false,
				 formStructure:
					[
						
					]),
		HTMLForm(id: 4, name: "Vaccines", formType: .consent,
				 ePaper: false,
				 formStructure:
					[
						
					]),
		HTMLForm(id: 123, name: "Signature Consent", formType: .consent,
				 ePaper: false,
				 formStructure:
					[
						
					]),
		HTMLForm(id: 1234231231231233, name: "Massage Consent", formType: .consent,
				 ePaper: false,
				 formStructure:
					[
						
					]),
	]
	
	public static let mockTreatmentN  = [
		HTMLForm(id: 1, name: "Treatment - Transplant", formType: .treatment,
				 ePaper: false,
				 formStructure:
					[
						
					]),
		HTMLForm(id: 2, name: "Treatment - Botox", formType: .treatment,
				 ePaper: false,
				 formStructure:
					[
						
					]),
		HTMLForm(id: 3, name: "Test Treatment", formType: .treatment,
				 ePaper: false,
				 formStructure:
					[
						
					]),
		HTMLForm(id: 4, name: "Treatment Vaccines", formType: .treatment,
				 ePaper: false,
				 formStructure:
					[
						
					]),
		HTMLForm(id: 123, name: "Signature Treatment", formType: .treatment,
				 ePaper: false,
				 formStructure:
					[
						
					]),
		HTMLForm(id: 123423, name: "Treatmentzzz",
				 formType: .treatment,
				 ePaper: false,
				 formStructure:
					[
						
					]),
	]
	
	
	public static func getMedHistory() -> HTMLForm {
		HTMLForm(id: 1, name: "Medical History Form", formType: .questionnaire,
				 ePaper: false,
				 formStructure:
					[
						
					])
	}
	public static func getPrescription() -> HTMLForm {
		HTMLForm(id: 1, name: "Prescription Form", formType: .prescription,
				 ePaper: false,
				 formStructure:
					[
						
					])
	}
	
}
