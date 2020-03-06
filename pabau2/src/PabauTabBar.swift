import SwiftUI
import ComposableArchitecture
import CasePaths
import Model
import Util
import Journey

public typealias TabBarEnvironment = (apiClient: APIClient, userDefaults: UserDefaults)

public struct TabBarState {
	public var navigation: Navigation
}

extension TabBarState {
	var settings: SettingsState {
		get { SettingsState(navigation: self.navigation)}
		set { self.navigation = newValue.navigation }
	}
}

public enum TabBarAction {
	case settings(SettingsAction)
}

struct PabauTabBar: View {
	let store: Store<TabBarState, TabBarAction>
	var body: some View {
		TabView {
			JourneyNavigationView()
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

public let tabBarReducer = (pullback(settingsReducer, value: \TabBarState.settings, action: /TabBarAction.settings, environment: { $0 }))

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
