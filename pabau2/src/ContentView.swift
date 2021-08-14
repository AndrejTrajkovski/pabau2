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
import CoreDataModel

typealias AppEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	formAPI: FormAPI,
	userDefaults: UserDefaultsConfig,
    repository: Repository,
	audioPlayer: AudioPlayerProtocol,
    debug: DebugEnvironment
)

func makeTabBarEnv(_ appEnv: AppEnvironment) -> TabBarEnvironment {
    TabBarEnvironment(
        loginAPI: appEnv.loginAPI,
        journeyAPI: appEnv.journeyAPI,
        clientsAPI: appEnv.clientsAPI,
        formAPI: appEnv.formAPI,
        userDefaults: appEnv.userDefaults,
        repository: appEnv.repository,
        audioPlayer: appEnv.audioPlayer
    )
}

func makeJourneyEnv(_ appEnv: TabBarEnvironment) -> JourneyEnvironment {
	return JourneyEnvironment(
		formAPI: appEnv.formAPI,
		journeyAPI: appEnv.journeyAPI,
		clientsAPI: appEnv.clientsAPI,
		userDefaults: appEnv.userDefaults,
        repository: appEnv.repository,
		audioPlayer: appEnv.audioPlayer
	)
}

func makeClientsEnv(appEnv: TabBarEnvironment) -> ClientsEnvironment {
	return ClientsEnvironment(
		apiClient: appEnv.clientsAPI,
		formAPI: appEnv.formAPI,
		userDefaults: appEnv.userDefaults,
        repository: appEnv.repository
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
	walkthroughContainerReducer.pullback(
		state: /AppState.walkthrough,
		action: /AppAction.walkthrough,
		environment: { LoginEnvironment($0.loginAPI, $0.userDefaults) }
	),
	tabBarReducer.pullback(
		state: /AppState.tabBar,
		action: /AppAction.tabBar,
		environment: makeTabBarEnv(_:)
	),
	.init { state, action, env in
		switch action {
		case .tabBar(.settings(.logoutTapped)):
			state = .walkthrough(
				WalkthroughContainerState(hasSeenWalkthrough: env.userDefaults.hasSeenAppIntroduction)
			)
			return env.repository.coreDataModel.removeAll().fireAndForget()
		case .walkthrough(.login(.login(.gotResponse(.success(let user))))):
			state = .tabBar(TabBarState())
			return	 .merge( // in parallel
				env.repository.getLocations()
					.receive(on: DispatchQueue.main)
					.catchToEffect()
					.map { AppAction.tabBar(.calendar(.gotLocationsResponse($0)))}
					.eraseToEffect(),
				
				env.journeyAPI.getEmployees()
					.receive(on: DispatchQueue.main)
					.catchToEffect()
					.map { AppAction.tabBar(.calendar(.employeeFilters(.gotSubsectionResponse($0))))}
					.eraseToEffect(),
				
				env.journeyAPI.getRooms()
					.receive(on: DispatchQueue.main)
					.catchToEffect()
					.map { AppAction.tabBar(.calendar(.roomFilters(.gotSubsectionResponse($0))))}
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
        SwitchStore(store) {
            CaseLet(state: /AppState.tabBar, action: AppAction.tabBar, then: PabauTabBar.init(store:))
            CaseLet(state: /AppState.walkthrough, action: AppAction.walkthrough, then: LoginContainer.init(store:))
        }
	}
}

struct LoginContainer: View {
	let store: Store<WalkthroughContainerState, WalkthroughContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, WalkthroughContainerAction>

	struct ViewState: Equatable {
		let isLoginActive: Bool
		init (state: WalkthroughContainerState) {
			self.isLoginActive = state.navigation.contains(.signInScreen)
		}
	}
  
    public init (store: Store<WalkthroughContainerState, WalkthroughContainerAction>) {
        self.store = store
        self.viewStore = ViewStore(
            self.store
                .scope(
                    state: ViewState.init(state:),
                    action: { $0 }
                )
        )
    }

    var body: some View {
        NavigationView {
            WalkthroughContainer(store)
            NavigationLink.emptyHidden(viewStore.state.isLoginActive,
                                       LoginView.init(store: store.scope(state: { $0 }, action: { .login($0) })))
//            ViewBuilder.buildBlock(
//                viewStore.state.shouldShowWalkthrough ?
//                    ViewBuilder.buildEither(first: )
//                    :
//                    ViewBuilder.buildEither(
//                        second:
//                            LoginView(
//                                store:
//                                    self.store.scope(
//                                        state: { $0 },
//                                        action: { .login($0)}
//                                    )
//                            )
//                    )
//            )
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
