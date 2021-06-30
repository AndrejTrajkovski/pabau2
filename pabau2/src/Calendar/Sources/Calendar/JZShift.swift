import Foundation
import JZCalendarWeekView
import Model

public class JZShift: JZBackgroundTime, Identifiable {
	
	public override func isEqual(_ object: Any?) -> Bool {
		guard let jzShift = object as? JZShift else { return false }
		return jzShift.shift == self.shift
	}
	
	static func == (lhs: JZShift, rhs: JZShift) -> Bool {
		lhs.shift == rhs.shift
	}

	public subscript<Value>(dynamicMember keyPath: KeyPath<Shift, Value>) -> Value {
		shift[keyPath: keyPath]
	}

	public let shift: Shift
	public init(shift: Shift) {
		self.shift = shift
		let start = Calendar.gregorian.dateComponents([.hour, .minute], from: shift.startTime)
		let end = Calendar.gregorian.dateComponents([.hour, .minute], from: shift.endTime)
		super.init(date: shift.date, start: start, end: end)
	}

	public override func copy(with zone: NSZone?) -> Any {
		return JZShift(shift: shift)
	}
}

extension Shift {
	public static func convertToCalendar(
		shifts: [Shift]
	) -> [Date: [Location.ID: [Employee.Id: [JZShift]]]] {
		
		let jzShifts = shifts.map(JZShift.init(shift:))
		
		let byDate = Dictionary.init(grouping: jzShifts, by: { $0[dynamicMember: \.date] })
		
		return byDate.mapValues { events in
			return Dictionary.init(
				grouping: events,
				by: { $0[dynamicMember: \.locationID] }
			)
			.mapValues { events2 in
				Dictionary.init(
					grouping: events2,
					by: { $0[dynamicMember: \.userID] }
				)
			}
		}
	}
}
