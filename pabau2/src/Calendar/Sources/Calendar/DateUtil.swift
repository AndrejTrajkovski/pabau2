import Foundation
import SwiftDate

extension Date {
	
	static func concat(_ yearMonthDay: Date, _ hourMinuteSecond: Date, _ calendar: Calendar = .gregorian) -> Date {
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
}
