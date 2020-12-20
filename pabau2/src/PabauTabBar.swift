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

public struct TabBarState: Equatable {
	public var addAppointment: AddAppointmentState?
	public var journeyState: JourneyState
	public var clients: ClientsState
	public var calendar: CalendarState
	public var settings: SettingsState
    public var communication: CommunicationState
	public var employeesFilter: JourneyFilterState = JourneyFilterState()

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
			JourneyContainerState(journey: journeyState,
								  employeesFilter: employeesFilter)
		}
		set {
			self.journeyState = newValue.journey
			self.employeesFilter = newValue.employeesFilter
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
			self.isShowingEmployees = state.employeesFilter.isShowingEmployees
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
				calendar()
				journey()
				clients()
				settings()
				communication()
			}
//			.fullScreenCover(isPresented: .constant(self.viewStore.state.isShowingCheckin)) {
//				checkIn()
//			}
			.modalLink(isPresented: .constant(self.viewStore.state.isShowingCheckin),
					   linkType: ModalTransition.circleReveal,
					   destination: {
						checkIn()
					   }
			)
			.fullScreenCover(isPresented: .constant(self.viewStore.state.isShowingAppointments)) {
				addAppointment()
			}
			if self.viewStore.state.isShowingEmployees {
				journeyFilter()
			}
		}
	}

	fileprivate func journey() -> some View {
		return JourneyNavigationView(
			self.store.scope(
				state: { $0.journeyContainer },
				action: { .journey($0)})
		).tabItem {
			Image(systemName: "staroflife")
			Text("Journey")
		}
		.onAppear {
			self.viewStore.send(.journey(JourneyContainerAction.journey(JourneyAction.loadJourneys)))
			self.viewStore.send(.employeesFilter(JourneyFilterAction.loadEmployees))
		}
	}

	fileprivate func calendar() -> some View {
		return CalendarContainer(store:
									self.store.scope(
										state: { $0.calendar },
										action: { .calendar($0)}
									)
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
			state: { $0.journeyContainer.journey.checkIn },
			action: { .journey(.checkIn($0))}
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

	fileprivate func journeyFilter() -> some View {
		return JourneyFilter(
			self.store.scope(state: { $0.employeesFilter },
							 action: { .employeesFilter($0)})
		).transition(.moveAndFade)
	}

}

let tabBarReducer: Reducer<TabBarState, TabBarAction, AppEnvironment> = Reducer.combine(
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
		state: \TabBarState.employeesFilter,
		action: /TabBarAction.employeesFilter,
		environment: {
			return EmployeesFilterEnvironment(
				appointmentsAPI: $0.appointmentsAPI,
				userDefaults: $0.userDefaults)
	}),
	addAppointmentReducer.pullback(
		state: \TabBarState.addAppointment,
		action: /TabBarAction.addAppointment,
		environment: {
			AddAppointmentEnv(appointmentsAPI: $0.appointmentsAPI,
							  userDefaults: $0.userDefaults)
		}
	),
	settingsReducer.pullback(
		state: \TabBarState.settings,
		action: /TabBarAction.settings,
		environment: { SettingsEnvironment($0) }
	),
	journeyContainerReducer.pullback(
		state: \TabBarState.journeyContainer,
		action: /TabBarAction.journey,
		environment: makeJourneyEnv(_:)
	),
	clientsContainerReducer.pullback(
		state: \TabBarState.clients,
		action: /TabBarAction.clients,
		environment: makeClientsEnv(_:)
	),
	calendarContainerReducer.pullback(
		state: \TabBarState.calendarContainer,
		action: /TabBarAction.calendar,
		environment: {
			return CalendarEnvironment(
			apiClient: $0.appointmentsAPI,
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
		self.journeyState = JourneyState()
		self.clients = ClientsState()
		self.calendar = CalendarState()
		self.settings = SettingsState()
		self.communication = CommunicationState()
	}
}
