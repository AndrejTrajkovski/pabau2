import Foundation
import JZCalendarWeekView
import Model

public class JZShift: JZBackgroundTime, Identifiable {
	
	subscript<Value>(dynamicMember keyPath: WritableKeyPath<Shift, Value>) -> Value {
		shift[keyPath: keyPath]
	}
	
	public var shift: Shift
	public init(shift: Shift) {
		self.shift = shift
		let start = Calendar.init(identifier: .gregorian).dateComponents([.hour, .minute], from: shift.startTime)
		let end = Calendar.init(identifier: .gregorian).dateComponents([.hour, .minute], from: shift.endTime)
		super.init(date: shift.date, start: start, end: end)
	}
	
	public override func copy(with zone: NSZone?) -> Any {
		return JZShift(shift: shift)
	}
}
