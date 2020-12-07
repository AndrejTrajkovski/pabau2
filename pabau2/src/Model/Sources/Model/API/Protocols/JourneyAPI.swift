import ComposableArchitecture

public protocol JourneyAPI {
    func getJourneys(date: Date, searchTerm: String?) -> Effect<Result<[Journey], RequestError>, Never>
	func getEmployees() -> Effect<Result<[Employee], RequestError>, Never>
	func getTemplates(_ type: FormType) -> Effect<Result<[FormTemplate], RequestError>, Never>
}
