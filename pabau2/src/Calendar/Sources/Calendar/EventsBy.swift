import Model
import Foundation
import JZCalendarWeekView
import ComposableArchitecture

public struct EventsBy<Event: JZBaseEvent, SubsectionHeader: Identifiable & Equatable> {
	
	var appointments: [Date: [Location.ID: [SubsectionHeader.ID: [Event]]]]
	
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

struct AppointmentsByReducer<Subsection: Identifiable & Equatable> {
	let reducer = Reducer<EventsBy<JZAppointmentEvent, Subsection>, SubsectionCalendarAction<Subsection>, Any> { state, action, _ in
			switch action {
			case .addAppointment(startDate: let startDate, durationMins: let durationMins, dropKeys: let dropKeys):
				break
			//TODO: Move this logic to reducer
//					let endDate = Calendar.current.date(byAdding: .minute, value: durationMins, to: startDate)!
			//		var newApp = CalAppointment.dummyInit(start: startDate, end: endDate)
//				state.appointments[dropKeys.date][dropKeys.location][dropKeys.subsection] =
			case .editAppointment(startDate: let startDate, startKeys: let startIndexes, dropKeys: let dropIndexes):
				fatalError("TODO")
			}
			return .none
	}
}
