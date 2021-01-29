import ComposableArchitecture

public protocol JourneyAPI {
    func getClients(search: String?, offset: Int) -> Effect<[Client], RequestError>
    func getJourneys(date: Date, searchTerm: String?) -> Effect<[Journey], RequestError>
	func getEmployees() -> Effect<[Employee], RequestError>
    func getServices() -> Effect<[Service], RequestError>
	func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError>
}
