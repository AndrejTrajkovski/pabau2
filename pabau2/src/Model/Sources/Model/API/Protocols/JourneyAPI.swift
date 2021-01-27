import ComposableArchitecture

public protocol JourneyAPI {
	func getJourneys(date: Date, searchTerm: String?) -> Effect<[Journey], RequestError>
	func getEmployees(companyId: Company.ID) -> Effect<[Employee], RequestError>
	func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError>
}
