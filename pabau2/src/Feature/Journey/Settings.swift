import SwiftUI
import ComposableArchitecture
import Util
import Model

public typealias SettingsEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	userDefaults: UserDefaultsConfig
)

public func settingsReducer(state: inout SettingsState, action: SettingsAction, environment: SettingsEnvironment) -> [Effect<SettingsAction>] {
	switch action {
	case .logoutTapped:
		var userDefaults = environment.userDefaults
		userDefaults.loggedInUser = nil
		return []
	}
}

public struct SettingsState: Equatable {
	public init () {}
}

public enum SettingsAction {
	case logoutTapped
}

public struct Settings: View {
	let store: Store<SettingsState, SettingsAction>
	@ObservedObject var viewStore: ViewStore<SettingsState, SettingsAction>
	public init (store: Store<SettingsState, SettingsAction>) {
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
