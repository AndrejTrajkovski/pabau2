import SwiftUI
import FSCalendarSwiftUI
import Model
import Util
import NonEmpty
import ComposableArchitecture
import SwiftDate

public struct EmployeesState: Equatable {
	var loadingState: LoadingState = .initial
	var employees: [Employee] = []
	var selectedEmployeesIds: Set<Int> = Set()
	public var isShowingEmployees: Bool = false
}

public enum EmployeesAction {
	case toggleEmployees
	case gotResponse(Result<[Employee], RequestError>)
	case onTapGestureEmployee(Employee)
	case loadEmployees
}

let employeeListReducer = Reducer<EmployeesState, EmployeesAction, JourneyEnvironemnt> { state, action, env in
	func handle(result: Result<[Employee], RequestError>,
							state: inout EmployeesState) -> Effect<EmployeesAction, Never> {
		switch result {
		case .success(let employees):
			state.employees = employees
			state.loadingState = .gotSuccess
			state.selectedEmployeesIds = Set.init(employees.map { $0.id })
		case .failure:
			state.loadingState = .gotError
		}
		return .none
	}

	switch action {
	case .gotResponse(let response):
		return handle(result: response, state: &state)
	case .onTapGestureEmployee(let employee):
		if state.selectedEmployeesIds.contains(employee.id) {
			state.selectedEmployeesIds.remove(employee.id)
		} else {
			state.selectedEmployeesIds.insert(employee.id)
		}
	case .toggleEmployees:
		state.isShowingEmployees.toggle()
	case .loadEmployees:
		state.loadingState = .loading
		return env.apiClient.getEmployees()
			.map {.gotResponse($0)}
			.eraseToEffect()
	}
	return .none
}

public typealias JourneyEnvironemnt = (apiClient: JourneyAPI, userDefaults: UserDefaultsConfig)

let checkInMiddleware2 = Reducer<JourneyState, ChooseFormAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .proceed:
		guard let selJ = state.selectedJourney,
			let selP = state.selectedPathway else { return .none }
		state.checkIn = CheckInContainerState(
			journey: selJ,
			pathway: selP,
			patientDetails: PatientDetails(),
			medHistory: JourneyMockAPI.getMedHistory(),
			consents: state.allConsents.filter { state.selectedConsentsIds.contains($0.id)},
			allConsents: state.allConsents)
	default:
		return .none
	}
	return .none
}

let checkInMiddleware = Reducer<JourneyState, CheckInContainerAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .closeBtnTap:
		state.selectedJourney = nil
		state.selectedPathway = nil
		state.checkIn = nil
	default:
		return .none
	}
	return .none
}

//JourneyState, ChooseFormAction
public let journeyContainerReducer: Reducer<JourneyState, JourneyContainerAction, JourneyEnvironemnt> =
	.combine(
		checkInMiddleware2.pullback(
			state: \JourneyState.self,
			action: /JourneyContainerAction.choosePathway..ChoosePathwayContainerAction.chooseConsent,
			environment: { $0 }),
		journeyReducer.pullback(
					 state: \JourneyState.self,
					 action: /JourneyContainerAction.journey,
					 environment: { $0 }),
		employeeListReducer.pullback(
					 state: \JourneyState.employeesState,
					 action: /JourneyContainerAction.employees,
					 environment: { $0 }),
		addAppointmentReducer.pullback(
					 state: \JourneyState.addAppointment,
					 action: /JourneyContainerAction.addAppointment,
					 environment: { $0 }),
		choosePathwayContainerReducer.pullback(
					 state: \JourneyState.choosePathway,
					 action: /JourneyContainerAction.choosePathway,
					 environment: { $0 }),
		checkInReducer.optional.pullback(
					 state: \JourneyState.checkIn,
					 action: /JourneyContainerAction.checkIn,
					 environment: { $0 }),
		checkInMiddleware.pullback(
					 state: \JourneyState.self,
					 action: /JourneyContainerAction.checkIn,
					 environment: { $0 })
)

