import SwiftUI
import ComposableArchitecture
import Model
import Util
import Journey
import Clients
import Calendar

public typealias TabBarEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	userDefaults: UserDefaultsConfig
)

public struct TabBarState: Equatable {
	public var journey: JourneyState
	public var clients: ClientsState
	public var calendar: CalendarState
	public var settings: SettingsState
}

public enum TabBarAction {
	case settings(SettingsAction)
	case journey(JourneyContainerAction)
	case clients(ClientsAction)
}

struct PabauTabBar: View {
	let store: Store<TabBarState, TabBarAction>
	@ObservedObject var viewStore: ViewStore<ViewState, TabBarAction>
	struct ViewState: Equatable {
		let isShowingEmployees: Bool
		let isShowingCheckin: Bool
		let isShowingAppointments: Bool
		init(state: TabBarState) {
			self.isShowingEmployees = state.journey.employeesState.isShowingEmployees
			self.isShowingCheckin = state.journey.checkIn != nil
			self.isShowingAppointments = state.journey.addAppointment.isShowingAddAppointment
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
		ZStack(alignment: .topTrailing) {
			TabView {
				CalendarSwiftUI()
					.tabItem {
						Image(systemName: "calendar")
						Text("Calendar")
				}
				JourneyNavigationView(
					self.store.scope(
						state: { $0.journey },
						action: { .journey($0)})
				).tabItem {
						Image(systemName: "staroflife")
						Text("Journey")
				}
				.onAppear {
					self.viewStore.send(.journey(JourneyContainerAction.journey(JourneyAction.loadJourneys)))
					self.viewStore.send(.journey(JourneyContainerAction.employees(EmployeesAction.loadEmployees)))
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
			}.modalLink(isPresented: .constant(self.viewStore.state.isShowingCheckin),
								 linkType: ModalTransition.circleReveal,
								 destination: {
									IfLetStore(self.store.scope(
										state: { $0.journey.checkIn },
										action: { .journey(.checkIn($0))}
										),
														 then: CheckInNavigationView.init(store:))
			}).modalLink(isPresented: .constant(self.viewStore.state.isShowingAppointments),
									 linkType: ModalTransition.fullScreenModal,
									 destination: {
										AddAppointment(store:
											self.store.scope(state: { $0.journey.addAppointment },
																			 action: { .journey(.addAppointment($0))}))
			})
			if self.viewStore.state.isShowingEmployees {
				EmployeesListStore(
					self.store.scope(state: { $0.journey.employeesState } ,
					action: { .journey(.employees($0))})
				).transition(.moveAndFade)
			}
		}
	}
}

public let tabBarReducer: Reducer<TabBarState, TabBarAction, TabBarEnvironment> = Reducer.combine(
	settingsReducer.pullback(
		state: \TabBarState.settings,
		action: /TabBarAction.settings,
		environment: { SettingsEnvironment($0) }
	),
	journeyContainerReducer.pullback(
		state: \TabBarState.journey,
		action: /TabBarAction.journey,
		environment: {
			return JourneyEnvironment(
				apiClient: $0.journeyAPI,
				userDefaults: $0.userDefaults)
	})
	,
	clientsContainerReducer.pullback(
		state: \TabBarState.clients,
		action: /TabBarAction.clients,
		environment: {
			return ClientsEnvironment(
				apiClient: $0.clientsAPI,
				userDefaults: $0.userDefaults)
	})
)

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        AnyTransition.move(edge: .trailing)
    }
}
