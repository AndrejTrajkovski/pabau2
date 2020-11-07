import Model
import Foundation
import JZCalendarWeekView
import ComposableArchitecture

public struct EventsBy<Event: JZBaseEvent, SubsectionHeader: Identifiable & Equatable> {
	let appointments: [Date: [Location.ID: [SubsectionHeader.ID: [Event]]]]
	
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

struct AppointmentsByReducer<Section: Identifiable & Equatable> {
	let reducer = Reducer<EventsBy<AppointmentEvent, Section>, SectionCalendarAction, Any> { state, action, _ in
			switch action {
			case .addAppointment(startDate: let startDate, durationMins: let durationMins, dropIndexes: let dropIndexes):
				fatalError("TODO")
			case .editAppointment(startDate: let startDate, startIndexes: let startIndexes, dropIndexes: let dropIndexes):
				fatalError("TODO")
			}
			return .none
	}
}
