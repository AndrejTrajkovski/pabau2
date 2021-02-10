import Foundation
import Tagged

public struct CalendarResponse: Decodable {
	public let success: Bool
	public let total: Int
	public let rota: [String: Rota]
	public let appointments: [CalendarEvent]
	public let intervalSetting: Int
	public let startTime, endTime, completeStatusColor, checkinStatusColor: String

	enum CodingKeys: String, CodingKey {
		case success, total, rota, appointments
		case intervalSetting = "interval_setting"
		case startTime = "start_time"
		case endTime = "end_time"
		case completeStatusColor = "complete_status_color"
		case checkinStatusColor = "checkin_status_color"
	}
}

// MARK: - Rota
public struct Rota: Codable {
	
	let shift: [Shift]
}
