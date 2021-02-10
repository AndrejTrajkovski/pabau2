import ComposableArchitecture

public protocol JourneyAPI {
	func getEmployees() -> Effect<[Employee], RequestError>
	func getAppointments(startDate: Date, endDate: Date, locationIds: [Location.ID], employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<CalendarResponse, RequestError>
	func getLocations() -> Effect<[Location], RequestError>
	func getBookoutReasons() -> Effect<[BookoutReason], RequestError>
}
