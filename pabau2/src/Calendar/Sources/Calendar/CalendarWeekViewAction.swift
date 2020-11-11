import ComposableArchitecture
import SwiftDate

public let calendarWeekViewReducer: Reducer<CalendarState, CalendarWeekViewAction, CalendarEnvironment> = .init { state, action, env in
	switch action {
	case .onPageSwipe(let isNext):
		let daysToAdd = isNext ? 7 : -7
		let newDate = state.selectedDate + daysToAdd.days
		state.selectedDate = newDate
	default:
		break
	}
	return .none
}

public enum CalendarWeekViewAction {
	case onPageSwipe(isNext: Bool)
}
