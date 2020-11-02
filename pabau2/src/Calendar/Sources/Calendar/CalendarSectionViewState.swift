import Foundation
import JZCalendarWeekView

struct CalendarSectionViewState<Event: JZBaseEvent, Section: Identifiable & Equatable>: Equatable {
	let selectedDate: Date
	let appointments: EventsBy<Event, Section>
	let chosenSectionsIds: [Section.ID]
	let sections: [Section.ID: Section]
}
