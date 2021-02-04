import ComposableArchitecture

public protocol JourneyAPI {
	func getEmployees(locationId: Location.ID) -> Effect<EmployeesList, RequestError>
	func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError>
	func getAppointments(dates: [Date], locationIds: [Location.ID], employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<CalendarResponse, RequestError>
}
