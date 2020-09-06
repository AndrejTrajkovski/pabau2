public struct CalendarResponse {
	public let rota: [Employee.Id: [Shift]]
	public let appointments: [Appointment]
}
