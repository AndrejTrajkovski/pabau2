import SwiftUI
import ComposableArchitecture
import Util
import Model

public typealias SettingsEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	userDefaults: UserDefaultsConfig
)

public let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment> { _, action, env in
	switch action {
	case .logoutTapped:
		var userDefaults = env.userDefaults
		userDefaults.loggedInUser = nil
		return .none
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
