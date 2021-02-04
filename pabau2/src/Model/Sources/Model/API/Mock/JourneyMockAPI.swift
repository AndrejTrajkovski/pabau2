import ComposableArchitecture
import NonEmpty
import SwiftDate

public struct JourneyMockAPI: MockAPI, JourneyAPI {
	public init () {}
	
	public func getJourneys(date: Date, searchTerm: String?) -> Effect<[Journey], RequestError> {
		mockSuccess(Self.mockJourneys, delay: 0.2)
	}
	
	public func getEmployees(companyId: Company.ID) -> Effect<[Employee], RequestError> {
		mockSuccess(Employee.mockEmployees, delay: 0.0)
	}
	
	public func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError> {
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
	
	static let mockJourneys = [
		Journey.init(id: 1,
					 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date() - 1.days, employeeInitials: "AT", locationId: 1, locationName: "Thailand", status: AppointmentStatus.mock.randomElement()!, service: BaseService.init(id: 1, name: "Botox", color: "#9400D3"))),
								 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "dummy2", phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil", locationId: Location.randomId()), forms: [], photos: [], postCare: [], paid: "Not Paid"),
		Journey.init(id: 2,
					 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date(), employeeInitials: "MR", locationId: 1, locationName: "Skopje", status: AppointmentStatus.mock.randomElement()!, service: BaseService.init(id: 1, name: "Botox", color: "#ec75ff"))),
								 patient: BaseClient.init(id: 1, firstName: "Elon", lastName: "Musk", dOB: "28.02.1991", email: "andrej.", avatar: nil, phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil", locationId: Location.randomId()), forms: [], photos: [], postCare: [], paid: "Paid"),
		Journey.init(id: 3,
					 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date(), employeeInitials: "BB", locationId: 1, locationName: "Skopje", status: AppointmentStatus.mock.randomElement()!, service: BaseService.init(id: 1, name: "Botox", color: "#88fa69"))),
								 patient: BaseClient.init(id: 2, firstName: "Madonna", lastName: "", dOB: "28.02.1991", email: "andrej.", avatar: "dummy3", phone: ""), employee: Employee.init(id: 3, name: "Michael Jordan",
																																																avatarUrl: "",
																																																pin: 1234, locationId: Location.randomId()), forms: [], photos: [], postCare: [], paid: "Broke"),
			Journey.init(id: 4,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeInitials: "WM", locationId: 1, locationName: "Manchester", status: AppointmentStatus.mock.randomElement()!, service: BaseService.init(id: 1, name: "Corona Virus", color: "#FFFF00"))),
									 patient: BaseClient.init(id: 0, firstName: "Carl", lastName: "Cox", dOB: "28.02.1991", email: "andrej.", avatar: "dummy1", phone: ""), employee: Employee.init(id: 4,
																																																	name: "Kobe Bryant", locationId: Location.randomId()), forms: [], photos: [], postCare: [], paid: "Not Paid"),
			Journey.init(id: 5,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeInitials: "NJ", locationId: 1, locationName: "Birmingham", status: AppointmentStatus.mock.randomElement()!, service: BaseService.init(id: 1, name: "Botox", color: "#ec75ff"))),
									 patient: BaseClient.init(id: 1, firstName: "Elon", lastName: "Musk", dOB: "28.02.1991", email: "andrej.", avatar: "dummy5", phone: ""), employee: Employee.init(id: 4,
																																																	 name: "Kobe Bryant", locationId: Location.randomId()), forms: [], photos: [], postCare: [], paid: "Paid"),
			Journey.init(id: 6,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() + 1.days, to: Date(), employeeInitials: "RE", locationId: 1, locationName: "London", status: AppointmentStatus.mock.randomElement()!, service: BaseService.init(id: 1, name: "Botox", color: "#88fa69"))),
									 patient: BaseClient.init(id: 2, firstName: "Joe", lastName: "Rogan", dOB: "28.02.1991", email: "andrej.", avatar: "dummy6", phone: ""), employee: Employee.init(id: 4,
									 name: "Kobe Bryant", locationId: Location.randomId()), forms: [], photos: [], postCare: [], paid: "Owes 1.000")
	]
}
