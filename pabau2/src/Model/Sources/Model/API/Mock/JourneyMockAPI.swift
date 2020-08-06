import ComposableArchitecture
import NonEmpty
import SwiftDate

public struct JourneyMockAPI: MockAPI, JourneyAPI {
	public init () {}
	public func getJourneys(date: Date) -> EffectWithResult<[Journey], RequestError> {
		mockSuccess(Self.mockJourneys, delay: 0.2)
	}

	public func getEmployees() -> EffectWithResult<[Employee], RequestError> {
		mockSuccess(Self.mockEmployees, delay: 0.0)
	}

	public func getTemplates(_ type: FormType) -> EffectWithResult<[FormTemplate], RequestError> {
		switch type {
		case .consent:
		  return mockSuccess(FormTemplate.mockConsents, delay: 0.1)
		case .treatment:
			return mockSuccess(FormTemplate.mockTreatmentN, delay: 0.1)
		default:
		fatalError("TODO")
		}
	}
}

extension JourneyMockAPI {
	static let mockEmployees = [
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
	]

	static let mockJourneys = [
		Journey.init(id: 1,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date() - 1.days, employeeId: 1, employeeInitials: "AT", locationId: 1, locationName: "Thailand", status: AppointmentStatus(id: 1, name: "Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#9400D3"))),
								 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "dummy2", phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil"), forms: [], photos: [], postCare: [], paid: "Not Paid"),
		Journey.init(id: 2,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date(), employeeId: 1, employeeInitials: "MR", locationId: 1, locationName: "Skopje", status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#ec75ff"))),
								 patient: BaseClient.init(id: 1, firstName: "Elon", lastName: "Musk", dOB: "28.02.1991", email: "andrej.", avatar: nil, phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil"), forms: [], photos: [], postCare: [], paid: "Paid"),
		Journey.init(id: 3,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date(), employeeId: 1, employeeInitials: "BB", locationId: 1, locationName: "Skopje", status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#88fa69"))),
								 patient: BaseClient.init(id: 2, firstName: "Madonna", lastName: "", dOB: "28.02.1991", email: "andrej.", avatar: "dummy3", phone: ""), employee: Employee.init(id: 2, name: "Dr. Off Boley"), forms: [], photos: [], postCare: [], paid: "Broke"),
			Journey.init(id: 4,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, employeeInitials: "WM", locationId: 1, locationName: "Manchester", status: AppointmentStatus(id: 1, name: "Checked In"), service: BaseService.init(id: 1, name: "Corona Virus", color: "#FFFF00"))),
									 patient: BaseClient.init(id: 0, firstName: "Carl", lastName: "Cox", dOB: "28.02.1991", email: "andrej.", avatar: "dummy1", phone: ""), employee: Employee.init(id: 4,
									 name: "Kobe Bryant"), forms: [], photos: [], postCare: [], paid: "Not Paid"),
			Journey.init(id: 5,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, employeeInitials: "NJ", locationId: 1, locationName: "Birmingham", status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#ec75ff"))),
									 patient: BaseClient.init(id: 1, firstName: "Elon", lastName: "Musk", dOB: "28.02.1991", email: "andrej.", avatar: "dummy5", phone: ""), employee: Employee.init(id: 4,
																																																																																									name: "Kobe Bryant"), forms: [], photos: [], postCare: [], paid: "Paid"),
			Journey.init(id: 6,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() + 1.days, to: Date(), employeeId: 1, employeeInitials: "RE", locationId: 1, locationName: "London", status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#88fa69"))),
									 patient: BaseClient.init(id: 2, firstName: "Joe", lastName: "Rogan", dOB: "28.02.1991", email: "andrej.", avatar: "dummy6", phone: ""), employee: Employee.init(id: 4,
									 name: "Kobe Bryant"), forms: [], photos: [], postCare: [], paid: "Owes 1.000")
	]

	
}

extension JourneyMockAPI {
	
	public static func photos() -> [[Int: SavedPhoto]] {
		[
			[1: SavedPhoto.dummyInit(id: 1, url: "dummy1")],
			[2: SavedPhoto.dummyInit(id: 2, url: "dummy2")],
			[3: SavedPhoto.dummyInit(id: 3, url: "dummy3")],
			[4: SavedPhoto.dummyInit(id: 4, url: "dummy4")],
			[5: SavedPhoto.dummyInit(id: 5, url: "dummy5")],
			[6: SavedPhoto.dummyInit(id: 6, url: "dummy6")],
			[7: SavedPhoto.dummyInit(id: 7, url: "dummy7")],
			[8: SavedPhoto.dummyInit(id: 8, url: "dummy8")],
			[9: SavedPhoto.dummyInit(id: 9, url: "dummy9")],
			[10: SavedPhoto.dummyInit(id:10, url: "dummy10")],
			[11: SavedPhoto.dummyInit(id:11, url: "emily")]
		]
	}
}
