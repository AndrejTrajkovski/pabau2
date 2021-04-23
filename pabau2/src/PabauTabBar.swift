import SwiftUI
import ComposableArchitecture
import Model
import Util
import Journey
import Clients
import Calendar
import Filters
import JZCalendarWeekView
import AddAppointment
import Communication
import Intercom
import Appointments

public typealias TabBarEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	formAPI: FormAPI,
	userDefaults: UserDefaultsConfig,
    storage: CoreDataStorage
)

public enum TabItemId: String {
	case journey
	case calendar
	case settings
	case communication
	case clients
}

public struct TabBarState: Equatable {
	var selectedTab: TabItemId = .journey
	var appsLoadingState: LoadingState
	var appointments: Appointments
	var addAppointment: AddAppointmentState?
	var journey: JourneyState
	var clients: ClientsState
	var calendar: CalendarState
	var settings: SettingsState
    var communication: CommunicationState

	public var calendarContainer: CalendarContainerState? {
		get {
			guard case .calendar(let calApps) = appointments else { return nil }
            return CalendarContainerState(
                addAppointment: addAppointment,
                calendar: calendar,
                appointments: calApps
            )
		}
		set {
			guard let newValue = newValue else { return }
			self.addAppointment = newValue.addAppointment
			self.calendar = newValue.calendar
			self.appointments = .calendar(newValue.appointments)
		}
	}

	public var journeyContainer: JourneyContainerState? {
		get {
			guard case .journey(let journeyApps) = appointments else { return nil }
			return JourneyContainerState(journey: self.journey,
										 employees: self.calendar.employees,
										 appointments: journeyApps,
										 loadingState: self.appsLoadingState)
		}
		set {
			guard let newValue = newValue else { return }
			self.journey = newValue.journey
			self.appointments = .journey(newValue.appointments)
			self.appsLoadingState = newValue.loadingState
		}
	}
}

public enum TabBarAction {
	case selectTab(TabItemId)
	case settings(SettingsAction)
	case journey(JourneyContainerAction)
	case clients(ClientsAction)
	case calendar(CalendarAction)
	case addAppointment(AddAppointmentAction)
    case communication(CommunicationAction)
	case gotLocationsResponse(Result<[Location], RequestError>)
}

struct PabauTabBar: View {
	let store: Store<TabBarState, TabBarAction>
	@ObservedObject var viewStore: ViewStore<ViewState, TabBarAction>
	struct ViewState: Equatable {
		let isShowingCheckin: Bool
		let isShowingAppointments: Bool
		let selectedTab: TabItemId
		init(state: TabBarState) {
			self.isShowingCheckin = state.journeyContainer?.journey.checkIn != nil
			self.isShowingAppointments = state.addAppointment != nil
			self.selectedTab = state.selectedTab
		}
	}
	init (store: Store<TabBarState, TabBarAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(state: ViewState.init(state:),
						 action: { $0 }))
	}

	var body: some View {
		TabView(selection: viewStore.binding(get: { $0.selectedTab },
											 send: { .selectTab($0) })) {
			journey().tag(TabItemId.journey)
			calendar().tag(TabItemId.calendar)
			clients().tag(TabItemId.clients)
			settings().tag(TabItemId.settings)
			communication().tag(TabItemId.communication)
		}
		.modalLink(isPresented: .constant(self.viewStore.state.isShowingCheckin),
				   linkType: ModalTransition.circleReveal,
				   destination: {
					checkIn()
				   }
		)
		.fullScreenCover(isPresented: .constant(self.viewStore.state.isShowingAppointments)) {
			addAppointment()
		}
	}

	fileprivate func journey() -> some View {
		return
			IfLetStore(store.scope(state: { $0.journeyContainer },
								   action: { .journey($0) }),
					   then: JourneyNavigationView.init(_:), else: Text("journey")
			)
			.tabItem {
				Image(systemName: "staroflife")
				Text("Journey")
			}
	}
	
	fileprivate func calendar() -> some View {
		return
			IfLetStore(store.scope(state: { $0.calendarContainer },
								   action: { .calendar($0) }),
					   then: CalendarContainer.init(store:), else: Text("calendar")
			)
			.tabItem {
				Image(systemName: "calendar")
				Text("Calendar")
			}
	}

	fileprivate func clients() -> some View {
		return ClientsNavigationView(
			self.store.scope(
				state: { $0.clients },
				action: { .clients($0) })
		).tabItem {
			Image(systemName: "rectangle.stack.person.crop")
			Text(Texts.clients)
		}.onAppear {
			self.viewStore.send(.clients(ClientsAction.onAppearNavigationView))
		}
	}

	fileprivate func settings() -> some View {
		return Settings(store:
							store.scope(state: { $0.settings },
										action: { .settings($0)}))
			.tabItem {
				Image(systemName: "gear")
				Text("Settings")
			}
	}

	fileprivate func communication() -> some View {
		return CommunicationView(store:
									store.scope(state: { $0.communication },
												action: { .communication($0)}))
			.tabItem {
				Image(systemName: "ico-tab-tasks")
				Text("Intercom")
			}
	}

	fileprivate func checkIn() -> IfLetStore<CheckInContainerState, CheckInContainerAction, CheckInNavigationView?> {
		return IfLetStore(self.store.scope(
			state: { $0.journeyContainer?.journey.checkIn },
			action: { .journey(.journey(.checkIn($0))) }
		),
		then: CheckInNavigationView.init(store:))
	}

	fileprivate func addAppointment() -> IfLetStore<AddAppointmentState, AddAppointmentAction, AddAppointment?> {
		return IfLetStore(self.store.scope(
			state: { $0.addAppointment },
			action: { .addAppointment($0)}
		),
		then: AddAppointment.init(store:))
	}
}

