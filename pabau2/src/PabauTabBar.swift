import SwiftUI
import ComposableArchitecture
import Model
import Util
import Journey
import Clients
import Calendar
import EmployeesFilter
import JZCalendarWeekView

public typealias TabBarEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	userDefaults: UserDefaultsConfig
)

public struct TabBarState: Equatable {
	public var addAppointment: AddAppointmentState?
	public var journeyState: JourneyState
	public var clients: ClientsState
	public var calendar: CalendarState
	public var settings: SettingsState
	public var employeesFilter: EmployeesFilterState = EmployeesFilterState()
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
	case employeesFilter(EmployeesFilterAction)
	case addAppointment(AddAppointmentAction)
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
					self.viewStore.send(.journey(JourneyContainerAction.journey(JourneyAction.loadJourneys)))
					self.viewStore.send(.employeesFilter(EmployeesFilterAction.loadEmployees))
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
				EmployeesFilter(
					self.store.scope(state: { $0.employeesFilter } ,
					action: { .employeesFilter($0)})
				).transition(.moveAndFade)
			}
		}
	}
}

public let tabBarReducer: Reducer<TabBarState, TabBarAction, TabBarEnvironment> = Reducer.combine(
	.init { state, action, env in
		switch action {
		case .journey(.addAppointmentTap):
			state.addAppointment = AddAppointmentState.dummy
		case .calendar(.employee(.addAppointment(let startDate, let durationMins, let dropKeys))):
			let (date, location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let employee = state.calendar.employees[location]?[id: subsection]
			employee.map {
				state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate, employee: $0)
			}
		case .calendar(.room(.addAppointment(let startDate, let durationMins, let dropKeys))):
			let (date, location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let room = state.calendar.rooms[location]?[id: subsection]
			//FIXME: missing room in add appointments screen
			state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate)
		case .calendar(.week(.addAppointment(let startOfDayDate, let startDate,let durationMins))):
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate)
		case .calendar(.appDetails(.addService)):
			let start = state.calendar.appDetails!.app.start_date
			let end = state.calendar.appDetails!.app.end_date
			let employee = state.calendar.employees.flatMap { $0.value }.first(where: { $0.id == state.calendar.appDetails?.app.employeeId })
			state.calendar.appDetails = nil
			employee.map {
				state.addAppointment = AddAppointmentState.init(startDate: start, endDate: end, employee: $0)
			}
		default: break
		}
		return .none
	},
	employeeFilterReducer.pullback(
		state: \TabBarState.employeesFilter,
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
		state: \TabBarState.calendar,
		action: /TabBarAction.calendar,
		environment: {
			return CalendarEnvironment(
			apiClient: $0.journeyAPI,
			userDefaults: $0.userDefaults)
	})
)

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        AnyTransition.move(edge: .trailing)
    }
}
