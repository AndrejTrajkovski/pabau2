import SwiftUI
import Combine
import ComposableArchitecture
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
	var navigation: [LoginNavScreen]
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

func handle (_ code: String, _ newPass: String, _ confirmPass: String, _ state: inout ResetPasswordState, _ apiClient: LoginAPI) -> Effect<ResetPasswordAction, Never> {
	let validated = validate(code, newPass, confirmPass)
	state.rpValidation = validated
	switch validated {
	case .success(let resetPassReq):
		state.loadingState = .loading
		return apiClient.sendConfirmation(resetPassReq.code, resetPassReq.newPass)
			.catchToEffect()
			.map(ResetPasswordAction.gotResponse)
			.eraseToEffect()
	case .failure:
		return .none
	}
}

func handle(_ result: Result<ResetPassSuccess, RequestError>, _ state: inout ResetPasswordState) -> Effect<ResetPasswordAction, Never> {
	switch result {
	case .success:
		state.loadingState = .gotSuccess
		state.navigation.append(.passChangedScreen)
		return .none
	case .failure(let error):
		state.loadingState = .gotError(error)
		return .none
	}
}

public let resetPassReducer = Reducer<ResetPasswordState, ResetPasswordAction, LoginEnvironment> { state, action, environment in
	switch action {
	case .backBtnTapped:
		state.navigation.removeAll(where: { $0 == .resetPassScreen })
		return .none
	case .changePassTapped(let code, let newPass, let confirmPass):
		return handle(code, newPass, confirmPass, &state, environment.apiClient)
	case .gotResponse(let result):
		return handle(result, &state)
	}
}

struct ResetPassword: View {
	let store: Store<ResetPasswordState, ResetPasswordAction>
	@ObservedObject var viewStore: ViewStore<ResetPasswordState, ResetPasswordAction>
	init (store: Store<ResetPasswordState, ResetPasswordAction>,
				passChangedStore: Store<[LoginNavScreen], PassChangedAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
		self.passChangedStore = passChangedStore
	}
	//
	let passChangedStore: Store<[LoginNavScreen], PassChangedAction>
	@State var code: String = ""
	@State var newPass: String = ""
	@State var confirmPass: String = ""
	var body: some View {
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
					TextAndTextField( Texts.resetCode.uppercased(),
														self.$code,
														Texts.resetCodePlaceholder,
														self.viewStore.state.codeValidator)
					TextAndTextField( Texts.newPass.uppercased(),
														self.$newPass,
														Texts.newPassPlaceholder,
														self.viewStore.state.newPassValidator)
					TextAndTextField( Texts.confirmPass.uppercased(),
														self.$confirmPass,
														Texts.confirmPassPlaceholder,
														self.viewStore.state.confirmPassValidator)
				}.frame(maxWidth: 319)
				PrimaryButton(Texts.changePass) {
					self.viewStore.send(
						.changePassTapped(self.code, self.newPass, self.confirmPass))
				}.frame(minWidth: 304, maxWidth: 495)
				NavigationLink.emptyHidden(
					self.viewStore.state.navigation.contains(.passChangedScreen),
					self.passChangedView)
			}
			.frame(minWidth: 280, maxWidth: 495)
			.fixedSize(horizontal: false, vertical: true)
			.customBackButton {
				self.viewStore.send(.backBtnTapped)
			}
			Spacer()
		}.loadingView(.constant(self.viewStore.state.loadingState.isLoading),
									Texts.verifyingCode)
	}

	var passChangedView: PasswordChanged {
		return PasswordChanged(store: passChangedStore)
	}
}
