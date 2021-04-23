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
import Overture

typealias AppEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	formAPI: FormAPI,
	userDefaults: UserDefaultsConfig,
    storage: CoreDataStorage
)

func makeJourneyEnv(_ appEnv: AppEnvironment) -> JourneyEnvironment {
	return JourneyEnvironment(
		formAPI: appEnv.formAPI,
		journeyAPI: appEnv.journeyAPI,
		clientsAPI: appEnv.clientsAPI,
		userDefaults: appEnv.userDefaults
	)
}

func makeClientsEnv(_ appEnv: AppEnvironment) -> ClientsEnvironment {
	return ClientsEnvironment(
		apiClient: appEnv.clientsAPI,
		formAPI: appEnv.formAPI,
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
		environment: {
			TabBarEnvironment(
				loginAPI: $0.loginAPI,
				journeyAPI: $0.journeyAPI,
				clientsAPI: $0.clientsAPI,
				formAPI: $0.formAPI,
				userDefaults: $0.userDefaults,
                storage: $0.storage
              )
			}
	),
	.init { state, action, env in
		switch action {
		case .tabBar(.settings(.logoutTapped)):
			state = .walkthrough(
				WalkthroughContainerState(hasSeenWalkthrough: env.userDefaults.hasSeenAppIntroduction)
			)
		case .walkthrough(.login(.login(.gotResponse(.success(let user))))):
			state = .tabBar(TabBarState())
			
			return .concatenate( // one after another
				// .merge( // in parallel
				env.journeyAPI.getLocations()
					.receive(on: DispatchQueue.main)
					.catchToEffect()
					.map { AppAction.tabBar(.gotLocationsResponse($0))}
					.eraseToEffect(),

				env.journeyAPI.getEmployees()
					.receive(on: DispatchQueue.main)
					.catchToEffect()
					.map { AppAction.tabBar(.journey(.employeesFilter(.gotResponse($0))))}
					.eraseToEffect()
			)
		default:
			break
		}
		return .none
	}
)

struct ContentView: View {
	let store: Store<AppState, AppAction>
	var body: some View {
		IfLetStore(self.store.scope(
					state: with(AppState.tabBar, curry(extract(case:from:))),
					action: { .tabBar($0)}),
				   then: PabauTabBar.init(store:)
		)
		IfLetStore(
			self.store.scope(
				state: with(AppState.walkthrough, curry(extract(case:from:))),
				action: { .walkthrough($0) }
			),
			then: LoginContainer.init(store:)
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
	}

	var body: some View {
		NavigationView {
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
		if loggedInUser == nil {
			self = .walkthrough(WalkthroughContainerState(hasSeenWalkthrough: hasSeenWalkthrough))
		} else {
			self = .tabBar(TabBarState())
		}
	}
}
