import Model
import Foundation
import JZCalendarWeekView
import ComposableArchitecture

public struct EventsBy<Event: JZBaseEvent, SectionHeader: Identifiable & Equatable> {
	let appointments: [Date: [SectionHeader.ID: [Event]]]
//	let sectionHeaders: IdentifiedArrayOf<SectionHeader>
	
	init(events: [Event],
		 sections: [SectionHeader],
		 keyPath: ReferenceWritableKeyPath<Event, SectionHeader.ID>) {
//		self.sectionHeaders = IdentifiedArray.init(sections)
		self.appointments = SectionHelper.group(events,
												sections,
												keyPath)
	}
	
	func flatten() -> [Event] {
		return appointments.flatMap { $0.value }.flatMap { $0.value }
	}
}

extension EventsBy: Equatable { }
