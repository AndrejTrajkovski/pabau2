import ComposableArchitecture
import SwiftDate
import Model
import AddBookout

public struct CalendarWeekViewState: Equatable {
	var appointments: [Date: IdentifiedArrayOf<CalendarEvent>]
	var selectedDate: Date
	var addBookout: AddBookoutState?
	var appDetails: AppDetailsState?
}

public let calendarWeekViewReducer: Reducer<CalendarWeekViewState, CalendarWeekViewAction, CalendarEnvironment> = .init { state, action, env in
	switch action {
	case .onPageSwipe(let isNext):
		let daysToAdd = isNext ? 7 : -7
		let newDate = state.selectedDate + daysToAdd.days
		state.selectedDate = newDate
	case .editStartTime(let startOfDayDate, let startDate, let eventId, let startingPointStartOfDay):
		let calId = CalendarEvent.ID.init(rawValue: eventId)
		var app = state.appointments[startingPointStartOfDay]?.remove(id: calId)
		app?.update(start: startDate)
		app.map {
			if state.appointments[startOfDayDate] == nil {
				state.appointments[startOfDayDate] = IdentifiedArrayOf<CalendarEvent>.init()
			}
			state.appointments[startOfDayDate]!.append($0)
		}
	case .editDuration(let startOfDayDate, let endDate, let eventId):
		let calId = CalendarEvent.ID.init(rawValue: eventId)
		state.appointments[startOfDayDate]?[id: calId]?.end_date = endDate
	case .addAppointment:
		break// handled in calendarContainerReducer
	case .addBookout(let startOfDayDate,
					 let startDate,
					 let durationMins):
		state.addBookout = AddBookoutState(employees: IdentifiedArrayOf([]),
										   chosenEmployee: nil,
										   start: startDate)
	case .onSelect(startOfDayDate: let startOfDayDate, eventId: let eventId):
		let calId = CalendarEvent.ID.init(rawValue: eventId)
		let event = state.appointments[startOfDayDate]?[id: calId]
		switch event {
		case .appointment(let app):
			state.appDetails = AppDetailsState(app: app)
		default:
			break
		}
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
	case onSelect(startOfDayDate: Date,
				  eventId: Int)
}
