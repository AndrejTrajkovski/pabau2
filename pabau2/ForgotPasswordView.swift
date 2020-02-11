import SwiftUI
import ComposableArchitecture
import Combine
import CasePaths

public enum ForgotPassError: Error {}
public struct ForgotPassResponse {}

func resetPass(_ email: String) -> Effect<Result<ForgotPassResponse, ForgotPassError>> {
	return Just(.success(ForgotPassResponse()))
		.delay(for: .seconds(1), scheduler: DispatchQueue.main)
		.eraseToEffect()
}

public enum ForgotPassViewAction {
	case forgotPass(ForgotPasswordAction)
	case resetPass(ResetPasswordAction)
	case checkEmail(CheckEmailAction)
}

public struct ForgotPassViewState {
	var navigation: Navigation
	var forgotPassLS: LoadingState<ForgotPassResponse>
	var fpValidation: String
	var rpValidation: ResetPassError?
	var rpLoading: LoadingState<ResetPassResponse>
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

public enum LoadingState<Value> {
	case initial
	case loading
	case gotSuccess(Value)
	case gotError(Error)
	var isLoading: Bool {
		guard case LoadingState.loading = self else { return false }
		return true
	}
}

public struct ForgotPassState {
	var navigation: Navigation
	var loadingState: LoadingState<ForgotPassResponse>
	var fpValidation: String
}

let forgotPassViewReducer = combine(
	pullback(forgotPasswordReducer, value: \ForgotPassViewState.forgotPass, action: /ForgotPassViewAction.forgotPass),
	pullback(resetPassReducer, value: \ForgotPassViewState.resetPass, action: /ForgotPassViewAction.resetPass),
	pullback(checkEmailReducer, value: \ForgotPassViewState.navigation, action: /ForgotPassViewAction.checkEmail)
)

public func forgotPasswordReducer(state: inout ForgotPassState, action: ForgotPasswordAction) -> [Effect<ForgotPasswordAction>] {
	switch action {
	case .backBtnTapped:
		state.navigation.login?.remove(.forgotPassScreen)
		return []
	case .sendRequest(let email):
		if isValidEmail(email) {
			state.loadingState = .loading
			return [
				resetPass(email)
					.map(ForgotPasswordAction.gotResponse)
				.receive(on: DispatchQueue.main)
				.eraseToEffect()
			]
		} else {
			state.fpValidation = Texts.invalidEmail
			return []
		}
	case .gotResponse(let result):
		switch result {
		case .success(let success):
			state.loadingState = .gotSuccess(success)
			state.navigation.login?.insert(.checkEmailScreen)
		case .failure(let error):
			state.loadingState = .gotError(error)
		}
		return []
	}
}

public enum ForgotPasswordAction {
	case backBtnTapped
	case sendRequest(email: String)
	case gotResponse(Result<ForgotPassResponse, ForgotPassError>)
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
					.font(.largeTitle)
					.frame(width: 157)
				Text(Texts.forgotPassDescription)
					.foregroundColor(.grey155)
					.font(.paragraph)
				TextAndTextView(title: Texts.emailAddress.uppercased(), placeholder: "", value: self.$email, validation: self.store.value.fpValidation)
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
	@ObservedObject var store: Store<ForgotPassViewState, ForgotPassViewAction>
	@Binding private var email: String
	init(_ store: Store<ForgotPassViewState, ForgotPassViewAction>, _ email: Binding<String>) {
		self.store = store
		_email = email
	}
	var body: some View {
		LoadingView(title: Texts.forgotPassLoading, isShowing: .constant(self.store.value.forgotPass.loadingState.isLoading)) {
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
							 store: self.store.view(value: { $0.navigation },
																			action: { .checkEmail($0)}))
	}

	var resetPassStore: Store<ResetPasswordState, ResetPasswordAction> {
		self.store.view(value: { $0.resetPass }, action: { .resetPass($0)})
	}
}
