import SwiftUI
import FSCalendarSwiftUI
import Model
import Util
import NonEmpty
import ComposableArchitecture
import SwiftDate

public struct EmployeesState {
	var loadingState: LoadingState
	var employees: [Employee]
	var selectedEmployeesIds: [Int]
}

public enum EmployeesAction {
	case gotResponse(Result<[Employee], ErrorResponse>)
	case onTapGestureEmployee(Employee)
}

public func employeeListReducer(state: inout EmployeesState,
																action: EmployeesAction,
																environment: JourneyEnvironemnt) -> [Effect<EmployeesAction>] {
	switch action {
	case .gotResponse(let response):
		switch (response) {
		case .success(let employees):
			state.employees = employees
		case .failure(let error):
			
		}
	default:
		<#code#>
	}
}

public typealias JourneyEnvironemnt = (apiClient: JourneyAPI, userDefaults: UserDefaults)

public func journeyReducer(state: inout JourneyState, action: JourneyAction, environment: JourneyEnvironemnt) -> [Effect<JourneyAction>] {
	switch action {
	case .selectedFilter(let filter):
		state.selectedFilter = filter
	case .selectedDate(let date):
		state.selectedDate = date
		state.loadingState = .loading
		return [
			environment.apiClient.getJourneys(date: date)
				.map(JourneyAction.gotResponse)
				.eraseToEffect()
		]
	case .selectedEmployees(let employees):
		state.employees = employees
	case .addAppointment:
		state.isShowingAddAppointment = true
	case .gotResponse(let result):
		switch result {
		case .success(let journeys):
			state.journeys.formUnion(journeys)
			state.loadingState = .gotSuccess
		case .failure:
			state.loadingState = .gotError
		}
	case .searchedText(let searchText):
		state.searchText = searchText
	case .toggleEmployees:
		state.isShowingEmployees.toggle()
	}
	return []
}
public struct JourneyContainerView: View {
	@State private var calendarHeight: CGFloat?
	@ObservedObject var store: Store<JourneyState, JourneyAction>
	public init(_ store: Store<JourneyState, JourneyAction>) {
		self.store = store
	}
	public var body: some View {
		VStack {
			SwiftUICalendar.init(store.value.selectedDate,
													 self.$calendarHeight,
													 .week) {date in
														self.store.send(.selectedDate(date))
			}
			.padding(0)
			.frame(height: self.calendarHeight)
			FilterPicker()
			LoadingView(title: Texts.fetchingJourneys, bindingIsShowing: .constant(self.store.value.loadingState.isLoading)) {
				JourneyList(self.store.value.filteredJourneys)
			}
			Spacer()
		}
	}
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
	init (_ journeys: [Journey]) {
		self.journeys = journeys
		UITableView.appearance().separatorStyle = journeys.isEmpty ? .none : .singleLine
	}
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
			Picker(selection: $filter, label: Text("Filter")) {
				ForEach(CompleteFilter.allCases, id: \.self) { (filter: CompleteFilter) in
					Text(String(filter.description)).tag(filter.rawValue)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}.padding()
	}
}

struct EmployeeList: View {
	public let selectedEmployeesIds: [Int]
	public let employees: [Employee]
	public let didSelectEmployee: (Employee) -> Void
	public var body: some View {
		List {
			ForEach(employees) { employee in
				EmployeeRow(employee: employee,
										isSelected: self.selectedEmployeesIds.contains(employee.id)) {
											self.didSelectEmployee($0)
				}
			}
		}
	}
}

struct EmployeeRow: View {
	let employee: Employee
	let isSelected: Bool
	let didSelectEmployee: (Employee) -> Void
	var body: some View {
		HStack {
			Image.init(self.isSelected ? "􀁣" : "􀀀")
			Text(employee.name)
		}.onTapGesture {
			self.didSelectEmployee(self.employee)
		}
	}
}
