import ComposableArchitecture

public struct JourneyMockAPI: MockAPI, JourneyAPI {
	public init () {}
	public func getJourneys(date: Date) -> Effect<Result<[Journey], RequestError>> {
		mockSuccess([])
	}
}
