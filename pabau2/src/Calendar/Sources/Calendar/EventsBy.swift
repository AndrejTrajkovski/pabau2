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
