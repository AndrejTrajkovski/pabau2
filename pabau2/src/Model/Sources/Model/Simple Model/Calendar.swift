//import Tagged
//import Foundation
//import SwiftDate
//import Util
//import CasePaths
//
//public struct CalAppointment: Equatable, Identifiable, Hashable {
//	
//	public func hash(into hasher: inout Hasher) {
//		hasher.combine(id)
//	}
//	
//	public let id: CalendarEvent.Id
//	public var start_date: Date
//	public var end_date: Date
//	public var employeeId: Employee.Id
//	public let employeeInitials: String
//	public var locationId: Location.Id
//	public let _private: Bool?
//	public let extraEmployees: [Employee]?
//	public var status: AppointmentStatus?
//	public let service: String
//	public let serviceColor: String?
//	public let clientName: String?
//	public let clientPhoto: String?
//	public var roomId: Room.Id
//	public let employeeName: String
//	public let roomName: String
//	public let customerId: Client.ID
//	public let serviceId: Service.Id
//}
//
//extension CalAppointment: CalendarEventVariant { }
//
//extension Date {
//	public func separateHMSandYMD(_ calendar: Calendar = Calendar.init(identifier: .gregorian)) -> (Date?, Date?) {
//		let ymdComps = calendar.dateComponents([.year, .month, .day], from: self)
//		let hmsComps = calendar.dateComponents([.hour, .minute, .second], from: self)
//		return (calendar.date(from: hmsComps), calendar.date(from: ymdComps))
//	}
//}
//
//extension Date {
//	static func mockStartAndEndDate(endRangeMax: Int) -> (Date, Date) {
//		let randomHours = Int.random(in: -100...100)
//		let randomMins = Int.random(in: -59...59)
//		let randomTime = randomHours.hours + randomMins.minutes
//		let today = Date()
//		let startDate = Calendar.gregorian.date(byAdding: .hour,
//												value: randomHours,
//												to: today)!
//		let randomEndMins = Int.random(in: 15...endRangeMax)
//		let randomEnding = startDate + randomEndMins.minutes
//		return (startDate, randomEnding)
//	}
//}
//
