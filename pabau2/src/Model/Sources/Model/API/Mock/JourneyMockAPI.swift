import ComposableArchitecture
import NonEmpty
import SwiftDate

public struct JourneyMockAPI: MockAPI, JourneyAPI {
	public init () {}
	
	public func getAppointments(dates: [Date], locationIds: [Location.ID], employeesIds: [Employee.ID]) -> Effect<[CalendarEvent], RequestError> {
		fatalError()
	}
	
	public func getEmployees(companyId: Company.ID) -> Effect<[Employee], RequestError> {
		mockSuccess(Employee.mockEmployees, delay: 0.0)
	}
	
	public func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError> {
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
