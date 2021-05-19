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
		let rota: [String: Rota]
		if let rotaDict = try? container.decode([String: Rota].self, forKey: .rota) {
			rota = rotaDict
		} else {
			rota = [:]
		}
		self.rota = rota
		self.intervalSetting = try container.decode(Int.self, forKey: .intervalSetting)
	}
}

// MARK: - Rota
public struct Rota: Decodable {
    public let shift: [Shift]
}
