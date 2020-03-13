import SwiftUI
import FSCalendarSwiftUI
import Model
import Util
import NonEmpty
import ComposableArchitecture

public typealias JourneyEnvironemnt = (apiClient: JourneyAPI, userDefaults: UserDefaults)

public func journeyReducer(state: inout JourneyState, action: JourneyAction, environment: JourneyEnvironemnt) -> [Effect<JourneyAction>] {
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
		state.isShowingEmployees.toggle()
	}
	return []
}
public struct JourneyContainerView: View {
	let journeys: [Journey] = [
		Journey.init(id: 0,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#9400D3"))),
								 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Bojan Trajkovskiiii"), forms: [], photos: [], postCare: [], paid: "Not Paid"),
		Journey.init(id: 1,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#ec75ff"))),
								 patient: BaseClient.init(id: 1, firstName: "Elon", lastName: "Musk", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "John Doe"), forms: [], photos: [], postCare: [], paid: "Paid"),
		Journey.init(id: 2,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#88fa69"))),
								 patient: BaseClient.init(id: 2, firstName: "Joe", lastName: "Rogan", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Tiger Woods"), forms: [], photos: [], postCare: [], paid: "Owes 1.000")
	]

	public init (date: Date) {
		calendarViewModel = MyCalendarViewModel(date)
	}
	
	@State private var calendarHeight: CGFloat?
	let calendarViewModel: MyCalendarViewModel
	public var body: some View {
		VStack {
			SwiftUICalendar.init(calendarViewModel, self.$calendarHeight)
				.padding(0)
				.frame(height: self.calendarHeight)
			FilterPicker()
			JourneyList(journeys: journeys)
			Spacer()
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
		paidStatus: journey.paid,
		stepsComplete: 0,
		stepsTotal: 3)
}

struct JourneyList: View {
	let journeys: [Journey]
	var body: some View {
		List {
			ForEach(journeys) { journey in
				journeyCellAdapter(journey: journey)
					.listRowInsets(EdgeInsets())
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
			Spacer()
			Group {
				Text(time).font(Font.semibold11)
				Spacer()
				Image(imageUrl ?? "emily")
					.resizable()
					.frame(width: 55, height: 55)
					.clipShape(Circle())
				VStack(alignment: .leading, spacing: 4) {
					Text(name).font(Font.semibold14)
					Text(services).font(Font.regular12)
					Text(status ?? "").font(.medium9).foregroundColor(.deepSkyBlue)
				}.frame(maxWidth: 158, alignment: .leading)
			}
			Spacer()
			IconAndText(imageSystemName: "person", text: employee)
				.frame(maxWidth: 110, alignment: .leading)
			Spacer()
			IconAndText(imageSystemName: "bag", text: paidStatus)
				.frame(maxWidth: 110, alignment: .leading)
			Spacer()
			StepsStatusView(stepsComplete: stepsComplete, stepsTotal: stepsTotal)
			Spacer()
		}
		.frame(minWidth: 0, maxWidth: .infinity, idealHeight: 97)
	}
}

struct IconAndText: View {
	let imageSystemName: String
	let text: String
	var body: some View {
		HStack {
			Image(systemName: imageSystemName)
				.resizable()
				.scaledToFit()
				.foregroundColor(.deepSkyBlue)
				.frame(width: 20, height: 20)
			Text(text)
				.font(Font.semibold11)
		}
	}
}

struct StepsStatusView: View {
	let stepsComplete: Int
	let stepsTotal: Int
	var body: some View {
		Text("\(stepsComplete)/\(stepsTotal)")
			.foregroundColor(.white)
			.font(.semibold14)
			.padding(5)
			.frame(width: 50, height: 20)
			.background(RoundedCorners(color: .blue, tl: 25, tr: 25, bl: 25, br: 25))
	}
}

struct JourneyColorRect: View {
	public let color: Color
	var body: some View {
		Rectangle()
			.foregroundColor(color)
			.frame(width: 8.0)
	}
}

struct FilterPicker: View {
	@State private var filter: CompleteFilter = .all
	var body: some View {
		VStack {
			Picker(selection: $filter, label: Text("What is your favorite color?")) {
				ForEach(CompleteFilter.allCases, id: \.self) { (filter: CompleteFilter) in
					Text(String(filter.description)).tag(filter.rawValue)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}.padding()
	}
}
