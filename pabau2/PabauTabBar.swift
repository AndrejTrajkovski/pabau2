import SwiftUI
import ComposableArchitecture
import CasePaths
import Model
import Util

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
			Text("Journey")
				.tabItem {
					Text("Journey")
			}
			Text("Calendar")
				.tabItem {
					Text("Calendar")
			}
			Settings(store:
				store.view(value: { $0.settings },
									 action: { .settings($0)}))
				.tabItem {
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

public let tabBarReducer = (pullback(settingsReducer, value: \TabBarState.settings, action: /TabBarAction.settings))

public func settingsReducer(state: inout SettingsState, action: SettingsAction) -> [Effect<SettingsAction>] {
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
