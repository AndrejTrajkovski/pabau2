import ComposableArchitecture

public protocol JourneyAPI {
	func getEmployees() -> Effect<[Employee], RequestError>
	func getAppointments(startDate: Date, endDate: Date, locationIds: [Location.ID], employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<[CalendarEvent], RequestError>
    func getParticipants(participantSchema: ParticipantSchema) -> Effect<[Participant], RequestError>
	func getLocations() -> Effect<[Location], RequestError>
    func createShift(shiftSheme: ShiftSchema) -> Effect<PlaceholdeResponse, RequestError>
}
