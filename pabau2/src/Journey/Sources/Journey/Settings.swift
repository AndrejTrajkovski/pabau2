import SwiftUI
import ComposableArchitecture
import Util
import Model
import TextLog

public typealias SettingsEnvironment = (
	loginAPI: LoginAPI,
	clientsAPI: ClientsAPI,
	formAPI: FormAPI,
	userDefaults: UserDefaultsConfig
)

public let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment> { state, action, env in
	switch action {
	case .logoutTapped:
		var userDefaults = env.userDefaults
		userDefaults.loggedInUser = nil
		return .none
    case .reportProblem:
        do {
            let log = try TextLog.retrieveLogFile()
            state.reportProblemLog = log
        } catch {
            print(error)
        }
        return .none
	}
}

public struct SettingsState: Equatable {
	public init () {}
    var reportProblemLog: Data? = nil
}

public enum SettingsAction {
	case logoutTapped
    case reportProblem
}

public struct Settings: View {
	let store: Store<SettingsState, SettingsAction>
	@ObservedObject var viewStore: ViewStore<SettingsState, SettingsAction>
	public init (store: Store<SettingsState, SettingsAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	public var body: some View {
		VStack {
			PrimaryButton(Texts.logout) {
				self.viewStore.send(.logoutTapped)
			}.frame(minWidth: 304, maxWidth: 495)
            PrimaryButton(Texts.reportProblem) {
                self.viewStore.send(.reportProblem)
            }.frame(minWidth: 304, maxWidth: 495)
            if viewStore.state.reportProblemLog != nil {
                MailView(isShowing: .constant(viewStore.state.reportProblemLog != nil),
                         result: .constant(nil),
                         file: viewStore.state.reportProblemLog!)
            }
		}
	}
}
