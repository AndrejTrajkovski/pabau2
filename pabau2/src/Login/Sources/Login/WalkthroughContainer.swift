import SwiftUI
import ComposableArchitecture
import Util
import Model

public struct WalkthroughContainerState: Equatable {
	public init (navigation: [LoginNavScreen],
							 loginViewState: LoginViewState) {
		self.navigation = navigation
		self.loginViewState = loginViewState
	}
	public var navigation: [LoginNavScreen]
	public var loginViewState: LoginViewState
}

public struct WalkthroughContainer: View {
	let store: Store<WalkthroughContainerState, WalkthroughContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, WalkthroughContainerAction>
	struct ViewState: Equatable {
		let isSignInActive: Bool
		init(state: WalkthroughContainerState) {
			self.isSignInActive = state.navigation.contains(.signInScreen)
		}
	}
	public init(_ store: Store<WalkthroughContainerState, WalkthroughContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store
			.scope(state: ViewState.init(state:),
						 action: { $0 }))
		print("WalkthroughContainer init")
	}

	public var body: some View {
		print("WalkthroughContainer body")
		return VStack(spacing: 50) {
			Walkthrough(action: {
				self.viewStore.send(.walkthrough(.signInTapped))
			}).onAppear {
				self.viewStore.send(.walkthrough(.onAppear))
			}
			NavigationLink.emptyHidden(
				viewStore.state.isSignInActive,
					LoginView(store: self.store.scope(state: { $0 },
																						action: { .login($0)}))
			)
		}
	}
}

extension WalkthroughContainerState {
	var forgotPass: ForgotPassContainerState {
		get { return ForgotPassContainerState(navigation: navigation,
																					forgotPassLS: self.loginViewState.forgotPassLS,
																					fpValidation: self.loginViewState.fpValidation,
																					rpValidation: self.loginViewState.rpValidation,
																					rpLoading: self.loginViewState.rpLoading)}
		set {
			self.navigation = newValue.navigation
			self.loginViewState.forgotPassLS = newValue.forgotPassLS
			self.loginViewState.fpValidation = newValue.fpValidation
			self.loginViewState.rpValidation = newValue.rpValidation
			self.loginViewState.rpLoading = newValue.rpLoading
		}
	}
}

public enum WalkthroughContainerAction {
  case walkthrough(WalkthroughAction)
	case login(LoginViewAction)
}

public let walkthroughContainerReducer: Reducer<WalkthroughContainerState, WalkthroughContainerAction, LoginEnvironment> = .combine(
	walkthroughReducer.pullback(state: \WalkthroughContainerState.navigation,
					 action: /WalkthroughContainerAction.walkthrough,
					 environment: { $0 }),
	loginViewReducer.pullback(state: \WalkthroughContainerState.self,
					 action: /WalkthroughContainerAction.login,
					 environment: { $0 })
)