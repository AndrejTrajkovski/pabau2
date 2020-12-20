import Combine
import ComposableArchitecture
import SwiftUI
import Login
import Model
import Journey
import Util
import Clients
import Calendar
import Communication

typealias AppEnvironment = (
	loginAPI: LoginAPI,
	appointmentsAPI: AppointmentsAPI,
	clientsAPI: ClientsAPI,
	formAPI: FormAPI,
	userDefaults: UserDefaultsConfig
)

func makeJourneyEnv(_ appEnv: AppEnvironment) -> JourneyEnvironment {
	return JourneyEnvironment(
		appointmentsAPI: appEnv.appointmentsAPI,
		formAPI: appEnv.formAPI,
		userDefaults: appEnv.userDefaults
	)
}

func makeClientsEnv(_ appEnv: AppEnvironment) -> ClientsEnvironment {
	return ClientsEnvironment(
		apiClient: appEnv.clientsAPI,
		userDefaults: appEnv.userDefaults
	)
}

enum AppState: Equatable {
	case walkthrough(WalkthroughContainerState)
	case tabBar(TabBarState)
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
		environment: { $0 }
	),
	.init { state, action, env in
		switch action {
		case .tabBar(.settings(.logoutTapped)):
			state = .walkthrough(
				WalkthroughContainerState(hasSeenWalkthrough: env.userDefaults.hasSeenAppIntroduction)
			)
		case .walkthrough(.login(.login(.gotResponse(.success(let user))))):
			var journeyState = JourneyState()
			journeyState.loadingState = .loading
			state = .tabBar(TabBarState())
		default:
			break
		}
		return .none
	}
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
                                calendar: CalendarState(),
                                settings: SettingsState(),
                                communication: CommunicationState())
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

extension AppState {
	init(loggedInUser: User?, hasSeenWalkthrough: Bool) {
		if loggedInUser != nil {
			self = .tabBar(TabBarState())
		} else {
			self = .walkthrough(WalkthroughContainerState(hasSeenWalkthrough: hasSeenWalkthrough))
		}
	}
}
