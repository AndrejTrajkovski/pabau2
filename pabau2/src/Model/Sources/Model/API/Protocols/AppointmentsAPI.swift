import ComposableArchitecture

public protocol AppointmentsAPI {
	func getAppointments(date: Date) -> EffectWithResult<[Appointment], RequestError>
	func getEmployees() -> Effect<Result<[Employee], RequestError>, Never>
}
