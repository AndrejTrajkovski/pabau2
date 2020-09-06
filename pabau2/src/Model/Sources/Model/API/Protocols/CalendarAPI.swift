import ComposableArchitecture

public protocol CalendarAPI {
	func getCalendar() -> Effect<Result<CalendarResponse, RequestError>, Never>
}
