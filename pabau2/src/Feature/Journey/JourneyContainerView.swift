import SwiftUI
import FSCalendarSwiftUI
import Model
import Util
import NonEmpty
import ComposableArchitecture

public typealias JourneyEnvironemnt = (apiClient: APIClient, userDefaults: UserDefaults)

func journeyReducer(state: inout JourneyState, action: JourneyAction, environment: JourneyEnvironemnt) -> [Effect<JourneyAction>] {
	switch action {
	case .selectedFilter(let filter):
		state.selectedFilter = filter
	case .selectedDate(let date):
		state.selectedDate = date
		return [
//			environment.apiClient.
		]
	case .selectedEmployees(let employees):
		state.selectedEmployees = employees
	case .addAppointment:
		state.isShowingAddAppointment = true
	case .gotResponse(let result):
		switch result {
		case .success(let journeys):
			state.journeys.formUnion(journeys)
			state.loadingState = .gotSuccess(journeys)
		case .failure(let error):
			state.loadingState = .gotError(error)
		}
	case .searchedText(let searchText):
		state.searchText = searchText
	case .toggleEmployees:
		state.isShowingEmployees = !state.isShowingEmployees
	}
	return []
}

enum JourneyAction {
	case selectedFilter(CompleteFilter)
	case selectedDate(Date)
	case selectedEmployees([Employee])
	case addAppointment
	case searchedText(String)
	case toggleEmployees
	case gotResponse(Result<[Journey], HTTPError>)
}

enum HTTPError: Error, Equatable {

}

enum CompleteFilter {
	case all
	case open
	case complete
}

struct JourneyState {
	var loadingState: LoadingState<[Journey], HTTPError>
	var journeys: Set<Journey>
	var selectedFilter: CompleteFilter
	var selectedDate: Date
	var selectedEmployees: [Employee]
	var selectedLocation: Location
	var searchText: String
	var isShowingAddAppointment: Bool
	var isShowingEmployees: Bool

//	var displayJourneys: [Journey] {
//		return journeys.filter { $0.date}
//	}
}

//func nonEmptyAppts() -> NonEmpty<[Appointment]> {
//	var appts = [Appointment]()
//	for i in 0...10 {
//		let appt = Appointment.init(id: i, from: Date(), to: Date(), employeeId: 1, locationId: 1)
//		appts.append(appt)
//	}
//	return NonEmpty.init(appts.first!, Array(appts.suffix(from: 1)))
//}
//let journeys: [Journey] = [
//	Journey.init(id: 0,
//							 appointments: nonEmptyAppts(),
//							 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "", phone: ""), employee: Employee.init(id: 1, name: "Bojan Trajkovski"), forms: [], photos: [], postCare: [])
//]

public struct JourneyContainerView: View {
	let journeys: [Journey] = [
			Journey.init(id: 0,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, locationId: 1, service: BaseService.init(id: 1, name: "purple", color: "#9400D3"))),
									 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "", phone: ""), employee: Employee.init(id: 1, name: "Bojan Trajkovski"), forms: [], photos: [], postCare: [])
	]
	let calendarViewModel = MyCalendarViewModel()
	public init () {}
	public var body: some View {
		VStack {
			SwiftUICalendar.init(calendarViewModel)
			JourneyList(journeys: journeys)
		}
	}

	//	let appt1 = Journey(id: 0,
	//											appointments: [],
	//											patient: BaseClient(),
	//											employee: Employee())
	//
	//	let journeys: [Journey] = [
	//
	//	]
}

func journeyCellAdapter(journey: Journey) -> JourneyCell {
	return JourneyCell(
		color: Color.init(hex: journey.appointments.head.service!.color),
		time: "12:30",
		imageUrl: journey.patient.avatar,
		name: journey.patient.firstName + journey.patient.lastName,
		services: journey.appointments
			.map { $0.service }
			.compactMap { $0?.name }
			.reduce("", +),
		status: journey.appointments.head.status?.name,
		employee: journey.employee.name,
		paidStatus: "Paid",
		stepsComplete: 0,
		stepsTotal: 3)
}

struct JourneyList: View {
	let journeys: [Journey]
	var body: some View {
		List {
			ForEach(journeys) { journey in
				journeyCellAdapter(journey: journey)
			}
		}
	}
}

struct JourneyCell: View {
	let color: Color
	let time: String
	let imageUrl: String?
	let name: String
	let services: String
	let status: String?
	let employee: String
	let paidStatus: String
	let stepsComplete: Int
	let stepsTotal: Int
	var body: some View {
		HStack {
			JourneyColorRect(color: color)
			Text(time)
			Image(imageUrl ?? "avatar_placeholder")
			VStack {
				Text(name)
				Text(services)
				Text(status ?? "")
			}
			Image(systemName: "person")
			Text(employee)
			Image(systemName: "briefcase")
			Text(paidStatus)
			StepsStatusView(stepsComplete: stepsComplete, stepsTotal: stepsTotal)
		}
	}
}

struct StepsStatusView: View {
	let stepsComplete: Int
	let stepsTotal: Int
	var body: some View {
		Ellipse()
			.fill(Color.blue)
			.frame(width: 100.0, height: 50.0)
	}
}

struct JourneyColorRect: View {
	let color: Color
	var body: some View {
		Rectangle()
			.frame(width: 8.0)
			.background(color)
	}
}