import ComposableArchitecture

public protocol JourneyAPI {
    func getClients(search: String?, offset: Int) -> Effect<Result<[Client], RequestError>, Never>
    func getJourneys(date: Date, searchTerm: String?) -> Effect<Result<[Journey], RequestError>, Never>
	func getEmployees() -> Effect<Result<[Employee], RequestError>, Never>
    func getServices() -> Effect<Result<[Service], RequestError>, Never>
	func getTemplates(_ type: FormType) -> Effect<Result<[FormTemplate], RequestError>, Never>
}
