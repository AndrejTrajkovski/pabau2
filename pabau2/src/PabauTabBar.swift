import SwiftUI
import ComposableArchitecture
import CasePaths
import Model
import Util
import Journey

public typealias TabBarEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	userDefaults: UserDefaultsConfig
)

public struct TabBarState: Equatable {
	public var journeyState: JourneyState
	public var settings: SettingsState
}

extension TabBarState {
	
	var journey: JourneyState {
		get {
			return self.journeyState
		}
		set {
			self.journeyState = newValue
		}
	}
}

public enum TabBarAction {
	case settings(SettingsAction)
	case journey(JourneyContainerAction)
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
			self.isShowingCheckin = state.journeyState.isJourneyModalShown
			self.isShowingAppointments = state.journeyState.addAppointment.isShowingAddAppointment
		}
	}
	init (store: Store<TabBarState, TabBarAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: ViewState.init(state:),
						 action: { $0 })
			.view
		print("PabauTabBar init")
	}
	var body: some View {
		print("PabauTabBar body")
		return ZStack(alignment: .topTrailing) {
			TabView {
				JourneyNavigationView(self.store.scope(value: { $0.journey },
																							action: { .journey($0)}))
					.tabItem {
						Image(systemName: "staroflife")
						Text("Journey")
				}
				.onAppear {
					self.viewStore.send(.journey(JourneyContainerAction.journey(JourneyAction.loadJourneys)))
					self.viewStore.send(.journey(JourneyContainerAction.employees(EmployeesAction.loadEmployees)))
				}
				Text("Calendar")
					.tabItem {
						Image(systemName: "calendar")
						Text("Calendar")
				}
				Settings(store:
					store.scope(value: { $0.settings },
										 action: { .settings($0)}))
					.tabItem {
						Image(systemName: "gear")
						Text("Settings")
				}
			}.modalLink(isPresented: .constant(self.viewStore.value.isShowingCheckin),
								 linkType: ModalTransition.circleReveal,
								 destination: {
									CheckIn()
			}).modalLink(isPresented: .constant(self.viewStore.value.isShowingAppointments),
									 linkType: ModalTransition.fullScreenModal,
									 destination: {
										AddAppointment.init(store:
											self.store.scope(value: { $0.journeyState.addAppointment },
																			 action: { .journey(.addAppointment($0))}))
			})
			if self.viewStore.value.isShowingEmployees {
				EmployeesListStore(self.store.scope(value: { $0.journey.employeesState } ,
																					action: { .journey(.employees($0))}))
				.transition(.moveAndFade)
			}
		}
	}
}

public let tabBarReducer = combine(
	pullback(settingsReducer,
					 value: \TabBarState.settings,
					 action: /TabBarAction.settings,
					 environment: { SettingsEnvironment($0) }
	),
	pullback(journeyContainerReducer,
					 value: \TabBarState.journey,
					 action: /TabBarAction.journey,
					 environment: {
						return JourneyEnvironemnt(
							apiClient: $0.journeyAPI,
							userDefaults: $0.userDefaults)
	})
)

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        AnyTransition.move(edge: .trailing)
    }
}
