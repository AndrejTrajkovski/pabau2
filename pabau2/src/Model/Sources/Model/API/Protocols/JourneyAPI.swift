import ComposableArchitecture

public protocol JourneyAPI {
	func getJourneys(date: Date) -> Effect<Result<[Journey], RequestError>, Never>
	func getEmployees() -> Effect<Result<[Employee], RequestError>, Never>
}
