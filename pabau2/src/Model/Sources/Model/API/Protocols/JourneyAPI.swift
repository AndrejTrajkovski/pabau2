import ComposableArchitecture

public protocol JourneyAPI {
	func getEmployees() -> Effect<[Employee], RequestError>
	func getAppointments(startDate: Date, endDate: Date, locationIds: [Location.ID], employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<[CalendarEvent], RequestError>
    func getParticipants(participantSchema: ParticipantSchema) -> Effect<[Participant], RequestError>
	func getLocations() -> Effect<[Location], RequestError>
	func createShift(shiftSheme: ShiftSchema) -> Effect<PlaceholdeResponse, RequestError>
	func getPathwayTemplates() -> Effect<IdentifiedArrayOf<PathwayTemplate>, RequestError>
    func getCalendar(startDate: Date, endDate: Date, locationIds: Set<Location.ID>, employeesIds: [Employee.ID], roomIds: [Room.ID]) -> Effect<CalendarResponse, RequestError>
	func match(appointment: Appointment, pathwayTemplateId: PathwayTemplate.ID) -> Effect<Pathway, RequestError>
	func getPathway(id: Pathway.ID) -> Effect<Pathway, RequestError>
}
