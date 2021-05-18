import Foundation
import JZCalendarWeekView
import Model

public class JZShift: JZBackgroundTime, Identifiable {

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
