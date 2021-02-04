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
	userDefaults: UserDefaultsConfig
)

public struct TabBarState: Equatable {
	var appsLoadingState: LoadingState
	var appointments: Appointments
	var addAppointment: AddAppointmentState?
	var journey: JourneyState
	var clients: ClientsState
	var calendar: CalendarState
	var settings: SettingsState
    var communication: CommunicationState
	
	var journeyEmployeesFilter: JourneyFilterState {
		get {
			JourneyFilterState(
				locationId: journey.selectedLocation.id,
				employeesLoadingState: journey.employeesLoadingState,
				employees: calendar.employees[journey.selectedLocation.id] ?? [],
				selectedEmployeesIds: journey.selectedEmployeesIds,
				isShowingEmployees: journey.isShowingEmployeesFilter
			)
		}
		set {
			self.journey.employeesLoadingState = newValue.employeesLoadingState
			self.calendar.employees[journey.selectedLocation.id] = newValue.employees
			self.journey.selectedEmployeesIds = newValue.selectedEmployeesIds
			self.journey.isShowingEmployeesFilter = newValue.isShowingEmployees
		}
	}

	public var calendarContainer: CalendarContainerState {
		get {
			CalendarContainerState(addAppointment: addAppointment,
								   calendar: calendar)
		}
		set {
			self.addAppointment = newValue.addAppointment
			self.calendar = newValue.calendar
		}
	}

	public var journeyContainer: JourneyContainerState {
		get {
			JourneyContainerState(journey: self.journey,
								  employeesFilter: self.journeyEmployeesFilter,
								  appointments: self.appointments,
								  loadingState: self.appsLoadingState)
		}
		set {
			self.journey = newValue.journey
			self.journeyEmployeesFilter = newValue.employeesFilter
			self.appointments = newValue.appointments
		}
	}
}

public enum TabBarAction {
	case settings(SettingsAction)
	case journey(JourneyContainerAction)
	case clients(ClientsAction)
	case calendar(CalendarAction)
	case employeesFilter(JourneyFilterAction)
	case addAppointment(AddAppointmentAction)
    case communication(CommunicationAction)
}

struct PabauTabBar: View {
	let store: Store<TabBarState, TabBarAction>
	@ObservedObject var viewStore: ViewStore<ViewState, TabBarAction>
	struct ViewState: Equatable {
		let isShowingEmployees: Bool
		let isShowingCheckin: Bool
		let isShowingAppointments: Bool
		init(state: TabBarState) {
			self.isShowingEmployees = state.journeyEmployeesFilter.isShowingEmployees
			self.isShowingCheckin = state.journeyContainer.journey.checkIn != nil
			self.isShowingAppointments = state.addAppointment != nil
		}
	}
	init (store: Store<TabBarState, TabBarAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(state: ViewState.init(state:),
						 action: { $0 }))
		print("PabauTabBar init")
	}
	var body: some View {
		print("PabauTabBar body")
		return ZStack(alignment: .topTrailing) {
			TabView {
				CalendarContainer(store:
									self.store.scope(
										state: { $0.calendar },
										action: { .calendar($0)}
									)
				)
				.tabItem {
						Image(systemName: "calendar")
						Text("Calendar")
				}
				JourneyNavigationView(
					self.store.scope(
						state: { $0.journeyContainer },
						action: { .journey($0)})
				).tabItem {
						Image(systemName: "staroflife")
						Text("Journey")
				}
				.onAppear {
					self.viewStore.send(.employeesFilter(JourneyFilterAction.loadEmployees))
				}
				ClientsNavigationView(
					self.store.scope(
						state: { $0.clients },
						action: { .clients($0) })
				).tabItem {
						Image(systemName: "rectangle.stack.person.crop")
						Text(Texts.clients)
				}.onAppear {
					self.viewStore.send(.clients(ClientsAction.onAppearNavigationView))
				}
				Settings(store:
					store.scope(state: { $0.settings },
										 action: { .settings($0)}))
					.tabItem {
						Image(systemName: "gear")
						Text("Settings")
				}

                CommunicationView(store:
                                store.scope(state: { $0.communication },
                                            action: { .communication($0)}))
                    .tabItem {
                        Image(systemName: "ico-tab-tasks")
                        Text("Intercom")
                    }
			}
			.fullScreenCover(isPresented: .constant(self.viewStore.state.isShowingCheckin)) {
				IfLetStore(self.store.scope(
					state: { $0.journeyContainer.journey.checkIn },
					action: { .journey(.checkIn($0))}
				),
				then: CheckInNavigationView.init(store:))
			}
			.modalLink(isPresented: .constant(self.viewStore.state.isShowingCheckin),
					   linkType: ModalTransition.circleReveal,
					   destination: {
						IfLetStore(self.store.scope(
							state: { $0.journeyContainer.journey.checkIn },
							action: { .journey(.checkIn($0))}
						),
						then: CheckInNavigationView.init(store:))
					   })
			.fullScreenCover(isPresented: .constant(self.viewStore.state.isShowingAppointments)) {
				IfLetStore(self.store.scope(
					state: { $0.addAppointment },
					action: { .addAppointment($0)}
				),
				then: AddAppointment.init(store:))
			}
			if self.viewStore.state.isShowingEmployees {
				JourneyFilter(
					self.store.scope(state: { $0.journeyEmployeesFilter },
					action: { .employeesFilter($0)})
				).transition(.moveAndFade)
			}
		}
	}
}

public let tabBarReducer: Reducer<TabBarState, TabBarAction, TabBarEnvironment> = Reducer.combine(
	.init { state, action, _ in
		switch action {
		case .journey(.addAppointmentTap):
			state.addAppointment = AddAppointmentState.dummy
		default:
			break
		}
		return .none
	},
	journeyFilterReducer.pullback(
		state: \TabBarState.journeyEmployeesFilter,
		action: /TabBarAction.employeesFilter,
		environment: {
			return EmployeesFilterEnvironment(
				apiClient: $0.journeyAPI,
				userDefaults: $0.userDefaults)
	}),
	addAppointmentReducer.pullback(
		state: \TabBarState.addAppointment,
		action: /TabBarAction.addAppointment,
		environment: {
			return JourneyEnvironment(
				apiClient: $0.journeyAPI,
				userDefaults: $0.userDefaults)
		}),
	settingsReducer.pullback(
		state: \TabBarState.settings,
		action: /TabBarAction.settings,
		environment: { SettingsEnvironment($0) }
	),
	journeyContainerReducer.pullback(
		state: \TabBarState.journeyContainer,
		action: /TabBarAction.journey,
		environment: {
			return JourneyEnvironment(
				apiClient: $0.journeyAPI,
				userDefaults: $0.userDefaults)
	}),
	clientsContainerReducer.pullback(
		state: \TabBarState.clients,
		action: /TabBarAction.clients,
		environment: {
			return ClientsEnvironment(
				apiClient: $0.clientsAPI,
				userDefaults: $0.userDefaults)
	}),
	calendarContainerReducer.pullback(
		state: \TabBarState.calendarContainer,
		action: /TabBarAction.calendar,
		environment: {
			return CalendarEnvironment(
			apiClient: $0.journeyAPI,
			userDefaults: $0.userDefaults)
	}),
    communicationReducer.pullback(
        state: \TabBarState.communication,
        action: /TabBarAction.communication,
        environment: { CommunicationEnvironment($0) }
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
		self.appointments = .week([:])
		self.appsLoadingState = .initial
	}
}
