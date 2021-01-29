import ComposableArchitecture

public protocol JourneyAPI {
	func getEmployees(companyId: Company.ID) -> Effect<[Employee], RequestError>
	func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError>
	func getAppointments(dates: [Date], locationIds: [Location.ID], employeesIds: [Employee.ID]) -> Effect<[CalendarEvent], RequestError>
}
