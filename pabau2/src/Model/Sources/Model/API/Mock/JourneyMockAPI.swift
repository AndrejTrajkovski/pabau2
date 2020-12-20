import ComposableArchitecture
import NonEmpty
import SwiftDate

public struct AppointmentsMockAPI: MockAPI, AppointmentsAPI {
	public init () {}
	public func getAppointments(date: Date) -> EffectWithResult<[Appointment], RequestError> {
		mockSuccess(Appointment.makeDummy(), delay: 0.2)
	}

	public func getEmployees() -> EffectWithResult<[Employee], RequestError> {
		mockSuccess(Employee.mockEmployees, delay: 0.0)
	}
}
