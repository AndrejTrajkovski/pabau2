import Combine
import ComposableArchitecture
import SwiftUI
import Login
import Model
import Journey
import Util
import Clients
import Calendar

typealias AppEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	userDefaults: UserDefaultsConfig
)

enum AppState: Equatable {
	case walkthrough(WalkthroughContainerState)
	case tabBar(TabBarState)
	public init (user: User?,
							 hasSeenWalkthrough: Bool) {
		if let user = user {
			self = .tabBar(
				TabBarState(
					journeyState: JourneyState(),
					clients: ClientsState(),
					calendar: CalendarState(calType: .week),
					settings: SettingsState()
				)
			)
		} else {
			let screens: [LoginNavScreen] = hasSeenWalkthrough ? [.signInScreen] : [.walkthroughScreen]
			self = .walkthrough(
				WalkthroughContainerState(
					navigation: screens,
					loginViewState: LoginViewState()
				)
			)
		}
	}
}

enum AppAction {
	case walkthrough(WalkthroughContainerAction)
	case tabBar(TabBarAction)
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
	walkthroughContainerReducer.pullbackCp(
		state: /AppState.walkthrough,
		action: /AppAction.walkthrough,
		environment: { LoginEnvironment($0.loginAPI, $0.userDefaults) }
	),
	tabBarReducer.pullbackCp(
		state: /AppState.tabBar,
		action: /AppAction.tabBar,
		environment: { TabBarEnvironment($0) }
	),
	globalReducer
)

struct ContentView: View {
	let store: Store<AppState, AppAction>
	@ObservedObject var viewStore: ViewStore<State, AppAction>
	struct State: Equatable {
		var shouldShowLogin: Bool
		init (_ appState: AppState) {
			switch appState {
			case .walkthrough:
				self.shouldShowLogin = true
			default:
				self.shouldShowLogin = false
			}
		}
	}
	init(store: Store<AppState, AppAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(state: State.init,
						 action: { $0 }))
		print("ContentView init")
	}
	var body: some View {
		print("ContentView body")
		return ViewBuilder.buildBlock(
			(self.viewStore.state.shouldShowLogin) ?
				ViewBuilder.buildEither(second: LoginContainer(store: loginContainerStore))
				:
				ViewBuilder.buildEither(first: PabauTabBar(store: tabBarStore))
		)
	}

	var loginContainerStore: Store<WalkthroughContainerState, WalkthroughContainerAction> {
		return self.store.scope(
			state: { extract(case: AppState.walkthrough, from: $0) ?? WalkthroughContainerState(navigation: [.signInScreen],
																																													loginViewState: LoginViewState()) },
			action: { .walkthrough($0)}
		)
	}

	var tabBarStore: Store<TabBarState, TabBarAction> {
		return self.store.scope(
			state: {
				extract(case: AppState.tabBar, from: $0) ??
					TabBarState(journeyState: JourneyState(),
											clients: ClientsState(),
											calendar: CalendarState(calType: .week),
											settings: SettingsState())
		},
			action: { .tabBar($0)}
		)
	}
}

struct LoginContainer: View {
	let store: Store<WalkthroughContainerState, WalkthroughContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, WalkthroughContainerAction>
	struct ViewState: Equatable {
		let shouldShowWalkthrough: Bool
		init (state: WalkthroughContainerState) {
			self.shouldShowWalkthrough = state.navigation.contains(.walkthroughScreen)
		}
	}
	public init (store: Store<WalkthroughContainerState, WalkthroughContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(state: ViewState.init(state:),
						 action: { $0 }))
		print("LoginContainer init")
	}

	var body: some View {
		print("LoginContainer body")
		return NavigationView {
			ViewBuilder.buildBlock(
				viewStore.state.shouldShowWalkthrough ?
					ViewBuilder.buildEither(first: WalkthroughContainer(store))
					:
					ViewBuilder.buildEither(second:
						LoginView(store:
							self.store.scope(state: { $0 },
															action: { .login($0)})
					))
			)
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}

let globalReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
	if case let AppAction.tabBar(tabBar) = action,
		case let TabBarAction.settings(settings) = tabBar,
		case SettingsAction.logoutTapped = settings {
		state = AppState(user: nil, hasSeenWalkthrough: environment.userDefaults.hasSeenAppIntroduction)
		return .none
	} else {
		let user = extract(case: { (value: User) -> (AppAction) in
			AppAction.walkthrough(WalkthroughContainerAction.login(LoginViewAction.login(LoginAction.gotResponse(Result.success(value)))))
		}, from: action)
		if let user = user {
			var journeyState = JourneyState()
			journeyState.loadingState = .loading
			state = AppState(user: user, hasSeenWalkthrough: environment.userDefaults.hasSeenAppIntroduction)
			return .none
		}
	}
	return .none
}
