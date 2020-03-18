import SwiftUI
import ComposableArchitecture
import CasePaths
import Model
import Util
import Journey

public typealias TabBarEnvironment = (loginAPI: LoginAPI, journeyAPI: JourneyAPI, userDefaults: UserDefaults)

public struct TabBarState {
	public var navigation: Navigation
	public var journeyState: JourneyState
}

extension TabBarState {
	var settings: SettingsState {
		get { SettingsState(navigation: self.navigation)}
		set { self.navigation = newValue.navigation }
	}
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
	var body: some View {
		TabView {
			JourneyNavigationView(self.store.view(value: { $0.journey },
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
				store.view(value: { $0.settings },
									 action: { .settings($0)}))
				.tabItem {
					Image(systemName: "gear")
					Text("Settings")
			}
		}
	}
}

public struct SettingsState {
	var navigation: Navigation
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
		state.navigation = .login([.signInScreen])
		return []
	}
}

public struct Settings: View {
	@ObservedObject var store: Store<SettingsState, SettingsAction>
	public var body: some View {
		VStack {
			BigButton(text: "Logout") {
				self.store.send(.logoutTapped)
			}
		}
	}
}
