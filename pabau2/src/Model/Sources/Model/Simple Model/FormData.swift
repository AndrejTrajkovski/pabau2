//
// Form.swift

import Foundation

/** Object representing a form, without the field values. Meant to be returned when the form patient_status is needed but not the form field values. Is a superclass of Form, which contains the field values. */
public struct FormData: Codable, Identifiable, Equatable {
	
	public let template: FormTemplate
	
	public let patientStatus: PatientStatus
	
	public let fieldValues: [FormFieldValue]?
	
	public let id: Int
	
	public let clientId: Int
	
	public let employeeId: Int
	
	public let date: Date
	
	public let journeyId: Int?
	
	public init(template: FormTemplate, patientStatus: PatientStatus, fieldValues: [FormFieldValue]? = nil, id: Int, clientId: Int, employeeId: Int, date: Date, journeyId: Int? = nil) {
		self.template = template
		self.patientStatus = patientStatus
		self.fieldValues = fieldValues
		self.id = id
		self.clientId = clientId
		self.employeeId = employeeId
		self.date = date
		self.journeyId = journeyId
	}
	
	public enum CodingKeys: String, CodingKey {
		case template
		case patientStatus = "patient_status"
		case fieldValues = "field_values"
		case id = "id"
		case clientId = "clientid"
		case employeeId = "employeeid"
		case date
		case journeyId = "journeyid"
	}
	
}

extension FormData {
	
	static let mockFilledConsents =
		[
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockConsents[1],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockConsents[2],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents[3],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents[2],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents[1],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockConsents.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
	]
	
	static let mockFilledTreatments =
		[
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockTreatmentN[1],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockTreatmentN[2],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN[3],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN[2],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN[1],
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
			,
			FormData(template: FormTemplate.mockTreatmentN.first!,
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
	]
	
	static let mockFIlledPrescriptions =
		[
			FormData(template: FormTemplate.getPrescription(),
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.getPrescription(),
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.getPrescription(),
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1),
			FormData(template: FormTemplate.getPrescription(),
							 patientStatus: .complete,
							 fieldValues: nil,
							 id: 1,
							 clientId: 1,
							 employeeId: 1,
							 date: Date(),
							 journeyId: 1)
	]
}
