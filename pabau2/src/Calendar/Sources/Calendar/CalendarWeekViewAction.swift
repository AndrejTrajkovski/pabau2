import ComposableArchitecture
import SwiftDate
import Model

public struct CalendarWeekViewState: Equatable {
	var appointments: [Date: IdentifiedArrayOf<CalAppointment>]
	var selectedDate: Date
}

public let calendarWeekViewReducer: Reducer<CalendarWeekViewState, CalendarWeekViewAction, CalendarEnvironment> = .init { state, action, env in
	switch action {
	case .onPageSwipe(let isNext):
		let daysToAdd = isNext ? 7 : -7
		let newDate = state.selectedDate + daysToAdd.days
		state.selectedDate = newDate
	case .editStartTime(let startDate, let startOfDayDate, let eventId):
		let calId = CalAppointment.ID.init(rawValue: eventId)
		state.appointments[startOfDayDate]?[id: calId]?.start_date = startDate
	case .editDuration(let endDate, let startOfDayDate, let eventId):
		let calId = CalAppointment.ID.init(rawValue: eventId)
		state.appointments[startOfDayDate]?[id: calId]?.end_date = endDate
	case .addAppointment(let startDate,let durationMins, let startOfDayDate):
		break
	}
	return .none
}

public enum CalendarWeekViewAction {
	case onPageSwipe(isNext: Bool)
	case addAppointment(startDate: Date,
						durationMins: Int,
						startOfDayDate: Date)
	case editStartTime(startDate: Date,
					   startOfDayDate: Date,
					   eventId: Int)
	case editDuration(endDate: Date,
					  startOfDayDate: Date,
					  eventId: Int)
}
