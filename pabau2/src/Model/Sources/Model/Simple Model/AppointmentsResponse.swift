import Foundation
import Tagged

public struct AppointmentsResponse: Decodable {
	public let rota: [String: Rota]
	public let appointments: [CalendarEvent]
	public let intervalSetting: Int

	enum CodingKeys: String, CodingKey {
		case rota, appointments
		case intervalSetting = "interval_setting"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.appointments = try container.decode([CalendarEvent].self, forKey: .appointments)		
		if let _ = try? container.decode([String].self, forKey: .rota) {
			//empty rota is array in response
			self.rota = [:]
		} else {
			self.rota = try container.decode([String: Rota].self, forKey: .rota)
		}

		self.intervalSetting = try container.decode(Int.self, forKey: .intervalSetting)
	}
}

// MARK: - Rota
public struct Rota: Decodable {
    public let shift: [Shift]
}

public struct AppointmentCreatedResponse: Decodable {
    public let appointments: [CalendarEvent]
    public let success: Bool
    public let message: String
}

public struct ShiftCreatedResponse: Decodable {
    var success: Bool
    var message: String
    var shift: Shift
}
