import Model
import Foundation
import JZCalendarWeekView
import ComposableArchitecture
import SwiftDate
import AddBookout

public struct EventsBy<SubsectionHeader: Identifiable & Equatable> {
	
	var appointments: [Date: [Location.ID: [SubsectionHeader.ID: IdentifiedArrayOf<CalendarEvent>]]]
	init(events: [CalendarEvent],
		 locationsIds: [Location.ID],
		 subsections: [SubsectionHeader],
		 sectionKeypath: KeyPath<CalendarEvent, Location.ID>,
		 subsKeypath: KeyPath<CalendarEvent, SubsectionHeader.ID>) {
		self.appointments = SectionHelper.group(events,
												locationsIds,
												subsections,
												sectionKeypath,
												subsKeypath)
	}
	
	func flatten() -> [CalendarEvent] {
		return appointments.flatMap { $0.value }.flatMap { $0.value }.flatMap { $0.value }
	}
}

extension EventsBy: Equatable { }

public struct AppointmentsByReducer<Subsection: Identifiable & Equatable> {
	let reducer = Reducer<CalendarSectionViewState<Subsection>, SubsectionCalendarAction<Subsection>, Any> { state, action, _ in
		switch action {
		case .addAppointment:
			break //handled in calendarContainerReducer
		case .editSections(startDate: let startDate, startKeys: let startIndexes, dropKeys: let dropIndexes, eventId: let eventId):
			let calId = CalendarEvent.Id(rawValue: eventId)
			var app = state.appointments.appointments[startIndexes.date]?[startIndexes.location]?[startIndexes.subsection]?.remove(id: calId)
			app?.update(start: startDate)
			app?.locationId = dropIndexes.location
			if let roomId = dropIndexes.subsection as? Room.ID {
				app?.roomId = roomId
			} else if let empId = dropIndexes.subsection as? Employee.ID {
				app?.employeeId = empId
			}
			if state.appointments.appointments[dropIndexes.date] == nil {
				state.appointments.appointments[dropIndexes.date] = [:]
			}
			app.map { app in
				state.appointments.appointments[dropIndexes.date]?[dropIndexes.location]?[dropIndexes.subsection]?.append(app)
			}
		case .onPageSwipe(isNext: let isNext):
			let daysToAdd = isNext ? 1 : -1
			let newDate = state.selectedDate + daysToAdd.days
			state.selectedDate = newDate
		case .editDuration(let newEndDate, let startIndexes, let eventId):
			let calId = CalendarEvent.Id(rawValue: eventId)
			let oldDateO = state.appointments.appointments[startIndexes.date]?[startIndexes.location]?[startIndexes.subsection]?[id: calId]?.end_date
			guard let oldDate = oldDateO else { return .none }
			state.appointments.appointments[startIndexes.date]?[startIndexes.location]?[startIndexes.subsection]?[id: calId]?.end_date = Date.concat(oldDate, newEndDate)
		case .onSelect(let keys, let eventId):
			let (date, location, subsection) = keys
			let calId = CalendarEvent.Id(rawValue: eventId)
			let event = state.appointments.appointments[keys.date]?[keys.location]?[keys.subsection]?[id: calId]
			switch event {
			case .appointment(let app):
				state.appDetails = AppDetailsState(app: app)
			default:
				break
			}
		case .addBookout(startDate: let startDxate, durationMins: let durationMins, dropKeys: let dropKeys):
			break
		}
		return .none
	}
	//	.debug(state: { return $0 }, action: (/SubsectionCalendarAction.editAppointment))
}
