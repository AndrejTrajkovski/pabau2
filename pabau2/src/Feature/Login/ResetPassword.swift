import SwiftUI
import ComposableArchitecture
import Combine
import CasePaths
import Util
import Model

public enum ResetPassValidationError: Error, Equatable {
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

extension Array: Error where Element == ResetPassValidationError {}

enum Authentication {
	case authenticated(accessToken: String)
	case unauthenticated
}
public typealias RPValidator = Result<ResetPassRequest, [ResetPassValidationError]>

public struct ResetPassRequest: Equatable {
	var code: String
	var newPass: String
}

public struct ResetPasswordState: Equatable {
	var navigation: Navigation
	var rpValidation: RPValidator
	var loadingState: LoadingState
	var newPassValidator: String {
		guard let rpFailure = (/RPValidator.failure).extract(from: rpValidation) else {
			return ""
		}
		if let newPassEmpty = rpFailure.first(where: { $0 == .newPassEmpty}) {
			return newPassEmpty.localizedDescription
		} else if let nonMatchingPasswords = rpFailure.first(where: { $0 == .nonMatchingPasswords}) {
			return nonMatchingPasswords.localizedDescription
		} else {
			return ""
		}
	}
	var confirmPassValidator: String {
		guard let rpFailure = (/RPValidator.failure).extract(from: rpValidation) else {
			return ""
		}
		if let confirmPassEmpty = rpFailure.first(where: { $0 == .confirmPassEmpty}) {
			return confirmPassEmpty.localizedDescription
		} else if let nonMatchingPasswords = rpFailure.first(where: { $0 == .nonMatchingPasswords}) {
			return nonMatchingPasswords.localizedDescription
		} else {
			return ""
		}
	}

	var codeValidator: String {
		guard let rpFailure = (/RPValidator.failure).extract(from: rpValidation) else {
			return ""
		}
		if let emptyCode = rpFailure.first(where: { $0 == .emptyCode}) {
			return emptyCode.localizedDescription
		} else {
			return ""
		}
	}
}

public enum ResetPasswordAction: Equatable {
	case backBtnTapped
	case changePassTapped(String, String, String)
	case gotResponse(Result<ResetPassSuccess, RequestError>)
}

func validate(_ code: String, _ newPass: String, _ confirmPass: String) -> RPValidator {
	var errors = [ResetPassValidationError]()
	if newPass != confirmPass {
		errors.append(.nonMatchingPasswords)
	}
	if newPass.isEmpty {
		errors.append(.newPassEmpty)
	}
	if confirmPass.isEmpty {
		errors.append(.confirmPassEmpty)
	}
	if code.isEmpty {
		errors.append(.emptyCode)
	}

	if errors.isEmpty {
		return .success(ResetPassRequest(code: code, newPass: newPass))
	} else {
		return .failure(errors)
	}
}

func handle (_ code: String, _ newPass: String, _ confirmPass: String, _ state: inout ResetPasswordState, _ apiClient: LoginAPI) -> [Effect<ResetPasswordAction>] {
	let validated = validate(code, newPass, confirmPass)
	state.rpValidation = validated
	switch validated {
	case .success(let resetPassReq):
		state.loadingState = .loading
		return [
			apiClient.sendConfirmation(resetPassReq.code, resetPassReq.newPass)
				.map(ResetPasswordAction.gotResponse)
				.eraseToEffect()
		]
	case .failure:
		return []
	}
}

func handle(_ result: Result<ResetPassSuccess, RequestError>, _ state: inout ResetPasswordState) ->  [Effect<ResetPasswordAction>] {
	switch result {
	case .success:
		state.loadingState = .gotSuccess
		state.navigation.login?.append(.passChangedScreen)
		return []
	case .failure:
		state.loadingState = .gotError
		return []
	}
}

public func resetPassReducer(state: inout ResetPasswordState, action: ResetPasswordAction, environment: LoginEnvironment) -> [Effect<ResetPasswordAction>] {
	switch action {
	case .backBtnTapped:
		state.navigation.login?.removeAll(where: { $0 == .resetPassScreen })
		return []
	case .changePassTapped(let code, let newPass, let confirmPass):
		return handle(code, newPass, confirmPass, &state, environment.apiClient)
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
		LoadingView(title: Texts.verifyingCode, bindingIsShowing: .constant(self.store.value.loadingState.isLoading)) {
			VStack {
				VStack(alignment: .leading, spacing: 25) {
					VStack(alignment: .leading, spacing: 36) {
						Text(Texts.resetPass)
							.foregroundColor(.blackTwo)
							.font(.bold34)
							.frame(width: 157)
						Text(Texts.resetPassDesc)
							.foregroundColor(.grey155)
							.font(.medium16)
						TextAndTextView(title: Texts.resetCode.uppercased(),
														placeholder: Texts.resetCodePlaceholder,
														bindingValue: self.$code,
														validation: self.store.value.codeValidator)
						TextAndTextView(title: Texts.newPass.uppercased(),
														placeholder: Texts.newPassPlaceholder,
														bindingValue: self.$newPass,
														validation: self.store.value.newPassValidator)
						TextAndTextView(title: Texts.confirmPass.uppercased(),
														placeholder: Texts.confirmPassPlaceholder,
														bindingValue: self.$confirmPass,
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
		return PasswordChanged(store: passChangedStore)
	}
}
