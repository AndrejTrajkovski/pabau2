import ComposableArchitecture

public protocol JourneyAPI {
	func getJourneys(date: Date) -> Effect<Result<[Journey], RequestError>>
}
