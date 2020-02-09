import SwiftUI
import ComposableArchitecture

public struct ResetPasswordState {
	var navigation: Navigation
}

public enum ResetPasswordAction {
	case backBtnTapped
	case changePassTapped
}

public func resetPassReducer(state: inout ResetPasswordState, action: ResetPasswordAction) -> [Effect<ResetPasswordAction>] {
	switch action {
	case .backBtnTapped:
		state.navigation.login?.remove(.resetPassScreen)
		return []
	case .changePassTapped:
		return []
	}
}

struct ResetPassword: View {
	var store: Store<ResetPasswordState, ResetPasswordAction>
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
					TextAndTextView(title: Texts.resetCode.uppercased(), placeholder: Texts.resetCodePlaceholder, value: $code)
					TextAndTextView(title: Texts.newPass.uppercased(), placeholder: Texts.newPassPlaceholder, value: $newPass)
					TextAndTextView(title: Texts.confirmPass.uppercased(), placeholder: Texts.confirmPassPlaceholder, value: $confirmPass)
				}.frame(maxWidth: 319)
				BigButton(text: Texts.changePass) {
					self.store.send(.changePassTapped)
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
