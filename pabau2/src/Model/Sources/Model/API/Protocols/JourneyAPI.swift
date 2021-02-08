import ComposableArchitecture

public protocol JourneyAPI {

    func getClients(search: String?, offset: Int) -> Effect<ClientsResponse, RequestError>
    func getJourneys(date: Date, searchTerm: String?) -> Effect<[Journey], RequestError>
    func getServices() -> Effect<[Service], RequestError>
	func getEmployees() -> Effect<[Employee], RequestError>
	func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError>
	func getAppointments(startDate: Date, endDate: Date, locationIds: [Location.ID], employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<CalendarResponse, RequestError>
	func getLocations() -> Effect<[Location], RequestError>
}
