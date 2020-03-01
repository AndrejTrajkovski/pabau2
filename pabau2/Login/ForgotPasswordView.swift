import SwiftUI
import ComposableArchitecture
import Combine
import CasePaths
import Util
import Model

public enum ForgotPassViewAction {
	case forgotPass(ForgotPasswordAction)
	case resetPass(ResetPasswordAction)
	case checkEmail(CheckEmailAction)
	case passChanged(PassChangedAction)
}

public struct ForgotPassContainerState {
	var navigation: Navigation
	var forgotPassLS: LoadingState<ForgotPassSuccess>
	var fpValidation: String
	var rpValidation: RPValidator
	var rpLoading: LoadingState<ResetPassSuccess>
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
																		rpValidation: rpValidation, loadingState: rpLoading)}
		set {
			self.navigation = newValue.navigation
			self.rpValidation = newValue.rpValidation
			self.rpLoading = newValue.loadingState
		}
	}
}

public struct ForgotPassState {
	var navigation: Navigation
	var loadingState: LoadingState<ForgotPassSuccess>
	var fpValidation: String
}

let forgotPassViewReducer = combine(
	pullback(forgotPasswordReducer, value: \ForgotPassContainerState.forgotPass, action: /ForgotPassViewAction.forgotPass),
	pullback(resetPassReducer, value: \ForgotPassContainerState.resetPass, action: /ForgotPassViewAction.resetPass),
	pullback(checkEmailReducer, value: \ForgotPassContainerState.navigation, action: /ForgotPassViewAction.checkEmail),
	pullback(passChangedReducer, value: \ForgotPassContainerState.navigation, action: /ForgotPassViewAction.passChanged)
)

public func forgotPasswordReducer(state: inout ForgotPassState, action: ForgotPasswordAction) -> [Effect<ForgotPasswordAction>] {
	switch action {
	case .backBtnTapped:
		state.navigation.login?.removeAll(where: { $0 == .forgotPassScreen })
		return []
	case .sendRequest(let email):
		let isValid = isValidEmail(email)
		state.fpValidation = emailValidationText(isValid)
		if isValid {
			state.loadingState = .loading
			return [
				resetPass(email)
					.map(ForgotPasswordAction.gotResponse)
				.receive(on: DispatchQueue.main)
				.eraseToEffect()
			]
		} else {
			return []
		}
	case .gotResponse(let result):
		switch result {
		case .success(let success):
			state.loadingState = .gotSuccess(success)
			state.navigation.login?.append(.checkEmailScreen)
		case .failure(let error):
			state.loadingState = .gotError(error)
		}
		return []
	}
}

public enum ForgotPasswordAction {
	case backBtnTapped
	case sendRequest(email: String)
	case gotResponse(Result<ForgotPassSuccess, ForgotPassError>)
}

struct ForgotPassword: View {
	@ObservedObject var store: Store<ForgotPassState, ForgotPasswordAction>
	@Binding private var email: String
	init(_ store: Store<ForgotPassState, ForgotPasswordAction>, _ email: Binding<String>) {
		self.store = store
		self._email = email
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 25) {
			VStack(alignment: .leading, spacing: 36) {
				Text(Texts.forgotPass)
					.foregroundColor(.blackTwo)
					.font(.customLargeTitle)
					.frame(width: 157)
				Text(Texts.forgotPassDescription)
					.foregroundColor(.grey155)
					.font(.paragraph)
				TextAndTextView(title: Texts.emailAddress.uppercased(), placeholder: "", bindingValue: self.$email, validation: self.store.value.fpValidation)
			}.frame(maxWidth: 319)
			BigButton(text: Texts.sendRequest) {
				self.store.send(.sendRequest(email: self.email))
			}
		}
		.frame(minWidth: 280, maxWidth: 495)
		.fixedSize(horizontal: false, vertical: true)
		.customBackButton {
			self.store.send(.backBtnTapped)
		}
	}
}

struct ForgotPasswordView: View {
	@ObservedObject var store: Store<ForgotPassContainerState, ForgotPassViewAction>
	@Binding private var email: String
	init(_ store: Store<ForgotPassContainerState, ForgotPassViewAction>, _ email: Binding<String>) {
		self.store = store
		_email = email
	}
	var body: some View {
		LoadingView(title: Texts.forgotPassLoading, bindingIsShowing: .constant(self.store.value.forgotPass.loadingState.isLoading)) {
			VStack(alignment: .leading, spacing: 36) {
				ForgotPassword(self.store.view(value: { $0.forgotPass }, action: { .forgotPass($0)}), self.$email)
				NavigationLink.emptyHidden(destination: self.checkEmailView,
																	 isActive: self.store.value.navigation.login?.contains(.checkEmailScreen) ?? false)
				Spacer()
			}
		}
	}

	var checkEmailView: CheckEmail {
		CheckEmail(resetPassStore: resetPassStore,
							 passChangedStore: passChangedStore,
							 store: self.store.view(value: { $0.navigation },
																			action: { .checkEmail($0)}))
	}

	var passChangedStore: Store<Navigation, PassChangedAction> {
		self.store.view(value: { $0.navigation }, action: { .passChanged($0)})
	}
	var resetPassStore: Store<ResetPasswordState, ResetPasswordAction> {
		self.store.view(value: { $0.resetPass }, action: { .resetPass($0)})
	}
}
