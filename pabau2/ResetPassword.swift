import SwiftUI
import ComposableArchitecture
import Combine

public struct ResetPassResponse {}
public enum ResetPassError: Error {}

func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassResponse, ResetPassError>> {
	return Just(.success(ResetPassResponse()))
					.delay(for: .seconds(2), scheduler: DispatchQueue.main)
					.eraseToEffect()
}

public struct ResetPasswordState {
	var navigation: Navigation
	var rpValidation: String
}

public enum ResetPasswordAction {
	case backBtnTapped
	case changePassTapped(String, String, String)
	case gotResponse(Result<ResetPassResponse, ResetPassError>)
}

public func resetPassReducer(state: inout ResetPasswordState, action: ResetPasswordAction) -> [Effect<ResetPasswordAction>] {
	switch action {
	case .backBtnTapped:
		state.navigation.login?.remove(.resetPassScreen)
		return []
	case .changePassTapped(let code, let newPass, let confirmPass):
		if newPass == confirmPass {
			state.rpValidation = ""
			return [
				sendConfirmation(code, newPass)
					.map(ResetPasswordAction.gotResponse)
					.eraseToEffect()
			]
		} else {
			state.rpValidation = Texts.passwordsDontMatch
			return []
		}
	case .gotResponse(let result):
		switch result {
		case .success:
			state.navigation.login?.remove(.resetPassScreen)
			state.navigation.login?.remove(.forgotPassScreen)
			return []
		case .failure(let error):
			state.rpValidation = error.localizedDescription
			return []
		}
	}
}

struct ResetPassword: View {
	@ObservedObject var store: Store<ResetPasswordState, ResetPasswordAction>
	@State var code: String = ""
	@State var newPass: String = ""
	@State var confirmPass: String = ""
	
	var body: some View {
		VStack {
			VStack(alignment: .leading, spacing: 25) {
				VStack(alignment: .leading, spacing: 36) {
					Text(Texts.resetPass)
						.foregroundColor(.blackTwo)
						.font(.largeTitle)
						.frame(width: 157)
					Text(Texts.forgotPassDescription)
						.foregroundColor(.grey155)
						.font(.paragraph)
					TextAndTextView(title: Texts.resetCode.uppercased(), placeholder: Texts.resetCodePlaceholder, value: $code, validation: "")
					TextAndTextView(title: Texts.newPass.uppercased(), placeholder: Texts.newPassPlaceholder, value: $newPass, validation: "")
					TextAndTextView(title: Texts.confirmPass.uppercased(), placeholder: Texts.confirmPassPlaceholder, value: $confirmPass, validation: "")
				}.frame(maxWidth: 319)
				BigButton(text: Texts.changePass) {
					self.store.send(.changePassTapped(self.code, self.newPass, self.confirmPass))
				}
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
