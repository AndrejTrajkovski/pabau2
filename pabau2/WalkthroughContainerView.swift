import SwiftUI
import PageControl
import ComposableArchitecture
import CasePaths

public struct WalkthroughViewState {
	var navigation: Navigation
	var loggedInUser: User?
	var emailValidationText: String
	var passValidationText: String
	var forgotPassLS: LoadingState<ForgotPassResponse>
	var loginLS: LoadingState<User>
	var fpValidation: String
	var rpValidation: ResetPassError?
	var rpLoading: LoadingState<ResetPassResponse>
}

extension WalkthroughViewState {
	var login: LoginViewState {
		get {
			return LoginViewState(loggedInUser: self.loggedInUser,
														navigation: self.navigation,
														forgotPassLS: self.forgotPassLS,
														loginLS: self.loginLS,
														fpValidation: fpValidation,
														rpValidation: rpValidation,
														rpLoading: rpLoading,
														emailValidationText: self.emailValidationText,
														passValidationText: self.passValidationText)
		}
		set {
			self.navigation = newValue.navigation
			self.loggedInUser = newValue.loggedInUser
			self.emailValidationText = newValue.emailValidationText
			self.passValidationText = newValue.passValidationText
			self.forgotPassLS = newValue.forgotPassLS
			self.loginLS = newValue.loginLS
			self.fpValidation = newValue.fpValidation
			self.rpValidation = newValue.rpValidation
			self.rpLoading = newValue.rpLoading
		}
	}
}

public enum WalkthroughViewAction {
  case walkthrough(WalkthroughAction)
	case login(LoginViewAction)
}

public enum WalkthroughAction: Equatable {
  case signInTapped
}

public let walkthroughViewReducer = combine(
pullback(walkthroughReducer, value: \WalkthroughViewState.navigation, action: /WalkthroughViewAction.walkthrough),
pullback(loginViewReducer, value: \WalkthroughViewState.login, action: /WalkthroughViewAction.login)
)

public func walkthroughReducer(state: inout Navigation, action: WalkthroughAction) -> [Effect<WalkthroughAction>] {
	switch action {
	case .signInTapped:
		state.login?.insert(.signInScreen)
		return []
	}
}

struct WalkthroughStatic {
	static let titles = [Texts.walkthrough1,
											 Texts.walkthrough2,
											 Texts.walkthrough3,
											 Texts.walkthrough4]
	static let description = [Texts.walkthroughDes1,
														Texts.walkthroughDes2,
														Texts.walkthroughDes3,
														Texts.walkthroughDes4]
	static let images = ["illu-walkthrough-1",
											 "illu-walkthrough-2",
											 "illu-walkthrough-3",
											 "illu-walkthrough-4"]
}

func makeState(titles: [String], descs: [String], imageTitles: [String]) -> [WalkthroughContentContent] {
	let zipped1 = zip(titles, descs)
	let zipped2 = zip(zipped1, imageTitles)
	return zipped2.map {
		return WalkthroughContentContent.init(title: $0.0, description: $0.1,
																				imageTitle: $1)
	}
}

struct WalkthroughContainerView: View {
	@ObservedObject var store: Store<WalkthroughViewState, WalkthroughViewAction>
	let state = makeState(titles: WalkthroughStatic.titles,
												descs: WalkthroughStatic.description,
												imageTitles: WalkthroughStatic.images)
	var body: some View {
		VStack(spacing: 50) {
			PageView(state.map { WalkthroughContentView(state: $0)})
				.frame(maxHeight: 686.0)
			BigButton(text: Texts.signIn,
								buttonTapAction: {
									self.store.send(.walkthrough(.signInTapped))
			})
			NavigationLink.emptyHidden(destination:
				LoginView(store:
				self.store.view(value: { $0.login },
												action: { .login($0)})), isActive: self.store.value.navigation.login?.contains(.signInScreen) ?? false)
		}
	}
}
