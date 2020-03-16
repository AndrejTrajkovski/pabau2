import ComposableArchitecture

public protocol JourneyAPI {
	func getJourneys(date: Date) -> Effect<Result<[Journey], RequestError>>
	func getEmployees() -> Effect<Result<[Employee], RequestError>>
}