public let tabBarReducer: Reducer<
    TabBarState,
    TabBarAction,
    TabBarEnvironment
> = Reducer.combine(
	.init { state, action, _ in
		switch action {
		case .selectTab(let tabItemId):
			state.selectedTab = tabItemId
			switch tabItemId {
			case .calendar:
				state.appointments.switchTo(type: .calendar(.employee),
											locationsIds: state.calendar.locations.map(\.id),
											employees: state.calendar.employees.flatMap(\.value),
											rooms: state.calendar.rooms.flatMap(\.value)
				)
			case .journey:
				state.appointments.switchTo(type: .journey,
											locationsIds: [], employees: [], rooms: [])
			default:
				break
			}
		case .gotLocationsResponse(let locationsResponse):
			switch locationsResponse {
				// MARK: - Iurii
			case .success(let locations):
				state.calendar.locations = IdentifiedArray(locations)
//				state.calendar.chosenLocationsIds = locations.map(\.id)
//				print("chosenLocation: \(locations.map(\.id).first!)")
//				state.journey.selectedLocation = locations.first!
//				state.calendar.chosenLocationsIds = [locations.map(\.id).first!]
			case .failure(let error):
				break
			}
		case .journey(.employeesFilter(.gotResponse(let employeesResponse))):
			switch employeesResponse {
			case .success(let employees):
				// MARK: - Iurii
				state.calendar.employees = employees.reduce(into: [Location.ID: IdentifiedArrayOf<Employee>](),
								 { result, employee in
									employee.locations.forEach { location in
										if result[location] != nil {
											result[location]!.append(employee)
										} else {
											result[location] = IdentifiedArrayOf.init([employee])
										}
									}
								 })
//				let locs = state.calendar.locations.map(\.id)
//				state.calendar.employees = locs.reduce(into: [Location.ID: IdentifiedArrayOf<Employee>](),
//													   {
//														$0[$1] = []
//													   })
				
//				state.calendar.chosenEmployeesIds = state.calendar.employees.mapValues {
//					$0.map(\.id)
//				}
			case .failure(let error):
				break
			}
		case .journey(.addAppointmentTap):
			state.addAppointment = AddAppointmentState.dummy
		default:
			break
		}
		return .none
	},
	addAppointmentReducer.pullback(
		state: \TabBarState.addAppointment,
		action: /TabBarAction.addAppointment,
		environment: {
			return AddAppointmentEnv(journeyAPI: $0.journeyAPI,
									 clientAPI: $0.clientsAPI,
									 userDefaults: $0.userDefaults)
		}
	),
	settingsReducer.pullback(
		state: \TabBarState.settings,
		action: /TabBarAction.settings,
		environment: {
			SettingsEnvironment(
				loginAPI: $0.loginAPI,
				clientsAPI: $0.clientsAPI,
				formAPI: $0.formAPI,
				userDefaults: $0.userDefaults)
		}
	),
	journeyContainerReducer.optional().pullback(
		state: \TabBarState.journeyContainer,
		action: /TabBarAction.journey,
		environment: makeJourneyEnv(_:)
	),
	clientsContainerReducer.pullback(
		state: \TabBarState.clients,
		action: /TabBarAction.clients,
		environment: makeClientsEnv(_:)
	),
	calendarContainerReducer.optional().pullback(
		state: \TabBarState.calendarContainer,
		action: /TabBarAction.calendar,
		environment: {
			return CalendarEnvironment(
				journeyAPI: $0.journeyAPI,
				clientsAPI: $0.clientsAPI,
                userDefaults: $0.userDefaults,
                storage: $0.storage
            )
		}),
	communicationReducer.pullback(
		state: \TabBarState.communication,
		action: /TabBarAction.communication,
		environment: { $0 }
	),
	.init { _, action, _ in
		switch action {
		case .communication(.liveChat):
			Intercom.registerUser(withEmail: "a@a.com")
			Intercom.presentMessenger()
			return .none
		case .communication(.helpGuides):
			Intercom.presentHelpCenter()
			return .none
		case .communication(.carousel):
			Intercom.presentCarousel("13796318")
			return .none
        default:
            break
        }

        return .none
    }
)

extension TabBarState {
	public init() {
		self.journey = JourneyState()
		self.clients = ClientsState()
		self.calendar = CalendarState()
		self.settings = SettingsState()
		self.communication = CommunicationState()
		self.appointments = .journey(JourneyAppointments.init(events: []))
//		self.appointments = .employee(EventsBy<Employee>.init(events: [], locationsIds: [], subsections: [], sectionKeypath: \CalendarEvent.locationId, subsKeypath: \CalendarEvent.employeeId))
		self.appsLoadingState = .initial
	}
}
