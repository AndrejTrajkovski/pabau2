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
	public var journey: JourneyState
	public var settings: SettingsState
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
			self.isShowingCheckin = state.journey.isCheckedIn
			self.isShowingAppointments = state.journey.addAppointment.isShowingAddAppointment
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
									CheckInNavigationView(store:
										self.store.scope(
											value: { $0.journey.checkIn },
											action: { .journey(.checkIn($0))})
									)
			}).modalLink(isPresented: .constant(self.viewStore.value.isShowingAppointments),
									 linkType: ModalTransition.fullScreenModal,
									 destination: {
										AddAppointment(store:
											self.store.scope(value: { $0.journey.addAppointment },
																			 action: { .journey(.addAppointment($0))}))
			})
			if self.viewStore.value.isShowingEmployees {
				EmployeesListStore(
					self.store.scope(value: { $0.journey.employeesState } ,
					action: { .journey(.employees($0))})
				).transition(.moveAndFade)
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
