import SwiftUI
import ComposableArchitecture
import CasePaths
import Model
import Util
import Journey

public typealias TabBarEnvironment = (loginAPI: LoginAPI, journeyAPI: JourneyAPI, userDefaults: UserDefaultsConfig)

public struct TabBarState: Equatable {
//	public var navigation: Navigation
	public var journeyState: JourneyState
	var settings: SettingsState
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
		init(state: TabBarState) {
			self.isShowingEmployees = state.journey.employeesState.isShowingEmployees
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
			}
			EmployeesListStore(self.store.scope(value: { $0.journey.employeesState } ,
																				 action: { .journey(.employees($0))}))
				.isHidden(!self.viewStore.value.isShowingEmployees, remove: true)
				.frame(width: 302)
				.background(Color.white.shadow(color: .employeeShadow, radius: 40.0, x: -20, y: 2))
		}
	}
}

public struct SettingsState: Equatable {
	
}

public enum SettingsAction {
	case logoutTapped
}

public let tabBarReducer = combine(
	pullback(settingsReducer,
					 value: \TabBarState.settings,
					 action: /TabBarAction.settings,
					 environment: { $0 }),
	pullback(journeyContainerReducer,
					 value: \TabBarState.journey,
					 action: /TabBarAction.journey,
					 environment: {
						return JourneyEnvironemnt(
							apiClient: $0.journeyAPI,
							userDefaults: $0.userDefaults)
	})
)

public func settingsReducer(state: inout SettingsState, action: SettingsAction, environment: TabBarEnvironment) -> [Effect<SettingsAction>] {
	switch action {
	case .logoutTapped:
		//TODO: 
		return []
	}
}

public struct Settings: View {
	let store: Store<SettingsState, SettingsAction>
	@ObservedObject var viewStore: ViewStore<SettingsState, SettingsAction>
	init (store: Store<SettingsState, SettingsAction>) {
		self.store = store
		self.viewStore = self.store.view
	}
	public var body: some View {
		VStack {
			BigButton(text: "Logout") {
				self.viewStore.send(.logoutTapped)
			}
		}
	}
}
