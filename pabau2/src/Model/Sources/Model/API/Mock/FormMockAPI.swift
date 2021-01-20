import Foundation
import ComposableArchitecture

public struct FormMockAPI: FormAPI, MockAPI {
	
	public init () {}
	
	public func get(form: HTMLForm.ID) -> Effect<Result<HTMLForm, RequestError>, Never> {
		mockSuccess(HTMLForm.mockConsents.first!)
	}
	
	public func post(form: HTMLForm, appointments: [CalendarEvent.Id]) -> Effect<Result<HTMLForm, RequestError>, Never> {
		mockSuccess(HTMLForm.mockTreatmentN.first!)
	}
	
	public func getTemplates(_ type: FormType) -> EffectWithResult<[HTMLForm], RequestError> {
		switch type {
		case .consent:
		  return mockSuccess(HTMLForm.mockConsents, delay: 0.1)
		case .treatment:
			return mockSuccess(HTMLForm.mockTreatmentN, delay: 0.1)
		default:
			fatalError("TODO")
		}
	}
}
