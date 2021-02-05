import ComposableArchitecture

public protocol JourneyAPI {
	func getEmployees(locationId: Location.ID) -> Effect<[Employee], RequestError>
	func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError>
	func getAppointments(startDate: Date, endDate: Date, locationIds: [Location.ID], employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<CalendarResponse, RequestError>
	func getLocations() -> Effect<[Location], RequestError>
}
