import ComposableArchitecture
import NonEmpty
import SwiftDate

public struct JourneyMockAPI: MockAPI, JourneyAPI {
	public init () {}
	public func getJourneys(date: Date) -> Effect<Result<[Journey], RequestError>> {
		mockSuccess([
			Journey.init(id: 1,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date() - 1.days, employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#9400D3"))),
									 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil"), forms: [], photos: [], postCare: [], paid: "Not Paid"),
			Journey.init(id: 2,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#ec75ff"))),
									 patient: BaseClient.init(id: 1, firstName: "Elon", lastName: "Musk", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil"), forms: [], photos: [], postCare: [], paid: "Paid"),
			Journey.init(id: 3,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#88fa69"))),
									 patient: BaseClient.init(id: 2, firstName: "Madonna", lastName: "", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 2, name: "Dr. Off Boley"), forms: [], photos: [], postCare: [], paid: "Broke"),
				Journey.init(id: 4,
										 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Checked In"), service: BaseService.init(id: 1, name: "Corona Virus", color: "#FFFF00"))),
										 patient: BaseClient.init(id: 0, firstName: "Carl", lastName: "Cox", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 4,
										 name: "Kobe Bryant"), forms: [], photos: [], postCare: [], paid: "Not Paid"),
				Journey.init(id: 5,
										 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#ec75ff"))),
										 patient: BaseClient.init(id: 1, firstName: "Elon", lastName: "Musk", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 4,
																																																																																										name: "Kobe Bryant"), forms: [], photos: [], postCare: [], paid: "Paid"),
				Journey.init(id: 6,
										 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() + 1.days, to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#88fa69"))),
										 patient: BaseClient.init(id: 2, firstName: "Joe", lastName: "Rogan", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 4,
										 name: "Kobe Bryant"), forms: [], photos: [], postCare: [], paid: "Owes 1.000")
		])
	}
	
	public func getEmployees() -> Effect<Result<[Employee], RequestError>> {
		mockSuccess([
			Employee.init(id: 1,
										name: "Dr. Jekil",
										avatarUrl: "asd",
										pin: 1234),
			Employee.init(id: 2,
										name: "Dr. Off Boley",
										avatarUrl: "",
										pin: 1234),
			Employee.init(id: 3,
										name: "Michael Jordan",
										avatarUrl: "",
										pin: 1234),
			Employee.init(id: 4,
										name: "Kobe Bryant",
										avatarUrl: "",
										pin: 1234),
			Employee.init(id: 5,
										name: "LeBron James",
										avatarUrl: "",
										pin: 1234),
			Employee.init(id: 6,
										name: "Britney Spears",
										avatarUrl: "",
										pin: 1234),
			Employee.init(id: 7,
										name: "Dr. Who",
										avatarUrl: "",
										pin: 1234)
		])
	}
}
