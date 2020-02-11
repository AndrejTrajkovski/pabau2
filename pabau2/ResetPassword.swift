import SwiftUI
import ComposableArchitecture
import Combine

public struct ResetPassResponse {}

func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassResponse, ResetPassError>> {
	return Just(.success(ResetPassResponse()))
		.delay(for: .seconds(2), scheduler: DispatchQueue.main)
		.eraseToEffect()
}

public struct ResetPasswordState {
	var navigation: Navigation
	var rpValidation: ResetPassError?
	var loadingState: LoadingState<ResetPassResponse>
	var newPassValidator: String {
		if case .newPassEmpty = rpValidation {
			return rpValidation!.localizedDescription
		} else if case .nonMatchingPasswords = rpValidation {
			return rpValidation!.localizedDescription
		} else {
			return ""
		}
	}
	var confirmPassValidator: String {
		if case .confirmPassEmpty = rpValidation {
			return rpValidation!.localizedDescription
		} else if case .nonMatchingPasswords = rpValidation {
			return rpValidation!.localizedDescription
		} else {
			return ""
		}
	}
	var codeValidator: String {
		if case .emptyCode = rpValidation {
			return rpValidation!.localizedDescription
		} else {
			return ""
		}
	}
}

public enum ResetPasswordAction {
	case backBtnTapped
	case changePassTapped(String, String, String)
	case gotResponse(Result<ResetPassResponse, ResetPassError>)
}

func validate(_ code: String, _ newPass: String, _ confirmPass: String) -> Result<(String, String), ResetPassError> {
	if newPass != confirmPass {
		return .failure(.nonMatchingPasswords)
	} else if newPass.isEmpty {
		return .failure(.newPassEmpty)
	} else if confirmPass.isEmpty {
		return .failure(.confirmPassEmpty)
	} else if code.isEmpty {
		return .failure(.emptyCode)
	} else {
		return .success((code, newPass))
	}
}

public enum ResetPassError: Error {
	case newPassEmpty
	case confirmPassEmpty
	case nonMatchingPasswords
	case emptyCode
	public var localizedDescription: String {
		switch self {
		case .newPassEmpty:
			return Texts.emptyPasswords
		case .confirmPassEmpty:
			return Texts.emptyPasswords
		case .nonMatchingPasswords:
			return Texts.passwordsDontMatch
		case .emptyCode:
			return Texts.emptyCode
		}
	}
}

func handle (_ code: String, _ newPass: String, _ confirmPass: String, _ state: inout ResetPasswordState) -> [Effect<ResetPasswordAction>] {
	let validated = validate(code, newPass, confirmPass)
	switch validated {
	case .success(let code, let newPass):
		state.rpValidation = nil
		state.loadingState = .loading
		return [
			sendConfirmation(code, newPass)
				.map(ResetPasswordAction.gotResponse)
				.eraseToEffect()
		]
	case .failure(let error):
		state.rpValidation = error
		return []
	}
}

func handle(_ result: Result<ResetPassResponse, ResetPassError>, _ state: inout ResetPasswordState) ->  [Effect<ResetPasswordAction>] {
	switch result {
	case .success(let success):
		state.loadingState = .gotSuccess(success)
		state.navigation.login?.insert(.passChangedScreen)
		return []
	case .failure(let error):
		state.loadingState = .gotError(error)
		state.rpValidation = error
		return []
	}
}

public func resetPassReducer(state: inout ResetPasswordState, action: ResetPasswordAction) -> [Effect<ResetPasswordAction>] {
	switch action {
	case .backBtnTapped:
		state.navigation.login?.remove(.resetPassScreen)
		return []
	case .changePassTapped(let code, let newPass, let confirmPass):
		return handle(code, newPass, confirmPass, &state)
	case .gotResponse(let result):
		return handle(result, &state)
	}
}

struct ResetPassword: View {
	let passChangedStore: Store<Navigation, PassChangedAction>
	@ObservedObject var store: Store<ResetPasswordState, ResetPasswordAction>
	@State var code: String = ""
	@State var newPass: String = ""
	@State var confirmPass: String = ""
	var body: some View {
		LoadingView(title: Texts.verifyingCode, isShowing: .constant(self.store.value.loadingState.isLoading)) {
			VStack {
				VStack(alignment: .leading, spacing: 25) {
					VStack(alignment: .leading, spacing: 36) {
						Text(Texts.resetPass)
							.foregroundColor(.blackTwo)
							.font(.largeTitle)
							.frame(width: 157)
						Text(Texts.resetPassDesc)
							.foregroundColor(.grey155)
							.font(.paragraph)
						TextAndTextView(title: Texts.resetCode.uppercased(),
														placeholder: Texts.resetCodePlaceholder,
														value: self.$code,
														validation: self.store.value.codeValidator)
						TextAndTextView(title: Texts.newPass.uppercased(),
														placeholder: Texts.newPassPlaceholder,
														value: self.$newPass,
														validation: self.store.value.newPassValidator)
						TextAndTextView(title: Texts.confirmPass.uppercased(),
														placeholder: Texts.confirmPassPlaceholder,
														value: self.$confirmPass,
														validation: self.store.value.confirmPassValidator)
					}.frame(maxWidth: 319)
					BigButton(text: Texts.changePass) {
						self.store.send(.changePassTapped(self.code, self.newPass, self.confirmPass))
					}
					NavigationLink.emptyHidden(destination: self.passChangedView,
																		 isActive: self.store.value.navigation.login?.contains(.passChangedScreen) ?? false)
				}
				.frame(minWidth: 280, maxWidth: 495)
				.fixedSize(horizontal: false, vertical: true)
				.customBackButton {
					self.store.send(.backBtnTapped)
				}
				Spacer()
			}
		}
	}
	
	var passChangedView: PasswordChanged {
		PasswordChanged(store: passChangedStore)
	}
}
