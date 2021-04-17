import Foundation
import Tagged

public struct HTMLForm: Identifiable, Equatable {
	
	public typealias ID = Tagged<FormTemplateInfo, String>
	
	public var id: Self.ID
	
	public let name: String
	
	public let type: FormType
	
	public let entryId: FilledFormData.ID?
	
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
		self.id = HTMLForm.ID(rawValue: String(id))
		self.name = name
		self.type = formType
		self.ePaper = ePaper
		self.formStructure = formStructure
		self.entryId = nil
	}
	
	init(builder: HTMLFormBuilder) {
		self.id = builder.id
		self.name = builder.name
		self.type = builder.formType
		self.entryId = builder.entryId
		self.ePaper = builder.ePaper
		self.formStructure = builder.formStructure
	}
	
	public func getJSONPOSTValues() -> [String: String] {
		return Dictionary.init(grouping: formStructure, by: { $0.id })
			.compactMapValues { $0.first!.cssClass.getJSONPOSTValue() }
			.mapKeys { $0.fakeId.rawValue }
	}
}

enum HTMLFormBuilderError: Error, CustomStringConvertible {
	var description: String {
		switch self {
		case .noTemplate:
			return "no template found"
		case .idNotInteger:
			return "id not integer"
		case .unhandledFormType:
			return "unhandledFormType"
		case .formStructureNotBase64:
			return "formStructureNotBase64"
		}
	}
	
	case noTemplate
	case idNotInteger
	case unhandledFormType
	case formStructureNotBase64
}

struct HTMLFormBuilder {
	
	public var entryId: FilledFormData.ID?
	public var id: HTMLForm.ID
	public var name: String
	public var formType: FormType
	public var ePaper: Bool?
	public var formStructure: [CSSField]
	
	init(formEntry: _FilledForm) throws {
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
			print($0.id.fakeId)
			if let medResult = medicalResultsById[$0.id.fakeId] {
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
//		guard let id = String(template.id) else { throw HTMLFormBuilderError.idNotInteger }
		guard let formType = FormType(rawValue: template.formType) else { throw HTMLFormBuilderError.unhandledFormType }
		
		self.entryId = nil
		self.id = .init(rawValue: template.id)
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
		var valueCounter = 0
		formStructure.enumerated().forEach { idx, field in
			print(valueCounter)
			print(field.cssClass)
			let fakeId = String(valueCounter) + field.keyString().lowercased()
			let id = CSSField.ID.init(idx: idx, fakeId: fakeId)
			if field.cssClass != .staticText &&
				field.cssClass != .heading {
				valueCounter += 1
			}
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
		HTMLForm(id: 1, name: "Medical History Form", formType: .history,
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
