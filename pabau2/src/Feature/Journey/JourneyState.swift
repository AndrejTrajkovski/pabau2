import Model
import Util
import NonEmpty
import SwiftDate

public struct JourneyState {
	public init () {}
	var loadingState: LoadingState<[Journey], RequestError> = .initial
	var journeys: Set<Journey> = [
		Journey.init(id: 0,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#9400D3"))),
								 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Bojan Trajkovskiiii"), forms: [], photos: [], postCare: [], paid: "Not Paid"),
		Journey.init(id: 1,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() + 1.days, to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#ec75ff"))),
								 patient: BaseClient.init(id: 1, firstName: "Elon", lastName: "Musk", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "John Doe"), forms: [], photos: [], postCare: [], paid: "Paid"),
		Journey.init(id: 2,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() + 1.days, to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#88fa69"))),
								 patient: BaseClient.init(id: 2, firstName: "Joe", lastName: "Rogan", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Tiger Woods"), forms: [], photos: [], postCare: [], paid: "Owes 1.000")
	]
	var selectedFilter: CompleteFilter = .all
	var selectedDate: Date = Date()
	var selectedEmployees: [Employee] = []
	var selectedLocation: Location = Location.init(id: 1)
	var searchText: String = ""
	var isShowingAddAppointment: Bool = false
	var isShowingEmployees: Bool = false

	var filteredJourneys: [Journey] {
		return self.journeys.filter { $0.appointments.first.from.isInside(date: selectedDate, granularity: .day) }
	}
}
