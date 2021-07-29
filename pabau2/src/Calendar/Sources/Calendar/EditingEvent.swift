import Model
import Foundation

public struct EditingEvent: Equatable, Identifiable {
	public var id: CalendarEvent.ID { oldEvent.id }
	let oldEvent: CalendarEvent
	let newLocation: Location.ID
	let newSection: Either<Room.ID, Employee.Id>
	let newStartDate: Date
}

extension Either: Equatable where Left == Room.ID, Right == Employee.Id {
    public static func == (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
        case (.left(let roomId), .left(let roomid2)):
            return roomId == roomid2
        case (.right(let empId), .right(let empId2)):
            return empId == empId2
        case (.left, .right):
            return false
        case (.right, .left):
            return false
        }
    }
}
