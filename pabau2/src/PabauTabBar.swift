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
import CoreDataModel

public typealias TabBarEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	formAPI: FormAPI,
	userDefaults: UserDefaultsConfig,
    storage: CoreDataModel
)

public struct TabBarState: Equatable {
	var appsLoadingState: LoadingState
	var journey: ListState
	var clients: ClientsState
	var calendar: CalendarState
	var settings: SettingsState
    var communication: CommunicationState
	var addAppointment: AddAppointmentState?
}

public enum TabBarAction {
	case settings(SettingsAction)
	case journey(JourneyContainerAction)
	case clients(ClientsAction)
	case calendar(CalendarAction)
	case addAppointment(AddAppointmentAction)
    case communication(CommunicationAction)
	case gotLocationsResponse(Result<[Location], RequestError>)
	case gotEmployeesResponse(Result<[Employee], RequestError>)
}

struct PabauTabBar: View {
	let store: Store<TabBarState, TabBarAction>
	@ObservedObject var viewStore: ViewStore<ViewState, TabBarAction>
	struct ViewState: Equatable {
		let isShowingCheckin: Bool
		let isShowingAddAppointment: Bool
		init(state: TabBarState) {
//			self.isShowingCheckin = false state.journeyContainer?.journey.checkIn != nil
//			self.isShowingAddAppointment = state.addAppointment != nil
			self.isShowingCheckin = false
			self.isShowingAddAppointment = false
		}
	}
	
	init (store: Store<TabBarState, TabBarAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: ViewState.init(state:),
											   action: { $0 }))
	}

	var body: some View {
		TabView {
			calendar()
			clients()
			settings()
			communication()
		}
//		.modalLink(isPresented: .constant(self.viewStore.state.isShowingCheckin),
//				   linkType: ModalTransition.circleReveal,
//				   destination: {
//					checkIn()
//				   }
//		)
		.fullScreenCover(isPresented: .constant(self.viewStore.state.isShowingAddAppointment)) {
			addAppointment()
		}
	}
	
	fileprivate func calendar() -> some View {
		CalendarContainer(store:
							store.scope(state: { $0.calendar },
										action: { .calendar($0) }
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

//	fileprivate func checkIn() -> IfLetStore<CheckInContainerState, CheckInContainerAction, CheckInNavigationView?> {
//		return IfLetStore(self.store.scope(
//			state: { $0.journeyContainer?.journey.checkIn },
//			action: { .journey(.journey(.checkIn($0))) }
//		),
//		then: CheckInNavigationView.init(store:))
//	}

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
		case .gotLocationsResponse(let result):
			switch result {
			case .success(let locations):
				state.calendar.locations = .init(locations)
			case .failure(let error):
				break
			}
		case .gotEmployeesResponse(let result):
			switch result {
			case .success(let employees):
				state.calendar.employees = [:]
				state.calendar.locations.forEach { location in
					state.calendar.employees[location.id] = IdentifiedArrayOf<Employee>.init([])
				}
				state.calendar.employees.keys.forEach { key in
					employees.forEach { employee in
						if employee.locations.contains(key) {
							state.calendar.employees[key]?.append(employee)
						}
					}
				}
				
			case .failure(let error):
				break
			}
		case .calendar(.addAppointmentTap):
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
            return AddAppointmentEnv(
                journeyAPI: $0.journeyAPI,
                clientAPI: $0.clientsAPI,
                userDefaults: $0.userDefaults,
                storage: $0.storage
            )
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
//	journeyContainerReducer.optional().pullback(
//		state: \TabBarState.journeyContainer,
//		action: /TabBarAction.journey,
//		environment: makeJourneyEnv(_:)
//	),
	showAddAppointmentReducer.pullback(
		state: \TabBarState.self,
		action: /TabBarAction.calendar,
		environment: makeClientsEnv(_:)
	),
	clientsContainerReducer.pullback(
		state: \TabBarState.clients,
		action: /TabBarAction.clients,
		environment: makeClientsEnv(_:)
	),
	calendarContainerReducer.pullback(
		state: \TabBarState.calendar,
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

public let showAddAppointmentReducer: Reducer<TabBarState, CalendarAction, Any> = .init { state, action, env in
	switch action {
	case .employee(.addAppointment(let startDate, let durationMins, let dropKeys)):
		let (location, subsection) = dropKeys
		let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
		let employee = state.calendar.employees[location]?[id: subsection]
		employee.map {
			state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate, employee: $0)
		}
	case .room(.addAppointment(let startDate, let durationMins, let dropKeys)):
		let (location, subsection) = dropKeys
		let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
		let room = state.calendar.rooms[location]?[id: subsection]
		//FIXME: missing room in add appointments screen
		state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate)
		
	case .week(.addAppointment(let startOfDayDate, let startDate, let durationMins)):
		let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
		state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate)
	case .showAddApp(let start, let end, let employee):
		
		state.addAppointment = AddAppointmentState.init(
			startDate: start,
			endDate: end,
			employee: employee
		)
	case .week(.editAppointment(let appointment)):
		print(appointment)
		state.addAppointment = AddAppointmentState.init(editingAppointment: appointment, startDate: appointment.start_date, endDate: appointment.end_date)
	default:
		break
	}
	return .none
}

extension TabBarState {
	public init() {
		self.journey = ListState()
		self.clients = ClientsState()
		self.calendar = CalendarState()
		self.settings = SettingsState()
		self.communication = CommunicationState()
		self.appsLoadingState = .initial
	}
}
