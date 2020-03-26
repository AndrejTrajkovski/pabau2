import Combine
import ComposableArchitecture
import SwiftUI
import CasePaths
import Login
import Model
import Journey

typealias AppEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	userDefaults: UserDefaults
)

struct AppState: Equatable {
	var loggedInUser: User?
	var navigation: Navigation
	var loginViewState: LoginViewState = LoginViewState()
	var journeyState: JourneyState = JourneyState()
}

enum AppAction {
	case walkthrough(WalkthroughContainerAction)
	case tabBar(TabBarAction)
}

extension AppState {
	var tabBar: TabBarState {
		get { TabBarState(navigation: self.navigation,
											journeyState: self.journeyState) }
		set {
			self.navigation = newValue.navigation
			self.journeyState = newValue.journeyState
		}
	}
	var walktrough: WalkthroughContainerState {
		get {
			return WalkthroughContainerState(navigation: self.navigation,
																			 loggedInUser: loggedInUser,
																			 loginViewState: self.loginViewState)
		}
		set {
			self.navigation = newValue.navigation
			self.loggedInUser = newValue.loggedInUser
			self.loginViewState = newValue.loginViewState
		}
	}
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
	pullback(
		walkthroughContainerReducer,
		value: \AppState.walktrough,
		action: /AppAction.walkthrough,
		environment: { LoginEnvironment($0.loginAPI, $0.userDefaults) }
	),
	pullback(
		tabBarReducer,
		value: \AppState.tabBar,
		action: /AppAction.tabBar,
		environment: { TabBarEnvironment($0) }
	),
	globalReducer
)

struct ContentView: View {
	let store: Store<AppState, AppAction>
	@ObservedObject var viewStore: ViewStore<AppState>
	init (store: Store<AppState, AppAction>) {
		self.store = store
		self.viewStore = self.store.view
	}
	var body: some View {
		ViewBuilder.buildBlock(
			(self.viewStore.value.navigation.login != nil) ?
				ViewBuilder.buildEither(second: LoginContainer(store: loginContainerStore))
				:
				ViewBuilder.buildEither(first: PabauTabBar(store: tabBarStore))
		)
	}

	var loginContainerStore: Store<WalkthroughContainerState, WalkthroughContainerAction> {
		return self.store.scope(
			value: { $0.walktrough },
			action: { .walkthrough($0)}
		)
	}

	var tabBarStore: Store<TabBarState, TabBarAction> {
		return self.store.scope(
			value: { $0.tabBar },
			action: { .tabBar($0)}
		)
	}
}

struct LoginContainer: View {
	let store: Store<WalkthroughContainerState, WalkthroughContainerAction>
	@ObservedObject var viewStore: ViewStore<WalkthroughContainerState>

	public init (store: Store<WalkthroughContainerState, WalkthroughContainerAction>) {
		self.store = store
		self.viewStore = self.store.view
	}

	var shouldShowWalkthrough: Bool {
		return self.viewStore.value.navigation.login?.contains(.walkthroughScreen) ?? false
	}

	var body: some View {
		NavigationView {
			ViewBuilder.buildBlock(
				shouldShowWalkthrough ?
					ViewBuilder.buildEither(first: WalkthroughContainer(store))
					:
					ViewBuilder.buildEither(second:
						LoginView(store:
							self.store.scope(value: { $0 },
															action: { .login($0)})
					))
			)
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}

func globalReducer(state: inout AppState, action: AppAction, environment: AppEnvironment) -> [Effect<AppAction>] {
	let user = extract(case: { (value: User) -> (AppAction) in
	AppAction.walkthrough(WalkthroughContainerAction.login(LoginViewAction.login(LoginAction.gotResponse(Result.success(value)))))
	}, from: action)
	if user != nil {
		state.journeyState.loadingState = .loading
		return [
			environment.journeyAPI.getJourneys(date: Date())
				.map {
					AppAction.tabBar(TabBarAction.journey(JourneyContainerAction.journey(.gotResponse($0))))
			}
			.eraseToEffect(),
			environment.journeyAPI.getEmployees()
				.map { AppAction.tabBar(TabBarAction.journey(JourneyContainerAction.employees(EmployeesAction.gotResponse($0))))}
			.eraseToEffect()
		]
	} else {
		return []
	}
}
