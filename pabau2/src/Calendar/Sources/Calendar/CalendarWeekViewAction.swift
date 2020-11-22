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
	case .editStartTime(let startOfDayDate, let startDate, let eventId, let startingPointStartOfDay):
		let calId = CalAppointment.ID.init(rawValue: eventId)
		var app = state.appointments[startingPointStartOfDay]?.remove(id: calId)
		app?.update(start: startDate)
		app.map {
			if state.appointments[startOfDayDate] == nil {
				state.appointments[startOfDayDate] = IdentifiedArrayOf<CalAppointment>.init()
			}
			state.appointments[startOfDayDate]!.append($0)
		}
	case .editDuration(let startOfDayDate, let endDate, let eventId):
		let calId = CalAppointment.ID.init(rawValue: eventId)
		state.appointments[startOfDayDate]?[id: calId]?.end_date = endDate
	case .addAppointment, .addBookout:
		break// handled in calendarContainerReducer
	}
	return .none
}

public enum CalendarWeekViewAction {
	case onPageSwipe(isNext: Bool)
	case addAppointment(startOfDayDate: Date,
						startDate: Date,
						durationMins: Int)
	case addBookout(startOfDayDate: Date,
					startDate: Date,
					durationMins: Int)
	case editStartTime(startOfDayDate: Date,
					   startDate: Date,
					   eventId: Int,
					   startingPointStartOfDay: Date)
	case editDuration(startOfDayDate: Date,
					  endDate: Date,
					  eventId: Int)
}
