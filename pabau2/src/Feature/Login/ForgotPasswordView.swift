import SwiftUI
import ComposableArchitecture
import Combine
import CasePaths
import Util
import Model

public enum ForgotPassViewAction: Equatable {
	case forgotPass(ForgotPasswordAction)
	case resetPass(ResetPasswordAction)
	case checkEmail(CheckEmailAction)
	case passChanged(PassChangedAction)
}

public struct ForgotPassContainerState: Equatable {
	var navigation: [LoginNavScreen]
	var forgotPassLS: LoadingState
	var fpValidation: String
	var rpValidation: RPValidator
	var rpLoading: LoadingState
	var forgotPass: ForgotPassState {
		get { return ForgotPassState(navigation: navigation,
																 loadingState: forgotPassLS,
																 fpValidation: fpValidation)}
		set {
			self.forgotPassLS = newValue.loadingState
			self.navigation = newValue.navigation
			self.fpValidation = newValue.fpValidation
		}
	}
	var resetPass: ResetPasswordState {
		get { return ResetPasswordState(navigation: navigation,
																		rpValidation: rpValidation,
																		loadingState: rpLoading)}
		set {
			self.navigation = newValue.navigation
			self.rpValidation = newValue.rpValidation
			self.rpLoading = newValue.loadingState
		}
	}
}

public struct ForgotPassState: Equatable {
	var navigation: [LoginNavScreen]
	var loadingState: LoadingState
	var fpValidation: String
}

let forgotPassViewReducer: Reducer<ForgotPassContainerState,
	ForgotPassViewAction,
	LoginEnvironment> = .combine(
		forgotPasswordReducer.pullback(
					 value: \ForgotPassContainerState.forgotPass,
					 action: /ForgotPassViewAction.forgotPass,
					 environment: { $0 }),
		resetPassReducer.pullback(
					 value: \ForgotPassContainerState.resetPass,
					 action: /ForgotPassViewAction.resetPass,
					 environment: { $0 }),
		checkEmailReducer.pullback(
					 value: \ForgotPassContainerState.navigation,
					 action: /ForgotPassViewAction.checkEmail,
					 environment: { $0 }),
		passChangedReducer.pullback(
					 value: \ForgotPassContainerState.navigation,
					 action: /ForgotPassViewAction.passChanged,
					 environment: { $0 })
)

let forgotPasswordReducer = Reducer<ForgotPassState, ForgotPasswordAction, LoginEnvironment> { state, action, environment in
		switch action {
		case .backBtnTapped:
			state.navigation.removeAll(where: { $0 == .forgotPassScreen })
			return []
		case .sendRequest(let email):
			let isValid = isValidEmail(email)
			state.fpValidation = emailValidationText(isValid)
			if isValid {
				state.loadingState = .loading
				return [
					environment.apiClient.resetPass(email)
						.map(ForgotPasswordAction.gotResponse)
						.receive(on: DispatchQueue.main)
						.eraseToEffect()
				]
			} else {
				return []
			}
		case .gotResponse(let result):
			switch result {
			case .success:
				state.loadingState = .gotSuccess
				state.navigation.append(.checkEmailScreen)
			case .failure:
				state.loadingState = .gotError
			}
			return []
		}
}

public enum ForgotPasswordAction: Equatable {
	case backBtnTapped
	case sendRequest(email: String)
	case gotResponse(Result<ForgotPassSuccess, ForgotPassError>)
}

struct ForgotPassword: View {
	let store: Store<ForgotPassState, ForgotPasswordAction>
	@ObservedObject var viewStore: ViewStore<ForgotPassState, ForgotPasswordAction>
	@Binding private var email: String
	init(_ store: Store<ForgotPassState, ForgotPasswordAction>,
			 _ email: Binding<String>) {
		self.store = store
		self.viewStore = self.store.view
		self._email = email
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 25) {
			VStack(alignment: .leading, spacing: 36) {
				Text(Texts.forgotPass)
					.foregroundColor(.blackTwo)
					.font(.bold34)
					.frame(width: 157)
				Text(Texts.forgotPassDescription)
					.foregroundColor(.grey155)
					.font(.medium16)
				TextAndTextField(Texts.emailAddress.uppercased(),
												 self.$email,
												 "",
												 self.viewStore.value.fpValidation)
			}.frame(maxWidth: 319)
			BigButton(text: Texts.sendRequest) {
				self.viewStore.send(.sendRequest(email: self.email))
			}
		}
		.frame(minWidth: 280, maxWidth: 495)
		.fixedSize(horizontal: false, vertical: true)
		.customBackButton {
			self.viewStore.send(.backBtnTapped)
		}
	}
}

struct ForgotPasswordView: View {
	let store: Store<ForgotPassContainerState, ForgotPassViewAction>
	@ObservedObject var viewStore: ViewStore<ForgotPassContainerState, ForgotPassViewAction>
	@Binding private var email: String
	init(_ store: Store<ForgotPassContainerState, ForgotPassViewAction>, _ email: Binding<String>) {
		self.store = store
		self.viewStore = self.store.view
		_email = email
		print("ForgotPasswordView init")
	}
	var body: some View {
		print("ForgotPasswordView body")
		return VStack(alignment: .leading, spacing: 36) {
			ForgotPassword(self.store.scope(value: { $0.forgotPass }, action: { .forgotPass($0)}), self.$email)
			NavigationLink.emptyHidden(
				self.viewStore.value.navigation.contains(.checkEmailScreen),
				self.checkEmailView)
			Spacer()
		}.loadingView(.constant(self.viewStore.value.forgotPass.loadingState.isLoading),
									Texts.forgotPassLoading)
	}

	var checkEmailView: CheckEmail {
		CheckEmail(store: self.store.scope(value: { $0.navigation },
																			 action: { .checkEmail($0)}),
							 resetPassStore: resetPassStore,
							 passChangedStore: passChangedStore
		)
	}

	var passChangedStore: Store<[LoginNavScreen], PassChangedAction> {
		self.store.scope(value: { $0.navigation }, action: { .passChanged($0)})
	}
	var resetPassStore: Store<ResetPasswordState, ResetPasswordAction> {
		self.store.scope(value: { $0.resetPass }, action: { .resetPass($0)})
	}
}
