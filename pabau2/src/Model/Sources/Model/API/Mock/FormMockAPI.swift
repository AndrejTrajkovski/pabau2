import Foundation
import ComposableArchitecture

public struct FormMockAPI: FormAPI, MockAPI {
	
	public init () {}
	
	public func get(form: HTMLFormTemplate.ID) -> Effect<Result<HTMLFormTemplate, RequestError>, Never> {
		mockSuccess(HTMLFormTemplate.mockConsents.first!)
	}
	
	public func post(form: HTMLFormTemplate, appointments: [CalendarEvent.Id]) -> Effect<Result<HTMLFormTemplate, RequestError>, Never> {
		mockSuccess(HTMLFormTemplate.mockTreatmentN.first!)
	}
	
	public func getTemplates(_ type: FormType) -> EffectWithResult<[HTMLFormTemplate], RequestError> {
		switch type {
		case .consent:
		  return mockSuccess(HTMLFormTemplate.mockConsents, delay: 0.1)
		case .treatment:
			return mockSuccess(HTMLFormTemplate.mockTreatmentN, delay: 0.1)
		default:
			fatalError("TODO")
		}
	}
}
