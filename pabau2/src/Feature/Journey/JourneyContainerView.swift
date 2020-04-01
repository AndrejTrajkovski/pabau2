import SwiftUI
import FSCalendarSwiftUI
import Model
import Util
import NonEmpty
import ComposableArchitecture
import SwiftDate
import CasePaths

public struct EmployeesState: Equatable {
	var loadingState: LoadingState = .initial
	var employees: [Employee] =
//		[]
	[
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
	var selectedEmployeesIds: Set<Int> = Set([1, 2, 3, 4, 5, 6, 7])
	public var isShowingEmployees: Bool = false
}

public enum EmployeesAction {
	case toggleEmployees
	case gotResponse(Result<[Employee], RequestError>)
	case onTapGestureEmployee(Employee)
	case onAppear
}

public func employeeListReducer(state: inout EmployeesState,
																action: EmployeesAction,
																environment: JourneyEnvironemnt) -> [Effect<EmployeesAction>] {
	func handle(result: Result<[Employee], RequestError>,
							state: inout EmployeesState) -> [Effect<EmployeesAction>] {
		switch result {
		case .success(let employees):
			state.employees = employees
			state.loadingState = .gotSuccess
			state.selectedEmployeesIds = Set.init(employees.map { $0.id })
		case .failure:
			state.loadingState = .gotError
		}
		return []
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
	case .onAppear:
		return [
			environment.apiClient.getEmployees()
				.map { .gotResponse($0)}
				.eraseToEffect()
		]
	}
	return []
}

public typealias JourneyEnvironemnt = (apiClient: JourneyAPI, userDefaults: UserDefaultsConfig)

public let journeyContainerReducer: Reducer<JourneyState, JourneyContainerAction, JourneyEnvironemnt> = combine(
	pullback(journeyReducer,
					 value: \JourneyState.self,
					 action: /JourneyContainerAction.journey,
					 environment: { $0 }),
	pullback(employeeListReducer,
					 value: \JourneyState.employeesState,
					 action: /JourneyContainerAction.employees,
					 environment: { $0 }),
	pullback(addAppointmentReducer,
					 value: \JourneyState.addAppointment,
					 action: /JourneyContainerAction.addAppointment,
					 environment: { $0 }),
	pullback(choosePathwayContainerReducer,
					 value: \JourneyState.choosePathway,
					 action: /JourneyContainerAction.choosePathway,
					 environment: { $0 })
)

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
		state.isChoosePathwayShown = true
		state.selectedJourney = journey
	case .choosePathwayBackTap:
		state.isChoosePathwayShown = false
		state.selectedJourney = nil
	}
	return []
}

public struct JourneyContainerView: View {
	@State private var calendarHeight: CGFloat?
	let store: Store<JourneyState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<JourneyState, JourneyContainerAction>
	public init(_ store: Store<JourneyState, JourneyContainerAction>) {
		self.store = store
		self.viewStore = self.store.view
		print("JourneyContainerView init")
	}
	public var body: some View {
		print("JourneyContainerView body")
		return VStack {
			SwiftUICalendar.init(viewStore.value.selectedDate,
													 self.$calendarHeight,
													 .week) { date in
														self.viewStore.send(.journey(.selectedDate(date)))
			}
			.padding(0)
			.frame(height: self.calendarHeight)
			FilterPicker()
			JourneyList(self.viewStore.value.filteredJourneys) {
				self.viewStore.send(.journey(.selectedJourney($0)))
			}.loadingView(.constant(self.viewStore.value.loadingState.isLoading),
										Texts.fetchingJourneys)
			NavigationLink.emptyHidden(self.viewStore.value.isChoosePathwayShown,
																 ChoosePathwayEither(store: store, isSelectedJourney: self.viewStore.value.isChoosePathwayShown)
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
						self.viewStore.send(.journey(.addAppointmentTap))
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
				self.viewStore.send(.journey(.toggleEmployees))
			}, label: {
				Image(systemName: "person")
					.font(.system(size: 20))
					.frame(width: 44, height: 44)
			})
		)
			.sheet(isPresented: .constant(self.viewStore.value.addAppointment.isShowingAddAppointment),
						 onDismiss: { self.viewStore.send(.journey(.addAppointmentDismissed))},
						 content: {
							AddAppointment.init(store:
								self.store.scope(value: { $0.addAppointment },
																 action: { .addAppointment($0)})
							)
			})
//			.modalLink(isPresented: .constant(self.viewStore.value.isModalShown),
//								 linkType: ModalTransition.circleReveal,
//								 destination: {
//									Rectangle().fill(Color.blue)
//
//			}).navigationBarHidden(self.viewStore.value.addAppointment.isShowingAddAppointment || self.viewStore.value.isModalShown)
	}

	struct ChoosePathwayEither: View {
		let store: Store<JourneyState, JourneyContainerAction>
		let isSelectedJourney: Bool
		var body: some View {
			ViewBuilder.buildBlock(
				(isSelectedJourney) ?
					ViewBuilder.buildEither(second:
						ChoosePathway(store: self.store.scope(value: { $0.choosePathway
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
		UITableView.appearance().separatorStyle = journeys.isEmpty ? .none : .singleLine
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

struct EmployeeHeader: View {
	let didTouchHeaderButton: () -> Void
	var body: some View {
		HStack {
			Button (action: {
				self.didTouchHeaderButton()
			}, label: {
				Image(systemName: "person").font(.system(size: 30))
			})
			Text(Texts.employee)
				.foregroundColor(.black)
				.font(Font.semibold20)
		}
		.padding(.bottom)
		.background(Color.employeeBg)
	}
}

public struct EmployeesListStore: View {
	let store: Store<EmployeesState, EmployeesAction>
	@ObservedObject var viewStore: ViewStore<EmployeesState, EmployeesAction>
	public init(_ store: Store<EmployeesState, EmployeesAction>) {
		self.store = store
		self.viewStore = self.store.view
		print("EmployeesListStore init")
	}
	public var body: some View {
		print("EmployeesListStore body")
		return EmployeeList(selectedEmployeesIds: self.viewStore.value.selectedEmployeesIds,
								 employees: self.viewStore.value.employees,
								 header: EmployeeHeader { self.viewStore.send(.toggleEmployees) },
								 didSelectEmployee: { self.viewStore.send(.onTapGestureEmployee($0))})
			.onAppear(perform: { self.viewStore.send(.onAppear) })
	}
}

struct EmployeeList: View {
	public let selectedEmployeesIds: Set<Int>
	public let employees: [Employee]
	public let header: EmployeeHeader
	public let didSelectEmployee: (Employee) -> Void
	public var body: some View {
		//wrapping in Form for color (https://stackoverflow.com/a/57468607/3050624)
		Form {
			List {
				Section(header: header) {
					ForEach(employees) { employee in
						EmployeeRow(employee: employee,
												isSelected: self.selectedEmployeesIds.contains(employee.id)) {
													self.didSelectEmployee($0)
						}
					}
				}
			}
		}.background(Color.employeeBg)
	}
}

struct EmployeeRow: View {
	let employee: Employee
	let isSelected: Bool
	let didSelectEmployee: (Employee) -> Void
	var body: some View {
		HStack {
			Image(systemName: self.isSelected ? "checkmark.circle.fill" : "circle")
				.foregroundColor(self.isSelected ? Color.deepSkyBlue : Color.gray192)
			Text(employee.name)
		}.onTapGesture {
			self.didSelectEmployee(self.employee)
		}.listRowBackground(Color.employeeBg)
	}
}
