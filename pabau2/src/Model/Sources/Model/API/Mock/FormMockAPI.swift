import Foundation
import ComposableArchitecture

public struct FormMockAPI: FormAPI, MockAPI {
	
	public init () {}
	
	public func get(form: FormTemplate.ID) -> Effect<Result<FormTemplate, RequestError>, Never> {
		mockSuccess(FormTemplate.mockConsents.first!)
	}
	
	public func post(form: FormTemplate, appointments: [Appointment.Id]) -> Effect<Result<FormTemplate, RequestError>, Never> {
		mockSuccess(FormTemplate.mockTreatmentN.first!)
	}
	
	public func getTemplates(_ type: FormType) -> EffectWithResult<[FormTemplate], RequestError> {
		switch type {
		case .consent:
		  return mockSuccess(FormTemplate.mockConsents, delay: 0.1)
		case .treatment:
			return mockSuccess(FormTemplate.mockTreatmentN, delay: 0.1)
		default:
			fatalError("TODO")
		}
	}
}