let journeyReducer = Reducer<JourneyState, JourneyAction, JourneyEnvironemnt> { state, action, environment in
	switch action {
	case .selectedFilter(let filter):
		state.selectedFilter = filter
	case .selectedDate(let date):
		state.selectedDate = date
		state.loadingState = .loading
		return environment.apiClient.getJourneys(date: date)
				.map(JourneyAction.gotResponse)
				.eraseToEffect()
	case .addAppointmentTap:
		state.addAppointment.isShowingAddAppointment = true
	case .addAppointmentDismissed:
		state.addAppointment.isShowingAddAppointment = false
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
		state.employeesState.isShowingEmployees.toggle()
	case .selectedJourney(let journey):
		state.selectedJourney = journey
	case .choosePathwayBackTap:
		state.selectedJourney = nil
	case .loadJourneys:
		state.loadingState = .loading
		return environment.apiClient
				.getJourneys(date: Date())
				.map(JourneyAction.gotResponse)
				.eraseToEffect()
	}
	return .none
}

public struct JourneyContainerView: View {
	@State private var calendarHeight: CGFloat?
	let store: Store<JourneyState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, JourneyContainerAction>
	struct ViewState: Equatable {
		let isChoosePathwayShown: Bool
		let selectedDate: Date
		let listedJourneys: [Journey]
		let isLoadingJourneys: Bool
		init(state: JourneyState) {
			self.isChoosePathwayShown = state.selectedJourney != nil
			self.selectedDate = state.selectedDate
			self.listedJourneys = state.filteredJourneys
			self.isLoadingJourneys = state.loadingState.isLoading
			UITableView.appearance().separatorStyle = .none
		}
	}
	public init(_ store: Store<JourneyState, JourneyContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(state: ViewState.init(state:),
						 action: { $0 }))
		print("JourneyContainerView init")
	}
	public var body: some View {
		print("JourneyContainerView body")
		return VStack {
			SwiftUICalendar.init(viewStore.state.selectedDate,
													 self.$calendarHeight,
													 .week) { date in
														self.viewStore.send(.journey(.selectedDate(date)))
			}
			.padding(0)
			.frame(height: self.calendarHeight)
			FilterPicker()
			JourneyList(self.viewStore.state.listedJourneys) {
				self.viewStore.send(.journey(.selectedJourney($0)))
			}.loadingView(.constant(self.viewStore.state.isLoadingJourneys),
										Texts.fetchingJourneys)
			NavigationLink.emptyHidden(self.viewStore.state.isChoosePathwayShown,
																 ChoosePathway(store: self.store.scope(state: { $0.choosePathway
																 }, action: { .choosePathway($0)}))
																	.navigationBarTitle("Choose Pathway")
																	.customBackButton {
																		self.viewStore.send(.journey(.choosePathwayBackTap))
				}
			)
			Spacer()
		}
		.navigationBarTitle("Manchester", displayMode: .inline)
		.navigationBarItems(leading:
			HStack(spacing: 8.0) {
				Button(action: {
					withAnimation(Animation.easeIn(duration: 0.5)) {
						self.viewStore.send(.journey(.addAppointmentTap))
					}
				}, label: {
					Image(systemName: "plus")
						.font(.system(size: 20))
						.frame(width: 44, height: 44)
				})
				Button(action: {

				}, label: {
					Image(systemName: "magnifyingglass")
						.font(.system(size: 20))
						.frame(width: 44, height: 44)
				})
			}, trailing:
			Button (action: {
				withAnimation {
					self.viewStore.send(.journey(.toggleEmployees))
				}
			}, label: {
				Image(systemName: "person")
					.font(.system(size: 20))
					.frame(width: 44, height: 44)
			})
		)
	}

	struct ChoosePathwayEither: View {
		let store: Store<JourneyState, JourneyContainerAction>
		let isSelectedJourney: Bool
		var body: some View {
			ViewBuilder.buildBlock(
				(isSelectedJourney) ?
					ViewBuilder.buildEither(second:
						ChoosePathway(store: self.store.scope(state: { $0.choosePathway
						}, action: { .choosePathway($0)}))
					)
					:
					ViewBuilder.buildEither(first:
						EmptyView()
				)
			)
		}
	}

	var clientState: PickerContainerState<Client> {
		return PickerContainerState.init(
			dataSource: [
				Client.init(id: 1, firstName: "Wayne", lastName: "Rooney", dOB: Date()),
				Client.init(id: 2, firstName: "Adam", lastName: "Smith", dOB: Date())
			],
			chosenItemId: 1,
			isActive: false)
	}

	var terminState: PickerContainerState<MyTermin> {
		PickerContainerState.init(
			dataSource: [
				MyTermin.init(name: "02-02-2020 12:30", id: 1, date: Date()),
				MyTermin.init(name: "01-03-2020 13:30", id: 2, date: Date()),
				MyTermin.init(name: "01-03-2020 14:30", id: 3, date: Date())
			],
			chosenItemId: 1,
			isActive: false)
	}

	var serviceState: PickerContainerState<Service> {
		PickerContainerState.init(
			dataSource: [
				Service.init(id: 1, name: "Botox", color: "", categoryId: 1, categoryName: "Injectables"),
				Service.init(id: 2, name: "Fillers", color: "", categoryId: 2, categoryName: "Urethra"),
				Service.init(id: 3, name: "Facial", color: "", categoryId: 3, categoryName: "Mosaic")
			],
			chosenItemId: 1,
			isActive: false)
	}

	var durationState: PickerContainerState<Duration> {
		PickerContainerState.init(
			dataSource: [
				Duration.init(name: "00:30", id: 1, duration: 30),
				Duration.init(name: "01:00", id: 2, duration: 60),
				Duration.init(name: "01:30", id: 3, duration: 90)
			],
			chosenItemId: 1,
			isActive: false)
	}

	var withState: PickerContainerState<Employee> {
		PickerContainerState.init(
			dataSource: [
				Employee.init(id: 1, name: "Andrej Trajkovski"),
				Employee.init(id: 2, name: "Mark Ronson")
			],
			chosenItemId: 1,
			isActive: false)
	}

	var participantsState: PickerContainerState<Employee> {
		PickerContainerState.init(
			dataSource: [
				Employee.init(id: 1, name: "Participant 1"),
				Employee.init(id: 2, name: "Participant 2")
			],
			chosenItemId: 1,
			isActive: false)
	}
}

