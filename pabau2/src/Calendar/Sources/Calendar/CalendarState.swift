import Model

//public struct Shifts: Codable, Equatable {
//	let
//}

public struct CalendarState: Equatable, Codable {
//	var rota: [Employee.Id: [Shift]]
	var appointments: [Appointment]
}

extension CalendarState {
	public init () {
//		self.rota = [:]
		self.appointments = []
	}
}
