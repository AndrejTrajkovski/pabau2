import ComposableArchitecture
import Model

public class MockRepository: RepositoryProtocol {
	public init(
		bookoutReasons: Effect<SuccessState<[BookoutReason]>, RequestError>,
		locations: Effect<SuccessState<[Location]>, RequestError>,
		employees: Effect<SuccessState<[Employee]>, RequestError>,
		templates: Effect<SuccessState<[FormTemplateInfo]>, RequestError>,
		pathwayTemplates: Effect<SuccessState<IdentifiedArrayOf<PathwayTemplate>>, RequestError>) {
		self.bookoutReasons = bookoutReasons
		self.locations = locations
		self.employees = employees
		self.templates = templates
		self.pathwayTemplates = pathwayTemplates
	}
	
	
	let bookoutReasons: Effect<SuccessState<[BookoutReason]>, RequestError>
	let locations: Effect<SuccessState<[Location]>, RequestError>
	let employees: Effect<SuccessState<[Employee]>, RequestError>
	let templates: Effect<SuccessState<[FormTemplateInfo]>, RequestError>
	let pathwayTemplates: Effect<SuccessState<IdentifiedArrayOf<PathwayTemplate>>, RequestError>
	
	public func getBookoutReasons() -> Effect<SuccessState<[BookoutReason]>, RequestError> {
		return bookoutReasons
	}
	
	public func getLocations() -> Effect<SuccessState<[Location]>, RequestError> {
		locations
	}
	
	public func getEmployees() -> Effect<SuccessState<[Employee]>, RequestError> {
		employees
	}
	
	public func getTemplates(_ type: FormType) -> Effect<SuccessState<[FormTemplateInfo]>, RequestError> {
		templates
	}
	
	public func getPathwayTemplates() -> Effect<SuccessState<IdentifiedArrayOf<PathwayTemplate>>, RequestError> {
		pathwayTemplates
	}
	
}
