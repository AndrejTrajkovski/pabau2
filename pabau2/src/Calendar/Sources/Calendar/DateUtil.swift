import Foundation
import SwiftDate

extension Date {
	
	func split(calendar: Calendar = .current) -> (ymd: Date, hms: Date) {
		let hmsComps = calendar.dateComponents([.hour, .minute, .second], from: self)
		let ymdComps = calendar.dateComponents([.year, .month, .day], from: self)
		return (calendar.date(from: ymdComps)!, calendar.date(from: hmsComps)!)
	}
	
	static func concat(_ yearMonthDay: Date, _ hourMinuteSecond: Date, _ calendar: Calendar = .current) -> Date {
		let ymdComps = calendar.dateComponents([.year, .month, .day], from: yearMonthDay)
		let hmsComps = calendar.dateComponents([.hour, .minute, .second], from: hourMinuteSecond)
		var components = DateComponents()
		components.year = ymdComps.year
		components.month = ymdComps.month
		components.day = ymdComps.day
		components.hour = hmsComps.hour
		components.minute = hmsComps.minute
		components.second = hmsComps.second
		return calendar.date(from: components)!
	}
	
	public func getMondayOfWeek() -> Date {
		self.dateAtStartOf(.weekOfYear) + 1.days
	}
}
