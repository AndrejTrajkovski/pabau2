import Model
import Foundation
import JZCalendarWeekView
import ComposableArchitecture
import SwiftDate

public struct EventsBy<Event: JZBaseEvent & Identifiable, SubsectionHeader: Identifiable & Equatable> {

	var appointments: [Date: [Location.ID: [SubsectionHeader.ID: IdentifiedArrayOf<Event>]]]
	init(events: [Event],
		 subsections: [SubsectionHeader],
		 sectionKeypath: KeyPath<Event, Location.ID>,
		 subsKeypath: KeyPath<Event, SubsectionHeader.ID>) {
		self.appointments = SectionHelper.group(events,
												subsections,
												sectionKeypath,
												subsKeypath)
	}

	func flatten() -> [Event] {
		return appointments.flatMap { $0.value }.flatMap { $0.value }.flatMap { $0.value }
	}
}

extension EventsBy: Equatable { }

public struct AppointmentsByReducer<Subsection: Identifiable & Equatable> {
	let reducer = Reducer<CalendarSectionViewState<Subsection>, SubsectionCalendarAction<Subsection>, Any> { state, action, _ in
			switch action {
			case .addAppointment:
				break //handled in tabBarReducer
			case .editAppointment(startDate: let startDate, startKeys: let startIndexes, dropKeys: let dropIndexes, eventId: let eventId):
				var app = state.appointments.appointments[startIndexes.date]?[startIndexes.location]?[startIndexes.subsection]?[id: eventId.rawValue]
				
			case .onPageSwipe(isNext: let isNext):
				let daysToAdd = isNext ? 1 : -1
				let newDate = state.selectedDate + daysToAdd.days
				state.selectedDate = newDate
			}
			return .none
	}
}
