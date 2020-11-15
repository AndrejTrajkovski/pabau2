import Model
import Foundation
import JZCalendarWeekView
import ComposableArchitecture
import SwiftDate

public struct EventsBy<SubsectionHeader: Identifiable & Equatable> {

	var appointments: [Date: [Location.ID: [SubsectionHeader.ID: IdentifiedArrayOf<CalAppointment>]]]
	init(events: [CalAppointment],
		 subsections: [SubsectionHeader],
		 sectionKeypath: KeyPath<CalAppointment, Location.ID>,
		 subsKeypath: KeyPath<CalAppointment, SubsectionHeader.ID>) {
		self.appointments = SectionHelper.group(events,
												subsections,
												sectionKeypath,
												subsKeypath)
	}

	func flatten() -> [CalAppointment] {
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
				print(state.appointments.appointments[startIndexes.date]?[startIndexes.location]?[ startIndexes.subsection]?.map(\.start_date))
				var app = state.appointments.appointments[startIndexes.date]?[startIndexes.location]?[startIndexes.subsection]?.remove(id: CalAppointment.Id(rawValue: eventId))
				app?.update(start: startDate)
				var apps = state.appointments
				app.map {
					apps.appointments[startIndexes.date]?[startIndexes.location]?[ startIndexes.subsection]?.append($0)
				}
				state.appointments = apps
			case .onPageSwipe(isNext: let isNext):
				let daysToAdd = isNext ? 1 : -1
				let newDate = state.selectedDate + daysToAdd.days
				state.selectedDate = newDate
			}
			return .none
	}
//	.debug(state: { return $0 }, action: (/SubsectionCalendarAction.editAppointment))
}
