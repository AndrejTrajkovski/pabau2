import Foundation
import Tagged

public struct CalendarResponse: Decodable {
	public let rota: [Employee.ID: Rota]
	public let appointments: [CalendarEvent]
	public let intervalSetting: Int

	enum CodingKeys: String, CodingKey {
		case rota, appointments
		case intervalSetting = "interval_setting"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.appointments = try container.decode([CalendarEvent].self, forKey: .appointments)
		let rota: [Employee.ID: Rota]
		if let rotaDict = try? container.decode([Employee.ID: Rota].self, forKey: .rota) {
			rota = rotaDict
		} else {
			rota = [:]
		}
		self.rota = rota
		self.intervalSetting = try container.decode(Int.self, forKey: .intervalSetting)
	}
}

// MARK: - Rota
public struct Rota: Codable {
	
	let shift: [Shift]
}
