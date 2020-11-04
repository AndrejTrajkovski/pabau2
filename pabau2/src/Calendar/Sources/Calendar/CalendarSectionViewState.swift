import Foundation
import JZCalendarWeekView
import ComposableArchitecture
import Model

struct CalendarSectionViewState<Event: JZBaseEvent, Subsection: Identifiable & Equatable>: Equatable {
	let selectedDate: Date
	let appointments: EventsBy<Event, Subsection>
	let locations: IdentifiedArrayOf<Location>
	let chosenLocationsIds: [Location.ID]
	let subsections: [Location.ID: IdentifiedArrayOf<Subsection>]
	let chosenSubsectionsIds: [Location.ID: [Subsection.ID]]
}
