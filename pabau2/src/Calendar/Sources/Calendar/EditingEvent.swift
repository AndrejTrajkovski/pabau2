import Model
import Foundation

public struct EditingEvent: Equatable, Identifiable {
	public var id: CalendarEvent.ID { oldEvent.id }
	let oldEvent: CalendarEvent
	let newLocation: Location.ID
	let newSection: Either<Room.ID, Employee.Id>
    let oldSection: Either<Room.Id, Employee.Id>
	let newStartDate: Date
}