func journeyCellAdapter(journey: Journey) -> JourneyCell {
	return JourneyCell(
		color: Color.init(hex: journey.appointments.head.service!.color),
		time: "12:30",
		imageUrl: journey.patient.avatar,
		name: journey.patient.firstName + " " + journey.patient.lastName,
		services: journey.servicesString,
		status: journey.appointments.head.status?.name,
		employee: journey.employee.name,
		paidStatus: journey.paid,
		stepsComplete: 0,
		stepsTotal: 3)
}

struct JourneyList: View {
	let journeys: [Journey]
	let onSelect: (Journey) -> Void
	init (_ journeys: [Journey],
				_ onSelect: @escaping (Journey) -> Void) {
		self.journeys = journeys
		self.onSelect = onSelect
	}
	var body: some View {
		List {
			ForEach(journeys) { journey in
				journeyCellAdapter(journey: journey)
					.onTapGesture { self.onSelect(journey) }
					.listRowInsets(EdgeInsets())
			}
		}.id(UUID())
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
		VStack(spacing: 0) {
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
				IconAndText(Image(systemName: "person"), employee)
					.frame(maxWidth: 110, alignment: .leading)
				Spacer()
				IconAndText(Image(systemName: "bag"), paidStatus)
					.frame(maxWidth: 110, alignment: .leading)
				Spacer()
				StepsStatusView(stepsComplete: stepsComplete, stepsTotal: stepsTotal)
				Spacer()
			}
			Divider().frame(height: 1)
		}
		.frame(minWidth: 0, maxWidth: .infinity, idealHeight: 97)
	}
}

struct IconAndText: View {
	let text: String
	let image: Image
	let textColor: Color
	init(_ image: Image,
			 _ text: String,
			 _ textColor: Color = .black) {
		self.image = image
		self.text = text
		self.textColor = textColor
	}
	var body: some View {
		HStack {
			image
				.resizable()
				.scaledToFit()
				.foregroundColor(.blue2)
				.frame(width: 20, height: 20)
			Text(text)
				.font(Font.semibold11)
				.foregroundColor(textColor)
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
