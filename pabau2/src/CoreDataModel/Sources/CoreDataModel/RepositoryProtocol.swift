import Model
import ComposableArchitecture

public protocol RepositoryProtocol {
	
	func getBookoutReasons() -> Effect<SuccessState<[BookoutReason]>, RequestError>
	func getLocations() -> Effect<SuccessState<[Location]>, RequestError>
	func getEmployees() -> Effect<SuccessState<[Employee]>, RequestError>
	func getTemplates(_ type: FormType) -> Effect<SuccessState<[FormTemplateInfo]>, RequestError>
	func getPathwayTemplates() -> Effect<SuccessState<IdentifiedArrayOf<PathwayTemplate>>, RequestError>
}
