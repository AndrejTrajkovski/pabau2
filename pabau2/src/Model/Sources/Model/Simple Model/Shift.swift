import Foundation
import Tagged

public struct Shift: Codable {
	let rotaID: Rota.ID
	let date, startTime, endTime: String
	let userID: Int
	let userName, locationName, locColor: String
	let locationID, roomID: Int
	let notes: String

	enum CodingKeys: String, CodingKey {
		case rotaID = "rota_id"
		case date
		case startTime = "start_time"
		case endTime = "end_time"
		case userID = "user_id"
		case userName = "user_name"
		case locationName = "location_name"
		case locColor = "loc_color"
		case locationID = "location_id"
		case roomID = "room_id"
		case notes
	}
}
